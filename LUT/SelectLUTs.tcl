# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
foreach {property value} {
    tech tsmc040
    device nch
    size 500
    th 5
    topv 1.1
    max_wbyl 10
    min_wbyl 0.5
    process ss
} {
    default ::opt($property) $value
}
array set ::corner_to_temp {
    ss 125
    tt 27
    ff -40
    fs 27
    sf 27
    mc 27
}
set epsilon 1e-2
set process $::opt(process)
set temp $::corner_to_temp($process)
set max_needed_volume 1e12
source $::env(RAMSPICE)/tests/geo_values.tcl
source $::env(RAMSPICE)/Tech_DB/$::opt(tech)/binning_$::opt(tech).tcl
set p [string index $::opt(device) 0]
if {$p=="p"} {
    set opt(topv) [expr -$opt(topv)]
}
set minw [set ::global_${p}wmin]
set minl [set ::global_${p}lmin]
set maxw [set ::global_${p}wmax]
set maxl [set ::global_${p}lmax]

foreach db_file [glob $::env(RAMSPICE)/Tech_DB/$::opt(tech)/4d/*/$::opt(tech)_$::opt(device)_ids.db] {
    set path [file dirname $db_file]
    source $path/$::opt(tech)_$::opt(device)_min_vt.tcl
    set rez [file tail $path]
    set volume 4
    foreach dim_rez [split $rez :] {
        set volume [expr $volume*(pow(2,$dim_rez)+1)]
    }
   # skip {$volume>$max_needed_volume}
    @ /look_up_tables/$::opt(device) load $db_file
    @ /look_up_tables/$::opt(device) load $path/$::opt(tech)_$::opt(device)_gm.db
    @ /look_up_tables/$::opt(device) load $path/$::opt(tech)_$::opt(device)_ro.db
    for {set max_wbyl $opt(max_wbyl)} {$max_wbyl<=$opt(max_wbyl)} {incr max_wbyl} {
        array unset hist
        set error_list {}
        set trail {}
        while {[llength $trail]<$::opt(size)} {
            set L [expr $minl+rand()*($maxl-$minl)]
	    set WbyL [expr $::opt(min_wbyl)+rand()*($::opt(max_wbyl)-$::opt(min_wbyl))]
            set W [expr $WbyL*$L]
            set s [find_mosfet_bin $p $L $W]
            skip {$W>$::bin($p,$s,wmax)}
            skip {$W<$::bin($p,$s,wmin)}
            set Vgs [expr $minVt+($::opt(topv)-$minVt)*rand()]
            set Vds [expr $::opt(topv)*rand()]
            set Vbs [expr -$::opt(topv)*rand()/6]
            lappend trail [list $Vgs $Vds $Vbs $L $W]
        }
	Info: Trail Length=[llength $trail]
        for {set s 1} {[info exists ::bin(n,$s,lmin)]} {incr s} {
           # Info: "Analyzing Bin=$s"
            netlist ".include $::env(RAMSPICE)/Tech_DB/$::opt(tech)/$::opt(tech).sp"
            netlist ".temp $temp"
            netlist "mn 3 1 5 4 ${::opt(device)}_${::opt(process)}_${s} L=$::bin(n,$s,lmin) W=$::bin(n,$s,lmax)"
            netlist "r5 5 0 1e-12"
            netlist "Vds 3 0 dc 0 ac 0"
            netlist "Vgs 1 0 dc 0 ac 0"
            netlist "Vbs 4 0 dc 0 ac 0"
            netlist ".end"
            update_netlist
            ::spice::op
            foreach point $trail {
                set L [lindex $point 3]
                set W [lindex $point 4]
                set s2 [find_mosfet_bin $p $L $W]
                skip {$s2!=$s}
                set Vgs [lindex $point 0]
                set Vds [lindex $point 1]
                set Vbs [lindex $point 2]
                ::spice::alter mn l = $L
                ::spice::alter mn w = $W
                ::spice::alter vgs = $Vgs
                ::spice::alter vds = $Vds
                ::spice::alter vbs = $Vbs
                ::spice::op
                if {[catch {set Ids [expr 1e12*[get_spice_data V(5) 0]]}]} {
                    Error: Ids=[get_spice_data V(5) 0]
                    continue
                }		
                if {[catch {set LUT_Ids [expr [@ /look_up_tables/$::opt(device)/Ids/$::opt(process) calc $Vgs $Vds $Vbs $L]*$W/$L]} msg ]} {
                    Error: $Vgs $Vds $Vbs $L $W [@ /look_up_tables/$::opt(device)/Ids/$::opt(process) calc $Vgs $Vds $Vbs $L] $Ids
                    continue
                }
                #	    Info: LUT_Ids=$LUT_Ids
                ::spice::alter vgs = [expr $Vgs+$epsilon]
                ::spice::op
                set Ids_gm [expr 1e12*[get_spice_data V(5) 0]]
                set gm [expr ($Ids_gm-$Ids)/$epsilon]
                if {[catch {set LUT_gm [expr [@ /look_up_tables/$::opt(device)/gm/$::opt(process) calc $Vgs $Vds $Vbs $L]*$W/$L]} msg ]} {
                    continue
                }
                ::spice::alter vgs = $Vgs
                ::spice::alter vds = [expr $Vds+$epsilon]
                ::spice::op
                set Ids_ro [expr 1e12*[get_spice_data V(5) 0]]
                set ro [expr $epsilon/($Ids_ro-$Ids)]
                if {[catch {set LUT_ro [expr [@ /look_up_tables/$::opt(device)/ro/$::opt(process) calc $Vgs $Vds $Vbs $L]*$L/$W]} msg ]} {
                    continue
                }
                set WbyL [expr $W/$L]
                if {[catch {set error [expr abs(($LUT_Ids/$Ids-1)*100)]}]} {
		    Warning: $Vgs $Vds $Vbs $L $W $LUT_Ids $Ids
		}
                
                skip {[regexp {[nN]} $error]} 
	#	Info: $Vgs $Vds $Vbs $L $W $LUT_Ids $Ids $error
                if {abs($LUT_Ids-$Ids)<=1e-7} {
                    set error 0
                }
                if {[catch {set hist_index [expr int(ceil(abs($error)))]}]} {
                    continue
                }
                if {![info exists hist($hist_index)]} {
                    set hist($hist_index) 0
                }
                incr hist($hist_index)
                lappend error_list $error
                ::spice::destroy all
            }
            ::spice::destroy all
        }
        if {[llength $error_list]==0} continue
        set error_list [lsort -real $error_list]
        set cap_index [expr int([llength $error_list]*98.0/100)-1]
        set final_error [lindex $error_list $cap_index]
###	set i 0
###	foreach err $error_list {
###	    Info: $i=$err
###	    incr i
###	}
	Info: cap_index=$cap_index Resolution=$rez Size=[eng $volume B] Sample=[llength $error_list] final_error=$final_error
	if {$final_error<=$::opt(th) && $volume<$max_needed_volume} {
	    set max_needed_volume $volume
	    set chosen_db_file $db_file
	    Info: Chosen DB file: $rez
	}
	
    }
    @ /look_up_tables/$::opt(device) delete
}
exit


