@ $::opt(topo):mode:freash_op = 1
@ $::opt(topo):status/fail = 0
@ $::opt(topo):status/index = 0
@ $::opt(topo):config/op_iterations = 5000
@ $::opt(topo):config/design_feedback_th = 1e-3
@ $::opt(topo):config/design_feedback_activate_th = 1e-6
@ $::opt(topo):config/kcl_th = 1e-9
@ $::opt(topo):config/kcl_step = 0.03
@ $::opt(topo):config/step = 0.05
@ $::opt(topo):config/fail_on_properties = 1
foreach property {Adc CMRR PSRR Vos Rout BW PM Cin ts Nt Nf TotalNoise fc Area Power} {
    @ $::opt(topo):config/factor/$property = 0
    @ $::opt(topo):config/shift/$property = 0
}
default ::opt(cap_factor) 3


@ $::opt(topo):config:cgg_factor = 1 
@ $::opt(topo):config:cgd_factor = 1  
@ $::opt(topo):config:cgs_factor = 1  
@ $::opt(topo):config:cgb_factor = 1  
@ $::opt(topo):config:cdd_factor = 1 
@ $::opt(topo):config:cdg_factor = 1 
@ $::opt(topo):config:cds_factor = 1 
@ $::opt(topo):config:cdb_factor = 1 
@ $::opt(topo):config:csd_factor = 1 
@ $::opt(topo):config:csg_factor = 1 
@ $::opt(topo):config:css_factor = 1 
@ $::opt(topo):config:csb_factor = 1 
@ $::opt(topo):config:cbd_factor = 1 
@ $::opt(topo):config:cbg_factor = 1 
@ $::opt(topo):config:cbs_factor = 1 
@ $::opt(topo):config:cbb_factor = 1 

