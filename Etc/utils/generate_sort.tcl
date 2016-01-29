# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
default ::opt(tech) tsmc040
source $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/binning_$::opt(tech).tcl

set l_values {}
set w_values {}
foreach lmin_key [array names ::bin p,*,lmin] {
    ladd l_values $::bin($lmin_key)
}
set l_values [lsort -real $l_values]
foreach wmin_key [array names ::bin p,*,wmin] {
    ladd w_values $::bin($wmin_key)
}
set w_values [lsort -real $w_values]

proc SortL {list wlist} {
    Info: L sort: $list $wlist
    if {[llength $list]==1} {
        SortW $wlist [lindex $list 0]
	return
    }
    set mid_l [lindex $list [expr [llength $list]/2]]
    set low_list [lrange $list 0 [expr [llength $list]/2-1]]
    set high_list [lrange $list [expr [llength $list]/2] end]
    puts $::O "if (L<$mid_l) \{"
    SortL $low_list $wlist
    puts $::O "\} else \{"
    SortL $high_list $wlist
    puts $::O "\}"
}
proc SortW {list L} {
    if {[llength $list]==1} {
        set W [lindex $list 0]
	for {set section 1} {[info exists ::bin(p,$section,lmin)]} {incr section} {
	    skip {$::bin(p,$section,lmin)!=$L}
	    skip {$::bin(p,$section,wmin)!=$W}
	    break
	}
	puts $::O "section=$section;"
	return
    }
    set mid_w [lindex $list [expr [llength $list]/2]]
    set low_list [lrange $list 0 [expr [llength $list]/2-1]]
    set high_list [lrange $list [expr [llength $list]/2] end]
    puts $::O "if (W<$mid_w) \{"
    SortW $low_list $L
    puts $::O "\} else \{"
    SortW $high_list $L
    puts $::O "\}"
}
Info: l_values=$l_values
Info: w_values=$w_values
set ::O [open $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/sort_$::opt(tech) w]
SortL $l_values $w_values
close $::O
exec /top/students/GRAD/ECE/ystatter/home/auto_indent.tcl $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/sort_$::opt(tech)
exit
