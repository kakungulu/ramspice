proc save_session {} {
    set S [open $::sessions_path/$::active_session w]
    puts $S [list array set ::SESSION [array get ::SESSION]]
    close $S
}
proc function {name body} {
   set body [uplevel [list subst $body]]
   puts $::HTML [list function $name $body]
}
proc get_step {min max} {
    set step 1e-25
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
        regsub {0\.(.).*} $step {0.\1} step
    }
    return $step
}
source $::env(RAMSPICE)/Gamma/Web/svg/svg.tcl
source $::env(RAMSPICE)/../schematic_lib.tcl

