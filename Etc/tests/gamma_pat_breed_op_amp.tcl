# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
default ::opt(interpolation) LUT
default ::opt(process) ss
default ::opt(device) nch
default ::opt(tech) tsmc040
default ::opt(topv) 1.1
default ::opt(rez) 5:5:3:6
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
default ::opt(source) $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/4d/$::opt(rez)/
@ / load Etc/Templates/$::opt(topology)/models_$::opt(tech).db
source $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/binning_$::opt(tech).tcl
Info: spacing1=[@ param/area_spacing]
@ max_Adc = 0
@ op_iterations = 3000
@ print_op_steps = 0
proc present_property {p {val {}}} {
    regsub -all @ [@ property/$p/formula] $val expr
    return [eng [expr $expr] [@ property/$p/unit]]
}
default ::opt(param) {}
Info: spacing2=[@ param/area_spacing]
foreach param_pair $::opt(param) {
    lassign [split $param_pair =] param value
    @ param:$param = $value
}
Info: spacing3=[@ param/area_spacing]
@ size foreach_child s {
    set min($s) [expr [@ size/$s]-([@ size/$s]-40e-9)/2]
    set span($s) [expr 10e-6-$min($s)]
}
default ::opt(sample) 100
default ::opt(iref) 20e-6
@ param:iref = $::opt(iref)
@ sizer_step = 20e-9
set pat_sizes {}
@ size foreach_child s {
    @ size:$s:step = 50e-9
    lappend pat_sizes $s
}
@ / foreach_child n {
    skip {![@ $n:V ?]}
    skip {$n=="vdd"}
    skip {$n=="0"}
    skip {[@ param:$n ?]}
    lappend pat_sizes $n
}
Info: spacing=[@ param/area_spacing]

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
@ param/unique = 5
@ size/Vref1 = 100e-3
@ size/Vref2 = 480e-3
@ size/Vref3 = 640e-3
@ size/Vref4 = 720e-3
for {set i 1} {$i<=4} {incr i} {
    @ size/Vref$i/min = 0
    @ size/Vref$i/max = 1.1
}
foreach side {c d} {
    foreach type {n p} {
	foreach level {1 2} {
	    @ size/L$side$type$level/min = 40e-9
	    @ size/L$side$type$level/max = 10e6
	    @ size/W$side$type$level/min = 1.08e-7
	    @ size/W$side$type$level/max = 100e6
	}
    }
}
source $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/binning_$::opt(tech).tcl
Info: spacing=[@ param/area_spacing]

for {set f 2} {$f<=2} {set f [expr $f+0.2]} {
    @ size/Lcp1 = 40e-9*2
    @ size/Wcp1 = 266e-9*8
    @ size/Lcp2 = 40e-9*2
    @ size/Wcp2 = 1.1e-6*8
    @ size/Lcn1 = 40e-9*2
    @ size/Wcn1 = 222e-9*8
    @ size/Lcn2 = 40e-9*2
    @ size/Wcn2 = 90e-9*8
    @ size/Ldp1 = 40e-9*2
    @ size/Wdp1 = 1.5e-6*8
    @ size/Ldp2 = 40e-9*2
    @ size/Wdp2 = 1e-6*8
    @ size/Ldn1 = 40e-9*2
    @ size/Wdn1 = 132e-9*8
    @ size/Ldn2 = 40e-9*2
    @ size/Wdn2 = 373e-9*8
    Info: F=$f
    ::C::import
    catch ::C::op
    ::C::export
}
Info: max Adc = [@ max_Adc]
Info: size after random=[@ $::opt(topology)/circuits PAT size] seed [clock format [clock seconds]]
@ param/unique = 0
while {[@ max_Adc]<35} {
    Info: PAT=[@ $::opt(topology)/circuits PAT size] max_Adc=[eng [@ max_Adc] dB] Trying [@ pat_size_target]
    ::C::import
    ::C::random_breed
    ::C::export
    @ $::opt(topology)/circuits PAT  unique 16
    #    @ $::opt(topology)/circuits PAT stars
}
@ size foreach_child s {
    @ size:$s:step = 100e-9
    lappend pat_sizes $s
}
@ size:iref:step = 1e-6
@ size:iref:min = 5e-6
@ size:iref:max = 25e-6
@ param/unique = 0
@ pat_size_target = $::opt(target)
::C::import
::C::random_breed
@ $::opt(topology)/circuits PAT  unique 128
Info: Done, saving PAT=[@ $::opt(topology)/circuits PAT size]
@ / save Etc/Templates/$::opt(topology)/$::opt(tech).db
exit
for {set i 0} {$i<[@ $::opt(topology)/circuits PAT size]} {incr i} {
    Info: [@ $::opt(topology)/circuits PAT index $i]
}
Info: [@ $::opt(topology)/circuits PAT size] Pareto points
exit
