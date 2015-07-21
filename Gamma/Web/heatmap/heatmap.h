#ifndef HEATMAP_GENERATOR
#define HEATMAP_GENERATOR

void create_heatmap(float *input, int count, int *pal, int pal_size, float *key, char *filename);
static int tcl_heatmap(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);



#endif
