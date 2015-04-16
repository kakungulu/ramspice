GammaCommand Push {float F} {
    // #Info: "Pushing Constant (%g)" F
    @F(0)=F;
    GammaVirtualMachineStackIndex--;
}

GammaCommand Default {var Var,float Val} {
    if (isnan(*Var)) {
        *Var=Val;
    }
}
GammaCommand GoSub {int SubRoutine} {
    // #Info: "%ld/%ld: Gosub to %ld" GammaVirtualMachineGosubStackIndex GammaVirtualMachineGosubStackSize SubRoutine
    GammaVirtualMachineGosubStack[GammaVirtualMachineGosubStackIndex].I=GammaVirtualMachineBatchProgramCounter;
    GammaVirtualMachineGosubStackIndex--;
    GammaVirtualMachineGosubStack[GammaVirtualMachineGosubStackIndex].I=GammaVirtualMachineStackArgs;
    GammaVirtualMachineGosubStackIndex--;
    GammaVirtualMachineBatchProgramCounter=SubRoutine-2;
    GammaVirtualMachineStackArgs=GammaVirtualMachineStackIndex;
}
GammaCommand Return {int NumOfArguments} {
    if (GammaVirtualMachineGosubStackIndex+1>=GammaVirtualMachineGosubStackSize) {
        // #Info: "Returning to nothing. Stoping!"
        GammaVirtualMachineReset();
	return;
    }
    GammaVirtualMachineGosubStackIndex++;
    GammaVirtualMachineStackArgs=GammaVirtualMachineGosubStack[GammaVirtualMachineGosubStackIndex].I;
    GammaVirtualMachineGosubStackIndex++;
    GammaVirtualMachineBatchProgramCounter=GammaVirtualMachineGosubStack[GammaVirtualMachineGosubStackIndex].I;
    // #Info: "%ld/%ld: Returning to %ld with value=%g" GammaVirtualMachineGosubStackIndex GammaVirtualMachineGosubStackSize GammaVirtualMachineBatchProgramCounter+2 @F(1)
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex+NumOfArguments+1].F=@F(1);
    GammaVirtualMachineStackIndex+=NumOfArguments;
}
GammaCommand PushArg {int Arg} {
    @F(0)=GammaVirtualMachineStack[GammaVirtualMachineStackArgs+Arg].F;
    GammaVirtualMachineStackIndex--;
}
GammaCommand TestVar {string VarName,var C} {
    #Info: "Test Point %s=%g (%x) (%ld:)" VarName *C C GammaVirtualMachineBatchProgramCounter
}
GammaCommand Tcl {string Code} {
    if (Tcl_Eval(interp,Code)==TCL_ERROR) {
        Tcl_Eval(interp,"Error: $::errorInfo");
    }
}
GammaCommand PushVar {var C} {
    #Info: "Pushing var %x (%g) to %d" C *C GammaVirtualMachineStackIndex
    @F(0)=*C;
    GammaVirtualMachineStackIndex--;
}
GammaCommand PushPointer {var C} {
    #Info: "Pushing pointer %x to %d" C GammaVirtualMachineStackIndex
    @P(0)=C;
    GammaVirtualMachineStackIndex--;
}
GammaCommand PushLUT {LUT C} {
    // #Info: "Pushing pointer %x" C 
    @P(0)=C;
    GammaVirtualMachineStackIndex--;
}
GammaCommand PopVar {var C} {
    GammaVirtualMachineStackIndex++;
    // #Info: "Poping Var %x (%g->%g)" &(GammaVirtualMachineStack[GammaVirtualMachineStackIndex]) *((float*)C) @F(0)
    *((float *)C)=@F(0);
}
GammaCommand Pop {} {
    GammaVirtualMachineStackIndex++;
}
GammaCommand Polynomial {} {
    ordinal i=1;
    float total=0;
    GammaVirtualMachineBatchProgramCounter++;
    while (GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter].P) {
        float coeff=GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter++].F;
        while (GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter].P) {
	    float *F=(float *)GammaVirtualMachineBatch[GammaVirtualMachineBatchProgramCounter++].P;
	    coeff*=*F;
	}    
	total+=coeff;
    }
    GammaVirtualMachineBatchProgramCounter++;
}
GammaCommand Interpolate {} {
    // #Info: "Accessing LUT at %x" @P(1)
    LUT *a=(LUT *)@P(1);
    // #Info: "Calling interpolation %x" a->gamma_interpolate
    a->gamma_interpolate(a);
}
GammaCommand Interpolateg {} {
    // #Info: "Accessing LUT at %x" @P(1)
    LUT *a=(LUT *)@P(1);
    // #Info: "Calling interpolation %x" a->gamma_interpolate
    a->gamma_gradient(a);
}
set op_template {
    float F=@F(1)@O@F(2);
    #Info: "%g@O%g=%g  =>  %d" @F(1) @F(2) F GammaVirtualMachineStackIndex+2
    @F(2)=F;
    GammaVirtualMachineStackIndex++;
}
foreach op {+ - * /} op_name {Plus Minus Mult Div} {
    regsub -all @O $op_template $op body
    GammaOperator $op_name {} $body 
}
GammaCommand Limit {} {
    #Info: "Limit %g (%g,%g)" @F(1) @F(2) @F(3)
    if (@F(1)>@F(3)) @F(1)=@F(3);
    if (@F(1)<@F(2)) @F(1)=@F(2);
}
set op_template {
    @I(2)=@F(1)@O@I(2);
    if (!(@I(2))) GammaVirtualMachineSkip=1;
    GammaVirtualMachineStackIndex++;
}
foreach op [list || "\\&\\&"] op_name {Or And} {
    regsub -all @O $op_template $op body
    GammaOperator $op_name {} $body 
}
GammaCommand Reverse {} {
    float temp=@F(2);
    @F(2)=@F(1);
    @F(1)=temp;
}
foreach op {fabs log10 sqrt} name {Abs Log10 Sqrt} {
    GammaCommand $name {} "@F(1)=${op}(@F(1));"
}
GammaCommand Square {} {
    @F(1)=@F(1)*@F(1);
}
GammaCommand DistAtLeast {} {
    if (@F(1)>=@F(2)) {
        @F(1)=0;
    } else {
        @F(1)=(@F(2)-@F(1))*(@F(2)-@F(1));
    }
}
GammaCommand DistAtMost {} {
    if (@F(1)<=@F(2)) {
        @F(1)=0;
    } else {
        @F(1)=(@F(2)-@F(1))*(@F(2)-@F(1));
    }
}
GammaCommand Dist {} {
    @F(1)=(@F(2)-@F(1))*(@F(2)-@F(1));
}
GammaCommand DeriveDistAtLeast {} {
    if (@F(1)>=@F(2)) {
        @F(1)=0;
    } else {
        @F(1)=2*fabs(@F(2)-@F(1));
    }
}
GammaCommand DeriveDistAtMost {} {
    if (@F(1)<=@F(2)) {
        @F(1)=0;
    } else {
        @F(1)=2*fabs(@F(2)-@F(1));
    }
}
GammaCommand DeriveDist {} {
    @F(1)=2*fabs(@F(2)-@F(1));
}
set op_template {
    if (!(@F(1)@O@F(2))) {
        // #Info: "Failed %g @ %g" @F(1) @F(2)
	@I(2)=0;
        GammaVirtualMachineSkip=1;
    } else {
	@I(2)=1;
        // #Info: "Passed %g @ %g" @F(1) @F(2)
    }	
    GammaVirtualMachineStackIndex++;
}
foreach op {< > <= >= == !=} op_name {LessThan GreaterThan AtMost AtLeast Equal Different} {
    regsub -all @O $op_template $op body
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
    // #Info: "This is the content of the stack (index=%ld):" GammaVirtualMachineStackIndex
    for (i=GammaVirtualMachineStackSize-1;i>GammaVirtualMachineStackIndex;i--) {
        // #Info: "Stack[%d] = %f" i GammaVirtualMachineStack[i].F
    }
}
