#include <stdio.h>
#include <stdlib.h>
#include "Data/ctree.h"
#include "DotCamel/DotCamelCommands.h"
void DotCamelCommandPush() {
    #Info: "Push"
    int DotCamelVirtualMachineTempSkip=DotCamelVirtualMachineSkip;
    DotCamelVirtualMachineSkip=0;
    if (!DotCamelVirtualMachineTempSkip) {
    FC FCUNION;
        float F=DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramCounter+1].F;

    DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex].F=F;
    DotCamelVirtualMachineStackIndex--;
    }
    DotCamelVirtualMachineBatchProgramCounter+=2;
}
void DotCamelCommandGoSub() {
    #Info: "GoSub"
    int DotCamelVirtualMachineTempSkip=DotCamelVirtualMachineSkip;
    DotCamelVirtualMachineSkip=0;
    if (!DotCamelVirtualMachineTempSkip) {
    FC FCUNION;
        ordinal SubRoutine=DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramCounter+1].I;

    DotCamelVirtualMachineGosubStack[DotCamelVirtualMachineGosubStackIndex].I=DotCamelVirtualMachineBatchProgramCounter+1;
    DotCamelVirtualMachineGosubStackIndex--;
    DotCamelVirtualMachineGosubStack[DotCamelVirtualMachineGosubStackIndex].I=DotCamelVirtualMachineStackArgs;
    DotCamelVirtualMachineGosubStackIndex--;
    DotCamelVirtualMachineBatchProgramCounter=SubRoutine-2;
    DotCamelVirtualMachineStackArgs=DotCamelVirtualMachineStackIndex;
    }
    DotCamelVirtualMachineBatchProgramCounter+=2;
}
void DotCamelCommandReturn() {
    #Info: "Return"
    int DotCamelVirtualMachineTempSkip=DotCamelVirtualMachineSkip;
    DotCamelVirtualMachineSkip=0;
    if (!DotCamelVirtualMachineTempSkip) {
    FC FCUNION;

    DotCamelVirtualMachineGosubStackIndex++;
    DotCamelVirtualMachineStackArgs=DotCamelVirtualMachineGosubStack[DotCamelVirtualMachineGosubStackIndex].I;
    DotCamelVirtualMachineGosubStackIndex++;
    DotCamelVirtualMachineBatchProgramCounter=DotCamelVirtualMachineGosubStack[DotCamelVirtualMachineGosubStackIndex].I;
    }
    DotCamelVirtualMachineBatchProgramCounter+=1;
}
void DotCamelCommandPushArg() {
    #Info: "PushArg"
    int DotCamelVirtualMachineTempSkip=DotCamelVirtualMachineSkip;
    DotCamelVirtualMachineSkip=0;
    if (!DotCamelVirtualMachineTempSkip) {
    FC FCUNION;
        ordinal Arg=DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramCounter+1].I;

    DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex].F=DotCamelVirtualMachineStack[DotCamelVirtualMachineStackArgs+Arg].F;
    DotCamelVirtualMachineStackIndex--;
    }
    DotCamelVirtualMachineBatchProgramCounter+=2;
}
void DotCamelCommandPushVar() {
    #Info: "PushVar"
    int DotCamelVirtualMachineTempSkip=DotCamelVirtualMachineSkip;
    DotCamelVirtualMachineSkip=0;
    if (!DotCamelVirtualMachineTempSkip) {
    FC FCUNION;
        float *C=(float *)DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramCounter+1].P;

    #Info: "Pushing var %x (%g)" C *C
    DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex].F=*C;
    DotCamelVirtualMachineStackIndex--;
    }
    DotCamelVirtualMachineBatchProgramCounter+=2;
}
void DotCamelCommandPopVar() {
    #Info: "PopVar"
    int DotCamelVirtualMachineTempSkip=DotCamelVirtualMachineSkip;
    DotCamelVirtualMachineSkip=0;
    if (!DotCamelVirtualMachineTempSkip) {
    FC FCUNION;
        float *C=(float *)DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramCounter+1].P;

    DotCamelVirtualMachineStackIndex++;
    *C=DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex].F;
    }
    DotCamelVirtualMachineBatchProgramCounter+=2;
}
void DotCamelCommandPop() {
    #Info: "Pop"
    int DotCamelVirtualMachineTempSkip=DotCamelVirtualMachineSkip;
    DotCamelVirtualMachineSkip=0;
    if (!DotCamelVirtualMachineTempSkip) {
    FC FCUNION;

    DotCamelVirtualMachineStackIndex++;
    }
    DotCamelVirtualMachineBatchProgramCounter+=1;
}
void DotCamelCommandPlus() {
    #Info: "Plus"
    int DotCamelVirtualMachineTempSkip=DotCamelVirtualMachineSkip;
    DotCamelVirtualMachineSkip=0;
    if (!DotCamelVirtualMachineTempSkip) {
    FC FCUNION;

    DotCamelVirtualMachineStackIndex++;
    DotCamelVirtualMachineStackIndex++;
    DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex].F=DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex+1].F+DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex+2].F;
    DotCamelVirtualMachineStackIndex--;
    }
    DotCamelVirtualMachineBatchProgramCounter+=1;
}
void DotCamelCommandMinus() {
    #Info: "Minus"
    int DotCamelVirtualMachineTempSkip=DotCamelVirtualMachineSkip;
    DotCamelVirtualMachineSkip=0;
    if (!DotCamelVirtualMachineTempSkip) {
    FC FCUNION;

    DotCamelVirtualMachineStackIndex++;
    DotCamelVirtualMachineStackIndex++;
    DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex].F=DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex+1].F-DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex+2].F;
    DotCamelVirtualMachineStackIndex--;
    }
    DotCamelVirtualMachineBatchProgramCounter+=1;
}
void DotCamelCommandMult() {
    #Info: "Mult"
    int DotCamelVirtualMachineTempSkip=DotCamelVirtualMachineSkip;
    DotCamelVirtualMachineSkip=0;
    if (!DotCamelVirtualMachineTempSkip) {
    FC FCUNION;

    DotCamelVirtualMachineStackIndex++;
    DotCamelVirtualMachineStackIndex++;
    DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex].F=DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex+1].F*DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex+2].F;
    DotCamelVirtualMachineStackIndex--;
    }
    DotCamelVirtualMachineBatchProgramCounter+=1;
}
void DotCamelCommandDiv() {
    #Info: "Div"
    int DotCamelVirtualMachineTempSkip=DotCamelVirtualMachineSkip;
    DotCamelVirtualMachineSkip=0;
    if (!DotCamelVirtualMachineTempSkip) {
    FC FCUNION;

    DotCamelVirtualMachineStackIndex++;
    DotCamelVirtualMachineStackIndex++;
    DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex].F=DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex+1].F/DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex+2].F;
    DotCamelVirtualMachineStackIndex--;
    }
    DotCamelVirtualMachineBatchProgramCounter+=1;
}
void DotCamelCommandLessThan() {
    #Info: "LessThan"
    int DotCamelVirtualMachineTempSkip=DotCamelVirtualMachineSkip;
    DotCamelVirtualMachineSkip=0;
    if (!DotCamelVirtualMachineTempSkip) {
    FC FCUNION;

    if (!(DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex+2].F<DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex+1].F)) DotCamelVirtualMachineSkip=1;
    }
    DotCamelVirtualMachineBatchProgramCounter+=1;
}
void DotCamelCommandGreaterThan() {
    #Info: "GreaterThan"
    int DotCamelVirtualMachineTempSkip=DotCamelVirtualMachineSkip;
    DotCamelVirtualMachineSkip=0;
    if (!DotCamelVirtualMachineTempSkip) {
    FC FCUNION;

    if (!(DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex+2].F>DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex+1].F)) DotCamelVirtualMachineSkip=1;
    }
    DotCamelVirtualMachineBatchProgramCounter+=1;
}
void DotCamelCommandAtMost() {
    #Info: "AtMost"
    int DotCamelVirtualMachineTempSkip=DotCamelVirtualMachineSkip;
    DotCamelVirtualMachineSkip=0;
    if (!DotCamelVirtualMachineTempSkip) {
    FC FCUNION;

    if (!(DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex+2].F<=DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex+1].F)) DotCamelVirtualMachineSkip=1;
    }
    DotCamelVirtualMachineBatchProgramCounter+=1;
}
void DotCamelCommandAtLeast() {
    #Info: "AtLeast"
    int DotCamelVirtualMachineTempSkip=DotCamelVirtualMachineSkip;
    DotCamelVirtualMachineSkip=0;
    if (!DotCamelVirtualMachineTempSkip) {
    FC FCUNION;

    if (!(DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex+2].F>=DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex+1].F)) DotCamelVirtualMachineSkip=1;
    }
    DotCamelVirtualMachineBatchProgramCounter+=1;
}
void DotCamelCommandEqual() {
    #Info: "Equal"
    int DotCamelVirtualMachineTempSkip=DotCamelVirtualMachineSkip;
    DotCamelVirtualMachineSkip=0;
    if (!DotCamelVirtualMachineTempSkip) {
    FC FCUNION;

    if (!(DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex+2].F==DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex+1].F)) DotCamelVirtualMachineSkip=1;
    }
    DotCamelVirtualMachineBatchProgramCounter+=1;
}
void DotCamelCommandDifferent() {
    #Info: "Different"
    int DotCamelVirtualMachineTempSkip=DotCamelVirtualMachineSkip;
    DotCamelVirtualMachineSkip=0;
    if (!DotCamelVirtualMachineTempSkip) {
    FC FCUNION;

    if (!(DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex+2].F!=DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex+1].F)) DotCamelVirtualMachineSkip=1;
    }
    DotCamelVirtualMachineBatchProgramCounter+=1;
}
void DotCamelCommandBranch() {
    #Info: "Branch"
    int DotCamelVirtualMachineTempSkip=DotCamelVirtualMachineSkip;
    DotCamelVirtualMachineSkip=0;
    if (!DotCamelVirtualMachineTempSkip) {
    FC FCUNION;
        ordinal step=DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramCounter+1].I;

    DotCamelVirtualMachineBatchProgramCounter+=step;
    }
    DotCamelVirtualMachineBatchProgramCounter+=2;
}
void DotCamelCommandStop() {
    #Info: "Stop"
    int DotCamelVirtualMachineTempSkip=DotCamelVirtualMachineSkip;
    DotCamelVirtualMachineSkip=0;
    if (!DotCamelVirtualMachineTempSkip) {
    FC FCUNION;

    DotCamelVirtualMachineRunning=0;
    }
    DotCamelVirtualMachineBatchProgramCounter+=1;
}
void DotCamelCommandGoto() {
    #Info: "Goto"
    int DotCamelVirtualMachineTempSkip=DotCamelVirtualMachineSkip;
    DotCamelVirtualMachineSkip=0;
    if (!DotCamelVirtualMachineTempSkip) {
    FC FCUNION;
        ordinal location=DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramCounter+1].I;

    DotCamelVirtualMachineBatchProgramCounter=location-2;
    }
    DotCamelVirtualMachineBatchProgramCounter+=2;
}
void DotCamelCommandDumpStack() {
    #Info: "DumpStack"
    int DotCamelVirtualMachineTempSkip=DotCamelVirtualMachineSkip;
    DotCamelVirtualMachineSkip=0;
    if (!DotCamelVirtualMachineTempSkip) {
    FC FCUNION;

    int i;
    #Info: "This is the content of the stack:"
    for (i=DotCamelVirtualMachineStackSize-1;i>DotCamelVirtualMachineStackIndex;i--) {
        #Info: "Stack[%d] = %f" i DotCamelVirtualMachineStack[i].F
    }
    }
    DotCamelVirtualMachineBatchProgramCounter+=1;
}
static int tcl_dot_camel_AtMost(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].func=DotCamelCommandAtMost;
    return TCL_OK;
}
static int tcl_dot_camel_GoSub(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=2) {
        #Error: "%s requires the following arguments: (int SubRoutine)" argv[0]
    }
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].func=DotCamelCommandGoSub;
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].I=atoi(argv[1]);

    return TCL_OK;
}
static int tcl_dot_camel_Return(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].func=DotCamelCommandReturn;
    return TCL_OK;
}
static int tcl_dot_camel_PopVar(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=2) {
        #Error: "%s requires the following arguments: (var C)" argv[0]
    }
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].func=DotCamelCommandPopVar;
    context *DotCamelContext1;
    resolve_context(argv[1],&(DotCamelContext1),NULL);
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].P=(void *)(&(DotCamelContext1->value.s));

    return TCL_OK;
}
static int tcl_dot_camel_Goto(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=2) {
        #Error: "%s requires the following arguments: (int location)" argv[0]
    }
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].func=DotCamelCommandGoto;
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].I=atoi(argv[1]);

    return TCL_OK;
}
static int tcl_dot_camel_PushArg(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=2) {
        #Error: "%s requires the following arguments: (int Arg)" argv[0]
    }
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].func=DotCamelCommandPushArg;
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].I=atoi(argv[1]);

    return TCL_OK;
}
static int tcl_dot_camel_LessThan(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].func=DotCamelCommandLessThan;
    return TCL_OK;
}
static int tcl_dot_camel_Stop(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].func=DotCamelCommandStop;
    return TCL_OK;
}
static int tcl_dot_camel_Pop(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].func=DotCamelCommandPop;
    return TCL_OK;
}
static int tcl_dot_camel_Equal(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].func=DotCamelCommandEqual;
    return TCL_OK;
}
static int tcl_dot_camel_Push(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=2) {
        #Error: "%s requires the following arguments: (float F)" argv[0]
    }
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].func=DotCamelCommandPush;
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].F=strtof(argv[1],NULL);

    return TCL_OK;
}
static int tcl_dot_camel_PushVar(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=2) {
        #Error: "%s requires the following arguments: (var C)" argv[0]
    }
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].func=DotCamelCommandPushVar;
    context *DotCamelContext1;
    resolve_context(argv[1],&(DotCamelContext1),NULL);
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].P=(void *)(&(DotCamelContext1->value.s));

    return TCL_OK;
}
static int tcl_dot_camel_Mult(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].func=DotCamelCommandMult;
    return TCL_OK;
}
static int tcl_dot_camel_Div(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].func=DotCamelCommandDiv;
    return TCL_OK;
}
static int tcl_dot_camel_DumpStack(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].func=DotCamelCommandDumpStack;
    return TCL_OK;
}
static int tcl_dot_camel_Plus(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].func=DotCamelCommandPlus;
    return TCL_OK;
}
static int tcl_dot_camel_Minus(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].func=DotCamelCommandMinus;
    return TCL_OK;
}
static int tcl_dot_camel_GreaterThan(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].func=DotCamelCommandGreaterThan;
    return TCL_OK;
}
static int tcl_dot_camel_Branch(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=2) {
        #Error: "%s requires the following arguments: (int step)" argv[0]
    }
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].func=DotCamelCommandBranch;
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].I=atoi(argv[1]);

    return TCL_OK;
}
static int tcl_dot_camel_AtLeast(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].func=DotCamelCommandAtLeast;
    return TCL_OK;
}
static int tcl_dot_camel_Different(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    DotCamelVirtualMachineBatch[DotCamelVirtualMachineBatchProgramSize++].func=DotCamelCommandDifferent;
    return TCL_OK;
}
void init_tcl_dot_camel(Tcl_Interp *interp) {
Tcl_CreateCommand(interp, "DotCamelCommandAtMost", tcl_dot_camel_AtMost, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommandGoSub", tcl_dot_camel_GoSub, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommandReturn", tcl_dot_camel_Return, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommandPopVar", tcl_dot_camel_PopVar, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommandGoto", tcl_dot_camel_Goto, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommandPushArg", tcl_dot_camel_PushArg, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommandLessThan", tcl_dot_camel_LessThan, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommandStop", tcl_dot_camel_Stop, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommandPop", tcl_dot_camel_Pop, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommandEqual", tcl_dot_camel_Equal, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommandPush", tcl_dot_camel_Push, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommandPushVar", tcl_dot_camel_PushVar, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommandMult", tcl_dot_camel_Mult, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommandDiv", tcl_dot_camel_Div, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommandDumpStack", tcl_dot_camel_DumpStack, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommandPlus", tcl_dot_camel_Plus, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommandMinus", tcl_dot_camel_Minus, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommandGreaterThan", tcl_dot_camel_GreaterThan, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommandBranch", tcl_dot_camel_Branch, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommandAtLeast", tcl_dot_camel_AtLeast, NULL, NULL);
Tcl_CreateCommand(interp, "DotCamelCommandDifferent", tcl_dot_camel_Different, NULL, NULL);
}
