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
proc If: {condition body {else {}}} {
    if {[uplevel "expr $condition"]} {
        uplevel [list tcl_preprocessor $body]
    } elseif {$else!={}} {
        uplevel [list tcl_preprocessor $else]
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
foreach cmd {Info Warning Error} {
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

