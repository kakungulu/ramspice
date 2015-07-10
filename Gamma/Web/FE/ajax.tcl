foreach key [array names ::opt] {
    skip {$key=="launch"}
    set ::SESSION($key) $::opt($key)
}
if {![info exists ::SESSION(selected_topology)]} return
source $::env(RAMSPICE)/Etc/Templates/$::SESSION(selected_topology)/data.tcl
source $::env(RAMSPICE)/Gamma/Web/svg/svg.tcl
source $::env(RAMSPICE)/../schematic_lib.tcl
::SVG::out
regsub -all %2C $::SESSION(selected_axes) { } selected_axes
regsub -all {(^|\s)\S*_} $selected_axes { } selected_axes
lassign $selected_axes x y z
regsub -all %2C $::SESSION(selected_g) { } selected_g
regsub -all {(^|\s)\S*_} $selected_g { } selected_g
set x_unit {}
if {[info exists ::properties($x,unit)]} {
    set x_unit $::properties($x,unit)
}
set y_unit {}
if {[info exists ::properties($y,unit)]} {
    set y_unit $::properties($y,unit)
}
set rowspan 1
foreach key [lsort [array names ::SESSION]] {
    skip {$key=="Name"}
    skip {$::SESSION($key)=={}}
    skip {![info exists ::properties($key,unit)]}
    incr rowspan
}  
incr rowspan [llength $selected_g]
set rowsize 15
set frame_size [expr 600+$rowsize*$rowspan]
set outer_frame_size [expr $frame_size+100]
<table border=1><tr>
<td rowspan="$rowspan" class="tableFormatter">
::SVG::svg width $outer_frame_size height $outer_frame_size {
    ::SVG::graph_markers x 100 y 0 width $frame_size height $frame_size data  {0 0 1 1 2 4 3 9 4 16 5 25} markers 4:green connect all x_title $x y_title $y x_unit $x_unit y_unit $y_unit
}
</td>
<td><b>Property</b></td><td><b>Required</b></td><td><b>Selected</b></td></tr>
foreach key [lsort -unique [concat [array names ::SESSION] $selected_g]] {
    skip {$key=="Name"}
    Info: key=$key [info exists ::SESSION($key)] 
    if {[info exists ::SESSION($key)] && [lsearch $selected_g $key]==-1} {
        skip {$::SESSION($key)=={}}
        skip {![info exists ::properties($key,unit)]}
    }
    Info: key=$key [lsearch $selected_g $key] selected_g=$selected_g
    if {[lsearch $selected_g $key]==-1} {
        <tr><td><b>$::properties($key,html)</b></td><td>[eng $::opt($key) $::properties($key,unit)]</td><td></td></tr>
    } else {
        <tr><td><b>$key</b></td><td>
	<svg enable-background="new 0 0 200 200" height="16px"  version="1.1" viewBox="0 0 200 200" width="16px" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" ><g><path d="M106.582,63.015c-4.273,4.856-7.285,9.74-8.877,14.553c-0.502,1.523-0.854,3.021-1.063,4.488   c-2.215-0.544-4.521-0.837-6.898-0.837c-16.009,0-29.036,13.028-29.036,29.036c0,16.01,13.026,29.034,29.036,29.034   c16.009,0,29.034-13.024,29.034-29.034c0-2.375-0.291-4.686-0.835-6.9c6.094-0.852,12.553-4.224,19.045-9.933   c1.877,5.267,2.906,10.931,2.906,16.833c0,27.652-22.499,50.152-50.15,50.152c-27.654,0-50.152-22.5-50.152-50.152   c0-27.653,22.498-50.15,50.152-50.15C95.649,60.104,101.318,61.136,106.582,63.015z M162.652,57.992   c-3.902,7.567-8.006,14.359-12.231,20.235c5.071,9.567,7.946,20.466,7.946,32.028c0,37.843-30.779,68.626-68.623,68.626   c-37.84,0-68.626-30.783-68.626-68.626c0-37.841,30.786-68.627,68.626-68.627c11.563,0,22.465,2.879,32.035,7.951   c5.856-4.217,12.632-8.319,20.224-12.234c-14.728-10.588-32.775-16.833-52.259-16.833C40.259,20.512,0,60.773,0,110.255   c0,49.485,40.259,89.744,89.744,89.744c49.481,0,89.743-40.259,89.743-89.744C179.487,90.771,173.241,72.722,162.652,57.992z    M92.301,97.312c-0.827-0.167-1.682-0.254-2.557-0.254c-7.28,0-13.197,5.92-13.197,13.198c0,7.278,5.917,13.197,13.197,13.197   c7.278,0,13.198-5.919,13.198-13.197c0-0.875-0.09-1.729-0.25-2.556l-8.962,6.983c-1.044,0.816-2.354,1.269-3.688,1.269   c-1.598,0-3.106-0.625-4.238-1.756c-2.135-2.138-2.344-5.549-0.485-7.928L92.301,97.312z" fill="#000000"/><path d="M168.587,36.007c6.827,1.365,21.227,3.238,27.908-3.444c10.069-10.07-3.803-25.252-13.385-15.674   c9.582-9.578-5.603-23.454-15.676-13.384c-6.678,6.68-4.805,21.079-3.442,27.906l-3.439,3.44   c-48.37,20.299-64.252,44.289-56.816,56.846l-14.027,17.998c-0.129,0.167-0.117,0.406,0.035,0.561   c0.152,0.154,0.394,0.165,0.564,0.033l17.996-14.022c12.551,7.433,36.543-8.446,56.844-56.819L168.587,36.007z" fill="#000000" /></g></svg>
	</td><td></td></tr>
    }	
}
<tr><td colspan="3">
draw_schematic $::SESSION(selected_topology) 
</td>
</tr>
<tr><td colspan="4" id="Sizers">
<label for=fader>L<sub>P</sub></label>
<input type="text" data-slider="true" value="0.8" data-slider-highlight="true">
</td>
</table>
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
