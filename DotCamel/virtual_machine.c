#include "DotCamel/virtual_machine.h"

void DotCamelVirtualMachineInit() {
    DotCamelVirtualMachineBatchProgramSize=0;
    DotCamelVirtualMachineReset();
}

void DotCamelVirtualMachineReset() {
    DotCamelVirtualMachineBatchProgramCounter=0;
    DotCamelVirtualMachineRunning=0;
    DotCamelVirtualMachineStackIndex=DotCamelVirtualMachineStackSize-1;
    DotCamelVirtualMachineStackArgs=&(DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex]);
    DotCamelVirtualMachineSkip=0;
}

void DotCamelVirtualMachineRun(ordinal StartCounter) {
    DotCamelVirtualMachineRunning=1;
    if (StartCounter>0) DotCamelVirtualMachineBatchProgramCounter=StartCounter;
    while (DotCamelVirtualMachineRunning) DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramCounter]();
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
tcl_reset_dot_camel (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    if (argc!=1) {
        #Error: "Usage: %s" argv[0]
        return TCL_ERROR;
    }
    DotCamelVirtualMachineReset();
}
static int
tcl_init_dot_camel (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    if (argc!=1) {
        #Error: "Usage: %s" argv[0]
        return TCL_ERROR;
    }
    DotCamelVirtualMachineInit();
}


