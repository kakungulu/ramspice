#!/usr/bin/tclsh8.5


set unknown {
    if {[regexp {^<} $args]} {
        regsub -all {\\\"} $args "\"" html_line 
        puts $html_line
        return
    }
}

append unknown [info body unknown]
proc unknown args $unknown

puts "Content-type: text/html\n\n"
if {[file exists data.tcl]} {
    source data.tcl
}

set user default
if {[info exists ::env(HTTP_X_FORWARDED_FOR)]} {
    set from [lindex $::env(HTTP_X_FORWARDED_FOR) end]
}
if {![info exists DATA($from,last_access)]} {
    set DATA($from,last_access) 0
}
set authenticate 0
if {[clock seconds]-$DATA($from,last_access)>15*60} {
    set authenticate 1
}
if {![info exists
<html>
<body>
<h1> Hello World</h1>
</body>
</html>

set O [open data.tcl w]
puts $O [list array set DATA [array get DATA]]
close $O


