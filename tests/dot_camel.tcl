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
    if {![regexp {^\s*([A-Za-z0-9_^]+)\s*\(([^\(\)]+)\)=\s*(.*)$} $args -> name arguments expression]} {
        Error: .function syntax is <name>(<arg1>,...,<argN>) = <expression>
    }
    Label: ::function($name,calculation)
    foreach switch {unit min max} {
        if {[regexp "^(.*)\\-$switch\\s+(\\S+)(.*)\$" $expression -> pre val post]} {
            set ::function($name,$switch) $val
	    set expression "$pre $post"
        }
    }
    regsub -all {\s+} $expression {} expression
    compile_camel_expression $expression
    DotCamelCommandReturn
}
proc .property {args} {
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
    compile_camel_expression $expression
    DotCamelCommandReturn
}

proc compile_camel_expression {expression} {
    Info: Compiling expression $expression
    if {[regexp {^(|.*[^a-z])\(([^\(\)]+)\)(.*)$} $expression -> pre sub_expression post]} {
        compile_camel_expression $sub_expression
	return [compile_camel_expression "$pre@$post"]
    }
    if {[regexp {^(|.*[^a-z])([A-Za-z]+)\(([^\(\)]+)\)(.*)$} $expression -> pre func arguments post]} {
        foreach arg [split $arguments ,] {
	    compile_camel_expression $arg
	}
        set dc DotCamelCommand
	append dc [string totitle $func]
        $dc
	Info: compiler output: $dc
	return [compile_camel_expression "$pre@$post"]
    }
    foreach op {< > <= >= == != + - * /} op_name {LessThan GreaterThan AtMost AtLeast Equal Different Plus Minus Mult Div} {
        if {[regexp "^(.*)\\${op}(.*)\$" $expression -> pre post]} {
	    compile_camel_expression $post
	    compile_camel_expression $pre
	    DotCamelCommand$op_name
	    Info: compiler output: DotCamelCommand$op_name
	    return
	}
    }
    # Literal!
    if {$expression=="@"} return
    if {[catch {expr $expression+0}]} {
        # must be variable
	DotCamelCommandPushVar $expression
	Info: compiler output: DotCamelCommandPushVar $expression
	return
    }
    # A number 
    DotCamelCommandPush $expression
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

# compile_camel_expression (a+2*b+interpolate(ceil(a/4),b*3))/(b+3)
# compile_camel_expression (a+7)/(b+3)
# DotCamelCommandDumpStack
# DotCamelCommandStop
# Test
# ResetDotCamel
# RunDotCamel
# Info: b = [@ b]
.property Ids=interpolate(Ids,Vgs,Vds,Vbs,L)*W/L -unit A -min 0 -max 1.0
.property F=(a+7)/(b+3)
Info: property=[array get property]
Label: start_here
     DotCamelCommandGoSub $::property(F,calculation)
     DotCamelCommandDumpStack
     DotCamelCommandStop

RunDotCamel   $start_here
exit
