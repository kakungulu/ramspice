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
foreach dev {nch pch} dtox {2.7e-10 3.91e-10} toxe {2.47e-9 2.71e-9} {
    set toxp [expr $dtox-$toxe]
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
@ op_iterations = 5
@ param:pos = 0.55
@ param:neg = 0.55
@ param:iref = 2e-6
@ tail:V = 0.55
@ outp:V = 0.55
@ bias:V = 0.55
@ outm:V = 0.55
@ size:Wp = 1
@ size:Lp = 1e-6
@ size:Wn = 1
@ size:Ln = 1e-6
@ size:Wn = 1
@ size:Ln = 1e-6
@ inm:V = 0.55
@ inp:V = 0.55
@ vdd:V = 1.1
Derror: ignore above errors
load /libOp_diffpair_nmos.so
::C::Op_diffpair
@ / foreach_child c {
    skip {![@ $c:V ?]}
    Info: $c=[@ $c:V]
}
exit
