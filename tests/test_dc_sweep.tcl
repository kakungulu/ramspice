# \
exec $RAMSPICE/ramspice $0 $argv

proc eng {value unit} {
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
    if {$value>1.0 && $value<1000.0} {
        regsub {(\-?[0-9]+\.[0-9]?[0-9]?[0-9]?).*$} $value {\1} value
        return $sign$value$unit
    }
    if {$unit=="%"} {    
        regsub {(\-?[0-9]+\.[0-9]?[0-9]?[0-9]?).*$} $value {\1} value
        return $sign$value$unit
    }
    set mag [expr int(log($value)/log(1000))]
    if {$value<1.0} {
        set mag [expr -$mag]
        set mag_qual [lindex {m u n p} $mag]
        set value [expr $value*pow(1000,$mag+1)]
    } else {
        set mag_qual [lindex {K M G T} $mag-1]
        set value [expr $value/pow(1000,$mag)]
    }
    regsub {(\-?[0-9]+\.[0-9]?[0-9]?[0-9]?).*$} $value {\1} value
    append value $mag_qual 
    return $sign$value$unit
}
foreach arg [lrange $argv 2 end] {
    if {[regexp {^\-(\S+)$} $arg -> found_key]} {
        set key $found_key
        set $key {}
        continue
    }
    set $key $arg
}
set ref {
82.20E-6
83.78E-6
84.84E-6
85.57E-6
86.09E-6
86.48E-6
86.78E-6
87.02E-6
87.21E-6
87.40E-6
87.56E-6
87.69E-6
87.80E-6
87.90E-6
87.99E-6
88.06E-6
88.13E-6
88.20E-6
88.25E-6
88.31E-6
}
# set section [find_mosfet_bin n $::L $::W]
# netlist ".include $::env(RAMSPICE)/crn40lp_2d5_v1d3.l"
set max_err 0
set w 0
for {set i 0} {$i<[llength $ref]} {incr i} {
    set w [expr $w+1e-6]
    set section [find_mosfet_bin n $w $w]
    netlist ".include ${::tech}_from_cadence.lib"
    netlist ".temp $::temp"
    netlist "mn 3 1 5 4 ${device}_${::process}_${section} L=$w W=$w AD=[expr 2.5*$::Lmin*$::W] AS=[expr 2.5*$::Lmin*$::W] PD=[expr 5*$::Lmin+$::W] PS=[expr 5*$::Lmin+$::W]"
    netlist "r5 5 0 1e-12"
    netlist "Vds 3 0 dc $::Vds ac 0"
    netlist "Vgs 1 0 dc $::Vgs ac 0"
    netlist "Vbs 4 0 dc -$::Vbs ac 0"
    netlist ".end"
    update_netlist
    ::spice::op
    if {[catch {set Ids [::spice::get_spice_data V(5) 0]} msg]} {
        Error: $msg
    }
    set Ids [expr $Ids*1e12]
    set err [expr abs([lindex $ref $i]/$Ids-1)*100]
    if {$err>$max_err} {
        set max_err $err
    }
    Info: bin=$section Ids=$Ids Ref=[lindex $ref $i] err=$err
}
exit


