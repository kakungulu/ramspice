# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
default ::opt(interpolation) LUT
default ::opt(process) ss
default ::opt(device) nch
default ::opt(tech) tsmc018
default ::opt(topv) 1.8
default ::opt(l) 360e-9
default ::opt(w) 360e-9
default ::opt(vgs) 1.0
default ::opt(vbs) 0.0
default ::opt(r) 1e3
default ::opt(limit) 10
default ::opt(np) 1

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
    append ::kcl_equations($m) "-$value"
    append ::kcl_equations($p) "+$value"
}
array set ::all_resistors {}
proc add_resistor {name m p value} {
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
}
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
	    }
	}
        Info: .let $name/Ids=interpolate(&{/look_up_tables/$type/Ids/$::opt(process)},$Vg-$Vs,$Vd-$Vs,$Vb-$Vs,$L)*($W/$L)
        .let $name/Ids=interpolate(&{/look_up_tables/$type/Ids/$::opt(process)},$Vg-$Vs,$Vd-$Vs,$Vb-$Vs,$L)*($W/$L)
    }
    foreach node [array names ::kcl_equations] {
        Info: .let KCL/$node=$::kcl_equations($node)
        .let KCL/$node=$::kcl_equations($node)
    }
}
proc add_transistor {name d g s b type args} {
    lappend ::all_transistors $name
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
    foreach field {L W} {
        if {![info exists  ::transistors($name,$field)]} {
            set class [lindex [split $name _] 0]
            set ::transistors($name,$field) \{Geometry/$field$class\}
        }
    }
    foreach channel_node [list $s $d] {
        if {![info exists ::kcl_equations($channel_node)]} {
            set ::kcl_equations($channel_node) ""
        }
    }
    if {$type=="nch"} {
        append ::kcl_equations($s) "-\{$name/Ids\}"
        append ::kcl_equations($d) "+\{$name/Ids\}"
    } else {
        append ::kcl_equations($s) "+\{$name/Ids\}"
        append ::kcl_equations($d) "-\{$name/Ids\}"
    }
}

v1 0 vdd 1.8
# v2 0 vin 0.9
mp mid mid vdd vdd pch 
mn mid vin 0 0 nch 
r1 0 vin r_in
r2 vin vdd (100-r_in)
.compile_circuit
exit


