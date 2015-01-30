# \
exec $RAMSPICE/ramspice $0 $argv

get_opts
namespace eval parse {
    proc Info: {args} {
        if {[lindex $args 0]!="random"} return
#	if {rand()>0.01} return
	set x [lindex $args 5]
	set y [lindex $args 6]
	lappend ::data $y
	lappend ::data $x
	set error [expr int(($y/$x-1)*1000)/10]
	if {![info exists ::rel_hist($error)]} {
	    set ::rel_hist($error) 0
	}
	incr ::rel_hist($error)
	set error [expr abs($y-$x)]
	# Simplify error figure to one decimal point
	if {$error!=0.0} {
   	    set i [expr int(-log(abs($error))/log(10))]
	    set error [expr int($error*pow(10,$i+1))/pow(10.0,$i+2)]
	}
	if {![info exists ::abs_hist($error)]} {
	    set ::abs_hist($error) 0
	}
	incr ::abs_hist($error)
    }
}
source Web/svg/svg.tcl
foreach logfile [glob $::env(RAMSPICE)/log?:?:?] {
    Info: plotting $logfile
    if {![regexp {([0-9]+):([0-9]+):([0-9]+)} $logfile -> rez(Vgs) rez(Vds) rez(Vbs)]} {
        Error: Log file name $logfile incompatible
	exit
    }
    set ::data {}
    array unset ::rel_hist
    array unset ::abs_hist
    
    namespace eval parse "source $logfile"
    set html_file [file join $::env(RAMSPICE) [regsub -all {:} [file tail $logfile].html "_"]]
    set O [open $html_file w]
    puts $O "<html><body>"
     puts $O <h1>
     puts $O "Accuracy Analysis for Look-Up table"
     puts $O </h1> 
     puts $O <h2>
     puts $O "Resolution:"
     puts $O </h2>
     puts $O <h3>
     foreach var {Vgs Vds Vbs} {
         puts $O "$var: [expr int(pow(2,$rez($var)))+1] Samples<br>"
     }
     puts $O "L: [llength $lvalues] Samples<br>"
     puts $O "W: [llength $wvalues] Samples<br>"
     puts $O </h3> 
     
    ::SVG::append $O
    ::SVG::svg width 1200 height 2000 {
        SVG::graph histogram x 100 y 100 width 500 height 400 x_unit A y_unit {} x_type log x_title "Absolute Error" title "Absolute Error Histogram" data [array get ::abs_hist]
        SVG::graph histogram x 100 y 700 width 500 height 400 x_unit % y_unit {} x_title "Relative Error" title "Relative Error Histogram" data [array get ::rel_hist]
        SVG::graph markers x 100 y 1300 width 500 height 400 x_unit A y_unit A x_title "LUT Ids" y_title "Simulated Ids" x_type log y_type log data $::data title "Simulated Vs. LUT Ids"
    }
    puts $O "</body></html>"
    close $O
}
exit
