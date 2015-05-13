# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
default ::opt(size) 10

@ pareto((ehad,shtayim,shalosh|Abra?0.1,Cadabra>0.1,Hocus?0.1,-Pocus?0.1)) !
for {set i 0} {$i<$::opt(size)} {incr i} {
    set sizes {}
    for {set j 0} {$j<3} {incr j} {
        lappend sizes [expr rand()]
    }
    set properties {}
    for {set j 0} {$j<4} {incr j} {
        lappend properties [expr rand()]
    }
    @ pareto <<< $sizes $properties
}    
Info: PAT populated [clock format [clock seconds]]
for {set i 0} {$i<[@ pareto PAT size]} {incr i} {
    Info: $i=[lrange [@ pareto PAT index $i] 3 end]
}
@ / save pareto.db
set sizes {}
for {set j 0} {$j<3} {incr j} {
    lappend sizes [expr rand()]
}
set properties {}
for {set j 0} {$j<4} {incr j} {
    lappend properties [expr rand()]
#    lappend properties NAN
}
Info: spec: $properties
set T [clock clicks]
set front [@ pareto >>> $sizes $properties]
Info: PAT spec calculated [expr $T-[clock clicks]]
foreach item $front {
    Info: $item: [lrange [@ pareto PAT index $item] 3 end]
}
Info: Spec filtered [llength $front]/[@ pareto PAT size]
exit

@ / load pareto.db
Info: Properties=[@ pareto PAT properties]
Info: Sizes=[@ pareto PAT sizes]
Info: margins=[@ pareto PAT margins]
for {set i 0} {$i<[@ pareto PAT size]} {incr i} {
    Info: $i=[@ pareto PAT index $i]
}
Info: spec: $sizes $properties
set front [@ pareto >>> {1 2 3} {1 7 NAN 4}]
foreach item $front {
    Info: $item: [lrange [@ pareto PAT index $item] 3 end]
}
exit
