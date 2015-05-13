constrain {
    Vgs  0          1.8          6
    Lsize 1         128          6
    WbyL  1         128          6
}
set ::fork_limit 6
# Clean droppings
foreach droppings [glob -nocomplain /tmp/*characterization_task*] {
    file delete $droppings
}
foreach droppings [glob -nocomplain /tmp/{size,ids,gm,ro}.*] {
    file delete $droppings
}
set views size
foreach ::corner {ss tt ff fs sf mc} ::temp {125 27 -40 27 27 27} {
    fork_task char_size_task {
        textbox "Corner [string toupper $::corner], Temperature=$::temp degC"
        ######### Template netlist
	netlist ".include $::env(RAMSPICE_TECH)"
        netlist {
            ** the N-transistor
            * name D G S B model L W 
        }
        netlist ".temp $::temp"
        set Lmin 1.8e-7
        foreach_in_range Lsize i3 {
            foreach_in_range WbyL i4 {
                set L [expr $Lmin*$Lsize]
                set W [expr  $L*$WbyL]
                set section [find_mosfet_bin n $L $W]
                netlist "mn_${i3}_${i4} 3 1 ${i3}_${i4} 0 nch_${::corner}_${section} L=$L W=$W AD=[expr 2.5*$Lmin*$W] AS=[expr 2.5*$Lmin*$W] PD=[expr 5*$Lmin+$W] PS=[expr 5*$Lmin+$W]"
                netlist "r_${i3}_${i4} ${i3}_${i4} 0 1e-12"
            }
        }
        netlist {
            Vds 3 0 dc 1.8 ac 0
            Vgs 1 0 dc 0.9 ac 0
            .end
        }
        update_netlist
        
        ######### Initialize database
        @ /look_up_tables/cmosn/$::corner !
        
        Info:  Measuring size(W,L)
        ######### Characterizing loops
        Info: simulation started ([clock format [clock seconds]])
        set index_range {}
        foreach var {Vgs Lsize WbyL} {
            lappend index_range $::constraints($var,index_range)
        }
	::spice::dc  vgs $::constraints(Vgs,minval) $::constraints(Vgs,maxval) $::constraints(Vgs,step)
        Info: done Size running. Saving results. ([clock format [clock seconds]])
        save_characterization_slice /tmp/size-[pid] $index_range 1 2 0 1e12
        foreach array $views {
            Info: New Array: look_up_tables/cmosn/$::corner/${array}([join $index_range ,])
            @ /tmp/${array}([join $index_range ,]) !
        }
        foreach array $views {
            foreach_in_range Vgs i2 {
                ::spice::array_set_legend /tmp/$array 0 $i2 $Vgs
            }
            foreach_in_range Lsize i3 {
                ::spice::array_set_legend /tmp/$array 1 $i3 $Lsize
            }
            foreach_in_range WbyL i4 {
                ::spice::array_set_legend /tmp/$array 2 $i4 $WbyL
            }
        }
        Info: Done ([clock format [clock seconds]])
        load_characterization_slice /tmp/size /tmp/size-[pid]
        foreach_in_range Vgs i2 {
            foreach_in_range Lsize i3 {
                set unitIds [@ /tmp/size($i2,$i3,0)]
                foreach_in_range WbyL i4 {
                    ^ @ /look_up_tables/cmosn/$::corner/size($i2,$i3,$i4) = [expr [@ /tmp/size($i2,$i3,$i4)]/$unitIds/$WbyL]
                }
            }    
	}
    }
    #  @    generate_lut size
}
foreach ::corner {ss tt ff fs sf mc} ::temp {125 27 -40 27 27 27} {
    set index_range {}
    foreach var {Vgs Lsize WbyL} {
        lappend index_range $::constraints($var,index_range)
    }
    foreach array $views {
        Info: New Array: look_up_tables/cmosn/$::corner/${array}([join $index_range ,])
        @ look_up_tables/cmosn/$::corner/${array}([join $index_range ,]) !
    }
    foreach array $views {
        Info: New Array: look_up_tables/cmosn/$::corner/${array}([join $index_range ,])
        @ look_up_tables/cmosn/$::corner/${array}([join $index_range ,]) !
    }
    foreach array $views {
        foreach_in_range Vgs i2 {
            ::spice::array_set_legend /look_up_tables/cmosn/$::corner/$array 0 $i2 $Vgs
        }
        foreach_in_range Lsize i3 {
            ::spice::array_set_legend /look_up_tables/cmosn/$::corner/$array 1 $i3 $Lsize
        }
        foreach_in_range WbyL i4 {
            ::spice::array_set_legend /look_up_tables/cmosn/$::corner/$array 2 $i4 $WbyL
        }
    }
}
wait_for_forked char_size_task
@ /look_up_tables save $::env(RAMSPICE)/../size.db
