#ifndef DotCamelVirtualMachine
#define DotCamelVirtualMachine
#include "ramspice_types.h"
#include <tcl.h>
#define DotCamelVirtualMachineStackSize $::DotCamelVirtualMachineStackSize
#define DotCamelVirtualMachineBatchSize $::DotCamelVirtualMachineBatchSize
void (*DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchSize])(void);
ordinal DotCamelVirtualMachineBatchProgramCounter;
ordinal DotCamelVirtualMachineBatchProgramSize;
int DotCamelVirtualMachineRunning;

void DotCamelVirtualMachineInit();
void DotCamelVirtualMachineReset();
static int tcl_run_dot_camel (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_reset_dot_camel (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_init_dot_camel (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
FC DotCamelVirtualMachineStack[DotCamelVirtualMachineStackSize];
FC *DotCamelVirtualMachineStackArgs;
ordinal DotCamelVirtualMachineStackIndex;
int DotCamelVirtualMachineSkip;
#endif


