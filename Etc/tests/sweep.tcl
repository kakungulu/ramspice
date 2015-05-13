source tests/vectors.tcl
set temp 27
set Lmin 2.2e-7
set Lsize 1
set WbyL 1
### array set ::offsets {
###  1  1.09164212505855414*1.008398279085247637
###  6  1.09084332944488368*1.008252510504631777
###  11 1.08754576383172312*1.007664260764879791
###  16 1.07507107134449242*1.00563566575280986
### }
array set ::average_errors {}
array set ::count_errors {}
set ::all_sections {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16}
foreach section {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16} {
    Info: $section $::bin(n,$section,lmin) $::bin(n,$section,lmax) $::bin(n,$section,wmin) $::bin(n,$section,wmax)
}
foreach {Vgs VirtIds} $test_vector(W_7u_L220n_Vgs) {
    
    set L 2.2e-7
    set W 7.005e-6
#    set W [expr 1*$L]
    set WbyL [expr $W/$L]
    Info: WbyL=$WbyL
    set Lsize [expr $L/$Lmin]
    set min_error 1000
    foreach section {4 8} {
#    set section [find_mosfet_bin n $L $W]
    if {![info exists ::offsets($section)]} {
        set ::offsets($section) 1
    }
    if {![info exists ::average_errors($section)]} {
        set ::average_errors($section) 0
    }
    if {![info exists ::count_errors($section)]} {
        set ::count_errors($section) 0
    }
    incr ::count_errors($section)
    netlist ".include $::env(RAMSPICE)/tsmc018_from_cadence.lib"
    netlist {
        ** the N-transistor
        * name D G S B model L W 
    }
    netlist ".temp $::temp"
    netlist "mn_0_0 3 1 0_0 4 nch_tt_$section L=$L W=$W AD=[expr 2.5*$Lmin*$W] AS=[expr 2.5*$Lmin*$W] PD=[expr 5*$Lmin+$W] PS=[expr 5*$Lmin+$W]"
    netlist "Vgs 1 0 dc $Vgs ac 0"
    netlist {
        r_0_0 0_0 0 1e-12
        Vds 3 0 dc 1.8 ac 0
        Vbs 4 0 dc 0 ac 0
        .end
    }
    update_netlist
    ::spice::op
    set Ids [expr [::spice::get_spice_data V(0_0) 0]*1e12*$::offsets($section)]
    set Ids_section($section) $Ids
    set error [expr 100*($Ids/$VirtIds-1)]
    set error_section($section) $error
    Info:  $section >>> $error
    if {abs($error)<abs($min_error)} {
        set min_error $error
	set min_section $section
	set minIds $Ids
    }
    }
    set ::average_errors($section) [expr $::average_errors($section)+$min_error]
    Info: Vgs=$Vgs L=$L section=$min_section ([find_mosfet_bin n $L $W]) Ids=$minIds Virtuoso=$VirtIds Error=$min_error
}
foreach section [array names ::average_errors] {
    Info: section=$section average=[expr $::average_errors($section)/$::count_errors($section)]
}


