# \
exec $RAMSPICE/ramspice $0 $argv
get_opts

default ::opt(topology) diffpair_output_nmos
source $::env(RAMSPICE)/Gamma/Web/svg/svg.tcl
set unknown {
    if {[regexp {^<} $args]} {
        set line $args
        regsub -all {\\\"} $line "\"" line
        regsub -all {[\{\}]} $line "" line
    #    puts $::HTML $line
        return
    }
}
append unknown [info body unknown]
proc unknown args $unknown
namespace eval SET {}
set ::index 0
proc SET::set {args} {
    ::set ::sample($::index) [lrange $args 2 end]
    incr ::index
}

set rez 32
set percentiles {50 75 90 95 99}
if {![file exists $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/regression.tcl]} {
    if {![file exists $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/regression.html]} {
        Error: No regression results exist. Run $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/match.tcl first
        exit
    }
    set I [open $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/regression.html r]
    set O [open $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/regression.tcl w]
    while {[gets $I line]>=0} {
        regsub {<.*$} $line {} line
        puts $O $line
    }
    close $O
    close $I
}
namespace eval SET "source $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/regression.tcl"

array set data {
    PSRR {}
    BW {}
    PM {}
}
array set unit {
   PSRR dB
   BW MHz
   PM &#176;
}
set a [expr (140.0-15.0)/(115-50)]
set b [expr 140-115*$a]


for {set i 0} {[info exists sample($i)]} {incr i} {
    Info: $i sample=$sample($i)
    lappend data(PSRR) [lindex $sample($i) 2]
    lappend data(PSRR) [lindex $sample($i) 3]
    if {([lindex $sample($i) 4]<=1e9)&&(abs([lindex $sample($i) 4]/[lindex $sample($i) 5]-1)*100<12)} {
        lappend data(BW) [expr [lindex $sample($i) 4]/1e6]
        lappend data(BW) [expr [lindex $sample($i) 5]/1e6]
    }
 #   skip {abs(165-[lindex $sample($i) 6]-[lindex $sample($i) 6])>10}
    set s [lindex $sample($i) 6]
    set g [expr ([lindex $sample($i) 7]-$b)/$a]
    skip {abs($s-$g)>10}
    lappend data(PM) $s
    lappend data(PM) $g
}
#set ::HTML [open $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/Accuracy.html w]
<html><body>
#::SVG::out 
foreach view [array names data] {
    set error_list {}
    foreach {X Y} $data($view) {
        lappend error_list [expr ($Y-$X)]
        skip {$X==0}
        lappend prop_error_list [expr 100*($Y/$X-1)]
    }
    <table>
    <tr>
    <td> 
    set ::HTML [open ~/$::opt(topology).$view.xy.svg w]
    ::SVG::out
    ::SVG::svg width 1000 height 1100 {
        ::SVG::graph_data font 32 x 100 y 100 width 900 height 900 data $data($view) show_unit 0 x_title SPICE y_title Gamma x_unit $unit($view) y_unit $unit($view) title "$view values"
    }
     close $::HTML
    </td>
    
    ########  Delta Errors
    set hist_data {}
    set error_list [lsort -real $error_list]
    set prop_error_list [lsort -real $prop_error_list]
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
    set precentile_errors {}
    foreach error $error_list {
        lappend precentile_errors [expr abs($error-$average)]
    }
    set precentile_errors [lsort -real $precentile_errors]
    set length [llength $precentile_errors]
    foreach precentile $percentiles {
        set PRECENTILE($precentile,delta) [lindex $precentile_errors [expr $precentile*$length/100]]
    }
    set delta_average $average
    set delta_hist_data $hist_data
    set delta_stdev $stdev
    ######## Relative Errors
    set hist_data {}
    array unset hist
    set error_list $prop_error_list
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
    set precentile_errors {}
    foreach error $error_list {
        lappend precentile_errors [expr abs($error-$average)]
    }
    set precentile_errors [lsort -real $precentile_errors]
    set length [llength $precentile_errors]
    foreach precentile $percentiles {
        set PRECENTILE($precentile,rel) [lindex $precentile_errors [expr $precentile*$length/100]]
    }
    set table_font 16
    <td align="center">
    <table border="1">
    <tr><td align="center" colspan="3"><font size="$table_font"><b>Statistics</b></font></td></tr>
    <tr><td> <font size="$table_font"><b>Average</b></font></td><td> <font size="$table_font">[eng $average %]</font></td><td> <font size="$table_font">[eng $delta_average $unit($view)]</font></td></tr>
    <tr><td> <font size="$table_font"><b>&#963\;</b></font></td><td> <font size="$table_font">[eng $stdev %]</font></td><td> <font size="$table_font">[eng $delta_stdev $unit($view)]</font></td></tr>
    <tr><td> <font size="$table_font"><b>Percentile</b></font></td><td> <font size="$table_font"><b>% Error</b></font></td><td> <font size="$table_font"><b>&#916\; Error</b></font></td></tr>
    foreach precentile $percentiles {
        <tr> <td> <font size=\"$table_font\">[eng $precentile %]</font></td><td> <font size=\"$table_font\">[eng $PRECENTILE($precentile,rel) %]</font></td><td> <font size=\"$table_font\">[eng $PRECENTILE($precentile,delta) $unit($view)]</font></td></tr>
    }
    </table>    
    </td>
    </tr>
    <tr>
    <td> 
    set ::HTML [open ~/$::opt(topology).$view.hist.delta.svg w]
    ::SVG::out
     ::SVG::svg width 1000 height 1100 {
        ::SVG::graph_hist font 32 stdev $delta_stdev average $delta_average x 100 y 100 width 900 height 900 data $delta_hist_data show_unit 0 connect all connect_pattern 1 connect_width 2 x_title "&#916;$view" y_title Count x_unit $unit($view) y_unit {} title "$view error histogram"
    }
    close $::HTML
    </td>
    <td> 
    set ::HTML [open ~/$::opt(topology).$view.hist.rel.svg w]
    ::SVG::out
     ::SVG::svg width 1000 height 1100 {
        ::SVG::graph_hist font 32 stdev $stdev average $average x 100 y 100 width 900 height 900 data $hist_data show_unit 0 connect all connect_pattern 1 connect_width 2 x_title "$view Ratio" y_title Count x_unit % y_unit {} title "$view error histogram"
    }
    close $::HTML
    </td>
    </tr>
    </table>    
}
</body>
</html>
# close $::HTML

exit


