# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
default opt(rez) 5:5:3:8
default opt(tech) tsmc040
deafult opt(input) $::env(RAMSPICE)/Etc/Spectre/40nm/crn40lp_1d8_v1d2.scs
default opt(devices) {nch pch}
default opt(corners) {ss tt ff fs sf}
default opt(hist_steps) 32
source $::env(RAMSPICE)/Gamma/Web/FE/gamma_procs.tcl

textbox "Regression Suite for RAMSpice \n version=[clock format [file mtime [info script]]]"

set skip_next_stage 0
if {[file exists $::env(RAMSPICE)/Etc/Tech_DB/$opt(tech)]} {
    if {[file exists $::env(RAMSPICE)/Etc/Tech_DB/$opt(tech)/$opt(tech).sp]} {
        set skip_next_stage 1
    }
}
if {!$skip_next_stage} {
    textbox "Converting $opt(tech)"
    source $::env(RAMSPICE)/Etc/utils/rf2tcl.tcl
}
# Old characterize.tcl uses the global variables for option switches. Converting:
lassign [split $opt(rez) :] ::vgs_rez ::vds_rez ::vbs_rez ::l_rez
set ::tech $::opt(tech)
source Etc/utils/4d_characterize.tcl
textbox "Matching Gamma to Simulation"




textbox "Generating Certificate of Calibration"
proc * {view args} {
    default ::config($view,relative) 0
    default ::config($view,absolute) 0
    default ::config($view,scatter) 0
    default ::config($view,rel_th) 0.1
    default ::config($view,abs_th) 0.1
    ladd ::views $view
    set flag {}
    foreach arg $args {
        switch -- $arg {
	    -relative {
	        set ::config($view,relative) 1
	    }
	    -absolute {
	        set ::config($view,absolute) 1
	    }
	    -scatter {
	        set ::config($view,scatter) 1
	    }
	    default {
	        if {![regexp {^\-(.*)$} $arg -> flag]} {
	            set ::config($view,$flag) $arg
		}    
	    }
	}
    }
}

* Adc -scatter -absolute -unit dB -th 0.1 -crit 95<1
* CMRR -scatter -absolute -unit dB -th 0.1 -crit 95<1
* PSRR -scatter -absolute -unit dB -th 0.1 -crit 95<1
* BW -scatter -relative -unit Hz -th 1e6  -crit 95<10
* PM -scatter -absolute -unit deg -th 5 -crit 95<20
* TotalNoise -scatter -relative -unit V^2 -th 1e-5 -crit 95<10
* fc -scatter -absolute -unit Hz -th 1 -crit 95<1e3

proc calculate_stats {name type} {
    set error_list {}
    set min_error 1e6
    set max_error -1e6
    foreach {x y} $::data($name) {
        if {$type=="relative"} {
	    skip {abs($y-$x)<$::config($name,th)}
            set error [expr 100*($y/$x-1)]
        } else {
	    skip {abs(100*($y/$x-1))<$::config($name,th)}
            set error [expr $y-$x]
        }    
        lappend error_list $error
        if {$error<$min_error} {
            set min_error $error
        }
        if {$error>$max_error} {
            set max_error $error
        }
    }
    set average 0
    foreach error $error_list {
        set average [expr $average+$error]
    }
    set average [expr $average/[llength $error_list]]
    set ::stats($::topology,$name,$type,average) $average
    set stddev 0
    foreach error $error_list {
        set stddev [expr $stddev+($error-$average)*($error-$average)]
    }
    set stddev [expr sqrt($stddev/[llength $error_list])]
    set ::stats($::topology,$name,$type,stddev) $stddev
    set centered_error_list {}
    foreach error $error_list {
        lappend centered_error_list [expr abs($error-$average)]
    }
    set centered_error_list [lsort -real $centered_error_list]
    foreach marker {90 95 99} {
        set ::stats($::topology,$name,$type,$marker) [lindex $centered_error_list [expr $marker*[llength $error_list]/100]]
    }
    
    set step [expr ($max_error-$min_error)/$opt(hist_steps)]
    set y {}
    for {set i 0} {$i<$opt(hist_steps)} {incr i} {
        set min [expr $step*$i+$min_error]
        set max [expr $min+$step]
        set count 0
        foreach error $error_list {
            skip {$error<$min}
            skip {$error>=$max} 
            incr count
        }
        lappend x $min
        lappend y $count
    }
    set ::stats($::topology,$name,$type,histogram,x) $x
    set ::stats($::topology,$name,$type,histogram,y) $y
    regexp {^(.*)([<>=]+)(.*)$} $::config($name,crit) -> field op th
    set ::stats($::topology,$name,$type,pass/fail) [expr $::stats($::topology,$name,$type,$field)$op$th]
}
foreach file [lsort [glob -nocomplain ~/temp/match_*_$opt(tech)_$opt(rez).tcl]] {
    array unset data
    source $file
    regexp {match_([^_]+)} $file -> ::topology
    foreach name [lsort [array names data]] {
        if {$::config($name,relative)} {
            calculate_stats $name relative
        }
        if {$::config($name,absolute)} {
            calculate_stats $name absolute
        }
        if {$::config($name,scatter)} {
        }
    }
}
set HTML [open ~/public_html/certificate_of_accuracy_$opt(tech)_$opt(rez).html w]
<!DOCTYPE html>
<html><body>
<h1> Summary </h1>
<table border="1"> 
<tr><td>Performance Parameter</td><td><font color="green">Pass</font>/<font color="red">Fail</font></td></tr>
foreach view $::views {
    <tr>
    <td><b>$view</b></td>
    <td>
    <svg width="300" height="10">
    <rect x="2" y="2" fill="none" strike="black"/>
    </svg>
    </td>
    </tr>
}
</body>
</html>
close $HTML

exit
