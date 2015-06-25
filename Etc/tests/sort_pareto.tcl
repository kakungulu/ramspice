# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
default ::opt(topv) 1.1
default ::opt(iref) 100e-6
default ::opt(topology) diffpair_nmos
default ::opt(spec) Adc=4:Zout=5000:Area=inf
# :BW=inf

@ / load $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/pareto.db
foreach spec_item [split $::opt(spec) :] {
    lassign [split $spec_item =] property value
    set spec($property) $value
}
set spec_list {}
set properties [@ /$::opt(topology)/circuits PAT properties]
foreach property $properties {
    regsub {^\-} $property {} neg_property
    if {[info exists spec($property)]} {
        lappend spec_list $spec($property)
    } elseif {[info exists spec($neg_property)]} {
        lappend spec_list $spec($neg_property)
    } else {
        lappend spec_list nan
    }
} 
Info: $spec_list
set tail_length [llength $properties]
incr tail_length -1
set specific_front [@ /$::opt(topology)/circuits >>> $spec_list]
set initial_size [llength $specific_front]
#exit
set j 1
foreach i $specific_front {
    set msg $j 
    foreach property $properties value [lrange [@ /$::opt(topology)/circuits PAT index $i] end-$tail_length end] {
        lappend msg $property=$value
    }	
    Info: $msg
    incr j
}
exit
Info: Breeding specific front:
set pat_sizes {}
@ size foreach_child w {
    skip {![string match W* $w]}
    regsub {W} L$w {} l
    lappend pat_sizes $w
    lappend pat_sizes $l
}
@ / foreach_child n {
    skip {![@ $n:V ?]}
    skip {$n=="vdd"}
    skip {$n=="0"}
    skip {[@ param:$n ?]}
    lappend pat_sizes $n
}
set pat_properties {}
@ property foreach_child p {
    if {[@ property/$p/step_factor]<0} {
        set p "-$p"
    }
    lappend pat_properties $p
}
lappend pat_properties -Area
lappend pat_properties -Power
while {[llength $specific_front]<10*$initial_size} {
    Info: [@ /$::opt(topology)/circuits PAT size] [llength $specific_front]<10*$initial_size
    for {set r 0} {$r<10} {incr r} {
    foreach index $specific_front {
        set sizes [@ $::opt(topology)/circuits PAT index $index]
        set j 0
        @ size foreach_child s {
            set step 5e-9
            if {rand()>0.5} {
                set step -$step
            }
            @ size/$s = [expr $step+[lindex $sizes $j]]
            if {[@ size/$s]<40e-9} {
                @ size/$s = 40e-9
            }
            set sample($s) [@ size:$s]
            incr j
        }
        set skip 0
        @ / foreach_child n {
            skip {![@ $n:V ?]}
            skip {$n=="vdd"}
            skip {$n=="0"}
            if {[@ param:$n ?]} {
                @ $n:V = [@ param:$n]
            } else {
                @ $n:V = [expr [@ vdd:V]/2]
            }
        }	 
        @ vdd:V = $::opt(topv)
        @ 0:V = 0
        @ param/iref = [expr $::opt(iref)*rand()]
        
        set sample(iref) [@ param/iref]
        ::C::import
        ::C::op
        ::C::export
        # Filter out bad OP circuits
        @ / foreach_child n {
            skip {![@ $n:V ?]}
            # Detect OP catastophe. A fix: exclude static nodes from OP loop.
            if {[string match *n* [@ $n:V]]} {
                set skip 1
            }
            skip {[@ param:$n ?]}
            skip {$n=="vdd"}
            skip {$n=="0"}
            if {[@ $n:V]==0} {
                set skip 1
            }
            if {[@ $n:V]==$::opt(topv)} {
                set skip 1
            }
            set sample($n) [@ $n:V]
        }
        @ property foreach_child p {
            if {[regexp n [@ property/$p]]} {
                set skip 1
            }
        }
        # illegal property values indicate bad OP or useless circuit sizes
        if {[@ property/ts]<0} {
            set skip 1
        }
        if {[@ property/Adc]<1} {
            set skip 1
        }
        
        if {$skip} {
            ###        set msg {}
            ###        @ / foreach_child n {
                ###   	    skip {![@ $n:V ?]}
                ###	    append msg "$n=[@ $n:V] "
            ###	}    
            ###        Info: $i $msg
            continue
        }
        # Good OP circuit
        @ property foreach_child p {
            set sample($p) [@ property:$p]
        }
        set Area 0
        @ size foreach_child w {
            skip {![string match W* $w]}
            regsub {W} L$w {} l
            set Area [expr $Area+[@ size/$w]*[@ size:$l]+40e-9*[@ size/$w]]
        }
        set sample(Area) [expr $Area*1e12]
        set sample(Power) [expr ([@ param/iref])*([@ vdd:V])]	
        set pat_entry_sizes {}
        foreach s $pat_sizes {
            lappend pat_entry_sizes $sample($s)
        }
        set pat_entry_properties {}
        foreach p $pat_properties {
            regsub {^\-} $p {} p
            lappend pat_entry_properties $sample($p)
        }
        @ $::opt(topology)/circuits <<< $pat_entry_sizes $pat_entry_properties
    }
    }
    set specific_front [@ /$::opt(topology)/circuits >>> $spec_list]
}    
foreach i $specific_front {
    set msg $i
    foreach property $properties value [lrange [@ /$::opt(topology)/circuits PAT index $i] end-$tail_length end] {
        lappend msg $property=$value
    }	
    Info: $msg
}
exit

