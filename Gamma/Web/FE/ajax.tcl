set process_path $fe_path/gamma_process
if {![file exists $process_path]} {
    file mkdir $process_path
}
if {![info exists ::opt(launch)]} {
    foreach key [array names ::opt] {
        skip {$key=="launch"}
        set ::SESSION($key) $::opt($key)
    }
    save_session
    return
}
exec echo 123 > ~ystatter/123
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
