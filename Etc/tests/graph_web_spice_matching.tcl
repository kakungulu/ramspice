# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
default ::opt(tech) tsmc040
default ::opt(topology) diffpair_nmos
default ::opt(op) 5
source $::env(RAMSPICE)/Gamma/Web/svg/svg.tcl
regsub {_nmos} $::opt(topology) {} topology_name
set HTML [open $::env(RAMSPICE)/../../GammaAccuracyStats.html w]
puts $HTML <html>
puts $HTML <body>
::SVG::out 

foreach topo_file [glob -nocomplain ~/Documents/*.stats.tcl] {
    foreach var [concat [info vars *_errors]  [info vars *_xy]] {
        unset $var
    }
    source $topo_file
    regsub {\.stats.*$} [file tail $topo_file] {} topology_name
    foreach type {op adc cmrr bw} unit {V dB dB Hz} rez {100 100 100 25} name {OP Adc CMRR BW} { 
        skip {![info exists ${type}_errors]}
        set data {}
        foreach xy [set ${type}_xy] {
            lappend data [lindex $xy 0]
            lappend data [lindex $xy 1]
        }
	set hist_data {}
	set error_list [lsort -real [set ${type}_errors]]
	set average 0
	foreach error $error_list {
	    set average [expr $average+$error]
	}
	set average [expr $average/[llength $error_list]]
	set stdev 0
	foreach error $error_list {
	    set stdev [expr $stdev+($error-$average)*($error-$average)]
	}
	set stdev [expr sqrt($stdev/[llength $error_list])]
	set last_error [lindex $error_list 0]
	set min_error $last_error
	set max_error [lindex $error_list end]
	foreach error $error_list {
	    set index [expr int($rez*($error-$min_error)/($max_error-$min_error)+0.5)]
	    default hist($index) 0
	    incr hist($index)
	}
	for {set i 0} {$i<$rez} {incr i} {
	    default hist($i) 0
	    lappend hist_data [expr $min_error+$i*($max_error-$min_error)/$rez]
	    lappend hist_data $hist($i)
	}
        ::SVG::svg width 1000 height 1100 {
            ::SVG::graph_data x 100 y 100 width 900 height 900 data $data markers 6:green x_title SPICE y_title Gamma x_unit $unit y_unit $unit title "Gamma vs SPICE $name values for $topology_name topology"
        }
        ::SVG::svg width 1000 height 1100 {
            ::SVG::graph_hist stdev $stdev average $average x 100 y 100 width 900 height 900 data $hist_data connect all connect_pattern 1 connect_width 2 x_title "$name Difference between Gamma and SPICE" y_title Count x_unit $unit y_unit {} title "Gamma vs SPICE $name error histogram for $topology_name topology"
        }
    }    
}
puts $HTML </body>
puts $HTML </html>
close $HTML
exit
