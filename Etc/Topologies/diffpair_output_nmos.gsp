.param inp = $::opt(topv)/2
.param inn = $::opt(topv)/2
.param vdd = $::opt(topv)
.param rload = 1e30
.param power_factor = 3
.size Lp  = $::global_nlmin $::global_nlmin 3e-6 20e-9
.size Wp  = $::global_nlmin @size:Lp 100e-6 20e-9
.size Ln  = $::global_nlmin $::global_nlmin 3e-6 20e-9
.size Wn  = $::global_nlmin @size:Ln 100e-6 20e-9
.size Ls  = $::global_nlmin $::global_nlmin 3e-6 20e-9
.size Lo  = 40e-9 40e-9 10e-6 20e-9
.size Wo  = 40e-9 @size:Lo 100e-6 20e-9
.size iref = $::opt(iref) 1e-6 30e-6 1e-6
mp_1 outm outm vdd vdd pch W=size:Wp L=size:Lp
mp_2 midoutp outm vdd vdd pch W=size:Wp L=size:Lp
mnin_1 outm inp tail 0 nch W=size:Wn L=size:Ln
mnin_2 midoutp inn tail 0 nch W=size:Wn L=size:Ln
mn_tail tail vbias 0 0 nch W=@size:Ls*2*@size:Wn/@size:Ln L=size:Ls
mn_ref  vbias vbias 0 0 nch W=@size:Ls*2*@size:Wn/@size:Ln L=size:Ls
mn_out outp vbias 0 0 nch W=@size:Ls*@size:Wn/@size:Ln L=size:Ls
mp_out outp midoutp vdd vdd pch W=size:Wo L=size:Lo
iref  vbias vdd size:iref
vdd 0 vdd param:vdd
vinp 0 inp param:inp
vinn 0 inn param:inn
