# \
exec $RAMSPICE/ramspice $0 $argv



if {[lsearch {-help -h --help} $argv]!=-1} {
    puts {
        Characterization script for Cadence .SCS files
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        This program (created by yishai@statter.net) parses a Cadence tech-file, generates a SPICE .model code 
        and uses it to produce transistor characterization tables
        Usage:
        characterize.tcl <SCS tech file> [<flags>]
        flags:
        -source input SCS file
        -device name or list of devices to extract
        -corner name or list of corners to extract
        -topv highest voltage to use in characterization loops
        -tech name of tech file to be generated
        Example:
        characterize.tcl core_40.scs -device 'nch pch' -corner 'ss ff' -topv 1.8
    }
    return
}
textbox {
    ###########################################################
    ###########################################################
    ##                                                       ##
    ##        Translating Cadence SCS to Spice .model        ##
    ##                                                       ##
    ###########################################################
    ###########################################################
}
proc source_rf {file {section {}}} {
    textbox "[string repeat .... [info level]] Translating $file section=$section"
    set append 0
    if {$section=={}} {
        set append 1
    }
    set code {}
    set line_buffer {}
    set I [open $file r]
    while {[gets $I line]>=0} {
        if {[regexp {^\s*//} $line]} continue
        if {[regexp {^\+\s*(.*)$} $line -> line_content]} {
            append line_buffer " "
            append line_buffer $line_content
            continue
        }
        if {$line_buffer!={}} {
            if {[regexp {^\s*section\s+(\S+)} $line_buffer -> section_name]} {
                if {$section_name==$section} {
                    set append 1
                    set line_buffer {}
                    continue
                }
            }
            if {[regexp {^\s*endsection\s+(\S+)} $line_buffer -> section_name]} {
                if {$section_name==$section} {
                    set append 0
                    set line_buffer {}
                    continue
                }
            }
            if {$append} {
                append code $line_buffer
                append code "\n"
            }
            set line_buffer {}
        }
        append line_buffer $line
    }
    close $I
    if {$line_buffer!={}} {
        if {$append} {
            append code $line_buffer
            append code "\n"
        }
    }
    uplevel $code
}
set ::parameter_on 1
proc parameters {args} {
    if {$::parameter_on!=1} return
    regsub -all {\s} $args {} expression
    set expression [split $expression =]
    set param [lindex $expression 0]
    set expression [lindex $expression 1]
    regsub -all {([a-zA-Z][a-zA-Z0-9_]*)} $expression {$\1} expression
    regsub -all {\$([a-zA-Z][a-zA-Z0-9_]*)\(} $expression {\1(} expression
    regsub -all {([0-9])\$([a-zA-Z])} $expression {\1\2} expression
    if {$::section=={}} return
    if {$param=="type"} {
        regsub -all {\$} $expression {} expression
    }
    set ::parameters($::section,$param) $expression
}
proc subckt {args} {
    set ::parameter_on 0
}
proc inline {args} {
    set ::parameter_on 0
}
proc ends {args} {
    set ::parameter_on 1
}
set ::section {}
set ::section_list {}
proc section {name} {
    set ::section $name
    if {[lsearch $::section_list $name]==-1} {
        lappend ::section_list $name
    }
}
set ::model_list {}
proc model {name type args} {
    if {[lsearch $::model_list $name]==-1} {
        lappend ::model_list $name
        set ::model_bins($name) {}
    }
    set payload $args
    if {[llength $payload]==1} {
        set payload [lindex $payload 0]
    }
    foreach line [split $payload \n] {
        if {[regexp {^\s*$} $line]} continue
        if {![regexp {^\s*([0-9]+):\s+(.*)$} $line -> bin expressions]} {
            set bin 0 
            set expressions $line
        } 
        lappend ::model_bins($name) $bin
        regsub -all {([a-zA-Z][a-zA-Z0-9_]*)=} $expressions {|||\1=} expressions
        regsub -all {\s} $expressions {} expressions
        regsub -all {\|\|\|} $expressions { } expressions
        foreach expression $expressions {
            set expression [split $expression =]
            set param [lindex $expression 0]
            set expression [lindex $expression 1]
            regsub -all {([a-zA-Z][a-zA-Z0-9_]*)} $expression {$\1} expression
            regsub -all {\$([a-zA-Z][a-zA-Z0-9_]*)\(} $expression {\1(} expression
            regsub -all {([0-9])\$([a-zA-Z])} $expression {\1\2} expression
            if {$param=="type"} {
                regsub -all {\$} $expression {} expression
            }
            set ::parameters($name,$bin,$param) $expression
        }
    }
}
proc include {file args} {
    Info: INCLUDE $file $args
    if {[regexp {section\s*=\s*(\S+)} $args -> section]} {
        source_rf $file $section
    } else {
        source_rf $file   
    }
}
foreach proc {
    simulator
    ends
    subckt
    parameters
    include
    endsection
    section
    model
    library
    statistics
    endlibrary
    inline
} {
    if {[info procs $proc]!=""} continue
    proc $proc args {}
}
set unknown_list {}
set unknown {
    if {[lsearch $::unknown_list [lindex $args 0]]==-1} {
        lappend ::unknown_list [lindex $args 0]
    }
}
append unknown [info body unknown]
proc unknown args $unknown

#puts [array get ::parameters]

proc calc_var {section model bin varname} {
    upvar #0 $varname var
    if {[info exists var]} return
    set expression {}
    if {[info exists ::parameters($section,$varname)]} {
        set expression $::parameters($section,$varname)
    }
    if {[info exists ::parameters($model,$bin,$varname)]} {
        set expression $::parameters($model,$bin,$varname)
    }
    if {$expression=={}} {
        puts $::O "Warning: missing var: $varname"
        set var 0
        return
    }
    while {[catch {uplevel \#0 "set $varname \[expr $expression\]"} msg]} {
        if {[regexp {"(\S+)"} $msg -> dep_var]} {
            calc_var $section $model $bin $dep_var 
        } else return
    }
}
set ::params_to_ignore {
    minr
    type
}
array set ::version_to_level {
    3.0 49
    3.1 49
    3.2 49
    3.3 49
    3.32 49
    4.0  54
    4.1  54
    4.2  54
    4.3  54
    4.4  54
    4.5  54
    4.6  54
    4.7  54
}
foreach arg [lrange $argv 2 end] {
    if {[regexp {^\-(\S+)$} $arg -> found_key]} {
        set key $found_key
        continue
    }
    set $key $arg
}
default source toplevel.scs
default device nch:pch
default corner {ss tt ff fs sf mc}
default topv 1.8
default tech tsmc018
default vgs_rez 5
default vds_rez 6
default vbs_rez 4
load_tech
set ::rez [join [list $vgs_rez $vds_rez $vbs_rez] :]
if {![file exists $::env(RAMSPICE)/Tech_DB]} {
    file mkdir $::env(RAMSPICE)/Tech_DB
}
if {![file exists $::env(RAMSPICE)/Tech_DB/${tech}]} {
    file mkdir $::env(RAMSPICE)/Tech_DB/${tech}
}
if {![file exists $::env(RAMSPICE)/Tech_DB/${tech}/${::rez}]} {
    file mkdir $::env(RAMSPICE)/Tech_DB/${tech}/${::rez}
}
set output_tech_file $::env(RAMSPICE)/Tech_DB/${tech}/${tech}.sp
if {![file exists $output_tech_file]} {
    textbox "Generating $output_tech_file"
    source_rf $scs
    set ::O [open param.tcl w]
    foreach {key val} [array get ::parameters] {
        puts $::O [list set ::parameters($key) $val]
    }
    set T [open $output_tech_file w]
    foreach model [split $device :] {
        Info: model=$model
        foreach section $corner {
            foreach bin $::model_bins($model) {
                set type $::parameters($model,$bin,type)
                puts $T ".model ${model}_${section}_${bin} ${type}mos \("
                if {[info exists ::parameters($model,$bin,version)]} {
                    set version $::parameters($model,$bin,version)
                } else {
                    set version 3.32
                }
                if {[info exists ::version_to_level($version)]} {
                    puts $T "+ level = $::version_to_level($version)"
                } else {
                    puts $T "+ level = 54"
                }
                set redo 1
                set watchdog 0
                while {$redo && $watchdog<50} {
                    set redo 0
                    foreach param [concat [array names ::parameters $section,*] [array names ::parameters $model,$bin,*]] {
                        set varname [lindex [split $param ,] end]
                        calc_var $section $model $bin $varname
                    }
                }
                foreach {key expression} [array get ::parameters $model,$bin,*] {
                    set param [lindex [split $key ,] end]
                    if {[lsearch $::params_to_ignore $param]!=-1} continue
                    if {![catch {set $param}]} {
                        puts $T "+ $param = [set $param]"
                    } else {
                        puts $T "+ $param = ?"
                    }
                }
                foreach {key expression} [array get ::parameters $section,*] {
                    set param [lindex [split $key ,] end]
                    catch {unset $param}
                }
                foreach {key expression} [array get ::parameters $model,$bin,*] {
                    set param [lindex [split $key ,] end]
                    catch {unset $param}
                }
                puts $T "+ \)\n"
            }
        }
    }
    close $T
    close $::O
}
set ::corner_list $corner
array set ::corner_to_temp {
    ss 125
    tt 27
    ff -40
    fs 27
    sf 27
    mc 27
}
Info: corner_list=$corner_list

proc mosfet {name type D G S B L W {section {}}} {
    set prefix [string index $type 0]
    if {$section=={}} {
        set section [find_mosfet_bin $prefix $L $W]
    }
    set Lmin $::bin($prefix,$section,lmin)
    set sim_corner $::corner
    if {$sim_corner=="mc"} {
        set sim_corner tt
    }
    netlist "$name $D $G $S $B ${type}_${sim_corner}_${section} L=$L W=$W AD=[expr 2.5*$Lmin*$W] AS=[expr 2.5*$Lmin*$W] PD=[expr 5*$Lmin+$W] PS=[expr 5*$Lmin+$W]"
}

textbox {
    #######################################################
    #######################################################
    ##                                                   ##
    ##        Starting characterization processes        ##
    ##                                                   ##
    #######################################################
    #######################################################
}
source $::env(RAMSPICE)/tests/geo_values.tcl
set ::epsilon 1e-2
foreach type [split $device :] {
    set max_supply $topv
    if {[regexp {^p} $type]} {
        set max_supply [expr -$topv]
    }
    set vt_db_file $::env(RAMSPICE)/Tech_DB/${tech}/${::rez}/${tech}_${type}_vt.db
    set va_db_file $::env(RAMSPICE)/Tech_DB/${tech}/${::rez}/${tech}_${type}_va.db
    set min_vt_file $::env(RAMSPICE)/Tech_DB/${tech}/${::rez}/${tech}_${type}_min_vt.tcl
    set ids_file $::env(RAMSPICE)/Tech_DB/${tech}/${::rez}/${tech}_${type}_ids.db
    set gm_file $::env(RAMSPICE)/Tech_DB/${tech}/${::rez}/${tech}_${type}_gm.db
    set go_file $::env(RAMSPICE)/Tech_DB/${tech}/${::rez}/${tech}_${type}_go.db
    set vth_mis_file $::env(RAMSPICE)/Tech_DB/${tech}/${::rez}/${tech}_${type}_vth_mis.db
    set ids_mis_file $::env(RAMSPICE)/Tech_DB/${tech}/${::rez}/${tech}_${type}_ids_mis.db
    if {[file exists $vt_db_file]&&[file exists $min_vt_file]&&[file exists $va_db_file]} {
        source $min_vt_file
    } else {
        textbox    "Characterizing Vt and Va for $type"    
        constrain "
        Vgs  0          $max_supply          $vgs_rez
        Vds  0          $max_supply          $vds_rez
        Vbs  [expr -$max_supply/2]       0            $vbs_rez
        "
        set ::fork_limit 6
        set ::mid_vgs [expr ($topv+0.5)/2]
        set ::min_Ids 1e-12
        set ::scalar_Ids_multiplier 3.9e-11
        set ::limit_Ids_multiplier 1e-1
        set ::minVgs [expr 0.5*$max_supply]
        set ::minVds [expr 0.1*$max_supply]
        set ::maxVds $max_supply
        set ::maxVgs [expr 0.8*$max_supply]
        set ::minVt  $max_supply
        ################################
        set ::low_vgs [expr $max_supply-$::epsilon]
        set ::high_vgs $max_supply
        # Clean droppings
        foreach droppings [glob -nocomplain /tmp/*characterization_task*] {
            file delete $droppings
        }
        foreach droppings [glob -nocomplain /tmp/{ids,gm,go}.*] {
            file delete $droppings
        }
        
        set short_views {Vt Va}
        set views {Ids gm go}
        foreach ::corner $::corner_list {
            set ::temp $::corner_to_temp($::corner)
            fork_task char_vt_task {
                set ::minVt $max_supply
                textbox "Corner [string toupper $::corner], Temperature=$::temp degC"
                ######### Template netlist
                netlist ".include $::env(RAMSPICE)/Tech_DB/${tech}/${tech}.sp"
                netlist {
                    ** the N-transistor
                    * name D G S B model L W 
                }
                set i3 0
                foreach L $l_values {
                    set i4 0
                    foreach W $w_values {
                        netlist ".temp $::temp"
                        # mosfet {name type D G S B L W Lmin}
                        mosfet mn_${i3}_${i4} $type 3 1 ${i3}_${i4} 4 $L $W
                        netlist "r_${i3}_${i4} ${i3}_${i4} 0 1e-12"
                        incr i4
                    }
                    incr i3
                }
                netlist "
                Vds 3 0 dc $max_supply ac 0
                Vgs 1 0 dc $max_supply ac 0
                Vbs 4 0 dc 0 ac 0
                .end
                "
                update_netlist
                
                ######### Initialize database
                Info: Measuring Vt(W,L) $::low_vgs $::high_vgs
                ::spice::dc vgs [expr $max_supply/2-$epsilon] [expr $max_supply/2] $epsilon
                set i2 0
                foreach L $l_values {
                    set i3 0
                    foreach W $w_values {
                        set Ids_low  [::spice::get_spice_data V(${i2}_${i3}) 0]
                        set Ids_high [::spice::get_spice_data V(${i2}_${i3}) 1]
			set slope [expr ($Ids_high-$Ids_low)/$epsilon]
                        set Vt [expr $max_supply/2-$Ids_high/$slope]
                        if {[regexp {^p} $type]} {
                            set Vt [expr -$Vt]
                        }
                        report_vars corner temp Vt L W
                        ^ @ look_up_tables/$type/Vt/${::corner}($i2,$i3) = $Vt
			if {$W/$L<=10.0} {
                            ^ if "abs($Vt)<abs(\$::minVt)" "set ::minVt $Vt"  
			}
                        incr i3
                    }
                    incr i2
                }
                
                Info: Measuring Va(W,L) 
                ::spice::dc vds [expr $max_supply-$epsilon] $max_supply $epsilon 
                set i2 0
                foreach L $l_values {
                    set i3 0
                    foreach W $w_values {
                        set Ids_low  [::spice::get_spice_data V(${i2}_${i3}) 0]
                        set Ids_high [::spice::get_spice_data V(${i2}_${i3}) 1]
			set slope [expr ($Ids_high-$Ids_low)/$epsilon]
                        set Va [expr $max_supply-$Ids_high/$slope]
                        report_vars corner temp Va L W
                        ^ @ look_up_tables/$type/Va/${::corner}($i2,$i3) = $Va
                        incr i3
                    }
                    incr i2
                }  
            }
        }
        foreach ::corner $::corner_list {
            set ::temp $::corner_to_temp($::corner)
            set index_range {}
            foreach var {l w} {
                lappend index_range [llength [set ${var}_values]]
            }
            foreach array $short_views {
                @ /look_up_tables/$type/$array/${::corner}([join $index_range ,]) !
            }
            foreach array $short_views {
                set i3 0
                foreach L $l_values {
                    ::spice::array_set_legend /look_up_tables/$type/$array/$::corner 0 $i3 $L
                    incr i3
                }
                set i4 0
                foreach W $w_values {
                    ::spice::array_set_legend /look_up_tables/$type/$array/$::corner 1 $i4 $W
                    incr i4
                }
            }
        }
        wait_for_forked char_vt_task
        @ /look_up_tables/$type/Vt save $vt_db_file
        @ /look_up_tables/$type/Va save $va_db_file
        
        Info: minVt=$minVt
        set MVT [open $min_vt_file w]
        puts $MVT [list set minVt [set minVt]]
        close $MVT
        # Cleanup
        foreach char_file [glob -nocomplain /tmp/char_vt_task*] {
            file delete $char_file
        }
    }
    if {![file exists $ids_file]||![file exists $gm_file]||![file exists $go_file]} {
        textbox    "Characterizing Ids, gm and go for $type"    
        constrain "
        Vgs  $minVt         $max_supply            $::vgs_rez
        Vds  0              $max_supply            $::vds_rez
        Vbs  [expr -$max_supply/3]           0     $::vbs_rez
        "
        set ::fork_limit 8
        set ::mid_vgs 0.8
        set ::min_Ids 1e-12
        ################################
        # Clean droppings
        foreach droppings [glob -nocomplain /tmp/*characterization_task*] {
            file delete $droppings
        }
        foreach droppings [glob -nocomplain /tmp/{Ids,gm,go}.*] {
            file delete $droppings
        }
        
        set views {Ids gm go}
        foreach ::corner $::corner_list {
            set ::temp $::corner_to_temp($::corner)
            fork_task char_vig_task {
                
                Info: "Corner [string toupper $::corner], Temperature=$::temp degC"
                netlist ".include $::env(RAMSPICE)/Tech_DB/${tech}/${tech}.sp"
                netlist {
                    ** the N-transistor
                    * name D G S B model L W 
                }
                set i3 0
                foreach L $l_values {
                    set i4 0
                    foreach W $w_values {
                        netlist ".temp $::temp"
                        # mosfet {name type D G S B L W Lmin}
                        mosfet mn_${i3}_${i4} $type 3 1 ${i3}_${i4} 4 $L $W
                        netlist "r_${i3}_${i4} ${i3}_${i4} 0 1e-12"
                        incr i4
                    }
                    incr i3
                }
                netlist "Vds 3 0 dc 0 ac 0"
                netlist "Vgs 1 0 dc 0 ac 0"
                netlist "Vbs 4 0 dc 0 ac 0"
                netlist ".end"
                update_netlist
                set index_range {}
                foreach var {Vgs Vds Vbs} {
                    lappend index_range $::constraints($var,index_range)
                }
                lappend index_range [llength $l_values]
                lappend index_range [llength $w_values]
                Info:  Measuring Ids(Vgs,Vds,Vbs) gm(Vgs,Vds,Vbs) and go(Vgs,Vds,Vbs)
                Info:  Vgs ($::constraints(Vgs,minval),$::constraints(Vgs,maxval)) step=$::constraints(Vgs,step)
                Info:  Vds ($::constraints(Vds,minval),$::constraints(Vds,maxval)) step=$::constraints(Vds,step)
                Info:  Vbs ($::constraints(Vbs,minval),$::constraints(Vbs,maxval)) step=$::constraints(Vbs,step)
                Info: simulation started ([clock format [clock seconds]])
                ::spice::dc vgs $::constraints(Vgs,minval) $::constraints(Vgs,maxval) $::constraints(Vgs,step) vds $::constraints(Vds,minval) $::constraints(Vds,maxval) $::constraints(Vds,step) vbs $::constraints(Vbs,minval) $::constraints(Vbs,maxval) $::constraints(Vbs,step)
                Info: done Ids running. Saving results. ([clock format [clock seconds]])
                save_characterization_slice /tmp/Ids.$::corner $index_range 3 2 0 1e12
                ::spice::dc vgs [expr $::constraints(Vgs,minval)+$::epsilon] [expr $::constraints(Vgs,maxval)+$::epsilon] $::constraints(Vgs,step) vds $::constraints(Vds,minval) $::constraints(Vds,maxval) $::constraints(Vds,step) vbs $::constraints(Vbs,minval) $::constraints(Vbs,maxval) $::constraints(Vbs,step) 
                Info: done gm running. Saving results. ([clock format [clock seconds]])
                save_characterization_slice_differential /tmp/gm.$::corner $index_range 3 2 0 [expr 1e12/$::epsilon]
                ::spice::dc vgs $::constraints(Vgs,minval) $::constraints(Vgs,maxval) $::constraints(Vgs,step) vds [expr $::constraints(Vds,minval)+$::epsilon] [expr $::constraints(Vds,maxval)+$::epsilon] $::constraints(Vds,step) vbs $::constraints(Vbs,minval) $::constraints(Vbs,maxval) $::constraints(Vbs,step) 
                Info: done go running. Saving results. ([clock format [clock seconds]])
                save_characterization_slice_differential /tmp/go.$::corner $index_range 3 2 0 [expr 1e12/$::epsilon] 
                Info: is done saving results. ([clock format [clock seconds]])
                Info: Done ([clock format [clock seconds]])
            }
        }
        foreach ::corner $::corner_list {
            set ::temp $::corner_to_temp($::corner)
            ######### Characterizing loops
            set index_range {}
            foreach var {Vgs Vds Vbs} {
                lappend index_range $::constraints($var,index_range)
            }
            lappend index_range [llength $l_values]
            lappend index_range [llength $w_values]
            foreach array $views {
                @ look_up_tables/$type/$array/${::corner}([join $index_range ,]) !
            }
            foreach array $views {
                foreach_in_range Vgs i0 { 
                    ::spice::array_set_legend /look_up_tables/$type/$array/$::corner 0 $i0 $Vgs
                }
                foreach_in_range Vds i1 {
                    ::spice::array_set_legend /look_up_tables/$type/$array/$::corner 1 $i1 $Vds
                }
                foreach_in_range Vbs i2 {
                    ::spice::array_set_legend /look_up_tables/$type/$array/$::corner 2 $i2 $Vbs
                }
                set i3 0
                foreach L $l_values {
                    ::spice::array_set_legend /look_up_tables/$type/$array/$::corner 3 $i3 $L
                    incr i3
                }
                set i4 0
                foreach W $w_values {
                    ::spice::array_set_legend /look_up_tables/$type/$array/$::corner 4 $i4 $W
                    incr i4
                }
            }
        }
        wait_for_forked char_vig_task
        
        foreach ::corner $::corner_list {
            load_characterization_slice /look_up_tables/$type/Ids/$::corner /tmp/Ids.$::corner
            load_characterization_slice /look_up_tables/$type/gm/$::corner /tmp/gm.$::corner
            load_characterization_slice /look_up_tables/$type/go/$::corner /tmp/go.$::corner
            normalize_ids /look_up_tables/$type/Ids/$::corner
            normalize_ids /look_up_tables/$type/gm/$::corner
            normalize_ids /look_up_tables/$type/go/$::corner
        }
        
        @ /look_up_tables/$type/Ids save $ids_file
        @ /look_up_tables/$type/gm save $gm_file
        @ /look_up_tables/$type/go save $go_file
        # Cleanup
        foreach char_file [glob -nocomplain /tmp/char_vig_task*] {
            file delete $char_file
        }
    }
    if {![file exists $vth_mis_file]||![file exists $ids_mis_file]} {
        textbox    "Characterizing Ids and Vt mismatch for $type"    
        set ::fork_limit 6
        @ /struct/dist/type = string
        @ /struct/dist/arg1 = string
        @ /struct/dist/arg2 = string
        set scaling 12
        for {set i 1} {[info exists bin(n,$i,lmin)]} {incr i} {
            @ /simulation_config/mc/nch_mc_$i = string {
                set lef [expr $BSIM_l - 20e-9]
                set wef $BSIM_w 
                set toxn 4.08e-9 
                set geo_fac [expr 1/sqrt($lef*$wef*1e12)]
                set vthmis [expr $scaling*3.635e-3*$geo_fac]
                set dlmis [expr $scaling*4.58e-3*$geo_fac*$lef]
                set dwmis [expr $scaling*3.73e-3*$geo_fac*$wef]
                set toxmis [expr $scaling*1.01e-3*$geo_fac*$geo_fac*$toxn]
            }
            @ /simulation_config/mc/nch_mc_$i/l = /struct/dist gauss * {{$dlmis}}
            @ /simulation_config/mc/nch_mc_$i/w = /struct/dist gauss * {{$dwmis}}
            @ /simulation_config/mc/nch_mc_$i/vth0 = /struct/dist gauss * {{$vthmis}}
            @ /simulation_config/mc/nch_mc_$i/tox = /struct/dist gauss * {{$toxmis}}
        }
        # Clean droppings
        foreach droppings [glob -nocomplain /tmp/*characterization_task*] {
            file delete $droppings
        }
        foreach droppings [glob -nocomplain /tmp/char_{mis,size,ids,gm,ro}*.*] {
            file delete $droppings
        }
        set views {Ids_mis Vth_mis}
        foreach ::corner $::corner_list {
            set ::temp $::corner_to_temp($::corner)
            fork_task char_mis_task {
                textbox "Corner [string toupper $::corner], Temperature=$::temp degC"
                ######### Template netlist
                netlist ".include $::env(RAMSPICE)/Tech_DB/${tech}/${tech}.sp"
                netlist {
                    ** the N-transistor
                    * name D G S B model L W 
                }
                netlist ".temp $::temp"
                set vars_of_interest {}
                set i3 0
                foreach L $l_values {
                    set i4 0
                    foreach W $w_values {
                        # mosfet {name type D G S B L W Lmin}
                        mosfet mn_${i3}_${i4} $type 3 1 ${i3}_${i4} 0 $L $W
                        netlist "r_${i3}_${i4} ${i3}_${i4} 0 1e-12"
                        lappend vars_of_interest mn_${i3}_${i4}
                        lappend vars_of_interest Vth
                        lappend vars_of_interest mn_${i3}_${i4}
                        lappend vars_of_interest Ids
                        incr i4
                    }
                    incr i3
                }
                netlist "
                Vds 3 0 dc $max_supply ac 0
                Vgs 1 0 dc [expr $max_supply/2] ac 0
                .end
                "
                set O [open test.sn w]
                puts $O $template_netlist
                close $O
                update_netlist
                
                Info:  Measuring mis(W,L)
                ######### Characterizing loops
                Info: simulation started ([clock format [clock seconds]])
                set result [monte_carlo_${::bsim_version} 200 /simulation_config/mc $vars_of_interest ::spice::op]
                Info: done Mismatch running. Saving results. ([clock format [clock seconds]])
                Info: Done ([clock format [clock seconds]])
                set i 0
                set i3 0
                foreach L $l_values {
                    set i4 0
                    foreach W $w_values {
                        set Vth [lindex $result $i]
                        incr i
                        set Sigma [lindex $result $i]
                        ^ @ /look_up_tables/$type/Vth_mis/${::corner}($i3,$i4) = [expr $Sigma/$Vth]
                        incr i
                        set Ids [lindex $result $i]
                        incr i
                        set Sigma [lindex $result $i]
                        ^ @ /look_up_tables/$type/Ids_mis/${::corner}($i3,$i4) = [expr $Sigma/$Ids]
                        incr i
                        incr i4
                    }
                    incr i3
                }    
            }
        }
        foreach ::corner $::corner_list {
            set ::temp $::corner_to_temp($::corner)
            ######### Initialize database
            set index_range {}
            foreach var {l w} {
                lappend index_range [llength [set ${var}_values]]
            }
            foreach array $views {
                Info: New Array: look_up_tables/$type/$array/${::corner}([join $index_range ,])
                @ look_up_tables/$type/$array/${::corner}([join $index_range ,]) !
            }
            foreach array $views {
                set i3 0
                foreach L $l_values {
                    ::spice::array_set_legend /look_up_tables/$type/$array/$::corner 0 $i3 $L
                    incr i3
                }
                set i4 0
                foreach W $w_values {
                    ::spice::array_set_legend /look_up_tables/$type/$array/$::corner 1 $i4 $W
                    incr i4
                }
            }
        }
        wait_for_forked char_mis_task
        foreach ::corner $::corner_list {
            set ::temp $::corner_to_temp($::corner)
            foreach array $views {
                generate_lut  /look_up_tables/$type/$array/$::corner
            }
        }
        @ /look_up_tables/$type/Vth_mis save $vth_mis_file
        @ /look_up_tables/$type/Ids_mis save $ids_mis_file
        # Cleanup
        foreach char_file [glob -nocomplain /tmp/char_mis_task*] {
            file delete $char_file
        }
    }
    set noise_complete 1
    foreach ::corner $::corner_list {
        set thermal_noise_file $::env(RAMSPICE)/Tech_DB/${tech}/${::rez}/${tech}_${type}_${::corner}_thermal_noise.db
        set flicker_noise_file $::env(RAMSPICE)/Tech_DB/${tech}/${::rez}/${tech}_${type}_${::corner}_flicker_noise.db
        if {[file exists $thermal_noise_file]} continue
        set noise_complete 0
        break
    }
    if {!$noise_complete} {
#        textbox    "Characterizing Noise for $type Vgs=($minVt,$max_supply) Vds=(0,$max_supply)"    
        textbox    "Characterizing Noise for $type "    
        constrain "
        Vgs  $minVt			$max_supply		7
        Vds  [expr $max_supply/20]	$max_supply		4
        Vbs  [expr -$max_supply/3]	0			1
        "
        set ::fork_limit 1
        foreach old_task_file [glob -nocomplain /tmp/*.tcl] {
            file delete $old_task_file
        }
        set views {flicker_const thermal_noise}
        set total_array_volume 1
        proc noise_cont {coord} {
            @ look_up_tables/$type/flicker_const/${::corner}($coord) = 0
            return -code continue
        }
        set index_range {}
        foreach var {Vgs Vds Vbs} {
            lappend index_range $::constraints($var,index_range)
        }
        lappend index_range [llength $l_values]
        lappend index_range [llength $w_values]
        set_spice_var Captured_Quick_Noise 1
        foreach ::corner $::corner_list {
            set thermal_noise_file $::env(RAMSPICE)/Tech_DB/${tech}/${::rez}/${tech}_${type}_${::corner}_thermal_noise.db
            set flicker_noise_file $::env(RAMSPICE)/Tech_DB/${tech}/${::rez}/${tech}_${type}_${::corner}_flicker_noise.db
            if {[file exists $thermal_noise_file]} continue
            set ::temp $::corner_to_temp($::corner)
            foreach array $views {
                @ look_up_tables/$type/$array/${::corner}([join $index_range ,]) !
            }
            foreach array $views {
                foreach_in_range Vgs i0 { 
                    ::spice::array_set_legend /look_up_tables/$type/$array/$::corner 0 $i0 $Vgs
                }
                foreach_in_range Vds i1 {
                    ::spice::array_set_legend /look_up_tables/$type/$array/$::corner 1 $i1 $Vds
                }
                foreach_in_range Vbs i2 {
                    ::spice::array_set_legend /look_up_tables/$type/$array/$::corner 2 $i2 $Vbs
                }
                set i3 0
                foreach L $l_values {
                    ::spice::array_set_legend /look_up_tables/$type/$array/$::corner 3 $i3 $L
                    incr i3
                }
                set i4 0
                foreach W $w_values {
                    ::spice::array_set_legend /look_up_tables/$type/$array/$::corner 4 $i4 $W
                    incr i4
                }
            }
            textbox "Corner [string toupper $::corner], Temperature=$::temp degC"
            for {set section 1} {[info exists bin(n,$section,lmin)]} {incr section} {}
            ETA $section
            for {set section 1} {[info exists bin(n,$section,lmin)]} {incr section} {
                Info: Analyzing bin $section [clock format [clock seconds]]
		set dummy_flicker 4.3e-12
		set dummy_thermal 5e-11
		set dummy_count_flicker 1
		set dummy_count_thermal 1
                netlist ".include $::env(RAMSPICE)/Tech_DB/${tech}/${tech}.sp"
                netlist ".temp $temp"
                netlist {
                    ** the N-transistor
                    * name D G S B model L W 
                    rtest 3 0 1e-12
                    Vgs 2 0 dc 0 ac 0
                    Vds 4 0 dc 0 ac 0
                    Vbs 1 0 dc 0 ac 0
                }
                # mosfet {name type D G S B L W Lmin}
                mosfet mn_0_0 $type 4 2 3 1 $bin(n,$section,lmin) $bin(n,$section,wmin) $section
                netlist {
                    .end
                }
                update_netlist
                set i3 0
                foreach L $l_values {
                    set i4 0
                    foreach W $w_values {
                        set prefix [string index $type 0]
                        if {$section!=[find_mosfet_bin $prefix $L $W]} {
			    incr i4
			    continue
			}
                        ::spice::alter mn_0_0 w = $W
                        ::spice::alter mn_0_0 l = $L
                        foreach_in_range Vgs i0 {
                            ::spice::alter vgs = $Vgs
                            foreach_in_range Vds i1 {
                                ::spice::alter vds = $Vds
                                foreach_in_range Vbs i2 {
                                    ::spice::alter vbs = $Vbs
                                    ::spice::noise v(3) vgs lin 2 1 2
                                    set thermal_noise [::spice::get_spice_data Captured_Thermal_Noise end]
                                    if {[string match *nan* $thermal_noise]} {
                                        set thermal_noise 0
                                    }
                                    set Ssi [::spice::get_spice_data Captured_Ssi end]
                                    set Captured_EffFreq [::spice::get_spice_data Captured_EffFreq end]
                                    if {[string match *nan* $Captured_EffFreq]} {
                                        noise_cont $i0,$i1,$i2,$i3
                                    }
                                    set flicker_noise [expr $Ssi*$Captured_EffFreq]
                                    if {![regexp {^[0-9\.\-\+e]+$} $flicker_noise]} {
				        Info: flicker_noise=$flicker_noise
                                        set flicker_noise 0
                                    }
                                    ::spice::op
                                    set Ids1 [::spice::get_spice_data V(3) 0]
                                    ::spice::alter vgs = [expr $Vgs+$::epsilon]
                                    ::spice::op
                                    set Ids2 [::spice::get_spice_data V(3) 0]
                                    set gm [expr ($Ids2-$Ids1)*1e12/$::epsilon]
				    if {$gm==0} {
                                        @ look_up_tables/$type/flicker_const/${::corner}($i0,$i1,$i2,$i3,$i4) =  [expr $dummy_flicker/$dummy_count_flicker]
	                                @ look_up_tables/$type/thermal_noise/${::corner}($i0,$i1,$i2,$i3,$i4) = [expr $dummy_thermal/$dummy_count_thermal]
				    } else {
					 if {[catch {@ look_up_tables/$type/flicker_const/${::corner}($i0,$i1,$i2,$i3,$i4) =  [expr sqrt($flicker_noise*$W*$L/($gm*$gm))]}]} {
					     @ look_up_tables/$type/flicker_const/${::corner}($i0,$i1,$i2,$i3,$i4) = [expr $dummy_flicker/$dummy_count_flicker]
					 } else {
					     set dummy_flicker [expr $dummy_flicker+sqrt($flicker_noise*$W*$L/($gm*$gm))]
					     incr dummy_count_flicker
					 }
					 if {[catch {@ look_up_tables/$type/thermal_noise/${::corner}($i0,$i1,$i2,$i3,$i4) = [expr sqrt($thermal_noise/$gm)]}]} {
					     @ look_up_tables/$type/thermal_noise/${::corner}($i0,$i1,$i2,$i3,$i4) = [expr $dummy_thermal/$dummy_count_thermal]
					 } else {
					     set dummy_thermal [expr $dummy_thermal+sqrt($thermal_noise/$gm)]
					     incr dummy_count_thermal
					 }
				    }
				    #report_vars Vgs Vds Vbs W L
				    #Info: thermal_noise=[@ look_up_tables/$type/thermal_noise/${::corner}($i0,$i1,$i2,$i3,$i4)]
				    #Info: flicker_noise=[@ look_up_tables/$type/flicker_const/${::corner}($i0,$i1,$i2,$i3,$i4)]
                                    ::spice::destroy all
                                    ::spice::alter vgs = $Vgs
                                 }
                                ETA
                            }
                        }
                        incr i4
                    }
                    incr i3
                }
            }
            @ /look_up_tables/$type/thermal_noise/$::corner save ${thermal_noise_file}
            @ /look_up_tables/$type/flicker_const/$::corner save ${flicker_noise_file}
        }
    }
}
exit
