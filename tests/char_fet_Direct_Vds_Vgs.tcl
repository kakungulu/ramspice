source tests/char_constraints_Direct_Vds_Vgs.tcl
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
foreach droppings [glob -nocomplain /tmp/ids.*] {
    file delete $droppings
}
set ::ids_sum 0
set ::ids_samp 0
proc average_ids {sum samp} {
    set ::ids_sum [expr $::ids_sum+$sum]
    set ::ids_samp [expr $::ids_sum+$samp]
}
set short_views {Vt Va}
set views {Ids gm ro}
foreach field $::rusage_fields {
    Info: usage ([pid]) $field=[usage self $field], [usage children $field]
}
######### Template netlist
netlist {
    .include tsmc018_from_cadence.lib
    .temp 27 
    ** the N-transistor
    * name D G S B model L W 
}
set Lmin 1.8e-7
foreach_in_range L i2 {
    foreach_in_range WbyL i3 {
        set W [expr  $L*$WbyL]
        netlist "mn_${i2}_${i3} 3 1 ${i2}_${i3} 4 nch_ss L=$L W=$W AD=[expr 2.5*$Lmin*$W] AS=[expr 2.5*$Lmin*$W] PD=[expr 5*$Lmin+$W] PS=[expr 5*$Lmin+$W]"
        netlist "r_${i2}_${i3} ${i2}_${i3} 0 1e-6"
    }
}
netlist {
    Vds 3 0 dc 1.8 ac 0
    Vgs 1 0 dc 0.9 ac 0
    Vbs 4 0 dc 0 ac 0
    .end
}
set O [open test.sn w]
puts $O $template_netlist
close $O
update_netlist

######### Initialize database
@ /look_up_tables/cmosn !

Info: Measuring Vt(W,L,T)
Info: low_vgs=$::low_vgs high_vgs=$::high_vgs epsilon=$::epsilon
foreach_in_range temp i4 {
    fork_task vt_characterization_task {
        ::spice::set temp = $temp
        ::spice::dc vgs $::low_vgs $::high_vgs $epsilon
        foreach_in_range L i2 {
            foreach_in_range WbyL i3 {
                set Ids_low  [::spice::get_spice_data V(${i2}_${i3}) 0]
                set Ids_mid [::spice::get_spice_data V(${i2}_${i3}) 1]
                set Ids_high [::spice::get_spice_data V(${i2}_${i3}) 2]
                set coeff [expr ($Ids_high-2*$Ids_mid+$Ids_low)/$::epsilon321]
                set Vt [expr ($Ids_mid-$Ids_low-$coeff*$::epsilon21)/(-2*$coeff*$::epsilon)]
                if {![regexp {^[0-9eE\+\-\.]+$} $Vt]} {
                    report_vars Vt L WbyL temp
                    exit
                }
                ^ @ look_up_tables/cmosn/Vt($i2,$i3,$i4) = $Vt
            }
        }
    } 
}

Info: Measuring Va(W,L,T) 
foreach_in_range temp i4 {
    fork_task va_characterization_task {
        ::spice::set temp = $temp
        ::spice::dc vds [expr 1.8-$epsilon] 1.8 $epsilon 
        foreach_in_range L i2 {
            foreach_in_range WbyL i3 {
                set Ids_low  [::spice::get_spice_data V(${i2}_${i3}) 0]
                set Ids_high [::spice::get_spice_data V(${i2}_${i3}) 1]
                if {[catch {set Va [expr 1.8-$Ids_high/(($Ids_high-$Ids_low)/$epsilon)]} msg]} {
                    set Va 0.5
                }
                if {![regexp {^[0-9eE\+\-\.]+$} $Va]} {
                    report_vars Va L WbyL temp
                    exit
                }
                ^ @ look_up_tables/cmosn/Va($i2,$i3,$i4) = $Va
            }
        }
    }  
}
set index_range {}
foreach var {L WbyL temp} {
    lappend index_range $::constraints($var,index_range)
}
foreach array $short_views {
    @ /look_up_tables/cmosn/${array}([join $index_range ,]) !
}
foreach array $short_views {
    foreach_in_range L i3 {
        ::spice::array_set_legend /look_up_tables/cmosn/$array 0 $i3 $L
    }
    foreach_in_range WbyL i4 {
        ::spice::array_set_legend /look_up_tables/cmosn/$array 1 $i4 $WbyL
    }
    foreach_in_range temp i5 {
        ::spice::array_set_legend /look_up_tables/cmosn/$array 2 $i5 $temp
    }
}
wait_for_forked vt_characterization_task
wait_for_forked va_characterization_task
Info:  Measuring Ids(Vgs,Vds,Vbs,L,W,T) gm(Vgs,Vds,Vbs,L,W,T) and Ro(Vgs,Vds,Vbs,L,W,T)
######### Characterizing loops
set index_range {}
foreach var {Vgs Vds Vbs L WbyL temp} {
    lappend index_range $::constraints($var,index_range)
}
foreach_in_range temp i4 {
    fork_task ids_characterization_task {
	::spice::set temp = $temp
        Info: Temp=$temp ($i4/$::constraints(temp,index_range)) simulation started ([clock format [clock seconds]])
        ::spice::dc vbs $::constraints(Vbs,minval) $::constraints(Vbs,maxval) $::constraints(Vbs,step) vds $::constraints(Vds,minval) $::constraints(Vds,maxval) $::constraints(Vds,step) vgs $::constraints(Vgs,minval) $::constraints(Vgs,maxval) $::constraints(Vgs,step)
        Info: Temp=$temp ($i4/$::constraints(temp,index_range)) done Ids running. Saving results. ([clock format [clock seconds]])
        save_characterization_slice /tmp/ids.$i4 $index_range 3 2 $i4 1e6
        ::spice::dc vbs $::constraints(Vbs,minval) $::constraints(Vbs,maxval) $::constraints(Vbs,step) vds $::constraints(Vds,minval) $::constraints(Vds,maxval) $::constraints(Vds,step) vgs [expr $::constraints(Vgs,minval)+$::epsilon] [expr $::constraints(Vgs,maxval)+$::epsilon] $::constraints(Vgs,step)
        Info: Temp=$temp ($i4/$::constraints(temp,index_range)) done gm running. Saving results. ([clock format [clock seconds]])
        save_characterization_slice_differential /tmp/gm.$i4 $index_range 3 2 $i4 [expr 1e6/$::epsilon]
        ::spice::dc vbs $::constraints(Vbs,minval) $::constraints(Vbs,maxval) $::constraints(Vbs,step) vds [expr $::constraints(Vds,minval)+$::epsilon] [expr $::constraints(Vds,maxval)+$::epsilon] $::constraints(Vds,step) vgs $::constraints(Vgs,minval) $::constraints(Vgs,maxval) $::constraints(Vgs,step)
        Info: Temp=$temp ($i4/$::constraints(temp,index_range)) done ro running. Saving results. ([clock format [clock seconds]])
        save_characterization_slice_differential /tmp/ro.$i4 $index_range 3 2 $i4 /[expr 1e6/$::epsilon] 
   	Info: Temp=$temp ($i4/$::constraints(temp,index_range)) is done saving results. ([clock format [clock seconds]])
    }  4
}
set index_range {}
foreach var {Vgs Vds Vbs L WbyL temp} {
    lappend index_range $::constraints($var,index_range)
}
foreach array $views {
    @ look_up_tables/cmosn/${array}([join $index_range ,]) !
}
foreach array $views {
    foreach_in_range Vgs i0 { 
        ::spice::array_set_legend /look_up_tables/cmosn/$array 0 $i0 $Vgs
    }
    foreach_in_range Vds i1 {
        ::spice::array_set_legend /look_up_tables/cmosn/$array 1 $i1 $Vds
    }
    foreach_in_range Vbs i2 {
        ::spice::array_set_legend /look_up_tables/cmosn/$array 2 $i2 $Vbs
    }
    foreach_in_range L i3 {
        ::spice::array_set_legend /look_up_tables/cmosn/$array 3 $i3 $L
    }
    foreach_in_range WbyL i4 {
        ::spice::array_set_legend /look_up_tables/cmosn/$array 4 $i4 $WbyL
    }
    foreach_in_range temp i5 {
        ::spice::array_set_legend /look_up_tables/cmosn/$array 5 $i5 $temp
    }
}
wait_for_forked ids_characterization_task
Info: Done ([clock format [clock seconds]])
@ /look_up_tables/cmosn cd
foreach_in_range temp i4 {
    Info: Reading slice /tmp/ids.$i4
    load_characterization_slice Ids /tmp/ids.$i4
    Info: Reading slice /tmp/gm.$i4
    load_characterization_slice gm /tmp/gm.$i4
    Info: Reading slice /tmp/ids.$i4
    load_characterization_slice ro /tmp/ro.$i4
}
normalize_ids Ids
generate_lut Ids
normalize_ids gm
generate_lut gm
normalize_ids ro
generate_lut ro
@ /look_up_tables save $::env(RAMSPICE)/../nch.db
exit

@ /look_up_tables/cmosn cd
foreach_in_range temp i4 {
    source /tmp/ids.$i4
}
foreach field $::rusage_fields {
    Info: usage ([pid]) $field=[usage self $field], [usage children $field]
}
exit

return
###### Save Results
set O [open ../mosfet.lib w]
foreach array $short_views {
    foreach_in_range L i2 {
        puts $O [list ::spice::array_set_legend /look_up_tables/cmosn/$array 0 $i2 $L]
    }
    foreach_in_range WbyL i3 {
        puts $O [list ::spice::array_set_legend /look_up_tables/cmosn/$array 1 $i3 $WbyL]
    }
    foreach_in_range temp i4 {
        puts $O [list ::spice::array_set_legend /look_up_tables/cmosn/$array 2 $i4 $temp]
    }
    puts $O [list ::spice::array_data /look_up_tables/cmosn/$array [::spice::array_list look_up_tables/cmosn/$array]]
}
foreach array $views {
    foreach_in_range Vgs i0 { 
        puts $O [list ::spice::array_set_legend /look_up_tables/cmosn/$array 0 $i0 $Vgs]
    }
    foreach_in_range Vds i1 {
        puts $O [list ::spice::array_set_legend /look_up_tables/cmosn/$array 1 $i1 $Vds]
    }
    foreach_in_range L i2 {
        puts $O [list ::spice::array_set_legend /look_up_tables/cmosn/$array 2 $i2 $L]
    }
    foreach_in_range WbyL i3 {
        puts $O [list ::spice::array_set_legend /look_up_tables/cmosn/$array 3 $i3 $WbyL]
    }
    foreach_in_range temp i4 {
        puts $O [list ::spice::array_set_legend /look_up_tables/cmosn/$array 4 $i4 $temp]
    }
    puts $O [list ::spice::array_data /look_up_tables/cmosn/$array [::spice::array_list look_up_tables/cmosn/$array]]
}
close $O
foreach_in_range temp i4 {
    Info: Reading slice /tmp/ids.$i4
    load_characterization_slice Ids /tmp/ids.$i4
    Info: Reading slice /tmp/gm.$i4
    load_characterization_slice gm /tmp/gm.$i4
    Info: Reading slice /tmp/ids.$i4
    load_characterization_slice ro /tmp/ro.$i4
}


