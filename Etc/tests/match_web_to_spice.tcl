# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
default ::opt(tech) tsmc040
default ::opt(topology) diffpair_nmos
default ::opt(op) 5
source $::env(RAMSPICE)/Etc/utils/generate_spice_netlist.tcl

@ / load $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/$::opt(tech).db
source $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/binning_$::opt(tech).tcl
source $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/data.tcl
# Info: Loading SO
load $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/libGamma.so
# Info: Loaded

# SPICE OP run
set eps 1e-4
foreach type {op adc cmrr} {
    set ${type}_errors {}
    set ${type}_xy {}
}
@ op_iterations = $::opt(op) 
@ print_op_steps = 0
ETA [@ /$::opt(topology)/circuits PAT size]
proc check_err {spice gamma sane} {
    set error [expr $spice-$gamma]
    if {abs($error)>$sane} {
        return -code continue
    }
}    
proc add_err {type spice gamma} {
    set error [expr $spice-$gamma]
    default ::${type}_xy {}
    lappend ::${type}_xy [list $spice $gamma]
    default ::${type}_errors {}
    lappend ::${type}_errors $error
    default ::${type}_average_error 0
    set ::${type}_average_error [expr [set ::${type}_average_error]+$error]
    default ::${type}_error_count 0
    incr ::${type}_error_count
}
proc stddev_err {type} {
    set average [expr [set ::${type}_average_error]/[set ::${type}_error_count]]
    Info: average $type=$average
    set std 0
    foreach error [set ::${type}_errors] {
        set std [expr $std+($error-$average)*($error-$average)]
    }
    return [expr sqrt($std/[llength [set ::${type}_errors]])]
}
default ::opt(size) 1000
set sampled 0
set pat_size [@ /$::opt(topology)/circuits PAT size]
set spice_bw_acc 0.1
set gamma_bw_acc 0.1
for {set ::index 0} {$sampled<$::opt(size)} {incr index} {
    if {$::index>=$pat_size} {
        set ::index 0
    }
#    skip {rand()>1.0*$::opt(size)/$pat_size}
    set i 0
    foreach s [@ /$::opt(topology)/circuits PAT sizes] {
        if {![@ size:$s ?]} {
            #        @ $s:V = 0.55
            continue
        }
        @ size:$s = [lindex [@ /$::opt(topology)/circuits PAT index $::index] $i]
        # Info: $s=[@ size:$s]
        incr i
    }
    foreach p [@ /$::opt(topology)/circuits PAT properties] {
        @ property:$p = 0
    }    
    default ::opt(op) 3
    @ param/rload = 1e30
    @ param/power_factor = 2
    @ param foreach_child p {
        # Info: PARAM $p = [@ param/$p]
    }
#    Info: [@ look_up_tables:pch:cox] [@ look_up_tables:nch:cox] 
    set c_factor [expr $gamma_bw_acc/$spice_bw_acc]
    set c_factor 3.5
    @ look_up_tables:pch:cox = [expr 0.00148906] 
    @ look_up_tables:nch:cox = [expr 0.0015696] 
    ::C::import
    catch {::C::op}
    ::C::export
    @ property/BW = [expr [@ property/BW]/$c_factor]
#    skip {[@ property/BW]<1e6}
     set eps 0.00001
    skip {[generate_spice_netlist $::opt(tech) $::opt(topology) 0.00001]==0} 
    ::spice::source $::env(RAMSPICE)/../../original.sn
#    ::spice::op
     ##########################################Testing AC
###        ::spice::dc vinn [expr 0.55-$eps] [expr 0.55+$eps] $eps vinp [expr 0.55-$eps] [expr 0.55+$eps] $eps 
###        set Adc [expr 20*log10(abs(([get_spice_data outp 2]-[get_spice_data outp 6]))/(4*$eps))]
###	::spice::ac dec 100 1e6 50e6
###	for {set i 0} {$i<[get_spice_data frequency length]} {incr i} {
###	    lassign [get_spice_data outp $i] real imag
###	    set outp [expr sqrt($real*$real+$imag*$imag)]
###	    set Aac [expr 20*log10($outp/(4*$eps))]
###	  #  Info: freq=[eng [lindex [get_spice_data frequency $i] 0] Hz]/[eng [@ property/BW] Hz] Gamma=[@ property/Adc] SPICE DC=$Adc AC=$Aac
###	    if {$Aac<$Adc-9} break
###	}
###	
###	Info: freq=[eng [lindex [get_spice_data frequency $i] 0] Hz]/[eng [@ property/BW] Hz] Gamma=[@ property/Adc] SPICE DC=$Adc AC=$Aac
###	Info: const=[expr [lindex [get_spice_data frequency $i] 0]/[@ property/BW]]
###	exit
     ##########################################Testing AC
    if {[regexp ^cs $::opt(topology)]} {
	::spice::dc vin [expr 0.55-$eps] [expr 0.55+$eps] $eps 
        set Adc [expr 20*log10(abs(([get_spice_data out 2]-[get_spice_data out 0]))/(2*$eps))]
	set CMRR 0
	set OP [get_spice_data out 1]
	set GammaOP [@ out/V]
	skip {$GammaOP>=1.1}
        check_err $OP $GammaOP 5e-3
        check_err $Adc [@ property/Adc] 5
	set types {op adc}
    } else {
        ::spice::dc vinn [expr 0.55-$eps] [expr 0.55+$eps] $eps vinp [expr 0.55-$eps] [expr 0.55+$eps] $eps 
        set Adc [expr 20*log10(abs(([get_spice_data outp 2]-[get_spice_data outp 6]))/(4*$eps))]
        set CMRR [expr 20*log10(abs(([get_spice_data outp 8]-[get_spice_data outp 0]))/(2*$eps))]
	set OP [get_spice_data outp 4]
	set GammaOP [@ outp/V]
	::spice::ac dec 100 1 200e6
	for {set i 0} {$i<[get_spice_data frequency length]} {incr i} {
	    lassign [get_spice_data outp $i] real imag
	    set outp [expr sqrt($real*$real+$imag*$imag)]
	    set Aac [expr 20*log10($outp/(4*$eps))]
	    if {$Aac<$Adc-9} break
	}
	if {$i>=[get_spice_data frequency length]} continue
        set BW [lindex [get_spice_data frequency $i] 0]
#	skip {$BW<1e6}
        set gamma_bw_acc [expr $gamma_bw_acc+[@ property/BW]]
        set spice_bw_acc [expr $spice_bw_acc+$BW]
        Info: ...$index [expr $gamma_bw_acc/$spice_bw_acc] [eng $BW Hz] [eng [@ property/BW] Hz]
	check_err [expr abs($BW/[@ property/BW]-1)] 0 0.2
        check_err $OP $GammaOP 5e-3
        check_err $Adc [@ property/Adc] 5
        check_err [expr $Adc-$CMRR] [expr [@ property/Adc]-[@ property/CMRR]] 5
	set types {op adc cmrr bw}
    }
    foreach vector [lsort [get_vectors]] {
        # Info: SIMULATION $vector=[eng [get_spice_data $vector 0] V]
    }
    set vectors [get_vectors]
    @ / foreach_child c {
        skip {![@ $c:V ?]}
        skip {[lsearch $vectors $c]==-1}
        skip {[@ param:$c ?]}
        # Info: GAMMA $c=[eng [@ $c:V] V] / / / SPICE [eng [get_spice_data $c 4] V] / / / DIFF=[eng [expr 100*abs([@ $c:V]/[get_spice_data $c 4]-1)] %]
    }
    foreach p [@ /$::opt(topology)/circuits PAT properties] {
        if {[info exists SPICE($p)]} {
            # Info: GAMMA $p=[eng [@ property:$p] $::properties($p,unit)] / / / SPICE [eng $SPICE($p) $::properties($p,unit)] / / / DIFF=[eng [expr 100*abs([@ property:$p]/$SPICE($p)-1)] %]
        }
    }
    add_err bw $BW [@ property/BW]
    add_err op $OP $GammaOP
    add_err adc $Adc [@ property/Adc]
    add_err cmrr [expr $Adc-$CMRR] [expr [@ property/Adc]-[@ property/CMRR]]
    incr sampled
    Info: $sampled [eng $BW Hz] [eng [@ property/BW] Hz]
}
foreach type $types {
    Info: $type stddev=[stddev_err $type]
}
set O [open /tmp/results.tcl w]
foreach type $types {
    puts $O [list set ${type}_errors [set ${type}_errors]]
    puts $O [list set ${type}_xy [set ${type}_xy]]
}
close $O

exit

