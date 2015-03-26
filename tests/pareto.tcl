# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
@ / load pareto.db
Info: Properties=[@ pareto PAT properties]
Info: Sizes=[@ pareto PAT sizes]
Info: margins=[@ pareto PAT margins]
for {set i 0} {$i<[@ pareto PAT size]} {incr i} {
    Info: $i=[@ pareto PAT index $i]
}
exit

@ pareto((ehad,shtayim,shalosh|Abra?1.1,Cadabra,Hocus?1.1,Pocus?1.1)) !
Info: [@ pareto <<< {1 2 3} {4 5 NAN 6}]
Info: [@ pareto <<< {1 2 3} {1 7 NAN 4}]
Info: [@ pareto <<< {1 2 3} {5 6 NAN 7}]
# Info: [@ pareto <<< {1 2 3} {8 7 NAN 9}]
for {set i 0} {$i<[@ pareto PAT size]} {incr i} {
    Info: $i=[@ pareto PAT entry $i]
}
@ / save pareto.db
exit
