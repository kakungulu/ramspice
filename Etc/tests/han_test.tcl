# \
exec $RAMSPICE/ramspice $0 $argv


set span 12
@ test($span,$span,$span,$span,$span) !
for {set j 0} {$j<5} {incr j} {
    for {set L 0} {$L<$span} {incr L} {
        ::spice::array_set_legend /test $j $L $L
    }
}
for {set L 0} {$L<$span} {incr L} {
    for {set W 0} {$W<$span} {incr W} {
        for {set Vgs 0} {$Vgs<$span} {incr Vgs} {
            for {set Vds 0} {$Vds<$span} {incr Vds} {
                for {set Vbs 0} {$Vbs<$span} {incr Vbs} {
                  #  @ /test($Vgs,$Vds,$Vbs,$L,$W) = [expr 4+$Vgs+$Vds+$Vbs+$L+$W]
                   @ /test($Vgs,$Vds,$Vbs,$L,$W) = [expr 10+$L*3+5*$W+rand()/15]
                  # @ /test($Vgs,$Vds,$Vbs,$L,$W) = [expr 10+$L*3+5*$W]
                  # @ /test($Vgs,$Vds,$Vbs,$L,$W) = [expr 3+$L*3+5*$W]
                  # @ /test($Vgs,$Vds,$Vbs,$L,$W) = [expr 100*$L+$W/100.0+$Vgs/10000.0+$Vds/1000000.0+$Vbs/100000000.0]
                }
            }
        }
    }
}
set trail {}
for {set i 0} {$i<1000} {incr i} {
    set L [expr rand()*($span-1)]
    set W [expr rand()*($span-1)]
    set Vgs [expr rand()*($span-1)]
    set Vds [expr rand()*($span-1)]
    set Vbs [expr rand()*($span-1)]
    set LUT_Ids [@ /test calc $Vgs $Vds $Vbs $L $W]
    foreach val [list $Vgs $Vds $Vbs $L $W $LUT_Ids] {
        lappend trail $val
    }
}   
set time [expr 1e-9*[lindex [timer_report] 0]]
Info: Access time LUT=[eng $time sec]
array2hit /test
# list_bytecode /test 
Info: Done Converting
set i 0
foreach {Vgs Vds Vbs L W LUT_Ids} $trail {
    incr i
    set HIT_Ids [@ /test calc $Vgs $Vds $Vbs $L $W]
    #   set error [expr 100*($HIT_Ids/$LUT_Ids-1)]
#   if {abs($HIT_Ids/$LUT_Ids-1)>0.01} {
#       report_vars i HIT_Ids LUT_Ids 
#   }
}   
set time [expr 1e-9*[lindex [timer_report] 0]]
Info: Access time HIT=[eng $time sec]
exit
