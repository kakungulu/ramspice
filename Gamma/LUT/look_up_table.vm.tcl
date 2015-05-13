# This is a virtual machine 
for {set DIM 1} {$DIM<$::MAXDIM} {incr DIM} {
    set num_of_corners [expr 1<<$DIM]
    set body {
        ordinal sizer=1;
	ordinal index=0;
	LUT *a=vm_contexts[vm_int()];
    }
    for {set i 0} {$i<$DIM} {incr i} {
        append body "    float coord$i;\n"
        append body "    vm_pop(&coord$i);\n"
        append body "    int key${i}=s2o((coord$i-a->legend[$i][0])*a->physical_factor[$i]);\n"
        append body "    if (key${i}<0) key${i}=0;\n"
        append body "    if (key${i}>=a->size[$i]-1) key${i}=a->size[$i]-2;\n"
        append body "    index+=key${i}*sizer;\n"
        append body "    sizer*=a->size[$i];\n"
    }	
    for {set corner 0} {$corner<$num_of_corners} {incr corner} {
        append body "    float interpolation_buffer$corner=a->content\[index+a->neighbors\[$corner\]\];\n"
    }
    append body {
        double hyper_volume=1;
    }
    set weighing_dim 0
    for {set breadth $num_of_corners} {$breadth>1} {set breadth [expr $breadth/2]} {
        set j 0
        for {set i 0} {$i<$breadth} {incr i 2} {
            set k [expr $i+1]
            append body "interpolation_buffer$j=interpolation_buffer$k*(coord$weighing_dim-a->legend[$weighing_dim][key${weighing_dim}])+interpolation_buffer$i*(a->legend[$weighing_dim][key${weighing_dim}+1]-coord$weighing_dim);\n"
            incr j
        }    
        append body "hyper_volume*=(a->legend[$weighing_dim][key${weighing_dim}+1]-a->legend[$weighing_dim][key${weighing_dim}]);\n"
        incr weighing_dim
    }
    append body {
        vm_push(interpolation_buffer0/hyper_volume);
    }
    set tcl_body {
        if {[lsearch $::vm_contexts $context]==-1} {
	    lappend ::vm_contexts $context
	}
	set context_index [lsearch $::vm_contexts $context]
    }
    append tcl_body "\n    write_bin int \[expr \$context_index<<8|\$::vm_bc_key(lut_interpolation_$DIM)\]\n"
    append tcl_body "    for \{set i 0\} \{\$i<1+$DIM*2+$num_of_corners\} \{incr i\} \{\n"
    append tcl_body "        write_bin float 0\n"
    append tcl_body "    \}\n"
    VM: lut_interpolation_$DIM {context} $tcl_body $body
}
