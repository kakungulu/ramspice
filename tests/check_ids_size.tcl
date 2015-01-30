# \
exec $RAMSPICE/ramspice $0 $argv

get_opts
default ::opt(process) tt
default ::opt(tech) tsmc040
default ::opt(device) nch
default ::opt(temp) 27
default ::opt(Vgs) 1.1
default ::opt(Vds) 1.1
default ::opt(Vbs) 0
source $::env(RAMSPICE)/Tech_DB/$opt(tech)/binning_$opt(tech).tcl
default ::opt(L) $::global_nlmin

source Web/svg/svg.tcl
set Spice_Ids {}
set Spectre_Ids {}
set data {}
set prev_section 0
set Lmin $::global_nlmin
default ::opt(rez) 0.1
default ::opt(start) 1
set l $::opt(L)
set w $::global_nwmin
set prev_section 0
while {$w<=$::global_nwmax} {
    set section [find_mosfet_bin n $l $w]
    if {$section!=$prev_section} {
        ::spice::destroy all
        netlist ".include $::env(RAMSPICE)/Tech_DB/$opt(tech)/$opt(tech).sp"
        netlist ".temp $::opt(temp)"
        netlist "mn 3 1 5 4 ${::opt(device)}_${::opt(process)}_${section} L=$l W=$w"
        netlist "r5 5 0 1e-18"
        netlist "Vds 3 0 dc $::opt(Vds) ac 0"
        netlist "Vgs 1 0 dc $::opt(Vgs) ac 0"
        netlist "Vbs 0 4 dc $::opt(Vbs) ac 0"
        netlist ".end"
        update_netlist
    } 
    ::spice::alter mn w = $w
    set prev_section $section
    ::spice::op
    set Ids [::spice::get_spice_data V(5) 0]
    set Ids [expr $Ids*1e18*$l/$w]
    Info: W=[eng $w m] Ids_size=[eng $Ids A]
    set w [expr $w*2]
}
exit

