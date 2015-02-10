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

proc .goto {step} {
    if {[catch {expr $step+0}]} {
        if {[info exists ::$step]} {
	    GammaCommandGoto [set ::$step]
	    return
	}
	.label: this_step 
	incr this_step
	if {![info exists ::GammaAssemblerSecondPass($step)]} {
	    set ::GammaAssemblerSecondPass($step) {}
	}
	lappend ::GammaAssemblerSecondPass($step) $this_step
	GammaCommandGoto -1
	return
    }
    GammaCommandGoto $step
}
proc .return {value} {
    if {[catch {expr $value+0}]} {
        GammaCommandPushVar $value
	return
    }
    GammaCommandPush $value
}
proc .procedure {args} {
    if {![regexp {^\s*(\S+)\s+([^\{]+)\s+\{(.*)\}\s*$} $args -> name interface body]} {
        Error: .procedure syntax is <name> <arg1>...<arg2> (<code>)
    }
    set linebuf {}
    set braces_rank 0
    compile_Gamma_batch $body
    GammaCommandReturn [llength $interface]
}
set ::GammaConditionCounter 0
proc .if {condition body args} {
    compile_Gamma_expression $condition
    incr ::GammaConditionCounter
    set label IF$::GammaConditionCounter
    .goto $label
    compile_Gamma_batch $body
    .label: $label
}
proc compile_Gamma_batch {body} {
    foreach line [split $body \;] {
        append linebuf $line
        incr braces_rank [regexp -all {\{} $line]
        incr braces_rank -[regexp -all {\}} $line]
	skip {$braces_rank}
        if {![regexp {^\s*([A-Za-z0-9_^]+)\s*=\s*(.*)$} $linebuf -> name expression]} {
	    uplevel $linebuf
	    set linebuf {}
	    continue
	}
	compile_Gamma_expression $expression
        GammaCommandPopVar $name
	set linebuf {}
    }
}
proc .function {args} {
    array unset ::Gamma_function_args
    if {![regexp {^\s*([A-Za-z0-9_^]+)\s*\(([^\(\)]+)\)=\s*(.*)$} $args -> name arguments expression]} {
        Error: .function syntax is <name>(<arg1>,...,<argN>) = <expression>
    }
    .label: ::function($name,calculation)
    set i [llength [split $arguments ,]]
    foreach arg [split $arguments ,] {
	set ::Gamma_function_args($arg) $i
        incr i -1
    }
    foreach switch {unit min max} {
        if {[regexp "^(.*)\\-$switch\\s+(\\S+)(.*)\$" $expression -> pre val post]} {
            set ::function($name,$switch) $val
	    set expression "$pre $post"
        }
    }
    regsub -all {\s+} $expression {} expression
    compile_Gamma_expression $expression
    GammaCommandReturn [llength [split $arguments ,]]
}
proc .push {something} {
    if {[catch {expr $something+0}]} {
        if {[regexp {^\&(\S+)$} $something -> varname]} {
	    GammaCommandPushPointer $varname
	    Info: compiler output: GammaCommandPushPointer $varname 
	    return
	}
	GammaCommandPushVar $something
	Info: compiler output: GammaCommandPushVar $something
	return
    }
    GammaCommandPush $something
    Info: compiler output: GammaCommandPush $something
}
proc .property {args} {
    array unset ::Gamma_function_args
    if {![regexp {^\s*([A-Za-z0-9_^]+)\s*=\s*(.*)$} $args -> name expression]} {
        Error: .property syntax is <var> = <expression>
    }
    .label: ::property($name,calculation)
    foreach switch {unit min max} {
        if {[regexp "^(.*)\\-$switch\\s+(\\S+)(.*)\$" $expression -> pre val post]} {
            set ::property($name,$switch) $val
	    set expression "$pre $post"
        }
    }
    regsub -all {\s+} $expression {} expression
    compile_Gamma_expression $expression
    GammaCommandPopVar $name
    GammaCommandReturn 0
}
proc .calculate {var} {
    if {![info exists ::property($var,calculation)]} {
        Error: No such Gamma property: $var
	exit 
    }
    GammaCommandGoSub $::property($var,calculation)
}
proc compile_Gamma_expression {expression} {
    Info: Compiling expression $expression
    if {[regexp {^(\&?)\{([^\{\}]*)\}$} $expression -> amp encapsulated_expression]} {
        .push $amp$encapsulated_expression
	return @
    }
    # Deal with parentheses first
    if {[regexp {^(.*[^a-z]|)([A-Za-z]*)\(([^\(\)]+)\)(.*)$} $expression -> pre func arguments post]} {
        if {$func==""} {
	    # no function call, just parentheses
            compile_Gamma_expression $arguments
	    return [compile_Gamma_expression "$pre@$post"]
	}
	# function call
        foreach arg [split $arguments ,] {
	    compile_Gamma_expression $arg
	}
	if {[info exists ::function($func,calculation)]} {
	    GammaCommandGoSub $::function($func,calculation)
	    Info: compiler output: GammaCommandGoSub $::function($func,calculation)
	    GammaCommandDumpStack
	    return [compile_Gamma_expression "$pre@$post"]
	}
        set dc GammaCommand
	append dc [string totitle $func]
        $dc
	Info: compiler output: $dc
	return [compile_Gamma_expression "$pre@$post"]
    }
    foreach op {< > <= >= == != + - * /} op_name {LessThan GreaterThan AtMost AtLeast Equal Different Plus Minus Mult Div} {
        if {[regexp "^(.*)\\${op}(.*)\$" $expression -> pre post]} {
	    compile_Gamma_expression $post
	    compile_Gamma_expression $pre
	    GammaCommand$op_name
	    GammaCommandDumpStack
	    Info: compiler output: GammaCommand$op_name
	    return
	}
    }
    # Literal!
    if {$expression=="@"} return
    # A number 
    .push $expression
    GammaCommandDumpStack
}

proc LinkGamma {} {
    foreach label [array names ::GammaAssemblerSecondPass] {
        skip {![info exists ::$label]}
        set destination [set ::$label]
	foreach source $::GammaAssemblerSecondPass($label) {
	    skip {[SetGamma $source]!=-1}
	    SetGamma $source $destination
	}
    }
}

