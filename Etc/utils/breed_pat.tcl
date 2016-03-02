# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
default ::opt(interpolation) LUT
default ::opt(process) ss
default ::opt(device) nch
default ::opt(tech) tsmc040
default ::opt(topv) 1.1
default ::opt(rez) 5:5:3:1:1
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
default ::opt(topo) diffpair_nmos
default ::opt(shell) 0
set ::opt(mode) [string tolower $::opt(mode)]
default EPS0 8.85418e-12
default ::opt(epsrox) 3.9
default ::opt(source) $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/2p3d/$::opt(rez)/
source $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/binning_$::opt(tech).tcl
@ $::opt(topo)/max_Adc = 0
@ $::opt(topo)// load Etc/Templates/$::opt(topo)/$::opt(tech).db

# @ $::opt(topo)//look_up_tables foreach_child type {
#     @ $::opt(topo)//look_up_tables/$type foreach_child table {
#         @ $::opt(topo)//look_up_tables/$type/$table foreach_child corner {
# 	    if {$corner!="ss"} {
# 	        Info: Deleting /look_up_tables/$type/$table/$corner
# 	        @ $::opt(topo)//look_up_tables/$type/$table/$corner delete
# 	    }
# 	}
#     }
# }
Info: Done
@ $::opt(topo)/config/op_iterations = 3000
@ $::opt(topo)/config/design_feedback_th = 1e-3
@ $::opt(topo)/config/design_feedback_activate_th = 1e-6
@ $::opt(topo)/print_op_steps = 0
@ $::opt(topo)/config/kcl_th = 1e-7	
@ $::opt(topo)/config/kcl_step = 0.03
@ $::opt(topo)/config/step = $::opt(step)
@ $::opt(topo)/config/fail_on_properties = 1
@ $::opt(topo)/mode/heat_map = 0
default ::opt(cap_factor) 3.5
@ $::opt(topo)/mode:fresh_op = 1
@ $::opt(topo)/look_up_tables:pch:cox = [expr 0.000148906*$::opt(cap_factor)] 
@ $::opt(topo)/look_up_tables:nch:cox = [expr 0.00015696*$::opt(cap_factor)] 

@ $::opt(topo)/property/TotalNoise = 0
@ $::opt(topo)/status/fail = 0
proc present_property {p {val {}}} {
    regsub -all @ $::opt(topo)/[@ $::opt(topo)/property/$p/formula] $val expr
    return [eng [expr $expr] [@ $::opt(topo)/property/$p/unit]]
}
default ::opt(param) {}
foreach param_pair $::opt(param) {
    lassign [split $param_pair =] param value
    @ $::opt(topo)/param:$param = $value
}
@ $::opt(topo)/size foreach_child s {
    set min($s) [expr [@ $::opt(topo)/size/$s]-([@ $::opt(topo)/size/$s]-40e-9)/2]
    set span($s) [expr 10e-6-$min($s)]
}
default ::opt(sample) 100
default ::opt(iref) 20e-6
@ $::opt(topo)/param:iref = $::opt(iref)
@ $::opt(topo)/sizer_step = 20e-9
set pat_sizes {}
@ $::opt(topo)/size foreach_child s {
    @ $::opt(topo)/size:$s:step = 50e-9
    lappend pat_sizes $s
}
@ $::opt(topo)/size:iref:step = 1e-6
@ $::opt(topo)/size:iref:min = 10e-6
@ $::opt(topo)/size:iref:max = 500e-6
@ $::opt(topo)// foreach_child n {
    skip {![@ $::opt(topo)/$n:V ?]}
    skip {$n=="vdd"}
    skip {$n=="0"}
    skip {[@ $::opt(topo)/param:$n ?]}
    lappend pat_sizes $n
}

set pat_properties {}
@ $::opt(topo)/property foreach_child p {
    if {[@ $::opt(topo)/property/$p/step_factor]<0} {
        set p "-$p"
    }
    lappend pat_properties $p
    Info: Property=$p
}
source $::env(RAMSPICE)/Gamma/Init.tcl
@ $::opt(topo)/size/L/min = 40e-9
@ $::opt(topo)/size/Lp/min = 40e-9
@ $::opt(topo)/size/Ln/min = 40e-9
@ $::opt(topo)/size/Ls/min = 40e-9
@ $::opt(topo)/size/Lo/min = 40e-9
@ $::opt(topo)/size/L/max = 10e-6
@ $::opt(topo)/size/Lp/max = 10e-6
@ $::opt(topo)/size/Ln/max = 10e-6
@ $::opt(topo)/size/Ls/max = 10e-6
@ $::opt(topo)/size/Lo/max = 10e-6

@ $::opt(topo)/size/L/step = 3e-6
@ $::opt(topo)/size/Lp/step = 3e-6
@ $::opt(topo)/size/Ln/step = 3e-6
@ $::opt(topo)/size/W/step = 3e-6
@ $::opt(topo)/size/Wp/step = 3e-6
@ $::opt(topo)/size/Wn/step = 3e-6
@ $::opt(topo)/size/Wo/step = 3e-6
@ $::opt(topo)/size/W/max = 500e-6
@ $::opt(topo)/size/Wp/max = 500e-6
@ $::opt(topo)/size/Wn/max = 500e-6
@ $::opt(topo)/size/Wo/max = 500e-6
@ $::opt(topo)/size/W/min = 120e-9
@ $::opt(topo)/size/Wp/min = 120e-9
@ $::opt(topo)/size/Wn/min = 120e-9
@ $::opt(topo)/size/Wo/min = 120e-9
@ $::opt(topo)/circuits(([join $pat_sizes ,]|[join $pat_properties ,])) !
@ $::opt(topo)/config/pat_size_target = $::opt(sample)
@ $::opt(topo)/config/op_iterations = 10000
set i 0
set initial_size [@ $::opt(topo)/circuits PAT size]
@ $::opt(topo)/param/unique = 0
Info: max_Adc=[@ $::opt(topo)/max_Adc] Trying [@ $::opt(topo)/config/pat_size_target]
::Gamma::$::opt(topo)::import
exit
::Gamma::$::opt(topo)::random
exit
::Gamma::$::opt(topo)::export

Info: max Adc = [@ $::opt(topo)/max_Adc]
Info: size after random=[@ $::opt(topo)/circuits PAT size] seed [clock format [clock seconds]]
if {$::opt(shell)} {
    Info: Done, saving PAT=[@ $::opt(topo)/circuits PAT size]
    @ $::opt(topo)// save Etc/Templates/$::opt(topo)/$::opt(tech).db
    exit
}
@ $::opt(topo)/param/unique = 0
@ $::opt(topo)/config/pat_size_target = $::opt(target)
@ $::opt(topo)/param/unique = 32
::Gamma::$::opt(topo)::import
::Gamma::$::opt(topo)::random_breed
::Gamma::$::opt(topo)::export
@ $::opt(topo)/config/pat_size_target = $::opt(target)
while {1} {
    ::Gamma::$::opt(topo)::import
    ::Gamma::$::opt(topo)::random_breed
    ::Gamma::$::opt(topo)::export
    @ $::opt(topo)/circuits PAT  unique 128
    Info: 5 Unique Size=[@ $::opt(topo)/circuits PAT size]
    if {[@ $::opt(topo)/circuits PAT size]>$::opt(target)*0.9} break
}
@ $::opt(topo)/size foreach_child s {
    @ $::opt(topo)/size:$s:step = 100e-9
    lappend pat_sizes $s
}
#@ $::opt(topo)/param/unique = 0
#::Gamma::$::opt(topo)::import
#::Gamma::$::opt(topo)::random_breed
#@ $::opt(topo)/circuits PAT  unique 128
Info: Done, saving PAT=[@ $::opt(topo)/circuits PAT size]
@ $::opt(topo)// save Etc/Templates/$::opt(topo)/$::opt(tech).db
exit
for {set i 0} {$i<[@ $::opt(topo)/circuits PAT size]} {incr i} {
    Info: [@ $::opt(topo)/circuits PAT index $i]
}
Info: [@ $::opt(topo)/circuits PAT size] Pareto points
exit
