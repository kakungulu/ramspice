# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
default ::path $::env(RAMSPICE)/Gamma/Web/FE/gamma_process
while {1} {
    exec touch $::path/ping_$::env(HOST)
    foreach kill [glob -nocomplain $::path/kill_$::env(HOST)*.tcl] {
        source $kill
	exec kill -9 $pid
	exec rm $kill
    }
    foreach request [glob -nocomplain $::path/gamma_$::env(HOST)*.tcl] {
	skip {[clock seconds]-[file mtime $request]<2}
	regsub {.*\.} [expr rand()] {} newname
	file rename $request $::path/$newname
	if {[fork]} {
	    continue
	} 
	set ::netbatch_signal_file $::path/active_$::env(HOST)_[pid].tcl
	set active_signal_file $::netbatch_signal_file
	source $::path/$newname
	if {![info exists ::netbatch_signal_file]} {
	    # If the global var was removed, that means that the script contains a header
	    # If a header was executed, the script's body still needs to run:
	    source $::path/$newname
	}
	exec rm $::path/$newname
	exec rm $active_signal_file
	exit
    }
}
exit
