# \
exec $RAMSPICE/ramspice $0 $argv
proc mosfet {name type D G S B L W} {
    set prefix [string index $type 0]
    set section [find_mosfet_bin $prefix $L $W]
    set Lmin [set ::global_${prefix}lmin]
    netlist "$name $D $G $S $B ${type}_${::corner}_${section} L=$L W=$W AD=[expr 2.5*$Lmin*$W] AS=[expr 2.5*$Lmin*$W] PD=[expr 5*$Lmin+$W] PS=[expr 5*$Lmin+$W]"
}

set max_supply 1.1
netlist "
.include $::env(RAMSPICE)/${tech}.lib
.temp 125
"
set ::corner ss
mosfet mn_0_0 nch 3 2 0 1 3.6e-8 3.6e-8
netlist "
Vds 3 0 dc $max_supply ac 0
Vgs 1 0 dc [expr $max_supply/2] ac 0
Vbs 4 0 dc 0 ac 0
.end
"
set O [open test.sn w]
puts $O $template_netlist
close $O
update_netlist
Info: tcl_list_insts=[list_insts]
for {set vgs_i 0} {$vgs_i<5} {incr vgs_i} {
    set Vgs [expr $vgs_i*$max_supply/5]
    ::spice::alter vgs = $Vgs
    foreach L {3.6e-8 4.5e-8} {
        ::spice::alter mn_0_0 l = $L
	::spice::noise v(3) vgs lin 2 1 2
	Info: Captured_Thermal_Noise=[::spice::get_spice_data Captured_Thermal_Noise end]
    }
}
exit

