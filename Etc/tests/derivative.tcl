# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
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
    return [derive_polynomial $var $expression]
}
proc evaluate {args} {
    foreach varname $args {
        upvar $varname var_$varname
        if {![catch {set retval [expr [set var_$varname]]}]} {
            set var_$varname $retval
        }
    }
}
proc expr+ {X Y} {
    set retval "$X+$Y"
    evaluate X Y retval
    # Info: Merging $retval
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
    # Info: Merging $retval
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
    # Info: Merging $retval
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
    # Info: Merging $retval
}    
proc expr/ {X Y} {
    set retval "$X/$Y"
    evaluate X Y
    # Info: Merging $retval
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
    incr ::Gamma_expression_counter
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
proc synthesize_minterms {{expression {}}} {
    if {[llength $expression]<=1} {
        set expression [lindex $expression 0]
    }	
    if {[llength $expression]<=1} {
        return $expression
    }	
    set op [lindex $expression 0] 
    switch $op {
        + {
	    set pre [synthesize_minterms [lindex $expression 1]]
	    set post [synthesize_minterms [lindex $expression 2]]
	    return [concat $pre $post]
	}
        - {
	    if {[llength $expression]==2} {
	        set post [synthesize_minterms [lindex $expression 1]]
	        set final_list {}
	        foreach term_post $post {
	            lappend final_list "-1,$term_post"
	        }
	        return [lsort $final_list]
	    }
	    set pre [synthesize_minterms [lindex $expression 1]]
	    set post [synthesize_minterms [lindex $expression 2]]
	    set final_list $pre
	    foreach term_post $post {
	        lappend final_list "-1,$term_post"
	    }
	    return [lsort $final_list]
	}
	* {
	    set pre [synthesize_minterms [lindex $expression 1]]
	    set post [synthesize_minterms [lindex $expression 2]]
	    set final_list {}
	    foreach term_pre $pre {
	        foreach term_post $post {
		    set pre_list [lsort [split $term_pre ,] ]
		    set post_list [lsort [split $term_post ,] ]
		    lappend final_list [join [lsort [concat $pre_list $post_list]] ,]
		}
	    }
	    return [lsort $final_list]
	}
	default {
	    Error: Operation $op not yet supported
	    exit
	}
    }
}
proc simplify_minterms {up_term} {
    upvar $up_term derived_term
    foreach term [array names derived_term] {
        Info: [string repeat .... [info level]] $derived_term($term)*$term
    }
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
    Info: internal_term=$internal_term external_term=$external_term
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
    Info: internal_term=$internal_term external_term=$external_term
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
    foreach t [array names term] {
        Info: [string repeat .... [info level]] $term($t)*$t
    }
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
    foreach t [array names derived_term] {
        Info: [string repeat .... [info level]] $derived_term($t)*$t
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
    # Info: synthesize_expr $expression
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
    if {[llength $expression]<2} {
        # Info: Atom: $expression
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
proc derivative {var expression} {
    Info: Expression=$expression
    set analyzed [analyse_expr $expression]
    Info: analyzed=$analyzed
    Info: polynomial_derived=[derive_polynomial $var $analyzed]
    while {[llength $analyzed]==1} {
        set analyzed [lindex $analyzed 0]
    }
    set retval [derive_expr $var $analyzed]
    beatufy_expression retval
    return $retval
}
proc flat_expression {equation} {
    set PN [lindex [analyse_expr $equation] 0]
    regsub -all {\{([\-\+\*\/,])} $PN "\{expr\\1" PN
#    set PN [lindex $PN 0]
    regsub -all {\{} $PN "\[" PN
    regsub -all {\}} $PN "\]" PN
    Info: PN=$PN
    set equation [uplevel $PN]
    return $equation
}    
### set analyzed [lindex [analyse_expr (-1*(1*(-n_1:gm*(-p_2:gm*((n_1:go+n_1:gm+n_2:go+n_2:gm+n_sink:go)*((n_ref:go+n_ref:gm)*(-1*(1*(-1*inp:V)))))-(-n_2:go-n_2:gm)*(-(-n_1:go)*((n_ref:go+n_ref:gm)*(-1*(1*(-1*inp:V))))))+(p_1:go+p_1:gm+n_1:go)*(n_2:gm*((n_1:go+n_1:gm+n_2:go+n_2:gm+n_sink:go)*((n_ref:go+n_ref:gm)*(-1*(-inm:V*(-1)))))+(-n_2:Ideq+-p_2:Ideq)*((n_1:go+n_1:gm+n_2:go+n_2:gm+n_sink:go)*((n_ref:go+n_ref:gm)))-(-n_2:go-n_2:gm)*((-n_2:gm)*((n_ref:go+n_ref:gm)*(-1*(-inm:V*(-1))))-(-n_1:gm)*((n_ref:go+n_ref:gm)*(-1*(1*(-1*inp:V))))+(-n_sink:Ideq+n_2:Ideq+n_1:Ideq)*((n_ref:go+n_ref:gm))-n_sink:gm*((-n_ref:Ideq+100e-6)))-(-p_2:go-p_2:gm)*(-(n_1:go+n_1:gm+n_2:go+n_2:gm+n_sink:go)*(-(n_ref:go+n_ref:gm)*1.1)))-(-n_1:Ideq+-p_1:Ideq)*(p_2:gm*((n_1:go+n_1:gm+n_2:go+n_2:gm+n_sink:go)*((n_ref:go+n_ref:gm)))-(-n_2:go-n_2:gm)*((-n_1:go)*((n_ref:go+n_ref:gm))))+(-n_1:go-n_1:gm)*(n_2:gm*(-(-n_1:go)*((n_ref:go+n_ref:gm)*(-1*(-inm:V*(-1)))))+p_2:gm*((-n_2:gm)*((n_ref:go+n_ref:gm)*(-1*(-inm:V*(-1))))-(-n_1:gm)*((n_ref:go+n_ref:gm)*(-1*(1*(-1*inp:V))))+(-n_sink:Ideq+n_2:Ideq+n_1:Ideq)*((n_ref:go+n_ref:gm))-n_sink:gm*((-n_ref:Ideq+100e-6)))-(-n_2:Ideq+-p_2:Ideq)*((-n_1:go)*((n_ref:go+n_ref:gm)))-(-p_2:go-p_2:gm)*((-n_1:go)*(-(n_ref:go+n_ref:gm)*1.1)))+(-p_1:go-p_1:gm)*(p_2:gm*(-(n_1:go+n_1:gm+n_2:go+n_2:gm+n_sink:go)*(-(n_ref:go+n_ref:gm)*1.1))+(-n_2:go-n_2:gm)*((-n_1:go)*(-(n_ref:go+n_ref:gm)*1.1))))))] 0]
### #set analyzed [lindex [analyse_expr ((n_ref:go+n_ref:gm)*(-1*(1*(-1*inp:V))))] 0]
### set synthesized [synthesize_expr [lindex $analyzed 0]]
### while {[llength $analyzed]==1} {
###     set analyzed [lindex $analyzed 0]
### }
### set derived [derive_expr inp:V $analyzed]
### report_vars analyzed 
### report_vars synthesized 
### report_vars derived
#Info: derive_p=[derivative inp:V (-1*(1*(-n_1:gm*(-p_2:gm*((n_1:go+n_1:gm+n_2:go+n_2:gm+n_sink:go)*((n_ref:go+n_ref:gm)*(-1*(1*(-1*inp:V)))))-(-n_2:go-n_2:gm)*(-(-n_1:go)*((n_ref:go+n_ref:gm)*(-1*(1*(-1*inp:V))))))+(p_1:go+p_1:gm+n_1:go)*(n_2:gm*((n_1:go+n_1:gm+n_2:go+n_2:gm+n_sink:go)*((n_ref:go+n_ref:gm)*(-1*(-inm:V*(-1)))))+(-n_2:Ideq+-p_2:Ideq)*((n_1:go+n_1:gm+n_2:go+n_2:gm+n_sink:go)*((n_ref:go+n_ref:gm)))-(-n_2:go-n_2:gm)*((-n_2:gm)*((n_ref:go+n_ref:gm)*(-1*(-inm:V*(-1))))-(-n_1:gm)*((n_ref:go+n_ref:gm)*(-1*(1*(-1*inp:V))))+(-n_sink:Ideq+n_2:Ideq+n_1:Ideq)*((n_ref:go+n_ref:gm))-n_sink:gm*((-n_ref:Ideq+100e-6)))-(-p_2:go-p_2:gm)*(-(n_1:go+n_1:gm+n_2:go+n_2:gm+n_sink:go)*(-(n_ref:go+n_ref:gm)*1.1)))-(-n_1:Ideq+-p_1:Ideq)*(p_2:gm*((n_1:go+n_1:gm+n_2:go+n_2:gm+n_sink:go)*((n_ref:go+n_ref:gm)))-(-n_2:go-n_2:gm)*((-n_1:go)*((n_ref:go+n_ref:gm))))+(-n_1:go-n_1:gm)*(n_2:gm*(-(-n_1:go)*((n_ref:go+n_ref:gm)*(-1*(-inm:V*(-1)))))+p_2:gm*((-n_2:gm)*((n_ref:go+n_ref:gm)*(-1*(-inm:V*(-1))))-(-n_1:gm)*((n_ref:go+n_ref:gm)*(-1*(1*(-1*inp:V))))+(-n_sink:Ideq+n_2:Ideq+n_1:Ideq)*((n_ref:go+n_ref:gm))-n_sink:gm*((-n_ref:Ideq+100e-6)))-(-n_2:Ideq+-p_2:Ideq)*((-n_1:go)*((n_ref:go+n_ref:gm)))-(-p_2:go-p_2:gm)*((-n_1:go)*(-(n_ref:go+n_ref:gm)*1.1)))+(-p_1:go-p_1:gm)*(p_2:gm*(-(n_1:go+n_1:gm+n_2:go+n_2:gm+n_sink:go)*(-(n_ref:go+n_ref:gm)*1.1))+(-n_2:go-n_2:gm)*((-n_1:go)*(-(n_ref:go+n_ref:gm)*1.1))))))]
#Info: derive_n=[derivative inm:V (-1*(1*(-n_1:gm*(-p_2:gm*((n_1:go+n_1:gm+n_2:go+n_2:gm+n_sink:go)*((n_ref:go+n_ref:gm)*(-1*(1*(-1*inp:V)))))-(-n_2:go-n_2:gm)*(-(-n_1:go)*((n_ref:go+n_ref:gm)*(-1*(1*(-1*inp:V))))))+(p_1:go+p_1:gm+n_1:go)*(n_2:gm*((n_1:go+n_1:gm+n_2:go+n_2:gm+n_sink:go)*((n_ref:go+n_ref:gm)*(-1*(-inm:V*(-1)))))+(-n_2:Ideq+-p_2:Ideq)*((n_1:go+n_1:gm+n_2:go+n_2:gm+n_sink:go)*((n_ref:go+n_ref:gm)))-(-n_2:go-n_2:gm)*((-n_2:gm)*((n_ref:go+n_ref:gm)*(-1*(-inm:V*(-1))))-(-n_1:gm)*((n_ref:go+n_ref:gm)*(-1*(1*(-1*inp:V))))+(-n_sink:Ideq+n_2:Ideq+n_1:Ideq)*((n_ref:go+n_ref:gm))-n_sink:gm*((-n_ref:Ideq+100e-6)))-(-p_2:go-p_2:gm)*(-(n_1:go+n_1:gm+n_2:go+n_2:gm+n_sink:go)*(-(n_ref:go+n_ref:gm)*1.1)))-(-n_1:Ideq+-p_1:Ideq)*(p_2:gm*((n_1:go+n_1:gm+n_2:go+n_2:gm+n_sink:go)*((n_ref:go+n_ref:gm)))-(-n_2:go-n_2:gm)*((-n_1:go)*((n_ref:go+n_ref:gm))))+(-n_1:go-n_1:gm)*(n_2:gm*(-(-n_1:go)*((n_ref:go+n_ref:gm)*(-1*(-inm:V*(-1)))))+p_2:gm*((-n_2:gm)*((n_ref:go+n_ref:gm)*(-1*(-inm:V*(-1))))-(-n_1:gm)*((n_ref:go+n_ref:gm)*(-1*(1*(-1*inp:V))))+(-n_sink:Ideq+n_2:Ideq+n_1:Ideq)*((n_ref:go+n_ref:gm))-n_sink:gm*((-n_ref:Ideq+100e-6)))-(-n_2:Ideq+-p_2:Ideq)*((-n_1:go)*((n_ref:go+n_ref:gm)))-(-p_2:go-p_2:gm)*((-n_1:go)*(-(n_ref:go+n_ref:gm)*1.1)))+(-p_1:go-p_1:gm)*(p_2:gm*(-(n_1:go+n_1:gm+n_2:go+n_2:gm+n_sink:go)*(-(n_ref:go+n_ref:gm)*1.1))+(-n_2:go-n_2:gm)*((-n_1:go)*(-(n_ref:go+n_ref:gm)*1.1))))))]
set outp derive((-1*(1*(-n_1:gm*(-p_2:gm*((n_1:go+n_1:gm+n_2:go+n_2:gm+n_sink:go)*((n_ref:go+n_ref:gm)*(-1*(1*(-1*inp:V)))))-(-n_2:go-n_2:gm)*(-(-n_1:go)*((n_ref:go+n_ref:gm)*(-1*(1*(-1*inp:V))))))+(p_1:go+p_1:gm+n_1:go)*(n_2:gm*((n_1:go+n_1:gm+n_2:go+n_2:gm+n_sink:go)*((n_ref:go+n_ref:gm)*(-1*(-inm:V*(-1)))))+(-n_2:Ideq+-p_2:Ideq)*((n_1:go+n_1:gm+n_2:go+n_2:gm+n_sink:go)*((n_ref:go+n_ref:gm)))-(-n_2:go-n_2:gm)*((-n_2:gm)*((n_ref:go+n_ref:gm)*(-1*(-inm:V*(-1))))-(-n_1:gm)*((n_ref:go+n_ref:gm)*(-1*(1*(-1*inp:V))))+(-n_sink:Ideq+n_2:Ideq+n_1:Ideq)*((n_ref:go+n_ref:gm))-n_sink:gm*((-n_ref:Ideq+100e-6)))-(-p_2:go-p_2:gm)*(-(n_1:go+n_1:gm+n_2:go+n_2:gm+n_sink:go)*(-(n_ref:go+n_ref:gm)*1.1)))-(-n_1:Ideq+-p_1:Ideq)*(p_2:gm*((n_1:go+n_1:gm+n_2:go+n_2:gm+n_sink:go)*((n_ref:go+n_ref:gm)))-(-n_2:go-n_2:gm)*((-n_1:go)*((n_ref:go+n_ref:gm))))+(-n_1:go-n_1:gm)*(n_2:gm*(-(-n_1:go)*((n_ref:go+n_ref:gm)*(-1*(-inm:V*(-1)))))+p_2:gm*((-n_2:gm)*((n_ref:go+n_ref:gm)*(-1*(-inm:V*(-1))))-(-n_1:gm)*((n_ref:go+n_ref:gm)*(-1*(1*(-1*inp:V))))+(-n_sink:Ideq+n_2:Ideq+n_1:Ideq)*((n_ref:go+n_ref:gm))-n_sink:gm*((-n_ref:Ideq+100e-6)))-(-n_2:Ideq+-p_2:Ideq)*((-n_1:go)*((n_ref:go+n_ref:gm)))-(-p_2:go-p_2:gm)*((-n_1:go)*(-(n_ref:go+n_ref:gm)*1.1)))+(-p_1:go-p_1:gm)*(p_2:gm*(-(n_1:go+n_1:gm+n_2:go+n_2:gm+n_sink:go)*(-(n_ref:go+n_ref:gm)*1.1))+(-n_2:go-n_2:gm)*((-n_1:go)*(-(n_ref:go+n_ref:gm)*Vdd)))))),Vdd)
Info: derive=[flat_expression $outp]
exit

