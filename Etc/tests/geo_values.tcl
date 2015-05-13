set w_values {
7.33333333333333E-007 1.00E-005 0.00015 0.0003066667 0.00045 0.000525 0.0005625 0.0006033333 0.00064 0.000675  0.00075 0.000825 0.0008425 9.00E-004	
}
set l_values {
1.80E-007	2.86666666666667E-007	3.4e-7 3.93333333333333E-007 5e-7
6.30E-007	8.33333333333333E-007	9.66666666666667E-007
1.20E-006	2.2e-6   4.13333333333333E-006	7.06666666666667E-006
1.00E-005	1.66666666666667E-005
2.00E-005		
}

foreach dim {l w} {
    set values {}
    foreach {key value} [array get ::bin n,*,$dim*] {
        if {[lsearch $values $value]!=-1} continue
        lappend values $value
    }
    set values [lsort -real $values]
    set ${dim}_values {}
    for {set i 0} {$i<[llength $values]-1} {incr i} {
        set this [lindex $values $i]
        set next [lindex $values [expr $i+1]]
	if {$i<[llength $values]-2} {
            lappend ${dim}_values $this
            lappend ${dim}_values [expr $this+($next-$this)*1/3]
            lappend ${dim}_values [expr $this+($next-$this)*2/3]
	} else {
            lappend ${dim}_values $this
            lappend ${dim}_values [expr $this+($next-$this)*1/4]
            lappend ${dim}_values [expr $this+($next-$this)*2/4]
            lappend ${dim}_values [expr $this+($next-$this)*3/4]
            lappend ${dim}_values [expr $this+($next-$this)*4/4]
          #  lappend ${dim}_values $next
	}
    }
}
Info: l_values=$l_values 
Info: w_values=$w_values

