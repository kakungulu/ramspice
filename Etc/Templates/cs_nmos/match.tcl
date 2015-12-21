# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
default ::opt(stim) 0.00025
default ::opt(append) 0
set_spice_var DEBUG_MODEL 0
source $::env(RAMSPICE)/Etc/utils/generate_spice_netlist.tcl
#### foreach s {
####     Lo  
####     Lp 
####     Wn 
####     Wo 
####     Wp  
####     Ls  
####     Ln 
####     iref 
#### } {
####     @ size:$s = 0
####     @ size:$s:min = 0
####     @ size:$s:max = 0
####     @ config:size:$s = 0
#### }
####     foreach s {Lo Lp Wn Wo Wp Ls iref Ln} {
####         @ size:$s = [expr [@ size:$s:min]+rand()*([@ size:$s:max]-[@ size:$s:min])]
####     }
   
    @ / load $::env(RAMSPICE)/Etc/Templates/$::opt(topo)/$::opt(tech).db
#    foreach key [array names ::opt size:*] {
#        @ $key = $::opt($key)
#        @ config:$key = 0
#    }
    source $::env(RAMSPICE)/Gamma/Init.tcl
    @ Gds_in_mid = 1
 foreach {s min max} {
     L 1e-7 5e-7 
     Lo 1e-7 5e-7 
     Lp 2e-6 2e-6
     Wn 1e-7 5e-5
     W 1e-7 10e-7
     Wo 1e-7 10e-7
     Wp 1e-7 1e-5 
     Ls 1e-7 1e-5 
     Ln 1e-6 10e-6
     iref 5e-6 10e-6
     rin 1 1
 } {
     @ size:$s:min = $min
     @ size:$s:max = $max
     @ config:size:$s = 0
 }
@ param:vin = 0.55
set bw_accumulate_spice 0
set bw_accumulate_gamma 0
set regression_sample_file $::env(RAMSPICE)/Etc/Templates/$::opt(topo)/regression.html
if {!$::opt(append)} {
    set O [open $regression_sample_file w]
    puts $O "<html><body>"
    puts $O "# [clock format [clock seconds]]<br>"
    close $O
}
set S 0
set start [clock seconds]
while {$S<1000} {
# for  {set iref 4.8e-6} {$iref<5.5e-6} {set iref [expr $iref+1e-8]} 
# for  {set L 0.8e-6} {$L<5.5e-6} {set L [expr $L+5e-8]} 
#    @ /size foreach_child s {
#        @ size:$s = [expr [@ size:$s:min]+rand()*([@ size:$s:max]-[@ size:$s:min])]
#    }
    ### DEBUG REMOVE!!!!!!!!!!
  #  set L 1e-6
    set L [expr 1e-6+9e-6*rand()]
    set iref [expr 1e-6+6e-6*rand()]
    @ size:L = $L
    @ size:W = $L
    @ size:iref = $iref
    @ size:rin = 1
    @ param:vin = 0.55
    ###
    skip {[generate_spice_netlist $::opt(tech) $::opt(topo) $::opt(stim)]==0}
    set eps $::opt(stim)
    ::spice::destroy all
    ::spice::source /tmp/temp[pid].sn
    file copy -force /tmp/temp[pid].sn ~/temp/tmp.sn
    set I [open /tmp/temp[pid].sn r]
    gets $I line
    eval [lrange $line 1 end]
    close $I
    ::spice::op
    foreach s [get_vectors] {
        set spice_op($s) [get_spice_data $s 0]
#	Info: $s=$spice_op($s)
    }
    if {[file exists spice_op(vbias)]} {
        skip {$spice_op(vbias)>650e-3}
    }
    set overflow 0
    @ / foreach_child node {
        if {[info exists spice_op($node)]} {
            if {$spice_op($node)>1.1} {
	        set overflow 1
	        break
	    }
	}
    }
    skip {$overflow}
    if {[info exists spice_op(inp)]} {
        set in_node inp
	set out_node outp
    } else {
        set in_node in
	set out_node out
    }
    ::spice::noise v($out_node) v$in_node lin 8 1 5e6 
    set TotalNoise [get_spice_data inoise_total 0]
 #   Info: inoise_spectrum=[get_spice_data inoise_spectrum all]
    if {[info exists spice_op(inp)]} {
        ::spice::dc vinn [expr 0.55-$eps] [expr 0.55+$eps] $eps vinp [expr 0.55-$eps] [expr 0.55+$eps] $eps 
        skip {[catch {set Adc [expr 20*log10(abs(([get_spice_data outp 2]-[get_spice_data outp 6]))/(4*$eps))]}]}
        skip {[catch {set CMRR [expr $Adc-20*log10(abs(([get_spice_data outp 8]-[get_spice_data outp 0]))/(2*$eps))]}]}
    } else {
        ::spice::dc vin [expr 0.55-$eps] [expr 0.55+$eps] $eps  
        skip {[catch {set Adc [expr 20*log10(abs(([get_spice_data out 2]-[get_spice_data out 0]))/($eps))]}]}
        set CMRR 0
    }
    ::spice::ac dec 20 1 10e12
    foreach var [lsort [info vars ::Captured_C*]] {
        set key [string index $var end-1]
	default ACC($key) 0
	set ACC($key) [expr $ACC($key)+[set $var]]
    }
 #   Info: Scanning [get_spice_data frequency length] frequencies
    set prev_Aac $Adc
    set Aac3dB 0
    for {set i 0} {$i<[get_spice_data frequency length]} {incr i} {
        lassign [get_spice_data $out_node $i] real imag
        if {$imag==""} {
            set imag 0
        }
        set outp [expr sqrt($real*$real+$imag*$imag)]
        set Aac [expr 20*log10($outp/($eps))]
        if {$i==0} {
            set Aac0 $Aac
        }
        if {($Aac<$Aac0-3) && ($Aac3dB==0)} {
            set Aac3dB $Aac
        }
        if {$Aac<=0} {
            set PM [expr atan(-$imag/$real)*180/3.1415926]
            break
        }
        set prev_Aac $Aac
    }
    skip {$Aac3dB==0} 
    set Aac $Aac3dB
    # Info: 3dB detected $i/[get_spice_data frequency length] ~ [eng [get_spice_data frequency $i] Hz]
    if {$i>=[get_spice_data frequency length]} {
        incr i -1
    }
    ## Interpulating the 3dB frequency
    set f2 [lindex [get_spice_data frequency $i] 0]
    incr i -1
    set f1 [lindex [get_spice_data frequency $i] 0]
    set Ath [expr $Aac0-3]
    set BW [expr (($Ath-$Aac)*$f1+($prev_Aac-$Ath)*$f2)/($prev_Aac-$Aac)]
    skip {[regexp n $BW]}
    ###
    ::spice::dc vdd [expr 1.1-$eps] 1.1 $eps
    set PSRR [expr $Aac0-20*log10(abs(([get_spice_data $out_node 1]-[get_spice_data $out_node 0]))/($eps))]
    
    
    load $::env(RAMSPICE)/Etc/Templates/$::opt(topo)/libGamma.so
    ::C::import
    skip {[catch {::C::op}]} 
    ::C::export
    set bw_accumulate_spice [expr $bw_accumulate_spice+$BW]
    set bw_accumulate_gamma [expr $bw_accumulate_gamma+[@ property:BW]]
    set gamma_pm [@ property:PM]
    while {$gamma_pm>180} {
        set gamma_pm [expr $gamma_pm-180]
    }
    set spice_pm [expr 180-$PM]
    while {$spice_pm>180} {
        set spice_pm [expr $spice_pm-180]
    }
#    @ / foreach_child s {
#        if {[@ $s/V ?]&& $s!="0"} {
#            Info: Node $s=[eng [@ $s/V] V] [eng $spice_op($s) V] Err=[eng [expr [@ $s/V]-$spice_op($s)] V]
#        }
#	lappend entry [@ $s/V] $spice_op($s)
#    }
    set spice_acc 0
    set gamma_acc 0
#    skip {abs([@ $out_node/V]-$spice_op($out_node))>5e-3}
    @ property:BW = [expr ((pow(10,[@ property:Adc]/20)-1))*[@ property:BW]]
#    @ property:BW = [expr 2*[@ property:BW]]
    set BW_error [expr abs(100*($BW/[@ property:BW]-1))]
    set rand [expr rand()]
    skip {$rand>(1.0/$BW_error)} 
#    skip {abs($Aac0-[@ property:Adc])>2}
    set O [open $regression_sample_file a]
#    puts -nonewline $O "# L=[eng $L m] Err=[eng [expr [@ out/V]-$spice_op(out)] V] BW=[eng [expr 100*($BW/[@ property:BW]-1)] %]"
    @ / foreach_child t {
        @ $t foreach_child c {
	    if {[regexp {^c..$} $c]} {
	        Info: $t $c = [eng [set Captured_C[regsub {^c} $c {}]] F] [eng [@ /$t/$c] F] 
#		puts -nonewline $O "$c = [eng [expr 100*([@ /$t/$c]/[set Captured_C[regsub {^c} $c {}]]-1)] %]\t"
		set spice_acc [expr $spice_acc+[set Captured_C[regsub {^c} $c {}]]]
		set gamma_acc [expr $gamma_acc+[@ /$t/$c]]
	    }
	}
    }
    @ / foreach_child t {
        @ $t foreach_child c {
	    if {[regexp {^c..$} $c]} {
	        Info: @ config:${c}_factor = [expr [set Captured_C[regsub {^c} $c {}]]/[@ /$t/$c]]
	    }
	}
    }
    puts $O ""
    set linAdc [expr (pow(10,[@ property:Adc]/20)-1)]
    Info: Rand=$rand [expr 1.0/$BW_error] [eng $BW_error %]
    Info: SPICE Adc=[eng $Aac0 dB] CMRR=[eng $CMRR dB] PSRR=[eng $PSRR dB] Total Noise=[eng $TotalNoise V^2] BW=[eng $BW Hz] PM=[eng $spice_pm deg]
    Info: Gamma Adc=[eng [expr [@ property:Adc]] dB] CMRR=[eng [@ property:CMRR] dB]  PSRR=[eng [expr [@ property:PSRR]] dB] Total Noise=[eng [@ property:TotalNoise] V^2] BW=[eng [@ property:BW] Hz] PM=[eng $gamma_pm deg]
#    exit
    skip {abs([@ $out_node/V]-$spice_op($out_node))>5e-3}
#    skip {abs($BW/([@ property:Adc]*[@ property:BW]/10)-1)*100>12} 
#    skip {abs($Aac0-[@ property:Adc])>1.5}
#    skip {abs($gamma_pm-$spice_pm)>20}
    Info: BW factor=[expr $bw_accumulate_spice/$bw_accumulate_gamma]
    set entry {}
#    set O [open $regression_sample_file a]
    puts $O [list set sample($S) [concat $iref $L $Aac0 [@ property:Adc] $BW [@ property:BW] $spice_pm $gamma_pm] <br>]
     close $O
     incr S
     Info: ETA: [clock format [expr int(1000.0*([clock seconds]-$start)/$S+$start)]]
#    Info: Gamma Adc=[eng [expr [@ property:Adc]] dB] CMRR=[eng [@ property:CMRR] dB]  PSRR=[eng [expr [@ property:PSRR]] dB] Total Noise=[eng [@ property:TotalNoise] V^2] Nf=[eng [expr 20*[@ property:Nf]] V^2/Hz] Nt=[eng [expr [@ property:Nt]*2] V^2/Hz] BW=[eng [@ property:BW] Hz] PM=[eng [expr ([@ property:PM]-90)] deg]
#    exit
}
exit

