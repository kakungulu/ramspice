# \
exec $RAMSPICE/ramspice $0 $argv

get_opts
default opt(topv) -1.1 
default opt(tech) tsmc040 
default opt(source) Tech_DB/tsmc040/3:6:3 
default opt(device) pch 
default opt(process) ss

array set ::corner_to_temp {
    ss 125
    tt 27
    ff -40
    fs 27
    sf 27
    mc 27
}
source $::env(RAMSPICE)/Tech_DB/$::opt(tech)/binning_$::opt(tech).tcl
source $::opt(source)/$::opt(tech)_$::opt(device)_min_vt.tcl
set process $::opt(process)
set temp $::corner_to_temp($process)
set p [string index $::opt(device) 0]
for {set section 1} {[info exists ::bin($p,$section,lmin)]} {incr section} {
    set L $::bin($p,$section,lmin)
    set W $::bin($p,$section,wmin)
    netlist ".include $::env(RAMSPICE)/Tech_DB/$::opt(tech)/$::opt(tech).sp"
    netlist ".temp $temp"
    netlist "mn 3 1 5 4 ${::opt(device)}_${::opt(process)}_${section} L=$L W=$W"
    netlist "r5 5 0 1e-12"
    netlist "Vds 3 0 dc $::opt(topv) ac 0"
    netlist "Vgs 1 0 dc $::opt(topv) ac 0"
    netlist "Vbs 4 0 dc 0 ac 0"
    netlist ".end"
    update_netlist
    ::spice::op
    Info: section=$section W/L=[expr $W/$L] Ids=[eng [expr 1e12*[::spice::get_spice_data V(5) 0]] A] Ids_size=[eng [expr 1e12*[::spice::get_spice_data V(5) 0]/$W*$L] A] 
}
exit
