set title "Instrumentation Operational Amplifier"
set input_type NMOS/PMOS

define_properties {
    Adc A<sub>DC</sub> dB 0 1000 1
    CMRR CMRR dB 0 1000 1
    PSRR PSRR dB 0 1000 1
    Vos V<sub>OS</sub> V 0 1 -0.001
    Rout R<sub>OUT</sub> &#8486\; 0 1e12 -1
    BW BW Hz 0 1e12 1
    ts t<sub>S</sub> sec 0 1 -1e-9
    Nt N<sub>T</sub> A<sup>2</sup>/Hz 0 1 -1e-17
    fc f<sub>corner</sub> Hz 0 1e9 -1
    Area Area (&#956\;m)<sup>2</sup> 0 1e9 -1
    Power Power W 0 1000 -1
}
define_sizers {
    Lcp1 {p48 p49} 40e-9 10e-6 m
    Wcp1 {p48 p49} 40e-9 10e-6 m
    Lcp2 {p2 p3} 40e-9 10e-6 m
    Wcp2 {p2 p3} 40e-9 10e-6 m
    Lcn1 {n4 n5} 40e-9 10e-6 m
    Wcn1 {n4 n5} 40e-9 10e-6 m
    Lcn2 {n27 n26} 40e-9 10e-6 m
    Wcn2 {n27 n26} 40e-9 10e-6 m

    Ldp1 {p47} 40e-9 10e-6 m
    Wdp1 {p47} 40e-9 10e-6 m
    Ldp2 {p39 p40} 40e-9 10e-6 m
    Wdp2 {p39 p40} 40e-9 10e-6 m
    Ldn1 {n42 n41} 40e-9 10e-6 m
    Wdn1 {n42 n41} 40e-9 10e-6 m
    Ldn2 {n36} 40e-9 10e-6 m
    Wdn2 {n36} 40e-9 10e-6 m
    Vref1 {} 0 1.1 V
    Vref2 {} 0 1.1 V
    Vref3 {} 0 1.1 V
    Vref4 {} 0 1.1 V
}
set name [file tail [file dirname [info script]]]
set ::topologies(op_amp,schematic) {
NewFormat	
blank			blank			blank			vdd			blank	      blank	    blank		blank		  blank 	    blank	    blank	    	vdd 		    blank		    blank	    vdd 	    nl  		    
blank			terminal(Vb1)/rrr	line/r  		pmos/rrr		blank	      blank	    blank		blank		  blank 	    blank	    blank	    	pmos/fr		    twire		    line/r	    pmos/rrr	    nl
blank			blank			corner/r		twire/rr		corner/rr     blank	    blank		blank		  blank 	    corner/r	    line/r	    	twire/r		    line		    corner/r	    twire/r	    nl
blank			corner/r		pmos/rrr		blank			pmos/fr       corner/rr     blank		blank		  blank 	    line	    terminal(Vb2)/rrr    pmos_linethrough/fr     crosswire		    crosswire	    pmos/rrr	    nl
blank			line			line			blank			corner        crosswire     line/r		corner/rr	  blank 	    line	    blank	    	twire/rrr		    double_corner/rrr	    corner/rrr      line	    nl
blank			line			corner  		line/r  		line/r        crosswire     line/r		double_corner/rr  cross_corner/rrr  double_corner/r line/r	    	crosswire		    corner/rrr  	    blank	    line	    nl
terminal(inn)/rrr	twire/r 		blank			blank			blank	      twire/rrr     terminal(inp)/r	cross_corner/rr   quad_corner/rr    cross_corner    blank	    	line		    blank		    blank	    twire/rrr	    terminal(outp)/r			    nl
blank			line			corner/r		line/r  		line/r        crosswire     line/r		double_corner/rrr cross_corner/r    double_corner   line/r	    	crosswire		    corner/rr		    blank	    line		    nl
blank			line			line			blank			corner/r      crosswire     line/r		corner/rrr	  blank 	    line	    blank	    	twire/rrr		    double_corner/rr	    corner/rr	    line	    nl
blank			corner  		nmos/frrr		blank			nmos/r        corner/rrr    blank		blank		  blank 	    line	    terminal(Vb3)/rrr    nmos_linethrough/r      crosswire		    crosswire	    nmos/frrr	    nl
blank			blank			corner  		twire			corner/rrr    blank	    blank		blank		  blank 	    corner	    line/r	    	twire/r		    line		    corner	    twire/r	    nl
blank			terminal(Vb4)/rrr	line/r  		nmos/frrr		blank	      blank	    blank		blank		  blank 	    blank	    blank	    	nmos/r		    twire/rr		    line/r	    nmos/frrr	    nl
blank			blank			blank			gnd			blank	      blank	    blank		blank		  blank 	    blank	    blank	    	gnd 		    blank		    blank	    gnd 	    nl
end
}
