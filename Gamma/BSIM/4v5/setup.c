#tcl source $::env(RAMSPICE)/Etc/Tech_DB/tsmc040/binning_tsmc040.tcl
#tcl source $::env(RAMSPICE)/Etc/Tech_DB/tsmc040/tsmc040.tcl
#Foreach: ::type {nch pch} {
    #tcl set ::t [string index $::type 0]
    #Foreach: ::corner {ss tt ff fs sf mc} {
        #For: {set ::section 1} {[info exists ::bin($::t,$::section,lmin)]} {incr ::section} {
            #tcl skip {[array names ::TECH $::type,$::corner,$::section,*]=={}}
            void Gamma_BSIM4v5_Setup_${::type}_${::corner}_${::section}(float Vgs,float Vds,float Vbs,float L,float W) {
	    }
	}
    }
}
