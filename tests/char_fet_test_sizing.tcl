source tests/char_constraints_test_sizing.tcl
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
array set Is {}
for {set WbyL 1} {$WbyL<100} {incr WbyL} {
set Is($WbyL) {}
for {set Lsize 1} {$Lsize<10} {incr Lsize} {
    comment_box "WbyL=$WbyL"
    netlist ".include $::env(RAMSPICE_TECH)"
    netlist {
        .temp 27 
        ** the N-transistor
        * name D G S B model L W 
    }
    set Lmin 1.8e-7
    set L [expr 1.8e-7*$Lsize]
    set W [expr  $L*$WbyL]
    netlist "mn_0_0 3 1 0_0 4 nch_ff L=$L W=$W AD=[expr 2.5*$Lmin*$W] AS=[expr 2.5*$Lmin*$W] PD=[expr 5*$Lmin+$W] PS=[expr 5*$Lmin+$W]"
    # netlist "mn_0_0 3 1 0_0 4 nch_tt L=$L W=$W"
    netlist "r_0_0 0_0 0 1e-12"
    netlist {
        Vds 3 0 dc 1.8 ac 0
        Vgs 1 0 dc 1.8 ac 0
        Vbs 4 0 dc 0 ac 0
        .end
    }
    set O [open test.sn w]
    puts $O $template_netlist
    close $O
    update_netlist
    
    ######### Initialize database
    @ /look_up_tables/cmosn !
    
    Info:  Measuring Ids(Vgs,Vds,Vbs) gm(Vgs,Vds,Vbs) and Ro(Vgs,Vds,Vbs)
    ######### Characterizing loops
    set index_range {}
    foreach var {Vgs Vds Vbs} {
        lappend index_range $::constraints($var,index_range)
    }
    Info: simulation started ([clock format [clock seconds]])
#    ::spice::dc vbs $::constraints(Vbs,minval) $::constraints(Vbs,maxval) $::constraints(Vbs,step) vds $::constraints(Vds,minval) $::constraints(Vds,maxval) $::constraints(Vds,step) vgs $::constraints(Vgs,minval) $::constraints(Vgs,maxval) $::constraints(Vgs,step)
#    Info: done Ids running. Saving results. ([clock format [clock seconds]])
#    save_characterization_slice /tmp/ids.0 $index_range 3 2 0 1e6
     ::spice::op
     set Ids [expr 1e12*[::spice::get_spice_data V(0_0) end]]
     set Isize [expr $Ids/$WbyL]
     puts "WbyL=$WbyL   Ids=$Ids   Isize=$Isize"
     lappend Is($WbyL) $Isize
}
}
for {set WbyL 1} {$WbyL<100} {incr WbyL} {
    puts $Is($WbyL)
}
exit
::spice::dc vbs $::constraints(Vbs,minval) $::constraints(Vbs,maxval) $::constraints(Vbs,step) vds $::constraints(Vds,minval) $::constraints(Vds,maxval) $::constraints(Vds,step) vgs [expr $::constraints(Vgs,minval)+$::epsilon] [expr $::constraints(Vgs,maxval)+$::epsilon] $::constraints(Vgs,step)
Info: done gm running. Saving results. ([clock format [clock seconds]])
save_characterization_slice_differential /tmp/gm.0 $index_range 3 2 0 [expr 1e6/$::epsilon]
::spice::dc vbs $::constraints(Vbs,minval) $::constraints(Vbs,maxval) $::constraints(Vbs,step) vds [expr $::constraints(Vds,minval)+$::epsilon] [expr $::constraints(Vds,maxval)+$::epsilon] $::constraints(Vds,step) vgs $::constraints(Vgs,minval) $::constraints(Vgs,maxval) $::constraints(Vgs,step)
Info: done ro running. Saving results. ([clock format [clock seconds]])
save_characterization_slice_differential /tmp/ro.0 $index_range 3 2 0 /[expr 1e6/$::epsilon] 
Info: is done saving results. ([clock format [clock seconds]])
set index_range {}
foreach var {Vgs Vds Vbs} {
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
}
Info: Done ([clock format [clock seconds]])
@ /look_up_tables/cmosn cd
Info: Reading slice /tmp/ids.0
load_characterization_slice Ids /tmp/ids.0
Info: Reading slice /tmp/gm.0
load_characterization_slice gm /tmp/gm.0
Info: Reading slice /tmp/ro.0
load_characterization_slice ro /tmp/ro.0
# normalize_ids Ids
generate_lut Ids
#  normalize_ids gm
generate_lut gm
#  normalize_ids ro
generate_lut ro
@ /look_up_tables save $::env(RAMSPICE)/../nch.db
