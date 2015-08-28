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
    Lp {p_1 p_2} 40e-9 10e6 m
    Wp {p_1 p_2} 40e-9 10e6 m
    Ln {n_1 n_2} 40e-9 10e6 m
    Wn {n_1 n_2} 40e-9 10e6 m
    Ls {p_ref p_tail n_out} 40e-9 10e6 m
    Ws {p_ref p_tail n_out} 40e-9 10e6 m
    Lo p_out 40e-9 10e6 m
    Wo p_out 40e-9 10e6 m
    iref cbias 0 100e-6 A
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
