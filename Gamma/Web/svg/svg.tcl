namespace eval SVG {
    variable out_file_name ""
    variable O stdout
}

proc SVG::out {{filename {}}} {
    if {$filename=={}} {
        if {[info exists ::HTML]} {
	    set SVG::O $::HTML
	    return
	}
	Error: No ::HTML outlet yet.
	exit
    }
    if {[catch {set SVG::O [open $filename w]} msg]} {
        Error: $msg
	return
    }
    set SVG::out_file_name $filename
}
proc SVG::append {stream} {
    if {[catch {set SVG::O $stream} msg]} {
        Error: $msg
	return
    }
    set SVG::out_file_name ""
}
proc SVG::close {} {
    if {[catch {close $SVG::O} msg]} {
        Error: $msg
	return
    }
    set SVG::O stdout
    set SVG::out_file_name ""
}

proc SVG::print {args} {
    foreach text $args {
        puts -nonewline $SVG::O "$text "
    }
}
foreach cmd {
    svg
    g
    text
    desc
    defs
} {
    proc SVG::$cmd {args} "set payload \[lindex \$args end\] ; SVG::print <$cmd ; foreach \{param value\} \[lrange \$args 0 end-1\] \{SVG::print \"\$param=\\\"\$value\\\"\"\} ; SVG::print \" >\"; uplevel \[list namespace eval ::SVG \[list uplevel \$payload\]\] ; SVG::print \"</$cmd>\\n\""
}
foreach cmd {
    rect
    circle
    img
    ellipse
    line
    polyline
    polygon
} {
    proc SVG::$cmd {args} "SVG::print \"<$cmd\" ; foreach \{param value\} \$args \{SVG::print \"\$param=\\\"\$value\\\"\"\} ; SVG::print \" />\\n\""
}

proc SVG::graph {type args} {
    if {[info procs ::SVG::graph_$type]=={}} {
	    Error: No such graph type: $type
	    exit
    }
    uplevel "SVG::graph_$type $args"
}
proc SVG::align {x} {
    if {[catch {set magnitude [expr int(-log10(abs($x)))+3]}]} {
        Warning: $x too large for alignment
        return $x
    }
    set factor [expr pow(10,$magnitude)]
    return [expr int($x*$factor)/$factor]
}
proc SVG::graph_markers {args} {
    array set opt {
        x 0
	y 0
	width 200
	height 200
	data {}
	markers {1:black}
	connect {}
	x_unit {}
	y_unit {}
	x_title {}
	y_title {}
	x_type lin
	y_type lin
	title {}
	connect_pattern 2,5
	connect_width 1
    }
    foreach {param value} $args {
        set opt($param) $value
    }
    if {[llength $opt(markers)]==1} {
        set order {x y}
    } else {
        set order {x y m}
    }
    SVG::text x [expr $opt(x)+$opt(width)/3-[string length $opt(title)]*2] y [expr $opt(y)-15] font-size 15  {
        print $opt(title)
    }
    set min_x 1e90
    set min_y 1e90
    set max_x -1e90
    set max_y -1e90
    set warn_log 0
    if {$opt(x_type)=="log"} {
        set log_data {}
	foreach $order $opt(data) {
	    default m {}
	    if {$x<=0.0} {
	        set warn_log 1
		continue
	    }
	    set x [expr log($x)]
	    lappend log_data $x
	    lappend log_data $y
	    if {$m!={}} {
	        lappend log_data $m
	    }
	}
	set opt(data) $log_data
    }
    if {$opt(y_type)=="log"} {
        set log_data {}
	foreach $order $opt(data) {
	    default m {}
	    if {$y<=0.0} {
	        set warn_log 1
		continue
	    }
	    set y [expr log($y)]
	    lappend log_data $x
	    lappend log_data $y
	    if {$m!={}} {
	        lappend log_data $m
	    }
	}
	set opt(data) $log_data
    }
    if {$warn_log} {
        Warning: Some graph entries were discarded because they were negative in a log-scale
    }
    foreach $order $opt(data) {
        if {$x<$min_x} {
	    set min_x $x
	}
        if {$y<$min_y} {
	    set min_y $y
	}
        if {$x>$max_x} {
	    set max_x $x
	}
        if {$y>$max_y} {
	    set max_y $y
	}
    }
    set x_min [expr $min_x-0.05*($max_x-$min_x)]
    set x_max [expr $max_x+0.05*($max_x-$min_x)]
    set y_min [expr $min_y-0.05*($max_y-$min_y)]
    set y_max [expr $max_y+0.05*($max_y-$min_y)]
    set min_x [SVG::align $x_min]
    set max_x [SVG::align $x_max]
    set min_y [SVG::align $y_min]
    set max_y [SVG::align $y_max]
    SVG::rect x $opt(x) y $opt(y) width $opt(width) height $opt(height) fill none stroke black stroke-width 3
    set y1_coord [expr $opt(y)+$opt(height)]
    set y2_coord [expr $y1_coord+10]
    set y3_coord [expr $y2_coord+10]
    set y4_coord [expr $y3_coord+20]
    SVG::text x [expr $opt(x)+$opt(width)/3] y $y4_coord font-size 15  {
        print "$opt(x_title)"
    }
    for {set i 0} {$i<=10} {incr i} {
        set x_coord [expr $opt(x)+($opt(width)/10.0)*$i]
	SVG::line x1 $x_coord y1 $y1_coord x2 $x_coord y2 $y2_coord stroke black stroke-width 3
	set ::x_value [expr $min_x+($max_x-$min_x)/10.0*$i]
	if {$opt(x_type)=="log"} {
	    set ::x_value [expr exp($::x_value)]
	}
	SVG::text x $x_coord y $y3_coord font-size 10 {
	    print [eng $::x_value $opt(x_unit)]
	}
	SVG::line x1 $x_coord y1 $y1_coord x2 $x_coord y2 $opt(y) stroke black stroke-width 1 stroke-dasharray 5,5
    }
    set x1_coord [expr $opt(x)]
    set x2_coord [expr $x1_coord-10]
    set x3_coord [expr $x2_coord-50]
    set x4_coord [expr $x3_coord-20]
    SVG::text x $x4_coord y [expr $opt(y)+(0.8*$opt(height))] font-size 15 style "direction: rtl; writing-mode: tb; glyph-orientation-vertical: 90;" {
        print "$opt(y_title)"
    }
    for {set i 0} {$i<=10} {incr i} {
        set y_coord [expr $opt(y)+($opt(height)/10.0)*$i]
	SVG::line x1 $x1_coord y1 $y_coord x2 $x2_coord y2 $y_coord stroke black stroke-width 3
	set ::y_value [expr $min_y+($max_y-$min_y)/10.0*(10-$i)]
	if {$opt(y_type)=="log"} {
	    set ::y_value [expr exp($::y_value)]
	}
	SVG::text x $x3_coord y $y_coord font-size 10 {
	    print [eng $::y_value $opt(y_unit)]
	}
	SVG::line x1 [expr $opt(x)+$opt(width)] y1 $y_coord x2 $opt(x) y2 $y_coord stroke black stroke-width 1 stroke-dasharray 5,5
    }
    set id 0
    foreach $order $opt(data) {
        default m 0
	set marker [split [lindex $opt(markers) $m] :]
	set radius [lindex $marker 0]
	set color [lindex $marker 1]
        set x_coord [expr $opt(x)+$opt(width)*($x-$min_x)/($max_x-$min_x)]
        set y_coord [expr $opt(y)+$opt(height)-$opt(height)*($y-$min_y)/($max_y-$min_y)]
        SVG::circle cx $x_coord cy $y_coord r $radius stroke $color stroke-width 1 fill $color id marker$id
        <text id="thepopup" x="[expr 1.05*$x_coord]" y="[expr 0.95*$y_coord]" font-size="20" fill="$color" visibility="hidden"> [eng $x $opt(x_unit)] [eng $y $opt(y_unit)] 
	    <set attributeName="visibility" from="hidden" to="visible" begin="marker$id.mouseover" end="marker$id.mouseout"/> 
	</text>
	incr id
    }
    if {$opt(connect)=="all"} {
        set opt(connect) {}
        foreach $order $opt(data) {
            default m 0
	    if {[lsearch $opt(connect) $m]} {
	        lappend opt(connect) $m
	    }
	}    
    }
    foreach connected_marker $opt(connect) {  
        set color [lindex [split [lindex $opt(markers) $connected_marker] :] 1]
        set previous_x {}
	set previous_y {}
        foreach $order $opt(data) {
	    default m -1
            skip {$m!=$connected_marker}
	    set x_coord [expr $opt(x)+$opt(width)*(($x-$min_x)/($max_x-$min_x))]
	    set y_coord [expr $opt(y)+$opt(height)*(1-($y-$min_y)/($max_y-$min_y))]
	    if {$previous_x!={}} {
	        if {$opt(connect_pattern)=="solid"} {
		    SVG::line x1 $x_coord y1 $y_coord x2 $previous_x y2 $previous_y stroke $color stroke-width $opt(connect_width) 
		} else {
		    SVG::line x1 $x_coord y1 $y_coord x2 $previous_x y2 $previous_y stroke $color stroke-width $opt(connect_width) stroke-dasharray $opt(connect_pattern)
		}
	    }
	    set previous_x $x_coord
	    set previous_y $y_coord
        }
    }
}
proc SVG::graph_markers3D {args} {
    array set opt {
        x 0
	y 0
	width 200
	height 200
	data {}
	markers {1:black}
	connect {}
	x_unit {}
	y_unit {}
	z_unit {}
	x_title {}
	y_title {}
	z_title {}
	x_type lin
	y_type lin
	z_type lin
	title {}
    }
    foreach {param value} $args {
        set opt($param) $value
    }
    if {[llength $opt(markers)]==1} {
        set order {x y z}
    } else {
        set order {x y z m}
    }
    SVG::text x [expr $opt(x)+$opt(width)/3-[string length $opt(title)]*2] y [expr $opt(y)-15] font-size 15  {
        print $opt(title)
    }
    set min_x 1e90
    set min_y 1e90
    set min_z 1e90
    set max_x -1e90
    set max_y -1e90
    set max_z -1e90
    set warn_log 0
    if {$opt(x_type)=="log"} {
        set log_data {}
	foreach $order $opt(data) {
	    default m {}
	    if {$x<=0.0} {
	        set warn_log 1
		continue
	    }
	    set x [expr log($x)]
	    lappend log_data $x
	    lappend log_data $y
	    lappend log_data $z
	    if {$m!={}} {
	        lappend log_data $m
	    }
	}
	set opt(data) $log_data
    }
    if {$opt(y_type)=="log"} {
        set log_data {}
	foreach $order $opt(data) {
	    default m {}
	    if {$y<=0.0} {
	        set warn_log 1
		continue
	    }
	    set y [expr log($y)]
	    lappend log_data $x
	    lappend log_data $y
	    lappend log_data $z
	    if {$m!={}} {
	        lappend log_data $m
	    }
	}
	set opt(data) $log_data
    }
    if {$opt(z_type)=="log"} {
        set log_data {}
	foreach $order $opt(data) {
	    default m {}
	    if {$z<=0.0} {
	        set warn_log 1
		continue
	    }
	    set z [expr log($z)]
	    lappend log_data $x
	    lappend log_data $y
	    lappend log_data $z
	    if {$m!={}} {
	        lappend log_data $m
	    }
	}
	set opt(data) $log_data
    }
    if {$warn_log} {
        Warning: Some graph entries were discarded because they were negative in a log-scale
    }
    foreach $order $opt(data) {
        if {$x<$min_x} {
	    set min_x $x
	}
        if {$y<$min_y} {
	    set min_y $y
	}
        if {$z<$min_z} {
	    set min_z $z
	}
        if {$x>$max_x} {
	    set max_x $x
	}
        if {$y>$max_y} {
	    set max_y $y
	}
        if {$z>$max_z} {
	    set max_z $z
	}
    }
    set x_min [expr $min_x-0.05*($max_x-$min_x)]
    set x_max [expr $max_x+0.05*($max_x-$min_x)]
    set y_min [expr $min_y-0.05*($max_y-$min_y)]
    set y_max [expr $max_y+0.05*($max_y-$min_y)]
    set z_min [expr $min_z-0.05*($max_z-$min_z)]
    set z_max [expr $max_z+0.05*($max_z-$min_z)]
    set min_x [SVG::align $x_min]
    set max_x [SVG::align $x_max]
    set min_y [SVG::align $y_min]
    set max_y [SVG::align $y_max]
    set min_z [SVG::align $z_min]
    set max_z [SVG::align $z_max]
    SVG::rect x $opt(x) y $opt(y) width $opt(width) height $opt(height) fill none stroke black stroke-width 3
    set y1_coord [expr $opt(y)+$opt(height)]
    set y2_coord [expr $y1_coord+10]
    set y3_coord [expr $y2_coord+10]
    set y4_coord [expr $y3_coord+20]
    set x1_coord [expr $opt(x)]
    set x2_coord [expr $x1_coord-10]
    set x3_coord [expr $x2_coord-50]
    set x4_coord [expr $x3_coord-20]
    foreach $order $opt(data) {
        default m 0
	set radius 1
	set color black
	if {$m<[llength $opt(markers)]} {
	    set marker [split [lindex $opt(markers) $m] :]
	    set radius [lindex $marker 0]
	    set color [lindex $marker 1]
	}
	foreach dim {x y z} {
	    set val [set $dim]
	    set min [set min_$dim]
	    set max [set max_$dim]
	    if {$max==$min} {
	        set ${dim}_rel 0
	    } else {
	        set ${dim}_rel [expr ($val-$min)/($max-$min)]
	    }
	}
        set x_coord [expr $opt(x)+$opt(width)/2+$opt(width)*($x_rel-$y_rel)/2]
        set y_coord [expr $opt(y)+$opt(height)-$opt(height)*(0.25*$x_rel+0.25*$y_rel+0.5*$z_rel)]
        SVG::circle cx $x_coord cy $y_coord r $radius stroke $color stroke-width 1 fill $color
    }
    if {$opt(connect)=="all"} {
        set opt(connect) {}
        foreach $order $opt(data) {
            default m 0
	    if {[lsearch $opt(connect) $m]} {
	        lappend opt(connect) $m
	    }
	}    
    }
    SVG::line x1 [expr $opt(x)+$opt(width)/2] y1 [expr $opt(y)+$opt(height)] x2 [expr $opt(x)+$opt(width)] y2 [expr $opt(y)+$opt(height)-$opt(height)*(0.25)] stroke black stroke-width 2
    SVG::line x1 [expr $opt(x)+$opt(width)/2] y1 [expr $opt(y)+$opt(height)] x2 [expr $opt(x)] y2 [expr $opt(y)+$opt(height)-$opt(height)*(0.25)] stroke black stroke-width 2
    SVG::line x1 [expr $opt(x)+$opt(width)/2] y1 [expr $opt(y)+$opt(height)] x2 [expr $opt(x)+$opt(width)/2] y2 [expr $opt(y)+0.5*$opt(height)] stroke black stroke-width 2
    
    foreach connected_marker $opt(connect) {  
        set color black
        if {$connected_marker<[llength $opt(markers)]} {
            set color [lindex [split [lindex $opt(markers) $connected_marker] :] 1]
	}
        set previous_x {}
	set previous_y {}
        foreach $order $opt(data) {
	    default m -1
            skip {$m!=$connected_marker}
	    foreach dim {x y z} {
	        set val [set $dim]
	        set min [set min_$dim]
	        set max [set max_$dim]
	        set ${dim}_rel [expr ($val-$min)/($max-$min)]
	    }
            set x_coord [expr $opt(x)+$opt(width)/2+$opt(width)*($x_rel-$y_rel)/2]
            set y_coord [expr $opt(y)+$opt(height)-$opt(height)*(0.25*$x_rel+0.25*$y_rel+0.5*$z_rel)]
	    if {$previous_x!={}} {
		SVG::line x1 $x_coord y1 $y_coord x2 $previous_x y2 $previous_y stroke $color stroke-width 1 stroke-dasharray 2,5
	    }
	    set previous_x $x_coord
	    set previous_y $y_coord
        }
    }
}
proc SVG::find_closest_x_coordinate {x list step} {
   set found_entry {}
   set dist [expr 2*$step]
   foreach entry $list {
     if {abs($x-$entry)<($step/10.0)} {
         if {$dist>abs($x-$entry)} {
 	     set found_entry $entry
	     set dist [expr abs($x-$entry)]
 	 }
     } elseif {$found_entry!={}} {
         break
     }
   }
   return  $found_entry
}
proc % {} {
    return "\[%\]"
}
proc SVG::graph_histogram {args} {
    array set opt {
        x 0
	y 0
	width 200
	height 200
	data {}
	x_unit {}
	y_unit {}
	x_title {}
	y_title Count
	x_type lin
	y_type lin
	title {}
    }
    foreach {param value} $args {
        set opt($param) $value
    }
    SVG::text x [expr $opt(x)+$opt(width)/3] y [expr $opt(y)-15] font-size 15  {
        print $opt(title)
    }
    set min_x 1e90
    set min_y 1e90
    set max_x -1e90
    set max_y -1e90
    set warn_log 0
    set average 0
    set num_of_samples 0
    foreach {x y} $opt(data) {
        set average [expr $average+$x*$y]
	incr num_of_samples $y
    }
    set average [expr $average/$num_of_samples]
    set sigma 0
    foreach {x y} $opt(data) {
        set sigma [expr $sigma+($x-$average)*($x-$average)*$y]
    }
    set sigma [expr sqrt($sigma/$num_of_samples)]
    if {$opt(x_type)=="log"} {
        set log_data {}
	foreach {x y} $opt(data) {
	    if {$x<=0.0} {
	        set warn_log 1
		continue
	    }
	    set x [expr log($x)]
	    lappend log_data $x
	    lappend log_data $y
	}
	set opt(data) $log_data
#	set sigma [expr log($sigma)]
    }
    if {$opt(y_type)=="log"} {
        set log_data {}
	foreach {x y} $opt(data) {
	    if {$y<=0.0} {
	        set warn_log 1
		continue
	    }
	    set y [expr log($y)]
	    lappend log_data $x
	    lappend log_data $y
	}
	set opt(data) $log_data
    }
    if {$warn_log} {
        Warning: Some graph entries were discarded because they were negative in a log-scale
    }
    foreach {x y} $opt(data) {
        if {$x<$min_x} {
	    set min_x $x
	}
        if {$y<$min_y} {
	    set min_y $y
	}
        if {$x>$max_x} {
	    set max_x $x
	}
        if {$y>$max_y} {
	    set max_y $y
	}
    }
    set min_y 0
    set max_y [expr int($max_y+0.05*($max_y-$min_y))]
    array set map $opt(data)
    set step 1e90
    set entries [lsort -real [array names map]]
    set prev_entry [lindex $entries 0]
    foreach entry [lrange $entries 1 end] {
        set current_step [expr $entry-$prev_entry]
	if {$current_step<$step} {
	    set step $current_step
	}
        set prev_entry $entry
    }
    set max_x [expr $max_x+$step]
    SVG::rect x $opt(x) y $opt(y) width $opt(width) height $opt(height) fill none stroke black stroke-width 3
    set y1_coord [expr $opt(y)+$opt(height)]
    set y2_coord [expr $y1_coord+10]
    set y3_coord [expr $y2_coord+10]
    set y4_coord [expr $y3_coord+20]
    SVG::text x [expr $opt(x)+$opt(width)/3] y $y4_coord font-size 15  {
        print "$opt(x_title)"
    }
    for {set x $min_x} {$x<=$max_x} {set x [expr $x+($max_x-$min_x)/10]} {
        set found_entry [SVG::find_closest_x_coordinate $x $entries $step]
	if {$found_entry=={}} {
	    set map($x) 0
	    set found_entry $x
	}
        set x_coord1 [expr $opt(x)+$opt(width)*($x-$min_x)/($max_x-$min_x)]
        set x_coord2 [expr $x_coord1+$opt(width)*$step/($max_x-$min_x)]
	SVG::line x1 $x_coord1 y1 $y1_coord x2 $x_coord1 y2 $y2_coord stroke black stroke-width 3
	set ::x_value $found_entry
	if {$opt(x_type)=="log"} {
	    set ::x_value [expr exp($::x_value)]
	}
	SVG::text x $x_coord1 y $y3_coord font-size 10 {
	    print [eng $::x_value $opt(x_unit)]
	}
    }
    foreach i {-3 -2 -1 1 2 3} color {blue green red red green blue} {
        set x_coord [expr $opt(x)+$opt(width)*($sigma*$i-$min_x)/($max_x-$min_x)]
	if {$x_coord<$opt(x)} continue
	if {$x_coord>$opt(x)+$opt(width)} continue
	SVG::line x1 $x_coord y1 $y1_coord x2 $x_coord y2 $opt(y) stroke $color stroke-width 1 stroke-dasharray 5,5
    }
    set x1_coord [expr $opt(x)]
    set x2_coord [expr $x1_coord-10]
    set x3_coord [expr $x2_coord-50]
    set x4_coord [expr $x3_coord-20]
    SVG::text x $x4_coord y [expr $opt(y)+(0.3*$opt(height))] font-size 15 style "direction: ltr; writing-mode: tb; glyph-orientation-vertical: 90;" {
        print "$opt(y_title)"
    }
    for {set i 0} {$i<=10} {incr i} {
        set y_coord [expr $opt(y)+($opt(height)/10.0)*$i]
	SVG::line x1 $x1_coord y1 $y_coord x2 $x2_coord y2 $y_coord stroke black stroke-width 3
	set ::y_value [expr $min_y+($max_y-$min_y)/10.0*(10-$i)]
	if {$opt(y_type)=="log"} {
	    set ::y_value [expr exp($::y_value)]
	}
	SVG::text x $x3_coord y $y_coord font-size 10 {
	    print [eng $::y_value $opt(y_unit)]
	}
	SVG::line x1 [expr $opt(x)+$opt(width)] y1 $y_coord x2 $opt(x) y2 $y_coord stroke black stroke-width 1 stroke-dasharray 5,5
    }
    for {set x $min_x} {$x<$max_x} {set x [expr $x+$step]} {
        set found_entry [SVG::find_closest_x_coordinate $x $entries $step]
	if {$found_entry=={}} {
	    set map($x) 0
	    set found_entry $x
	}
        set x_coord1 [expr $opt(x)+$opt(width)*($x-$min_x)/($max_x-$min_x)]
        set x_coord2 [expr $x_coord1+$opt(width)*$step/($max_x-$min_x)]
	set x_coord1 [expr floor($x_coord1)]
	set x_coord2 [expr ceil($x_coord2)]
	set y_coord1 [expr $opt(y)+$opt(height)-$map($found_entry)*$opt(height)/($max_y-$min_y)]
	set y_coord2 [expr $opt(y)+$opt(height)]
	set y_coord1 [expr floor($y_coord1)]
	set y_coord2 [expr ceil($y_coord2)]
	SVG::polygon points "$x_coord1,$y_coord2 $x_coord1,$y_coord1 $x_coord2,$y_coord1 $x_coord2,$y_coord2" style "fill:black;stroke:black;stroke-width:3"
    }
}


