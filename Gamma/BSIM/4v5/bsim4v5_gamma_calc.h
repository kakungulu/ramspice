#tcl source $::env(RAMSPICE)/Etc/Tech_DB/tsmc040/binning_tsmc040.tcl
#tcl source $::env(RAMSPICE)/Etc/Tech_DB/tsmc040/tsmc040.tcl
#Foreach: ::type {nch pch} {
    #tcl set ::t [string index $::type 0]
    #Foreach: ::corner {ss tt ff} {
        #tcl set ::TEMP $::corner_to_temp($::corner)
        #For: {set ::section 1} {[info exists ::bin($::t,$::section,lmin)]} {incr ::section} {
            #tcl skip {[array names ::TECH $::type,$::corner,$::section,*]=={}}
            void Gamma_tsmc040_Calc_${::type}_${::corner}_${::section}(float Vgs_in,float Vds_in,float Vbs_in,float L_in,float W_in,float M_in
		#Foreach: pointer $::bsim_access_fields {
		    ,float *${pointer}_out
		} 
	    );
        }
    }
}    	    
