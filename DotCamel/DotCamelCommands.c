#include "DotCamel/DotCamelCommands.h"
void DotCamelCommand_Push() {if (!DotCamelVirtualMachineSkip) {FC FCUNION;
FCUNION.P=(void *)DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramCounter+1];
float F=FCUNION.F;

    DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex].F=F;
    DotCamelVirtualMachineStackIndex--;
    DotCamelVirtualMachineStackArgs=&(DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex]);
}
DotCamelVirtualMachineSkip=0;
DotCamelVirtualMachineBatchProgramCounter+=2;
}
void DotCamelCommand_Pop() {if (!DotCamelVirtualMachineSkip) {FC FCUNION;

    DotCamelVirtualMachineStackIndex++;
    DotCamelVirtualMachineStackArgs=&(DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex]);
}
DotCamelVirtualMachineSkip=0;
DotCamelVirtualMachineBatchProgramCounter+=1;
}
void DotCamelCommand_Plus() {if (!DotCamelVirtualMachineSkip) {FC FCUNION;

    float result=DotCamelVirtualMachineStackArgs[2].F+DotCamelVirtualMachineStackArgs[1].F; 
    DotCamelCommand_Pop();
    DotCamelCommand_Pop(); 
    DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex].F=result;
    DotCamelVirtualMachineStackIndex--;
    DotCamelVirtualMachineStackArgs=&(DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex]);
}
DotCamelVirtualMachineSkip=0;
DotCamelVirtualMachineBatchProgramCounter+=1;
}
void DotCamelCommand_Minus() {if (!DotCamelVirtualMachineSkip) {FC FCUNION;

    float result=DotCamelVirtualMachineStackArgs[2].F-DotCamelVirtualMachineStackArgs[1].F; 
    DotCamelCommand_Pop();
    DotCamelCommand_Pop(); 
    DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex].F=result;
    DotCamelVirtualMachineStackIndex--;
    DotCamelVirtualMachineStackArgs=&(DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex]);
}
DotCamelVirtualMachineSkip=0;
DotCamelVirtualMachineBatchProgramCounter+=1;
}
void DotCamelCommand_Mult() {if (!DotCamelVirtualMachineSkip) {FC FCUNION;

    float result=DotCamelVirtualMachineStackArgs[2].F*DotCamelVirtualMachineStackArgs[1].F; 
    DotCamelCommand_Pop();
    DotCamelCommand_Pop(); 
    DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex].F=result;
    DotCamelVirtualMachineStackIndex--;
    DotCamelVirtualMachineStackArgs=&(DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex]);
}
DotCamelVirtualMachineSkip=0;
DotCamelVirtualMachineBatchProgramCounter+=1;
}
void DotCamelCommand_Div() {if (!DotCamelVirtualMachineSkip) {FC FCUNION;

    float result=DotCamelVirtualMachineStackArgs[2].F/DotCamelVirtualMachineStackArgs[1].F; 
    DotCamelCommand_Pop();
    DotCamelCommand_Pop(); 
    DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex].F=result;
    DotCamelVirtualMachineStackIndex--;
    DotCamelVirtualMachineStackArgs=&(DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex]);
}
DotCamelVirtualMachineSkip=0;
DotCamelVirtualMachineBatchProgramCounter+=1;
}
void DotCamelCommand_LessThan() {if (!DotCamelVirtualMachineSkip) {FC FCUNION;

    if (!(DotCamelVirtualMachineStackArgs[2].F<DotCamelVirtualMachineStackArgs[1].F)) DotCamelVirtualMachineSkip=1;
}
DotCamelVirtualMachineSkip=0;
DotCamelVirtualMachineBatchProgramCounter+=1;
}
void DotCamelCommand_GreaterThan() {if (!DotCamelVirtualMachineSkip) {FC FCUNION;

    if (!(DotCamelVirtualMachineStackArgs[2].F>DotCamelVirtualMachineStackArgs[1].F)) DotCamelVirtualMachineSkip=1;
}
DotCamelVirtualMachineSkip=0;
DotCamelVirtualMachineBatchProgramCounter+=1;
}
void DotCamelCommand_AtMost() {if (!DotCamelVirtualMachineSkip) {FC FCUNION;

    if (!(DotCamelVirtualMachineStackArgs[2].F<=DotCamelVirtualMachineStackArgs[1].F)) DotCamelVirtualMachineSkip=1;
}
DotCamelVirtualMachineSkip=0;
DotCamelVirtualMachineBatchProgramCounter+=1;
}
void DotCamelCommand_AtLeast() {if (!DotCamelVirtualMachineSkip) {FC FCUNION;

    if (!(DotCamelVirtualMachineStackArgs[2].F>=DotCamelVirtualMachineStackArgs[1].F)) DotCamelVirtualMachineSkip=1;
}
DotCamelVirtualMachineSkip=0;
DotCamelVirtualMachineBatchProgramCounter+=1;
}
void DotCamelCommand_Equal() {if (!DotCamelVirtualMachineSkip) {FC FCUNION;

    if (!(DotCamelVirtualMachineStackArgs[2].F==DotCamelVirtualMachineStackArgs[1].F)) DotCamelVirtualMachineSkip=1;
}
DotCamelVirtualMachineSkip=0;
DotCamelVirtualMachineBatchProgramCounter+=1;
}
void DotCamelCommand_Different() {if (!DotCamelVirtualMachineSkip) {FC FCUNION;

    if (!(DotCamelVirtualMachineStackArgs[2].F!=DotCamelVirtualMachineStackArgs[1].F)) DotCamelVirtualMachineSkip=1;
}
DotCamelVirtualMachineSkip=0;
DotCamelVirtualMachineBatchProgramCounter+=1;
}
void DotCamelCommand_Branch() {if (!DotCamelVirtualMachineSkip) {FC FCUNION;
FCUNION.P=(void *)DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramCounter+1];
ordinal step=FCUNION.I;

    DotCamelVirtualMachineBatchProgramCounter+=step;
}
DotCamelVirtualMachineSkip=0;
DotCamelVirtualMachineBatchProgramCounter+=2;
}
static int tcl_dot_camel_AtMost(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++]=DotCamelCommand_AtMost;
    return TCL_OK;
}
static int tcl_dot_camel_LessThan(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++]=DotCamelCommand_LessThan;
    return TCL_OK;
}
static int tcl_dot_camel_Pop(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++]=DotCamelCommand_Pop;
    return TCL_OK;
}
static int tcl_dot_camel_Push(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=2) {
        #Error: "%s requires the following arguments: (float F)" argv[0]
    }
DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++]=DotCamelCommand_Push;
FCUNION.F=atof(argv[1]);
DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++]=FCUNION.P;

    return TCL_OK;
}
static int tcl_dot_camel_Equal(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++]=DotCamelCommand_Equal;
    return TCL_OK;
}
static int tcl_dot_camel_Mult(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++]=DotCamelCommand_Mult;
    return TCL_OK;
}
static int tcl_dot_camel_Div(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++]=DotCamelCommand_Div;
    return TCL_OK;
}
static int tcl_dot_camel_Plus(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++]=DotCamelCommand_Plus;
    return TCL_OK;
}
static int tcl_dot_camel_Minus(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++]=DotCamelCommand_Minus;
    return TCL_OK;
}
static int tcl_dot_camel_GreaterThan(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++]=DotCamelCommand_GreaterThan;
    return TCL_OK;
}
static int tcl_dot_camel_Branch(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=2) {
        #Error: "%s requires the following arguments: (int step)" argv[0]
    }
DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++]=DotCamelCommand_Branch;
FCUNION.I=atoi(argv[1]);
DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++]=FCUNION.P;

    return TCL_OK;
}
static int tcl_dot_camel_AtLeast(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++]=DotCamelCommand_AtLeast;
    return TCL_OK;
}
static int tcl_dot_camel_Different(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++]=DotCamelCommand_Different;
    return TCL_OK;
}
void init_tcl_dot_camel(Tcl_Interp *interp) {
Tcl_CreateCommand(interp, "DotCamelCommand_AtMost", tcl_dot_camel_AtMost, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommand_LessThan", tcl_dot_camel_LessThan, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommand_Pop", tcl_dot_camel_Pop, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommand_Push", tcl_dot_camel_Push, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommand_Equal", tcl_dot_camel_Equal, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommand_Mult", tcl_dot_camel_Mult, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommand_Div", tcl_dot_camel_Div, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommand_Plus", tcl_dot_camel_Plus, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommand_Minus", tcl_dot_camel_Minus, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommand_GreaterThan", tcl_dot_camel_GreaterThan, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommand_Branch", tcl_dot_camel_Branch, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommand_AtLeast", tcl_dot_camel_AtLeast, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommand_Different", tcl_dot_camel_Different, NULL, NULL);
}
