# \
exec $RAMSPICE/ramspice $0 $argv
get_opts

if {[info exists opt(help)] || [info exists opt(h)]} {
    puts {
        Convertion utility from Cadence to Spice syntax
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    This program (created by yishai@statter.net) parses a Cadence tech-file and generates a SPICE .model code.
    Usage:
    rf2tcl.tcl -input <SCS tech file> -devices '<list of models>' -corners '<list of corners>'  -globals '<list of global sections>' -tech <technology>
    
    Example:
    rf2tcl.tcl -input rf018.scs -devices 'nch pch' -corners 'ss ff tt fs sf mc' -tech tsmc040
    }
    return
}
set ::temp 27
default ::opt(devices) {nch pch}
default ::opt(corners) {ss tt ff fs sf}
default ::opt(globals) {}
set ::translated_file $::opt(input)
set ::translated_models  $::opt(devices)
set ::translated_sections $::opt(corners)
set ::global_sections  $::opt(globals)
set techfile $::env(RAMSPICE)/Tech_DB/$::opt(tech)/$::opt(tech).sp
set bin_file $::env(RAMSPICE)/Tech_DB/$::opt(tech)/binning_$::opt(tech).tcl
if {![file exists $::env(RAMSPICE)/Tech_DB/$::opt(tech)]} {
    file mkdir $::env(RAMSPICE)/Tech_DB/$::opt(tech)
}
set TECH [open $techfile w]
proc ::tcl::mathfunc::selbin {par1 par2 r1 r2} {
    return [expr $par1>$r1 ? 0:($par2>$r2 ? 1:2)]
}
proc ::tcl::mathfunc::selsd {par1 par2 par3 par4} { 
    return [expr $par1>$par2 ? $par3 : $par4]
}
proc ::tcl::mathfunc::bin3 {bin k0 k1 k2} { 
    return [expr $bin==0 ? $k0: ($bin==1 ? $k1: ($bin==2 ? $k2:$k0))]
}
proc ::tcl::mathfunc::bin12 {bin k1 k2 k3 k4 k5 k6 k7 k8 k9 k10 k11 k12} { 
    return [expr $bin==1 ? $k1: $bin==2 ? $k2: $bin==3 ? $k3: $bin==4 ? $k4: $bin==5 ? $k5: $bin==6 ? $k6: $bin==7 ? $k7: $bin==8 ? $k8: $bin==9 ? $k9: $bin==10 ? $k10: $bin==11 ? $k11: $bin==12 ? $k12:9.99e+09]
}
proc ::tcl::mathfunc::wirange {par r1} { 
    return [expr $par<$r1 ? 1 : 0]
}
array set ::version_to_level {
    3.0 49
    3.1 49
    3.2 49
    3.24 49
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
proc source_rf_section {file section} {
    puts $::LOG "source_rf_section \"$file\" section=$section"
    set append 0
    set code {}
    set line_buffer {}
    set tmp_file /tmp/
    append tmp_file [file tail $file]
    append tmp_file .
    append tmp_file [pid]
    set I [open $file r]
    set O [open $tmp_file w]
    while {[gets $I line]>=0} {
        if {[regexp {^//} $line]} continue
	if {[regexp {^\+\s+(.*)$} $line -> line_content]} {
	    puts -nonewline $O " "
	    puts -nonewline $O $line_content
	} else {
	    puts $O ""
	    puts -nonewline $O $line
	}
    }
    close $O
    close $I
    set I [open $tmp_file r]
    set section_name ""
    while {[gets $I line]>=0} {
        regsub -all {\s+} $line " " line
	if {[regexp {^\s*section\s+(\S+)} $line -> section_name]} {
	    if {$section_name==$section} {
	    	set append 1
	    	continue
	    }
	}
	if {[regexp {^\s*endsection\s+(\S+)} $line -> section_name]} {
	    if {$section_name==$section} {
	    	set append 0
                append code "^|^\}^|^"
	    	continue
	    }
	}
	if {$append} {
	    append code $line
	    append code "^|^"
	}
    }
    close $I
    regsub -all {(\^\|\^\s*)+} $code "\n" code
    uplevel $code
}
proc source_rf_model {file model} {
    puts $::LOG "source_rf_model \"$file\" model=$model"
    set append 0
    set code {}
    set line_buffer {}
    set tmp_file /tmp/
    append tmp_file [file tail $file]
    append tmp_file .
    append tmp_file [pid]
    set I [open $file r]
    set O [open $tmp_file w]
    while {[gets $I line]>=0} {
        if {[regexp {^//} $line]} continue
	if {[regexp {^\+\s+(.*)$} $line -> line_content]} {
	    puts -nonewline $O " "
	    puts -nonewline $O $line_content
	} else {
	    puts $O ""
	    puts -nonewline $O $line
	}
    }
    close $O
    close $I
    set I [open $tmp_file r]
    set model_name ""
    while {[gets $I line]>=0} {
        regsub -all {\s+} $line " " line
	if {[regexp {^\s*model\s+(\S+)} $line -> model_name]} {
	    if {$model_name==$model} {
	    	set append 1
		append code $line
		append code "^|^"
	    	continue
	    }
	}
	if {[regexp {^\s*\}\s*$} $line] && $append} {
	    if {$model_name==$model} {
	    	set append 0
                append code "^|^\}^|^"
	    	continue
	    }
	}
	if {$append} {
	    append code $line
	    append code "^|^"
	}
    }
    close $I
    regsub -all {(\^\|\^\s*)+} $code "\n" code
    uplevel $code
}
set ::parameter_on 1
proc parameters {args} {
     if {$::parameter_on!=1} {
         set ::parameter_on 1
         puts $::LOG "ignored: $args"
         return
     }
     regsub -all {([A-Za-z_][A-Za-z_0-9]*)\s*=} $args {#\1=} param_line
     regsub -all {\s} $param_line {} param_line
     foreach expression [split $param_line #] {
          set expression [split $expression =]
          set param [lindex $expression 0]
          set expression [lindex $expression 1]
          regsub -all {([a-zA-Z_][a-zA-Z0-9_]*)} $expression {$\1} expression
          regsub -all {\$([a-zA-Z_][a-zA-Z0-9_]*)\(} $expression {\1(} expression
          regsub -all {([0-9])\$([a-zA-Z])} $expression {\1\2} expression
          if {$::section=={}} return
          if {$param=="type"} {
              regsub -all {\$} $expression {} expression
          }
          puts $::LOG "$param=$expression ($::section)"
          set ::sec_param($::section,$param) $expression
     }
}
proc subckt {args} {
    set ::parameter_on 0
}
proc inline {args} {
#    set ::parameter_on 0
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
    puts $::LOG "Translating model $name type=$type"
    if {[lsearch $::translated_models $name]==-1} return
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
    if {[regexp {section\s*=\s*(\S+)} $args -> section]} {
        source_rf_section $file $section
    } else {
        source_rf_model $file {} 
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
proc unknown args {if {[lsearch $::unknown_list [lindex $args 0]]==-1} {lappend ::unknown_list [lindex $args 0]}}
set LOG [open /tmp/tech_converter.log w]
foreach model $::translated_models {
    source_rf_model $::translated_file $model
}
foreach section [concat $::translated_sections $::global_sections] {
    set ::parameter_on 1
    source_rf_section $::translated_file $section
}
set ::O [open param.tcl w]
foreach {key val} [array get ::parameters] {
    puts $::O [list set ::parameters($key) $val]
}
foreach {key val} [array get ::sec_param] {
    puts $::O [list set ::sec_param($key) $val]
}
#puts [array get ::parameters]
flush $::O

proc calc_var {section model bin varname} {
    upvar #0 $varname var
    puts $::LOG "[string repeat ... [info level]] calc $varname ($model.$section.$bin)"
    if {[info exists var]} return
    set expression {}
    foreach global_section $::global_sections {
        if {[info exists ::sec_param($global_section,$varname)]} {
            set expression $::sec_param($global_section,$varname)
        }
    }
    if {[info exists ::sec_param($section,$varname)]} {
        set expression $::sec_param($section,$varname)
    }
    if {[info exists ::parameters($model,$bin,$varname)]} {
        set expression $::parameters($model,$bin,$varname)
    }
    if {$expression=={}} {
        puts "missing var: $varname"
        puts $::LOG "missing var: $varname"
        puts $::LOG "[uplevel \"set expression\"]"
	set var 0
	return
        if {[info exists ::setup_defaults($varname)]} {
	    set var $::setup_defaults($varname)
	} else {
            puts $::O "missing var: $varname"
            puts "missing var: $varname"
	    set var 0
	    return
	}
    }
    puts $::LOG "[string repeat ... [info level]]     =    $expression"
    while {[catch {uplevel \#0 "set $varname \[expr $expression\]"} msg]} {
	if {[regexp {"(\S+)".*no such variable} $msg -> dep_var]} {
    	    calc_var $section $model $bin $dep_var 
	} else {
	    puts $::LOG "check expression: $expression"
	    puts $::LOG "$msg"
	    exit
	}
    }
}
set ::params_to_ignore {
    minr
    type
}
set ::params_to_ignore {type}
set dont_repeat {}
foreach model $::translated_models {
    foreach section $::translated_sections {
        foreach geo_bin $::model_bins($model) {
	    set name ${model}_${section}_${geo_bin}
	    if {[lsearch $dont_repeat $name]!=-1} continue
	    lappend dont_repeat $name
	    set type $::parameters($model,$geo_bin,type)
	    puts $TECH ".model $name ${type}mos \("
            if {[info exists ::parameters($model,$geo_bin,version)]} {
            	set version $::parameters($model,$geo_bin,version)
            } else {
            	set version 3.32
            }
            if {[info exists ::version_to_level($version)]} {
            	puts $TECH "+ level = $::version_to_level($version)"
            } else {
            	puts $TECH "+ level = 54"
            }
            set redo 1
	    foreach param [array names ::parameters $model,$geo_bin,*] {
	    	set varname [lindex [split $param ,] end]
	    	calc_var $section $model $geo_bin $varname
	    }
	    foreach {key expression} [array get ::parameters $model,$geo_bin,*] {
	        set param [lindex [split $key ,] end]
		if {[lsearch $::params_to_ignore $param]!=-1} continue
		if {![catch {set $param}]} {
	            puts $TECH "+ $param = [set $param]"
		} else {
		    puts $TECH "+ $param = ?"
		}
	    }
            foreach {key expression} [array get ::sec_param $section,*] {
	        set param [lindex [split $key ,] end]
	        catch {unset $param}
	    }
            foreach {key expression} [array get ::parameters $model,$geo_bin,*] {
	        set param [lindex [split $key ,] end]
	        catch {unset $param}
	    }
	    puts $TECH "+ \)\n"
	}
    }
}
close $::O
close $LOG
close $TECH
set I [open $techfile r]
set lvalues {}
set wvalues {}
while {[gets $I line]>=0} {
    if {[regexp {^\s*\.model\s+\S+_([0-9]+)\s+([np])} $line -> tmp_bin tmp_type]} {
        set current_bin $tmp_bin
        set current_type $tmp_type
        continue
    }
    if {[regexp {^\s*\+\s*([lw])(min|max)\s*=\s*(\S+)} $line -> dim field value]} {
        set ::bin($current_type,$current_bin,$dim$field) $value
        if {[lsearch [set ${dim}values] $value]==-1} {
            lappend ${dim}values $value
        }
        continue
    }
}
close $I
foreach type {n p} {
    foreach key [array names ::bin $type,*,lmin] {
        set section [lindex [split $key ,] 1]
        foreach dim {l w} {
            foreach side {min max} op {> <} {
                if {![info exists ::global_$type$dim$side]} {
                    set ::global_$type$dim$side $::bin($type,$section,$dim$side)
                }
                if "[set ::global_$type$dim$side]$op$::bin($type,$section,$dim$side)" {
                    set ::global_$type$dim$side $::bin($type,$section,$dim$side)
                }
            }
        }
    }    
}
set O [open $bin_file w]
puts $O [list array set ::bin [array get ::bin]]
foreach type {n p} {
    foreach dim {l w} {
        foreach side {min max} {
            puts $O [list set ::global_$type$dim$side [set ::global_$type$dim$side]]
        }
    }
}	
puts $O [list set lvalues [lsort -real $lvalues]]
puts $O [list set wvalues [lsort -real $wvalues]]
foreach option {
    topv flicker_const
} {
    skip {![info exists opt($option)]}
    puts $O [list default opt($option) [set opt($option)]]
}
close $O
exit
