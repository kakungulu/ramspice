# \
exec $RAMSPICE/ramspice $0 $argv

get_opts




@ /test_vars/a !
@ /test_vars/F !
@ /test_vars/a = real 3.0
@ /test_vars/b !
@ /test_vars/b = real 8.0
@ /test_vars/F = real 5.0
Info: a = [@ /test_vars/a]
.init
@ /test_vars cd
### # Program
###     GammaCommandPushVar a
###     GammaCommandPushVar b
###     GammaCommandMult
### .label: MainLoop
###     GammaCommandPush 6.0
###     GammaCommandAtLeast
###     GammaCommandStop
###     GammaCommandPop
###     GammaCommandPush 1.0
###     GammaCommandPlus
###     GammaCommandDumpStack
###     GammaCommandGoto $MainLoop

# compile_Gamma_expression (a+2*b+interpolate(ceil(a/4),b*3))/(b+3)
# compile_Gamma_expression (a+7)/(b+3)
# GammaCommandDumpStack
# GammaCommandStop
# Test
# .reset
# .run
Info: b = [@ b]
Info: F = [@ F]
@ cost !
@ cost = real 0
# .property Ids=interpolate(&Ids,Vgs,Vds,Vbs,L)*W/L -unit A -min 0 -max 1.0
.function square(x)=x*x
# .property F=(a*7-square(2))/(b+square(3))

.function distance(x,y,z)=square(abs(x/y-1)*100)
.property cost=distance(a,b,0)

@ A(2,2) !
array_set_legend A 0 0 0 
array_set_legend A 0 1 1 
array_set_legend A 1 0 0 
array_set_legend A 1 1 1 
@ A(0,0) = 0
@ A(0,1) = 1
@ A(1,0) = 2
@ A(1,1) = 3
@ I !
@ I = real 0
@ W !
@ L !
@ W = real 0.7
@ L = real 0.3
.property I=interpolate(W,L,&A)*(W/L)
.label: start_here
     .calculate I
     GammaCommandDumpStack
     GammaCommandStop
@ cost = real 0
.run   $start_here
Info: Result=[@ I]
exit
