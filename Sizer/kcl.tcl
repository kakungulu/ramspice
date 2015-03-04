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
source $::env(RAMSPICE)/Sizer/matrices.tcl
foreach dev {nch pch} {
    @ /look_up_tables/$dev !
    foreach param {ids gm ro} {
        @ /look_up_tables/$dev load $::opt(source)/$::opt(tech)_${dev}_${param}.db
    }
}

set unknown {
    if {[regexp {^[mM](\S+)\s+(.*)$} $args -> name arguments]} {
        eval "add_transistor $name $arguments"
        return
    }
    if {[regexp {^[vV](\S+)\s+(.*)$} $args -> name arguments]} {
        eval "add_vdc $name $arguments"
        return
    }
    if {[regexp {^[iI](\S+)\s+(.*)$} $args -> name arguments]} {
        eval "add_idc $name $arguments"
        return
    }
    if {[regexp {^[rR](\S+)\s+(.*)$} $args -> name arguments]} {
        eval "add_resistor $name $arguments"
        return
    }
}
append unknown [info body unknown]
proc unknown args $unknown
set ::all_transistors {}
set ::all_nodes {}
#array set ::vdc {0 0}

proc add_idc {name m p value} {
    set ::idc($m,$p) $value
    ladd ::all_nodes $m
    ladd ::all_nodes $p
}
proc add_vdc {name m p value} {
    set ::vdc($m,$p) $value
    ladd ::all_nodes $m
    ladd ::all_nodes $p
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
                set V($node) \{$node:V\}
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
                set V$node_name \{$node:V\}
 #               @ $node:V = real [expr $::opt(topv)]
                @ $node:V = real 0.8
                @ $node:Next = real 0
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
        set ::gm_equations($name) "interpolate(&:look_up_tables:$type:gm:$::opt(process),[Vdiff $Vg $Vs],[Vdiff $Vd $Vs],[Vdiff $Vb $Vs],$L)*($W/$L)"
        set ::go_equations($name) "($W/$L)/interpolate(&:look_up_tables:$type:ro:$::opt(process),[Vdiff $Vg $Vs],[Vdiff $Vd $Vs],[Vdiff $Vb $Vs],$L)"
        @ $name:Ideq = real 0
        @ $name:go = real 1
        @ $name:gm = real 1
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
    puts $HTML [det ::KCL]
    puts $HTML </h3>
    puts $HTML </body>
    puts $HTML </html>
    close $HTML
    @ 0:V = real 0
    .procedure operating_point {} {
        .for {i=0} {i<$::opt(limit)} {i=i+1} {
            Info: Gtotal=[det ::KCL]
            Gtotal=[det ::KCL]
            .tp Gtotal
            set i 0
            foreach node $::independent_nodes {
                Info: $node:Next=([det ::KCL 0 {} $i $y])/Gtotal
                $node:Next=([det ::KCL 0 {} $i $y])/Gtotal
                incr i
            }
            foreach node $::independent_nodes {
                Info: $node:V=$node:Next
                $node:V=limit($node:Next,0,$::opt(topv))
#                .tcl "Info: V$node=\[eng \[@ $node:V\] V\]"
            }
            foreach name [array names ::Ids_equations] {
                Info: $name:Ideq=$::Ids_equations($name)
		$name:gm=$::gm_equations($name)
		$name:go=$::go_equations($name)
		.if {$::transistors($name,Vgs)<6e-1} {
                    $name:Ideq=0
		} else {
                    $name:Ideq=$::Ids_equations($name)
		}
#                .tcl "Info: Ideq$node=\[eng \[@ $name:Ideq\] A\]"
            }
            foreach name [array names ::G_equations] {
                Info: Gds_$name=$::G_equations($name)
                Gds_$name=$::G_equations($name)
                .default Gds_$name 1e+0
            }
        }
    }
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
        if {![info exists  ::transistors($name,$field)]} {
            set ::transistors($name,$field) \{Geometry/$field$class\}
        }
        @ Geometry/$field$class = real $::transistors($name,$field)
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
} elseif {1} {
    mp_1 outm outm vdd vdd pch L=1e-6 W=2e-6
    mp_2 outp outm vdd vdd pch L=1e-6 W=2e-6
    mn_1 outm inp sink 0 nch L=1e-6 W=2e-6
    mn_2 outp inm sink 0 nch L=1e-6 W=2e-6
    mn_sink sink vbias 0 0 nch L=1e-6 W=2e-6
    mn_ref  vbias vbias 0 0 nch L=1e-6 W=2e-6
    iref  vbias vdd $::opt(iref)
    vdd 0 vdd $::opt(topv)
    vinp 0 inp [expr $::opt(topv)/2]
    vinm 0 inm [expr $::opt(topv)/2]
    #    rload outp 0 1e+7
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
    iref 0 vbias -$::opt(iref)
    vdd 0 vdd $::opt(topv)
    mn_ref  vbias vbias 0 0 nch L=1e-6 W=2e-6
}
.compile_circuit
set box {}
operating_point
@ . foreach_child node {
    skip {![@ $node:V ?]}
    append box V$node=[eng [@ $node:V] V]
    append box \n
}    
textbox $box
Info: Converged after [@ i] iterations. 
# error=[eng [expr sqrt([@ optimal_error]/[llength $::independent_nodes])] A]
exit


