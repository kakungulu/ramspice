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
// Trade-off analysis
default p n
set ::to_steps 10
array set ::to_var_to_title {
    Int "Thermal Noise"
    Kf "Flicker Noise"
}
set max_area [expr [set ::global_${p}lmax]*[set ::global_${p}wmax]]
set min_area [expr [set ::global_${p}lmin]*[set ::global_${p}wmin]]
set area_step [expr pow($max_area/$min_area,1.0/$::to_steps)]
set ::to_area_list {}
set area $min_area
for {set k 0} {$k<$::to_steps} {set k [expr $k+0.1]} {
    lappend ::to_area_list $area
    set area [expr $area*$area_step]
}
set ::to_WbyL_list {}
for {set k $::to_steps} {$k>1} {set k [expr $k-0.1]} {
    lappend ::to_WbyL_list [expr 1.0/$k]
}
for {set k 1} {$k<=$::to_steps} {incr k} {
    lappend ::to_WbyL_list [expr $k]
}
set index 0
set area_index 0
foreach area $::to_area_list {
    set WbyL_index -1
    foreach WbyL $::to_WbyL_list {
        incr WbyL_index
        set W [expr sqrt($area*$WbyL)]
        set L [expr sqrt($area/$WbyL)]
        skip {$W>[set ::global_${p}wmax]}
        skip {$W<[set ::global_${p}wmin]}
        skip {$L>[set ::global_${p}lmax]}
        skip {$L<[set ::global_${p}lmin]}
        set ::TO($index,L) $L
        set ::TO($index,W) $W
        set ::TO($index,area) $area_index
        set ::TO($index,WbyL) $WbyL_index
        incr index
    }
    incr area_index
}
set ::to_sample_size $index

default opt(rez) 5:6:5
foreach device {nch pch} {
    @ /look_up_tables/$device !
    foreach view {ids gm go va vt ids_mis vth_mis} {
        set file $::env(RAMSPICE)/Tech_DB/$tech/reduced/$::opt(rez)/${tech}_${device}_${view}.db
        skip {![file exists $file]}
        Info: Loading  $file to @ /look_up_tables/$device
        @ /look_up_tables/$device load $file
    }
    foreach view {flicker thermal} suffix {const noise} {
        @ /look_up_tables/$device/${view}_noise !
        foreach corner {ss tt ff fs sf mc} {
            set file $::env(RAMSPICE)/Tech_DB/$tech/reduced/$::opt(rez)/${tech}_${device}_${corner}_${view}_noise.db
            skip {![file exists $file]}
            Info: Loading  $file to @ /look_up_tables/$device/${view}_${suffix}
            @ /look_up_tables/$device/${view}_${suffix} load $file
        }
    }
    source $::env(RAMSPICE)/Tech_DB/$tech/reduced/$::opt(rez)/${tech}_${device}_min_vt.tcl
    set ::min_vt($device) $::minVt
}
source $::env(RAMSPICE)/Web/svg/svg.tcl
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
form_field		Vds		"V<sub>DS</sub>\[mV\]"  -	text		{$::maxv($::device)}      0		       {$::maxv($::device)}	       V
form_field		Ids		"I<sub>DS</sub>\[mA\]"	-	text		10e-6		0			20e-3			A
form_sep		"Primary Performance Targets"
form_field		gm		g<sub>M</sub>		-	text		{}		0			1000			S
form_field		ro		r<sub>O</sub>		-	text		{}		0			1e99			Ohm
form_field		Gain		Gain			-	text		{}		-1e99			1e99			dB
form_sep		"Optional Parameters"
form_field		Vgs		"V<sub>GS</sub>\[mV\]"  -       text	       {$::maxv($::device)}      {$::min_vt($::device)}  {$::maxv($::device)}	       V
form_field		Vbs		"V<sub>BS</sub>\[mV\]"  -       text	       0	       [expr -{$::maxv($::device)}/3]    0		       V
form_sep		"Secondary Performance Targets"
form_field		Int		"Noise_Floor"    	-	text		{}		0			1000			"A/&radic;<span style=\\\"text-decoration:overline;\\\">&nbsp;Hz&nbsp;</span>"
form_field		Kf		i<sub>Nf</sub>*f    	-	text		{}		0			1000			A
form_field		fc		f<sub>C</sub>		-	text		{}		0			1e12			Hz
form_field		Va		V<sub>a</sub>		-	text		{}		-50			0			V
form_field		Vt		V<sub>T</sub>		-	text		{}		0.2			0.8			V

form_sep		"Calculated Parameters"
form_field		L		-			-	text		$Lmin		{$Lmin}			$::maxl		m
form_field		W		-			-	text		$::global_nwmin $::global_nwmin 	$::maxw			m
form_field		Area		-			-	text		{} [expr $::global_nwmin*$::global_nlmin*1e12] [expr $::maxw*$::maxl*1e12] 	um<sup>2</sup>
form_field		sigmaIds	"&#963;I<sub>DS</sub>"	-	text		{}		0			100			%
form_field		sigmaVt		"&#963;V<sub>T</sub>"	-	text		{}		0			100			%
form_field		Offset		-			-	text		{}		0			100			%
form_field		Lmin		L<sub>min</sub>		-	text		$Lmin		0			$::maxl		m
form_field		Tolerance	-		        -	text		10		0			100		%

if {[lsearch {nch pch} $::device]==-1} {
    set ::device nch
}

link			Lsize		{$L/$Lmin}
link			WbyL		{$W/$L}
link			array_factor	{sqrt($W*$L)/$Lmin}
link			Ids_unit	{[LUT Ids tt $Vgs $Vds $Vbs $L]} -unit A -min 0 -max 1
link			gm_unit		{[LUT gm ss $Vgs $Vds $Vbs $L]} -unit $::mho -min 0 -max 1e99
link			go_unit		{[LUT go ff $Vgs $Vds $Vbs $L]} -unit $::ohm -min 0 -max 1e99
link			Ids		{$Ids_unit*$WbyL} -unit A -min 0 -max 1
link			gm		{$gm_unit*$WbyL} -unit $::mho -min 0 -max 1e99
link			go		{$go_unit*$WbyL} -unit $::mho -min 0 -max 1e99
link			ro		{1/$go} -unit $::ohm -min 0 -max 1e99
link			Va		{[LUT Va tt $L]}
link			Vt		{[LUT Vt tt $L]}
link			sigmaIds	{[LUT Ids_mis tt $L]*100}
link			sigmaVt		{[LUT Vth_mis tt $L]*100}
link			Offset		{3*$sigmaVt}
link 			temp		{$::process2temp($process)}
link			Int	       {[LUT thermal_noise tt $Vgs $Vds $Vbs $L]*sqrt($gm)}
link			Kf	       {[LUT flicker_const tt $Vgs $Vds $Vbs $L]*sqrt($gm*$gm/$W/$L)}
link			fc	       {($Kf*$Kf)/($Int*$Int)}
link 			Area           {$W*$L*1e12}
link 			Gain           {20*log10($gm*$ro)}
default ::Distance 0
proc pre_calculate {} {
    
    # Now find the real solution
    set vt_mis $::sigmaVt
    if {$vt_mis!=""} {
        set vt_mis [expr $vt_mis/100]
    }
    set cmd sizer
    foreach input {Vgs Vds Vbs L W} {
        lappend cmd [set ::$input]
        lappend cmd $::const($input,min)
        lappend cmd $::const($input,max)
    }
    set ::go {}
    if {$::ro!={}} {
        set ::go [expr 1/$::ro]
    }
    foreach parameter {Ids gm go Vt Int Kf sigmaVt} lut {Ids/tt gm/ss go/ff Vt/tt thermal_noise/tt flicker_const/tt Vth_mis/tt} {
        lappend cmd [set ::$parameter]
        lappend cmd "/look_up_tables/nch/$lut"
    }
    lappend cmd $::Gain
    lappend cmd $::Area
    lappend cmd $::fc
    lappend cmd $::Tolerance
    Info: Sending cmd=$cmd 
    set cpu_time -[clock microseconds]
    set gamma [uplevel $cmd]
    incr cpu_time [clock microseconds]
    Info: Solution! ${cpu_time}usec
    set cpu_time -[clock microseconds]
    set i 0
    foreach param {Vgs Vds Vbs L W Ids gm go Vt Int Kf sigmaVt Gain Area fc Distance} value $gamma {
        set ::$param $value	
    }	
    set ::ro [expr 1/$::go]
    set O [open /tmp/tmp.html w]
    if {$::tolerance_analysis} {
        
    } else {
        # Create a 3D graphic presentation of the cost function
        puts $O "<h3>Cost Function L/W Plot</h3>"
        ::SVG::append $O
        source /tmp/trail.tcl
        set trail $data
        set data {}
        foreach {l w} $trail {
            set cmd sizer
            foreach input {Vgs Vds Vbs} {
                lappend cmd [set ::$input]
                lappend cmd $::const($input,min)
                lappend cmd $::const($input,max)
            }
            foreach input {l w} {
                lappend cmd [set $input]
                lappend cmd [set $input]
                lappend cmd [set $input]
            }
            set ::go {}
            if {$::ro!={}} {
                set ::go [expr 1/$::ro]
            }
            foreach parameter {Ids gm go Vt Int Kf sigmaVt} lut {Ids/tt gm/ss go/ff Vt/tt thermal_noise/tt flicker_const/tt Vth_mis/tt} {
                if {[info exists ::original_value($parameter)]} {
                    lappend cmd $::original_value($parameter)
                } else {
                    lappend cmd {}
                }
                lappend cmd "/look_up_tables/nch/$lut"
            }
            foreach parameter {Gain Area fc Tolerance} {
                if {[info exists ::original_value($parameter)]} {
                    lappend cmd $::original_value($parameter)
                } else {
                    lappend cmd {}
                }
            }   
            set gamma [uplevel $cmd]
            set d [expr [lindex $gamma end]+1]
            lappend data $l
            lappend data $w
            lappend data $d
            lappend data 32
        }
        set trail $data
        set TRAIL [open trail.tcl w]
        puts $TRAIL $trail
        close $TRAIL
        set markers {}
        for {set k 0} {$k<32} {incr k} {
            lappend markers 1:black
        }
        lappend markers 2:green
        set l_marker 0
        for {set l $::global_nlmin} {$l<=$::global_nlmax} {set l [expr $l*pow(($::global_nlmax/$::global_nlmin),1.0/15)]} {
            set w_marker 16
            for {set w $::global_nwmin} {$w<=$::global_nwmax} {set w [expr $w*pow(($::global_nwmax/$::global_nwmin),1.0/15)]} {
                set cmd sizer
                foreach input {Vgs Vds Vbs} {
                    lappend cmd [set ::$input]
                    lappend cmd $::const($input,min)
                    lappend cmd $::const($input,max)
                }
                foreach input {l w} {
                    lappend cmd [set $input]
                    lappend cmd [set $input]
                    lappend cmd [set $input]
                }
                set ::go {}
                if {$::ro!={}} {
                    set ::go [expr 1/$::ro]
                }
                foreach parameter {Ids gm go Vt Int Kf sigmaVt} lut {Ids/tt gm/ss go/ff Vt/tt thermal_noise/tt flicker_const/tt Vth_mis/tt} {
                    if {[info exists ::original_value($parameter)]} {
                        lappend cmd $::original_value($parameter)
                    } else {
                        lappend cmd {}
                    }
                    lappend cmd "/look_up_tables/nch/$lut"
                }
                foreach parameter {Gain Area fc Tolerance} {
                    if {[info exists ::original_value($parameter)]} {
                        lappend cmd $::original_value($parameter)
                    } else {
                        lappend cmd {}
                    }
                }	
                set gamma [uplevel $cmd]
                set d [expr [lindex $gamma end]+1]
                lappend data $l
                lappend data $w
                lappend data $d
                lappend data $l_marker
                lappend data $l
                lappend data $w
                lappend data $d
                lappend data $w_marker
                incr w_marker
            }
            incr l_marker
        }
        set data_zoom {}
        foreach {l w d m} $trail {
            skip {$l<$::L/2}
            skip {$w<$::W/2}
            lappend data_zoom $l
            lappend data_zoom $w
            lappend data_zoom $d
            lappend data_zoom $m
        }	
        set l_marker 0
        for {set l [expr $::L/2]} {$l<=2*$::L} {set l [expr $l*pow(4,1.0/15)]} {
            set w_marker 16
            for {set w [expr $::W/2]} {$w<=2*$::W} {set w [expr $w*pow(4,1.0/15)]} {
                set cmd sizer
                foreach input {Vgs Vds Vbs} {
                    lappend cmd [set ::$input]
                    lappend cmd $::const($input,min)
                    lappend cmd $::const($input,max)
                }
                foreach input {l w} {
                    lappend cmd [set $input]
                    lappend cmd [set $input]
                    lappend cmd [set $input]
                }
                set ::go {}
                if {$::ro!={}} {
                    set ::go [expr 1/$::ro]
                }
                foreach parameter {Ids gm go Vt Int Kf sigmaVt} lut {Ids/tt gm/ss go/ff Vt/tt thermal_noise/tt flicker_const/tt Vth_mis/tt} {
                    if {[info exists ::original_value($parameter)]} {
                        lappend cmd $::original_value($parameter)
                    } else {
                        lappend cmd {}
                    }
                    lappend cmd "/look_up_tables/nch/$lut"
                }
                foreach parameter {Gain Area fc Tolerance} {
                    if {[info exists ::original_value($parameter)]} {
                        lappend cmd $::original_value($parameter)
                    } else {
                        lappend cmd {}
                    }
                }	
                set gamma [uplevel $cmd]
                set d [expr [lindex $gamma end]+1]
                lappend data_zoom $l
                lappend data_zoom $w
                lappend data_zoom $d
                lappend data_zoom $l_marker
                lappend data_zoom $l
                lappend data_zoom $w
                lappend data_zoom $d
                lappend data_zoom $w_marker
                incr w_marker
            }
            incr l_marker
        }
        ::SVG::svg width 1000 height 500 {
            SVG::graph_markers3D x 0 y 0 width 1000 height 500 markers $markers data $data x_type log y_type log z_type log connect all
        }
        puts $O "<h3>Zoom-In on Solution Area:</h3>"
        ::SVG::svg width 1000 height 500 {
            SVG::graph_markers3D x 0 y 0 width 1000 height 500 markers $markers data $data_zoom x_type log y_type log z_type log connect all
        }
        incr cpu_time [clock microseconds]
        Info: Wire-mesh generated in ${cpu_time}usec
    }
    set ::to_filtered_list {}
    for {set T 0} {$T<$::to_sample_size} {incr T} {
        set W $::TO($T,W)
        set L $::TO($T,L)
        set maxIds [LUT Ids tt $::opt(topv) $::Vds $::Vbs $L]
        skip {$maxIds*$W/$L<$::Ids} 
        lappend ::to_filtered_list $T
    }
    Info: Trade Off Analysis selected [llength $::to_filtered_list] test transistors
    set ::to_var_list {gm ro Vt Int Kf fc Gain}
    foreach T $::to_filtered_list {
        set W $::TO($T,W)
        set L $::TO($T,L)
        Info: Collecting trade-off info on L=$L W=$W
        set VgsLow 0
        set VgsHigh $::opt(topv)
        while {$VgsHigh-$VgsLow>1e-4} {
            set TestVgs [expr ($VgsLow+$VgsHigh)/2]
            set TestIds [expr [LUT Ids tt $TestVgs $::Vds $::Vbs $L]*$W/$L]
	    Info: $TestIds>$::Ids ? $TestVgs 
            if {$TestIds>$::Ids} {
                set VgsHigh $TestVgs
            } else {
                set VgsLow $TestVgs
            }
	    Info:  VgsLow=$VgsLow VgsHigh=$VgsHigh 
        }
	foreach {var expr} {
         WbyL {expr $W/$L}
         gm_unit		{LUT gm ss $TestVgs $::Vds $::Vbs $L}
         go_unit		{LUT go ff $TestVgs $::Vds $::Vbs $L}
         gm			{expr $gm_unit*$WbyL}
         go			{expr $go_unit*$WbyL}
         ro			{expr 1/$go}
         Va			{LUT Va tt $L}
         Vt			{LUT Vt tt $L}
         sigmaIds		{expr [LUT Ids_mis tt $L]*100}
         sigmaVt			{expr [LUT Vth_mis tt $L]*100}
         Off		{expr 3*$sigmaVt}
         Int	       	{expr [LUT thermal_noise tt $TestVgs $::Vds $::Vbs $L]*sqrt($gm)}
         Kf	       		{expr [LUT flicker_const tt $TestVgs $::Vds $::Vbs $L]*sqrt($gm*$gm/$W/$L)}
         fc	       		{expr ($Kf*$Kf)/($Int*$Int)}
         Gain           	{expr 20*log10($gm*$ro)}
	} {
	    if {[catch {set $var [eval $expr]}]} {
	        set $var -1
	    }
	}
        foreach var $::to_var_list {
            set ::TO($T,$var) [set $var]
        }
    }
    for {set x 0} {$x<[llength $::to_var_list]} {incr x} {
    	set x_var [lindex $::to_var_list $x]
    	for {set y [expr $x+1]} {$y<[llength $::to_var_list]} {incr y} {
    	    set y_var [lindex $::to_var_list $y]
	    set x_title $x_var
	    set y_title $y_var
	    if {[info exists ::to_var_to_title($x_var)]} {
	        set x_title $::to_var_to_title($x_var)
	    }
	    if {[info exists ::to_var_to_title($y_var)]} {
	        set y_title $::to_var_to_title($y_var)
	    }
    	    set data {}
    	    set area_markers {}
    	    set markers {}
    	    set connect {}
    	    foreach T $::to_filtered_list {
    		skip {![info exists ::TO($T,$x_var)]}
    		skip {![info exists ::TO($T,$y_var)]}
    		lappend data $::TO($T,$x_var)
    		lappend data $::TO($T,$y_var)
		if {[lsearch $area_markers $::TO($T,area)]==-1} {
    		    lappend area_markers $::TO($T,area)
		}
    		lappend data [lsearch $area_markers $::TO($T,area)]
    	    }
    	    # Info: $x_var Vs. $y_var $data
	    set span [llength $area_markers]
	    set pallete {}
    	    for {set m 0} {$m<$span} {incr m} {
	        set deg [expr 1.0*$m/$span]
		set blue [expr int(128*gauss($deg,0,0.5))]
		set green [expr int(128*gauss($deg,0.5,0.5))]
		set red [expr int(128*gauss($deg,1.0,0.5))]
		set color [format "#%02x%02x%02x" $red $green $blue]
		lappend pallete $color
    		lappend markers 1:$color
		lappend connect $m
    	    }
	    set area_markers [lsort -integer $area_markers]
	    set min_area_index [lindex $area_markers 0]
	    set max_area_index [lindex $area_markers end]
	    set min_area [eng [expr [lindex $::to_area_list $min_area_index]*1e12] "(um)<sup>2</sup>"]
	    set max_area [eng [expr [lindex $::to_area_list $max_area_index]*1e12] "(um)<sup>2</sup>"]
     	    puts $O "<h3>Trade-off Analysis: $y_title Vs. $x_title (area range: <font color=\"[lindex $pallete 0]\">$min_area</font> to <font color=\"[lindex $pallete end]\">$max_area</font>)</h3>"
   	    ::SVG::svg width 1000 height 1000 {
    	#	SVG::graph_markers x 100 y 0 width 800 height 800 markers $markers x_title $x_title y_title $y_title data $data connect $connect connect_pattern solid connect_width 20
    	    }
    	}
    }
    close $O
}
proc tcl::mathfunc::gauss {x {shift 0}  {width 1}} {
    set x [expr $x-$shift]
    return [expr exp(-$x*$x/$width)]
}
set O [open /tmp/sizer.log w]
puts $O [clock format [clock seconds]]
close $O
proc post_calculate {} {
    array unset ::simulated
    set epsilon 0.01
    set p [string index $::device 0]
    set section [find_mosfet_bin $p $::L $::W]
    textbox "Verifying Results by Simulations $::opt(tech) ${p}ch  L=$::L W=$::W (bin=${section})"
    foreach corner {ss tt ff} {
        set temp $::process2temp($corner)
        textbox "Corner [string toupper $corner] Temperature=$temp C"
        netlist ".include $::env(RAMSPICE)/Tech_DB/${::opt(tech)}/${::opt(tech)}.sp"
        netlist ".temp $temp"
        netlist "r5 5 0 1e-12"
        netlist "mn 3 1 5 4 ${p}ch_${corner}_${section} L=$::L W=$::W AD=[expr 2.5*$::Lmin*$::W] AS=[expr 2.5*$::Lmin*$::W] PD=[expr 5*$::Lmin+$::W] PS=[expr 5*$::Lmin+$::W]"
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
        if {[catch {set sim_Ids [get_spice_data V(5) 0]} msg]} {
            Error: $msg
        }
        set sim_Ids [expr $sim_Ids*1e12]
        Info: Simulated Ids=[eng $sim_Ids A] (bin=$section)
        set ::simulated(Ids,$corner) $sim_Ids
        ::spice::alter vgs = [expr $::Vgs+$epsilon]
        ::spice::op
        if {[catch {set Ids_gm [get_spice_data V(5) 0]} msg]} {
            Error: $msg
        }
        set Ids_gm [expr $Ids_gm*1e12]
        Info: Ids=($sim_Ids,$Ids_gm) epsilon=$epsilon
        set sim_gm [expr ($Ids_gm-$sim_Ids)/$epsilon]
        set ::simulated(gm,$corner) $sim_gm
        Info: Simulated gm=[eng $sim_gm Mho] (bin=$section)
        ::spice::alter vgs = $::Vgs
        ::spice::alter vds = [expr $::Vds+$epsilon]
        ::spice::op
        if {[catch {set Ids_go [get_spice_data V(5) 0]} msg]} {
            Error: $msg
        }
        set Ids_go [expr $Ids_go*1e12]
        set sim_ro [expr $epsilon/abs($Ids_go-$sim_Ids)]
        set ::simulated(ro,$corner) $sim_ro
        Info: Simulated ro=[eng $sim_ro Ohm] (bin=$section)
        ::spice::noise v(5) vgs lin 2 1 2
        set thermal_noise [expr sqrt([get_spice_data Captured_Thermal_Noise end])]
        if {[string match *nan* $thermal_noise]} {
            set thermal_noise 0
        }
        set Ssi [get_spice_data Captured_Ssi end]
        set Captured_EffFreq [get_spice_data Captured_EffFreq end]
        if {[string match *nan* $Captured_EffFreq]} {
            noise_cont $i0,$i1,$i2,$i3
        }
        set flicker_noise [expr sqrt($Ssi*$Captured_EffFreq)]
        set ::simulated(Int,$corner) $thermal_noise
        Info: Simulated Int=$thermal_noise
        set ::simulated(Kf,$corner) $flicker_noise
        Info: Simulated Kf=$flicker_noise
        set ::simulated(fc,$corner) [expr ($flicker_noise*$flicker_noise)/($thermal_noise*$thermal_noise)]
        Info: Simulated Fc=$::simulated(fc,$corner)
        ::spice::alter vds = $::maxv($::device)
        ::spice::alter vgs = [expr $::maxv($::device)/2]
        ::spice::alter vbs = 0
        ::spice::op
        if {[catch {set Ids_vt1 [get_spice_data V(5) 0]} msg]} {
            Error: $msg
        }
        ::spice::alter vgs = [expr $::maxv($::device)/2-$epsilon]
        ::spice::op
        if {[catch {set Ids_vt2 [get_spice_data V(5) 0]} msg]} {
            Error: $msg
        }
        set slope [expr ($Ids_vt1-$Ids_vt2)/$epsilon]
        set ::simulated(Vt,$corner) [expr $::maxv($::device)/2-$Ids_vt1/$slope]
        Info: Simulated Vt=$::simulated(Vt,$corner)
        ::spice::alter vgs = [expr $::maxv($::device)]
        ::spice::alter vds = [expr $::maxv($::device)]
        ::spice::op
        if {[catch {set Ids_va1 [get_spice_data V(5) 0]} msg]} {
            Error: $msg
        }
        ::spice::alter vds = [expr $::maxv($::device)-$epsilon]
        ::spice::op
        if {[catch {set Ids_va2 [get_spice_data V(5) 0]} msg]} {
            Error: $msg
        }
        set slope [expr ($Ids_va1-$Ids_va2)/$epsilon]
        set ::simulated(Va,$corner) [expr $::maxv($::device)-$Ids_va1/$slope]
        Info: Simulated Va=$::simulated(Va,$corner)
        ::spice::destroy all
    }
    set ::simulated(gm) $::simulated(gm,ss)
    set ::simulated(ro) $::simulated(ro,ff)
    set ::simulated(Ids) $::simulated(Ids,tt)
    set ::simulated(Int) $::simulated(Int,ss)
    set ::simulated(Kf) $::simulated(Kf,ss)
    set ::simulated(Vt) $::simulated(Vt,tt)
    set ::simulated(Va) $::simulated(Va,tt)
    set ::simulated(fc) $::simulated(fc,ss)
    set ::simulated(Gain) [expr 20*log10($::simulated(gm)*$::simulated(ro))]
    set O [open /tmp/sizer.log a]
    foreach var {Vds Ids gm ro Vgs Vbs L W} {
        skip {[info exists ::original_value($var)]}
        set ::original_value($var) ""
    }
    foreach var {Vds Ids gm ro Vgs Vbs L W} {
        puts -nonewline $O "$::original_value($var),"
    }
    foreach var {W L ro gm Vgs} {
        puts -nonewline $O "[set ::$var],"
    }
    puts -nonewline $O 	"$::simulated(ro),"
    set Ids_error [expr 100*($::Ids/$::simulated(Ids)-1)]
    set gm_error [expr 100*($::gm/$::simulated(gm)-1)]
    set ro_error [expr 100*($::ro/$::simulated(ro)-1)]
    puts  $O 	"$::simulated(gm),$::simulated(Kf),$Ids_error,$gm_error,$ro_error"
    close $O
    
}
