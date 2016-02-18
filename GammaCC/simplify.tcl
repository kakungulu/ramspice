proc s_to_iw {expr varReal varImag {top 1}} {
    upvar $varReal Real
    upvar $varImag Imag
    if {[llength $expr]==1} {
        if {$expr=="s"} {
	 #  Info: Atom 0 W [info level]
	    set Real 0
	    set Imag W
	    return 
	}
	# Info: Atom $expr 0 [info level]
	set Real $expr
	set Imag 0
	return 
    }
   # Info: EXPR $expr
    set op [lindex $expr 0]
    set L [lindex $expr 1]
    set R [lindex $expr 2]
    s_to_iw $L Lr Li 0
    s_to_iw $R Rr Ri 0
    switch $op {
        - {
	    set Real [simple- $Lr $Rr]
	    set Imag [simple- $Li $Ri]
	}
	+ {
	    set Real [simple+ $Lr $Rr]
	    set Imag [simple+ $Li $Ri]
	}
	* {
	    set Real [simple- [simple* $Lr $Rr] [simple* $Li $Ri]]
	    set Imag [simple+ [simple* $Lr $Ri] [simple* $Li $Rr]]
	}
	default {
	    Error: Operator $op not supported!
	    exit
	}
    }
    return
    Error: Can't s_to_iw $expr
    exit
}


proc eval_diff {term} {
    if {![string match *$::wrt* $term]} {
        return 0
    }
    if {[llength $term]==1} {
	if {$term==$::wrt} {
	    return 1
	}
	return 0    
    }
    set op [lindex $term 0]
    set L [lindex $term 1]
    set R [lindex $term 2]
    switch $op {
        + {
	    return [list + [eval_diff $L]  [eval_diff $R]]
	}
        - {
	    return [list - [eval_diff $L]  [eval_diff $R]]
	}
        * {
	    return [list + [list * [eval_diff $L]  $R] [list * $L  [eval_diff $R]]]
	}
    }
}
proc eval_expr {term} {
    lassign $term op a b
    Info: op=$op a=$a b=$b
    return [simple$op $a $b]
}
proc simple* {a b} {
    if {[llength $a]!=1} {
        lassign $a op L R
	set a [simple$op $L $R] 
    } 
    if {[llength $b]!=1} {
        lassign $b op L R
	set b [simple$op $L $R] 
    } 
    if {![catch {set res_a [expr $a]}]} {
        set a $res_a
    }
    if {![catch {set res_b [expr $b]}]} {
        set b $res_b
    }
    if {![catch {set res [expr $a*$b]}]} {
        return $res
    }
    if {$a==0} {
    	return 0
    }
    if {$a==1} {
        if {[regexp {[\-\+]} $b]} {
	    set b "($b)"
        }
    	return $b
    }
    if {$a==-1} {
    	return [simple- 0 $b]
    }
    if {$b==0} {
    	return 0
    }
    if {$b==1} {
        if {[regexp {[\-\+]} $a]} {
	    set a "($a)"
        }
    	return $a
    }
    if {$b==-1} {
    	return [simple- 0 $a]
    }
    if {[regexp {[\-\+]} $a]} {
	set a "($a)"
    }
    if {[regexp {[\-\+]} $b]} {
	set b "($b)"
    }
    return "$a*$b"
}
proc simple+ {a b} {
    if {[llength $a]!=1} {
        lassign $a op L R
	set a [simple$op $L $R] 
    } 
    if {[llength $b]!=1} {
        lassign $b op L R
	set b [simple$op $L $R] 
    } 
    if {![catch {set res_a [expr $a]}]} {
        set a $res_a
    }
    if {![catch {set res_b [expr $b]}]} {
        set b $res_b
    }
    if {![catch {set res [expr $a+$b]}]} {
        return $res
    }
    if {$a=="0"} {
        return $b
    }
    if {$b=="0"} {
        return $a
    }	
    if {$a==0} {
        return $b
    }
    if {$b==0} {
        return $a
    }	
    return "$a+$b"
}
proc simple- {a b} {
    if {[llength $a]!=1} {
        lassign $a op L R
	set a [simple$op $L $R] 
    } 
    if {[llength $b]!=1} {
        lassign $b op L R
	set b [simple$op $L $R] 
    } 
    if {![catch {set res_a [expr $a]}]} {
        set a $res_a
    }
    if {![catch {set res_b [expr $b]}]} {
        set b $res_b
    }
    Info: a=$a b=$b
    if {![catch {set res [expr $a-$b]}]} {
        return $res
    }
    if {$a==0} {
        if {$b==0} {
	    return 0
	}
	if {![catch {set n [expr -$b]}]} {
	    return $n
	}
	if {[regexp {[\-\+]} $b]} {
	    set b "($b)"
	}
	return -$b
    }
    if {$b==0} {
        return $a
    }	
    return "$a-$b"
}
proc simplify {expr} {
    if {[llength $expr]==1} {
        set expr [lindex $expr 0]
    }
    Info: 1 Simplifying $expr
    set expr [eval_expr $expr]
    Info: 2 Simplifying $expr
    regsub -all {\+\-} $expr {-} expr
    Info: 3 Simplifying $expr
    regsub -all {\-\+} $expr {-} expr
    Info: 4 Simplifying $expr
    regsub -all {\-\-} $expr {+} expr
    Info: 5 Simplifying $expr
    regsub -all {\+}   $expr {+} expr
    Info: 6 Simplifying $expr
    return $expr
}
