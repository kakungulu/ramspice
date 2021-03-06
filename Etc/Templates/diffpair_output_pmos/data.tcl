set title "Differential Pair with Output Stage"
set input_type PMOS

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
    Lp {p_1 p_2} 40e-9 10e-6 m
    Wp {p_1 p_2} 40e-9 10e-6 m
    Ln {n_1 n_2} 40e-9 10e-6 m
    Wn {n_1 n_2} 40e-9 10e-6 m
    Ls {p_ref p_tail p_out} 40e-9 10e-6 m
    Ws {p_ref p_tail p_out} 40e-9 10e-6 m
    Lo n_out 40e-9 10e-6 m
    Wo n_out 40e-9 10e-6 m
    iref cbias 0 100e-6 A
}
set name [file tail [file dirname [info script]]]
set ::topologies($name,schematic) {
    vdd 0 0 vdd
    blank 0 0 {}
    blank 0 0 {}
    vdd 0 0 vdd
    blank 0 0 {}
    blank 0 0 {}
    blank 0 0 {}
    vdd 0 0 vdd
    nl 0 0 {}
    
    pmos 1 90 p_ref
    twire 0 0 bias
    line 0 90 bias
    pmos_linethrough 0 270 p_tail
    line 0 90 bias
    line 0 90 bias
    line 0 90 bias
    pmos 0 270 p_out
    nl 0 0 {}
    
    twire 0 270 bias
    corner 0 270 bias
    corner 0 90 tail
    twire 0 180 tail
    corner 0 180 tail
    blank 0 0 {}
    blank 0 0 {}
    line 0 0 outp
    nl 0 0 {}
    
    csrc 0 180 cbias
    terminal 0 270 inn
    pmos 0 270 pin_1
    blank 0 0 {}
    pmos 1 90 pin_2
    terminal 0 90 inp
    blank 0 0 {}
    line 0 0 outp
    nl 0 0 {}
    
    gnd 0 0 {}
    blank 0 0 {}
    twire 0 270 outm
    corner 0 180 outm
    twire 0 270 midoutp
    twire 0 0 midoutp
    cap 0 90 midoutp
    crosswireconn 0 270 outp
    terminal 0 90 outp
    nl 0 0 {}
    
    blank 0 0 {}
    blank 0 0 {}
    nmos 0 90 n_1
    twire 0 180 outm
    nmos 1 270 n_2
    corner 0 0 midoutp
    line 0 90 midoutp
    nmos 1 270 n_out
    nl 0 0 {}
    
    blank 0 0 {}
    blank 0 0 {}
    gnd 0 0 {}
    blank 0 0 {}
    gnd 0 0 {}
    blank 0 0 {}	
    blank 0 0 {}	
    gnd 0 0 {}
}
