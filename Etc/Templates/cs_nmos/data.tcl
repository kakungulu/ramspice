set title "Common Source"
set input_type NMOS

#    Name Name (optional) {} {} {}
define_properties {
    Adc A<sub>DC</sub> dB 0 1000 1
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
    L n 40e-9 10e6 m
    W n 40e-9 10e6 m
    iref cbias 0 100e-6 A
}
set name [file tail [file dirname [info script]]]
set ::topologies($name,schematic) {
   blank 0 0 {}
   vdd 0 0 {}
   blank 0 0 {}
   nl 0 0 {}

   blank 0 0 {}
   twire 0 270 {}
   terminal 0 90 out
   nl 0 0 {}

   blank 0 0 {}
   csrc 0 180 {}
   blank 0 0 {}
   nl 0 0 {}

   terminal 0 270 in
   nmos 1 270 {}
   blank 0 0 {}
   nl 0 0 {}

   blank 0 0 {}
   gnd 0 0 {}
   blank 0 0 {}
   nl 0 0 {}
}
