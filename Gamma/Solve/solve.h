#ifndef GAMMA_SOLVE_FRONT
#define GAMMA_SOLVE_FRONT
#include <tcl.h>
#include "Gamma/Data/ctree.h"

static int tcl_gamma_export_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]);
void populate_pat(PAT *p,ordinal target_size);


#endif
