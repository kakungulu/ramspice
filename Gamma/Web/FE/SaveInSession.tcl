lassign [split $::opt(arg) ,] var val
set ::SESSION($var) $val
save_session
return
