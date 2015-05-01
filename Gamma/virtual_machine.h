#ifndef GammaVirtualMachine
#define GammaVirtualMachine
#include "ramspice_types.h"
#include "Data/ctree.h"
#include <tcl.h>
#define GammaVirtualMachineGosubStackSize $::GammaVirtualMachineGosubStackSize
#define GammaVirtualMachineStackSize $::GammaVirtualMachineStackSize
#define GammaVirtualMachineBatchSize $::GammaVirtualMachineBatchSize
//void (*GammaVirtualMachineBatch[GammaVirtualMachineBatchSize])(void);
DC GammaVirtualMachineBatch[GammaVirtualMachineBatchSize];
ordinal GammaVirtualMachineBatchProgramCounter;
ordinal GammaVirtualMachineBatchProgramSize;
int GammaVirtualMachineRunning;

void GammaVirtualMachineInit(void);
void GammaVirtualMachineReset(void);
static int tcl_run_gamma (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_reset_gamma (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_init_gamma (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_set_gamma (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_push_gamma (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
DC GammaVirtualMachineGosubStack[GammaVirtualMachineGosubStackSize];
ordinal GammaVirtualMachineGosubStackIndex;
DC GammaVirtualMachineStack[GammaVirtualMachineStackSize];
ordinal GammaVirtualMachineStackArgs;
ordinal GammaVirtualMachineStackIndex;
int GammaVirtualMachineSkip;
#endif


