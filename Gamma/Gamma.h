#ifndef Gamma
#define Gamma
#include "ramspice_types.h"
#include "Gamma/virtual_machine.h"
void GammaCommandPush(void);
void GammaCommandGoSub(void);
void GammaCommandReturn(void);
void GammaCommandPushArg(void);
void GammaCommandPushVar(void);
void GammaCommandPushPointer(void);
void GammaCommandPopVar(void);
void GammaCommandPop(void);
void GammaCommandInterpolate(void);
void GammaCommandPlus(void);
void GammaCommandMinus(void);
void GammaCommandMult(void);
void GammaCommandDiv(void);
void GammaCommandAbs(void);
void GammaCommandLessThan(void);
void GammaCommandGreaterThan(void);
void GammaCommandAtMost(void);
void GammaCommandAtLeast(void);
void GammaCommandEqual(void);
void GammaCommandDifferent(void);
void GammaCommandBranch(void);
void GammaCommandStop(void);
void GammaCommandGoto(void);
void GammaCommandDumpStack(void);
static int tcl_gamma_AtMost(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_GoSub(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Return(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_PopVar(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Goto(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_LessThan(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_PushArg(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Stop(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Abs(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Pop(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Equal(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Push(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_PushVar(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_PushPointer(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Mult(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Div(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_DumpStack(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Plus(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Minus(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_GreaterThan(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Branch(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_AtLeast(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Different(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Interpolate(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
void init_tcl_gamma(Tcl_Interp *interp);
#endif
