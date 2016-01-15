# \
exec $RAMSPICE/ramspice $0 $argv
source $::env(RAMSPICE)/Gamma/GammaCC.tcl
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
default ::opt(rez) 5:5:3:1:1
default ::opt(dim) 2p3

set ::opt(mode) [string tolower $::opt(mode)]
default EPS0 8.85418e-12
default ::opt(epsrox) 3.9
default ::opt(source) $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/$::opt(dim)d/$::opt(rez)/
source $::env(RAMSPICE)/Sizer/simplify.tcl
source $::env(RAMSPICE)/Sizer/matrices.tcl
source $::env(RAMSPICE)/Sizer/derivatives.tcl
source $::env(RAMSPICE)/Sizer/polynomials.tcl
source $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/binning_$::opt(tech).tcl
proc derive_by_polish {by expr} {
    if {[llength $expr]==1} {
        set expr [lindex $expr 0]
    }
    if {[llength $expr]==1} {
        if {$expr==$by} {
	    return 1
	}
	return 0
    }
    lassign $expr op X Y
    switch $op {
        + {
	    return [list $op [derive_by_polish $by $X] [derive_by_polish $by $Y]]
	}
	- {
	    return [list $op [derive_by_polish $by $X] [derive_by_polish $by $Y]]
	}
	* {
	    return [list + [list $op $X [derive_by_polish $by $Y]] [list $op [derive_by_polish $by $X] $Y]]
	}
    }
}
proc derive_expression {by expr} {
    return [DERIVE $by $expr]
}
foreach dev {nch pch} dtox {2.7e-10 3.91e-10} toxe {2.47e-9 2.71e-9} {
    set toxp [expr $toxe-$dtox]
    @ /look_up_tables/$dev/cox = [expr $::opt(epsrox)*$EPS0/$toxp]
    @ /look_up_tables/$dev !
    foreach param {ids gm go gb} {
        foreach file [glob -nocomplain $::opt(source)/$::opt(tech)_${dev}_*_${param}.db] {
	     regexp {_([0-9]+)_} [file tail $file] -> section
             @ /look_up_tables/$dev/$section load $file
        }
    }
    foreach param {thermal_noise flicker_noise} {
        @ /look_up_tables/$dev/$param !
        foreach file [glob -nocomplain $::opt(source)/$::opt(tech)_${dev}_*_${param}.db] {
	     regexp {_([0-9]+)_} [file tail $file] -> section
             @ /look_up_tables/$dev/$section/$param load $file
        }
    }
    foreach cap {cgg cgd cgs cgb cdd cdg cdb cds csd csg css csb cbd cbg cbs cbb} {
        foreach file [glob -nocomplain $::opt(source)/$::opt(tech)_${dev}_ss_*_$cap.db] {
	    regexp {_([0-9]+)_} [file tail $file] -> section
            @ /look_up_tables/$dev/$section/$cap/ load $file
	}    
    }	
}

set ::all_transistors {}
set ::all_nodes {}
#array set ::vdc {0 0}

proc add_idc {name m p value} {
    set ::idc($m,$p) $value
    add_node $m $p
}
set ::dependent_nodes(0) 1
proc add_vdc {name m p value} {
    set init_value $value
    while {[regexp {^(.*)@([a-zA-Z0-9_:]+)(.*)$} $init_value -> pre c post]} {
        set init_value $pre
	append init_value [@ $c]
	append init_value $post
    }
    if {[@ $init_value ?]} {
        set init_value [@ $init_value]
    }
    if {[catch {expr $value}]} {
        set ::vdc($m,$p) @$value
    } else {
        set ::vdc($m,$p) $value
    }
    add_node $m $p
    if {[info exists ::dependent_nodes($m)]} {
        Dinfo: $p depends on $m ($value)
        set ::dependent_nodes($p) {}
        $p:Next=>$m+$value
        $p:V=>$p:Next
        @ $p:Next = [expr [@ $m:Next]+$init_value]
        @ $p:V = [expr [@ $m:Next]+$init_value]
    } elseif {[info exists ::dependent_nodes($p)]} {
        Dinfo: $m depends on $p ($value)
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
    add_node $m $p
    foreach node [list $m $p] {
        if {![info exists ::mna_equations($node)]} {
            set ::mna_equations($node) ""
        }
    }
    if {![info exists ::all_resistors($m,$p)]} {
        set ::all_resistors($m,$p) $value
    } else {
        set ::all_resistors($m,$p) [expr $value*$::all_resistors($m,$p)/($value+$::all_resistors($m,$p))]
    }
}
array set ::mna_mapping {}
proc mna_map {node} {
    if {[info exists ::mna_mapping($node)]} {
        return [mna_map $::mna_mapping($node)]
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
        return @$v1
    }
    if {$v2=="\{0:V\}"} {
        return @$v1
    }
    if {$v1==0} {
        return "(-@$v2)"
    }
    if {$v1=="0:V"} {
        return "(-@$v2)"
    }
    if {$v1=="\{0:V\}"} {
        return "(-@$v2)"
    }
    if {$v1==$v2} {
        return 0
    }	
    return "(@$v1-@$v2)"
}
proc add_mna {i j element} {
    if {$i=="0"} return
    if {$j=="0"} return
    set i [lsearch $::independent_nodes $i]
    set j [lsearch $::independent_nodes $j]
    default ::MNA($i,$j)
    default ::MNA(dim) 0
    if {$::MNA(dim)<=$i} {
        set ::MNA(dim) $i
	incr ::MNA(dim)
    }
    if {$::MNA(dim)<=$j} {
        set ::MNA(dim) $j
	incr ::MNA(dim)
    }
    append ::MNA($i,$j) $element
    regsub {^\++} $::MNA($i,$j)  {} ::MNA($i,$j)
    regsub {^\+\-} $::MNA($i,$j)  {-} ::MNA($i,$j)
    regsub {^\-\+} $::MNA($i,$j)  {-} ::MNA($i,$j)
}
proc tmp_sort {t1 t2} {
    regsub tmp $t1 {} i1
    regsub tmp $t2 {} i2
    if {int($i1)>int($i2)} {
        return 1
    }	
    return 0
}
proc add_node {args} {
    foreach m $args {
        ladd ::all_nodes $m
        if {![@ $m:V ?]} {
            @ $m:V = 0
        }
    }
}
set ::circuit_components {}
proc add_transistor {name d g s b type args} {
    lappend ::all_transistors $name
    add_node $d $g $s $b
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
source $::env(RAMSPICE)/Etc/Topologies/$::opt(topology).gsp
@ param/unique = 0

foreach {p unit formula step_factor} {
    Adc    dB 20*log10(abs(@)) 1e-16
    CMRR    dB 20*log10(abs(@)) 1e-13
    PSRR    dB 20*log10(abs(@)) -1e-11
    Rout    Ohm @ -1e-19
    BW    Hz @ 7e-23
    PM    deg @ 1
    Cin   F @ -1e-15
    ts    sec @ -1e-6
    Nt    V^2/Hz @ -1e-9
    Nf    V^2/Hz @ -1e-14
    TotalNoise V @ -1e-14
    fc     Hz @ -1e-17
    Vos   V @ -1e-6
    Area m^2 @ -1e-12
    Power W @ -1e-7
} {
    @ /property/$p = 0
    @ /property/$p/unit = string $unit
    @ /property/$p/formula = string $formula
    @ /property/$p/step_factor = $step_factor
    if {$step_factor<0} {
        lappend pareto_properties -$p
    } else {
        lappend pareto_properties $p
    }
    @ /size foreach_child s {
        @ /property/$p/$s = 0
    }
}
.compile_circuit
if {[file exists $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/models_$::opt(tech).db]} {
    exit
}
# Prepare some defaults in the skeleton db file
set pareto_properties {}
set pareto_sizes {}
@ size foreach_child s {
    @ size/$s = 1e-6
    lappend pareto_sizes $s
}
@ param foreach_child p {
    if {[regexp {^i[^n]} $p] } {
        @ param/$p = 10e-6
    } elseif {[string match r* $p]} {
        @ param/$p = 1e9
    } else {
        @ param/$p = [expr $::opt(topv)/2]
    }
}
foreach node $::all_nodes {
    @ $node/V = [expr $::opt(topv)/2]
}
@ vdd:V = $::opt(topv)
@ param/vdd = $::opt(topv)
@ p1 = 0
@ p2 = 0
@ op_iterations = 10

@ /pareto(([join $pareto_sizes ,]|[join $pareto_properties ,])) !
@ / save $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/models_$::opt(tech).db
exit

