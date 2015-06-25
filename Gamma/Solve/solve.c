#include "Gamma/Solve/solve.h"
static int tcl_gamma_op_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
     // Just a stub, do nothing
     return TCL_OK;
 }
static int tcl_gamma_export_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
     // Just a stub, do nothing
     return TCL_OK;
 }
static int tcl_gamma_import_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
     // Just a stub, do nothing
     return TCL_OK;
 }
void populate_pat(PAT *p,ordinal target_size) {
    while (p->content->num_of<target_size) {
        ClientData clientData;
        tcl_gamma_op_cmd(clientData,NULL,0,NULL);
    }
}
