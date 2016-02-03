default ::opt(vin) 0.55
.param in = $::opt(vin)
.param vdd = $::opt(topv)
.size L = 360e-9 $::global_nlmin 10e-6 10e-9
.size W = 360e-9 @size:L 10e-6 10e-9
.size Lp = 360e-9 $::global_nlmin 10e-6 10e-9
.size Wp = 360e-9 @size:L 10e-6 10e-9
.size rin = 500 500 10e6 10

vin 0 in param:in
vdd 0 vdd param:vdd
mp  out out vdd vdd pch W=size:Wp L=size:Lp
mn_ref  out mid 0 0 nch W=size:W L=size:L
rin in mid size:rin
#.property Adc -expression derive(out,param:vin)  -denom Det -to_display 20*log10(@) -from_display pow(10,@/20) -unit dB
#.spec Adc < -15
#.compile_circuit -out out:V -in param:vin -sup param:vdd
