proc expr, {left right} {
    return [concat $left $right]
}
namespace eval func {}
proc func {name arguments} {
    if {[info procs ::func::$name]=={}} {
        return "${name}($arguments)"
    } else {
        uplevel [list namespace eval func [concat $name [split $arguments ,]]]
    }
} 
proc ::func::derive {expression var} {
    if {[array names ::POLY::$expression]!={}} {
        Info: $expression has a corresponding polynomial
        derive_poly $expression $var dpoly
        return [present_poly dpoly $expression]
    }
    return [derive_expression $var $expression]
}
proc flat_expression {equation} {
    set PN [lindex [analyse_expr $equation] 0]
    regsub -all {(^|\{)([\-\+\*\/,])} $PN "\\1expr\\2" PN
    #    set PN [lindex $PN 0]
    regsub -all {\{} $PN "\[" PN
    regsub -all {\}} $PN "\]" PN
    set equation [uplevel $PN]
    return $equation
}    

proc expr+ {X Y} {
    set retval "$X+$Y"
    evaluate X Y retval
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
    evaluate X Y retval
    if {$X==0} {
        return 0
    }
    if {$Y==0} {
        return 0
    }
    if {$X==1} {
        return $Y
    }
    if {$Y==1} {
        return $X
    }
    if {$Y==-1} {
        set retval "(-$X)"
        evaluate retval
        return $retval
    }
    if {$X==-1} {
        set retval "(-$Y)"
        evaluate retval
        return $retval
    }
    if {[regexp {^\(\-(.*)\)$} $X -> inx] && [regexp {^\(\-(.*)\)$} $Y -> iny]} {
        evaluate inx iny
        set retval "$inx*$iny"
        evaluate retval
        return $retval
    }
    return $retval
}
proc expr- {X {Y {}}} {
    set retval "$X-$Y"
    if {$Y=={}} {
        set retval "-$X"
    }
    evaluate X Y retval
    if {$X==$Y} {
        return 0
    }
    if {$Y==0} {
        return $X
    }
    if {$X==0} {
        if {$Y=={}} {
            return 0
        }
        return "(-$Y)"
    }
    return "($retval)"
}
proc expr, {X Y} {
    return "$X,$Y"
}    
proc expr/ {X Y} {
    set retval "$X/$Y"
    evaluate X Y
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
    #Info: [.] Analyzing $expression
    incr ::Gamma_expression_counter
    # Protect negative constants
    while {[regexp {^(.*)([\*\/\+\-])(\-[0-9]+\.?[0-9]*e?[\+\-]?[0-9]*)(.*)$} $expression -> pre op const post]} {
        set counter $::Gamma_expression_counter
        set ::Gamma_deffered_expressions($counter) $const
        incr ::Gamma_expression_counter
        set expression "$pre$op@<$counter>@$post"
    }
    while {[regexp {^(.*[^0-9])([0-9]+\.?[0-9]*e[\+\-]?[0-9]+)(.*)$} $expression -> pre const post]} {
        set counter $::Gamma_expression_counter
        set ::Gamma_deffered_expressions($counter) $const
        incr ::Gamma_expression_counter
        set expression "$pre@<$counter>@$post"
    }
    if {[regexp {^(.*[^A-Za-z0-9_]|)([A-Za-z0-9_]*)\(([^\(\)]*)\)(.*)$} $expression -> pre func arguments post]} {
        set counter $::Gamma_expression_counter
        if {$func==""} {
            set ::Gamma_deffered_expressions($counter) "[analyse_expr $arguments]"
        } else {
            set ::Gamma_deffered_expressions($counter) "\{func $func [analyse_expr $arguments]\}"
        }
        set analysis [analyse_expr "$pre@<$counter>@$post"]
        regsub -all "@\\<$counter\\>@" $analysis $::Gamma_deffered_expressions($counter) retval
        #Info: [.] Analysis $retval
        return $retval
    }
    foreach op ", + - * /" {
        set pattern "^(.*)\\"
        append pattern $op
        append pattern "(.+)\$" 
        if {[regexp $pattern $expression -> pre post]} {
            set retval "\{$op [analyse_expr $pre] [analyse_expr $post]\}"
            #Info: [.] Analysis $retval
            return $retval
        }
    }
    if {[regexp {^@<([0-9]+)>@$} $expression -> counter]} {
        #Info: [.] Analysis ::Gamma_deffered_expressions($counter)
        return $::Gamma_deffered_expressions($counter)
    }
    #Info: [.] Analysis $expression
    return $expression
}
proc simplify_minterms {up_term} {
    upvar $up_term derived_term
    if {[array size derived_term]==0} {
        return 0
    }
    if {[array size derived_term]==1} {
        set term [lindex [array names derived_term] 0]
        set factor $derived_term($term)
        if {$term=={}} {
            return $factor
        }
        if {$factor==1} {
            return $term
        }
        if {$factor==-1} {
            return -$term
        }
        return "$factor*$term"
    }
    foreach key [array names derived_term] {
        foreach multiplier [split $key ,] {
            default hist($multiplier) 0
            incr hist($multiplier)
        }
    }
    set most_common {}
    set most_common_appearance 0
    foreach multiplier [array names hist] {
        skip {$hist($multiplier)<=$most_common_appearance} 
        set most_common_appearance $hist($multiplier)
        set most_common $multiplier
    }
    foreach key [array names derived_term] {
        set rank 0
        set final_key {}
        foreach multiplier [split $key ,] {
            if {$multiplier!=$most_common} {
                lappend final_key $multiplier
                continue
            }
            if {$rank} {
                lappend final_key $multiplier
            }
            incr rank
        }
        set final_key [join $final_key ,]
        if {$rank} {
            set in($final_key) $derived_term($key)
        } else {
            set out($final_key) $derived_term($key)
        }
    }
    set internal_term [simplify_minterms in]
    set external_term [simplify_minterms out]
    if {![catch {set external_factor [expr $external_term]}]} {
        if {$external_factor==0} {
            set external_term ""
        } elseif {$external_factor<0} {
            set external_factor [expr 0-$external_factor]
            set external_term "-$external_factor"
        } else {
            set external_term "+$external_factor"
        }    
    } else {
        set external_term "+$external_term"
    }
    if {![catch {set internal_factor [expr $internal_term]}]} {
        if {$internal_factor==0} {
            return $external_term
        } 
        if {$internal_factor==1} {
            return $most_common$external_term
        } 
        if {$internal_factor==-1} {
            return -$most_common$external_term
        } 
        if {$internal_factor<0} {
            set internal_factor [expr 0-$internal_factor]
            return "-$internal_factor*$most_common$external_term"
        } 
        return "+$internal_factor*$most_common$external_term"
    } 
    return "$most_common*($internal_term)$external_term"
}
proc derive_polynomial {var {expression {}}} {
    array unset term
    foreach minterm [synthesize_minterms [analyse_expr $expression]] {
        set factor 1
        set final_minterm {}
        foreach multiplier [split $minterm ,] {
            if {![catch {set next_factor [expr $factor*$multiplier]}]} {
                set factor $next_factor
            } else {
                lappend final_minterm $multiplier
            }
        }
        set key [join [lsort $final_minterm] ,]
        default term($key) 0
        set term($key) [expr $factor+$term($key)]
    }
    set retval {}
    #    foreach t [array names term] {
    #    }
    foreach key [array names term] {
        set rank 0
        set final_minterm {}
        foreach multiplier [split $key ,] {
            if {$multiplier!=$var} {
                lappend final_minterm $multiplier
                continue
            }	
            if {$rank} {
                lappend final_minterm $multiplier
            }
            incr rank
        }
        skip {$rank==0}
        set factor [expr $rank*$term($key)]
        skip {$factor==0}
        set final_key [join $final_minterm ,]
        set derived_term($final_key) $factor
    }
    regsub -all {\(\+} [simplify_minterms derived_term] "(" retval
    regsub -all {\+\-} $retval "-" retval
    return $retval 
    
}
proc synthesize_expr {{expression {}}} {
    if {[llength $expression]<=1} {
        set expression [lindex $expression 0]
    }	
    if {[llength $expression]<=1} {
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
    if {[llength $expression]==1} {
        set expression [lindex $expression 0]
    }
    if {$expression=={}} {
        return {}
    } 
    Dinfo: expression=$expression [array names ::DEF]
    if {[llength $expression]==1} {
        regsub -all {^@+} $expression @ expression
        if {$expression==$var} {
            return 1
        } 
        default ::DERMODE first
        if {[array names ::sensitivity $expression,*]!={}} {
            if {[info exists ::sensitivity($expression,$var)]} {
                Info: $expression has predefined derivative
                return $::sensitivity($expression,$var)
            }
            if {[info exists ::DER($expression,*,$::DERMODE)]} {
                Info: $expression has predefined derivative
                return $::DER($expression,*,$::DERMODE)
            }
            return 0
        }
        if {[info exists ::DEF($expression)]} {
            Info: $expression is dependent on $::DEF($expression)
            return [derive_expr $var [analyse_expr $::DEF($expression)]]
        }
        if {[info exists ::DEF(@$expression)]} {
            Info: $expression is dependent on $::DEF(@$expression)
            return [derive_expr $var [analyse_expr $::DEF(@$expression)]]
        }
        return 0
    }	
    set op [lindex $expression 0] 
    # Info: op=$op
    switch $op {
        func {
            set func [lindex $expression 1]
            set arguments [synthesize_expr [lindex $expression 2]]
            set derivative [derive_expr $var  [lindex $expression 2]]
            if {[info procs d_${func}]==""} {
                return "d_${func}($arguments)*($derivative)"
            }
            return [uplevel [concat d_${func} $var [split $arguments ,]]]
        }
        "*" {
            set pre [synthesize_expr [lindex $expression 1]]
            set post [synthesize_expr [lindex $expression 2]]
            set dpre [derive_expr $var  [lindex $expression 1]]
            set dpost [derive_expr $var  [lindex $expression 2]]
            return "[expr+ [expr* $pre $dpost] [expr* $dpre $post]]"
        }
        "/" {
            set pre [synthesize_expr [lindex $expression 1]]
            set post [synthesize_expr [lindex $expression 2]]
            set dpre [derive_expr $var  [lindex $expression 1]]
            set dpost [derive_expr $var  [lindex $expression 2]]
            return "[expr- [expr* $dpre $post] [expr* [expr/ $pre [expr* $post $post]] $dpost]]"
        }
        default {
            set pre [derive_expr $var  [lindex $expression 1]]
            set post [derive_expr $var  [lindex $expression 2]]
            return "[expr$op $pre $post]"
        }
    }
}
proc beatufy_expression {varname} {

    upvar $varname var
    set continue 1
    while {$continue} {
        set continue 0
        while {[regexp {^(.*)\(\(([^\)]*)\)\)(.*)$} $var -> pre in post]} {
            set var "${pre}($in)${post}"
            set continue 1
        }
        while {[regexp {^(.*)\-\(\-([^\)]*)\)(.*)$} $var -> pre in post]} {
            set var "${pre}($in)${post}"
            set continue 1
        }
        while {[regexp {^(.*)\(\(([^\)]*)([\+\-])([^\)\+\-\*\/]*)\)([\+\-])([^\)\+\-\*\/]*)\)(.*)$} $var -> pre in1 op1 in2 op2 in3 post]} {
            set var "${pre}($in1$op1$in2$op2$in3)${post}"
            set continue 1
        }
        
    }
    
}
proc derive_expression {var expression} {
    for {set i 1} {$i<=[info level]} {incr i} {
        Info: ($i) [info level $i]
    }
    set analyzed [analyse_expr $expression]
    if {[llength $analyzed]==1} {
        set analyzed [lindex $analyzed 0]
    }
    set retval [derive_expr $var $analyzed]
#    beatufy_expression retval
    return $retval
}
proc define_derivative {name var mode value} {
    set ::DER($name,$var,$mode) $value
}

proc d_limit {var expression low_limit high_limit} {
    set derived_expression [derive_expr $var $expression]
    return "d_limit($derived_expression,$low_limit,$high_limit)"
}
proc d_limit {var expression low_limit high_limit} {
    return [derive_expr $var $expression]
}

