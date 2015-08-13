set title "Differential Pair with Output Stage"
set input_type NMOS

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
set ::topologies($name,schematic) {
    NewFormat	
    blank		blank			vdd(vdd)		blank				vdd(vdd)			blank			blank		vdd(vdd)					nl
    blank		blank			pmos(p_1)/fr		twire(outm)			pmos(p_2)/rrr			corner(midoutp)/r	line(midoutp)/r	pmos(p_out)/rrr					nl
    vdd(vdd)		blank			twire(outm)/rrr		corner(outm)/rrr		twire(midoutp)/rrr		twire(midoutp)/rr	cap(midoutp)/r	crosswireconn(outp)/rrr	terminal(outp)/r	nl
    csrc(vbias)/rr	terminal(inp)/rrr	nmos(nin_1)/frrr	blank	nmos(nin_2)/r		terminal(inn)/r			blank			line(outp)							nl
    twire(vbias)/rrr	corner(vbias)/rr	corner(tail)		twire(tail)			corner(tail)/rrr		blank			blank		line(outp)					nl
    nmos(n_ref)/r	twire(vbias)/rr		line(vbias)/r		nmos_linethrough(n_tail)/frrr	line(vbias)/r			line(vbias)/r		line(vbias)/r	nmos(n_out)/frrr				nl
    gnd			blank			blank			gnd				blank				blank			blank		gnd
    end
}
