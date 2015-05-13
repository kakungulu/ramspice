#ifndef TCL_INPUT
#define TCL_INPUT
#include <tcl.h>
static int tcl_alter_model(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_fe_add_instance (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_sweep (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
int register_tcl_input_functions(Tcl_Interp *interp);

#endif

