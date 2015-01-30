source tests/char_constraints.tcl
set depth 4
set extra_depth 7
set index_range [expr 1+int(pow(2,$depth))]
set extra_index_range [expr 1+int(pow(2,$extra_depth))]
set ::epsilon 0.01
set ::mid_vgs 0.8
################################################################
# Pre-calculating some constants for Vt calculation ahead
################################################################
set ::low_vgs [expr $::mid_vgs-$::epsilon]
set ::high_vgs [expr $::mid_vgs+$::epsilon]
set ::epsilon21 [expr $::mid_vgs*$::mid_vgs-$::low_vgs*$::low_vgs]
set ::epsilon32 [expr $::high_vgs*$::high_vgs-$::mid_vgs*$::mid_vgs]
set ::epsilon321 [expr $::high_vgs*$::high_vgs-2*$::mid_vgs*$::mid_vgs+$::low_vgs*$::low_vgs]
################################################################
# Clean droppings
################################################################
foreach droppings [glob -nocomplain /tmp/characterization_task*] {
    file delete $droppings
}
################################################################

set short_views {Vt Va Ro}
set long_views {Ids gm}

foreach field $::rusage_fields {
    Info: usage ([pid]) $field=[usage self $field], [usage children $field]
}
######### Template netlist
netlist {
    .include tsmc018.lib
    .temp 27 
    ** the N-transistor
    * name D G S B model L W
    r_1 4 0 1e-6 
}
set Lmin 1.8e-7
set W 1.8e-7
netlist "m_1 3 1 4 0 nch_rf L=$Lmin W=$W AD=[expr 2.5*$Lmin*$W] AS=[expr 2.5*$Lmin*$W] PD=[expr 5*$Lmin+$W] PS=[expr 5*$Lmin+$W]"
netlist {
    vds 3 0 dc 1.8
    vgs 1 0 dc 0.9
    .end
}
set O [open test.sn w]
puts $O $template_netlist
close $O
update_netlist

######### Initialize database
@ . add string look_up_tables
@ look_up_tables add string cmosn
set index_range {}
foreach var {L WbyL temp} {
    lappend index_range $::constraints($var,index_range)
}
foreach array $short_views {
    @ look_up_tables/cmosn add string $array
    @ look_up_tables/cmosn/$array add array [join $index_range ,]
}
foreach array $short_views {
    foreach_in_range L i2 {
        ::spice::array_set_legend /look_up_tables/cmosn/$array 0 $i2 $L
    }
    foreach_in_range WbyL i3 {
        ::spice::array_set_legend /look_up_tables/cmosn/$array 1 $i3 $WbyL
    }
    foreach_in_range temp i4 {
        ::spice::array_set_legend /look_up_tables/cmosn/$array 2 $i4 $temp
    }
}

Info: Measuring Vt(W,L,T)
ETA $::constraints(temp,index_range) Vt
Info: low_vgs=$::low_vgs high_vgs=$::high_vgs epsilon=$::epsilon
foreach_in_range temp i4 {
    ::spice::set temp = $temp
    foreach_in_range L i2 {
        foreach_in_range WbyL i3 {
            m_1 L $L
            m_1 W [expr $L*$WbyL]
            ::spice::dc vgs $::low_vgs $::high_vgs $epsilon
            set Ids_low  [::spice::get_spice_data V(4) 0]
            set Ids_mid [::spice::get_spice_data V(4) 1]
            set Ids_high [::spice::get_spice_data V(4) 2]
            set coeff [expr ($Ids_high-2*$Ids_mid+$Ids_low)/$::epsilon321]
            if {[catch {set Vt_high [expr ($Ids_mid-$Ids_low-$coeff*$::epsilon21)/(-2*$coeff*$::epsilon)]} msg]} {
                Error:$msg
                exit
            }
            if {[catch {set Vt_low [expr ($Ids_high-$Ids_mid-$coeff*$::epsilon32)/(-2*$coeff*$::epsilon)]} msg]} {
                Error:$msg
                exit
            }
            set Vt [expr ($Vt_high+$Vt_low)*0.5] 
            if {![regexp {^[0-9eE\+\-\.]+$} $Vt]} {
                report_vars Vt L WbyL temp
                exit
            }
            @ look_up_tables/cmosn/Vt($i2,$i3,$i4) = $Vt
        }
    }
    ETA
}

Info: Measuring Va(W,L,T) 
ETA $::constraints(temp,index_range) Va
foreach_in_range temp i4 {
    ::spice::set temp = $temp
    foreach_in_range L i2 {
        foreach_in_range WbyL i3 {
            m_1 L $L
            m_1 W [expr $L*$WbyL]
            ::spice::dc vds [expr 1.8-$epsilon] 1.8 $epsilon 
            set Ids_low  [::spice::get_spice_data V(4) 0]
            set Ids_high [::spice::get_spice_data V(4) 1]
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
proc calculate_vgs_vds {sweep_vector_name Vt} {
    upvar $sweep_vector_name sweep_vector
    set sweep_vector {}
    puts "Vt=$Vt"
    foreach_in_range DVgs i0 {
        foreach_in_range DVds i1 {
            set Vgs [expr $DVgs*$Vt]
            puts "DVgs=$DVgs Vgs=$Vgs"
            set Vds [expr ($DVds-9)*$Vt+$Vgs]
            puts "DVds=$DVds Vds=$Vds"
            lappend sweep_vector $Vgs
            lappend sweep_vector $Vds
        }
    }    
    exit
}
######### Characterizing loops
foreach_in_range temp i4 {
    fork_task characterization_task {
        ::spice::set temp = $temp
        #        ::spice::dc vds $::constraints(DVds,minval) $::constraints(DVds,maxval) [expr ($::constraints(DVds,maxval)-$::constraints(DVds,minval))/pow(2,$::constraints(DVds,depth))] vgs $::constraints(DVgs,minval) $::constraints(DVgs,maxval) [expr ($::constraints(DVgs,maxval)-$::constraints(DVgs,minval))/pow(2,$::constraints(DVgs,depth))]
        ETA $::constraints(L,index_range) Ids
        foreach_in_range L i2 {
            foreach_in_range WbyL i3 {
                m_1 L $L
                m_1 W [expr $L*$WbyL]
                set Vt [@ look_up_tables/cmosn/Vt($i2,$i3,$i4)]
                set Va [@ look_up_tables/cmosn/Va($i2,$i3,$i4)]
                calculate_vgs_vds sweep_vector $Vt
		
                set sweep [sweep {vgs dc vds dc} $sweep_vector V(4)]
                set i 0
                foreach_in_range DVgs i0 {
                    foreach_in_range DVds i1 {
                        set Vgs [expr $DVgs*$Vt]
                        set Vds [expr ($DVds-9)*$Vt+$Vgs]
                        if {[catch {set predicted_Ids [est_Ids_direct $Va $Vt $Vgs $Vds $L $WbyL $temp]} msg]} {
                            Error: $msg
                            report_vars Va Vt Vgs Vds L WbyL temp predicted_Ids 
                            exit
                        }
                        set spice_vector_index [expr $::constraints(DVds,index_range)*$i0+$i1]
                        set spice_sample [expr 1e6*[lindex $sweep $i]]
                        incr i
                        #			report_vars spice_sample predicted_Ids
                        if {[catch {set Ids [expr $spice_sample/$predicted_Ids]} msg]} {
                            report_vars spice_sample  Va Vt Vgs Vds L WbyL predicted_Ids
                            #  exit
                        }
                        #		report_vars spice_sample predicted_Ids Ids
                        if {$Ids>1e-2} {
                            set Ids 1e-2
                        }
                        if {![regexp {^[0-9eE\+\-\.]+$} $Ids]} {
                            report_vars predicted_Ids spice_sample Va_internal Va Vt_internal Vt Vgs Vds L WbyL Ids
                        }
                        ^ @ look_up_tables/cmosn/Ids($i0,$i1,$i2,$i3,$i4) =  $Ids
                    }
                }
            } 
            ETA
        } 
        #       ::spice::dc vds $::constraints(DVds,minval) $::constraints(DVds,maxval) [expr ($::constraints(DVds,maxval)-$::constraints(DVds,minval))/pow(2,$::constraints(DVds,depth))] vgs [expr $::constraints(DVgs,minval)+$epsilon] [expr $::constraints(DVgs,maxval)+$epsilon] [expr ($::constraints(DVgs,maxval)-$::constraints(DVgs,minval))/pow(2,$::constraints(DVgs,depth))]
        #       ETA $::constraints(DVgs,index_range) gm
        #       foreach_in_range Vgs i0 {
            #	   foreach_in_range Vds i1 {
                #	       foreach_in_range L i2 {
                    #		   foreach_in_range WbyL i3 {
                        #		       set Vt [@ look_up_tables/cmosn/Vt($i2,$i3,$i4)]
                        #		       set Va [@ look_up_tables/cmosn/Va($i2,$i3,$i4)]
                        #		       set predicted_Ids [est_Ids look_up_tables/cmosn/Va look_up_tables/cmosn/Vt $Vgs $Vds $L $WbyL $temp]
                        #		       set spice_vector_index [expr $::constraints(DVds,index_range)*$i0+$i1]
                        #		       set Ids [@ look_up_tables/cmosn/Ids($i0,$i1,$i2,$i3,$i4)]
                        #		       set spice_sample [expr 1e6*[::spice::get_spice_data V(${i2}_${i3}) $spice_vector_index]]
                        #                       set Ids_eps [expr $spice_sample/$predicted_Ids]
                        #		       ^ @ look_up_tables/cmosn/gm($i0,$i1,$i2,$i3,$i4) = [expr ($Ids_eps-$Ids)/$epsilon]
                    #		   }
                #	       }
            #	   } 
            #	   ETA
        #       } 
    }
}
wait_for_forked characterization_task
set index_range {}
foreach var {DVgs DVds L WbyL temp} {
    lappend index_range $::constraints($var,index_range)
}
foreach array $long_views {
    @ look_up_tables/cmosn add string $array
    @ look_up_tables/cmosn/$array add array [join $index_range ,]
}
foreach array $long_views {
    foreach_in_range Vgs i0 { 
        ::spice::array_set_legend /look_up_tables/cmosn/$array 0 $i0 $Vgs
    }
    foreach_in_range Vds i1 {
        ::spice::array_set_legend /look_up_tables/cmosn/$array 1 $i1 $Vds
    }
    foreach_in_range L i2 {
        ::spice::array_set_legend /look_up_tables/cmosn/$array 2 $i2 $L
    }
    foreach_in_range WbyL i3 {
        ::spice::array_set_legend /look_up_tables/cmosn/$array 3 $i3 $WbyL
    }
    foreach_in_range temp i4 {
        ::spice::array_set_legend /look_up_tables/cmosn/$array 4 $i4 $temp
    }
}

foreach field $::rusage_fields {
    Info: usage ([pid]) $field=[usage self $field], [usage children $field]
}
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
foreach array $long_views {
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

