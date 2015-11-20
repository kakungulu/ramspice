foreach session_file [glob -nocomplain $::env(RAMSPICE)/Gamma/Web/FE/gamma_sessions/*.tcl] {
    file delete $session_file
}
set user  $::SESSION(user)
array unset ::SESSION
save_session

return
