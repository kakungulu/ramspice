#ifndef DotCamelCommands
#define DotCamelCommands
#include "ramspice_types.h"
#include "DotCamel/virtual_machine.h"
void DotCamelCommandPush();
void DotCamelCommandGoSub();
void DotCamelCommandReturn();
void DotCamelCommandPushArg();
void DotCamelCommandPushVar();
void DotCamelCommandPopVar();
void DotCamelCommandPop();
void DotCamelCommandPlus();
void DotCamelCommandMinus();
void DotCamelCommandMult();
void DotCamelCommandDiv();
void DotCamelCommandLessThan();
void DotCamelCommandGreaterThan();
void DotCamelCommandAtMost();
void DotCamelCommandAtLeast();
void DotCamelCommandEqual();
void DotCamelCommandDifferent();
void DotCamelCommandBranch();
void DotCamelCommandStop();
void DotCamelCommandGoto();
void DotCamelCommandDumpStack();
static int tcl_dot_camel_AtMost(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_GoSub(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_Return(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_PopVar(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_Goto(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_PushArg(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_LessThan(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_Stop(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_Pop(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_Equal(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_Push(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_PushVar(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_Mult(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_Div(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_DumpStack(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_Plus(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_Minus(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_GreaterThan(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_Branch(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_AtLeast(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_Different(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
void init_tcl_dot_camel(Tcl_Interp *interp);
#endif
