set depth 2
set index_range [expr 1+int(pow(2,$depth))]
set epsilon 1e-2
set ::min_Ids 1e-12
set ::scalar_Ids_multiplier 3.9e-11
set ::limit_Ids_multiplier 1e-1
# Clean droppings
foreach droppings [glob -nocomplain /tmp/characterization_task*] {
    file delete $droppings
}
set index_range [expr 1+int(pow(2,$depth))]
# Procedure to predict Ids (up to a "constant" multiplier)
# the multiplier is not expected to be constant. 
# It is left to the LUT to provide the dependence of that multiplier 
# on the rest of the design/environment variables.
proc predict_Ids {Va Vt Vgs Vds WbyL temp} {
    if {$Vgs<$Vt} {
        return $::min_Ids
    }
    if {$Vds<=$Vgs-$Vt} {
        set Ids [expr ($temp+273)*$WbyL*(($Vgs-$Vt)*$Vds-0.5*$Vds*$Vds)]
    } else {
        set Ids [expr 0.5*($temp+273)*$WbyL*($Vgs-$Vt)*($Vgs-$Vt)*($Vds-$Va)/($Vgs-$Vt-$Va)]
    }
    limit_min Ids $::min_Ids
    if {$Ids<0} {
        report_vars Va Vt Vgs Vds WbyL temp Ids
	exit
    }
    return $Ids
}
set ::ids_sum 0
set ::ids_samp 0
proc average_ids {sum samp} {
    set ::ids_sum [expr $::ids_sum+$sum]
    set ::ids_samp [expr $::ids_sum+$samp]
}
set short_views {Vt Va Ro}
set views {Ids gm}
foreach field $::rusage_fields {
    Info: usage ([pid]) $field=[usage self $field], [usage children $field]
}
######### Template netlist
netlist {
    .include tsmc018.lib
    .temp 27 
    ** the N-transistor
    * name D G S B model L W 
}
set Lmin 1.8e-7
foreach_in_range 180e-9 900e-8 ${depth}b L i2 {
    foreach_in_range 1 500 ${depth}b WbyL i3 {
        set W [expr  $L*$WbyL]
        netlist "mn_${i2}_${i3} 3 1 ${i2}_${i3} 0 nch_rf L=$L W=$W AD=[expr 2.5*$Lmin*$W] AS=[expr 2.5*$Lmin*$W] PD=[expr 5*$Lmin+$W] PS=[expr 5*$Lmin+$W]"
        netlist "r_${i2}_${i3} ${i2}_${i3} 0 1e-6"
    }
}
netlist {
    Vds 3 0 dc 1.8
    Vgs 1 0 dc 0.9
    .end
}
set O [open test.sn w]
puts $O $template_netlist
close $O
update_netlist
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
foreach array $short_views {
    foreach_in_range 180e-9 900e-8 ${depth}b L i2 {
        ::spice::array_set_legend /look_up_tables/cmosn/$array 0 $i2 $L
    }
    foreach_in_range 1 500 ${depth}b WbyL i3 {
        ::spice::array_set_legend /look_up_tables/cmosn/$array 1 $i3 $WbyL
    }
    foreach_in_range -40 120 ${depth}b temp i4 {
        ::spice::array_set_legend /look_up_tables/cmosn/$array 2 $i4 $temp
    }
}
foreach array $views {
    foreach_in_range 0.01 2.0 ${depth}b Vgs i0 { 
        ::spice::array_set_legend /look_up_tables/cmosn/$array 0 $i0 $Vgs
    }
    foreach_in_range 0.01 2.0 ${depth}b Vds i1 {
        ::spice::array_set_legend /look_up_tables/cmosn/$array 1 $i1 $Vds
    }
    foreach_in_range 180e-9 900e-8 ${depth}b L i2 {
        ::spice::array_set_legend /look_up_tables/cmosn/$array 2 $i2 $L
    }
    foreach_in_range 1 500 ${depth}b WbyL i3 {
        ::spice::array_set_legend /look_up_tables/cmosn/$array 3 $i3 $WbyL
    }
    foreach_in_range -40 120 ${depth}b temp i4 {
        ::spice::array_set_legend /look_up_tables/cmosn/$array 4 $i4 $temp
    }
}


Info: Measuring Vt(W,L,T)
ETA $index_range Vt
foreach_in_range -40 120 ${depth}b temp i4 {
    ::spice::set temp = $temp
    ::spice::dc vgs [expr 1.0-$epsilon] 1.0 $epsilon
    foreach_in_range 180e-9 900e-8 ${depth}b L i2 {
        foreach_in_range 1 500 ${depth}b WbyL i3 {
            set Ids_low  [::spice::get_spice_data V(${i2}_${i3}) 0]
            set Ids_high [::spice::get_spice_data V(${i2}_${i3}) 1]
            if {[catch {set Vt [expr 1.0-$Ids_high/(($Ids_high-$Ids_low)/$epsilon)]} msg]} {
		set Vt 0.5
	    }
            if {![regexp {^[0-9eE\+\-\.]+$} $Vt]} {
                report_vars Vt L WbyL temp
                exit
            }
            @ look_up_tables/cmosn/Vt($i2,$i3,$i4) = $Vt
        }
    }
    ETA
}

Info: Measuring Va(W,L,T) and Ro(W,L,T)
ETA $index_range Va
foreach_in_range -40 120 ${depth}b temp i4 {
    ::spice::set temp = $temp
    ::spice::dc vds [expr 1.8-$epsilon] 1.8 $epsilon 
    foreach_in_range 180e-9 900e-8 ${depth}b L i2 {
        foreach_in_range 1 500 ${depth}b WbyL i3 {
            set Ids_low  [::spice::get_spice_data V(${i2}_${i3}) 0]
            set Ids_high [::spice::get_spice_data V(${i2}_${i3}) 1]
            if {[catch {set Va [expr 1.8-$Ids_high/(($Ids_high-$Ids_low)/$epsilon)]} msg]} {
		set Va 0.5
	    }
            if {![regexp {^[0-9eE\+\-\.]+$} $Va]} {
                report_vars Va L WbyL temp
                exit
            }
            set Ro [expr 1e6*(($Ids_high-$Ids_low)/$epsilon)]
            if {![regexp {^[0-9eE\+\-\.]+$} $Ro]} {
                report_vars Vo L WbyL temp
                exit
            }
            @ look_up_tables/cmosn/Va($i2,$i3,$i4) = $Va
            @ look_up_tables/cmosn/Ro($i2,$i3,$i4) = $Ro
        }
    }
    ETA
}
######### Characterizing loops
set thread_list {}
foreach_in_range -40 120 ${depth}b temp i4 {
    fork_task characterization_task {
        set average_Ids 0
	set no_samples 0
        ::spice::set temp = $temp
        ::spice::dc vds 0.01 2.0 [expr (2.0-0.01)/pow(2,$depth)] vgs 0.01 2.0 [expr (2.0-0.01)/pow(2,$depth)]
        ETA $index_range Ids
        foreach_in_range 0.01 2.0 ${depth}b Vgs i0 {
            foreach_in_range 0.01 2.0 ${depth}b Vds i1 {
                foreach_in_range 180e-9 900e-8 ${depth}b L i2 {
                    foreach_in_range 1 500 ${depth}b WbyL i3 {
		        W=$L*$WbyL
                        set Vt [@ look_up_tables/cmosn/Vt($i2,$i3,$i4)]
                        set Va [@ look_up_tables/cmosn/Va($i2,$i3,$i4)]
                        if {[catch {set predicted_Ids [est_Ids look_up_tables/cmosn/Va look_up_tables/cmosn/Vt $Vgs $Vds $L $WbyL $temp]} msg]} {
                            Error: $msg
                            report_vars Va Vt Vgs Vds L WbyL temp predicted_Ids 
                            exit
                        }
                        set spice_vector_index [expr $index_range*$i0+$i1]
                        set spice_sample [expr 1e6*[::spice::get_spice_data V(${i2}_${i3}) $spice_vector_index]]
			report_vars Vgs Vds L W temp spice_sample
                        set Ids [expr $spice_sample/$predicted_Ids]
		        if {$Ids>1e-10} {
			    set Ids $::scalar_Ids_multiplier
			} else {
			     set average_Ids [expr $average_Ids+$Ids]
			     incr no_samples
		        }
			if {$Ids<0} {
			    report_vars predicted_Ids spice_sample Ids
			}
                        if {![regexp {^[0-9eE\+\-\.]+$} $Ids]} {
                            report_vars predicted_Ids spice_sample spice_vector_index
                        }
                        ^ @ look_up_tables/cmosn/Ids($i0,$i1,$i2,$i3,$i4) =  $Ids
                    }
                }
            } 
            ETA
        } 
#        ::spice::dc vds 0.01 2.0 [expr (2.0-0.01)/pow(2,$depth)] vgs [expr 0.01+$epsilon] [expr 2.0+$epsilon] [expr (2.0-0.01)/pow(2,$depth)]
#        ETA $index_range gm
#        foreach_in_range 0.01 2.0 ${depth}b Vgs i0 {
#            foreach_in_range 0.01 2.0 ${depth}b Vds i1 {
#                foreach_in_range 180e-9 900e-8 ${depth}b L i2 {
#                    foreach_in_range 1 500 ${depth}b WbyL i3 {
#                        set Vt [@ look_up_tables/cmosn/Vt($i2,$i3,$i4)]
#                        set Va [@ look_up_tables/cmosn/Va($i2,$i3,$i4)]
#                        set predicted_Ids [est_Ids look_up_tables/cmosn/Va look_up_tables/cmosn/Vt $Vgs $Vds $L $WbyL $temp]
#                        set spice_vector_index [expr $index_range*$i0+$i1]
#                        set Ids [expr [@ look_up_tables/cmosn/Ids($i0,$i1,$i2,$i3,$i4)]*$predicted_Ids]
#                        set spice_sample [expr 1e6*[::spice::get_spice_data V(${i2}_${i3}) $spice_vector_index]]
#			limit_min spice_sample $::min_Ids
#                        ^ @ look_up_tables/cmosn/gm($i0,$i1,$i2,$i3,$i4) = [expr ($spice_sample-$Ids)/$epsilon]
#                    }
#                }
#            } 
#            ETA
#        } 
        Info: Average multiplier is [expr $average_Ids/$no_samples] temp=$temp
    }
}
wait_for_forked characterization_task
foreach field $::rusage_fields {
    Info: usage ([pid]) $field=[usage self $field], [usage children $field]
}
###### Save Results
set O [open ../mosfet.lib w]
foreach array $short_views {
    foreach_in_range 180e-9 900e-8 ${depth}b L i2 {
        puts $O [list ::spice::array_set_legend /look_up_tables/cmosn/$array 0 $i2 $L]
    }
    foreach_in_range 1 500 ${depth}b WbyL i3 {
        puts $O [list ::spice::array_set_legend /look_up_tables/cmosn/$array 1 $i3 $WbyL]
    }
    foreach_in_range -40 120 ${depth}b temp i4 {
        puts $O [list ::spice::array_set_legend /look_up_tables/cmosn/$array 2 $i4 $temp]
    }
    puts $O [list ::spice::array_data /look_up_tables/cmosn/$array [::spice::array_list look_up_tables/cmosn/$array]]
}
foreach array $views {
    foreach_in_range 0.01 2.0 ${depth}b Vgs i0 { 
        puts $O [list ::spice::array_set_legend /look_up_tables/cmosn/$array 0 $i0 $Vgs]
    }
    foreach_in_range 0.01 2.0 ${depth}b Vds i1 {
        puts $O [list ::spice::array_set_legend /look_up_tables/cmosn/$array 1 $i1 $Vds]
    }
    foreach_in_range 180e-9 900e-8 ${depth}b L i2 {
        puts $O [list ::spice::array_set_legend /look_up_tables/cmosn/$array 2 $i2 $L]
    }
    foreach_in_range 1 500 ${depth}b WbyL i3 {
        puts $O [list ::spice::array_set_legend /look_up_tables/cmosn/$array 3 $i3 $WbyL]
    }
    foreach_in_range -40 120 ${depth}b temp i4 {
        puts $O [list ::spice::array_set_legend /look_up_tables/cmosn/$array 4 $i4 $temp]
    }
    puts $O [list ::spice::array_data /look_up_tables/cmosn/$array [::spice::array_list look_up_tables/cmosn/$array]]
}
close $O

