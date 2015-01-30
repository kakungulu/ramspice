proc Skill {filename code} {
    set O [open $filename w]
    set subst_code [uplevel [list subst $code]]
    regsub -all {^\s*} $subst_code {} subst_code
    regsub -all {\s*$} $subst_code {} subst_code
    puts $O "($subst_code)"
    close $O
}
set unknown {
    if {[regexp {^`(.*)} $args -> code]} {
       set subst_code [uplevel [list subst $code]]
       return "($subst_code)"
    }
}
append unknown [info body unknown]
proc unknown args $unknown 



