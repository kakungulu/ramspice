proc unknown {args} {
    variable ::tcl::UnknownPending
    global auto_noexec auto_noload env tcl_interactive
    # HTML stuff
    if {[regexp {^<} $args] && [info exists ::web_output]} {
        default ::HTML stdout
        regsub -all {\\\"} $args "\"" html_line
#	puts $html_line
	if {$::web_output==1} {
	    puts $::HTML $html_line
	} else {
	    append $::web_output $html_line
	}
	return
    }
    
    # Bus notation support
    if {[regexp {^[0-9]+$} $args]} {
        return "\[$args\]"
    }
    
    # polish to expression conversion
    if {[regexp {^expr(\S+)\s} $args -> op]} {
        return [concat $op [lrange $args 1 end]]
    }
    
    # Support for Spice cards
    if {[regexp {^[mM](\S+)\s+(.*)$} $args -> name arguments]} {
        eval "add_transistor $name $arguments"
        return
    }
    if {[regexp {^[vV](\S+)\s+(.*)$} $args -> name arguments]} {
        eval "add_vdc $name $arguments"
        return
    }
    if {[regexp {^[iI](\S+)\s+(.*)$} $args -> name arguments]} {
        eval "add_idc $name $arguments"
        return
    }
    if {[regexp {^[rR](\S+)\s+(.*)$} $args -> name arguments]} {
        eval "add_resistor $name $arguments"
        return
    }
    if {[regexp {^([A-Za-z_/:][:/A-Za-z0-9_]*)\s*=>\s*(.*)$} $args -> var expression]} {
        set ::DEF($var) $expression
	return
    }
    if {[regexp {^[A-Za-z_/:][:/A-Za-z0-9_]*\s*=} $args]} {
        Info: Gamma Calculation $args
        uplevel ".let $args"
	return
    }
    
    # Report generator indentation
    if {[regexp {^(\*+)(.*)$} $args -> bullet payload]} {
        set indent [string length $bullet]
        incr indent -1
        set index [lindex $::report_index_list $indent]
        if {$index=={}} {
            set index 0
        }
        incr index
        incr indent -1
        set ::report_index_list [concat [lrange $::report_index_list 0 $indent] $index]
        set ::report_index [join $::report_index_list .]
        return [uplevel $payload]
    }
    # If the command word has the form "namespace inscope ns cmd"
    # then concatenate its arguments onto the end and evaluate it.

    set cmd [lindex $args 0]
    if {[regexp "^:*namespace\[ \t\n\]+inscope" $cmd] && [llength $cmd] == 4} {
	#return -code error "You need an {*}"
        set arglist [lrange $args 1 end]
	set ret [catch {uplevel 1 ::$cmd $arglist} result opts]
	dict unset opts -errorinfo
	dict incr opts -level
	return -options $opts $result
    }

    catch {set savedErrorInfo $::errorInfo}
    catch {set savedErrorCode $::errorCode}
    set name $cmd
    if {![info exists auto_noload]} {
	#
	# Make sure we're not trying to load the same proc twice.
	#
	if {[info exists UnknownPending($name)]} {
	    return -code error "self-referential recursion in \"unknown\" for command \"$name\"";
	}
	set UnknownPending($name) pending;
	set ret [catch {
		auto_load $name [uplevel 1 {::namespace current}]
	} msg opts]
	unset UnknownPending($name);
	if {$ret != 0} {
	    dict append opts -errorinfo "\n    (autoloading \"$name\")"
	    return -options $opts $msg
	}
	if {![array size UnknownPending]} {
	    unset UnknownPending
	}
	if {$msg} {
	    if {[info exists savedErrorCode]} {
		set ::errorCode $savedErrorCode
	    } else {
		unset -nocomplain ::errorCode
	    }
	    if {[info exists savedErrorInfo]} {
		set ::errorInfo $savedErrorInfo
	    } else {
		unset -nocomplain ::errorInfo
	    }
	    set code [catch {uplevel 1 $args} msg opts]
	    if {$code ==  1} {
		#
		# Compute stack trace contribution from the [uplevel].
		# Note the dependence on how Tcl_AddErrorInfo, etc. 
		# construct the stack trace.
		#
		set errorInfo [dict get $opts -errorinfo]
		set errorCode [dict get $opts -errorcode]
		set cinfo $args
		if {[string bytelength $cinfo] > 150} {
		    set cinfo [string range $cinfo 0 150]
		    while {[string bytelength $cinfo] > 150} {
			set cinfo [string range $cinfo 0 end-1]
		    }
		    append cinfo ...
		}
		append cinfo "\"\n    (\"uplevel\" body line 1)"
		append cinfo "\n    invoked from within"
		append cinfo "\n\"uplevel 1 \$args\""
		#
		# Try each possible form of the stack trace
		# and trim the extra contribution from the matching case
		#
		set expect "$msg\n    while executing\n\"$cinfo"
		if {$errorInfo eq $expect} {
		    #
		    # The stack has only the eval from the expanded command
		    # Do not generate any stack trace here.
		    #
		    dict unset opts -errorinfo
		    dict incr opts -level
		    return -options $opts $msg
		}
		#
		# Stack trace is nested, trim off just the contribution
		# from the extra "eval" of $args due to the "catch" above.
		#
		set expect "\n    invoked from within\n\"$cinfo"
		set exlen [string length $expect]
		set eilen [string length $errorInfo]
		set i [expr {$eilen - $exlen - 1}]
		set einfo [string range $errorInfo 0 $i]
		#
		# For now verify that $errorInfo consists of what we are about
		# to return plus what we expected to trim off.
		#
		if {$errorInfo ne "$einfo$expect"} {
		    error "Tcl bug: unexpected stack trace in \"unknown\"" {}  [list CORE UNKNOWN BADTRACE $einfo $expect $errorInfo]
		}
		return -code error -errorcode $errorCode  -errorinfo $einfo $msg
	    } else {
		dict incr opts -level
		return -options $opts $msg
	    }
	}
    }

    if {([info level] == 1) && ([info script] eq "")  && [info exists tcl_interactive] && $tcl_interactive} {
	if {![info exists auto_noexec]} {
	    set new [auto_execok $name]
	    if {$new ne ""} {
		set redir ""
		if {[namespace which -command console] eq ""} {
		    set redir ">&@stdout <@stdin"
		}
		uplevel 1 [list ::catch  [concat exec $redir $new [lrange $args 1 end]]  ::tcl::UnknownResult ::tcl::UnknownOptions]
		dict incr ::tcl::UnknownOptions -level
		return -options $::tcl::UnknownOptions $::tcl::UnknownResult
	    }
	}
	if {$name eq "!!"} {
	    set newcmd [history event]
	} elseif {[regexp {^!(.+)$} $name -> event]} {
	    set newcmd [history event $event]
	} elseif {[regexp {^\^([^^]*)\^([^^]*)\^?$} $name -> old new]} {
	    set newcmd [history event -1]
	    catch {regsub -all -- $old $newcmd $new newcmd}
	}
	if {[info exists newcmd]} {
	    tclLog $newcmd
	    history change $newcmd 0
	    uplevel 1 [list ::catch $newcmd  ::tcl::UnknownResult ::tcl::UnknownOptions]
	    dict incr ::tcl::UnknownOptions -level
	    return -options $::tcl::UnknownOptions $::tcl::UnknownResult
	}

	set ret [catch {set candidates [info commands $name*]} msg]
	if {$name eq "::"} {
	    set name ""
	}
	if {$ret != 0} {
	    dict append opts -errorinfo  "\n    (expanding command prefix \"$name\" in unknown)"
	    return -options $opts $msg
	}
	# Filter out bogus matches when $name contained
	# a glob-special char [Bug 946952]
	if {$name eq ""} {
	    # Handle empty $name separately due to strangeness
	    # in [string first] (See RFE 1243354)
	    set cmds $candidates
	} else {
	    set cmds [list]
	    foreach x $candidates {
		if {[string first $name $x] == 0} {
		    lappend cmds $x
		}
	    }
	}
	if {[llength $cmds] == 1} {
	    uplevel 1 [list ::catch [lreplace $args 0 0 [lindex $cmds 0]]  ::tcl::UnknownResult ::tcl::UnknownOptions]
	    dict incr ::tcl::UnknownOptions -level
	    return -options $::tcl::UnknownOptions $::tcl::UnknownResult
	}
	if {[llength $cmds]} {
	    return -code error "ambiguous command name \"$name\": [lsort $cmds]"
	}
    }
    return "\[$args\]"
}
