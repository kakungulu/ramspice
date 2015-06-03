#ifndef CTREE_SPICE
#define CTREE_SPICE
#ifdef SPICE_COMPILATION
wordlist *args2wordlist(int argc, char **argv);
int Spice_Init(Tcl_Interp *interp);
int SIMinit(IFfrontEnd *frontEnd, IFsimulator **simulator);
#endif

#endif
