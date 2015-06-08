# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
default ::opt(interpolation) LUT
default ::opt(process) ss
default ::opt(device) nch
default ::opt(tech) tsmc040
default ::opt(topv) 1.1
default ::opt(l) 360e-9
default ::opt(w) 360e-9
default ::opt(vgs) 1.0
default ::opt(vbs) 0.0
default ::opt(r) 50
default ::opt(ref) 100e-6
default ::opt(op_limit) 2
default ::opt(step_limit) 1000
default ::opt(step_count) 10
default ::opt(np) 1
default ::opt(mode) dc
set ::opt(mode) [string tolower $::opt(mode)]
default EPS0 8.85418e-12
default ::opt(epsrox) 3.9
default ::opt(source) Etc/Tech_DB/tsmc040/4d/5:5:3:6/

@ / load Etc/Templates/Op_diffpair_nmos/diffpair_nmos.db

foreach dev {nch pch} dtox {2.7e-10 3.91e-10} toxe {2.47e-9 2.71e-9} {
    set toxp [expr $toxe-$dtox]
    @ /look_up_tables/$dev/cox = [expr $::opt(epsrox)*$EPS0/$toxp]
    @ /look_up_tables/$dev !
    foreach param {ids gm ro} {
        @ /look_up_tables/$dev load $::opt(source)/$::opt(tech)_${dev}_${param}.db
    }
    @ /look_up_tables/$dev/thermal_noise/ !
    @ /look_up_tables/$dev/flicker_noise/ !
    @ /look_up_tables/$dev/thermal_noise/ load $::opt(source)/$::opt(tech)_${dev}_ss_thermal_noise.db
    @ /look_up_tables/$dev/flicker_noise/ load $::opt(source)/$::opt(tech)_${dev}_ss_flicker_noise.db
}
foreach {p unit formula} {
    Adc    dB 20*log10(abs(@))
    CMRR    dB 20*log10(abs(@))
    PSRR    dB 20*log10(abs(@))
    Zout    Ohm @
    BW    Hz @
    ts    sec @
    Nt    V^2/Hz @
    Nf    V^2/Hz @
    fc     Hz @
} {
    @ property/$p = 0
    @ property/$p/unit = string $unit
    @ property/$p/formula = string $formula
    foreach sizer {p n s} {
        foreach dim {L W} {
            @ property/$p/$dim$sizer = 0
        }
    }
}
@ p1 = 0
@ p2 = 0

@ op_iterations = 10
@ param:rload = 1e7
@ param:pos = 0.55
@ param:neg = 0.55
@ param:iref = 50e-6
@ param:vdd = 1.1
@ tail:V = 0.55
@ outp:V = 0.55
@ outm:V = 0.55
@ vbias:V = 0.55
@ size:Wp = 1e-6
@ size:Lp = 1e-6
@ size:Wn = 1e-6
@ size:Ln = 1e-6
@ size:Ws = 1e-6
@ size:Ls = 1e-6
@ inn:V = 0.55
@ inp:V = 0.55
@ vdd:V = 1.1
Derror: ignore above errors
load $::env(RAMSPICE)/Etc/Templates/Op_diffpair_nmos/libOp_diffpair_nmos.so
::C::Op_diffpair_nmos
@ / foreach_child c {
    skip {![@ $c:V ?]}
    skip {$c=="0"}
    Info: $c=[@ $c:V]
}
Info: p1=[eng [@ p1] rad/sec] p2=[eng [@ p2] rad/sec]
@ property foreach_child p {
    Info: $p=[eng [expr [regsub -all @ [@ property:$p/formula] [@ property:$p]]] [@ property:$p/unit]]
}

set list [@ property/$p]
@ property foreach_child p {
    foreach sizer {p n s} {
        foreach dim {L W} {
            skip {![@ property/$p/$dim$sizer ?]}
            Info: d$p/d$dim$sizer=[eng [@ property:$p:$dim$sizer] [@ property:$p/unit]/m]
        }    
    }
}
set p Adc
set entry [@ property/$p]
@ size foreach_child s {
    lappend entry [eng [@ size/$s] m]
    lappend entry [eng [@ property/$p/$s] [@ property:$p/unit]/m]
}
set list $entry    
for {set i 0} {$i<40} {incr i} {
    @ size foreach_child s {
        @ size/$s = [expr [@ size/$s]-1e-16*[@ property/$p/$s]]
    }
    ::C::Op_diffpair_nmos
    set entry [@ property/$p]
    @ size foreach_child s {
        lappend entry [eng [@ size/$s] m]
        lappend entry [eng [@ property/$p/$s] [@ property:$p/unit]/m]
    }
    lappend list $entry    
}
Info: list=[join $list \n]
exit
