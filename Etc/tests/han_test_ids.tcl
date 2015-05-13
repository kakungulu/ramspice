# \
exec $RAMSPICE/ramspice $0 $argv

@ /look_up_tables/nch load  $::env(RAMSPICE)/Tech_DB/tsmc018/5:6:5/tsmc018_nch_ids.db
set trail {}
for {set i 0} {$i<1000} {incr i} {
    set L [expr rand()*(5e-6-180e-9)+180e-9]
    set W [expr rand()*(5e-6-220e-9)+220e-9]
    set Vgs [expr rand()*1.2+0.6]
    set Vds [expr rand()*(1.8-$Vgs)+$Vgs]
    set Vbs [expr rand()*0.3]
    set LUT_Ids [@ /look_up_tables/nch/Ids/ss calc $Vgs $Vds $Vbs $L $W]
    foreach val [list $Vgs $Vds $Vbs $L $W $LUT_Ids] {
        lappend trail $val
    }
}   
set time [expr 1e-9*[lindex [timer_report] 0]]
Info: Access time LUT=[eng $time sec]
array2hit /look_up_tables/nch/Ids/ss
list_bytecode /look_up_tables/nch/Ids/ss 10
foreach {Vgs Vds Vbs L W LUT_Ids} $trail {
    set HIT_Ids [@ /look_up_tables/nch/Ids/ss calc $Vgs $Vds $Vbs $L $W]
#    set error [expr 100*abs($HIT_Ids/$LUT_Ids-1)]
#    if {$error>10} {
#        report_vars HIT_Ids LUT_Ids 
#    }
}   
set time [expr 1e-9*[lindex [timer_report] 0]]
Info: Access time HIT=[eng $time sec]

exit
