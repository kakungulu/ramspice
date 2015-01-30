constrain {
    Lsize 1         129          5
    WbyL  1         513          6
}
set ::fork_limit 6
@ /struct/dist/type = string
@ /struct/dist/arg1 = string
@ /struct/dist/arg2 = string
for {set i 1} {$i<=16} {incr i} {
    @ /simulation_config/mc/nch_mc_$i = string {
        set lef [expr $BSIM_l - 20e-9]
        set wef $BSIM_w 
        set geo_fac [expr 1/sqrt($lef*$wef*1e12)]
        set vthmis [expr 3.635e-3*$geo_fac]
        set dlmis [expr 4.58e-3*$geo_fac*$lef]
        set dwmis [expr 3.73e-3*$geo_fac*$wef]
    }
    @ /simulation_config/mc/nch_mc_$i/l = /struct/dist gauss * {{$dlmis}}
    @ /simulation_config/mc/nch_mc_$i/w = /struct/dist gauss * {{$dwmis}}
    @ /simulation_config/mc/nch_mc_$i/vth0 = /struct/dist gauss * {{$vthmis}}
}
# Clean droppings
foreach droppings [glob -nocomplain /tmp/*characterization_task*] {
    file delete $droppings
}
foreach droppings [glob -nocomplain /tmp/char_{mis,size,ids,gm,ro}*.*] {
    file delete $droppings
}
set views {Ids_mis Vth_mis}
foreach ::corner {ss tt ff fs sf mis} ::temp {125 27 -40 27 27 27} {
    fork_task char_mis_task {
        textbox "Corner [string toupper $::corner], Temperature=$::temp degC"
        ######### Template netlist
	netlist ".include $::env(RAMSPICE_TECH)"
        netlist {
            ** the N-transistor
            * name D G S B model L W 
        }
        netlist ".temp $::temp"
        set Lmin 1.8e-7
        set vars_of_interest {}
        foreach_in_range Lsize i3 {
            foreach_in_range WbyL i4 {
                set L [expr $Lmin*$Lsize]
                set W [expr  $L*$WbyL]
                set section [find_mosfet_bin n $L $W]
                netlist "mn_${i3}_${i4} 3 1 ${i3}_${i4} 0 nch_mc_${section} L=$L W=$W AD=[expr 2.5*$Lmin*$W] AS=[expr 2.5*$Lmin*$W] PD=[expr 5*$Lmin+$W] PS=[expr 5*$Lmin+$W]"
                netlist "r_${i3}_${i4} ${i3}_${i4} 0 1e-12"
                lappend vars_of_interest mn_${i3}_${i4}
                lappend vars_of_interest Vth
                lappend vars_of_interest mn_${i3}_${i4}
                lappend vars_of_interest Ids
            }
        }
        netlist {
            Vds 3 0 dc 1.8 ac 0
            Vgs 1 0 dc 0.9 ac 0
            .end
        }
        set O [open test.sn w]
        puts $O $template_netlist
        close $O
        update_netlist
        
        Info:  Measuring mis(W,L)
        ######### Characterizing loops
        Info: simulation started ([clock format [clock seconds]])
        set result [monte_carlo_${::bsim_version} 500 /simulation_config/mc $vars_of_interest ::spice::op]
        Info: done Mismatch running. Saving results. ([clock format [clock seconds]])
        Info: Done ([clock format [clock seconds]])
        set i 0
        foreach_in_range Lsize i3 {
            foreach_in_range WbyL i4 {
                set Vth [lindex $result $i]
                incr i
                set Sigma [lindex $result $i]
                ^ @ /look_up_tables/cmosn/$::corner/Vth_mis($i3,$i4) = [expr $Sigma/$Vth]
                #	Info: Area=[expr $Lsize*$WbyL] ($Lsize*$WbyL) Sigma=$Sigma Vth=$Vth sigma/vth=[expr $Sigma/$Vth]
                incr i
                set Ids [lindex $result $i]
                incr i
                set Sigma [lindex $result $i]
                ^ @ /look_up_tables/cmosn/$::corner/Ids_mis($i3,$i4) = [expr $Sigma/$Ids]
                #	Info: Area=[expr $Lsize*$WbyL] ($Lsize*$WbyL) Sigma=$Sigma Ids=$Ids sigma/Ids=[expr $Sigma/$Ids]
                incr i
            }
        }    
    }
}
foreach ::corner {ss tt ff fs sf mis} ::temp {125 27 -40 27 27 27} {
    ######### Initialize database
    @ /look_up_tables/cmosn/$::corner !
    set index_range {}
    foreach var {Lsize WbyL} {
        lappend index_range $::constraints($var,index_range)
    }
    foreach array $views {
        Info: New Array: look_up_tables/cmosn/$::corner/${array}([join $index_range ,])
        @ look_up_tables/cmosn/$::corner/${array}([join $index_range ,]) !
    }
    foreach array $views {
        foreach_in_range Lsize i3 {
            ::spice::array_set_legend /look_up_tables/cmosn/$::corner/$array 0 $i3 $Lsize
        }
        foreach_in_range WbyL i4 {
            ::spice::array_set_legend /look_up_tables/cmosn/$::corner/$array 1 $i4 $WbyL
        }
    }
}
wait_for_forked char_mis_task
foreach ::corner {ss tt ff fs sf mis} ::temp {125 27 -40 27 27 27} {
    foreach array $views {
        generate_lut  /look_up_tables/cmosn/$::corner/$array
    }
}

@ /look_up_tables save $::env(RAMSPICE)/../mis.db
