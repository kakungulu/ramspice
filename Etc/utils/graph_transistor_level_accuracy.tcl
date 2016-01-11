# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
default ::opt(tech) tsmc040
default ::opt(rez) 5:5:3:8
default ::opt(dev) nch:pch
default ::opt(corners) ss:tt:ff
default ::opt(work_file) $::env(RAMSPICE)/../../PRECENTILE.tcl

source $::env(RAMSPICE)/Gamma/Web/svg/svg.tcl
set unknown {
    if {[regexp {^<} $args]} {
        set line $args
        regsub -all {\\\"} $line "\"" line
        regsub -all {[\{\}]} $line "" line
        puts $::HTML $line
        return
    }
}
append unknown [info body unknown]
proc unknown args $unknown

foreach corner [split $::opt(corners) :] {
    foreach dev [split $::opt(dev) :] {
        foreach info_file [glob -nocomplain $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/4d/$::opt(rez)/$dev.$corner.???.info] {
            open_bin read $info_file
            set num_of_lines 0
            while {1} {
                foreach var {Vgs Vds Vbs L W LUT_Ids Ids LUT_gm gm LUT_go go LUT_cgs cgs LUT_cgd cgd LUT_nt nt LUT_nf nf} {
                    set value [read_bin float]
                    if {[string match *n* $value]} break
                    default  RAW($dev,$var,$corner) {}
                    lappend RAW($dev,$var,$corner) [expr abs($value)]
                }
                if {[string match *n* $value]} break
            }
            close_bin read
        }    
    }
}
set rez 32
set percentiles {50 75 90 95 99}
$::env(RAMSPICE)/../../PRECENTILE.tcl
if {[file exists $::opt(work_file)]} {
    source $::opt(work_file)
}
foreach view {Ids gm go Cgs Cgd Thermal_Noise_Floor Flicker_Noise_at_1Hz} key {Ids gm go cgs cgd nt nf} unit {A &#8487\; &#8487\; F F V&#178\;/Hz V&#178\;/Hz} scale {1 1 1 1 1 1e-24 1e-18} font {32 32 32 32 32 32 32} {
    set CONF($key,view) $view
    set CONF($key,unit) $unit
    set CONF($key,scale) $scale
    set CONF($key,font) $font
}
foreach dev [split $::opt(dev) :] {
    foreach key {Ids gm go cgs cgd nt nf} {
        set view $CONF($key,view)
        set unit $CONF($key,unit)
        set scale $CONF($key,scale)
        set font $CONF($key,font)
        foreach corner [split $::opt(corners) :] { 
            skip {![info exists RAW($dev,$key,$corner)]}
            skip {[llength $RAW($dev,$key,$corner)]==0}
            set ::HTML [open $::env(RAMSPICE)/../../Accuracy_${::opt(tech)}_${::opt(rez)}_${dev}_${key}_${corner}.html w]
            <html>
            <body>
            ::SVG::out 
            set data {}
            set prop_error_list {}
            set error_list {}
            foreach X $RAW($dev,LUT_$key,$corner) Y $RAW($dev,$key,$corner) {
                skip {$Y==""}
                lappend data [expr $X/$scale]
                lappend data [expr $Y/$scale]
                lappend error_list [expr ($Y-$X)/$scale]
                skip {$X==0}
                lappend prop_error_list [expr 100*($Y/$X-1)]
            }
            set scale_notice {}
            if {$scale!=1} {
                set scale_notice "x$scale"
            }
            <table>
            <tr>
            <td> 
            
            ::SVG::svg width 1000 height 1100 {
                ::SVG::graph_data font $font x 100 y 100 width 900 height 900 data $data show_unit 0 markers 6:green x_title SPICE y_title Gamma x_unit $scale_notice$unit y_unit $scale_notice$unit title "$view values for $dev at [string toupper $corner]"
            }
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
                set PRECENTILE($::opt(tech),$::opt(rez),$dev,$key,$corner,$precentile,delta) [lindex $precentile_errors [expr $precentile*$length/100]]
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
                set PRECENTILE($::opt(tech),$::opt(rez),$dev,$key,$corner,$precentile,rel) [lindex $precentile_errors [expr $precentile*$length/100]]
            }
            set table_font [expr $font/2]
            <td align="center">
            <table border="1">
            <tr><td align="center" colspan="3"><font size="$table_font"><b>Statistics</b></font></td></tr>
            <tr><td> <font size="$table_font"><b>Average</b></font></td><td> <font size="$table_font">[eng $average %]</font></td><td> <font size="$table_font">[eng $delta_average*$scale $unit]</font></td></tr>
            <tr><td> <font size="$table_font"><b>&#963\;</b></font></td><td> <font size="$table_font">[eng $stdev %]</font></td><td> <font size="$table_font">[eng $delta_stdev*$scale $unit]</font></td></tr>
            <tr><td> <font size="$table_font"><b>Percentile</b></font></td><td> <font size="$table_font"><b>% Error</b></font></td><td> <font size="$table_font"><b>&#916\; Error</b></font></td></tr>
            foreach precentile $percentiles {
                <tr> <td> <font size=\"$table_font\">[eng $precentile %]</font></td><td> <font size=\"$table_font\">[eng $PRECENTILE($::opt(tech),$::opt(rez),$dev,$key,$corner,$precentile,rel) %]</font></td><td> <font size=\"$table_font\">[eng $PRECENTILE($::opt(tech),$::opt(rez),$dev,$key,$corner,$precentile,delta)*$scale $unit]</font></td></tr>
            }
            </table>    
            </td>
            </tr>
            <tr>
            <td> 
            ::SVG::svg width 1000 height 1100 {
                ::SVG::graph_hist font $font stdev $delta_stdev average $delta_average x 100 y 100 width 900 height 900 data $delta_hist_data show_unit 0 connect all connect_pattern 1 connect_width 2 x_title "&#916;$view" y_title Count x_unit $scale_notice$unit y_unit {} title "$view error histogram for $dev at [string toupper $corner]"
            }
            </td>
            <td> 
            ::SVG::svg width 1000 height 1100 {
                ::SVG::graph_hist font $font stdev $stdev average $average x 100 y 100 width 900 height 900 data $hist_data show_unit 0 connect all connect_pattern 1 connect_width 2 x_title "$view Ratio" y_title Count x_unit % y_unit {} title "$view error histogram for $dev at [string toupper $corner]"
            }
            </td>
            </tr>
            </table>    
            </body>
            </html>
            close $::HTML
        }    
    }
}
set O [open $::opt(work_file) w]
puts $O [list array set PRECENTILE [array get PRECENTILE]]
close $O
set ::HTML [open $::env(RAMSPICE)/../../Accuracy_${::opt(tech)}_${::opt(rez)}.html w]
<html><body>
<h1> Accuracy Results for Tech: $::opt(tech) Resolution: $::opt(rez) </h1>
<table border="1"> 
#foreach list {key dev corner precentile type} {
    #    set ${list}_list {}
#}
foreach key [array names PRECENTILE $::opt(tech),$::opt(rez),*] {
    lassign [split $key ,] tech rez dev view corner precentile type
    ladd dev_list $dev
    ladd key_list $view
    ladd corner_list $corner
    ladd precentile_list $precentile
    ladd type_list $type
}
set dev_list [lsort $dev_list]
set key_list [lsort $key_list]
set precentile_list [lsort -integer $precentile_list]
set type_list [lsort $type_list]
<tr><td colspan="2"></td>
foreach dev $dev_list {
    <td colspan="[expr [llength $corner_list]*[llength $type_list]]" align="center"><b>$dev</b></td>
}
</tr>
<tr><td colspan="2"></td>
foreach dev $dev_list {
    foreach corner $corner_list {
        <td colspan="[llength $type_list]"><b>$corner</b></td>
    }
}
</tr>    
<tr><td colspan="2"></td>
foreach dev $dev_list {
    foreach corner $corner_list {
        foreach type $type_list {
            <td> <b>$type</b></td>
        }
    }
}
</tr>    
foreach key $key_list {
    <tr><td rowspan="[llength $precentile_list]" align="center"><b>$CONF($key,view)</b></td>
    set first 1
    foreach precentile $precentile_list {
        if {!$first} {
            <tr>
        }
        set first 0
        <td> <b>$precentile</b></td>
        foreach dev $dev_list {
            foreach corner $corner_list {
                foreach type $type_list {
                    if {![info exists PRECENTILE($::opt(tech),$::opt(rez),$dev,$key,$corner,$precentile,$type)]} {
                        <td> </td>
                        continue
                    }
                    set color black
                    if {[info exists PRECENTILE($::opt(tech),$::opt(rez),$dev,$key,$corner,$precentile,rel)]} {
                        if {$PRECENTILE($::opt(tech),$::opt(rez),$dev,$key,$corner,$precentile,rel)<10} {
                            set color green
                        } else {
                            set color red
                        }
                    }
                    set unit $CONF($key,unit)
                    if {$type=="rel"} {
                        set unit %
                    }
                    set pre {}
                    set post {}
                    if {[file exists $::env(RAMSPICE)/../../Accuracy_${::opt(tech)}_${::opt(rez)}_${dev}_${key}_${corner}.html]} {
                        set pre "<a href=\"Accuracy_${::opt(tech)}_${::opt(rez)}_${dev}_${key}_${corner}.html\">"
                        set post </a>
                    }
                    Info: $::opt(tech),$::opt(rez),$dev,$key,$corner,$precentile,$type=[eng $PRECENTILE($::opt(tech),$::opt(rez),$dev,$key,$corner,$precentile,$type) $unit]
                    <td> $pre<font color="$color">[eng $PRECENTILE($::opt(tech),$::opt(rez),$dev,$key,$corner,$precentile,$type) $unit]</font>$post</td>
                }    
            }
        }
        </tr>
    }
}
</table>
</body></html>
close $::HTML
set ::HTML [open $::env(RAMSPICE)/../../Accuracy.html w]
<html><body>
<h1> Accuracy Results</h1>
foreach report_file [glob -nocomplain $::env(RAMSPICE)/../../Accuracy_*.html] {
    skip {![regexp {^Accuracy_([^_]+)_([^_]+)\.html$} [file tail $report_file] -> tech rez]}
    ladd resolutions($tech) $rez
}
<table border="1">
foreach tech [array names resolutions] {
    <tr><td rowspan="[llength $resolutions($tech)]" align="center">><b>$tech</b></td>
    set first 1
    foreach rez $resolutions($tech) {
        if {!$first} {
            <tr>
        }
        <td> <a href="Accuracy_${tech}_${rez}.html">$rez</a></td>
        </tr>
    }
}
</body></html>

close $::HTML
exit
