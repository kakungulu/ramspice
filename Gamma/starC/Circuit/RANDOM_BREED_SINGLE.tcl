    *c "ClientData CD;"
    *c "int i;"
    *c "PAT *p=(PAT *)&@$::opt(topology):circuits:PAT;"
    *c "int more_to_breed=0;"
    *c "long int r;"
    *c "long int breed_count=p->content->num_of;"
    *c "long int watchdog=0;"
    *c "float step;"
    *c "int sweep_size=p->content->num_of;"
    *c "int searched_id=(int)@$::opt(topology):circuit_breed_id;"
    *c "for (i=0;i<p->content->num_of;i++) \{"
    *c "    if (p->content->content[i]->id==searched_id) break;"
    *c "\}"
    *c "printf(\"Found circuit id %d at index %d\\n\",searched_id,i);"
    *c "while (watchdog++<10000) \{"
    if {$::debug_mode} {*c "printf(\"Visiting %d\\n\",i);"}
    set j 0
    @ $::opt(topology):size foreach_child s {
        *c "@$::opt(topology):size:$s=p->content->content[i]->sizes->content[$j];"
        incr j;
    }
    foreach s $::sizers_list {
        *c "while (1) \{"
        *c "step=(2.0*random()/RAND_MAX-1)*$::sizing_code($s,step);"
        *c "if (@$::opt(topology):size:$s+step<$::sizing_code($s,min)) continue;"
        *c "if (@$::opt(topology):size:$s+step>$::sizing_code($s,max)) continue;"
        *c "break;"
        *c "\}"
        *c "@$::opt(topology):size:$s+=step;"
    }
    *c "if (tcl_gamma_${::opt(topology)}_op_cmd(CD,NULL,0,NULL)==TCL_ERROR) continue;"
    *c "if (p->content->num_of>=breed_count+@$::opt(topology):circuit_breed_target) break;"
    *c "\}"
