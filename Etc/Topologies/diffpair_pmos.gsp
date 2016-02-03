.param inp = $::opt(topv)/2
.param inn = $::opt(topv)/2
.param vdd = $::opt(topv)
.size iref = $::opt(iref) 1e-6 100e-6 1e-6
.size Lp  = $::global_nlmin $::global_nlmin 10e-6 20e-9
.size Wp  = $::global_nlmin @size:Lp 10e-6 20e-9
.size Ln  = $::global_nlmin $::global_nlmin 10e-6 20e-9
.size Wn  = $::global_nlmin @size:Ln 10e-6 20e-9
.size Ls  = $::global_nlmin $::global_nlmin 10e-6 20e-9
mn_1 outm outm 0 0 nch W=size:Wn L=size:Ln
mn_2 outp outm 0 0 nch W=size:Wn L=size:Ln
mpin_1 outm inp tail vdd pch W=size:Wp L=size:Lp
mpin_2 outp inn tail vdd pch W=size:Wp L=size:Lp
mp_tail tail vbias vdd vdd pch W=@size:Ls*2*@size:Wp/@size:Lp L=size:Ls
mp_ref  vbias vbias vdd vdd pch W=@size:Ls*2*@size:Wp/@size:Lp L=size:Ls
iref  vbias vdd size:iref
vdd 0 vdd param:vdd
vinp 0 inp param:inp
vinn 0 inn param:inn
