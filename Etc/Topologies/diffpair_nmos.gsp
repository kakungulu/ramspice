.param inp = $::opt(topv)/2
.param inn = $::opt(topv)/2
.param vdd = $::opt(topv)
.size iref = $::opt(iref) 1e-6 100e-6 1e-6
.size Lp  = $::global_nlmin $::global_nlmin 3e-6 20e-9
.size Wp  = $::global_nlmin @size:Lp 10e-6 20e-9
.size Ln  = $::global_nlmin $::global_nlmin 3e-6 20e-9
.size Wn  = $::global_nlmin @size:Ln 10e-6 20e-9
.size Ls  = $::global_nlmin $::global_nlmin 3e-6 20e-9
mp_1 outm outm vdd vdd pch W=size:Wp L=size:Lp
mp_2 outp outm vdd vdd pch W=size:Wp L=size:Lp
mnin_1 outm inp tail 0 nch W=size:Wn L=size:Ln
mnin_2 outp inn tail 0 nch W=size:Wn L=size:Ln
mntail tail vbias 0 0 nch W=@size:Ls*2*@size:Wn/@size:Ln L=size:Ls
mnref  vbias vbias 0 0 nch W=@size:Ls*2*@size:Wn/@size:Ln L=size:Ls
iref   vbias vdd size:iref
vdd 0 vdd @param:vdd
vinp 0 inp @param:inp
vinn 0 inn @param:inn
