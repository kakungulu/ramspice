*c "ClientData CD;"
*c "int i,viable;"
*c "PAT *p=(PAT *)&@$::opt(topology):circuits:PAT;"
*c "int more_to_breed=1;"
*c "while (more_to_breed&&(p->content->num_of<@pat_size_target)) \{"
*c "more_to_breed=0;"
*c "int sweep_size=p->content->num_of;"
*c "for (i=0;i<sweep_size;i++) \{"
*c "if (p->content->content[i]->flags) continue;"
*c "p->content->content[i]->flags=1;"
*c "more_to_breed++;"
if {$::debug_mode} {*c "printf(\"Visiting %d\\n\",i);"}
set j 0
@ size foreach_child s {
    *c "@size:$s=p->content->content[i]->sizes->content[$j];"
    incr j;
}
@ size foreach_child s {
    foreach step_dir {+ -2*} {
	*c "@size:$s=@size:$s$step_dir@size:$s:step;"
	*c "viable=1;"
	*c "if ((@size:$s>=$::sizing_code($s,min))&&(@size:$s<=$::sizing_code($s,max))) \{"
	*c "tcl_gamma_${::opt(topology)}_op_cmd(CD,NULL,0,NULL);"
	*c "\}"
    }
    *c "@size:$s=@size:$s+@size:$s:step;"
}
*c "if (p->content->num_of%100==0) \{"
*c "	printf(\"		%ld/%g=%g%%\\n\",p->content->num_of,@pat_size_target,100*p->content->num_of/@pat_size_target);"
*c "	fflush(stdout);"
*c "	if (@param:unique>0) \{"
*c "	    pat_unique(p,@param:unique);"
*c "\}"
*c "\}"
*c "\}"
*c "printf(\"	Done %ld/%g=%g%% (%ld visited)\\n\",p->content->num_of,@pat_size_target,100*p->content->num_of/@pat_size_target,more_to_breed);"
*c "\}"
