constrain {
    Vgs  0.4          1.8            6
    Vds  0.5          1.8            7
    Vbs  -1.8         0              3
}
set w_values {
2.20E-007	3.13333333333333E-007	4.06666666666667E-007
5.00E-007	7.33333333333333E-007	9.66666666666667E-007
1.20E-006	4.13333333333333E-006	7.06666666666667E-006
1.00E-005	0.0003066667	0.0006033333
9.00E-004	
}
set l_values {
1.80E-007	2.86666666666667E-007	3.93333333333333E-007
5.00E-007	7.33333333333333E-007	9.66666666666667E-007
1.20E-006	4.13333333333333E-006	7.06666666666667E-006
1.00E-005	1.33333333333333E-005	1.66666666666667E-005
2.00E-005		
}
set ::fork_limit 8
foreach type {n p} {
    foreach dim {l w} {
        foreach side {min max} op {> <} {
            Info: global_$type$dim$side=[set ::global_$type$dim$side]
        }
    }
}
set ::corner_list {ss tt ff fs sf mc}
set ::temp_list {125 27 -40 27 27 27} 
set ::accuracy 1e12
set ::res_factor 1
set ::epsilon 0.01
set ::mid_vgs 0.8
set ::min_Ids 1e-12
################################
# Clean droppings
foreach droppings [glob -nocomplain /tmp/*characterization_task*] {
    file delete $droppings
}
foreach droppings [glob -nocomplain /tmp/{Ids,gm,go}.*] {
    file delete $droppings
}

set views {Ids gm go}
foreach ::corner $::corner_list ::temp $::temp_list {
    fork_task char_vig_task {
	
	textbox "Corner [string toupper $::corner], Temperature=$::temp degC"
	netlist ".include $::env(RAMSPICE_TECH)"
	netlist {
	    ** the N-transistor
	    * name D G S B model L W 
	}
	set Lmin 1.8e-7
	set i3 0
	foreach L $l_values {
	set i4 0
	foreach W $w_values {
	    set section [find_mosfet_bin n $L $W]
	    netlist ".temp $::temp"
#	    netlist "mn_${i3}_${i4} 3 1 ${i3}_${i4} 4 nch_${::corner}_${section} L=$L W=$W AD=[expr 2.5*$Lmin*$W] AS=[expr 2.5*$Lmin*$W] PD=[expr 5*$Lmin+$W] PS=[expr 5*$Lmin+$W]"
	    netlist "mn_${i3}_${i4} 3 1 ${i3}_${i4} 4 nch_${::corner}_${section} L=$L W=$W "
	    netlist "r_${i3}_${i4} ${i3}_${i4} 0 [expr $::res_factor/$::accuracy]"
	    incr i4
	}
	    incr i3
	}
	netlist {
	    Vds 3 0 dc 1.8 ac 0
	    Vgs 1 0 dc 1.3 ac 0
	    Vbs 4 0 dc 0 ac 0
	    .end
	}
	update_netlist
	set index_range {}
	foreach var {Vgs Vds Vbs} {
	    lappend index_range $::constraints($var,index_range)
	}
	lappend index_range [llength $l_values]
	lappend index_range [llength $w_values]
	Info:  Measuring Ids(Vgs,Vds,Vbs) gm(Vgs,Vds,Vbs) and go(Vgs,Vds,Vbs)
	Info: simulation started ([clock format [clock seconds]])
	::spice::dc  vgs $::constraints(Vgs,minval) $::constraints(Vgs,maxval) $::constraints(Vgs,step) vds $::constraints(Vds,minval) $::constraints(Vds,maxval) $::constraints(Vds,step) vbs $::constraints(Vbs,minval) $::constraints(Vbs,maxval) $::constraints(Vbs,step)
	Info: done Ids running. Saving results. ([clock format [clock seconds]])
	save_characterization_slice /tmp/Ids.$::corner $index_range 3 2 0 $::accuracy
	::spice::dc vgs [expr $::constraints(Vgs,minval)+$::epsilon] [expr $::constraints(Vgs,maxval)+$::epsilon] $::constraints(Vgs,step) vds $::constraints(Vds,minval) $::constraints(Vds,maxval) $::constraints(Vds,step) vbs $::constraints(Vbs,minval) $::constraints(Vbs,maxval) $::constraints(Vbs,step) 
	Info: done gm running. Saving results. ([clock format [clock seconds]])
	save_characterization_slice_differential /tmp/gm.$::corner $index_range 3 2 0 [expr $::accuracy/$::epsilon]
	::spice::dc vgs $::constraints(Vgs,minval) $::constraints(Vgs,maxval) $::constraints(Vgs,step) vds [expr $::constraints(Vds,minval)+$::epsilon] [expr $::constraints(Vds,maxval)+$::epsilon] $::constraints(Vds,step) vbs $::constraints(Vbs,minval) $::constraints(Vbs,maxval) $::constraints(Vbs,step) 
	Info: done go running. Saving results. ([clock format [clock seconds]])
	save_characterization_slice_differential /tmp/go.$::corner $index_range 3 2 0 [expr $::accuracy/$::epsilon] 
	Info: is done saving results. ([clock format [clock seconds]])
	Info: Done ([clock format [clock seconds]])
    }
}
foreach ::corner $::corner_list ::temp $::temp_list {
    ######### Characterizing loops
    set index_range {}
    foreach var {Vgs Vds Vbs} {
        lappend index_range $::constraints($var,index_range)
    }
    lappend index_range [llength $l_values]
    lappend index_range [llength $w_values]
    foreach array $views {
        @ look_up_tables/cmosn/$::corner/${array}([join $index_range ,]) !
    }
    foreach array $views {
        foreach_in_range Vgs i0 { 
            ::spice::array_set_legend /look_up_tables/cmosn/$::corner/$array 0 $i0 $Vgs
        }
        foreach_in_range Vds i1 {
            ::spice::array_set_legend /look_up_tables/cmosn/$::corner/$array 1 $i1 $Vds
        }
        foreach_in_range Vbs i2 {
            ::spice::array_set_legend /look_up_tables/cmosn/$::corner/$array 2 $i2 $Vbs
        }
	set i3 0
        foreach L $l_values {
            ::spice::array_set_legend /look_up_tables/cmosn/$::corner/$array 3 $i3 $L
	    incr i3
        }
	set i4 0
        foreach W $w_values {
            ::spice::array_set_legend /look_up_tables/cmosn/$::corner/$array 4 $i4 $W
	    incr i4
        }
    }
}
wait_for_forked char_vig_task

foreach ::corner $::corner_list {
    load_characterization_slice /look_up_tables/cmosn/$::corner/Ids /tmp/Ids.$::corner
    load_characterization_slice /look_up_tables/cmosn/$::corner/gm /tmp/gm.$::corner
    load_characterization_slice /look_up_tables/cmosn/$::corner/go /tmp/go.$::corner
    normalize_ids /look_up_tables/cmosn/$::corner/Ids
    normalize_ids /look_up_tables/cmosn/$::corner/gm
    normalize_ids /look_up_tables/cmosn/$::corner/go
}

@ /look_up_tables save $::env(RAMSPICE)/../vig.db
