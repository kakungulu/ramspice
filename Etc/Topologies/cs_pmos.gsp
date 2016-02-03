default ::opt(vin) 0.55
.param iref = 15e-6
.param rload = 1e9
.param in = $::opt(vin)
.param vdd = $::opt(topv)
.size L = 360e-9 $::global_nlmin 1e-6 10e-9
.size W = 360e-9 @size:L 10e-6 10e-9
.size iref = $::opt(iref) 1e-6 5e-6 1e-6

iref 0 out size:iref
vin 0 in param:in
vdd 0 vdd param:vdd
mpin  out in vdd vdd pch W=size:W L=size:L
