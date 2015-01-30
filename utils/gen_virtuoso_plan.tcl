# \
exec $RAMSPICE/ramspice $0 $argv

get_opts
must    ::opt(maxv) "No -maxv given. Please specify max voltage."
must    ::opt(minv) "No -minv given. Please specify min voltage."
must    ::opt(out) "No -out given. Please specify output file name."
must    ::opt(tech) "No -techgiven. Please specify technology."
default ::opt(size) 10
set ref {
type 0
variable 0 "Vds"
inclusion 0 (?value (0.01 0.02) ?select t)
variable 1 "Vgs"
inclusion 1 (?value (0.2 0.5) ?select t)
variable 2 "Vbs"
inclusion 2 (?value ( 0.1 0) ?select t)
variable 3 "l"
inclusion 3 (?value (1e-6 1.1e-6) ?select t)
variable 4 "w"
inclusion 4 (?value ( 1e-6 1e-6) ?select t)
variable 5 "m"
inclusion 5 (?value ( 1e-6 1e-6) ?select t)
}
array unset bin
source $::env(RAMSPICE)/Tech_DB/$opt(tech)/binning_$opt(tech).tcl
set l {}
set w {}
set Vds {}
set Vgs {}
set Vbs {}
for {set i 1} {[info exists ::bin(n,$i,lmax)]} {incr i} {
    for {set j 0} {$j<$::opt(size)} {incr j} {
        set l0 [expr $::bin(n,$i,lmin)+rand()*($::bin(n,$i,lmax)-$::bin(n,$i,lmin))]
        set w0 [expr $::bin(n,$i,wmin)+rand()*($::bin(n,$i,wmax)-$::bin(n,$i,wmin))]
	set m0 [expr ceil($w0/$l0/10)]
        lappend w [expr $w0/$m0]
        lappend m [expr int($m0)]
	lappend l $l0
	lappend Vds [expr $::opt(minv)+rand()*($::opt(maxv)-$::opt(minv))]
	lappend Vgs [expr $::opt(minv)+rand()*($::opt(maxv)-$::opt(minv))]
	lappend Vbs [expr -0.3*rand()*$::opt(maxv)]
    }
}


set O [open $::opt(out) w]
puts $O "type 0"
set i 0
foreach var "Vds Vgs Vbs l w m" {
    puts $O "variable $i \"$var\""
    puts $O "inclusion $i (?value ([set $var]) ?select t)"
}
close $O
exit

