default ::SESSION(selected_circuits_tags) {}
set O [open $::env(RAMSPICE)/Gamma/Web/FE/gamma_sessions/optimization$::active_session w]
puts $O [clock format [clock seconds]]
flush $O

Info: [array get ::SESSION selcircuit_*]
default ::SESSION(circuit_list) {}
default ::opt(selected_circuit) {}
foreach id $::opt(selected_circuit) {
    default ::SESSION(selcircuit_$id) 0
    set ::SESSION(selcircuit_$id) 1
}
default ::opt(deselect) {}
foreach id $::opt(deselect) {
    set ::SESSION(selcircuit_$id) 0
}
Info: [array get ::SESSION selcircuit_*]
Info: QUERY_STRING=$::env(QUERY_STRING)
foreach key [array names ::opt] {
    skip {$key=="launch"}
    skip {$key=="selected_circuit"}
    set ::SESSION($key) $::opt($key)
    Info: $key=$::opt($key)
}
if {![info exists ::SESSION(selected_topology)]} return
set work_pat_file $::env(RAMSPICE)/Gamma/Web/FE/gamma_sessions/PAT$::active_session.db
if {[file exists $work_pat_file]} {
    @ / load $work_pat_file
} else {
    @ / load $::env(RAMSPICE)/Etc/Templates/$::SESSION(selected_topology)/pareto_bi.db
}
load $::env(RAMSPICE)/Etc/Templates/$::opt(selected_topology)/libGamma.so
default ::opt(selected_circuit) {}
puts $O "QUERY_STRING=$::env(QUERY_STRING)"
puts $O "selected_circuit=$::opt(selected_circuit)"
foreach id $::opt(selected_circuit) {
    puts $O "Info: id=$id before=[@ $::opt(selected_topology)/circuits PAT size]"
    flush $O
    @ circuit_breed_id = $id
    ::C::import
    ::C::random_breed_single
    puts $O "Info: id=$id after=[@ $::opt(selected_topology)/circuits PAT size]"
    flush $O
}
close $O
@ / save /tmp/gamma[pid]
exec mv /tmp/gamma[pid] $work_pat_file
set t [clock format [clock seconds]]
while {[clock format [clock seconds]]<$t+2} {}
return
