set title "Differential Pair with Output Stage"
set input_type NMOS

define_properties {
    Name Name (optional) {} {} {}
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
set name [file tail [file dirname [info script]]]
set ::topologies($name,schematic) {
    blank 0 0 {}
    blank 0 0 {}
    vdd   0 0 vdd
    blank 0 0 {}
    vdd   0 0 vdd
    blank 0 0 {}
    blank 0 0 {}
    vdd   0 0 vdd
    nl 0 0 {}
    
    blank 0 0 {}
    blank 0 0 {}
    pmos 1 90 p_1
    twire 0 0 outm
    pmos 0 270 p_2
    corner 0 90 midoutp
    line 0 90 midoutp
    pmos 0 270 p_out
    nl 0 0 {}
    
    vdd 0 0 vdd
    blank 0 0 {}
    twire 0 270 outm
    corner 0 270 outm
    twire 0 270 midoutp
    twire 0 180 midoutp
    cap  0 90 midoutp
    crosswireconn 0 270 outp
    terminal 0 90 outp
    nl 0 0 {}
    
    csrc 0 180 vbias
    terminal 0 270 inp
    nmos 1 270 nin_1
    blank 0 0 {}
    nmos 0 90 nin_2
    terminal 0 90 inn
    blank 0 0 {}
    line 0 0 outp
    nl 0 0 {}
    
    twire 0 270 vbias
    corner 0 180 vbias
    corner 0 0 tail
    twire 0 0 tail
    corner 0 270 tail
    blank 0 0 {}
    blank 0 0 {}
    line 0 0 outp
    nl 0 0 {}
    
    nmos 0 90 n_ref
    twire 0 180 vbias
    line 0 90 vbias
    nmos_linethrough 1 270 n_tail
    line 0 90 vbias
    line 0 90 vbias
    line 0 90 vbias
    nmos 1 270 n_out
    nl 0 0 {}
    
    gnd  0 0 {}
    blank  0 0 {}
    blank  0 0 {}
    gnd  0 0 {}
    blank  0 0 {}
    blank  0 0 {}	
    blank  0 0 {}	
    gnd  0 0 {}
}
