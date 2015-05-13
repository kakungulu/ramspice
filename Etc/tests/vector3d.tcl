# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
default opt(tech) tsmc018
source $::env(RAMSPICE)/Tech_DB/tsmc018/binning_tsmc018.tcl

######### Template netlist
netlist ".include $::env(RAMSPICE)/Tech_DB/$opt(tech)/$opt(tech).sp"
netlist {
    ** the N-transistor
    * name D G S B model L W 
}
set ::corner ss

proc mosfet {name type D G S B L W {section {}}} {
    set prefix [string index $type 0]
    if {$section=={}} {
        set section [find_mosfet_bin $prefix $L $W]
    }
    set Lmin $::bin($prefix,$section,lmin)
    set sim_corner $::corner
    if {$sim_corner=="mc"} {
        set sim_corner tt
    }
    netlist "$name $D $G $S $B ${type}_${sim_corner}_${section} L=$L W=$W AD=[expr 2.5*$Lmin*$W] AS=[expr 2.5*$Lmin*$W] PD=[expr 5*$Lmin+$W] PS=[expr 5*$Lmin+$W]"
}
set L 180e-9
set W 220e-9
set ohmic_factor [expr 1e12]

netlist ".temp 125"
# mosfet {name type D G S B L W Lmin}
mosfet mn_1 nch D G 1 B $L $W
netlist "r_1 1 0 1e-12"
incr i3
netlist "
Vds D 0 dc 1.8 ac 0
Vgs G 0 dc 1.8 ac 0
Vbs B 0 dc 0 ac 0
.end
"
update_netlist
set index_range {}
foreach var {Vgs Vds Vbs} {
    lappend index_range 2
}

lappend index_range 1
::spice::dc vgs 1.0 1.8 0.8 vds 0 1.8 1.8 vbs 0 -0.1 -0.1
save_characterization_slice /tmp/test_Ids $index_range 3 1 0 $ohmic_factor
        foreach Vbs {0 -0.1} {
    foreach Vds {0 1.8} {
foreach Vgs {1.0 1.8} {
	    ::spice::alter vgs = $Vgs
	    ::spice::alter vds = $Vds
	    ::spice::alter vbs = $Vbs
	    ::spice::op
	    set Ids [expr [::spice::get_spice_data V(1) end]*$ohmic_factor]
	    report_vars Vgs Vds Vbs Ids
	}
    }
}
exit


