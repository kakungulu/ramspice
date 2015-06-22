# \
exec $RAMSPICE/ramspice $0 $argv

################################################
#
#            Topology compiler
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
proc .size {name = value {min {}} {max {}} {step {}} } {
    if {[catch {set evaluated_value [expr $value]}]} {
        @ size/$name = $value
    } else {
        @ size/$name = $evaluated_value
    }
    if {$min!={}} {
        @ size/$name/min = $min
    }
    if {$max!={}} {
        @ size/$name/max = $max
    }
    if {$step!={}} {
        @ size/$name/step = $step
    }
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
        if {$mode=="ac" || $mode=="noise"} {
            add_mna $s $g "+@$name:cgs*@s"
            add_mna $g $s "-@$name:cgs*@s"
            if {$g!=$d} {
                add_mna $d $g "+@$name:cgd*@s"
                add_mna $g $d "-@$name:cgd*@s"
            }
            set ::cap_equations($name,cgs) "0.66666*@look_up_tables:$type:cox*@$L*@$W"
            set ::cap_equations($name,cgd) "0.33333*@look_up_tables:$type:cox*@$L*@$W"
            @ $name:cgd = 0
            @ $name:cgs = 0
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
    if {$::C::target=="OP"} {
        if {$mode=="dc"} {
            set ::HTML [open /tmp/MNA.html w]
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
                    puts $::HTML $::MNA($i,$j)
                } else {
                    puts $::HTML 0
                }
                puts $::HTML </td>
            }
            puts $::HTML <td>
            puts $::HTML [lindex $::MNAy $i]
            puts $::HTML </td>
            puts $::HTML </tr>
        }
        puts $::HTML </table>
        puts $::HTML <h2>
        puts $::HTML "DET=[DET ::MNA]"
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
}
#proc .circuit {name} {
    #    set ::opt(topology) $name
#}
proc .compile_circuit {args} {
    get_opts outp {} out {} outn {} in {} inn {} inp {} vdd {} name {}
    set ::debug_mode 0
    if {[ginfo target]=="debug"} {
        set ::debug_mode 1
    }
    set ::debug_mode 0
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
            if {![@ property/Adc ?]} {
                .property Adc -expression derive($::output_net,$opt(inp))-derive($::output_net,$opt(inn)) -to_display 20*log10(@) -from_display pow(10,@/20) -unit dB
            }
        } elseif {$opt(in)!={}} {
            if {![@ property/Adc ?]} {
                .property Adc -expression derive($::output_net,$opt(in)) -to_display 20*log10(@) -from_display pow(10,@/20) -unit dB
            }
        }
        if {$opt(inp)!={} && $opt(inn)!={}} {
            if {![@ property/CMRR ?]} {
                .property CMRR -expression derive($::output_net,$opt(inp))+derive($::output_net,$opt(inn)) -to_display 20*log10(@) -from_display pow(10,@/20) -unit dB
            }
        }
        if {![@ property/PSRR ?]} {
            if {$opt(vdd)=={}} {
                Error: Can't define PSRR code for the circuit, because it has no -vdd defined.
                exit
            }
            .property PSRR -expression derive($::output_net,$opt(vdd)) -to_display 20*log10(@) -from_display pow(10,@/20) -unit dB
        }
    }
    foreach p {Adc CMRR PSRR Zout BW ts Nt Nf fc Area Power} {
        @ property/$p = 0
    }
    regsub {:V} $::output_net {} output_expr
    .prep_mna dc
    set dim $::MNA(dim)
    @ op_iterations = $::opt(op_limit)
    code_target OP
    *c "// Calculating circuit operating point:"
    *c "int op_it=0;"
    if {$::debug_mode} {*c "printf(\"==================================================\\n\");"}
    if {$::debug_mode} {*c "printf(\"======%g Operating Point Iterations. ======\\n\",@op_iterations);"}
    if {$::debug_mode} {*c "printf(\"==================================================\\n\");"}
    *c "for (op_it=0;op_it<@op_iterations;op_it++) \{"
    if {$::debug_mode} {*c "    printf(\"========================= op_it=%d =========================\\n\",op_it);"}
    foreach transistor $::all_transistors {
        set L $::transistors($transistor,L)
        set W $::transistors($transistor,W)
        if {[info exists ::gm_equations($transistor)]} {
            *c "@$transistor:gm=$::gm_equations($transistor);"
            if {$::debug_mode} {*c "printf(\"@$transistor:gm=%g\\n\",@$transistor:gm);"}
            *c "@$transistor:go=$::go_equations($transistor);"
            if {$::debug_mode} {*c "printf(\"@$transistor:go=%g\\n\",@$transistor:go);"}
        } else {
            *c "@$transistor:g=$::g_equations($transistor);"
        }
        *c "@$transistor:Ideq=$::Ids_equations($transistor);"
        if {$::debug_mode} {*c "printf(\"@$transistor:Ideq=%g\\n\",@$transistor:Ideq);"}
    }
    foreach name [array names ::G_equations] {
        *c "@Gds_$name=$::G_equations($name);"
        .default Gds_$name 1e+0
    }
    set expression(Det) [DET ::MNA]
    foreach transistor $::all_transistors {
        if {[info exists ::gm_equations($transistor)]} {
            if {$::debug_mode} {*c "printf(\"@$transistor:gm=%g\\n\",@$transistor:gm);"}
            *c "if (@$transistor:gm==0) @$transistor:gm=1e-6;"
            if {$::debug_mode} {*c "printf(\"@$transistor:go=%g\\n\",@$transistor:go);"}
            *c "if (@$transistor:go==0) @$transistor:go=1e-6;"
        }    
        
        if {$::debug_mode} {*c "printf(\"@$transistor:Ideq=%g\\n\",@$transistor:Ideq);"}
    }
    *c "@Det=$expression(Det);"
    *c "@Ted=1/@Det;"
    *c "// Updating node voltages"
    if {$::debug_mode} {*c "printf(\"Det=$expression(Det)\\n\");"}
    if {$::debug_mode} {*c "printf(\"Det=%g Ted=%g\\n\",@Det,@Ted);"}
    set i 0
    foreach node $::independent_nodes {
        set expression($node) [DET ::MNA $i $::MNAy]
        $node=>($expression($node))*@Ted
        #       if {![info exists ::vdc(0,$node)]} 
        if {1} {
            *c "@$node:V=($expression($node))*@Ted;"
            *c "if (@$node:V<0) @$node:V=0;"
            *c "if (@$node:V>$::opt(topv)) @$node:V=$::opt(topv);"
            if {$::debug_mode} {*c "printf(\"$node=%g\\n\",@$node:V);"}
        }
        incr i
    }
    *c "\}"
    foreach transistor $::all_transistors {
        set L $::transistors($transistor,L)
        set W $::transistors($transistor,W)
        *c "@$transistor:Nt_unit=$::Nt_equations($transistor);"
        *c "@$transistor:Nt=@$transistor:Nt_unit*sqrt(@$transistor:gm);"
        *c "@$transistor:Nf_unit=$::Nf_equations($transistor);"
        *c "@$transistor:Nf=@$transistor:Nf_unit*@$transistor:gm*@$transistor:gm/(@$W*@$L);"
    }
    *c "// Calculating circuit properties:"
    @ property foreach_child p {
        set expression($p) [flat_expression  $::properties($p,expression)]
        *c "@property:$p=$expression($p);"
        if {$::debug_mode} {*c "printf(\"$p=%g\\n\",@property:$p);"}
    }	
    @ 0:V = 0
    .prep_mna zout
    set expression(Zout) [DET ::MNA [lsearch $::independent_nodes $::output_net] $::MNAy]
    *c "@property:Zout=($expression(Zout))*@Ted;"
    .prep_mna ac
    set expression(Det_ac) [DET ::MNA]
    set expression(dDet_ac) [derive_expression @s $expression(Det_ac)]
    foreach transistor $::all_transistors {
        foreach cap {cgs cgd} {
            skip {![@ $transistor:$cap ?]}
            *c "@$transistor:$cap=$::cap_equations($transistor,$cap);"
            if {$::debug_mode} {*c "printf(\"$transistor:$cap=%g\\n\",@$transistor:$cap);"}
        }
    }	    
    *c "@s=-1;"
    *c "int BW_it;"
    if {$::debug_mode} {*c "printf(\"num=$expression(Det_ac)\\n\");"}
    if {$::debug_mode} {*c "printf(\"denom=$expression(dDet_ac)\\n\");"}
    *c "for (BW_it=0;BW_it<5;BW_it++) \{"
    *c "    @s-=($expression(Det_ac))/($expression(dDet_ac));"
    #    *c "    @s-=(($expression(Det_ac))*@s)/(($expression(dDet_ac))*@s-($expression(Det_ac)));"
    *c "\}"
    *c "@property:BW:s=$expression(dDet_ac);"
    *c "@p1=-@s;"
    *c "@property:BW=@p1/(2*3.141592656);"
    if {$::debug_mode} {*c "printf(\"BW=%g\\n\",@property:BW);"}
    # Move away from the found root 
    *c "@s-=1e3;"
    # Find next root (=pole)
    *c "for (BW_it=0;BW_it<20;BW_it++) \{"
    *c "    @s-=(($expression(Det_ac))*(@s+@p1-5e2))/(($expression(dDet_ac))*(@s+@p1-5e2)-($expression(Det_ac)));"
    *c "\}"
    *c "@p2=-@s;"
    if {$::debug_mode} {*c "printf(\"Poles: %g    %g\\n\",@p1,@p2);"}
    *c "float A1=-@p2/(-@p1+@p2);"
    *c "float A2=-@p1/(-@p1+@p2);"
    *c "@property:ts=0;"
    *c "for (BW_it=0;BW_it<10;BW_it++) \{"
    *c "    @property:ts-=(0.02+A1*exp(-@p1*@property:ts)+A2*exp(-@p2*@property:ts))/(-@p1*A1*exp(-@p1*@property:ts)-@p2*A2*exp(-@p2*@property:ts));"
    *c "\}"
    if {$::debug_mode} {*c "printf(\"Settling time=%g\\n\",@property:ts);"}
    foreach transistor $::all_transistors {
        set dpoly(noise_trans_$transistor) [derive_expression @$transistor:Ideq $expression($output_expr)]
        *c "@$transistor:noise_trans=@Ted*($dpoly(noise_trans_$transistor))/@property:Adc;"
    } 
    foreach noise_type {t f} {   
        set chain {}
        foreach transistor $::all_transistors {
            lappend chain @$transistor:noise_trans*@$transistor:noise_trans*@$transistor:N$noise_type
        }
        if {$chain=={}} {
            set chain 0
        }
        *c "@property:N$noise_type=[join $chain +];"
        @ size foreach_child c {
            set chain {}
            foreach transistor $::all_transistors {
                lappend chain  2*@$transistor:noise_trans*@$transistor:noise_trans:$c*@$transistor:N$noise_type
                lappend chain @$transistor:noise_trans*@$transistor:noise_trans*@$transistor:N$noise_type:$c
            }
            *c "@property:N$noise_type:$c=[join $chain +];"
        }	    
    }
    foreach transistor $::all_transistors {
        if {$::debug_mode} {*c "printf(\"$transistor:  Nt=%g (%g%%)  Nf=%g (%g%%)\\n\",@$transistor:Nt,100*@$transistor:noise_trans*@$transistor:noise_trans*@$transistor:Nt/@property:Nt,@$transistor:Nf,100*@$transistor:noise_trans*@$transistor:noise_trans*@$transistor:Nf/@property:Nf);"}
    }
    *c "@property:fc=@property:Nf/@property:Nt;"
    if {$::debug_mode} {*c "printf(\"Corner=%g\\n\",@property:fc);"}
    
    code_target GRAD
    *c "// Calculating circuit operating point:"
    *c "int op_it=0;"
    foreach transistor $::all_transistors {
        set L $::transistors($transistor,L)
        set W $::transistors($transistor,W)
        if {[info exists ::gm_equations($transistor)]} {
            *c "@$transistor:gm=$::gm_equations($transistor);"
            if {$::debug_mode} {*c "printf(\"@$transistor:gm=%g\\n\",@$transistor:gm);"}
            *c "@$transistor:go=$::go_equations($transistor);"
            if {$::debug_mode} {*c "printf(\"@$transistor:go=%g\\n\",@$transistor:go);"}
        } else {
            *c "@$transistor:g=$::g_equations($transistor);"
        }
        *c "@$transistor:Ideq=$::Ids_equations($transistor);"
        if {$::debug_mode} {*c "printf(\"@$transistor:Ideq=%g\\n\",@$transistor:Ideq);"}
    }
    foreach name [array names ::G_equations] {
        *c "@Gds_$name=$::G_equations($name);"
        .default Gds_$name 1e+0
    }
    set expression(Det) [DET ::MNA]
    foreach transistor $::all_transistors {
        if {[info exists ::gm_equations($transistor)]} {
            if {$::debug_mode} {*c "printf(\"@$transistor:gm=%g\\n\",@$transistor:gm);"}
            *c "if (@$transistor:gm==0) @$transistor:gm=1e-6;"
            if {$::debug_mode} {*c "printf(\"@$transistor:go=%g\\n\",@$transistor:go);"}
            *c "if (@$transistor:go==0) @$transistor:go=1e-6;"
        }    
        
        if {$::debug_mode} {*c "printf(\"@$transistor:Ideq=%g\\n\",@$transistor:Ideq);"}
    }
    *c "@Det=$expression(Det);"
    *c "@Ted=1/@Det;"
    *c "// Updating node voltages"
    if {$::debug_mode} {*c "printf(\"Det=$expression(Det)\\n\");"}
    if {$::debug_mode} {*c "printf(\"Det=%g Ted=%g\\n\",@Det,@Ted);"}
    set i 0
    foreach node $::independent_nodes {
        set expression($node) [DET ::MNA $i $::MNAy]
        $node=>($expression($node))*@Ted
        #       if {![info exists ::vdc(0,$node)]} 
        if {1} {
            *c "@$node:V=($expression($node))*@Ted;"
            *c "if (@$node:V<0) @$node:V=0;"
            *c "if (@$node:V>$::opt(topv)) @$node:V=$::opt(topv);"
            if {$::debug_mode} {*c "printf(\"$node=%g\\n\",@$node:V);"}
        }
        incr i
    }
    foreach transistor $::all_transistors {
        set L $::transistors($transistor,L)
        set W $::transistors($transistor,W)
        *c "@$transistor:Nt_unit=$::Nt_equations($transistor);"
        *c "@$transistor:Nt=@$transistor:Nt_unit*sqrt(@$transistor:gm);"
        *c "@$transistor:Nf_unit=$::Nf_equations($transistor);"
        *c "@$transistor:Nf=@$transistor:Nf_unit*@$transistor:gm*@$transistor:gm/(@$W*@$L);"
    }
    *c "// Calculating circuit properties:"
    @ property foreach_child p {
        set expression($p) [flat_expression  $::properties($p,expression)]
        *c "@property:$p=$expression($p);"
        if {$::debug_mode} {*c "printf(\"$p=%g\\n\",@property:$p);"}
    }	
    *c "// Calculating circuit properties' gradients:"
    foreach transistor $::all_transistors {
        if {$::debug_mode} {*c "printf(\"d$transistor:dgm_dl=%g $transistor:gm=%g\\n\",@$transistor:dgm_dl,@$transistor:gm);"}
        foreach admittance {gm go} {
            @ $transistor:$admittance:size foreach_child c {
                if {[info exists ::DEF($transistor:$admittance:size:$c)]} {
                    *c "@$transistor:$admittance:size:$c=$::DEF($transistor:$admittance:size:$c);"
                    if {$::debug_mode} {*c "printf(\"d$transistor:$admittance/d$c=%g\\n\",@$transistor:$admittance:size:$c);"}
                }
            }
        }
    }
    *c "// Main determinant gradient:"
    foreach transistor $::all_transistors {
        foreach admittance {gm go} {
            set dpoly(Det,$transistor,$admittance) [derive_expression @$transistor:$admittance $expression(Det)]
            *c "@Det:${transistor}:${admittance}=$dpoly(Det,$transistor,$admittance);"
            *c "@Ted:${transistor}:${admittance}=-@Det:${transistor}:${admittance}/(@Det*@Det);"
        }
    }
    @ size foreach_child c {
        set chain {}
        foreach influence [array names ::DEF *:*:size:$c] {
            lassign [split $influence :] transistor admittance
            lappend chain @Det:${transistor}:${admittance}*@$transistor:$admittance:size:$c
        }
        set chain [join $chain +]
        if {$chain=={}} {
            *c "@Det:$c=0;"
            *c "@Ted:$c=0;"
        } else {
            *c "@Det:$c=$chain;"
            *c "@Ted:$c=-@Det:$c/(@Det*@Det);"
        }
    }	    
    @ property foreach_child p {
        foreach transistor $::all_transistors {
            foreach admittance {gm go} {
                set dpoly($p,$transistor,$admittance) [derive_expression @$transistor:$admittance $expression($p)]
                *c "@property:${p}:${transistor}:${admittance}=@Ted:${transistor}:${admittance}*@$p+$dpoly($p,$transistor,$admittance);"
            }
        }
        @ size foreach_child c {
            set chain {}
            foreach influence [array names ::DEF *:*:size:$c] {
                lassign [split $influence :] transistor admittance
                lappend chain "@$transistor:$admittance:size:$c*@property:${p}:${transistor}:${admittance}"
            }
            set chain [join $chain +]
            if {$chain=={}} {
                *c "@property:${p}:${c}=0;"
            } else {
                *c "@property:${p}:${c}=$chain;"
            }
            if {$::debug_mode} {*c "printf(\"d${p}/d${c}=%g\\n\",@property:${p}:${c});"}
        }
        
    }
    @ 0:V = 0
    .prep_mna zout
    set expression(Zout) [DET ::MNA [lsearch $::independent_nodes $::output_net] $::MNAy]
    *c "@property:Zout=($expression(Zout))*@Ted;"
    foreach transistor $::all_transistors {
        foreach admittance {gm go} {
            set dpoly(Zout,$transistor,$admittance) [derive_expression @$transistor:$admittance $expression(Zout)]
            *c "@property:Zout:${transistor}:${admittance}=@Ted_${transistor}_${admittance}*@Zout+$dpoly(Zout,$transistor,$admittance);"
        }
    }
    @ size foreach_child c {
        set chain {}
        foreach influence [array names ::DEF *:*:size:$c] {
            lassign [split $influence :] transistor admittance
            lappend chain "@$transistor:$admittance:size:$c*@property:Zout:${transistor}:${admittance}"
        }
        set chain [join $chain +]
        if {$chain=={}} {
            *c "@property:Zout:${c}=0;"
        } else {
            *c "@property:Zout:${c}=$chain;"
        }
        if {$::debug_mode} {*c "printf(\"dZout/d${c}=%g\\n\",@property:Zout:${c});"}
    }
    .prep_mna ac
    set expression(Det_ac) [DET ::MNA]
    set expression(dDet_ac) [derive_expression @s $expression(Det_ac)]
    foreach transistor $::all_transistors {
        foreach cap {cgs cgd} {
            skip {![@ $transistor:$cap ?]}
            *c "@$transistor:$cap=$::cap_equations($transistor,$cap);"
            if {$::debug_mode} {*c "printf(\"$transistor:$cap=%g\\n\",@$transistor:$cap);"}
        }
    }	    
    *c "@s=-1;"
    *c "int BW_it;"
    if {$::debug_mode} {*c "printf(\"num=$expression(Det_ac)\\n\");"}
    if {$::debug_mode} {*c "printf(\"denom=$expression(dDet_ac)\\n\");"}
    *c "for (BW_it=0;BW_it<5;BW_it++) \{"
    *c "    @s-=($expression(Det_ac))/($expression(dDet_ac));"
    #    *c "    @s-=(($expression(Det_ac))*@s)/(($expression(dDet_ac))*@s-($expression(Det_ac)));"
    *c "\}"
    *c "@property:BW:s=$expression(dDet_ac);"
    *c "@p1=-@s;"
    *c "@property:BW=@p1/(2*3.141592656);"
    if {$::debug_mode} {*c "printf(\"BW=%g\\n\",@property:BW);"}
    # Move away from the found root 
    *c "@s-=1e3;"
    # Find next root (=pole)
    *c "for (BW_it=0;BW_it<20;BW_it++) \{"
    *c "    @s-=(($expression(Det_ac))*(@s+@p1-5e2))/(($expression(dDet_ac))*(@s+@p1-5e2)-($expression(Det_ac)));"
    *c "\}"
    *c "@p2=-@s;"
    if {$::debug_mode} {*c "printf(\"Poles: %g    %g\\n\",@p1,@p2);"}
    *c "float A1=-@p2/(-@p1+@p2);"
    *c "float A2=-@p1/(-@p1+@p2);"
    *c "@property:ts=0;"
    *c "for (BW_it=0;BW_it<10;BW_it++) \{"
    *c "    @property:ts-=(0.02+A1*exp(-@p1*@property:ts)+A2*exp(-@p2*@property:ts))/(-@p1*A1*exp(-@p1*@property:ts)-@p2*A2*exp(-@p2*@property:ts));"
    *c "\}"
    if {$::debug_mode} {*c "printf(\"Settling time=%g\\n\",@property:ts);"}
    *c "@property:ts:s=-@p1*A1*exp(-@p1*@property:ts)-@p2*A2*exp(-@p2*@property:ts);"
    foreach transistor $::all_transistors {
        foreach admittance {gm go} {
            set dpoly(Det_ac,$transistor,$admittance) [derive_expression @$transistor:$admittance $expression(Det_ac)]
            *c "@Det_ac:${transistor}:${admittance}=$dpoly(Det_ac,$transistor,$admittance);"
        }
    }
    @ size foreach_child c {
        set chain {}
        foreach influence [array names ::DEF *:*:size:$c] {
            lassign [split $influence :] transistor admittance
            lappend chain "@$transistor:$admittance:size:$c*@Det_ac:${transistor}:${admittance}"
        }
        set chain [join $chain +]
        if {$chain=={}} {
            set chain 0
        }    
        *c "@property:BW:${c}=-($chain)/@property:BW:s;"
        *c "@property:ts:${c}=-($chain)/@property:ts:s;"
    }
    @ size foreach_child c {
        foreach influence [array names ::DEF *:*:size:$c] {
            lassign [split $influence :] transistor admittance
            set L $::transistors($transistor,L)
            set W $::transistors($transistor,W)
            if {[string match *L* $c]} {
                *c "@$transistor:Nt:$c=@$transistor:dNt_dl*sqrt(@$transistor:gm)+0.5*@$transistor:Nt_unit/sqrt(@$transistor:gm)*@$transistor:gm:size:$c;"
                *c "@$transistor:Nf:$c=@$name:dNf_dl*@$name:gm/sqrt(@$W*@$L)+@$transistor:Nf_unit*@$transistor:gm:size:$c/sqrt(@$W*@$L)-@$transistor:Nf_unit*@$name:gm/sqrt(@$W*@$L);"
            } else {
                *c "@$transistor:Nt:$c=@$transistor:Nt_unit/sqrt(@$transistor:gm)*@$transistor:gm:size:$c;"
                *c "@$transistor:Nf:$c=@$transistor:Nf_unit*@$transistor:gm:size:$c/sqrt(@$W*@$L)-0.5*@$transistor:Nf_unit*@$transistor:gm/(sqrt(@$W)*@$L*@$W);"
            }
        }
    }	  
    foreach transistor $::all_transistors {
        set dpoly(noise_trans_$transistor) [derive_expression @$transistor:Ideq $expression($output_expr)]
        *c "@$transistor:noise_trans=@Ted*($dpoly(noise_trans_$transistor))/@property:Adc;"
        @ size foreach_child c {
            set chain {}
            foreach influence [array names ::DEF *:*:size:$c] {
                lassign [split $influence :] transistor2 admittance
                set dpoly(noise_trans_$transistor,$transistor2,$admittance) [derive_expression @$transistor2:$admittance $dpoly(noise_trans_$transistor)]
                if {$dpoly(noise_trans_$transistor,$transistor2,$admittance)!="0"} {
                    *c "@$transistor:noise_trans:$transistor2:$admittance=$dpoly(noise_trans_$transistor,$transistor2,$admittance);"
                    lappend chain $dpoly(noise_trans_$transistor,$transistor2,$admittance)*@$transistor2:$admittance:size:$c
                    lappend sum_chain $dpoly(noise_trans_$transistor,$transistor2,$admittance)*@$transistor2:$admittance:size:$c
                }    
            }	
            if {$chain=={}} {
                set chain 0
            }
            set chain [join $chain +]
            if {$chain=={}} {
                set chain 0
            }
            *c "@$transistor:noise_trans:$c=$chain;"
        }   
    } 
    foreach noise_type {t f} {   
        set chain {}
        foreach transistor $::all_transistors {
            lappend chain @$transistor:noise_trans*@$transistor:noise_trans*@$transistor:N$noise_type
        }
        if {$chain=={}} {
            set chain 0
        }
        *c "@property:N$noise_type=[join $chain +];"
        @ size foreach_child c {
            set chain {}
            foreach transistor $::all_transistors {
                lappend chain  2*@$transistor:noise_trans*@$transistor:noise_trans:$c*@$transistor:N$noise_type
                lappend chain @$transistor:noise_trans*@$transistor:noise_trans*@$transistor:N$noise_type:$c
            }
            *c "@property:N$noise_type:$c=[join $chain +];"
        }	    
    }
    foreach transistor $::all_transistors {
        if {$::debug_mode} {*c "printf(\"$transistor:  Nt=%g (%g%%)  Nf=%g (%g%%)\\n\",@$transistor:Nt,100*@$transistor:noise_trans*@$transistor:noise_trans*@$transistor:Nt/@property:Nt,@$transistor:Nf,100*@$transistor:noise_trans*@$transistor:noise_trans*@$transistor:Nf/@property:Nf);"}
    }
    *c "@property:fc=@property:Nf/@property:Nt;"
    if {$::debug_mode} {*c "printf(\"Corner=%g\\n\",@property:fc);"}
    @ size foreach_child c {
        *c "@property:fc:$c=@property:Nf:$c/@property:Nt-@property:Nf/(@property:Nt*@property:Nt)*@property:Nt:$c;"
    }	
    
    code_target RANDOM
    *c "ClientData CD;"
    #    *c "int i;"
    #    *c "for (i=0;i<@pat_size_target;i++) \{"
    *c "PAT *p=(PAT *)&@$::opt(topology):circuits:PAT;"
    *c "while (p->content->num_of<@pat_size_target) \{"
    @ size foreach_child s {
        *c "@size:$s=@size:$s:min+random()*(@size:$s:max-@size:$s:min)/RAND_MAX;"
    }	
    @ / foreach_child n {
        skip {![@ $n:V ?]}
        skip {$n=="vdd"}
        skip {$n=="0"}
        if {[@ param:$n ?]} {
            *c "@$n:V=@param:$n;"
        } else {
            *c "@$n:V=@vdd:V/2;"
        }
    }	 
    *c "@vdd:V=$::opt(topv);"
    *c "@0:V=0;"
    *c "tcl_gamma_op_cmd(CD,NULL,0,NULL);"
    @ / foreach_child n {
        skip {![@ $n:V ?]}
        skip {[@ param:$n ?]}
        skip {$n=="vdd"}
        skip {$n=="0"}
        if {$::debug_mode} {*c "printf(\"$n=%g\\n\",@$n:V);"}
        *c "if (!isfinite(@$n:V)) continue;"
        *c "if (@$n:V==0) continue;"
    }     
    @ property foreach_child p {
        if {$::debug_mode} {*c "printf(\"$p=%g\\n\",@property:$p);"}
        *c "if (!isfinite(@property:$p)) continue;"
    }
    *c "if (@property:ts<0) continue;"
    *c "if (@property:Adc<1) continue;"
    *c "vector_float *sizes=new_vector_float();"
    @ size foreach_child s {
        *c "add_entry_vector_float(sizes,@size:$s);"
    }	
    @ / foreach_child n {
        skip {![@ $n:V ?]}
        skip {$n=="vdd"}
        skip {$n=="0"}
        skip {[@ param:$n ?]}
        *c "add_entry_vector_float(sizes,@$n:V);"
    }
    *c "vector_float *properties=new_vector_float();"
    @ property foreach_child p {
        *c "add_entry_vector_float(properties,@property:$p);"
    }	
    set chain {}
    @ size foreach_child w {
        skip {![regexp {^W} $w]}
        regsub {^W} $w L l
        lappend chain "@size:$w*@size:$l+40e-9*@size:$w"
    }
    *c "@property:Area=[join $chain +];"	
    *c "@property:Power=@size:iref*@vdd:V;"
    *c "add_entry_vector_float(properties,@property:Area);"
    *c "add_entry_vector_float(properties,@property:Power);"
    *c "add_pat_entry(p,sizes,properties);"
    *c "free(sizes);"
    *c "free(properties);"
    *c "\}"
    
    
    code_target BREED
    *c "ClientData CD;"
    *c "int i,viable;"
    *c "PAT *p=(PAT *)&@$::opt(topology):circuits:PAT;"
    *c "int more_to_breed=1;"
    *c "while (more_to_breed&&(p->content->num_of<@pat_size_target)) \{"
    *c "more_to_breed=0;"
    *c "int sweep_size=p->content->num_of;"
    *c "for (i=0;i<sweep_size;i++) \{"
    *c "if (p->content->content[i]->flags) continue;"
    *c "p->content->content[i]->flags=1;"
    *c "more_to_breed++;"
    if {$::debug_mode} {*c "printf(\"Visiting %d\\n\",i);"}
    set j 0
    @ size foreach_child s {
        *c "@size:$s=p->content->content[i]->sizes->content[$j];"
        incr j;
    }
    @ size foreach_child s {
        foreach step_dir {+ -2*} {
            *c "@size:$s=@size:$s$step_dir@size:$s:step;"
            *c "viable=1;"
            *c "if (@size:$s<@size:$s:min) viable=0;"
            *c "if (@size:$s>@size:$s:max) viable=0;"
            *c "if (viable) \{"
            @ / foreach_child n {
                skip {![@ $n:V ?]}
                skip {$n=="vdd"}
                skip {$n=="0"}
                if {[@ param:$n ?]} {
                    *c "@$n:V=@param:$n;"
                } else {
                    *c "@$n:V=@vdd:V/2;"
                }
            }	 
            *c "@vdd:V=$::opt(topv);"
            *c "@0:V=0;"
            *c ""
            *c "tcl_gamma_op_cmd(CD,NULL,0,NULL);"
            if {$::debug_mode} {*c "printf(\"Viable=%d\\n\",viable);"}
            @ / foreach_child n {
                skip {![@ $n:V ?]}
                skip {[@ param:$n ?]}
                skip {$n=="vdd"}
                skip {$n=="0"}
                if {$::debug_mode} {*c "printf(\"$n=%g Viable=%d\\n\",@$n:V,viable);"}
                *c "if (!isfinite(@$n:V)) viable=0;"
                *c "if (@$n:V==0) viable=0;"
            }     
            @ property foreach_child p {
                if {$::debug_mode} {*c "printf(\"$p=%g Viable=%d\\n\",@property:$p,viable);"}
                *c "if (!isfinite(@property:$p)) viable=0;"
            }
            *c "if (@property:ts<0) viable=0;"
            *c "if (@property:Adc<1) viable=0;"
            if {$::debug_mode} {*c "printf(\"Viable=%d\\n\",viable);"}
            *c "if (viable) \{"
            *c "vector_float *sizes=new_vector_float();"
            @ size foreach_child s {
                *c "add_entry_vector_float(sizes,@size:$s);"
            }	
            @ / foreach_child n {
                skip {![@ $n:V ?]}
                skip {$n=="vdd"}
                skip {$n=="0"}
                skip {[@ param:$n ?]}
                *c "add_entry_vector_float(sizes,@$n:V);"
            }
            *c "vector_float *properties=new_vector_float();"
            @ property foreach_child p {
                *c "add_entry_vector_float(properties,@property:$p);"
            }	
            set chain {}
            @ size foreach_child w {
                skip {![regexp {^W} $w]}
                regsub {^W} $w L l
                lappend chain "@size:$w*@size:$l+40e-9*@size:$w"
            }
            *c "@property:Area=[join $chain +];"	
            *c "@property:Power=@size:iref*@vdd:V;"
            *c "add_entry_vector_float(properties,@property:Area);"
            *c "add_entry_vector_float(properties,@property:Power);"
            *c "add_pat_entry(p,sizes,properties);"
            *c "free(sizes);"
            *c "free(properties);"
            *c "\}"
            *c "\}"
        }
        *c "@size:$s=@size:$s+@size:$s:step;"
        
    }
    *c "if (p->content->num_of%100==0) {printf(\"               %ld/%g=%g%%\\n\",p->content->num_of,@pat_size_target,100*p->content->num_of/@pat_size_target); fflush(stdout);}"
    *c "\}"
    *c "printf(\"   Done %ld/%g=%g%% (%ld visited)\\n\",p->content->num_of,@pat_size_target,100*p->content->num_of/@pat_size_target,more_to_breed);"
    *c "\}"
    
    code_target RANDOM_BREED
    *c "ClientData CD;"
    *c "int i;"
    *c "PAT *p=(PAT *)&@$::opt(topology):circuits:PAT;"
    *c "int more_to_breed=0;"
    *c "long int r;"
    *c "while (p->content->num_of<@pat_size_target) \{"
    *c "int sweep_size=p->content->num_of;"
    *c "for (i=0;i<sweep_size;i++) \{"
    *c "more_to_breed++;"
    if {$::debug_mode} {*c "printf(\"Visiting %d\\n\",i);"}
    set j 0
    @ size foreach_child s {
        *c "@size:$s=p->content->content[i]->sizes->content[$j];"
        incr j;
    }
    @ size foreach_child s {
#        *c "@size:$s+=(2.0*random()/RAND_MAX-1)*@size:$s:step;"
        *c "r=random();"
        *c "if (r<RAND_MAX/3) \{"
        *c "@size:$s-=@size:$s:step;"
        *c "\}"
	*c "if (r>RAND_MAX/3) \{"
        *c "@size:$s+=@size:$s:step;"
        *c "\}"
        *c "if (@size:$s<@size:$s:min) continue;"
        *c "if (@size:$s>@size:$s:max) continue;"
    }
    @ / foreach_child n {
        skip {![@ $n:V ?]}
        skip {$n=="vdd"}
        skip {$n=="0"}
        if {[@ param:$n ?]} {
            *c "@$n:V=@param:$n;"
        } else {
            *c "@$n:V=@vdd:V/2;"
        }
    }	 
    *c "@vdd:V=$::opt(topv);"
    *c "@0:V=0;"
    *c ""
    *c "tcl_gamma_op_cmd(CD,NULL,0,NULL);"
    @ / foreach_child n {
        skip {![@ $n:V ?]}
        skip {[@ param:$n ?]}
        skip {$n=="vdd"}
        skip {$n=="0"}
        if {$::debug_mode} {*c "printf(\"$n=%g Viable=%d\\n\",@$n:V,viable);"}
        *c "if (!isfinite(@$n:V)) continue;"
        *c "if (@$n:V==0) continue;"
    }     
    @ property foreach_child p {
        if {$::debug_mode} {*c "printf(\"$p=%g Viable=%d\\n\",@property:$p,viable);"}
        *c "if (!isfinite(@property:$p)) continue;"
    }
    *c "if (@property:ts<0) continue;"
    *c "if (@property:Adc<1) continue;"
    if {$::debug_mode} {*c "printf(\"Viable=%d\\n\",viable);"}
    *c "vector_float *sizes=new_vector_float();"
    @ size foreach_child s {
        *c "add_entry_vector_float(sizes,@size:$s);"
    }	
    @ / foreach_child n {
        skip {![@ $n:V ?]}
        skip {$n=="vdd"}
        skip {$n=="0"}
        skip {[@ param:$n ?]}
        *c "add_entry_vector_float(sizes,@$n:V);"
    }
    *c "vector_float *properties=new_vector_float();"
    @ property foreach_child p {
        *c "add_entry_vector_float(properties,@property:$p);"
    }	
    set chain {}
    @ size foreach_child w {
        skip {![regexp {^W} $w]}
        regsub {^W} $w L l
        lappend chain "@size:$w*@size:$l+40e-9*@size:$w"
    }
    *c "@property:Area=[join $chain +];"	
    *c "@property:Power=@size:iref*@vdd:V;"
    *c "add_entry_vector_float(properties,@property:Area);"
    *c "add_entry_vector_float(properties,@property:Power);"
    *c "add_pat_entry(p,sizes,properties);"
    *c "free(sizes);"
    *c "free(properties);"
    *c "if (p->content->num_of%1000==0) {printf(\"               %ld/%g=%g%%\\n\",p->content->num_of,@pat_size_target,100*p->content->num_of/@pat_size_target); fflush(stdout);}"
    *c "\}"
    *c "\}"
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
        static int tcl_gamma_grad_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
            //            Tcl_ResetResult(interp);
            GRAD_CODE_GOES_HERE
            return TCL_OK;
        }
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
            Tcl_CreateObjCommand(interp, "::C::breed", tcl_gamma_breed_cmd, NULL, NULL);
            Tcl_CreateObjCommand(interp, "::C::grad", tcl_gamma_grad_cmd, NULL, NULL);
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


proc gcc {name} {
    regsub -all @name $::C::code_template $name body
    set global_pointers {}
    set global_variables {}
    set global_pointer_init {}
    set local_buffer_init_goes_here {}
    set local_buffer_return_goes_here {}
    set used_var_names {}
    set used_pointer_names {}
    foreach target [array names ::C::code] {
        set code $::C::code($target)
        while {[regexp {@+([A-Za-z0-9_:]+)} $code -> context_string]} {
            if {[info exists pointer_names($context_string)]} {
                #            regsub "&&@+$context_string" $code `$var_names($context_string) code
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
            append global_variables "float $var_name;\n"
            if {[regexp {(.*):PAT} $context_string -> base]} {
                append global_pointer_init "$pointer_name=(float *)get_PAT(\"$base\");\n"
                regsub "&@+$context_string" $code $pointer_name code
            } elseif {[regexp {(.*):LUT} $context_string -> base]} {
                append global_pointer_init "$pointer_name=(float *)get_LUT(\"$base\");\n"
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
    }
    regsub GLOBAL_POINTERS_GO_HERE $body $global_pointers body
    regsub GLOBAL_VARIABLES_GO_HERE $body $global_variables body
    regsub GLOBAL_POINTER_INIT_GO_HERE $body $global_pointer_init body
    regsub LOCAL_BUFFER_INIT_GOES_HERE $body $local_buffer_init_goes_here body
    regsub LOCAL_BUFFER_RETURN_GOES_HERE $body $local_buffer_return_goes_here body
    regsub -all `_ $body {P_} body
    regsub -all ` $body {\&} body
    set ::C::O [open /tmp/gamma_source.ignore.c w]
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
    Info: Launching GCC
    
    uplevel "exec gcc -O3 [glob /tmp/${::binary}_build/object_files-[ginfo target]/*.o] -fPIC -shared -DUSE_TCL_STUBS -I$build_path -I$build_path/Gamma/Data  -I$build_path/Gamma/LUT -I$build_path/ngspice/root/maths/poly -I$build_path/ngspice/root/frontend -I$build_path/ngspice/root/spicelib/devices -I$build_path/ngspice/root/xspice/icm/analog -I/usr/include /tmp/gamma_source.ignore.c -L[file dirname [lindex $find_lib_stub 0]] -ltclstub[info tclversion]  -o /tmp/libGamma.so"
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
    Dinfo: CCC $args
    set body $args
    if {[llength $body]!=1} {
        append ::C::code($::C::target) "$body;\n"
    } else {
        append ::C::code($::C::target) [lindex $body 0]
        append ::C::code($::C::target) "\n"
    }
}
return
