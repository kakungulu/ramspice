#ifndef DotCamelCommands
#define DotCamelCommands
#include "ramspice_types.h"
#include "DotCamel/virtual_machine.h"
void DotCamelCommand_Push();
void DotCamelCommand_Pop();
void DotCamelCommand_Plus();
void DotCamelCommand_Minus();
void DotCamelCommand_Mult();
void DotCamelCommand_Div();
void DotCamelCommand_LessThan();
void DotCamelCommand_GreaterThan();
void DotCamelCommand_AtMost();
void DotCamelCommand_AtLeast();
void DotCamelCommand_Equal();
void DotCamelCommand_Different();
void DotCamelCommand_Branch();
static int tcl_dot_camel_AtMost(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_LessThan(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_Pop(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_Push(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_Equal(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_Mult(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_Div(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_Plus(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_Minus(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_GreaterThan(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_Branch(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_AtLeast(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_dot_camel_Different(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
void init_tcl_dot_camel(Tcl_Interp *interp);
#endif
