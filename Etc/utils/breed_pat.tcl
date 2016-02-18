# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
default ::opt(interpolation) LUT
default ::opt(process) ss
default ::opt(device) nch
default ::opt(tech) tsmc040
default ::opt(topv) 1.1
default ::opt(rez) 5:5:3:8
default ::opt(l) 360e-9
default ::opt(w) 360e-9
default ::opt(vgs) 1.0
default ::opt(vbs) 0.0
default ::opt(r) 50
default ::opt(ref) 100e-6
default ::opt(op_limit) 2
default ::opt(step) 0.01
default ::opt(step_limit) 1000
default ::opt(step_count) 10
default ::opt(np) 1
default ::opt(mode) dc
default ::opt(topology) diffpair_nmos
default ::opt(shell) 0
set ::opt(mode) [string tolower $::opt(mode)]
default EPS0 8.85418e-12
default ::opt(epsrox) 3.9
default ::opt(source) $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/4d/$::opt(rez)/
source $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/binning_$::opt(tech).tcl
@ max_Adc = 0
@ / load Etc/Templates/$::opt(topology)/$::opt(tech).db

@ /look_up_tables foreach_child type {
    @ /look_up_tables/$type foreach_child table {
        @ /look_up_tables/$type/$table foreach_child corner {
	    if {$corner!="ss"} {
	        Info: Deleting /look_up_tables/$type/$table/$corner
	        @ /look_up_tables/$type/$table/$corner delete
	    }
	}
    }
}
Info: Done
@ config/op_iterations = 3000
@ config/design_feedback_th = 1e-3
@ config/design_feedback_activate_th = 1e-6
@ print_op_steps = 0
@ config/kcl_th = 1e-7	
@ config/kcl_step = 0.03
@ config/step = $::opt(step)
@ config/fail_on_properties = 1
@ mode/heat_map = 0
default ::opt(cap_factor) 3.5
@ mode:fresh_op = 1
@ look_up_tables:pch:cox = [expr 0.000148906*$::opt(cap_factor)] 
@ look_up_tables:nch:cox = [expr 0.00015696*$::opt(cap_factor)] 

@ property/TotalNoise = 0
@ status/fail = 0
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
default ::opt(iref) 20e-6
@ param:iref = $::opt(iref)
@ sizer_step = 20e-9
set pat_sizes {}
@ size foreach_child s {
    @ size:$s:step = 50e-9
    lappend pat_sizes $s
}
@ size:iref:step = 1e-6
@ size:iref:min = 10e-6
@ size:iref:max = 500e-6
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
    Info: Property=$p
}
source $::env(RAMSPICE)/Gamma/Init.tcl
@ size/L/min = 40e-9
@ size/Lp/min = 40e-9
@ size/Ln/min = 40e-9
@ size/Ls/min = 40e-9
@ size/Lo/min = 40e-9
@ size/L/max = 10e-6
@ size/Lp/max = 10e-6
@ size/Ln/max = 10e-6
@ size/Ls/max = 10e-6
@ size/Lo/max = 10e-6

@ size/L/step = 3e-6
@ size/Lp/step = 3e-6
@ size/Ln/step = 3e-6
@ size/W/step = 3e-6
@ size/Wp/step = 3e-6
@ size/Wn/step = 3e-6
@ size/Wo/step = 3e-6
@ size/W/max = 500e-6
@ size/Wp/max = 500e-6
@ size/Wn/max = 500e-6
@ size/Wo/max = 500e-6
@ size/W/min = 120e-9
@ size/Wp/min = 120e-9
@ size/Wn/min = 120e-9
@ size/Wo/min = 120e-9
# @ $::opt(topology)/circuits(([join $pat_sizes ,]|[join $pat_properties ,])) !
@ config/pat_size_target = $::opt(sample)
@ config/op_iterations = 10000
load $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/libGamma.so
set i 0
set initial_size [@ $::opt(topology)/circuits PAT size]
@ param/unique = 0
Info: max_Adc=[@ max_Adc] Trying [@ config/pat_size_target]
::C::import
::C::random
::C::export

Info: max Adc = [@ max_Adc]
Info: size after random=[@ $::opt(topology)/circuits PAT size] seed [clock format [clock seconds]]
if {$::opt(shell)} {
    Info: Done, saving PAT=[@ $::opt(topology)/circuits PAT size]
    @ / save Etc/Templates/$::opt(topology)/$::opt(tech).db
    exit
}
@ param/unique = 0
@ config/pat_size_target = $::opt(target)
@ param/unique = 32
::C::import
::C::random_breed
::C::export
@ config/pat_size_target = $::opt(target)
while {1} {
    ::C::import
    ::C::random_breed
    ::C::export
    @ $::opt(topology)/circuits PAT  unique 128
    Info: 5 Unique Size=[@ $::opt(topology)/circuits PAT size]
    if {[@ $::opt(topology)/circuits PAT size]>$::opt(target)*0.9} break
}
@ size foreach_child s {
    @ size:$s:step = 100e-9
    lappend pat_sizes $s
}
#@ param/unique = 0
#::C::import
#::C::random_breed
#@ $::opt(topology)/circuits PAT  unique 128
Info: Done, saving PAT=[@ $::opt(topology)/circuits PAT size]
@ / save Etc/Templates/$::opt(topology)/$::opt(tech).db
exit
for {set i 0} {$i<[@ $::opt(topology)/circuits PAT size]} {incr i} {
    Info: [@ $::opt(topology)/circuits PAT index $i]
}
Info: [@ $::opt(topology)/circuits PAT size] Pareto points
exit
