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
proc LinkGamma {} {
    foreach label [array names ::GammaAssemblerSecondPass] {
        Info: Linking label $label [info exists ::$label]
        skip {![info exists ::$label]}
        set destination [set ::$label]
	foreach source $::GammaAssemblerSecondPass($label) {
	   
	    skip {[..set $source]!=-1}
	    
	    ..set $source $destination
	}
    }
}



proc .return {value} {
    if {[catch {expr $value+0}]} {
        GammaCommandPushVar $value
	return
    }
    GammaCommandPush $value
}
proc .procedure {name args} {
    array unset ::Gamma_function_args
    set body [lindex $args end]
    set interface [lrange $args 1 end-1]
    set i [llength $interface]
    foreach arg $interface {
	set ::Gamma_function_args($arg) $i
        incr i -1
    }
    .label: ::function($name,calculation)
    uplevel $body
    GammaCommandReturn [llength $interface]
    array unset ::Gamma_function_args
    set body ""
    foreach arg $interface {
        append body "..push $arg\n"
    }
    append body "..run $::function($name,calculation)"
    proc $name $interface $body
}
set ::GammaConditionCounter 0
proc .if {args} {
    set cond_code_list {}
    foreach field $args {
        skip {$field=="else"}
        skip {$field=="elseif"}
	lappend cond_code_list $field
    }
    set else_code {}
    if {[llength $cond_code_list]%2} {
        set else_code [lindex $cond_code_list end]
	set cond_code_list [lrange $cond_code_list 0 end-1]
    }
    incr ::GammaConditionCounter
    set end_label ENDIF$::GammaConditionCounter
    foreach {cond code} $cond_code_list {
        Gamma_expression $cond
        incr ::GammaConditionCounter
        set do_label IF$::GammaConditionCounter
	.goto $do_label
        incr ::GammaConditionCounter
        set skip_label IF$::GammaConditionCounter
        .goto $skip_label
	.label: ::$do_label
        uplevel $code
	.goto $end_label
        .label: ::$skip_label
    }
    uplevel $else_code
    .label: ::$end_label
    LinkGamma
}
proc .while {cond body} {
    .label: while_label
    Gamma_expression $cond
    incr ::GammaConditionCounter
    set do_label IF$::GammaConditionCounter
    .goto $do_label
    incr ::GammaConditionCounter
    set skip_label IF$::GammaConditionCounter
    .goto $skip_label
    .label: ::$do_label
    uplevel $body
    .goto $while_label
    .label: ::$skip_label
    LinkGamma
}
proc .for {init cond step body} {
    uplevel $init
    .label: while_label
    Gamma_expression $cond
    incr ::GammaConditionCounter
    set do_label IF$::GammaConditionCounter
    .goto $do_label
    incr ::GammaConditionCounter
    set skip_label IF$::GammaConditionCounter
    .goto $skip_label
    .label: ::$do_label
    uplevel $body
    uplevel $step
    .goto $while_label
    .label: ::$skip_label
    LinkGamma
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
    Gamma_expression $expression
    GammaCommandReturn [llength [split $arguments ,]]
    array unset ::Gamma_function_args
}
proc .push {something} {
    if {[info exists ::Gamma_expression_constants($something)]} {
    	GammaCommandPush $::Gamma_expression_constants($something)
    	return
    }
    if {[catch {expr $something+0}]} {
        if {[regexp {^\&(\S+)$} $something -> varname]} {
	    if {![@ $varname ?]} {
	        @ $varname !
		@ $varname = real 0
	    }
	    GammaCommandPushPointer $varname
	    return
	}
	if {[info exists ::Gamma_function_args($something)]} {
	    GammaCommandPushArg $::Gamma_function_args($something)
	    return
	}
	GammaCommandPushVar $something
	return
    }
    GammaCommandPush $something
}
proc .let {args} {
    array unset ::Gamma_function_args
    if {![regexp {^\s*([A-Za-z0-9_^]+)\s*=\s*(.*)$} $args -> name expression]} {
        Error: .property syntax is <var> = <expression>
    }
    if {![@ $name ?]} {
        @ $name !
	@ $name = real 0
    }
    foreach switch {unit min max} {
        if {[regexp "^(.*)\\-$switch\\s+(\\S+)(.*)\$" $expression -> pre val post]} {
            set ::property($name,$switch) $val
	    set expression "$pre $post"
        }
    }
    regsub -all {\s+} $expression {} expression
    Gamma_expression $expression
    GammaCommandPopVar $name
}
proc .property {args} {
    array unset ::Gamma_function_args
    if {![regexp {^\s*([A-Za-z0-9_^]+)\s*=\s*(.*)$} $args -> name expression]} {
        Error: .property syntax is <var> = <expression>
    }
    .label: ::property($name,calculation)
    if {![@ $name ?]} {
        @ $name !
	@ $name = real 0
    }
    foreach switch {unit min max} {
        if {[regexp "^(.*)\\-$switch\\s+(\\S+)(.*)\$" $expression -> pre val post]} {
            set ::property($name,$switch) $val
	    set expression "$pre $post"
        }
    }
    regsub -all {\s+} $expression {} expression
    Gamma_expression $expression
    GammaCommandPopVar $name
    GammaCommandReturn 0
}
proc .calculate {var} {
    if {![info exists ::property($var,calculation)]} {
        Error: No such Gamma property: $var
	exit 
    }
    .run $::property($var,calculation)
}
set ::Gamma_expression_counter 0
proc Gamma_expression {expression} {
    regsub -all {\s} $expression "" expression
    set expression [uplevel #0 "subst $expression"]
    array unset ::Gamma_expression_constants
    Info: EXPRESSION $expression
    while {[regexp {^(.*[^0-9_A-Za-z\.]|)([0-9]*\.?[0-9]+)([eE][-+][0-9]+)(.*)$} $expression -> pre mantissa exponenta post]} {
        set handle "CONSTVALUE_"
	append handle [array size ::Gamma_expression_constants]
	set ::Gamma_expression_constants($handle) $mantissa$exponenta
	set expression "$pre$handle$post"
        Info: EXPRESSION $expression
    }
    compile_Gamma_expression $expression
}
proc compile_Gamma_expression {expression} {
    Info: Compiling expression $expression
    incr ::Gamma_expression_counter
    if {[regexp {^(\&?)\{([^\{\}]*)\}$} $expression -> amp encapsulated_expression]} {
        .push $amp$encapsulated_expression
	return @$::Gamma_expression_counter
    }
    # Deal with parentheses first
    if {[regexp {^(.*[^A-Za-z0-9_]|)([A-Za-z0-9_]*)\(([^\(\)]+)\)(.*)$} $expression -> pre func arguments post]} {
        if {$func==""} {
	    # no function call, just parentheses
            compile_Gamma_expression $arguments
	    return [compile_Gamma_expression "$pre@$::Gamma_expression_counter$post"]
	}
	# function call
        foreach arg [split $arguments ,] {
	    compile_Gamma_expression $arg
	}
	if {[info exists ::function($func,calculation)]} {
	    GammaCommandGoSub $::function($func,calculation)
	    return [compile_Gamma_expression "$pre@$::Gamma_expression_counter$post"]
	}
        set dc GammaCommand
	append dc [string totitle $func]
        $dc
	return [compile_Gamma_expression "$pre@$::Gamma_expression_counter$post"]
    }
    foreach op "x7c\\\\x7c x26\\x26 < > <= >= == != + - * /" op_name {Or And LessThan GreaterThan AtMost AtLeast Equal Different Plus Minus Mult Div} {
        set pattern "^(.*)\\"
	append pattern $op
	append pattern "(.+)\$" 
        if {[regexp $pattern $expression -> pre post]} {
	#    Info: pattern=$pattern Op=$op Op_name=$op_name
	    if {![regexp {^@([0-9]+)} $pre -> pre_num]} {
	        set pre_num $::Gamma_expression_counter
	    }
	    if {![regexp {^@([0-9]+)} $post -> post_num]} {
	        set post_num $::Gamma_expression_counter
	    }
	    if {$pre=={}} {
	        set pre 0
	    }
	    compile_Gamma_expression $post
	    compile_Gamma_expression $pre
	    if {$post_num>$pre_num && [lsearch {< > <= >= - /} $op]!=-1} {
	        GammaCommandReverse
	    }
	    GammaCommand$op_name
	    return
	}
    }
    # Literal!
    if {[regexp {^@([0-9]+)} $expression -> num]} return
    # A number 
    .push $expression
}
set unknown {
    if {[regexp {^[A-Za-z_/][/A-Za-z0-9_]*\s*=} $args]} {
        uplevel ".let $args"
	return
    }
}
append unknown [info body unknown]
proc unknown args $unknown

