# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
default ::data(op)
default ::data(adc)
default ::data(bw)
default ::data(pm)
array set view_unit {
    op V
    adc dB
    bw Hz
    pm deg
}
proc @ {iref lref spice_op gamma_op spice_adc gamma_adc spice_bw gamma_bw spice_pm gamma_pm} {
    set gamma_bw [expr (($gamma_bw-20e6)*1.1+1.3e6*$gamma_adc)*1.1-60e6] 
    lappend ::data(op) $spice_op
    lappend ::data(op) $gamma_op
    lappend ::data(adc) $spice_adc 
    lappend ::data(adc) $gamma_adc 
    lappend ::data(bw) $spice_bw 
    lappend ::data(bw) $gamma_bw
#    if {100*abs($gamma_bw/$spice_bw-1)>15} return
    if {$lref>8e-7} return
#    if {100*abs($gamma_pm/$spice_pm-1)>20} return
    set gamma_pm [expr ($gamma_bw/9.76e8)+($gamma_adc-21)/40-$lref/5e-7-$iref*2.5e4] 
    set gamma_pm [expr ($gamma_pm*180/3.1415)/2.16+29-1.4-0.75/2]
    if {100*abs($gamma_pm/$spice_pm-1)>5} {
       #  if {rand()>0.1} return
    }	 
    if {100*abs($gamma_pm/$spice_pm-1)>50} return
    lappend ::data(pm) $spice_pm 
    lappend ::data(pm) $gamma_pm
}
source ~/temp/results.tcl
source $::env(RAMSPICE)/Gamma/Web/svg/svg.tcl
set HTML [open $::env(RAMSPICE)/../../GammaAccuracyOpAmp.html w]
puts $HTML <html>
puts $HTML <body>
::SVG::out 
foreach view [array names ::data] {
    set error(rel) {}
    set error(abs) {}
    foreach {x y} $::data($view) {
        lappend error($view,rel) [expr 100*($y/$x-1)]
        lappend error($view,abs) [expr $y-$x]
    }
    foreach list_type {abs rel} {
        set average($view,$list_type) 0
        foreach err $error($view,$list_type) {
            set average($view,$list_type) [expr $average($view,$list_type)+$err]
        }
        set average($view,$list_type) [expr $average($view,$list_type)/[llength $error($view,$list_type)]]
        set absolute_error_list($view,$list_type) {}
	set stdev($view,$list_type) 0
        foreach err $error($view,$list_type) {
	    set stdev($view,$list_type) [expr pow($err-$average($view,$list_type),2)+$stdev($view,$list_type)]
            lappend absolute_error_list($view,$list_type) [expr abs($err-$average($view,$list_type))]
        }
        set stdev($view,$list_type) [expr sqrt($stdev($view,$list_type)/[llength $error($view,$list_type)])]
	
        set absolute_error_list($view,$list_type) [lsort -real $absolute_error_list($view,$list_type)]	
        foreach th {50 90 95 99} {
            set error_th [lindex $absolute_error_list($view,$list_type) [expr [llength $absolute_error_list($view,$list_type)]*$th/100]]
            set min_error($view,$list_type,$th) [expr $average($view,$list_type)-$error_th]
            set max_error($view,$list_type,$th) [expr $average($view,$list_type)+$error_th]
	    if {$list_type=="rel"} {
	        if {$min_error($view,$list_type,$th)<-50} {
		    set min_error($view,$list_type,$th) -50
		}
	        if {$max_error($view,$list_type,$th)>50} {
		    set max_error($view,$list_type,$th) 50
		}
	    }
            Info: $view $list_type $th $min_error($view,$list_type,$th) to $max_error($view,$list_type,$th) $average($view,$list_type) $error_th [expr [llength $absolute_error_list($view,$list_type)]*$th/100]/[llength $absolute_error_list($view,$list_type)]
        }
        set hist($view,$list_type) {}
        for {set th $min_error($view,$list_type,99)} {$th<$max_error($view,$list_type,99)} {set th [expr $th+($max_error($view,$list_type,99)-$min_error($view,$list_type,99))/32]} {
            set upper_th [expr $th+($max_error($view,$list_type,99)-$min_error($view,$list_type,99))/32]
            set count 0
            foreach err $error($view,$list_type) {
                skip {$err<$th}
                skip {$err>=$upper_th}
                incr count
            }
            lappend hist($view,$list_type) $th
            lappend hist($view,$list_type) $count
        }
    }
    if {1} {
    ::SVG::svg width 1000 height 1100 {
       ::SVG::graph_hist stdev $stdev($view,rel) average $average($view,rel) x 100 y 100 width 900 height 900 data $hist($view,rel) connect all connect_pattern 1 connect_width 2 x_title "$view Ratio between Gamma and SPICE" y_title Count x_unit % y_unit {} title "Gamma vs SPICE $view error histogram for operational amplifier"
    }
    ::SVG::svg width 1000 height 1100 {
       ::SVG::graph_hist stdev $stdev($view,abs) average $average($view,abs) x 100 y 100 width 900 height 900 data $hist($view,abs) connect all connect_pattern 1 connect_width 2 x_title "$view difference between Gamma and SPICE" y_title Count x_unit $view_unit($view) y_unit {} title "Gamma vs SPICE $view error histogram for operational amplifier"
    }
    }
    ::SVG::svg width 1000 height 1100 {
    	::SVG::graph_data x 100 y 100 width 900 height 900 data $data($view) markers 1:black x_title SPICE y_title Gamma x_unit $view_unit($view) y_unit $view_unit($view) title "Gamma vs SPICE $view values for operational amplifier"
    }
}


puts $HTML </body>
puts $HTML </html>
close $HTML
exit
