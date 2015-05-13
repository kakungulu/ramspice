constrain {
        Vgs  0.4          1.8            3
        Vds  0.5          1.8            3
	Vbs  -1.8       0                3
}
set l_values {
	1.80E-007	2.86666666666667E-007	3.93333333333333E-007
	5.00E-007	7.33333333333333E-007	9.66666666666667E-007
	1.20E-006	4.13333333333333E-006	7.06666666666667E-006
	1.00E-005	1.33333333333333E-005	1.66666666666667E-005
	2.00E-005		
}

set ::corner_list {ss tt ff fs sf mc}
set ::temp_list {125 27 -40 27 27 27} 
set ::accuracy 1e12
set ::res_factor 1
set ::fork_limit 6
foreach old_task_file [glob -nocomplain /tmp/*.tcl] {
    file delete $old_task_file
}
set views {flicker_const thermal_noise}
set total_array_volume 1
set Lmin 180e-9
proc noise_cont {coord} {
    @ look_up_tables/cmosn/$::corner/flicker_const($coord) = 0
    return -code continue
}
set index_range {}
foreach var {Vgs Vds Vbs} {
    lappend index_range $::constraints($var,index_range)
}
lappend index_range [llength $l_values]
foreach temp $::temp_list ::corner $::corner_list {
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
}
}
foreach temp $::temp_list ::corner $::corner_list {
#    fork_task noise_char_task 
        textbox "Corner [string toupper $::corner], Temperature=$::temp degC"
        ETA [expr $::constraints(Vgs,index_range)*$::constraints(Vds,index_range)*$::constraints(Vbs,index_range)*[llength $l_values]]
        foreach_in_range Vgs i0 {
            foreach_in_range Vds i1 {
                foreach_in_range Vbs i2 {
		    set i3 0
                    foreach L $l_values {
                        set W $L
                        set section [find_mosfet_bin n $L $W]
                        netlist ".include $::env(RAMSPICE_TECH)"
                        netlist {
                            ** the N-transistor
                            * name D G S B model L W 
                            rtest 3_1 3 1e-12
                        }
                        netlist ".temp $temp"
                        netlist "mn_0_0 3 2 0 1 nch_${corner}_${section} L=$L W=$W AD=[expr 2.5*$Lmin*$W] AS=[expr 2.5*$Lmin*$W] PD=[expr 5*$Lmin+$W] PS=[expr 5*$Lmin+$W]"
                        netlist "Vgs 2   0 dc $Vgs ac 0"
                        netlist "Vds 3_1   0 dc $Vds ac 0"
                        netlist "Vbs 1   0 dc $Vbs ac 0"
                        netlist {
                            .end
                        }
                        set O [open test.sn w]
                        puts $O $template_netlist
                        close $O
                        update_netlist
                        ::spice::op
                        ::spice::noise v(3) vgs lin 2 1 2
                        set thermal_noise [::spice::get_spice_data Captured_Thermal_Noise end]
                        if {[string match *nan* $thermal_noise]} {
                            set thermal_noise 0
                        }
                        @ look_up_tables/cmosn/$::corner/thermal_noise($i0,$i1,$i2,$i3) = $thermal_noise
                        ETA
                        set Ssi [::spice::get_spice_data Captured_Ssi end]
                        set Captured_EffFreq [::spice::get_spice_data Captured_EffFreq end]
                        if {[string match *nan* $Captured_EffFreq]} {
                            noise_cont $i0,$i1,$i2,$i3
                        }
                        set flicker_noise $Ssi ; #[expr sqrt($Ssi)]
                        set flicker_const [expr $Captured_EffFreq*$flicker_noise]
                        #Info: Lsize=$Lsize thermal_noise=$thermal_noise flicker_noise=$flicker_noise corner=[expr $flicker_const/$thermal_noise]
                        @ look_up_tables/cmosn/$::corner/flicker_const($i0,$i1,$i2,$i3) =  $flicker_const
			incr i3
                    }
                }
            }
        } 
#{    }
}
#wait_for_forked  noise_char_task
@ /look_up_tables save $::env(RAMSPICE)/../noise.db


