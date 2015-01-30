# \
exec $RAMSPICE/ramspice $0 $argv

get_opts
set param_list {Ids gm ro}
source $::env(RAMSPICE)/Web/svg/svg.tcl
source $::env(RAMSPICE)/Tech_DB/$::opt(tech)/binning_$::opt(tech).tcl
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
    ro  1e4
    gm  1e-6
}
array set ::unit {
    Ids A
    ro  Ohm
    gm  Mho
}
proc volume_sort {rez1 rez2} {
    if {$::volume($rez1)>$::volume($rez2)} {
        return 1
    }
    return 0
} 
default opt(top_error) 100
set html_file $::env(RAMSPICE)/Tech_DB/$::opt(tech)/reduced/$::opt(device).$::opt(process).$::opt(interpolation).$::opt(view).$opt(type).pareto.html
if {[file exists $html_file]} {
#    Info: HTML report exists: $html_file
#    exit
}    
set pareto_data_file $::env(RAMSPICE)/Tech_DB/$::opt(tech)/reduced/$::opt(device).$::opt(process).$::opt(interpolation).pareto.tcl
proc calc_error {parameter section sim int} {
    if {[regexp {n} $int]} return 
    if {[regexp {n} $sim]} return 
    default ::err($parameter,$section) {}
    default ::rel_err($parameter,$section) {}
    default ::abs_err($parameter,$section) {}
    default ::threshold($parameter) 5e-6
    if {(abs($int-$sim)<$::threshold($parameter))} {
        set int $sim
    }
    #    if {$sim<0} return
    #    if {$int<0} return
    #    Info: Including $::Vgs $::Vds $::Vbs | $int-$sim in $parameter $section [expr ($int/$sim-1)*100]
    if {$sim==0} {
        Warning: sim=0
	set sim 1e-99
    }
    if {$parameter=="ro" && $section==0} {
#        Info: $int <> $sim ===> [expr (1.0*$int/$sim-1)*100]
    }
    lappend ::err($parameter,$section) [expr (1.0*$int/$sim-1)*100]
    lappend ::rel_err($parameter,$section) [expr abs(1.0*$int/$sim-1)*100]
    lappend ::abs_err($parameter,$section) [expr abs($int-$sim)]
}
    foreach source [lsort [glob $::env(RAMSPICE)/Tech_DB/$::opt(tech)/reduced/*:*:*:*]] {
        set rez [file tail $source]
        set input_file $source/$::opt(device).$::opt(process).$::opt(interpolation).info
        if {![file exists $input_file]} continue
	Info: Reading $input_file
        set volume($rez) 4
        foreach rez_bits [split $rez :] {
            set volume($rez) [expr $volume($rez)*int(pow(2,$rez_bits)+1)]
        }
        if {$opt(interpolation)=="LIT"} {
            set volume($rez) [expr $volume($rez)*6]
        }
        source $source/$::opt(tech)_$::opt(device)_min_vt.tcl
        set p [string index $::opt(device) 0]
        open_bin read $source/$::opt(device).$::opt(process).$::opt(interpolation).info
	set sample_size [read_bin int]
        for {set section 1} {[info exists ::bin($p,$section,lmin)]} {incr section} {
	    set access_time($rez) -1
            for {set j 0} {$j<$sample_size} {incr j} {
                foreach var {Vgs Vds Vbs L W LUT_Ids Ids LUT_gm gm LUT_ro ro} {
                    set $var [read_bin float]
                }
		# Limit analysis to saturated op
	#	if {$Vds<=($Vgs-0.6)} continue
	   #     skip {$W/$L>5} 
		# report_vars Vgs Vds Vbs L W LUT_Ids Ids LUT_gm gm LUT_ro ro
		report_vars Vgs Vds Vbs L W LUT_ro ro 
		# Info: Vgs=$Vgs Vds=$Vds [regexp {nan} $Vds]
                if {[regexp {nan} $Vds]} {
                    set access_time($rez) $Vgs
                    break
                }
                #if {$Vgs<$minVt} continue
                #if {$Vds<$minVt} continue
                #if {$Vbs>$minVt} continue
                set s [find_mosfet_bin $p $L $W]
                foreach parameter $param_list {
                    calc_error $parameter $s [set $parameter] [set LUT_$parameter]
                    calc_error $parameter 0 [set $parameter] [set LUT_$parameter]
                }
            } 
	    if {$access_time($rez)!= 1} break
        }
        set access_time($rez) [read_bin float]
        Info: access_time=[eng $access_time($rez) sec]
        close_bin read 
        foreach parameter $param_list {
            set limit_index [expr (99*[llength $::err($parameter,0)])/100]
            set limit_rel [lindex [lsort -real $::rel_err($parameter,0)] $limit_index]
            set limit_abs [lindex [lsort -real $::abs_err($parameter,0)] $limit_index]
            for {set section 0} {[info exists ::bin($p,$section,lmin)]||$section==0} {incr section} {
                skip {$section!=0} 
                set average_error($parameter,$section) 0
                set sample_size 0
                foreach error $::err($parameter,$section) {
                    set average_error($parameter,$section) [expr $error+$average_error($parameter,$section)]
                    incr sample_size
                }
                if {$sample_size==0} continue
                set sigma($parameter,$section) 0
		set k 0
                set average_error($parameter,$section) [expr $average_error($parameter,$section)/$sample_size]
                foreach error $::err($parameter,$section) {
                    if {[catch {set sigma($parameter,$section) [expr $sigma($parameter,$section)+($error-$average_error($parameter,$section))*($error-$average_error($parameter,$section))]}]} {
		        Info:  error=$error average_error($parameter,$section)=$average_error($parameter,$section)
			set sigma($parameter,$section) 5
		    }
		    if {$parameter=="ro"} {
		        incr k
		   #     Info: error=$error sigma=[expr sqrt($sigma($parameter,$section)/$k)]
		    }
                }
                set sigma($parameter,$section) [expr sqrt($sigma($parameter,$section)/$sample_size)]
                # Info: $rez $parameter $section $sample_size error=$average_error($parameter,$section) |99%|=[eng $limit_abs $::unit($parameter)],[eng $limit_rel %] sigma=$sigma($parameter,$section) ([expr $average_error($parameter,$section)-3*$sigma($parameter,$section)],[expr $average_error($parameter,$section)+3*$sigma($parameter,$section)])
                set ninety_nine_rel($rez,$parameter) $limit_rel
		skip {[string match *n*  $average_error($parameter,$section)]}
                set ninety_nine_rel($rez,$parameter) [expr $limit_rel-abs($average_error($parameter,0))]
                set ninety_nine_abs($rez,$parameter) $limit_abs
                set sigma_per_rez($rez,$parameter) $sigma($parameter,0)
                set error_per_rez($rez,$parameter) $average_error($parameter,0)
            }
        }
        array unset ::err
        array unset ::abs_err
        array unset ::rel_err
    }
    set O [open $pareto_data_file w]
    foreach array {volume ninety_nine_rel ninety_nine_abs sigma_per_rez error_per_rez access_time} {
        puts $O [list array set $array [array get $array]]
    }
    close $O
default opt(type) accuracy
if {$opt(type)=="access_time"} {
    array set volume [array get access_time]
    set x_title "Access Time"
    set x_unit sec
} else {
    set x_title "Required Memory"
    set x_unit B
}
foreach rez [array names volume] {
    set marker($rez) 0
}
# Filter dominated markers
foreach rez1 [array names volume] {
    foreach rez2 [array names volume] {
        skip {$volume($rez1)>=$volume($rez2)}
	skip {![info exists ninety_nine_rel($rez1,$::opt(view))]}
	skip {![info exists ninety_nine_rel($rez2,$::opt(view))]}
        skip {$ninety_nine_rel($rez1,$::opt(view))>=$ninety_nine_rel($rez2,$::opt(view))}
        set marker($rez2) 1
    }
}
# Filter "inland" markers
set continue 1
while {$continue} {
    set continue 0
    set rez1 {}
    set rez2 {}
    foreach rez [lsort -command volume_sort [array names volume]] {
        skip {$marker($rez)}
        if {$rez1!={}} {
            if {$volume($rez)==$volume($rez1)} {
                set marker($rez2) 2
                set continue 1
            } else {
	        skip {![info exists ninety_nine_rel($rez1,$::opt(view))]}
	        skip {![info exists ninety_nine_rel($rez2,$::opt(view))]}
	        skip {![info exists ninety_nine_rel($rez,$::opt(view))]}
                set slope [expr ($ninety_nine_rel($rez,$::opt(view))-$ninety_nine_rel($rez1,$::opt(view)))/($volume($rez)-$volume($rez1))]
                set intercept [expr $ninety_nine_rel($rez,$::opt(view))-$slope*$volume($rez)]
                if {$ninety_nine_rel($rez2,$::opt(view))>$slope*$volume($rez2)+$intercept} {
                    set marker($rez2) 2
                    set continue 1
                }
            }
        }
        set rez1 $rez2
        set rez2 $rez
    }
}
# Find roof of the plot
set top_error 0
foreach rez [lsort -command volume_sort [array names volume]] {
    skip {$marker($rez)}
    skip {$top_error>$ninety_nine_rel($rez,$::opt(view))}
    set top_error $ninety_nine_rel($rez,$::opt(view))
}
# construct the plot
set plot {}
foreach rez [lsort -command volume_sort [array names volume]] {
    skip {![info exists ninety_nine_rel($rez,$::opt(view))]}
    skip ($ninety_nine_rel($rez,$::opt(view))>$::opt(top_error))
    skip ($ninety_nine_rel($rez,$::opt(view))>$top_error)
    lappend plot $volume($rez)
    lappend plot $ninety_nine_rel($rez,$::opt(view))
    lappend plot $marker($rez)
}
set O [open $html_file w]
puts $O "<html><body>"
if {$opt(type)=="volume"} {
    puts $O "<h2>$opt(interpolation) Memory/Accuracy Trade-Off for $::opt(view) for $opt(device)@$opt(process)</h2>"
    set x_axis_type log
} else {
    puts $O "<h2>$opt(interpolation) Access-Time/Accuracy Trade-Off for $::opt(view) for $opt(device)@$opt(process)</h2>"
    set x_axis_type lin
}
puts $O "<h3>Useful Resolution Combinations:</h3>"
#puts $O "<table align=\"center\"><tr><td>"
if {$opt(type)=="volume"} {
    puts $O "<table border=\"2\"><tr><td></td><td><b>Vgs</b></td><td><b>Vds</b></td><td><b>Vbs</b></td><td><b>L</b></td><td><b>Memory</b></td><td><b>Max Error</b></td></tr>"
} else {
    puts $O "<table border=\"2\"><tr><td></td><td><b>Vgs</b></td><td><b>Vds</b></td><td><b>Vbs</b></td><td><b>L</b></td><td><b>Time</b></td><td><b>Max Error</b></td></tr>"
}
set index 1
foreach rez [lsort -command volume_sort [array names volume]] {
    skip {![info exists ninety_nine_rel($rez,$::opt(view))]}
    skip {$marker($rez)}
    puts $O <tr>
    puts $O <td>
    puts $O "<b>$index</b>"
    incr index
    puts $O </td>
    foreach bits [split $rez :] {
        puts $O <td>
        puts $O [expr int(pow(2,$bits)+1)]
        puts $O </td>
    }
    puts $O <td>
    if {$opt(type)=="volume"} {
        puts $O [eng $volume($rez) B]
    } else {
        puts $O [eng $volume($rez) sec]
    }
    puts $O </td>
    puts $O <td>
    puts $O [eng $ninety_nine_rel($rez,$::opt(view)) %]
    puts $O </td>
    puts $O </tr>
}	    
puts $O "</table>"
#puts $O "</td></tr><tr><td>"
puts $O "<h3>Pareto Front:</h3>"
::SVG::append $O
::SVG::svg width 1200 height 600 {
    SVG::graph markers title "Pareto-front for $::opt(view) look-up error for $opt(device)@$opt(process) and $opt(interpolation) interpolation method" \
    x 100 y 10 width 500 height 400 x_unit $x_unit y_unit % x_title $x_title y_title "Max Relative Error for 99% of the samples" x_type $x_axis_type markers {3:green 3:red 3:orange} connect {0} data $plot
}
#puts $O "</td></tr></table>"
puts $O "</body></html>"
close $O
exit

