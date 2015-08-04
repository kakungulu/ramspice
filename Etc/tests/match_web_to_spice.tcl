# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
default ::opt(circ) test.sn

# Get information from the circuit title
set I [open $::opt(circ) r]
gets $I line
default ::opt(id) [lindex $line 3]
default ::opt(topology) [lindex $line 1]
close $I

# SPICE OP run
::spice::source $::opt(circ)
::spice::op
foreach vector [lsort [get_vectors]] {
    Info: $vector=[eng [get_spice_data $vector 0] V]
}
set_param inp 0.551
::spice::op
foreach vector [lsort [get_vectors]] {
    Info: $vector=[eng [get_spice_data $vector 0] V]
}

# Initialize the Gamma database
@ / load $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/pareto_bi.db
load $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/libGamma.so
for {set i 0} {$i<[@ /$::opt(topology)/circuits PAT size]} {incr i} {
    if {[@ /$::opt(topology)/circuits PAT id $i]==$::opt(id)} break
}
set index $i
set i 0
foreach s [@ /$::opt(topology)/circuits PAT sizes] {
    @ size:$s = [lindex [@ /$::opt(topology)/circuits PAT index $index] $i]
    incr i
}
::C::import
catch {::C::op}
::C::export
@ / foreach_child c {
    skip {![@ $c:V ?]}
    Info: $c=[eng [@ $c:V] V]
}
exit

