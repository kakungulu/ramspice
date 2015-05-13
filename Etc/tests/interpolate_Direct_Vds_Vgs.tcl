source tests/char_constraints_Direct_Vds_Vgs.tcl
set views {Ids gm ro}
set views Ids
set short_views {Vt Va}
set depth 4
set extra_depth 7
set index_range [expr 1+int(pow(2,$depth))]
set extra_index_range [expr 1+int(pow(2,$extra_depth))]
set ::min_Ids 1e-13
######### Initialize database
@ . add string look_up_tables
@ look_up_tables add string cmosn
set index_range {}
foreach var {Vgs Vds L WbyL temp} {
    lappend index_range $::constraints($var,index_range)
}
foreach array $views {
    @ look_up_tables/cmosn add string $array
    @ look_up_tables/cmosn/$array add array [join $index_range ,]
}
set index_range {}
foreach var {L WbyL temp} {
    lappend index_range $::constraints($var,index_range)
}
foreach array $short_views {
    @ look_up_tables/cmosn add string $array
    @ look_up_tables/cmosn/$array add array [join $index_range ,]
}
@ /look_up_tables/cmosn cd

Info: Loading LUT
#array_load $::env(RAMSPICE)/../mosfet.lib
Info: Loaded LUT
foreach_in_range temp i4 {
    foreach view $views {
        set filename /tmp/
	append filename [string tolower $view]
	append filename .
	append filename $i4
        Info: Reading slice $filename
        load_characterization_slice $view $filename
    }
}
foreach array $views {
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
Info: Saving Vt
array_save Vt  $::env(RAMSPICE)/../nch.db
Info: Saving Va
array_save Va  $::env(RAMSPICE)/../nch.db append
foreach view $views {
    normalize_ids $view
    Info: Generating LUT for $view
    generate_lut $view
    array_save $view $::env(RAMSPICE)/../nch.db append
}
set j 0
set passed 0
set failed 0
set sample_size 10000
set valid_samples 0
for {set j 0} {$j<$sample_size} {incr j} {
    set i 0
    foreach var {Vgs Vds L WbyL temp} {
        set i$i [expr int(rand()*($::constraints($var,index_range)-1))]
        set index_coord [set i$i]
        set $var [::spice::array_get_legend Ids $i $index_coord]
        incr i
    }
    set entry [@ Ids($i0,$i1,$i2,$i3,$i4)]
    if {[string match *nan* $entry]} {
	incr j -1
	continue
    }
    set estimation_list [get_Ids_direct Ids $Vgs $Vds $L $WbyL $temp]
    set estimation [lindex $estimation_list end]
    if {[string match *nan* $estimation]} {
	incr j -1
	continue
    }
    if {$estimation<0} {
       set estimation 0
    }
    if {[catch {set error [expr 100.0*abs($estimation-$entry)/$entry]} msg]} {
        if {$entry==0.0} {
	    if {$estimation==0.0} {
	        set error 0
	    } else {
	        set error 100
	    }
	} else {
            report_vars entry estimation
            Error: $msg $errorInfo
	}
    }
    incr valid_samples
    if {[catch {set abs_error [expr abs($estimation-$entry)]} msg]} {
	report_vars entry estimation
	Error: $msg $errorInfo
    }
    if {$error<1.0||$abs_error<1e-12} {
        incr passed
    } else {
        incr failed
        set errors($error) [list $entry $estimation Vgs=$Vgs Vds=$Vds area=$WbyL]
    }
}

set j 0
foreach error [lsort -real [array names errors]] {
    puts "$j    [array get errors $error]"
    incr j
}
set fidelity [expr 100.0*$passed/$valid_samples]
Info: Total fidelity is ${fidelity}% ($valid_samples samples)

