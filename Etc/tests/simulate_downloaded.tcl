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
set eps $::opt(stim)
::spice::source /tmp/temp.sn
set I [open /tmp/temp.sn r]
gets $I line
eval [lrange $line 1 end]
close $I
::spice::op
::spice::noise v(outp) vinp lin 8 1 5e6 
set TotalNoise [get_spice_data inoise_total 0]
Info: inoise_spectrum=[get_spice_data inoise_spectrum all]
::spice::dc vinn [expr 0.55-$eps] [expr 0.55+$eps] $eps vinp [expr 0.55-$eps] [expr 0.55+$eps] $eps 
set Adc [expr 20*log10(abs(([get_spice_data outp 2]-[get_spice_data outp 6]))/(4*$eps))]
set CMRR [expr $Adc-20*log10(abs(([get_spice_data outp 8]-[get_spice_data outp 0]))/(2*$eps))]
::spice::ac dec 20 1 10e12
Info: Scanning [get_spice_data frequency length] frequencies
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
    if {$Aac<$Aac0-3} {
        default Aac3dB $Aac
    }
    if {$Aac<=0} {
        set PM [expr atan(-$imag/$real)*180/3.1415926]
	break
    }
    set prev_Aac $Aac
}
set Aac $Aac3dB
Info: 3dB detected $i/[get_spice_data frequency length] ~ [eng [get_spice_data frequency $i] Hz]
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

::spice::dc vdd [expr 1.1-$eps] 1.1 $eps
set PSRR [expr $Aac0-20*log10(abs(([get_spice_data outp 1]-[get_spice_data outp 0]))/($eps))]
Info: SPICE Adc=[eng $Aac0 dB] CMRR=[eng $CMRR dB] PSRR=[eng $PSRR dB] Total Noise=[eng $TotalNoise V^2] BW=[eng [expr $BW/50] Hz] PM=[eng $PM deg]
 
@ / load $::env(RAMSPICE)/Etc/Templates/$::opt(topo)/$::opt(tech).db
foreach key [array names ::opt size:*] {
   @ $key = $::opt($key)
   @ config:$key = 0
}
source $::env(RAMSPICE)/Gamma/Init.tcl

load $::env(RAMSPICE)/Etc/Templates/$::opt(topo)/libGamma.so
::C::import
if {[catch {::C::op}]} {
    Info: Gamma failed code=[@ status/fail]
}
::C::export
@ / foreach_child s {
    if {[@ $s/V ?]} {
        Info: Node $s=[eng [@ $s/V] V]
    }
}
Info: Gamma Adc=[eng [@ property:Adc] dB] CMRR=[eng [@ property:CMRR] dB]  PSRR=[eng [@ property:PSRR] dB] Total Noise=[eng [@ property:TotalNoise] V^2] Nf=[eng [expr 20*[@ property:Nf]] V^2/Hz] Nt=[eng [expr [@ property:Nt]*2] V^2/Hz] BW=[eng [@ property:BW] Hz] PM=[eng [expr (180-[@ property:PM])] deg]

exit

