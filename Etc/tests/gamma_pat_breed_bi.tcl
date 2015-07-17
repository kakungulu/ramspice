# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
default ::opt(interpolation) LUT
default ::opt(process) ss
default ::opt(device) nch
default ::opt(tech) tsmc040
default ::opt(topv) 1.1
default ::opt(l) 360e-9
default ::opt(w) 360e-9
default ::opt(vgs) 1.0
default ::opt(vbs) 0.0
default ::opt(r) 50
default ::opt(ref) 100e-6
default ::opt(op_limit) 2
default ::opt(step_limit) 1000
default ::opt(step_count) 10
default ::opt(np) 1
default ::opt(mode) dc
default ::opt(topology) diffpair_nmos
set ::opt(mode) [string tolower $::opt(mode)]
default EPS0 8.85418e-12
default ::opt(epsrox) 3.9
default ::opt(source) $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/4d/5:5:3:6/
source $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/binning_$::opt(tech).tcl

@ / load Etc/Templates/$::opt(topology)/ctree.db
@ op_iterations = 5
proc present_property {p {val {}}} {
    regsub -all @ [@ property/$p/formula] $val expr
    return [eng [expr $expr] [@ property/$p/unit]]
}
default ::opt(param) {}
foreach param_pair $::opt(param) {
    lassign [split $param_pair =] param value
    @ param:$param = $value
}
@ size foreach_child s {
    set min($s) [expr [@ size/$s]-([@ size/$s]-40e-9)/2]
    set span($s) [expr 10e-6-$min($s)]
}
default ::opt(sample) 100
default ::opt(iref) 40e-6
@ param:iref = $::opt(iref)
@ sizer_step = 20e-9
set pat_sizes {}
@ size foreach_child s {
    @ size:$s:step = 500e-9
    lappend pat_sizes $s
}
@ size:iref:step = 1e-6
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
@ $::opt(topology)/circuits(([join $pat_sizes ,]|[join $pat_properties ,])) !
load $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/libGamma.so
set i 0
set initial_size [@ $::opt(topology)/circuits PAT size]
@ pat_size_target = $::opt(sample)
@ param/unique = 2
::C::import
::C::random
@ $::opt(topology)/circuits PAT  unique 2
Info: size after random=[@ $::opt(topology)/circuits PAT size] seed [clock format [clock seconds]]
@ param/unique = 5
::C::import
::C::random_breed
Info: size after  breed=[@ $::opt(topology)/circuits PAT size] seed [clock format [clock seconds]]
default ::opt(target) 500000
@ pat_size_target = $::opt(target)
@ param/unique = 0
::C::import
::C::random_breed
@ / save Etc/Templates/$::opt(topology)/pareto_bi.db
exit
for {set i 0} {$i<[@ $::opt(topology)/circuits PAT size]} {incr i} {
    Info: [@ $::opt(topology)/circuits PAT index $i]
}
Info: [@ $::opt(topology)/circuits PAT size] Pareto points
exit
