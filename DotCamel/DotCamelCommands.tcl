DotCamelCommand Push {float F} {
    DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex].F=F;
    DotCamelVirtualMachineStackIndex--;
    DotCamelVirtualMachineStackArgs=&(DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex]);
}

DotCamelCommand Pop {} {
    DotCamelVirtualMachineStackIndex++;
    DotCamelVirtualMachineStackArgs=&(DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex]);
}

set op_template {
    float result=DotCamelVirtualMachineStackArgs[2].F@DotCamelVirtualMachineStackArgs[1].F; 
    DotCamelCommand_Pop();
    DotCamelCommand_Pop(); 
    DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex].F=result;
    DotCamelVirtualMachineStackIndex--;
    DotCamelVirtualMachineStackArgs=&(DotCamelVirtualMachineStack[DotCamelVirtualMachineStackIndex]);
}
foreach op {+ - * /} op_name {Plus Minus Mult Div} {
    regsub @ $op_template $op body
    DotCamelCommand $op_name {} $body 
}

set op_template {
    if (!(DotCamelVirtualMachineStackArgs[2].F@DotCamelVirtualMachineStackArgs[1].F)) DotCamelVirtualMachineSkip=1;
}
foreach op {< > <= >= == !=} op_name {LessThan GreaterThan AtMost AtLeast Equal Different} {
    regsub @ $op_template $op body
    DotCamelCommand $op_name {} $body 
}

DotCamelCommand Branch {int step} {
    DotCamelVirtualMachineBatchProgramCounter+=step;
}

