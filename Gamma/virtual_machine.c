#include "Gamma/virtual_machine.h"

void GammaVirtualMachineInit() {
    GammaVirtualMachineBatchProgramSize=0;
    GammaVirtualMachineReset();
}

void GammaVirtualMachineReset() {
    GammaVirtualMachineBatchProgramCounter=0;
    GammaVirtualMachineRunning=0;
    GammaVirtualMachineGosubStackIndex=GammaVirtualMachineGosubStackSize-1;
    GammaVirtualMachineStackIndex=GammaVirtualMachineStackSize-1;
    GammaVirtualMachineStackArgs=GammaVirtualMachineStackIndex;
    GammaVirtualMachineSkip=0;
}

void GammaVirtualMachineRun(ordinal StartCounter) {
    GammaVirtualMachineRunning=1;
    if (StartCounter>0) GammaVirtualMachineBatchProgramCounter=StartCounter;
    while (GammaVirtualMachineRunning) GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter].func();
}

static int
tcl_run_gamma (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    if ((argc!=2)&&(argc!=1)) {
        #Error: "Usage: %s <starting position>" argv[0]
        return TCL_ERROR;
    }
    if (argc==1) GammaVirtualMachineRun(-1);
    if (argc==2) GammaVirtualMachineRun(atoi(argv[1]));
    return TCL_OK;
}
static int
tcl_label_gamma (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    if ((argc!=2)&&(argc!=1)) {
        #Error: "Usage: %s <varname>" argv[0]
        return TCL_ERROR;
    }
    char *label=(char *)malloc(sizeof(char)*16);
    sprintf(label,"%d",GammaVirtualMachineBatchProgramSize);
    Tcl_SetVar(interp,argv[1],label,0);
    #Info: "Assembly %ld:" GammaVirtualMachineBatchProgramSize
    #Info: "Assembly %ld:" GammaVirtualMachineBatchProgramSize
    #Info: "Assembly %ld: ------- %s -------" GammaVirtualMachineBatchProgramSize argv[1]
    #Info: "Assembly %ld:" GammaVirtualMachineBatchProgramSize
    return TCL_OK;
}
static int
tcl_set_gamma (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    if ((argc!=2)&&(argc!=3)) {
        #Error: "Usage: %s <step> [<number>]" argv[0]
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    ordinal value=GammaVirtualMachineBatch[atoi(argv[1])].I;
    if (argc==2) {
        tcl_append_long(interp,GammaVirtualMachineBatch[atoi(argv[1])].I);
	return TCL_OK;
    }
    GammaVirtualMachineBatch[atoi(argv[1])].I=atoi(argv[2]);
    return TCL_OK;
}
static int
tcl_reset_gamma (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    if (argc!=1) {
        #Error: "Usage: %s" argv[0]
        return TCL_ERROR;
    }
    GammaVirtualMachineReset();
    return TCL_OK;
}
static int
tcl_init_gamma (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    if (argc!=1) {
        #Error: "Usage: %s" argv[0]
        return TCL_ERROR;
    }
    GammaVirtualMachineInit();
    return TCL_OK;
}
static int
tcl_push_gamma (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    if (argc!=2) {
        #Error: "Usage: %s <const>|<var>|<context>" argv[0]
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    char *err;
    float F=strtof(argv[1],&err);
    if (strlen(err)==0) {
    	GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F=F;
    	GammaVirtualMachineStackIndex--;
    	return TCL_OK;
    }
    if (argv[1][0]=='&') {
    	GammaVirtualMachineStack[GammaVirtualMachineStackIndex].P=get_LUT(&(argv[1][1]));
    	GammaVirtualMachineStackIndex--;
    	return TCL_OK;
    }
    context *c=Context;
    float *array_entry=NULL;
    if (argv[1][0]=='/') {
    	c=Ctree;
    }
    if (!(resolve_context(argv[1],&c,&array_entry))) {
    	#Error: "(%s) no such context %s" argv[0] argv[1]
    	return TCL_ERROR;
    }
    if (array_entry) {
    	GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F=*(array_entry);
    	GammaVirtualMachineStackIndex--;
    	return TCL_OK;
    }
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F=c->value.s;
    GammaVirtualMachineStackIndex--;
    return TCL_OK;
}
int register_gamma_functions(Tcl_Interp *interp) {
    Tcl_CreateCommand(interp, ".label:", tcl_label_gamma, NULL, NULL);
    Tcl_CreateCommand(interp, "..run", tcl_run_gamma, NULL, NULL);
    Tcl_CreateCommand(interp, "..init", tcl_init_gamma, NULL, NULL);
    Tcl_CreateCommand(interp, "..reset", tcl_reset_gamma, NULL, NULL);
    Tcl_CreateCommand(interp, "..set", tcl_set_gamma, NULL, NULL);
    Tcl_CreateCommand(interp, "..push", tcl_push_gamma, NULL, NULL);
}


