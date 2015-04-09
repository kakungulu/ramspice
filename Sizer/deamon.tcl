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
default ::opt(np) 1
default ::opt(source) Tech_DB/tsmc040/4d/5:5:3:6/
source $::env(RAMSPICE)/Sizer/matrices.tcl
source $::env(RAMSPICE)/Sizer/derivatives.tcl
source $::env(RAMSPICE)/Sizer/polynomials.tcl
foreach dev {nch pch} {
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
@ property/quality = 0
proc .compile_spec {} {
    set original_der_mode $::DERMODE
    set ::DERMODE second
    .procedure calculate_step {} {
        Info: Calculating Step [array get ::specification]
        @ size foreach_child value {
            Info: Size=$value
            size:$value:step=0
            foreach spec [array names ::specification] {
                Info: Compiling Spec: $spec $::specification($spec)
                lassign [split $spec ,] name op
                switch $op {
                    "=" {
                        .let size:$value:step=(property:$name-$::specification($spec))/property:$name:$value
                    }
                    "<" {
                        .if {property:$name>=$::specification($spec)} {
                            .let size:$value:step=(property:$name-$::specification($spec))/property:$name:$value
                        }
                    }
                    ">" {
                        .if {property:$name<=$::specification($spec)} {
                            .let size:$value:step=(property:$name-$::specification($spec))/property:$name:$value
                        }
                    }
                }
            }
        }
    }
    .procedure apply_step {} {
        step_factor=step_divider*step_size
        @ size foreach_child value {
            size:$value=limit(size:$value+size:$value:step,$size:min,$size:max)
        }
    }
    .procedure quality {} {
        property/quality=0
        set calculated_properties {}
        foreach spec [array names ::specification] {
            lassign [split $spec ,] name op
            #          if {[lsearch $calculated_properties $name]==-1} {
                #                property/$name=[flat_expression  $::properties($name,expression)]
                #.calculate property/$name
                #               lappend calculated_properties $name
            #         }
            regsub -all @ $::properties($name,from_display) $::specification($spec) th
            evaluate th
            switch $op {
                "=" {
                    property:quality=property:quality+abs(property:$name/$th-1)
                }
                "<" {
                    .if {property:$name>=$th} {
                        property:quality=property:quality+abs(property:$name/$th-1)
                    }
                }
                ">" {
                    .if {property:$name<=$th} {
                        property:quality=property:quality+abs(property:$name/$th-1)
                    }
                }
            }
        }
    }
    set ::DERMODE $original_der_mode
}
proc tmp_sort {t1 t2} {
    regsub tmp $t1 {} i1
    regsub tmp $t2 {} i2
    if {int($i1)>int($i2)} {
        return 1
    }	
    return 0
}
proc .compile_circuit {} {
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
            set ::Ids_equations($name) "interpolate(&:look_up_tables:$type:Ids:$::opt(process),[Vdiff $Vg $Vs],[Vdiff $Vd $Vs],[Vdiff $Vb $Vs],$L)*($W/$L)-$name:gm*[Vdiff $Vg $Vs]-$name:go*[Vdiff $Vd $Vs]"
	} else {
            set ::Ids_equations($name) "-interpolate(&:look_up_tables:$type:Ids:$::opt(process),[Vdiff $Vg $Vs],[Vdiff $Vd $Vs],[Vdiff $Vb $Vs],$L)*($W/$L)-$name:gm*[Vdiff $Vg $Vs]-$name:go*[Vdiff $Vd $Vs]"
	}
        set ::gm_equations($name) "interpolateg(&:look_up_tables:$type:gm:$::opt(process),[Vdiff $Vg $Vs],[Vdiff $Vd $Vs],[Vdiff $Vb $Vs],$L,&$name:dgm_dvgs,&$name:dgm_dvds,&$name:dgm_dvbs,&$name:dgm_dl)*($W/$L)"
        set ::go_equations($name) "($W/$L)/interpolateg(&:look_up_tables:$type:ro:$::opt(process),[Vdiff $Vg $Vs],[Vdiff $Vd $Vs],[Vdiff $Vb $Vs],$L,&$name:dro_dvgs,&$name:dro_dvds,&$name:dro_dvbs,&$name:dro_dl)"
        @ $name:Ideq = 0
        @ $name:go = 1
        @ $name:gm = 1
        define_derivative $name:gm * first 0
        define_derivative $name:gm $W second "$name:gm/$W"
        define_derivative $name:gm $L second "($name:dgm_dl-$name:gm/$L)*($W/$L)"
        define_derivative $name:go * first 0
        define_derivative $name:go $W second "$name:go/$W"
        define_derivative $name:go $L second "-$name:go*($name:dro_dl*$name:go*($L/$W)+1/$L)"
        set ::sensitivity($name:gm,$W) $name:gm:$W
        @ $name:gm:$W = 0
        $name:gm:$W=>$name:gm/$W
        set ::sensitivity($name:gm,$L) $name:gm:$L
        @ $name:gm:$L = 0
        $name:gm:$L=>($name:dgm_dl-$name:gm/$L)*($W/$L)
        @ $name:go:$W = 0
        set ::sensitivity($name:go,$W) $name:go:$W
        $name:go:$W=>$name:go/$W
        set ::sensitivity($name:go,$L) $name:go:$L
        @ $name:go:$L = 0
        $name:go:$L=>-$name:go*($name:dro_dl*$name:go*($L/$W)+1/$L)
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
    puts $HTML <body>
    puts $HTML "<table border=\"2\">"
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
    set poly [present_poly g Det]
    Det=>$poly
    Ted=>1/Det
    @ size foreach_child c {
        derive_poly g size:$c dg_d$c
        Det:$c=>[present_poly dg_d$c Det_d$c]
        Ted:$c=>-Det:$c/(Det*Det)
        set ::sensitivity(Det,size:$c) Det:$c
        set ::sensitivity(Ted,size:$c) Ted:$c
    }
    set ::POLY(Ted@Ted) 1
    Info: Det=$poly
    puts $HTML Det=$poly
    puts $HTML </h3>
    @ 0:V = 0
    set i 0
    # Define Data Dependencies
    foreach node $::independent_nodes {
        if {[info exists ::dependent_nodes($node)]} {
            incr i
            continue
        }
        detp ::KCL p 0 {} $i $y
        mult_poly p Ted $node
        set poly [present_poly $node $node:Next]
        $node:Next=>$poly
        puts $HTML "$node:Next=$poly<br><br>"
        Info: $node:Next=$poly
        $node:V=>limit($node:Next,0,$::opt(topv))
        incr i
    }
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
    set needed_temps {}
    foreach key [array names ::NEEDED] {
        skip {$::NEEDED($key)==0}
        lappend needed_temps $::CSE($key)
    }
    set needed_temps [lsort -command tmp_sort $needed_temps]
    .procedure converge {} {
        continue=1
        .for {step_counter=0} {step_counter<$::opt(step_limit) && continue} {step_limit=step_limit+1} {
	    continue=0
            # Set operating point
	    .tp step_counter
            .tp size:L
            .tp size:W
            .for {i=0} {i<$::opt(op_limit)} {i=i+1} {
                .tp i
                foreach name [array names ::Ids_equations] {
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
#                    .if {$::transistors($name,Vgs)<6e-1} {
#                        $name:Ideq=0
#                    } else {
#                        $name:Ideq=$::Ids_equations($name)
#                    }
                        $name:Ideq=$::Ids_equations($name)
                }
                
                foreach temp $needed_temps {
                    .calculate $temp
                }
                .calculate Det
                .calculate Ted
                @ size foreach_child c {
                    .calculate Det:$c
                    .tp Det:$c
                    .calculate Ted:$c
                    .tp Ted:$c
                    puts $HTML "dDet/d$c=$::DEF(Det:$c)<br><br>"
                    puts $HTML "dTed/d$c=$::DEF(Ted:$c)<br><br>"
                }
                foreach node $::independent_nodes {
                    Info: NODE $node
                    .calculate $node:Next
                    .tp $node:Next
                    .tp i
                }
                foreach node $::independent_nodes {
                    .calculate $node:V
                    .tp $node:V
                }
                foreach name [array names ::G_equations] {
                    .calculate Gds_$name
                    .default Gds_$name 1e+0
                }
            }
            .tp Det
            .tp Ted
            @ property foreach_child p {
                Info: PROPERTY $p
                set expression [flat_expression  $::properties($p,expression)]
                property:$p=$expression
                .tp property:$p
                puts $HTML "$p=$expression<br><br>"
                start_poly $p $expression
                @ size foreach_child s {
                    @ property:$p:$s = 0
                    derive_poly $p size:$s d_$p
                    set expression [present_poly d_$p]
                    remove_poly d_$p
                    property:$p:$s=$expression
                    .tp property:$p:$s
                    puts $HTML "d$p/d$s=$expression<br><br>"
                }
            }
            @ size foreach_child value {
                Info: Size=$value
                size:$value:step=0
                foreach spec [array names ::specification] {
                    Info: Compiling Spec: $spec $::specification($spec)
                    lassign [split $spec ,] name op
                    switch $op {
                        "=" {
                            .if {property:$name:$value!=0} {
                                .let size:$value:step=(property:$name-$::specification($spec))/property:$name:$value
                            }    
                        }
                        "<" {
                            .if {(property:$name>=$::specification($spec))&&(property:$name:$value!=0)} {
                                .let size:$value:step=(property:$name-$::specification($spec))/property:$name:$value
                            }
                        }
                        ">" {
                            .if {(property:$name<=$::specification($spec))&&(property:$name:$value!=0)} {
                                .let size:$value:step=(property:$name-$::specification($spec))/property:$name:$value
                            }
                        }
                    }
                    .let size:$value:step=limit(size:$value:step,size:$value:step:min,size:$value:step:max)
                    .tp size:$value:step
                }
		.if {size:$value:step!=0} {
		    continue=1
		}
            }
            @ size foreach_child value {
                .let size:$value=limit(size:$value-size:$value:step/1000,size:$value:min,size:$value:max)
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
default ::opt(iref) 40e-6
..init
default ::opt(topology) nmos_cs
switch $::opt(topology) {
    diffpair {
        @ topologies/$::opt(topology)((Wp,Lp,Wn,Ln,Ws,Ls,Iref|Adc,Area)) !
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
        @ param/pos = [expr $::opt(topv)/2]
        @ param/neg = [expr $::opt(topv)/2]
        @ param/vdd = $::opt(topv)
        @ param/iref = $::opt(iref)
        foreach class {p n s} {
            @ size/W$class/min = 40e-9
            @ size/W$class/max = 10e-6
            @ size/L$class/min = 40e-9
            @ size/L$class/max = 10e-6
        }
        #    rload outp 0 1e+7
        .property Adc -expression derive(outp,param:pos)-derive(outp,param:neg) -to_display 20*log10(@) -from_display pow(10,@/20) -unit dB
        .spec Adc < 40
        .spec Adc > 30
    }
    diffpair_simple {
        @ topologies/$::opt(topology)((Wp,Lp,Wn,Ln,Ws,Ls|Adc,Area)) !
        mp_1 outm outm vdd vdd pch W=size:Wp L=size:Lp
        mp_2 outp outm vdd vdd pch W=size:Wp L=size:Lp
        mnin_1 outm inp tail 0 nch W=size:Wn L=size:Ln
        mnin_2 outp inm tail 0 nch W=size:Wn L=size:Ln
        mn_tail tail vbias 0 0 nch W=size:Ws L=size:Ls
        vref  vbias 0 param:vref
        vdd 0 vdd $::opt(topv)
        vinp 0 inp param:pos
        vinm 0 inm param:neg
        @ param/pos = [expr $::opt(topv)/2]
        @ param/neg = [expr $::opt(topv)/2]
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
    nmos {
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
        @ param:ref_current = 15e-6
        vin 0 in param:vin
        default ::opt(vin) 0.9
        @ param:vin = $::opt(vin)
        vdd 0 vdd $::opt(topv)
        mn_ref  out in 0 0 nch W=size:W L=size:L
        .property Adc -expression derive(out,param:vin) -to_display 20*log10(@) -from_display pow(10,@/20) -unit dB
        .spec Adc < -15
    }
    pmos {
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
        @ param:ref_current = -5e-6
        default ::opt(vin) 0.2
        @ param:vin = $::opt(vin)
        vin 0 in param:vin
        vdd 0 vdd $::opt(topv)
        mn_ref  out in vdd vdd pch W=size:W L=size:L
        .property Adc -expression derive(out,param:vin) -to_display 20*log10(@) -from_display pow(10,@/20) -unit dB
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
converge
exit
while {1} {
    for {set main_loop 0} {$main_loop<$::opt(save_size)} {incr main_loop} {
        @ size foreach_child s {
            @ size/$s = [expr [@ size/$s/min]+([@ size/$s/max]-[@ size/$s/min])*rand()]
        }
        for {set k 0} {$k<4} {incr k} {
            converge
        }
        @ topologies/$::opt(topology) <<< [@ size/L] [list [@ property/Adc] [@ size/L]]
    }
    @ topologies save pareto.db
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


