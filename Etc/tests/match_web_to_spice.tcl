# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
default ::opt(circ) test.sn

# Get information from the circuit title
set I [open $::opt(circ) r]
gets $I line
default ::opt(id) [lindex $line 3]
default ::opt(topology) [lindex $line 1]
default ::opt(tech) [lindex $line 4]
close $I

# SPICE OP run
set eps 1e-4
::spice::source $::opt(circ)
# ::spice::pz inp inn outp outm vol pol
::spice::dc vinp [expr 0.55-$eps] [expr 0.55+$eps] $eps vinn [expr 0.55-$eps] [expr 0.55+$eps] $eps
set SPICE(Adc) [expr 20*log10(abs(([get_spice_data outp 2]-[get_spice_data outp 6]))/(4*$eps))]
set SPICE(CMRR) [expr 20*log10(abs(([get_spice_data outp 8]-[get_spice_data outp 0]))/(2*$eps))]
foreach vector [lsort [get_vectors]] {
    Info: SIMULATION $vector=[eng [get_spice_data $vector 0] V]
}
# exit
# Initialize the Gamma database
@ / load $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/pareto_bi.db
source $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/binning_$::opt(tech).tcl
source $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/data.tcl
load $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/libGamma.so
for {set i 0} {$i<[@ /$::opt(topology)/circuits PAT size]} {incr i} {
    if {[@ /$::opt(topology)/circuits PAT id $i]==$::opt(id)} break
}
set index $i
set i 0
foreach s [@ /$::opt(topology)/circuits PAT sizes] {
    if {![@ size:$s ?]} {
        #        @ $s:V = 0.55
        continue
    }
    @ size:$s = [lindex [@ /$::opt(topology)/circuits PAT index $index] $i]
    incr i
}
foreach p [@ /$::opt(topology)/circuits PAT properties] {
    @ property:$p = 0
}    
default ::opt(op) 3
@ op_iterations = $::opt(op) 
@ print_op_steps = 1
@ param/rload = 1e30
@ param/power_factor = 2
@ param foreach_child p {
    Info: PARAM $p = [@ param/$p]
}
::C::import
catch {::C::op}
::C::export
set i 11
foreach p [@ /$::opt(topology)/circuits PAT properties] {
    Info: PROP $p=[@ property:$p] [lindex [@ /$::opt(topology)/circuits PAT index $index] $i]
    incr i
}
@ param foreach_child p {
    Info: PARAM $p = [@ param/$p]
}
@ size foreach_child s {
    Info: SIZE $s = [@ size/$s]
}
set vectors [get_vectors]
@ / foreach_child c {
    skip {![@ $c:V ?]}
    skip {[lsearch $vectors $c]==-1}
    skip {[@ param:$c ?]}
    Info: GAMMA $c=[eng [@ $c:V] V] / / / SPICE [eng [get_spice_data $c 4] V] / / / DIFF=[eng [expr 100*abs([@ $c:V]/[get_spice_data $c 4]-1)] %]
}
foreach p [@ /$::opt(topology)/circuits PAT properties] {
    if {[info exists SPICE($p)]} {
        Info: GAMMA $p=[eng [@ property:$p] $::properties($p,unit)] / / / SPICE [eng $SPICE($p) $::properties($p,unit)] / / / DIFF=[eng [expr 100*abs([@ property:$p]/$SPICE($p)-1)] %]
    }
}
::spice::pz inp 0 outpi 0 vol pol

exit

