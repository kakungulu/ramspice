source $::env(RAMSPICE)/unknown.tcl
proc foreach_fork {args} {
    set ::main_process 1
    set body {
        if {[fork]} {
            continue
        }
        set ::main_process 0
    }
    append body [lindex $args end]
    set cmd [concat foreach [lrange $args 0 end-1]]
    lappend cmd $body
    uplevel $cmd
}
set ::auto_context_index 0
proc . {} {
    return [string repeat .... [info level]]
}
proc ^ {args} {
    set text $args
    if {[llength $args]==1} {
        set text [lindex $args 0]
    }
    puts $::ParentProcess $text
    flush $::ParentProcess
}
proc sleep {units} {
    set c [clock clicks]
    while {[clock clicks]<$c+$units} {}
}
proc human_volume {bytes} {
    if {$bytes<1024} {
        return $bytes
    }
    foreach suffix {K M G T} {
        set bytes [expr $bytes/1024]
        if {$bytes<1024} {
            return ${bytes}${suffix}
        }
    }
    return ${bytes}T
}
proc fork_task {group_var task {limit {}}} {
    upvar $group_var group
    if {$limit=={}} {
        set limit $::fork_limit 
    }
    if {![info exists group]} {
        set group {}
    }
    while {1} {
        sleep 10000
        set num_of_active [llength [glob -nocomplain /tmp/forked_processes/[pid]-*-running]]
        if {$limit>$num_of_active} break
        #	 Info: $num_of_active forked processes still active. Limit is $limit.
    p    }
    set parent_pid [pid]
    set p [fork]
    if {$p!=0} {
        if {$p!=$parent_pid} {
            Info: Spawned $p
            lappend group $p
            return
        }
    }
    set ::ParentProcess [open /tmp/${group_var}-${parent_pid}-[pid].tcl w]
    exec touch /tmp/forked_processes/${parent_pid}-[pid]-running
    if {[catch {uplevel $task} msg]} {
        Error: $msg "$::errorInfo"
    }
    close $::ParentProcess
    Info: Done 
    exec touch /tmp/forked_processes/${parent_pid}-[pid]
    file delete /tmp/forked_processes/${parent_pid}-[pid]-running
    exit
}
if {![file exists /tmp/forked_processes]} {
    file mkdir /tmp/forked_processes
}
foreach random_fork_signal [glob -nocomplain /tmp/forked_processes/[pid]-*] {
    file delete $random_fork_signal
}
proc limit_min {varname value} {
    upvar $varname var
    if {abs($var)<$value} {
        set var $value
    }
}
proc limit_max {varname value} {
    upvar $varname var
    if {abs($var)>$value} {
        set var $value
    }
}
proc report_vars {args} {
    set text {}
    foreach varname $args {
        upvar $varname $varname
        if {![info exists $varname]} continue
        append text "$varname=[set $varname] "
    }
    Info: $text
}
proc vInfo: {args} {
    set text {}
    foreach varname $args {
        upvar $varname $varname
        if {![info exists $varname]} continue
        append text "$varname=[set $varname] "
    }
    Info: $text
}
proc ladd {listname item} {
    upvar $listname list
    if {![info exists list]} {
        set list $item
	return
    }
    if {[lsearch $list $item]!=-1} return
    lappend list $item
}
proc wait_for_forked {forked_processes_var} {
    upvar $forked_processes_var forked_processes
    set wait 1
    while {$wait} {
        sleep 10000
        set wait 0
        set proc_list {}
        set fork_signal_list [glob -nocomplain /tmp/forked_processes/[pid]-*]
        foreach fork_signal $fork_signal_list {
            if {[regexp {\-([0-9]+)$} $fork_signal -> proc_num]} {
                lappend proc_list $proc_num
            }
        }
        foreach process $forked_processes  {
            if {$process==[pid]} continue
            if {[lsearch $proc_list $process]==-1} {
                set wait 1
                break
            }
        }
    }
    Info: All forked processes from [pid] finished for $forked_processes_var
    foreach file [glob -nocomplain /tmp/${forked_processes_var}-[pid]-*.tcl] {
        source $file
        #	file delete $file
    }
}
proc foreach_fork {iterator_name list body} {
    upvar $iterator_name iterator
    set forked_processes {}
    foreach iterator $list {
        if {[set p [fork]]} {
            lappend forked_processes $p
            continue
        }
        uplevel $body
        Info: Forked process [pid] Finished running
        exit
    }
    Info: Waiting for $forked_processes
    wait_for $forked_processes
}
proc get_cross_time {vec_name {voltage 1.8}} {
    set th [expr $voltage/2]
    return [::spice::get_spice_data $vec_name tx$th]
}
proc get_delay {vec_name1 vec_name2 {voltage 1.8}} {
    return [expr [get_cross_time $vec_name2 $voltage]-[get_cross_time $vec_name1 $voltage]]
}

proc goal {body} {
    if {[llength [split $body \n]]==1} {
        if {[catch {set val [uplevel $body]} msg]} {
            Warning: $msg
            set val -1.0
        }
    } else {
        if {[catch {eval $body} msg]} {
            Warning: $msg
            set val -1.0
        }
    }
    if {![info exists val]} {
        Error: characterization goal did not produce result
        set val -1.0
    }
    upvar key key
    upvar array array_name
    set index "\([join $key ,]\)"
    @ $array_name$index =  $val
    puts "DATUM $val for key=$key"
}
proc change_param {name val} {
    set I [open temp[pid].sn r]
    set O [open temp1[pid].sn w]
    while {[gets $I line]>=0} {
        if {[regexp {^\s*\.param\s+} $line]} {
            regsub -all "$name\\s*=\\s*(\\S+)" $line "$name=$val" line
        }
        puts $O $line
    }
    close $O
    close $I
    file copy -force temp1[pid].sn temp[pid].sn
    file delete temp1[pid].sn
    ::spice::source temp[pid].sn
    file delete temp[pid].sn
}
proc characterize_loop {body} {
    upvar loop loop
    upvar key key
    upvar i i 
    upvar param_values param_values
    upvar dimension dimension
    append loop "set I$i -1\n"
    append loop "set ::L$i \{$param_values\} \n"
    if {$i==1} {
        append loop "foreach C$i \$::L$i \{\n"
    } else {
        append loop "foreach C$i \$::L$i \{\n"
    }
    append loop "incr I$i\n"
    append loop $body
    append key " \$I$i"
    lappend dimension [llength $param_values]
    incr i
}
proc push_vars {varlist pattern_in_var pattern_out_var} {
    upvar $pattern_in_var pattern_in
    upvar $pattern_out_var pattern_out
    set i 0
    set pattern $pattern_in
    foreach var_name $varlist {
        incr i
        upvar $var_name var$i
        regsub -all "@\\\{$var_name\\\}" $pattern [set var$i] pattern 
    }
    set pattern_out $pattern
}
proc characterize {array netlist char_file params body} {
    if {[file exists $char_file]} {
        Info: Characterization file $char_file already exists.
        source $char_file
        return
    }
    set loop "::spice::source temp[pid].sn ; set array $array\n"
    set key {}
    set i 0
    set alters {}
    set O [open temp[pid].sn w]
    puts $O $netlist
    close $O
    set dimension {}
    foreach line [split $params \n] {
        skip {[regexp {^\s*$} $line]}
        skip {[regexp {^\s*\#} $line]}
        regexp {^\s*(\S+)\s+(\S+)\s+(.*)$} $line -> param_type param_name param_values
        if {[regexp {^([^:]+):([^:]+):([^:]+)$} $param_values -> initial step final]} {
            set final_param_values {}
            set value $initial
            while {$value<$final} {
                lappend final_param_values $value
                set value [expr {$value+$step}]
            }
            set param_values $final_param_values
        }
        if {[regexp {^([^:]+):([^:]+)::([^:]+)$} $param_values -> initial final depth]} {
            set step [expr {($final-$initial)/pow(2,$depth)}]
            set final_param_values {}
            set value $initial
            while {$value<$final} {
                lappend final_param_values $value
                set value [expr {$value+$step}]
            }
            set param_values $final_param_values
        }
        switch $param_type {
            var {
                characterize_loop "set $param_name \$C$i\n"
            }
            param {
                characterize_loop "change_param $param_name \$C$i\n"
            }
            device {
                characterize_loop "::spice::alter $param_name = \$C$i\n"
            }
            set {
                append alters "::spice::alter [split $param_name \/] = $param_values\n"
            }
            Set {
                append alters "::spice::set [split $param_name \/] = $param_values\n"
            }
            default {
                Error: Type $param_type not supported in characterization
            }
        }
    }
    append loop "set key \[list [string range $key 1 end]\]\n"
    append loop $alters
    append loop $body
    for {set j 0} {$j<$i} {incr j} {
        append loop "\}\n"
    }
    @ . add string $array
    @ $array add array [join $dimension ,]
    uplevel $loop
    set O [open $char_file w]
    puts $O "@ . add string $array"
    puts $O "@ $array add array [join $dimension ,]"
    for {set j 1} {$j <= $i} {incr j} {
        for {set k 0} {$k<[llength [set ::L$j]]} {incr k } {
            puts $O [list ::spice::array_set_legend $array [expr $j-1] $k [lindex [set ::L$j] $k]]
        }
    }
    puts $O [list ::spice::array_data $array [::spice::array_list $array]]
    close $O
}
proc skip {condition} {
    set ::skip_indication_var 0
    uplevel [list if $condition [list set ::skip_indication_var 1]]
    if {$::skip_indication_var} {
        return -code continue
    }
}
proc network_task_done {task_id} {
    puts "Finished: $task_id"
    lappend ::finished_tasks $task_id
}

proc fork_each {var_name list body args} {
    set ::finished_tasks {}
    set sent_tasks {}
    foreach item $list {
        set sent_body [list set ::template_netlist [set ::template_netlist]]
        append sent_body "\n"
        foreach var $args {
            append sent_body [list set $var [uplevel [list set $var]]]
            append sent_body "\n"
        } 
        append sent_body [list set $var_name $item]
        append sent_body "\n"
        append sent_body $body
        set sent_task_handle [>> $sent_body]
        puts "Info: ([pid]) fork-each task handle: $sent_task_handle"
        if {$sent_task_handle!={}} {
            lappend sent_tasks $sent_task_handle
        }
    }
    set waiting 1
    while {$waiting} {
        set waiting 0
        network_update
        foreach task $sent_tasks {
            puts "looking for $task"
            if {[lsearch $::finished_tasks $task]==-1} {
                set waiting 1
                break
            }
        }
    }
    puts "Forkeach finished!"
}
proc set_param {param value} {
    set ::netlist_parameters($param) $value
}
proc ask {varname {question {}}} {
    upvar $varname var
    if {[info exists var]} return
    if {$question=={}} {
        set question "What's the value of $varname?"
    }
    if {![regexp {\?\s*$} $question]} {
        if {[catch {set var [subst $question]} msg]} {
            while {[regexp {read "(\S+)": no such variable} $msg -> dependent_var]} {
                ask $dependent_var
                catch {set var [subst $question]} msg
            }
        }
        return
    }
    puts "Question: $question"
    gets stdin var
}
set ::top_netlist 1
proc netlist {netlist} {
    if {$::top_netlist} {
        set ::template_netlist ""
    }
    set ::top_netlist 0
    foreach line [split $netlist \n] {
        if {[regexp {^\s*\.include\s+(\S+)} $line -> file]} {
            set I [open $file r]
            netlist [read $I]
            close $I
            append ::template_netlist "\n"
            continue
        }
        append ::template_netlist $line
        append ::template_netlist "\n"
    }
}
proc clear_netlist {} {
    set ::template_netlist ""
}
proc update_netlist {} {
    set ::final_netlist $::template_netlist
    foreach param [array names ::netlist_parameters] {
        regsub -all "@$param\(\[\\s\$\]\)" $::final_netlist "$::netlist_parameters($param)\\1" ::final_netlist
    }
    set O [open temp[pid].sn w]
    puts $O "* Generated from [pid] $::env(USER) $::env(HOSTNAME)"
    puts $O $::final_netlist
    close $O
    ::spice::source temp[pid].sn
    file copy -force temp[pid].sn temp.sn
    file delete temp[pid].sn
    set ::template_netlist {}
}
proc range {iterator_name} {
    set depth [uplevel [list subst $::constraints($iterator_name,depth)]]
    set initial [uplevel [list subst $::constraints($iterator_name,minval)]]
    set final [uplevel [list subst $::constraints($iterator_name,maxval)]]
    set step [expr {($final-$initial)/pow(2,$depth)}]
    set ::constraints($iterator_name,step) $step
    set iterations [expr {int(pow(2,$depth))}]
    set retval {}
    set r $initial
    for {set i 0} {$i<$iterations} {incr i} {
        lappend retval $r
        set r [expr $r+$step]
    }
    lappend retval $final
    return $retval
}
proc foreach_in_range {iterator_name index_name body} {
    upvar $iterator_name iterator
    upvar $index_name index
    set depth [uplevel [list subst $::constraints($iterator_name,depth)]]
    set initial [uplevel [list subst $::constraints($iterator_name,minval)]]
    set final [uplevel [list subst $::constraints($iterator_name,maxval)]]
    set step [expr {($final-$initial)/pow(2,$depth)}]
    set iterations [expr {int(pow(2,$depth))}]
    set retval {}
    set r $initial
    for {set i 0} {$i<$iterations} {incr i} {
        lappend retval $r
        set r [expr $r+$step]
    }
    lappend retval $final
    set index 0
    foreach iterator $retval {
        uplevel $body
        incr index
    }
}
proc ETA {{count {}} {title {}}} {
    if {$count!={}} {
        set ::ETA_TITLE $title
        set ::ETA_COUNT $count
        set ::ETA_INDEX 0
        set ::ETA_START [clock seconds]
        puts "Info: starting loop at [clock format $::ETA_START]"
        return
    }
    incr ::ETA_INDEX
    if {$::ETA_COUNT/100==0} return
    if {($::ETA_COUNT>20)&&($::ETA_INDEX%($::ETA_COUNT/10)!=0)} return
    set current_time [clock seconds]
    set eta [expr int(($current_time-$::ETA_START)*1.0*$::ETA_COUNT/$::ETA_INDEX+$::ETA_START)]
    puts "Info: ${::ETA_TITLE}($::ETA_INDEX/$::ETA_COUNT) est. finish: [clock format $eta -format [list %D %H:%M:%S]]"
}
set ::rusage_fields {
    utime
    stime
    cputime
    maxrss
    ixrss
    idrss
    isrss
    minflt
    majflt
    nswap
    inblock
    oublock
    msgsnd
    msgrcv
    nsignals
    nvcsw
}
proc textbox {text_in {out stdout}} {
    set max_length 0
    foreach line [split $text_in \n] {
        regsub {^\s*} $line {} line
        set line_length [string length $line]
        if {$line_length>$max_length} {
            set max_length $line_length
        }
    }
    puts -nonewline $out "    ##"
    puts -nonewline $out [string repeat \# $max_length]
    puts $out ##
    foreach line [split $text_in \n] {
        regsub {^\s*} $line {} line
        set line_length [string length $line]
        puts -nonewline $out "    # "
        puts -nonewline $out $line
        puts -nonewline $out [string repeat " " [expr $max_length-$line_length]]
        puts $out " #"
        
    }    
    puts -nonewline $out "    ##"
    puts -nonewline $out [string repeat \# $max_length]
    puts $out ##
}
namespace eval SPICE {
}
proc ::SPICE::end {} {
    Info: finished reading circuit
}
proc evaluate {args} {
    foreach varname $args {
        upvar $varname var_$varname
        if {![catch {set retval [expr [set var_$varname]]}]} {
            set var_$varname $retval
        }
    }
}
proc ::SPICE::process_line_buf {} {
    upvar line_buf line_buf
    if {[regexp {^\s*\.(.*)} $line_buf -> code]} {
        uplevel [list namespace eval SPICE $code] 
        set line_buf {}
        return
    }
    uplevel [concat add_instance $line_buf]
    set line_buf {}
}
proc ::SPICE::include {filename} {
    set I [open $filename r]
    set line_buf {}
    while {[gets $I line]>=0} {
        set line [string tolower $line]
        if {[regexp {^\s*\*} $line]} continue
        if {[regexp {^\s*\+(.*)$} $line -> content]} {
            append line_buf " "
            append line_buf $line
            continue
        }
        ::SPICE::process_line_buf
        append line_buf $line
    }
    ::SPICE::process_line_buf
    close $I
}
### set unknown {
###     if {[regexp {^[A-Za-z][0-9_]+\s} $args]} {
###         return [uplevel [concat add_instance $args]]
###     }
###     if {[regexp {^[A-Za-z]_\S+\s} $args]} {
###         return [uplevel [concat add_instance $args]]
###     }
###     if {[regexp {^\.(.*)$} $args -> code]} {
###         if {![catch {set retval [uplevel "::SPICE::$code"]}]} {
###             return $retval
###         }
###         return [uplevel $code]
###     }
###     if {[regexp {^\s*([^\s=]+)\s*=\s*(.*)$} $args -> var expression]} {
###         return [uplevel "set $var \[expr \{$expression\}\]"]
###     }
### }
### append unknown [info body unknown]
### proc unknown args $unknown

proc circuit: {args} {
    Info: creating new circuit: $args
    set temp_file /tmp/empty[pid].sn
    set O [open $temp_file w]
    puts $O "* $args"
    puts $O ".end"
    close $O
    ::spice::source $temp_file
    file delete $temp_file
}
proc ::SPICE::macro {name args} {
    set code_pre [lindex $args end]
    set arguments [lrange $args 0 end-1]
    set code ""
    foreach line [split $code_pre \n] {
        if {[regexp {^\s*\*} $line]} continue
        if {[regexp {^\s*([^\s=]+)\s*=\s*(.*)$} $line -> var expression]} {
            set line "set $var \[expr \{$expression\}\]"
        }
        append code $line
        append code "\n"
    }
    proc ::SPICE::$name $arguments $code
}

proc ::SPICE::repeat {num code} {
    for {set i 0} {$i<$num} {incr i} {
        uplevel $code
    }
}

proc constrain {body} {
    foreach line [split $body \n] {
        if {[regexp {^\s*$} $line]} continue
        if {[regexp {^\s*#} $line]} continue
        if {[regexp {^\s*\/\/} $line]} continue
        set fields {minval maxval depth}
        set varname [lindex $line 0]
        foreach field $fields value [lrange $line 1 end] {
            set ::constraints($varname,$field) $value
        }
        set ::constraints($varname,step) [expr {($::constraints($varname,maxval)-$::constraints($varname,minval))/int(pow(2,$::constraints($varname,depth)))}]
        set ::constraints($varname,index_range) [expr 1+int(pow(2,$::constraints($varname,depth)))]
    }
}
proc find_mosfet_bin {type l w} {
    foreach dim {l w} {
        foreach side {min max} op {< >} {
            if "[set $dim]$op[set ::global_$type$dim$side]" {
                set $dim [set ::global_$type$dim$side]
            }
        }
    }
    foreach key [array names ::bin $type,*,lmin] {
        set section [lindex [split $key ,] 1]
        set hit 1
        foreach dim {l w} {
            foreach side {min max} op {< >} {
                if "[set $dim] $op $::bin($type,$section,$dim$side)" {
                    set hit 0
                }
            }
        }
        if {$hit} {
            return $section
        }
    }
    return -1
}
### if {![info exists ::env(RAMSPICE_BSIM)]} {
    ###     puts "Warning: RAMSPICE_BSIM is not set. Chosing the default 3v32"
    ###     set ::env(RAMSPICE_BSIM) 3v32
### }
### set ::bsim_version $::env(RAMSPICE_BSIM)
### if {![info exists ::env(RAMSPICE_TECH)]} {
    ###     puts "No technology file set up for this session. Choosing from:"
    ###     set techfiles {}
    ###     foreach techfile [glob -nocomplain $::env(RAMSPICE)/*.lib] {
        ###         puts "\t$techfile"
        ###         lappend techfiles $techfile
    ###     }
    ###     set ::env(RAMSPICE_TECH) [lindex $techfiles 0]
    ###     puts "Chose $::env(RAMSPICE_TECH). To change technology, do this before running ramspice:"
    ###     puts "% setenv RAMSPICE_TECH <techfile>"
### }
if {![info exists ::env(HOSTNAME)]} {
    set ::env(HOSTNAME) [exec hostname]
}
### if {![file exists $::env(RAMSPICE_TECH)]} {
    ###     puts "Warning: Tech file $::env(RAMSPICE_TECH), specified in env-var RAMSPICE_TECH, does not exist"
### }
proc load_tech {} {
    default ::opt(tech) tsmc018
    default ::tech $::opt(tech)
    set bin_file $::env(RAMSPICE)/Tech_DB/${::tech}/binning_$::tech.tcl
    if {[file exists $bin_file]} {
        source $bin_file
    } elseif {[file exists $::env(RAMSPICE_TECH)]} {
        set I [open $::env(RAMSPICE_TECH) r]
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
        close $O
    }
    foreach dim {l w} {
        set values {}
        foreach {key value} [array get ::bin n,*,$dim*] {
            skip {[lsearch $values $value]!=-1} 
            lappend values $value
        }
        set values [lsort -real $values]
        set ::${dim}_values {}
        for {set i 0} {$i<[llength $values]-1} {incr i} {
            set this [lindex $values $i]
            set next [lindex $values [expr $i+1]]
            lappend ::${dim}_values $this
            lappend ::${dim}_values [expr $this+($next-$this)*1/3]
            lappend ::${dim}_values [expr $this+($next-$this)*2/3]
        }
    }
}
proc must {varname {error {}}} {
    upvar $varname var
    # default only making a sure a variable is defined with a default value
    if {[info exists var]} return
    if {$error=={}} {
        set error "Variable $varname must be set"
    }    
    Error: $error
    exit
}
proc eng {value {unit {}} } {
    if {[string match *n* $value]} {
        return $value$unit
    }
    if {[catch {expr $value}]} {
        return $value$unit
    }
    if {$value==0.0} {
        return 0
    }
    set sign {}
    if {$value<0.0} {
        set value [expr -$value]
        set sign -
    }
    set kilo 1000.0
    if {$unit=="B"} {
        set kilo 1024.0
    }
    if {$value>1.0 && $value<$kilo} {
        regsub {(\-?[0-9]+\.[0-9]?[0-9]?[0-9]?).*$} $value {\1} value
        return $sign$value$unit
    }
    if {$unit=="%"} {    
        regsub {(\-?[0-9]+\.[0-9]?[0-9]?[0-9]?).*$} [format "%f" $value] {\1} value
        return $sign$value$unit
    }
    set mag [expr int(log($value)/log($kilo))]
    if {$value<1.0} {
        set mag [expr -$mag]
        set mag_qual [lindex {m u n p f a z y e-27 e-30 e-33 e-36} $mag]
        set value [expr $value*pow($kilo,$mag+1)]
    } else {
        set mag_qual [lindex {K M G T P E Z Y e+27 e+30 e+33 e+36} $mag-1]
        set value [expr $value/pow($kilo,$mag)]
    }
    if {$unit=="B"} {
        set value [expr round($value)]
    } else {
        regsub {(\-?[0-9]+\.[0-9]?[0-9]?[0-9]?).*$} $value {\1} value
    }
    append value $mag_qual 
    return $sign$value$unit
}
proc default {varname {val {}}} {
    upvar $varname var
    # default only making a sure a variable is defined with a default value
    if {[info exists var]} return
    #   Info: $varname is not given, using default statement
    # Given a multi-line default value, it is treated as a code that should set the variable
    if {[llength [split $val \n]]>1} {
        if {[catch {uplevel $val} msg]} {
            Warning: $msg
        }
        if {[info exists var]} return
        # If the given code did not do the trick, the var is set to {} after a warning
        Warning: $varname was not defined by code passed to a default statement
        set var {}
        return
    }
    if {[catch {uplevel "set $varname \[subst \{$val\}\]"} msg]} {
        Warning: $msg
        set var {}
    }
}
proc get_opts {} {
    foreach arg [lrange $::argv 2 end] {
        if {[regexp {^\-([A-Za-z][a-z_0-9]*)$} $arg -> found_key]} {
            set key $found_key
            set $key {}
            continue
        }
        set ::opt($key) $arg
    }
}
source $::env(RAMSPICE)/Gamma/.Gamma.tcl
textbox {
    RAMSpice: Colorado State University version of NGSPICE
    Rewritten by Yishai Statter as part of PhD requirements
    Advisor: Dr Tom Chen
}
puts version=[clock format [file mtime $::env(RAMSPICE)/ramspice]]


