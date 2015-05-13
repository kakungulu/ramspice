# \
exec $RAMSPICE/ramspice $0 $argv


get_opts
default ::opt(interpolation) LUT
default ::opt(process) ss
default ::opt(device) nch
default ::opt(tech) tsmc018
default ::opt(topv) 1.8
default ::opt(l) 360e-9
default ::opt(w) 360e-9
default ::opt(vgs) 1.0
default ::opt(vbs) 0.0
default ::opt(r) 1e3
default ::opt(limit) 10
default ::opt(np) 1

array set ::corner_to_temp {
    ss 125
    tt 27
    ff -40
    fs 27
    sf 27
    mc 27
}
foreach dev {nch pch} {
    @ /look_up_tables/$dev !
    foreach param {ids gm ro} {
        @ /look_up_tables/$dev load $::opt(source)/$::opt(tech)_${dev}_${param}.db
    }
}

set resI 1.0
@ Vds = real $::opt(topv)
@ meanVds = real $::opt(topv)
@ R = real $::opt(r)
foreach var {L W Vbs Vgs} switch {l w vbs vgs} {
    @ $var !
    @ $var = real $::opt($switch)
} 
@ Wp = real [expr $::opt(w)*$::opt(np)]
@ minVds = real 0
@ maxVds = real $::opt(topv)
..init
.function parallel(x,y)=x*y/(x+y)
@ Ids1 = real 2
@ Ids2 = real 1

set unknown {
    if {[regexp {^[mM](\S+)\s+(.*)$} $args -> name arguments]} {
        eval "add_transistor $name $arguments"
        return
    }
}
append unknown [info body unknown]
proc unknown args $unknown
set ::all_transistors {}
proc add_transistor {name d g s b type args} {
    lappend ::all_transistors $name
    set ::transistors($name,connectivity) trivial
    if {$d==$g} {
        set ::transistors($name,connectivity) diode
    }
    foreach field {d g s b type} {
        set ::transistors($name,$field) [set $field]
    }
}

.procedure operating_point {
    .for {i=0} {i<$::opt(limit) && abs(Ids1-Ids2)>1e-9} {i=i+1} {
        foreach name $::all_transistors {
	    foreach field {type L W d g s b} {
	        set $field $::transistors($name,$field)
	    }
	    if {$::transistors($name,connectivity)=="diode"} {
	        if {$::transistors($name,type)=="nch"} {
		    $name/Ids=interpolate($L,$d,meanVds,Vgs,&{/look_up_tables/$::transistors($name,type)/Ids/$::opt(process)})*($::transistors($name,W)/L)
		} else {
		}
	    } else {
	    }
	}
        meanVds=(minVds+maxVds)/2
        Ids1=interpolate(L,0,meanVds,Vgs,&{/look_up_tables/nch/Ids/$::opt(process)})*(W/L)
        ro1=interpolate(L,0,meanVds,Vgs,&{/look_up_tables/nch/ro/$::opt(process)})*(L/W)
        gm=interpolate(L,0,meanVds,Vgs,&{/look_up_tables/nch/gm/$::opt(process)})*(W/L)
        Ids2=interpolate(L,0,meanVds-$::opt(topv),meanVds-$::opt(topv),&{/look_up_tables/pch/Ids/$::opt(process)})*(Wp/L)
        gm2_1=1/interpolate(L,0,meanVds-$::opt(topv),meanVds-$::opt(topv),&{/look_up_tables/pch/ro/$::opt(process)})*(L/Wp)
        gm2_2=interpolate(L,0,meanVds-$::opt(topv),meanVds-$::opt(topv),&{/look_up_tables/pch/gm/$::opt(process)})*(Wp/L)
	ro2=1/sqrt(gm2_1*gm2_1+gm2_2*gm2_2)
        ro=parallel(ro1,ro2)
        Adc=20*log10(gm*ro)
        .if {Ids2>Ids1} {
            minVds=meanVds
        } else {
            maxVds=meanVds
        }
    }
}
operating_point
Info: Converged after [@ i] iterations: Vds=[eng [@ meanVds] V] Ids1=[eng [@ Ids1] A] Ids2=[eng [@ Ids2] A] gm=[eng [@ gm] Mho] ro=[@ ro1]||[@ ro2]=[eng [@ ro] Ohm] Adc=[eng [@ Adc] dB]
exit

