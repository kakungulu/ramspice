* Effecting a Monte Carlo calculation in ngspice
.include ../tsmc018_from_cadence.lib
mn_0_0 3 3 0 0 nch_mis L=360e-9 W=360e-9  AD=8.1e-14 AS=8.1e-14 PD=1.08e-6 PS=1.08e-6
V1 3 0 AC 0 DC 1.8
.temp -40
*   'control' style Monte-Carlo that was replaced with C-coded function:
* .control
*   let mc_runs = 1
*   let run = 0
*   let res=unitvec(mc_runs)
* * define distributions for random numbers:
* * unif: uniform distribution, deviation relativ to nominal value
* * aunif: uniform distribution, deviation absolut
* * gauss: Gaussian distribution, deviation relativ to nominal value
* * agauss: Gaussian distribution, deviation absolut
* * limit: if unif. distributed value >=0 then add +avar to nom, else -avar
*   define unif(nom, rvar) (nom + (nom*rvar) * sunif(0))
*   define aunif(nom, avar) (nom + avar * sunif(0))
*   define gauss(nom, rvar, sig) (nom + (nom*rvar)/sig * sgauss(0))
*   define agauss(nom, avar, sig) (nom + avar/sig * sgauss(0))
* * define limit(nom, avar) (nom + ((sgauss(0) ge 0) ? avar : -avar))
*   define limit(nom, avar) (nom + ((sgauss(0) >= 0) ? avar : -avar))
* *
* *
*   dowhile run < mc_runs $ loop starts here
* *    alter mn_0_0 l = gauss(3.6e-7, 3.6e-7 , 0.00001)
*     op 
*     let res[run]=V(ntest)*1e6 $ store bw to vector res in plot 'scratch'
*     set run ="$&run" $ create a variable from the vector
*     let run = run + 1
*   end $ loop ends here
* .endc

.end
