@ /old/array(3,3) !
@ /old cd
for {set i 0} {$i<3} {incr i} {
   for {set j 0} {$j<3} {incr j} {
       @ array($i,$j) = [expr rand()]
   }
}
for {set i 0} {$i<3} {incr i} {
   for {set j 0} {$j<3} {incr j} {
       puts "$i $j [@  array($i,$j)]"
   }
}

@ /old save test.db
@ /new !
@ /new cd
@ . load test.db
@ old cd
for {set i 0} {$i<3} {incr i} {
   for {set j 0} {$j<3} {incr j} {
       puts "$i $j [@  array($i,$j)]"
   }
}

proc tree {c} {
    puts -nonewline [string repeat "    " [info level]]
    puts $c
    @ $c foreach_child d {
       tree $d
    }
}
@ / cd
tree /
