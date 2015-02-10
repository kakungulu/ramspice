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
    while (GammaVirtualMachineRunning) {
       #Info: "Running %d" GammaVirtualMachineBatchProgramCounter
       GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter].func();
    }   
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
int register_gamma_functions(Tcl_Interp *interp) {
    Tcl_CreateCommand(interp, ".label:", tcl_label_gamma, NULL, NULL);
    Tcl_CreateCommand(interp, ".run", tcl_run_gamma, NULL, NULL);
    Tcl_CreateCommand(interp, ".init", tcl_init_gamma, NULL, NULL);
    Tcl_CreateCommand(interp, ".reset", tcl_reset_gamma, NULL, NULL);
    Tcl_CreateCommand(interp, ".set", tcl_set_gamma, NULL, NULL);
}


