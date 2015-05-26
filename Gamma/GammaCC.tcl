# \
exec $RAMSPICE/ramspice $0 $argv

################################################
#
#            Topology compiler
#
################################################
proc .prep_kcl {mode} {
     array unset ::KCL
    @ s = 0
    set ::independent_nodes {}
    foreach node [lsort $::all_nodes] {
        skip {$node==0}
        lappend ::independent_nodes $node
    }
    set dim [llength $::independent_nodes]
    array set ::KCL [list dim $dim]
    # Add resistors
    foreach res_nodes [array names ::all_resistors] {
        lassign [split $res_nodes ,] m p
        foreach node [list $m $p ] {
            if {[info exists ::vdc($node)]} {
                set V($node) $::vdc($node)
            } else {
                set V($node) $node:V
            }
        }
        if {[catch {set G [expr 1.0/$::all_resistors($res_nodes)]}]} {
            set ::G_equations(${m}_${p}) 1.0/@$::all_resistors($res_nodes)
            set G Gds_${m}_${p}
            set ::sensitivity(Gds_${m}_${p},$::all_resistors($res_nodes)) -1.0/($::all_resistors($res_nodes)*$::all_resistors($res_nodes))
        }
        add_kcl $m $m $G
        add_kcl $p $p $G
        add_kcl $p $m -$G
        add_kcl $m $p -$G
    }
    array unset ::Ids_equations
    
    #Add transistors
    foreach name $::all_transistors {
        foreach field {type L W d g s b} {
            set $field $::transistors($name,$field)
        }
        foreach node_name {d g s b} {
            set node [set $node_name]
            if {[info exists ::vdc($node)]} {
                set V$node_name $::vdc($node)
            } else {
                set V$node_name $node:V
                #               @ $node:V = [expr $::opt(topv)]
                if {![@ $node:V ?]} {
                    @ $node:V = $::opt(topv)
                }
                if {![@ $node:Next ?]} {
                    @ $node:Next = $::opt(topv)
                }
            }
        }
        #        add_kcl_entry $s $d "Gds_$name"
        set ::transistors($name,Vgs) [Vdiff $Vg $Vs]
        @ Gds_$name = 1
        add_kcl $s $s "+@$name:go"
        add_kcl $s $d "-@$name:go"
        add_kcl $d $s "-@$name:go"
        add_kcl $d $d "+@$name:go"
        default ::idc($d,$s)
        append ::idc($d,$s) "-@$name:Ideq"
        add_kcl $s $s "+@$name:gm"
        add_kcl $s $g "-@$name:gm"
        add_kcl $d $s "-@$name:gm"
        add_kcl $d $g "+@$name:gm"
        if {$type=="nch"} {
            set ::Ids_equations($name) "gamma_gcc_interpolate_4(&@:look_up_tables:$type:Ids:$::opt(process),[Vdiff $Vg $Vs],[Vdiff $Vd $Vs],[Vdiff $Vb $Vs],@$L)*@$W-@$name:gm*[Vdiff $Vg $Vs]-@$name:go*[Vdiff $Vd $Vs]"
        } else {
            set ::Ids_equations($name) "-gamma_gcc_interpolate_4(&@:look_up_tables:$type:Ids:$::opt(process),[Vdiff $Vg $Vs],[Vdiff $Vd $Vs],[Vdiff $Vb $Vs],@$L)*@$W-@$name:gm*[Vdiff $Vg $Vs]-@$name:go*[Vdiff $Vd $Vs]"
        }
	set ::Nt_equations($name) "gamma_gcc_interpolateg_4(&@:look_up_tables:$type:thermal_noise:ss:,[Vdiff $Vg $Vs],[Vdiff $Vd $Vs],[Vdiff $Vb $Vs],@$L,&(@$name:dNt_dvgs),&(@$name:dNt_dvds),&(@$name:dNt_dvbs),&(@$name:dNt_dl))*sqrt(@$name:gm)"
	set ::Nf_equations($name) "gamma_gcc_interpolateg_4(&@:look_up_tables:$type:flicker_noise:ss:,[Vdiff $Vg $Vs],[Vdiff $Vd $Vs],[Vdiff $Vb $Vs],@$L,&(@$name:dNf_dvgs),&(@$name:dNf_dvds),&(@$name:dNf_dvbs),&(@$name:dNf_dl))*@$name:gm/sqrt(@$W*@$L*@$L)"
        set ::gm_equations($name) "gamma_gcc_interpolateg_4(&@:look_up_tables:$type:gm:$::opt(process),[Vdiff $Vg $Vs],[Vdiff $Vd $Vs],[Vdiff $Vb $Vs],@$L,&(@$name:dgm_dvgs),&(@$name:dgm_dvds),&(@$name:dgm_dvbs),&(@$name:dgm_dl))*@$W"
        set ::go_equations($name) "@$W/gamma_gcc_interpolateg_4(&@:look_up_tables:$type:ro:$::opt(process),[Vdiff $Vg $Vs],[Vdiff $Vd $Vs],[Vdiff $Vb $Vs],@$L,&(@$name:dro_dvgs),&(@$name:dro_dvds),&(@$name:dro_dvbs),&(@$name:dro_dl))"
        @ $name:Ideq = 0
        @ $name:go = 1
        @ $name:gm = 1
        set ::sensitivity($name:gm,$W) @$name:gm:$W
        @ $name:gm:$W = 0
        $name:gm:$W=>@$name:gm/@$W
        set ::sensitivity($name:gm,$L) @$name:gm:$L
        @ $name:gm:$L = 0
        $name:gm:$L=>@$name:dgm_dl*@$W
        @ $name:go:$W = 0
        set ::sensitivity($name:go,$W) @$name:go:$W
        $name:go:$W=>@$name:go/@$W
        set ::sensitivity($name:go,$L) @$name:go:$L
        @ $name:go:$L = 0
        $name:go:$L=>-@$name:go*(@$name:dro_dl*@$name:go/@$W)
        if {$mode=="ac" || $mode=="noise"} {
            add_kcl $s $g "-@$name:cgs*s"
            add_kcl $g $s "+@$name:cgs*s"
            add_kcl $d $g "-@$name:cgd*s"
            add_kcl $g $d "+@$name:cgd*s"
            $name:cgs=>0.66666*[@ /look_up_tables/$type/cox]*@$L*@$L*@$W
            $name:cgd=>0.33334*[@ /look_up_tables/$type/cox]*@$L*@$L*@$W
        }
    }
    foreach idc_pair [array names ::idc] {
        lassign [split $idc_pair ,] m p
        foreach node [list $m $p] sign {+ -} {
            skip {$node==0} 
            set index [lsearch $::independent_nodes $node]
            default ::KCL($index)
            set element $::idc($idc_pair)
            if {![regexp {^[0-9\-\+]} $element]} {
                set element "@$element"
            }
            regsub -all {\-\-} "$sign$element" {+} entry
            regsub -all {\-\+} $entry {-} entry
            regsub {^\++} $entry {+} entry
            append ::KCL($index) "$entry"
            regsub {^\++} $::KCL($index)  {} ::KCL($index)
        }
    }
    set all_vdc [array names ::vdc]
    set i $dim
    foreach vdc_pair $all_vdc {
        lassign [split $vdc_pair ,] m p
        default ::KCL($m,$p)
        default ::KCL($p,$m)
        foreach node [list $m $p] entry {-1 1} {
            if {$node!="0"} {
                set j [lsearch $::independent_nodes $node]
                set ::KCL($j,$i) $entry
                set ::KCL($i,$j) $entry
            }
        }
        set ::KCL($i) @$::vdc($vdc_pair)
        incr i
    }
    set ::KCLy {}
    for {set i 0} {$i<$dim} {incr i} {
        if {![info exists ::KCL($i)]} {
            lappend ::KCLy 0
        } else {
            lappend ::KCLy $::KCL($i)
        }
    }
    foreach vdc_pair $all_vdc {
        lappend ::KCLy $::vdc($vdc_pair)
    }
    set dim [llength $::KCLy]
    set ::KCL(dim) $dim	
    Info: Done preparing matrix for $mode mode
}
proc .compile_circuit {args} {
    get_opts outp {} out {} outn {} in {} inn {} inp {} sup {} name {}
    if {$opt(name)=={}} {
        set opt(name) $::opt(topology)
    }
    if {$opt(outp)=={} && $opt(outn)=={} && $opt(out)=={}} {
        Error: Can't compile a circuit without a defined output. Add -out <net> to the .compile_circuit command
        exit
    }
    if {$opt(inp)=={} && $opt(inn)=={} && $opt(in)=={}} {
        Error: Can't compile a circuit without a defined input. Add -in <net> to the .compile_circuit command
        exit
    }
    
    ######## Abstract circuit properties
    if {($opt(outp)!={} || $opt(out)!={}) && $opt(outn)=={}} {
        if {$opt(outp)!={} && $opt(out)!={} && $opt(out)!=$opt(outp)} {
            Error: Conflicting definitions of output net: $opt(out)!=$opt(outp)
            exit
        }
        if {$opt(outp)!={}} {
            set output_net $opt(outp)
        } else {
            set output_net $opt(out)
        }
        if {$opt(inp)!={} && $opt(inn)!={} && $opt(in)!={}} {
            Error: Conflicting definitions of input net.
            exit
        }
        if {$opt(inp)!={} && $opt(inn)!={}} {
            if {![@ property/Adc !]} {
                .property Adc -expression derive($output_net,$opt(inp))-derive($output_net,$opt(inn)) -to_display 20*log10(@) -from_display pow(10,@/20) -unit dB
            }
        } elseif {$opt(in)!={}} {
            if {![@ property/Adc !]} {
                .property Adc -expression derive($output_net,$opt(in))) -to_display 20*log10(@) -from_display pow(10,@/20) -unit dB
            }
        }
        if {$opt(inp)!={} && $opt(inn)!={}} {
            if {![@ property/CMRR !]} {
                .property CMRR -expression derive($output_net,$opt(inp))+derive($output_net,$opt(inn)) -to_display 20*log10(@) -from_display pow(10,@/20) -unit dB
            }
        }
        if {![@ property/PSRR !]} {
            if {$opt(sup)=={}} {
                Error: Can't define PSRR code for the circuit, because it has no -sup defined.
		exit
            }
            .property PSRR -expression derive($output_net,$opt(sup)) -to_display 20*log10(@) -from_display pow(10,@/20) -unit dB
        }
    }
    .prep_kcl dc
    set dim $::KCL(dim)
    set HTML [open /tmp/KCL.html w]
    puts $HTML <html>
    puts $HTML <head>
    puts $HTML {<style type="text/css">
        .matrix {
            position: relative;
        }
        .matrix:before, .matrix:after {
            content: "";
            position: absolute;
            top: 0;
            border: 1px solid #000;
            width: 6px;
            height: 100%;
        }
        .matrix:before {
            left: -6px;
            border-right: 0;
        }
        .matrix:after {
            right: -6px;
            border-left: 0;
        } 
    }
    puts $HTML </style>
    puts $HTML </head>
    puts $HTML <body>
    puts $HTML "<table class=\"matrix\">"
    for {set i 0} {$i<$dim} {incr i} {
        puts $HTML <tr>
        puts $HTML <td>
        puts $HTML <b>
        puts $HTML [lindex $::independent_nodes $i]
        puts $HTML </b>
        puts $HTML </td>
        for {set j 0} {$j<$dim} {incr j} {
            puts $HTML <td>
            if {[info exists ::KCL($i,$j)]} {
                puts $HTML $::KCL($i,$j)
            } else {
                puts $HTML 0
            }
            puts $HTML </td>
        }
        puts $HTML <td>
        puts $HTML [lindex $::KCLy $i]
        puts $HTML </td>
        puts $HTML </tr>
    }
    puts $HTML </table>
    puts $HTML <h3>
    puts $HTML Det=[present_poly g Det]
    puts $HTML </h3>
    @ op_iterations = $::opt(op_limit)
    *c "// Calculating circuit operating point:"
    *c "int op_it=0;"
    *c "for (op_it=0;op_it<@op_iterations;op_it++) \{"
    foreach name [array names ::Ids_equations] {
        if {[info exists ::gm_equations($name)]} {
            *c "@$name:gm=$::gm_equations($name);"
            *c "@$name:go=$::go_equations($name);"
        } else {
            *c "@$name:g=$::g_equations($name);"
        }
        *c "@$name:Ideq=$::Ids_equations($name);"
        *c "@$name:Nt=$::Nt_equations($name);"
        *c "@$name:Nf=$::Nf_equations($name)*@$name:gm*@$W;"
    }
    foreach name [array names ::G_equations] {
        *c "@Gds_$name:g=$::G_equations($name);"
        .default Gds_$name 1e+0
    }
    set expression(Det) [DET ::KCL]
    *c "@Det=$expression(Det);"
    *c "@Ted=1/@Det;"
    detp ::KCL g
    set i 0
    foreach node $::independent_nodes {
        detp ::KCL poly_$node 0 {} $i $::KCLy
        Info: Setting poly poly_$node to [list_poly poly_$node]
        set poly [present_poly_c poly_$node $node:Next]
        $node=>($poly)*@Ted
        *c "@$node=($poly)*@Ted;"
        puts $HTML "$node:Next=$poly<br><br>"
        incr i
    }
    *c "\}"
    *c "// Calculating circuit properties:"
    @ property foreach_child p {
        Info: PROPERTY $p=$::properties($p,expression)
        set expression($p) [flat_expression  $::properties($p,expression)]
        *c "@property:$p=$expression($p);"
    }	
    *c "// Calculating circuit properties' gradients:"
    foreach transistor $::all_transistors {
        foreach admittance {gm go} {
            @ $transistor:$admittance:size foreach_child c {
                if {[info exists ::DEF($transistor:$admittance:size:$c)]} {
                    *c "@$transistor:$admittance:size:$c=$::DEF($transistor:$admittance:size:$c);"
                }
            }
        }
    }
    @ size foreach_child c {
        derive_poly g size:$c dg_d$c
        set derived_poly [present_poly_c dg_d$c Det_d$c]
        *c "@Det:$c=$derived_poly;"
        *c "@Ted:$c=-@Det:$c/(@Det*@Det);"
        set ::sensitivity(Det,size:$c) Det:$c
        set ::sensitivity(Ted,size:$c) Ted:$c
        
    }
    Info: Deriving DET
    foreach transistor $::all_transistors {
        foreach admittance {gm go} {
            set dpoly(Det,$transistor,$admittance) [derive_expression @$transistor:$admittance $expression(Det)]
            *c "@Det_${transistor}_${admittance}=$dpoly(Det,$transistor,$admittance);"
            *c "@Ted_${transistor}_${admittance}=-@Det_${transistor}_${admittance}/(@Det*@Det);"
        }
    }
    @ property foreach_child p {
        foreach transistor $::all_transistors {
            foreach admittance {gm go} {
                set dpoly($p,$transistor,$admittance) [derive_expression @$transistor:$admittance $expression($p)]
                *c "@${p}_${transistor}_${admittance}=@Ted_${transistor}_${admittance}*@$p+$dpoly($p,$transistor,$admittance);"
            }
        }
        @ size foreach_child c {
            set chain {}
            foreach influence [array names ::DEF *:*:size:$c] {
                lassign [split $influence :] transistor admittance
                lappend chain "@$transistor:$admittance:size:$c*@${p}_${transistor}_${admittance}"
            }
            *c "@${p}_${c}=[join $chain +];"
        }
        
    }
    @ 0:V = 0
    .prep_kcl ac
    set expression(Det_ac) [DET ::KCL]
    set expression(dDet_ac) [derive_expression @s $expression(Det_ac)]
    *c "@s=0;"
    *c "int BW_it;"
    *c "for (BW_it=0;BW_it<10;BW_it++) \{"
    *c "    @s-=($expression(Det_ac))/($expression(dDet_ac));"
    *c "\}"
    foreach transistor $::all_transistors {
        foreach admittance {gm go} {
            set dpoly(Det_ac,$transistor,$admittance) [derive_expression @$transistor:$admittance $expression(Det_ac)]
            *c "@Det_ac_${transistor}_${admittance}=$dpoly(Det_ac,$transistor,$admittance);"
        }
    }
    *c "@dBW_ds=$expression(dDet_ac);"
    *c "@p1=-@s;"
    *c "@BW=-@s/(2*3.141592656);"
    *c "@s=0;"
    *c "for (BW_it=0;BW_it<10;BW_it++) \{"
    *c "    float nom=$expression(Det_ac);"
    *c "    @s-=(nom*(@s+@p1))/($expression(dDet_ac)*(@s+@p1)-nom);"
    *c "\}"
    *c "@p2=-@s;"
    *c "float A1=-@p2/(-@p1+@p2);"
    *c "float A2=-@p1/(-@p1+@p2);"
    *c "@ts=0;"
    *c "for (BW_it=0;BW_it<10;BW_it++) \{"
    *c "    @ts-=(0.02+A1*exp(-@p1*@ts)+A2*exp(-@p2*@ts))/(-@p1*A1*exp(-@p1*@ts)-@p2*A2*exp(-@p2*@ts));"
    *c "\}"
    *c "@dts_ds=-@p1*A1*exp(-@p1*@ts)-@p2*A2*exp(-@p2*@ts);"
    @ size foreach_child c {
        set chain {}
        foreach influence [array names ::DEF *:*:size:$c] {
            lassign [split $influence :] transistor admittance
            lappend chain "@$transistor:$admittance:size:$c*@Det_ac_${transistor}_${admittance}"
        }
        *c "@BW_${c}=-([join $chain +])/@dBW_ds;"
        *c "@ts_${c}=-([join $chain +])/@dts_ds;"
    }
    foreach transistor $::all_transistors {
        foreach admittance {gm go} {
	    *c "float Nt_$transistor_$admittance="
    }    
    @ size foreach_child c {
    	foreach influence [array names ::DEF *:*:size:$c] {
    	    lassign [split $influence :] transistor admittance
            if {[string match *L* $c]} {
	        *c "@$transistor:Nt:$c=@$transistor:dNt_dl*sqrt(@$transistor:gm)+@$transistor:Nt/(2*@$transistor:gm)*@$transistor:gm:size:$c;"
	        *c "@$transistor:Nf:$c="
	    } else {
	        *c "@$transistor:Nt:$c="
	        *c "@$transistor:Nf:$c="
	    }
	 }
    }	    
    # Define Data Dependencies
    gcc Op_$opt(name)
}



























################################################
#
#            gcc Interface
#
################################################

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


