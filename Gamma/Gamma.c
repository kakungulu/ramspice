#include <stdio.h>
#include <stdlib.h>
#include "Data/ctree.h"
#include "Gamma/Gamma.h"
void GammaCommandPush() {
    #Info: "Push"
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    FC FCUNION;
        float F=GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter+1].F;

    GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F=F;
    GammaVirtualMachineStackIndex--;
    }
    GammaVirtualMachineBatchProgramCounter+=2;
}
void GammaCommandGoSub() {
    #Info: "GoSub"
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    FC FCUNION;
        ordinal SubRoutine=GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter+1].I;

    GammaVirtualMachineGosubStack[GammaVirtualMachineGosubStackIndex].I=GammaVirtualMachineBatchProgramCounter;
    GammaVirtualMachineGosubStackIndex--;
    GammaVirtualMachineGosubStack[GammaVirtualMachineGosubStackIndex].I=GammaVirtualMachineStackArgs;
    GammaVirtualMachineGosubStackIndex--;
    GammaVirtualMachineBatchProgramCounter=SubRoutine-2;
    GammaVirtualMachineStackArgs=GammaVirtualMachineStackIndex;
    }
    GammaVirtualMachineBatchProgramCounter+=2;
}
void GammaCommandReturn() {
    #Info: "Return"
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    FC FCUNION;
        ordinal NumOfArguments=GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter+1].I;

    GammaVirtualMachineGosubStackIndex++;
    GammaVirtualMachineStackArgs=GammaVirtualMachineGosubStack[GammaVirtualMachineGosubStackIndex].I;
    GammaVirtualMachineGosubStackIndex++;
    GammaVirtualMachineBatchProgramCounter=GammaVirtualMachineGosubStack[GammaVirtualMachineGosubStackIndex].I;
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex+NumOfArguments+1].F=GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F;
    GammaVirtualMachineStackIndex+=NumOfArguments;
    }
    GammaVirtualMachineBatchProgramCounter+=2;
}
void GammaCommandPushArg() {
    #Info: "PushArg"
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    FC FCUNION;
        ordinal Arg=GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter+1].I;

    GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F=GammaVirtualMachineStack[GammaVirtualMachineStackArgs+Arg].F;
    GammaVirtualMachineStackIndex--;
    }
    GammaVirtualMachineBatchProgramCounter+=2;
}
void GammaCommandPushVar() {
    #Info: "PushVar"
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    FC FCUNION;
        float *C=(float *)GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter+1].P;

    #Info: "Pushing var %x (%g)" C *C
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F=*C;
    GammaVirtualMachineStackIndex--;
    }
    GammaVirtualMachineBatchProgramCounter+=2;
}
void GammaCommandPushPointer() {
    #Info: "PushPointer"
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    FC FCUNION;
        LUT *C=(LUT *)GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter+1].P;

    #Info: "Pushing pointer %x" C 
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex].P=C;
    GammaVirtualMachineStackIndex--;
    }
    GammaVirtualMachineBatchProgramCounter+=2;
}
void GammaCommandPopVar() {
    #Info: "PopVar"
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    FC FCUNION;
        float *C=(float *)GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter+1].P;

    GammaVirtualMachineStackIndex++;
    #Info: "Poping Var %x (%g->%g)" &(GammaVirtualMachineStack[GammaVirtualMachineStackIndex]) *((float*)C) GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F
    *((float *)C)=GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F;
    }
    GammaVirtualMachineBatchProgramCounter+=2;
}
void GammaCommandPop() {
    #Info: "Pop"
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    FC FCUNION;

    GammaVirtualMachineStackIndex++;
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandInterpolate() {
    #Info: "Interpolate"
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    FC FCUNION;

    #Info: "Accessing LUT at %x" GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].P
    LUT *a=(LUT *)GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].P;
    #Info: "Calling interpolation %x" a->gamma_interpolate
    a->gamma_interpolate(a);
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandPlus() {
    #Info: "Plus"
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    FC FCUNION;

    GammaVirtualMachineStackIndex++;
    GammaVirtualMachineStackIndex++;
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F=GammaVirtualMachineStack[GammaVirtualMachineStackIndex-1].F+GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F;
    GammaVirtualMachineStackIndex--;
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandMinus() {
    #Info: "Minus"
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    FC FCUNION;

    GammaVirtualMachineStackIndex++;
    GammaVirtualMachineStackIndex++;
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F=GammaVirtualMachineStack[GammaVirtualMachineStackIndex-1].F-GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F;
    GammaVirtualMachineStackIndex--;
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandMult() {
    #Info: "Mult"
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    FC FCUNION;

    GammaVirtualMachineStackIndex++;
    GammaVirtualMachineStackIndex++;
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F=GammaVirtualMachineStack[GammaVirtualMachineStackIndex-1].F*GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F;
    GammaVirtualMachineStackIndex--;
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandDiv() {
    #Info: "Div"
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    FC FCUNION;

    GammaVirtualMachineStackIndex++;
    GammaVirtualMachineStackIndex++;
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F=GammaVirtualMachineStack[GammaVirtualMachineStackIndex-1].F/GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F;
    GammaVirtualMachineStackIndex--;
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandAbs() {
    #Info: "Abs"
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    FC FCUNION;

   GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F=fabs(GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F);
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandLessThan() {
    #Info: "LessThan"
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    FC FCUNION;

    if (!(GammaVirtualMachineStack[GammaVirtualMachineStackIndex-1].F<GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F)) GammaVirtualMachineSkip=1;
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandGreaterThan() {
    #Info: "GreaterThan"
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    FC FCUNION;

    if (!(GammaVirtualMachineStack[GammaVirtualMachineStackIndex-1].F>GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F)) GammaVirtualMachineSkip=1;
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandAtMost() {
    #Info: "AtMost"
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    FC FCUNION;

    if (!(GammaVirtualMachineStack[GammaVirtualMachineStackIndex-1].F<=GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F)) GammaVirtualMachineSkip=1;
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandAtLeast() {
    #Info: "AtLeast"
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    FC FCUNION;

    if (!(GammaVirtualMachineStack[GammaVirtualMachineStackIndex-1].F>=GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F)) GammaVirtualMachineSkip=1;
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandEqual() {
    #Info: "Equal"
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    FC FCUNION;

    if (!(GammaVirtualMachineStack[GammaVirtualMachineStackIndex-1].F==GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F)) GammaVirtualMachineSkip=1;
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandDifferent() {
    #Info: "Different"
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    FC FCUNION;

    if (!(GammaVirtualMachineStack[GammaVirtualMachineStackIndex-1].F!=GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F)) GammaVirtualMachineSkip=1;
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandBranch() {
    #Info: "Branch"
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    FC FCUNION;
        ordinal step=GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter+1].I;

    GammaVirtualMachineBatchProgramCounter+=step;
    }
    GammaVirtualMachineBatchProgramCounter+=2;
}
void GammaCommandStop() {
    #Info: "Stop"
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    FC FCUNION;

    GammaVirtualMachineRunning=0;
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandGoto() {
    #Info: "Goto"
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    FC FCUNION;
        ordinal location=GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter+1].I;

    GammaVirtualMachineBatchProgramCounter=location-2;
    }
    GammaVirtualMachineBatchProgramCounter+=2;
}
void GammaCommandDumpStack() {
    #Info: "DumpStack"
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    FC FCUNION;

    int i;
    #Info: "This is the content of the stack (index=%ld):" GammaVirtualMachineStackIndex
    for (i=GammaVirtualMachineStackSize-1;i>GammaVirtualMachineStackIndex;i--) {
        #Info: "Stack[%d] = %f" i GammaVirtualMachineStack[i].F
    }
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
int tcl_gamma_AtMost(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandAtMost;
    return TCL_OK;
}
int tcl_gamma_GoSub(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=2) {
        #Error: "%s requires the following arguments: (int SubRoutine)" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandGoSub;
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].I=atoi(argv[1]);

    return TCL_OK;
}
int tcl_gamma_Return(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=2) {
        #Error: "%s requires the following arguments: (int NumOfArguments)" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandReturn;
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].I=atoi(argv[1]);

    return TCL_OK;
}
int tcl_gamma_PopVar(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=2) {
        #Error: "%s requires the following arguments: (var C)" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandPopVar;
    context *GammaContext1;
    resolve_context(argv[1],&(GammaContext1),NULL);
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].P=(void *)(&(GammaContext1->value.s));

    return TCL_OK;
}
int tcl_gamma_Goto(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=2) {
        #Error: "%s requires the following arguments: (int location)" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandGoto;
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].I=atoi(argv[1]);

    return TCL_OK;
}
int tcl_gamma_LessThan(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandLessThan;
    return TCL_OK;
}
int tcl_gamma_PushArg(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=2) {
        #Error: "%s requires the following arguments: (int Arg)" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandPushArg;
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].I=atoi(argv[1]);

    return TCL_OK;
}
int tcl_gamma_Stop(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandStop;
    return TCL_OK;
}
int tcl_gamma_Abs(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandAbs;
    return TCL_OK;
}
int tcl_gamma_Pop(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandPop;
    return TCL_OK;
}
int tcl_gamma_Equal(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandEqual;
    return TCL_OK;
}
int tcl_gamma_Push(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=2) {
        #Error: "%s requires the following arguments: (float F)" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandPush;
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].F=strtof(argv[1],NULL);

    return TCL_OK;
}
int tcl_gamma_PushVar(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=2) {
        #Error: "%s requires the following arguments: (var C)" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandPushVar;
    context *GammaContext1;
    resolve_context(argv[1],&(GammaContext1),NULL);
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].P=(void *)(&(GammaContext1->value.s));

    return TCL_OK;
}
int tcl_gamma_PushPointer(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=2) {
        #Error: "%s requires the following arguments: (LUT C)" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandPushPointer;
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].P=get_LUT(argv[1]);

    return TCL_OK;
}
int tcl_gamma_Mult(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandMult;
    return TCL_OK;
}
int tcl_gamma_Div(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandDiv;
    return TCL_OK;
}
int tcl_gamma_DumpStack(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandDumpStack;
    return TCL_OK;
}
int tcl_gamma_Plus(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandPlus;
    return TCL_OK;
}
int tcl_gamma_Minus(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandMinus;
    return TCL_OK;
}
int tcl_gamma_GreaterThan(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandGreaterThan;
    return TCL_OK;
}
int tcl_gamma_Branch(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=2) {
        #Error: "%s requires the following arguments: (int step)" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandBranch;
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].I=atoi(argv[1]);

    return TCL_OK;
}
int tcl_gamma_AtLeast(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandAtLeast;
    return TCL_OK;
}
int tcl_gamma_Different(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandDifferent;
    return TCL_OK;
}
int tcl_gamma_Interpolate(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandInterpolate;
    return TCL_OK;
}
void init_tcl_gamma(Tcl_Interp *interp) {
Tcl_CreateCommand(interp, "GammaCommandAtMost", tcl_gamma_AtMost, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandGoSub", tcl_gamma_GoSub, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandReturn", tcl_gamma_Return, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandPopVar", tcl_gamma_PopVar, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandGoto", tcl_gamma_Goto, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandLessThan", tcl_gamma_LessThan, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandPushArg", tcl_gamma_PushArg, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandStop", tcl_gamma_Stop, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandAbs", tcl_gamma_Abs, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandPop", tcl_gamma_Pop, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandEqual", tcl_gamma_Equal, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandPush", tcl_gamma_Push, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandPushVar", tcl_gamma_PushVar, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandPushPointer", tcl_gamma_PushPointer, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandMult", tcl_gamma_Mult, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandDiv", tcl_gamma_Div, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandDumpStack", tcl_gamma_DumpStack, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandPlus", tcl_gamma_Plus, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandMinus", tcl_gamma_Minus, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandGreaterThan", tcl_gamma_GreaterThan, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandBranch", tcl_gamma_Branch, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandAtLeast", tcl_gamma_AtLeast, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandDifferent", tcl_gamma_Different, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandInterpolate", tcl_gamma_Interpolate, NULL, NULL);
}
