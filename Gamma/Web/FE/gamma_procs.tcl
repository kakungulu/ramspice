source $::env(RAMSPICE)/Gamma/Web/svg/svg.tcl
source $::env(RAMSPICE)/../schematic_lib.tcl
proc save_session {} {
    set S [open $::sessions_path/$::active_session w]
    puts $S "array set ::SESSION \{"
    foreach var [lsort [array names ::SESSION]] {
        set val $::SESSION($var)
	puts $S [list $var $val]
    }
    puts $S "\}"
    close $S
}
proc function {name body} {
   set body [uplevel [list subst $body]]
   puts $::HTML [list function $name $body]
}
proc get_step {min max} {
    set step 1e-35
    while {$step<abs($min)} {
        set step [expr 10*$step]
    }
    set step [expr $step/100]
    set count 200
    set search_index 0
    while {$count>12} {
        set step [expr $step*[lindex {2 2.5 2} [expr $search_index%3]]]
        incr search_index
        set low_bar [expr int($min/$step)*$step]
        set high_bar [expr int($max/$step)*$step]
        set count [expr int(($high_bar-$low_bar)/$step)+1]
    }
    if {$step>1.0} {
        regsub {\.[0-9]+} $step {} step
    } elseif {[regexp e $step]} {
        regsub {\.[0-9]+} $step {} step
    } else {
        regsub {0\.(0*[^0]).*} $step {0.\1} step
    }
    return $step
}
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
        z {}
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
        SVG::text x [expr $opt(x)+$opt(width)] y [expr $opt(y)+100+15*$key_index] font-size 15 text-decoration "underline" {
            print "$opt(z) \[$opt(z_unit)\]"
        }   
        incr key_index 2
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
    set xstep [get_step $min_x $max_x]
    set ystep [get_step $min_y $max_y]
    Info: xstep=$xstep ystep=$ystep
    set ::x_value [expr int($min_x/$xstep)*$xstep]
    if {$::x_value<$min_x} {
        set ::x_value [expr $::x_value+$xstep]
    }
    Info: x_value=$::x_value min_x=$min_x max_x=$max_x
    while {$::x_value<=$max_x} {
        set x_coord [expr $opt(x)+int($opt(width)*($::x_value-$min_x)/($max_x-$min_x))]
        Info: x_coord=$x_coord
        SVG::line x1 $x_coord y1 $y1_coord x2 $x_coord y2 $y2_coord stroke black stroke-width 3
        SVG::text x $x_coord y $y3_coord font-size 18 {
            print [eng $::x_value $opt(x_unit)]
        }
        SVG::line x1 $x_coord y1 $y1_coord x2 $x_coord y2 $opt(y) stroke black stroke-width 1 stroke-dasharray 5,5
        set ::x_value [expr $::x_value+$xstep]
    }
    set x1_coord [expr $opt(x)]
    set x2_coord [expr $x1_coord-10]
    set x3_coord [expr $x2_coord-50]
    set x4_coord [expr $x3_coord-20]
    SVG::text x $x4_coord y [expr $opt(y)+(0.8*$opt(height))] font-size 15 style "direction: rtl; writing-mode: tb; glyph-orientation-vertical: 90;" {
        print "$opt(y_title)"
    }
    set ::y_value [expr int($min_y/$ystep)*$ystep]
    if {$::y_value<$min_y} {
        set ::y_value [expr $::y_value+$ystep]
    }
    while {$::y_value<=$max_y} {
        set y_coord [expr $opt(y)+$opt(height)-int($opt(height)*($::y_value-$min_y)/($max_y-$min_y))]
        Info: y_coord=$y_coord
        SVG::line x1 $x1_coord y1 $y_coord x2 $x2_coord y2 $y_coord stroke black stroke-width 3
        SVG::text x [expr $x4_coord+10] y $y_coord font-size 18 {
            print [eng $::y_value $opt(y_unit)]
        }
        SVG::line x1 [expr $opt(x)+$opt(width)] y1 $y_coord x2 $opt(x) y2 $y_coord stroke black stroke-width 1 stroke-dasharray 5,5
        set ::y_value [expr $::y_value+$ystep]
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
        if {[regexp {[nN]} $x_coord]} continue;
        if {[regexp {[nN]} $y_coord]} continue;
        default ::SESSION(selcircuit_$id) 0
        if {$::SESSION(selcircuit_$id)} {
            <circle cx="$x_coord" cy="$y_coord" r="[expr 2*$radius]" fill="transparent" stroke="$color" stroke-width="1" visibility="visible" id="washer$id">
            <set attributeName="visibility" from="visible" to="hidden" begin="marker$id.click"/> 
            </circle>
            <text x="[expr $x_coord-5]" y="[expr $y_coord-15]" font-size="14" fill="red" visibility="visible" id="tag$id"> $tag
            <set attributeName="visibility" from="visible" to="hidden" begin="marker$id.click"/> 
            </text>
        } else {
            <circle cx="$x_coord" cy="$y_coord" r="[expr 2*$radius]" fill="transparent" stroke="$color" stroke-width="1" visibility="hidden" id="washer$id">
            <set attributeName="visibility" from="hidden" to="visible" begin="marker$id.click"/> 
            </circle>
            <text x="[expr $x_coord-5]" y="[expr $y_coord-15]" font-size="14" fill="red" visibility="hidden" id="tag$id"> $tag 
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
namespace eval ::GEN_SPICE {
}
proc ::GEN_SPICE::transistor {name d g s b L W {corner ss}} {
    set type [string index $name 0]
    set n [expr int(ceil($W/(10*$L)))]
    set W [expr $W/$n]
    for {set i 1} {[info exists ::bin($type,$i,lmax)]} {incr i} {
        skip {$::bin($type,$i,lmax)<$L}
        skip {$::bin($type,$i,lmin)>$L}
        skip {$::bin($type,$i,wmax)<$W}
        skip {$::bin($type,$i,wmin)>$W}
	break
    }
    if {![info exists ::bin($type,$i,lmax)]} {
        Error: Transistor dimensions L=$l and W=$W (n=$n) do not correspond to any bin
	exit
    }
    set retval {}
    if {$n==1} {
	append retval [list $name $d $g $s $b ${type}ch_${corner}_$i L=$L W=$W]
	append retval "\n"
        return $retval
    }
    set retval {}
    for {set j 0} {$j<$n} {incr j} {
        append retval [list ${name}_$j $d $g $s $b ${type}ch_${corner}_$i L=$L W=$W]
	append retval "\n"
    }
    return $retval
}
proc sort_front {a b} {
    set xa [lindex [@ /$::SESSION(selected_topology)/circuits PAT index $a] $::x_index]
    set xb [lindex [@ /$::SESSION(selected_topology)/circuits PAT index $b] $::x_index]
    if {$xb>$xa} {
        return 0
    }
    return 1
}

proc generate_table_code {x y z} {
    set ::table_code ""
    set entry_offset [llength [@ /$::SESSION(selected_topology)/circuits PAT sizes]]
    append ::table_code "table+=\"<tr bgcolor='$::colors(bg)'><td></td><td></td>"
    set ::num_of_columns 1
    foreach property $::property_list {
        incr ::num_of_columns
        if {[catch {expr $::opt($property)+0}]} {
            set ::opt($property) {}
        }
        set property_color($property) gray
        foreach axis {x y z} {
            skip {[set $axis]!=$property}
            set property_color($property) black
        }
        if {$::opt($property)!={}} {
            set property_color($property) black
        }
        if {[lsearch $::selected_g $property]!=-1} {
            set property_color($property) black
        }
        append ::table_code "<td align='center'><table><tr><td onclick=\\\"DefinePropertySpec('$property','$::opt($property)')\\\">$::config_icon</td>"
        if {$x==$property} {
            append ::table_code "<td id='X_$property' onclick=\\\"toggle_axis_property(0,'$property')\\\"><font color=\\\"#000000\\\"><b>X</b></font></td>"
        } else {
            append ::table_code "<td id='X_$property' onclick=\\\"toggle_axis_property(0,'$property')\\\"><font color=\\\"#808080\\\">X</font></td>"
        }
        if {$y==$property} {
            append ::table_code "<td id='Y_$property' onclick=\\\"toggle_axis_property(1,'$property')\\\"><font color=\\\"#000000\\\"><b>Y</b></font></td>"
        } else {
            append ::table_code "<td id='Y_$property' onclick=\\\"toggle_axis_property(1,'$property')\\\"><font color=\\\"#808080\\\">Y</font></td>"
        }
        if {$z==$property} {
            append ::table_code "<td id='Z_$property' onclick=\\\"toggle_axis_property(2,'$property')\\\"><font color=\\\"#000000\\\"><b>Z</b></font></td>"
        } else {
            append ::table_code "<td id='Z_$property' onclick=\\\"toggle_axis_property(2,'$property')\\\"><font color=\\\"#808080\\\">Z</font></td>"
        }
        if {[lsearch $::selected_g $property]==-1} {
            append ::table_code "<td id='G_$property' onclick=\\\"toggle_g2('$property')\\\">$::goal_icon_gray2</td>"
        } else {
            append ::table_code "<td id='G_$property' onclick=\\\"toggle_g2('$property')\\\">$::goal_icon_black2</td>"
        }
        append ::table_code "<tr></tr><td colspan='4' align='center'><font color='$property_color($property)'><b>$property</b></font></td></tr></table></td>"
    }
    append ::table_code "<td bgcolor='black'> </td>"
    foreach size [@ /$::SESSION(selected_topology)/circuits PAT sizes] {
        skip {![@ size:$size ?]}
        incr ::num_of_columns
        if {[catch {expr $::opt($size)+0}]} {
            set ::opt($size) {}
        }
        set property_color($size) gray
        foreach axis {x y z} {
            skip {[set $axis]!=$size}
            set property_color($size) black
        }
        if {$::opt($size)!={}} {
            set property_color($size) black
        }
        if {[lsearch $::selected_g $size]!=-1} {
            set property_color($size) black
        }
        append ::table_code "<td align='center'><table><tr>"
        if {$x==$size} {
            append ::table_code "<td id='X_$size' onclick=\\\"toggle_axis_sizer(0,'$size')\\\"><font color=\\\"#000000\\\"><b>X</b></font></td>"
        } else {
            append ::table_code "<td id='X_$size' onclick=\\\"toggle_axis_sizer(0,'$size')\\\"><font color=\\\"#808080\\\">X</font></td>"
        }
        if {$y==$size} {
            append ::table_code "<td id='Y_$size' onclick=\\\"toggle_axis_sizer(1,'$size')\\\"><font color=\\\"#000000\\\"><b>Y</b></font></td>"
        } else {
            append ::table_code "<td id='Y_$size' onclick=\\\"toggle_axis_sizer(1,'$size')\\\"><font color=\\\"#808080\\\">Y</font></td>"
        }
        append ::table_code "<tr></tr><td colspan='4' align='center'><font color='black'><b>$size</b></font></td></tr></table></td>"
    }
    append ::table_code "<td id='SelectedCircuitID'></td></tr>\"\;\n"
    append ::table_code "table+=\"<tr bgcolor=$::colors(bg)><td></td><td><b>Spec:</b></td><td></td>"
    foreach property $::property_list {
        set value {}
        if {$::opt($property)!={}} {
            if {$::properties($property,step)>0} {
                append value " >"
            } else {
                append value " <"
            }
            append value [eng $::opt($property) $::properties($property,unit)]
        }
        append ::table_code "<td align='center'><b>$value</b></td>"
    }
    foreach size [@ /$::SESSION(selected_topology)/circuits PAT sizes] {
        skip {![@ size:$size ?]}
        append ::table_code "<td></td>"
    }
    append ::table_code "<td onclick='SendSpecToServer(\\\"\\\",\\\"\\\")'>$::refresh_icon</td></tr>\"\;\n"
    set j 0
    foreach circuit $::circuit_ids index $::circuit_list {
        set color green
        foreach property $::property_list  {
            if {$::opt($property)!={}} {
                set entry [lsearch $::ref_list $property]
                set value [lindex [@ /$::SESSION(selected_topology)/circuits PAT index $index] $entry]
                if {$::properties($property,step)>0} {
                    if {$value<$::opt($property)} {
                        set color red
                    }
                } else {
                    if {$value>$::opt($property)} {
                        set color red
                    }
                }
                
            }   
        }
        default ::SESSION(selcircuit_$circuit) 0
        if {$::SESSION(selcircuit_$circuit)} {
            lappend selected_circuits_ids $circuit
        }
        set tag [lsearch $::SESSION(selected_circuits_tags) $circuit]
        set bgcolor [lindex {yellow orange} [expr $j%2]] 
        set bgcolor $::colors($bgcolor)
        foreach operator {== !=} {
            append ::table_code "    if ((selected_circuits.lastIndexOf($circuit)!=-1)&&(focus_circuit$operator'$circuit')) \{\n        table+=\"<tr bgcolor=$::colors(bg)><td><button onclick='DeSelect($circuit)'>X</button></td><td bgcolor=$bgcolor><font color='$color'><b>$tag</b></font></td>"
            incr j
            foreach property $::property_list {
                set entry [lsearch [@ /$::SESSION(selected_topology)/circuits PAT properties] $property]
                incr entry $entry_offset
                set value [lindex [@ /$::SESSION(selected_topology)/circuits PAT index $index] $entry]
                set font_color $property_color($property)
                if {$::opt($property)!={}} {
                    if {$::properties($property,step)>0} {
                        if {$value>=$::opt($property)} {
                            set font_color green
                        } else {
                            set font_color red
                        }
                    } else {
                        if {$value>=$::opt($property)} {
                            set font_color red
                        } else {
                            set font_color green
                        }
                    }
                }
                if {$operator=="=="} {
                    set bgcolor $::colors(bg)
                } else {
                    set bgcolor [lindex {yellow orange} [expr $j%2]] 
                    set bgcolor $::colors($bgcolor)
                }   
                set value [eng [lindex [@ /$::SESSION(selected_topology)/circuits PAT index $index] $entry] $::properties($property,unit)]
                if {[regexp {^(\S+)\.(.)..(\S+)$}  $value -> a b c]} {
                    set value "$a.$b$c"
                }
                append ::table_code "<td bgcolor=$bgcolor><font color='$font_color'> $value </font></td>"
              #  append ::table_code "<td bgcolor=$bgcolor><font color='$font_color'> [eng [lindex [@ /$::SESSION(selected_topology)/circuits PAT index $index] $entry] $::properties($property,unit)] </font></td>"
                incr j
            }
            append ::table_code "<td bgcolor='black'> </td>"
            foreach size [@ /$::SESSION(selected_topology)/circuits PAT sizes] {
                skip {![@ size:$size ?]}
                set entry [lsearch [@ /$::SESSION(selected_topology)/circuits PAT sizes] $size]
                set value [lindex [@ /$::SESSION(selected_topology)/circuits PAT index $index] $entry]
                set font_color black
                if {$operator=="=="} {
                    set bgcolor $::colors(bg)
                } else {
                    set bgcolor [lindex {yellow orange} [expr $j%2]] 
                    set bgcolor $::colors($bgcolor)
                }   
                set value [eng [lindex [@ /$::SESSION(selected_topology)/circuits PAT index $index] $entry] $::sizers($size,unit)]
                if {[regexp {^(\S+)\.(.)..(\S+)$}  $value -> a b c]} {
                    set value "$a.$b$c"
                }
                append ::table_code "<td bgcolor=$bgcolor><font color='$font_color'> $value </font></td>"
                incr j
            }
            append ::table_code "<td><button onclick='FocusOn($circuit)'>$::focus_icon</button></td></tr>\"\;\n    \}\n"
        }
    }
    set T [open $::env(RAMSPICE)/table.js w]
    puts $T $::table_code
    close $T
} 
