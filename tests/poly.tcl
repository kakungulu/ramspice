# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
source $::env(RAMSPICE)/Sizer/polynomials.tcl
source $::env(RAMSPICE)/Sizer/derivatives.tcl
source $::env(RAMSPICE)/Sizer/matrices.tcl

set M(dim) 3
set M(0,0) 1
set M(1,1) 1
set M(2,2) 1
array unset M 

set M(dim) 2
set M(0,0) a
set M(0,1) b
set M(1,0) c
set M(1,1) d
array unset M 
set M(dim) 4
for {set i 0} {$i<$M(dim)} {incr i} {
    for {set j 0} {$j<$M(dim)} {incr j} {
        set M($i,$j) [expr int(10*rand())]
    }
}
mat_print M
pseudo_inv M N
mat_print N
mat_mult M N I
mat_print I
exit



