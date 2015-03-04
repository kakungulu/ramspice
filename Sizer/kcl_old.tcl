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
foreach dev {nch pch} {
    @ /look_up_tables/$dev !
    foreach param {ids} {
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
array set ::vdc {0 0}
array set ::floating_vdc {}

proc add_idc {name m p value} {
    foreach node [list $m $p] {
        if {![info exists ::kcl_equations($node)]} {
            set ::kcl_equations($node) ""
        }
    }
    append ::kcl_equations($m) "+$value"
    append ::kcl_equations($p) "-$value"
}
array set ::all_resistors {}
proc add_resistor {name m p value} {
    ladd ::adjacency($m) $p
    ladd ::adjacency($p) $m
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
proc add_vdc {name m p value} {
    if {[string compare $m $p]==1} {
        set ::kcl_mapping($m) $p
    } else {
        set ::kcl_mapping($p) $m
    }
    if {[info exists ::vdc($m)]} {
        if {![info exists ::vdc($p)]} {
            set ::vdc($p) [expr $::vdc($m)+$value]
        }  
        return
    }
    if {[info exists ::vdc($p)]} {
        if {![info exists ::vdc($m)]} {
            set ::vdc($m) [expr $::vdc($p)+$value]
        }  
        return
    }
    if {[info exists ::vdc($p)]} {
        if {[info exists ::vdc($m)]} {
            if {$::vdc($p)-$::vdc($m)!=$value} {
                Error: Voltage source cycle violates KVL
            }
            return
        }  
    }
    set ::floating_vdc($m,$p) $value
    foreach m_neighbor $::adjacency($m) {
        ladd ::adjacency($p) $m_neighbor
    }
    foreach p_neighbor $::adjacency($p) {
        ladd ::adjacency($m) $p_neighbor
    }
}
default ::opt(eps) 1e-4
set ::epsilon $::opt(eps)
array unset ::adjacency
proc .compile_circuit {} {
    # Eliminate floating vdc
    set all_vdc [lsort [array names ::floating_vdc]]
    while {[array size ::floating_vdc]>0} {
        foreach node_list [array names ::floating_vdc] {
            set value $::floating_vdc($node_list)
            array unset ::floating_vdc $node_list
            uplevel [list add_vdc [split $node_list ,] $value]
        }
        set post_all_vdc [lsort [array names ::floating_vdc]]
        if {$all_vdc==$post_all_vdc} break
        set all_vdc $post_all_vdc
    }
    # Add resistors
    foreach res_nodes [array names ::all_resistors] {
        lassign [split $res_nodes ,] m p
        foreach node [list $m $p ] {
            if {[info exists ::vdc($node)]} {
                set V($node) $::vdc($node)
            } else {
                set V($node) \{V/$node\}
            }
        }
        append ::kcl_equations($m) "+($V($p)-$V($m))/$::all_resistors($res_nodes)"
        append ::kcl_equations($p) "+($V($m)-$V($p))/$::all_resistors($res_nodes)"
    }
    # Merge all voltage-tied nodes into a single KCL node
    foreach node [array names ::kcl_equations] {
        set kcl_map [kcl_map $node]
        if {$node!=$kcl_map} {
            append ::kcl_equations($kcl_map) $::kcl_equations($node)
            array unset ::kcl_equations $node
        }
    }
    # generate Gamma equations for the circuit
    foreach name $::all_transistors {
        foreach field {type L W d g s b} {
            set $field $::transistors($name,$field)
        }
        foreach node_name {d g s b} {
            set node [set $node_name]
            if {[info exists ::vdc($node)]} {
                set V$node_name $::vdc($node)
            } else {
                set V$node_name \{V/$node\}
                @ V/$node = real [expr $::opt(topv)/2]
                @ Next/$node = real [expr $::opt(topv)/2]
            }
        }
        Info: .function Ids_${name}()=interpolate(&{/look_up_tables/$type/Ids/$::opt(process)},$Vg-$Vs,$Vd-$Vs,$Vb-$Vs,$L)*($W/$L)
        .function Ids_${name}()=interpolate(&{/look_up_tables/$type/Ids/$::opt(process)},$Vg-$Vs,$Vd-$Vs,$Vb-$Vs,$L)*($W/$L)
        #        .function Ids_${name}()=interpolate(&{/look_up_tables/$type/Ids/$::opt(process)},$Vg-$Vs,$Vd-$Vs,0,$L)*($W/$L)
    }
    set independent_nodes 0
    foreach node [array names ::kcl_equations] {
        skip {[info exists ::vdc($node)]}
        incr independent_nodes
    }
    default ::opt(th) 1e-3
    set threshold [expr pow($::opt(th)*$independent_nodes,2)]	
    default ::opt(steps) 1e+1
    set ::independent_nodes {}
    foreach node [array names ::kcl_equations] {
        skip {[info exists ::vdc($node)]}
        lappend ::independent_nodes $node
    }
###    .procedure operating_point {} {
###        total_error=10
###        Info: independent_nodes=$::independent_nodes
###        top_step=[expr $::opt(topv)/3]
###        error_orig=0
###        foreach node $::independent_nodes {
###            error_orig=error_orig+square($::kcl_equations($node))
###        }   
###        .for {i=1} {i<$::opt(limit)} {i=i+1} {
###            step=1e-3
###            foreach node $::independent_nodes {
###	        original_voltage={V/$node}
###	        V/$node=[expr $::opt(topv)/2]
###                .for {j=1} {j<10} {j=j+1} {
###                    down_voltage={V/$node}
###                    error_down=square($::kcl_equations($node))
###                    foreach other_node $::adjacency($node) {
###                        skip {[info exists ::vdc($other_node)]}
###                        error_down=error_down+square($::kcl_equations($other_node))
###                    }   
###                    V/$node={V/$node}+step
###                    up_voltage={V/$node}
###                    error_up=square($::kcl_equations($node))
###                    foreach other_node $::adjacency($node) {
###                        skip {[info exists ::vdc($other_node)]}
###                        error_up=error_up+square($::kcl_equations($other_node))
###                    }   
###                    V/$node=up_voltage-step*error_up/(error_up-error_down)
###                    error_orig=0
###                    foreach other_node $::independent_nodes {
###                        error_orig=error_orig+square($::kcl_equations($other_node))
###                    }   
###                }
###                .tp error_orig
###                .tp V/$node
###            }
###        }
###    }
    .procedure operating_point {} {
	optimal_error=1e+3
        .for {i=1} {i<$::opt(limit) && optimal_error>1e-14} {i=i+1} {
            step=1e-3
            foreach node $::independent_nodes {
	         tmp={V/$node}
	         V/$node=0
		 optimal_voltage=0
		 optimal_error=1e+3
                .for {j=1} {j<1.1e+3} {j=j+1} {
                    V/$node={V/$node}+step
                    error_orig=0
                    foreach other_node $::independent_nodes {
                        error_orig=error_orig+square($::kcl_equations($other_node))
                    }   
		    .if {error_orig<optimal_error} {
		        optimal_voltage={V/$node}
			optimal_error=error_orig
		    }
                }
		Next/$node=optimal_voltage
		.if {i<5} {
		    V/$node=tmp
		} else {
		    V/$node=optimal_voltage
		}
            }
            foreach node $::independent_nodes {
		V/$node={Next/$node}
            }
        }
    }
}
# proc .tp args {}
proc add_transistor {name d g s b type args} {
    lappend ::all_transistors $name
    ladd ::adjacency($d) $s
    ladd ::adjacency($s) $d
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
    foreach channel_node [list $s $d] {
        if {![info exists ::kcl_equations($channel_node)]} {
            set ::kcl_equations($channel_node) ""
        }
    }
    if {$type=="nch"} {
        append ::kcl_equations($s) "-Ids_${name}()"
        append ::kcl_equations($d) "+Ids_${name}()"
    } else {
        append ::kcl_equations($s) "+Ids_${name}()"
        append ::kcl_equations($d) "-Ids_${name}()"
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
} else {
    mp_1 outm outm vdd vdd pch L=1e-6 W=2e-6
    mp_2 outp outm vdd vdd pch L=1e-6 W=2e-6
    mn_1 outm inp sink 0 nch L=1e-6 W=2e-6
    mn_2 outp inm sink 0 nch L=1e-6 W=2e-6
    mn_sink sink vbias 0 0 nch L=1e-6 W=2e-6
    mn_ref  vbias vbias 0 0 nch L=1e-6 W=2e-6
    iref vdd vbias $::opt(iref)
    vdd 0 vdd $::opt(topv)
    vinp 0 inp [expr $::opt(topv)/2]
    vinm 0 inm [expr $::opt(topv)/2]
    #    rload outp 0 1e+7
}
.compile_circuit

operating_point
foreach node [array names ::kcl_equations] {
    skip {[info exists ::vdc($node)]}
    Info: KCL$node=0=$::kcl_equations($node)
}
@ V foreach_child node {
    Info: V$node=[eng [@ V/$node] V]
}    
Info: Converged after [@ i] iterations. error=[eng [expr sqrt([@ optimal_error]/[llength $::independent_nodes])] A]
exit


