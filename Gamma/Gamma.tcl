GammaCommand Push {float F} {
    #Dinfo: "Pushing Constant (%g)" F
    @F(0)=F;
    GammaVirtualMachineStackIndex--;
}

GammaCommand Default {var Var,float Val} {
    if (isnan(*Var)) {
        *Var=Val;
    }
}
GammaCommand GoSub {int SubRoutine} {
    #Dinfo: "%ld/%ld: Gosub to %ld" GammaVirtualMachineGosubStackIndex GammaVirtualMachineGosubStackSize SubRoutine
    GammaVirtualMachineGosubStack[GammaVirtualMachineGosubStackIndex].I=GammaVirtualMachineBatchProgramCounter;
    GammaVirtualMachineGosubStackIndex--;
    GammaVirtualMachineGosubStack[GammaVirtualMachineGosubStackIndex].I=GammaVirtualMachineStackArgs;
    GammaVirtualMachineGosubStackIndex--;
    GammaVirtualMachineBatchProgramCounter=SubRoutine-2;
    GammaVirtualMachineStackArgs=GammaVirtualMachineStackIndex;
}
GammaCommand Return {int NumOfArguments} {
    if (GammaVirtualMachineGosubStackIndex+1>=GammaVirtualMachineGosubStackSize) {
        #Dinfo: "Returning to nothing. Stoping!"
        GammaVirtualMachineReset();
	return;
    }
    GammaVirtualMachineGosubStackIndex++;
    GammaVirtualMachineStackArgs=GammaVirtualMachineGosubStack[GammaVirtualMachineGosubStackIndex].I;
    GammaVirtualMachineGosubStackIndex++;
    GammaVirtualMachineBatchProgramCounter=GammaVirtualMachineGosubStack[GammaVirtualMachineGosubStackIndex].I;
    #Dinfo: "%ld/%ld: Returning to %ld with value=%g" GammaVirtualMachineGosubStackIndex GammaVirtualMachineGosubStackSize GammaVirtualMachineBatchProgramCounter+2 @F(1)
    GammaVirtualMachineStack[GammaVirtualMachineStackIndex+NumOfArguments+1].F=@F(1);
    GammaVirtualMachineStackIndex+=NumOfArguments;
}
GammaCommand PushArg {int Arg} {
    @F(0)=GammaVirtualMachineStack[GammaVirtualMachineStackArgs+Arg].F;
    GammaVirtualMachineStackIndex--;
}
GammaCommand TestVar {string VarName,var C} {
    #Dinfo: "Test Point %s=%g (%x) (%ld:)" VarName *C C GammaVirtualMachineBatchProgramCounter
}
GammaCommand Tcl {string Code} {
    if (Tcl_Eval(interp,Code)==TCL_ERROR) {
        Tcl_Eval(interp,"Error: $::errorInfo");
    }
}
GammaCommand PushVar {var C} {
    @F(0)=*C;
    #Dinfo: "Pushing var %x (%g=>%g) to %d" C *C @F(0) GammaVirtualMachineStackIndex
    GammaVirtualMachineStackIndex--;
}
GammaCommand PushPointer {var C} {
    #Dinfo: "Pushing pointer %x to %d" C GammaVirtualMachineStackIndex
    @P(0)=C;
    GammaVirtualMachineStackIndex--;
}
GammaCommand PushPOLY {POLY P} {
    @P(0)=P;
    #Dinfo: "Pushing POLY %x" P
    GammaVirtualMachineStackIndex--;
}
GammaCommand PushLUT {LUT C} {
    #Dinfo: "Pushing pointer %x" C 
    @P(0)=C;
    GammaVirtualMachineStackIndex--;
}
GammaCommand PopVar {var C} {
    GammaVirtualMachineStackIndex++;
    #Dinfo: "Poping Var %x (%g->%g)" C *((float*)C) @F(0)
    *((float *)C)=@F(0);
}
GammaCommand Pop {} {
    GammaVirtualMachineStackIndex++;
}

GammaCommand Polynomial {} {
    @F(1)=calc_POLY(@P(1));
    #Dinfo: "Pushing var %x (%g=>%g) to %d" C *C @F(0) GammaVirtualMachineStackIndex
}
GammaCommand Root {} {
    @F(2)=root_POLY(@P(1),@P(2),0);
    #Dinfo: "Pushing var %x (%g=>%g) to %d" C *C @F(0) GammaVirtualMachineStackIndex
    GammaVirtualMachineStackIndex++;
}
GammaCommand Derive {} {
    @F(2)=derive_POLY(@P(1),@P(2));
    #Dinfo: "Pushing var %x (%g=>%g) to %d" C *C @F(0) GammaVirtualMachineStackIndex
    GammaVirtualMachineStackIndex++;
}
GammaCommand ImpDerive {} {
    @F(3)=imp_derive_POLY(@P(1),@P(2),@P(3),0);
    #Dinfo: "Pushing var %x (%g=>%g) to %d" C *C @F(0) GammaVirtualMachineStackIndex
    GammaVirtualMachineStackIndex+=2;
}
GammaCommand Interpolate {} {
    #Dinfo: "Accessing LUT at %x" @P(1)
    LUT *a=(LUT *)@P(1);
    #Dinfo: "Calling interpolation %x" a->gamma_interpolate
    a->gamma_interpolate(a);
}
GammaCommand Interpolateg {} {
    #Dinfo: "Accessing LUT at %x" @P(1)
    LUT *a=(LUT *)@P(1);
    #Dinfo: "Calling interpolation %x" a->gamma_interpolate
    a->gamma_gradient(a);
}
set op_template {
    float F=@F(1)@O@F(2);
    if (isinf(F)==1) {
        //#Warning: "Overflow!"
        F=DBL_MAX;
    }	
    if (isinf(F)==-1) {
        //#Warning: "Underflow!"
        F=-DBL_MAX;
    }	
    if (fabs(F)>1e20) {
        //#Warning: "Large Number: %g" F
    }	
    #Dinfo: "%g@O%g=%g  =>  %d" @F(1) @F(2) F GammaVirtualMachineStackIndex+2
    @F(2)=F;
    GammaVirtualMachineStackIndex++;
}
foreach op {+ - * /} op_name {Plus Minus Mult Div} {
    regsub -all @O $op_template $op body
    GammaOperator $op_name {} $body 
}
GammaCommand Limit {} {
    #Dinfo: "Limit %g (%g,%g)" @F(1) @F(2) @F(3)
    if (@F(1)>@F(3)) @F(1)=@F(3);
    if (@F(1)<@F(2)) @F(1)=@F(2);
}
set op_template {
    #Dinfo: "%d@O%d   %g@O%g " @I(1) @I(2) @F(1) @F(2)
    @I(2)=@I(1)@O@I(2);
    #Dinfo: "= %d" @I(2)
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
#    GammaCommand $name {} "#Info: \"$name\(%g\)\" @F(1)\n @F(1)=${op}(@F(1));\n #Info: \"=%g\" @F(1)\n"
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
        #Dinfo: "Failed %g @O %g" @F(1) @F(2)
	@I(2)=0;
        GammaVirtualMachineSkip=1;
    } else {
	@I(2)=1;
        #Dinfo: "Passed %g @O %g" @F(1) @F(2)
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
    #Dinfo: "This is the content of the stack (index=%ld):" GammaVirtualMachineStackIndex
    for (i=GammaVirtualMachineStackSize-1;i>GammaVirtualMachineStackIndex;i--) {
        #Dinfo: "Stack[%d] = %f" i GammaVirtualMachineStack[i].F
    }
}
