# \
exec $RAMSPICE/ramspice_sp $0 $argv

get_opts
source random_$::opt(tech).csv
source $::env(RAMSPICE)/Tech_DB/$opt(tech)/binning_$opt(tech).tcl
source Web/svg/svg.tcl
set Spice_Ids {}
set Spectre_Ids {}
set data {}
set prev_section 0
set Lmin $::global_nlmin
default ::opt(rez) 0.1
default ::opt(start) 1
set CSV [open $::env(RAMSPICE)/effective_error_$opt(tech).csv w]
#    toxe toxm vth0 voff vsat lua lub luc ua1 ub1 uc1 lkt1 lkt2 lpdiblc2 lute pags paigc paigsd waigc waigsd wetab wk2 wkt1 wkt2 wpclm wpdiblc2
for {set i $::opt(start)} {[info exists bin(n,$i,lmin)]} {incr i} {
    array set tryme [array get ::ref_model]
    set rms_err 0
    set err_radius 0
    set max_err 0
    set min_err 0
    set num_of_samples 0
    set average 0
    set first_run 1
    foreach stimulus $stimuli ref_ids $ref {
        foreach {var val} $stimulus {
            if {[info exists $var]} {
                set $var
            }
        }
        foreach {var val} $stimulus {
            set $var $val
        }
#	set w [expr $w*$Mult]
        set factor [expr sqrt(1+(3.62252432910646*$w)/(0.00077581))]
        set section [find_mosfet_bin n $l $w]
        #       set w [expr $w/$factor]
        #       set w [expr $w/$factor]
        #       set l [expr $l*$factor]
        if {$section!=$i} continue
	#if {$w/$l>100} continue
        if {$Vbs<-0.4} continue
        if {$first_run} {
            netlist ".include $::env(RAMSPICE)/Tech_DB/$opt(tech)/$opt(tech).sp"
            netlist ".temp $opt(temp)"
            netlist "mn 3 1 5 4 ${::opt(device)}_${::opt(process)}_${section} L=$l W=$w"
            netlist "r5 5 0 1e-18"
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
        ::spice::op
        if {[catch {set Ids [::spice::get_spice_data V(5) 0]} msg]} {
            Error: $msg
        }
        if {[catch {set Ids [expr $Ids*1e18*$Mult]}]} {
            continue
        }
        lappend Spectre_Ids $ref_ids
        lappend Spice_Ids $Ids
        lappend data $ref_ids
        lappend data $Ids
        set rel_error_index [expr int(($ref_ids/$Ids-1)*100/$::opt(rez))*$::opt(rez)]
        if {![info exists ::rel_hist($rel_error_index)]} {
            set ::rel_hist($rel_error_index) 0
        }
        incr ::rel_hist($rel_error_index)
        Info: W=[eng $w m] L=[eng $l m] Vgs=[eng $Vgs V]  Vds=[eng $Vds V] Vbs=[eng $Vbs V] ref=[eng $ref_ids A] [eng [expr $ref_ids*$l/$w] A] ramspice=[eng $Ids A] [eng [expr $Ids*$l/$w] A] error=[expr ($Ids/$ref_ids-1)*100] W/L=[expr $w/$l]
        set rel_error [expr $Ids/$ref_ids]
        set err [expr $ref_ids-$Ids]
        set rms_err [expr $rms_err+$err*$err]
        set average [expr $average+$ref_ids]
        #            set err [expr ($ref_ids/$Ids-1)*100]
        set rel_err [expr ($ref_ids/$Ids-1)*100]
        if {$rel_err>$max_err} {
            set max_err $rel_err
        }
        if {$rel_err<$min_err} {
            set min_err $rel_err
        }
        if {abs($err)>$err_radius} {
            set err_radius [expr abs($err)]
        }
        incr num_of_samples
        #            if {$num_of_samples>9} break
	if {(1-$ref_ids/$Ids)*100>50} 	exit
    }
    if {$num_of_samples==0} continue
    set rms_err [expr sqrt($rms_err/$num_of_samples)]
    set average [expr $average/$num_of_samples]
    Info: Bin $i W=[eng $bin(n,$i,wmin) m],[eng $bin(n,$i,wmax) m] L=[eng $bin(n,$i,lmin) m],[eng $bin(n,$i,lmax) m] error=([eng $max_err %],[eng $min_err %]) rms_err=[eng $rms_err A] err_radius=[eng $err_radius A] ($num_of_samples)
    ::spice::destroy all
}

set O [open $::env(RAMSPICE)/Tech_DB/$opt(tech)/match_spectre_ramspice.html w]
puts $O "<html><body>"
puts $O <h1>
puts $O "Matching Spectre to RAMSpice"
puts $O </h1> 
::SVG::append $O
::SVG::svg width 1200 height 2000 {
    #        SVG::graph histogram x 100 y 100 width 500 height 400 x_unit A y_unit {} x_type log x_title "Absolute Error" title "Absolute Error Histogram" data [array get ::abs_hist]
    SVG::graph histogram x 100 y 700 width 500 height 400 x_unit % y_unit {} x_title "Relative Error" title "Relative Error Histogram" data [array get ::rel_hist]
    SVG::graph markers x 100 y 1300 width 500 height 400 x_unit A y_unit A x_title "Spectre Ids" y_title "RAMSpice Ids" x_type log y_type log data $::data title "RAMSpice Vs. Spectre Ids"
}
puts $O "</body></html>"

close $O
close $CSV
exit

