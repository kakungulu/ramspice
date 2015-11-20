# \
exec $RAMSPICE/ramspice $0 $argv
get_opts

proc @ {SPICE Gamma} {
    default ::data(SPICE) {}
    lappend ::data(SPICE) $SPICE
    default ::data(Gamma) {}
    lappend ::data(Gamma) $Gamma
    default ::data(xy) {}
    lappend ::data(xy) $SPICE
    lappend ::data(xy) $Gamma
}
source ~/temp/times.tcl
source $::env(RAMSPICE)/Gamma/Web/svg/svg.tcl
set HTML [open $::env(RAMSPICE)/../../GammaSPICERunTime.html w]
puts $HTML <html>
puts $HTML <body>
::SVG::out 

foreach tool {SPICE Gamma} command {.op OP} {
    set average($tool) 0
    set min 100
    set max -1
    foreach t $::data($tool) {
        set average($tool) [expr $average($tool)+$t]
	if {$min>$t} {
	    set min $t
	}
	if {$max<$t} {
	    set max $t
	}
    }
    set average($tool) [expr $average($tool)/[llength $::data($tool)]]
    set stdev($tool) 0
    foreach t $::data($tool) {
        set stdev($tool) [expr $stdev($tool)+($t-$average($tool))*($t-$average($tool))]
    }
    set stdev($tool) [expr sqrt($stdev($tool)/[llength $::data($tool)])]
    set hist($tool) {}
    set step [expr ($max-$min)/30]
    set common 0
    set common_count 0
    for {set s $min} {$s<$max} {set s [expr $s+$step]} {
        set count 0
	foreach t $::data($tool) {
	    skip {$t<$s}
	    skip {$t>=$s+$step}
	    incr count
	}
	lappend hist($tool) $s
	lappend hist($tool) $count
	if {$count>$common_count} {
	    set common $s
	    set common_count $count
	}
    }
    ::SVG::svg width 1000 height 1100 {
       ::SVG::graph_hist stdev $stdev($tool) average $average($tool) x 100 y 100 width 900 height 900 data $hist($tool) connect all connect_pattern 1 connect_width 2 x_title "Run Time" y_title Count x_unit sec y_unit {} title "$tool $command command run time histogram"
    }
    Info: $tool  min=[eng $min sec] max=[eng $max sec]  Most Common=[eng $common sec] to [eng [expr $common+$step] sec] Median=[eng [lindex [lsort -real $::data($tool)] [expr [llength $::data($tool)]/2]] sec] Averag=[eng $average($tool) sec] Stddev=[eng $stdev($tool) sec]
}
::SVG::svg width 1000 height 1100 {
    ::SVG::graph_data x 100 y 100 width 900 height 900 data $data(xy) markers 1:black x_title SPICE y_title Gamma x_unit sec y_unit sec title "Gamma vs SPICE operating point calculation times"
}


puts $HTML </body>
puts $HTML </html>
close $HTML
exit


