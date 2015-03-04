# \
exec $RAMSPICE/ramspice $0 $argv
get_opts

proc evaluate {varname} {
    upvar $varname var
    if {[catch {set val [expr $var]}]} {
        return 
    }
    set var $val 
}
proc deti {M i y} {
    return [det $M 0 {} $i $y]
}
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
        return 1.0
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
#	Info: ${M_var}($row,$i)=$entry
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
	if {$next_det==1.0} {
	    set retval "$retval$sign$entry"
	} else {
	    set retval "$retval$sign$entry*$next_det"
	}
    }
    if {$retval=={}} {
        set retval 0
    }
    evaluate retval
    return $retval
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




