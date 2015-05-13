#!/usr/bin/tclsh8.5
####################################################
# populate two arrays: direct and rev that map the 
# knowledge stored in the LUT's. Those maps are 
# to be used in creating a resolution path from 
# LUT's to final L's and W's
#
# @param dependent - the dependent variable of a LUT
# @param LUT - name of a LUT's. 
# @param args - a list of independent variables
#
# @returns - empty
####################################################
namespace eval ::solver {
    variable solution_steps {}
    variable O stdout
    variable line 0
}
array set ::solver::direct {}
array set ::solver::rev {}
array set ::solver::default {}
array set ::solver::provided {}
array set ::solver::linkage {}

proc ::solver::dependence {dependent LUT args} {
    set key [join $args ,]
    set ::solver::direct($dependent,$key) $LUT
    for {set i 0} {$i<[llength $args]} {incr i} {
        set rev_dependent [lindex $args $i]
        set j $i
        incr j -1
        set k $i
        incr k
        set rev_independent [concat $dependent [lrange $args 0 $j] [lrange $args $k end]]
        set rev_key [join $rev_independent ,]
        set ::solver::rev($rev_dependent,$rev_key) $LUT
    }
}
proc ::solver::default {var value} {
    set ::solver::default($var) $value
}
proc ::solver::require {var value} {
    regsub -all {\$([a-z])} $value {$::solver::\1} value
    set ::solver::required($var) $value
}
proc ::solver::provide {var value} {
    set ::solver::provided($var) $value
}
proc ::solver::span {var min max step} {
    set ::solver::min($var) $min
    set ::solver::max($var) $max
    set ::solver::step($var) $step
    
}
proc ::solver::link {var expr} {
    set buf $expr
    set depends {}
    while {[regexp {\$([a-zA-Z][a-zA-Z_0-9]*)} $buf -> varname]} {
        lappend depends $varname
	puts "$var depends on $varname"
        regsub -all "\\$$varname" $buf {} buf
    }
    set ::solver::linkage($var) $depends
    set ::solver::expression($var) $expr
}
proc ::solver::solve_var_direct {var context} {
    # Don't re-calculate a variable, waste of time
    if {[lsearch $::solver::solved_vars $var ]!=-1} {return 1}
    # If it's provided, consider it calculated and document that you got it from the interface
    if {[info exists ::solver::provided($var)]} {
        lappend ::solver::solution_steps [list calc_provided $var $::solver::provided($var)]
        lappend ::solver::solved_vars $var
        return 1
    }
    # Look for user-provided expression first
    if {[info exists ::solver::linkage($var)]} {
        set success 1
        set steps_before_this_LUT $::solver::solution_steps
        foreach independent_var $::solver::linkage($var) {
            if {![solve_var_direct $independent_var $context]} {
                # disaster! but no worries, the script forgets about this LUT and every solution step that was added to serve it.
                set success 0
                set ::solver::solution_steps $steps_before_this_LUT
                break
            }
        }
        if {$success} {
            lappend ::solver::solution_steps [list calc_expression $var $::solver::expression($var)]
            lappend ::solver::solved_vars $var
            return 1
        }
    }
    # Try to find a LUT for calculation. Prioritize direct LUT over reverse lookup
    foreach dep_type {direct rev} {
        foreach dependence_key [array names $dep_type $var,*] {
            set success 1
            set independent_vars [lrange [split $dependence_key ,] 1 end]
            # Keep a copy of the solution path in case this LUT leads nowhere
            set steps_before_this_LUT $::solver::solution_steps
            # Make sure all variables this LUT depends on are solveable
            foreach independent_var $independent_vars {
                if {![solve_var_direct $independent_var $context] {
                        # disaster! but no worries, the script forgets about this LUT and every solution step that was added to serve it.
                        set success 0
                        set ::solver::solution_steps $steps_before_this_LUT
                        break
                    }
                }
            }
            # If no variable failed, this LUT is good enough and is added as a step to the solution
            if {$success} {
                lappend ::solver::solution_steps [list calc_$dep_type $var $independent_vars [set $dep_type($dependence_key)]]
                lappend ::solver::solved_vars $var
                return 1
            }
        } 
    }
    # LUT's gave no solution. However, there's a default value in case calculation is not possible
    if {[info exists ::solver::default($var)]} {
        lappend ::solver::solution_steps [list calc_default $var $::solver::default($var)]
        lappend ::solver::solved_vars $var
        return 1
    }
    # Sorry, this variable is outside the scope of the registered information. 
    # Returning 0 redirects the solver to find other ways to calculate the target variables.
    if {[lsearch $::solver::sweeped_vars $var] == -1} {
        lappend ::solver::sweeped_vars $var
	set ::solver::solution($var) [expr ($::solver::max($var)+$::solver::min($var))/2]
    }
    set ::$var 0
    return 1
}
proc calc_sweep var {set ::$var 0}

proc solution {error args} {
    array unset ::solver::solution
   # puts "Solution   ($error)"
    foreach var $args {
        set ::solver::solution($var) [set ::$var]
	#puts "    $var=$::solver::solution($var)"
    }
}
proc scan {var body} {
    if {[info exists ::solver::solution($var)]} {
        set span [expr $::solver::max($var)-$::solver::min($var)]
        set min [expr $::solver::solution($var)-$span/$::deflation/2]
        set max [expr $::solver::solution($var)+$span/$::deflation/2]
	set step [expr $span/$::deflation/16]
    } else {
        set min $::solver::min($var)
        set max $::solver::max($var)
        set step $::solver::step($var)
    }
    for {set ::$var $min} {[set ::$var]<$max} {set ::$var [expr [set ::$var]+$step]} {uplevel $body}
}
proc ::solver::calculate {context report_file_name args} {
    set ::solver::solution_steps {}
    set ::solver::solved_vars {}
    set ::solver::sweeped_vars {}
    set ::solver::error {}
    foreach var $args {
        solve_var_direct $var $context
    }
    # Create the search loop
    set code {}
    foreach var $::solver::sweeped_vars {
        append code "scan $var \{\n"
    }
    append code [join $::solver::solution_steps \n]
    append code "\n"
    append code "set local_error 0\n"
    foreach var [array names ::solver::required] {
        append code "set local_error \[expr \$local_error+(\$::solver::required($var)-\$::$var)*(\$::solver::required($var)-\$::$var)\]\n"
    }
    append code "if \{\$::solver::error=={}\} \{set ::solver::error \$local_error ; solution \$::solver::error $args\}\n"
    append code "if \{\$::solver::error>\$local_error\} \{set ::solver::error \$local_error ; solution \$::solver::error $args\}\n"
#    append code "puts \"local_error=\$local_error a=\$::solver::a b=\$::solver::b c=\$::solver::c\"\n"
    foreach var $::solver::sweeped_vars {
        append code "\}\n"
    }
    set pre_unknown [info body unknown]
    set unknown {
        if {[regexp {\<} $args]} {
            puts $::solver::O $args
            return
        }
    }
    append unknown [info body ::unknown]
    proc ::unknown args $unknown
    set ::solver::O [open $report_file_name w]
    <html>
    <body>
    <h1>
    ::solver::report Solving $args
    </h1>
    set ::solver::line 1
    foreach step $::solver::solution_steps {
        uplevel $step
        incr ::solver::line
    }
    for {set ::deflation 1} {$::deflation<100} {incr ::deflation} {
        uplevel $code
	if {$::solver::error<1e-19} break
    }
    foreach var [array names ::solver::solution] {
        puts "$var= $::solver::solution($var)"
    }
    </body>
    </html>
    close $::solver::O
    proc unknown args $pre_unknown
}
proc ::solver::report {args} {
    puts $::solver::O $args
}

proc calc_expression {var expression} {
    ::solver::report $::solver::line Using $var=$expression
    set val [namespace eval ::solver [list expr $expression]]
    ::solver::report $var=$val
    set ::$var $val
    <br>
}
proc calc_default {var val} {
    ::solver::report $::solver::line Defaulting $var to $val
    set ::$var $val
    <br>
}
proc calc_provided {var val} {
    ::solver::report $::solver::line $var = $val (given)
    set ::$var $val
    <br>
}

proc cal_direct {var independent_vars LUT} {
    set inputs {}
    set coordinates {}
    foreach independent_var $independent_vars {
	set input $independent_var
	append input =
	append input [set ::solver::$independent_var]
	lappend coordinates [set ::solver::$independent_var]
	lappend inputs $input
    }
    set inputs [join $inputs ,]
    set ::$var [eval "array_interpolate $LUT $coordinates"]
    ::solver::report $::solver::line $var can be taken directly from a characterization lookup table ${var}($inputs) = [set ::$var]
    <br>
}
proc cal_rev {var independent_vars LUT} {
    set inputs {}
    set coordinates {}
    foreach independent_var $independent_vars {
	set input $independent_var
	append input =
	append input [set ::solver::$independent_var]
	lappend coordinates [set ::solver::$independent_var]
	lappend inputs $input
    }
    set inputs [join $inputs ,]
    set ::$var [eval "array_interpolate $LUT $coordinates"]
    ::solver::report $::solver::line $var can be taken directly from a characterization lookup table ${var}($inputs) = [set ::$var]
    <br>
}


### ::solver::link g {$b+$c}
### ::solver::link b {$c*$c+$a*3}
### ::solver::span a -10 10 0.001
### ::solver::span b -10 10 0.001
### ::solver::span c -10 10 0.001
### ::solver::require g {$a}
### 
### ::solver::calculate / test.rpt a b c g
