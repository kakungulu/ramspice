constrain {
    Vgs  0.23          1.3            5
    Vds  0.23          1.3            5
    Vbs  -0.65         0              6
}
set ::fork_limit 8
source $::env(RAMSPICE)/tests/geo_values.tcl
set ::corner_list {tt}
set ::temp_list {27} 
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

set views {Ids}
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
	    netlist "mn_${i3}_${i4} 3 1 ${i3}_${i4} 4 nch_${::corner}_${section} L=$L W=$W AD=[expr 2.5*$Lmin*$W] AS=[expr 2.5*$Lmin*$W] PD=[expr 5*$Lmin+$W] PS=[expr 5*$Lmin+$W]"
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
    normalize_ids /look_up_tables/cmosn/$::corner/Ids
}

@ /look_up_tables save $::env(RAMSPICE)/../ids.db
