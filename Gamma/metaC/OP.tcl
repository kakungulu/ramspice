    #####################################################################################################
    ############
    ############   Initial Conditions
    ############
    #####################################################################################################
    *c "if (@mode:freash_op) \{"
    @ / foreach_child n {
        skip {![@ $n:V ?]}
        skip {$n=="vdd"}
        skip {$n=="0"}
        if {[@ param:$n ?]} {
            *c "@$n:V=@param:$n;"
        } else {
            *c "@$n:V=@vdd:V/2;"
        }
    }	 
    *c "\}"
    *c "@status:index=0;"
    @ size foreach_child c {
            if {$::debug_mode} {*c "printf(\"$c=%g\\n\",@size:$c);"}
	    *c "if(@config:size:$c!=0) @size:$c=@config:size:$c;"
            if {$::debug_mode} {*c "printf(\"$c=%g\\n\",@size:$c);"}
    }
    #####################################################################################################
    ############
    ############   Operating Point
    ############
    #####################################################################################################
    *c "@vdd:V=$::opt(topv);"
    *c "@0:V=0;"
    *c "// Calculating circuit operating point:"
    *c "int op_it=0;"
    *c "@status:fail=-1;"
    *c "@design_feedback=1000;"
    if {$::debug_mode} {*c "printf(\"==================================================\\n\");"}
    if {$::debug_mode} {*c "printf(\"======%g Operating Point Iterations. ======\\n\",@config:op_iterations);"}
    if {$::debug_mode} {*c "printf(\"==================================================\\n\");"}
    if {$::debug_mode} {*c "fflush(stdout);"}
    *c "@leak=1e3;"
#    *c "@size:iref=50e-6;"
    *c "float node_step=0;"
    *c "for (op_it=0;(op_it<@config:op_iterations)&&((@leak>@config:kcl_th)||(@design_feedback>@config:design_feedback_th));op_it++) \{"
    *c "float previous_out_dc=@$::output_net:V;"
    if {$::debug_mode} {*c "    printf(\"========================= op_it=%d =========================\\n\",op_it);"}
    foreach transistor $::all_transistors {
        foreach key [array names ::transistors $transistor,*] {
	    set field [regsub {.*,} $key {}]
	    set $field $::transistors($key)
	}    
 #       *c "composite_gamma_gcc_interpolate_4(&@look_up_tables:${type}:Ids:ss:LUT,&@look_up_tables:${type}:gm:ss:LUT,&@look_up_tables:${type}:ro:ss:LUT,&(@$transistor:gm),&(@$transistor:go),&(@$transistor:Ids),(@$g:V)-(@$s:V),(@$d:V)-(@$s:V),(@$b:V)-(@$s:V),@$L,@$W);"
        *c "composite_gamma_gcc_interpolate_2p3(&@look_up_tables:${type}:Ids:ss:LUT,&@look_up_tables:${type}:gm:ss:LUT,&@look_up_tables:${type}:go:ss:LUT,&@look_up_tables:${type}:gb:ss:LUT,&(@$transistor:gb),&(@$transistor:gm),&(@$transistor:go),&(@$transistor:Ids),(@$g:V)-(@$s:V),(@$d:V)-(@$s:V),(@$b:V)-(@$s:V),@$L,@$W);"
	*c "if (@$transistor:Ids<0) @$transistor:Ids=0;"
	*c "if (@$transistor:Ids>1e-3) @$transistor:Ids=1e-3;"
	if {$type=="pch"} {
	    *c "@$transistor:Ids=-@$transistor:Ids;"
	}
        if {$::debug_mode} {*c "printf(\"%d) $transistor L=%g W=%g Vgs=%g Vds=%g Vbs=%g Ids=%g gm=%g go=%g\\n\",op_it,@$L,@$W,(@$g:V)-(@$s:V),(@$d:V)-(@$s:V),(@$b:V)-(@$s:V),@$transistor:Ids,@$transistor:gm,@$transistor:go);"}
        if {$::debug_mode} {*c "fflush(stdout);"}
    }
    foreach name [array names ::G_equations] {
        *c "@Gds_$name=$::G_equations($name);"
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
    if {$::debug_mode} {*c "printf(\"iref=%g\\n\",@size:iref);"}
    *c "// Updating node voltages"
	*c "@leak=0;"
	set i -1
    foreach node $::independent_nodes {
        incr i
        DET ::MNA ::MNAy $i
	set expression($node) $::det_calc_result
	Info: ===== $node =====
	Info: $expression($node)
        $node=>($expression($node))*@Ted
        skip {$node=="vdd"}
        skip {![info exists ::MNA($i,$i)]}
	skip {$::MNA($i,$i)=="0"}
	set total_Ids  [lindex $::MNAy $i]
	regsub -all Ideq $total_Ids Ids total_Ids
        if {$::debug_mode} {*c "printf(\"$node step=%g/%g=%g*%g=%g\\n\",$total_Ids,$::MNA($i,$i),($total_Ids)/($::MNA($i,$i)),@config:step,@config:step*($total_Ids)/($::MNA($i,$i)));"}
	regsub -all {[\-\+]?@[a-z0-9A-Z_]+:gm} $::MNA($i,$i) {} point_admitance($i)
	*c "node_step=@config:kcl_step*($total_Ids)/($point_admitance($i));"
	*c "if (node_step<-0.02) node_step=-0.02;"
	*c "if (node_step>0.02) node_step=0.02;"
	*c "@$node:V+=node_step;"
	*c "if (fabs($total_Ids)>@leak) @leak=fabs($total_Ids);"
	Info: OP for $node
        *c "if (@$node:V<0) @$node:V=0;"
        *c "if (@$node:V>$::opt(topv)) @$node:V=$::opt(topv);"
        if {$::debug_mode} {*c "printf(\"%d) $node=%g\\n\",op_it,@$node:V);"}
        if {$::debug_mode} {*c "fflush(stdout);"}
    }
    *c "@design_feedback=0;"
    if {[info exists ::DESIGN_DEPENDENCES]} {
        foreach net [array names ::DESIGN_DEPENDENCES] {
	    *c "if (@design_feedback<fabs($::DESIGN_DEPENDENCES($net))) @design_feedback=fabs($::DESIGN_DEPENDENCES($net));"
	    *c "if (@leak<@config:design_feedback_activate_th) $net+=0.1*($::DESIGN_DEPENDENCES($net));"
	}
    }
    if {$::debug_mode} {*c "printf(\"KCL error=%g\\n\",@leak);"}
    if {$::debug_mode} {*c "fflush(stdout);"}
    *c "\}"
    *c "if (op_it>=@config:op_iterations) \{@status:fail=@leak; return TCL_ERROR;\}"
    foreach transistor $::all_transistors {
        if {[string index $transistor 0]=="n" || [string index $transistor 0]=="N"} {
            *c "if (@$::transistors($transistor,s):V>@$::transistors($transistor,d):V) \{@status:fail=3; return TCL_ERROR;\}"
        } else {
            *c "if (@$::transistors($transistor,s):V<@$::transistors($transistor,d):V) \{@status:fail=4; return TCL_ERROR;\}"
        }
    }
    #####################################################################################################
    ############
    ############   DC Properties
    ############
    #####################################################################################################
    *c "@Det=$expression(Det);"
    if {$::debug_mode} {*c "printf(\"Det=%g\\n\",@Det);"}
    *c "@Ted=1/@Det;"
     if {$::debug_mode} {*c "printf(\"Ted=%g\\n\",@Ted);"}
   if {[@ param:inn ?] && [@ param:inp ?]} {
        set out_node_expression $expression(outp)
        *c "double der_p=[DERIVE @param:inp $out_node_expression];"
        *c "double der_n=[DERIVE @param:inn $out_node_expression];"
        if {$::debug_mode} {*c "printf(\" der=%g %g\\n\",der_p,der_n);"}
       *c "@property:Adc=0.5*Ted*(fabs(der_p)+fabs(der_n));"
        *c "@property:CMRR=Ted*(fabs(der_p)-fabs(der_n));"
        *c "@property:PSRR=Ted*([DERIVE @param:vdd $out_node_expression]);"
    } elseif {[@ param:in ?]} {
        set out_node_expression $expression(out)
        *c "@property:Adc=Ted*([DERIVE @param:in $out_node_expression]);"
        *c "@property:CMRR=@property:Adc;"
        *c "@property:PSRR=Ted*([DERIVE @param:vdd $out_node_expression]);"
    } else {
        Error: param=[@ param ?] param:inn=[@ param:inn ?] param:inp=[@ param:inp ?] param:in=[@ param:in ?]
	exit
    }
    if {$::debug_mode} {*c "printf(\" Adc=%g (%gdB)\\n\",@property:Adc,20*log10(fabs(@property:Adc)));"}
    
   # if {$::debug_mode} {*c "exit(0);"}
    *c "@property:Adc=fabs(@property:Adc);"
    *c "if ((@property:Adc<1)&&(@config:fail_on_properties)) \{@status:fail=2; return TCL_ERROR;\}"
    @ 0:V = 0
    .prep_mna zout
    DET ::MNA ::MNAy [lsearch $::independent_nodes $::output_net]
    set expression(Rout) $::det_calc_result
    *c "@property:Rout=fabs(($expression(Rout))*@Ted);"
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
        set spectrum_num ([DERIVE @param:inp $::det_calc_result])+([DERIVE @param:inn $::det_calc_result])
    } elseif {[set index_out [lsearch $::independent_nodes out]]!=-1} {	
        DET ::MNA ::MNAy $index_out 
        set spectrum_num [DERIVE @param:in $::det_calc_result]
	*c "//AC output: $::det_calc_result/$expression(Det_ac)"
	*c "//AC gain: $spectrum_num/$expression(Det_ac)"
    } else {
        Error: No output node in list: $::independent_nodes
	exit
    }	
    Info: AC
    set expression(dDet_ac) [derive_expression @s $expression(Det_ac)]
    set views {gg gd gs gb dd dg db ds sd sg ss sb bd bg bs bb}
    foreach transistor $::all_transistors {
        foreach key [array names ::transistors $transistor,*] {
	    set field [regsub {.*,} $key {}]
	    set $field $::transistors($key)
	}    
        foreach view $views {
	    set cap c$view
            skip {![@ $transistor:$cap ?]}
            *c "@$transistor:$cap=gamma_gcc_interpolate_4(&@look_up_tables:${type}:$cap:ss:LUT,(@$g:V)-(@$s:V),(@$d:V)-(@$s:V),(@$b:V)-(@$s:V),@$L)*@$L*@$W*@config:${cap}_factor;"
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
    *c "@s=-1;"
    *c "int BW_it;"
    if {$::debug_mode} {*c "printf(\"num=$expression(Det_ac)\\n\");"}
    if {$::debug_mode} {*c "printf(\"denom=$expression(dDet_ac)\\n\");"}
    s2iW $spectrum_num spectrum_num_real spectrum_num_imag
    s2iW $expression(Det_ac) spectrum_denom_real spectrum_denom_imag
    *c "float W=0;"
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
#    *c "      printf(\"F=%g fraction=(%g,%g/%g,%g) Adc=%g A=%g/%g=%g phase=%g\\n\",W/(2*3.141592656),snr,sni,sdr,sdi,@property:Adc*@property:Adc,BW_Mag0,BW_Mag,BW_Mag/BW_Mag0,atan(sni/snr)-atan(sdi/sdr));"
    *c "      if (W==0) W=1; else W*=1.01;"
    *c "\}"
    *c "@property:BW=fabs(W/(2*3.141592656));"
    *c "for (BW_it=0;BW_it<5;BW_it++)  @s-=($expression(Det_ac))/($expression(dDet_ac));"
    *c "@property:BW:s=$expression(dDet_ac);"
    *c "@p1=-@s;"
    if {$::debug_mode} {*c "printf(\"BW=%g\\n\",@property:BW);"}
    *c "if (!isfinite(@property:BW))  \{@status:fail=8; return TCL_ERROR;\}"
    # Move away from the found root 
    *c "@s-=1e3;"
    # Find next root (=pole)
    *c "for (BW_it=0;BW_it<20;BW_it++)  @s-=(($expression(Det_ac))*(@s+@p1-5e2))/(($expression(dDet_ac))*(@s+@p1-5e2)-($expression(Det_ac)));"
    *c "@p2=-@s;"
    if {$::debug_mode} {*c "printf(\"Poles: %g    %g\\n\",@p1,@p2);"}
    *c "if (!isfinite(p1)) \{"
    *c "    @property:ts=1/@property:BW;"
    *c "\} else if (!isfinite(p2)) \{"
    *c "    @property:ts=-log(0.02)/@p1;"
    *c "\} else \{"
    *c "    float A1=-@p2/(-@p1+@p2);"
    *c "    float A2=-@p1/(-@p1+@p2);"
    *c "    @property:ts=0;"
    *c "    for (BW_it=0;BW_it<10;BW_it++) @property:ts-=(0.02+A1*exp(-@p1*@property:ts)+A2*exp(-@p2*@property:ts))/(-@p1*A1*exp(-@p1*@property:ts)-@p2*A2*exp(-@p2*@property:ts));"
    *c "\}"
    *c "if (!isfinite(@property:ts)) \{"
    *c "    @property:ts=1/@property:BW;"
    *c "\}"
    foreach transistor $::all_transistors {
        skip {![regexp {^[np]in} $transistor]}
        *c "@property:Cin=@$transistor:cgd+@$transistor:cgs;"
        *c "@property:PM=(@property:BW/9.76e8)+(@property:Adc-21)-sqrt(@$::transistors($transistor,L)*@$::transistors($transistor,W))/5e-7-@size:iref*2.5e4;"
        *c "@property:PM=(@property:PM*180/3.1415)/2.16+29-1.4-0.75/2;"
	*c "while (@property:PM<0) @property:PM+=360;"
	*c "while (fabs(@property:PM)>180) @property:PM-=360;"
	*c "@property:PM=fabs(@property:PM);"
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
    *c "@property:PM=180-180*(atan(sni/snr)-atan(sdi/sdr))/3.1415926;"
    if {$::debug_mode} {*c "printf(\"Settling time=%g\\n\",@property:ts);"}
    
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
	*c "if (!isfinite(@$transistor:Nt))  \{@status:fail=5; return TCL_ERROR;\}"
        *c "@$transistor:Nf_unit=$::Nf_equations($transistor);"
        *c "@$transistor:Nf=@$transistor:Nf_unit*@$transistor:go*@$transistor:go/(@$W*@$L);"
	*c "if (!isfinite(@$transistor:Nf))  \{@status:fail=6; return TCL_ERROR;\}"
	if {0} {*c "printf(\"$transistor Nt=%gA^2/Hz Nf(f=1Hz)=%gA^2/Hz\\n\",@$transistor:Nt,@$transistor:Nf);"}
    }
    foreach transistor $::all_transistors {
        *c "float current_transfer_$transistor=@Ted*([DERIVE @$transistor:Ideq $out_node_expression])/@property:Adc;"
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
        *c "@property:N$noise_type=([join $chain +])/@property:Adc;"
    }
    foreach transistor $::all_transistors {
        if {$::debug_mode} {*c "printf(\"$transistor:  Nt=%g (%g%%)  Nf=%g (%g%%)\\n\",@$transistor:Nt,100*@$transistor:noise_trans*@$transistor:noise_trans*@$transistor:Nt/@property:Nt,@$transistor:Nf,100*@$transistor:noise_trans*@$transistor:noise_trans*@$transistor:Nf/@property:Nf);"}
    }
    *c "@property:fc=@property:Nf/@property:Nt;"
    *c "@property:TotalNoise=(log(2*@property:BW)*@property:Nf+2*@property:BW*@property:Nt);"
    if {[@ param:inn ?] && [@ param:inp ?]} {
        *c "@property:TotalNoise/=2;"
    }	
    if {0} {*c "printf(\"Adc=%gdB BW=%gHz fc=%g Nf(f=1Hz)=%gV^2/Hz Nt=%gV^2/Hz TN=%gV^2\\n\",20*log10(@property:Adc),@property:BW,@property:fc,@property:Nf,@property:Nt,@property:TotalNoise); if (@property:Adc>600) exit(0);"}
    if {$::debug_mode} {*c "printf(\"Corner=%g\\n\",@property:fc);"}

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
        if {$::debug_mode} {*c "printf(\"Transistor $transistor contributes %g*(%g+%g)=%g\\n\",@$w,@$l,@area_spacing,@$w*(@$l+@area_spacing));"}
    }
    *c "@property:Area=1e12*([join $chain +]);"	
    if {$::debug_mode} {*c "printf(\"Temporary Area=%g\\n\",@property:Area);"}
    *c "float single_transistor_vos;"
    *c "@property:Vos=0;"
    foreach transistor $::all_transistors {
        skip {![regexp {^in} $::transistors($transistor,g)]}
	if {$::transistors($transistor,type)=="pch"} {
            *c "single_transistor_vos=vos(-@$transistor:Ids*@$::transistors($transistor,L)/@$::transistors($transistor,W));"
	} else {
            *c "single_transistor_vos=vos(@$transistor:Ids*@$::transistors($transistor,L)/@$::transistors($transistor,W));"
	}
        *c "@property:Vos+=single_transistor_vos*single_transistor_vos;"
    }	
    *c "@property:Vos=1e-3*sqrt(@property:Vos);"
    *c "@property:Power=0;"
    foreach transistor $::all_transistors {
        foreach key [array names ::transistors $transistor,*] {
	    set field [regsub {.*,} $key {}]
	    set $field $::transistors($key)
	}    
        *c "@property:Power+=fabs(@$transistor:Ids*((@$d:V)-(@$s:V)));"
    }
    @ property foreach_child p {
        if {[lsearch {Adc CMRR PSRR} $p]!=-1} {
            *c "@property:$p=20*log10(fabs(@property:$p));"
	    if {$p!="Adc"} {
                *c "@property:$p=@property:Adc-@property:$p;"
	    }
        }
        if {$::debug_mode} {*c "printf(\"Final $p=%g\\n\",@property:$p);"}
    }
    
    *c "if (@max_Adc<@property:Adc) @max_Adc=@property:Adc;"
    #####################################################################################################
    ############
    ############   PAT 
    ############
    #####################################################################################################
    *c "PAT *p=(PAT *)&@$::opt(topology):circuits:PAT;"
    set index 0
    @ size foreach_child s {
	incr index
    }	
    @ / foreach_child n {
        skip {![@ $n:V ?]}
        skip {$n=="vdd"}
        skip {$n=="0"}
        skip {[@ param:$n ?]}
	incr index
    }
    *c "float sizes\[$index\];"
    set index 0
    @ size foreach_child s {
        *c "sizes\[$index\]=@size:$s;"
	incr index
    }	
    @ / foreach_child n {
        skip {![@ $n:V ?]}
        skip {$n=="vdd"}
        skip {$n=="0"}
        skip {[@ param:$n ?]}
        *c "sizes\[$index\]=@$n:V;"
	incr index
    }
    set index 0
    @ property foreach_child p {
	incr index
    }	
    *c "float properties\[$index\];"
    set index 0
    @ property foreach_child p {
        *c "if ((@config:factor:$p!=0)||(@config:shift:$p!=0)) @property:$p=@property:$p*@config:factor:$p+@config:shift:$p;"
        *c "properties\[$index\]=@property:$p;"
	incr index
    }	
    *c "@status:fail=op_it;"
    *c "@status:index=add_pat_array(p,sizes,properties);"
    if {$::debug_mode} {*c "printf(\"PAT contains %d entries\\n\",p->content->num_of);"}
