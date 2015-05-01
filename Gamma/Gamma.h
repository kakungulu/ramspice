#ifndef Gamma
#define Gamma
#include "ramspice_types.h"
#include "Gamma/virtual_machine.h"
void GammaCommandPush(void);
void GammaCommandDefault(void);
void GammaCommandGoSub(void);
void GammaCommandReturn(void);
void GammaCommandPushArg(void);
void GammaCommandTestVar(void);
void GammaCommandTcl(void);
void GammaCommandPushVar(void);
void GammaCommandPushPointer(void);
void GammaCommandPushLUT(void);
void GammaCommandPopVar(void);
void GammaCommandPop(void);
void GammaCommandPolynomial(void);
void GammaCommandRoot(void);
void GammaCommandDerive(void);
void GammaCommandImpDerive(void);
void GammaCommandInterpolate(void);
void GammaCommandInterpolateg(void);
void GammaCommandPlus(void);
void GammaCommandMinus(void);
void GammaCommandMult(void);
void GammaCommandDiv(void);
void GammaCommandLimit(void);
void GammaCommandOr(void);
void GammaCommandAnd(void);
void GammaCommandReverse(void);
void GammaCommandAbs(void);
void GammaCommandLog10(void);
void GammaCommandSqrt(void);
void GammaCommandSquare(void);
void GammaCommandDistAtLeast(void);
void GammaCommandDistAtMost(void);
void GammaCommandDist(void);
void GammaCommandDeriveDistAtLeast(void);
void GammaCommandDeriveDistAtMost(void);
void GammaCommandDeriveDist(void);
void GammaCommandLessThan(void);
void GammaCommandGreaterThan(void);
void GammaCommandAtMost(void);
void GammaCommandAtLeast(void);
void GammaCommandEqual(void);
void GammaCommandDifferent(void);
void GammaCommandBranch(void);
void GammaCommandStop(void);
void GammaCommandGoto(void);
void GammaCommandDumpStack(void);
static int tcl_gamma_AtMost(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_GoSub(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Return(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_PopVar(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Goto(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_DeriveDistAtLeast(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Square(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_LessThan(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Sqrt(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_PushArg(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Log10(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_And(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Reverse(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Polynomial(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Default(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_PushLUT(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Stop(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Abs(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Pop(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Equal(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Push(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Or(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_TestVar(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_PushVar(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_PushPointer(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_DistAtLeast(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Mult(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_DeriveDist(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_DeriveDistAtMost(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Div(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Tcl(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_DumpStack(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Dist(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_DistAtMost(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Minus(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Plus(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Root(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_GreaterThan(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_ImpDerive(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Branch(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_AtLeast(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Interpolateg(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Different(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Limit(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Interpolate(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_gamma_Derive(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
void init_tcl_gamma(Tcl_Interp *interp);
#endif
