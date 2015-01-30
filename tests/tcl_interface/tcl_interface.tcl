.circuit: Using Tcl as Spice Language Front End

.macro stage: args {
    Info: $args
    ::spice::dc v1 0 1 0.5
    i=0
    .repeat [::spice::get_spice_data V(1) length] {
        puts "$i) [::spice::get_spice_data V(1) $i]"
	i=$i+1
    }
}

v1 2 0 1
r1 1 2 100
.stage: Initial circuit

r11 1 4 5000
r12 4 0 5000
.stage: Adding resistors

r2 1 0 500
.stage: Another resistor

R=10
.repeat 4 {
    r2 resistance $R
    R=$R*10
    .stage: Modified resistor=$R
}

c1 1 0 1e-12
.stage: And a capacitor

