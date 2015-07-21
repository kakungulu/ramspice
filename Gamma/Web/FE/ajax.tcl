source $::env(RAMSPICE)/Gamma/Web/svg/svg.tcl
set ::heatmap_pallet {0xa50026 0xd73027 0xf46d43 0xfdae61 0xfee090 0xffffbf 0xe0f3f8 0xabd9e9 0x74add1 0x4575b4 0x313695}
set ::arrow_icon "<svg enable-background=\"new 0 0 128 128\" height=\"18px\" id=\"Layer_1\" version=\"1.1\" viewBox=\"0 0 128 128\" width=\"18px\" xml:space=\"preserve\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\"><g><g><path d=\"M64.032,13.869c-27.642,0-50.129,22.489-50.129,50.131c0.002,27.643,22.49,50.131,50.131,50.131    c27.64,0,50.126-22.488,50.126-50.131C114.16,36.358,91.673,13.869,64.032,13.869z M64.034,110.131    C38.6,110.131,17.905,89.438,17.903,64c0-25.437,20.693-46.131,46.129-46.131c25.435,0,46.128,20.694,46.128,46.131    C110.16,89.438,89.468,110.131,64.034,110.131z M78.539,68.918L66.034,79.694V43.942c0-1.104-0.896-2-2-2s-2,0.896-2,2v35.752    L49.527,68.918c-0.837-0.721-2.101-0.627-2.821,0.21s-0.627,2.101,0.21,2.821l17.118,14.748L81.15,71.949    c0.837-0.722,0.931-1.984,0.209-2.821C80.639,68.291,79.376,68.197,78.539,68.918z\" /></g></g></svg>"
proc SVG::graph_pareto_front {args} {
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
        x_type lin
        y_type lin
        title {}
        connect_pattern 2,5
        connect_width 1
        script {}
	heatmap 0
	pallet {}
    }
    foreach {param value} $args {
        set opt($param) $value
    }
    if {$opt(script)!={}} {
        puts $::SVG::O "<script type=\"text/javascript\"><!\[CDATA\["
        puts $::SVG::O $opt(script)
        puts $::SVG::O "\]\]>"
        puts $::SVG::O </script>
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
    if {$opt(heatmap)} {
        <image xlink:href="http://www.engr.colostate.edu/~ystatter/hm$opt(heatmap).bmp" x="$opt(x)" y="$opt(y)" height="$opt(height)" width="$opt(width)" />  
	set key_index 0
	set key [lindex $opt(key) 0]
	SVG::text x [expr $opt(x)+$opt(width)] y [expr $opt(y)+100+15*$key_index] font-size 15 {
	    print [eng $key $opt(z_unit)]
	}   
	incr key_index
	foreach key [lrange $opt(key) 1 end] color $opt(pallet) {
	    regsub {0x} $color {#} color
	    SVG::rect x [expr $opt(x)+$opt(width)] y [expr $opt(y)+85+15*$key_index] width 100 height 12 style "fill:$color"
	    incr key_index
	    SVG::text x [expr $opt(x)+$opt(width)] y [expr $opt(y)+100+15*$key_index] font-size 15 {
	        print [eng $key $opt(z_unit)]
	    }	
	    incr key_index
	} 
    }	
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
    foreach $order $opt(data) id $::circuit_ids index $::circuit_list {
        set color green
        foreach key [lsort -unique [array names ::opt] ] {
            skip {$key=="Name"}
            skip {$key=="none"}
            skip {![info exists ::properties($key,unit)]}
            if {$::opt($key)!={}} {
                set entry [lsearch $::ref_list $key]
                set value [lindex [@ /$::SESSION(selected_topology)/circuits PAT index $index] $entry]
                if {$::properties($key,step)>0} {
                    if {$value<$::opt($key)} {
                        set color red
                    }
                } else {
                    if {$value>$::opt($key)} {
                        set color red
                    }
                }
                
            }	
        }
        set tag [lsearch $::SESSION(selected_circuits_tags) $id]
        default m 0
        set marker [split [lindex $opt(markers) $m] :]
        set radius [lindex $marker 0]
        set x_coord [expr $opt(x)+$opt(width)*($x-$min_x)/($max_x-$min_x)]
        set y_coord [expr $opt(y)+$opt(height)-$opt(height)*($y-$min_y)/($max_y-$min_y)]
        default ::SESSION(selcircuit_$id) 0
        if {$::SESSION(selcircuit_$id)} {
            <circle cx="$x_coord" cy="$y_coord" r="[expr 2*$radius]" fill="transparent" stroke="$color" stroke-width="1" visibility="visible">
            <set attributeName="visibility" from="visible" to="hidden" begin="marker$id.click"/> 
            </circle>
            <text x="[expr $x_coord-5]" y="[expr $y_coord-15]" font-size="14" fill="red" visibility="visible"> $tag
            <set attributeName="visibility" from="visible" to="hidden" begin="marker$id.click"/> 
            </text>
        } else {
            <circle cx="$x_coord" cy="$y_coord" r="[expr 2*$radius]" fill="transparent" stroke="$color" stroke-width="1" visibility="hidden">
            <set attributeName="visibility" from="hidden" to="visible" begin="marker$id.click"/> 
            </circle>
            <text x="[expr $x_coord-5]" y="[expr $y_coord-15]" font-size="14" fill="red" visibility="hidden"> $tag 
            <set attributeName="visibility" from="hidden" to="visible" begin="marker$id.click"/> 
            </text>
        }
        SVG::circle cx $x_coord cy $y_coord r $radius stroke $color stroke-width 1 fill $color id marker$id onclick "updateSelectedSpec($id)"
        <text x="[expr 1.05*$x_coord]" y="[expr 0.95*$y_coord]" font-size="20" fill="$color" visibility="hidden"> [eng $x $opt(x_unit)] [eng $y $opt(y_unit)] 
        <set attributeName="visibility" from="hidden" to="visible" begin="marker$id.mouseover" end="marker$id.mouseout"/> 
        </text>
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
default ::SESSION(selected_circuits_tags) {}
Info: [array get ::SESSION selcircuit_*]
default ::SESSION(circuit_list) {}
default ::opt(selected_circuit) {}
foreach id $::opt(selected_circuit) {
    default ::SESSION(selcircuit_$id) 0
    set ::SESSION(selcircuit_$id) [expr !$::SESSION(selcircuit_$id)]
}
default ::opt(deselect) {}
foreach id $::opt(deselect) {
    set ::SESSION(selcircuit_$id) 0
}
Info: [array get ::SESSION selcircuit_*]
foreach key [array names ::opt] {
    skip {$key=="launch"}
    skip {$key=="selected_circuit"}
    set ::SESSION($key) $::opt($key)
}
if {![info exists ::SESSION(selected_topology)]} return
source $::env(RAMSPICE)/Etc/Templates/$::SESSION(selected_topology)/data.tcl
source $::env(RAMSPICE)/../schematic_lib.tcl
@ / load $::env(RAMSPICE)/Etc/Templates/$::SESSION(selected_topology)/pareto_bi.db
Info: properties=[@ /$::SESSION(selected_topology)/circuits PAT properties]
Info: sizes=[@ /$::SESSION(selected_topology)/circuits PAT sizes]
regsub -all %2C $::SESSION(selected_g) { } selected_g
regsub -all {(^|\s)\S*_} $selected_g { } selected_g
regsub -all %2C $::SESSION(selected_axes) { } selected_axes
regsub -all {(^|\s)\S*_} $selected_axes { } selected_axes
lassign $selected_axes x y z



set spec_list {}
foreach p [@ /$::SESSION(selected_topology)/circuits PAT properties] {
    if {![info exists ::opt($p)]} {
        lappend spec_list nan
        continue
    }
    if {[lsearch $selected_g $p]!=-1} {
        lappend spec_list inf
        continue
    }
    if {$::opt($p)=={}} {
        if {[lsearch $selected_axes $p]!=-1} {
            lappend spec_list inf
        } else {
            lappend spec_list nan
        }
        continue
    }
    lappend spec_list $::opt($p)
}
set axes_list {}
foreach p [@ /$::SESSION(selected_topology)/circuits PAT properties] {
    if {[lsearch $selected_axes $p]==-1} {
        lappend axes_list nan
        continue
    }
    lappend axes_list inf
}


@ /$::SESSION(selected_topology)/circuits >>> $spec_list
::SVG::out
set ::circuit_list [@ /$::SESSION(selected_topology)/circuits >>> $axes_list]
set ::SESSION(circuit_list) $::circuit_list
set retval {}
set ::ref_list [concat [@ /$::SESSION(selected_topology)/circuits PAT sizes] [@ /$::SESSION(selected_topology)/circuits PAT properties]]
set entries {}
foreach axis {x y z} {
    skip {[set $axis]=="none"}
    lappend entries [lsearch $::ref_list [set $axis]]
}    
Info: [array get ::opt]
Info: [array get ::SESSION selcircuit_*]
Info: spec_list=$spec_list
Info: axes_list=$axes_list
Info: circuit_list=$circuit_list
Info: entries=$entries
proc sort_front {a b} {
    set xa [lindex [@ /$::SESSION(selected_topology)/circuits PAT index $a] $::x_index]
    set xb [lindex [@ /$::SESSION(selected_topology)/circuits PAT index $b] $::x_index]
    if {$xb>$xa} {
        return 0
    }
    return 1
}
set ::x_index [lindex $entries 0]
set ::circuit_list [lsort -command sort_front $::circuit_list]
set ::circuit_ids {}
foreach circuit $::circuit_list {
    lappend ::circuit_ids  [@ /$::SESSION(selected_topology)/circuits PAT id $circuit]
}
Info: circuit_ids=$circuit_ids
set pixels {}
foreach index $::circuit_list {
    set circuit [@ /$::SESSION(selected_topology)/circuits PAT index $index]
    set id [@ /$::SESSION(selected_topology)/circuits PAT id $index]
    if {[lsearch $::SESSION(selected_circuits_tags) $id]==-1} {
        lappend ::SESSION(selected_circuits_tags) $id
    }
    foreach entry [lrange $entries 0 1] {
        Info: $index,$entry=[lindex $circuit $entry]
        lappend pixels [lindex $circuit $entry]
    }
}
set 3d_pixels {}
foreach index $::circuit_list {
    set circuit [@ /$::SESSION(selected_topology)/circuits PAT index $index]
    foreach entry $entries {
        lappend 3d_pixels [lindex $circuit $entry]
    }
}

set x_unit {}
if {[info exists ::properties($x,unit)]} {
    set x_unit $::properties($x,unit)
}
set y_unit {}
if {[info exists ::properties($y,unit)]} {
    set y_unit $::properties($y,unit)
}
set z_unit {}
if {[info exists ::properties($z,unit)]} {
    set z_unit $::properties($z,unit)
}
# set z_unit m2
set rowspan 2
foreach key [lsort -unique [concat $x $y $z [array names ::opt] $selected_g]] {
    skip {$key=="Name"}
    skip {$key=="none"}
    if {[info exists ::SESSION($key)] && [lsearch $selected_g $key]==-1 && $x!=$key && $y!=$key && $z!=$key} {
        skip {$::opt($key)=={}}
        skip {![info exists ::properties($key,unit)]}
    }
    skip {![info exists ::properties($key,unit)]}
    incr rowspan
}  
incr rowspan [llength $::sizer_list]
incr rowspan [llength $selected_g]
set rowsize 15
set frame_size [expr 600+$rowsize*$rowspan]
set outer_frame_size [expr $frame_size+200]
if {[info exists $z=="none"]} {
    default ::opt(title) "$y \[$y_unit\] vs $x \[$x_unit\]"
} else {
    default ::opt(title) "$z \[$z_unit\] vs $y \[$y_unit\] and $x \[$x_unit\]"
}

<table><tr bgcolor=$::colors(gray)>
<td rowspan="$rowspan bgcolor=$::colors(gray)" class="tableFormatter" id="MapContainer">
::SVG::svg width $outer_frame_size height $outer_frame_size {
    if {$z=="none"} {
        ::SVG::graph_pareto_front x 100 y 100 width $frame_size height $frame_size data $pixels markers 8:green connect all x_title $x y_title $y x_unit $x_unit y_unit $y_unit title $::opt(title)
    } else {
        set pallet $::heatmap_pallet
        if {[info exists ::properties($z,step)]} {
	    if {$::properties($z,step)<0} {
	        set pallet {}
		foreach color $::heatmap_pallet {
		    set pallet [concat $color $pallet]
		}
	    }
	}
        set hm /top/students/GRAD/ECE/ystatter/home/public_html/hm[pid].bmp
        set key [heatmap $3d_pixels $pallet $hm]
        ::SVG::graph_pareto_front pallet $pallet heatmap [pid] key $key x 100 y 100 width $frame_size height $frame_size data $pixels markers 8:green x_title $x y_title $y x_unit $x_unit y_unit $y_unit z_unit $z_unit title $::opt(title)
    }
}
</td>
set selected_circuits {}
<td bgcolor=$::colors(yellow)><b>Property</b></td><td bgcolor=$::colors(gray)><b>Required</b></td>
set i 0
foreach circuit [array names ::SESSION selcircuit_*] {
    skip {$::SESSION($circuit)==0}
    lassign [split $circuit _] -> id
    lappend selected_circuits $id
}    
set selected_circuits [lsort -integer $selected_circuits]
set present_selected_circuits {}
foreach id $selected_circuits {
    foreach index $::circuit_list {
        skip {$id!=[@ /$::SESSION(selected_topology)/circuits PAT id $index]}
        lappend present_selected_circuits $id
        break
    }
}
set selected_circuits $present_selected_circuits
foreach id $selected_circuits {
    set tag [lsearch $::SESSION(selected_circuits_tags) $id]
    set color [lindex {yellow gray} [expr $i%2]] 
    <td align="center" bgcolor=$::colors($color)><button onclick="DeSelect($id)">X</button><b>$tag</b><button onclick="Focus($id)">$::arrow_icon</button></td>
    incr i
}
</tr>
set i 0
foreach key [lsort -unique [concat $x $y $z [array names ::opt] $selected_g]] {
    skip {$key=="Name"}
    skip {$key=="none"}
    if {[info exists ::SESSION($key)] && [lsearch $selected_g $key]==-1 && $x!=$key && $y!=$key && $z!=$key} {
        skip {$::opt($key)=={}}
        skip {![info exists ::properties($key,unit)]}
    }
    skip {![info exists ::properties($key,unit)]}
    Info: KEY=$key [lsearch $::ref_list $key]
    set j $i 
    set color [lindex {yellow orange} [expr $j%2]] 
    set prefix [lindex {<b>X:</b> <b>Y:</b> <b>Z:</b>} [lsearch [list $x $y $z] $key]]
    <tr><td bgcolor=$::colors($color)>$prefix <b>$::properties($key,html)</b></td>
    incr j
    set color [lindex {yellow orange} [expr $j%2]] 
    set entry [lsearch $::ref_list $key]
    set value [eng $::opt($key) $::properties($key,unit)]
    if {$::opt($key)=={}} {
        set value {}
    }
    if {[lsearch $selected_g $key]==-1} {
        puts $::HTML "<td bgcolor=$::colors($color)>$value</td>"
    } else {
        <td bgcolor=$::colors($color)>
        <svg enable-background="new 0 0 200 200" height="16px"  version="1.1" viewBox="0 0 200 200" width="16px" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" ><g><path d="M106.582,63.015c-4.273,4.856-7.285,9.74-8.877,14.553c-0.502,1.523-0.854,3.021-1.063,4.488   c-2.215-0.544-4.521-0.837-6.898-0.837c-16.009,0-29.036,13.028-29.036,29.036c0,16.01,13.026,29.034,29.036,29.034   c16.009,0,29.034-13.024,29.034-29.034c0-2.375-0.291-4.686-0.835-6.9c6.094-0.852,12.553-4.224,19.045-9.933   c1.877,5.267,2.906,10.931,2.906,16.833c0,27.652-22.499,50.152-50.15,50.152c-27.654,0-50.152-22.5-50.152-50.152   c0-27.653,22.498-50.15,50.152-50.15C95.649,60.104,101.318,61.136,106.582,63.015z M162.652,57.992   c-3.902,7.567-8.006,14.359-12.231,20.235c5.071,9.567,7.946,20.466,7.946,32.028c0,37.843-30.779,68.626-68.623,68.626   c-37.84,0-68.626-30.783-68.626-68.626c0-37.841,30.786-68.627,68.626-68.627c11.563,0,22.465,2.879,32.035,7.951   c5.856-4.217,12.632-8.319,20.224-12.234c-14.728-10.588-32.775-16.833-52.259-16.833C40.259,20.512,0,60.773,0,110.255   c0,49.485,40.259,89.744,89.744,89.744c49.481,0,89.743-40.259,89.743-89.744C179.487,90.771,173.241,72.722,162.652,57.992z    M92.301,97.312c-0.827-0.167-1.682-0.254-2.557-0.254c-7.28,0-13.197,5.92-13.197,13.198c0,7.278,5.917,13.197,13.197,13.197   c7.278,0,13.198-5.919,13.198-13.197c0-0.875-0.09-1.729-0.25-2.556l-8.962,6.983c-1.044,0.816-2.354,1.269-3.688,1.269   c-1.598,0-3.106-0.625-4.238-1.756c-2.135-2.138-2.344-5.549-0.485-7.928L92.301,97.312z" fill="#000000"/><path d="M168.587,36.007c6.827,1.365,21.227,3.238,27.908-3.444c10.069-10.07-3.803-25.252-13.385-15.674   c9.582-9.578-5.603-23.454-15.676-13.384c-6.678,6.68-4.805,21.079-3.442,27.906l-3.439,3.44   c-48.37,20.299-64.252,44.289-56.816,56.846l-14.027,17.998c-0.129,0.167-0.117,0.406,0.035,0.561   c0.152,0.154,0.394,0.165,0.564,0.033l17.996-14.022c12.551,7.433,36.543-8.446,56.844-56.819L168.587,36.007z" fill="#000000" /></g></svg>
        </td>
    }	
    foreach id $selected_circuits {
        foreach index $::circuit_list {
            skip {$id!=[@ /$::SESSION(selected_topology)/circuits PAT id $index]}
            incr j 
            set color [lindex {yellow orange} [expr $j%2]] 
            set value [lindex [@ /$::SESSION(selected_topology)/circuits PAT index $index] $entry]
            set font_color black
            if {$::opt($key)!={}} {
                if {$::properties($key,step)>0} {
                    if {$value>=$::opt($key)} {
                        set font_color green
                    } else {
                        set font_color red
                    }
                } else {
                    if {$value>=$::opt($key)} {
                        set font_color red
                    } else {
                        set font_color green
                    }
                }
                Info: $key=$::opt($key) step=$::properties($key,step) value=$value font_color=$font_color
            }
            
            puts $::HTML "<td bgcolor=\"$::colors($color)\"><font color=\"$font_color\">&nbsp[eng [lindex [@ /$::SESSION(selected_topology)/circuits PAT index $index] $entry] $::properties($key,unit)]&nbsp</font></td>"
            break
        }    
    }
    incr i
    </tr>
}
<tr bgcolor=$::colors(green)><td colspan="[expr 2+[llength $selected_circuits]]" align="center">
draw_schematic $::SESSION(selected_topology) 
</td>
</tr>
incr ::svg_width -100
foreach sizer $::sizer_list {
    set color [lindex {yellow orange} [expr $i%2]] 
    <tr bgcolor=$::colors($color)><td><b>$sizer</b></td><td colspan="[expr 2+[llength $selected_circuits]]"><input type=range id="$sizer" min="$::sizers($sizer,min)"  max="$::sizers($sizer,max)" style="width:${::svg_width}px"></td></tr>
    incr i 
}
</table>
save_session
return
save_session
if {![info exists ::opt(launch)]} {
    return
}

set nbcode [list array set ::SESSION [array get ::SESSION]]
append nbcode {
    set sleep_until [clock seconds]
    incr sleep_until 40
    while {[clock seconds]<$sleep_until} {}
} 
netbatch $nbcode user $::SESSION(user) Name $::SESSION(Name)
