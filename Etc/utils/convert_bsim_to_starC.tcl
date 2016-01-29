# \
exec $RAMSPICE/ramspice $0 $argv
get_opts

array set ::version_to_level {
    49 3v0
    49 3v1
    49 3v2
    49 3v3
    49 3v32
    54 4v0
    54 4v1
    54 4v2
    54 4v3
    54 4v4
    54 4v5
    54 4v6
    54 4v7
}
set ::CONSTCtoK 273.15
set ::CONSTboltz 1.3806226e-23
set ::CHARGE 1.602191770e-19
set ::CONSTroot2 [expr sqrt(2.)]
set ::CONSTvt0 [expr $::CONSTboltz * (27 + $::CONSTCtoK ) / $::CHARGE]
set ::CONSTKoverQ [expr $::CONSTboltz / $::CHARGE]
set ::CONSTe [expr exp(1.0)]
set_spice_var DEBUG_MODEL 1
default ::opt(tech) tsmc040
default ::opt(topv) 1.1
default ::opt(family) tsmc040
default ::opt(tcl_tech_file) $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/$::opt(tech).tcl
source $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/binning_$::opt(tech).tcl
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
array set ::corner_to_temp {
    ss 125
    tt 27
    ff -40
    fs 27
    sf 27
    mc 27
}
proc model {name payload} {
    lassign [split $name _] type corner bin
    foreach {param value} $payload {
    	set ::TECH($type,$corner,$bin,$param) $value
    }
}
foreach ::corner {ss tt ff sf fs mc} {
    Info: Corner=$::corner
    set ::temp $::corner_to_temp($::corner)
    netlist ".include $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/$::opt(tech).sp"
    netlist {
        ** the N-transistor
        * name D G S B model L W 
    }
    foreach type {nch pch} {
        set p [string index $type 0]
        set l_values {}
        set w_values {}
        foreach lmin_key [array names ::bin $p,*,lmin] {
            ladd l_values $::bin($lmin_key)
        }
        set l_values [lsort -real $l_values]
        foreach wmin_key [array names ::bin $p,*,wmin] {
            ladd w_values $::bin($wmin_key)
        }
        set i2 0
        foreach L $l_values {
            set i3 0
            foreach W $w_values {
                set rtest 1e-12
                netlist ".temp $::temp"
                # mosfet {name type D G S B L W Lmin}
                mosfet m${type}_${i2}_${i3} $type D G ${i2}_${i3} B $L $W
                netlist "r${type}_${i2}_${i3} ${i2}_${i3} 0 $rtest"
                incr i3
            }
            incr i2
        }
    }
    netlist "
    Vds D 0 dc $::opt(topv) ac 0
    Vgs G 0 dc $::opt(topv) ac 0
    Vbs B 0 dc 0 ac 0
    .end
    "
    update_netlist Vt $::corner $::temp
    ::spice::op
    source /tmp/bsim4v5.tcl
    file copy -force /tmp/bsim4v5.tcl $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/$::opt(tech).$corner.tcl
    ::spice::destroy all
}
Info: writing tech file for Gamma
set O [open $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/$::opt(tech).tcl w]
puts $O "array set ::TECH \{"
foreach key [lsort [array names ::TECH]] {
    puts $O "	 $key $::TECH($key)"
}
puts $O "\}"
close $O


exit



if {[file exists $::opt(tcl_tech_file)]} {
    source $::opt(tcl_tech_file)
} else {
    set I [open $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/$::opt(tech).sp r]
    set tech_data ""
    while {[gets $I line]>=0} {
        if {[regexp {^\s*.model} $line]} {
            append tech_data "\n"
        }
        append tech_data $line
    }
    close $I
    regsub -all {\+} $tech_data {} tech_data
    regsub -all {\=} $tech_data {} tech_data
    regsub -all {\(} $tech_data "\{" tech_data
    regsub -all {\)} $tech_data "\}" tech_data
    proc .model {name - payload} {
        lassign [split $name _] type corner bin
        foreach {param value} $payload {
            set ::TECH($type,$corner,$bin,$param) $value
        }
        if {$type=="nch"} {
            set ::TECH($type,$corner,$bin,type) 1
        } else {
            set ::TECH($type,$corner,$bin,type) -1
        }
        default ::TECH($type,$corner,$bin,rdsMod) 0
        default ::TECH($type,$corner,$bin,igcMod) 0
        default ::TECH($type,$corner,$bin,igbMod) 0
        default ::TECH($type,$corner,$bin,vcrit) [expr $::CONSTvt0 * log($::CONSTvt0 / ($::CONSTroot2 * 1.0e-14))]
    }
    eval $tech_data
    set O [open $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/$::opt(tech).tcl w]
    puts $O "array set ::TECH \{"
    foreach key [lsort [array names ::TECH]] {
        puts $O "    $key $::TECH($key)"
    }
    puts $O "\}"
    close $O
}

set any_key [lindex [array names ::TECH *,level] 0]
set level $::TECH($any_key)
default ::opt(version) $::version_to_level($level)



exit



