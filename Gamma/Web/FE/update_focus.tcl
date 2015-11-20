set ::SESSION(focus_circuit) $::opt(arg)
### if {![info exists ::SESSION(selected_topology)]} return
### if {![info exists ::SESSION(selected_tech)]} return
### source $::env(RAMSPICE)/Etc/Templates/$::SESSION(selected_topology)/data.tcl
set work_pat_file $::env(RAMSPICE)/Gamma/Web/FE/gamma_sessions/PAT$::active_session.db
set use_original_pat 1
if {[file exists $work_pat_file]} {
    if {[clock seconds]>[file mtime $work_pat_file]+5} {
        set use_original_pat 0
    }
}
if {$use_original_pat} {  
    @ / load $::env(RAMSPICE)/Etc/Templates/$::SESSION(selected_topology)/$::SESSION(selected_tech).db
} else {
    @ / load $work_pat_file
}
@ / foreach_child c {
    Info: $c [@ $c/circuits ?]
    if {[@ $c/circuits ?]} {
        default ::SESSION(selected_topology) $c
    }
}
set index [@ /$::SESSION(selected_topology)/circuits PAT id2index $::SESSION(focus_circuit)]
Info: Looking for id=$::SESSION(focus_circuit) index=$index
set i 0
foreach s [@ /$::SESSION(selected_topology)/circuits PAT sizes] {
    @ size:$s = [lindex [@ /$::SESSION(selected_topology)/circuits PAT index $index] $i]
    incr i
}
source $::env(RAMSPICE)/Etc/utils/generate_spice_netlist.tcl
generate_spice_netlist $::SESSION(selected_tech) $::SESSION(selected_topology)
save_session
return
