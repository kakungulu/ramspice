foreach key [array names ::opt] {
    skip {$key=="launch"}
    set ::SESSION($key) $::opt($key)
}
save_session
if {![info exists ::opt(launch)]} {
    return
}

set nbcode [list array set ::SESSION [array get ::SESSION]]
append nbcode {
    set sleep_until [clock seconds]
    incr sleep_until 40
    while {[clock seconds]<$sleep_until} {}
} 
netbatch $nbcode user $::SESSION(user) Name $::SESSION(Name)
