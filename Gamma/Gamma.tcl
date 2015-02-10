GammaCommand Push {float F} {
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F=F;
    GammaVirtualMachineStackIndex--;
}

GammaCommand GoSub {int SubRoutine} {
    GammaVirtualMachineGosubStack[GammaVirtualMachineGosubStackIndex].I=GammaVirtualMachineBatchProgramCounter;
    GammaVirtualMachineGosubStackIndex--;
    GammaVirtualMachineGosubStack[GammaVirtualMachineGosubStackIndex].I=GammaVirtualMachineStackArgs;
    GammaVirtualMachineGosubStackIndex--;
    GammaVirtualMachineBatchProgramCounter=SubRoutine-2;
    GammaVirtualMachineStackArgs=GammaVirtualMachineStackIndex;
}
GammaCommand Return {int NumOfArguments} {
    GammaVirtualMachineGosubStackIndex++;
    GammaVirtualMachineStackArgs=GammaVirtualMachineGosubStack[GammaVirtualMachineGosubStackIndex].I;
    GammaVirtualMachineGosubStackIndex++;
    GammaVirtualMachineBatchProgramCounter=GammaVirtualMachineGosubStack[GammaVirtualMachineGosubStackIndex].I;
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
    GammaVirtualMachineStackIndex++;
    GammaVirtualMachineStackIndex++;
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F=GammaVirtualMachineStack[GammaVirtualMachineStackIndex-1].F@GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F;
    GammaVirtualMachineStackIndex--;
}
foreach op {+ - * /} op_name {Plus Minus Mult Div} {
    regsub @ $op_template $op body
    GammaCommand $op_name {} $body 
}

GammaCommand Abs {} {
   GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F=fabs(GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F);
}

set op_template {
    if (!(GammaVirtualMachineStack[GammaVirtualMachineStackIndex-1].F@GammaVirtualMachineStack[GammaVirtualMachineStackIndex].F)) GammaVirtualMachineSkip=1;
}
foreach op {< > <= >= == !=} op_name {LessThan GreaterThan AtMost AtLeast Equal Different} {
    regsub @ $op_template $op body
    GammaCommand $op_name {} $body 
}

GammaCommand Branch {int step} {
    GammaVirtualMachineBatchProgramCounter+=step;
}
GammaCommand Stop {} {
    GammaVirtualMachineRunning=0;
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
