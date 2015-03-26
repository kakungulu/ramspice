

proc load_circuits {} {
    default ::opt(tech) tsmc040
    default ::opt(topo) diffpair
    set ::circuit_db $::env(RAMSPICE)/Tech_DB/$::opt(tech)/topologies/$::opt(topo)/::circuit_db.tcl
    if {[file exists $::circuit_db]} {
        source $::circuit_db
	return
    }
    for {set i 2} {$i<[llength [file split $::circuit_db]]-1} {incr i} {
        set dir [file join [lrange [file split $::circuit_db] 0 $i]]
	if {![file exists $dir]} {
	    file mkdir $dir
	}
    }
    set O [open $::circuit_db w]
    puts $O [list \# Created at [clock format [clock seconds]]]
    close $O
}


proc save_circuits {} {
    set O [open $::circuit_db w]
    puts $O [list array set ::CIRC [array get ::CIRC]]
    puts $O [list array set ::POS_CRIT [array get ::POS_CRIT]]
    puts $O [set ::CIRC_list [set ::CIRC_list]]
    puts $O [set ::CIRC_index [set ::CIRC_index]]
    close $O
}

proc add_circ {arg_list} {
    default ::CIRC_index 0
    set circ $::CIRC_index
    incr circ
    lappend ::CIRC_list $circ
    foreach {property value} $arg_list {
        if {[info exists ::POS_CRIT($property)]} {
	    set value [expr -$value]
	}
	set ::CIRC($circ,$property) $value
    }
    save_circuits
}
proc useful? {args} {
    foreach {property value} $args {
        if {[info exists ::POS_CRIT($property)]} {
	    set value [expr -$value]
	}
	set this_circ($property) $value
    }
    foreach circ $::CIRC_list {
        set dominates 1
	set dominated 1
        foreach property [array names this_circ] {
	    skip {![info exists ::CIRC($circ,$property)]}
	    if {$this_circ($property)>$::CIRC($circ,$property)} {
	       set dominates 0
	    } elseif {$this_circ($property)<$::CIRC($circ,$property)} {
	        set dominated 0
	    }
	    if {!($dominates||$dominated)} break
	}
	if {$dominated} {
	    set i [lsearch $::CIRC_list $circ]
	    set ::CIRC_list [lreplace $::CIRC_list $i $i]
            return [add_circ $args]
	}
	if {$dominates} {
	    return 0
	}
    }
    return [add_circ $args]
}

proc filter {args} {
    
}

