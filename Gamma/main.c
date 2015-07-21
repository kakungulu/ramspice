#include "ramspice_types.h"
#include "Gamma/Data/ctree.h"
#include "Gamma/LUT/look_up_table.h"
#include <setjmp.h>
#include <signal.h>
int main(int argc, char **argv)
{
    interp=Tcl_CreateInterp();
    Tcl_Init(interp);
    vector_buffer_allocation=1024;
    vector_buffer=(char *)malloc(vector_buffer_allocation);
    if (Tcl_Eval(interp,"if {![info exists ::env(RAMSPICE)]} {set ::env(RAMSPICE) [pwd]}")==TCL_ERROR) {
        Tcl_Eval(interp,"puts $errorInfo");
	exit(1);
    };
    Tcl_Eval(interp, "namespace eval " TCLSPICE_namespace " { }");
    /*register functions*/
    int i;
    char *key;
    char buf[256];
    Tcl_CmdInfo infoPtr;
    register_tcl_functions(interp);    
    init_tcl_gamma(interp);
    register_gamma_functions(interp);
    Tcl_Eval(interp,"set ::argv {}");
    char args_buf[1024*64];
    for (i=0;i<argc;i++) {
        sprintf(args_buf,"lappend ::argv %s",argv[i]);
	Tcl_Eval(interp,args_buf);
    }
    if (Tcl_Eval(interp,"source $::env(RAMSPICE)/.ramspice.tcl")==TCL_ERROR) {
        Tcl_Eval(interp,"puts $errorInfo");
    };
    execute_main_commands(interp,argc,argv);
    
    // Execute stdin input code here:
    ordinal input_code_size=1024*1024;
    char *input_code;
    char c;
    ordinal input_code_index=0;
    input_code=(char *)malloc(sizeof(char)*input_code_size);
    while (!feof(stdin)) {
        if (input_code_index>=input_code_size-1) {
	    char *new_input_code=(char *)malloc(sizeof(char)*input_code_size*2);
	    ordinal i;
	    for (i=0;i<input_code_index;i++) new_input_code[i]=input_code[i];
	    input_code_size*=2;
	    free(input_code);
	    input_code=new_input_code;
	}
	input_code[input_code_index++]=fgetc(stdin);
    }
    input_code[input_code_index]=0;
    if (Tcl_Eval(interp,input_code)==TCL_ERROR) {
        Tcl_Eval(interp,"puts $errorInfo");
    };
    Tcl_Eval(interp,"puts \"Bye! ; exit");
    fflush(stdout);
    exit(0);
}


