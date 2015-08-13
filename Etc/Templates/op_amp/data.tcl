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
set ::topologies(diffpair_output_nmos,schematic) {
NewFormat	
vdd	       	blank		blank		vdd	       	blank		blank			blank			blank			vdd			blank	      blank	    blank		blank		  blank 	    blank	    blank	    	vdd 		    blank		    blank	    vdd 	    nl  		    
pmos/fr	       	twire		terminal(Vn)/r 	pmos/fr	       	twire		line/r  		line/r  		line/r  		pmos/rrr		blank	      blank	    blank		blank		  blank 	    blank	    blank	    	pmos/fr		    twire		    line/r	    pmos/rrr	    nl
twire/rrr      	corner/rrr	blank		twire/rrr      	corner/rrr	blank			blank			corner/r		twire/rr		corner/rr     blank	    blank		blank		  blank 	    corner/r	    line/r	    	twire/r		    line		    corner/r	    twire/r	    nl
line	       	blank		blank		line	       	blank		blank			corner/r		pmos/rrr		blank			pmos/fr       corner/rr     blank		blank		  blank 	    line	    terminal(Vp)/rrr    pmos_linethrough/fr     crosswire		    crosswire	    pmos/rrr	    nl
line		blank		blank		line		blank		blank			line			line			blank			corner        crosswire     line/r		corner/rr	  blank 	    line	    blank	    	twire/rrr		    double_corner/rrr	    corner/rrr      line	    nl
line	       	blank		blank		line	       	blank		blank			line			corner  		line/r  		line/r        crosswire     line/r		double_corner/rr  cross_corner/rrr  double_corner/r line/r	    	crosswire		    corner/rrr  	    blank	    line	    nl
line		blank		blank		line		blank		terminal(inn)/rrr	twire/r 		blank			blank			blank	      twire/rrr     terminal(inp)/r	cross_corner/rr   quad_corner/rr    cross_corner    blank	    	line		    blank		    blank	    twire/rrr	    terminal(outp)/r			    nl
line	       	blank		blank		line	       	blank		blank			line			corner/r		line/r  		line/r        crosswire     line/r		double_corner/rrr cross_corner/r    double_corner   line/r	    	crosswire		    corner/rr		    blank	    line		    nl
twire/rrr      	corner/rr	blank		twire/rrr      	corner/rr	blank			line			line			blank			corner/r      crosswire     line/r		corner/rrr	  blank 	    line	    blank	    	twire/rrr		    double_corner/rr	    corner/rr	    line	    nl
nmos/r	       	corner/rrr 	blank		nmos/r	       	corner/rrr 	blank			corner  		nmos/frrr		blank			nmos/r        corner/rrr    blank		blank		  blank 	    line	    terminal(Vn)/rrr    nmos_linethrough/r      crosswire		    crosswire	    nmos/frrr	    nl
twire/rrr      	corner/rr	blank		twire/rrr      	corner/rr	blank			blank			corner  		twire			corner/rrr    blank	    blank		blank		  blank 	    corner	    line/r	    	twire/r		    line		    corner	    twire/r	    nl
nmos/r	       	twire/rr 	terminal(Vp)/r 	nmos/r	       	twire/rr 	line/r  		line/r  		line/r  		nmos/frrr		blank	      blank	    blank		blank		  blank 	    blank	    blank	    	nmos/r		    twire/rr		    line/r	    nmos/frrr	    nl
gnd	       	blank		blank		gnd	       	blank		blank			blank			blank			gnd			blank	      blank	    blank		blank		  blank 	    blank	    blank	    	gnd 		    blank		    blank	    gnd 	    nl
end
}
return
blank		vdd(vdd)		blank				vdd(vdd)			blank			blank		vdd(vdd)					nl
	blank		vdd(vdd)		blank				vdd(vdd)			blank			blank		vdd(vdd)					nl
blank		pmos(p_1)/fr		twire(outm)			pmos(p_2)/rrr			corner(midoutp)/r	line(midoutp)/r	pmos(p_out)/rrr					nl
	blank		twire(outm)/rrr		corner(outm)/rrr		twire(midoutp)/rrr		twire(midoutp)/rr	cap(midoutp)/r	crosswireconn(outp)/rrr	terminal(outp)/r	nl
blank		nmos(nin_1)/frrr	blank	nmos(nin_2)/r		terminal(inn)/r			blank			line(outp)							nl
	blank		corner(tail)		twire(tail)			corner(tail)/rrr		blank			blank		line(outp)					nl
blank		line(vbias)/r		nmos_linethrough(n_tail)/frrr	line(vbias)/r			line(vbias)/r		line(vbias)/r	nmos(n_out)/frrr				nl
	blank		blank			gnd				blank				blank			blank		gnd
blank		line(vbias)/r		nmos_linethrough(n_tail)/frrr	line(vbias)/r			line(vbias)/r		line(vbias)/r	nmos(n_out)/frrr				nl
	blank		blank			gnd				blank				blank			blank		gnd	nl
blank		blank			gnd				blank				blank			blank		gnd	nl
