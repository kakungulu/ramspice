@ . add string test_array
@ . add string appended_array
array_load array.db
for {set i 0} {$i<4} {incr i} {
    for {set j 0} {$j<4} {incr j} {
        puts "test_array($i,$j) = [@ test_array($i,$j)]"
    }
}
for {set i 0} {$i<4} {incr i} {
    for {set j 0} {$j<4} {incr j} {
        puts "appended_array($i,$j) = [@ appended_array($i,$j)]"
    }
}

