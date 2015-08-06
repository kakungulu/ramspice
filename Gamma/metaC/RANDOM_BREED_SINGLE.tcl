    *c "ClientData CD;"
    *c "int i;"
    *c "PAT *p=(PAT *)&@$::opt(topology):circuits:PAT;"
    *c "int more_to_breed=0;"
    *c "long int r;"
    *c "long int breed_count=p->content->num_of;"
    *c "long int watchdog=0;"
    *c "float step;"
    *c "int sweep_size=p->content->num_of;"
    *c "int searched_id=(int)@circuit_breed_id;"
    *c "for (i=0;i<p->content->num_of;i++) \{"
    *c "    if (p->content->content[i]->id==searched_id) break;"
    *c "\}"
    *c "printf(\"Found circuit id %d at index %d\\n\",searched_id,i);"
    *c "while (watchdog++<10000) \{"
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
    *c "if (tcl_gamma_op_cmd(CD,NULL,0,NULL)==TCL_ERROR) continue;"
    *c "if (p->content->num_of>=breed_count+@circuit_breed_target) break;"
    *c "\}"
