#!/bin/tcsh
source ~/virunga/setup

set tech=$1
set topv=$2
foreach l (6 6.5 7)
foreach vgs (5 5.5 6 6.5)
    foreach vds (5 6 6.5 7 7.5)
        foreach vbs (3 3.5 4 4.5)
	    set rez=$vgs":"$vds":"$vbs":"$l
	    foreach dev (nch)
	       foreach corner (ss tt ff fs sf) 
	          foreach interpolation (LUT) 
                     utils/reduced_collect_random_sample.tcl -topv $topv -tech $tech -device $dev -process $corner -size 500 -source $RAMSPICE/Tech_DB/$tech/reduced/$rez -interpolation $interpolation
		  end
	       end	
	    end	
        end
    end
end
end

foreach device (nch)
   foreach corner (ss tt ff fs sf) 
      foreach interpolation (LUT) 
         foreach view (Ids gm ro) 
            foreach type (volume access_time) 
	        utils/reduced_plot_pareto_front.tcl -topv $topv -tech $tech -device $device -process $corner -interpolation $interpolation -view $view -type $type 
            end
         end
      end
   end
end
