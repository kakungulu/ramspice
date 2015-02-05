proc DotCamelCommand {name interface i_body} {
    puts "Info: Declaring DotCamel command: $name"
    set body "\n    #Info: \"$name\"\n    int DotCamelVirtualMachineTempSkip=DotCamelVirtualMachineSkip;\n    DotCamelVirtualMachineSkip=0;\n    if (!DotCamelVirtualMachineTempSkip) \{\n    FC FCUNION;\n"
    set i 0
    foreach var_declaration [split $interface ,] {
        incr i
        if {([llength $var_declaration]!=2) && ([llength $var_declaration]!=1)} {
            puts -stderr "Error: DotCamelCommand requires one or two tokens per interface decalaration"
            exit
        }
        set var_type real
        if {[llength $var_declaration]==2} {
            set var_type [lindex $var_declaration 0]
        }
        set var_name [lindex $var_declaration end]
        switch $var_type {
            LUT {
                append body "        LUT *$var_name=(LUT *)DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramCounter+$i].P;\n"
            } 
            var {
                append body "        float *$var_name=(float *)DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramCounter+$i].P;\n"
            } 
            pointer {
                append body "        void *$var_name=DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramCounter+$i].P;\n"
            } 
            float {
                append body "        float $var_name=DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramCounter+$i].F;\n"
            }
            int {
                append body "        ordinal $var_name=DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramCounter+$i].I;\n"
            }
            default {
                puts -stderr "Error: DotCamelCommand interface type $var_type undefined"
                exit
            }
        }
    }
    append body $i_body
    incr i
    append body "    \}\n"
    append body "    DotCamelVirtualMachineBatchProgramCounter+=$i;\n"
    set O [open $::env(RAMSPICE)/DotCamel/DotCamelCommands.h a]
    puts $O "void DotCamelCommand$name\(\);"
    close $O
    set O [open $::env(RAMSPICE)/DotCamel/DotCamelCommands.c a]
    puts $O "void DotCamelCommand$name\(\) \{$body\}"
    close $O
    set ::DotCamelCommands($name) $interface
}



proc DotCamelTclInterface {} {
    set O [open $::env(RAMSPICE)/DotCamel/DotCamelCommands.c a]
    foreach name [array names ::DotCamelCommands] {
        set interface $::DotCamelCommands($name)
        puts $O "static int tcl_dot_camel_$name\(ClientData clientData,Tcl_Interp *interp,int argc,char *argv\[\]\) \{"
        set argc [llength [split $interface ,]]
        incr argc
        puts $O "    FC FCUNION;"
        puts $O "    if (argc!=$argc) \{"
        puts $O "        #Error: \"%s requires the following arguments: \($::DotCamelCommands($name)\)\" argv[0]"
        puts $O "    \}"
        set i 0
	puts $O "    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].func=DotCamelCommand$name;"
        foreach var_declaration [split $interface ,] {
            incr i
            set var_type real
            if {[llength $var_declaration]==2} {
                set var_type [lindex $var_declaration 0]
            }
            set var_name [lindex $var_declaration end]
            switch $var_type {
                var {
	            puts $O "    context *DotCamelContext$i;"
	            puts $O "    resolve_context(argv\[$i\],&(DotCamelContext$i),NULL);"
	            puts $O "    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].P=(void *)(&(DotCamelContext$i->value.s));"
		}
                LUT {
	            puts $O "    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].P=get_LUT(argv\[$i\]);"
		}
                pointer {
	            puts $O "    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].P=get_LUT(argv\[$i\]);"
                } 
                float {
	            puts $O "    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].F=strtof(argv\[$i\],NULL);"
                }
                int {
	            puts $O "    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].I=atoi(argv\[$i\]);"
                }
                default {
                    puts stderr "Error: DotCamelCommand interface type $var_type undefined"
                    exit
                }
            }
            puts $O ""
        }
        puts $O "    return TCL_OK;"
        puts $O "\}"
    }
    puts $O "void init_tcl_dot_camel(Tcl_Interp *interp) \{"
    foreach name [array names ::DotCamelCommands] {
        puts $O "Tcl_CreateCommand(interp, \"DotCamelCommand$name\", tcl_dot_camel_$name, NULL, NULL);"
    }
    puts $O "\}"
    close $O
    set O [open $::env(RAMSPICE)/DotCamel/DotCamelCommands.h a]
    foreach name [array names ::DotCamelCommands] {
        puts $O "static int tcl_dot_camel_$name\(ClientData clientData,Tcl_Interp *interp,int argc,char *argv\[\]\);"
    }
    puts $O "void init_tcl_dot_camel(Tcl_Interp *interp);"
    close $O
    
}


