# \
exec $RAMSPICE/ramspice $0 $argv
get_opts

default ::opt(W) 2e-6
default ::opt(L) 1e-6
default ::opt(tech) tsmc040
default ::opt(topv) 1.1
default ::opt(process) ss
default ::opt(iref) 10e-6

set ::Lmin 180e-9
source $::env(RAMSPICE)/Tech_DB/$::opt(tech)/binning_$::opt(tech).tcl

set section [find_mosfet_bin n $::opt(L) $::opt(W)]
netlist ".include $::env(RAMSPICE)/Tech_DB/$::opt(tech)/$::opt(tech).sp"
netlist ".temp 125"
netlist "iref 1 0 dc -$::opt(iref)"
netlist "vdd 3 0 dc $::opt(topv)"
netlist "vin 5 0 dc [expr $::opt(topv)/2]"
netlist "mp1 2 2 3 3 pch_${::opt(process)}_${section} L=$::opt(L) W=$::opt(W)"
netlist "mp2 6 2 3 3 pch_${::opt(process)}_${section} L=$::opt(L) W=$::opt(W)"
netlist "mref 1 1 0 0 nch_${::opt(process)}_${section} L=$::opt(L) W=$::opt(W) "
netlist "msink 4 1 0 0 nch_${::opt(process)}_${section} L=$::opt(L) W=$::opt(W) "
netlist "min1 2 5 4 0 nch_${::opt(process)}_${section} L=$::opt(L) W=$::opt(W) "
netlist "min2 6 5 4 0 nch_${::opt(process)}_${section} L=$::opt(L) W=$::opt(W) "
netlist ".end"
update_netlist
::spice::op
Info: Vref=[eng [get_spice_data V(1) 0] V]
Info: Vsink=[eng [get_spice_data V(4) 0] V]
Info: Vout1=[eng [get_spice_data V(2) 0] V]
Info: Vout2=[eng [get_spice_data V(6) 0] V]
exit



