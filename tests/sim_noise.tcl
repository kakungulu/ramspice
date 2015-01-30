# \
exec $RAMSPICE/ramspice $0 $argv

get_opts

foreach {option default} {
    tech tsmc018
    L 1e-6
    W 1e-6
    Vgs 1.1
    Vds 1.1
    Vbs 0
    process tt
    device nch
    temp 27
} {
    default opt($option) $default
}
source $::env(RAMSPICE)/Tech_DB/$opt(tech)/binning_$opt(tech).tcl

set l $opt(L)
set w $opt(W)
set epsilon 1e-3

set section [find_mosfet_bin n $l $w]
netlist ".include $::env(RAMSPICE)/Tech_DB/$opt(tech)/$opt(tech).sp"
netlist ".temp $opt(temp)"
netlist "mn 3 1 5 4 ${::opt(device)}_${::opt(process)}_${section} L=$l W=$w"
netlist "r5 5 0 1e-12"
netlist "Vds 3 0 dc $opt(Vds) ac 0"
netlist "Vgs 1 0 dc $opt(Vgs) ac 0"
netlist "Vbs 0 4 dc $opt(Vbs) ac 0"
netlist ".end"
update_netlist
::spice::op
set Ids [expr [::spice::get_spice_data V(5) 0]*1e12]
::spice::noise v(4) vbs lin 2 1 2
set thermal_noise [::spice::get_spice_data Captured_Thermal_Noise end]
::spice::alter vgs = [expr $opt(Vgs)+$epsilon]
::spice::op
set Ids_eps  [expr [::spice::get_spice_data V(5) 0]*1e12]
set gm [expr ($Ids_eps-$Ids)/$epsilon]
Info: Ids=$Ids Ids_eps=$Ids_eps gm=$gm 
Info: Ids=[eng $Ids A] Ids_eps=[eng $Ids_eps A] gm=[eng $gm Mho] 
Info: thermal_noise=$thermal_noise
Info: Kf=[expr [::spice::get_spice_data Captured_Ssi end]*[::spice::get_spice_data Captured_EffFreq end]]
exit


