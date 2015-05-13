constrain {
        Vgs  0          1.8            6
        Vds  0          1.8            6
	Vbs  -1.8       0              6
	Lsize 1         128            7
	WbyL  1         128            7
}
set ::corner_list {ss tt ff fs sf mc}
set ::temp_list {125 27 -40 27 27 27} 
set ::accuracy 1e12
set ::res_factor 1
set ::fork_limit 6
set ::epsilon 0.01
set ::mid_vgs 0.8
set ::min_Ids 1e-12
set ::scalar_Ids_multiplier 3.9e-11
set ::limit_Ids_multiplier 1e-1
set ::minVgs 0.6
set ::minVds 0.1
set ::maxVds 1.8
set ::maxVgs 1.4
################################
set ::low_vgs [expr $::mid_vgs-$::epsilon]
set ::high_vgs [expr $::mid_vgs+$::epsilon]
set ::epsilon21 [expr $::mid_vgs*$::mid_vgs-$::low_vgs*$::low_vgs]
set ::epsilon32 [expr $::high_vgs*$::high_vgs-$::mid_vgs*$::mid_vgs]
set ::epsilon321 [expr $::high_vgs*$::high_vgs-2*$::mid_vgs*$::mid_vgs+$::low_vgs*$::low_vgs]
# Clean droppings
foreach droppings [glob -nocomplain /tmp/*characterization_task*] {
    file delete $droppings
}
foreach droppings [glob -nocomplain /tmp/{ids,gm,go}.*] {
    file delete $droppings
}

set short_views {Vt Va}
set views {Ids gm go}
foreach ::corner $::corner_list ::temp $::temp_list {
    fork_task char_vt_task {
        textbox "Corner [string toupper $::corner], Temperature=$::temp degC"
        ######### Template netlist
	netlist ".include $::env(RAMSPICE_TECH)"
        netlist {
            ** the N-transistor
            * name D G S B model L W 
        }
        set Lmin $::global_nlmin
        foreach_in_range Lsize i3 {
            foreach_in_range WbyL i4 {
                set L [expr $Lmin*$Lsize]
                set W [expr  $L*$WbyL]
                set section [find_mosfet_bin n $L $W]
                netlist ".temp $::temp"
                netlist "mn_${i3}_${i4} 3 1 ${i3}_${i4} 4 nch_${::corner}_${section} L=$L W=$W AD=[expr 2.5*$Lmin*$W] AS=[expr 2.5*$Lmin*$W] PD=[expr 5*$Lmin+$W] PS=[expr 5*$Lmin+$W]"
                netlist "r_${i3}_${i4} ${i3}_${i4} 0 1e-12"
            }
        }
        netlist {
            Vds 3 0 dc 1.8 ac 0
            Vgs 1 0 dc 0.9 ac 0
            Vbs 4 0 dc 0 ac 0
            .end
        }
        update_netlist
        
        ######### Initialize database
         Info: Measuring Vt(W,L)
        ::spice::dc vgs $::low_vgs $::high_vgs $epsilon
	set length 1
        foreach var {Lsize WbyL} {
	    set length [expr $length*$::constraints($var,index_range)]
	}
     ETA $length
	foreach_in_range Lsize i2 {
	    foreach_in_range WbyL i3 {
		set Ids_low  [::spice::get_spice_data V(${i2}_${i3}) 0]
		set Ids_mid [::spice::get_spice_data V(${i2}_${i3}) 1]
		set Ids_high [::spice::get_spice_data V(${i2}_${i3}) 2]
		set coeff [expr ($Ids_high-2*$Ids_mid+$Ids_low)/$::epsilon321]
		set Vt [expr $::high_vgs-$Ids_high/(($Ids_high-$Ids_low)/($::high_vgs-$::low_vgs))]
		if {![regexp {^[0-9eE\+\-\.]+$} $Vt]} {
		    report_vars Vt Lsize WbyL
		    exit
		}
		^ @ look_up_tables/cmosn/$::corner/Vt($i2,$i3) = $Vt
	     ETA
	    }
	}
        
        Info: Measuring Va(W,L) 
        ::spice::dc vds [expr 1.8-$epsilon] 1.8 $epsilon 
	ETA $length
        foreach_in_range Lsize i2 {
            foreach_in_range WbyL i3 {
                set Ids_low  [::spice::get_spice_data V(${i2}_${i3}) 0]
                set Ids_high [::spice::get_spice_data V(${i2}_${i3}) 1]
                if {[catch {set Va [expr 1.8-$Ids_high/(($Ids_high-$Ids_low)/$epsilon)]} msg]} {
                    report_vars Ids_low Ids_high epsilon Va
                }
                if {![regexp {^[0-9eE\+\-\.]+$} $Va]} {
                    report_vars Va Lsize WbyL
                    exit
                }
                ^ @ look_up_tables/cmosn/$::corner/Va($i2,$i3) = $Va
		ETA
            }
        }  
    }
}
foreach ::corner $::corner_list ::temp $::temp_list {
        set index_range {}
        foreach var {Lsize WbyL} {
            lappend index_range $::constraints($var,index_range)
        }
        foreach array $short_views {
            @ /look_up_tables/cmosn/$::corner/${array}([join $index_range ,]) !
        }
        foreach array $short_views {
            foreach_in_range Lsize i3 {
                ::spice::array_set_legend /look_up_tables/cmosn/$::corner/$array 0 $i3 $Lsize
            }
            foreach_in_range WbyL i4 {
                ::spice::array_set_legend /look_up_tables/cmosn/$::corner/$array 1 $i4 $WbyL
            }
        }
}
wait_for_forked char_vt_task
@ /look_up_tables save $::env(RAMSPICE)/../vat.db
