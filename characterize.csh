#!/bin/tcsh
source ~/mengo/setup

set tech=$1
set topv=$2
setenv RAMSPICE_TECH $RAMSPICE/Tech_DB/$tech/$tech.sp
echo `time` > log
foreach vgs (3 3.5 4 5)
    foreach vds (3 4 5 6 7)
        foreach vbs (3 3.5 4 5)
	    set rez=$vgs":"$vds":"$vbs
	    echo `date` > log$rez
            @ x = 1
            while ($x <= 15)
	        echo "Characterizing $rez, #$x/15 pass"
                characterize.tcl -vgs_rez $vgs -vds_rez $vds -vbs_rez $vbs -tech $tech -topv $topv -device nch 
                characterize.tcl -vgs_rez $vgs -vds_rez $vds -vbs_rez $vbs -tech $tech -topv $topv -device pch 
                @ x += 1
            end
	    foreach dev (nch pch)
	       foreach corner (ss tt ff fs sf) 
	          foreach interpolation (LIT LUT) 
                     utils/collect_random_sample.tcl -topv $topv -tech $tech -device $dev -process $corner -size 500 -source $RAMSPICE/Tech_DB/$tech/$rez -interpolation $interpolation
                     utils/analyze_stats.tcl -topv $topv -tech $tech -device $dev -process $corner -size 500 -source $RAMSPICE/Tech_DB/$tech/$rez -interpolation $interpolation > $RAMSPICE/Tech_DB/$tech/$rez/$dev.$corner.$interpolation.stats
		  end
	       end	
	    end	
        end
    end
end
foreach device (nch pch)
   foreach corner (ss tt ff fs sf) 
      foreach interpolation (LIT LUT) 
         foreach view (Ids gm go) 
            foreach type (volume access_time) 
	        utils/plot_pareto_front.tcl -topv $topv -tech $tech -device $device -process $corner -interpolation $interpolation -view $view -type $type -size 500
            end
         end
      end
   end
end
