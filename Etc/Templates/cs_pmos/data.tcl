set title "Common Source"
set input_type PMOS

define_properties {
    Name Name (optional) {} {} {}
    Adc A<sub>DC</sub> dB 0 1000 1
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
    vdd 0 0 vdd
    blank 0 0 {}
    nl 0 0 {}
    
    terminal 0 270 in
    pmos 0 270 p_ref
    blank 0 0 {}
    nl 0 0 {}
    
    blank 0 0 {}
    twire 0 270 out
    terminal 0 90 out
    nl 0 0 {}
    
    blank 0 0 {}
    csrc 0 180 out
    blank 0 0 {}
    nl 0 0 {}
    
    blank 0 0 {}
    gnd 0 0 {}
    blank 0 0 {}
}
