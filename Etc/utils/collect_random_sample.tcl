# \
exec $RAMSPICE/ramspice $0 $argv

get_opts
array set ::corner_to_temp {
    ss 125
    tt 27
    ff -40
    fs 27
    sf 27
    mc 27
}
set output_file $::opt(source)/$::opt(device).$::opt(process).$::opt(interpolation).info
if {[file exists $output_file]} exit
@ /look_up_tables/$::opt(device) load $::opt(source)/$::opt(tech)_$::opt(device)_ids.db
@ /look_up_tables/$::opt(device) load $::opt(source)/$::opt(tech)_$::opt(device)_gm.db
@ /look_up_tables/$::opt(device) load $::opt(source)/$::opt(tech)_$::opt(device)_go.db
if {$::opt(interpolation)=="LIT"} {
    generate_lit /look_up_tables/$::opt(device)/Ids/$::opt(process)
    generate_lit /look_up_tables/$::opt(device)/gm/$::opt(process)
    generate_lit /look_up_tables/$::opt(device)/go/$::opt(process)
}
open_bin write $output_file
source $::env(RAMSPICE)/Tech_DB/$::opt(tech)/binning_$::opt(tech).tcl
source $::env(RAMSPICE)/tests/geo_values.tcl
source $::opt(source)/$::opt(tech)_$::opt(device)_min_vt.tcl
#set minVt 0.53
Info: minVt=$minVt
set epsilon 1e-3
set process $::opt(process)
set temp $::corner_to_temp($process)
set p [string index $::opt(device) 0]
if {$p=="p"} {
    set opt(topv) [expr -$opt(topv)]
}
for {set section 1} {[info exists ::bin($p,$section,lmin)]} {incr section} {
    set L $::bin($p,$section,lmin)
    set W $::bin($p,$section,wmin)
    netlist ".include $::env(RAMSPICE)/Tech_DB/$::opt(tech)/$::opt(tech).sp"
    netlist ".temp $temp"
    netlist "mn 3 1 5 4 ${::opt(device)}_${::opt(process)}_${section} L=$L W=$W"
    netlist "r5 5 0 1e-12"
    netlist "Vds 3 0 dc 0 ac 0"
    netlist "Vgs 1 0 dc 0 ac 0"
    netlist "Vbs 4 0 dc 0 ac 0"
    netlist ".end"
    update_netlist
    ::spice::op
    Info: Running section $section
    for {set i 0} {$i<$::opt(size)} {incr i} {
        set maxw $::bin($p,$section,wmax)
        if {$::bin($p,$section,wmax)>[lindex $w_values end]} {
	    set maxw [lindex $w_values end]
	}
        set maxl $::bin($p,$section,lmax)
        if {$::bin($p,$section,lmax)>[lindex $l_values end]} {
	    set maxl [lindex $l_values end]
	}
        set L [expr $::bin($p,$section,lmin)+rand()*($maxl-$::bin($p,$section,lmin))]
        set W [expr $::bin($p,$section,wmin)+rand()*($maxw-$::bin($p,$section,wmin))]
        set Vgs [expr $minVt+($::opt(topv)-$minVt)*rand()]
        set Vds [expr $::opt(topv)*rand()]
        set Vbs [expr -$::opt(topv)*rand()/3]
        ::spice::alter mn l = $L
        ::spice::alter mn w = $W
	::spice::alter vgs = $Vgs
	::spice::alter vds = $Vds
	::spice::alter vbs = $Vbs
	::spice::op
	set Ids [expr 1e12*[::spice::get_spice_data V(5) 0]]
        if {[catch {set LUT_Ids [expr [@ /look_up_tables/$::opt(device)/Ids/$::opt(process) calc $Vgs $Vds $Vbs $L $W]*$W/$L]} msg ]} {
	    Error: $Vgs $Vds $Vbs $L $W [@ /look_up_tables/$::opt(device)/Ids/$::opt(process) calc $Vgs $Vds $Vbs $L $W] $Ids
	    continue
	}
	::spice::alter vgs = [expr $Vgs+$epsilon]
	::spice::op
	set Ids_gm [expr 1e12*[::spice::get_spice_data V(5) 0]]
	set gm [expr ($Ids_gm-$Ids)/$epsilon]
        set LUT_gm [expr [@ /look_up_tables/$::opt(device)/gm/$::opt(process) calc $Vgs $Vds $Vbs $L $W]*$W/$L]
	::spice::alter vgs = $Vgs
	::spice::alter vds = [expr $Vds+$epsilon]
	::spice::op
	set Ids_go [expr 1e12*[::spice::get_spice_data V(5) 0]]
	set go [expr ($Ids_go-$Ids)/$epsilon]
        set LUT_go [expr [@ /look_up_tables/$::opt(device)/go/$::opt(process) calc $Vgs $Vds $Vbs $L $W]*$W/$L]
	write_bin float $Vgs $Vds $Vbs $L $W $LUT_Ids $Ids $LUT_gm $gm $LUT_go $go
	#Info: $Vgs $Vds $Vbs $L $W $LUT_Ids $Ids $LUT_gm $gm $LUT_go $go [expr abs($LUT_Ids/$Ids-1)*100] [expr abs($LUT_gm/$gm-1)*100] [expr abs($LUT_go/$go-1)*100]
	#Info: $Vgs $Vds $Vbs LUT=[eng $LUT_Ids A] Sim=[eng $Ids A] Error=[expr ($LUT_Ids/$Ids-1)*100]
    }
    spice::destroy all
}

set time [expr 1e-9*[lindex [timer_report] 0]]
Info: Access time=[eng $time sec]
write_bin float $time
close_bin write
exit

