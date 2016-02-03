#@ topologies/$::opt(topology)((Wp,Lp,Wn,Ln,Ws,Ls,Iref|Adc,-Zout,-CMRR,-PSRR,-Area)) !
#if {[file exists $::env(RAMSPICE)/pareto.db]} {
#    @ / load $::env(RAMSPICE)/pareto.db
#}
.param inp = $::opt(topv)/2
.param inn = $::opt(topv)/2
.param vdd = $::opt(topv)
.param rload = 1e30
.param power_factor = 3
.size Lp  = 40e-9 40e-9 10e-6 20e-9
.size Wp  = 40e-9 @size:Lp 10e-6 20e-9
.size Ln  = 40e-9 40e-9 10e-6 20e-9
.size Wn  = 40e-9 @size:Ln 10e-6 20e-9
.size Ls  = 40e-9 40e-9 10e-6 20e-9
.size Ws  = 40e-9 @size:Ls 10e-6 20e-9
.size Lo  = 40e-9 40e-9 10e-6 20e-9
.size Wo  = 40e-9 @size:Lo 10e-6 20e-9
.size iref = $::opt(iref) 1e-6 30e-6 1e-6
mn_1 outm outm 0 0 nch W=size:Wn L=size:Ln
mn_2 midoutp outm 0 0 nch W=size:Wn L=size:Ln
mpin_1 outm inp tail vdd pch W=size:Wp L=size:Lp
mpin_2 midoutp inn tail vdd pch W=size:Wp L=size:Lp
mp_tail tail vbias vdd vdd pch W=size:Ws L=size:Ls
mp_ref  vbias vbias vdd vdd pch W=size:Ws L=size:Ls
mp_out outp vbias vdd vdd pch W=size:Ws L=size:Ls
mn_out outp midoutp 0 0 nch W=size:Wo L=size:Lo
iref  vdd vbias size:iref
vdd 0 vdd param:vdd
vinp 0 inp param:inp
vinn 0 inn param:inn
# rload outp 0 param:rload
#   .property Adc -expression derive(outp,@param:pos)-derive(outp,@param:neg) -denom Det -to_display 20*log10(@) -from_display pow(10,@/20) -unit dB
#   .property CMRR -expression derive(outp,@param:pos)+derive(outp,@param:neg) -denom Det -to_display 20*log10(@) -from_display pow(10,@/20) -unit dB -more worse
#   .property PSRR -expression derive(outp,@param:vdd) -denom Det -to_display 20*log10(@) -from_display pow(10,@/20) -unit dB -more worse
#    .property Zout -expression (@n_tail:go+@nin_2:go)/((@n_tail:go*@nin_2:go)+(@n_tail:go+@nin_2:go)*@p_2:go) -unit Ohm -more worse
# .compile_circuit -out outp -inn @param:neg -inp @param:pos -vdd param:vdd
