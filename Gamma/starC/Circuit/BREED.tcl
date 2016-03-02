*c "ClientData CD;"
*c "int i,viable;"
*c "PAT *p=(PAT *)&@$::opt(topology):circuits:PAT;"
*c "int more_to_breed=1;"
*c "while (more_to_breed&&(p->content->num_of<@$::opt(topology):pat_size_target)) \{"
*c "more_to_breed=0;"
*c "int sweep_size=p->content->num_of;"
*c "for (i=0;i<sweep_size;i++) \{"
*c "if (p->content->content[i]->flags) continue;"
*c "p->content->content[i]->flags=1;"
*c "more_to_breed++;"
if {$::debug_mode} {*c "printf(\"Visiting %d\\n\",i);"}
set j 0
@ $::opt(topology):size foreach_child s {
    *c "@$::opt(topology):size:$s=p->content->content[i]->sizes->content[$j];"
    incr j;
}
@ $::opt(topology):size foreach_child s {
    foreach step_dir {+ -2*} {
	*c "@$::opt(topology):size:$s=@$::opt(topology):size:$s$step_dir@$::opt(topology):size:$s:step;"
	*c "viable=1;"
	*c "if ((@$::opt(topology):size:$s>=$::sizing_code($s,min))&&(@$::opt(topology):size:$s<=$::sizing_code($s,max))) \{"
	*c "tcl_gamma_${::opt(topology)}_op_cmd(CD,NULL,0,NULL);"
	*c "\}"
    }
    *c "@$::opt(topology):size:$s=@$::opt(topology):size:$s+@$::opt(topology):size:$s:step;"
}
*c "if (p->content->num_of%100==0) \{"
*c "	printf(\"		%ld/%g=%g%%\\n\",p->content->num_of,@$::opt(topology):pat_size_target,100*p->content->num_of/@$::opt(topology):pat_size_target);"
*c "	fflush(stdout);"
*c "	if (@$::opt(topology):param:unique>0) \{"
*c "	    pat_unique(p,@$::opt(topology):param:unique);"
*c "\}"
*c "\}"
*c "\}"
*c "printf(\"	Done %ld/%g=%g%% (%ld visited)\\n\",p->content->num_of,@$::opt(topology):pat_size_target,100*p->content->num_of/@$::opt(topology):pat_size_target,more_to_breed);"
*c "\}"
