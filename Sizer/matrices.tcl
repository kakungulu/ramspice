# \
exec $RAMSPICE/ramspice $0 $argv
get_opts

proc derive {var {expression {}}} {
    incr ::Gamma_expression_counter
    if {[regexp {^(.*[^A-Za-z0-9_]|)([A-Za-z0-9_]*)\(([^\(\)]*)\)(.*)$} $expression -> pre func arguments post]} {
	if {$func==""} {
	    set ::Gamma_deffered_expressions($::Gamma_expression_counter) "[derive $var $arguments]"
	} else {
	    set ::Gamma_deffered_expressions($::Gamma_expression_counter) "d_${func}($arguments)*([derive $var $arguments])"
	}
	set derivative [derive $var "$pre@\($::Gamma_expression_counter\)@$post"]
	regsub "@\\($::Gamma_expression_counter\\)@" $derivative $::Gamma_deffered_expressions($::Gamma_expression_counter) retval
	return $retval
    }
    foreach op ", x7c\\\\x7c x26\\x26 <= >= == != < > + - * /" {
        set pattern "^(.*)\\"
	append pattern $op
	append pattern "(.+)\$" 
        if {[regexp $pattern $expression -> pre post]} {
            if {$op=="*"} {
	        return "([derive $var $pre]*$post+$pre*[derive $var $post])"
	    }
            if {$op=="/"} {
	        return "([derive $var $pre]/$post-[derive $var $post]*$pre/($post*$post))"
	    }
	    return [derive $var $pre]$op[derive $var $post]
	}
    }
    if {[regexp {^@\(([0-9]+)\)@$} $expression -> counter]} {
        return $::Gamma_deffered_expressions($counter)
    }
    if {$expression==$var} {
        return 1.0
    } else {
        return 0.0
    }
}
    
}
proc inv {M_var N_var} {
    upvar $M_var M
    upvar $N_var N
    set N(dim) $M(dim)
    set global_det [det M]
    set factor 1.0
    for {set i 0} {$i<$M(dim)} {incr i} {
        for {set j 0} {$j<$M(dim)} {incr j} {
	    set factor [expr pow(-1,$i+$j)]
	    set det $factor*([detij M $i $j])/($global_det)
	    evaluate det
	    skip {$det==0}
	    set N($j,$i) $det
	}
    }
}
proc inv_no_det {M_var N_var} {
    upvar $M_var M
    upvar $N_var N
    set N(dim) $M(dim)
    set factor 1.0
    for {set i 0} {$i<$M(dim)} {incr i} {
        for {set j 0} {$j<$M(dim)} {incr j} {
	    set det $factor*([detij M $i $j])
	    evaluate det
	    set factor [expr -$factor]
	    skip {$det==0}
	    set N($j,$i) $det
	}
    }
}
proc mat_mult {M_var N_var O_var} {
    upvar $M_var M
    upvar $N_var N
    upvar $O_var O
    for {set i 0} {[array names M $i,*]!={}} {incr i} {
         for {set j 0} {[array names N *,$j]!={}} {incr j} {
	     set acc 0.0
	     for {set k 0} {[array names N $k,*]!={}} {incr k} {
	         skip {![info exists M($i,$k)]}
	         skip {![info exists N($k,$j)]}
		 set acc [expr $acc+$M($i,$k)*$N($k,$j)]
	     }
	     skip {$acc==0.0}
	     set O($i,$j) $acc
	 }
    }
    set O(dim) $M(dim)
}
proc mat_print {M_var } {
    upvar $M_var M
    Info: $M_var=
    for {set i 0} {$i<$M(dim)} {incr i} {
        for {set j 0} {$j<$M(dim)} {incr j} {
	    if {![info exists M($i,$j)]} {
	        puts -nonewline 0.0
	    } elseif {abs($M($i,$j))<1e-12} {
	        puts -nonewline 0.0
	    } else {
	        puts -nonewline $M($i,$j)
	    }
	    puts -nonewline "\t"
	}
        puts ""
    } 
}
proc transpose {M_var N_var} {
    upvar $M_var M
    upvar $N_var N
    set N(dim) $M(dim)
    foreach keyM [array names M *,*] {
        lassign [split $keyM ,] im jm
        set N($jm,$im) $M($keyM)
    }
    	   
}
proc pseudo_inv {M_var N_var} {
    upvar $M_var M
    upvar $N_var N
    transpose M Mt
    mat_print Mt
    mat_mult Mt M MtM
    mat_print MtM
    inv MtM MtMi
    mat_print MtMi
    mat_mult MtMi Mt N
}
proc deti {M i y} {
    return [det $M 0 {} $i $y]
}
proc DET {M_var {i -1} {y {}}} {
    regsub -all {([^\-\+\*/\(\)0-9\.][^\-\+\*/\(\)]*)} [det $M_var 0 {} $i $y] {@\1} line
    regsub -all {@+} $line @ line
    return $line
}
proc is_one {x} {
    if {[catch {set retval [expr $x==1]}]} {
        return 0
    }
    return $retval
}
proc is_minus_one {x} {
    if {[catch {set retval [expr $x==-1]}]} {
        return 0
    }
    return $retval
}
proc neg_expression {e} {
    if {![catch {set retval [expr 0-($e)]}]} {
        return $retval
    }
    if {[regexp {^\-(.*)$} $e -> minus_e]} {
         return $minus_e
    }
    return "-$e"
}
proc peel {varname} {
    upvar $varname e
    set cont 1
    while {$cont} {
        set cont 0
	if {[regexp {^(.*)\(\(([^\)]+)\)\)(.*)$} $e -> pre in post]} {
	    set cont 1
	    regsub -all {\-\-} "${pre}($in)$post" {} e
	} 
	if {[regexp {^(.*)\(\-\(([^\)]+)\)\)(.*)$} $e -> pre in post]} {
	    set cont 1
	    regsub -all {\-\-} [neg_expression "${pre}($in)$post"] {} e
	} 
    }
}
proc det {
    M_var 
    {row 0} 
    {ignore_columes {}} 
    {replace_column -1} 
    {replacement_column {}}
} {
    upvar $M_var M
    set dim $M(dim)
    if {$row==$dim} {
        return 1.0
    }
    set sign I
    set retval {}
    set next_row $row
    incr next_row
    if {$row==$dim} {
        return 1
    }
    for {set i 0} {$i<$dim} {incr i} {
        skip {[lsearch $ignore_columes $i]!=-1}
	switch $sign {
	    "-" {set sign +}
	    "+" {set sign -}
	    "I" {set sign {}}
	    {} {set sign -}
	}
	skip {![info exists M($row,$i)]&&$i!=$replace_column} 
	if {$i==$replace_column} {
	    set entry [lindex $replacement_column $row]
	} else {
	    set entry $M($row,$i)
	}
	skip {$entry==0} 
	set next_ignore_columes [concat $ignore_columes $i]
	set next_det [det M $next_row $next_ignore_columes $replace_column $replacement_column]
	skip {$next_det==0}
	regsub {^\++} $next_det {} next_det
	regsub {^\++} $entry {} entry
	if {[regexp {[\-\+]} $next_det]} {
	    set next_det "($next_det)"
	}
	if {[regexp {[\-\+]} $entry]} {
	    set entry "($entry)"
	}
	set this "$retval$sign$entry"
	if {[is_one $this]} {
	    if {[is_one $next_det]} {
	        set retval 1
	    } elseif {[is_minus_one $next_det]} {
	        set retval -1
	    } else {
	        set retval $next_det
	    }
	} elseif {[is_minus_one $this]} {
	    if {[is_one $next_det]} {
	        set retval -1
	    } elseif {[is_minus_one $next_det]} {
	        set retval 1
	    } else {
	        set retval [neg_expression $next_det]
	    }
	} else {
	    if {[is_one $next_det]} {
	        set retval "$retval$sign$entry"
	    } elseif {[is_minus_one $next_det]} {
	        set retval [neg_expression $retval$sign$entry]
	    } else {
	        set retval "$retval$sign$entry*$next_det"
	    }
	}
    }
    if {$retval=={}} {
        set retval 0
    }
    evaluate retval
    peel retval
    return $retval
}
proc detij {
    M_var 
    ignore_row 
    ignore_column
} {
    upvar $M_var M
    foreach key [array names M *,*] {
        lassign [split $key ,] i j
	skip {$i==$ignore_row}
	skip {$j==$ignore_column}
	if {$i>$ignore_row} {
	    incr i -1
	}
	if {$j>$ignore_column} {
	    incr j -1
	}
	set N($i,$j) $M($key)
    }
    set N(dim) $M(dim)
    incr N(dim) -1
    return [det N]
}
set ::p_index 0
proc detp {
    M_var 
    p
    {row 0} 
    {ignore_columes {}} 
    {replace_column -1} 
    {replacement_column {}}
} {
    upvar $M_var M
    set dim $M(dim)
    if {$row==$dim} {
        set ::POLY::${p}({}) 1.0
        return
    }
    start_poly $p 
    set next_row $row
    incr next_row
    set factor -1
    for {set i 0} {$i<$dim} {incr i} {
        skip {[lsearch $ignore_columes $i]!=-1}
	set factor [expr 0-$factor]
	skip {![info exists M($row,$i)]&&$i!=$replace_column} 
	if {$i==$replace_column} {
	    set entry [lindex $replacement_column $row]
	} else {
	    set entry $M($row,$i)
	}
	skip {$entry==0} 
	set next_ignore_columes [concat $ignore_columes $i]
	incr ::p_index
	set next_p ${p}_$::p_index
	detp M $next_p $next_row $next_ignore_columes $replace_column $replacement_column
	if {[zero_poly $next_p]} {
	    remove_poly $next_p
	    continue
	}
	start_poly entry $entry
	mult_poly entry $next_p m
	acc_poly $p m $factor
	remove_poly $next_p
    }
}
proc Ax_y {A_var x_var y} {
    upvar $A_var A
    upvar $x_var x
    if {![info exists A(dim)]} {
        set A(dim) [llength $y]
    } 
    set det [det A]
    set x {}
    for {set i 0} {$i<$A(dim)} {incr i} {
        set det_i [deti A $i $y]
        set x_i "($det_i)/($det)"
	evaluate x_i
	lappend x $x_i
    }
}




