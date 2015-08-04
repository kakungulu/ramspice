    *c "ClientData CD;"
    *c "int i;"
    *c "PAT *p=(PAT *)&@$::opt(topology):circuits:PAT;"
    *c "long int r;"
    *c "float step;"
    *c "while (1) \{"
    *c "    if (p->content->num_of>@pat_size_target) break;"
    *c "int sweep_size=p->content->num_of;"
    *c "for (i=0;i<sweep_size;i++) \{"
    if {$::debug_mode} {*c "printf(\"Visiting %d\\n\",i);"}
    set j 0
    @ size foreach_child s {
        *c "@size:$s=p->content->content[i]->sizes->content[$j];"
        incr j;
    }
    @ size foreach_child s {
        *c "while (1) \{"
        *c "step=(2.0*random()/RAND_MAX-1)*@size:$s:step;"
        *c "if (@size:$s+step<@size:$s:min) continue;"
        *c "if (@size:$s+step>@size:$s:max) continue;"
        *c "break;"
        *c "\}"
        *c "@size:$s+=step;"
    }
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
    *c "int pre_volume=p->content->num_of;"
    *c "if (tcl_gamma_op_cmd(CD,NULL,0,NULL)==TCL_ERROR) \{i--; continue;\}"
    *c "if (pre_volume==p->content->num_of) \{i--; continue;\}"
    *c "if (p->content->num_of%1000==0) \{"
    *c "    printf(\"               %ld/%g=%g%% max gain=%g\\n\",p->content->num_of,@pat_size_target,100*p->content->num_of/@pat_size_target,@max_Adc);"
    *c "    printf(\"               %ld/%g=%g%%\\n\",p->content->num_of,@pat_size_target,100*p->content->num_of/@pat_size_target);"
    *c "    fflush(stdout);"
    *c "    if (@param:unique>0) \{"
    *c "        pat_unique(p,@param:unique);"
    *c "    printf(\"               post unique: %ld/%g=%g%%\\n\",p->content->num_of,@pat_size_target,100*p->content->num_of/@pat_size_target);"
    *c "    if (p->content->num_of>0.92*@pat_size_target) break;"
    *c "\}"
    *c "\}"
    *c "    if (p->content->num_of>@pat_size_target) break;"
    *c "\}"
    *c "    if (p->content->num_of>@pat_size_target) break;"
    *c "\}"
