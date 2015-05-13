# \
exec $RAMSPICE/ramspice $0 $argv

get_opts
proc LUT {name args} {
    return [expr abs([uplevel \#0 "@ /look_up_tables/$::opt(device)/$name/$::opt(process) calc $args"])]
}
default opt(size) 1024
#Info: L=4.05657e-08 W=2.27243e-07 Vds=0.998388 Vgs=0.606657 Vbs=-0.274593 Ids=1.967347e-5 LUT_Ids=1.7421330324190142e-5 Ref=19.65E-6 err=-0.11929771412972912 lut_err=12.792764010193135 
default opt(l) 4.05657e-08
default opt(w)  2.27243e-07
default opt(vds)  0.998388
default opt(vgs) 0.606657
default opt(vbs)  -0.274593
default opt(device) nch
default opt(process) tt
default opt(temp) 27
default opt(tech) tsmc040
set l $opt(l)
set w $opt(w)
set Lmin 3.6e-8
foreach device {nch pch} {
    @ /look_up_tables/$device !
    foreach view ids {
        @ /look_up_tables/$device load $::env(RAMSPICE)/../${::opt(tech)}_${device}_${view}.db
    }
}
foreach tech {n p} {
set opt(device) ${tech}ch
foreach corner {ss tt ff fs sf mc} {
set section [find_mosfet_bin n $l $w]
for {set section 1} {[info exists bin($tech,$section,lmin)]} {incr section} {
    set l $bin($tech,$section,lmin)
    set w $bin($tech,$section,wmin)
    netlist ".include $::env(RAMSPICE_TECH)"
    netlist ".temp $opt(temp)"
    netlist "mn 3 1 5 4 ${::opt(device)}_${::opt(process)}_${section} L=$l W=$w AD=[expr 2.5*$::Lmin*$w] AS=[expr 2.5*$::Lmin*$w] PD=[expr 5*$::Lmin+$w] PS=[expr 5*$::Lmin+$w]"
    netlist "r5 5 0 1e-12"
    netlist "Vds 3 0 dc $opt(vds) ac 0"
    netlist "Vgs 1 0 dc $opt(vgs) ac 0"
    netlist "Vbs 0 4 dc $opt(vbs) ac 0"
    netlist ".end"
    update_netlist
    set offset($tech,$corner,$section) 0
    set average 0
    for {set i 0} {$i<$opt(size)} {incr i} {
        set Vgs [expr 0.52+(1.1-0.52)*rand()]
        set Vds [expr 0.52+(1.1-0.52)*rand()]
        set Vbs [expr -0.5*rand()]
	if {$tech=="p"} {
	    set Vds -$Vds
	    set Vgs -$Vgs 
	    set Vbs -$Vbs
	}
        ::spice::alter vgs = $Vgs
        ::spice::alter vds = $Vds
        ::spice::alter vbs = $Vbs
	set w [expr $bin($tech,$section,wmin)+rand()*($bin($tech,$section,wmax)-$bin($tech,$section,wmin))]
	set l [expr $bin($tech,$section,lmin)+rand()*($bin($tech,$section,lmax)-$bin($tech,$section,lmin))]
        ::spice::alter mn l = $l
        ::spice::alter mn w = $w
        ::spice::op
        if {[catch {set Ids [::spice::get_spice_data V(5) 0]} msg]} {
        	Error: $msg
        }
        set Ids [expr $Ids*1e12]
        set LUT_Ids [expr [LUT Ids $Vgs $Vds [expr -$Vbs] $l $w]*$w/$l]
	set offset($tech,$corner,$section) [expr $offset($tech,$corner,$section)+$Ids-$LUT_Ids]
	set average [expr $average+$Ids]
    }
    set offset($tech,$corner,$section) [expr $offset($tech,$corner,$section)/$opt(size)]
    set average [expr $average/$opt(size)]
    Info: tech=$tech corner=$corner $section = [eng $offset($tech,$corner,$section) A] ([eng $average A]) [expr int(1000*($offset($tech,$corner,$section)/$average))/10]%
}
}
}
set O [open lut_offsets.tcl w]
puts $O [list array set offset [array get offset]]
close $O

