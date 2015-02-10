# \
exec $RAMSPICE/ramspice $0 $argv

get_opts
default ::opt(interpolation) LUT
default ::opt(process) ss
default ::opt(device) nch
default ::opt(tech) tsmc018
Info: Collecting $::opt(source) for $::opt(device) at $::opt(process)
array set ::corner_to_temp {
    ss 125
    tt 27
    ff -40
    fs 27
    sf 27
    mc 27
}


set output_file $::opt(source)/$::opt(device).$::opt(process).$::opt(interpolation).info
#if {[file exists $output_file]} exit
foreach table {ids gm ro} {
    if {![file exists $::opt(source)/$::opt(tech)_$::opt(device)_$table.db]} exit
}
@ /look_up_tables/$::opt(device) load $::opt(source)/$::opt(tech)_$::opt(device)_ids.db
@ /look_up_tables/$::opt(device) load $::opt(source)/$::opt(tech)_$::opt(device)_gm.db
@ /look_up_tables/$::opt(device) load $::opt(source)/$::opt(tech)_$::opt(device)_ro.db
if {$::opt(interpolation)=="LIT"} {
    generate_lit /look_up_tables/$::opt(device)/Ids/$::opt(process)
    generate_lit /look_up_tables/$::opt(device)/gm/$::opt(process)
    generate_lit /look_up_tables/$::opt(device)/ro/$::opt(process)
}
open_bin write $output_file
write_bin int $::opt(size)
source $::env(RAMSPICE)/Tech_DB/$::opt(tech)/binning_$::opt(tech).tcl
source $::env(RAMSPICE)/tests/geo_values.tcl
source $::opt(source)/$::opt(tech)_$::opt(device)_min_vt.tcl
#set minVt 0.53
Info: minVt=$minVt
set epsilon 1e-2
set process $::opt(process)
set temp $::corner_to_temp($process)
set p [string index $::opt(device) 0]
if {$p=="p"} {
    set opt(topv) [expr -$opt(topv)]
}
default opt(max_wbyl) 10
default opt(min_wbyl) 0.5
set minw [set ::global_${p}wmin]
set minl [set ::global_${p}lmin]
set maxw [set ::global_${p}wmax]
set maxl [set ::global_${p}lmax]
foreach param {L W Vgs Vds Vbs LUT_Ids LUT_gm LUT_ro} {
    @ $param !
    @ $param = real 0
}
.init
# Gamma code defines the properties below
.property LUT_Ids=interpolate(L,Vbs,Vds,Vgs,&{/look_up_tables/$::opt(device)/Ids/$::opt(process)})*(W/L)
.property LUT_gm=interpolate(L,Vbs,Vds,Vgs,&{/look_up_tables/$::opt(device)/gm/$::opt(process)})*(W/L)
.property LUT_ro=interpolate(L,Vbs,Vds,Vgs,&{/look_up_tables/$::opt(device)/ro/$::opt(process)})*(L/W)
foreach prop {Ids gm ro} {
     .label: LUT_$prop
     .calculate LUT_$prop
     GammaCommandStop
}

for {set max_wbyl $opt(max_wbyl)} {$max_wbyl<=$opt(max_wbyl)} {incr max_wbyl} {
    array unset hist
    set error_list {}
    set trail {}
    while {[llength $trail]<$::opt(size)} {
        @ L = real [expr $minl+rand()*($maxl-$minl)]
        @ W = real [expr (rand()*($max_wbyl-$opt(min_wbyl))+$opt(min_wbyl))*[@ L]]
        set s [find_mosfet_bin $p [@ L] [@ W]]
        skip {[@ W]>$::bin($p,$s,wmax)}
        skip {[@ W]<$::bin($p,$s,wmin)}
        @ Vgs = real [expr $minVt+($::opt(topv)-$minVt)*rand()]
        @ Vds = real [expr $::opt(topv)*rand()]
        @ Vbs = real [expr -$::opt(topv)*rand()/6]
        lappend trail [list [@ Vgs] [@ Vds] [@ Vbs] [@ L] [@ W]]
    }
    for {set s 1} {[info exists ::bin(n,$s,lmin)]} {incr s} {
#        Info: "Analyzing Bin=$s"
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
            @ L = real [lindex $point 3]
            @ W = real [lindex $point 4]
            set s2 [find_mosfet_bin $p [@ L] [@ W]]
            skip {$s2!=$s}
            @ Vgs = real [lindex $point 0]
            @ Vds = real [lindex $point 1]
            @ Vbs = real [lindex $point 2]
            ::spice::alter mn l = [@ L]
            ::spice::alter mn w = [@ W]
            ::spice::alter vgs = [@ Vgs]
            ::spice::alter vds = [@ Vds]
            ::spice::alter vbs = [@ Vbs]
            ::spice::op
            if {[catch {set Ids [expr 1e12*[get_spice_data V(5) 0]]}]} {
	        Error: Ids=[get_spice_data V(5) 0]
	        continue
            }	
	    .run LUT_Ids	
#	    Info: LUT_Ids=$LUT_Ids
            ::spice::alter vgs = [expr [@ Vgs]+$epsilon]
            ::spice::op
            set Ids_gm [expr 1e12*[get_spice_data V(5) 0]]
            set gm [expr ($Ids_gm-$Ids)/$epsilon]
	    .run LUT_gm	
            ::spice::alter vgs = [@ Vgs]
            ::spice::alter vds = [expr [@ Vds]+$epsilon]
            ::spice::op
            set Ids_ro [expr 1e12*[get_spice_data V(5) 0]]
            set ro [expr $epsilon/($Ids_ro-$Ids)]
	    .run LUT_ro	
            write_bin float [@ Vgs] [@ Vds] [@ Vbs] [@ L] [@ W] [@ LUT_Ids] [@ Ids] [@ LUT_gm] [@ gm] [@ LUT_ro] [@ ro]
            set WbyL [expr [@ W]/[@ L]]
            skip {[catch {set error [expr ([@ LUT_ro]/$ro-1)*100]}]}
	    
	    skip {[regexp {[nN]} $error]} 
	    if {abs($LUT_ro-$ro)<=1e3} {
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
            #Info:   $L  [eng $WbyL {}]  [eng $error %] Ids=$Ids LUT=$LUT_Ids
            #Info:  $Vgs $Vds $Vbs $L $W $LUT_Ids $Ids [eng $WbyL {}]  [eng $error %] 
            #Info: $Vgs $Vds $Vbs $L $W $LUT_Ids $Ids $LUT_gm $gm $LUT_ro $ro [expr abs($LUT_Ids/$Ids-1)*100] [expr abs($LUT_gm/$gm-1)*100] [expr abs($LUT_ro/$ro-1)*100]
            #Info: $Vgs $Vds $Vbs LUT=[eng $LUT_Ids A] Sim=[eng $Ids A] Error=[expr ($LUT_Ids/$Ids-1)*100]
            ::spice::destroy all
        }
        ::spice::destroy all
    }
    if {[llength $error_list]==0} exit
    set error_list [lsort -real $error_list]
#    set cap_index [expr int([llength $error_list]*99.0/100)-1]
#    set error_list [lrange $error_list 0 $cap_index]
    
    Info: Sample size=[llength $error_list]
    set average 0
    foreach error $error_list {
        set average [expr $average+$error]
    }
    set average [expr $average/[llength $error_list]]
    set stddev 0
    foreach error $error_list {
        set stddev [expr $stddev+($error-$average)*($error-$average)]
    }
    set acc 0
    foreach i [lsort -integer [array names hist]] {
        set acc [expr $acc+$hist($i)]
        Info: $i% [eng [expr 100.0*$hist($i)/[llength $error_list]] %] [eng [expr 100.0*$acc/[llength $error_list]] %]
    }
    set stddev [expr sqrt($stddev/[llength $error_list])]
    Info: average=$average stddev=$stddev
    set time [expr 1e-9*[lindex [timer_report] 0]]
    Info: Access time=[eng $time sec]
    write_bin float $time
    close_bin write
    set O [open /tmp/stats a]
    puts $O "$max_wbyl $average $stddev"
    close $O
}
exit

