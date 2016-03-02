#####################################################################################################
############
############   Initial Conditions
############
#####################################################################################################
*c "if (@$::opt(topology):mode:freash_op) \{"
@ $::opt(topology):/ foreach_child n {
    skip {![@ $::opt(topology):$n:V ?]}
    skip {$n=="vdd"}
    skip {$n=="0"}
    if {[@ $::opt(topology):param:$n ?]} {
        *c "@$n:V=@$::opt(topology):param:$n;"
    } else {
        *c "@$n:V=@$::opt(topology):vdd:V/2;"
    }
}	 
*c "\}"
*c "@$::opt(topology):status:index=0;"
@ $::opt(topology):size foreach_child c {
    if {$::debug_mode} {*c "printf(\"$c=%g\\n\",@$::opt(topology):size:$c);"}
    *c "if(@$::opt(topology):config:size:$c!=0) @$::opt(topology):size:$c=@$::opt(topology):config:size:$c;"
    if {$::debug_mode} {*c "printf(\"$c=%g\\n\",@$::opt(topology):size:$c);"}
}
#####################################################################################################
############
############   Operating Point
############
#####################################################################################################
*c "@$::opt(topology):vdd:V=$::opt(topv);"
*c "@$::opt(topology):0:V=0;"
*c "// Calculating circuit operating point:"
*c "int op_it=0;"
*c "@$::opt(topology):status:fail=-1;"
*c "@$::opt(topology):design_feedback=1000;"
foreach transistor $::all_transistors {
    *c "@$transistor:bin=get_transistor_bin(&@look_up_tables:$::transistors($transistor,type):binning:LUT,@$transistor:L,@$transistor:W);"
}	
if {$::debug_mode} {*c "printf(\"==================================================\\n\");"}
if {$::debug_mode} {*c "printf(\"======%g Operating Point Iterations. ======\\n\",@$::opt(topology):config:op_iterations);"}
if {$::debug_mode} {*c "printf(\"==================================================\\n\");"}
if {$::debug_mode} {*c "fflush(stdout);"}
*c "@$::opt(topology):leak=1e3;"
#    *c "@$::opt(topology):size:iref=50e-6;"
*c "float node_step=0;"
*c "for (op_it=0;(op_it<@$::opt(topology):config:op_iterations)&&((@$::opt(topology):leak>@$::opt(topology):config:kcl_th)||(@$::opt(topology):design_feedback>@$::opt(topology):config:design_feedback_th));op_it++) \{"
*c "float previous_out_dc=@$::output_net:V;"
if {$::debug_mode} {*c "    printf(\"========================= op_it=%d =========================\\n\",op_it);"}
foreach transistor $::all_transistors {
    foreach key [array names ::transistors $transistor,*] {
        set field [regsub {.*,} $key {}]
        set $field $::transistors($key)
    }    
    #       *c "composite_gamma_gcc_interpolate_4(&@look_up_tables:${type}:Ids:ss:LUT,&@look_up_tables:${type}:gm:ss:LUT,&@look_up_tables:${type}:ro:ss:LUT,&(@$transistor:gm),&(@$transistor:go),&(@$transistor:Ids),(@$g:V)-(@$s:V),(@$d:V)-(@$s:V),(@$b:V)-(@$s:V),@$L,@$W);"
    *c "composite_gamma_gcc_interpolate_2p3(@$transistor:bin,&@$::opt(topology):look_up_tables:${type}:Ids:ss:CONTEXT,&@$::opt(topology):look_up_tables:${type}:gm:ss:CONTEXT,&@$::opt(topology):look_up_tables:${type}:go:ss:CONTEXT,&@$::opt(topology):look_up_tables:${type}:gb:ss:CONTEXT,&(@$transistor:gb),&(@$transistor:gm),&(@$transistor:go),&(@$transistor:Ids),(@$g:V)-(@$s:V),(@$d:V)-(@$s:V),(@$b:V)-(@$s:V),@$L,@$W);"
    *c "if (@$transistor:Ids<0) @$transistor:Ids=0;"
    *c "if (@$transistor:Ids>1e-3) @$transistor:Ids=1e-3;"
    if {$type=="pch"} {
        *c "@$transistor:Ids=-@$transistor:Ids;"
    }
    if {$::debug_mode} {*c "printf(\"%d) $transistor L=%g W=%g Vgs=%g Vds=%g Vbs=%g Ids=%g gm=%g go=%g\\n\",op_it,@$L,@$W,(@$g:V)-(@$s:V),(@$d:V)-(@$s:V),(@$b:V)-(@$s:V),@$transistor:Ids,@$transistor:gm,@$transistor:go);"}
    if {$::debug_mode} {*c "fflush(stdout);"}
}
foreach name [array names ::G_equations] {
    *c "@$::opt(topology):Gds_$name=$::G_equations($name);"
    .default Gds_$name 1e+0
}
DET ::MNA
set expression(Det) $::det_calc_result
foreach transistor $::all_transistors {
    if {[info exists ::gm_equations($transistor)]} {
        *c "if (@$transistor:gm==0) @$transistor:gm=1e-6;"
        *c "if (@$transistor:go==0) @$transistor:go=1e-6;"
    }    
}
if {$::debug_mode} {*c "printf(\"iref=%g\\n\",@$::opt(topology):size:iref);"}
*c "// Updating node voltages"
*c "@$::opt(topology):leak=0;"
set i -1
foreach node $::independent_nodes {
    incr i
    DET ::MNA ::MNAy $i
    set expression($node) $::det_calc_result
    Info: ===== $node =====
    Info: $expression($node)
    $node=>($expression($node))*Ted
    skip {$node=="vdd"}
    skip {![info exists ::MNA($i,$i)]}
    skip {$::MNA($i,$i)=="0"}
    set total_Ids  [lindex $::MNAy $i]
    regsub -all Ideq $total_Ids Ids total_Ids
    if {$::debug_mode} {*c "printf(\"$node step=%g/%g=%g*%g=%g\\n\",$total_Ids,$::MNA($i,$i),($total_Ids)/($::MNA($i,$i)),@$::opt(topology):config:step,@$::opt(topology):config:step*($total_Ids)/($::MNA($i,$i)));"}
    regsub -all {[\-\+]?@$::opt(topology):[a-z0-9A-Z_]+:gm} $::MNA($i,$i) {} point_admitance($i)
    *c "node_step=@$::opt(topology):config:kcl_step*($total_Ids)/($point_admitance($i));"
    *c "if (node_step<-0.02) node_step=-0.02;"
    *c "if (node_step>0.02) node_step=0.02;"
    *c "@$node:V+=node_step;"
    *c "if (fabs($total_Ids)>@$::opt(topology):leak) @$::opt(topology):leak=fabs($total_Ids);"
    Info: OP for $node
    *c "if (@$node:V<0) @$node:V=0;"
    *c "if (@$node:V>$::opt(topv)) @$node:V=$::opt(topv);"
    if {$::debug_mode} {*c "printf(\"%d) $node=%g\\n\",op_it,@$node:V);"}
    if {$::debug_mode} {*c "fflush(stdout);"}
}
*c "@$::opt(topology):design_feedback=0;"
if {[info exists ::DESIGN_DEPENDENCES]} {
    foreach net [array names ::DESIGN_DEPENDENCES] {
        *c "if (@$::opt(topology):design_feedback<fabs($::DESIGN_DEPENDENCES($net))) @$::opt(topology):design_feedback=fabs($::DESIGN_DEPENDENCES($net));"
        *c "if (@$::opt(topology):leak<@$::opt(topology):config:design_feedback_activate_th) $net+=0.1*($::DESIGN_DEPENDENCES($net));"
    }
}
if {$::debug_mode} {*c "printf(\"KCL error=%g\\n\",@$::opt(topology):leak);"}
if {$::debug_mode} {*c "fflush(stdout);"}
*c "\}"
*c "if (op_it>=@$::opt(topology):config:op_iterations) \{@$::opt(topology):status:fail=@$::opt(topology):leak; return TCL_ERROR;\}"
foreach transistor $::all_transistors {
    if {[string index $transistor 0]=="n" || [string index $transistor 0]=="N"} {
        *c "if (@$::transistors($transistor,s):V>@$::transistors($transistor,d):V) \{@$::opt(topology):status:fail=3; return TCL_ERROR;\}"
    } else {
        *c "if (@$::transistors($transistor,s):V<@$::transistors($transistor,d):V) \{@$::opt(topology):status:fail=4; return TCL_ERROR;\}"
    }
}
default ::opt(bsim) 0
*c "float W,M;"
if {$::opt(bsim)} {
    source  $::env(RAMSPICE)/Etc/Tech_DB/${::opt(tech)}/binning_${::opt(tech)}.tcl
    set sections {}
    for {set section 1} {[info exists ::bin(p,$section,lmin)]} {incr section} {lappend sections $section}
    *c "float L;"
    *c "int section;"
    foreach transistor $::all_transistors {
        foreach key [array names ::transistors $transistor,*] {
            set field [regsub {.*,} $key {}]
            set $field $::transistors($key)
        }    
        set type_index [lsearch {nch pch} $type]
        *c "Gamma_${::opt(tech)}_Calc($type_index,0,(@$g:V)-(@$s:V),(@$d:V)-(@$s:V),(@$b:V)-(@$s:V),@$L,@$W"
                   foreach pointer {Ids gm gmb go cdd cdg cds cdb csd csg css csb cgd cgg cgs cgb} {
                        *c ",&(@$transistor:${pointer})"
                    } 
                    *c ");"
    }
}
#####################################################################################################
############
############   DC Properties
############
#####################################################################################################
*c "double Det=$expression(Det);"
if {$::debug_mode} {*c "printf(\"Det=%g\\n\",Det);"}
*c "double Ted=1/Det;"
if {$::debug_mode} {*c "printf(\"Ted=%g\\n\",Ted);"}
if {[@ $::opt(topology):param:inn ?] && [@ $::opt(topology):param:inp ?]} {
    set out_node_expression $expression(outp)
    *c "double der_p=[DERIVE @$::opt(topology):param:inp $out_node_expression];"
    *c "double der_n=[DERIVE @$::opt(topology):param:inn $out_node_expression];"
    if {$::debug_mode} {*c "printf(\" der=%g %g\\n\",der_p,der_n);"}
    *c "@$::opt(topology):property:Adc=0.5*Ted*(fabs(der_p)+fabs(der_n));"
    *c "@$::opt(topology):property:CMRR=Ted*(fabs(der_p)-fabs(der_n));"
    *c "@$::opt(topology):property:PSRR=Ted*([DERIVE @$::opt(topology):param:vdd $out_node_expression]);"
} elseif {[@ $::opt(topology):param:in ?]} {
    set out_node_expression $expression(out)
    *c "@$::opt(topology):property:Adc=Ted*([DERIVE @$::opt(topology):param:in $out_node_expression]);"
    *c "@$::opt(topology):property:CMRR=@$::opt(topology):property:Adc;"
    *c "@$::opt(topology):property:PSRR=Ted*([DERIVE @$::opt(topology):param:vdd $out_node_expression]);"
} else {
    Error: param=[@ $::opt(topology):param ?] param:inn=[@ $::opt(topology):param:inn ?] param:inp=[@ $::opt(topology):param:inp ?] param:in=[@ $::opt(topology):param:in ?]
    exit
}
if {$::debug_mode} {*c "printf(\" Adc=%g (%gdB)\\n\",@$::opt(topology):property:Adc,20*log10(fabs(@$::opt(topology):property:Adc)));"}

# if {$::debug_mode} {*c "exit(0);"}
*c "@$::opt(topology):property:Adc=fabs(@$::opt(topology):property:Adc);"
*c "if ((@$::opt(topology):property:Adc<1)&&(@$::opt(topology):config:fail_on_properties)) \{@$::opt(topology):status:fail=2; return TCL_ERROR;\}"
@ $::opt(topology):0:V = 0
.prep_mna zout
DET ::MNA ::MNAy [lsearch $::independent_nodes $::output_net]
set expression(Rout) $::det_calc_result
*c "@$::opt(topology):property:Rout=fabs(($expression(Rout))*Ted);"
#####################################################################################################
############
############   AC Properties
############
#####################################################################################################
.prep_mna ac
DET ::MNA
set expression(Det_ac) $::det_calc_result
if {[set index_out [lsearch $::independent_nodes outp]]!=-1} {
    DET ::MNA ::MNAy $index_out 
    set spectrum_num ([DERIVE @$::opt(topology):param:inp $::det_calc_result])+([DERIVE @$::opt(topology):param:inn $::det_calc_result])
} elseif {[set index_out [lsearch $::independent_nodes out]]!=-1} {	
    DET ::MNA ::MNAy $index_out 
    set spectrum_num [DERIVE @$::opt(topology):param:in $::det_calc_result]
    *c "//AC output: $::det_calc_result/$expression(Det_ac)"
    *c "//AC gain: $spectrum_num/$expression(Det_ac)"
} else {
    Error: No output node in list: $::independent_nodes
    exit
}	
Info: AC
regsub -all {\@$::opt(topology):s} $expression(Det_ac) s expression(Det_ac)
set expression(dDet_ac) [derive_expression s $expression(Det_ac)]
set views {gg gd gs gb dd dg db ds sd sg ss sb bd bg bs bb}
foreach transistor $::all_transistors {
    foreach key [array names ::transistors $transistor,*] {
        set field [regsub {.*,} $key {}]
        set $field $::transistors($key)
    }    
    if {!$::opt(bsim)} {
        foreach view $views {
            set cap c$view
            skip {![@ $::opt(topology):$transistor:$cap ?]}
            *c "@$transistor:$cap=gamma_gcc_interpolate_4(&@$::opt(topology):look_up_tables:${type}:$cap:ss:LUT,(@$g:V)-(@$s:V),(@$d:V)-(@$s:V),(@$b:V)-(@$s:V),@$L)*@$L*@$W*@$::opt(topology):config:${cap}_factor;"
            if {$::debug_mode} {*c "printf(\"$transistor:$cap=%g\\n\",@$transistor:$cap);"}
            set target_node [string index $cap end]
            skip {$::transistors($transistor,$target_node)=="0"}
            skip {$::transistors($transistor,$target_node)=="vdd"}
            set index [lsearch $::independent_nodes $::transistors($transistor,$target_node)]
            skip {$index==-1} 
            skip {![info exists point_admitance($index)]} 
            skip {$point_admitance($index)==0} 
        }
    }
}	    
*c "float s=-1;"
*c "int BW_it;"
if {$::debug_mode} {*c "printf(\"num=$expression(Det_ac)\\n\");"}
if {$::debug_mode} {*c "printf(\"denom=$expression(dDet_ac)\\n\");"}
s2iW $spectrum_num spectrum_num_real spectrum_num_imag
s2iW $expression(Det_ac) spectrum_denom_real spectrum_denom_imag
*c "W=0;"
*c "float BW_Mag0=1;"
*c "float BW_Mag=1;"
*c "float snr;"
*c "float sni;"
*c "float sdr;"
*c "float sdi;"
*c "while ((BW_Mag0/BW_Mag)<2) \{"
*c "      snr=$spectrum_num_real;"
*c "      sni=$spectrum_num_imag;"
*c "      sdr=$spectrum_denom_real;"
*c "      sdi=$spectrum_denom_imag;"
*c "      BW_Mag=(snr*snr+sni*sni)/(sdr*sdr+sdi*sdi);"
*c "      if (W==0) BW_Mag0=BW_Mag;"
#    *c "      printf(\"F=%g fraction=(%g,%g/%g,%g) Adc=%g A=%g/%g=%g phase=%g\\n\",W/(2*3.141592656),snr,sni,sdr,sdi,@$::opt(topology):property:Adc*@$::opt(topology):property:Adc,BW_Mag0,BW_Mag,BW_Mag/BW_Mag0,atan(sni/snr)-atan(sdi/sdr));"
*c "      if (W==0) W=1; else W*=1.01;"
*c "\}"
*c "@$::opt(topology):property:BW=fabs(W/(2*3.141592656));"
*c "for (BW_it=0;BW_it<5;BW_it++)  s-=($expression(Det_ac))/($expression(dDet_ac));"
*c "@$::opt(topology):property:BW:s=$expression(dDet_ac);"
*c "@$::opt(topology):p1=-s;"
if {$::debug_mode} {*c "printf(\"BW=%g\\n\",@$::opt(topology):property:BW);"}
*c "if (!isfinite(@$::opt(topology):property:BW))  \{@$::opt(topology):status:fail=8; return TCL_ERROR;\}"
# Move away from the found root 
*c "s-=1e3;"
# Find next root (=pole)
*c "for (BW_it=0;BW_it<20;BW_it++)  s-=(($expression(Det_ac))*(s+@$::opt(topology):p1-5e2))/(($expression(dDet_ac))*(s+@$::opt(topology):p1-5e2)-($expression(Det_ac)));"
*c "@$::opt(topology):p2=-s;"
if {$::debug_mode} {*c "printf(\"Poles: %g    %g\\n\",@$::opt(topology):p1,@$::opt(topology):p2);"}
*c "if (!isfinite(@$::opt(topology):p1)) \{"
*c "    @$::opt(topology):property:ts=1/@$::opt(topology):property:BW;"
*c "\} else if (!isfinite(@$::opt(topology):p2)) \{"
*c "    @$::opt(topology):property:ts=-log(0.02)/@$::opt(topology):p1;"
*c "\} else \{"
*c "    float A1=-@$::opt(topology):p2/(-@$::opt(topology):p1+@$::opt(topology):p2);"
*c "    float A2=-@$::opt(topology):p1/(-@$::opt(topology):p1+@$::opt(topology):p2);"
*c "    @$::opt(topology):property:ts=0;"
*c "    for (BW_it=0;BW_it<10;BW_it++) @$::opt(topology):property:ts-=(0.02+A1*exp(-@$::opt(topology):p1*@$::opt(topology):property:ts)+A2*exp(-@$::opt(topology):p2*@$::opt(topology):property:ts))/(-@$::opt(topology):p1*A1*exp(-@$::opt(topology):p1*@$::opt(topology):property:ts)-@$::opt(topology):p2*A2*exp(-@$::opt(topology):p2*@$::opt(topology):property:ts));"
*c "\}"
*c "if (!isfinite(@$::opt(topology):property:ts)) \{"
*c "    @$::opt(topology):property:ts=1/@$::opt(topology):property:BW;"
*c "\}"
foreach transistor $::all_transistors {
    skip {![regexp {^[np]in} $transistor]}
    *c "@$::opt(topology):property:Cin=@$transistor:cgd+@$transistor:cgs;"
    *c "@$::opt(topology):property:PM=(@$::opt(topology):property:BW/9.76e8)+(@$::opt(topology):property:Adc-21)-sqrt(@$::transistors($transistor,L)*@$::transistors($transistor,W))/5e-7-@$::opt(topology):size:iref*2.5e4;"
    *c "@$::opt(topology):property:PM=(@$::opt(topology):property:PM*180/3.1415)/2.16+29-1.4-0.75/2;"
    *c "while (@$::opt(topology):property:PM<0) @$::opt(topology):property:PM+=360;"
    *c "while (fabs(@$::opt(topology):property:PM)>180) @$::opt(topology):property:PM-=360;"
    *c "@$::opt(topology):property:PM=fabs(@$::opt(topology):property:PM);"
    break
}	
*c "while (BW_Mag>4) \{"
*c "      snr=$spectrum_num_real;"
*c "      sni=$spectrum_num_imag;"
*c "      sdr=$spectrum_denom_real;"
*c "      sdi=$spectrum_denom_imag;"
*c "      BW_Mag=(snr*snr+sni*sni)/(sdr*sdr+sdi*sdi);"
*c "      W*=1.01;"
*c "\}"
*c "@$::opt(topology):property:PM=180-180*(atan(sni/snr)-atan(sdi/sdr))/3.1415926;"
if {$::debug_mode} {*c "printf(\"Settling time=%g\\n\",@$::opt(topology):property:ts);"}

#####################################################################################################
############
############   Noise 
############
#####################################################################################################
foreach transistor $::all_transistors {
    set L $::transistors($transistor,L)
    set W $::transistors($transistor,W)
    *c "@$transistor:Nt_unit=$::Nt_equations($transistor);"
    *c "@$transistor:Nt=@$transistor:Nt_unit*@$transistor:go;"
    *c "if (!isfinite(@$transistor:Nt))  \{@$::opt(topology):status:fail=5; return TCL_ERROR;\}"
    *c "@$transistor:Nf_unit=$::Nf_equations($transistor);"
    *c "@$transistor:Nf=@$transistor:Nf_unit*@$transistor:go*@$transistor:go/(@$W*@$L);"
    *c "if (!isfinite(@$transistor:Nf))  \{@$::opt(topology):status:fail=6; return TCL_ERROR;\}"
    if {0} {*c "printf(\"$transistor Nt=%gA^2/Hz Nf(f=1Hz)=%gA^2/Hz\\n\",@$transistor:Nt,@$transistor:Nf);"}
}
foreach transistor $::all_transistors {
    *c "float current_transfer_$transistor=Ted*([DERIVE @$transistor:Ideq $out_node_expression])/@$::opt(topology):property:Adc;"
    if {0} {*c "printf(\"$transistor:noise_trans=%gOhm\\n\",current_transfer_$transistor);"}
} 
foreach noise_type {t f} {   
    set chain {}
    foreach transistor $::all_transistors {
        lappend chain current_transfer_$transistor*current_transfer_$transistor*@$transistor:N$noise_type
    }
    if {$chain=={}} {
        set chain 0
    }
    *c "@$::opt(topology):property:N$noise_type=([join $chain +])/@$::opt(topology):property:Adc;"
}
foreach transistor $::all_transistors {
    if {$::debug_mode} {*c "printf(\"$transistor:  Nt=%g (%g%%)  Nf=%g (%g%%)\\n\",@$transistor:Nt,100*@$transistor:noise_trans*@$transistor:noise_trans*@$transistor:Nt/@$::opt(topology):property:Nt,@$transistor:Nf,100*@$transistor:noise_trans*@$transistor:noise_trans*@$transistor:Nf/@$::opt(topology):property:Nf);"}
}
*c "@$::opt(topology):property:fc=@$::opt(topology):property:Nf/@$::opt(topology):property:Nt;"
*c "@$::opt(topology):property:TotalNoise=(log(2*@$::opt(topology):property:BW)*@$::opt(topology):property:Nf+2*@$::opt(topology):property:BW*@$::opt(topology):property:Nt);"
if {[@ $::opt(topology):param:inn ?] && [@ $::opt(topology):param:inp ?]} {
    *c "@$::opt(topology):property:TotalNoise/=2;"
}	
if {0} {*c "printf(\"Adc=%gdB BW=%gHz fc=%g Nf(f=1Hz)=%gV^2/Hz Nt=%gV^2/Hz TN=%gV^2\\n\",20*log10(@$::opt(topology):property:Adc),@$::opt(topology):property:BW,@$::opt(topology):property:fc,@$::opt(topology):property:Nf,@$::opt(topology):property:Nt,@$::opt(topology):property:TotalNoise); if (@$::opt(topology):property:Adc>600) exit(0);"}
if {$::debug_mode} {*c "printf(\"Corner=%g\\n\",@$::opt(topology):property:fc);"}

#####################################################################################################
############
############   Area, Power, etc. 
############
#####################################################################################################
set chain {}
foreach transistor $::all_transistors {
    set l  $::transistors($transistor,L)
    set w  $::transistors($transistor,W)
    lappend chain "@$w*@$l"
    if {$::debug_mode} {*c "printf(\"Transistor $transistor contributes %g*(%g+%g)=%g\\n\",@$w,@$l,@$::opt(topology):area_spacing,@$w*(@$l+@$::opt(topology):area_spacing));"}
}
*c "@$::opt(topology):property:Area=1e12*([join $chain +]);"	
if {$::debug_mode} {*c "printf(\"Temporary Area=%g\\n\",@$::opt(topology):property:Area);"}
*c "float single_transistor_vos;"
*c "@$::opt(topology):property:Vos=0;"
foreach transistor $::all_transistors {
    skip {![regexp {^in} $::transistors($transistor,g)]}
    if {$::transistors($transistor,type)=="pch"} {
        *c "single_transistor_vos=vos(-@$transistor:Ids*@$::transistors($transistor,L)/@$::transistors($transistor,W),@$::opt(topology):property:Area);"
    } else {
        *c "single_transistor_vos=vos(@$transistor:Ids*@$::transistors($transistor,L)/@$::transistors($transistor,W),@$::opt(topology):property:Area);"
    }
    *c "@$::opt(topology):property:Vos+=single_transistor_vos*single_transistor_vos;"
}	
*c "@$::opt(topology):property:Vos=1e-3*sqrt(@$::opt(topology):property:Vos);"
*c "@$::opt(topology):property:Power=0;"
foreach transistor $::all_transistors {
    foreach key [array names ::transistors $transistor,*] {
        set field [regsub {.*,} $key {}]
        set $field $::transistors($key)
    }    
    *c "@$::opt(topology):property:Power+=fabs(@$transistor:Ids*((@$d:V)-(@$s:V)));"
}
@ $::opt(topology):property foreach_child p {
    if {[lsearch {Adc CMRR PSRR} $p]!=-1} {
        *c "@$::opt(topology):property:$p=20*log10(fabs(@$::opt(topology):property:$p));"
        if {$p!="Adc"} {
            *c "@$::opt(topology):property:$p=@$::opt(topology):property:Adc-@$::opt(topology):property:$p;"
        }
    }
    if {$::debug_mode} {*c "printf(\"Final $p=%g\\n\",@$::opt(topology):property:$p);"}
}

*c "if (@$::opt(topology):max_Adc<@$::opt(topology):property:Adc) @$::opt(topology):max_Adc=@$::opt(topology):property:Adc;"
#####################################################################################################
############
############   PAT 
############
#####################################################################################################
*c "PAT *p=(PAT *)&@$::opt(topology):circuits:PAT;"
set index 0
@ $::opt(topology):size foreach_child s {
    incr index
}	
@ $::opt(topology):/ foreach_child n {
    skip {![@ $::opt(topology):$n:V ?]}
    skip {$n=="vdd"}
    skip {$n=="0"}
    skip {[@ $::opt(topology):param:$n ?]}
    incr index
}
*c "float sizes\[$index\];"
set index 0
@ $::opt(topology):size foreach_child s {
    *c "sizes\[$index\]=@$::opt(topology):size:$s;"
    incr index
}	
@ $::opt(topology):/ foreach_child n {
    skip {![@ $::opt(topology):$n:V ?]}
    skip {$n=="vdd"}
    skip {$n=="0"}
    skip {[@ $::opt(topology):param:$n ?]}
    *c "sizes\[$index\]=@$n:V;"
    incr index
}
set index 0
@ $::opt(topology):property foreach_child p {
    incr index
}	
*c "float properties\[$index\];"
set index 0
@ $::opt(topology):property foreach_child p {
    *c "if ((@$::opt(topology):config:factor:$p!=0)||(@$::opt(topology):config:shift:$p!=0)) @$::opt(topology):property:$p=@$::opt(topology):property:$p*@$::opt(topology):config:factor:$p+@$::opt(topology):config:shift:$p;"
    *c "properties\[$index\]=@$::opt(topology):property:$p;"
    incr index
}	
*c "@$::opt(topology):status:fail=op_it;"
*c "@$::opt(topology):status:index=add_pat_array(p,sizes,properties);"
if {$::debug_mode} {*c "printf(\"PAT contains %d entries\\n\",p->content->num_of);"}
