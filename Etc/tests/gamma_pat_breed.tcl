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
default ::opt(topology) diffpair_nmos
set ::opt(mode) [string tolower $::opt(mode)]
default EPS0 8.85418e-12
default ::opt(epsrox) 3.9
default ::opt(source) Etc/Tech_DB/tsmc040/4d/5:5:3:6/
@ / load Etc/Templates/$::opt(topology)/ctree.db
@ op_iterations = 5
proc present_property {p {val {}}} {
    regsub -all @ [@ property/$p/formula] $val expr
    return [eng [expr $expr] [@ property/$p/unit]]
}
default ::opt(param) {}
foreach param_pair $::opt(param) {
    lassign [split $param_pair =] param value
    @ param:$param = $value
}
load $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/libGamma.so
@ size foreach_child s {
    set min($s) [expr [@ size/$s]-([@ size/$s]-40e-9)/2]
    set span($s) [expr 10e-6-$min($s)]
}
default ::opt(sample) 100
default ::opt(iref) 10e-6
set pat_sizes {}
@ size foreach_child w {
    skip {![string match W* $w]}
    regsub {W} L$w {} l
    lappend pat_sizes $w
    lappend pat_sizes $l
}
@ / foreach_child n {
    skip {![@ $n:V ?]}
    skip {$n=="vdd"}
    skip {$n=="0"}
    skip {[@ param:$n ?]}
    lappend pat_sizes $n
}
set pat_properties {}
@ property foreach_child p {
    if {[@ property/$p/step_factor]<0} {
        set p "-$p"
    }
    lappend pat_properties $p
}
lappend pat_properties -Area
lappend pat_properties -Power

set seed 1
set maxAdc 0
if {[file exists Etc/Templates/$::opt(topology)/pareto.db]} {
    @ / load Etc/Templates/$::opt(topology)/pareto.db
    set AdcIndex [llength [@ $::opt(topology)/circuits PAT properties]]
    incr AdcIndex -1
    for {set i 0} {$i<[@ $::opt(topology)/circuits PAT size]} {incr i} {
        set Adc [lindex [@ $::opt(topology)/circuits PAT index $i] end-$AdcIndex]
	if {$maxAdc<$Adc} {
	    set maxAdc $Adc
	}
    }
} else {
    @ $::opt(topology)/circuits(([join $pat_sizes ,]|[join $pat_properties ,])) !
}
Info: maxAdc=$maxAdc
set i 0
set initial_size [@ $::opt(topology)/circuits PAT size]
while {[@ $::opt(topology)/circuits PAT size]<$::opt(sample)*50+$initial_size} {
    set skip 0
    if {[@ $::opt(topology)/circuits PAT size]<$::opt(sample)+$initial_size} {
        set phase seed
        @ size foreach_child w {
            skip {![string match W* $w]}
            regsub {W} L$w {} l
            @ size/$l = [expr (10e-6-40e-9)/(exp(5)-1)*(exp(rand()*5)-1)+40e-9]
            set wbyl [expr 49/(exp(5)-1)*(exp(rand()*5)-1)+1]
            @ size/$w = [expr $wbyl*[@ size/$l]]
            if {[@ size/$w]>10e-6} {
                set skip 1
            }
            set sample($w) [@ size:$w]
            set sample($l) [@ size:$l]
        }
    } elseif {0} {
        set phase breed
        set index [expr int(rand()*([@ $::opt(topology)/circuits PAT size]-1))]
        set sizes [@ $::opt(topology)/circuits PAT index $index]
        set j 0
        @ size foreach_child s {
            set step 10e-9
            if {rand()>0.5} {
                set step -$step
            }
            @ size/$s = [expr $step+[lindex $sizes $j]]
            if {[@ size/$s]<40e-9} {
                @ size/$s = 40e-9
            }
            incr j
        }
    } else {
        set phase breed
        set index [expr (-$i)%[@ $::opt(topology)/circuits PAT size]]
        set sizes [@ $::opt(topology)/circuits PAT index $index]
        set j 0
        @ size foreach_child s {
            set step 10e-9
            if {rand()>0.5} {
                set step -$step
            }
            @ size/$s = [expr $step+[lindex $sizes $j]]
            if {[@ size/$s]<40e-9} {
                @ size/$s = 40e-9
            }
            incr j
        }
    }
    if {$skip} {
        continue
    }
    @ / foreach_child n {
        skip {![@ $n:V ?]}
        skip {$n=="vdd"}
        skip {$n=="0"}
        if {[@ param:$n ?]} {
            @ $n:V = [@ param:$n]
        } else {
            @ $n:V = [expr [@ vdd:V]/2]
        }
    }	 
    @ vdd:V = $::opt(topv)
    @ 0:V = 0
    @ param/iref = [expr $::opt(iref)*rand()]
    
    set sample(iref) [@ param/iref]
    ::C::import
    ::C::op
    ::C::export
    # Filter out bad OP circuits
    @ / foreach_child n {
        skip {![@ $n:V ?]}
        # Detect OP catastophe. A fix: exclude static nodes from OP loop.
        if {[string match *n* [@ $n:V]]} {
            set skip 1
        }
        skip {[@ param:$n ?]}
        skip {$n=="vdd"}
        skip {$n=="0"}
        if {[@ $n:V]==0} {
            set skip 1
        }
        if {[@ $n:V]==$::opt(topv)} {
            set skip 1
        }
        set sample($n) [@ $n:V]
    }
    @ property foreach_child p {
        if {[regexp n [@ property/$p]]} {
            set skip 1
        }
    }
    # illegal property values indicate bad OP or useless circuit sizes
    if {[@ property/ts]<0} {
        set skip 1
    }
    if {[@ property/Adc]<1} {
        set skip 1
    }
    
    if {$skip} {
        ###        set msg {}
        ###        @ / foreach_child n {
            ###   	    skip {![@ $n:V ?]}
            ###	    append msg "$n=[@ $n:V] "
        ###	}    
        ###        Info: $i $msg
        continue
    }
    # Good OP circuit
    @ property foreach_child p {
        set sample($p) [@ property:$p]
    }
    if {$maxAdc<[@ property/Adc]} {
        set maxAdc [@ property/Adc]
    }
    set Area 0
    @ size foreach_child w {
        skip {![string match W* $w]}
        regsub {W} L$w {} l
        set Area [expr $Area+[@ size/$w]*[@ size:$l]+40e-9*[@ size/$w]]
    }
    set sample(Area) [expr $Area*1e12]
    set sample(Power) [expr ([@ param/iref])*([@ vdd:V])]	
    set pat_entry_sizes {}
    foreach s $pat_sizes {
        lappend pat_entry_sizes $sample($s)
    }
    set pat_entry_properties {}
    foreach p $pat_properties {
        regsub {^\-} $p {} p
        lappend pat_entry_properties $sample($p)
    }
    @ $::opt(topology)/circuits <<< $pat_entry_sizes $pat_entry_properties
    Info: $i [@ $::opt(topology)/circuits PAT size] [eng [expr 100.0*([@ $::opt(topology)/circuits PAT size]-$initial_size)/$i] %] $maxAdc $phase
    incr i
} 
@ / save Etc/Templates/$::opt(topology)/pareto.db
exit
for {set i 0} {$i<[@ $::opt(topology)/circuits PAT size]} {incr i} {
    Info: [@ $::opt(topology)/circuits PAT index $i]
}
Info: [@ $::opt(topology)/circuits PAT size] Pareto points
exit

Info: Generating HTML report
set ::web_output 1
set ::HTML [open /tmp/report.html w]
<html><body><table border="1">
for {set i 0} {$i<[@ $::opt(topology)/circuits PAT size]} {incr i} {
    if {$i%30==0} {
        <tr><td></td>
        @ size foreach_child s {
            <td><b>$s</b></td>
        }   
        <td><b>I<sub>Ref.</sub></b></td>
        @ / foreach_child n {
            skip {![@ $n:V ?]}
            skip {[@ param:$n ?]}
            skip {$n=="vdd"}
            skip {$n=="0"}
            <td><b>$n</b></td>
        }   
        @ property foreach_child p {
            <td><b>$p</b></td>
        }   
        <td><b>Area</b></td><td><b>Power</b></td>
        </tr>
    }
    if {$sample(Adc,$i)>1} {
        <font color=green>
    } else {
        <font color=black>
    }
    <tr><td><b>$i</b></td>
    @ size foreach_child s {
        <td>[eng $sample($s,$i) m]</td>
    }	
    <td>[eng $sample(iref,$i) A]</td>
    @ / foreach_child n {
        skip {![@ $n:V ?]}
        skip {[@ param:$n ?]}
        skip {$n=="vdd"}
        skip {$n=="0"}
        <td>[eng $sample($n,$i) V]</td>
    }	
    @ property foreach_child p {
        <td>[present_property $p $sample($p,$i)]</td>
    }	
    <td>[eng $sample(Area,$i) (um)<sup>2</sup>]</td>
    <td>[eng $sample(Power,$i) W]</td>
    </tr></font>
}
</table></body></html>
close $::HTML
exit
