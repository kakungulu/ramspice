#!/bin/tcsh
source ~/virunga/setup

set tech=$1
set topv=$2
setenv RAMSPICE_TECH $RAMSPICE/Tech_DB/$tech/$tech.sp
echo `time` > log
foreach l (6 6.5 7)
foreach vgs (5 5.5 6 6.5)
    foreach vds (5 6 6.5 7 7.5)
        foreach vbs (3 3.5 4 4.5)
	    set rez=$vgs":"$vds":"$vbs":"$l
	    echo `date` > log$rez
	    echo "Characterizing $rez"
            utils/4d_characterize.tcl -vgs_rez $vgs -vds_rez $vds -vbs_rez $vbs -l_rez $l -tech $tech -topv $topv -device nch 
            utils/4d_characterize.tcl -vgs_rez $vgs -vds_rez $vds -vbs_rez $vbs -l_rez $l -tech $tech -topv $topv -device pch 
	    foreach dev (nch pch)
	       foreach corner (ss tt ff fs sf) 
	          foreach interpolation (LUT) 
                     utils/4d_collect_random_sample.tcl -topv $topv -tech $tech -device $dev -process $corner -size 500 -source $RAMSPICE/Tech_DB/$tech/4d/$rez -interpolation $interpolation
                     # utils/4d_analyze_stats.tcl -topv $topv -tech $tech -device $dev -process $corner -size 500 -source $RAMSPICE/Tech_DB/$tech/4d/$rez -interpolation $interpolation > $RAMSPICE/Tech_DB/$tech/4d/$rez/$dev.$corner.$interpolation.stats
		  end
	       end	
	    end	
        end
    end
end
end
foreach device (nch pch)
   foreach corner (ss tt ff fs sf) 
      foreach interpolation (LUT) 
         foreach view (Ids gm go) 
            foreach type (volume access_time) 
	        utils/4d_plot_pareto_front.tcl -topv $topv -tech $tech -device $device -process $corner -interpolation $interpolation -view $view -type $type 
            end
         end
      end
   end
end
