array set ::bin {p,5,wmin 1.2e-6 n,2,lmin 1.2e-6 p,15,wmin 2.2e-7 p,7,lmax 1.2e-6 n,15,wmax 5e-7 p,5,wmax 1e-5 n,2,lmax 1e-5 p,15,wmax 5e-7 n,14,lmin 1.2e-6 p,4,lmin 1.8e-7 n,12,wmin 5e-7 p,14,lmin 1.2e-6 p,2,wmin 1e-5 n,14,lmax 1e-5 p,12,wmin 5e-7 p,4,lmax 5e-7 n,12,wmax 1.2e-6 p,14,lmax 1e-5 p,2,wmax 0.000900001 p,12,wmax 1.2e-6 n,11,lmin 5e-7 p,1,lmin 1e-5 n,8,wmin 1.2e-6 p,11,lmin 5e-7 n,11,lmax 1.2e-6 p,1,lmax 2.0001e-5 n,8,wmax 1e-5 p,11,lmax 1.2e-6 n,7,lmin 5e-7 n,5,wmin 1.2e-6 n,7,lmax 1.2e-6 n,5,wmax 1e-5 p,9,lmin 1e-5 p,7,wmin 1.2e-6 n,4,lmin 1.8e-7 p,9,lmax 2.0001e-5 n,2,wmin 1e-5 p,7,wmax 1e-5 n,4,lmax 5e-7 n,16,lmin 1.8e-7 n,2,wmax 0.000900001 p,6,lmin 1.2e-6 n,14,wmin 2.2e-7 p,16,lmin 1.8e-7 p,4,wmin 1e-5 n,16,lmax 5e-7 n,1,lmin 1e-5 p,14,wmin 2.2e-7 p,6,lmax 1e-5 n,14,wmax 5e-7 p,16,lmax 5e-7 p,4,wmax 0.000900001 n,1,lmax 2.0001e-5 p,14,wmax 5e-7 n,13,lmin 1e-5 p,3,lmin 5e-7 n,11,wmin 5e-7 p,13,lmin 1e-5 p,1,wmin 1e-5 n,13,lmax 2.0001e-5 p,11,wmin 5e-7 p,3,lmax 1.2e-6 n,11,wmax 1.2e-6 p,13,lmax 2.0001e-5 p,1,wmax 0.000900001 p,11,wmax 1.2e-6 n,9,lmin 1e-5 n,10,lmin 1.2e-6 n,7,wmin 1.2e-6 p,10,lmin 1.2e-6 n,9,lmax 2.0001e-5 n,10,lmax 1e-5 n,7,wmax 1e-5 p,10,lmax 1e-5 p,9,wmin 5e-7 n,6,lmin 1.2e-6 n,4,wmin 1e-5 p,9,wmax 1.2e-6 n,6,lmax 1e-5 n,4,wmax 0.000900001 p,8,lmin 1.8e-7 n,16,wmin 2.2e-7 p,6,wmin 1.2e-6 n,3,lmin 5e-7 p,16,wmin 2.2e-7 p,8,lmax 5e-7 n,16,wmax 5e-7 n,1,wmin 1e-5 p,6,wmax 1e-5 n,3,lmax 1.2e-6 p,16,wmax 5e-7 n,15,lmin 5e-7 n,1,wmax 0.000900001 p,5,lmin 1e-5 n,13,wmin 2.2e-7 p,15,lmin 5e-7 p,3,wmin 1e-5 n,15,lmax 1.2e-6 p,13,wmin 2.2e-7 p,5,lmax 2.0001e-5 n,13,wmax 5e-7 p,15,lmax 1.2e-6 p,3,wmax 0.000900001 p,13,wmax 5e-7 n,12,lmin 1.8e-7 p,2,lmin 1.2e-6 n,9,wmin 5e-7 n,10,wmin 5e-7 p,12,lmin 1.8e-7 n,12,lmax 5e-7 p,10,wmin 5e-7 p,2,lmax 1e-5 n,9,wmax 1.2e-6 n,10,wmax 1.2e-6 p,12,lmax 5e-7 p,10,wmax 1.2e-6 n,8,lmin 1.8e-7 n,6,wmin 1.2e-6 n,8,lmax 5e-7 n,6,wmax 1e-5 p,8,wmin 1.2e-6 n,5,lmin 1e-5 n,3,wmin 1e-5 p,8,wmax 1e-5 n,5,lmax 2.0001e-5 n,3,wmax 0.000900001 p,7,lmin 5e-7 n,15,wmin 2.2e-7}
set ::global_nlmin 1.8e-7
set ::global_nlmax 2.0001e-5
set ::global_nwmin 2.2e-7
set ::global_nwmax 0.000900001
set ::global_plmin 1.8e-7
set ::global_plmax 2.0001e-5
set ::global_pwmin 2.2e-7
set ::global_pwmax 0.000900001
set ::bsim_version 3v32
set lvalues {}
set wvalues {}
foreach key [array names ::bin n,*,lmin] {
    if {[lsearch $lvalues $::bin($key)]==-1} {
        lappend lvalues $::bin($key)
    }
}
foreach key [array names ::bin n,*,lmax] {
    if {[lsearch $lvalues $::bin($key)]==-1} {
        lappend lvalues $::bin($key)
    }
}
set wvalues {}
foreach key [array names ::bin n,*,wmin] {
    if {[lsearch $wvalues $::bin($key)]==-1} {
        lappend wvalues $::bin($key)
    }
}
foreach key [array names ::bin n,*,lmax] {
    if {[lsearch $wvalues $::bin($key)]==-1} {
        lappend wvalues $::bin($key)
    }
}
default opt(topv) 1.8

