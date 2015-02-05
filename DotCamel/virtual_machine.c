#include "DotCamel/virtual_machine.h"

void DotCamelVirtualMachineInit() {
    DotCamelVirtualMachineBatchProgramSize=0;
    DotCamelVirtualMachineReset();
}

void DotCamelVirtualMachineReset() {
    DotCamelVirtualMachineBatchProgramCounter=0;
    DotCamelVirtualMachineRunning=0;
    DotCamelVirtualMachineGosubStackIndex=DotCamelVirtualMachineGosubStackSize-1;
    DotCamelVirtualMachineStackIndex=DotCamelVirtualMachineStackSize-1;
    DotCamelVirtualMachineStackArgs=DotCamelVirtualMachineStackIndex;
    DotCamelVirtualMachineSkip=0;
}

void DotCamelVirtualMachineRun(ordinal StartCounter) {
    DotCamelVirtualMachineRunning=1;
    if (StartCounter>0) DotCamelVirtualMachineBatchProgramCounter=StartCounter;
    while (DotCamelVirtualMachineRunning) {
       #Info: "Running %d" DotCamelVirtualMachineBatchProgramCounter
       DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramCounter].func();
    }   
}

static int
tcl_run_dot_camel (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    if ((argc!=2)&&(argc!=1)) {
        #Error: "Usage: %s <starting position>" argv[0]
        return TCL_ERROR;
    }
    if (argc==1) DotCamelVirtualMachineRun(-1);
    if (argc==2) DotCamelVirtualMachineRun(atoi(argv[1]));
    return TCL_OK;
}
static int
tcl_label_dot_camel (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    if ((argc!=2)&&(argc!=1)) {
        #Error: "Usage: %s <varname>" argv[0]
        return TCL_ERROR;
    }
    char *label=(char *)malloc(sizeof(char)*16);
    sprintf(label,"%d",DotCamelVirtualMachineBatchProgramSize);
    Tcl_SetVar(interp,argv[1],label,0);
    return TCL_OK;
}
static int
tcl_reset_dot_camel (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    if (argc!=1) {
        #Error: "Usage: %s" argv[0]
        return TCL_ERROR;
    }
    DotCamelVirtualMachineReset();
    return TCL_OK;
}
static int
tcl_init_dot_camel (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    if (argc!=1) {
        #Error: "Usage: %s" argv[0]
        return TCL_ERROR;
    }
    DotCamelVirtualMachineInit();
    return TCL_OK;
}
int register_dot_camel_functions(Tcl_Interp *interp) {
    Tcl_CreateCommand(interp, "Label:", tcl_label_dot_camel, NULL, NULL);
    Tcl_CreateCommand(interp, "RunDotCamel", tcl_run_dot_camel, NULL, NULL);
    Tcl_CreateCommand(interp, "InitDotCamel", tcl_init_dot_camel, NULL, NULL);
    Tcl_CreateCommand(interp, "ResetDotCamel", tcl_reset_dot_camel, NULL, NULL);
}


