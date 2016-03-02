    *c "ClientData CD;"
    *c "PAT *p=(PAT *)&@$::opt(topology):circuits:PAT;"
   *c "while (p->content->num_of<@$::opt(topology):config:pat_size_target) \{"
    foreach s $::sizers_list {
        *c "@$::opt(topology):size:$s=$::sizing_code($s,min)+random()*($::sizing_code($s,max)-$::sizing_code($s,min))/RAND_MAX;"
    }	
    *c "if (tcl_gamma_op_cmd(CD,NULL,0,NULL)==TCL_ERROR) continue;"
    *c "\}"
