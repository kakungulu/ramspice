#ifndef BSIM4V5_GAMMA_CALC
#define BSIM4V5_GAMMA_CALC
#tcl source $::env(RAMSPICE)/Etc/Tech_DB/tsmc040/binning_tsmc040.tcl
#tcl source $::env(RAMSPICE)/Etc/Tech_DB/tsmc040/tsmc040.tcl
#tcl set ::corners {ss tt ff}
#Foreach: ::type {nch pch} {
    #tcl set ::t [string index $::type 0]
    #Foreach: ::corner $::corners {
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
#For: {set ::section 1} {[info exists ::bin($::t,$::section,lmin)]} {incr ::section} {}
#tcl set Gamma_tsmc040_Calc_Length [expr ($::section-1)*[llength $::corners]*2]
void (*Gamma_tsmc040_Calc_Functions[$Gamma_tsmc040_Calc_Length])(float Vgs_in,float Vds_in,float Vbs_in,float L_in,float W_in,float M_in
		#Foreach: pointer $::bsim_access_fields {
		    ,float *${pointer}_out
		} 
		);
void Gamma_tsmc040_Calc(int type,int corner,float Vgs_in,float Vds_in,float Vbs_in,float L_in,float W_in
		#Foreach: pointer $::bsim_access_fields {
		    ,float *${pointer}_out
		} 
);
void register_tsmc040();
#endif
