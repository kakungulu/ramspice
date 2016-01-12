# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
proc service {chan addr port} {
    fconfigure $chan -buffering line
    array set ::SERVICE [list chah $chan addr $addr port $port]
    fork
    while {[gets $chan line]>=0} {
        Info: $line
        if {[catch $line msg]} {
	    puts $chan $msg
	    flush $chan
	}
    }
    close $chan
    exit
}
set ::PORT 13570
while {[catch {set ::S [socekt -server service $::PORT]}]} {
    Info: $::PORT busy
    incr ::PORT
}
Info: Started Gamma at $::PORT
while 1 update

exit
