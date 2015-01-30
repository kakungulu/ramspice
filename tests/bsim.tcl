source tests/char_constraints_noise.tcl
set views {noise_corner thermal_noise}
set total_array_volume 1
foreach var {Vgs Ids WbyL Lsize} {
    lappend index_range $::constraints($var,index_range)
    set total_array_volume [expr $total_array_volume*$::constraints($var,index_range)]
}
foreach array $views {
    @ look_up_tables/cmosn/${array}([join $index_range ,]) !
}
foreach array $views {
    foreach_in_range Vgs i0 { 
        ::spice::array_set_legend /look_up_tables/cmosn/$array 0 $i0 $Vgs
    }
    foreach_in_range Ids i1 {
        ::spice::array_set_legend /look_up_tables/cmosn/$array 1 $i1 $Ids
    }
    foreach_in_range WbyL i2 {
        ::spice::array_set_legend /look_up_tables/cmosn/$array 2 $i2 $WbyL
    }
    foreach_in_range Lsize i3 {
        ::spice::array_set_legend /look_up_tables/cmosn/$array 3 $i3 $Lsize
    }
}
set Lmin 180e-9
proc noise_cont {coord} {
    @ look_up_tables/cmosn/noise_corner($coord) = 0
    return -code continue
}
ETA $total_array_volume
foreach_in_range Vgs i0 {
foreach_in_range Ids i1 {
    puts "Ids=$Ids"
foreach_in_range WbyL i2 {
foreach_in_range Lsize i3 {
    set L [expr $Lsize*$Lmin]
    set W [expr $L*$WbyL]
    netlist {
        .include tsmc018_from_cadence.lib
        .temp 27 
        ** the N-transistor
        * name D G S B model L W 
        rtest 3_1 3 1e-12
    }
    netlist "mn_0_0 3 2 0 0 nch_tt L=$L W=$W AD=[expr 2.5*$Lmin*$W] AS=[expr 2.5*$Lmin*$W] PD=[expr 5*$Lmin+$W] PS=[expr 5*$Lmin+$W]"
    netlist "Ids 3_1 0 dc $Ids ac 0"
    netlist "Vgs 2   0 dc $Vgs ac 0"
    netlist {
        .end
    }
    set O [open test.sn w]
    puts $O $template_netlist
    close $O
    update_netlist
    ::spice::noise v(3) vgs lin 10000 1 10000
    set thermal_noise [::spice::get_spice_data onoise_spectrum end]
    @ look_up_tables/cmosn/thermal_noise($i0,$i1,$i2,$i3) = $thermal_noise
    ETA
    set Ssi [::spice::get_spice_data Captured_Ssi end]
    if {[string match *nan* $Ssi]} {
        noise_cont $i0,$i1,$i2,$i3
    }
    set Captured_EffFreq [::spice::get_spice_data Captured_EffFreq end]
    if {[string match *nan* $Captured_EffFreq]} {
        noise_cont $i0,$i1,$i2,$i3
    }
    if {$Ssi<$thermal_noise} {
        noise_cont $i0,$i1,$i2,$i3
    }
    set flicker_noise [expr sqrt($Ssi*$Ssi-$thermal_noise*$thermal_noise)]
    set flicker_const [expr $Captured_EffFreq*$flicker_noise]
    set corner [expr $flicker_const/$thermal_noise]
}
}
}
}

@ look_up_tables/cmosn save ../noise.db


