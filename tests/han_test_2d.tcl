# \
exec $RAMSPICE/ramspice $0 $argv


set span 3
@ test($span,$span) !
for {set j 0} {$j<2} {incr j} {
    for {set L 0} {$L<$span} {incr L} {
        ::spice::array_set_legend /test $j $L $L
    }
}
for {set L 0} {$L<$span} {incr L} {
    for {set W 0} {$W<$span} {incr W} {
                  #  @ /test($Vgs,$Vds,$Vbs,$L,$W) = [expr 4+$Vgs+$Vds+$Vbs+$L+$W]
                  # @ /test($L,$W) = [expr 10+$L*3+5*$W+rand()/5]
                   @ /test($L,$W) = [expr 3+$L*3+5*$W]
    }
}
set trail {}
for {set i 0} {$i<100} {incr i} {
    set L [expr rand()*($span-1)]
    set W [expr rand()*($span-1)]
    set LUT_Ids [@ /test calc $L $W]
    foreach val [list $L $W $LUT_Ids] {
        lappend trail $val
    }
}   
set time [expr 1e-9*[lindex [timer_report] 0]]
Info: Access time LUT=[eng $time sec]
array2hit /test
list_bytecode /test 1000
Info: Done Converting
foreach { L W LUT_Ids} $trail {
    set HAN_Ids [@ /test calc  $L $W]
    #   set error [expr 100*($HAN_Ids/$LUT_Ids-1)]
   # report_vars HAN_Ids LUT_Ids 
}   
set time [expr 1e-9*[lindex [timer_report] 0]]
Info: Access time HAN=[eng $time sec]
exit
