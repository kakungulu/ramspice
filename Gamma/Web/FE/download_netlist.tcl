if {![info exists ::SESSION(focus_circuit)]} return
if {![info exists ::SESSION(selected_topology)]} return
if {![info exists ::SESSION(selected_technology)]} return
source $::env(RAMSPICE)/Etc/Templates/$::SESSION(selected_topology)/data.tcl
set work_pat_file $::env(RAMSPICE)/Gamma/Web/FE/gamma_sessions/PAT$::active_session.db
set use_original_pat 1
if {[file exists $work_pat_file]} {
    if {[clock seconds]>[file mtime $work_pat_file]+5} {
        set use_original_pat 0
    }
}
if {$use_original_pat} {  
    @ / load $::env(RAMSPICE)/Etc/Templates/$::SESSION(selected_topology)/pareto_bi.db
} else {
    @ / load $work_pat_file
}
source $::env(RAMSPICE)/Etc/Tech_DB/$::SESSION(selected_technology)/binning_$::SESSION(selected_technology).tcl
set netlist {}
set topology_file $::env(RAMSPICE)/Etc/Topologies/$::SESSION(selected_topology).gsp
set I [open $topology_file r]
while {[gets $I line]>=0} {
    switch {[string index $line 0]} {
        m {
	    set name [string range [lindex $line 0] 0 1 end]
	    lassign [lrange $line 1 4] d g s b
	    if {![regexp {W=(\S+)} $line -> W]} {
	        Error: No width param in topology file $topology_file
		exit
	    }
	    if {![regexp {L=(\S+)} $line -> L]} {
	        Error: No length param in topology file $topology_file
		exit
	    }
	    set W $::SESSION(focus_circuit,$W)
	    set L $::SESSION(focus_circuit,$L)
	    append netlist [::GEN_SPICE::transistor $name $d $g $s $b $L $W]
	}
	r {
	}
	c {
	}
	default {}
    }
}
close $I
return
