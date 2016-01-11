# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
source $::env(RAMSPICE)/Etc/utils/generate_spice_netlist.tcl
default ::opt(size) 1000
default ::opt(Lcp1) 40e-9
default ::opt(Wcp1) 266e-9
default ::opt(Lcp2) 40e-9
default ::opt(Wcp2) 1.1e-6
default ::opt(Lcn1) 40e-9
default ::opt(Wcn1) 222e-9
default ::opt(Lcn2) 40e-9
default ::opt(Wcn2) 90e-9
default ::opt(Ldp1) 40e-9
default ::opt(Wdp1) 1.5e-6
default ::opt(Ldp2) 40e-9
default ::opt(Wdp2) 1e-6
default ::opt(Ldn1) 40e-9
default ::opt(Wdn1) 132e-9
default ::opt(Ldn2) 40e-9
default ::opt(Wdn2) 373e-9

default ::opt(Vref1) 0.05
default ::opt(Vref2) 0.95
default ::opt(Vref3) 0.64
default ::opt(Vref4) 1.05
default ::opt(Iref) 50e-6
proc init_nodes {} {
    @ param/vdd = 1.1
    @ param/inp = 0.55
    @ param/inn = 0.55
    @ net017/V = 0.617
    @ net028/V = 0.55
    @ net031/V = 0.64
    @ net039/V = 0.48
    @ net045/V = 0.72
    @ net048/V = 0.55
    @ net049/V = 0.55
    @ net051/V = 0.55
    @ net058/V = 0.55
    @ net076/V = 0.55
    @ net52/V = 0.55
    @ outp/V = 0.55
    @ inn/V = 0.55    
    @ inp/V = 0.55    
    @ vdd/V = 1.1
}
foreach s {
Lcp1 Lcp2  Lcn1  Lcn2  Ldp1  Ldp2  Ldn1  Ldn2 } { 
    @ size/$s = [expr 2*$::opt($s)]
}
foreach s {
Wcp1  Wcp2  Wcn1  Wcn2  Wdp1  Wdp2  Wdn1  Wdn2} { 
    @ size/$s = [expr 8*$::opt($s)]
}
foreach s {
Vref1 Vref2 Vref3 Vref4} { 
    @ size/$s = [expr $::opt($s)]
}
@ size:Iref = 100e-6
@ / load Etc/Templates/op_amp_inst/models_tsmc040.db
set pat_sizes {    
    Lcp1 Wcp1 Lcp2 Wcp2 Lcn1 Wcn1 Lcn2 Wcn2 Ldp1 Wdp1 Ldp2 Wdp2 Ldn1 Wdn1 Ldn2 Wdn2 Iref nrefc prefc net017 net058 net045 net076 outp net028 net52 net051 net049 net039 net048 net031
}
set pat_properties {
    Adc CMRR PSRR Rout BW PM ts Nt Nf fc Vos Area Power
}
@ op_amp_inst/circuits(([join $pat_sizes ,]|[join $pat_properties ,])) !
init_nodes
load $::env(RAMSPICE)/Etc/Templates/op_amp_inst/libGamma.so
init_nodes
set sample_size 0
set O [open ~/op_adc_cmrr.tcl w]
while {$sample_size<$::opt(size)} {
    set iref [expr $::opt(Iref_min)+rand()*($::opt(Iref_max)-$::opt(Iref_min))]
    # 0.2 0.96 0.64 0.5
    @ size:Iref = $iref
    ::C::import
    skip {[catch ::C::op]} 
    ::C::export
    Info: net17=[@ net017/V]
    @ param:vb1 = [@ net017/V]
    @ param:vb2 = [@ net045/V]
    generate_spice_netlist tsmc040 op_amp_inst
    file copy -force /tmp/temp[pid].sn ~/original.sn
    set eps 1e-4
    ::spice::destroy all
    ::spice::source ~/original.sn
    ::spice::op
    foreach vector [lsort [get_vectors]] {
        #    skip {![regexp ^net $vector]}
        skip {![@ $vector/V ?]}
        Info: SIMULATION $vector=[eng [get_spice_data $vector 0] V] Gamma [eng [@ $vector/V] V]
    }
    # Info: Itest=[expr ([get_spice_data outp1 0]-[get_spice_data outp 0])/1e-5] 
    ::spice::dc vinp [expr 0.55-$eps] [expr 0.55+$eps] $eps vinn [expr 0.55-$eps] [expr 0.55+$eps] $eps 
    set Adc [expr 20*log10(abs(([get_spice_data outp 2]-[get_spice_data outp 6]))/(4*$eps))]
    set CMRR  [expr $Adc-20*log10(abs(([get_spice_data outp 8]-[get_spice_data outp 0]))/(2*$eps))]
    ::spice::dc vdd [expr 1.1-$eps] [expr 1.1+$eps] $eps
    set PSRR  [expr $Adc-20*log10(abs(([get_spice_data outp 2]-[get_spice_data outp 0]))/(2*$eps))]
    @ property/Adc = [expr [@ property/Adc]/3+12]
    @ property/CMRR = [expr $Adc+13.8]
    @ property/PSRR = [expr $Adc+12]
    Info: Adc=[eng $Adc dB] [eng [@ property/Adc] dB] [expr fabs($Adc-[@ property/Adc])]
    Info: CMRR=[eng $CMRR dB] [eng [@ property/CMRR] dB] 
    Info: PSRR=[eng $PSRR dB] [eng [@ property/PSRR] dB] 
#    skip {abs($Adc-[@ property/Adc])>2}
    skip {abs($CMRR-[@ property/CMRR])>2}
    skip {abs($PSRR-[@ property/PSRR])>2}
    puts $O [list @ $iref ADC $Adc [@ property/Adc] CMRR $CMRR [@ property/CMRR] PSRR $PSRR [@ property/PSRR] ]
    flush $O
    incr sample_size
}
close $O
exit
