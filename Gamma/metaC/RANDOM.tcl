    *c "ClientData CD;"
    *c "PAT *p=(PAT *)&@$::opt(topology):circuits:PAT;"
    *c "while (p->content->num_of<@pat_size_target) \{"
    @ size foreach_child s {
        skip {![regexp {^L(.*)$} $s -> x]}
        *c "@size:$s=@size:$s:min+random()*(@size:$s:max-@size:$s:min)/RAND_MAX;"
        *c "@size:W$x=@size:$s+random()*(@size:W$x:max-@size:$s)/RAND_MAX;"
    }	
    @ size foreach_child s {
        skip {[regexp {^L(.*)$} $s -> x]}
        skip {[regexp {^W(.*)$} $s -> x]}
        *c "@size:$s=@size:$s:min+random()*(@size:$s:max-@size:$s:min)/RAND_MAX;"
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
    *c "if (tcl_gamma_op_cmd(CD,NULL,0,NULL)==TCL_ERROR) continue;"
    *c "\}"
