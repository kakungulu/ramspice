set title "Single Reference Instrumentation Operational Amplifier"
set input_type NMOS/PMOS

define_properties {
    Adc A<sub>DC</sub> dB 0 1000 1
    CMRR CMRR dB 0 1000 1
    PSRR PSRR dB 0 1000 1
    Vos V<sub>OS</sub> V 0 1 -0.001
    Rout R<sub>OUT</sub> &#8486\; 0 1e12 -1
    BW BW Hz 0 1e12 1
    PM PM deg 0 360 1
    Cin C<sub>in</sub> F 0 1e-3 -1
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
    Iref {} 1e-6 2e-5 A
}
set name [file tail [file dirname [info script]]]
set ::topologies(op_amp_inst,schematic) {
NewFormat	
vdd		blank			blank		blank		vdd			blank		blank		blank		blank	blank	vdd		blank			vdd			blank		blank		vdd 	    nl  		    
pmos/fr		twire			line/r			line/r		pmos/rrr	blank		blank		blank		blank	blank	pmos/fr		line/r			pmos_linethrough/fr	twire		line/r		pmos/rrr	    nl
twire/rrr	corner/rrr		blank			corner/r	twire/rr	corner/rr	blank		blank		blank	blank	line		terminal(C)/rrr		twire/r			line		terminal(D)/rrr	twire/r	    nl
line		blank			corner/r		pmos/rrr	blank		pmos/fr		corner/rr	blank		blank	blank	pmos/fr		twire			pmos_linethrough/fr     crosswire	line/r		pmos/rrr	    nl
line		blank			line			terminal(A)/rr	blank		terminal(B)/rr	line		blank		blank	blank	twire/rrr	corner/rrr		twire/rrr		corner/rrr	blank		line	    nl
line		blank			line			blank		blank		blank		line		blank		blank	blank	line		blank			line			blank		blank		line	    nl
csrc/rr		terminal(inn)/rrr	twire/r 		blank		blank		blank		twire/rrr	terminal(inp)/r	blank	blank	csrc/rr		blank			line			blank		blank		twire/rrr	    terminal(outp)/r			    nl
line		blank			line			blank		blank		blank		line		blank		blank	blank	line		blank			line			blank		blank		line		    nl
line		blank			line			terminal(C)	blank		terminal(D)	line		blank		blank	blank	twire/rrr	corner/rr		twire/rrr		corner/rr	blank		line	    nl
line		blank			corner  		nmos/frrr	blank		nmos/r		corner/rrr	blank		blank	blank	nmos/r		twire/rr		nmos_linethrough/r      crosswire	line/r		nmos/frrr	    nl
twire/rrr	corner/rr		blank			corner		twire		corner/rrr	blank		blank		blank	blank	line		terminal(A)/rrr		twire/r			line		terminal(B)/rrr	twire/r	    nl
nmos/r		twire/rr		line/r			line/r		nmos/frrr	blank		blank		blank		blank	blank	nmos/r		line/r			nmos_linethrough/r			twire/rr	line/r		nmos/frrr	    nl
gnd		blank			blank			blank		gnd		blank		blank		blank		blank	blank	gnd		blank			gnd			blank		blank		gnd 	    nl
end
}
