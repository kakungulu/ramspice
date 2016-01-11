# \
exec $RAMSPICE/ramspice $0 $argv

get_opts
array set ::corner_to_temp {
    ss 125
    tt 27
    ff -40
    fs 27
    sf 27
    mc 27
}
default ::opt(tech) tsmc040
default ::opt(device) nch
default ::opt(process) ss
default ::opt(rez) 5:5:3:8
default ::opt(size) 1000
default ::opt(topv) 1.1
default ::opt(squares) 1
set ::opt(interpolation) LUT
default ::opt(source) $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/4d/$::opt(rez)
set output_file $::opt(source)/$::opt(device).$::opt(process).$::opt(interpolation).info
# if {[file exists $output_file]} exit
@ /look_up_tables/$::opt(device) load $::opt(source)/$::opt(tech)_$::opt(device)_ids.db
@ /look_up_tables/$::opt(device) load $::opt(source)/$::opt(tech)_$::opt(device)_gm.db
@ /look_up_tables/$::opt(device) load $::opt(source)/$::opt(tech)_$::opt(device)_ro.db
@ /look_up_tables/$::opt(device)/cgs load $::opt(source)/$::opt(tech)_$::opt(device)_$::opt(process)_cgs.db
@ /look_up_tables/$::opt(device)/cgd load $::opt(source)/$::opt(tech)_$::opt(device)_$::opt(process)_cgd.db
@ /look_up_tables/$::opt(device)/nf load $::opt(source)/$::opt(tech)_$::opt(device)_$::opt(process)_flicker_noise.db
@ /look_up_tables/$::opt(device)/nt load $::opt(source)/$::opt(tech)_$::opt(device)_$::opt(process)_thermal_noise.db
if {$::opt(interpolation)=="LIT"} {
    generate_lit /look_up_tables/$::opt(device)/Ids/$::opt(process)
    generate_lit /look_up_tables/$::opt(device)/gm/$::opt(process)
    generate_lit /look_up_tables/$::opt(device)/go/$::opt(process)
}
open_bin write $output_file
source $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/binning_$::opt(tech).tcl
source $::env(RAMSPICE)/Etc/tests/geo_values.tcl
source $::opt(source)/$::opt(tech)_$::opt(device)_min_vt.tcl
set minVt 0.3
Info: minVt=$minVt
set epsilon 1e-4
set process $::opt(process)
set temp $::corner_to_temp($process)
set p [string index $::opt(device) 0]
if {$p=="p"} {
    set opt(topv) [expr -$opt(topv)]
}
set sample_size 0
set t0 [clock seconds]
while {$sample_size<$::opt(size)} {
    for {set section 1} {[info exists ::bin($p,$section,lmin)]} {incr section} {
        set L $::bin($p,$section,lmin)
        set W $::bin($p,$section,wmin)
        netlist ".include $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/$::opt(tech).sp"
        netlist ".temp $temp"
        netlist "mn 3 1 5 4 ${::opt(device)}_${::opt(process)}_${section} L=$L W=$W"
        netlist "r5 5 0 1e-12"
        netlist "Vds 3 0 dc 0 ac 0"
        netlist "Vgs 1 0 dc 0 ac 0"
        netlist "Vbs 4 0 dc 0 ac 0"
        netlist ".end"
        update_netlist
        ::spice::op
        # Info: Running section $section
        for {set i 0} {$i<10} {incr i} {
            set maxw $::bin($p,$section,wmax)
            if {$::bin($p,$section,wmax)>[lindex $w_values end]} {
                set maxw [lindex $w_values end]
            }
            set maxl $::bin($p,$section,lmax)
            if {$::bin($p,$section,lmax)>[lindex $l_values end]} {
                set maxl [lindex $l_values end]
            }
            set L [expr $::bin($p,$section,lmin)+rand()*($maxl-$::bin($p,$section,lmin))]
            set W [expr $L*(1+rand()*($::opt(squares)-1))]
            skip {$W>$::bin($p,$section,wmax)}
            skip {$W<$::bin($p,$section,wmin)}
            set Vgs [expr $::opt(topv)-rand()*$::opt(topv)/2]
            set Vds [expr $::opt(topv)-rand()*$::opt(topv)/2]
            set Vbs 0
            ::spice::alter mn l = $L
            ::spice::alter mn w = $W
            ::spice::alter vgs = $Vgs
            ::spice::alter vds = $Vds
            ::spice::alter vbs = $Vbs
            ::spice::op
            set Ids [expr 1e12*[get_spice_data V(5) 0]]
            if {[catch {set LUT_Ids [expr [@ /look_up_tables/$::opt(device)/Ids/$::opt(process) calc $Vgs $Vds $Vbs $L]*$W/$L]} msg ]} {
                Error: $Vgs $Vds $Vbs $L $W [@ /look_up_tables/$::opt(device)/Ids/$::opt(process) calc $Vgs $Vds $Vbs $L] $Ids
                continue
            }
            ::spice::alter vgs = [expr $Vgs+$epsilon]
            ::spice::op
            set Ids_gm [expr 1e12*[get_spice_data V(5) 0]]
            set gm [expr ($Ids_gm-$Ids)/$epsilon]
            set LUT_gm [expr [@ /look_up_tables/$::opt(device)/gm/$::opt(process) calc $Vgs $Vds $Vbs $L]*$W/$L]
            ::spice::alter vgs = $Vgs
            ::spice::alter vds = [expr $Vds+$epsilon]
            ::spice::op
            set Ids_go [expr 1e12*[get_spice_data V(5) 0]]
            set go [expr ($Ids_go-$Ids)/$epsilon]
            #  skip {$go<1e-5}
            set LUT_go [expr $W/$L/([@ /look_up_tables/$::opt(device)/ro/$::opt(process) calc $Vgs $Vds $Vbs $L])]
            skip {1.0/pow((abs($go/$LUT_go-1)*100),2)<rand()}
            
            ::spice::ac dec 1 1 10
            set LUT_cgs [expr [@ /look_up_tables/$::opt(device)/cgs/$::opt(process) calc $Vgs $Vds $Vbs $L]*$W*$L]
            set LUT_cgd [expr [@ /look_up_tables/$::opt(device)/cgd/$::opt(process) calc $Vgs $Vds $Vbs $L]*$W*$L]
            set cgs $::Captured_Cgs
            set cgd $::Captured_Cgd
            
            ::spice::noise v(3) vgs lin 2 1 2
            set LUT_nt [expr [@ /look_up_tables/$::opt(device)/nt/$::opt(process) calc $Vgs $Vds $Vbs $L]*$W/$L]
            set LUT_nf [expr [@ /look_up_tables/$::opt(device)/nf/$::opt(process) calc $Vgs $Vds $Vbs $L]*$W/$L]
	    set LUT_nf [expr $LUT_nf*$LUT_nf*$gm*$gm/($W*$L)]
	    set LUT_nt [expr $LUT_nt*$LUT_nt*$gm]
            set Ssi [get_spice_data Captured_Ssi end]
            set Captured_EffFreq [get_spice_data Captured_EffFreq end]
            set nt [get_spice_data Captured_Thermal_Noise end]
            set nf [expr $Ssi*$Captured_EffFreq]
	    # pch bug:
	    set Ids [expr abs($Ids)]	    
	    ###
            write_bin float $Vgs $Vds $Vbs $L $W $LUT_Ids $Ids $LUT_gm $gm $LUT_go $go $LUT_cgs $cgs $LUT_cgd $cgd $LUT_nt $nt $LUT_nf $nf
            incr sample_size
            set t1 [clock seconds]
            set te [clock format [expr $t0+$::opt(size)*($t1-$t0)/$sample_size]]
            Info:  $sample_size $te [eng $nt V^2/Hz] [eng $nf V^2/Hz] [eng [expr ($LUT_Ids/$Ids-1)*100] %] [eng [expr ($LUT_gm/$gm-1)*100] %] [eng [expr ($go/$LUT_go-1)*100] %] [eng [expr ($cgs/$LUT_cgs-1)*100] %] [eng [expr ($cgd/$LUT_cgd-1)*100] %]  [eng [expr ($nt/$LUT_nt-1)*100] %] [eng [expr ($nf/$LUT_nf-1)*100] %] 
            #Info: $Vgs $Vds $Vbs LUT=[eng $LUT_Ids A] Sim=[eng $Ids A] Error=[expr ($LUT_Ids/$Ids-1)*100]
        }
        spice::destroy all
    }
}
set time [expr 1e-9*[lindex [timer_report] 0]]
Info: Access time=[eng $time sec]
write_bin float $time
close_bin write
exit

