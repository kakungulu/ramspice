set dim 6
set population_size 500000
set length 15
set scan_list {}
set previous 0
for {set i 0} {$i<$length} {incr i} {
    lappend scan_list $previous
    set previous [expr $previous+rand()]
}

@ /test/array([join [string repeat "$length " $dim] ,]) !
set pre_code {}
set index {}
set post_code {}
for {set j 0} {$j<$dim} {incr j} {
    append pre_code "foreach i$j \{$scan_list\} \{\n"
    append index "i$j "
    append post_code "\}\n"
    set i 0
    foreach val $scan_list {
        ::spice::array_set_legend /test/array $j $i $val
        incr i
    }
}
set code $pre_code
append code "@ /test/array([join $index ,]) = \[expr rand()\]\n"
append code $post_code
eval $code
#generate_lut /test/array
ETA $population_size
for {set i 0} {$i<$population_size} {incr i} {
    ETA
    set coord {}
    for {j=0} {$j<$dim} {incr j} {
        lappend coord [expr rand()*10]
    }	
    eval "@ /test/array calc $coord"
}
Info: DIM=$dim
 
