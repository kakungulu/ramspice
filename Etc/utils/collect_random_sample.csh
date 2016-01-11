#!/bin/tcsh

$RAMSPICE/Etc/utils/4d_characterize.tcl -vgs_rez 5 -vds_rez 5 -vbs_rez 3 -l_rez 8 -tech tsmc180 -topv 1.8 -device nch:pch 
$RAMSPICE/Etc/utils/4d_characterize.tcl -vgs_rez 5 -vds_rez 5 -vbs_rez 3 -l_rez 8 -tech tsmc040 -topv 1.1 -device nch:pch 
foreach dev (nch pch) 
    foreach process (ss tt ff)
        $RAMSPICE/Etc/utils/collect_random_sample.tcl -size 500 -device $dev -process $process -tech tsmc180
        $RAMSPICE/Etc/utils/collect_random_sample.tcl -size 500 -device $dev -process $process -tech tsmc040
    end
end
$RAMSPICE/Etc/utils/graph_transistor_level_accuracy.tcl -tech tsmc180
$RAMSPICE/Etc/utils/graph_transistor_level_accuracy.tcl -tech tsmc040
	
