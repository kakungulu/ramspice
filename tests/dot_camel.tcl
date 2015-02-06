# \
exec $RAMSPICE/ramspice $0 $argv

get_opts


proc .include {filename} {
    set I [open $filename r]
    set linebuf {}
    while {[gets $I line]>=0} {
        skip {[regexp {^\s*$} $line]}
	skip {[regexp {^\s*\*\s} $line]}
	if {[regexp {^\s*\+\s+(.*)$} $line -> line_content] } {
	    append linebuf " "
	    append linebuf $line_content
	    continue
	}
	if {![regexp {^\s*\.} $linebuf]} {
	    set linebuf ".instance $linebuf"
	}
	uplevel $linebuf
	set linebuf $line
    }
    if {![regexp {^\s*\.} $linebuf]} {
    	set linebuf ".instance $linebuf"
    }
    uplevel $linebuf
    close $I
}

proc .circuit {name} {
    set ::circuit_name $name
}

proc .instance {name args} {
    set ::nl($name,type) [string tolower [string index $name 0]]
    switch -regexp -- $::nl($name,type) {
        {[rcvi]} {
	    lassign $args ::nl($name,node1) ::nl($name,node2) ::nl($name,value)
	}
	m {
	    lassign $args ::nl($name,nodeD) ::nl($name,nodeG) ::nl($name,nodeS) ::nl($name,nodeB)
	}
	default {
	    Error: Instance card [string index $name 0] not supported at the moment
	}
    }
}

proc .function {args} {
    array unset ::DotCamel_function_args
    if {![regexp {^\s*([A-Za-z0-9_^]+)\s*\(([^\(\)]+)\)=\s*(.*)$} $args -> name arguments expression]} {
        Error: .function syntax is <name>(<arg1>,...,<argN>) = <expression>
    }
    Label: ::function($name,calculation)
    set i 0
    foreach arg [split $arguments ,] {
        incr i
	set ::DotCamel_function_args($arg) $i
    }
    foreach switch {unit min max} {
        if {[regexp "^(.*)\\-$switch\\s+(\\S+)(.*)\$" $expression -> pre val post]} {
            set ::function($name,$switch) $val
	    set expression "$pre $post"
        }
    }
    regsub -all {\s+} $expression {} expression
    compile_DotCamel_expression $expression
    DotCamelCommandReturn [llength [split $arguments ,]]
}
proc .property {args} {
    array unset ::DotCamel_function_args
    if {![regexp {^\s*([A-Za-z0-9_^]+)\s*=\s*(.*)$} $args -> name expression]} {
        Error: .property syntax is <var> = <expression>
    }
    Label: ::property($name,calculation)
    foreach switch {unit min max} {
        if {[regexp "^(.*)\\-$switch\\s+(\\S+)(.*)\$" $expression -> pre val post]} {
            set ::property($name,$switch) $val
	    set expression "$pre $post"
        }
    }
    regsub -all {\s+} $expression {} expression
    compile_DotCamel_expression $expression
    DotCamelCommandReturn 0
}

proc compile_DotCamel_expression {expression} {
    Info: Compiling expression $expression
    # Deal with parentheses first
    if {[regexp {^(.*[^a-z]|)([A-Za-z]*)\(([^\(\)]+)\)(.*)$} $expression -> pre func arguments post]} {
        if {$func==""} {
	    # no function call, just parentheses
            compile_DotCamel_expression $arguments
	    return [compile_DotCamel_expression "$pre@$post"]
	}
	# function call
        foreach arg [split $arguments ,] {
	    compile_DotCamel_expression $arg
	}
	if {[info exists ::function($func,calculation)]} {
	    DotCamelCommandGoSub $::function($func,calculation)
	    Info: compiler output: DotCamelCommandGoSub $::function($func,calculation)
	    DotCamelCommandDumpStack
	    return [compile_DotCamel_expression "$pre@$post"]
	}
        set dc DotCamelCommand
	append dc [string totitle $func]
        $dc
	Info: compiler output: $dc
	return [compile_DotCamel_expression "$pre@$post"]
    }
    foreach op {< > <= >= == != + - * /} op_name {LessThan GreaterThan AtMost AtLeast Equal Different Plus Minus Mult Div} {
        if {[regexp "^(.*)\\${op}(.*)\$" $expression -> pre post]} {
	    compile_DotCamel_expression $post
	    compile_DotCamel_expression $pre
	    DotCamelCommand$op_name
	    DotCamelCommandDumpStack
	    Info: compiler output: DotCamelCommand$op_name
	    return
	}
    }
    # Literal!
    if {$expression=="@"} return
    if {[catch {expr $expression+0}]} {
        if {[info exists ::DotCamel_function_args($expression)]} {
	    DotCamelCommandPushArg $::DotCamel_function_args($expression)
	    DotCamelCommandDumpStack
	    return
	}
        # must be variable
	DotCamelCommandPushVar $expression
        DotCamelCommandDumpStack
	Info: compiler output: DotCamelCommandPushVar $expression
	return
    }
    # A number 
    DotCamelCommandPush $expression
    DotCamelCommandDumpStack
    Info: compiler output: DotCamelCommandPush $expression
}

@ /test_vars/a !
@ /test_vars/a = real 4.0
@ /test_vars/b !
@ /test_vars/b = real 3.0
Info: a = [@ /test_vars/a]
InitDotCamel
@ /test_vars cd
### # Program
###     DotCamelCommandPushVar a
###     DotCamelCommandPushVar b
###     DotCamelCommandMult
### Label: MainLoop
###     DotCamelCommandPush 6.0
###     DotCamelCommandAtLeast
###     DotCamelCommandStop
###     DotCamelCommandPop
###     DotCamelCommandPush 1.0
###     DotCamelCommandPlus
###     DotCamelCommandDumpStack
###     DotCamelCommandGoto $MainLoop

# compile_DotCamel_expression (a+2*b+interpolate(ceil(a/4),b*3))/(b+3)
# compile_DotCamel_expression (a+7)/(b+3)
# DotCamelCommandDumpStack
# DotCamelCommandStop
# Test
# ResetDotCamel
# RunDotCamel
# Info: b = [@ b]
.property Ids=interpolate(Ids,Vgs,Vds,Vbs,L)*W/L -unit A -min 0 -max 1.0
.function square(x)=x*x
.property F=(a*7-square(2))/(b+square(3))
Info: property=[array get property]
Label: start_here
     DotCamelCommandGoSub $::property(F,calculation)
     DotCamelCommandDumpStack
     DotCamelCommandStop

RunDotCamel   $start_here
exit
