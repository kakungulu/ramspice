set rounds 1
set average 0
@ /struct/dist/type = string
@ /struct/dist/arg1 = string
@ /struct/dist/arg2 = string

### l=18.e-08 
### w=1.5e-6 
### multi=1 
### ad=2*hdifn*w 
### as=2*hdifn*w 
### pd=2*(2*hdifn+w) 
### ps=2*(2*hdifn+w) 
### nrd=hdifn/w 
### nrs=hdifn/w
### lef=l - 20e-9 
### wef=w 
### geo_fac=1 / sqrt(multi * lef * wef * 1e12) 
### vthmis=3.635e-3 * geo_fac * vthnmis 
### dlmis=4.58e-3 * geo_fac * lef * dlnmis 
### dwmis=3.73e-3 * geo_fac * wef * dwnmis 
### toxmis=1.01e-3 * geo_fac * toxn * toxnmis 
### statistics {
###     process {
###         vary par1 dist=unif N=0.57735
###         vary par2 dist=unif N=0.57735
###         vary par3 dist=unif N=0.57735
###         vary par4 dist=unif N=0.57735
###         vary par5 dist=unif N=0.57735
###         }
###     mismatch {
###         vary vthnmis dist=gauss std=1/1
###         vary dlnmis dist=gauss std=1/1
###         vary dwnmis dist=gauss std=1/1
###         vary toxnmis dist=gauss std=1/1
###         vary vthpmis dist=gauss std=1/1
###         vary dlpmis dist=gauss std=1/1
###         vary dwpmis dist=gauss std=1/1
###         vary toxpmis dist=gauss std=1/1
###         }
###     }

@ /simulation_config/mc/nch_mis = string {
    set lef [expr $BSIM_l - 20e-9]
    set wef $BSIM_w 
    set geo_fac [expr 1/sqrt($lef*$wef*1e12)]
    set vthmis [expr 3.635e-3*$geo_fac]
    set dlmis [expr 4.58e-3*$geo_fac*$lef]
    set dwmis [expr 3.73e-3*$geo_fac*$wef]
}

@ /simulation_config/mc/nch_mis/l = /struct/dist gauss * {{$dlmis}}
@ /simulation_config/mc/nch_mis/w = /struct/dist gauss * {{$dwmis}}
@ /simulation_config/mc/nch_mis/vth0 = /struct/dist gauss * {{$vthmis}}

::spice::source $::env(RAMSPICE)/tests/monte_carlo.sp
::spice::op

# Get nominal values to be matched with MC averages
Info: Nominal (gm,Ids)=[bsim mn_0_0 l 360e-9 gm Ids]

# Run MC for gm and Ids
set result [monte_carlo 5000 /simulation_config/mc {
    mn_0_0 gm 
    mn_0_0 Ids
} ::spice::op]
Info: E(gm),std(gm),E(Ids),std(Ids)=$result
