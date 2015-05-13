# \
exec $RAMSPICE/ramspice $0 $argv

get_opts
set param_list {Ids gm go}
array set ::corner_to_temp {
    ss 125
    tt 27
    ff -40
    fs 27
    sf 27
    mc 27
}
array set ::threshold {
    Ids 1e-6
    go  1e-6
    gm  1e-6
}
array set ::unit {
    Ids A
    go  Mho
    gm  Mho
}

set input_file $::opt(source)/$::opt(device).$::opt(process).$::opt(interpolation).info
Info: Looking for $::opt(source)/$::opt(device).$::opt(process).$::opt(interpolation).info
#if {![file exists $input_file]} exit
source $::env(RAMSPICE)/Web/svg/svg.tcl
source $::env(RAMSPICE)/Tech_DB/$::opt(tech)/binning_$::opt(tech).tcl
source $::opt(source)/$::opt(tech)_$::opt(device)_min_vt.tcl

set p [string index $::opt(device) 0]
proc calc_error {parameter section sim int} {
    default ::err($parameter,$section) {}
    default ::rel_err($parameter,$section) {}
    default ::abs_err($parameter,$section) {}
    default ::threshold($parameter) 5e-6
    if {(abs($int-$sim)<$::threshold($parameter))&&(abs($int/$sim-1)>0.1)} return
    set error [expr floor(($int/$sim-1)*1000)/10.0]
    if {![info exists ::hist_${parameter}($error)]} {
        set ::hist_${parameter}($error) 0
    }
    incr ::hist_${parameter}($error)
    lappend ::err($parameter,$section) [expr ($int/$sim-1)*100]
    lappend ::rel_err($parameter,$section) [expr abs($int/$sim-1)*100]
    lappend ::abs_err($parameter,$section) [expr abs($int-$sim)]
}
open_bin read $::opt(source)/$::opt(device).$::opt(process).$::opt(interpolation).info
Info: minVt=$minVt
for {set section 1} {[info exists ::bin($p,$section,lmin)]} {incr section} {
    for {set j 0} {$j<$opt(size)} {incr j} {
        foreach var {Vgs Vds Vbs L W LUT_Ids Ids LUT_gm gm LUT_go go} {
	    set $var [read_bin float]
	}
	if {[string match *nan* $Vds]} continue
	set s [find_mosfet_bin $p $L $W]
	foreach parameter $param_list {
	    calc_error $parameter $s [set $parameter] [set LUT_$parameter]
            calc_error $parameter 0 [set $parameter] [set LUT_$parameter]
	}
    } 
}
close_bin read
foreach parameter $param_list {
    set limit_index [expr (99*[llength $::err($parameter,0)])/100]
    set limit_rel [lindex [lsort -real $::rel_err($parameter,0)] $limit_index]
    set limit_abs [lindex [lsort -real $::abs_err($parameter,0)] $limit_index]
    for {set section 0} {[info exists ::bin($p,$section,lmin)]||$section==0} {incr section} {
        set average_error($parameter,$section) 0
	set sample_size 0
	foreach error $::err($parameter,$section) {
	    set average_error($parameter,$section) [expr $error+$average_error($parameter,$section)]
	    incr sample_size
	}
	if {$sample_size==0} continue
	set sigma($parameter,$section) 0
	set average_error($parameter,$section) [expr $average_error($parameter,$section)/$sample_size]
	foreach error $::err($parameter,$section) {
	    set sigma($parameter,$section) [expr $sigma($parameter,$section)+($error-$average_error($parameter,$section))*($error-$average_error($parameter,$section))]
	}
	set sigma($parameter,$section) [expr sqrt($sigma($parameter,$section)/$sample_size)]
	if {$section==0} {
            Info: $parameter $section $sample_size error=$average_error($parameter,$section) |99%|=[eng $limit_abs $::unit($parameter)],[eng $limit_rel %] sigma=$sigma($parameter,$section) ([expr $average_error($parameter,$section)-3*$sigma($parameter,$section)],[expr $average_error($parameter,$section)+3*$sigma($parameter,$section)])
	} else {
            Info: $parameter $section $sample_size error=$average_error($parameter,$section) sigma=$sigma($parameter,$section) ([expr $average_error($parameter,$section)-3*$sigma($parameter,$section)],[expr $average_error($parameter,$section)+3*$sigma($parameter,$section)])
	}    
    }
    foreach error [lsort -real [array names ::hist_${parameter}]] {
        puts "$error [set ::hist_${parameter}($error)]"
    }
}
exit

