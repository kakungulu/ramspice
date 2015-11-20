# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
default ::opt(tech) tsmc040
default ::opt(topology) test_nmos
default ::opt(L) 200e-9
default ::opt(W) 200e-9
default ::opt(rez) 5:5:3:8
default ::opt(source) $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/4d/$::opt(rez)/
source $::env(RAMSPICE)/Etc/utils/generate_spice_netlist.tcl
source $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/binning_$::opt(tech).tcl
source $::env(RAMSPICE)/Gamma/Web/svg/svg.tcl

foreach dev {nch pch}  {
    @ /look_up_tables/$dev !
    foreach param {ids gm ro} {
     @ /look_up_tables/$dev load $::opt(source)/$::opt(tech)_${dev}_${param}.db
    }
    @ /look_up_tables/$dev/thermal_noise/ !
    @ /look_up_tables/$dev/flicker_noise/ !
    @ /look_up_tables/$dev/thermal_noise/ load $::opt(source)/$::opt(tech)_${dev}_ss_thermal_noise.db
    @ /look_up_tables/$dev/flicker_noise/ load $::opt(source)/$::opt(tech)_${dev}_ss_flicker_noise.db
    @ /look_up_tables/$dev/cgs/ load $::opt(source)/$::opt(tech)_${dev}_ss_cgs.db
    @ /look_up_tables/$dev/cgd/ load $::opt(source)/$::opt(tech)_${dev}_ss_cds.db
}

@ size:W = $::opt(W)
@ size:L = $::opt(L)
generate_spice_netlist $::opt(tech) $::opt(topology) 0.00001
::spice::source ~/temp/temp.sn
::spice::dc vdd 30e-3 65e-3 1e-4
set length [get_spice_data tp length]
set data1 {}
for {set i 0} {$i<$length} {incr i} {
    set vdd [get_spice_data vdd $i]
    set inter_Ids [expr [@ /look_up_tables/nch/Ids/ss calc 1.1 $vdd 0 $::opt(L)]*$::opt(W)/$::opt(L)]
    set comp_Ids [lindex [comp_interpolate /look_up_tables/nch/gm/ss /look_up_tables/nch/ro/ss /look_up_tables/nch/Ids/ss 1.1 $vdd 0 $::opt(L) $::opt(W)] 2]
    set spice_Ids [expr 1e12*[get_spice_data tp $i]]
    Info: Vdd=$vdd Ids=$spice_Ids $inter_Ids $comp_Ids Err=[eng [expr 100*($inter_Ids/$spice_Ids-1)] %] [eng [expr 100*($comp_Ids/$spice_Ids-1)] %] Abs=[eng [expr 100*abs($comp_Ids/$spice_Ids-$inter_Ids/$spice_Ids)] %]
    foreach datum [list $vdd $spice_Ids 0 $vdd $inter_Ids 1 $vdd $comp_Ids 2] {
        lappend data1 $datum
    }
}
::spice::dc vdd 48e-3 52e-3 1e-4
set length [get_spice_data tp length]
set data2 {}
for {set i 0} {$i<$length} {incr i} {
    set vdd [get_spice_data vdd $i]
    set inter_Ids [expr [@ /look_up_tables/nch/Ids/ss calc 1.1 $vdd 0 $::opt(L)]*$::opt(W)/$::opt(L)]
    set comp_Ids [lindex [comp_interpolate /look_up_tables/nch/gm/ss /look_up_tables/nch/ro/ss /look_up_tables/nch/Ids/ss 1.1 $vdd 0 $::opt(L) $::opt(W)] 2]
    set spice_Ids [expr 1e12*[get_spice_data tp $i]]
    Info: Vdd=$vdd Ids=$spice_Ids $inter_Ids $comp_Ids Err=[eng [expr 100*($inter_Ids/$spice_Ids-1)] %] [eng [expr 100*($comp_Ids/$spice_Ids-1)] %] Abs=[eng [expr 100*abs($comp_Ids/$spice_Ids-$inter_Ids/$spice_Ids)] %]
    foreach datum [list $vdd $spice_Ids 0 $vdd $inter_Ids 1 $vdd $comp_Ids 2] {
        lappend data2 $datum
    }
}
set ::HTML [open ~/public_html/CompositeInterpolation.html w]
<html><body>
SVG::out
::SVG::svg width 800 height 800 {
    SVG::graph_data x_title Vds x_unit V y_title Ids y_unit A title "SPICE (black) vs. Linear (red) and Composite (green) Interpolations" font 20 x 100 y 100 width 600 height 600 data $data1 markers {1:black 1:red 1:green} 
}
::SVG::svg width 800 height 800 {
    SVG::graph_data x_title Vds x_unit V y_title Ids y_unit A title "SPICE (black) vs. Linear (red) and Composite (green) Interpolations" font 20 x 100 y 100 width 600 height 600 data $data2 markers {1:black 1:red 1:green} 
}
</body></html>
close $::HTML
exit
