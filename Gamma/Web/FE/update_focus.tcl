set ::SESSION(focus_circuit) $::opt(arg)
save_session
Info: SFSG $::active_session
if {![info exists ::SESSION(selected_topology)]} return
Info: SFSG
if {![info exists ::SESSION(selected_tech)]} return
source $::env(RAMSPICE)/Etc/Templates/$::SESSION(selected_topology)/data.tcl
set work_pat_file $::env(RAMSPICE)/Gamma/Web/FE/gamma_sessions/PAT$::active_session.db
set use_original_pat 1
if {[file exists $work_pat_file]} {
    if {[clock seconds]>[file mtime $work_pat_file]+5} {
        set use_original_pat 0
    }
}
if {$use_original_pat} {  
    @ / load $::env(RAMSPICE)/Etc/Templates/$::SESSION(selected_topology)/pareto_bi.db
} else {
    @ / load $work_pat_file
}
for {set i 0} {$i<[@ /$::SESSION(selected_topology)/circuits PAT size]} {incr i} {
    if {[@ /$::SESSION(selected_topology)/circuits PAT id $i]==$::SESSION(focus_circuit)} break
}
set index $i
set i 0
foreach s [@ /$::SESSION(selected_topology)/circuits PAT sizes] {
    @ size:$s = [lindex [@ /$::SESSION(selected_topology)/circuits PAT index $index] $i]
    incr i
}
Info: SFSG
source $::env(RAMSPICE)/Etc/Tech_DB/$::SESSION(selected_tech)/binning_$::SESSION(selected_tech).tcl
set netlist {}
set topology_file $::env(RAMSPICE)/Etc/Topologies/$::SESSION(selected_topology).gsp
set ::required_models {}
set I [open $topology_file r]
while {[gets $I line]>=0} {
    Info: $line
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
	    set L [@ $L]
	    set W [@ $W]
	    default corner ss
            set n [expr int(ceil($W/(10*$L)))]
            set W [expr $W/$n]
            for {set i 1} {[info exists ::bin($type,$i,lmax)]} {incr i} {
                skip {$::bin($type,$i,lmax)<$L}
                skip {$::bin($type,$i,lmin)>$L}
                skip {$::bin($type,$i,wmax)<$W}
                skip {$::bin($type,$i,wmin)>$W}
                break
            }
            if {![info exists ::bin($type,$i,lmax)]} {
                Error: Transistor dimensions L=$l and W=$W (n=$n) do not correspond to any bin
                return
            }
            if {$n==1} {
                append netlist [list m$name $d $g $s $b ${type}ch_${corner}_$i L=$L W=$W]
                append netlist "\n"
            } else {
                for {set j 0} {$j<$n} {incr j} {
                    append netlist [list m${name}_$j $d $g $s $b ${type}ch_${corner}_$i L=$L W=$W]
                    append netlist "\n"
                }
            }
	    ladd ::required_models ${type}ch_${corner}_$i
        }
        {[rciv]} {
            set size [lindex $line 3]
            Info: line=$line size=$size
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
regsub {\.tcl} $::env(RAMSPICE)/../../$::active_session.sn {} ::SESSION(spice_netlist)
set O [open $::SESSION(spice_netlist) w]
puts $O "* $::SESSION(selected_topology) Instance: $::SESSION(focus_circuit)"
set I [open $::env(RAMSPICE)/Etc/Tech_DB/$::SESSION(selected_tech)/$::SESSION(selected_tech).sp r]
set copy_line 0
Info: required_models=$::required_models
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
save_session
return
