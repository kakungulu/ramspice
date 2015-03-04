# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
set ::Gamma_expression_counter 10
proc expr+ {X Y} {
    set retval "$X+$Y"
    if {![catch {expr $X==0}]} {
        if {$X==0} {
	    set retval $Y
	}
    }
    if {![catch {expr $Y==0}]} {
        if {$Y==0} {
	    set retval $X
	}
    }
    if {$X==$Y} {
        set retval "2*$X"
    }
    if {![catch {expr $retval}]} {
        set retval [expr $retval]
    }
    return "($retval)"
}
proc expr* {X Y} {
    set retval "$X*$Y"
    Info: Assembling $X*$Y
    if {![catch {expr $X==1}]} {
        if {$X==1} {
	    set retval $Y
	}
        if {$X==0} {
	    return 0
	}
    }
    if {![catch {expr $Y==1}]} {
        if {$Y==0} {
	    return 0
	}
        if {$Y==1} {
	    set retval $X
	} else {
	    set retval "$Y*$X"
	}
    }
    if {![catch {expr $retval}]} {
        set retval [expr $retval]
    }
    return $retval
}
proc expr- {X Y} {
    set retval "$X-$Y"
    if {$X==$Y} {
        return 0
    }
    if {![catch {expr $X==0}]} {
        if {$X==0} {
	    set retval "(-$Y)"
	}
    }
    if {![catch {expr $Y==0}]} {
        if {$Y==0} {
	    set retval $X
	}
    }
    if {![catch {expr $retval}]} {
        set retval [expr $retval]
    }
    return "($retval)"
}
proc expr, {X Y} {
    return "$X,$Y"
}    
proc expr/ {X Y} {
    set retval "$X/$Y"
    if {$X==$Y} {
        return 0
    }
    if {![catch {expr $X==0}]} {
        if {$X==0} {
	    set retval 0
	}
    }
    if {![catch {expr $Y==1}]} {
        if {$Y==1} {
	    set retval $X
	}
    }
    if {![catch {expr $retval}]} {
        set retval [expr $retval]
    }
    return $retval
}
proc analyse_expr {{expression {}}} {
    Info: Deriving $expression
    incr ::Gamma_expression_counter
    if {[regexp {^(.*[^A-Za-z0-9_]|)([A-Za-z0-9_]*)\(([^\(\)]*)\)(.*)$} $expression -> pre func arguments post]} {
        set counter $::Gamma_expression_counter
	if {$func==""} {
	    set ::Gamma_deffered_expressions($counter) "\{[analyse_expr $arguments]\}"
	} else {
	    set ::Gamma_deffered_expressions($counter) "\{func $func [analyse_expr $arguments]\}"
	}
	set analysis [analyse_expr "$pre@<$counter>@$post"]
	regsub -all "@\\<$counter\\>@" $analysis $::Gamma_deffered_expressions($counter) retval
	return $retval
    }
    foreach op ", + - * /" {
        set pattern "^(.*)\\"
	append pattern $op
	append pattern "(.+)\$" 
        if {[regexp $pattern $expression -> pre post]} {
	    return "\{$op [analyse_expr $pre] [analyse_expr $post]\}"
	}
    }
    if {[regexp {^@<([0-9]+)>@$} $expression -> counter]} {
        return $::Gamma_deffered_expressions($counter)
    }
    return $expression
}
proc synthesize_expr {{expression {}}} {
    if {[llength $expression]<2} {
        return $expression
    }	
    set op [lindex $expression 0] 
    switch $op {
        func {
	    set func [lindex $expression 1]
	    set arguments [synthesize_expr [lindex $expression 2]]
	    return "${func}($arguments)"
	}
	default {
	    set pre [synthesize_expr [lindex $expression 1]]
	    set post [synthesize_expr [lindex $expression 2]]
	    return "[expr$op $pre $post]"
	}
    }
}
proc derive_expr {var expression} {
    if {[llength $expression]<2} {
        if {$expression==$var} {
	    return 1
	} 
	if {$expression=={}} {
	    return {}
	} 
	if {[string match */* $expression]} {
	    if {[file dirname $expression]==[file dirname $var]} {
	        return "[file dirname $expression]/d_[file tail $expression]"
	    } 
	}
        return 0
    }	
    set op [lindex $expression 0] 
    switch $op {
        func {
	    set func [lindex $expression 1]
	    set arguments [synthesize_expr [lindex $expression 2]]
	    set derivative [derive_expr $var  [lindex $expression 2]]
	    return "d_${func}($arguments)*($derivative)"
	}
	* {
	    set pre [synthesize_expr [lindex $expression 1]]
	    set post [synthesize_expr [lindex $expression 2]]
	    set dpre [derive_expr $var  [lindex $expression 1]]
	    set dpost [derive_expr $var  [lindex $expression 2]]
	    return "[expr+ [expr* $pre $dpost] [expr* $dpre $post]]"
	}
	/ {
	    set pre [synthesize_expr [lindex $expression 1]]
	    set post [synthesize_expr [lindex $expression 2]]
	    set dpre [derive_expr $var  [lindex $expression 1]]
	    set dpost [derive_expr $var  [lindex $expression 2]]
	    return "[expr- [expr* $dpre $post] [expr* [expr/ $pre [expr* $post $post]] $dpost]"
	}
	default {
	    set pre [derive_expr $var  [lindex $expression 1]]
	    set post [derive_expr $var  [lindex $expression 2]]
	    return "[expr$op $pre $post]"
	}
    }
}
set analyzed [lindex [analyse_expr {log(V\X+V\Y+3*log(V\X*V\X*2))}] 0]
set synthesized [synthesize_expr $analyzed]
set derived [derive_expr V\X $analyzed]
report_vars analyzed synthesized derived
exit

