# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
### foreach pat_file [glob $::env(RAMSPICE)/Etc/Templates/*/*.db] {
###     Info: loading $pat_file
###     @ / load $pat_file
### }
init_gamma
proc http {} {
    set chan $::SERVICE(chan)
    while {![eof $chan]} {
        gets $chan line
        Info: Reading $line
        skip {![regexp {GET\s+\/(\S+)} $line -> cmd]}
        Info: cmd=$cmd
        puts $chan "<!DOCTYPE HTML>"
        puts $chan "<html><body>"
        puts $chan $cmd
        puts $chan "</body></html>"
        flush $chan
        break
    }
    close $chan
    exit
}
proc service {chan addr port} {
    fconfigure $chan -buffering line
    source $::env(RAMSPICE)/Gamma/Web/Server/server_procs.tcl
    array set ::SERVICE [list chan $chan addr $addr port $port]
    if {[fork]!=0} {
        close $chan
    } else {
        while {![eof $chan]} {
            gets $chan line
            Info: Reading $line
            skip {![regexp {GET\s+\/(\S+)} $line -> cmd]}
	    if {[regexp {^cmd/([^,]+),?(.*)$} $cmd -> command arguments]} {
		set tmp_file /tmp/tmp[pid].html
		set ::HTML [open $tmp_file w]
	        uplevel [concat ::SERVE::$command [split $arguments ,]]
		close $::HTML
		set I [open $tmp_file r]
		set msg [read $I]
		close $I
		file delete $tmp_file
	    } elseif {[regexp {^cgi\-bin/([^,]+),?(.*)$} $cmd -> script arguments]} {
	        array unset ::opt
	        array set ::opt [split $arguments ,]
		set tmp_file /tmp/tmp[pid].html
		set ::HTML [open $tmp_file w]
		source $script
		close $::HTML
		set I [open $tmp_file r]
		set msg [read $I]
		close $I
		file delete $tmp_file
	    } elseif {[file exists $::env(RAMSPICE)/Gamma/Web/HTML/$cmd]} {
	        set I [open $::env(RAMSPICE)/Gamma/Web/HTML/$cmd r]
		set msg [read $I]
		Info: length=[eng [string length $msg] B]
		close $I
	    } else {
	        set msg "Error: No such file: $cmd"
	    }
            puts $chan "HTTP/1.1 200 OK"
            puts $chan "Date: [clock format [clock seconds]]"
            puts $chan "Content-Type: text/html; charset=UTF-8"
            puts $chan "Content-Length: [expr 2*[string length $msg]]"
	    puts $chan "Cache-Control: no-cache, private"
            puts $chan "Accept-Ranges: bytes"
            puts $chan "Connection: close"
            puts $chan ""
            puts $chan $msg
            break
        }
        close $chan
        exit
    }
}
set ::PORT 1024
while {[catch {set ::S [socket -server service $::PORT]}]} {
    puts "port=$::PORT busy"
    incr ::PORT
}
puts "port=$::PORT"
vwait forever

exit
