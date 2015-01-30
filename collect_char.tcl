source spice_lib.tcl
set depth 5
set index_range [expr 1+int(pow(2,$depth))]
set epsilon 1e-2
set short_views {Vt Va Ro}
set views {Ids gm}
set ::min_Ids 1e-9
proc average_ids args {}
######### Initialize database
@ . add string look_up_tables
@ look_up_tables add string cmosn
foreach array $views {
    @ look_up_tables/cmosn add string $array
    @ look_up_tables/cmosn/$array add array $index_range,$index_range,$index_range,$index_range,$index_range
}
foreach array $short_views {
    @ look_up_tables/cmosn add string $array
    @ look_up_tables/cmosn/$array add array $index_range,$index_range,$index_range
}
foreach file [glob /tmp/characterization_task*] {
    Info: Sourcing $file
    source $file
}
###### Save Results
set O [open ../mosfet.lib w]
foreach array $short_views {
    foreach_in_range 180e-9 180e-8 ${depth}b L i2 {
        puts $O [list ::spice::array_set_legend look_up_tables/cmosn/$array 0 $i2 $L]
    }
    foreach_in_range 1 500 ${depth}b WbyL i3 {
        puts $O [list ::spice::array_set_legend look_up_tables/cmosn/$array 1 $i3 $WbyL]
    }
    foreach_in_range -40 120 ${depth}b temp i4 {
        puts $O [list ::spice::array_set_legend look_up_tables/cmosn/$array 2 $i4 $temp]
    }
    puts $O [list ::spice::array_data look_up_tables/cmosn/$array [::spice::array_list look_up_tables/cmosn/$array]]
}
foreach array $views {
    foreach_in_range 0.01 2.0 ${depth}b Vgs i0 { 
        puts $O [list ::spice::array_set_legend look_up_tables/cmosn/$array 0 $i0 $Vgs]
    }
    foreach_in_range 0.01 2.0 ${depth}b Vds i1 {
        puts $O [list ::spice::array_set_legend look_up_tables/cmosn/$array 1 $i1 $Vds]
    }
    foreach_in_range 180e-9 900e-9 ${depth}b L i2 {
        puts $O [list ::spice::array_set_legend look_up_tables/cmosn/$array 2 $i2 $L]
    }
    foreach_in_range 1 500 ${depth}b WbyL i3 {
        puts $O [list ::spice::array_set_legend look_up_tables/cmosn/$array 3 $i3 $WbyL]
    }
    foreach_in_range -40 120 ${depth}b temp i4 {
        puts $O [list ::spice::array_set_legend look_up_tables/cmosn/$array 4 $i4 $temp]
    }
    puts $O [list ::spice::array_data look_up_tables/cmosn/$array [::spice::array_list look_up_tables/cmosn/$array]]
}
close $O

