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
default ::opt(limit) 10
default ::opt(np) 1
default ::opt(source) Tech_DB/tsmc040/4d/5:7.5:4:6/
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
    set opt(expression) [flat_expression $opt(expression)]
    foreach field [array names opt] {
        set ::properties($name,$field) $opt($field)
    }
    @ property/$name = real 0
    property/$name=>$opt(expression)
    set ::DERMODE $original_der_mode
}
proc .spec {name op value} {
    if {![info exists ::properties($name,expression)]} {
        Error: $name is not a defined property you can use in a spec. Start with: .property $name -expression <expression>
        exit
    }
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
    set ::vdc($m,$p) $value
    ladd ::all_nodes $m
    ladd ::all_nodes $p
    if {[info exists ::dependent_nodes($m)]} {
        Info: $p depends on $m ($value)
        set ::dependent_nodes($p) {}
        $p:Next=>$m+$value
        $p:V=>$p:Next
        @ $p:Next = real $::opt(topv)
    } elseif {[info exists ::dependent_nodes($p)]} {
        Info: $m depends on $p ($value)
        set ::dependent_nodes($m) {}
        $m:Next=>$p+$value
        $m:V=>$m:Next
        @ $m:Next = real $::opt(topv)
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
@ property/quality = real 0
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
                        .if {property:$name>=$::specification($spec)} {
                            .let size:$value:step=(1-$::specification($spec)/property:$name)/([derive_expression size:$value $::properties($name,expression)])
                        } else {
                            .let size:$value:step=(1-property:$name/$::specification($spec))/([derive_expression size:$value $::properties($name,expression)])
                        }
                    }
                    "<" {
                        .if {property:$name>=$::specification($spec)} {
                            .let size:$value:step=(1-$::specification($spec)/property:$name)/([derive_expression size:$value $::properties($name,expression)])
                        }
                    }
                    ">" {
                        .if {property:$name<=$::specification($spec)} {
                            .let size:$value:step=(1-property:$name/$::specification($spec))/([derive_expression size:$value $::properties($name,expression)])
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
            if {[lsearch $calculated_properties $name]==-1} {
                .calculate property/$name
                lappend calculated_properties $name
            }
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
                #               @ $node:V = real [expr $::opt(topv)]
                @ $node:V = real $::opt(topv)
                @ $node:Next = real $::opt(topv)
            }
        }
        #        add_kcl_entry $s $d "Gds_$name"
        set ::transistors($name,Vgs) [Vdiff $Vg $Vs]
        @ Gds_$name = real 1
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
        set ::Ids_equations($name) "interpolate(&:look_up_tables:$type:Ids:$::opt(process),[Vdiff $Vg $Vs],[Vdiff $Vd $Vs],[Vdiff $Vb $Vs],$L)*($W/$L)-$name:gm*[Vdiff $Vg $Vs]-$name:go*[Vdiff $Vb $Vs]"
        set ::gm_equations($name) "interpolateg(&:look_up_tables:$type:gm:$::opt(process),[Vdiff $Vg $Vs],[Vdiff $Vd $Vs],[Vdiff $Vb $Vs],$L,&$name:dgm_dvgs,&$name:dgm_dvds,&$name:dgm_dvbs,&$name:dgm_dl)*($W/$L)"
        set ::go_equations($name) "($W/$L)/interpolateg(&:look_up_tables:$type:ro:$::opt(process),[Vdiff $Vg $Vs],[Vdiff $Vd $Vs],[Vdiff $Vb $Vs],$L,&$name:dro_dvgs,&$name:dro_dvds,&$name:dro_dvbs,&$name:dro_dl)"
        @ $name:Ideq = real 0
        @ $name:go = real 1
        @ $name:gm = real 1
        define_derivative $name:gm * first 0
        define_derivative $name:gm $W second "$name:gm/$W"
        define_derivative $name:gm $L second "($name:dgm_dl-$name:gm/$L)*($W/$L)"
        define_derivative $name:go * first 0
        define_derivative $name:go $W second "$name:go/$W"
        define_derivative $name:go $L second "-$name:go*($name:dro_dl*$name:go*($L/$W)+1/$L)"
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
    set poly [present_poly g Gtotal]
    Gtotal=>$poly
    Info: Gtotal=$poly
    puts $HTML Gtotal=$poly
    puts $HTML </h3>
    @ 0:V = real 0
    set i 0
    # Define Data Dependencies
    foreach node $::independent_nodes {
        skip {[info exists ::dependent_nodes($node)]}
        detp ::KCL p 0 {} $i $y
        set poly [present_poly p $node:Next]
        $node:Next=>($poly)/Gtotal
        puts $HTML "$node:Next=($poly)/Gtotal<br>"
        Info: $node:Next=$poly
        $node:V=>limit($node:Next,0,$::opt(topv))
        incr i
    }
    foreach name [array names ::Ids_equations] {
        $name:gm=>$::gm_equations($name)
        $name:go=>$::go_equations($name)
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
    .procedure operating_point {} {
        .for {i=0} {i<$::opt(limit)} {i=i+1} {
            foreach name [array names ::Ids_equations] {
                .calculate $name:gm
                .calculate $name:go
                .if {$::transistors($name,Vgs)<6e-1} {
                    $name:Ideq=0
                } else {
                    $name:Ideq=$::Ids_equations($name)
                }
            }
            foreach temp $needed_temps {
                .calculate $temp
            }
            .calculate Gtotal
            foreach node $::independent_nodes {
                .calculate $node:Next
            }
            foreach node $::independent_nodes {
                .calculate $node:V
            }
            foreach name [array names ::G_equations] {
                .calculate Gds_$name
                .default Gds_$name 1e+0
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
            @ size:$field$class = real 3.6e-8
        } elseif {[regexp {^\((.*)\)$} $::transistors($name,$field) -> guide]} {
            set ::transistors($name,$field) size:$field$class
            @ size:$field$class = real $guide
        } else {
            
        }
    }
}
default ::opt(iref) 40e-6
..init
if {0} {
    #### # @ r_ref = real $::opt(ref)
    @ r_in = real $::opt(r)
    mp_2 mid ref vdd vdd pch L=1e-6 W=2e-6
    mn mid in 0 0 nch  L=1e-6 W=2e-6
    r1 0 in r_in
    r2 in vdd (100-r_in)
    # @ V/ref = real 0
    v1 0 vdd $::opt(topv)
    mp_1 ref ref vdd vdd pch L=1e-6 W=2e-6
    i1 0 ref $::opt(ref)
} elseif {0} {
    #    mp_1 outm outm vdd vdd pch L=1e-6 W=2e-6
    mp_1 outm outm vdd vdd pch
    mp_2 outp outm vdd vdd pch
    mnin_1 outm inp sink 0 nch
    mnin_2 outp inm sink 0 nch
    mn_sink sink vbias 0 0 nch
    mn_ref  vbias vbias 0 0 nch
    iref  vbias vdd $::opt(iref)
    vdd 0 vdd $::opt(topv)
    vinp 0 inp size:pos
    vinm 0 inm size:neg
    @ size:pos = real [expr $::opt(topv)/2]
    @ size:neg = real [expr $::opt(topv)/2]
    #    rload outp 0 1e+7
    .property Adc -expression (derive(outp:V,pos_input)-derive(outp:V,neg_input))/Gtotal -to_display 20*log10(@) -from_display pow(10,@/20) -unit dB
} elseif {0} {
    vs1 0 1 0.5
    vs2 0 3 $::opt(topv)
    r1 1 2 100
    r1 0 2 100
    r3 2 3 100
} elseif {0} {
    vdd 0 vdd 1.1
    r2 2 vdd 100
    vm 2 3 0.5
    r1 0 3 100
} else {
    iref 0 vbias parameter:ref_current
    @ parameter:ref_current = real -$::opt(iref)
    vdd 0 vdd $::opt(topv)
    mn_ref  vbias vbias 0 0 nch W=parameter:WbyL*size:L L=size:L
    @ parameter/WbyL = real 1
    @ size/L = real 360e-9
    .property Adc -expression n_ref:gm/n_ref:go -to_display 20*log10(@) -from_display pow(10,@/20) -unit dB
}
.compile_circuit

.spec Adc < 40
.spec Adc > 30
.compile_spec
#exit
@ inp:V = real [expr $::opt(topv)/2]
@ inm:V = real [expr $::opt(topv)/2]
set box {}
for {set k 0} {$k<80} {incr k} {
    operating_point
    quality
    calculate_step
    @ size foreach_child c {
        if {[@ size:$c:step ?]} {
            set step [expr 1-[@ size:$c:step]]
            @ size:$c = real [expr [@ size:$c]*$step]
        }
    }
}
operating_point
quality

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


