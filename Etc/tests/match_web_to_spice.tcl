# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
default ::opt(tech) tsmc040
default ::opt(topology) diffpair_nmos
default ::opt(op) 5
default ::opt(iref) 2e-5
default ::opt(lref) 5e-7
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
# @ / load $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/models_$::opt(tech).db
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
Info: Trying [@ /$::opt(topology)/circuits PAT size]
set RES [open ~/temp/res.tcl w]
puts $RES [concat \# [clock format [clock seconds]]]
close $RES
set O [open ~/temp/times.tcl w]
puts $O [list \# [clock format [clock seconds]]]
close $O
for {set ::index 0} {$sampled<[@ /$::opt(topology)/circuits PAT size]} {incr index} {
    Info: index=$index
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
    foreach p [@ /$::opt(topology)/circuits PAT properties] {
        set Gamma($p) [lindex [@ /$::opt(topology)/circuits PAT index $::index] $i]
        incr i
    }    
    default ::opt(op) 3
    @ param/rload = 1e30
    @ param/power_factor = 2
    set c_factor [expr $gamma_bw_acc/$spice_bw_acc]
    set cap_factor 6
    @ look_up_tables:pch:cox = [expr 0.00148906*$cap_factor] 
    @ look_up_tables:nch:cox = [expr 0.0015696*$cap_factor] 
    for {set IREF 5e-6} {$IREF<30e-6} {set IREF [expr $IREF+1e-7]} {
        for {set LREF 2e-7} {$LREF<8e-7} {set LREF [expr $LREF+1e-8]} {
	    set ::opt(iref) $IREF
	    set ::opt(lref) $LREF
            @ size/Iref = $::opt(iref)
            foreach dim {L W} {
                foreach level {1 2} {
                    foreach type {p n} {
                        foreach side {c d} {
                            @ size:${dim}${side}${type}${level} = 0
                        }
                    }
                }
            }
            @ size/Lcp2 = $::opt(lref)
            @ size/Lcn1 = $::opt(lref)
            ::C::import
	    default ::gamma_time 0
	    default ::gamma_time_count 0
	    default ::spice_time 0
	    default ::spice_time_count 0
	    set t [clock clicks]
            if {[catch {::C::op}]} continue
	    set gamma_interval [expr [clock clicks]-$t]
	    set ::gamma_time [expr $::gamma_time+$gamma_interval]
	    incr ::gamma_time_count
            ::C::export
            
            @ property/BW = [expr [@ property/BW]/$c_factor]
            #    skip {[@ property/BW]<1e6}
            set eps 0.00001
            skip {[generate_spice_netlist $::opt(tech) $::opt(topology) 0.00001]==0} 
	    ::spice::reset
            ::spice::source ~/temp/temp.sn
	    set t [clock clicks]
            ::spice::op
	    set spice_interval [expr [clock clicks]-$t]
	    set ::spice_time [expr $::spice_time+$spice_interval]
	    incr ::spice_time_count
	    Info: SPICE Time: [eng [expr 1e-6*$::spice_time/$::spice_time_count] sec] Gamma Time: [eng [expr 1e-6*$::gamma_time/$::gamma_time_count] sec]
	    set O [open ~/temp/times.tcl a]
	    puts $O [list @ [expr 1e-6*$spice_interval] [expr 1e-6*$gamma_interval]]
	    close $O
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
                Info: Running SPICE
                ::spice::dc vinn [expr 0.55-$eps] [expr 0.55+$eps] $eps vinp [expr 0.55-$eps] [expr 0.55+$eps] $eps 
                Info: SPICE done
                set Adc [expr 20*log10(abs(([get_spice_data outp 2]-[get_spice_data outp 6]))/(4*$eps))]
                #	if {abs([@ property/Adc]-$Adc)>2.1} {
                    #	    @ /$::opt(topology)/circuits PAT delete $::index
                    #	    incr ::index -1
                    #	    continue 
                #	}
                Info: $::index/[@ /$::opt(topology)/circuits PAT size]  SPICE=$Adc Gamma=[@ property/Adc]  Err=[eng [expr [@ property/Adc]-$Adc] dB]
                
                set DATA [open ~/temp/adc.log a]
                puts $DATA [list $Adc [@ property/Adc] [expr [@ property/Adc]-$Adc]]
                close $DATA
                set CMRR [expr 20*log10(abs(([get_spice_data outp 8]-[get_spice_data outp 0]))/(2*$eps))]
                set OP [get_spice_data outp 4]
                foreach node {net048 net52 outp net028 net051 net031 net039 net058} {
                    Info: OP at $node SPICE=[eng [get_spice_data $node 4] V] Gamma=[eng [@ $node/V] V] Err=[eng [expr [@ $node/V]-[get_spice_data $node 4]] V]
		    set OperatingPoint(Gamma,$node) [@ $node/V]
		    set OperatingPoint(SPICE,$node) [get_spice_data $node 4]
                }    
                #        ::spice::dc vinn 0.55 0.55 $eps vinp 0.55 0.55 $eps 
                #	set GammaOP [@ outp/V]
                #        check_err $OP $Gamma(outp) 2e-3
                ::spice::ac dec 20 1 10e12
                set prev_Aac $Adc
                for {set i 0} {$i<[get_spice_data frequency length]} {incr i} {
                    lassign [get_spice_data outp $i] real imag
                    set outp [expr sqrt($real*$real+$imag*$imag)]
                    set Aac [expr 20*log10($outp/(2*$eps))]
                   # Info: freq=[eng [lindex [get_spice_data frequency $i] 0] Hz] real=[eng $real V] imag=[eng $imag V] Aac=[eng $Aac dB] Adc=[eng $Adc dB]
                    if {$Aac<$Adc-3} break
                    set prev_Aac $Aac
                }
                set prev_phase_Aac $prev_Aac
                for {set j $i} {$j<[get_spice_data frequency length]} {incr j} {
                    lassign [get_spice_data outp $j] real imag
                    set outp [expr sqrt($real*$real+$imag*$imag)]
                    set phase_Aac [expr 20*log10($outp/(2*$eps))]
                    set PM [expr atan($imag/$real)]
                    if {$phase_Aac<0} break
                    set prev_phase_Aac $Aac
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
                foreach dim {L W} {
                    foreach level {1 2} {
                        foreach type {p n} {
                            foreach side {c d} {
                                @ size:${dim}${side}${type}${level} = 0
                            }
                        }
                    }
                }
                @ size/Lcp2 = $::opt(lref)
                @ size/Lcn1 = $::opt(lref)
                ::C::import
                skip [catch {::C::op}]
                ::C::export
                foreach dim {L W} {
                    foreach level {1 2} {
                        foreach type {p n} {
                            foreach side {c d} {
                                Info: ${dim}${side}${type}${level} = [@ size:${dim}${side}${type}${level}]
                            }
                        }
                    }
                }
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
                    Info: $name SPICE: cgd=[eng $cgd F] cgs=[eng $cgs F] ratio=[expr $cgs/$cgd] Gamma: cgd=[eng [@ $name/cgd] F] cgs=[eng [@ $name/cgs] F] Error: cgd=[eng [expr 100*([@ $name/cgd]/$cgd-1)] %] cgs=[eng [expr 100*([@ $name/cgs]/$cgs-1)] %]
                }
                #        check_err $Adc $Gamma(Adc) 1.5
                #	@ property/BW = [expr [@ property/BW]*1.15]
                set factor [expr 2.e9*2e-7/[@ size/Lcp2]]
                set GammaBW [expr $factor/sqrt([@ property/Adc])]
                set err [expr 100*($GammaBW/$BW-1)]
		set GammaPM [expr $GammaBW/9.76e8]
		set PM [expr $PM/3.1415926*180]
		set GammaPM [expr $GammaPM/3.1415926*180]
		set RES [open ~/temp/res.tcl a]
                puts $RES [list $IREF $LREF $OperatingPoint(SPICE,outp) $OperatingPoint(Gamma,outp) $Adc [expr [@ property/Adc]-0.5] $BW $GammaBW $PM $GammaPM]
		close $RES
                Info: Index=$index SPICE=[eng $Adc dB] Gamma=[eng [@ property/Adc] dB] BW: SPICE=[eng $BW Hz] Gamma=[eng $GammaBW Hz] Error=[eng $err %] PM=$PM 
#		if {$gamma_time_count>200} exit
            }
        }
    }
}
default types
#foreach type $types {
    #    Info: $type stddev=[stddev_err $type]
#}
set O [open ~/temp/results.tcl w]
foreach type $types {
    puts $O [list set ${type}_errors [set ${type}_errors]]
    puts $O [list set ${type}_xy [set ${type}_xy]]
}
close $O
@ / save $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/xmodels_$::opt(tech).db
exit

