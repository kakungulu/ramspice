# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
source $::env(RAMSPICE)/Etc/utils/generate_spice_netlist.tcl

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
# 0.2 0.96 0.64 0.5
@ param/vdd = 1.1
@ param/inp = 0.55
@ param/inn = 0.55

foreach s {
Lcp1 Lcp2  Lcn1  Lcn2  Ldp1  Ldp2  Ldn1  Ldn2 } { 
    @ size/$s = [expr 2*$::opt($s)]
}
foreach s {
 Wcp1  Wcp2  Wcn1  Wcn2  Wdp1  Wdp2  Wdn1  Wdn2} { 
    @ size/$s = [expr 8*$::opt($s)]
}
foreach s {
Vref1 Vref2 Vref3 Vref4 } { 
    @ size/$s = [expr $::opt($s)]
}
generate_spice_netlist tsmc040 op_amp
set eps 1e-4
::spice::source $::env(RAMSPICE)/../../original.sn
::spice::op
foreach vector [lsort [get_vectors]] {
#    skip {![regexp ^net $vector]}
    Info: SIMULATION $vector=[eng [get_spice_data $vector 0] V]
}
Info: Itest=[expr ([get_spice_data outp1 0]-[get_spice_data outp 0])/1e-5] 
::spice::dc vinp [expr 0.55-$eps] [expr 0.55+$eps] $eps vinn [expr 0.55-$eps] [expr 0.55+$eps] $eps
set Adc [expr 20*log10(abs(([get_spice_data outp 2]-[get_spice_data outp 6]))/(4*$eps))]
set CMRR  [expr $Adc-20*log10(abs(([get_spice_data outp 8]-[get_spice_data outp 0]))/(2*$eps))]
Info: Adc=[eng $Adc dB]
Info: CMRR=[eng $CMRR dB]
exit
