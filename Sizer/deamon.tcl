# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
default ::opt(interpolation) LUT
default ::opt(process) ss
default ::opt(device) nch
default ::opt(tech) tsmc040
default ::opt(topv) 1.1
default ::opt(l) 360e-9
default ::opt(w) 360e-9
default ::opt(vgs) 1.0
default ::opt(vbs) 0.0
default ::opt(r) 50
default ::opt(ref) 100e-6
default ::opt(op_limit) 2
default ::opt(step_limit) 1000
default ::opt(step_count) 10
default ::opt(np) 1
default ::opt(mode) dc
set ::opt(mode) [string tolower $::opt(mode)]
default EPS0 8.85418e-12
default ::opt(epsrox) 3.9
default ::opt(source) Etc/Tech_DB/tsmc040/4d/5:5:3:6/
source $::env(RAMSPICE)/Sizer/matrices.tcl
source $::env(RAMSPICE)/Sizer/derivatives.tcl
source $::env(RAMSPICE)/Sizer/polynomials.tcl

foreach dev {nch pch} dtox {2.7e-10 3.91e-10} toxe {2.47e-9 2.71e-9} {
    set toxp [expr $dtox-$toxe]
    @ /look_up_tables/$dev/cox = [expr $::opt(epsrox)*$EPS0/$toxp]
    @ /look_up_tables/$dev !
    foreach param {ids gm ro} {
        @ /look_up_tables/$dev load $::opt(source)/$::opt(tech)_${dev}_${param}.db
    }
}

proc .property {name args} {
    default ::DERMODE first
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
    #    set opt(expression) [flat_expression $opt(expression)]
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
set ::all_transistors {}
set ::all_nodes {}
#array set ::vdc {0 0}

proc add_idc {name m p value} {
    set ::idc($m,$p) $value
    ladd ::all_nodes $m
    ladd ::all_nodes $p
}
set ::dependent_nodes(0) 1
proc add_vdc {name m p value} {
    set init_value $value
    if {[@ $value ?]} {
        set init_value [@ $value]
    }
    set ::vdc($m,$p) $value
    ladd ::all_nodes $m
    ladd ::all_nodes $p
    if {[info exists ::dependent_nodes($m)]} {
        Info: $p depends on $m ($value)
        set ::dependent_nodes($p) {}
        $p:Next=>$m+$value
        $p:V=>$p:Next
        @ $p:Next = [expr [@ $m:Next]+$init_value]
        @ $p:V = [expr [@ $m:Next]+$init_value]
    } elseif {[info exists ::dependent_nodes($p)]} {
        Info: $m depends on $p ($value)
        set ::dependent_nodes($m) {}
        $m:Next=>$p+$value
        $m:V=>$m:Next
        @ $m:Next = [expr [@ $p:Next]-$init_value]
        @ $m:V = [expr [@ $p:Next]-$init_value]
    }
}
array set ::all_resistors {}
set ::all_nodes {}
proc add_resistor {name m p value} {
    ladd ::all_nodes $m
    ladd ::all_nodes $p
    foreach node [list $m $p] {
        if {![info exists ::kcl_equations($node)]} {
            set ::kcl_equations($node) ""
        }
    }
    if {![info exists ::all_resistors($m,$p)]} {
        set ::all_resistors($m,$p) $value
    } else {
        set ::all_resistors($m,$p) [expr $value*$::all_resistors($m,$p)/($value+$::all_resistors($m,$p))]
    }
}
array set ::kcl_mapping {}
proc kcl_map {node} {
    if {[info exists ::kcl_mapping($node)]} {
        return [kcl_map $::kcl_mapping($node)]
    }
    return $node	
}
default ::opt(eps) 1e-4
set ::epsilon $::opt(eps)
proc Vdiff {v1 v2} {
    if {$v2==0} {
        return $v1
    }
    if {$v2=="0:V"} {
        return $v1
    }
    if {$v2=="\{0:V\}"} {
        return $v1
    }
    if {$v1==0} {
        return "(-$v2)"
    }
    if {$v1=="0:V"} {
        return "(-$v2)"
    }
    if {$v1=="\{0:V\}"} {
        return "(-$v2)"
    }
    if {$v1==$v2} {
        return 0
    }	
    return "($v1-$v2)"
}
proc add_kcl {i j element} {
    if {$i=="0"} return
    if {$j=="0"} return
    set i [lsearch $::independent_nodes $i]
    set j [lsearch $::independent_nodes $j]
    default ::KCL($i,$j)
    append ::KCL($i,$j) $element
    regsub {^\++} $::KCL($i,$j)  {} ::KCL($i,$j)
}
proc tmp_sort {t1 t2} {
    regsub tmp $t1 {} i1
    regsub tmp $t2 {} i2
    if {int($i1)>int($i2)} {
        return 1
    }	
    return 0
}
set ::circuit_components {}
proc .compile_circuit {} {
    @ s = 0
    set ::independent_nodes {}
    foreach node [lsort $::all_nodes] {
        skip {$node==0}
        lappend ::independent_nodes $node
    }
    set dim [llength $::independent_nodes]
    array unset ::KCL
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
            set ::G_equations(${m}_${p}) 1.0/$::all_resistors($res_nodes)
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
        add_kcl $s $s "+$name:go"
        add_kcl $s $d "-$name:go"
        add_kcl $d $s "-$name:go"
        add_kcl $d $d "+$name:go"
        default ::idc($d,$s)
        append ::idc($d,$s) "-$name:Ideq"
        add_kcl $s $s "+$name:gm"
        add_kcl $s $g "-$name:gm"
        add_kcl $d $s "-$name:gm"
        add_kcl $d $g "+$name:gm"
        if {$type=="nch"} {
            set ::Ids_equations($name) "interpolate(&:look_up_tables:$type:Ids:$::opt(process),[Vdiff $Vg $Vs],[Vdiff $Vd $Vs],[Vdiff $Vb $Vs],$L)*$W-$name:gm*[Vdiff $Vg $Vs]-$name:go*[Vdiff $Vd $Vs]"
        } else {
            set ::Ids_equations($name) "-interpolate(&:look_up_tables:$type:Ids:$::opt(process),[Vdiff $Vg $Vs],[Vdiff $Vd $Vs],[Vdiff $Vb $Vs],$L)*$W-$name:gm*[Vdiff $Vg $Vs]-$name:go*[Vdiff $Vd $Vs]"
        }
        set ::gm_equations($name) "interpolateg(&:look_up_tables:$type:gm:$::opt(process),[Vdiff $Vg $Vs],[Vdiff $Vd $Vs],[Vdiff $Vb $Vs],$L,&$name:dgm_dvgs,&$name:dgm_dvds,&$name:dgm_dvbs,&$name:dgm_dl)*$W"
        set ::go_equations($name) "$W/interpolateg(&:look_up_tables:$type:ro:$::opt(process),[Vdiff $Vg $Vs],[Vdiff $Vd $Vs],[Vdiff $Vb $Vs],$L,&$name:dro_dvgs,&$name:dro_dvds,&$name:dro_dvbs,&$name:dro_dl)"
        @ $name:Ideq = 0
        @ $name:go = 1
        @ $name:gm = 1
        set ::sensitivity($name:gm,$W) $name:gm:$W
        @ $name:gm:$W = 0
        $name:gm:$W=>$name:gm/$W
        set ::sensitivity($name:gm,$L) $name:gm:$L
        @ $name:gm:$L = 0
        $name:gm:$L=>$name:dgm_dl*$W
        @ $name:go:$W = 0
        set ::sensitivity($name:go,$W) $name:go:$W
        $name:go:$W=>$name:go/$W
        set ::sensitivity($name:go,$L) $name:go:$L
        @ $name:go:$L = 0
        $name:go:$L=>-$name:go*($name:dro_dl*$name:go/$W)
        if {$::opt(mode)=="ac" || $::opt(mode)=="noise"} {
            add_kcl $s $g "-$name:cgs*s"
            add_kcl $g $s "+$name:cgs*s"
            add_kcl $d $g "-$name:cgd*s"
            add_kcl $g $d "+$name:cgd*s"
            $name:cgs=>0.66666*[@ /look_up_tables/$type/cox]*$L*$L*$W
            $name:cgd=>0.33334*[@ /look_up_tables/$type/cox]*$L*$L*$W
        }
    }
    foreach idc_pair [array names ::idc] {
        lassign [split $idc_pair ,] m p
        foreach node [list $m $p] sign {+ -} {
            skip {$node==0} 
            set index [lsearch $::independent_nodes $node]
            default ::KCL($index)
            regsub -all {\-\-} "$sign$::idc($idc_pair)" {+} entry
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
        set ::KCL($i) $::vdc($vdc_pair)
        incr i
    }
    set y {}
    for {set i 0} {$i<$dim} {incr i} {
        if {![info exists ::KCL($i)]} {
            lappend y 0
        } else {
            lappend y $::KCL($i)
        }
    }
    foreach vdc_pair $all_vdc {
        lappend y $::vdc($vdc_pair)
    }
    set dim [llength $y]
    set ::KCL(dim) $dim	
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
        puts $HTML [lindex $y $i]
        puts $HTML </td>
        puts $HTML </tr>
    }
    puts $HTML </table>
    puts $HTML <h3>
    detp ::KCL g
    @ Det/POLY = [list_poly g]
    @ size foreach_child c {
        derive_poly g size:$c dg_d$c
        Det:$c=>[present_poly dg_d$c Det_d$c]
        Ted:$c=>-Det:$c/(Det*Det)
        set ::sensitivity(Det,size:$c) Det:$c
        set ::sensitivity(Ted,size:$c) Ted:$c
    }
    puts $HTML Det=[present_poly g Det]
    puts $HTML </h3>
    @ 0:V = 0
    set i 0
    # Define Data Dependencies
    foreach node $::independent_nodes {
        detp ::KCL poly_$node 0 {} $i $y
        Info: Setting poly poly_$node to [list_poly poly_$node]
        @ $node:Next:POLY = [list_poly poly_$node]
        @ $node:Next:POLY denom Det:POLY
        set poly [present_poly poly_$node $node:Next]
        $node=>$poly
        puts $HTML "$node:Next=$poly<br><br>"
        incr i
    }
    #exit
    foreach name [array names ::Ids_equations] {
        if {[info exists ::gm_equations($name)]} {
            $name:gm=>$::gm_equations($name)
            $name:go=>$::go_equations($name)
        } else {
            $name:g=>$::g_equations($name)
        }
    }
    foreach name [array names ::G_equations] {
        Gds_$name=>$::G_equations($name)
        .default Gds_$name 1e+0
    }
    @ continue = 1
    @ step_counter = 0
    @ max_slopeW = 0
    @ max_slopeL = 0
    @ unit_stepW = 5
    @ unit_stepL = 5e-8
    .procedure converge {} {
        continue=1
        .tp continue
        .for {step_counter=0} {step_counter<$::opt(step_count)} {step_counter=step_counter+1} {
            .tp continue
            continue=0
            # Set operating point
            .tp step_counter
            @ size foreach_child c {
                .tp size:$c
            }
            foreach name [array names ::G_equations] {
                .calculate Gds_$name
                .default Gds_$name 1e+0
            }
            .for {i=0} {i<$::opt(op_limit)} {i=i+1} {
                .tp i
                foreach name [array names ::Ids_equations] {
                    if {$::opt(mode)=="ac" ||  $::opt(mode)=="noise"} {
                        .calculate $name:cgs
                        .calculate $name:cgd
                    }
                    .calculate $name:gm
                    .tp $name:gm
                    .tp $name:dgm_dl
                    puts $HTML "$name:gm=$::DEF($name:gm)<br><br>"
                    @ $name:gm:size foreach_child c {
                        if {[info exists ::DEF($name:gm:size:$c)]} {
                            .calculate $name:gm:size:$c
                            .tp $name:gm:size:$c
                            puts $HTML "$name:dgm/d$c=$::DEF($name:gm:size:$c)<br><br>"
                        }
                    }
                    .calculate $name:go
                    .tp $name:go
                    .tp $name:dro_dl
                    @ $name:go:size foreach_child c {
                        if {[info exists ::DEF($name:go:size:$c)]} {
                            .calculate $name:go:size:$c
                            .tp $name:go:size:$c
                            puts $HTML "$name:dgo/d$c=$::DEF($name:go:size:$c)<br><br>"
                        }
                    }
                    $name:Ideq=$::Ids_equations($name)
                }
                Det=Polynomial(&Det:POLY)
                foreach node $::independent_nodes {
                    Info: NODE $node
                    $node:Next=Polynomial(&$node:Next:POLY)
                    .tp $node:Next
                }
                foreach node $::independent_nodes {
                    $node:V=limit($node:Next,0,$::opt(topv))
                    .tp $node:V
                }
                foreach name [array names ::G_equations] {
                    .calculate Gds_$name
                    .default Gds_$name 1e+0
                }
            }
	    @ size foreach_child s {
	        .tp size:$s
	    }
            @ property foreach_child p {
                Info: PROPERTY $p=$::properties($p,expression)
                set expression [flat_expression  $::properties($p,expression)]
                Info: PROPERTY $p=$expression
                start_poly $p $expression
                if {[array names ::POLY::$p]!={}} {
                    @ property:$p:POLY = [list_poly $p]
                    if {[@ property:$p:denom] != {}} {
                        @ property:$p:POLY denom [@ property:$p:denom]:POLY
                    }
                    property:$p=Polynomial(&property:$p:POLY)
		    .tp property:$p
                    set visited_components {}
                    foreach component [lindex [@ property:$p/POLY expression] 0] {
                        skip {$component=="+"}
                        skip {![catch {expr $component+0}]}
                        skip {[lsearch $visited_components $component]!=-1}
                        lappend visited_components $component
			@ property:$p:$component !
			@ property:$p:$component = 0
                        property:$p:$component=Derive(&property:$p:POLY,&$component)
			.tp property:$p:$component
                        skip {[lsearch $::circuit_components $component]!=-1}
                        lappend ::circuit_components $component
                    }
                } else {    
                    property:$p=$expression
                    foreach component $::circuit_components {
		        set derivative [derive_expression $component $expression]
			if {$derivative!=0} {
 			   @ property:$p:$component !
                           @ property:$p:$component = 0
                           property:$p:$component=$derivative
			   .tp property:$p:$component
			}
		    }
                }   
                @ size foreach_child s {
                    set expression {}
                    foreach component $::circuit_components {
                	skip {![info exists ::sensitivity($component,size:$s)]}
			skip {![@ property:$p:$component ?]}
                	lappend expression property:$p:$component*$::sensitivity($component,size:$s)
                    }
                    @ property:$p:$s !
                    property:$p:$s=[join $expression +]
		    .tp property:$p:$s
                }
            }
            @ property foreach_child p {
                puts $HTML "$p=$expression<br><br>"
                max_slopeW=0
                max_slopeL=0
                @ size foreach_child value {
                    set Dim [string index $value 0]
                    .if {abs(property:$p:$value)>max_slope$Dim} {
                        max_slope$Dim=abs(property:$p:$value)
                    }
                }
                set display_grad "Info: Test Point step \[@ step_counter\] $p=\[@ property:$p\] "
                @ size foreach_child value {
                    set Dim [string index $value 0]
                    size:$value:step=unit_step$Dim*property:$p:$value/max_slope$Dim
                    append display_grad "$value=\[@ size/$value\] \[@ property:$p:$value\] "
                    .tp size:$value:step
                    .tp size:$value
                    size:$value=limit(size:$value[@ property/$p/op]size:$value:step,size:$value:min,size:$value:max)
                    .tp size:$value
                }
		#.tcl exit
                               .tcl $display_grad
            }
        }
    }
    puts $HTML </body>
    puts $HTML </html>
    close $HTML
}
# proc .tp args {}
proc add_transistor {name d g s b type args} {
    lappend ::all_transistors $name
    ladd ::all_nodes $d
    ladd ::all_nodes $g
    ladd ::all_nodes $s
    ladd ::all_nodes $b
    set ::transistors($name,connectivity) trivial
    if {$d==$g} {
        set ::transistors($name,connectivity) diode
    }
    foreach field {d g s b type} {
        set ::transistors($name,$field) [set $field]
    }
    foreach param $args {
        lassign [split $param =] field value
        set ::transistors($name,$field) $value
    }
    set class [lindex [split $name _] 0]
    foreach field {L W} {
        if {![info exists ::transistors($name,$field)]} {
            set ::transistors($name,$field) size:$field$class
            @ size:$field$class = 3.6e-8
        } elseif {[regexp {^\((.*)\)$} $::transistors($name,$field) -> guide]} {
            set ::transistors($name,$field) size:$field$class
            @ size:$field$class = $guide
        } else {
            
        }
    }
}
default ::opt(iref) 50e-6
..init
default ::opt(topology) nmos_cs
switch $::opt(topology) {
    diffpair {
        @ topologies/$::opt(topology)((Wp,Lp,Wn,Ln,Ws,Ls,Iref|Adc,-Zout,-CMRR,-PSRR,-Area)) !
        #@ topologies/$::opt(topology)((Wp,Lp,Wn,Ln,Ws,Ls,Iref|Adc,-Area)) !
        if {[file exists $::env(RAMSPICE)/pareto.db]} {
            @ / load $::env(RAMSPICE)/pareto.db
        }
        @ param/pos = [expr $::opt(topv)/2]
        @ param/neg = [expr $::opt(topv)/2]
        @ param/vdd = $::opt(topv)
        @ param/iref = $::opt(iref)
        foreach class {p n s} {
            @ size/W$class  = 4
            @ size/W$class/min = 0.1
            @ size/W$class/max = 200
            @ size/W$class/step/min = -2
            @ size/W$class/step/max = 2
            @ size/L$class  = 40e-9
            @ size/L$class/min = 40e-9
            @ size/L$class/max = 1e-6
            @ size/L$class/step/min = -1e-6
            @ size/L$class/step/max = 1e-6
        }
        mp_1 outm outm vdd vdd pch W=size:Wp L=size:Lp
        mp_2 outp outm vdd vdd pch W=size:Wp L=size:Lp
        mnin_1 outm inp tail 0 nch W=size:Wn L=size:Ln
        mnin_2 outp inm tail 0 nch W=size:Wn L=size:Ln
        mn_tail tail vbias 0 0 nch W=size:Ws L=size:Ls
        mn_ref  vbias vbias 0 0 nch W=size:Ws L=size:Ls
        iref  vbias vdd param:iref
        vdd 0 vdd param:vdd
        vinp 0 inp param:pos
        vinm 0 inm param:neg
        #    rload outp 0 1e+7
        .property Adc -expression derive(outp,param:pos)-derive(outp,param:neg) -denom Det -to_display 20*log10(@) -from_display pow(10,@/20) -unit dB
#        .property CMRR -expression derive(outp,param:pos)+derive(outp,param:neg) -denom Det -to_display 20*log10(@) -from_display pow(10,@/20) -unit dB -more worse
#        .property PSRR -expression derive(outp,param:vdd) -denom Det -to_display 20*log10(@) -from_display pow(10,@/20) -unit dB -more worse
#        .property Zout -expression (n_tail:go+nin_2:go)/((n_tail:go*nin_2:go)+(n_tail:go+nin_2:go)*p_2:go) -unit Ohm -more worse
        .spec Adc > 50
#        .spec Zout < 100
    }
    diffpair_simple {
        @ topologies/$::opt(topology)((Wp,Lp,Wn,Ln,Ws,Ls|Adc,Area)) !
        @ param/pos = [expr $::opt(topv)/2]
        @ param/neg = [expr $::opt(topv)/2]
        @ param/vref = $::opt(vref)
        @ param/vdd = $::opt(topv)
        mp_1 outm outm vdd vdd pch W=size:Wp L=size:Lp
        mp_2 outp outm vdd vdd pch W=size:Wp L=size:Lp
        mnin_1 outm inp tail 0 nch W=size:Wn L=size:Ln
        mnin_2 outp inm tail 0 nch W=size:Wn L=size:Ln
        mn_tail tail vbias 0 0 nch W=size:Ws L=size:Ls
        vref  vbias 0 param:vref
        vdd 0 vdd param:vdd
        vinp 0 inp param:pos
        vinm 0 inm param:neg
        default ::opt(vref) 100e-3
        @ param/vref = $::opt(vref)
        foreach class {p n s} {
            @ size/W$class/min = 40e-9
            @ size/W$class/max = 10e-6
            @ size/L$class/min = 40e-9
            @ size/L$class/max = 10e-6
        }
        #    rload outp 0 1e+7
        .property Adc -expression (derive(outp:V,pos_input)-derive(outp:V,neg_input))/Det -to_display 20*log10(@) -from_display pow(10,@/20) -unit dB
    }
    nmos_cs {
        default ::opt(vin) [expr $::opt(topv)/2]
        @ param:ref_current = 15e-6
        @ param:vin = $::opt(vin)
        @ size:L !
        @ size:L = 360e-9
        @ size:L:min = 40e-9
        @ size:L:max = 10e-6
        @ size:L:step:min = -1e-6
        @ size:L:step:max = 1e-6
        @ size:W = 360e-9
        @ size:W:min = 0.1
        @ size:W:max = 1000
        @ size:W:step:min = -1e-6
        @ size:W:step:max = 1e-6
        @ topologies/$::opt(topology)((L|Adc,L)) !
        iref out 0 param:ref_current
        vin 0 in param:vin
        default ::opt(vin) 0.9
        vdd 0 vdd $::opt(topv)
        mn_ref  out in 0 0 nch W=size:W L=size:L
        .property Adc -expression derive(out,param:vin)  -denom Det -to_display 20*log10(@) -from_display pow(10,@/20) -unit dB
        .spec Adc < -15
    }
    pmos_cs {
        @ size:L !
        @ size:L = 360e-9
        @ size:L:min = 40e-9
        @ size:L:max = 10e-6
        @ size:L:step:min = -1e-6
        @ size:L:step:max = 1e-6
        @ size:W = 360e-9
        @ size:W:min = 40e-9
        @ size:W:max = 10e-6
        @ size:W:step:min = -1e-6
        @ size:W:step:max = 1e-6
        @ topologies/$::opt(topology)((L|Adc,L)) !
        iref out 0 param:ref_current
        @ param:ref_current = -3e-6
        default ::opt(vin) 0.2
        @ param:vin = $::opt(vin)
        vin 0 in param:vin
        vdd 0 vdd $::opt(topv)
        @ param:rload = 5e13
        rload out 0 param:rload
        mn_ref  out in vdd vdd pch W=size:W L=size:L
        .property Adc -expression derive(out,param:vin) -to_display 20*log10(@) -from_display pow(10,@/20) -unit dB
        .property Zout -expression out:V/(out:V/param:rload-derive(out,param:rload))-param:rload
        .spec Adc < -15
    }
    default {
        Error: No support for topology named $::opt(topology)
        exit
    }
}
.compile_circuit

#.compile_spec
#exit
@ inp:V = [expr $::opt(topv)/2]
@ inm:V = [expr $::opt(topv)/2]
default ::opt(save_size) 1
set box {}
set O [open /tmp/results.tcl w]
puts $O "# [clock format [clock seconds]]"
close $O
set max_gain 0
while {1} {
    for {set super_loop 0} {$super_loop<100} {incr super_loop} {
        set save_a_change 0
        for {set main_loop 0} {$main_loop<$::opt(save_size)} {incr main_loop} {
            if {[@ topologies/$::opt(topology) PAT size]<4 || rand()<0.5} {
                # PAT too small, use randomizer to seed it
                Info: random, only [@ topologies/$::opt(topology) PAT size] entries
                
		@ size foreach_child L {
		    skip {![string match L* $L]}
		    regsub {^L} $L W W
                    @ size/$L = [expr [@ size/$L/min]+([@ size/$L/max]-[@ size/$L/min])*rand()]
                    @ size/$W = [expr (99*rand()+1)]
                }    
            } else {
                Info: PAT
                # Take a random entry from the PAT and try to improve it
                set i [expr int([@ topologies/$::opt(topology) PAT size]*rand())]
                set entry [@ topologies/$::opt(topology) PAT index $i]
                set j 0
		@ size foreach_child L {
		    skip {![string match L* $L]}
		    regsub {^L} $L W W
                        @ size/$W = [lindex $entry $j]
                        incr j
                        @ size/$L = [lindex $entry $j]
                        incr j
                    }
                }
            }
            converge
            Info: converged
            set area 0
            set sizes {}
            set printed_sizes {}
            set WbyLviolated 0
	    @ size foreach_child L {
	    	skip {![string match L* $L]}
	    	regsub {^L} $L W W
                #    Info: Width=[@ size/$W] Length=[@ size/$L]
                set area [expr $area+[@ size/$W]*[@ size/$L]*[@ size/$L]]
                lappend sizes [@ size/$W]
                lappend sizes [@ size/$L]
                if {[@ size/$W]<[@ size/$L]} {
                    set WbyLviolated 1
                }
                lappend printed_sizes $W=[eng [@ size/$W] m]
                lappend printed_sizes $L=[eng [@ size/$L] m]
            }
            skip $WbyLviolated 
            skip {[@ outp:V]<50e-3}
            skip {[@ outp:V]<[@ tail:V]}
            skip {[@ property/Adc]<0}
            lappend printed_sizes Out=[eng [@ outp:V] V]
            lappend printed_sizes Tail=[eng [@ tail:V] V]
            lappend printed_sizes Adc=[eng [expr 20*log10([@ property/Adc])] dB]
            #            lappend printed_sizes Zout=[eng [@ property/Zout] Ohm]
            lappend sizes [@ param/iref]
            #            set saved [@ topologies/$::opt(topology) <<< $sizes [list [@ property/Adc] [@ property/Zout] $area]]
            set saved [@ topologies/$::opt(topology) <<< $sizes [list [@ property/Adc] $area]]
            if {$saved>=0} {
                set save_a_change 1
                Info: [clock format [clock seconds]] $saved $printed_sizes
            }
            if {$max_gain<[@ property/Adc]} {
                set max_gain [@ property/Adc]
            }
            set O [open /tmp/results.tcl a]
            puts $O "@ $sizes [eng [@ property/Adc] {}] [eng $area m^2]"
            close $O
        }
        if {$save_a_change} {
            @ topologies save pareto.db
        } 
    }	
    @ size foreach_child L {
    	skip {![string match L* $L]}
    	regsub {^L} $L W W
        @ size/$W/max = [expr 1e-6+[@ size/$W/max]]
        @ size/$L/max = [expr 1e-6+[@ size/$L/max]]
    }
}

##### Print Results
@ . foreach_child node {
    skip {![@ $node:V ?]}
    append box V$node=[eng [@ $node:V] V]
    append box \n
}    
@ property foreach_child node {
    if {[info exists ::properties($node,to_display)]} {
        regsub -all @ $::properties($node,to_display) [@ property/$node] value
        evaluate value
        if {[info exists ::properties($node,unit)]} {
            append box "property $node=[eng $value $::properties($node,unit)]"
        } else {
            append box "property $node=$value"
        }
    } else {
        append box "property $node=[@ property/$node]"
    }
    append box \n
}   
@ . foreach_child c {
    @ $c foreach_child g {
        if {[string match g* $g]} {
            append box "$c:$g = [eng [@ $c/$g] Mho]\n"
        } elseif {[string match r* $g]} {
            append box "$c:$g = [eng [@ $c/$g] Ohm]\n"
        }
    }
} 
@ size foreach_child c {
    append box "Size $c=[@ size:$c]"
    if {[@ size:$c:step ?]} {
        append box ", step=[@ size:$c:step]"
    }
    append box \n
}    
textbox $box
Info: Converged after [@ i] iterations. 
# error=[eng [expr sqrt([@ optimal_error]/[llength $::independent_nodes])] A]
exit


