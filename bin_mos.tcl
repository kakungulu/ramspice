source bin.tcl

proc find_bin {type l w} {
    foreach key [array names ::bin $type,*,lmin] {
        set section [lindex [split $key ,] 1]
	set lmin $::bin($type,$section,lmin)
	set lmax $::bin($type,$section,lmax)
	set wmin $::bin($type,$section,wmin)
	set wmax $::bin($type,$section,wmax)
	if {$lmin>$l} continue
	if {$lmax<$l} continue
	if {$wmin>$w} continue
	if {$wmax<$w} continue
	return $section
    }
}

puts [find_bin n 2e-6 2e-6]
