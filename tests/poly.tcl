# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
source $::env(RAMSPICE)/Sizer/polynomials.tcl
source $::env(RAMSPICE)/Sizer/derivatives.tcl
source $::env(RAMSPICE)/Sizer/matrices.tcl


set M(dim) 2
set M(0,0) a+b
set M(0,1) b+c
set M(1,0) c+d
set M(1,1) d+a
detp M p
Info: [present_poly p]
exit



