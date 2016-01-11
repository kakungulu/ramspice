proc calculate_size {size_var} {
    upvar $size_var size
    # Info: calculating $size_var=$size
    while {[regexp {^(.*)@([a-zA-Z0-9_:]+)(.*)$} $size -> pre c post]} {
    #    Info: c=$c=[@ $c]
        set size $pre
	append size [@ $c]
	append size $post
    }
    if {[catch {set val [expr $size]}]} {
        set size [@ $size]
    } else {
        set size $val
    }
   # Info: = $size
}
default ::squares 1
proc generate_spice_netlist {selected_tech selected_topology {stimulus 0.00025}} {
    source $::env(RAMSPICE)/Etc/Tech_DB/$selected_tech/binning_$selected_tech.tcl
    set netlist {}
    set topology_file $::env(RAMSPICE)/Etc/Topologies/$selected_topology.gsp
    set ::required_models {}
    set I [open $topology_file r]
    while {[gets $I line]>=0} {
        switch -regexp [string index $line 0] {
            m {
                set name [string range [lindex $line 0] 1 end]
                lassign [lrange $line 1 4] d g s b
                if {![regexp {W=(\S+)} $line -> W]} {
                    Error: No width param in topology file $topology_file
                    exit
                }
                if {![regexp {L=(\S+)} $line -> L]} {
                    Error: No length param in topology file $topology_file
                    exit
                }
                set type [string index $name 0]
		# Info: generate: L=$L W=$W
		foreach expression {L W} {
		    while {[regexp {^(.*)@([A-Za-z0-9_:]+)(.*)$} [set $expression] -> pre context post]} {
		        set value [@ $context]
			set $expression $pre$value$post
		    }
		    if {[catch {set value [expr [set $expression]]}]} {
		        set $expression [@ [set $expression]]
		    } else {
		        set $expression $value
		    }
		}
                # set L [@ $L]
                # set W [@ $W]
		# Info: generate: L=$L W=$W
                default corner ss
                set n [expr int(ceil($W/($::squares*$L)))]
                set alt_W [expr $W/$n]
                for {set i 1} {[info exists ::bin($type,$i,lmax)]} {incr i} {
                    skip {$::bin($type,$i,lmax)<$L}
                    skip {$::bin($type,$i,lmin)>$L}
                    skip {$::bin($type,$i,wmax)<$alt_W}
                    skip {$::bin($type,$i,wmin)>$alt_W}
                    break
                }
		# If couldn't find a bin, try different number of squares
		set alt_squares $::squares
                while {![info exists ::bin($type,$i,lmax)]} {
		    incr  alt_squares
		    if {$alt_squares>10} {
		        Error: Couldn't find bin for L=$L W=$W
			return 0
		    }
                    set n [expr int(ceil($W/($alt_squares*$L)))]
                    set alt_W [expr $W/$n]
                    for {set i 1} {[info exists ::bin($type,$i,lmax)]} {incr i} {
                        skip {$::bin($type,$i,lmax)<$L}
                        skip {$::bin($type,$i,lmin)>$L}
                        skip {$::bin($type,$i,wmax)<$alt_W}
                        skip {$::bin($type,$i,wmin)>$alt_W}
                        break
                    }
                }
		set W $alt_W
                if {$n==1} {
                    append netlist [list m$name $d $g $s $b ${type}ch_${corner}_$i L=$L W=$W]
                    append netlist "\n"
                } else {
                    append netlist [list m$name $d $g $s $b ${type}ch_${corner}_$i L=$L W=$W m=$n]
                    append netlist "\n"
                #    for {set j 0} {$j<$n} {incr j} {
                #        append netlist [list m${name}_$j $d $g $s $b ${type}ch_${corner}_$i L=$L W=$W]
                #        append netlist "\n"
                #    }
                }
                ladd ::required_models ${type}ch_${corner}_$i
            }
            v {
                set size [lindex $line 3]
		calculate_size size
                if {[catch {expr $size}]} {
                    set size [@ $size]
                }
	        if {[regexp {^vin(.?)} [lindex $line 0] -> type]} {
		    switch $type {
		        p {
			    append netlist [concat [lindex $line 0] [lindex $line 2] [lindex $line 1] AC $stimulus 0 DC $size]
                            append netlist "\n"
			}
			default {
			    append netlist [concat [lindex $line 0] [lindex $line 2] [lindex $line 1] AC $stimulus 180 DC $size]
                            append netlist "\n"
			}
		    }
		    continue
		}
                append netlist [concat [lindex $line 0] [lindex $line 2] [lindex $line 1] $size]
                append netlist "\n"
            }
            {[rci]} {
                set size [lindex $line 3]
		calculate_size size
                if {[catch {expr $size}]} {
                    set size [@ $size]
                }
                append netlist [concat [lindex $line 0] [lindex $line 2] [lindex $line 1] $size]
                append netlist "\n"
            }
            default {
            }
        }
    }
    close $I
    default ::active_session original
    regsub {\.tcl} $::env(RAMSPICE)/../../$::active_session.sn {} ::SESSION(spice_netlist)
    default ::SESSION(focus_circuit) original
    # Info: Generating $::SESSION(spice_netlist)
    set O [open /tmp/temp[pid].sn w]
    puts $O "* array set ::opt \{[array get ::opt]\}"
    puts $O "* $selected_topology Instance: $::SESSION(focus_circuit) $selected_tech"
    puts $O "* generated on [clock format [clock seconds]]"
    set I [open $::env(RAMSPICE)/Etc/Tech_DB/$selected_tech/$selected_tech.sp r]
    set copy_line 0
    # Info: required_models=$::required_models
    while {[gets $I line]>=0} {
        if {[regexp {model\s+(\S+)} $line -> model_name]} {
            if {[lsearch $::required_models $model_name]!=-1} {
                set copy_line 1
            }
        }
        if {$copy_line} {
            puts $O $line
        }
        if {[regexp {\)} $line]} {
            set copy_line 0
        }
    }
    close $I
    puts $O ".temp 125"
    puts $O $netlist
    puts $O ".end"
    close $O
    return 1
}
