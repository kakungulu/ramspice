# \
exec $RAMSPICE/ramspice $0 $argv

get_opts
default opt(tech) tsmc040

set devices {}
set corners {}
set sections {}
set params {}
set I [open $opt(tech)_from_cadence.lib r]
while {[gets $I line]>=0} {
    if {[regexp {model\s+(\S+)_(\S+)_(\S+)} $line -> fdev fcor fbin]} {
        set device $fdev
        set corner $fcor
        set section $fbin
        if {[lsearch $corners $corner]==-1} {
            lappend corners $corner
        }
        if {[lsearch $devices $device]==-1} {
            lappend devices $device
        }
        if {[lsearch $sections $section]==-1} {
            lappend sections $section
        }
        continue
    }
    if {![regexp {^\+\s*(\S+)\s*=\s*(\S+)\s*$} $line -> param value]} continue
    set table($device,$corner,$section,$param) $value
    if {[lsearch $params $param]==-1} {
        lappend params $param
    }
}
close $I
set O [open $opt(tech).html w]
puts $O <html><body>
foreach device $devices {
    puts $O "<table border=\"2\"><tr><td>Param</td>"
    foreach section [lsort -integer $sections] {
        puts $O "<td>$section</td>"
    }
    puts $O "</tr>"
    foreach param [lsort $params] {
        puts $O "<tr><td>$param</td>"
        foreach section [lsort -integer $sections] {
            set color [lindex {green blue red orange brown} [expr ($section-1)/8]]
            puts $O "<td>"
            foreach corner $corners {
                if {![info exists table($device,$corner,$section,$param)]} {
                    set table($device,$corner,$section,$param) XXX
                }
                puts $O "<font color=\"$color\">[eng $table($device,$corner,$section,$param)]</font><br>"
            }
            puts $O "</td>"
        }
        puts $O "</tr>"
    }
    puts $O "</table>"
}
close $O 

exit


