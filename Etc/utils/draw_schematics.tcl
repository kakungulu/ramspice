# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
Info: [array get opt]
array set ::colors {
    gray #F2F2F3
    green #3C8555
    red #EE4B3E
    orange #E9BC1B
    yellow #F5EACD 
    
    red #a50026 
    orange #fdae61
    yellow #fee090 
    gray #e0f3f8
    bg #ffffbf
    blue 0x313695
}
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
source $::env(RAMSPICE)/Gamma/Web/svg/svg.tcl
source $::env(RAMSPICE)/../schematic_lib.tcl

set ::HTML [open ~/public_html/sch.html w]
<html><body>
::SVG::out
foreach data_file [glob $::env(RAMSPICE)/Etc/Templates/*/data.tcl] {
    source $data_file
    set topo [file tail [file dirname $data_file]]
    skip {![info exists ::topologies($topo,schematic)]}
    draw_schematic  $topo
}
</body></html>
close $::HTML
foreach data_file [glob $::env(RAMSPICE)/Etc/Templates/*/data.tcl] {
    source $data_file
    set topo [file tail [file dirname $data_file]]
    set ::HTML [open ~/public_html/$topo.svg w]
    ::SVG::out
    draw_schematic  $topo
    close $::HTML
}    

exit
