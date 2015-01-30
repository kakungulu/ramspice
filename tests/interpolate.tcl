source tests/char_constraints.tcl
set views {Ids gm}
set short_views {Vt Va Ro}
set depth 4
set extra_depth 7
set index_range [expr 1+int(pow(2,$depth))]
set extra_index_range [expr 1+int(pow(2,$extra_depth))]
set ::min_Ids 1e-13
######### Initialize database
@ . add string look_up_tables
@ look_up_tables add string cmosn
@ /look_up_tables/cmosn cd
proc average_ids args {}
set index_range {}
foreach var {Vgs Vds L WbyL temp} {
    lappend index_range $::constraints($var,index_range)
}
foreach array $views {
    @ . add string $array
    @ $array add array [join $index_range ,]
}
set index_range {}
foreach var {L WbyL temp} {
    lappend index_range $::constraints($var,index_range)
}
foreach array $short_views {
    @ . add string $array
    @ $array add array [join $index_range ,]
}
Info: Loading LUT
source $::env(RAMSPICE)/../mosfet.lib
Info: Loaded LUT
set j 0
set passed 0
set sample_size 100000
for {set j 0} {$j<$sample_size} {incr j} {
    set i 0
    foreach var {Vgs Vds L WbyL temp} {
        set i$i [expr int(rand()*($::constraints($var,index_range)-1))]
        set index_coord [set i$i]
        set $var [::spice::array_get_legend Ids $i $index_coord]
        incr i
    }
    set entry [@ Ids($i0,$i1,$i2,$i3,$i4)]
    set multiplier [lindex [est_Ids Va Vt $Vgs $Vds $L $WbyL $temp] 0]
    
    if {[catch {set spice [expr $entry*$multiplier]} msg]} {
        report_vars entry multiplier 
	Error: $i0,$i1,$i2,$i3,$i4
        Error: $msg $errorInfo
	exit
    }
    set estimation_list [get_Ids Va Vt Ids $Vgs $Vds $L $WbyL $temp]
    set estimation [lindex $estimation_list 0]
    set bad_neighbours 0
    foreach neighbor [lrange $estimation_list 2 end] {
        if {$neighbor==5e-10} {
	    incr bad_neighbours
	}
    }
    if {[catch {set error [expr 100.0*abs($estimation-$spice)/$spice]} msg]} {
        if {$spice==0.0} {
	    if {$estimation==0.0} {
	        set error 0
	    } else {
	        set error 100
	    }
	} else {
            report_vars entry multiplier spice estimation
            Error: $msg $errorInfo
	}
    }
    if {[catch {set abs_error [expr abs($estimation-$spice)]} msg]} {
	report_vars entry multiplier spice estimation
	Error: $msg $errorInfo
    }
    if {$error<1.0||$estimation<1e-13} {
        incr passed
    } else {
        set errors($error) [list $spice $estimation Vgs=$Vgs Vds=$Vds area=$WbyL]
    }
    	
}
set j 0
foreach error [lsort -real [array names errors]] {
    puts "$j    [array get errors $error]"
    incr j
}
set fidelity [expr 100.0*$passed/$sample_size]
Info: Total fidelity is $fidelity ($sample_size samples)

