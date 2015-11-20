# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
set ::data {}
set ::hist_data {}
set ::min_slope 1000
set ::max_slope -1000
proc @PAT {usec num} {
    set slope [expr ($usec-0.666)*1e-6/$num]
    if {$num>400} return
    if {$slope>0.6e-6} return
    lappend ::data $num
    lappend ::data [expr $usec*1e-6]
    lappend ::hist_data $slope
    if {$slope>$::max_slope} {
        set ::max_slope $slope
    }
    if {$slope<$::min_slope} {
        set ::min_slope $slope
    }
}
source ~/temp/pat_times.tcl
source $::env(RAMSPICE)/Gamma/Web/svg/svg.tcl
set HTML [open $::env(RAMSPICE)/../../GammaPATInsertionTime.html w]
puts $HTML <html>
puts $HTML <body>
::SVG::out 
::SVG::svg width 1000 height 1100 {
    ::SVG::graph_data x 100 y 100 width 900 height 900 data $::data markers 1:black x_title |PAT| y_title Gamma x_unit {} y_unit sec title "PAT insertion time per overall size"
}
set average 0
foreach t $::hist_data {
    set average [expr $average+$t]
}
set average [expr $average/[llength $::hist_data]]
set stdev 0
foreach t $::hist_data {
    set stdev [expr $stdev+($average-$t)*($average-$t)]
}
set stdev [expr sqrt($stdev/[llength $::hist_data])]

set step [expr ($::max_slope-$::min_slope)/30]
set common 0
set common_count 0
for {set s $::min_slope} {$s<$::max_slope} {set s [expr $s+$step]} {
    set count 0
    foreach t $::hist_data {
    	skip {$t<$s}
    	skip {$t>=$s+$step}
    	incr count
    }
    lappend ::hist $s
    lappend ::hist $count
    if {$count>$common_count} {
    	set common $s
    	set common_count $count
    }
}
::SVG::svg width 1000 height 1100 {
   ::SVG::graph_hist stdev $stdev average $average x 100 y 100 width 900 height 900 data $::hist connect all connect_pattern 1 connect_width 2 x_title "Insertion Time per PAT Size" y_title Count x_unit sec y_unit {} title "PAT Insertion Time per Size Histogram"
}


puts $HTML </body>
puts $HTML </html>
close $HTML
exit


