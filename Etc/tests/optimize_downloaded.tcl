# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
default ::opt(stim) 0.00025
if {![info exists ::opt(netlist)]} {
    foreach key [array names ::opt size:*] {
        @ $key = [expr $::opt($key)]
    }
    @ param:vdd = 1.1
    @ param:inn = 0.55
    @ param:inp = 0.55
    source $::env(RAMSPICE)/Etc/utils/generate_spice_netlist.tcl
    generate_spice_netlist $::opt(tech) $::opt(topo) $::opt(stim)
}
set pivot_adc 0
set pivot_bw 0
while {1} {
    set eps $::opt(stim)
    ::spice::source /tmp/temp.sn
    ::spice::op
    ::spice::noise v(outp) vinp lin 8 1 1e6 
    set TotalNoise [get_spice_data inoise_total 0]
    ::spice::dc vinn [expr 0.55-$eps] [expr 0.55+$eps] $eps vinp [expr 0.55-$eps] [expr 0.55+$eps] $eps 
    set Adc [expr 20*log10(abs(([get_spice_data outp 2]-[get_spice_data outp 6]))/(4*$eps))]
    set CMRR [expr $Adc-20*log10(abs(([get_spice_data outp 8]-[get_spice_data outp 0]))/(2*$eps))]
    ::spice::ac dec 20 1 10e12
    # Info: Scanning [get_spice_data frequency length] frequencies
    set prev_Aac $Adc
    for {set i 0} {$i<[get_spice_data frequency length]} {incr i} {
        lassign [get_spice_data outp $i] real imag
        if {$imag==""} {
            set imag 0
        }
        set outp [expr sqrt($real*$real+$imag*$imag)]
        set Aac [expr 20*log10($outp/(2*$eps))]
        if {$i==0} {
            set Aac0 $Aac
        }
        #    Info: $i) freq=[eng [lindex [get_spice_data frequency $i] 0] Hz] real=[eng $real V] imag=[eng $imag V] Aac=[eng $Aac dB] Adc=[eng $Adc dB]
        if {$Aac<$Aac0-3} break
        set prev_Aac $Aac
    }
    # Info: 3dB detected $i/[get_spice_data frequency length]
    if {$i>=[get_spice_data frequency length]} {
        incr i -1
    }
    ## Interpulating the 3dB frequency
    set f2 [lindex [get_spice_data frequency $i] 0]
    incr i -1
    set f1 [lindex [get_spice_data frequency $i] 0]
    set Ath [expr $Aac0-3]
    set BW [expr (($Ath-$Aac)*$f1+($prev_Aac-$Ath)*$f2)/($prev_Aac-$Aac)]
    ###
    ::spice::dc vinn [expr 0.55-$eps] [expr 0.55+$eps] $eps vinp [expr 0.55-$eps] [expr 0.55+$eps] $eps 
    set CMRR [expr $Aac0-20*log10(abs(([get_spice_data outp 8]-[get_spice_data outp 0]))/(2*$eps))]
    set top_bw $BW
    if {$top_bw>5e6} {
        set top_bw 5e6
    }
    set top_adc $Aac0
    if {$top_adc>60} {
        set top_adc 60
    }
    if {($top_adc>=$pivot_adc)&&($top_bw>=$pivot_bw)} {
        array unset pivot
        @ size foreach_child s {
            set pivot(size:$s) [@ size:$s] 
        }
        set pivot_adc $top_adc
        set pivot_bw $top_bw
        Info: PIVOT:  Adc=[eng $Aac0 dB] BW=[eng $BW Hz] [regsub -all size [array get pivot] -size]
	file copy -force /tmp/temp.sn ~/temp/temp.sn
        foreach key [array names pivot size:*] {
	    default step($key) 1e-7
            set step($key) [expr 2*$step($key)]
	}    
    } else {
       foreach key [array names pivot size:*] {
          if {$key=="size:iref"} {
              set step($key) [expr 10e-6*rand()-5e-6]
	  } else {
              set step($key) [expr 2e-8*rand()-1e-8]
	  }
       }	  
    }
#     Info: Adc=[eng $Aac0 dB] CMRR=[eng $CMRR dB] Total Noise=[eng $TotalNoise V^2] BW=[eng $BW Hz]
    if {($Aac0>60)&&($BW>5e6)} break
    foreach key [array names pivot size:*] {
        skip {$key=="size:iref"}
        default step($key) 1e-9
        @ $key = [expr $pivot($key)+$step($key)]
    }
   generate_spice_netlist $::opt(tech) $::opt(topo) $::opt(stim)
}
exit

