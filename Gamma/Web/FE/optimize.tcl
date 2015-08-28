# \
exec $RAMSPICE/ramspice $0 $argv
set fe_path $::env(RAMSPICE)/Gamma/Web/FE
set ::sessions_path $fe_path/gamma_sessions
array set ::session_tracking {}
while {1} {
    Info: [c] Searching for active sessions
    foreach session_file [glob -nocomplain $::sessions_path/*.tcl] {
        skip {[file mtime $session_file]-[clock seconds]>15*60}
        array unset ::SESSION
        source $session_file
        regsub {\.tcl} [file tail $session_file] {} session_number
        set logfile $::env(RAMSPICE)/Gamma/Web/FE/gamma_sessions/optimization$session_number.log
        set O [open $logfile w]
        puts $O [clock format [clock seconds]]
        flush $O
        if {![info exists ::SESSION(selected_topology)]} return
        default circuit_ids {}
	foreach key [array names ::SESSION selcircuit_*] {
	    skip {$::SESSION($key)==0}
	    lappend circuit_ids [lindex [split $key _] 1]
	}
	skip {$circuit_ids=={}} 
	set circuit_ids [lsort $circuit_ids]
	default ::session_tracking($session_number) {}
	skip {$::session_tracking($session_number)==$circuit_ids}
	Info: Processing session $session_number
        set work_pat_file $::env(RAMSPICE)/Gamma/Web/FE/gamma_sessions/PAT$session_number.db
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
        load $::env(RAMSPICE)/Etc/Templates/$::SESSION(selected_topology)/libGamma.so
	set ::session_tracking($session_number) $circuit_ids
        puts $O "selected_circuit=$circuit_ids"
	Info: Strting to modify PAT [@ $::SESSION(selected_topology)/circuits PAT size]
        foreach id $circuit_ids {
            puts $O "Info: id=$id before=[@ $::SESSION(selected_topology)/circuits PAT size]"
            flush $O
            @ circuit_breed_id = $id
            @ circuit_breed_target = 1000
            ::C::import
            ::C::random_breed_single
            puts $O "Info: id=$id after=[@ $::SESSION(selected_topology)/circuits PAT size]"
	    Info: modified PAT [@ $::SESSION(selected_topology)/circuits PAT size]
            flush $O
        }
        close $O
	Info: Done, saving modified PAT [@ $::SESSION(selected_topology)/circuits PAT size]
        @ / save /tmp/gamma[pid]
        exec mv /tmp/gamma[pid] $work_pat_file
        exec rm $logfile
    }
    # Wait 5 seconds
    set t [clock seconds]
    incr t 5
    while {$t>[clock seconds]} {}
}
exit
