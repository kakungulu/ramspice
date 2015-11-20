@ mode:fresh_op = 1
@ status/fail = 0
@ status/index = 0
@ config/op_iterations = 500
@ config/design_feedback_th = 1e-3
@ config/design_feedback_activate_th = 1e-6
@ config/kcl_th = 2e-7
@ config/kcl_step = 0.03
@ config/step = 0.05
@ config/fail_on_properties = 1
foreach property {Adc CMRR PSRR Vos Rout BW PM Cin ts Nt Nf TotalNoise fc Area Power} {
    @ config/factor/$property = 0
    @ config/shift/$property = 0
}
default ::opt(cap_factor) 5
@ look_up_tables:pch:cox = [expr 0.000148906*$::opt(cap_factor)] 
@ look_up_tables:nch:cox = [expr 0.00015696*$::opt(cap_factor)] 
