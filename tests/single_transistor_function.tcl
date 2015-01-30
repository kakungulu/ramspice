# \
exec $RAMSPICE/ramspice $0 $argv

set ::HTML {
    [clock format [clock seconds]]
    <h1> Transistor Sizer [string toupper $::opt(tech)]</h1>
    <datalist id="process">
    [list_processes]
    </datalist>   
    <form name="input" method="get">
    [gen_form]
    <input type="submit" value="Submit">
    </form>
}
array set ::process2temp {
    ss 125
    tt 27
    ff -40
    fs 27
    sf 27
    mc 27
}
proc list_processes {} {
    set retval {}
    foreach process [array names ::process2temp] {
        append retval "<option value=\"$process\">\n"
    }
    return $retval
}
default opt(rez) 5:6:5
foreach device {nch pch} {
    @ /look_up_tables/$device !
    foreach view {ids gm go va vt ids_mis vth_mis} {
        set file $::env(RAMSPICE)/Tech_DB/$tech/$::opt(rez)/${tech}_${device}_${view}.db
	skip {![file exists $file]}
        Info: Loading  $file to @ /look_up_tables/$device
        @ /look_up_tables/$device load $file
    }
    foreach view {flicker thermal} suffix {const noise} {
        @ /look_up_tables/$device/${view}_noise !
        foreach corner {ss tt ff fs sf mc} {
	    set file $::env(RAMSPICE)/Tech_DB/$tech/$::opt(rez)/${tech}_${device}_${corner}_${view}_noise.db
	    skip {![file exists $file]}
            Info: Loading  $file to @ /look_up_tables/$device/${view}_${suffix}
            @ /look_up_tables/$device/${view}_${suffix} load $file
        }
    }
    source $::env(RAMSPICE)/Tech_DB/$tech/$::opt(rez)/${tech}_${device}_min_vt.tcl
    set ::min_vt($device) $::minVt
}
set Lmin $::global_nlmin
set maxv(nch) $opt(topv)
#set ::global_nwmax 20e-6
set maxv(pch) [expr -$opt(topv)]
source $::env(RAMSPICE)/tests/geo_values.tcl
set p [string index $::device 0]
set maxw $::global_nwmax
if {$::global_nwmax>[lindex $w_values end]} {
    set maxw [lindex $w_values end]
}
set maxl $::global_nlmax
if {$::global_nlmax>[lindex $l_values end]} {
    set maxl [lindex $l_values end]
}

#			field 		display			factor	type		default		min			max			unit
form_field		device		-			-	device		nch		{}			{}			{}
form_field		process		-			-	process		tt		{}			{}			{}
form_field		temp		-			-	text		27		-40			125			<sup>O</sup>C
form_sep		"Operating Limits"
form_field		Vds		"V<sub>DS</sub>\[mV\]"  -      text	       {$::maxv($::device)}      0		       {$::maxv($::device)}	       V
form_field		Ids		"I<sub>DS</sub>\[mA\]"	-		text		{}		0			20e-3			A
form_sep		"Primary Performance Targets"
form_field		gm		g<sub>M</sub>		-	text		{}		0			1000			S
form_field		ro		r<sub>O</sub>		-	text		{}		0			1e99			Ohm
form_field		Gain		Gain			-	text		{}		-1e99			1e99			dB
form_sep		"Optional Parameters"
form_field		Vgs		"V<sub>GS</sub>\[mV\]"  -       text	       {$::maxv($::device)}      {$::min_vt($::device)}  {$::maxv($::device)}	       V
form_field		Vbs		"V<sub>BS</sub>\[mV\]"  -       text	       0	       [expr -{$::maxv($::device)}/3]    0		       V
form_sep		"Secondary Performance Targets"
form_field		Int		"Noise_Floor"    	-	text		{}		0			1000			"A/&radic;<span style=\"text-decoration:overline;\">&nbsp;Hz&nbsp;</span>"
form_field		Kf		i<sub>Nf</sub>*f    	-	text		{}		0			1000			A
form_field		fc		f<sub>C</sub>		-	text		{}		0			1e12			Hz
form_field		Va		V<sub>a</sub>		-	text		{}		-50			0			V
form_field		Vt		V<sub>T</sub>		-	text		{}		0.2			0.8			V

form_sep		"Calculated Parameters"
form_field		L		-			-	text		$Lmin		{$Lmin}			$::maxl		m
form_field		W		-			-	text		$::global_nwmin $::global_nwmin 	$::maxw			m
form_field		Area		-			-	text		{} [expr $::global_nwmin*$::global_nlmin] [expr $::maxw*$::maxl] 	um<sup>2</sup>
form_field		sigmaIds	"&#963;I<sub>DS</sub>"	-	text		{}		0			100			%
form_field		sigmaVt		"&#963;V<sub>T</sub>"	-	text		{}		0			100			%
form_field		Lmin		L<sub>min</sub>		-	text		$Lmin		0			$::maxl		m



link			Lsize		{$L/$Lmin}
link			WbyL		{$W/$L}
link			array_factor	{sqrt($W*$L)/$Lmin}
link			Ids_unit	{[LUT Ids $Vgs $Vds $Vbs $L $W]} -unit A -min 0 -max 1
link			gm_unit		{[LUT gm $Vgs $Vds $Vbs $L $W]} -unit $::mho -min 0 -max 1000
link			go_unit		{[LUT go $Vgs $Vds $Vbs $L $W]} -unit $::ohm -min 0 -max 1000
link			Ids		{$Ids_unit*$WbyL} -unit A -min 0 -max 1
link			gm		{$gm_unit*$WbyL} -unit $::mho -min 0 -max 1000
link			go		{$go_unit*$WbyL} -unit $::mho -min 0 -max 1000
link			ro		{1/$go} -unit $::ohm -min 0 -max 1000
link			Va		{[LUT Va $L $W]}
link			Vt		{[LUT Vt $L $W]}
link			sigmaIds	{[LUT Ids_mis $L $W]*100}
link			sigmaVt		{[LUT Vth_mis $L $W]*100}
link 			temp		{$::process2temp($process)}
link			Int	       {[LUT thermal_noise $Vgs $Vds $Vbs $L $W]*sqrt($gm)}
link			Kf	       {[LUT flicker_const $Vgs $Vds $Vbs $L $W]*sqrt($gm*$gm/$W/$L)}
link			fc	       {$Kf/$Int}
link 			Area           {$W*$L*1e12}
link 			Gain           {20*log10($gm*$ro)}
proc post_calculate {} {
    array unset ::simulated
    set epsilon 0.01
    set p [string index $::device 0]
    set section [find_mosfet_bin $p $::L $::W]
    netlist ".include $::env(RAMSPICE)/Tech_DB/${::opt(tech)}/${::opt(tech)}.sp"
    netlist ".temp $::temp"
    netlist "r5 5 0 1e-12"
    netlist "mn 3 1 5 4 ${p}ch_${::process}_${section} L=$::L W=$::W AD=[expr 2.5*$::Lmin*$::W] AS=[expr 2.5*$::Lmin*$::W] PD=[expr 5*$::Lmin+$::W] PS=[expr 5*$::Lmin+$::W]"
    if {$p=="p"} {
        netlist "Vds 0 3 dc $::Vds ac 0"
        netlist "Vgs 0 1 dc $::Vgs ac 0"
        netlist "Vbs 0 4 dc $::Vbs ac 0"
    } else {
        netlist "Vds 3 0 dc $::Vds ac 0"
        netlist "Vgs 1 0 dc $::Vgs ac 0"
        netlist "Vbs 4 0 dc $::Vbs ac 0"
    }
    netlist ".end"
    update_netlist
    ::spice::op
    if {[catch {set Ids [::spice::get_spice_data V(5) 0]} msg]} {
        Error: $msg
    }
    set Ids [expr $Ids*1e12]
    Info: Simulated Ids=[eng $Ids A] (bin=$section)
    set ::simulated(Ids) $Ids
    ::spice::alter vgs = [expr $::Vgs+$epsilon]
    ::spice::op
    if {[catch {set Ids_gm [::spice::get_spice_data V(5) 0]} msg]} {
        Error: $msg
    }
    set Ids_gm [expr $Ids_gm*1e12]
    set gm [expr abs($Ids_gm-$Ids)/$epsilon]
    set ::simulated(gm) $gm
    Info: Simulated gm=[eng $gm Mho] (bin=$section)
    ::spice::alter vgs = $::Vgs
    ::spice::alter vds = [expr $::Vds+$epsilon]
    ::spice::op
    if {[catch {set Ids_go [::spice::get_spice_data V(5) 0]} msg]} {
        Error: $msg
    }
    set Ids_go [expr $Ids_go*1e12]
    set ro [expr $epsilon/abs($Ids_go-$Ids)]
    set ::simulated(ro) $ro
    Info: Simulated ro=[eng $ro Ohm] (bin=$section)
    ::spice::noise v(5) vgs lin 2 1 2
    set thermal_noise [expr sqrt([::spice::get_spice_data Captured_Thermal_Noise end])]
    if {[string match *nan* $thermal_noise]} {
        set thermal_noise 0
    }
    set Ssi [::spice::get_spice_data Captured_Ssi end]
    set Captured_EffFreq [::spice::get_spice_data Captured_EffFreq end]
    if {[string match *nan* $Captured_EffFreq]} {
        noise_cont $i0,$i1,$i2,$i3
    }
    set flicker_noise [expr sqrt($Ssi*$Captured_EffFreq)]
    set ::simulated(Int) $thermal_noise
    Info: Simulated Int=$thermal_noise
    set ::simulated(Kf) $flicker_noise
    Info: Simulated Kf=$flicker_noise
    ::spice::destroy all
    
}


