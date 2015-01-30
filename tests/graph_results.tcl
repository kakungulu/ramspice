# \
exec $RAMSPICE/ramspice $0 $argv

foreach arg [lrange $argv 2 end] {
    if {[regexp {^\-(\S+)$} $arg -> found_key]} {
        set key $found_key
	set $key {}
        continue
    }
    set $key $arg
}

default ssize 200
set MinIds 1e-10
set ::corner tt
set ::temp 27
foreach process {ss tt ff fs sf mc} {
    @ /look_up_tables/nch/Ids !
}
source $::env(RAMSPICE)/binning_${tech}_from_cadence.tcl
set max_bin 0
foreach key [array names ::bin n,*,lmax] {
    set bin_num [lindex [split $key ,] 1]
    if {$bin_num>$max_bin} {
        set max_bin $bin_num
    }
}
source $::env(RAMSPICE)/tests/geo_values.tcl
@ /look_up_tables/nch load $::env(RAMSPICE)/../${tech}_nch_ids.db
set Lmin 180e-9
set SumPropError 0
set SumAbsError 0
set ListPropError {}
ETA $max_bin
for {set e -10} {$e<10} {set e [expr $e+0.1]} {
    set ::histogram($e) 0
}
set previous_bin -1
for {set bin_num 1} {$bin_num<$max_bin} {incr bin_num} {
ETA
for {set i 0} {$i<$ssize} {incr i} {
    set Vds [expr 0.5+0.6*rand()]
    set Vgs [expr 0.5+0.6*rand()]
    set Vbs [expr -0.55*rand()]
    set L [expr $::bin(n,$bin_num,lmin)+($::bin(n,$bin_num,lmax)-$::bin(n,$bin_num,lmin))*rand()]
    set W [expr $::bin(n,$bin_num,wmin)+($::bin(n,$bin_num,wmax)-$::bin(n,$bin_num,wmin))*rand()]
    set Li -1
    set Wi -1
    foreach w $w_values {
        if {$w>$W} {
	    set Wi $w
	    break
	}    
    }
    if {$Wi==-1} {
        incr i -1
        continue
    }
    foreach l $l_values {
        if {$l>$L} {
	    set Li $l
	    break
	}    
    }
    if {$Li==-1} {
        incr i -1
        continue
    }
    ETA
    set Bin [find_mosfet_bin n $L $W]
    if {$Bin!=$previous_bin} {
        netlist ".include $::env(RAMSPICE)/${tech}_from_cadence.lib"
        netlist ".temp $::temp"
        netlist "mn_5 3 1 5 4 nch_${::corner}_${Bin} L=$L W=$W AD=[expr 2.5*$Lmin*$W] AS=[expr 2.5*$Lmin*$W] PD=[expr 5*$Lmin+$W] PS=[expr 5*$Lmin+$W]"
        netlist "r_5 5 0 1e-12"
        netlist "Vds 3 0 dc $Vds ac 0"
        netlist "Vgs 1 0 dc $Vgs ac 0"
        netlist "Vbs 4 0 dc $Vbs ac 0"
        netlist ".end"
        update_netlist
    } else {
        ::spice::alter mn_5 w = $W
        ::spice::alter mn_5 l = $L
	::spice::alter vds = $Vds
	::spice::alter vgs = $Vgs
	::spice::alter vbs = $Vbs
    }
    ::spice::op
    set previous_bin $Bin
    if {![info exists error_list_l($Li)]} {
        set error_list_l($Li) {}
    }
    if {![info exists error_list_w($Wi)]} {
        set error_list_w($Wi) {}
    }
    if {[catch {set Ids [::spice::get_spice_data V(5) 0]} msg]} {
    	Error: $msg
    }
    set Simulation_Ids [expr $Ids*1e12]
    if {$Simulation_Ids<$MinIds} {
        set Simulation_Ids $MinIds
    }
    set LUT_Ids [expr [@ /look_up_tables/nch/Ids/$::corner calc $Vgs $Vds $Vbs $L $W]*$W/$L]
#    Info: Ids   $LUT_Ids =?= $Simulation_Ids
    if {$LUT_Ids<$MinIds} {
        set LUT_Ids $MinIds
    }
    set PropError [expr ($Simulation_Ids/$LUT_Ids-1)*100] 
    set index [expr int($PropError*10)/10.0]
    foreach entry [lsort -real [array names ::histogram]] {
        if {$index<=$entry} {
            incr ::histogram($entry)
	    break
        }
    }
    set SumPropError [expr $SumPropError+$PropError]
    lappend ListPropError $PropError
    lappend error_list_l($Li) $PropError
    lappend error_list_w($Wi) $PropError
}
}
set AveragePropError [expr $SumPropError/$ssize/$max_bin]
set SigmaPropError 0
foreach PropError $ListPropError {
    set SigmaPropError [expr $SigmaPropError+pow($PropError-$AveragePropError,2)]
}
set SigmaPropError [expr sqrt($SigmaPropError/$ssize/$max_bin)]
report_vars AveragePropError SigmaPropError 
foreach l [lsort -real [array names error_list_l]] {
    set average 0
    set hits [llength $error_list_l($l)]
    foreach error $error_list_l($l) {
        set average [expr $average+$error]
    }
    set average [expr $average/$hits]
    set stdev 0
    foreach error $error_list_l($l) {
        set stdev [expr $stdev+pow($error-$average,2)]
    }
    set stdev [expr sqrt($stdev/$hits)]
    report_vars l average stdev hits
}
foreach w [lsort -real [array names error_list_w]] {
    set average 0
    set hits [llength $error_list_w($w)]
    foreach error $error_list_w($w) {
        set average [expr $average+$error]
    }
    set average [expr $average/[llength $error_list_w($w)]]
    set stdev 0
    foreach error $error_list_w($w) {
        set stdev [expr $stdev+pow($error-$average,2)]
    }
    set stdev [expr sqrt($stdev/[llength $error_list_w($w)])]
    report_vars w average stdev hits
}
Info: Error histogram
foreach entry [lsort -real [array names ::histogram]] {
    puts "$entry = $::histogram($entry)"
}
set O [open /tmp/errors.txt w]
puts $O [join $ListPropError ,]
close $O
exit
