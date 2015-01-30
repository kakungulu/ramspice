# \
exec $RAMSPICE/ramspice $0 $argv

get_opts
load_tech

default opt(tech) tsmc018
default opt(temp) 27
default opt(bsim_version) 3v32
set ::bsim_version $opt(bsim_version)
set scaling [expr (6.8/5.8)*12.5]
set scaling 12
@ /struct/dist/type = string
@ /struct/dist/arg1 = string
@ /struct/dist/arg2 = string

# vthmis=3.635e-3 * geo_fac * vthnmis 
# dlmis=4.58e-3 * geo_fac * lef * dlnmis 
# dwmis=3.73e-3 * geo_fac * wef * dwnmis 
# toxmis=1.01e-3 * geo_fac * toxn * toxnmis 
for {set i 1} {$i<=16} {incr i} {
    @ /simulation_config/mc/nch_mc_$i = string {
        set lef [expr $BSIM_l - 20e-9]
        set wef $BSIM_w 
        set toxn 4.08e-9 
        set geo_fac [expr 1/sqrt($lef*$wef*1e12)]
        set vthmis [expr $scaling*3.635e-3*$geo_fac]
        set dlmis [expr $scaling*4.58e-3*$geo_fac*$lef]
        set dwmis [expr $scaling*3.73e-3*$geo_fac*$wef]
        set toxmis [expr $scaling*1.01e-3*$geo_fac*$toxn]
    }
    @ /simulation_config/mc/nch_mc_$i/l = /struct/dist gauss * {{$dlmis}}
    @ /simulation_config/mc/nch_mc_$i/w = /struct/dist gauss * {{$dwmis}}
    @ /simulation_config/mc/nch_mc_$i/vth0 = /struct/dist gauss * {{$vthmis}}
    @ /simulation_config/mc/nch_mc_$i/tox = /struct/dist gauss * {{$toxmis}}
}
######### Template netlist
netlist ".include $::env(RAMSPICE)/Tech_DB/$opt(tech)/$opt(tech).sp"
netlist {
    ** the N-transistor
    * name D G S B model L W 
}
netlist ".temp $opt(temp)"
set Lmin $::global_nlmin
set vars_of_interest {mn Vth mn Ids}
set L $opt(L)
set W $opt(W)
set section [find_mosfet_bin n $L $W]
foreach v {Vbs Vgs Vds} {
    default opt($v) 0
}
netlist "mn 3 1 5 4 nch_mc_${section} L=$L W=$W AD=[expr 2.5*$Lmin*$W] AS=[expr 2.5*$Lmin*$W] PD=[expr 5*$Lmin+$W] PS=[expr 5*$Lmin+$W]"
netlist "r 5 0 1e-12"
netlist "Vds 3 0 dc $opt(Vds) ac 0"
netlist "Vgs 1 0 dc $opt(Vgs) ac 0"
netlist "Vbs 4 0 dc $opt(Vbs) ac 0"
netlist .end
set O [open test.sn w]
puts $O $template_netlist
close $O
update_netlist

Info:  Measuring mis(W,L)
######### Characterizing loops
Info: simulation started ([clock format [clock seconds]])
set result [monte_carlo_${::bsim_version} 2000 /simulation_config/mc $vars_of_interest ::spice::op]
Info: done Mismatch running. Saving results. ([clock format [clock seconds]])
foreach var {Vth Sigma_Vth Ids Sigma_Ids} val $result {
    set $var $val
}
Info: Done ([clock format [clock seconds]]) Ids=[eng $Ids A] Sigma=[eng $Sigma_Ids A] ([eng [expr $Sigma_Ids/$Ids*100] %]) 
exit
