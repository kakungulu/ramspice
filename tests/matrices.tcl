# \
exec $RAMSPICE/ramspice $0 $argv
get_opts

source $::env(RAMSPICE)/Sizer/matrices.tcl

array set M {
    dim 3
    0,0 A
    0,1 -1
    0,2 -1
    1,0 -1
    1,1 1
    1,2 -1
    2,0 -1
    2,1 -1
    2,2 1
}

array set N {
    dim 2
    0,0 (g1+g2)
    0,1 (-g2)
    1,0 (-g2)
    1,1 (g3+g2)
}
set y {g1Vdd 0}
Ax_y N x $y
report_vars x
Info: [info script]
exit
