set process_path $fe_path/gamma_process
if {![file exists $process_path]} {
    file mkdir $process_path
}
foreach key [array names ::opt] {
    skip {$key=="launch"}
    set ::SESSION($key) $::opt($key)
}
save_session
if {![info exists ::opt(launch)]} {
    return
}
default ::opt(process) ss
default ::opt(device) nch
default ::SESSION(selected_tech) tsmc040
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
default ::SESSION(selected_topology) diffpair_nmos
set ::opt(mode) [string tolower $::opt(mode)]
default EPS0 8.85418e-12
default ::opt(epsrox) 3.9
default ::opt(source) Etc/Tech_DB/tsmc040/4d/5:5:3:6/
@ / load Etc/Templates/$::SESSION(selected_topology)/ctree.db
@ op_iterations = 5
proc present_property {p {val {}}} {
    regsub -all @ [@ property/$p/formula] $val expr
    return [eng [expr $expr] [@ property/$p/unit]]
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
    @ size:$s:step = 10e-9
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
lappend pat_properties -Area
lappend pat_properties -Power
@ $::SESSION(selected_topology)/circuits(([join $pat_sizes ,]|[join $pat_properties ,])) !
load $::env(RAMSPICE)/Etc/Templates/$::SESSION(selected_topology)/libGamma.so
set i 0
set initial_size [@ $::SESSION(selected_topology)/circuits PAT size]
@ pat_size_target = $::opt(sample)
::C::import
::C::random
Info: size=[@ $::SESSION(selected_topology)/circuits PAT size] seed [clock format [clock seconds]]
default ::config(target_pareto_size) 500000
@ pat_size_target = $::config(target_pareto_size)
::C::import
::C::random_breed
@ / save Etc/Templates/$::SESSION(selected_topology)/pareto_bi.db

return
exec /usr/bin/ssh -f ystatter@linux1.engr.colostate.edu "echo 123 > ~ystatter/123"

return
set script_file $process_path/[pid].tcl
set O [open $script_file w]
puts $O {# \
exec $RAMSPICE/ramspice $0 $argv
}
puts $O #[clock format [clock seconds]]
puts $O [list array set ::opt [array get ::opt]]
puts $O [list array set ::opt [array get ::SESSION]]
puts $O [list array set ::config [array get ::config]]
set I [open $fe_path/analyze.tcl r]
puts $O [read $I]
close $I
close $O
exec chmod +x $script_file
exec $script_file 
return
