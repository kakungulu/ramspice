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
    *c "@vdd:V=$::opt(topv);"
    *c "@0:V=0;"
    *c "// Calculating circuit operating point:"
    *c "int op_it=0;"
    if {$::debug_mode} {*c "printf(\"==================================================\\n\");"}
    if {$::debug_mode} {*c "printf(\"======%g Operating Point Iterations. ======\\n\",@op_iterations);"}
    if {$::debug_mode} {*c "printf(\"==================================================\\n\");"}
    *c "for (op_it=0;(op_it<@op_iterations);op_it++) \{"
    *c "if (op_it>100) return TCL_ERROR;"
    *c "float previous_out_dc=@$::output_net:V;"
    if {$::debug_mode} {*c "    printf(\"========================= op_it=%d =========================\\n\",op_it);"}
    foreach transistor $::all_transistors {
        set L $::transistors($transistor,L)
        set W $::transistors($transistor,W)
        if {[info exists ::gm_equations($transistor)]} {
            *c "@$transistor:gm=$::gm_equations($transistor);"
	    *c "if (@print_op_steps>0) printf(\"%d) $transistor:gm=%g\\n\",op_it,@$transistor:gm);"
            if {$::debug_mode} {*c "printf(\"@$transistor:gm=%g\\n\",@$transistor:gm);"}
            *c "@$transistor:go=$::go_equations($transistor);"
	    *c "if (@print_op_steps>0) printf(\"%d) $transistor:go=%g\\n\",op_it,@$transistor:go);"
            if {$::debug_mode} {*c "printf(\"@$transistor:go=%g\\n\",@$transistor:go);"}
        } else {
            *c "@$transistor:g=$::g_equations($transistor);"
        }
        *c "@$transistor:Ideq=$::Ids_equations($transistor);"
	*c "if (@print_op_steps>0) printf(\"%d) $transistor:Ideq=%g\\n\",op_it,@$transistor:Ideq);"
        if {$::debug_mode} {*c "printf(\"@$transistor:Ideq=%g\\n\",@$transistor:Ideq);"}
    }
    foreach name [array names ::G_equations] {
        *c "@Gds_$name=$::G_equations($name);"
        .default Gds_$name 1e+0
    }
    set expression(Det) [DET ::MNA]
    foreach transistor $::all_transistors {
        if {[info exists ::gm_equations($transistor)]} {
            if {$::debug_mode} {*c "printf(\"@$transistor:gm=%g\\n\",@$transistor:gm);"}
            *c "if (@$transistor:gm==0) @$transistor:gm=1e-6;"
            if {$::debug_mode} {*c "printf(\"@$transistor:go=%g\\n\",@$transistor:go);"}
            *c "if (@$transistor:go==0) @$transistor:go=1e-6;"
        }    
        
        if {$::debug_mode} {*c "printf(\"@$transistor:Ideq=%g\\n\",@$transistor:Ideq);"}
    }
    *c "@Det=$expression(Det);"
    *c "@Ted=1/@Det;"
    *c "// Updating node voltages"
    if {$::debug_mode} {*c "printf(\"Det=$expression(Det)\\n\");"}
    if {$::debug_mode} {*c "printf(\"Det=%g Ted=%g\\n\",@Det,@Ted);"}
    set i 0
    foreach node $::independent_nodes {
        set expression($node) [DET ::MNA $i $::MNAy]
        $node=>($expression($node))*@Ted
        #       if {![info exists ::vdc(0,$node)]} 
        if {1} {
            *c "@$node:V=($expression($node))*@Ted;"
	    Info: OP for $node
            *c "if (@$node:V<0) @$node:V=0;"
            *c "if (@$node:V>$::opt(topv)) @$node:V=$::opt(topv);"
            if {1} {*c "if (@print_op_steps>0) printf(\"%d) $node=%g\\n\",op_it,@$node:V);"}
        }
        incr i
    }
    *c "\}"
    #### Confirm Viability
    @ / foreach_child n {
        skip {![@ $n:V ?]}
        skip {[@ param:$n ?]}
        skip {$n=="vdd"}
        skip {$n=="0"}
        if {$::debug_mode} {*c "printf(\"$n=%g\\n\",@$n:V);"}
        *c "if (!isfinite(@$n:V)) return TCL_ERROR;"
        *c "if (@$n:V==0) return TCL_ERROR;"
        *c "if (@$n:V==$::opt(topv)) return TCL_ERROR;"
    }     
    foreach transistor $::all_transistors {
        if {[string index $transistor 0]=="n" || [string index $transistor 0]=="N"} {
            *c "if (@$::transistors($transistor,s):V>@$::transistors($transistor,d):V) return TCL_ERROR;"
        } else {
            *c "if (@$::transistors($transistor,s):V<@$::transistors($transistor,d):V) return TCL_ERROR;"
        }
    }
    
    foreach transistor $::all_transistors {
        set L $::transistors($transistor,L)
        set W $::transistors($transistor,W)
        *c "@$transistor:Nt_unit=$::Nt_equations($transistor);"
        *c "@$transistor:Nt=@$transistor:Nt_unit*sqrt(@$transistor:gm);"
	*c "if (!isfinite(@$transistor:Nt))  return TCL_ERROR;"
        *c "@$transistor:Nf_unit=$::Nf_equations($transistor);"
        *c "@$transistor:Nf=@$transistor:Nf_unit*@$transistor:gm*@$transistor:gm/(@$W*@$L);"
	*c "if (!isfinite(@$transistor:Nf))  return TCL_ERROR;"
    }
    *c "// Calculating circuit properties:"
    @ property foreach_child p {
        set expression($p) [flat_expression  $::properties($p,expression)]
        *c "@property:$p=$expression($p);"
        if {$::debug_mode} {*c "printf(\"Temporary $p=%g\\n\",@property:$p);"}
	*c "if (!isfinite(@property:$p))  return TCL_ERROR;"
	Info: Code generated for $p
    }	
    *c "if (@print_op_steps>0) printf(\" Adc=%g\\n\",@property:Adc);"
    *c "@property:Adc=fabs(@property:Adc);"
    *c "if (@property:Adc<1) return TCL_ERROR;"
    @ 0:V = 0
    .prep_mna zout
    set expression(Rout) [DET ::MNA [lsearch $::independent_nodes $::output_net] $::MNAy]
    *c "@property:Rout=($expression(Rout))*@Ted;"
    .prep_mna ac
    set expression(Det_ac) [DET ::MNA]
    set expression(dDet_ac) [derive_expression @s $expression(Det_ac)]
    foreach transistor $::all_transistors {
        foreach cap {cgs cgd} {
            skip {![@ $transistor:$cap ?]}
            *c "@$transistor:$cap=$::cap_equations($transistor,$cap);"
            if {$::debug_mode} {*c "printf(\"$transistor:$cap=%g\\n\",@$transistor:$cap);"}
	    *c "if (!isfinite(@$transistor:$cap))  return TCL_ERROR;"
        }
    }	    
    *c "@s=-1;"
    *c "int BW_it;"
    if {$::debug_mode} {*c "printf(\"num=$expression(Det_ac)\\n\");"}
    if {$::debug_mode} {*c "printf(\"denom=$expression(dDet_ac)\\n\");"}
    *c "for (BW_it=0;BW_it<5;BW_it++) \{"
    *c "    @s-=($expression(Det_ac))/($expression(dDet_ac));"
    *c "\}"
    *c "@property:BW:s=$expression(dDet_ac);"
    *c "@p1=-@s;"
    *c "@property:BW=@p1/(2*3.141592656);"
    if {$::debug_mode} {*c "printf(\"BW=%g\\n\",@property:BW);"}
    *c "if (!isfinite(@property:BW))  return TCL_ERROR;"
    *c "if (@property:BW<0)  return TCL_ERROR;"
    # Move away from the found root 
    *c "@s-=1e3;"
    # Find next root (=pole)
    *c "for (BW_it=0;BW_it<20;BW_it++) \{"
    *c "    @s-=(($expression(Det_ac))*(@s+@p1-5e2))/(($expression(dDet_ac))*(@s+@p1-5e2)-($expression(Det_ac)));"
    *c "\}"
    *c "@p2=-@s;"
    if {$::debug_mode} {*c "printf(\"Poles: %g    %g\\n\",@p1,@p2);"}
    *c "float A1=-@p2/(-@p1+@p2);"
    *c "float A2=-@p1/(-@p1+@p2);"
    *c "@property:ts=0;"
    *c "for (BW_it=0;BW_it<10;BW_it++) \{"
    *c "    @property:ts-=(0.02+A1*exp(-@p1*@property:ts)+A2*exp(-@p2*@property:ts))/(-@p1*A1*exp(-@p1*@property:ts)-@p2*A2*exp(-@p2*@property:ts));"
    *c "\}"
    if {$::debug_mode} {*c "printf(\"Settling time=%g\\n\",@property:ts);"}
    foreach transistor $::all_transistors {
        set dpoly(noise_trans_$transistor) [derive_expression @$transistor:Ideq $expression($output_expr)]
        *c "@$transistor:noise_trans=@Ted*($dpoly(noise_trans_$transistor))/@property:Adc;"
    } 
    foreach noise_type {t f} {   
        set chain {}
        foreach transistor $::all_transistors {
            lappend chain @$transistor:noise_trans*@$transistor:noise_trans*@$transistor:N$noise_type
        }
        if {$chain=={}} {
            set chain 0
        }
        *c "@property:N$noise_type=[join $chain +];"
        @ size foreach_child c {
            set chain {}
            foreach transistor $::all_transistors {
                lappend chain  2*@$transistor:noise_trans*@$transistor:noise_trans:$c*@$transistor:N$noise_type
                lappend chain @$transistor:noise_trans*@$transistor:noise_trans*@$transistor:N$noise_type:$c
            }
            *c "@property:N$noise_type:$c=[join $chain +];"
        }	    
    }
    foreach transistor $::all_transistors {
        if {$::debug_mode} {*c "printf(\"$transistor:  Nt=%g (%g%%)  Nf=%g (%g%%)\\n\",@$transistor:Nt,100*@$transistor:noise_trans*@$transistor:noise_trans*@$transistor:Nt/@property:Nt,@$transistor:Nf,100*@$transistor:noise_trans*@$transistor:noise_trans*@$transistor:Nf/@property:Nf);"}
    }
    *c "@property:fc=@property:Nf/@property:Nt;"
    if {$::debug_mode} {*c "printf(\"Corner=%g\\n\",@property:fc);"}
    set chain {}
    foreach transistor $::all_transistors {
        set l  $::transistors($transistor,L)
        set w  $::transistors($transistor,W)
        lappend chain "@$w*(@$l+@param:area_spacing)"
        if {$::debug_mode} {*c "printf(\"Transistor $transistor contributes %g*(%g+%g)=%g\\n\",@$w,@$l,@area_spacing,@$w*(@$l+@area_spacing));"}
    }
    *c "@property:Area=1e12*([join $chain +]);"	
    if {$::debug_mode} {*c "printf(\"Temporary Area=%g\\n\",@property:Area);"}
    *c "float single_transistor_vos;"
    *c "@property:Vos=0;"
    foreach transistor $::all_transistors {
        skip {![regexp {^in} $::transistors($transistor,g)]}
        *c "single_transistor_vos=vos((@$transistor:Ideq+(@$::transistors($transistor,g):V-@$::transistors($transistor,s):V)*@$transistor:gm+(@$::transistors($transistor,d):V-@$::transistors($transistor,s):V)*@$transistor:go)*@$::transistors($transistor,L)/@$::transistors($transistor,W));"
        *c "@property:Vos+=single_transistor_vos*single_transistor_vos;"
    }	
    *c "@property:Vos=sqrt(@property:Vos);"
    *c "@property:Power=@size:iref*@vdd:V*@param:power_factor;"
    @ property foreach_child p {
        if {[lsearch {Adc CMRR PSRR} $p]!=-1} {
            *c "@property:$p=20*log10(fabs(@property:$p));"
        }
        if {$::debug_mode} {*c "printf(\"Final $p=%g\\n\",@property:$p);"}
    }
    
    *c "if (@max_Adc<@property:Adc) @max_Adc=@property:Adc;"
    ####################### Add circuit to the PAT
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
        *c "properties\[$index\]=@property:$p;"
	incr index
    }	
    *c "add_pat_array(p,sizes,properties);"
    if {$::debug_mode} {*c "printf(\"PAT contains %d entries\\n\",p->content->num_of);"}
