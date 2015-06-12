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
for {set i 0} {$i<$::opt(sample)} {incr i} {
    set skip 0
    @ size foreach_child w {
        skip {![string match W* $w]}
	regsub {W} L$w {} l
	@ size/$l = [expr (10e-6-40e-9)/(exp(5)-1)*(exp(rand()*5)-1)+40e-9]
	set wbyl [expr 49/(exp(5)-1)*(exp(rand()*5)-1)+1]
	@ size/$w = [expr $wbyl*[@ size/$l]]
	if {[@ size/$w]>10e-6} {
	    set skip 1
	}
	set sample($w,$i) [@ size:$w]
	set sample($l,$i) [@ size:$l]
    }
    if {$skip} {
        incr i -1
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
    
    set sample(iref,$i) [@ param/iref]
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
        set sample($n,$i) [@ $n:V]
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
        incr i -1
	continue
    }
    # Good OP circuit
    Info: $i
    @ property foreach_child p {
        set sample($p,$i) [@ property:$p]
    }
    set Area 0
    @ size foreach_child w {
        skip {![string match W* $w]}
	regsub {W} L$w {} l
        set Area [expr $Area+[@ size/$w]*[@ size:$l]+40e-9*[@ size/$w]]
    }
    set sample(Area,$i) [expr $Area*1e12]
    set sample(Power,$i) [expr ([@ param/iref])*([@ vdd:V])]	
} 

Info: Generating HTML report
set ::web_output 1
set ::HTML [open /tmp/report.html w]
<html><body><table border="1">
for {set i 0} {$i<$::opt(sample)} {incr i} {
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
