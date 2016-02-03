.param inp = $::opt(topv)/2
.param inn = $::opt(topv)/2
.param vdd = $::opt(topv)
.param power_factor = 2
.size Lcp1  = $::global_nlmin $::global_nlmin 10e-6 20e-9
.size Wcp1  = $::global_nlmin @size:Lcp1 10e-6 20e-9
.size Lcp2  = $::global_nlmin $::global_nlmin 10e-6 20e-9
.size Wcp2  = $::global_nlmin @size:Lcp2 10e-6 20e-9
.size Lcn1  = $::global_nlmin $::global_nlmin 10e-6 20e-9
.size Wcn1  = $::global_nlmin @size:Lcn1 10e-6 20e-9
.size Lcn2  = $::global_nlmin $::global_nlmin 10e-6 20e-9
.size Wcn2  = $::global_nlmin @size:Lcn2 10e-6 20e-9
.size Ldp1  = $::global_nlmin $::global_nlmin 10e-6 20e-9
.size Wdp1  = $::global_nlmin @size:Ldp1 10e-6 20e-9
.size Ldp2  = $::global_nlmin $::global_nlmin 10e-6 20e-9
.size Wdp2  = $::global_nlmin @size:Ldp2 10e-6 20e-9
.size Ldn1  = $::global_nlmin $::global_nlmin 10e-6 20e-9
.size Wdn1  = $::global_nlmin @size:Ldn1 10e-6 20e-9
.size Ldn2  = $::global_nlmin $::global_nlmin 10e-6 20e-9
.size Wdn2  = $::global_nlmin @size:Ldn2 10e-6 20e-9
.size Vref1 = 0 0 $::opt(topv) 1e-3
.size Vref2 = 0 @size:Vref1 $::opt(topv) 1e-3
.size Vref3 = 0 @size:Vref2 $::opt(topv) 1e-3
.size Vref4 = 0 @size:Vref3 $::opt(topv) 1e-3



mn4 net058 net045 net076 0 nch L=size:Lcn1 W=size:Wcn1
mn5 outp net045 net028 0 nch L=size:Lcn1 W=size:Wcn1

mn42 net52 inn net051 0 nch L=size:Ldn1 W=size:Wdn1
mn41 net049 inp net051 0 nch L=size:Ldn1 W=size:Wdn1

mn36 net051 net039 0 0 nch L=size:Ldn2 W=size:Wdn2

mn27 net076 net058 0 0 nch L=size:Lcn2 W=size:Wcn2
mn26 net028 net058 0 0 nch L=size:Lcn2 W=size:Wcn2

mp49 net049 net058 vdd vdd pch L=size:Lcp1 W=size:Wcp1
mp48 net52 net058 vdd vdd pch L=size:Lcp1 W=size:Wcp1

mp47 net048 net031 vdd vdd pch L=size:Ldp1 W=size:Wdp1

mp40 net028 inp net048 vdd pch L=size:Ldp2 W=size:Wdp2
mp39 net076 inn net048 vdd pch L=size:Ldp2 W=size:Wdp2

mp2 net058 net017 net52 vdd pch L=size:Lcp2 W=size:Wcp2
mp3 outp net017 net049 vdd pch L=size:Lcp2 W=size:Wcp2

v9 0 net045 size:Vref4
v8 0 net017 size:Vref1
v5 0 net039 size:Vref2
v4 0 net031 size:Vref3
vdd 0 vdd param:vdd
vinp 0 inp param:inp
vinn 0 inn param:inn


