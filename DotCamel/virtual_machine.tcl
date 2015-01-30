proc DotCamelCommand {name interface i_body} {
    puts "Info: Declaring DotCamel command: $name"
    set body "if (!DotCamelVirtualMachineSkip) \{FC FCUNION;\n"
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
            pointer {
                append body "void *$var_name=(void *)DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramCounter+$i];\n"
            } 
            float {
                append body "FCUNION.P=(void *)DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramCounter+$i];\n"
                append body "float $var_name=FCUNION.F;\n"
            }
            int {
                append body "FCUNION.P=(void *)DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramCounter+$i];\n"
                append body "ordinal $var_name=FCUNION.I;\n"
            }
            default {
                puts -stderr "Error: DotCamelCommand interface type $var_type undefined"
                exit
            }
        }
    }
    append body $i_body
    incr i
    append body "\}\nDotCamelVirtualMachineSkip=0;\n"
    append body "DotCamelVirtualMachineBatchProgramCounter+=$i;\n"
    set O [open $::env(RAMSPICE)/DotCamel/DotCamelCommands.h a]
    puts $O "void DotCamelCommand_$name\(\);"
    close $O
    set O [open $::env(RAMSPICE)/DotCamel/DotCamelCommands.c a]
    puts $O "void DotCamelCommand_$name\(\) \{$body\}"
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
	puts $O "DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++]=DotCamelCommand_$name;"
        foreach var_declaration [split $interface ,] {
            incr i
            set var_type real
            if {[llength $var_declaration]==2} {
                set var_type [lindex $var_declaration 0]
            }
            set var_name [lindex $var_declaration end]
            switch $var_type {
                pointer {
	            puts $O "DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++]=get_LUT(argv\[$i\]);"
                } 
                float {
	            puts $O "FCUNION.F=atof(argv\[$i\]);"
	            puts $O "DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++]=FCUNION.P;"
                }
                int {
	            puts $O "FCUNION.I=atoi(argv\[$i\]);"
	            puts $O "DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++]=FCUNION.P;"
                }
                default {
                    puts -stderr "Error: DotCamelCommand interface type $var_type undefined"
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
        puts $O "Tcl_CreateCommand(interp, \"DotCamelCommand_$name\", tcl_dot_camel_$name, NULL, NULL);"
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


