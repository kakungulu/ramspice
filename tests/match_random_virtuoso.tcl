# \
exec $RAMSPICE/ramspice $0 $argv

get_opts
set refined_section $opt(section)
set directional_final_step_size 0.125
source random_$::opt(tech).csv
must ::opt(input) "-input not given. Please provide stimuli file"
array set ref_model {
 level 54
 eta0   -0.25440451
 etab   -0.81370191
 scref   1e-6
 lku0we   2.5e-11
 pigcd   2.621
 epsrox   3.9
 aigsd   0.010772817
 njtsswg   9
 lvoff   -6.3267068e-9
 rdsmod   0
 xtsswgd   0.18
 xtsswgs   0.18
 wvfbsdoff   0
 lvfbsdoff   0
 igbmod   1
 lvsat   -0.0013704545999999999
 ckappad   0.6
 ckappas   0.6
 lvth0   3.9667989999999906e-10
 pdiblc1   0
 pdiblc2   0.0069718933
 pscbe1   1000000000.0
 pscbe2   1e-20
 pdiblcb   -0.3
 delta   0.007595625
 laigc   9.707156e-12
 pbswgd   0.95
 pbswgs   0.95
 rnoia   0
 rnoib   0
 igcmod   1
 pketa   -6.053668000000001e-15
 ngate   8e20
 ngcon   1
 wpclm   1.6305740000000013e-7
 bigbacc   0.002588
 gbmin   1e-12
 jswgd   1.28e-13
 jswgs   1.28e-13
 kvth0we   0.00018
 paigsd   -1.2154906e-23
 lintnoi   -1.5e-8
 bigbinv   0.004953
 vtsswgd   4.2
 vtsswgs   4.2
 ijthsfwd   0.01
 permod   1
 keta   -0.59506219
 ijthsrev   0.01
 jswd   1.28e-13
 jsws   1.28e-13
 lcit   3.03749e-10
 tvoff   0.0034020192
 kt1l   0
 voffcv   -0.16942
 wpemod   1
 xjbvd   1
 xjbvs   1
 lk2we   -1.5e-12
 lint   0
 lkt1   -1.8529946e-8
 lkt2   1.0897551e-9
 lmax   4.5e-8
 lmin   3.6e-8
 ku0we   -0.0007
 nfactor   1
 lpe0   9.2e-8
 lpeb   2.5e-7
 beta0   13
 leta0   2.4927632200000002e-8
 letab   2.5974719e-8
 minv   -0.3
 lua1   7.6118385e-17
 lub1   -1.2790425e-25
 luc1   -3.7246243e-17
 ppclm   -8.780734400000002e-15
 ndep   1e18
 dlcig   2.5e-9
 lwlc   0
 tpbswg   0.0009
 bgidl   2320000000.0
 moin   5.1
 nigc   3.083
 nigbacc   10
 dmcgt   0
 pkvth0we   -1.3e-19
 noff   2.7195
 tcjsw   0.000357
 ptvoff   -5.392468e-18
 noia   3.11e42
 noib   1.22e22
 noic   45200000.0
 waigsd   3.1116181e-12
 nigbinv   10
 diomod   1
 ntox   1
 pcit   -3.4847791e-17
 vfbsdoff   0.02
 pclm   1.46768105
 bigsd   0.00125
 pditsd   0
 pditsl   0
 cjswgd   2.82e-10
 pku0we   -1.5e-18
 cjswgs   2.82e-10
 phin   0.15
 wvoff   6.255152000000001e-9
 paramchk   1
 pkt1   5.3710205e-15
 pkt2   -4.1883975e-17
 wvsat   -0.026256236
 wvth0   -1.0572559e-8
 fnoimod   1
 mjswgd   0.85
 mjswgs   0.85
 eigbinv   1.1
 waigc   7.6854687e-11
 tcjswg   0.001
 rbdb   50
 pua1   -2.7889543e-23
 prwb   0
 prwg   0
 pub1   4.5022459e-32
 puc1   1.2190153e-23
 rbpb   50
 rbpd   50
 rbps   50
 rbsb   50
 pvag   1.2
 pvfbsdoff   0
 lketa   1.80561909e-8
 ijthdfwd   0.01
 rdsw   100
 xpart   1
 egidl   0.29734
 cigbacc   0.32875
 ijthdrev   0.01
 fprout   300
 rshg   15.6
 xrcrg1   12
 xrcrg2   1
 tnoimod   0
 cigbinv   0.006
 wtvoff   7.822084e-11
 pvoff   -9.865003999999993e-17
 version   4.5
 capmod   2
 tnom   25
 cdscb   0
 cdscd   0
 tempmod   0
 toxe   2.43e-9
 toxm   2.43e-9
 pvsat   9.6591382e-10
 wku0we   2e-11
 lkvth0we   -2e-12
 wk2we   5e-12
 pvth0   4.698127899999999e-16
 drout   0.56
 mobmod   0
 wtvfbsdoff   0
 paigc   -2.6395467e-18
 aigbacc   0.02
 voffl   0
 acnqsmod   0
 ltvfbsdoff   0
 weta0   8.5615058e-8
 wetab   2.2270081e-8
 wags   1.3953333e-7
 lpclm   -1.8821805999999992e-8
 wcit   5.840239e-10
 rbodymod   0
 aigbinv   0.0163
 voff   -0.061499972999999986
 cgidl   0.22
 acde   0.4
 laigsd   4.4039511e-17
 vsat   153199.842
 wint   0
 vth0   0.36181767099999995
 wkt1   -1.2486137e-7
 wkt2   7.8385579e-10
 wmax   5.4e-7
 aigc   0.011053515
 wmin   2.7e-7
 pbswd   0.8
 pbsws   0.8
 ptvfbsdoff   0
 wpdiblc2   1.4081704e-10
 wua1   6.7078609e-16
 wub1   -1.1020589000000001e-24
 wuc1   -3.0000411e-16
 alpha0   2e-10
 alpha1   3.6
 poxedge   1
 bigc   0.001442
 pdits   0
 wwlc   0
 cigsd   0.069865
 dvt0w   0
 dvt1w   0
 dvt2w   0
 binunit   2
 cdsc   0
 cgbo   0
 cgdl   3.31989e-12
 cgdo   4.90562e-11
 xtid   3
 xtis   3
 ags   2.7444444
 cgsl   3.31989e-12
 pk2we   -1e-19
 cgso   4.90562e-11
 cigc   0.000625
 dvtp0   4e-7
 dvtp1   0.01
 a0   10.55945905
 a1   0
 a2   1
 b0   0
 b1   0
 at   101543.357
 cf   8.15e-11
 cjd   0.001357
 cit   -0.0019532508
 cjs   0.001357
 clc   1e-7
 ef   1.0
 k1   0.274
 cle   0.6
 k2   0.039127322
 k3   -1.8419
 em   1000000.0
 bvd   8.7
 bvs   8.7
 ll   0
 lw   0
 dlc   3.26497e-9
 u0   0.0080463574
 w0   0
 k3b   1.9326
 ua   -1.7148580999999998e-9
 ub   1.250859149999999e-18
 uc   5.4381728e-10
 ud   0
 wl   0
 wr   1
 xj   8.6e-8
 xl   4e-9
 dwb   0
 ww   0
 dwc   0
 dwg   0
 dwj   0
 xw   6e-9
 wkvth0we   2e-12
 tnoia   0
 toxref   3e-9
 peta0   -4.1184253e-15
 la0   -4.65319969e-7
 trnqsmod   0
 petab   -7.719916e-16
 jsd   6.11e-7
 jss   6.11e-7
 lat   -0.0014882648800000002
 kt1   0.12069622
 lk2   -4.2131932e-9
 kt2   -0.11741295
 wketa   1.87190595e-7
 llc   0
 lln   1
 lu0   1.1331622e-10
 mjd   0.26
 lua   1.6761980000000137e-18
 mjs   0.26
 lub   8.339062399999967e-27
 luc   -2.98810456e-17
 lud   0
 lwc   0
 lwl   0
 tpbsw   0.0019
 lwn   1
 njd   1.02
 njs   1.02
 pa0   9.065128000000001e-14
 dmcg   3.1e-8
 dmci   3.1e-8
 dmdg   0
 nsd   1e20
 pbd   0.52
 pat   -2.7208428e-10
 pbs   0.52
 pk2   5.9540883e-16
 cjswd   8.2e-11
 cjsws   8.2e-11
 jtsswgd   2.3e-7
 jtsswgs   2.3e-7
 pu0   -7.954093e-17
 mjswd   0.11
 mjsws   0.11
 agidl   9.41e-8
 prt   0
 pua   -1.6092489999999997e-23
 pub   1.5276544400000003e-32
 puc   5.518326299999999e-24
 pud   0
 rsh   17.5
 tcj   0.00076
 ua1   -1.1935669e-9
 ub1   2.1692222300000005e-18
 uc1   1.0139469700000001e-9
 tpb   0.0014
 k2we   5e-5
 wa0   -2.59429679e-6
 tvfbsdoff   0.022
 ute   -1
 wat   0.0028451685
 dsub   0.75
 web   6843.8
 wec   -25529.0
 wk2   -1.1593839e-8
 ltvoff   -1.1952424e-10
 dtox   2.7e-10
 wlc   0
 wln   1
 rgatemod   0
 wu0   1.2231027e-9
 xgl   -1.09e-8
 xgw   0
 wua   3.2583921000000013e-16
 wub   -3.447615700000002e-25
 wuc   -8.750290400000002e-17
 wud   0
 wwc   0
 wwl   0
 wwn   1
 dvt0   3.2
 dvt1   0.5
 dvt2   -0.35
 tnjtsswg   1

}
set I [open $::env(RAMSPICE_TECH) r]
set in_section 0
while {[gets $I line]>=0} {
    if {[regexp {model nch_tt_(\S+) nmos } $line -> bin_num]} {
        if {$bin_num==$refined_section} {
	    set in_section 1
	}
	continue
    }
    if {[regexp {\+ \)} $line]} {
        set in_section 0
	continue
    }
    if {$in_section==0} continue
    if {[regexp {\+\s+(\S+)\s*=\s*(\S+)} $line -> param value]} {
        set ref_model($param) $value
    }
}
close $I
if {[file exists $::env(RAMSPICE)/matched_model_${refined_section}.tcl]} {
    source $::env(RAMSPICE)/matched_model_${refined_section}.tcl
}
array set second_best [array get ref_model]
set I [open $::opt(input) r]
while {[gets $I line]>=0} {
    if {[regexp {^variable.*\"(\S+)\"} $line -> field]} {
        set varname $field
        continue
    }
    if {[regexp {^inclusion.*value \((.+)\)} $line -> value]} {
        set $varname $value
    }
}
close $I
set prev_section 0
set Lmin $::global_nlmin
#    toxe toxm vth0 voff vsat lua lub luc ua1 ub1 uc1 lkt1 lkt2 lpdiblc2 lute pags paigc paigsd waigc waigsd wetab wk2 wkt1 wkt2 wpclm wpdiblc2
set tweaked_params {
    toxe toxm vth0 voff vsat lua lub luc ua1 ub1 uc1 lkt1 lkt2 lpdiblc2 lute pags paigc paigsd waigc waigsd wetab wk2 wkt1 wkt2 wpclm wpdiblc2
    lua lub luc ua1 ub1 uc1 lkt1 lkt2
    lute pags paigc paigsd waigc waigsd wetab wk2 wkt1 wkt2 wpclm wpdiblc2
    wua  
    wua1 
    wub 
    wub1 
    wuc 
    wuc1 wute wketa
    pua
    pua1
    pub
    pub1
    puc
    puc1
    petab lvoff lk2we lpclm
    ku0we
    lku0we
    pku0we
    wku0we bgidl
}
set initial_directional_step_size 8.0
set directional_step_size 0
foreach i $refined_section {
    set annealing_factor 100
    while 1 {
        array set tryme [array get ::ref_model]
        set O [open /tmp/tech_${refined_section}.lib w]
        puts $O ".model nch_tt_${refined_section} nmos ("
        puts $O "+ level = 54"
        puts $O "+ version = 4.5"
        if {$directional_step_size>$directional_final_step_size} {
            foreach {param value} [array get tryme] {
                set tryme($param) [expr (1-$directional_step_size)*$second_best($param)+$directional_step_size*$ref_model($param)]
                puts $O "+ $param = $tryme($param)"
            }
        } else {
            foreach {param value} [array get tryme] {
                if {[lsearch $tweaked_params $param]!=-1} {
                    set tryme($param) [expr (1+(rand()-0.5)/$annealing_factor)*$tryme($param)]
                    if {rand()<(1/50)} {
                        set tryme($param) [expr -$tryme($param)]
                    }
                }	
                puts $O "+ $param = $tryme($param)"
            }
        }
        puts $O "+ )"
        close $O
        set rms_err 0
        set err_radius 0
        set max_err 0
        set min_err 0
        set num_of_samples 0
        set average 0
        set first_run 1
        foreach stimulus [split $stimuli ,] ref_ids $ref {
            foreach {var val} $stimulus {
                set $var $val
            }
            set section [find_mosfet_bin n $l $w]
            if {$section!=$i} continue
            if {$first_run} {
                netlist ".include /tmp/tech_${refined_section}.lib"
                netlist ".temp $opt(temp)"
                netlist "mn 3 1 5 4 ${::opt(device)}_${::opt(process)}_${section} L=$l W=$w"
                netlist "r5 5 0 1e-12"
                netlist "Vds 3 0 dc 0 ac 0"
                netlist "Vgs 1 0 dc 0 ac 0"
                netlist "Vbs 0 4 dc 0 ac 0"
                netlist ".end"
                update_netlist
                ::spice::op
                set first_run 0
            } else {
                ::spice::alter mn l = $l
                ::spice::alter mn w = $w
            }
            ::spice::alter vds = $Vds
            ::spice::alter vgs = $Vgs
            ::spice::alter vbs = $Vbs
            if {$Vds<($Vgs-0.52)} continue
            if {$Vgs<0.52} continue
            ::spice::op
            if {[catch {set Ids [::spice::get_spice_data V(5) 0]} msg]} {
                Error: $msg
            }
            if {[catch {set Ids [expr $Ids*1e12]}]} {
                continue
            }
            set err [expr $ref_ids-$Ids]
	    set rms_err [expr $rms_err+$err*$err]
            set average [expr $average+$ref_ids]
            #            set err [expr ($ref_ids/$Ids-1)*100]
	    set rel_err [expr $err/$ref_ids*100]
            if {$rel_err>$max_err} {
                set max_err $rel_err
            }
            if {$rel_err<$min_err} {
                set min_err $rel_err
            }
            if {abs($rel_err)>$err_radius} {
                set err_radius [expr abs($rel_err)]
            }
	    
            incr num_of_samples
#            if {$num_of_samples>9} break
        }
        if {$num_of_samples==0} continue
        set rms_err [expr sqrt($rms_err/$num_of_samples)]
        set average [expr $average/$num_of_samples]
        if {![info exists lowest_err]} {
            set lowest_err $err_radius
        }
        set directional_step_size [expr $directional_step_size/2.0]
        if {$err_radius<$lowest_err} {
            if {($directional_step_size>$directional_final_step_size)&&($directional_step_size*2<$initial_directional_step_size)} {
               # set directional_step_size 0
            } else {
                set directional_step_size $initial_directional_step_size
            }
            set annealing_factor [expr $annealing_factor/1.5]
	    if {$annealing_factor<100} {
	        set annealing_factor 100
	    }
            array set second_best [array get ref_model]
            array set ref_model [array get tryme]
            set lowest_err $err_radius
            set O [open $::env(RAMSPICE)/matched_model_${refined_section}.tcl w]
            puts $O [list array set ref_model [array get ref_model]]
            puts $O [list set lowest_err $lowest_err]
            close $O
        }
        if {$directional_step_size>$directional_final_step_size} {
            Info: Bin $i best=[eng $lowest_err %] temp=[eng [expr 1e5/$annealing_factor] K] error=([eng $max_err %],[eng $min_err %]) rms_err=[eng $rms_err A] err_radius=[eng $err_radius %] ($num_of_samples) trying $directional_step_size step size 
        } else {
            Info: Bin $i best=[eng $lowest_err %] temp=[eng [expr 1e5/$annealing_factor] K] error=([eng $max_err %],[eng $min_err %]) rms_err=[eng $rms_err A] err_radius=[eng $err_radius %] ($num_of_samples)
            if {abs($err_radius/$lowest_err-1)*10000>1} {
                set annealing_factor [expr $annealing_factor*1.1]
            }
        }
    }
}
exit

