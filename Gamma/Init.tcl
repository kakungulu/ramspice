@ mode:fresh_op = 1
@ status/fail = 0
@ status/index = 0
@ config/op_iterations = 5000
@ config/design_feedback_th = 1e-3
@ config/design_feedback_activate_th = 1e-6
@ config/kcl_th = 1e-9
@ config/kcl_step = 0.03
@ config/step = 0.05
@ config/fail_on_properties = 1
foreach property {Adc CMRR PSRR Vos Rout BW PM Cin ts Nt Nf TotalNoise fc Area Power} {
    @ config/factor/$property = 0
    @ config/shift/$property = 0
}
default ::opt(cap_factor) 3


@ config:cgg_factor = 1 
@ config:cgd_factor = 1  
@ config:cgs_factor = 1  
@ config:cgb_factor = 1  
@ config:cdd_factor = 1 
@ config:cdg_factor = 1 
@ config:cds_factor = 1 
@ config:cdb_factor = 1 
@ config:csd_factor = 1 
@ config:csg_factor = 1 
@ config:css_factor = 1 
@ config:csb_factor = 1 
@ config:cbd_factor = 1 
@ config:cbg_factor = 1 
@ config:cbs_factor = 1 
@ config:cbb_factor = 1 

