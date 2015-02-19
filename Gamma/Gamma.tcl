GammaCommand Push {float F} {
    #Info: "Pushing Constant (%g)" F
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F=F;
    GammaVirtualMachineStackIndex--;
}

GammaCommand GoSub {int SubRoutine} {
    #Info: "%ld/%ld: Gosub to %ld" GammaVirtualMachineGosubStackIndex GammaVirtualMachineGosubStackSize SubRoutine
    GammaVirtualMachineGosubStack[GammaVirtualMachineGosubStackIndex].I=GammaVirtualMachineBatchProgramCounter;
    GammaVirtualMachineGosubStackIndex--;
    GammaVirtualMachineGosubStack[GammaVirtualMachineGosubStackIndex].I=GammaVirtualMachineStackArgs;
    GammaVirtualMachineGosubStackIndex--;
    GammaVirtualMachineBatchProgramCounter=SubRoutine-2;
    GammaVirtualMachineStackArgs=GammaVirtualMachineStackIndex;
}
GammaCommand Return {int NumOfArguments} {
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
GammaCommand PushArg {int Arg} {
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F=GammaVirtualMachineStack[GammaVirtualMachineStackArgs+Arg].F;
    GammaVirtualMachineStackIndex--;
}
GammaCommand PushVar {var C} {
    #Info: "Pushing var %x (%g)" C *C
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F=*C;
    GammaVirtualMachineStackIndex--;
}
GammaCommand PushPointer {LUT C} {
    #Info: "Pushing pointer %x" C 
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex].P=C;
    GammaVirtualMachineStackIndex--;
}
GammaCommand PopVar {var C} {
    GammaVirtualMachineStackIndex++;
    #Info: "Poping Var %x (%g->%g)" &(GammaVirtualMachineStack[GammaVirtualMachineStackIndex]) *((float*)C) GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F
    *((float *)C)=GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F;
}
GammaCommand Pop {} {
    GammaVirtualMachineStackIndex++;
}
GammaCommand Interpolate {} {
    #Info: "Accessing LUT at %x" GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].P
    LUT *a=(LUT *)GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].P;
    #Info: "Calling interpolation %x" a->gamma_interpolate
    a->gamma_interpolate(a);
}
set op_template {
    float F=GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F@GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F;
    #Info: "%g@%g=%g" GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F F
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F=F;
    GammaVirtualMachineStackIndex++;
}
foreach op {+ - * /} op_name {Plus Minus Mult Div} {
    regsub -all @ $op_template $op body
    GammaOperator $op_name {} $body 
}
GammaCommand Limit {} {
    if (GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F>GammaVirtualMachineStack[GammaVirtualMachineStackIndex+3].F) GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F=GammaVirtualMachineStack[GammaVirtualMachineStackIndex+3].F;
    if (GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F<GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F) GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F=GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F;
}
set op_template {
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].I=GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F@GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].I;
    if (!(GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].I)) GammaVirtualMachineSkip=1;
    GammaVirtualMachineStackIndex++;
}
foreach op [list || "\\&\\&"] op_name {Or And} {
    regsub -all @ $op_template $op body
    GammaOperator $op_name {} $body 
}
GammaCommand Reverse {} {
    float temp=GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F;
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F=GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F;
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F=temp;
}
foreach op {fabs log10 sqrt} name {Abs Log10 Sqrt} {
    GammaCommand $name {} "GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F=${op}(GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F);"
}

set op_template {
    if (!(GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F@GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F)) {
        #Info: "Failed %g @ %g" GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F
	GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].I=0;
        GammaVirtualMachineSkip=1;
    } else {
	GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].I=1;
        #Info: "Passed %g @ %g" GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2].F
    }	
    GammaVirtualMachineStackIndex++;
}
foreach op {< > <= >= == !=} op_name {LessThan GreaterThan AtMost AtLeast Equal Different} {
    regsub -all @ $op_template $op body
    GammaOperator $op_name {} $body 
}

GammaCommand Branch {int step} {
    GammaVirtualMachineBatchProgramCounter+=step;
}
GammaCommand Stop {} {
    GammaVirtualMachineReset();
}
GammaCommand Goto {int location} {
    GammaVirtualMachineBatchProgramCounter=location-2;
}
GammaCommand DumpStack {} {
    int i;
    #Info: "This is the content of the stack (index=%ld):" GammaVirtualMachineStackIndex
    for (i=GammaVirtualMachineStackSize-1;i>GammaVirtualMachineStackIndex;i--) {
        #Info: "Stack[%d] = %f" i GammaVirtualMachineStack[i].F
    }
}
