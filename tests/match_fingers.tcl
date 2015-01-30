# \
exec $RAMSPICE/ramspice $0 $argv

get_opts

source random_$::opt(tech).csv
must ::opt(input) "-input not given. Please provide stimuli file"

set I [open $::opt(input) r]
while {[gets $I line]>=0} {
    if {[regexp {^variable.*\"(\S+)\"} $line -> field]} {
        set varname $field
        continue
    }
    if {[regexp {^inclusion.*value \((.+)\)} $line -> value]} {
        set $varname $value
    }
}
close $I
set prev_section 0
set Lmin $::global_nlmin
for {set i 2} {$i<10} {incr i} {
    set rms_lut_err 0
    set rms_err 0
    set max_err 0
    set min_err 0
    set num_of_samples 0
    foreach stimulus [split $stimuli ,] ref_ids $ref {
        foreach {var val} $stimulus {
            set $var $val
        }
   	if {$Vds<0.52} continue
	if {$Vgs<0.52} continue
        set section [find_mosfet_bin n $l $w]
        if {$section!=$i} continue
	#for {set section 1} {$section<=40} {incr section} 
	foreach section $section {
	    if {$l<$bin(n,$section,lmin)} continue
	    if {$l>$bin(n,$section,lmax)} continue
	    set fingers [expr int(ceil($w/$bin(n,$section,wmax)))]
	    set wf [expr $w/$fingers]
            netlist ".include $::env(RAMSPICE_TECH)"
            netlist ".temp $opt(temp)"
	    for {set j 0} {$j<$fingers} {incr j} {
                #netlist "mn$j 3 1 5 4 ${::opt(device)}_${::opt(process)}_${section} L=$l W=$wf AD=[expr 2.5*$::Lmin*$w] AS=[expr 2.5*$::Lmin*$w] PD=[expr 5*$::Lmin+$w] PS=[expr 5*$::Lmin+$w]"
                netlist "mn$j 3 1 5 4 ${::opt(device)}_${::opt(process)}_${section} L=$l W=$wf"
	    }
            netlist "r5 5 0 1e-12"
            netlist "Vds 3 0 dc 0 ac 0"
            netlist "Vgs 1 0 dc 0 ac 0"
            netlist "Vbs 0 4 dc 0 ac 0"
            netlist ".end"
            update_netlist
            ::spice::alter vds = $Vds
            ::spice::alter vgs = $Vgs
            ::spice::alter vbs = $Vbs
            ::spice::op
            if {[catch {set Ids [::spice::get_spice_data V(5) 0]} msg]} {
                Error: $msg
            }
            if {[catch {set Ids [expr $Ids*1e12]} msg]} {
                Error: $msg
		continue
            }
            set err [expr ($ref_ids/$Ids-1)*100]
            if {$err>$max_err} {
                set max_err $err
            }
            if {$err<$min_err} {
                set min_err $err
            }
            Info: ($section) L=$l W=$wf*$fingers Vds=$Vds Vgs=$Vgs Vbs=$Vbs Ids=$Ids Ref=$ref_ids err=$err 
	}
	Info: 
    }
}

exit

