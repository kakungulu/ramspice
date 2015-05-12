proc spice_object {name body} {
    puts "Info: Defining Spice object $name"
    print_line "typedef struct \{"
        print_line $body
    print_line "\} $name;"
    print_line "void serial_$name\($name *i_$name\);"
    print_line "void serial_read_$name\($name *i_$name\);"
}


proc For: {initial condition step body} {
    uplevel $initial
while {[uplevel "expr $condition"]} {
        uplevel [list tcl_preprocessor $body]
        uplevel $step
    }
}

proc Close_Bracket: {{num 1}} {
print_line [string repeat "\}" $num]
}
proc Open_Bracket: {{num 1}} {
print_line [string repeat "\{" $num]
}
proc Foreach: {iterator_var list body} {
    upvar $iterator_var iterator
    foreach iterator $list {
        uplevel [list tcl_preprocessor $body]
    }
}
proc define_message_templates {} {
    switch $::target_flag {
        TCL_MSG_REG {
        set printed {Info Warning Error Print Nl Token}
        set silent {Dinfo Dwarning Derror Dprint Dnl Dtoken}
        }
        TCL_MSG_SILENT {
        set printed {}
        set silent {Info Warning Error Print Nl Token Dinfo Dwarning Derror Dprint Dnl Dtoken}
        } 
        TCL_MSG_DEBUG {
        set printed {Info Warning Error Print Nl Token Dinfo Dwarning Derror Dprint Dnl Dtoken}
        set silent {}
        }
    }
    foreach cmd $printed {
        regsub -all @ {
        proc @: {pattern args} {
                set line "sprintf(tcl_print_buffer,\"@: $pattern\\n\""
                foreach field $args {
                    append line ,
                    append line $field
                }
                append line ");"
                print_line $line
                print_line "if (Tcl_Eval(interp,tcl_print_buffer)==TCL_ERROR) Tcl_Eval(interp,\"puts \$::errorInfo\");"
            }
        } $cmd body
        eval $body
    }
    foreach cmd $silent {
    proc $cmd: args {}
    }
}


