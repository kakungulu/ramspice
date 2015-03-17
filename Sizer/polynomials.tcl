proc synthesize_minterms {{expression {}}} {
#    Info: [.]SYNTH $expression
    if {[llength $expression]<=1} {
        set expression [lindex $expression 0]
    }	
    if {[llength $expression]==0} {
#	Info: [.]RET 0,
        return 0,
    }	
    if {[llength $expression]==1} {
        if {[llength [split $expression ,]]>1} {
#	    Info: [.]RET $expression
            return $expression
        }
        if {[catch {set val [expr $expression]}]} {
#	    Info: [.]RET 1,$expression
            return 1,$expression
        } else {
#	    Info: [.]RET $val,
            return $val,
        }
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
                    set const [lindex [split $term_post ,] 0]
                    set const [expr 0-$const]
                    lappend final_list [join [concat $const [lrange [split $term_post ,] 1 end]] ,]
                }
                return [lsort $final_list]
            }
            set pre [synthesize_minterms [lindex $expression 1]]
            set post [synthesize_minterms [lindex $expression 2]]
            set final_list $pre
            foreach term_post $post {
                set const [lindex [split $term_post ,] 0]
                set const [expr 0-$const]
                lappend final_list [join [concat $const [lrange [split $term_post ,] 1 end]] ,]
            }
            return [lsort $final_list]
        }
        * {
            set pre [synthesize_minterms [lindex $expression 1]]
            set post [synthesize_minterms [lindex $expression 2]]
            set final_list {}
            foreach term_pre $pre {
	        set pre_const [lindex [split $term_pre ,] 0]
		set pre_list [lsort [lrange [split $term_pre ,] 1 end]]
                foreach term_post $post {
	            set post_const [lindex [split $term_post ,] 0]
		    set post_list [lsort [lrange [split $term_post ,] 1 end]]
		    set const [expr $pre_const*$post_const]
                    lappend final_list [join [concat $const [lsort [concat $pre_list $post_list]]] ,]
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

array set ::POLY {}
proc calc {expression} {
    if {[catch {set retval [expr $expression]}]} {
        return $expression
    }
    return $retval
}
proc start_poly {name {expression {}}} {
    remove_poly $name
    set analysis [analyse_expr $expression]
#    Info: [.]analysis=$analysis
    if {[regexp {(\{|@)func\s} $analysis]} {
        Error@ Expression $expression contains a function, which cannot be analysed as polynomial.
        exit
    }
    if {[regexp {(\{|@)/\s} $analysis]} {
        Error@ Expression $expression contains a division, which cannot be analysed as polynomial.
        exit
    }
    set synthesis [synthesize_minterms $analysis]
#    Info: [.]synthesis=$synthesis
    foreach minterm $synthesis {
        set val [lindex [split $minterm ,] 0]
        set term [join [lrange [split $minterm ,] 1 end] ,]
        set ::POLY($name@$term) $val
    }
    dezero_poly $name
}

proc dezero_poly {p} {
    foreach key [array names ::POLY $p@*] {
        skip {$::POLY($key)!=0.0}
        array unset ::POLY $key
    }
}
proc remove_poly {name} {
    array unset ::POLY $name@*
}

proc add_poly {a b c} {
    remove_poly $c
    foreach a_minterm [array names ::POLY $a@*] {
        set minterm [lindex [split $a_minterm @] 1]
        set val $::POLY($a_minterm)
        if {[info exists ::POLY($b@$minterm)]} {
            set val [calc $val+$::POLY($b@$minterm)]
        }
        set ::POLY($c@$minterm) $val
    }
    foreach b_minterm [array names ::POLY $b@*] {
        set minterm [lindex [split $b_minterm @] 1]
        skip {[info exists ::POLY($a@$minterm)]} 
        set ::POLY($c@$minterm) $::POLY($b_minterm)
    }
    dezero_poly $c
} 
proc acc_poly {a b {factor 1.0}} {
    foreach a_minterm [array names ::POLY $a@*] {
        set minterm [lindex [split $a_minterm @] 1]
        set val $::POLY($a_minterm)
        if {[info exists ::POLY($b@$minterm)]} {
            set val [calc $val+$::POLY($b@$minterm)*$factor]
        }
        set ::POLY(result@$minterm) $val
    }
    foreach b_minterm [array names ::POLY $b@*] {
        set minterm [lindex [split $b_minterm @] 1]
        skip {[info exists ::POLY($a@$minterm)]} 
        set ::POLY(result@$minterm) [calc $::POLY($b_minterm)*$factor]
    }
    array unset ::POLY $a@*
    foreach result_minterm [array names ::POLY result@*] {
        set minterm [lindex [split $result_minterm @] 1]
        set ::POLY($a@$minterm) $::POLY($result_minterm)
    }
    array unset ::POLY result@*
    dezero_poly $a
} 
proc mult_poly {a b c} {
    remove_poly $c
    foreach a_minterm [array names ::POLY $a@*] {
        set a_term [lindex [split $a_minterm @] 1]
        foreach b_minterm [array names ::POLY $b@*] {
            set b_term [lindex [split $b_minterm @] 1]
            set c_term [join [lsort [concat [split $a_term ,] [split $b_term ,]]] ,]
            default ::POLY($c@$c_term) 0.0
            set ::POLY($c@$c_term) [calc $::POLY($c@$c_term)+$::POLY($a_minterm)*$::POLY($b_minterm)]
        }
    }
    dezero_poly $c
}

proc zero_poly {a} {
    if {[array names ::POLY $a@*]=="$a@"} {
        if {$::POLY($a@)==0} {
            return 1
        }
    }
    return 0
}
proc unit_poly {a} {
    if {[array names ::POLY $a@*]=="$a@"} {
        if {$::POLY($a@)==1.0} {
            return 1
        }
    }
    return 0
}
set ::temp_index 0
proc implement_analysis {analysis} {
    if {[llength $analysis]==1} {
        set analysis [lindex $analysis 0]
    }
    if {[llength $analysis]==1} {
        return $analysis
    }
    set op [lindex $analysis 0]
    set arguments [lrange $analysis 1 end]
    if {[lsearch {* +} $op]!=-1} {
        set arguments [lsort $arguments]
    }
    set args {}
    foreach arg $arguments {
        lappend args [implement_analysis $arg]
    }
    set key [join [concat $op $args] ,]
    if {[info exists ::CSE($key)]} {
        incr ::NEEDED($key) 
        return $::CSE($key)
    }
    incr ::temp_index
    if {[llength $args]==1} {
        set expression $op$args
    } else {
        set expression [join $args $op]
    }
    tmp$::temp_index=>$expression
#    Info: [.]tmp$::temp_index=$expression
    set ::CSE($key) tmp$::temp_index
    set ::NEEDED($key) 0
    return tmp$::temp_index
}
proc implement_analysis_post {analysis} {
    if {[llength $analysis]==1} {
        set analysis [lindex $analysis 0]
    }
    if {[llength $analysis]==1} {
        return $analysis
    }
    set op [lindex $analysis 0]
    set arguments [lrange $analysis 1 end]
    if {[lsearch {* +} $op]!=-1} {
        set arguments [lsort $arguments]
    }
    set args {}
    foreach arg $arguments {
        lappend args [implement_analysis_post $arg]
    }
    set key [join [concat $op $args] ,]
    if {[info exists ::NEEDED($key)]} {
        if {$::NEEDED($key)>0} {
            return $::CSE($key)
        }
    }
    if {[llength $args]==1} {
        set expression $op$args
    } else {
        set expression [join $args $op]
    }
    if {$op=="+"} {
        return ($expression)
    }
    if {$op=="-"} {
        return ($expression)
    }
    return $expression
}
proc present_poly {p {name {}}}  {
    set retval [expression_poly $p 1]
    regsub -all {\(\+} $retval "\(" retval
    set analysis [analyse_expr $retval]
    implement_analysis $analysis
    set analysis [implement_analysis_post $analysis]
    set synthesis [synthesize_minterms $analysis]
    remove_poly $p
    foreach minterm $synthesis {
        set val [lindex [split $minterm ,] 0]
        set term [join [lrange [split $minterm ,] 1 end] ,]
        set ::POLY($p@$term) $val
    }
    dezero_poly $p
    return [expression_poly $p 1]
}

# expression_poly takes a standardized polynomial and converts it back to hierarchical expression
proc expression_poly {p {first 1}} {
    if {[llength [array names ::POLY $p@*]]==1} {
        set expression [lindex [split [array names ::POLY $p@*] @] 1]
        set const $::POLY($p@$expression)
        if {$const==1.0} {
            if {$first} {
                return [join [split $expression ,] *]
            }
            return +[join [split $expression ,] *]
        }
        if {$const==-1.0} {
            return -[join [split $expression ,] *]
        }
        if {$first} {
            if {$const>0} {
                return [join [concat $const [split $expression ,]] *]
            }
        }
        if {$const>0} {
            return +[join [concat $const [split $expression ,]] *]
        }
        return [join [concat $const [split $expression ,]] *]
    }
    foreach p_minterm [lsort [array names ::POLY $p@*]] {
        array unset local
        set minterm [lindex [split $p_minterm @] 1]
        foreach var [lsort [split $minterm ,]] {
            default local($var) 0
            incr local($var)
            default count($var,$local($var)) 0
            incr count($var,$local($var))
        }
    }
    set max_var {}
    set max_cnt 0
    foreach var_key [array names count] {
        skip {$count($var_key)<$max_cnt}
        set varcnt [lindex [split $var_key ,] 1]
        set maxcnt [lindex [split $max_var ,] 1]
        skip {($count($var_key)==$max_cnt) && ($maxcnt<$varcnt)}
        set max_cnt $count($var_key)
        set max_var $var_key
    }
    if {$max_cnt<=1} {
        set first 1
        set retval {}
        foreach  p_minterm [lsort [array names ::POLY $p@*]] {
            array unset ::POLY result$p@*
            set minterm [lindex [split $p_minterm @] 1]
            set ::POLY(result$p@$minterm) $::POLY($p@$minterm)
            append retval [expression_poly result$p $first]
            set first 0
        }
        if {$first} {
            return $retval
        }   
        if {[regexp {^\-} $retval]} {
            return $retval
        }
        return +$retval
    }
    set varname [lindex [split $max_var ,] 0]
    set varcnt [lindex [split $max_var ,] 1]
    set var_pattern [join [string repeat " $varname" $varcnt] ,]
    foreach p_minterm [lsort [array names ::POLY $p@*]] {
        set minterm [lindex [split $p_minterm @] 1]
        if {[regexp $var_pattern $p_minterm]} {
            set final_key {} 
            set countdown $varcnt
            foreach var [lsort [split $minterm ,]] {
                if {($var!=$varname) || ($countdown==0)} {
                    lappend final_key $var
                    continue
                }
                incr countdown -1
            }
            set final_key [join $final_key ,]
            set ::POLY(in__$p@$final_key) $::POLY($p_minterm)
        } else {
            set ::POLY(out__$p@$minterm) $::POLY($p_minterm)
        }
    }
    if {[llength [array names ::POLY in__$p@*]]==1} {
        set invar [lindex [array get ::POLY in__$p@*] 0]
        set const $::POLY($invar)
        set var [lindex [split $invar @] 1]
        if {$const==0} {
        } elseif {$const==1.0} {
            if {$first} {
                set retval [join [lsort [concat [split $var_pattern ,] [split $var ,]]] *]
            } else {
                set retval +[join [lsort [concat [split $var_pattern ,] [split $var ,]]] *]
            }
        } elseif {$const==-1.0} {
            set retval -[join [lsort [concat [split $var_pattern ,] [split $var ,]]] *]
        } else {
            if {$const<0} {
                set retval $const*[join [lsort [concat [split $var_pattern ,] [split $var ,]]] *]
            } elseif {$first} {
                set retval $const*[join [lsort [concat [split $var_pattern ,] [split $var ,]]] *]
            } else {
                set retval +$const*[join [lsort [concat [split $var_pattern ,] [split $var ,]]] *]
            }
        }
    } else {
        if {$first} { 
            set retval {}
        } else {
            set retval +
        }
        append retval "[join [split $var_pattern ,] *]*\("
        append retval [expression_poly in__$p 1]
        append retval "\)"
    }
    if {$retval=={}} {
        append retval [expression_poly out__$p 1]
    } else {
        append retval [expression_poly out__$p 0]
    }
    return $retval
}


