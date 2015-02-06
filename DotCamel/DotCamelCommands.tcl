DotCamelCommand Push {float F} {
    DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex].F=F;
    DotCamelVirtualMachineStackIndex--;
}

DotCamelCommand GoSub {int SubRoutine} {
    DotCamelVirtualMachineGosubStack[DotCamelVirtualMachineGosubStackIndex].I=DotCamelVirtualMachineBatchProgramCounter;
    DotCamelVirtualMachineGosubStackIndex--;
    DotCamelVirtualMachineGosubStack[DotCamelVirtualMachineGosubStackIndex].I=DotCamelVirtualMachineStackArgs;
    DotCamelVirtualMachineGosubStackIndex--;
    DotCamelVirtualMachineBatchProgramCounter=SubRoutine-2;
    DotCamelVirtualMachineStackArgs=DotCamelVirtualMachineStackIndex;
}
DotCamelCommand Return {int NumOfArguments} {
    DotCamelVirtualMachineGosubStackIndex++;
    DotCamelVirtualMachineStackArgs=DotCamelVirtualMachineGosubStack[DotCamelVirtualMachineGosubStackIndex].I;
    DotCamelVirtualMachineGosubStackIndex++;
    DotCamelVirtualMachineBatchProgramCounter=DotCamelVirtualMachineGosubStack[DotCamelVirtualMachineGosubStackIndex].I;
    DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex+NumOfArguments+1].F=DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex+1].F;
    DotCamelVirtualMachineStackIndex+=NumOfArguments;
}
DotCamelCommand PushArg {int Arg} {
    DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex].F=DotCamelVirtualMachineStack[DotCamelVirtualMachineStackArgs+Arg].F;
    DotCamelVirtualMachineStackIndex--;
}
DotCamelCommand PushVar {var C} {
    #Info: "Pushing var %x (%g)" C *C
    DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex].F=*C;
    DotCamelVirtualMachineStackIndex--;
}
DotCamelCommand PopVar {var C} {
    DotCamelVirtualMachineStackIndex++;
    *C=DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex].F;
}
DotCamelCommand Pop {} {
    DotCamelVirtualMachineStackIndex++;
}

set op_template {
    DotCamelVirtualMachineStackIndex++;
    DotCamelVirtualMachineStackIndex++;
    DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex].F=DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex-1].F@DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex].F;
    DotCamelVirtualMachineStackIndex--;
}
foreach op {+ - * /} op_name {Plus Minus Mult Div} {
    regsub @ $op_template $op body
    DotCamelCommand $op_name {} $body 
}

set op_template {
    if (!(DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex-1].F@DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex].F)) DotCamelVirtualMachineSkip=1;
}
foreach op {< > <= >= == !=} op_name {LessThan GreaterThan AtMost AtLeast Equal Different} {
    regsub @ $op_template $op body
    DotCamelCommand $op_name {} $body 
}

DotCamelCommand Branch {int step} {
    DotCamelVirtualMachineBatchProgramCounter+=step;
}
DotCamelCommand Stop {} {
    DotCamelVirtualMachineRunning=0;
}
DotCamelCommand Goto {int location} {
    DotCamelVirtualMachineBatchProgramCounter=location-2;
}
DotCamelCommand DumpStack {} {
    int i;
    #Info: "This is the content of the stack (index=%ld):" DotCamelVirtualMachineStackIndex
    for (i=DotCamelVirtualMachineStackSize-1;i>DotCamelVirtualMachineStackIndex;i--) {
        #Info: "Stack[%d] = %f" i DotCamelVirtualMachineStack[i].F
    }
}
