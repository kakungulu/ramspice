#include <stdio.h>
#include <stdlib.h>
#include "Data/ctree.h"
#include "Gamma/Gamma.h"
void GammaCommandPush() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    #Info: "%ld: Push" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;
        float F=GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter+1].F;

    #Info: "Pushing Constant (%g)" F
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F=F;
    GammaVirtualMachineStackIndex--;
    }
    GammaVirtualMachineBatchProgramCounter+=2;
}
void GammaCommandGoSub() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    #Info: "%ld: GoSub" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;
        ordinal SubRoutine=GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter+1].I;

    #Info: "%ld/%ld: Gosub to %ld" GammaVirtualMachineGosubStackIndex GammaVirtualMachineGosubStackSize SubRoutine
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
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    #Info: "%ld: Return" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;
        ordinal NumOfArguments=GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter+1].I;

    if (GammaVirtualMachineGosubStackIndex+1>=GammaVirtualMachineGosubStackSize) {
        #Info: "Returning to nothing. Stoping!"
        GammaVirtualMachineReset();
	return;
    }
    GammaVirtualMachineGosubStackIndex++;
    GammaVirtualMachineStackArgs=GammaVirtualMachineGosubStack[GammaVirtualMachineGosubStackIndex].I;
    GammaVirtualMachineGosubStackIndex++;
    GammaVirtualMachineBatchProgramCounter=GammaVirtualMachineGosubStack[GammaVirtualMachineGosubStackIndex].I;
    #Info: "%ld/%ld: Returning to %ld with value=%g" GammaVirtualMachineGosubStackIndex GammaVirtualMachineGosubStackSize GammaVirtualMachineBatchProgramCounter+2 GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex+NumOfArguments+1].F=GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F;
    GammaVirtualMachineStackIndex+=NumOfArguments;
    }
    GammaVirtualMachineBatchProgramCounter+=2;
}
void GammaCommandPushArg() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    #Info: "%ld: PushArg" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;
        ordinal Arg=GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter+1].I;

    GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F=GammaVirtualMachineStack[GammaVirtualMachineStackArgs+Arg].F;
    GammaVirtualMachineStackIndex--;
    }
    GammaVirtualMachineBatchProgramCounter+=2;
}
void GammaCommandPushVar() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    #Info: "%ld: PushVar" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;
        float *C=(float *)GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter+1].P;

    #Info: "Pushing var %x (%g)" C *C
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F=*C;
    GammaVirtualMachineStackIndex--;
    }
    GammaVirtualMachineBatchProgramCounter+=2;
}
void GammaCommandPushPointer() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    #Info: "%ld: PushPointer" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;
        LUT *C=(LUT *)GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter+1].P;

    #Info: "Pushing pointer %x" C 
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex].P=C;
    GammaVirtualMachineStackIndex--;
    }
    GammaVirtualMachineBatchProgramCounter+=2;
}
void GammaCommandPopVar() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    #Info: "%ld: PopVar" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;
        float *C=(float *)GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter+1].P;

    GammaVirtualMachineStackIndex++;
    #Info: "Poping Var %x (%g->%g)" &(GammaVirtualMachineStack[GammaVirtualMachineStackIndex]) *((float*)C) GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F
    *((float *)C)=GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F;
    }
    GammaVirtualMachineBatchProgramCounter+=2;
}
void GammaCommandPop() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    #Info: "%ld: Pop" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;

    GammaVirtualMachineStackIndex++;
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandInterpolate() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    #Info: "%ld: Interpolate" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;

    #Info: "Accessing LUT at %x" GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].P
    LUT *a=(LUT *)GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].P;
    #Info: "Calling interpolation %x" a->gamma_interpolate
    a->gamma_interpolate(a);
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandPlus() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (1) {
    #Info: "%ld: Plus" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;

    float F=GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F+GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F;
    #Info: "%g+%g=%g" GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F F
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F=F;
    GammaVirtualMachineStackIndex++;
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandMinus() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (1) {
    #Info: "%ld: Minus" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;

    float F=GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F-GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F;
    #Info: "%g-%g=%g" GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F F
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F=F;
    GammaVirtualMachineStackIndex++;
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandMult() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (1) {
    #Info: "%ld: Mult" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;

    float F=GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F*GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F;
    #Info: "%g*%g=%g" GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F F
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F=F;
    GammaVirtualMachineStackIndex++;
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandDiv() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (1) {
    #Info: "%ld: Div" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;

    float F=GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F/GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F;
    #Info: "%g/%g=%g" GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F F
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F=F;
    GammaVirtualMachineStackIndex++;
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandLimit() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    #Info: "%ld: Limit" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;

    if (GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F>GammaVirtualMachineStack[GammaVirtualMachineStackIndex+3].F) GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F=GammaVirtualMachineStack[GammaVirtualMachineStackIndex+3].F;
    if (GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F<GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F) GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F=GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F;
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandOr() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (1) {
    #Info: "%ld: Or" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;

    GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].I=GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F||GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].I;
    if (!(GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].I)) GammaVirtualMachineSkip=1;
    GammaVirtualMachineStackIndex++;
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandAnd() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (1) {
    #Info: "%ld: And" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;

    GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].I=GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F&&GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].I;
    if (!(GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].I)) GammaVirtualMachineSkip=1;
    GammaVirtualMachineStackIndex++;
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandReverse() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    #Info: "%ld: Reverse" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;

    float temp=GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F;
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F=GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F;
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F=temp;
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandAbs() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    #Info: "%ld: Abs" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;
GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F=fabs(GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F);    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandLog10() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    #Info: "%ld: Log10" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;
GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F=log10(GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F);    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandSqrt() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    #Info: "%ld: Sqrt" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;
GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F=sqrt(GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F);    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandLessThan() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (1) {
    #Info: "%ld: LessThan" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;

    if (!(GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F<GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F)) {
        #Info: "Failed %g < %g" GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F
	GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].I=0;
        GammaVirtualMachineSkip=1;
    } else {
	GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].I=1;
        #Info: "Passed %g < %g" GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F
    }	
    GammaVirtualMachineStackIndex++;
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandGreaterThan() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (1) {
    #Info: "%ld: GreaterThan" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;

    if (!(GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F>GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F)) {
        #Info: "Failed %g > %g" GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F
	GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].I=0;
        GammaVirtualMachineSkip=1;
    } else {
	GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].I=1;
        #Info: "Passed %g > %g" GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F
    }	
    GammaVirtualMachineStackIndex++;
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandAtMost() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (1) {
    #Info: "%ld: AtMost" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;

    if (!(GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F<=GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F)) {
        #Info: "Failed %g <= %g" GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F
	GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].I=0;
        GammaVirtualMachineSkip=1;
    } else {
	GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].I=1;
        #Info: "Passed %g <= %g" GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F
    }	
    GammaVirtualMachineStackIndex++;
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandAtLeast() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (1) {
    #Info: "%ld: AtLeast" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;

    if (!(GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F>=GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F)) {
        #Info: "Failed %g >= %g" GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F
	GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].I=0;
        GammaVirtualMachineSkip=1;
    } else {
	GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].I=1;
        #Info: "Passed %g >= %g" GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F
    }	
    GammaVirtualMachineStackIndex++;
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandEqual() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (1) {
    #Info: "%ld: Equal" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;

    if (!(GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F==GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F)) {
        #Info: "Failed %g == %g" GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F
	GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].I=0;
        GammaVirtualMachineSkip=1;
    } else {
	GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].I=1;
        #Info: "Passed %g == %g" GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F
    }	
    GammaVirtualMachineStackIndex++;
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandDifferent() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (1) {
    #Info: "%ld: Different" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;

    if (!(GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F!=GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F)) {
        #Info: "Failed %g != %g" GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F
	GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].I=0;
        GammaVirtualMachineSkip=1;
    } else {
	GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].I=1;
        #Info: "Passed %g != %g" GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F
    }	
    GammaVirtualMachineStackIndex++;
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandBranch() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    #Info: "%ld: Branch" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;
        ordinal step=GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter+1].I;

    GammaVirtualMachineBatchProgramCounter+=step;
    }
    GammaVirtualMachineBatchProgramCounter+=2;
}
void GammaCommandStop() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    #Info: "%ld: Stop" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;

    GammaVirtualMachineReset();
    }
    GammaVirtualMachineBatchProgramCounter+=1;
}
void GammaCommandGoto() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    #Info: "%ld: Goto" GammaVirtualMachineBatchProgramCounter
 FC FCUNION;
        ordinal location=GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter+1].I;

    GammaVirtualMachineBatchProgramCounter=location-2;
    }
    GammaVirtualMachineBatchProgramCounter+=2;
}
void GammaCommandDumpStack() {
    int GammaVirtualMachineTempSkip=GammaVirtualMachineSkip;
    GammaVirtualMachineSkip=0;
    if (!GammaVirtualMachineTempSkip) {
    #Info: "%ld: DumpStack" GammaVirtualMachineBatchProgramCounter
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
    #Info: "Assembly %ld: %x AtMost " GammaVirtualMachineBatchProgramSize-1 GammaCommandAtMost 
    return TCL_OK;
}
int tcl_gamma_GoSub(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=2) {
        #Error: "%s requires the following arguments: (int SubRoutine)" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandGoSub;
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].I=atoi(argv[1]);

    #Info: "Assembly %ld: %x GoSub %ld " GammaVirtualMachineBatchProgramSize-2 GammaCommandGoSub atoi(argv[1]) 
    return TCL_OK;
}
int tcl_gamma_Return(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=2) {
        #Error: "%s requires the following arguments: (int NumOfArguments)" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandReturn;
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].I=atoi(argv[1]);

    #Info: "Assembly %ld: %x Return %ld " GammaVirtualMachineBatchProgramSize-2 GammaCommandReturn atoi(argv[1]) 
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

    #Info: "Assembly %ld: %x PopVar %x " GammaVirtualMachineBatchProgramSize-2 GammaCommandPopVar (&(GammaContext1->value.s)) 
    return TCL_OK;
}
int tcl_gamma_Goto(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=2) {
        #Error: "%s requires the following arguments: (int location)" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandGoto;
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].I=atoi(argv[1]);

    #Info: "Assembly %ld: %x Goto %ld " GammaVirtualMachineBatchProgramSize-2 GammaCommandGoto atoi(argv[1]) 
    return TCL_OK;
}
int tcl_gamma_LessThan(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandLessThan;
    #Info: "Assembly %ld: %x LessThan " GammaVirtualMachineBatchProgramSize-1 GammaCommandLessThan 
    return TCL_OK;
}
int tcl_gamma_Sqrt(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandSqrt;
    #Info: "Assembly %ld: %x Sqrt " GammaVirtualMachineBatchProgramSize-1 GammaCommandSqrt 
    return TCL_OK;
}
int tcl_gamma_PushArg(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=2) {
        #Error: "%s requires the following arguments: (int Arg)" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandPushArg;
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].I=atoi(argv[1]);

    #Info: "Assembly %ld: %x PushArg %ld " GammaVirtualMachineBatchProgramSize-2 GammaCommandPushArg atoi(argv[1]) 
    return TCL_OK;
}
int tcl_gamma_Log10(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandLog10;
    #Info: "Assembly %ld: %x Log10 " GammaVirtualMachineBatchProgramSize-1 GammaCommandLog10 
    return TCL_OK;
}
int tcl_gamma_And(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandAnd;
    #Info: "Assembly %ld: %x And " GammaVirtualMachineBatchProgramSize-1 GammaCommandAnd 
    return TCL_OK;
}
int tcl_gamma_Reverse(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandReverse;
    #Info: "Assembly %ld: %x Reverse " GammaVirtualMachineBatchProgramSize-1 GammaCommandReverse 
    return TCL_OK;
}
int tcl_gamma_Stop(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandStop;
    #Info: "Assembly %ld: %x Stop " GammaVirtualMachineBatchProgramSize-1 GammaCommandStop 
    return TCL_OK;
}
int tcl_gamma_Abs(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandAbs;
    #Info: "Assembly %ld: %x Abs " GammaVirtualMachineBatchProgramSize-1 GammaCommandAbs 
    return TCL_OK;
}
int tcl_gamma_Pop(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandPop;
    #Info: "Assembly %ld: %x Pop " GammaVirtualMachineBatchProgramSize-1 GammaCommandPop 
    return TCL_OK;
}
int tcl_gamma_Equal(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandEqual;
    #Info: "Assembly %ld: %x Equal " GammaVirtualMachineBatchProgramSize-1 GammaCommandEqual 
    return TCL_OK;
}
int tcl_gamma_Push(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=2) {
        #Error: "%s requires the following arguments: (float F)" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandPush;
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].F=strtof(argv[1],NULL);

    #Info: "Assembly %ld: %x Push %g " GammaVirtualMachineBatchProgramSize-2 GammaCommandPush strtof(argv[1],NULL) 
    return TCL_OK;
}
int tcl_gamma_Or(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandOr;
    #Info: "Assembly %ld: %x Or " GammaVirtualMachineBatchProgramSize-1 GammaCommandOr 
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

    #Info: "Assembly %ld: %x PushVar %x " GammaVirtualMachineBatchProgramSize-2 GammaCommandPushVar (&(GammaContext1->value.s)) 
    return TCL_OK;
}
int tcl_gamma_PushPointer(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=2) {
        #Error: "%s requires the following arguments: (LUT C)" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandPushPointer;
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].P=get_LUT(argv[1]);

    #Info: "Assembly %ld: %x PushPointer %x " GammaVirtualMachineBatchProgramSize-2 GammaCommandPushPointer get_LUT(argv[1]) 
    return TCL_OK;
}
int tcl_gamma_Mult(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandMult;
    #Info: "Assembly %ld: %x Mult " GammaVirtualMachineBatchProgramSize-1 GammaCommandMult 
    return TCL_OK;
}
int tcl_gamma_Div(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandDiv;
    #Info: "Assembly %ld: %x Div " GammaVirtualMachineBatchProgramSize-1 GammaCommandDiv 
    return TCL_OK;
}
int tcl_gamma_DumpStack(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandDumpStack;
    #Info: "Assembly %ld: %x DumpStack " GammaVirtualMachineBatchProgramSize-1 GammaCommandDumpStack 
    return TCL_OK;
}
int tcl_gamma_Plus(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandPlus;
    #Info: "Assembly %ld: %x Plus " GammaVirtualMachineBatchProgramSize-1 GammaCommandPlus 
    return TCL_OK;
}
int tcl_gamma_Minus(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandMinus;
    #Info: "Assembly %ld: %x Minus " GammaVirtualMachineBatchProgramSize-1 GammaCommandMinus 
    return TCL_OK;
}
int tcl_gamma_GreaterThan(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandGreaterThan;
    #Info: "Assembly %ld: %x GreaterThan " GammaVirtualMachineBatchProgramSize-1 GammaCommandGreaterThan 
    return TCL_OK;
}
int tcl_gamma_Branch(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=2) {
        #Error: "%s requires the following arguments: (int step)" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandBranch;
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].I=atoi(argv[1]);

    #Info: "Assembly %ld: %x Branch %ld " GammaVirtualMachineBatchProgramSize-2 GammaCommandBranch atoi(argv[1]) 
    return TCL_OK;
}
int tcl_gamma_AtLeast(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandAtLeast;
    #Info: "Assembly %ld: %x AtLeast " GammaVirtualMachineBatchProgramSize-1 GammaCommandAtLeast 
    return TCL_OK;
}
int tcl_gamma_Different(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandDifferent;
    #Info: "Assembly %ld: %x Different " GammaVirtualMachineBatchProgramSize-1 GammaCommandDifferent 
    return TCL_OK;
}
int tcl_gamma_Limit(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandLimit;
    #Info: "Assembly %ld: %x Limit " GammaVirtualMachineBatchProgramSize-1 GammaCommandLimit 
    return TCL_OK;
}
int tcl_gamma_Interpolate(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    FC FCUNION;
    if (argc!=1) {
        #Error: "%s requires the following arguments: ()" argv[0]
    }
    GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramSize++].func=GammaCommandInterpolate;
    #Info: "Assembly %ld: %x Interpolate " GammaVirtualMachineBatchProgramSize-1 GammaCommandInterpolate 
    return TCL_OK;
}
void init_tcl_gamma(Tcl_Interp *interp) {
Tcl_CreateCommand(interp, "GammaCommandAtMost", tcl_gamma_AtMost, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandGoSub", tcl_gamma_GoSub, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandReturn", tcl_gamma_Return, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandPopVar", tcl_gamma_PopVar, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandGoto", tcl_gamma_Goto, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandLessThan", tcl_gamma_LessThan, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandSqrt", tcl_gamma_Sqrt, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandPushArg", tcl_gamma_PushArg, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandLog10", tcl_gamma_Log10, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandAnd", tcl_gamma_And, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandReverse", tcl_gamma_Reverse, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandStop", tcl_gamma_Stop, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandAbs", tcl_gamma_Abs, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandPop", tcl_gamma_Pop, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandEqual", tcl_gamma_Equal, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandPush", tcl_gamma_Push, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandOr", tcl_gamma_Or, NULL, NULL);
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
Tcl_CreateCommand(interp, "GammaCommandLimit", tcl_gamma_Limit, NULL, NULL);
Tcl_CreateCommand(interp, "GammaCommandInterpolate", tcl_gamma_Interpolate, NULL, NULL);
}
