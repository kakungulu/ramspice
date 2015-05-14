set ::Gamma_operators {}
proc GammaOperator {name interface i_body} {
    lappend ::Gamma_operators $name
    GammaCommand $name $interface $i_body
}
proc GammaCommand {name interface i_body} {
 #   puts "Info: Declaring Gamma command: $name"
    regsub -all {@(.)\(([^\)]+)\)} $i_body "GammaVirtualMachineStack\[GammaVirtualMachineStackIndex+\\2\].\\1" i_body
    if {[lsearch $::Gamma_operators $name]==-1} {
        set body "\n    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;\n    GammaVirtualMachineSkip=0;\n    if (!GammaVirtualMachineTempSkip) \{\n    "
	append body "#Dinfo: \"%ld: $name\" GammaVirtualMachineBatchProgramCounter\n"
	append body " FC FCUNION;\n"
    } else {
        set body "\n    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;\n    GammaVirtualMachineSkip=0;\n    if (1) \{\n    "
	append body "#Dinfo: \"%ld: $name\" GammaVirtualMachineBatchProgramCounter\n"
	append body " FC FCUNION;\n"
    }
    set i 0
    foreach var_declaration [split $interface ,] {
        incr i
        if {([llength $var_declaration]!=2) && ([llength $var_declaration]!=1)} {
            puts -stderr "Error: GammaCommand requires one or two tokens per interface decalaration"
            exit
        }
        set var_type real
        if {[llength $var_declaration]==2} {
            set var_type [lindex $var_declaration 0]
        }
        set var_name [lindex $var_declaration end]
        switch $var_type {
            string {
                append body "        char *$var_name=(char *)GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter+$i].P;\n"
            } 
            LUT {
                append body "        LUT *$var_name=(LUT *)GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter+$i].P;\n"
            } 
            PAT {
                append body "        PAT *$var_name=(PAT *)GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter+$i].P;\n"
            } 
            POLY {
                append body "        POLY *$var_name=(POLY *)GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter+$i].P;\n"
            } 
            var {
                append body "        float *$var_name=(float *)GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter+$i].P;\n"
            } 
            pointer {
                append body "        void *$var_name=GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter+$i].P;\n"
            } 
            float {
                append body "        float $var_name=GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter+$i].F;\n"
            }
            int {
                append body "        ordinal $var_name=GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter+$i].I;\n"
            }
            default {
                puts -stderr "Error: GammaCommand interface type $var_type undefined"
                exit
            }
        }
    }
    append body $i_body
    incr i
    append body "    \}\n"
    append body "    GammaVirtualMachineBatchProgramCounter+=$i;\n"
    set O [open $::env(RAMSPICE)/Gamma/Gamma.h a]
    puts $O "void GammaCommand$name\(void\);"
    close $O
    set O [open $::env(RAMSPICE)/Gamma/Gamma.c a]
    puts $O "void GammaCommand$name\(\) \{$body\}"
    close $O
    set ::Gamma($name) $interface
}

proc GammaSpecialCommand {name interface i_body c_body} {
    GammaCommand $name $interface $i_body
    set ::GammaSpecialCommand($name) $c_body
}

proc GammaTclInterface {} {
    set O [open $::env(RAMSPICE)/Gamma/Gamma.c a]
    foreach name [array names ::Gamma] {
        if {[info exists ::GammaSpecialCommand($name)]} {
            puts $O "int tcl_gamma_$name\(ClientData clientData,Tcl_Interp *interp,int argc,char *argv\[\]\) \{"
	    puts $O $::GammaSpecialCommand($name)
            puts $O "\}"
	    continue
	}
        set interface $::Gamma($name)
        puts $O "int tcl_gamma_$name\(ClientData clientData,Tcl_Interp *interp,int argc,char *argv\[\]\) \{"
        set argc [llength [split $interface ,]]
        incr argc
        puts $O "    FC FCUNION;"
        puts $O "    if (argc!=$argc) \{"
        puts $O "        #Error: \"%s requires the following arguments: \($::Gamma($name)\)\" argv[0]"
        puts $O "    \}"
        set i 0
	puts $O "    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommand$name;"
	set info_pattern "Assembly %ld: %x $name "
	set info_list  "GammaVirtualMachineBatchProgramSize-$argc GammaCommand$name "
        foreach var_declaration [split $interface ,] {
            incr i
            set var_type real
            if {[llength $var_declaration]==2} {
                set var_type [lindex $var_declaration 0]
            }
            set var_name [lindex $var_declaration end]
	    append info_pattern "%s "
	    append info_list "argv\[$i\] "
            switch $var_type {
                var {
	            puts $O "    context *GammaContext$i;"
	            puts $O "    resolve_context(argv\[$i\],&(GammaContext$i),NULL);"
	            puts $O "    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].P=(void *)(&(GammaContext$i->value.s));"
		    append info_pattern "%x "
		    append info_list "(&(GammaContext$i->value.s)) "
		}
                string {
	            puts $O "    char *new_name=(char *)malloc(sizeof(char)*(strlen(argv\[$i\])+1));"
	            puts $O "    sprintf(new_name,\"%s\",argv\[$i\]);"
	            puts $O "    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].P=new_name;"
		    #append info_pattern "%s "
		    #append info_list "argv\[$i\] "
		}
                LUT {
	            puts $O "    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].P=get_LUT(argv\[$i\]);"
		    #append info_pattern "%x "
		    #append info_list "get_LUT(argv\[$i\]) "
		}
                PAT {
	            puts $O "    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].P=get_PAT(argv\[$i\]);"
		    #append info_pattern "%x "
		    #append info_list "get_PAT(argv\[$i\]) "
		}
                POLY {
	            puts $O "    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].P=get_POLY(argv\[$i\]);"
		    #append info_pattern "%x "
		    #append info_list "get_LUT(argv\[$i\]) "
		}
                pointer {
	            puts $O "    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].P=get_LUT(argv\[$i\]);"
		    #append info_pattern "%x "
		    #append info_list "get_LUT(argv\[$i\]) "
                } 
                float {
	            puts $O "    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].F=strtof(argv\[$i\],NULL);"
		    #append info_pattern "%g "
		    #append info_list "strtof(argv\[$i\],NULL) "
                }
                int {
	            puts $O "    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].I=atoi(argv\[$i\]);"
		    #append info_pattern "%ld "
		    #append info_list "atoi(argv\[$i\]) "
                }
                default {
                    puts stderr "Error: GammaCommand interface type $var_type undefined"
                    exit
                }
            }
            puts $O ""
        }
        puts $O "    #Info: \"$info_pattern\" $info_list"
        puts $O "    return TCL_OK;"
        puts $O "\}"
    }
    puts $O "void init_tcl_gamma(Tcl_Interp *interp) \{"
    foreach name [array names ::Gamma] {
        puts $O "Tcl_CreateCommand(interp, \"GammaCommand$name\", tcl_gamma_$name, NULL, NULL);"
    }
    puts $O "\}"
    close $O
    set O [open $::env(RAMSPICE)/Gamma/Gamma.h a]
    foreach name [array names ::Gamma] {
        puts $O "static int tcl_gamma_$name\(ClientData clientData,Tcl_Interp *interp,int argc,char *argv\[\]\);"
    }
    puts $O "void init_tcl_gamma(Tcl_Interp *interp);"
    close $O
    
}


