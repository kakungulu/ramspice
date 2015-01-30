# \
exec $RAMSPICE/ramspice $0 $argv
get_opts

foreach arg [lrange $argv 2 end] {
    if {[regexp {^\-(\S+)$} $arg -> found_key]} {
        set key $found_key
	set $key {}
        continue
    }
    set $key $arg
}

default opt(tech) tsmc040
default ::randomized {}
set tech $opt(tech)
source $::env(RAMSPICE)/Tech_DB/$::opt(tech)/binning_$::opt(tech).tcl

set ::mho &#x2127
set ::ohm &#x2126
default opt(port) 1024
set ::port $opt(port)
while {[catch {set socket [socket -server server $::port]}]} {
    incr ::port
}
proc server {chan addr port} {
    fconfigure $chan -buffering line ;# NOT -blocking 0 (see below!)
    while {[gets $chan line]>=0} {
        puts $line
        if {[catch $line res]} {
            Error: $res
	    Error: $::errorInfo
            continue
        }
        puts $chan $res
	flush $chan
        break
    }
    close $chan
}
proc respond {code body {head ""}} {
    return "HTTP/1.0 $code ???\nContent-Type: text/html; charset=ISO-8859-1\nConnection: close\n$head\n$body"
}
set ::solution {}
proc Log: {args} {
    set text $args
    if {[llength $text]==1} {
        set text [lindex $text 0]
    }
    regsub -all {\$:*} $text {} text
    regsub -all {\[\s*LUT\s+(\S+)\s+([^\]]+)\]} $text {\1(\2)} text
    append ::solution "$text<br>\n"
}
set ::open_fields {}
proc GET {args} {
    foreach var $::reset_list {
        set ::$var {}
    }
    array unset ::original_value
    set error {}
    set ::tolerance_analysis 0
    if {[regexp {\?(\S+)\s} $args -> assignment_list]} {
        set ::open_fields {}
	set ::randomized {}
        foreach assignment [split $assignment_list &] {
            set field [lindex [split $assignment =] 0]
            set value [lindex [split $assignment =] 1]
	    de_http field
	    de_http value
	    set ::original_value($field) $value
            if {$value!={}} {
	        if {[regexp {^\s*([xyz])\s*(\S*)} $value -> axis goal]} {
		    set ::tolerance_analysis 1
		    set ::tolerance($axis) $field
		    set value $goal
		}
	        if {$value=="#"} {
		    Info: Random value for $field: $::const($field,min) $::const($field,max)
		    set value "rand()*($::const($field,max)-$::const($field,min))+$::const($field,min)"
		    lappend ::randomized $field
		} 
		if {![catch {set expr_value [uplevel \#0 "expr $value"]}]} {
                    set value $expr_value
		    if {$::const($field,factor)!="-"} {
		        append value "*($::const($field,factor))"
		    }
                    if {$::const($field,min)!={}} {
                        set min $::const($field,min)
                        if {![catch {set expr_min [uplevel \#0 "expr $min"]} msg]} {
                            set min $expr_min
                        } else {
			    Error: $msg
			}
                        if {$value<$min} {
                            append error "$field was assigned a value outside predefined limits: $value<$min<br>"
                            continue
                        }
                    }
                    if {$::const($field,max)!={}} {
                        set max $::const($field,max)
                        if {![catch {set expr_max [uplevel \#0 "expr $max"]} msg]} {
                            set max $expr_max
                        } else {
			    Error: $msg
			}
                        if {$value>$max} {
                            append error "$field was assigned a value outside predefined limits: $value>$max<br>"
                            continue
                        }
                    }
                }
	        Info: Setting $field to $value
            } else {
	        lappend ::open_fields $field
	    }
            set ::$field $value
        }
	set ::solution {}
	set ::step_index 0
	set ::taboo_list {}
	pre_calculate
       if {[catch calculate msg]} {
	append error [concat $msg <br> $::errorInfo]
     }
	post_calculate
    }
    if {$error!={}} {
        Error: $error
    }
    set I [open /tmp/tmp.html r]
    append post_solution [read $I]
    close $I
    append post_solution $::solution
    return [respond 200 "<html><body>[subst $::HTML]<font color=\"red\">$error</font>$post_solution</body></html>"]
}
proc post_calculate {} {}
proc de_http {varname} {
    upvar $varname var
    while {[regexp {^(.*)%([0-9A-Fa-f][0-9A-Fa-f])(.*)$} $var -> pre code post]} {
        set var $pre
	append var [format "%c" 0x$code]
	append var $post
    }
}
set unknown {
    if {[string match *: [lindex $args 0]]} {
        Info: ignoring unknown command $args
        return
    }	
}
append unknown [info body unknown]
proc unknown args $unknown
set ::fields {}
set ::form_fields {}
set ::target_fields {}
set ::source_fileds {}
set ::Lmin 180e-9
proc form_sep {title} {
    lappend ::form_fields [list @sep $title]
}
proc form_field {field display factor type default min max unit} {
    lappend ::fields $field
    lappend ::form_fields $field
    set ::$field $default
    if {$type=="text"} {
        set ::const($field,type) "type=\"$type\""
    } else {
        set ::const($field,type) "list=\"$type\""
    }
    if {$min!={} && $max!={}} {
        set min [uplevel \#0 "expr $min"]
        set max [uplevel \#0 "expr $max"]
        set ::const($field,min) $min
        set ::const($field,max) $max
    } else {
        set ::const($field,min) $min
        set ::const($field,max) $max
    }
    if {$::const($field,min)>$::const($field,max)} {
        set tmp $::const($field,min)
	set ::const($field,min) $::const($field,max)
	set ::const($field,max) $tmp
    }
    set ::const($field,unit) $unit
    if {$display=="-"} {
        set display $field
    } 
    set ::const($field,display) $display
    set ::const($field,factor) $factor
}
proc min {a b} {
    if {$a<$b} {
        return $a
    }
    return $b
}

proc gen_form {} {
    set retval "<table border=\"1\"><tr><td align=\"center\"><b>Parameter</b></td><td align=\"center\"><b>Input</b></td><td align=\"center\"><b>Calculation</b></td><td align=\"center\"><b>Source</b></td><td align=\"center\"><b>Simulation</b></td><td align=\"center\"><b>|Error|</b></td><td align=\"center\"><b>Error\[%\]</b></td></tr>"
    foreach field $::form_fields {
	if {[lindex $field 0]=="@sep"} { 
	 append retval "<tr><td colspan=\"7\"><h3>[lindex $field 1]</h3></td></tr>"
	 continue
        }
        set value [set ::$field]
        if {$value!={}} {
            if {[catch {set value [uplevel \#0 "expr $value"]}]} {
                set value [set ::$field]
            }
        } 
        set width [expr 80-[string length $field]]
	set sim_value ""
	set abs_err ""
	set rel_err ""
	if {[info exists ::simulated($field)]} {
	    set sim_value [eng $::simulated($field) $::const($field,unit)]
	    Info: $field value=$value sim=$::simulated($field)
	    if {[catch {set abs_err [eng [expr $value-$::simulated($field)] $::const($field,unit)]}]} {
	        set abs_err 0
	    }
	    if {[catch {set rel_err [eng [expr ($value/$::simulated($field)-1)*100] %]}]} {
	        set rel_err 0
	    }
	}
	set hint [eng $::const($field,min) $::const($field,unit)] 
	append hint "   -   "
	append hint [eng $::const($field,max) $::const($field,unit)]
	set field_token "<div title=\"$hint\">$::const($field,display)</div>"
	 if {![info exists ::step_lookup($field)]} {
	     set step_reference (defaulted)
	 } else {
	     set step_reference "(step $::step_lookup($field))"
	 }
	 set display_value {}
	 if {[info exists ::original_value($field)]} {
	     set display_value $::original_value($field)
	 }
	 set input_color black
	 if {$::Distance>=$::Tolerance} {
	     set input_color red
	 }
	 append retval "<tr><td>$field_token</td><td><input $::const($field,type) name=\"$field\" value=\"$display_value\" width=\"$width\" style=\"color: $input_color;\"></td><td>[eng $value $::const($field,unit)]</td><td>$step_reference</td><td>$sim_value</td><td>$abs_err</td><td>$rel_err</td></tr>"
    }
    append retval "</table>"
    return $retval
}
proc LUT {name corner args} {
    if {![@ /look_up_tables/$::device/$name/$corner exists]} {
        Warning: look up in $name:  $args => does not exist
	return -1
    }
    set retval [uplevel \#0 "@ /look_up_tables/$::device/$name/$corner calc $args"]
   #  Info: @ /look_up_tables/$::device/$name/$corner calc $args => $retval
    if {[string match *n* $retval]} return -1
    if {[string match *N* $retval]} return -1
  #  Info: look up in $name ($::device):  $args => $retval
    return $retval
}
############ Solver
set ::link_index 0
set ::reset_list {}
proc link_bwd {var dep code} {
   set ::calc($::link_index,var) $var
   set ::calc($::link_index,code) [regsub -all {\$:*} $code {$::}]
   set ::calc($::link_index,dir) bwd
   set ::calc($::link_index,dep) $dep
   default ::calc_list($var) 
   lappend ::calc_list($var) $::link_index
   incr ::link_index
}
proc link {var code args} {
   default ::$var 
   if {[lsearch $::fields $var]==-1} {
       lappend ::reset_list $var
   }
   if {[lsearch $::target_fields $var]==-1} {
       lappend ::target_fields $var
   }
   set ::calc($::link_index,var) $var
   set ::calc($::link_index,code) [regsub -all {\$:*} $code {$::}]
   set ::calc($::link_index,dir) fwd
   regsub -all {\$([A-Za-z_0-9]+)} $code {`$\1`} var_list
   set varlist $var
   foreach section [split $var_list `] {
       if {[regexp {\$([A-Za-z_0-9]+)} $section -> varname]} {
           if {[lsearch $varlist $varname]==-1} {
	       lappend varlist $varname
	   }
       }
   }
   set ::calc($::link_index,dep) [lrange $varlist 1 end]
   default ::calc_list($var) 
   lappend ::calc_list($var) $::link_index
   incr ::link_index
   for {set i 1} {$i<[llength $varlist]} {incr i} {
       set pre [expr $i-1]
       set post [expr $i+1]
       link_bwd [lindex $varlist $i] [concat [lrange $varlist 0 $pre] [lrange $varlist $post end]] $code 
   }
   foreach {flag value} $args {
       switch $flag {
           "-unit" {
               set ::const($var,unit) $value
	   }
	   "-min" {
               set ::const($var,min) $value
	   }
	   "-max" {
               set ::const($var,max) $value
	   }
       }
   }
}
proc untaboo {var} {
    if {[set i [lsearch $::taboo_list $var]]!=-1} {
        set ::taboo_list [lreplace $::taboo_list $i $i]
    }
}
proc . {} {
    return [string repeat . [info level]]
}
proc calc_var {i} {
    if {$::device=="pch"} {
        foreach var {::Vgs ::Vds ::Vbs} {
	    set $var [expr -[set $var]]
	}
    }
    set val [subst $::calc($i,code)]
    if {[catch "expr $val" msg]} {
        Log: $msg
    if {$::device=="pch"} {
        foreach var {::Vgs ::Vds ::Vbs} {
	    set $var [expr -[set $var]]
	}
    }
        return $val
    }
    set retval [eval "expr $val"]
    set name $::calc($i,var)
    if {![info exists ::track($name)]} {
        set ::track($name) $retval
    } else {
        set change [expr abs($retval/$::track($name)-1)*100]
	if {$change>$::max_change} {
	    set ::max_change $change
	}
    }
    if {$::device=="pch"} {
        foreach var {::Vgs ::Vds ::Vbs} {
	    set $var [expr -[set $var]]
	}
    }
    return $retval
}

#/**
# * Recursively tries to calculate each variable it's given
# * By default, all form-fields are calculated
# * @param  $varlist - a list of variables to calculate
# */

proc calculate {{varlist {}}} {
   # By default, calculate every field
   set ::max_change 0
   set vars_to_be_calculated $varlist
   if {$varlist=={}} {
       set vars_to_be_calculated $::fields
   }
   # A signal to the upper level in the recursion that this variable list cannot be completed
   # and another expression may be needed to calculate the variable
   set backtrack_from_this_calculation 0
   # Scan all variables
   foreach var $vars_to_be_calculated {
       # No need to re-calculate a variable that has assigned value
       if {[set ::$var]!={}} continue
       # Taboo-list is used to prevent infinite loops on dependence cycles
       lappend ::taboo_list $var
       for {set i 0} {$i<$::link_index} {incr i} {
           if {$::calc($i,var)!="$var"} continue
	   if {$::calc($i,dir)!="fwd"} continue
	   # If I'm here, I found a direct expression
	   # First make sure there are no dependece cycles in this expression
	   set backtrack 0
	   foreach dep_var $::calc($i,dep) {
	       if {[lsearch $::taboo_list $dep_var]!=-1 && [set ::$dep_var]=={}} {
	           set backtrack 1
		   break
	       }
	   }
	   if {$backtrack} continue
	   # Now decend into each variable and calculate it recursively
	   if {[calculate $::calc($i,dep)]} continue
	   # If I'm here, the variables this one depends on are calculated and the chosen expression is ready to be calculated
	   # Log the calculation step for the HTML page
	   incr ::step_index
	   Log: 
	   Log: $::step_index Calculating $var based on $::calc($i,dep)
	   
	   # Calculate the variable !
	   set ::$var [calc_var $i]
	   
	   #remove it from the taboo list. Cycles containing this variables are broken anyway because it is assigned a value 
	   untaboo $var
	   # Log the result
	   set unit {}
	   if {[info exists ::const($var,unit)]} {
	       set unit $::const($var,unit)
	   }
	   Log: $var=$::calc($i,code)=[eng [set ::$var] $unit]
	   set ::step_lookup($var) $::step_index
	   break
       }
       # Go to the next var if done
       if {[set ::$var]!={}} continue
       set backtrack_from_this_calculation 1
       set ::$var {}
       untaboo $var
   } 
   if {$varlist!={}} {
      return $backtrack_from_this_calculation
   }
   
   # Now for the more expensive and expansive solver: the randomized sample, deflating solution-space search
   set independent_vars {}
   foreach var $::source_fields {
       set val [set ::$var]
       if {[set ::$var]=={}} {
     	   lappend independent_vars $var
     	   set centre($var) [expr "($::const($var,min)+$::const($var,max))/2"]
       }
   }
   if {$independent_vars=={}} return
   set dependent_vars {}
   foreach var $::target_fields {
       if {[set ::$var]!={}} {
     	   set target_value($var) [set ::$var]
     	   lappend dependent_vars $var
       }
       set ::$var {}
   }
   # Do this N times: from a sample of M coordinate combinations pick the one with the minimal squared-error and centre the next solution space arround it.
   # Each space is the size of the original divided by the iteration number: 1 1/2 1/3 .... 1/N
   # To make sure the error is only descending, only reset the error variable at the top level and then update the centroid only if smaller error figure found.
   set error {}
   for {set iteration 1} {$iteration<=2} {incr iteration} {
       set ::max_change 0
       # Find span for each variable. Make sure to clip the solution space according to original min/max figures
       foreach var $independent_vars {
     	   set span [expr "($::const($var,max)-$::const($var,min))/$iteration"]
     	   set min($var) [expr $centre($var)-$span/2]
     	   set max($var) [expr $centre($var)+$span/2]
	   # Clip min and max to top-level feasible boundaries
     	   if {$min($var)<$::const($var,min)} {
     	       set min($var) $::const($var,min)
     	   }
     	   if {$max($var)>$::const($var,max)} {
     	       set max($var) $::const($var,max)
     	   }
       }
       # Withing the shrinking solution space, draw M samples and calculate square-error for each
       for {set sample_index 0} {$sample_index<64} {incr sample_index} {
           # Get a random value per independent variable
     	   foreach var $independent_vars {
	       set ::$var [expr $min($var)+rand()*($max($var)-$min($var))]
	   }
	   # Run calculation "forward" as above
	   calculate $dependent_vars
	   # Calculate square-error
	   set local_error 0
	   foreach var $dependent_vars {
	       set local_error [expr $local_error+pow([set ::$var]-$target_value($var),2)]
	 #      set local_error [expr ($local_error)*$::L*$::W]
	   }
	   # A new minimizer? If so, keep it as the next centre for the next iteration
	   if {$error=={} || $local_error<$error} {
	       set error $local_error
	       foreach var $independent_vars {
	           set centre($var) [set ::$var]
	       }
	   }
	   # Reset the fields so the next call to calculate doesn't skip them
           foreach var $::target_fields {
               set ::$var {}
           }
       }
 #      Info: error=$error
#       if {$::max_change<0.01 && $i>3} break
   }
   # Searched variables still show in the report, although I need to find a creative way to make it convincing.
   set ::solution {}
   set ::step_index 0
   foreach var $independent_vars {
       set ::$var $centre($var)
       incr ::step_index
       Log: 
       Log: $::step_index $var was automatically searched to fit given $dependent_vars
       set unit {}
       if {[info exists ::const($var,unit)]} {
           set unit $::const($var,unit)
       }
       Log: $var=[eng [set ::$var] $unit]
       set ::step_lookup($var) $::step_index
   }
   # The rest of the report is populated with this final calculation, which shouldn't end with a search (all independents were searched)
   calculate $::target_fields
}

##### Import circuit-specific fields and rules
source $::env(RAMSPICE)/sizer_functionality.tcl
foreach field $::fields {
    if {[lsearch $::target_fields $field]==-1} {
        lappend ::source_fields $field
    }
}
####################
Info: [.] Ready! Log into: $::env(HOSTNAME):$::port
vwait forever

