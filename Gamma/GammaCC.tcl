# \
exec $RAMSPICE/ramspice $0 $argv

namespace eval C {
    variable O stdout
    variable code {}
    variable code_template {
        #include <tcl.h>
        #include <stdio.h>
	#include "ctree.h"
	// Some global pointers to keep reference of the contexts this object manipulates
	GLOBAL_POINTERS_GO_HERE
	// The compiled function
        static int tcl_@name_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
            Tcl_ResetResult(interp);
	    LOCAL_BUFFER_INIT_GOES_HERE
	    USER_CODE_GOES_HERE
	    LOCAL_BUFFER_RETURN_GOES_HERE
            return TCL_OK;
        }
	// Initializing cTree references and registering the tcl_@name_cmd command as ::C::@name
        int @name_Init(Tcl_Interp *interp) {
	    float *array_entry;
	    context *c;
	    GLOBAL_POINTER_INIT_GO_HERE
            if (Tcl_InitStubs(interp, "8.1", 0) == NULL) {
                return TCL_ERROR;
            }
            Tcl_CreateObjCommand(interp, "::C::@name", tcl_@name_cmd, NULL, NULL);
            return TCL_OK;
        }
    }
}
proc ::C::count_braces {line minvar maxvar} {
    upvar $minvar min
    upvar $maxvar max
    set max 0
    set min 0
    set count 0
    for {set i 0} {$i < [string length $line]} {incr i} {
        set c [string index $line $i]
        if {$c=="\\"} {
            incr i
            continue
        }
        if {$c=="\{"} {
            incr count
        }
        if {$c=="\}"} {
            incr count -1
        }
        if {$count<$min} {
            set min $count
        }
        if {$count>$max} {
            set max $count
        }
    }
    return $count
}

proc ::C::print_line {line} {
    regsub -all {^\s*} $line {} line
    if {[string length $line]==0} return
    if {[regexp {^\S+:\s*$} $line]} {
        puts $::C::O $line
        return
    }
    set increment [::C::count_braces $line min max]
    if {$min<0} {
        incr ::rank $min
        puts -nonewline $::C::O [string repeat "    " $::rank]
        incr ::rank [expr -$min]
    } else {
        puts -nonewline $::C::O [string repeat "    " $::rank]
    }
    incr ::rank $increment
    puts $::C::O $line
}
proc ::C::tcl_preprocessor {c_code} {
    set bracket_rank 0
    set ::rank 0
    set lines [split $c_code \n]
    for {set i 0} {$i<[llength $lines]} {incr i ; set line [lindex $lines $i]} {
        set line [lindex $lines $i]
        if {[regexp {^\s*\/\/} $line]} {
            ::C::print_line $line
            continue
        }
        # Sometimes you can find Tcl code inside C. Don't pre-substitute variables in those.
        if {[regexp {^\s*Tcl_Eval} $line]} {
            ::C::print_line $line
            continue
        }
        # Identify a beginning of Tcl preprocessed block
        if {[regexp {^\s*\#tcl\s+(.*)$} $line -> tcl_command] || [regexp {^\s*\#([A-Z]\S+:.*)$} $line -> tcl_command]} {
            set bracket_rank [regexp -all {\{} $line]
            incr bracket_rank -[regexp -all {\}} $line]
            set template_body $tcl_command
            # one-liners can be precessed here
            while {($bracket_rank!=0)&&($i<[llength $lines])} {
                incr i
                set line [lindex $lines $i]
                append template_body \n
                append template_body $line
                incr bracket_rank [regexp -all {\{} $line]
                incr bracket_rank -[regexp -all {\}} $line]
            }
            uplevel #0 $template_body
            continue
        }
        # Substitute Tcl variables everywhere else.
        while {[regexp {\$\{(:*[a-zA-Z0-9_]+)\}} $line -> varname] } {
            if {[uplevel "info exists $varname"] && ![uplevel "array exists $varname"]} {
                regsub -all "\\\$\\\{$varname\\\}" $line [uplevel "set $varname"] line
            } else {
                regsub -all "\\\$\\\{$varname\\\}" $line "\$`$varname" line
            }
        }
        while {[regexp {\$(:*[a-zA-Z0-9_]+)} $line -> varname] } {
            if {[uplevel "info exists $varname"] && ![uplevel "array exists $varname"]} {
                regsub -all "\\\$$varname" $line [uplevel "set $varname"] line
            } else {
                regsub -all "\\\$$varname" $line "\$`$varname" line
            }
        }
        regsub -all {\$`} $line {\$} line
        # print simplified and substituted lines here
        ::C::print_line $line
    }
}


proc gcc {name {code {}}} {
    if {$code=={}} {
        set code $::C::code
	set ::C::code {}
    }
    if {![string equal $name [string totitle $name]]} {
        Error: Naming convention of dynamically compiled code is Title. $name should be [string totitle $name]
	exit
    }
    set global_pointers {}
    set global_pointer_init {}
    set local_buffer_init_goes_here {}
    set local_buffer_return_goes_here {}
    set used_var_names {}
    set used_pointer_names {}
    while {[regexp {@+([A-Za-z0-9_:]+)} $code -> context_string]} {
        if {[info exists pointer_names($context_string)]} {
	    regsub "&@+$context_string" $code $pointer_names($context_string) code
	    regsub "@+$context_string" $code $var_names($context_string) code
	    continue
	}
	if {[regexp {^[0-9]} $context_string]} {
	    regsub -all {[^a-zA-Z_0-9]} CONST_$context_string _ var_name
	} else {
	    regsub -all {[^a-zA-Z_0-9]} $context_string _ var_name
	}
	regsub -all {[^a-zA-Z_0-9]} P$context_string _ pointer_name
	if {[lsearch $used_var_names $var_name]!=-1} {
	    set i 0
	    while {[lsearch $used_var_names $var_name$i]!=-1} {
	        incr i
	    }
	    set var_name $var_name$i
	}
	lappend used_var_names $var_name
	if {[lsearch $used_pointer_names $pointer_name]!=-1} {
	    set i 0
	    while {[lsearch $used_pointer_names $pointer_name$i]!=-1} {
	        incr i
	    }
	    set pointer_name $pointer_name$i
	}
	lappend used_pointer_names $pointer_name
        append global_pointers "float *$pointer_name;\n"
	append global_pointer_init "resolve_context(\"$context_string\",`c,`array_entry);\n"
	append global_pointer_init "$pointer_name=(float *)(`c->value.s);\n"
	append local_buffer_init_goes_here "float $var_name=*$pointer_name;\n"
	append local_buffer_return_goes_here "*$pointer_name=$var_name;\n"
	regsub "&@+$context_string" $code $pointer_name code
	regsub "@+$context_string" $code $var_name code
	set pointer_names($context_string) $pointer_name
	set var_names($context_string) $var_name
	incr i
    }
    regsub -all \& $code ` code
    regsub -all @name $::C::code_template $name body
    regsub USER_CODE_GOES_HERE $body $code body
    regsub GLOBAL_POINTERS_GO_HERE $body $global_pointers body
    regsub GLOBAL_POINTER_INIT_GO_HERE $body $global_pointer_init body
    regsub LOCAL_BUFFER_INIT_GOES_HERE $body $local_buffer_init_goes_here body
    regsub LOCAL_BUFFER_RETURN_GOES_HERE $body $local_buffer_return_goes_here body
    regsub -all ` $body {\&} body
    set ::C::O [open /tmp/$name.c w]
    ::C::tcl_preprocessor $body
    close $::C::O
    
    set find_lib_stub [glob -nocomplain /usr/*/libtclstub*]
    if {$find_lib_stub=={}} {
        Error: This system has no tclstub library and therefore can't compile code on the fly.
	exit
    }
   
    ######## Compilation
    default ::binary [ginfo binary]
    default ::target [ginfo target]
    set build_path /tmp/${::binary}_build/preprocessed-${::target}
    eval exec gcc /tmp/${::binary}_build/object_files-${::target}/ctree.o /tmp/${::binary}_build/object_files-${::target}/serialize.o /tmp/${::binary}_build/object_files-${::target}/look_up_table.o /tmp/${::binary}_build/object_files-${::target}/ramspice_types.o \
                  -fPIC -shared -DUSE_TCL_STUBS -I$build_path -I$build_path/Gamma/Data -I$build_path/ngspice/root/maths/poly -I$build_path/ngspice/root/frontend -I$build_path/ngspice/root/spicelib/devices \
		  -I$build_path/ngspice/root/xspice/icm/analog -I/usr/include /tmp/${name}.c -L[file dirname [lindex $find_lib_stub 0]] -ltclstub[info tclversion]  -o /tmp/lib${name}.so
    load /tmp/lib${name}.so
}
proc *c {args} {
    set body $args
    if {[llength $body]!=1} {
        append ::C::code "$body;\n"
    } else {
	append ::C::code [lindex $body 0]
	append ::C::code "\n"
    }
}
return
# Example: 

# cTree contexts do not have to be created before code or even compilation. They must be ready before the command is called.
@ r/a = 5
@ r/b = 3
@ c = 0

*c int i=0;

*c {
    @c=@r/a*@r/b;
    for (i=0;i<@r/a;i++) @c=@c*2;
    printf("I found C in %x\n",&@c);
}
gcc Test

::C::Test
Info: c=[@ c]
exit


