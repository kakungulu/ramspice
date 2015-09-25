# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
default ::opt(tech) tsmc040
default ::opt(topology) diffpair_nmos
default ::opt(op) 5
source $::env(RAMSPICE)/Etc/utils/generate_spice_netlist.tcl

@ / load $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/$::opt(tech).db
#@ /look_up_tables/nch foreach_child t {
#    Info: Table: $t
#}
#exit
source $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/binning_$::opt(tech).tcl
source $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/data.tcl
# Info: Loading SO
load $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/libGamma.so
@ / load $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/models_$::opt(tech).db
# Info: Loaded
set DATA [open ~/temp/adc.log w]
puts $DATA [list # [clock format [clock seconds]]]
close $DATA
set DATA [open ~/temp/bw.log w]
puts $DATA [list # [clock format [clock seconds]]]
close $DATA
set DATA [open ~/temp/bw.1.2.log w]
puts $DATA [list # [clock format [clock seconds]]]
close $DATA
set DATA [open ~/temp/bw.2.log w]
puts $DATA [list # [clock format [clock seconds]]]
close $DATA

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
foreach name {n4 n5 n42 n41 n36 n27 n26 p49 p48 p47 p40 p39 p2 p3} {
    @ $name/cgs = 0
    @ $name/cgd = 0
}    
for {set ::index 191} {$sampled<[@ /$::opt(topology)/circuits PAT size]} {incr index} {
   # foreach ::index {11 44 75 105 161} 
    if {$::index>=$pat_size} {
        set ::index 0
    }
#    skip {rand()>1.0*$::opt(size)/$pat_size}
    set i 0
    foreach s [@ /$::opt(topology)/circuits PAT sizes] {
        if {![@ size:$s ?]} {
            set Gamma($s) [lindex [@ /$::opt(topology)/circuits PAT index $::index] $i]
        } else {
            @ size:$s = [lindex [@ /$::opt(topology)/circuits PAT index $::index] $i]
	    if {[regexp {^W} $s]} {
	        @ size:$s = [expr 16*[@ size:$s]]
	    }
	}
        # Info: $s=[@ size:$s]
        incr i
    }
 #    @ size:Vref2 = 0.52
 #    @ size:Vref3 = 0.1
#     @ size:Wdn2 = 200e-9
    foreach p [@ /$::opt(topology)/circuits PAT properties] {
        set Gamma($p) [lindex [@ /$::opt(topology)/circuits PAT index $::index] $i]
#	Info: $i $p= $Gamma($p)
        incr i
    }    
    default ::opt(op) 3
    @ param/rload = 1e30
    @ param/power_factor = 2
    @ param foreach_child p {
        # Info: PARAM $p = [@ param/$p]
    }
#    Info: [@ look_up_tables:pch:cox] [@ look_up_tables:nch:cox] 
    set c_factor [expr $gamma_bw_acc/$spice_bw_acc]
    set cap_factor 12.5
    @ look_up_tables:pch:cox = [expr 0.00148906*$cap_factor] 
    @ look_up_tables:nch:cox = [expr 0.0015696*$cap_factor] 
    ::C::import
    catch {::C::op}
    ::C::export
    @ property/BW = [expr [@ property/BW]/$c_factor]
#    skip {[@ property/BW]<1e6}
     set eps 0.00001
    skip {[generate_spice_netlist $::opt(tech) $::opt(topology) 0.00001]==0} 
    ::spice::source ~/temp/temp.sn
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
        set Adc [expr 20*log10(abs(([get_spice_data out 2]-[get_spice_data out 0]))/(4*$eps))]
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
	if {abs([@ property/Adc]-$Adc)>2.1} {
	    @ /$::opt(topology)/circuits PAT delete $::index
	    incr ::index -1
	    continue 
	}
	Info: $::index/[@ /$::opt(topology)/circuits PAT size]  SPICE=$Adc Gamma=[@ property/Adc]  Err=[eng [expr [@ property/Adc]-$Adc] dB]
	
	set DATA [open ~/temp/adc.log a]
	puts $DATA [list $Adc [@ property/Adc] [expr [@ property/Adc]-$Adc]]
	close $DATA
#        set CMRR [expr 20*log10(abs(([get_spice_data outp 8]-[get_spice_data outp 0]))/(2*$eps))]
#	set OP [get_spice_data outp 4]
#	foreach node {net048 net52 outp net028 net051} {
#	    Info: $node SPICE=[eng [get_spice_data $node 4] V] Gamma=[eng [@ $node/V] V] Err=[eng [expr [@ $node/V]-[get_spice_data $node 4]] V]
#	}    
#	continue
        ::spice::dc vinn 0.55 0.55 $eps vinp 0.55 0.55 $eps 
	set GammaOP [@ outp/V]
#        check_err $OP $Gamma(outp) 2e-3
	::spice::ac dec 100 1 200e6
	set prev_Aac $Adc
	for {set i 0} {$i<[get_spice_data frequency length]} {incr i} {
	    lassign [get_spice_data outp $i] real imag
	    set outp [expr sqrt($real*$real+$imag*$imag)]
	    set Aac [expr 20*log10($outp/(2*$eps))]
#	    Info: freq=[eng [lindex [get_spice_data frequency $i] 0] Hz] real=[eng $real V] imag=[eng $imag V] Aac=[eng $Aac dB] Adc=[eng $Adc dB]
	    if {$Aac<$Adc-3} break
	    set prev_Aac $Aac
	}
	if {$i>=[get_spice_data frequency length]} continue
	########### Injecting SPICE into Gamma
        foreach name {n4 n5 n42 n41 n36 n27 n26 p49 p48 p47 p40 p39 p2 p3} {
	    set cgs 0
	    set cgd 0
	    foreach key [array names ::CGS] {
	        skip {![string match m$name $key] && ![string match m${name}_* $key]}
		set cgs [expr $::CGS($key)+$cgs]
		set cgd [expr $::CGD($key)+$cgd]
	    }
	    @ $name/cgs = $cgs
	    @ $name/cgd = $cgd
	}    
        ::C::import
        if {[catch {::C::op}]} {
	     Info: Gamma returned error
	}
        ::C::export
        set f2 [lindex [get_spice_data frequency $i] 0]
	incr i -1
        set f1 [lindex [get_spice_data frequency $i] 0]
	set Ath [expr $Adc-3]
	set BW [expr (($Ath-$Aac)*$f1+($prev_Aac-$Ath)*$f2)/($prev_Aac-$Aac)]
#	skip {$BW<1e6}
        set gamma_bw_acc [expr $gamma_bw_acc+[@ property/BW]]
        set spice_bw_acc [expr $spice_bw_acc+$BW]
#	check_err $BW [@ property/BW]  5e6
	#set Gamma(Adc) [expr $Gamma(Adc)+7]
 #       check_err $OP $Gamma(outp) 1e-3
	array set total_cap {
	    spice,n,cgs 0
	    spice,p,cgs 0
	    gamma,n,cgs 0
	    gamma,p,cgs 0
	    spice,n,cgd 0
	    spice,p,cgd 0
	    gamma,n,cgd 0
	    gamma,p,cgd 0
	}
        foreach name {n4 n5 n42 n41 n36 n27 n26 p49 p48 p47 p40 p39 p2 p3} {
	    set cgs 0
	    set cgd 0
	    foreach key [array names ::CGS] {
	        skip {![string match m$name $key] && ![string match m${name}_* $key]}
		set cgs [expr $::CGS($key)+$cgs]
		set cgd [expr $::CGD($key)+$cgd]
	    }
	    set type [string index $name 0]
	    set total_cap(spice,$type,cgs) [expr $total_cap(spice,$type,cgs)+$cgs]
	    set total_cap(spice,$type,cgd) [expr $total_cap(spice,$type,cgd)+$cgd]
	    set total_cap(gamma,$type,cgs) [expr $total_cap(gamma,$type,cgs)+[@ $name/cgs]]
	    set total_cap(gamma,$type,cgd) [expr $total_cap(gamma,$type,cgd)+[@ $name/cgd]]
#	    Info: $name SPICE: cgd=[eng $cgd F] cgs=[eng $cgs F] ratio=[expr $cgs/$cgd] Gamma: cgd=[eng [@ $name/cgd] F] cgs=[eng [@ $name/cgs] F] Error: cgd=[eng [expr 100*([@ $name/cgd]/$cgd-1)] %] cgs=[eng [expr 100*([@ $name/cgs]/$cgs-1)] %]
	}
#        check_err $Adc $Gamma(Adc) 1.5
#	@ property/BW = [expr [@ property/BW]*1.15]
        set err [expr 100*([@ property/BW]/$BW-1)]
	Info: Index=$index  $Adc $Gamma(Adc) BW: SPICE=[eng $BW Hz] Gamma=[eng [@ property/BW] Hz] Error=[eng $err %]
	if {abs($err)<14.9} {
	    set DATA [open ~/temp/bw.log a]
	    puts $DATA "\{$BW [@ property/BW]\}"
	    close $DATA
	    continue
	} 
	set BW [expr 1.221*$BW]
        set err [expr 100*([@ property/BW]/$BW-1)]
	if {abs($err)<14.9} {
	    set DATA [open ~/temp/bw.1.2.log a]
	    puts $DATA "\{$BW [@ property/BW]\}"
	    close $DATA
	    continue
	} 
	set BW [expr 2*$BW/1.221]
        set err [expr 100*([@ property/BW]/$BW-1)]
	if {abs($err)<14.9} {
	    set DATA [open ~/temp/bw.2.log a]
	    puts $DATA "\{$BW [@ property/BW]\}"
	    close $DATA
	    continue
	} 
#	Info: N cgs Error=[eng [expr ($total_cap(gamma,n,cgs)/$total_cap(spice,n,cgs)-1)*100] %]
#	Info: N cgd Error=[eng [expr ($total_cap(gamma,n,cgd)/$total_cap(spice,n,cgd)-1)*100] %]
#	Info: P cgs Error=[eng [expr ($total_cap(gamma,p,cgs)/$total_cap(spice,p,cgs)-1)*100] %]
#	Info: P cgd Error=[eng [expr ($total_cap(gamma,p,cgd)/$total_cap(spice,p,cgd)-1)*100] %]
#	exit
#        check_err $Adc $Gamma(Adc) 3
 #       check_err [expr $Adc-$CMRR] [expr [@ property/Adc]-[@ property/CMRR]] 5
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
#    add_err op $OP $GammaOP
    add_err adc $Adc [@ property/Adc]
#    add_err cmrr [expr $Adc-$CMRR] [expr [@ property/Adc]-[@ property/CMRR]]
    incr sampled
    
#    Info: $sampled [eng $BW Hz] [eng [@ property/BW] Hz] Error=[eng [expr ($BW/[@ property/BW]-1)*100] %]
}
foreach type $types {
    Info: $type stddev=[stddev_err $type]
}
set O [open ~/temp/results.tcl w]
foreach type $types {
    puts $O [list set ${type}_errors [set ${type}_errors]]
    puts $O [list set ${type}_xy [set ${type}_xy]]
}
close $O
@ / save $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/xmodels_$::opt(tech).db
exit

