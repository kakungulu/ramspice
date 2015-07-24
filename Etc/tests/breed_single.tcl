# \
exec $RAMSPICE/ramspice $0 $argv
@ / load Etc/Templates/diffpair_nmos/pareto_bi.db
set ::opt(topology) diffpair_nmos
load $::env(RAMSPICE)/Etc/Templates/$::opt(topology)/libGamma.so
Info: before=[@ diffpair_nmos/circuits PAT size]
@ circuit_breed_id = 258729
::C::import
::C::random_breed_single
Info: after=[@ diffpair_nmos/circuits PAT size]

exit
