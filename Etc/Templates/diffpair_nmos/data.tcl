set title "Differential Pair"
set input_type NMOS

define_properties {
    Adc A<sub>DC</sub> dB 0 1000 1
    CMRR CMRR dB 0 1000 1
    PSRR PSRR dB 0 1000 1
    Vos V<sub>OS</sub> V 0 1 0.001
    Rout R<sub>OUT</sub> &#8486\; 0 1e12 1
    BW BW Hz 0 1e12 1
    ts t<sub>S</sub> sec 0 1 1e-9
    Nt N<sub>T</sub> A<sup>2</sup>/Hz 0 1 1e-17
    fc f<sub>corner</sub> Hz 0 1e9 1
    Area Area (&#956\;m)<sup>2</sup> 0 1e9 1
    Power Power W 0 1000 1
}
define_sizers {
    Lp {p_1 p_2} 40e-9 10e6 m
    Wp {p_1 p_2} 40e-9 10e6 m
    Ln {n_1 n_2} 40e-9 10e6 m
    Wn {n_1 n_2} 40e-9 10e6 m
    Ls {n_ref n_tail} 40e-9 10e6 m
    Ws {n_ref n_tail} 40e-9 10e6 m
    iref cbias 0 100e-6 A
}
set name [file tail [file dirname [info script]]]
set ::topologies($name,schematic) {
    blank 0 0 {}
    blank 0 0 {}
    vdd   0 0 vdd
    blank 0 0 {}
    vdd   0 0 vdd
    blank 0 0 {}
    nl 0 0 {}
    
    blank 0 0 {}
    blank 0 0 {}
    pmos 1 90 p_1
    twire 0 0 outm
    pmos 0 270 p_2
    blank 0 0 {}
    nl 0 0 {}
    
    vdd 0 0 vdd
    blank 0 0 {}
    twire 0 270 outm
    corner 0 270 outm
    twire 0 270 outp
    terminal 0 90 outp
    nl 0 0 {}
    
    csrc 0 180 vbias
    terminal 0 270 inp
    nmos 1 270 nin_1
    blank 0 0 {}
    nmos 0 90 nin_2
    terminal 0 90 inn
    nl 0 0 {}
    
    twire 0 270 vbias
    corner 0 180 vbias
    corner 0 0 tail
    twire 0 0 tail
    corner 0 270 tail
    blank 0 0 {}
    nl 0 0 {}
    
    nmos 0 90 n_ref
    twire 0 180 vbias
    line 0 90 vbias
    nmos 1 270 n_tail
    blank  0 0 {}
    blank  0 0 {}
    nl 0 0 {}
    
    gnd  0 0 {}
    blank  0 0 {}
    blank  0 0 {}
    gnd  0 0 {}
    blank  0 0 {}
    blank  0 0 {}	
}
