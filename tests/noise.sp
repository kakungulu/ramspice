* Effecting a Monte Carlo calculation in ngspice
.include ../tsmc018_from_cadence.lib
mn_0_0 3 2 0 1 nch_tt L=360e-9 W=360e-9  AD=8.1e-14 AS=8.1e-14 PD=1.08e-6 PS=1.08e-6
Vds 3_1 0 AC 0 DC 1.8
Vgs 2 0 AC 0 DC 1.8
Vbs 1 0 AC 0 DC 0
rtest 3_1 3 1e-12
.temp 27
.end
