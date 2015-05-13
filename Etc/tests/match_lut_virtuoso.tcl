    netlist {
        .include tsmc018_from_cadence.lib
        .temp = 125.0
    }
    set Lmin 1.8e-7
    set xwidth 1.8e-6
    set xlength 1.8e-07
#    netlist "m_test 3 3 4 0 NCH_SS L=$xlength W=$xwidth AD=[expr 2.5*$Lmin*$xwidth] AS=[expr 2.5*$Lmin*$xwidth] PD=[expr 5*$Lmin+$xwidth] PS=[expr 5*$Lmin+$xwidth]"
set factor 100
#    netlist "m_test 3 3 4 0 NCH_SS L=$xlength W=$xwidth AD=[expr $factor*$Lmin*$xwidth] AS=[expr $factor*$Lmin*$xwidth] PD=[expr 2*$factor*$Lmin+$xwidth] PS=[expr 2*$factor*$Lmin+$xwidth]"
    netlist "m_test 3 3 4 0 NCH_SS L=$xlength W=$xwidth"
    netlist {
        r_test 4 0 1e-6
        ids 0 3 dc 5e-5 ac 0
        .end
    }
    update_netlist
    ::spice::dc ids 50e-6 300e-6 50e-6
    set Ids 50
for {set i 0} {$i<[::spice::get_spice_data V(3) length]} {incr i} {    
    set virtVgs [lindex {0.692284 0.796683 0.796683 0.961232 0.961232 1.1086} $i]
    set Vgs [::spice::get_spice_data V(3) $i]
    puts "virtVgs=$virtVgs Ids=$Ids Vgs=$Vgs [expr 100*abs($virtVgs/$Vgs-1)]"
    incr Ids 50
}
return
@ . add string look_up_tables
@ look_up_tables add string cmosn
@ /look_up_tables/cmosn cd
array_load $::env(RAMSPICE)/../nch.db


# Parser definitions
proc Extracted: args {}
proc count {args} {
    set ::field_list $args
}
set unknown {
    if {[regexp {^[0-9]+\s} $args]} {
        set count [lindex $args 0]
        set sub 1
        while {[info exists ::virtuoso($count,$sub,ratio)]} {
            incr sub
        }
        set count $count,$sub
        lappend ::entry_list $count
        foreach field $::field_list val [lrange $args 1 end] {
            set ::virtuoso($count,$field) $val
        }
        return
    }
}
append unknown [info body unknown]
proc unknown args $unknown

set ::entry_list {}
source ~/gm_full.txt
foreach entry $::entry_list {
    if {$::virtuoso($entry,corner_name)!="slow"} continue
    if {$::virtuoso($entry,device_display_name)!="nmos2v"} continue
    foreach field $::field_list {
        set $field $::virtuoso($entry,$field)
    }
    set xwidth [expr $xratio*$xlength]
    set ramspice_ids [expr 1e6*[::spice::get_spice_data V(4) 0]]
    clear_circuit
    # Test LUT
    set estimation_list [get_Ids_direct Ids 0.692284 1.8 $xlength $xratio 125]
    set isize [lindex $estimation_list end]
    if {[catch {set estimation [expr $isize*$xratio]}]} continue
    foreach var {
        entry xlength xratio vdrain_value ref_vgs drain_current 
    isize estimation ramspice_ids} {
        puts -nonewline $var
        puts -nonewline =
        puts -nonewline [set $var]
        puts -nonewline "\t"
    }
    puts ""
    break
}
