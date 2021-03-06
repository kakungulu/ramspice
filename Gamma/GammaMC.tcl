# \
exec $RAMSPICE/ramspice $0 $argv

################################################
#
#            Model compiler
#
################################################
proc .param {name = value {min {}} {max {}}} {
    if {[catch {set evaluated_value [expr $value]}]} {
        @ param/$name = $value
    } else {
        @ param/$name = $evaluated_value
    }
    if {$min!={}} {
        @ param/$name/min = $min
    }
    if {$max!={}} {
        @ param/$name/max = $max
    }
}
proc .size {name = value {min {}} {max {}} {step {}} {dependence {}}} {
    if {[catch {set evaluated_value [expr $value]}]} {
        @ size/$name = $value
    } else {
        @ size/$name = $evaluated_value
    }
    foreach field {min max step dependence} {
        if {[catch {set evaluated_value [expr [set $field]]}]} {
            set ::sizing_code($name,$field) [set $field]
        } else {
            set ::sizing_code($name,$field) @size:$name:$field
            @ size:$name:$field = $evaluated_value
        }
    }
    default ::sizers_list {}
    lappend ::sizers_list $name
    
}
proc .property {name args} {
    default ::DERMODE first
    Info: PROPERTY "$name=$args"
    set original_der_mode $::DERMODE
    set ::DERMODE first
    array set opt {}
    set current_switch arguments
    foreach arg $args {
        if {[regexp {^\-(\S+)$} $arg -> switch]} {
            set current_switch $switch
            default opt($current_switch) {}
            continue
        }
        lappend opt($current_switch) $arg
    }
    default opt(to_display) @
    default opt(from_display) @
    default opt(unit) {}
    default opt(more) better
    default opt(denom) {}
    @ property/$name/denom = string $opt(denom)
    if {![info exists opt(expression)]} {
        Error: property requires a -expression switch
        exit
    }
    # set opt(expression) [flat_expression $opt(expression)]
    foreach field [array names opt] {
        set ::properties($name,$field) $opt($field)
    }
    @ property/$name = 0
    # property:$name=>$opt(expression)
    switch $opt(more) {
        better {@ property/$name/op = string +}
        worse {@ property/$name/op = string -}
        default {
            Error: A property $name can be either '-more better' or '-more worse'.
            exit
        }
    }
    set ::DERMODE $original_der_mode
}
proc .dependence {args} {
    regsub -all {\s} $args {} expr
    lassign [split $expr =] net dep
    set ::DESIGN_DEPENDENCES($net) $dep
}
proc .spec {name op value} {
    if {![info exists ::properties($name,expression)]} {
        Error: $name is not a defined property you can use in a spec. Start with: .property $name -expression <expression>
        exit
    }
    Info: Examining  $name $op $value w.r.t. previous specifications
    set useful_op 1
    foreach previous_entry [array names ::specification $name,*] {
        set previous_op [lindex [split $previous_entry ,] 1]
        
        switch $op {
            "=" {
                switch $previous_op {
                    "=" {
                        if {$::specification($previous_entry)!=$value} {
                            Error: Conflicting specification! $name can't be both $value and $::specification($previous_entry)
                            exit
                        }
                    }
                    "<" {
                        if {$::specification($previous_entry)<$value} {
                            Error: Conflicting specification! $name can't be both $value and less than $::specification($previous_entry)
                            exit
                        }
                        array unset ::specification $previous_entry
                    }
                    ">" {
                        if {$::specification($previous_entry)>$value} {
                            Error: Conflicting specification! $name can't be both $value and greater than $::specification($previous_entry)
                            exit
                        }
                        array unset ::specification $previous_entry
                    }
                }
            }
            "<" {
                switch $previous_op {
                    "=" {
                        if {$::specification($previous_entry)>$value} {
                            Error: Conflicting specification! $name can't be less than $value and equal to $::specification($previous_entry)
                            exit
                        }
                        set useful_op 0
                    }
                    "<" {
                        if {$::specification($previous_entry)<$value} {
                            set useful_op 0
                        } else {
                            array unset ::specification $previous_entry
                        }
                    }
                    ">" {
                        if {$::specification($previous_entry)>$value} {
                            Error: Conflicting specification! $name can't be less than $value and greater than $::specification($previous_entry)
                            exit
                        }
                    }
                }
            }
            ">" {
                switch $previous_op {
                    "=" {
                        if {$::specification($previous_entry)<$value} {
                            Error: Conflicting specification! $name can't be greater than $value and equal to $::specification($previous_entry)
                            exit
                        }
                        set useful_op 0
                    }
                    ">" {
                        if {$::specification($previous_entry)>$value} {
                            set useful_op 0
                        } else {
                            array unset ::specification $previous_entry
                        }
                    }
                    "<" {
                        if {$::specification($previous_entry)<$value} {
                            Error: Conflicting specification! $name can't be greater than $value and less than $::specification($previous_entry)
                            exit
                        }
                    }
                }
            }
        }
    }
    if {$useful_op} {
        set ::specification($name,$op) $value
    } else {
        Warning: $name $op $value is not a useful spec
    }
}
proc s2iW {expr varReal varImag {top 1}} {
    upvar $varReal Real
    upvar $varImag Imag
    if {$top} {
        while {[regexp {[\-\+][\-\+]} $expr]} {
            regsub -all {\-\+} $expr {-} expr
            regsub -all {\+\-} $expr {-} expr
            regsub -all {\-\-} $expr {+} expr
            regsub -all {\++} $expr {+} expr
        }
        set expr [polish $expr]
        while {[llength $expr]==1} {
            set expr [lindex $expr 0]
        }
    }
    if {[llength $expr]==1} {
        if {$expr=="@s"} {
            set Real 0
            set Imag W
            return 
        }
        set Real $expr
        set Imag 0
        return 
    }
    set op [lindex $expr 0]
    set L [lindex $expr 1]
    set R [lindex $expr 2]
    s2iW $L Lr Li 0
    s2iW $R Rr Ri 0
    switch $op {
        - {
            set Real [simple- $Lr $Rr]
            set Imag [simple- $Li $Ri]
        }
        + {
            set Real [simple+ $Lr $Rr]
            set Imag [simple+ $Li $Ri]
        }
        * {
            set Real [simple- [simple* $Lr $Rr] [simple* $Li $Ri]]
            set Imag [simple+ [simple* $Lr $Ri] [simple* $Li $Rr]]
        }
        default {
            Error: Operator $op not supported!
            exit
        }
    }
    while {[regexp {[\-\+][\-\+]} $Real]} {
        regsub -all {\-\+} $Real {-} Real
        regsub -all {\+\-} $Real {-} Real
        regsub -all {\-\-} $Real {+} Real
        regsub -all {\++} $Real {+} Real
    }
    while {[regexp {[\-\+][\-\+]} $Imag]} {
        regsub -all {\-\+} $Imag {-} Imag
        regsub -all {\+\-} $Imag {-} Imag
        regsub -all {\-\-} $Imag {+} Imag
        regsub -all {\++} $Imag {+} Imag
    }
    return
}
proc .prep_mna {mode} {
    array unset ::MNA
    set idc_orig [array get ::idc]
    set vdc_orig [array get ::vdc]
    set ::MNAy {}
    @ s = 0
    set ::independent_nodes {}
    foreach node [lsort $::all_nodes] {
        skip {$node==0}
        lappend ::independent_nodes $node
    }
    set dim [llength $::independent_nodes]
    array set ::MNA [list dim $dim]
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
        Info: Adding Resistor! m=$m p=$p
        add_mna $m $m $G
        add_mna $p $p $G
        add_mna $p $m -$G
        add_mna $m $p -$G
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
        #        add_mna_entry $s $d "Gds_$name"
        set ::transistors($name,Vgs) [Vdiff $Vg $Vs]
        @ Gds_$name = 1
        add_mna $s $s "+@$name:go"
        add_mna $s $d "-@$name:go"
        add_mna $d $s "-@$name:go"
        add_mna $d $d "+@$name:go"
        default ::idc($d,$s)
        append ::idc($d,$s) "-@$name:Ideq"
        add_mna $s $s "+@$name:gm"
        add_mna $s $g "-@$name:gm"
        add_mna $d $s "-@$name:gm"
        add_mna $d $g "+@$name:gm"
        if {$s!=$b} {
            add_mna $s $s "+@$name:gb"
            add_mna $s $b "-@$name:gb"
            add_mna $d $s "-@$name:gb"
            add_mna $d $b "+@$name:gb"
        }
        if {$type=="nch"} {
            set ::Ids_equations($name) "gamma_gcc_interpolate_4(`@:look_up_tables:$type:Ids:$::opt(process):LUT,[Vdiff $Vg $Vs],[Vdiff $Vd $Vs],[Vdiff $Vb $Vs],@$L)*@$W/@$L-@$name:gm*[Vdiff $Vg $Vs]-@$name:go*[Vdiff $Vd $Vs]"
        } else {
            set ::Ids_equations($name) "-gamma_gcc_interpolate_4(`@:look_up_tables:$type:Ids:$::opt(process):LUT,[Vdiff $Vg $Vs],[Vdiff $Vd $Vs],[Vdiff $Vb $Vs],@$L)*@$W/@$L-@$name:gm*[Vdiff $Vg $Vs]-@$name:go*[Vdiff $Vd $Vs]"
        }
        set ::Nt_equations($name) "gamma_gcc_interpolateg_4(`@:look_up_tables:$type:thermal_noise:ss:LUT,[Vdiff $Vg $Vs],[Vdiff $Vd $Vs],[Vdiff $Vb $Vs],@$L,`@$name:dNt_dvgs,`@$name:dNt_dvds,`@$name:dNt_dvbs,`@$name:dNt_dl)"
        set ::Nf_equations($name) "gamma_gcc_interpolateg_4(`@:look_up_tables:$type:flicker_noise:ss:LUT,[Vdiff $Vg $Vs],[Vdiff $Vd $Vs],[Vdiff $Vb $Vs],@$L,`@$name:dNf_dvgs,`@$name:dNf_dvds,`@$name:dNf_dvbs,`@$name:dNf_dl)"
        set ::gm_equations($name) "gamma_gcc_interpolateg_4(`@:look_up_tables:$type:gm:$::opt(process):LUT,[Vdiff $Vg $Vs],[Vdiff $Vd $Vs],[Vdiff $Vb $Vs],@$L,`@$name:dgm_dvgs,`@$name:dgm_dvds,`@$name:dgm_dvbs,`@$name:dgm_dl)*@$W/@$L"
        set ::go_equations($name) "@$W/@$L/gamma_gcc_interpolateg_4(`@:look_up_tables:$type:ro:$::opt(process):LUT,[Vdiff $Vg $Vs],[Vdiff $Vd $Vs],[Vdiff $Vb $Vs],@$L,`@$name:dro_dvgs,`@$name:dro_dvds,`@$name:dro_dvbs,`@$name:dro_dl)"
        @ $name:Ideq = 0
        @ $name:go = 1
        @ $name:gm = 1
        set ::sensitivity($name:gm,$W) @$name:gm:$W
        @ $name:gm:$W = 0
        $name:gm:$W=>@$name:gm/@$W
        set ::sensitivity($name:gm,$L) @$name:gm:$L
        @ $name:gm:$L = 0
        $name:gm:$L=>(@$W*@$name:dgm_dl-2*@$name:gm)/@$L
        @ $name:go:$W = 0
        set ::sensitivity($name:go,$W) @$name:go:$W
        $name:go:$W=>@$name:go/@$W
        set ::sensitivity($name:go,$L) @$name:go:$L
        @ $name:go:$L = 0
        $name:go:$L=>(@$name:dro_dl*@$L/@$W-@$L/@$name:go)*@$name:go*@$name:go
        foreach pin {d g s b} {
            set ac($pin) [set $pin]
            if {$ac($pin)=="0"} {
                # set ac($pin) vdd
            }
        }
        if {$mode=="ac" || $mode=="noise"} {
            foreach from {g d s b} {
                foreach to {d g s b} {
                    add_mna $ac($from)  $ac($to) "+@$name:c$from$to*@s"
                    @ $name:c$from$to = 0
                }    
            }
        }
    }
    if {$mode!="zout"} {
        foreach idc_pair [array names ::idc] {
            lassign [split $idc_pair ,] m p
            foreach node [list $m $p] sign {+ -} {
                skip {$node==0} 
                set index [lsearch $::independent_nodes $node]
                default ::MNA($index)
                set element $::idc($idc_pair)
                if {![regexp {^[0-9\-\+]} $element]} {
                    set element "@$element"
                }
                regsub -all {\-\-} "$sign$element" {+} entry
                regsub -all {\-\+} $entry {-} entry
                regsub {^\++} $entry {+} entry
                append ::MNA($index) "$entry"
                regsub {^\++} $::MNA($index)  {} ::MNA($index)
            }
        }
    } else {
        set index [lsearch $::independent_nodes $::output_net]
        default ::MNA($index)
        append ::MNA($index) +1
        regsub {^\++} $::MNA($index)  {} ::MNA($index)
    }
    set i $dim
    set all_vdc [array names ::vdc]
    foreach vdc_pair $all_vdc {
        lassign [split $vdc_pair ,] m p
        default ::MNA($m,$p)
        default ::MNA($p,$m)
        foreach node [list $m $p] entry {-1 1} {
            if {$node!="0"} {
                set j [lsearch $::independent_nodes $node]
                set ::MNA($j,$i) $entry
                set ::MNA($i,$j) $entry
            }
        }
        if {$mode=="zout"} {
            set ::MNA($i) 0
        } elseif {![regexp {^[0-9\-\+]} $::vdc($vdc_pair)]} {
            set ::MNA($i) @$::vdc($vdc_pair)
        } else {
            set ::MNA($i) $::vdc($vdc_pair)
        }    
        incr i
    }
    for {set i 0} {$i<$dim} {incr i} {
        if {![info exists ::MNA($i)]} {
            lappend ::MNAy 0
        } else {
            lappend ::MNAy $::MNA($i)
        }
    }
    foreach vdc_pair $all_vdc {
        if {$mode=="zout"} {
            lappend ::MNAy 0
        } else {
            lappend ::MNAy $::vdc($vdc_pair)
        }
    }
    set dim [llength $::MNAy]
    set ::MNA(dim) $dim	
    foreach entry [array names ::MNA] {
        set expr $::MNA($entry)
        regsub -all {\+\-} $expr {-} expr
        regsub -all {\-\+} $expr {-} expr
        regsub -all {\-\-} $expr {+} expr
        regsub -all {\+}   $expr {+} expr
        set ::MNA($entry) $expr
    }
    set old_y $::MNAy
    set ::MNAy {}
    foreach expr $old_y {
        regsub -all {\+\-} $expr {-} expr
        regsub -all {\-\+} $expr {-} expr
        regsub -all {\-\-} $expr {+} expr
        regsub -all {\+}   $expr {+} expr
        lappend ::MNAy $expr
    }
    if {$::C::target=="OP"} {
        if {$mode=="dc"} {
            set ::HTML [open ~/public_html/$::opt(topology)_MNA.html w]
            puts $::HTML <html>
            puts $::HTML <head>
            puts $::HTML {<style type="text/css">
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
            puts $::HTML </style>
            puts $::HTML </head>
            puts $::HTML <body>
        }
        puts $::HTML "<table class=\"matrix\" border=\"1\">"
        for {set i 0} {$i<$dim} {incr i} {
            puts $::HTML <tr>
            puts $::HTML <td>
            puts $::HTML <b>
            puts $::HTML [lindex $::independent_nodes $i]
            puts $::HTML </b>
            puts $::HTML </td>
            for {set j 0} {$j<$dim} {incr j} {
                puts $::HTML <td>
                if {[info exists ::MNA($i,$j)]} {
                    set td $::MNA($i,$j)
                    regsub -all @ $td {} td
                    regsub -all {:([a-zA-Z]+)} $td {<sub>\1</sub>} td
                    puts $::HTML $td
                } else {
                    puts $::HTML 0
                }
                puts $::HTML </td>
            }
            puts $::HTML <td>
            set td [lindex $::MNAy $i]
            regsub -all @ $td {} td
            regsub -all param: $td {} td
            regsub -all size: $td {} td
            regsub -all {:([a-zA-Z]+)} $td {<sub>\1</sub>} td
            puts $::HTML $td
            puts $::HTML </td>
            puts $::HTML </tr>
        }
        puts $::HTML </table>
        puts $::HTML <h2>
        DET ::MNA
        set td $::det_calc_result
        regsub -all @ $td {} td
        regsub -all param: $td {} td
        regsub -all size: $td {} td
        regsub -all {:([a-zA-Z]+)} $td {<sub>\1</sub>} td
        puts $::HTML "DET=$td<br>"
        if {[set index_out [lsearch $::independent_nodes outp]]!=-1} {
            DET ::MNA ::MNAy $index_out 
        } elseif {[set index_out [lsearch $::independent_nodes out]]!=-1} {	
            DET ::MNA ::MNAy $index_out 
        }
        set td $::det_calc_result
        regsub -all @ $td {} td
        regsub -all param: $td {} td
        regsub -all size: $td {} td
        regsub -all {:([a-zA-Z]+)} $td {<sub>\1</sub>} td
        puts $::HTML "V<sub>OUT</sub>=$td<br>"
        puts $::HTML </h2>
        if {$mode=="ac"} {
            puts $::HTML </body></html>
            close $::HTML
        }
    }
    array unset ::vdc
    array set ::vdc $vdc_orig
    array unset ::idc
    array set ::idc $idc_orig
    for {set i 0} {$i<$::MNA(dim)} {incr i} {
        set all_zeroes 1
        for {set j 0} {$j<$::MNA(dim)} {incr j} {
            skip {![info exists ::MNA($i,$j)]}
            skip {$::MNA($i,$j)==0}
            set all_zeroes 0
            break
        }
        skip {$all_zeroes==0}
        Error: Node [lindex $::independent_nodes $i] is dangling. Add path to ground or a voltage source.
        exit
    }
}
#proc .circuit {name} {
    #    set ::opt(topology) $name
#}
proc .compile_circuit {args} {
    if {[file exists $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/bypass.ignore.c]} {
        file copy -force $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/bypass.ignore.c /tmp/gamma_source.ignore.c
        gcc $::opt(topology) 0
        return
    }
    get_opts outp {} out {} outn {} in {} inn {} inp {} vdd {} name {}
    default ::opt(debug) 0
    set ::debug_mode $::opt(debug)
    foreach possible_ports {out outp outn inn inp in vdd} {
        skip {$opt($possible_ports)!={}}
        if {[@ param:$possible_ports ?]} {
            set opt($possible_ports) @param:$possible_ports
        }
        skip {$opt($possible_ports)!={}}
        if {[@ $possible_ports:V ?]} {
            set opt($possible_ports) @$possible_ports:V
        }
    }
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
            set ::output_net $opt(outp)
        } else {
            set ::output_net $opt(out)
        }
        regsub {@} $::output_net {} ::output_net
        regsub {:.*} $::output_net {} ::output_net
        if {$opt(inp)!={} && $opt(inn)!={} && $opt(in)!={}} {
            Error: Conflicting definitions of input net.
            exit
        }
        if {$opt(inp)!={} && $opt(inn)!={}} {
            set expr 0.5*([DERIVE $opt(inp) $::output_net]-[DERIVE $opt(inn) $::output_net])
        } elseif {$opt(in)!={}} {
            set expr [DERIVE $opt(in) $::output_net]
        }
        Info: Adc expr=$expr ($::output_net)
        .property Adc -expression $expr -to_display 20*log10(@) -from_display pow(10,@/20) -unit dB
        if {$opt(inp)!={} && $opt(inn)!={}} {
            .property CMRR -expression derive($::output_net,$opt(inp))+derive($::output_net,$opt(inn)) -to_display 20*log10(@) -from_display pow(10,@/20) -unit dB
        } elseif {$opt(in)!={}} {
            .property CMRR -expression 0 -to_display 20*log10(@) -from_display pow(10,@/20) -unit dB
        }
        if {![@ property/PSRR ?]} {
            if {$opt(vdd)=={}} {
                Error: Can't define PSRR code for the circuit, because it has no -vdd defined.
                exit
            }
            .property PSRR -expression derive($::output_net,$opt(vdd)) -to_display 20*log10(@) -from_display pow(10,@/20) -unit dB
        }
    }
    foreach p {Adc CMRR PSRR Rout BW ts Nt Nf fc Vos Area Power} {
        @ property/$p = 0
    }
    regsub {:V} $::output_net {} output_expr
    .prep_mna dc
    set dim $::MNA(dim)
    @ op_iterations = $::opt(op_limit)
    foreach starC_file [glob -nocomplain $::env(RAMSPICE)/Gamma/starC/Model/*.tcl] {
        regsub {\.tcl$} [file tail $starC_file] {} target_name
        if {[file exists $::env(RAMSPICE)/Gamma/starC/$::opt(topology)/$target_name.tcl]} {
            set starC_file $::env(RAMSPICE)/Gamma/starC/$::opt(topology)/$target_name.tcl
        }
        Info: Compiling $target_name from [file dirname $starC_file]
        code_target $target_name
        source $starC_file
    }
    foreach starC_file [glob -nocomplain $::env(RAMSPICE)/Gamma/starC/Model/*.c] {
        regsub {\.c$} [file tail $starC_file] {} target_name
        Info: Compiling $target_name from [file dirname $starC_file]
        code_target $target_name
        set code {}
        set I [open $starC_file r]
        while {[gets $I line]>=0} {
            if {[regexp {^\s*\*(.*)$} $line -> code_line]} {
                append code "$code_line\n"
            } elseif {[regexp {^[\s\{\}]*$} $line]} {
                append code "$line\n"
            } else {
                append code "*c \"$line\"\n"
            }
        }
        close $I
        uplevel #0 $code
    }
    gcc $opt(name)
}

################################################
#
#            gcc Interface
#
################################################

namespace eval C {
    variable O stdout
    array set code {}
    variable target OP
    variable code_template {
        #include <tcl.h>
        #include <stdio.h>
        #include <stdlib.h>
        #include "ctree.h"
        #include "look_up_table.h"
        // Some global pointers to keep reference of the contexts this object manipulates
        GLOBAL_POINTERS_GO_HERE
        GLOBAL_VARIABLES_GO_HERE
        // The compiled function
        float vos(float isize) {
            VOS_FORMULA
        }
        static int tcl_gamma_import_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
            LOCAL_BUFFER_INIT_GOES_HERE
            return TCL_OK;
        }
        static int tcl_gamma_export_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
            LOCAL_BUFFER_RETURN_GOES_HERE
            return TCL_OK;
        }
        static int tcl_gamma_op_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
            //            Tcl_ResetResult(interp);
            OP_CODE_GOES_HERE
            return TCL_OK;
        }
        //      static int tcl_gamma_grad_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
            //            Tcl_ResetResult(interp);
            //          GRAD_CODE_GOES_HERE
            //         return TCL_OK;
        //    }
        static int tcl_gamma_random_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
            RANDOM_CODE_GOES_HERE
            return TCL_OK;
        }
        static int tcl_gamma_breed_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
            BREED_CODE_GOES_HERE
            return TCL_OK;
        }
        static int tcl_gamma_random_breed_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
            RANDOM_BREED_CODE_GOES_HERE
            return TCL_OK;
        }
        static int tcl_gamma_random_breed_single_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
            RANDOM_BREED_SINGLE_CODE_GOES_HERE
            return TCL_OK;
        }
        // Initializing cTree references and registering the tcl_gamma_op_cmd command as ::C::@name
        int Gamma_Init(Tcl_Interp *interp) {
            if (Tcl_InitStubs(interp, TCL_VERSION, 0) == NULL) {
                return TCL_ERROR;
            }
            float *array_entry;
            context *c;
            GLOBAL_POINTER_INIT_GO_HERE
            Tcl_CreateObjCommand(interp, "::C::random", tcl_gamma_random_cmd, NULL, NULL);
            Tcl_CreateObjCommand(interp, "::C::random_breed", tcl_gamma_random_breed_cmd, NULL, NULL);
            Tcl_CreateObjCommand(interp, "::C::random_breed_single", tcl_gamma_random_breed_single_cmd, NULL, NULL);
            Tcl_CreateObjCommand(interp, "::C::breed", tcl_gamma_breed_cmd, NULL, NULL);
            // Tcl_CreateObjCommand(interp, "::C::grad", tcl_gamma_grad_cmd, NULL, NULL);
            Tcl_CreateObjCommand(interp, "::C::op", tcl_gamma_op_cmd, NULL, NULL);
            Tcl_CreateObjCommand(interp, "::C::import", tcl_gamma_import_cmd, NULL, NULL);
            Tcl_CreateObjCommand(interp, "::C::export", tcl_gamma_export_cmd, NULL, NULL);
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

### rename regsub regsub_orig
### proc regsub {args} {
    ###     Info: REGSUB $args
    ###     uplevel [concat regsub_orig $args]
### }
proc gcc {name {preprocess 1}} {
    if {$preprocess} {
        regsub -all @name $::C::code_template $name body
        set global_pointers {}
        set global_variables {}
        set global_pointer_init {}
        set local_buffer_init_goes_here {}
        set local_buffer_return_goes_here {}
        set used_var_names {}
        set used_pointer_names {}
        foreach target [array names ::C::code] {
            Info: Post processing $target
            set code $::C::code($target)
            while {[regexp {@+([A-Za-z0-9_:]+)} $code -> context_string]} {
                if {[info exists pointer_names($context_string)]} {
                    #            regsub "&&@+$context_string" $code `$var_names($context_string) code
                    regsub "&@+$context_string" $code $pointer_names($context_string) code
                    regsub "@+$context_string" $code $var_names($context_string) code
                    continue
                }
                Info: Linking $context_string to cTree
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
                append global_variables "float $var_name;\n"
                if {[regexp {(.*):PAT} $context_string -> base]} {
                    append global_pointer_init "$pointer_name=(float *)get_PAT(\"$base\");\n"
                    regsub "&@+$context_string" $code $pointer_name code
                } elseif {[regexp {(.*):LUT} $context_string -> base]} {
                    append global_pointer_init "$pointer_name=(float *)get_LUT(\"$base\");\n"
                    regsub "&@+$context_string" $code $pointer_name code
                } elseif {[regexp {(.*):CONTEXT} $context_string -> base]} {
                    append global_pointer_init "c=create_context(\"$base\");\n"
                    append global_pointer_init "$pointer_name=(float *)`c;\n"
                    regsub "&@+$context_string" $code $pointer_name code
                } else {
                    #            append global_pointer_init "resolve_context(\"$context_string\",`c,`array_entry);\n"
                    append global_pointer_init "c=create_context(\"$context_string\");\n"
                    append global_pointer_init "$pointer_name=(float *)(`c->value.s);\n"
                    append local_buffer_init_goes_here "$var_name=*$pointer_name;\n"
                    append local_buffer_return_goes_here "*$pointer_name=$var_name;\n"
                    regsub "&@+$context_string" $code $pointer_name code
                    regsub "@+$context_string" $code $var_name code
                }
                set pointer_names($context_string) $pointer_name
                set var_names($context_string) $var_name
                incr i
            }
            regsub -all \& $code ` code
            regsub ${target}_CODE_GOES_HERE $body $code body
            Info: converted $context_string
        }
        Info: Post Processing is Done
        regsub VOS_FORMULA $body $::VOS_FORMULA body
        regsub GLOBAL_POINTERS_GO_HERE $body $global_pointers body
        regsub GLOBAL_VARIABLES_GO_HERE $body $global_variables body
        regsub GLOBAL_POINTER_INIT_GO_HERE $body $global_pointer_init body
        regsub LOCAL_BUFFER_INIT_GOES_HERE $body $local_buffer_init_goes_here body
        regsub LOCAL_BUFFER_RETURN_GOES_HERE $body $local_buffer_return_goes_here body
        regsub -all `_ $body {P_} body
        regsub -all ` $body {\&} body
        regsub -all {\&look_up} $body {Plook_up} body
        set ::C::O [open /tmp/gamma_pre_processed.ignore.c w]
        puts $::C::O $body
        close $::C::O
        set ::C::O [open /tmp/gamma_source.ignore.c w]
        ::C::tcl_preprocessor $body
        close $::C::O
    }
    set find_lib_stub [glob -nocomplain /usr/*/libtclstub*]
    if {$find_lib_stub=={}} {
        Error: This system has no tclstub library and therefore can't compile code on the fly.
        exit
    }
    
    ######## Compilation
    default ::binary [ginfo binary]
    default ::target [ginfo target]
    set build_path /tmp/${::binary}_build/preprocessed-${::target}
    Info: Launching GCC
    
    uplevel "exec gcc -O3 [glob /tmp/${::binary}_build/object_files-[ginfo target]/*.o] -fPIC -shared -DUSE_TCL_STUBS -I$build_path -I$build_path/Gamma/Data  -I$build_path/Gamma/LUT -I$build_path/ngspice/root/maths/poly -I$build_path/ngspice/root/frontend -I$build_path/ngspice/root/spicelib/devices -I$build_path/ngspice/root/xspice/icm/analog -I/usr/include /tmp/gamma_source.ignore.c -L[file dirname [lindex $find_lib_stub 0]] -ltclstub[info tclversion]  -o /tmp/libGamma.so |& tee  $::env(RAMSPICE)/compilation.log"
    if {[file exists /tmp/libGamma.so]} {
        Info: Shared Object was created for Gamma on [clock format [file mtime /tmp/libGamma.so]]
        if {![file exists $::env(RAMSPICE)/Etc/Templates]} {
            file mkdir $::env(RAMSPICE)/Etc/Templates
        }
        if {![file exists $::env(RAMSPICE)/Etc/Templates/$name]} {
            file mkdir $::env(RAMSPICE)/Etc/Templates/$name
        }
        file copy -force /tmp/libGamma.so $::env(RAMSPICE)/Etc/Templates/$name
        file copy -force /tmp/gamma_source.ignore.c $::env(RAMSPICE)/Etc/Templates/$name/
    }
    #    load $::env(RAMSPICE)/Etc/Templates/$name/libGamma.so
}
proc code_target {name} {
    set ::C::target $name
}
proc *c {args} {
    Info: CCC $args
    set body $args
    if {[llength $body]!=1} {
        append ::C::code($::C::target) "$body;\n"
    } else {
        append ::C::code($::C::target) [lindex $body 0]
        append ::C::code($::C::target) "\n"
    }
}
proc stack_debug args {
    Stack:
}
trace add variable ::C::target write stack_debug
return
