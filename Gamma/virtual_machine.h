#ifndef GammaVirtualMachine
#define GammaVirtualMachine
#include "ramspice_types.h"
#include <tcl.h>
#define GammaVirtualMachineGosubStackSize $::GammaVirtualMachineGosubStackSize
#define GammaVirtualMachineStackSize $::GammaVirtualMachineStackSize
#define GammaVirtualMachineBatchSize $::GammaVirtualMachineBatchSize
//void (*GammaVirtualMachineBatch[GammaVirtualMachineBatchSize])(void);
FC GammaVirtualMachineBatch[GammaVirtualMachineBatchSize];
ordinal GammaVirtualMachineBatchProgramCounter;
ordinal GammaVirtualMachineBatchProgramSize;
int GammaVirtualMachineRunning;

void GammaVirtualMachineInit(void);
void GammaVirtualMachineReset(void);
static int tcl_run_gamma (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_reset_gamma (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_init_gamma (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_set_gamma (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
FC GammaVirtualMachineGosubStack[GammaVirtualMachineGosubStackSize];
ordinal GammaVirtualMachineGosubStackIndex;
FC GammaVirtualMachineStack[GammaVirtualMachineStackSize];
ordinal GammaVirtualMachineStackArgs;
ordinal GammaVirtualMachineStackIndex;
int GammaVirtualMachineSkip;
#endif


