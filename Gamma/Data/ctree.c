#include "ramspice_types.h"
#include "ctree.h"
#ifdef SPICE_COMPILATION
#include "ngspice/config.h"
#include "ngspice/macros.h"
#include "frontend/parser/complete.h"
#include "ngspice/ngspice.h"
#include "ngspice/defines.h"
#include "frontend/signal_handler.h"
#include "frontend/quote.h"
#include "frontend/variable.h"
#include "frontend/plotting/plotting.h"
#include "frontend/plotting/pvec.h"
#include "frontend/numparam/general.h"
#include "frontend/numparam/numparam.h"
#include "ngspice/wordlist.h"
#include "ngspice/iferrmsg.h"
#include "ngspice/ftedefs.h"
#include "ngspice/devdefs.h"
#include "spicelib/devices/dev.h"
#include "spicelib/analysis/analysis.h"
#include "misc/ivars.h"
#include "misc/misc_time.h"
#include "frontend/outitf.h"
#endif
#include "Gamma/LUT/look_up_table.h"
#include "Gamma/Data/serialize.h"
#include "Gamma/Web/heatmap/heatmap.h"
#ifdef SPICE_COMPILATION
#include "Gamma/Data/ctree_spice.h"
#include "spicelib/devices/bsim3v32/bsim3v32def.h"
#endif
#include <sys/stat.h>
#include <sys/times.h>
#define save_interp()                           \
do {                                        \
    spice_interp = interp;                  \
} while(0)
#ifdef SPICE_COMPILATION
IFfrontEnd nutmeginfo = {
    IFnewUid,
    IFdelUid,
    OUTstopnow,
    seconds,
    OUTerror,
    OUTpBeginPlot,
    OUTpData,
    OUTwBeginPlot,
    OUTwReference,
    OUTwData,
    OUTwEnd,
    OUTendPlot,
    OUTbeginDomain,
    OUTendDomain,
    OUTattributes
};
#endif

#Foreach: type $::vector_pointer_types {
    vector_pointer_$type *new_vector_pointer_$type() {
        vector_pointer_$type *v=(vector_pointer_$type *)malloc(sizeof(vector_pointer_$type));
        v->max_num_of=8;
        v->content=($type **)malloc(sizeof($type *)*v->max_num_of);
        v->num_of=0;
        return(v);
    } 
    void add_entry_vector_pointer_$type(vector_pointer_$type *v,$type *e) {
        if (v->num_of>=v->max_num_of) {
            v->max_num_of*=2;
            $type **new_content=($type **)malloc(sizeof($type *)*v->max_num_of);
            ordinal i;
            for (i=0;i<v->num_of;i++) new_content[i]=v->content[i];
            free(v->content);
            v->content=new_content;
        }
        v->content[v->num_of]=e;
        v->num_of++;
    }
    $type *get_entry_vector_pointer_$type(vector_pointer_$type *v,ordinal i) {
        if ((i>=v->num_of)||(i<0)) {
            #Error: "Attempted accessing vector outside boundaries %ld/%ld" i v->num_of
            return(v->content[0]);
        }
        return(v->content[i]);
    }
    int delete_entry_vector_pointer_$type(vector_pointer_$type *v,ordinal i) {
        if ((i>=v->num_of)||(i<0)) {
            #Error: "Attempted deleting entry from vector outside boundaries %ld/%ld" i v->num_of
            return(-1);
        }
        v->content[i]=v->content[v->num_of-1];
        v->num_of--;
        return(v->num_of);
    }
    void write_vector_pointer_$type(FILE *O,vector_pointer_$type *v) {
        write_ordinal(O,v->num_of);
        ordinal i;
        for (i=0;i<v->num_of;i++) write_pointer_$type(O,v->content[i]);
    }
    vector_pointer_$type *read_vector_pointer_$type() {
        vector_pointer_$type *v=new_vector_pointer_$type();
        ordinal length=read_ordinal();
        ordinal i;
        for (i=0;i<length;i++) add_entry_vector_pointer_$type(v,read_pointer_$type());
        return(v);
    }
}
#Foreach: type $::vector_types {
    vector_$type *new_vector_$type() {
        vector_$type *v=(vector_$type *)malloc(sizeof(vector_$type));
        v->max_num_of=8;
        v->content=($type *)malloc(sizeof($type)*v->max_num_of);
        v->num_of=0;
        return(v);
    } 
    void add_entry_vector_$type(vector_$type *v,$type e) {
        if (v->num_of>=v->max_num_of) {
            v->max_num_of*=2;
            $type *new_content=($type *)malloc(sizeof($type)*v->max_num_of);
            ordinal i;
            for (i=0;i<v->num_of;i++) new_content[i]=v->content[i];
            free(v->content);
            v->content=new_content;
        }
        v->content[v->num_of]=e;
        v->num_of++;
    }
    $type get_entry_vector_$type(vector_$type *v,ordinal i) {
        if ((i>=v->num_of)||(i<0)) {
            #Error: "Attempted accessing vector outside boundaries %ld/%ld" i v->num_of
            return(v->content[0]);
        }
        return(v->content[i]);
    }
    int delete_entry_vector_$type(vector_$type *v,ordinal i) {
        if ((i>=v->num_of)||(i<0)) {
            #Error: "Attempted deleting entry from vector outside boundaries %ld/%ld" i v->num_of
            return(-1);
        }
        v->content[i]=v->content[v->num_of-1];
        v->num_of--;
        return(v->num_of);
    }
    void write_vector_$type(FILE *O,vector_$type *v) {
        write_ordinal(O,v->num_of);
        ordinal i;
        for (i=0;i<v->num_of;i++) write_$type(O,v->content[i]);
    }
    vector_$type *read_vector_$type() {
        vector_$type *v=new_vector_$type();
        ordinal length=read_ordinal();
        ordinal i;
        for (i=0;i<length;i++) add_entry_vector_$type(v,read_$type());
        return(v);
    }
}
void write_pointer_PAT_entry(FILE *O,PAT_entry *p) {
    write_ordinal(O,p->id);
    write_ordinal(O,p->flags);
    write_vector_float(O,p->sizes);
    write_vector_float(O,p->properties);
}
PAT_entry *read_pointer_PAT_entry() {
    PAT_entry *p=(PAT_entry *)malloc(sizeof(PAT_entry));
    p->id=read_ordinal();
    p->flags=read_ordinal();
    p->sizes=read_vector_float();
    p->properties=read_vector_float();
    return(p);
}
void write_pointer_PAT(FILE *O,PAT *p) {
    write_vector_pointer_PAT_entry(O,p->content);
    write_vector_pointer_char(O,p->sizes);
    write_vector_pointer_char(O,p->properties);
    write_vector_float(O,p->margins);
    write_vector_int(O,p->factors);
    write_ordinal(O,p->id_counter);
}
void write_pointer_POLY(FILE *O,POLY *p) {
    write_string(O,p->expression);
}
PAT *read_pointer_PAT() {
    PAT *p=(PAT *)malloc(sizeof(PAT));
    p->content=read_vector_pointer_PAT_entry();
    p->sizes=read_vector_pointer_char();
    p->properties=read_vector_pointer_char();
    p->margins=read_vector_float();
    p->factors=read_vector_int();
    p->id_counter=read_ordinal();
    return(p);
}
void link_POLY(POLY *p) {
    char *draft=(char *)malloc(sizeof(char)*(strlen(p->expression)+1));
    sprintf(draft,"%s",p->expression);
    #Info: "Linking POLY %s" p->expression
    ordinal i,j,argc=1;
    for (i=0;draft[i];i++) if (draft[i]==' ') argc++;
    char **argv=(char **)malloc(sizeof(char *)*argc);
    argv[0]=draft;
    j=1;
    for (i=0;draft[i];i++) if (draft[i]==' ') {
        draft[i]=0;
        argv[j++]=&(draft[i+1]);
    }
    int next_is_coeff=1;
    so_union SO;
    for (i=0;i<argc;i++) {
        if (strcmp(argv[i],"+")==0) {
            SO.v=NULL;
            add_entry_vector_float(p->polynomial,SO.s);
            next_is_coeff=1;
            continue;
        }
        if (next_is_coeff) {
            add_entry_vector_float(p->polynomial,strtod(argv[i],NULL));
            next_is_coeff=0;
            continue;
        }
        context *c=Context;
        float *array_entry;
        if ((argv[i][0]=='/')||(argv[i][0]==':')) {
            c=Ctree;
        }
        if (!(resolve_context(argv[i],&c,&array_entry))) {
            c=create_context(argv[i]);
        }
        SO.v=&(c->value.s);
        add_entry_vector_float(p->polynomial,SO.s);
    }
    free(argv);
    free(draft);
}
POLY *read_pointer_POLY() {
    POLY *p=(POLY *)malloc(sizeof(POLY));
    p->expression=copy_string();
    link_POLY(p);
    return(p);
}

static Tcl_Interp *spice_interp;
#ifdef SPICE_COMPILATION
static int
_run(int argc, char **argv)
{
    char buf[1024] = "";
    int i;
    sighandler oldHandler;
    #ifdef THREADS
    char *string;
    int fl_bg = FALSE;
    /* run task in background if preceeded by "bg"*/
    if (!strcmp(argv[0], "bg")) {
        argc--;
        argv = &argv[1];
        fl_bg = TRUE;
    }
    #endif
    
    
    /* Catch Ctrl-C to break simulations */
    #ifndef _MSC_VER_
    oldHandler = signal(SIGINT, (SIGNAL_FUNCTION) ft_sigintr);
    if (SETJMP(jbuf, 1) != 0) {
        ft_sigintr_cleanup();
        signal(SIGINT, oldHandler);
        return TCL_OK;
    }
    #else
    oldHandler = SIG_IGN;
    #endif
    
    /*build a char * to pass to cp_evloop */
    for (i = 0; i < argc; i++) {
        strcat(buf, argv[i]);
        strcat(buf, " ");
    }
    
    #ifdef THREADS
    /* run in the background */
    if (fl_bg) {
        if (fl_running)
        _thread_stop();
        fl_running = TRUE;
        string = copy(buf);     /*as buf gets freed fairly quickly*/
        #ifdef HAVE_LIBPTHREAD
        pthread_create(&tid, NULL, _thread_run, (void *)string);
        #else
        Tcl_CreateThread(&tid, (Tcl_ThreadCreateProc *)_thread_run, string,
        TCL_THREAD_STACK_DEFAULT, TCL_THREAD_NOFLAGS);
        #endif
    } else
    /* halt (pause) a bg run */
    if (!strcmp(argv[0], "halt")) {
        signal(SIGINT, oldHandler);
        return _thread_stop();
    } else
    /* backwards compatability with old command */
    if (!strcmp(argv[0], "stop"))
    if (argc > 1) {
        cp_evloop(buf);
    } else {
        _thread_stop();
        cp_evloop(buf);
    }
    else {
        /* cannot do anything if spice is running in the bg*/
        if (fl_running) {
            if (fl_exited) {
                _thread_stop();
                cp_evloop(buf);
            } else {
                fprintf(stderr, "type \"spice stop\" first\n");
            }
        } else {
            /*do the command*/
            cp_evloop(buf);
        }
    }
    #else
    cp_evloop(buf);
    #endif /*THREADS*/
    signal(SIGINT, oldHandler);
    return TCL_OK;
}

/* Runs the spice command given in spice <cmd>*/
static int
_spice_dispatch (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    NG_IGNORE(clientData);
    save_interp();
    if (argc == 1)
    return TCL_OK;
    return _run(argc-1, (char **)&argv[1]);
}
static int
_tcl_dispatch (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    int i;
    NG_IGNORE(clientData);
    save_interp();
    /* Looks backwards through the first command and strips the :: part */
    for (i = strlen(argv[0])-1; i > 0; i--)
    if (argv[0][i] == *":")
    argv[0] += i + 1;
    return _run(argc, (char **)argv);
}
#endif
/********************************************************
Atomic C->Tcl result passing functions
********************************************************/
void tcl_append_long(Tcl_Interp *interp,long in_int) {
    char buf[16];
    sprintf(buf,"%d",in_int);
    Tcl_AppendElement(interp,buf);
}
void tcl_append_int(Tcl_Interp *interp,int in_int) {
    char buf[16];
    sprintf(buf,"%d",in_int);
    Tcl_AppendElement(interp,buf);
}
void tcl_append_float(Tcl_Interp *interp,float in_int) {
    char buf[16];
    sprintf(buf,"%g",in_int);
    Tcl_AppendElement(interp,buf);
}
static int
gamma_info (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    if (argc!=2) {
        #Error: "usage: %s <target>" argv[0]
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    if (strcmp(argv[1],"target")==0) {
        Tcl_AppendElement(interp,"$::target");
        return TCL_OK;
    }
    if (strcmp(argv[1],"binary")==0) {
        Tcl_AppendElement(interp,"$::binary");
        return TCL_OK;
    }
    if (strcmp(argv[1],"version")==0) {
        Tcl_AppendElement(interp,"$::compilation_time");
        return TCL_OK;
    }
    #Error: "No such %s field: %s" argv[0] argv[1]
    return TCL_ERROR;
}
/********************************************************
Binary File interface from Tcl
******************************
open_bin - open a file to read/write
There is no handle returned. This simplifies Tcl code,
but also limits the coder to only one file open for read
and one open for write. 
This is 99.9% of the applications anyway...

close_bin - again, no handle, but still requires to specify
if its the one open for read or the one open for write that 
is to be closed.

write_bin, read_bin - can accept a list of values after a type token, 
provided they are the same type. Again, no handle used.
********************************************************/
static int
tcl_open_bin (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc!=3) {
        #Error: "usage: %s <read|write> <filename>" argv[0]
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    if (strcmp(argv[1],"write")==0) {
        if (OpenFileForWriting!=NULL) {
            #Error: "%s: Can't open file before it is closed" argv[0]
            return TCL_ERROR;
        }
        open_to_write(argv[2]);
        return TCL_OK;
    }
    if (strcmp(argv[1],"read")==0) {
        if (OpenFileForReading!=NULL) {
            #Error: "%s: Can't open file before it is closed" argv[0]
            return TCL_ERROR;
        }
        open_to_read(argv[2]);
        return TCL_OK;
    }
    #Error: "%s: No such type %s. Supported: read, write." argv[0] argv[1]
    return TCL_ERROR;
}
static int
tcl_close_bin (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc!=2) {
        #Error: "usage: %s <read|write>" argv[0]
        return TCL_ERROR;
    }
    if (strcmp(argv[1],"write")==0) {
        if (OpenFileForWriting==NULL) {
            #Error: "%s: Can't close file before it is opened" argv[0]
            return TCL_ERROR;
        }
        fclose(OpenFileForWriting);
        OpenFileForWriting=NULL;
        return TCL_OK;
    }
    if (strcmp(argv[1],"read")==0) {
        if (OpenFileForReading==NULL) {
            #Error: "%s: Can't close file before it is opened" argv[0]
            return TCL_ERROR;
        }
        fclose(OpenFileForReading);
        OpenFileForReading=NULL;
        return TCL_OK;
    }
    #Error: "%s: No such type %s. Supported: read, write." argv[0] argv[1]
    return TCL_ERROR;
}

static int
tcl_write_bin (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc<2) {
        #Error: "usage: %s <type> [<token1>...<tokenN>]" argv[0]
        return TCL_ERROR;
    }
    if (OpenFileForWriting==NULL) {
        #Error: "%s: Can't write to file before it is opened" argv[0]
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    if (strcmp(argv[1],"int")==0) {
        int i=2;
        for (;i<argc;i++) write_ordinal(NULL,atol(argv[i]));
        return TCL_OK;
    }
    if (strcmp(argv[1],"float")==0) {
        int i=2;
        for (;i<argc;i++) write_float(NULL,atof(argv[i]));
        return TCL_OK;
    }
    if (strcmp(argv[1],"string")==0) {
        int i=2;
        for (;i<argc;i++) write_string(NULL,argv[i]);
        return TCL_OK;
    }
    #Error: "%s: No such type %s. Supported: int, float and string." argv[0] argv[1]
    return TCL_ERROR;
}
static int
tcl_read_bin (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc!=2) {
        #Error: "usage: %s <type>" argv[0]
        return TCL_ERROR;
    }
    if (OpenFileForReading==NULL) {
        #Error: "%s: Can't read from file before it is opened" argv[0]
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    if (strcmp(argv[1],"int")==0) {
        tcl_append_long(interp,read_ordinal()); 
        return TCL_OK;
    }
    if (strcmp(argv[1],"float")==0) {
        tcl_append_float(interp,read_float()); 
        return TCL_OK;
    }
    if (strcmp(argv[1],"string")==0) {
        Tcl_AppendElement(interp,copy_string()); 
        return TCL_OK;
    }
    #Error: "%s: No such type %s. Supported: int, float and string." argv[0] argv[1]
    return TCL_ERROR;
}
/********************************************************
Simple Fork implementation in Tcl
C level has a global variable indicating whether this process
is user invoked or forked. It is used by the Info functions
to indicate source of messages.
********************************************************/
static int
tcl_fork (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc!=1) {
        #Error: "fork requires no arguments"
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    int PID=getpid();
    int child_pid=fork();
    if (getpid()!=PID) this_process_forked=1;
    tcl_append_int(interp,child_pid);
    return TCL_OK;
}

/********************************************************
Timing report retrieves and resets the global variables 
get_Tcl_timer and get_Tcl_counter
********************************************************/

static int
tcl_timer_report (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc!=1) {
        #Error: "timer_report requires no argument"
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    tcl_append_float(interp,(1e3*get_Tcl_timer)/get_Tcl_counter);
    tcl_append_float(interp,get_Tcl_timer);
    tcl_append_int(interp,get_Tcl_counter);
    get_Tcl_timer=0;
    get_Tcl_counter=0;
    return TCL_OK;
}

/********************************************************
LUT support commands
********************************************************/

static int
LUT_set_legend (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc!=5) {
        #Error: "LUT_set_legend requires array name, dimension, coordinate and physical value"
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    LUT *a=get_LUT(argv[1]);
    if (a==NULL) {
        #Error: "(LUT_set_legend) No such array: %s" argv[1]
        return TCL_ERROR;
    }
    ordinal l_index=atoi(argv[2]);
    if (l_index>=a->dim) {
        #Error: "(LUT_set_legend) index %s exceeds array's dimension" argv[2]
        return TCL_ERROR;
    }
    ordinal s_index=atoi(argv[3]);
    if (s_index>=a->size[l_index]) {
        #Error: "(LUT_set_legend) index %s exceeds array's size" argv[3]
        return TCL_ERROR;
    }
    a->legend[l_index][s_index]=atof(argv[4]);
    if (a->legend[l_index][1]!=a->legend[l_index][0]) a->physical_factor[l_index]=1.0/(a->legend[l_index][1]-a->legend[l_index][0]);
    a->hypercube_volume=1;
    int i;
    for (i=0;i<a->dim;i++) a->hypercube_volume*=(a->legend[i][1]-a->legend[i][0]);
    a->sizer[0]=1;
    for (i=1;i<a->dim;i++) a->sizer[i]=a->sizer[i-1]*a->size[i-1];
    return TCL_OK;
}
static int
LUT_get_legend (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc!=4) {
        #Error: "LUT_get_legend requires array name, dimension, coordinat and legend"
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    LUT *a=get_LUT(argv[1]);
    if (a==NULL) {
        #Error: "(LUT_get_legend) No such array: %s" argv[1]
        return TCL_ERROR;
    }
    int l_index=atoi(argv[2]);
    if (l_index>=a->dim) {
        #Error: "(LUT_get_legend) index %s exceeds array's dimension" argv[2]
        return TCL_ERROR;
    }
    int s_index=atoi(argv[3]);
    if (s_index>=a->size[l_index]) {
        #Error: "(LUT_get_legend) index %s exceeds array's size" argv[3]
        return TCL_ERROR;
    }
    tcl_append_float(interp,a->legend[l_index][s_index]);
    return TCL_OK;
}
static int
LUT_get_dim (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc!=2) {
        #Error: "LUT_get_dim  requires array name"
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    LUT *a=get_LUT(argv[1]);
    if (a==NULL) {
        #Error: "(LUT_get_legend) No such array: %s" argv[1]
        return TCL_ERROR;
    }
    tcl_append_int(interp,a->dim);
    return TCL_OK;
}
static int
LUT_get_size (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc!=3) {
        #Error: "LUT_get_size requires array name, dimension"
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    LUT *a=get_LUT(argv[1]);
    if (a==NULL) {
        #Error: "(LUT_get_size) No such array: %s" argv[1]
        return TCL_ERROR;
    }
    int l_index=atoi(argv[2]);
    if (l_index>=a->dim) {
        #Error: "(LUT_get_size) index %s exceeds array's dimension" argv[2]
        return TCL_ERROR;
    }
    tcl_append_int(interp,a->size[l_index]);
    return TCL_OK;
}
static int
normalize_ids (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc<2) {
        #Error: "(%s) requires array name" argv[0]
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    LUT *a=get_LUT(argv[1]);
    int i;
    ordinal maskL=1;
    ordinal maskW=1;
    for (i=1;i<a->dim;i++) maskW*=a->size[i-1];
    for (i=1;i<a->dim-1;i++) maskL*=a->size[i-1];
    int end=a->dim-1;
    for (i=0;i<maskW*a->size[end];i++) a->content[i]/=(a->legend[end][i/maskW]/a->legend[end-1][(i/maskL)%a->size[end-1]]);
    return TCL_OK;
}
static int
LUT_list (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc<2) {
        #Error: "(%s) requires array name" argv[0]
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    LUT *a=get_LUT(argv[1]);
    if (a==NULL) {
        #Error: "(LUT_list) No such array: %s" argv[1]
        return TCL_ERROR;
    }
    int i;
    int volume=1;
    for (i=0;i<a->dim;i++) {
        volume*=a->size[i];
    }
    for (i=0;i<volume;i++) {
        tcl_append_float(interp,a->content[i]);
    }
    return TCL_OK;
}
static int
tcl_generate_lit (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    if (argc!=2) {
        #Error: "usage: %s <array>" argv[0]
        return TCL_ERROR;
    }
    LUT *a=get_LUT(argv[1]);
    new_linear_interpolation_table(a);
    return TCL_OK;
}
#ifdef SPICE_COMPILATION
/********************************************************
Simulation slice saving functions
*********************************
Once a DC loop has run, the results can be saved in a binary file
that can be later used to populate a LUT.
The interim binary file is necessary for now, because the runs
may be split to different processes and the parent process 
needs to collect all the results to a single LUT.

Slices can be saved as-is, or be processed on the fly 
to perform derivatives of simulations. The baseline command
sets a certain slice as reference for future processing.
If, for instance, a gm vector is needed. The ids slice for 
one Vgs sweep can be set as baseline and then a following 
Vgs+epsilon sweep can be saved as differential, with the 1/epsilon
factor. 
delta saving is designed for vectors of totem-pole circuits, 
where the voltage we want is the difference between drain and source and
not the absolute value of all the sources. 
The two, delta and differential functions, can be combined in a 4th 
slice-saving function.
Finally, a complementary load_characterization_slice function
takes a slice and uses it to populate part of a LUT.
********************************************************/

static int
baseline_characterization_slice (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    if (argc!=1) {
        #Error: "usage: %s " argv[0]
        return TCL_ERROR;
    }
    save_slice_base=plot_cur;
    return TCL_OK;
}
static int
save_characterization_slice (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    if ((argc!=7)&&(argc!=6)) {
        #Error: "usage: %s <file name> <array sizes> <per vector dim>  <slice dim> <post indices> [<factor>]" argv[0]
        return TCL_ERROR;
    }
    ordinal i;
    float factor=1;
    int factor_mode=0;
    if (argc==7) {
        if (argv[6][0]=='/') {
            factor=atof(&(argv[6][1]));
            factor_mode=1;
        } else {
            factor=atof(argv[6]);
        }
    }
    FILE *O=fopen(argv[1],"w");
    int dim;
    char **sizes_string;
    Tcl_SplitList(interp,argv[2],&dim,&sizes_string);
    ordinal size[MAXDIM];
    for (i=0;i<dim;i++) size[i]=atoi(sizes_string[i]);
    free(sizes_string);
    
    ordinal offset[MAXDIM];
    offset[0]=1;
    for (i=1;i<dim;i++) offset[i]=offset[i-1]*size[i-1];
    
    ordinal vector_dim=atoi(argv[3]);
    ordinal slice_dim=atoi(argv[4]);
    int starting_index=0;
    if (slice_dim==1) starting_index=1;
    int postfix_dim;
    char **postfix_indices_string;
    Tcl_SplitList(interp,argv[5],&postfix_dim,&postfix_indices_string);
    ordinal postfix_indices[MAXDIM];
    for (i=0;i<postfix_dim;i++) postfix_indices[i]=atoi(postfix_indices_string[i]);
    free(postfix_indices_string);
    ordinal initial_offset=0;
    for (i=0;i<postfix_dim;i++) initial_offset+=postfix_indices[i]*offset[i+vector_dim+slice_dim];
    struct dvec *d=plot_cur->pl_dvecs;
    save_slice_base=plot_cur;
    #Info: "Saving vectors for slice %s in %s" argv[5],argv[1]
    while (d) {
        if (d->v_name[0]!='V') {
            d = d->v_next;
            continue;
        }
        char vector_id[128];
        for (i=2;d->v_name[i]!=')';i++) {
            if (d->v_name[i]=='_') {
                vector_id[i-2]=' ';
            } else {
                vector_id[i-2]=d->v_name[i];
            }
        }
        vector_id[i-2]=0;
        int tmp_dim;
        char **vector_index_string;
        Tcl_SplitList(interp,vector_id,&tmp_dim,&vector_index_string);
        if (slice_dim!=tmp_dim) {
            d = d->v_next;
            continue;
        }
        ordinal final_offset=initial_offset;
        for (i=0;i<slice_dim;i++) final_offset+=(atoi(vector_index_string[i])-starting_index)*offset[i+vector_dim];
        free(vector_index_string);
        write_ordinal(O,final_offset);
        write_ordinal(O,d->v_length);
        float w;
        if (factor_mode) {
            for (i=0;i<d->v_length;i++) {
                w=factor/d->v_realdata[i];
                write_float(O,w);
            }	
        } else {
            for (i=0;i<d->v_length;i++) {
                w=d->v_realdata[i]*factor;
                write_float(O,w);
            }	
        }
        /*
        for (i=0;i<d->v_length;i++) {
            if (isnan(d->v_realdata[i])) {
                #Error: "%s(%d)=%g" d->v_name i d->v_realdata[i]
            } else {
                #Info: "%s(%d)=%g" d->v_name i d->v_realdata[i]*factor
            }
        }
        */
        d = d->v_next;
    }
    fclose(O);
    return TCL_OK;
}
static int
save_characterization_slice_differential (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    if ((argc!=7)&&(argc!=6)) {
        #Error: "usage: %s <file name> <array sizes> <per vector dim>  <slice dim> <post indices> [<factor>]" argv[0]
        return TCL_ERROR;
    }
    if (save_slice_base==NULL) {
        #Error: "(%s) can't save a differential slice before a baseline slice was saved" argv[0]
        return TCL_ERROR;
    }
    ordinal i;
    float factor=1;
    int factor_mode=0;
    if (argc==7) {
        if (argv[6][0]=='/') {
            factor=atof(&(argv[6][1]));
            factor_mode=1;
        } else {
            factor=atof(argv[6]);
        }
    }
    FILE *O=fopen(argv[1],"w");
    int dim;
    char **sizes_string;
    Tcl_SplitList(interp,argv[2],&dim,&sizes_string);
    ordinal size[MAXDIM];
    for (i=0;i<dim;i++) size[i]=atoi(sizes_string[i]);
    free(sizes_string);
    
    ordinal offset[MAXDIM];
    offset[0]=1;
    for (i=1;i<dim;i++) offset[i]=offset[i-1]*size[i-1];
    
    ordinal vector_dim=atoi(argv[3]);
    ordinal slice_dim=atoi(argv[4]);
    int starting_index=0;
    if (slice_dim==1) starting_index=1;
    int postfix_dim;
    char **postfix_indices_string;
    Tcl_SplitList(interp,argv[5],&postfix_dim,&postfix_indices_string);
    ordinal postfix_indices[MAXDIM];
    for (i=0;i<postfix_dim;i++) postfix_indices[i]=atoi(postfix_indices_string[i]);
    free(postfix_indices_string);
    ordinal initial_offset=0;
    for (i=0;i<postfix_dim;i++) initial_offset+=postfix_indices[i]*offset[i+vector_dim+slice_dim];
    struct dvec *d=plot_cur->pl_dvecs;
    #Info: "Saving vectors for slice %s (differential) in %s" argv[5],argv[1]
    while (d) {
        if (d->v_name[0]!='V') {
            d = d->v_next;
            continue;
        }
        struct dvec *b=save_slice_base->pl_dvecs;
        while (b) {
            if (strcmp(b->v_name,d->v_name)==0) break;
            b=b->v_next;
        }
        if (b==NULL) {
            #Error: "(%s) vector %s has no baseline" argv[0],d->v_name
            return TCL_ERROR;
        }
        if (d->v_length!=b->v_length) {
            #Error: "(%s) vector %s is of length %d, while its baseline has length %d" argv[0],d->v_name,d->v_length,b->v_length
            return TCL_ERROR;
        }
        char vector_id[128];
        for (i=2;d->v_name[i]!=')';i++) {
            if (d->v_name[i]=='_') {
                vector_id[i-2]=' ';
            } else {
                vector_id[i-2]=d->v_name[i];
            }
        }
        vector_id[i-2]=0;
        int tmp_dim;
        char **vector_index_string;
        Tcl_SplitList(interp,vector_id,&tmp_dim,&vector_index_string);
        if (slice_dim!=tmp_dim) {
            d = d->v_next;
            continue;
        }
        ordinal final_offset=initial_offset;
        for (i=0;i<slice_dim;i++) final_offset+=(atoi(vector_index_string[i])-starting_index)*offset[i+vector_dim];
        free(vector_index_string);
        write_ordinal(O,final_offset);
        write_ordinal(O,d->v_length);
        /*        for (i=0;i<d->v_length;i++) {
            printf("(%g-%g)*%g\n",d->v_realdata[i],b->v_realdata[i],factor);
            fflush(stdout);
        }*/
        if (factor_mode) {
            for (i=0;i<d->v_length;i++) write_float(O,factor/(d->v_realdata[i]-b->v_realdata[i]));
        } else {
            for (i=0;i<d->v_length;i++) write_float(O,(d->v_realdata[i]-b->v_realdata[i])*factor);
        }
        d = d->v_next;
    }
    fclose(O);
    return TCL_OK;
}
static int
save_characterization_slice_delta (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    if ((argc!=9)&&(argc!=8)) {
        #Error: "usage: %s <file name> <array sizes> <per vector dim>  <slice dim> <post indices> <vector order list> <first offsets> [<factor>]" argv[0]
        return TCL_ERROR;
    }
    ordinal i;
    float factor=1;
    int factor_mode=0;
    if (argc==9) {
        if (argv[8][0]=='/') {
            factor=atof(&(argv[8][1]));
            factor_mode=1;
        } else {
            factor=atof(argv[8]);
        }
    }
    FILE *O=fopen(argv[1],"w");
    int dim;
    char **sizes_string;
    Tcl_SplitList(interp,argv[2],&dim,&sizes_string);
    ordinal size[MAXDIM];
    for (i=0;i<dim;i++) size[i]=atoi(sizes_string[i]);
    free(sizes_string);
    
    ordinal offset[MAXDIM];
    offset[0]=1;
    for (i=1;i<dim;i++) offset[i]=offset[i-1]*size[i-1];
    
    ordinal vector_dim=atoi(argv[3]);
    ordinal slice_dim=atoi(argv[4]);
    int starting_index=0;
    if (slice_dim==1) starting_index=1;
    int postfix_dim;
    char **postfix_indices_string;
    Tcl_SplitList(interp,argv[5],&postfix_dim,&postfix_indices_string);
    ordinal postfix_indices[MAXDIM];
    for (i=0;i<postfix_dim;i++) postfix_indices[i]=atoi(postfix_indices_string[i]);
    free(postfix_indices_string);
    ordinal initial_offset=0;
    for (i=0;i<postfix_dim;i++) initial_offset+=postfix_indices[i]*offset[i+vector_dim+slice_dim];
    int first_offset_argc;
    char **first_offset_argv;
    Tcl_SplitList(interp,argv[7],&first_offset_argc,&first_offset_argv);
    float *previous_offset=(float *)malloc(sizeof(scalar)*first_offset_argc);
    for (i=0;i<first_offset_argc;i++) previous_offset[i]=atof(first_offset_argv[i]);
    free(first_offset_argv);
    int vector_order_argc;
    char **vector_order_argv;
    Tcl_SplitList(interp,argv[6],&vector_order_argc,&vector_order_argv);
    #Info: "Saving vectors for slice %s (delta) in %s" argv[5],argv[1]
    ordinal vector_index;
    for (vector_index=0;vector_index<vector_order_argc;vector_index++) {
        struct dvec *d=plot_cur->pl_dvecs;
        while ((d)&&(strcmp(d->v_name,vector_order_argv[vector_index])))  d = d->v_next;
        if (!(d)) {
            #Error: "(%s) listed vector %s was not simulated" argv[0] vector_order_argv[vector_index]
            return TCL_ERROR;
        }
        char vector_id[128];
        for (i=2;d->v_name[i]!=')';i++) {
            if (d->v_name[i]=='_') {
                vector_id[i-2]=' ';
            } else {
                vector_id[i-2]=d->v_name[i];
            }
        }
        vector_id[i-2]=0;
        int tmp_dim;
        char **vector_index_string;
        Tcl_SplitList(interp,vector_id,&tmp_dim,&vector_index_string);
        if (slice_dim!=tmp_dim) continue;
        ordinal final_offset=initial_offset;
        for (i=0;i<slice_dim;i++) final_offset+=(atoi(vector_index_string[i])-starting_index)*offset[i+vector_dim];
        free(vector_index_string);
        write_ordinal(O,final_offset);
        write_ordinal(O,d->v_length);
        if (factor_mode) {
            for (i=0;i<d->v_length;i++) {
                write_float(O,factor/(d->v_realdata[i]-previous_offset[i]));
                previous_offset[i]=d->v_realdata[i];
            }
        } else {
            for (i=0;i<d->v_length;i++) {
                write_float(O,(d->v_realdata[i]-previous_offset[i])*factor);
                previous_offset[i]=d->v_realdata[i];
            }
        }
    }
    free(previous_offset);
    fclose(O);
    return TCL_OK;
}
static int
save_characterization_slice_delta_differential (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    if ((argc!=10)&&(argc!=9)) {
        #Error: "usage: %s <file name> <array sizes> <per vector dim>  <slice dim> <post indices> <vector order list> <first offsets> <basline first_offsets> [<factor>]" argv[0]
        return TCL_ERROR;
    }
    if (save_slice_base==NULL) {
        #Error: "(%s) can't save a delta+differential slice before a baseline slice was saved" argv[0]
        return TCL_ERROR;
    }
    ordinal i;
    float factor=1;
    int factor_mode=0;
    if (argc==10) {
        if (argv[9][0]=='/') {
            factor=atof(&(argv[9][1]));
            factor_mode=1;
        } else {
            factor=atof(argv[9]);
        }
    }
    FILE *O=fopen(argv[1],"w");
    int dim;
    char **sizes_string;
    Tcl_SplitList(interp,argv[2],&dim,&sizes_string);
    ordinal size[MAXDIM];
    for (i=0;i<dim;i++) size[i]=atoi(sizes_string[i]);
    free(sizes_string);
    
    ordinal offset[MAXDIM];
    offset[0]=1;
    for (i=1;i<dim;i++) offset[i]=offset[i-1]*size[i-1];
    
    ordinal vector_dim=atoi(argv[3]);
    ordinal slice_dim=atoi(argv[4]);
    int starting_index=0;
    if (slice_dim==1) starting_index=1;
    int postfix_dim;
    char **postfix_indices_string;
    Tcl_SplitList(interp,argv[5],&postfix_dim,&postfix_indices_string);
    ordinal postfix_indices[MAXDIM];
    for (i=0;i<postfix_dim;i++) postfix_indices[i]=atoi(postfix_indices_string[i]);
    free(postfix_indices_string);
    ordinal initial_offset=0;
    for (i=0;i<postfix_dim;i++) initial_offset+=postfix_indices[i]*offset[i+vector_dim+slice_dim];
    int first_offset_argc;
    char **first_offset_argv;
    Tcl_SplitList(interp,argv[7],&first_offset_argc,&first_offset_argv);
    float *previous_offset=(float *)malloc(sizeof(scalar)*first_offset_argc);
    for (i=0;i<first_offset_argc;i++) previous_offset[i]=atof(first_offset_argv[i]);
    int baseline_first_offset_argc;
    char **baseline_first_offset_argv;
    Tcl_SplitList(interp,argv[8],&baseline_first_offset_argc,&baseline_first_offset_argv);
    float *baseline_previous_offset=(float *)malloc(sizeof(scalar)*baseline_first_offset_argc);
    for (i=0;i<baseline_first_offset_argc;i++) baseline_previous_offset[i]=atof(baseline_first_offset_argv[i]);
    free(first_offset_argv);
    free(baseline_first_offset_argv);
    int vector_order_argc;
    char **vector_order_argv;
    Tcl_SplitList(interp,argv[6],&vector_order_argc,&vector_order_argv);
    #Info: "Saving vectors for slice %s (delta and differential) in %s" argv[5],argv[1]
    ordinal vector_index;
    for (vector_index=0;vector_index<vector_order_argc;vector_index++) {
        struct dvec *d=plot_cur->pl_dvecs;
        while ((d)&&(strcmp(d->v_name,vector_order_argv[vector_index])))  d = d->v_next;
        if (!(d)) {
            #Error: "(%s) listed vector %s was not simulated" argv[0] vector_order_argv[vector_index]
            return TCL_ERROR;
        }
        struct dvec *b=save_slice_base->pl_dvecs;
        while ((b)&&(strcmp(b->v_name,vector_order_argv[vector_index])))  b = b->v_next;
        if (!(b)) {
            #Error: "(%s) listed vector %s was not simulated in the saved baseline" argv[0] vector_order_argv[vector_index]
            return TCL_ERROR;
        }
        char vector_id[128];
        for (i=2;d->v_name[i]!=')';i++) {
            if (d->v_name[i]=='_') {
                vector_id[i-2]=' ';
            } else {
                vector_id[i-2]=d->v_name[i];
            }
        }
        vector_id[i-2]=0;
        int tmp_dim;
        char **vector_index_string;
        Tcl_SplitList(interp,vector_id,&tmp_dim,&vector_index_string);
        if (slice_dim!=tmp_dim) continue;
        ordinal final_offset=initial_offset;
        for (i=0;i<slice_dim;i++) final_offset+=(atoi(vector_index_string[i])-starting_index)*offset[i+vector_dim];
        free(vector_index_string);
        write_ordinal(O,final_offset);
        write_ordinal(O,d->v_length);
        if (factor_mode) {
            for (i=0;i<d->v_length;i++) {
                #Dinfo: "%s   %g/((%g-%g)-(%g-%g))=%g" d->v_name factor d->v_realdata[i] previous_offset[i] b->v_realdata[i] baseline_previous_offset[i] factor/((d->v_realdata[i]-previous_offset[i])-(b->v_realdata[i]-baseline_previous_offset[i]))
                write_float(O,factor/((d->v_realdata[i]-previous_offset[i])-(b->v_realdata[i]-baseline_previous_offset[i])));
                previous_offset[i]=d->v_realdata[i];
                baseline_previous_offset[i]=b->v_realdata[i];
            }
        } else {
            for (i=0;i<d->v_length;i++) {
                #Dinfo: "%s   ((%g-%g)-(%g-%g))*%g=%g" d->v_name d->v_realdata[i] previous_offset[i] b->v_realdata[i] baseline_previous_offset[i] factor factor*((d->v_realdata[i]-previous_offset[i])-(b->v_realdata[i]-baseline_previous_offset[i]))
                write_float(O,((d->v_realdata[i]-previous_offset[i])-(b->v_realdata[i]-baseline_previous_offset[i]))*factor);
                previous_offset[i]=d->v_realdata[i];
                baseline_previous_offset[i]=b->v_realdata[i];
            }
        }
    }
    free(previous_offset);
    free(baseline_previous_offset);
    fclose(O);
    return TCL_OK;
}
static int
load_characterization_slice (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    if (argc!=3) {
        #Error: "usage: %s <array name> <file name>" argv[0]
        return TCL_ERROR;
    }
    LUT *a=get_LUT(argv[1]);
    if (!a) {
        #Error: "(%s) array %s must be initialized before slices can be loaded" argv[0],argv[1]
        return TCL_ERROR;
    }
    open_to_read(argv[2]);
    #Info: "Slice loader from file %s" argv[2]
    while (more_to_read()) {
        ordinal i;
        ordinal offset=read_ordinal();
        ordinal length=read_ordinal();
        for (i=0;i<length; i++) {
            get_float(&(a->content[offset+i]));
            #Dinfo: "%ld+%ld  =  %g" offset i a->content[offset+i]
        }    
    }
    done_reading();
    return TCL_OK;
}
#endif
/********************************************************
DEPRECATED: Tcl based LUT populating function.
LUT's should not be dumped and loaded in ASCII files,
because of run time constraints.
The cTree database system takes care of binary marshalling
and file saving/loading of LUT's as well as other 
data structures.
********************************************************/

static int
array_data (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc!=3) {
        #Error: "array_data requires array name and list of floating-point numbers"
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    LUT *a=get_LUT(argv[1]);
    if (a==NULL) {
        #Error: "(array_data) No such array: %s" argv[1]
        return TCL_ERROR;
    }
    ordinal i;
    ordinal volume=1;
    for (i=0;i<a->dim;i++) {
        volume*=a->size[i];
    }
    #Info: "loading %s, %d data points." argv[1],volume
    char **data=(char **)malloc(sizeof(char *)*volume);
    int arm=1;
    ordinal j=0;
    char *list=strdup(argv[2]);
    for (i=0;list[i];i++) {
        if ((list[i]==' ')||(list[i]==' ')) {
            list[i]=0;
            arm=1;
            continue;
        }
        if (arm) {
            data[j]=&(list[i]);
            j++;
            arm=0;
        }
    }
    #Info: "parsed %s" argv[1],volume
    for (i=0;i<volume;i++) {
        a->content[i]=atof(data[i]);
    }
    #Info: "loaded %s" argv[1],volume
    return TCL_OK;
}

int array_save(LUT *a,char *filename,int append_mode) {
    FILE *O;
    if (append_mode) {
        O=fopen(filename,"a");
    } else {
        O=fopen(filename,"w");
    }
    write_string(O,a->name);
    write_ordinal(O,a->dim);
    ordinal i,j;
    for (i=0;i<a->dim;i++) write_ordinal(O,a->size[i]);
    for (i=0;i<a->dim;i++) for (j=0;j<a->size[i];j++) write_float(O,a->legend[i][j]);
    ordinal volume=1;
    for (i=0;i<a->dim;i++) volume*=a->size[i];
    for (i=0;i<volume;i++) write_float(O,a->content[i]);
    if (a->LIT==NULL) {
        write_ordinal(O,0);
        fclose(O);
        return TCL_OK;
    }
    write_ordinal(O,1);
    for (i=0;i<a->LIT->volume*(a->dim+1);i++) write_ordinal(O,a->LIT->content[i]);
    fclose(O);
    return TCL_OK;
}
void context_save(context *c,FILE *O) {
    if (c->parent) {
        #Dinfo: "[c] Saving context %s type=%d" c->name c->value_type
        write_string(O,c->name);
        write_ordinal(O,c->value_type);
        if (c->value_type==ctype_void) write_string(O,"");
        if (c->value_type==ctype_string) write_string(O,c->value.v);
        if (c->value_type==ctype_real) write_float(O,c->value.s);
        if (c->value_type==ctype_integer) write_ordinal(O,c->value.o);
        if (c->value_type==ctype_PAT) write_pointer_PAT(O,(PAT *)c->value.v);
        if (c->value_type==ctype_LUT) {
            LUT *a=(LUT *)c->value.v;
            #Dinfo: "Saving LUT %s (%x) name=%s dim=%d" c->name c->value.v a->name a->dim
            write_string(O,a->name);
            write_ordinal(O,a->dim);
            ordinal i,j;
            for (i=0;i<a->dim;i++) write_ordinal(O,a->size[i]);
            for (i=0;i<a->dim;i++) for (j=0;j<a->size[i];j++) write_float(O,a->legend[i][j]);
            ordinal volume=1;
            for (i=0;i<a->dim;i++) volume*=a->size[i];
            for (i=0;i<volume;i++) write_float(O,a->content[i]);
            if (a->LIT==NULL) {
                write_ordinal(O,0);
            } else {
                write_ordinal(O,1);
                for (i=0;i<a->LIT->volume*(a->dim+1);i++) write_ordinal(O,a->LIT->content[i]);
            }
        }    
        write_ordinal(O,c->num_of_children);
    }
    int i;
    #Dinfo: "[c] Saving %d children of %s" c->num_of_children c->name
    for (i=0;i<c->num_of_children;i++) context_save(c->children[i],O);
}
void context_load(context *c,int level) {
    while (more_to_read()) {
        char name[256];
        read_string(name);
        CTYPE value_type=read_ordinal();
        context *next_context=new_context(c,name,value_type);
        #Dinfo: "Loading context %s type=%d starting at (%x) level=%d" name value_type c level
        if (value_type==ctype_void) next_context->value.v=copy_string();
        if (value_type==ctype_string) {
            next_context->value.v=copy_string();
            #Dinfo: "   string value: %s" next_context->value.v
        }    
        if (value_type==ctype_real) next_context->value.s=read_float();
        if (value_type==ctype_integer) next_context->value.o=read_ordinal();
        if (value_type==ctype_PAT) {
            next_context->value.v=read_pointer_PAT();
        }    
        if (value_type==ctype_POLY) {
            next_context->value.v=read_pointer_POLY();
        }    
        if (value_type==ctype_LUT) {
            LUT *a=(LUT *)malloc(sizeof(LUT));
            a->name=copy_string();
            a->dim=read_ordinal();
            #Dinfo: "Loaded LUT %s dim=%d" a->name a->dim
            #For: {set dim 1} {$dim<$::MAXDIM} {incr dim} {
                if (a->dim==$dim) {
                    a->interpolate=lut_interpolation_$dim;
                    a->gamma_interpolate=lut_gamma_interpolation_$dim;
                    a->gamma_gradient=lut_gamma_gradient_$dim;
                }    
            }
            ordinal volume=1;
            int j,k,i;
            for (j=0;j<a->dim;j++) {
                a->size[j]=read_ordinal();
                a->legend[j]=(ordinal *)malloc(sizeof(ordinal)*a->size[j]);
                volume*=a->size[j];
            }
            #Info: "Loading array ./%s [eng %ld B]" name volume*BYTES_PER_FLOAT
            for (j=0;j<a->dim;j++) {
                for (k=0;k<a->size[j];k++) {
                    a->legend[j][k]=read_float();
                }
                a->physical_factor[j]=1.0/(a->legend[j][1]-a->legend[j][0]);
            }
            a->hypercube_volume=1;
            for (i=0;i<a->dim;i++) a->hypercube_volume*=(a->legend[i][1]-a->legend[i][0]);
            a->sizer[0]=1;
            for (i=1;i<a->dim;i++) a->sizer[i]=a->sizer[i-1]*a->size[i-1];
            a->content=(float *)malloc(sizeof(float)*volume);
            for (i=0;i<volume;i++) a->content[i]=read_float();
            ordinal num_of_corners=1<<a->dim;
            ordinal offset;
            for (offset=0;offset<num_of_corners;offset++) {
                ordinal sizer=1;
                ordinal index=0;
                // scratch 'tmp' to roll the offset bits without destroying offset itself:
                ordinal tmp_offset=offset;
                for (i=0;i<a->dim;i++) {
                    index+=sizer*(tmp_offset&1);
                    sizer*=a->size[i];
                    // next bit
                    tmp_offset>>=1;
                }  
                a->neighbors[offset]=index;
            } 
            a->LIT=NULL;
            a->hit=NULL;
            if (read_float()) {
                #Info: "Array %s has attached LIT" name
                linear_interpolation_table *L=(linear_interpolation_table *)malloc(sizeof(linear_interpolation_table));
                a->LIT=L;
                L->dim=a->dim;
                L->size=(ordinal *)malloc(sizeof(ordinal)*L->dim);
                L->index_weight=(ordinal *)malloc(sizeof(ordinal)*L->dim);
                L->baseline=(float *)malloc(sizeof(scalar)*L->dim);
                L->inv_step=(float *)malloc(sizeof(scalar)*L->dim);
                ordinal i;
                L->volume=1;
                for (i=0;i<a->dim;i++) {
                    L->size[i]=-1;
                    ordinal tmp=a->size[i];
                    while (tmp) {
                        L->size[i]++;
                        tmp/=2;
                    }
                    fflush(stdout);
                    L->index_weight[i]=L->volume;
                    
                    L->volume*=(a->size[i]-1);
                    L->baseline[i]=a->legend[i][0];
                    L->inv_step[i]=1/(a->legend[i][1]-a->legend[i][0]);
                }
                ordinal num_of_corners=1<<a->dim;
                L->content=(float *)malloc(sizeof(scalar)*(1+a->dim)*L->volume);
                #Info: "Loading attached LIT[%ld]" L->volume*(a->dim+1)
                for (i=0;i<L->volume*(a->dim+1);i++) L->content[i]=read_float();
                #Info: "Done loading attached LIT[%ld]" L->volume*(a->dim+1)
            }
            next_context->value.v=a;
        }
        //add_sub_context(c,next_context);
        ordinal num_of_children=read_ordinal();
        #Dinfo: "num_of_children=%ld" num_of_children
        int i;
        for (i=0;i<num_of_children;i++) context_load(next_context,level+1);
        if (level!=0) break;
    }    
}
static int
LUT_save (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if ((argc!=3)&&(argc!=4)) {
        #Error: "usage: %s <array> <file name> [<mode>]" argv[0]
        return TCL_ERROR;
    }
    int append_mode=0;
    if (argc==4) if (strcmp(argv[3],"append")==0) append_mode=1;
    LUT *a=get_LUT(argv[1]);
    return(array_save(a,argv[2],append_mode));
}
int array_load(char *filename) {
    open_to_read(filename);
    char name_buffer[1024*1024];
    ordinal i,j,k;
    #Info: "Reading arrays from %s" filename
    while (more_to_read()) {
        char *name=copy_string();
        LUT *a;
        if (!(a=get_LUT_quiet(name))) {
            char cmd[1024];
            #Warning: "array %s is implied from file" name
            add_array_context(name,&Context);
            a=get_LUT(name);
        }
        a->name=name;
        a->dim=read_ordinal();
        #For: {set dim 2} {$dim<$::MAXDIM} {incr dim} {
            if (a->dim==$dim) {
                a->interpolate=lut_interpolation_$dim;
                a->gamma_interpolate=lut_gamma_interpolation_$dim;
                a->gamma_gradient=lut_gamma_gradient_$dim;
            }	
        }
        a->LIT=NULL;
        a->hit=NULL;
        ordinal volume=1;
        for (j=0;j<a->dim;j++) {
            a->size[j]=read_ordinal();
            a->legend[j]=(ordinal *)malloc(sizeof(ordinal)*a->size[j]);
            volume*=a->size[j];
        }
        #Info: "Loading array %s [eng %ld B]" name volume*BYTES_PER_FLOAT
        for (j=0;j<a->dim;j++) {
            for (k=0;k<a->size[j];k++) {
                a->legend[j][k]=read_float();
            }
            a->physical_factor[j]=1.0/(a->legend[j][1]-a->legend[j][0]);
        }
        a->hypercube_volume=1;
        for (i=0;i<a->dim;i++) a->hypercube_volume*=(a->legend[i][1]-a->legend[i][0]);
        a->sizer[0]=1;
        for (i=1;i<a->dim;i++) a->sizer[i]=a->sizer[i-1]*a->size[i-1];
        a->content=(float *)malloc(sizeof(scalar)*volume);
        for (i=0;i<volume;i++) {
            a->content[i]=read_float();
        }
        ordinal num_of_corners=1<<a->dim;
        ordinal offset;
        for (offset=0;offset<num_of_corners;offset++) {
            ordinal sizer=1;
            ordinal index=0;
            // scratch 'tmp' to roll the offset bits without destroying offset itself:
            ordinal tmp_offset=offset;
            for (i=0;i<a->dim;i++) {
                index+=sizer*(tmp_offset&1);
                sizer*=a->size[i];
                // next bit
                tmp_offset>>=1;
            }  
            a->neighbors[offset]=index;
        } 
        if (read_float()) {
            #Info: "Array %s has attached LIT" name
            linear_interpolation_table *L=(linear_interpolation_table *)malloc(sizeof(linear_interpolation_table));
            a->LIT=L;
            L->dim=a->dim;
            L->size=(ordinal *)malloc(sizeof(ordinal)*L->dim);
            L->index_weight=(ordinal *)malloc(sizeof(ordinal)*L->dim);
            L->baseline=(float *)malloc(sizeof(scalar)*L->dim);
            L->inv_step=(float *)malloc(sizeof(scalar)*L->dim);
            ordinal i;
            L->volume=1;
            for (i=0;i<a->dim;i++) {
                L->size[i]=-1;
                ordinal tmp=a->size[i];
                while (tmp) {
                    L->size[i]++;
                    tmp/=2;
                }
                fflush(stdout);
                L->index_weight[i]=L->volume;
                
                L->volume*=(a->size[i]-1);
                L->baseline[i]=a->legend[i][0];
                L->inv_step[i]=1/(a->legend[i][1]-a->legend[i][0]);
            }
            ordinal num_of_corners=1<<a->dim;
            L->content=(float *)malloc(sizeof(scalar)*(1+a->dim)*L->volume);
            #Info: "Loading attached LIT[%ld]" L->volume*(a->dim+1)
            for (i=0;i<L->volume*(a->dim+1);i++) L->content[i]=read_float();
            #Info: "Done loading attached LIT[%ld]" L->volume*(a->dim+1)
        }
    }
    #Info: "Done reading arrays from %s" filename
    done_reading();
    return TCL_OK;    
}
static int
LUT_load (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc!=2) {
        #Error: "usage: %s <file name>" argv[0]
        return TCL_ERROR;
    }
    return(array_load(argv[1]));
}
static int
array_get (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc<2) {
        #Error: "array_set requires array name and list of indices"
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    LUT *a=get_LUT(argv[1]);
    if (a==NULL) {
        #Error: "(array_set) No such array: %s" argv[1]
        return TCL_ERROR;
    }
    if (argc-2!=a->dim) {
        #Error: "(array_set) Array: %s has %d dimension, but accessed with %d indices" argv[1],a->dim,argc-2
        return TCL_ERROR;
    }
    long offset=1;
    long index=0;    
    long i;
    for (i=0;i<a->dim;i++) {
        index+=atoi(argv[i+2])*offset;
        offset*=a->size[i];
    }
    tcl_append_float(interp,a->content[index]);
    return TCL_OK;
}
static int
array_set (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc<2) {
        #Error: "array_set requires array name and list of indices"
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    LUT *a=get_LUT(argv[1]);
    if (a==NULL) {
        #Error: "(array_set) No such array: %s" argv[1]
        return TCL_ERROR;
    }
    if (argc-3!=a->dim) {
        #Error: "(array_set) Array: %s has %d dimension, but accessed with %d indices" argv[1],a->dim,argc-3
        return TCL_ERROR;
    }
    int offset=1;
    int index=0;    
    int i;
    for (i=0;i<a->dim;i++) {
        index+=atoi(argv[i+2])*offset;
        offset*=a->size[i];
    }
    a->content[index]=atof(argv[argc-1]);
    return TCL_OK;
}
char *strcopy(char *src) {
    char *dest=(char *)malloc(strlen(src)+1);
    sprintf(dest,"%s",src);
    return(dest);
}
#ifdef SPICE_COMPILATION
wordlist *args2wordlist(int argc, char **argv) {
    wordlist *last=NULL;
    wordlist *source=NULL;
    int i;
    for (i=1;i<argc;i++) {
        wordlist *w=(wordlist *)malloc(sizeof(wordlist));
        w->wl_prev=last;
        if (last) {
            last->wl_next=w;
        } else {
            source=w;
        }   
        w->wl_next=NULL;
        w->wl_word=strdup(argv[i]);
        last=w;
    }
    return(source);
}
static int
alter_param (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    com_alter(args2wordlist(argc,argv));
    return TCL_OK;
}
static int
set_param (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    com_set(args2wordlist(argc,argv));
    return TCL_OK;
}
static int
get_circuits (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    struct circ *circ_p=ft_curckt;
    Tcl_ResetResult(interp);
    while (circ_p!=NULL) {
        Tcl_AppendElement(interp,circ_p->ci_name);
        circ_p=circ_p->ci_next;
    }
    return TCL_OK;
}
void print_ccom_tree(struct ccom *root,int indent) {
    if (root==NULL) {
        return;
    }
    if (root->cc_name==NULL) {
        return;
    }
    int i=0;
    for (i=0;i<indent;i++) printf(" ");
    printf("%s\n",root->cc_name);
    if (root->cc_child==NULL) {
        return;
    }
    struct ccom *child=root->cc_child;
    while (child!=NULL) {
        print_ccom_tree(child,indent+4);
        child=child->cc_sibling;
    }
}
static int
get_ckt_tree (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc!=3) {
        #Error: "get_ckt_tree requires circuit number and tree type [nodes,devices]"
        return TCL_ERROR;
    }
    struct circ *circ_p=ft_curckt;
    Tcl_ResetResult(interp);
    int ckt_index=atoi(argv[1]);
    int i=0;
    while (circ_p!=NULL && i<ckt_index) {
        circ_p=circ_p->ci_next;
        i++;
    }
    if (circ_p==NULL) {
        #Error: "(get_ckt_tree) Circuit index %d exceeded number of circuits (only %d circuits loaded)" ckt_index,i
        return TCL_ERROR;
    }
    struct ccom *root=NULL;
    if ((strcmp(argv[2],"nodes")!=0)&&(strcmp(argv[2],"devices")!=0)) {
        #Error: "(get_ckt_tree) Tree type %s invalid" argv[2]
        return TCL_ERROR;
    }
    if (strcmp(argv[2],"nodes")==0) {
        root=circ_p->ci_nodes;
    }
    if (strcmp(argv[2],"devices")==0) {
        root=circ_p->ci_devices;
    }
    if (root==NULL) {
        #Warning: {(get_ckt_tree) Tree type \"%s\" missing from circuit \"%s\"} argv[2],circ_p->ci_name
        return TCL_ERROR;
    }
    print_ccom_tree(root,0);
    return TCL_OK;
}
static int
get_vectors (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc!=1) {
        #Error: "get_vectors requires no arguments"
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    if (plot_cur==NULL) {
        #Error: "No vectors exist"
        return TCL_ERROR;
    }
    struct plot *any_plot=plot_list;
    while (any_plot) {
        struct dvec *d=any_plot->pl_dvecs;
        while (d) {
            Tcl_AppendElement(interp,d->v_name);
            d = d->v_next;
        }
        any_plot=any_plot->pl_next;
    }
    return TCL_OK;
}
static int
tcl_dc_analysis (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    printf("DC Analysis begin\n");
    com_dc(args2wordlist(argc,argv));
    printf("DC Analysis end\n");
    return TCL_OK;
}
static int
set_spice_var (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if ((argc!=3)&&(argc!=2)) {
        #Error: "usage: %s <var> [<val>]" argv[0]
        return TCL_ERROR;
    }
    if (argc==2) {
        #Foreach: global_var $::global_c_variables {
            if (strcmp(argv[1],"$global_var")==0) {
                tcl_append_float(interp,$global_var);
                return TCL_OK;
            }
        }
        #Error: "No such spice variable %s" argv[1]
        return TCL_ERROR;
    }
    #Foreach: global_var $::global_c_variables {
        if (strcmp(argv[1],"$global_var")==0) {
            $global_var=atof(argv[2]);
            return TCL_OK;
        }
    }
    #Error: "No such spice variable %s" argv[1]
    return TCL_ERROR;
}    
static int
get_spice_data (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc!=3) {
        #Error: "get_vector_data requires vector name and index/command"
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    if (plot_cur==NULL) {
        #Error: "No vectors exist"
        return TCL_ERROR;
    }
    char *vector_name=argv[1];
    struct dvec *d=plot_cur->pl_dvecs;
    struct dvec *V=NULL;
    while (d) {
        if(strcmp(vector_name,d->v_name)==0) {
            V=d;
            break;
        }
        d = d->v_next;
    }
    // Try to get the vector in other plots
    if (V==NULL) {
        struct plot *any_plot=plot_list;
        while (any_plot) {
            d=any_plot->pl_dvecs;
            while (d) {
                if(strcmp(vector_name,d->v_name)==0) {
                    V=d;
                    break;
                }
                d = d->v_next;
            }
            if (V) break;
            any_plot=any_plot->pl_next;
        }
    }
    // Last chitce: maybe the user wants a global variable
    #Foreach: global_var $::global_c_variables {
        if (strcmp(vector_name,"$global_var")==0) {
            tcl_append_float(interp,$global_var);
            return TCL_OK;
        }
    }
    if (V==NULL) {
        #Error: "get_vector_data did not get a valid vector name '%s'" vector_name
        return TCL_ERROR;
    }
    char *command=argv[2];
    if (strcmp(command,"length")==0) {
        tcl_append_int(interp,V->v_length);
        return TCL_OK;
    }
    if (strcmp(command,"end")==0) {
        tcl_append_float(interp,V->v_realdata[V->v_length-1]);
        return TCL_OK;
    }
    if (command[0]=='>') {
        int i;
        int res=-1;
        float th=atof(&(command[1]));
        for (i=0;i<V->v_length;i++) {
            if (V->v_realdata[i]>th) {
                res=i;
                break;
            }
        }
        tcl_append_int(interp,res);
        return TCL_OK;
    }
    if (command[0]=='<') {
        int i;
        int res=-1;
        float th=atof(&(command[1]));
        for (i=0;i<V->v_length;i++) {
            if (V->v_realdata[i]<th) {
                res=i;
                break;
            }
        }
        tcl_append_int(interp,res);
        return TCL_OK;
    }
    if (command[0]=='x') {
        int i;
        int res=-1;
        float th=atof(&(command[1]));
        for (i=0;i<V->v_length;i++) {
            if (((V->v_realdata[i]<th)&&(V->v_realdata[0]>th))||((V->v_realdata[i]>th)&&(V->v_realdata[0]<th))) {
                res=i;
                break;
            }
        }
        tcl_append_int(interp,res);
        return TCL_OK;
    }
    if (command[0]=='t') {
        struct dvec *T=NULL;
        d=plot_cur->pl_dvecs;
        while (d) {
            if(strcmp("time",d->v_name)==0) {
                T=d;
                break;
            }
            d = d->v_next;
        }
        if (T==NULL) {
            #Error: "get_vector_data cannot process operator t, no time vector found."
            return TCL_ERROR;
        }
        if (command[1]=='>') {
            int i;
            int res=-1;
            float th=atof(&(command[2]));
            for (i=0;i<V->v_length;i++) {
                if (V->v_realdata[i]>th) {
                    res=i;
                    break;
                }
            }
            if ((res==-1)||(res>=T->v_length)) {
                tcl_append_float(interp,-1);
                return TCL_OK;
            }
            tcl_append_float(interp,T->v_realdata[res]);
            return TCL_OK;
        }
        if (command[1]=='<') {
            int i;
            int res=-1;
            float th=atof(&(command[2]));
            for (i=0;i<V->v_length;i++) {
                if (V->v_realdata[i]<th) {
                    res=i;
                    break;
                }
            }
            if ((res==-1)||(res>=T->v_length)) {
                tcl_append_float(interp,-1);
                return TCL_OK;
            }
            tcl_append_float(interp,T->v_realdata[res]);
            return TCL_OK;
        }
        if (command[1]=='x') {
            int i;
            int res=-1;
            float th=atof(&(command[2]));
            for (i=0;i<V->v_length;i++) {
                if (((V->v_realdata[i]<th)&&(V->v_realdata[0]>th))||((V->v_realdata[i]>th)&&(V->v_realdata[0]<th))) {
                    res=i;
                    break;
                }
            }
            if (res==-1) {
                tcl_append_float(interp,-1);
                return TCL_OK;
            }
            if (res>=T->v_length) {
                tcl_append_float(interp,-2);
                return TCL_OK;
            }
            tcl_append_float(interp,T->v_realdata[res]);
            return TCL_OK;
        }
    }
    if (strcmp(command,"type")==0) {
        if (V->v_realdata) Tcl_AppendElement(interp,"real");
        else if (V->v_compdata) Tcl_AppendElement(interp,"complex");
        return TCL_OK;
    }
    if (strcmp(command,"average")==0) {
        float average=0;
        int i;
        for (i=0;i<V->v_length;i++) average+=V->v_realdata[i];
        tcl_append_float(interp,average/V->v_length);
        return TCL_OK;
    }
    if (strcmp(command,"stddev")==0) {
        float average=0;
        int i;
        for (i=0;i<V->v_length;i++) average+=V->v_realdata[i];
        average/=V->v_length;
        float stddev=0;
        for (i=0;i<V->v_length;i++) stddev+=(V->v_realdata[i]-average)*(V->v_realdata[i]-average);
        stddev/=V->v_length;
        tcl_append_float(interp,sqrt(stddev));
        return TCL_OK;
    }
    if (strcmp(command,"all")==0) {
        int i;
        for (i=0;i<V->v_length;i++) tcl_append_float(interp,V->v_realdata[i]);
        return TCL_OK;
    }
    int index =atoi(command);
    if (index>=V->v_length) {
        #Error: "get_vector_data vector %s has only %d entries" vector_name,V->v_length
        return TCL_ERROR;
    }
    if (V->v_realdata) {
        tcl_append_float(interp,V->v_realdata[index]);
    } else if (V->v_compdata) {
        tcl_append_float(interp,V->v_compdata[index].cx_real);
        tcl_append_float(interp,V->v_compdata[index].cx_imag);
    }	 
    return TCL_OK;
}


static int
get_var (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc!=3) {
        #Error: "get_var requires circuit number and parameter name"
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    struct circ *circ_p=ft_curckt;
    int ckt_index=atoi(argv[1]);
    int i=0;
    float res;
    char buf[16];
    nupa_get_params(argv[2],buf);
    Tcl_AppendElement(interp,buf);
    return TCL_OK;
}
static int
set_var (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc!=4) {
        #Error: "set_var requires circuit number, parameter name and value"
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    struct circ *circ_p=ft_curckt;
    int ckt_index=atoi(argv[1]);
    int i=0;
    float res;
    nupa_set_params(argv[2],argv[3]);
    cp_vset(argv[2],CP_REAL,argv[3]);
    return TCL_OK;
}
static int
get_ckt_devices (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc!=2) {
        #Error: "get_ckt_devices requires circuit number"
        return TCL_ERROR;
    }
    struct circ *circ_p=ft_curckt;
    Tcl_ResetResult(interp);
    int ckt_index=atoi(argv[1]);
    int i=0;
    while (circ_p!=NULL && i<ckt_index) {
        circ_p=circ_p->ci_next;
        i++;
    }
    if (circ_p==NULL) {
        #Error: "(get_ckt_devices) Circuit index %d exceeded number of circuits (only %d circuits loaded)" ckt_index,i
        return TCL_ERROR;
    }
    if (circ_p->ci_ckt==NULL) {
        #Error: "(get_ckt_devices) Circuit %s has no content" circ_p->ci_name
        return TCL_ERROR;
    }
    printf("Temp: %e \n",circ_p->ci_ckt->CKTtemp);
    GENmodel **models=circ_p->ci_ckt->CKThead;
    i=0;
    if (models==NULL) {
        #Error: "(get_ckt_devices) Circuit %s has no content" circ_p->ci_name
        return TCL_ERROR;
    }
    if (models[0]==NULL) {
        #Error: "(get_ckt_devices) Circuit %s is empty" circ_p->ci_name
        return TCL_ERROR;
    }
    while (models[i]!=NULL) {
        GENinstance *inst=models[i]->GENinstances;
        while (inst!=NULL) {
            Tcl_AppendElement(interp,(char *)inst->GENname);
            inst=inst->GENnextInstance;
        }
        i++;
    }
    printf("%d models\n",i);
    return TCL_OK;
}
static int
get_ckt_lines (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc!=2) {
        #Error: "(get_ckt_lines) requires circuit number"
        return TCL_ERROR;
    }
    struct circ *circ_p=ft_curckt;
    Tcl_ResetResult(interp);
    int ckt_index=atoi(argv[1]);
    int i=0;
    while (circ_p!=NULL && i<ckt_index) {
        circ_p=circ_p->ci_next;
        i++;
    }
    if (circ_p==NULL) {
        #Error: "(get_ckt_lines) Circuit index %d exceeded number of circuits (only %d circuits loaded)" ckt_index,i
        return TCL_ERROR;
    }
    struct line *linep=circ_p->ci_deck;
    while (linep!=NULL) {
        char buf[256];
        sprintf(buf,"%d",linep->li_linenum);
        Tcl_AppendElement(interp,buf);
        Tcl_AppendElement(interp,linep->li_line);
        linep=linep->li_next;
        
    }
    return TCL_OK;
}
#endif
static int
tcl_verbose (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if ((argc!=1)&&(argc!=2)) {
        #Error: "usage: %s [<value>]" argv[0]
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    if (argc==2) {
        verbose=atoi(argv[1]);
    } else {
        verbose=1-verbose;
    }
    tcl_append_int(interp,verbose);
    return TCL_OK;
}    
#ifdef SPICE_COMPILATION
static int
set_ckt_lines (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc!=4) {
        #Error: "(set_ckt_lines) requires circuit number, line number and new content"
        return TCL_ERROR;
    }
    struct circ *circ_p=ft_curckt;
    Tcl_ResetResult(interp);
    int ckt_index=atoi(argv[1]);
    int i=0;
    while (circ_p!=NULL && i<ckt_index) {
        circ_p=circ_p->ci_next;
        i++;
    }
    if (circ_p==NULL) {
        #Error: "(get_ckt_lines) Circuit index %d exceeded number of circuits (only %d circuits loaded)" ckt_index,i
        return TCL_ERROR;
    }
    int line_index=atoi(argv[2]);
    struct line *linep=circ_p->ci_deck;
    while (linep!=NULL) {
        if (linep->li_linenum!=line_index) {
            linep=linep->li_next;
            continue;
        }
        linep->li_line=(char *)malloc(strlen(argv[3])+1);
        strcpy(linep->li_line,argv[3]);
        break;
    }
    return TCL_OK;
}
// Imported from tclspice.c
Spice_Init(Tcl_Interp *interp)
{
    if (interp == 0)
    return TCL_ERROR;
    verbose=0;
    get_Tcl_timer=0;
    get_Tcl_counter=0;
    save_slice_base=NULL;
    #ifdef USE_TCL_STUBS
    if (Tcl_InitStubs(interp, (char *)"8.1", 0) == NULL)
    return TCL_ERROR;
    #endif
    
    Tcl_PkgProvide(interp, (char*) TCLSPICE_name, (char*) TCLSPICE_version);
    
    Tcl_Eval(interp, "namespace eval " TCLSPICE_namespace " { }");
    BSIM3v32InnerCalcList=NULL;
    network_node_root=NULL;
    save_interp();
    //init_serial();
    network_task_handle=0;
    {
        int i;
        char *key;
        Tcl_CmdInfo infoPtr;
        char buf[256];
        sighandler old_sigint;
        ft_rawfile = NULL;
        ivars(NULL);
        
        cp_in = stdin;
        cp_out = stdout;
        cp_err = stderr;
        
        /*timer*/
        init_time();
        
        /*IFsimulator struct initilised*/
        SIMinit(&nutmeginfo, &ft_sim);
        
        /* program name*/
        cp_program = ft_sim->simulator;
        
        srand((unsigned int) getpid());
        TausSeed();
        
        /*parameter fetcher, used in show*/
        if_getparam = spif_getparam_special;
        
        /* Get startup system limits */
        init_rlimits();
        
        /*Command prompt stuff */
        ft_cpinit();
        
        
        /* Read the user config files */
        /* To catch interrupts during .spiceinit... */
        old_sigint = signal(SIGINT, (SIGNAL_FUNCTION) ft_sigintr);
        if (SETJMP(jbuf, 1) == 1) {
            ft_sigintr_cleanup();
            fprintf(cp_err, "Warning: error executing .spiceinit.\n");
            goto bot;
        }
        
        #ifdef HAVE_PWD_H
        /* Try to source either .spiceinit or ~/.spiceinit. */
        if (access(".spiceinit", 0) == 0) {
            inp_source(".spiceinit");
        } else {
            char *s;
            struct passwd *pw;
            pw = getpwuid(getuid());
            
            #ifdef HAVE_ASPRINTF
            //    asprintf(&s, "%s%s", pw->pw_dir, INITSTR);
            #else
            s = TMALLOC(char, 1 + strlen(pw->pw_dir) + strlen(INITSTR));
            sprintf(s, "%s%s", pw->pw_dir, INITSTR);
            #endif
            if (access(s, 0) == 0)
            inp_source(s);
        }
        #else /* ~ HAVE_PWD_H */
        {
            FILE *fp;
            /* Try to source the file "spice.rc" in the current directory.  */
            if ((fp = fopen("spice.rc", "r")) != NULL) {
                (void) fclose(fp);
                inp_source("spice.rc");
            }
        }
        #endif /* ~ HAVE_PWD_H */
        bot:
        signal(SIGINT, old_sigint);
        
        /* initilise Tk display */
        DevInit();
        
        /* init the mutex */
        #ifdef HAVE_LIBPTHREAD
        pthread_mutex_init(&triggerMutex, NULL);
        #endif
        #ifdef THREADS
        signal(SIGINT, sighandler_tclspice);
        #endif
        
        /*register functions*/
        for (i = 0; (key = cp_coms[i].co_comname); i++) {
            sprintf(buf, "%s%s", TCLSPICE_prefix, key);
            if (Tcl_GetCommandInfo(interp, buf, &infoPtr) != 0)
            printf("Command '%s' can not be registered!\n", buf);
            else
            Tcl_CreateCommand(interp, buf, _tcl_dispatch, NULL, NULL);
        }
    }
    return TCL_OK;
}
#endif
#include "ctree.h"
node *new_node(node *i_parent,int i_index) {
    node *new_node=(node *)malloc(sizeof(node));
    int i;
    for (i=0;i<16;i++) new_node->children[i]=NULL;
    new_node->ctype=ctype_void;
    new_node->rtype=rtype_void;
    new_node->parent=i_parent;
    new_node->index=i_index;
    new_node->value=NULL;
    new_node->next=NULL;
    new_node->last=NULL;
    new_node->name=NULL;
    new_node->child=NULL;
    new_node->remote=NULL;
    return(new_node);
}

context *new_context(context *i_parent, char *i_name,CTYPE i_type) {
    // First, make sure the context is really new.
    if ((i_parent)&&(i_name)) {
        int i;
        for (i=0;i<i_parent->num_of_children;i++) {
            if (strcmp(i_parent->children[i]->name,i_name)==0) {
                if (i_type) i_parent->children[i]->value_type=i_type;
                return i_parent->children[i];
            }
        }
    }
    context *new_context=(context *)malloc(sizeof(context));
    new_context->max_num_of_children=DEFAULT_NUM_OF_SUBCONTEXTS;
    new_context->children=(context **)malloc(sizeof(context *)*new_context->max_num_of_children);
    int i;
    for (i=0;i<new_context->max_num_of_children;i++) new_context->children[i]=NULL;
    new_context->num_of_children=0;
    new_context->sibling_order=0;
    new_context->parent=i_parent;
    if (i_parent) new_context->sibling_order=add_sub_context(i_parent,new_context);
    new_context->name=NULL;
    if (i_name) new_context->name=strdup(i_name);
    new_context->value_type=i_type;
    return new_context;
}
ordinal add_sub_context(context *i_parent,context *i_child) {
    int i;
    if (i_parent->num_of_children==i_parent->max_num_of_children) {
        context **copied_list_of_children=(context **)malloc(sizeof(context *)*i_parent->max_num_of_children*2);
        for (i=0;i<i_parent->max_num_of_children;i++) copied_list_of_children[i]=i_parent->children[i];
        for (;i<i_parent->max_num_of_children*2;i++) copied_list_of_children[i]=NULL;
        i_parent->max_num_of_children*=2;
        free(i_parent->children);
        i_parent->children=copied_list_of_children;
    }
    i_parent->children[i_parent->num_of_children]=i_child;
    i_parent->num_of_children++;
    return(i_parent->num_of_children-1);
}
int resolve_context(char *i_key,context **i_context,float **array_entry) {
    context *temp_context=Context;
    if ((i_key[0]=='/')||(i_key[0]==':')) temp_context=Ctree;
    char context_name_buffer[1024];
    int j=0,i=0;
    #Dinfo: "Started Resolving Context %s from %x" i_key temp_context
    while (i_key[i]) {
        while (((i_key[i]=='/')||(i_key[i]==':'))&&(i_key[i])) i++;
        if (i_key[i]==0) break;
        while ((i_key[i]!='/')&&(i_key[i]!=':')&&(i_key[i])) context_name_buffer[j++]=i_key[i++];
        context_name_buffer[j]=0;
        #Dinfo: "Resolving SubContext %s from %x" context_name_buffer temp_context
        j=0;
        if (strcmp(context_name_buffer,"..")==0) {
            if (temp_context->parent==NULL)  {
                #Derror: "(resolve_context) No such context: %s, failed at %s" i_key context_name_buffer
                return 0;
            }
            temp_context=temp_context->parent;
            continue;
        }
        if (strcmp(context_name_buffer,".")==0) continue;
        int k=0;
        while ((context_name_buffer[k])&&(context_name_buffer[k]!='(')) k++;
        if (context_name_buffer[k]=='(') {
            context_name_buffer[k]=0;
            int l;
            context *next_context=NULL;
            for (l=0;l<temp_context->num_of_children;l++) {
                if (strcmp(context_name_buffer,temp_context->children[l]->name)==0) {
                    next_context=temp_context->children[l];
                    break;
                }
            }
            if (!next_context) {
                #Derror: "(resolve_context) No such context: %s, failed at %s" i_key context_name_buffer
                return 0;
            }
            temp_context=next_context;
            if (temp_context->value_type!=ctype_LUT) {
                #Error: "(resolve_context) No such array: %s" temp_context->name
                return 0;
            }
            LUT *a=(LUT *)temp_context->value.v;
            if (a==NULL) {
                #Error: "(resolve_context) No such array: %s" temp_context->name
                return 0;
            }
            char *argv[256];
            int argc=1;
            argv[0]=&(context_name_buffer[k+1]);
            for (l=k+1;context_name_buffer[l]!=')';l++) if (context_name_buffer[l]==',') argv[argc++]=&(context_name_buffer[l+1]);
            for (l=k+1;context_name_buffer[l]!=')';l++) if (context_name_buffer[l]==',') context_name_buffer[l]=0;
            context_name_buffer[l]=0;
            if (argc!=a->dim) {
                #Error: "(resolve_context) Array: %s has %d dimension, but accessed with %d indices" temp_context->name a->dim argc
                return 0;
            }
            ordinal offset=1;
            ordinal index=0;    
            for (l=0;l<a->dim;l++) {
                index+=atoi(argv[l])*offset;
                offset*=a->size[l];
            }
            *array_entry=&(a->content[index]);
            continue;
        }
        context *next_context=NULL;
        for (k=0;k<temp_context->num_of_children;k++) {
            if (strcmp(context_name_buffer,temp_context->children[k]->name)==0) {
                next_context=temp_context->children[k];
                break;
            }
        }
        if (!next_context) {
            #Derror: "(resolve_context) No such context: %s, failed at %s!" i_key context_name_buffer
            return 0;
        }
        temp_context=next_context;
    }
    #Dinfo: "Resolved context %s -> %x (%x,%g)" i_key temp_context &(temp_context->value.s) temp_context->value.s
    *i_context=temp_context;
    return 1;
}
PAT *new_PAT() {
    PAT *p=(PAT *)malloc(sizeof(PAT));
    p->content=new_vector_pointer_PAT_entry();
    p->sizes=new_vector_pointer_char();
    p->properties=new_vector_pointer_char();
    p->margins=new_vector_float();
    p->factors=new_vector_int();
    p->id_counter=0;
    return(p);
}
POLY *new_POLY() {
    POLY *p=(POLY *)malloc(sizeof(POLY));
    p->expression="";
    p->polynomial=new_vector_float();
    p->denom=NULL;
    return(p);
}
context *create_context(char *i_key) {
    #Dinfo: "Trying context %s" i_key
    context *temp_context=Context;
    if ((i_key[0]=='/')||(i_key[0]==':')) temp_context=Ctree;
    char context_name_buffer[1024];
    int j=0,i=0,n=0;
    while (i_key[i]) {
        while (((i_key[i]=='/')||(i_key[i]==':'))&&(i_key[i])) i++;
        if (i_key[i]==0) break;
        while ((i_key[i]!='/')&&(i_key[i]!=':')&&(i_key[i])) context_name_buffer[j++]=i_key[i++];
        context_name_buffer[j]=0;
        j=0;
        if (strcmp(context_name_buffer,"..")==0) {
            if (temp_context->parent==NULL)  {
                #Derror: "(create_context) No such context: %s, failed at %s" i_key context_name_buffer
                return(NULL);
            }
            temp_context=temp_context->parent;
            continue;
        }
        if (strcmp(context_name_buffer,".")==0) continue;
        int k=0;
        while ((context_name_buffer[k])&&(context_name_buffer[k]!='(')) k++;
        // New PAT
        if ((context_name_buffer[k]=='(')&&(context_name_buffer[k+1]=='(')) {
            #Dinfo: "PAT declaration" 
            context_name_buffer[k]=0;
            int l;
            context *next_context=NULL;
            for (l=0;l<temp_context->num_of_children;l++) {
                if (strcmp(context_name_buffer,temp_context->children[l])==0) {
                    next_context=temp_context->children[l];
                    break;
                }
            }
            if (!next_context) next_context=new_context(temp_context,context_name_buffer,ctype_PAT);
            temp_context=next_context;
            PAT *p=new_PAT();
            temp_context->value.v=p;
            add_entry_vector_pointer_char(p->sizes,&(context_name_buffer[k+2]));
            for (l=k+2;context_name_buffer[l]!='|';l++) if (context_name_buffer[l]==',') {
                add_entry_vector_pointer_char(p->sizes,&(context_name_buffer[l+1]));
                context_name_buffer[l]=0;
            }		
            context_name_buffer[l++]=0;
	    add_entry_vector_int(p->factors,1);
            add_entry_vector_pointer_char(p->properties,&(context_name_buffer[l]));
            for (;context_name_buffer[l]!=')';l++) if (context_name_buffer[l]==',') {
		add_entry_vector_int(p->factors,1);
                add_entry_vector_pointer_char(p->properties,&(context_name_buffer[l+1]));
                context_name_buffer[l]=0;
            }		
            context_name_buffer[l]=0;
            for (l=0;l<p->sizes->num_of;l++) p->sizes->content[l]=strdup(p->sizes->content[l]);
            for (l=0;l<p->properties->num_of;l++) {
	        #Dinfo: "p%d %x" l p->properties->content[l]
                int colon=0;
                float margin=0;
                while ((p->properties->content[l][colon])&&(p->properties->content[l][colon]!='?')) {
		    #Dinfo: "SFSG %c" p->properties->content[l][colon]
		    colon++; 
		    #Dinfo: "SFSG %c" p->properties->content[l][colon]
		}    
                if (p->properties->content[l][colon]=='?') {
                    margin=atof(&(p->properties->content[l][colon+1]));
                    p->properties->content[l][colon]=0;
                }
                add_entry_vector_float(p->margins,margin);
		if (p->properties->content[l][0]=='-') {
                    p->properties->content[l]=strdup(&(p->properties->content[l][1]));
		    p->factors->content[l]=-1;
		} else {
                    p->properties->content[l]=strdup(p->properties->content[l]);
		}
            }
            #Dinfo: "new pareto associative table: %s (%d sizes and %d properties)" temp_context->name p->sizes->num_of p->properties->num_of
            continue;
        } else if (context_name_buffer[k]=='(') {
            context_name_buffer[k]=0;
            int l;
            context *next_context=NULL;
            for (l=0;l<temp_context->num_of_children;l++) {
                if (strcmp(context_name_buffer,temp_context->children[l])==0) {
                    next_context=temp_context->children[l];
                    break;
                }
            }
            if (!next_context) next_context=new_context(temp_context,context_name_buffer,ctype_LUT);
            temp_context=next_context;
            LUT *a=(LUT *)malloc(sizeof(LUT));
            a->name=strdup(context_name_buffer);
            temp_context->value.v=a;
            char *argv[256];
            a->dim=1;
            argv[0]=&(context_name_buffer[k+1]);
            for (l=k+1;context_name_buffer[l]!=')';l++) if (context_name_buffer[l]==',') argv[a->dim++]=&(context_name_buffer[l+1]);
            for (l=k+1;context_name_buffer[l]!=')';l++) if (context_name_buffer[l]==',') context_name_buffer[l]=0;
            context_name_buffer[l]=0;
            #For: {set dim 2} {$dim<$::MAXDIM} {incr dim} {
                if (a->dim==$dim) {
                    a->interpolate=lut_interpolation_$dim;
                    a->gamma_interpolate=lut_gamma_interpolation_$dim;
                    a->gamma_gradient=lut_gamma_gradient_$dim;
                }
            }
            ordinal volume=1;
            for (l=0;l<a->dim;l++) {
                a->size[l]=atoi(argv[l]);
                volume*=a->size[l];
            }
            a->content=(float *)malloc(sizeof(float)*volume);
            for (l=0;l<volume;l++) a->content[l]=NAN;
            for (l=0;l<a->dim;l++) {
                a->legend[l]=(float *)malloc(sizeof(scalar)*a->size[l]);
                int j;
                for (j=0;j<a->size[l];j++) a->legend[l][j]=0;
            }
            a->sizer[0]=1;
            for (n=1;n<a->dim;n++) a->sizer[i]=a->sizer[i-1]*a->size[i-1];
            a->hypercube_volume=1;
            ordinal num_of_corners=1<<a->dim;
            ordinal offset;
            for (offset=0;offset<num_of_corners;offset++) {
                ordinal sizer=1;
                ordinal index=0;
                // scratch 'tmp' to roll the offset bits without destroying offset itself:
                ordinal tmp_offset=offset;
                for (l=0;l<a->dim;l++) {
                    index+=sizer*(tmp_offset&1);
                    sizer*=a->size[l];
                    // next bit
                    tmp_offset>>=1;
                }  
                a->neighbors[offset]=index;
            } 
            a->LIT=NULL;
            a->hit=NULL;
            #Dinfo: "new lookup table: %s (size: %ld*%ld=[eng %ld B]) %x" temp_context->name volume sizeof(float) volume*sizeof(float) a
            continue;
        }
        context *next_context=NULL;
        #Dinfo: "Searching for sub-context %s of %s" context_name_buffer temp_context->name
        for (k=0;k<temp_context->num_of_children;k++) {
            #Dinfo: "    Child %d=%s" k temp_context->children[k]->name
            if (strcmp(context_name_buffer,temp_context->children[k]->name)==0) {
                #Dinfo: "Sub-context %s already exists as child of %s" context_name_buffer temp_context->name
                next_context=temp_context->children[k];
                break;
            }
        }
        if (!next_context) {
            CTYPE c_type=ctype_void;
            void *v=NULL;
            if (strcmp(context_name_buffer,"POLY")==0) {
                c_type=ctype_POLY;
                v=new_POLY();
                #Dinfo: "New POLY at %s (%x %x)"  i_key temp_context v
            }	
            next_context=new_context(temp_context,context_name_buffer,c_type);
            next_context->value.v=v;
        }    
        temp_context=next_context;
    }
    #Dinfo: "Context %s created at %x, find scalar at (%x=%g)" i_key temp_context (&temp_context->value.s) temp_context->value.s
    return(temp_context);
}
int resolve_string_char(char i_char,node **i_node) {
    int upper_index=(i_char & 0xF0)>>4;
    int lower_index=i_char & 0x0F;
    if ((*i_node)->children[upper_index]==NULL) {
        return 0;
    }
    (*i_node)=(*i_node)->children[upper_index];
    if ((*i_node)->children[lower_index]==NULL) {
        return 0;
    }
    *i_node=(*i_node)->children[lower_index];
    return 1;
}
int resolve_string_token(char *i_token,node **i_node) {
    node *temp_node=*i_node;
    int i;
    for (i=0;i_token[i];i++) {
        if (!(resolve_string_char(i_token[i],&temp_node))) {
            return 0;
        }
    }
    if (temp_node->ctype==ctype_void) return 0;
    *i_node=temp_node;
    return 1;
}
int resolve_real_token(char *i_token,node **i_node) {
    if (i_token[0]=='<') {
        return(resolve_real_token_less_thit(&(i_token[1]),i_node));
    }
    if (i_token[0]=='>') {
        return(resolve_real_token_greater_thit(&(i_token[1]),i_node));
    }
    node *temp_node=*i_node;
    DL keydl;
    keydl.d=atof(i_token);
    long key=keydl.l;
    int i;
    for (i=0;i<sizeof(scalar)*8;i+=4) {
        int upper_index=((key & (0xF<<i))>>i)&0xf;
        if (temp_node->children[upper_index]==NULL) {
            return 0;
        }
        temp_node=temp_node->children[upper_index];
    }
    if (temp_node->ctype==ctype_void) return 0;
    *i_node=temp_node;
    return 1;
}
int resolve_real_token_less_thit(char *i_token,node **i_node) {
    return 0;
}
int resolve_real_token_greater_thit(char *i_token,node **i_node) {
    return 0;
}
int resolve_key(char *i_key,node **i_node,float **array_entry) {
    node *temp_node=*i_node;
    char *key=strdup(i_key);
    // Quick parse
    int len=strlen(key);
    int argc=1;
    int i;
    int array_start=0;
    *array_entry=NULL;
    for (i=0;i<len;i++) {
        if (key[i]=='(') {
            array_start=i+1;
            key[i]=0;
            len=i;
        }
    }
    for (i=0;i<len;i++) {
        if ((key[i]!='/')&&(key[i]!=':')) continue;
        key[i]=0;
        argc++;
    }
    char *argv[1024];
    int arg_index=0;
    argv[arg_index++]=key;
    for (i=0;i<len-1;i++) {
        if (key[i]==0) {
            argv[arg_index++]=&(key[i+1]);
        }
    } 
    if (key[0]==0) {
        temp_node=ctree;
    }	
    // Resolution
    for (i=0;((i<argc)&&(temp_node!=NULL));i++) {
        if (temp_node==NULL) break;
        if (argv[i][0]==0) continue;
        if ((argv[i][0]=='.')&&(argv[i][1]==0)) continue;
        if ((argv[i][0]=='.')&&(argv[i][1]=='.')&&(argv[i][2]==0)) {
            temp_node=temp_node->parent;
            continue;
        }
        if (temp_node->rtype==rtype_string)
        if (!(resolve_string_token(argv[i],&temp_node))) {
            return 0;
        } else continue;
        
        if (temp_node->rtype==rtype_real)
        if (!(resolve_real_token(argv[i],&temp_node))) {
            return 0;
        } else continue;
    }  
    if (temp_node==NULL) return 0;
    if (temp_node->ctype==ctype_void) return 0;
    *i_node=temp_node;
    if (array_start) {
        LUT *a=(LUT *)temp_node->value;
        if (a==NULL) {
            #Error: "(ctree) No such array: %s" temp_node->name
            return 0;
        }
        char *argv[256];
        int argc=1;
        argv[0]=&(key[array_start]);
        for (i=array_start;key[i]!=')';i++) {
            if (key[i]==',') argv[argc++]=&(key[i+1]);
        }
        if (argc!=a->dim) {
            #Error: "(ctree) Array: %s has %d dimension, but accessed with %d indices" temp_node->name,a->dim,argc
            return 0;
        }
        long offset=1;
        long index=0;    
        int i;
        for (i=0;i<a->dim;i++) {
            index+=atoi(argv[i])*offset;
            offset*=a->size[i];
        }
        *array_entry=&(a->content[index]);
    }
    return 1;
}
void add_child(node *parent,node *child) {
    child->parent=parent;
    if (parent->child==NULL) {
        parent->child=child;
        return;
    }
    node *sibling=parent->child;
    while (sibling->next) {
        sibling=sibling->next;
    }
    sibling->next=child;
    child->last=sibling;
}
node *add_string_context(char *key,node **i_node,CTYPE i_ctype) {
    node *temp_node=*i_node;
    int i;
    for (i=0;key[i];i++) {
        int upper_index=(key[i] & 0xF0)>>4;
        int lower_index=key[i] & 0x0F;
        if (temp_node->children[upper_index]==NULL) {
            temp_node->children[upper_index]=new_node(temp_node,upper_index);
            temp_node->rtype=rtype_string;
        }
        temp_node=temp_node->children[upper_index];
        if (temp_node->children[lower_index]==NULL) {
            temp_node->children[lower_index]=new_node(temp_node,lower_index);
            temp_node->rtype=rtype_string;
        }
        temp_node=temp_node->children[lower_index];
    }
    temp_node->ctype=i_ctype;
    temp_node->name=strdup(key);
    add_child(*i_node,temp_node);
    return(temp_node);
}
node *add_remote_context(char *key,node **i_node) {
    (*i_node)->rtype=rtype_remote;
    int i;
    //Parsing port number
    int port_start=0;
    int port=15295;
    for (i=0;key[i];i++) {
        if (key[i]==':') {
            port_start=i+1;
            key[i]=0;
            break;
        }
    }
    if (port_start) {
        port=atoi(&(key[port_start]));
    }
    // Resolving IP address from host name
    struct hostent *h;
    if((h=gethostbyname(key)) == NULL) {
        #Error: "Couldn't get host %s" key
        return NULL;
    }
    char host_ip[32];
    sprintf(host_ip,"%i.%i.%i.%i",(h->h_addr_list[0][0]+256)%256,(h->h_addr_list[0][1]+256)%256,(h->h_addr_list[0][2]+256)%256,(h->h_addr_list[0][3]+256)%256);
    (*i_node)->remote=(struct sockaddr_in *)malloc(sizeof(struct sockaddr_in));
    bzero((*i_node)->remote,sizeof(struct sockaddr_in));
    (*i_node)->remote->sin_family = AF_INET;
    (*i_node)->remote->sin_addr.s_addr=inet_addr(host_ip);
    (*i_node)->remote->sin_port=htons(port);
    return(*i_node);
}
node *add_array_context(char *i_key,node **i_node) {
    char *key=strdup(i_key);
    // Quick parse
    int len=strlen(key);
    if (len==0) { 
        LUT *a=(LUT *)malloc(sizeof(LUT));
        a->name=(*i_node)->name;
        (*i_node)->value=(void *)a;
        (*i_node)->ctype=ctype_LUT;
        return(NULL);
    }
    int argc=1;
    int i;
    for (i=0;i<len;i++) {
        if (key[i]!=',') continue;
        key[i]=0;
        argc++;
    }
    char **argv=(char **)malloc(sizeof(char *)*argc);
    int arg_index=0;
    argv[arg_index++]=key;
    for (i=0;i<len-1;i++) {
        if (key[i]==0) {
            argv[arg_index++]=&(key[i+1]);
        }
    } 
    LUT *a=(LUT *)malloc(sizeof(LUT));
    a->name=(*i_node)->name;
    a->dim=argc;
    #For: {set dim 2} {$dim<$::MAXDIM} {incr dim} {
        if (a->dim==$dim) {
            a->interpolate=lut_interpolation_$dim;
            a->gamma_interpolate=lut_gamma_interpolation_$dim;
            a->gamma_gradient=lut_gamma_gradient_$dim;
        }    
    }
    ordinal volume=1;
    for (i=0;i<a->dim;i++) {
        a->size[i]=atoi(argv[i]);
        volume*=a->size[i];
    }
    #Info: "new array: %s[%ld]" (*i_node)->name,volume*sizeof(float)
    a->content=(float *)malloc(sizeof(float)*volume);
    for (i=0;i<volume;i++) a->content[i]=NAN;
    for (i=0;i<a->dim;i++) {
        a->legend[i]=(float *)malloc(sizeof(scalar)*a->size[i]);
        int j;
        for (j=0;j<a->size[i];j++) a->legend[i][j]=0;
        a->physical_factor[i]=1.0;
    }
    a->sizer[0]=1;
    for (i=1;i<a->dim;i++) a->sizer[i]=a->sizer[i-1]*a->size[i-1];
    a->hypercube_volume=1;
    ordinal num_of_corners=1<<a->dim;
    ordinal offset;
    for (offset=0;offset<num_of_corners;offset++) {
        ordinal sizer=1;
        ordinal index=0;
        // scratch 'tmp' to roll the offset bits without destroying offset itself:
        ordinal tmp_offset=offset;
        for (i=0;i<a->dim;i++) {
            index+=sizer*(tmp_offset&1);
            sizer*=a->size[i];
            // next bit
            tmp_offset>>=1;
        }  
        a->neighbors[offset]=index;
    } 
    a->LIT=NULL;
    a->hit=NULL;
    (*i_node)->value=(void *)a;
    (*i_node)->ctype=ctype_LUT;
    return(NULL);
}
node *add_real_context(char *i_key,node **i_node,CTYPE i_ctype) {
    node *temp_node=*i_node;
    DL keydl;
    keydl.d=atof(i_key);
    long key=keydl.l;
    int i;
    for (i=0;i<sizeof(scalar)*8;i+=4) {
        int upper_index=((key& (0xF<<i))>>i)&0xf;
        if (temp_node->children[upper_index]==NULL) {
            temp_node->children[upper_index]=new_node(temp_node,upper_index);
            temp_node->rtype=rtype_real;
        }
        temp_node=temp_node->children[upper_index];
    }
    temp_node->ctype=i_ctype;
    temp_node->name=strdup(key);
    printf("Adding name %s (copy of %s)\n",temp_node->name,key);
    add_child(*i_node,temp_node);
    return(temp_node);
}
PAT *get_PAT(char *i_context) {
    context *c=Context;
    float *array_entry;
    if ((i_context[0]=='/')||(i_context[0]==':')) {
        c=Ctree;
    }
    if (!(resolve_context(i_context,&c,&array_entry))) {
        #Error: "(get_PAT) no such context %s" i_context
        return NULL;
    }
    return (PAT *)c->value.v;
}
PAT *get_PAT_quiet(char *i_context) {
    node *c=Context;
    float *array_entry;
    if ((i_context[0]=='/')||(i_context[0]==':')) {
        c=Ctree;
    }
    if (!(resolve_context(i_context,&c,&array_entry))) {
        return NULL;
    }
    return (PAT *)c->value;
}
LUT *get_LUT(char *i_context) {
    context *c=Context;
    float *array_entry;
    if ((i_context[0]=='/')||(i_context[0]==':')) {
        c=Ctree;
    }
    if (!(resolve_context(i_context,&c,&array_entry))) {
        #Error: "(get_LUT) no such context %s" i_context
        return NULL;
    }
    return (LUT *)c->value.v;
}
POLY *get_POLY(char *i_context) {
    context *c=Context;
    float *array_entry;
    if ((i_context[0]=='/')||(i_context[0]==':')) {
        c=Ctree;
    }
    if (!(resolve_context(i_context,&c,&array_entry))) {
        #Error: "(get_POLY) no such context %s" i_context
        return NULL;
    }
    if ((strcmp(c->name,"POLY")==0)&&(c->value_type!=ctype_POLY)) {
        c->value_type=ctype_POLY;
        c->value.v=new_POLY();
    }
    if (c->value_type!=ctype_POLY) {
        #Error: "(get_POLY) context %s is not a polynomial" i_context
        return NULL;
    }
    return (POLY *)c->value.v;
}
LUT *get_LUT_quiet(char *i_context) {
    node *c=Context;
    float *array_entry;
    if ((i_context[0]=='/')||(i_context[0]==':')) {
        c=Ctree;
    }
    if (!(resolve_context(i_context,&c,&array_entry))) {
        return NULL;
    }
    return (LUT *)c->value;
}
int context_print_path(Tcl_Interp *interp,context *c) {
    if (c->parent) context_print_path(interp,c->parent);
    Tcl_AppendElement(interp,c->name);
}
static int
copy_ctree_structure(Tcl_Interp *interp,char *target,char *key,char *argv[]) {
    context *s;
    if (!(resolve_context(key,&s,NULL))) {
        #Error: "Can't find structure %s" key
        return TCL_ERROR;
    }
    int i;
    for (i=0;i<s->num_of_children;i++) {
        char *field=s->children[i]->name;
        char *type=s->children[i]->value.v;
        char buffer[1024];
        sprintf(buffer,"@ %s/%s exists!",target,field);
        Tcl_Eval(interp,buffer);
        sprintf(buffer,"@ %s/%s = %s %s",target,field,type,argv[i+4]);
        Tcl_Eval(interp,buffer);
    }
    return TCL_OK;
}
void delete_context(context *c) {
    struct rusage* memory = malloc(sizeof(struct rusage));
    getrusage(RUSAGE_SELF, memory);
    if (c->value_type==ctype_LUT) {
        delete_array((LUT *)c->value.v);
        free(c);
        return;
    }
    ordinal size=c->num_of_children;
    ordinal i;
    #Info: "Deleting context %s (%d children) Mem=[eng %ld B]" c->name size memory->ru_maxrss
    for (i=0;i<size;i++) delete_context(c->children[i]);
    if (c->value_type==ctype_string) {
        free(c->value.v);
    }
    free(c);
}
void delete_array(LUT *a) {
    if (a->content) free(a->content);
    //    if (a->hit) free(a->hit);
    //    if (a->hit_bytecode) free(a->hit_bytecode);
    if (a->LIT) free(a->LIT);
    free(a);
}
void pat_front(PAT *p,vector_float *properties) {
    ordinal i,ii,j;
    if (properties->num_of!=p->properties->num_of) {
        #Error: "Tried to match front to PAT with incompatible number of properties."
        exit(1);
    }
    /// Initial filtration gets rid of all but the top 1000 matching circuits
    //Asses how many points meet the spec
    int num_of_th=0;
    for (i=0;i<p->properties->num_of;i++) if (isfinite(properties->content[i])) num_of_th++;
    for (i=0;i<p->properties->num_of;i++) properties->content[i]=p->factors->content[i]*properties->content[i];
    int histogram[128];
    for (j=0;j<128;j++) histogram[j]=0;
    for (i=0;i<p->content->num_of;i++) {
        int num_of_th_met=0;
        for (j=0;j<p->properties->num_of;j++) if (isfinite(properties->content[j])) if (p->content->content[i]->properties->content[j]>properties->content[j]) num_of_th_met++;
        histogram[num_of_th_met]++;
    }	
    // Determine how many thresholds should be met to make it to the Specific Pareto Analysis
    int collection=0;
    int criterion=num_of_th;
    for (;(criterion>=0)&&(collection<1000);criterion--) collection+=histogram[criterion];
    for (i=0;i<p->content->num_of;i++) {
        int num_of_th_met=0;
        for (j=0;j<p->properties->num_of;j++) if (isfinite(properties->content[j])) if (p->content->content[i]->properties->content[j]>properties->content[j]) num_of_th_met++;
        if (num_of_th_met<=criterion) p->content->content[i]->flags|=1;
    }	
    #Dinfo: "Performing Specific Pareto Analysis on %ld circuits. To qualify, a circuit must meet %d spec criteria" collection criterion
    // Negate all properties that are "less is better"
    ordinal volume=collection;
    for (i=0;i<p->content->num_of;i++) {
        if (p->content->content[i]->flags) continue;
        for (ii=0;ii<p->content->num_of;ii++) {
            if (i==ii) continue;
            if (p->content->content[ii]->flags) continue;
            int dominates=1;
            int significantly_better=0;
            int dominated=1;
            int significantly_worse=0;
            for (j=0;j<p->properties->num_of;j++) {
                float TH=properties->content[j];
                float P=p->content->content[i]->properties->content[j];
                float Q=p->content->content[ii]->properties->content[j];
                // Don't check properties that are "don't cared" in the spec
                if (isnan(TH)) continue;
                
                //Partial property record - should be rare
                if (isnan(Q))  {
                    // This entry can't dominate ones that have properties that are missing from it.
                    if (!(isnan(P))) dominates=0;
                    continue;
                }
                if (isnan(P)) continue;
                if (isnan(P)) {
                    // This entry can't be dominated by ones that are missing properties it has.
                    if (!(isnan(Q))) dominated=0;
                    continue;
                } 
                // end of partial record
                
                // Here's where the spec matters:
                //   If both entries excede the threshold in the spec, 
                //   then this property cannot justify the higher entry and can't be used to turn off one of the domination flags
                if (isinf(TH)==0) {
                    #Dinfo: "%d,%d: TH %d: %g %g %g" i ii j TH P Q
                    if (Q>TH) Q=TH;
                    if (P>TH) P=TH;
                }    
                #Dinfo: "%d,%d: Comparing %d: %g %g" i ii j P Q
                if (Q>P) dominated=0;
                if (Q<P) dominates=0;	    
		if (!(dominated||dominates)) break;

            }
            if (dominated) {
                if (!(p->content->content[ii]->flags)) {
                    volume--;
                    #Dinfo: "%d Dominated %ld left" ii volume
                }
                p->content->content[ii]->flags|=1;
            }    
            if (dominates) {
                if (!(p->content->content[i]->flags)) {
                    volume--;
                    #Dinfo: "%d Dominated %ld left" i volume
                }
                p->content->content[i]->flags|=1;
            }    
        }
    }
}
ordinal add_pat_entry(PAT *p,vector_float *sizes,vector_float *properties) {
    ordinal i,j;
    if (sizes->num_of!=p->sizes->num_of) {
        #Error: "Tried to add an entry to PAT with incompatible number of sizes."
        return(-2);
    }
    if (properties->num_of!=p->properties->num_of) {
        #Error: "Tried to add an entry to PAT with incompatible number of properties: PAT has %d property, but the entry has %d" p->properties->num_of properties->num_of
	exit(1);
        return(-2);
    }
    // Negate all properties that are "less is better"
    for (i=0;i<p->properties->num_of;i++) properties->content[i]=p->factors->content[i]*properties->content[i];
    for (i=0;i<p->content->num_of;i++) {
        int dominates=1;
        int significantly_better=0;
        int dominated=1;
        int significantly_worse=0;
        for (j=0;j<p->properties->num_of;j++) {
            if (isnan(properties->content[j])) {
                // This entry can't dominate ones that have properties that are missing from it.
                if (!(isnan(p->content->content[i]->properties->content[j]))) dominates=0;
                continue;
            }	
            if (isnan(p->content->content[i]->properties->content[j])) {
                // This entry can't be dominated by ones that are missing properties it has.
                if (!(isnan(properties->content[j]))) dominated=0;
                continue;
            } 
            if (properties->content[j]>p->content->content[i]->properties->content[j]) dominated=0;
            if (properties->content[j]-p->margins->content[j]>p->content->content[i]->properties->content[j]) significantly_better=1;
            if (properties->content[j]<p->content->content[i]->properties->content[j]) dominates=0;
            if (properties->content[j]+p->margins->content[j]<p->content->content[i]->properties->content[j]) significantly_worse=1;
	    if (!(dominated||dominates)) break;
        }
        if (dominated) {
            return(-1);
        }    
        // If this older entry is dominated by the new one, delete it. Deleting an entry puts the last one in its place. 
        // Don't move on until you cleared the last entry that was put in place, hence the i--.
        if (dominates&&significantly_better) {
            delete_entry_vector_pointer_PAT_entry(p->content,i--);
        }    
    }
    
    PAT_entry *pe=(PAT_entry *)malloc(sizeof(PAT_entry));
    pe->id=p->id_counter++;
    pe->flags=0;
    pe->sizes=new_vector_float();
    for (i=0;i<sizes->num_of;i++) add_entry_vector_float(pe->sizes,sizes->content[i]);
    pe->properties=new_vector_float();
    for (i=0;i<properties->num_of;i++) add_entry_vector_float(pe->properties,properties->content[i]);
    add_entry_vector_pointer_PAT_entry(p->content,pe);
    return(p->content->num_of);
}

ordinal add_pat_array(PAT *p,float *sizes,float *properties) {
    ordinal i,j;
    // Negate all properties that are "less is better"
    for (i=0;i<p->properties->num_of;i++) properties[i]=p->factors->content[i]*properties[i];
    for (i=0;i<p->content->num_of;i++) {
        int dominates=1;
        int significantly_better=0;
        int dominated=1;
        int significantly_worse=0;
        for (j=0;j<p->properties->num_of;j++) {
            if (isnan(properties[j])) {
                // This entry can't dominate ones that have properties that are missing from it.
                if (!(isnan(p->content->content[i]->properties->content[j]))) dominates=0;
                continue;
            }	
            if (isnan(p->content->content[i]->properties->content[j])) {
                // This entry can't be dominated by ones that are missing properties it has.
                if (!(isnan(properties[j]))) dominated=0;
                continue;
            } 
            if (properties[j]>p->content->content[i]->properties->content[j]) dominated=0;
            if (properties[j]-p->margins->content[j]>p->content->content[i]->properties->content[j]) significantly_better=1;
            if (properties[j]<p->content->content[i]->properties->content[j]) dominates=0;
            if (properties[j]+p->margins->content[j]<p->content->content[i]->properties->content[j]) significantly_worse=1;
	    if (!(dominated||dominates)) break;
        }
        if (dominated) {
            return(-1);
        }    
        // If this older entry is dominated by the new one, delete it. Deleting an entry puts the last one in its place. 
        // Don't move on until you cleared the last entry that was put in place, hence the i--.
        if (dominates&&significantly_better) {
            delete_entry_vector_pointer_PAT_entry(p->content,i--);
        }    
    }
    
    PAT_entry *pe=(PAT_entry *)malloc(sizeof(PAT_entry));
    pe->id=p->id_counter++;
    pe->flags=0;
    pe->sizes=new_vector_float();
    for (i=0;i<p->sizes->num_of;i++) add_entry_vector_float(pe->sizes,sizes[i]);
    pe->properties=new_vector_float();
    for (i=0;i<p->properties->num_of;i++) add_entry_vector_float(pe->properties,properties[i]);
    add_entry_vector_pointer_PAT_entry(p->content,pe);
    return(p->content->num_of);
}
float calc_POLY(POLY *p) {
    ordinal i=0;
    int next_is_coeff=1;
    float total=0;
    FC SO;
    #Dinfo: "POLY %x = %s" p p->expression
    for (i=0;i<p->polynomial->num_of;i++) {
        SO.F=get_entry_vector_float(p->polynomial,i);
        next_is_coeff=1;
        float term=0;
        while ((SO.P)&&(i<p->polynomial->num_of)) {
            if (next_is_coeff) {
                term=SO.F;
                #Dinfo: "POLY %x const=%g" p term
                next_is_coeff=0;
                i++;
                if (i<p->polynomial->num_of) SO.F=get_entry_vector_float(p->polynomial,i);
                continue;
            }
            float var=*((float *)SO.P);
            #Dinfo: "POLY %x var %x=%g" p SO.P var
            term*=var;
            i++;
            if (i<p->polynomial->num_of) SO.F=get_entry_vector_float(p->polynomial,i);
        }
        total+=term;
    }
    float retval=total;
    #Dinfo: "POLY %x total=%g" p total
    if (p->denom) {
        retval/=calc_POLY(p->denom);
        #Dinfo: "POLY %x divided to total=%g" p retval
    }
    return(retval);
}
float derive_POLY(POLY *p,void *by_var) {
    ordinal i=0;
    int next_is_coeff=1;
    float total=0;
    FC SO;
    for (i=0;i<p->polynomial->num_of;i++) {
        SO.F=get_entry_vector_float(p->polynomial,i);
        next_is_coeff=1;
        float term=0;
        int num_of_by_var=0;
        while ((SO.P)&&(i<p->polynomial->num_of)) {
            if (next_is_coeff) {
                term=SO.F;
                next_is_coeff=0;
                i++;
                if (i<p->polynomial->num_of) SO.F=get_entry_vector_float(p->polynomial,i);
                continue;
            }
            if (SO.P==by_var) {
                num_of_by_var++;
                if (num_of_by_var==1) {
                    i++;
                    if (i<p->polynomial->num_of) SO.F=get_entry_vector_float(p->polynomial,i);
                    continue;
                }
            }
            float var=*((float *)SO.P);
            term*=var;
            i++;
            if (i<p->polynomial->num_of) SO.F=get_entry_vector_float(p->polynomial,i);
        }
        total+=term*num_of_by_var;
    }
    float retval=total;
    #Dinfo: "derive %x/%x total=%g" p by_var total
    if (p->denom) {
        float nom=calc_POLY(p);
        #Dinfo: "derive %x nom=%g" p nom
        float denom=calc_POLY(p->denom);
        #Dinfo: "derive %x denom=%g" p denom
        float d_denom=derive_POLY(p->denom,by_var);
        #Dinfo: "derive %x d_denom=%g" p d_denom
        retval=(total*denom-nom*d_denom)/(denom*denom);	
        #Dinfo: "derive %x retval=(total*denom-nom*d_denom)/(denom*denom)=%g" p retval
    }
    return(retval);
}
float root_POLY(POLY *p,void *by_var,float init) {
    float total=init;
    float *by=(float *)by_var;
    float original_value=*by;
    *by=total;
    float dist=calc_POLY(p);
    while (fabs(dist)>1e-20) {
        total-=dist/derive_POLY(p,by_var);
        *by=total;
        dist=calc_POLY(p);
    }
    float retval=total;
    *by=original_value;
    return(retval);
}
float imp_derive_POLY(POLY *p,void *by_var,void *root_var,float init) {
    float root_value=root_POLY(p,root_var,init);
    float *root=(float *)root_var;
    float original_value=*root;
    *root=root_value;
    float nom=derive_POLY(p,by_var);
    float denom=derive_POLY(p,root_var);
    *root=original_value;
    float retval=-nom/denom;
    return(retval);
}
int compare_pat_graph_pixels(const void *i, const void *j) {
    PAT_graph_pixel *I=(PAT_graph_pixel *)i;
    PAT_graph_pixel *J=(PAT_graph_pixel *)j;
    if (I->x<J->x) return -1;
    if (I->x==J->x) return 0;
    return 1;
}
#define PAT_GRAPH_WIDTH 512
#define PAT_GRAPH_HEIGHT 512
void pat_graph(FILE *O,PAT *p,int x,int y) {
    int i;
    vector_float *properties=new_vector_float();
    for (i=0;i<p->properties->num_of;i++) if ((i==x)||(i==y)) add_entry_vector_float(properties,INFINITY); else add_entry_vector_float(properties,NAN);
    for (i=0;i<p->content->num_of;i++) p->content->content[i]->flags<<=1;
    pat_front(p,properties);
    free(properties);
    int size=0;
    for (i=0;i<p->content->num_of;i++) {
        if (p->content->content[i]->flags) continue;
	size++;
    }
    PAT_graph_pixel *g=(PAT_graph_pixel *)malloc(sizeof(PAT_graph_pixel)*size);
    int j=0;
    for (i=0;i<p->content->num_of;i++) {
        if (p->content->content[i]->flags) continue;
	g[j].x=p->factors->content[x]*p->content->content[i]->properties->content[x];
	g[j].y=p->factors->content[y]*p->content->content[i]->properties->content[y];
        j++;
    }
    qsort(g,size,sizeof(PAT_graph_pixel),compare_pat_graph_pixels);
    for (i=0;i<size;i++) fprintf(O,"%g,%g\n",g[i].x,g[i].y);
    // Undo
    for (i=0;i<p->content->num_of;i++) p->content->content[i]->flags>>=1;
}
void pat_unique(PAT *p,float f) {
    ordinal i,j,k;
    vector_float *min=new_vector_float();
    vector_float *max=new_vector_float();
    for (i=0;i<p->properties->num_of;i++) add_entry_vector_float(min,p->content->content[0]->properties->content[i]);
    for (i=0;i<p->properties->num_of;i++) add_entry_vector_float(max,p->content->content[0]->properties->content[i]);
    for (i=0;i<p->content->num_of;i++) for (j=0;j<p->properties->num_of;j++) {
    	if (p->content->content[i]->properties->content[j]>max->content[j]) max->content[j]=p->content->content[i]->properties->content[j];
    	if (p->content->content[i]->properties->content[j]<min->content[j]) min->content[j]=p->content->content[i]->properties->content[j];
    }
    vector_float *interval=new_vector_float();
    for (i=0;i<p->properties->num_of;i++) {
        add_entry_vector_float(interval,(max->content[i]-min->content[i])/f);
//	#Info: "Interval %s: (%g-%g)/%g=%g" p->properties->content[i] max->content[i] min->content[i] f interval->content[i] 
    }
    for (i=0;i<p->content->num_of;i++) for (j=i+1;j<p->content->num_of;j++) {
        int same=1;
	for (k=0;k<p->properties->num_of;k++) {
	    if (fabs(p->content->content[i]->properties->content[k]-p->content->content[j]->properties->content[k])>interval->content[k]) {
	        same=0;
		break;
	    }
	}
	if (same) {
	 //   for (k=0;k<p->properties->num_of;k++) {
	  //      float diff=fabs(p->content->content[i]->properties->content[k]-p->content->content[j]->properties->content[k]);
	  //      #Info: "Same %s: %g-%g=%g<%g" p->properties->content[k] p->content->content[i]->properties->content[k] p->content->content[j]->properties->content[k] diff interval->content[k]
	//    }
	    delete_entry_vector_pointer_PAT_entry(p->content,j--);
	}    
    }
}
void pat_stars(PAT *p) {
    ordinal i,j,k;
    vector_float *max=new_vector_float();
    vector_int *indices=new_vector_int();
    for (i=0;i<p->properties->num_of;i++) add_entry_vector_float(max,p->content->content[0]->properties->content[i]);
    for (i=0;i<p->properties->num_of;i++) add_entry_vector_int(indices,0);
    for (i=0;i<p->content->num_of;i++) for (j=0;j<p->properties->num_of;j++) {
    	if (p->content->content[i]->properties->content[j]<=max->content[j]) continue;
	max->content[j]=p->content->content[i]->properties->content[j];
	indices->content[j]=p->content->content[i]->id;
    }
    for (i=0;i<p->content->num_of;i++) {
        int star=0;
        for (j=0;j<p->properties->num_of;j++) if (indices->content[j]==p->content->content[i]->id) star=1;
	if (star) continue;
	delete_entry_vector_pointer_PAT_entry(p->content,i--);
    }	
}
char *expr2polish(char *expr_in,int toplevel) {
    int i=0;
    if (expr_in[0]==0) {
        #Error: "Empty expression!"
    }
    char *expr=(char *)malloc(sizeof(char)*(1+strlen(expr_in)));
    for (i=0;expr_in[i];i++) expr[i]=expr_in[i];
    expr[i]=0;
    int brace_count;
    int weakest_degree=3;
    int weakest=-1;
    int peelme=1;
    while (peelme) {
        brace_count=0;
        for (i=0;expr[i];i++) {
            if (expr[i]=='(') brace_count++;
            if (brace_count==0) peelme=0;
            if (expr[i]==')') brace_count--;
        }
        if (peelme) {
            expr[i-1]=0;
            expr=&(expr[1]);   
        }
    }
    brace_count=0;
    for (i=0;expr[i];i++) {
        if (expr[i]=='(') brace_count++;
        if (brace_count==0) {
            if ((expr[i]=='-')||(expr[i]=='+')) if (weakest_degree>=1) {
                weakest_degree=1;
                weakest=i;
            }
            if ((expr[i]=='*')||(expr[i]=='/')) if (weakest_degree>=2) {
                weakest_degree=2;
                weakest=i;
            }
        }
        if (expr[i]==')') brace_count--;
    }
    if (weakest==-1) {
        return(expr);
    }
    if (weakest==0) {
        char op=expr[weakest];
        char *post=expr2polish(&(expr[weakest+1]),0);
        //free(expr);
        char *result=(char *)malloc(sizeof(char)*(16+strlen(post)));
	if (toplevel) {
            if ((op=='-')||(op=='+')) sprintf(result,"%c 0 %s",op,post);
            if ((op=='/')||(op=='*')) sprintf(result,"%c 1 %s",op,post);
	} else {
            if ((op=='-')||(op=='+')) sprintf(result,"{%c 0 %s}",op,post);
            if ((op=='/')||(op=='*')) sprintf(result,"{%c 1 %s}",op,post);
	}
        return(result);
    }
    char op=expr[weakest];
    expr[weakest]=0;
    char *pre=expr2polish(expr,0);
    char *post=expr2polish(&(expr[weakest+1]),0);
    // free(expr);
    char *result=(char *)malloc(sizeof(char)*(16+strlen(pre)+strlen(post)));
    if (toplevel) {
        sprintf(result,"%c %s %s",op,pre,post);
    } else {
        sprintf(result,"{%c %s %s}",op,pre,post);
    }	
    return(result);
}
char *peel(char *expr_in,int toplevel) {
    int i=0;
    char *expr=(char *)malloc(sizeof(char)*(1+strlen(expr_in)));
    for (i=0;expr_in[i];i++) expr[i]=expr_in[i];
    expr[i]=0;
    int brace_count;
    int weakest_degree=3;
    int weakest=-1;
    int peelme=1;
    while (peelme) {
        brace_count=0;
        for (i=0;expr[i];i++) {
            if (expr[i]=='(') brace_count++;
            if (brace_count==0) peelme=0;
            if (expr[i]==')') brace_count--;
        }
        if (peelme) {
            expr[i-1]=0;
            expr=&(expr[1]);   
        }
    }
    return(expr);
}

static int
tcl_polish (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    if (argc!=2) {
        #Error: "%s requires a no-spaces expression"
	return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    Tcl_AppendElement(interp,expr2polish(argv[1],1));
    return TCL_OK;	
}
static int
tcl_peel (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    if (argc!=2) {
        #Error: "%s requires a no-spaces expression"
	return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    Tcl_AppendElement(interp,peel(argv[1],1));
    return TCL_OK;	
}

static int
tcl_ctree (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc<2) {
        #Error: "(ctree) got no context"
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    context *c=Context;
    float *array_entry;
    if ((argv[1][0]=='/')||(argv[1][0]==':')) {
        c=ctree;
    }
    // "exists" and "create" require an exception to the rule other commands require, that the context given as 1st arg must be valid.
    if (argc==3) {
        if ((strcmp(argv[2],"exists")==0)||(strcmp(argv[2],"?")==0)||(strcmp(argv[2],"exists?")==0)) {
            tcl_append_int(interp,resolve_context(argv[1],&c,&array_entry));
            return TCL_OK;
        }
        if ((strcmp(argv[2],"!")==0)||(strcmp(argv[2],"create")==0)||(strcmp(argv[2],"exists!")==0)) {
            create_context(argv[1]);
            return TCL_OK;
        }
    }
    if (!(resolve_context(argv[1],&c,&array_entry))) {
        //        #Error: "(ctree) no such context %s" argv[1]
        //        return TCL_ERROR;
        create_context(argv[1]);
        resolve_context(argv[1],&c,&array_entry);
    }
    if (argc==2) {
        // simple value return
        if (c->value_type==ctype_POLY) {
            tcl_append_float(interp,calc_POLY(c->value.v));
            return TCL_OK;
        }
        if (c->value_type==ctype_void) {
            return TCL_OK;
        }
        if (c->value_type==ctype_string) {
            Tcl_AppendElement(interp,(char *)c->value.v);
            return TCL_OK;
        }
        if (c->value_type==ctype_real) {
            tcl_append_float(interp,c->value.s);
            return TCL_OK;
        }
        if (c->value_type==ctype_integer) {
            tcl_append_int(interp,c->value.o);
            return TCL_OK;
        }
        if (c->value_type==ctype_LUT) {
            if (array_entry==NULL) {
                #Error: "(ctree) invalid array access %s" argv[1]
                return TCL_ERROR;
            }
            tcl_append_float(interp,*array_entry);
            return TCL_OK;
        }
        if (c->value_type==ctype_PAT) {
            PAT *p=(PAT *)c->value.v;
            tcl_append_int(interp,p->content->num_of);
            return TCL_OK;
        }
        #Error: "(ctree) ccontext has unrecognized value_type. (%d)" c->value_type
        return TCL_ERROR;
    }
    if (strcmp(argv[2],"type")==0) {
        tcl_append_int(interp,c->value_type);
        return TCL_OK;
    }
    if (strcmp(argv[2],"expression")==0) {
        if (c->value_type!=ctype_POLY) {
            #Error: "(ctree) The expression command is to be used with a polynomial only."
            return TCL_ERROR;
        }
        if (argc!=3) {
            #Error: "(ctree) The expression command takes no arguments"
            return TCL_ERROR;
        }
        if (c->value_type!=ctype_POLY) {
            #Error: "(ctree) The expression command is to be used with a polynomial only."
            return TCL_ERROR;
        }
        POLY *p=(POLY *)c->value.v;
        Tcl_AppendElement(interp,p->expression);
        return TCL_OK;
    }	
    if (strcmp(argv[2],"denom")==0) {
        if (c->value_type!=ctype_POLY) {
            #Error: "(ctree) The denom command is to be used with a polynomial only."
            return TCL_ERROR;
        }
        if (argc<4) {
            #Error: "(ctree) The denom command requires a polynomial"
            return TCL_ERROR;
        }
        POLY *nom=get_POLY(argv[1]);
        nom->denom=get_POLY(argv[3]);
        return TCL_OK;
    }
    if (strcmp(argv[2],"derive")==0) {
        if (c->value_type!=ctype_POLY) {
            #Error: "(ctree) The derive command is to be used with a polynomial only."
            return TCL_ERROR;
        }
        if (argc<4) {
            #Error: "(ctree) The derive command requires a by-variable"
            return TCL_ERROR;
        }
        context *by=Context;
        float *array_entry;
        if ((argv[3][0]=='/')||(argv[3][0]==':')) {
            by=ctree;
        }
        float *array_context;
        if (!resolve_context(argv[3],&by,&array_context)) {
            #Warning: "(ctree) The derive command was given a non-existent context %s" argv[3]
            tcl_append_float(interp,0);
            return TCL_OK;
        }
        void *by_var=&(by->value.s);
        tcl_append_float(interp,derive_POLY(c->value.v,by_var));
        return TCL_OK;
    }
    if (strcmp(argv[2],"root")==0) {
        if (c->value_type!=ctype_POLY) {
            #Error: "(ctree) The root command is to be used with a polynomial only."
            return TCL_ERROR;
        }
        if (argc<4) {
            #Error: "(ctree) The root command requires a by-variable"
            return TCL_ERROR;
        }
        float init=0;
        if (argc==5) init=strtod(argv[4],NULL);
        context *by=Context;
        float *array_entry;
        if ((argv[3][0]=='/')||(argv[3][0]==':')) {
            by=ctree;
        }
        float *array_context;
        if (!resolve_context(argv[3],&by,&array_context)) {
            #Warning: "(ctree) The root command was given a non-existent context %s" argv[3]
            tcl_append_float(interp,0);
            return TCL_OK;
        }
        void *by_var=&(by->value.s);
        tcl_append_float(interp,root_POLY(c->value.v,by_var,init));
        return TCL_OK;
    }
    if (strcmp(argv[2],"imp_derive")==0) {
        if (c->value_type!=ctype_POLY) {
            #Error: "(ctree) The root command is to be used with a polynomial only."
            return TCL_ERROR;
        }
        if (argc<5) {
            #Error: "(ctree) The implicit derivative command requires two by-variables"
            return TCL_ERROR;
        }
        float init=0;
        if (argc==6) init=strtod(argv[5],NULL);
        float *array_context;
        context *by=Context;
        if ((argv[3][0]=='/')||(argv[3][0]==':')) {
            by=ctree;
        }
        if (!resolve_context(argv[3],&by,&array_context)) {
            #Warning: "(ctree) The root command was given a non-existent context %s" argv[3]
            tcl_append_float(interp,0);
            return TCL_OK;
        }
        void *by_var=&(by->value.s);
        context *root=Context;
        if ((argv[4][0]=='/')||(argv[4][0]==':')) {
            root=ctree;
        }
        if (!resolve_context(argv[4],&root,&array_context)) {
            #Warning: "(ctree) The root command was given a non-existent context %s" argv[4]
            tcl_append_float(interp,0);
            return TCL_OK;
        }
        void *root_var=&(root->value.s);
        tcl_append_float(interp,imp_derive_POLY(c->value.v,by_var,root_var,init));
        return TCL_OK;
    }
    if (strcmp(argv[2],"PAT")==0) {
        if (c->value_type!=ctype_PAT) {
            #Error: "(ctree) The PAT command is to be used with a pareto-associative table only. Use double parentheses to declare one: @ PAT((size1,size2|prop1,prop2)) !"
            return TCL_ERROR;
        }
        if (argc<4) {
            #Error: "(ctree) The PAT command requires a sub-command: size, index, delete, foreach"
            return TCL_ERROR;
        }
        PAT *p=(PAT *)c->value.v;
        if (strcmp(argv[3],"size")==0) {
            tcl_append_int(interp,p->content->num_of);
            return TCL_OK;
        }
        if (strcmp(argv[3],"properties")==0) {
            ordinal i;
            for (i=0;i<p->properties->num_of;i++) Tcl_AppendElement(interp,p->properties->content[i]);
            return TCL_OK;
        }
        if (strcmp(argv[3],"sizes")==0) {
            ordinal i;
            for (i=0;i<p->sizes->num_of;i++) Tcl_AppendElement(interp,p->sizes->content[i]);
            return TCL_OK;
        }
        if (strcmp(argv[3],"margins")==0) {
            ordinal i;
            for (i=0;i<p->margins->num_of;i++) tcl_append_float(interp,p->margins->content[i]);
            return TCL_OK;
        }
        if (strcmp(argv[3],"index")==0) {
            if (argc!=5) {
                #Error: "(ctree) The PAT index sub-command requires an index"
                return TCL_ERROR;
            }
            ordinal i,j;
            j=atoi(argv[4]);
            for (i=0;i<p->sizes->num_of;i++) tcl_append_float(interp,p->content->content[j]->sizes->content[i]);
            for (i=0;i<p->properties->num_of;i++) {
                float value=p->factors->content[i]*p->content->content[j]->properties->content[i];
                tcl_append_float(interp,value);
            }	
            return TCL_OK;
        }
       if (strcmp(argv[3],"unique")==0) {
            if (argc!=5) {
                #Error: "(ctree) The PAT unique sub-command requires a factor"
                return TCL_ERROR;
            }
	    pat_unique(p,atof(argv[4]));
            return TCL_OK;
        }
        if (strcmp(argv[3],"id")==0) {
            if (argc!=5) {
                #Error: "(ctree) The PAT id sub-command requires an index"
                return TCL_ERROR;
            }
	    tcl_append_int(interp,p->content->content[atoi(argv[4])]->id);
            return TCL_OK;
        }
        if (strcmp(argv[3],"graph")==0) {
            if (argc!=7) {
                #Error: "(ctree) The PAT graph sub-command requires an output file, x and y axes"
                return TCL_ERROR;
            }
	    int i,x=-1,y=-1;
	    for (i=0;i<p->properties->num_of;i++) if (strcmp(p->properties->content[i],argv[5])==0) x=i;
	    for (i=0;i<p->properties->num_of;i++) if (strcmp(p->properties->content[i],argv[6])==0) y=i;
	    if (x==-1) {
	        #Error: "No such property %s in PAT %s" argv[5] c->name;
		return TCL_ERROR;
	    }
	    if (y==-1) {
	        #Error: "No such property %s in PAT %s" argv[6] c->name;
		return TCL_ERROR;
	    }
	    FILE *O=fopen(argv[4],"w");
	    fprintf(O,"%s,%s\n",argv[5],argv[6]);
	    pat_graph(O,p,x,y);
	    fclose(O);
            return TCL_OK;
        }
        if (strcmp(argv[3],"delete")==0) {
            if (argc!=5) {
                #Error: "(ctree) The PAT delete sub-command requires an index"
                return TCL_ERROR;
            }
            ordinal j;
            j=atoi(argv[4]);
            delete_entry_vector_pointer_PAT_entry(p->content,j);
            return TCL_OK;
        }
        if (strcmp(argv[3],"stars")==0) {
            if (argc!=4) {
                #Error: "(ctree) The PAT stars sub-command requires no more arguments"
                return TCL_ERROR;
            }
	    pat_stars(p);
            return TCL_OK;
        }
        #Error: "(ctree) Unrecognized PAT sub-command %s. It requires a sub-command: size, index, delete, foreach" argv[3]
        return TCL_ERROR;
    }
    if (strcmp(argv[2],">>>")==0) {
        if (c->value_type!=ctype_PAT) {
            #Error: "(ctree) The >>> operator is to be used with a pareto-associative table only. Use double parentheses to declare one: @ PAT((size1,size2|prop1,prop2)) !"
            return TCL_ERROR;
        }
        if (argc!=4) {
            #Error: "(ctree) The >>> operator requires a list of properties."
            return TCL_ERROR;
        }
        ordinal i;
	PAT *p=(PAT *)c->value.v;
	if (strcmp(argv[3],"reset")==0) {
            for (i=0;i<p->content->num_of;i++) p->content->content[i]->flags=0;
            return TCL_OK;
	}
	if (strcmp(argv[3],"undo")==0) {
            for (i=0;i<p->content->num_of;i++) p->content->content[i]->flags>>=1;
            return TCL_OK;
	}
        int ARGC;
        char **ARGV;
        Tcl_SplitList(interp,argv[3],&ARGC,&ARGV);
        vector_float *properties=new_vector_float();
        for (i=0;i<ARGC;i++) add_entry_vector_float(properties,atof(ARGV[i]));
        free(ARGV);
	for (i=0;i<p->content->num_of;i++) p->content->content[i]->flags<<=1;
        pat_front(p,properties);
        for (i=0;i<p->content->num_of;i++) if (!(p->content->content[i]->flags)) tcl_append_int(interp,i);
        return TCL_OK;
    }
    if (strcmp(argv[2],"<<<")==0) {
        if (c->value_type!=ctype_PAT) {
            #Error: "(ctree) The <<< operator is to be used with a pareto-associative table only. Use double parentheses to declare one: @ PAT((size1,size2|prop1,prop2)) !"
            return TCL_ERROR;
        }
        if (argc!=5) {
            #Error: "(ctree) The <<< operator requires a list of sizes and a list of properties."
            return TCL_ERROR;
        }
        int ARGC;
        char **ARGV;
        Tcl_SplitList(interp,argv[3],&ARGC,&ARGV);
        vector_float *sizes=new_vector_float();
        int i;
        for (i=0;i<ARGC;i++) add_entry_vector_float(sizes,atof(ARGV[i]));
        free(ARGV);
        Tcl_SplitList(interp,argv[4],&ARGC,&ARGV);
        vector_float *properties=new_vector_float();
        for (i=0;i<ARGC;i++) add_entry_vector_float(properties,atof(ARGV[i]));
        free(ARGV);
        tcl_append_int(interp,add_pat_entry((PAT *)c->value.v,sizes,properties));
        return TCL_OK;
    }
    if (strcmp(argv[2],"=")==0) {
        #Dinfo: "%s gets assignemnt" argv[1]
        if (argc==4) {
            if (c->value_type==ctype_POLY) {
                POLY *p=new_POLY();
                p->expression=strdup(argv[3]);
                link_POLY(p);
                c->value.v=p;
                return TCL_OK;
            }
            if (c->value_type==ctype_LUT) {
                if (array_entry==NULL) {
                    #Error: "(ctree) invalid array access %s" argv[1]
                    return TCL_ERROR;
                }
                *array_entry=atof(argv[3]);
                return TCL_OK;
            }
            if (strcmp(c->name,"POLY")==0) {
                POLY *p=new_POLY();
                p->expression=strdup(argv[3]);
                link_POLY(p);
                c->value.v=p;
                c->value_type=ctype_POLY;
                return TCL_OK;
            }
            c->value.s=atof(argv[3]);
            #Dinfo: "ASSIGNMENT %x=%s %g" &(c->value.s) argv[3] c->value.s
            //         #Warning: "%s is getting typed real (%x=%g)" c->name &(c->value.s) c->value.s
            c->value_type=ctype_real;
            return TCL_OK;
        }
        if (argc<5) {
            #Error: "(ctree) usage: @ <context> = [<type>] <value>"
            return TCL_ERROR;
        }
        if (strcmp(argv[3],"real")==0) {
            c->value.s=atof(argv[4]);
            c->value_type=ctype_real;
            return TCL_OK;
        }
        if (strcmp(argv[3],"integer")==0) {
            c->value.o=atol(argv[4]);
            c->value_type=ctype_integer;
            return TCL_OK;
        }
        if (strcmp(argv[3],"string")==0) {
            c->value.v=strdup(argv[4]);
            c->value_type=ctype_string;
            return TCL_OK;
        }
        return(copy_ctree_structure(interp,argv[1],argv[3],argv));	
    }
    if (strcmp(argv[2],"is_array")==0) {
        if (argc!=3) {
            #Error: "(ctree) usage: @ <context> is_array"
            return TCL_ERROR;
        }
        if (c->value_type==ctype_LUT) {
            tcl_append_int(interp,1);
        } else {
            tcl_append_int(interp,0);
        }
        return TCL_OK;
    }
    if (strcmp(argv[2],"delete")==0) {
        if (argc!=3) {
            #Error: "(ctree) usage: @ <context> delete"
            return TCL_ERROR;
        }
        context *d=c->parent;
        int i=0,j=0;
        for (i=0;i<d->num_of_children;i++) {
            if (d->children[i]=c) j++;
            if (j>=d->num_of_children) break;
            d->children[i]=d->children[j];
            j++;
        }
        d->num_of_children--;
        delete_context(c);
        Context=Ctree;
        return TCL_OK;
    }
    if (strcmp(argv[2],"cd")==0) {
        if (argc!=3) {
            #Error: "(ctree) usage: @ <context> cd"
            return TCL_ERROR;
        }
        Context=c;
        return TCL_OK;
    }
    if (strcmp(argv[2],"list")==0) {
        if (argc!=3) {
            #Error: "(ctree) usage: @ <context> list"
            return TCL_ERROR;
        }
        int i;
        for (i=0;i<c->num_of_children;i++) Tcl_AppendElement(interp,c->children[i]->name);
        return TCL_OK;
    }
    if (strcmp(argv[2],"foreach_child")==0) {
        if (argc!=5) {
            #Error: "(ctree) usage: @ <context> foreach_child <iterator> <code>"
            return TCL_ERROR;
        }
        int i;
        char buf[1024*1024];
        for (i=0;i<c->num_of_children;i++)  {
            sprintf(buf,"set %s %s",argv[3],c->children[i]->name);
            Tcl_Eval(interp,buf);
            Tcl_Eval(interp,argv[4]);
        }
        return TCL_OK;
    }
    if (strcmp(argv[2],"path")==0) {
        if (argc!=3) {
            #Error: "(ctree) usage: @ . path"
            return TCL_ERROR;
        }
        context_print_path(interp,c);
        return TCL_OK;
    }
    if (strcmp(argv[2],"save")==0) {
        if (argc!=4) {
            #Error: "(ctree) usage: @ <array context> save <filename>"
            return TCL_ERROR;
        }
        FILE *O=fopen(argv[3],"w");
        context_save(c,O);
        fclose(O);
        return TCL_OK;
    }
    if (strcmp(argv[2],"load")==0) {
        if (argc!=4) {
            #Error: "(ctree) usage: @ <array context> load <filename>"
            return TCL_ERROR;
        }
        open_to_read(argv[3]);
        context_load(c,0);
        done_reading();
        return TCL_OK;
    }
    if (strcmp(argv[2],"calc")==0) {
        if (c->value_type!=ctype_LUT) {
            #Error: "(ctree) @ calc requires an array context"
            return TCL_ERROR;
        }
        LUT *a=(LUT *)c->value.v;
        if (argc-3!=a->dim) {
            #Error: "(ctree) Array %s has %d dimentions. Can't interpolate with %d coordinates." a->name a->dim argc-3
            return TCL_ERROR;
        }
        int i;
        for (i=0;i<a->dim;i++) global_coord[i]=atof(argv[i+3]);
        tcl_append_float(interp,a->interpolate(a,global_coord));
        return TCL_OK;
    }
    #Error: "(ctree) unsupported command %s" argv[2]
    return TCL_ERROR;
}
static int
init_ip(int temp_port) {
    if (my_port) return 0;
    // Create the socket
    node_sock = socket(AF_INET, SOCK_STREAM, 0); 
    bzero(my_ip,HOSTNAME_SIZE);
    gethostname(my_ip,HOSTNAME_SIZE-1);
    struct hostent *h;
    int i;
    if((h=gethostbyname(my_ip)) == NULL) {
        sprintf(my_ip,"127.0.0.1");
    } else {
        // Converting 4 bytes to IP string
        int host_ip_int[4];
        for (i=0;i<4;i++) {
            host_ip_int[i]=(h->h_addr_list[0][i]+256)%256;
        }
        sprintf(my_ip,"%i.%i.%i.%i",host_ip_int[0],host_ip_int[1],host_ip_int[2],host_ip_int[3]);
    }
    // Reset the buffer content
    bzero((char *)&my_addr, sizeof(my_addr)); 
    // Make it an INET connection
    my_addr.sin_family = AF_INET;
    // Get the port
    my_addr.sin_port=htons(temp_port);
    // Any address allocated to this machine
    my_addr.sin_addr.s_addr = INADDR_ANY;
    // Don't give up if the port's busy. Find an available one
    while (bind(node_sock, &my_addr, sizeof(my_addr)) == -1){
        #Info: "Skipping unavailable port %d" temp_port
        temp_port++;
        my_addr.sin_port=htons(temp_port);
    }
    my_port=temp_port;
    #Info: "(%d) New node %s %d" getpid(),my_ip,my_port
    return TCL_OK;
}
static int
set_base_ip(char *host,int port) {
    // Getting IP address of host from its name
    struct hostent *h;
    int i;
    printf("Tryin to find host %s\n",host);
    if((h=gethostbyname(host)) == NULL) {
        printf("Host %s not found => using loopback address instead\n",host);
        sprintf(base_ip,"127.0.0.1");
    } else {
        // Converting 4 bytes to IP string
        int host_ip_int[4];
        for (i=0;i<4;i++) {
            host_ip_int[i]=(h->h_addr_list[0][i]+256)%256;
        }
        sprintf(base_ip,"%i.%i.%i.%i",host_ip_int[0],host_ip_int[1],host_ip_int[2],host_ip_int[3]);
        printf("Host %s found => using IP address %s\n",host,base_ip);
    }
    base_port=port;
    #Info: "(%d) Set base IP=%s port=%d" getpid(),base_ip,port
}
static int
network_update (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    char buffer[NETWORK_BEFFER_SIZE];
    struct sockaddr rem_addr; 
    int length = sizeof(rem_addr);
    signal(SIGCHLD, SIG_IGN);
    int I;
    while(1) {
        I=accept(node_sock, &rem_addr, &length);
        if (I!=-1) {
            break;
        }
    }
    char *rx=buffer;
    int i=read(I, buffer, NETWORK_BEFFER_SIZE);
    buffer[i]=0;
    if (buffer[0]=='!') {
        while (buffer[i-1]!='!') {
            i+=read(I, &(buffer[i]), NETWORK_BEFFER_SIZE);
            buffer[i]=0;
        }
        rx=&(buffer[1]);
        buffer[i-1]=0;
    }	
    #Info: "(%d) received: %s" getpid(),rx
    if (Tcl_Eval(interp,rx)==TCL_ERROR) {
        Tcl_Eval(interp,"puts $::errorInfo");
    }
    close(I);
    return TCL_OK;
}
static int network_wait_loop(Tcl_Interp *interp) {
    char buffer[NETWORK_BEFFER_SIZE];
    struct sockaddr_in addr;
    // Reset the buffer content
    bzero((char *)&addr, sizeof(addr)); 
    // Make it an INET connection
    addr.sin_family = AF_INET;
    // Get the port
    addr.sin_port=htons(my_port);
    // Any address allocated to this machine
    addr.sin_addr.s_addr = INADDR_ANY;
    #Info: "Node: %s %d" my_ip,my_port
    // Now LISTEN TO ME
    if (listen(node_sock, CLIENT_COUNT) == -1) {
        // or let me know you can't hear
        perror("Listen error");
        exit(1);
    }
    
    struct sockaddr rem_addr; 
    int length = sizeof(rem_addr);
    signal(SIGCHLD, SIG_IGN);
    Tcl_Eval(interp,"if {![info exists ::network_node_event_code]} {set ::network_node_event_code {}}");
    Tcl_Eval(interp,"set ::network_mode 1");
    // Start serving commands from nodes
    int cnt=0;
    network_loop=1;
    Tcl_LinkVar(interp,"::network_mode",&network_loop,TCL_LINK_INT);
    #Info: "(%d) Starting TCP event loop" getpid()
    while (network_loop) {
        Tcl_Eval(interp,"uplevel #0 $::network_node_event_code");
        int I=accept(node_sock, &rem_addr, &length);
        if (I==-1) {
            continue;
        }
        char *rx=buffer;
        int i=read(I, buffer, NETWORK_BEFFER_SIZE);
        buffer[i]=0;
        if (buffer[0]=='!') {
            while (buffer[i-1]!='!') {
                i+=read(I, &(buffer[i]), NETWORK_BEFFER_SIZE);
                buffer[i]=0;
            }
            rx=&(buffer[1]);
            buffer[i-1]=0;
        }	
        #Info: "(%d) received: %s" getpid(),rx
        if (Tcl_Eval(interp,rx)==TCL_ERROR) {
            Tcl_Eval(interp,"puts $::errorInfo");
        }
        close(I);
    }
    #Info: "(%d) Finished TCP event loop" getpid()
    return TCL_OK;
    
}
static int
network_mode (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if ((argc!=1)&&(argc!=3)) {
        #Error: "Usage: %s [<base-station> <base station port>]" argv[0]
    } 
    if (argc==3) {
        network_node_type=net_mode_node;
        set_base_ip(argv[1],atoi(argv[2]));
    }
    int i;
    init_ip(atoi(argv[2]));
    return(network_wait_loop(interp));
}
static int
start_network_node (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc!=3) {
        #Error: "Usage: %s <base-station> <base station port>" argv[0]
    }
    char buffer[NETWORK_BEFFER_SIZE];
    int i;
    // Create the socket
    node_sock = socket(AF_INET, SOCK_STREAM, 0); 
    // Getting IP address of host from its name
    set_base_ip(argv[1],atoi(argv[2]));
    bzero(my_ip,HOSTNAME_SIZE);
    gethostname(my_ip,HOSTNAME_SIZE-1);
    init_ip(atoi(argv[2]));
    #Info: "New node: %s %d" my_ip,my_port
    sprintf(buffer,"add_network_node %s %d",my_ip,my_port);
    send_task_to_base(buffer);
    struct sockaddr rem_addr; 
    int length = sizeof(rem_addr);
    signal(SIGCHLD, SIG_IGN);
    Tcl_Eval(interp,"if {![info exists ::network_node_event_code]} {set ::network_node_event_code {}}");
    // Start serving commands from BS
    network_loop=1;
    while (network_loop) {
        Tcl_Eval(interp,"uplevel #0 $::network_node_event_code");
        int I=accept(node_sock, &rem_addr, &length);
        if (I==-1) {
            continue;
        }
        
        int i=read(I, buffer, NETWORK_BEFFER_SIZE);
        buffer[i]=0;
        if (Tcl_Eval(interp,buffer)==TCL_ERROR) {
            Tcl_Eval(interp,"puts $::errorInfo");
        }
        close(I);
    }
    
    return TCL_OK;
}
static int
add_network_node (char *host,int port)
{
    struct hostent *h;
    network_node *n=network_node_root;
    char host_ip[32];
    network_node *new_network_node=(network_node *)malloc(sizeof(network_node));
    if((h=gethostbyname(host)) == NULL) {
        sprintf(new_network_node->host_ip,"127.0.0.1");
    } else {
        // Converting 4 bytes to IP string
        int host_ip_int[4],i;
        for (i=0;i<4;i++) {
            host_ip_int[i]=(h->h_addr_list[0][i]+256)%256;
        }
        sprintf(host_ip,"%i.%i.%i.%i",host_ip_int[0],host_ip_int[1],host_ip_int[2],host_ip_int[3]);
    }
    while (n) {
        if ((n->port==port)&&(strcmp(n->host_ip,host_ip)==0)) return(0);
        n=n->next;
    }
    sprintf(new_network_node->host_ip,"%s",host_ip);
    #Info: "New node: %s:%d" new_network_node->host_ip,port
    new_network_node->next=NULL;
    // Reset the buffer content
    new_network_node->port=port;
    new_network_node->last=NULL;
    
    // Insert the new network node to the list
    if (network_node_root==NULL) {
        network_node_root=new_network_node;
        return TCL_OK;
    }
    
    network_node *previous_network_node=network_node_root;
    while (previous_network_node->next) previous_network_node=previous_network_node->next;
    previous_network_node->next=new_network_node;
    new_network_node->last=previous_network_node;
    
    // Send all nodes the news
    n=network_node_root;
    char buffer[256];
    sprintf(buffer,"add_network_node %s %d",new_network_node->host_ip,port);
    while (n) {
        if ((n->port==port)&&(strcmp(n->host_ip,new_network_node->host_ip)==0)) {
            network_node *m=network_node_root;
            char buffer[256];
            while (m) {
                if ((m->port==port)&&(strcmp(m->host_ip,new_network_node->host_ip)==0)) {
                    m=m->next;
                    continue;
                }
                sprintf(buffer,"add_network_node %s %d",m->host_ip,m->port);
                tcp_send_no_fork(n,buffer);
                m=m->next;
            }
            n=n->next;
            continue;
        }    
        tcp_send_no_fork(n,buffer);
        n=n->next;
    }
    sprintf(buffer,"node_release");
    tcp_send_no_fork(new_network_node,buffer);
    return TCL_OK;
}
static int
node_release (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (network_node_type==net_mode_node) network_loop=0;
    return TCL_OK;
}
static int
tcl_add_network_node (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc!=3) {
        #Error: "Usage: %s <host> <port>" argv[0]
    }
    return (add_network_node(argv[1],atoi(argv[2])));
}
static int
tcp_send_no_fork(network_node *n,char *code) {
    // Starting the socket
    int sock=socket(AF_INET, SOCK_STREAM, 0);
    //Creating the message:
    char *msg=(char *)malloc(sizeof(char)*(strlen(code)+256));
    sprintf(msg,"!%s!",code);
    #Info: "(%d) sending %s to node %s %d" getpid(),msg,n->host_ip,n->port
    // Updating the node IP structure
    bzero(&node_addr,sizeof(node_addr));
    node_addr.sin_family = AF_INET;
    node_addr.sin_addr.s_addr=inet_addr(n->host_ip);
    node_addr.sin_port=htons(n->port);
    // Connecting to server
    if (connect(sock, (struct sockaddr *)&node_addr, sizeof(node_addr))!=0) {
        #Error: "(%d tcp_send_no_fork) Failed connecting to node." getpid()
        return TCL_ERROR;
    }
    // Sending message
    if(write(sock,msg,strlen(msg))==0) {
        #Error: "(%d tcp_send_no_fork) Failed sending command to node." getpid()
        return TCL_ERROR;
    }
    free(msg);
    close(sock);
    printf("Sent %s to %s:%d\n",code,n->host_ip,n->port);
    return TCL_OK;
}
static int
tcp_send(network_node *n,char *code) {
    // Starting the socket
    int sock=socket(AF_INET, SOCK_STREAM, 0);
    //Creating the message:
    char *msg=(char *)malloc(sizeof(char)*(strlen(code)+256));
    sprintf(msg,"!%% %s %d {%s} %d!",my_ip,my_port,code,network_task_handle);
    #Info: "(%d) sending %s to node %s %d" getpid(),msg,n->host_ip,n->port
    // Updating the node IP structure
    bzero(&node_addr,sizeof(node_addr));
    node_addr.sin_family = AF_INET;
    node_addr.sin_addr.s_addr=inet_addr(n->host_ip);
    node_addr.sin_port=htons(n->port);
    // Connecting to server
    if (connect(sock, (struct sockaddr *)&node_addr, sizeof(node_addr))!=0) {
        #Error: "(%d tcp_send) Failed connecting to node." getpid()
        return TCL_ERROR;
    }
    // Sending message
    if(write(sock,msg,strlen(msg))==0) {
        #Error: "(%d tcp_send) Failed sending command to node." getpid()
        return TCL_ERROR;
    }
    free(msg);
    close(sock);
    printf("Sent %s to %s:%d\n",code,n->host_ip,n->port);
    return TCL_OK;
}
static int
send_task_to_node (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if ((argc!=3)&&(argc!=2)) {
        #Error: "Usage: %s [<node_num>] <code>" argv[0]
        return TCL_ERROR;
    }
    int node_number;
    char *code;
    int node_list_size=0;
    network_node *n=network_node_root;
    while (n) {
        node_list_size++;
        n=n->next;
    }
    if (argc==2) {
        node_number=rand()%node_list_size;
        code=argv[1];
    } else {
        node_number=atoi(argv[1]);
        if (node_number>=node_list_size) {
            #Error: "(%s) node index %d exceeds node list size %d" argv[0],node_number,node_list_size
        }
        code=argv[2];
    }
    n=network_node_root;
    int i=node_number;
    while ((n)&&(i)) {
        i--;
        n=n->next;
    }
    if (n==NULL) {
        printf("Error: node %d does not exist.",node_number);
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    int good_nodes_count=node_list_size;
    network_task_handle++;
    while ((tcp_send(n,code)==TCL_ERROR)&&(good_nodes_count)) {
        // Look for a different node
        good_nodes_count--;
        node_number=rand()%node_list_size;
        n=network_node_root;
        int i=node_number;
        while ((n)&&(i)) {
            i--;
            n=n->next;
        }
    }
    if (good_nodes_count) {
        tcl_append_int(interp,network_task_handle);
        network_task_handle++; 
        return TCL_OK;
    }
    return TCL_ERROR;
}
static int
eval_task_from_node (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc!=5) {
        #Error: "Usage: %s <base host> <base port> <code> <handle>" argv[0]
        return TCL_ERROR;
    }
    // Fork the process and continue listening
    if (fork()) {
        return TCL_OK;
    } 
    Tcl_Eval(interp,"set ::network_node_event_code {}");
    network_loop=0;
    // The forked node has its own identity
    //     Its base is the calling node
    set_base_ip(argv[1],atoi(argv[2]));
    //    close(node_sock);
    //     And it has a new port
    init_ip(atoi(argv[2]));
    // And now it is ready to evaluate the command
    if (Tcl_Eval(interp,argv[3])==TCL_ERROR) {
        Tcl_Eval(interp,"puts $::errorInfo");
    }
    // and send update to the caller
    char buffer[NETWORK_BEFFER_SIZE];
    sprintf(buffer,"network_task_done %s",argv[4]);
    send_task_to_base(buffer);
    // ...after which it is no longer needed
    #Info: "(%d) done!" getpid()
    exit(0);
}
static int
network_task_done (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc!=2) {
        #Error: "Usage: %s <task handle>" argv[0]
        return TCL_ERROR;
    }
    
    
    return TCL_OK;
}
static int
send_task_to_base (char *code)
{
    // Updating the server IP structure
    bzero(&server_addr,sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr=inet_addr(base_ip);
    server_addr.sin_port=htons(base_port);
    #Info: "(%d) Sending {%s} to parent node: %s:%d" getpid(),code,base_ip,base_port
    int sock=socket(AF_INET, SOCK_STREAM, 0);
    // Connecting to server
    if (connect(sock, (struct sockaddr *)&server_addr, sizeof(server_addr))!=0) {
        #Error: "(send_task_to_base) Failed connecting to base station."
        return TCL_ERROR;
    }
    // Sending message
    if(write(sock,code,strlen(code))==0) {
        #Error: "(send_task_to_base) Failed sending command to base station."
        return TCL_ERROR;
    }
    close(sock);
    #Info: "{%s} sent successfuly." code
    return TCL_OK;
}
static int
tcl_send_task_to_base (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc!=2) {
        #Error: "Usage: %s <code>" argv[0]
        return TCL_ERROR;
    }
    return(send_task_to_base(argv[1]));
}
static int
tcl_resource_usage (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc!=3) {
        #Error: "Usage: %s [self|children] <metric>" argv[0]
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    int who;
    if (strcmp(argv[1],"self")==0) {
        who=RUSAGE_SELF;
    }
    if (strcmp(argv[1],"children")==0) {
        who=RUSAGE_CHILDREN;
    }
    if ((who!=RUSAGE_SELF)&&(who!=RUSAGE_CHILDREN)) {
        #Error: "(usage) first argument must be either 'self' or 'children'"
        return TCL_ERROR;
    }
    struct rusage usage;
    getrusage(who,&usage);
    if (strcmp(argv[2],"utime")==0) {
        tcl_append_long(interp,usage.ru_utime.tv_sec*1000000+usage.ru_utime.tv_usec);
        return TCL_OK;
    }
    if (strcmp(argv[2],"stime")==0) {
        tcl_append_long(interp,usage.ru_stime.tv_sec*1000000+usage.ru_stime.tv_usec);
        return TCL_OK;
    }
    if (strcmp(argv[2],"cputime")==0) {
        tcl_append_long(interp,(long)clock());
        return TCL_OK;
    }
    if (strcmp(argv[2],"maxrss")==0) {
        tcl_append_long(interp,usage.ru_maxrss);
        return TCL_OK;
    }
    if (strcmp(argv[2],"ixrss")==0) {
        tcl_append_long(interp,usage.ru_ixrss);
        return TCL_OK;
    }
    if (strcmp(argv[2],"idrss")==0) {
        tcl_append_long(interp,usage.ru_idrss);
        return TCL_OK;
    }
    if (strcmp(argv[2],"isrss")==0) {
        tcl_append_long(interp,usage.ru_isrss);
        return TCL_OK;
    }
    if (strcmp(argv[2],"minflt")==0) {
        tcl_append_long(interp,usage.ru_minflt);
        return TCL_OK;
    }
    if (strcmp(argv[2],"majflt")==0) {
        tcl_append_long(interp,usage.ru_majflt);
        return TCL_OK;
    }
    if (strcmp(argv[2],"nswap")==0) {
        tcl_append_long(interp,usage.ru_nswap);
        return TCL_OK;
    }
    if (strcmp(argv[2],"inblock")==0) {
        tcl_append_long(interp,usage.ru_inblock);
        return TCL_OK;
    }
    if (strcmp(argv[2],"oublock")==0) {
        tcl_append_long(interp,usage.ru_oublock);
        return TCL_OK;
    }
    if (strcmp(argv[2],"msgsnd")==0) {
        tcl_append_long(interp,usage.ru_msgsnd);
        return TCL_OK;
    }
    if (strcmp(argv[2],"msgrcv")==0) {
        tcl_append_long(interp,usage.ru_msgrcv);
        return TCL_OK;
    }
    if (strcmp(argv[2],"nsignals")==0) {
        tcl_append_long(interp,usage.ru_nsignals);
        return TCL_OK;
    }
    if (strcmp(argv[2],"nvcsw")==0) {
        tcl_append_long(interp,usage.ru_nvcsw);
        return TCL_OK;
    }
    if (strcmp(argv[2],"nivcsw")==0) {
        tcl_append_long(interp,usage.ru_nivcsw);
        return TCL_OK;
    }
    #Error: "(usage) unrecognized field: %s" argv[2]
    return TCL_ERROR;
    
}
#If: {[string match *regular $::target] || [string match *debug $::target]} {
    #Foreach: type {Info Warning Error} {
        static int tcl_$type (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
            #If: {![string equal ${type} "Nl"] && ![string equal ${type} "Token"] } {
                printf("%s ",argv[0]);
            }
            if (this_process_forked) printf("(forked process %d) ",getpid());
            int i;
            for (i=1;i<argc;i++) printf("%s ",argv[i]);
            printf("\n");
            fflush(stdout);
            return TCL_OK;
        }
    }
    #Foreach: type {Print} {
        static int tcl_$type (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
            printf("Info: ");
            if (this_process_forked) printf("(forked process %d) ",getpid());
            int i;
            for (i=1;i<argc;i++) printf("%s ",argv[i]);
            fflush(stdout);
            return TCL_OK;
        }
    }
    #Foreach: type {Token} {
        static int tcl_$type (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
            int i;
            for (i=1;i<argc;i++) printf("%s ",argv[i]);
            fflush(stdout);
            return TCL_OK;
        }
    }
    #Foreach: type {Nl} {
        static int tcl_$type (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
            printf("\n");
            fflush(stdout);
            return TCL_OK;
        }
    }
} 
#If: {[string match *silent $::target]} {
    #Foreach: type {Info Warning Error Print Token Nl} {
        static int tcl_$type (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
            return TCL_OK;
        }
    }
}
#If: {[string match *debug $::target]} {
    #Foreach: type {Dinfo Dwarning Derror} {
        static int tcl_$type (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
            #If: {![string equal ${type} "Nl"] && ![string equal ${type} "Token"] } {
                printf("%s ",argv[0]);
            }
            if (this_process_forked) printf("(forked process %d) ",getpid());
            int i;
            for (i=1;i<argc;i++) printf("%s ",argv[i]);
            printf("\n");
            fflush(stdout);
            return TCL_OK;
        }
    }
    #Foreach: type {Dprint} {
        static int tcl_$type (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
            printf("Info: ");
            if (this_process_forked) printf("(forked process %d) ",getpid());
            int i;
            for (i=1;i<argc;i++) printf("%s ",argv[i]);
            fflush(stdout);
            return TCL_OK;
        }
    }
    #Foreach: type {Dtoken} {
        static int tcl_$type (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
            int i;
            for (i=1;i<argc;i++) printf("%s ",argv[i]);
            fflush(stdout);
            return TCL_OK;
        }
    }
    #Foreach: type {Dnl} {
        static int tcl_$type (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
            printf("\n");
            fflush(stdout);
            return TCL_OK;
        }
    }
} 
#If: {[string match *regular $::target]||[string match *silent $::target]} {
    #Foreach: type {Dinfo Dwarning Derror Dprint Dtoken Dnl} {
        static int tcl_$type (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
            return TCL_OK;
        }
    }
}

static int
tcl_sizer (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    #tcl set arg_count 5 
    #Foreach: input $::sizer_inputs {
        float $input=NAN;
        float min_$input;
        float max_$input;
        #tcl incr arg_count 3
    } 
    #Foreach: parameter $::sizer_parameters {
        float $parameter=NAN;
        LUT *${parameter}_LUT;
        #tcl incr arg_count 2
    }
    float Gain=NAN;
    float Area=NAN;
    float fc=NAN;
    if (argc!=$arg_count) {
        #Error: "Usage: %s Ids_LUT gm_LUT go_LUT Nth_LUT Nflicker_LUT Vt_LUT sigmaVt_LUT Lmin Vds Ids Vt Vgs Vbs Nflicker Nth L W gm ro sigmaVt Tolerance" argv[0]
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    #tcl set arg_count 1 
    #Foreach: input $::sizer_inputs {
        if (argv[$arg_count][0]!=0) $input=atof(argv[$arg_count]);
        #tcl incr arg_count 1
        min_$input=atof(argv[$arg_count]);
        #tcl incr arg_count 1
        max_$input=atof(argv[$arg_count]);
        #tcl incr arg_count 1
    }
    #Foreach: parameter $::sizer_parameters {
        if (argv[$arg_count][0]!=0) $parameter=atof(argv[$arg_count]);
        #tcl incr arg_count 1
        ${parameter}_LUT=get_LUT(argv[$arg_count]);
        #tcl incr arg_count 1
    }
    if (argv[$arg_count][0]!=0) Gain=atof(argv[$arg_count]);
    #tcl incr arg_count 1
    if (argv[$arg_count][0]!=0) Area=atof(argv[$arg_count]);
    #tcl incr arg_count 1
    if (argv[$arg_count][0]!=0) fc=atof(argv[$arg_count]);
    #tcl incr arg_count 1
    float tolerance=atof(argv[$arg_count])/100;
    float distance=sizer(
    #Foreach: input $::sizer_inputs {
        &$input,min_$input,max_$input,
    }
    #Foreach: parameter $::sizer_parameters {
        &$parameter,${parameter}_LUT,
    } 
    &Gain,&Area,&fc,tolerance
    );
    #Foreach: input $::sizer_inputs {
        tcl_append_float(interp,$input);
    }
    #Foreach: parameter [concat $::sizer_parameters Gain Area fc] {
        tcl_append_float(interp,$parameter);
    }
    tcl_append_float(interp,distance);
    return TCL_OK;
}
static int
tcl_enable_hit (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if ((argc!=2)&&(argc!=1)) {
        #Error: "Usage: %s on/off" argv[0]
        return TCL_ERROR;
    }
    if (argc==1) hit_enabled=1;
    if (argc==2) {
        if (strcmp(argv[1],"on")) hit_enabled=1;
        if (strcmp(argv[1],"off")) hit_enabled=0;
    }	
    return TCL_OK;
}
void list_hit(hit_node *hit,int level) {
    if (hit==NULL) return;
    char *indent=(char *)malloc(sizeof(char)*(level+1));
    int i;
    for (i=0;i<level;i++) indent[i]='.';
    indent[level]=0;
    if (hit[HIT_TYPE].o==HIT_DIVIDER) {
        #Info: "%s DIM %d Level %g" indent hit[HIT_DIM].o hit[HIT_VALUES].s
        list_hit((hit_node *)hit[HIT_VALUES+1].p,level+4);
        list_hit((hit_node *)hit[HIT_VALUES+2].p,level+4);
        return;
    }
    if (hit[HIT_TYPE].o==HIT_FULL_INTERP) {
        #Info: "%s hypercube:" indent 
        for (i=0;i<merge_dim;i++) {
            #Info: "%s %d) %g %g" indent i hit[HIT_VALUES+2*i].s 1/(hit[HIT_VALUES+2*i+1].s)
        }
        #Info: "%s   corners" indent 
        for (i=2*merge_dim;i<hit[HIT_DIM].o+2*merge_dim;i++) {
            #Info: "%s   %d) %g" indent i-2*merge_dim hit[HIT_VALUES+i].s 
        }
    }
}
static int
tcl_list_bytecode (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if ((argc!=2)&&(argc!=3)) {
        #Error: "Usage: %s <array name> <limit>" argv[0]
        return TCL_ERROR;
    }
    ordinal i,j;
    bytecode_buffer_index=0;
    LUT *a=get_LUT(argv[1]);
    bc_start(a->hit_bytecode);
    ordinal limit=a->hit_bytecode_size;
    if (argc==3) limit=atoi(argv[2]);
    if (limit>a->hit_bytecode_size) limit=a->hit_bytecode_size;
    #Info: "(%016X) Listing Bytecode (%ld) " bytecode_buffer limit 
    while (bytecode_buffer_index<limit) {
        unsigned char bc=bc_byte();
        if (bc&HIT_CELL) {
            #Info: "<%d> Corner=%g %08X" bytecode_buffer_index bc_float() bc_full_int()
            bc_step();
            continue;
        }
        float level=bc_float();
        int32_t I0=bc_full_int();
        bc_step();
        int32_t I1=bc_full_int();
        int32_t jump=bytecode_buffer_index+bc_int();
        #Info: "<%d> Dim%d>=%g or jump to <%ld> %08X %08X" bytecode_buffer_index-1 bc level jump I0 I1
        bc_step();
    }
    bc_start(a->hit_bytecode);
    return TCL_OK;
}
static int
LUT2hit (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[])
{
    if (argc!=2) {
        #Error: "Usage: %s <array name>" argv[0]
        return TCL_ERROR;
    }
    LUT *a=get_LUT(argv[1]);
    ordinal i,j;
    for (i=0;i<a->dim;i++) array2hit_partial_legend_top[i]=a->size[i];
    for (i=0;i<a->dim;i++) array2hit_partial_legend_bottom[i]=0;
    ordinal *separation[$::MAXDIM];
    map_slice_separation(a,separation);
    a->hit=array2hit(a,separation,0);
    for (i=0;i<a->dim;i++) free(separation[i]);
    merge_dim=a->dim;
    ordinal m=0;
    m=merge_hit_leaves(&(a->hit));
    
    #Info: "Done merging %d cells" m
    ordinal stats[3];
    for (i=0;i<3;i++) stats[i]=0;
    //    a->hit=linearize_hit_leaf(a->hit,stats);
    ordinal sizer=1;
    for (i=0;i<a->dim;i++) sizer*=(a->size[i]-1);
    bc_start(a->hit_bytecode);
    ordinal num_of_bc_words=count_hit_bytecode(a->hit);
    
    #Info: "Writing Byte Code in %ld Bytes" 4*num_of_bc_words
    a->hit_bytecode=(FC *)malloc(sizeof(FC)*num_of_bc_words);
    a->hit_bytecode_size=num_of_bc_words;
    bc_start(a->hit_bytecode);
    compile_bytecode(a->hit);
    
    hit_enabled=1;
    free(a->content);
    bc_start(a->hit_bytecode);
    return TCL_OK;
}  
void map_slice_separation(LUT *a,ordinal **separation) {
    ordinal *total[$::MAXDIM];
    int i,j;
    for (i=0;i<a->dim;i++) {
        separation[i]=(ordinal *)malloc(sizeof(ordinal)*a->size[i]);
        total[i]=(ordinal *)malloc(sizeof(ordinal)*a->size[i]);
        for (j=0;j<a->size[i];j++) separation[i][j]=0;
        for (j=0;j<a->size[i];j++) total[i][j]=0;
    }
    ordinal sizer=1,index;
    for (i=0;i<a->dim;i++) {
        //        a->neighbors[i]=sizer;
        sizer*=a->size[i];
    }	
    for (index=0;index<sizer;index++) {
        ordinal key[$::MAXDIM];
        ordinal partial_index=index;
        int skip_point=0;
        for (j=0;j<a->dim;j++) {
            key[j]=partial_index%a->size[j];
            if (key[j]==0) skip_point=1;
            if (key[j]==a->size[j]-1) skip_point=1;
            partial_index/=a->size[j];
        }
        if (skip_point) continue;
        for (j=0;j<a->dim;j++) {
            ordinal slice=key[j];
            float weight=(a->legend[j][slice+1]-a->legend[j][slice])/(a->legend[j][slice+1]-a->legend[j][slice-1]);
            float pre=a->content[index-a->neighbors[j]];
            float post=a->content[index+a->neighbors[j]];
            float M=a->content[index];
            float I=pre*weight+post*(1-weight);
            float Error=fabs(I/M-1)*100;
            if (Error>1.0) separation[j][slice]+=1000;
            total[j][slice]++;
        }
    }
    for (i=0;i<a->dim;i++) for (j=1;j<a->size[i]-1;j++) {
        if (total[i][j]==0) continue;
        separation[i][j]/=total[i][j];
        #Dinfo: "Separation in Slice %d, Dim %d equals %d" j i  separation[i][j]
    }
    for (i=0;i<a->dim;i++) {
        free(total[i]);
    }
    
}
ordinal count_hit_bytecode(hit_node *hit) {
    ordinal retval=0;
    if (hit[HIT_TYPE].o&HIT_CELL) {
        retval++;
        return(retval);
    }	
    retval+=2;
    retval+=count_hit_bytecode((hit_node *)hit[HIT_VALUES+1].p);
    retval+=count_hit_bytecode((hit_node *)hit[HIT_VALUES+2].p);
    return(retval);
}
void compile_bytecode(hit_node *hit) {
    int i,j;
    if (hit[HIT_TYPE].o==HIT_FULL_INTERP) {
        // bc command
        bc_put_byte(HIT_FULL_INTERP);
        // corners (skipping the scafold information about starting value and factor per dimension)
        bc_put_scalar(hit[HIT_VALUES+2*merge_dim].s);
        bc_step();
        return;
    }
    // bc command
    bc_put_byte((unsigned char)hit[HIT_DIM].o);
    // slice level
    float level=hit[HIT_VALUES+i++].s;
    bc_put_scalar(level);
    bc_step();
    // This little dance is necessary to create the jump entry in the divider command. The steps are: 
    ordinal this_index=bytecode_buffer_index;
    // 1. writing  a placeholder 0
    bc_put_full_int(0);
    bc_step();
    // 2. compiling one side of the tree
    compile_bytecode((hit_node *)hit[HIT_VALUES+1].p);
    // 3. returning to the place-holder and changing it to the size of that half tree
    ordinal next_index=bytecode_buffer_index;
    bytecode_buffer_index=this_index;
    bc_put_full_int(next_index-this_index);
    bc_step();
    // 4. returning to the end of the bc buffer and compiling the other half.
    bytecode_buffer_index=next_index;
    compile_bytecode((hit_node *)hit[HIT_VALUES+2].p);
    return;
}
hit_node *linearize_hit_leaf(hit_node *hit,ordinal *stats) {
    if (!(hit[HIT_TYPE].o&HIT_CELL)) {
        hit[HIT_VALUES+1].p=linearize_hit_leaf((hit_node *)hit[HIT_VALUES+1].p,stats);
        hit[HIT_VALUES+2].p=linearize_hit_leaf((hit_node *)hit[HIT_VALUES+2].p,stats);
        return(hit);
    }
    if (!(hit[HIT_TYPE].o==HIT_FULL_INTERP)) return(hit);
    float constant=0;
    float midpoint[$::MAXDIM];
    float slopes[$::MAXDIM];
    ordinal l=1;
    int i;
    for (i=0;i<merge_dim;i++) {
        slopes[i]=0;
        l*=2;
        midpoint[i]=-hit[HIT_VALUES+i*2].s+0.5*1/(hit[HIT_VALUES+i*2+1].s);
    }    
    l/=2;
    ordinal corner=0;
    ordinal num_of_corners;
    num_of_corners=1<<merge_dim;
    for (corner=0;corner<num_of_corners;corner++) {
        float corner_value=hit[HIT_VALUES+merge_dim*2+corner].s;
        // constant is pre-loaded with the average between all points
        constant+=corner_value;
        ordinal tmp_corner=corner;
        for (i=0;i<merge_dim;i++) {
            if (tmp_corner&1) {
                slopes[i]+=corner_value;
            } else {
                slopes[i]-=corner_value;
            }
            // next bit
            tmp_corner>>=1;
        }
    } 
    // Normalizing constant to the average
    constant/=l;
    constant/=2;
    for (i=0;i<merge_dim;i++) {
        // Normalizing each slope
        slopes[i]/=l;
        slopes[i]*=hit[HIT_VALUES+i*2+1].s;
        // subtracting the regression from the average -> the midpoint regression is now anchored to the average between hypercube's points.
        constant-=slopes[i]*midpoint[i];
    }  
    slopes[merge_dim]=constant;
    ////////////////////////////////////// Testing:
    float max_error=0;
    for (corner=0;corner<num_of_corners;corner++) {
        ordinal index=0;
        // scratch 'tmp' to roll the corner bits without destroying corner itself:
        ordinal tmp_corner=corner;
        float interpolated_value=slopes[merge_dim];
        tmp_corner=corner;
        for (i=0;i<merge_dim;i++) {
            interpolated_value+=slopes[i]*(-hit[HIT_VALUES+i*2].s+(tmp_corner&1)/(hit[HIT_VALUES+i*2+1].s));
            tmp_corner>>=1;
        }  
        float original_value=hit[HIT_VALUES+merge_dim*2+corner].s;
        float error=100*fabs((original_value-interpolated_value)/original_value);
        if (fabs((original_value-interpolated_value))<1e-12) error=0.1;
        if (error>max_error) max_error=error;
    }
    if (max_error>1.0) {
        // Try cLUT
        float baseline=1e99;
        float top_value=-1e99;
        for (corner=0;corner<num_of_corners;corner++) if (baseline>hit[HIT_VALUES+merge_dim*2+corner].s) baseline=hit[HIT_VALUES+merge_dim*2+corner].s;
        for (corner=0;corner<num_of_corners;corner++) if (top_value<hit[HIT_VALUES+merge_dim*2+corner].s) top_value=hit[HIT_VALUES+merge_dim*2+corner].s;
        float resolution_step=(top_value-baseline)/255;
        if (fabs(resolution_step/baseline)*100>1) {
            stats[0]++;
            return(hit);
        }
        stats[1]++;
        // Go ahead and convert the entries to 8bit representation
        hit_node *new_hit=(hit_node *)malloc(sizeof(hit_node)*(4+num_of_corners));
        new_hit[HIT_TYPE].o=HIT_CFULL_INTERP;
        new_hit[HIT_DIM].o=num_of_corners;
        new_hit[HIT_VALUES].s=baseline;
        new_hit[HIT_VALUES+1].s=resolution_step;
        for (corner=0;corner<num_of_corners;corner++) new_hit[HIT_VALUES+2+corner].o=s2o((hit[HIT_VALUES+merge_dim*2+corner].s-baseline)/resolution_step);
        free(hit);
        return(new_hit);
    }
    stats[2]++;
    free(hit); 
    hit=(hit_node *)malloc(sizeof(hit_node)*(3+merge_dim));
    hit[HIT_TYPE].o=HIT_LIN_INTERP;
    hit[HIT_DIM].o=merge_dim;
    hit[HIT_VALUES].s=slopes[merge_dim];
    for (i=0;i<merge_dim;i++) hit[HIT_VALUES+1+i].s=slopes[i];
    return(hit);
}
hit_node *array2hit(LUT *a,ordinal **separation,int degree) {
    ordinal seperation_dim=-1;
    ordinal separation_slice;
    ordinal separation_slice_loss=0;
    int i,j;
    char indent[1024];
    for (i=0;i<degree;i++) indent[i]='.';
    indent[degree]=0;
    for (i=0;i<a->dim;i++) {
        if (array2hit_partial_legend_top[i]-array2hit_partial_legend_bottom[i]<2) continue;
        ordinal total_separation=0;
        for (j=array2hit_partial_legend_bottom[i]+1;j<array2hit_partial_legend_top[i];j++) total_separation+=separation[i][j];
        total_separation/=(array2hit_partial_legend_top[i]-array2hit_partial_legend_bottom[i]-1);
        if (total_separation>separation_slice_loss) {
            separation_slice_loss=total_separation;
            seperation_dim=i;
            separation_slice=(array2hit_partial_legend_top[i]+array2hit_partial_legend_bottom[i])/2;
        }
    }
    seperation_dim=-1;
    if (seperation_dim<0) {
        ordinal max_width=1;
        for (i=0;i<a->dim;i++) if (array2hit_partial_legend_top[i]-array2hit_partial_legend_bottom[i]>max_width) {
            seperation_dim=i;
            separation_slice=(array2hit_partial_legend_top[i]+array2hit_partial_legend_bottom[i])/2;
            max_width=array2hit_partial_legend_top[i]-array2hit_partial_legend_bottom[i];
        }
    }
    if (seperation_dim>=0) {
        #Dinfo: "%s %d) Dividing along dim=%d, slice=%d" indent degree seperation_dim separation_slice
        hit_node *hit=(hit_node *)malloc(sizeof(hit_node)*5);
        hit[HIT_TYPE].o=HIT_DIVIDER;
        hit[HIT_DIM].o=seperation_dim;
        float orig_top=array2hit_partial_legend_top[seperation_dim];
        float orig_bottom=array2hit_partial_legend_bottom[seperation_dim];
        hit[HIT_VALUES+0].s=a->legend[seperation_dim][separation_slice];
        array2hit_partial_legend_bottom[seperation_dim]=separation_slice;
        hit[HIT_VALUES+1].p=(void *)array2hit(a,separation,degree+1);
        array2hit_partial_legend_bottom[seperation_dim]=orig_bottom;
        array2hit_partial_legend_top[seperation_dim]=separation_slice;
        hit[HIT_VALUES+2].p=(void *)array2hit(a,separation,degree+1);
        array2hit_partial_legend_top[seperation_dim]=orig_top;
        return(hit);
    }
    #Dinfo: "%s Cell" indent
    ordinal num_of_corners;
    num_of_corners=1<<a->dim;
    ordinal index=0;
    ordinal sizer=1;
    for (i=0;i<a->dim;i++) {
        index+=sizer*array2hit_partial_legend_bottom[i];
        sizer*=a->size[i];
    } 	 
    hit_node *hit=(hit_node *)malloc(sizeof(hit_node)*(2+num_of_corners+a->dim*2));
    hit[HIT_TYPE].o=HIT_FULL_INTERP;
    hit[HIT_DIM].o=num_of_corners;
    for (i=0;i<a->dim;i++) {
        hit[HIT_VALUES+i*2].s=-a->legend[i][array2hit_partial_legend_bottom[i]];
        hit[HIT_VALUES+i*2+1].s=1.0/(a->legend[i][array2hit_partial_legend_top[i]]-a->legend[i][array2hit_partial_legend_bottom[i]]);
    }
    for (i=0;i<num_of_corners;i++) {
        int outsider=0; 
        for (j=0;j<a->dim;j++) if (i&(1<<j)) if (array2hit_partial_legend_top[j]>=a->size[j]) outsider=1;
        if (outsider) {
            hit[HIT_VALUES+i+a->dim*2].s=NAN;
        } else {
            hit[HIT_VALUES+i+a->dim*2].s=a->content[index+a->neighbors[i]]; 
        }    
    }	
    return(hit);  
}
ordinal merge_hit_leaves(hit_node **hit) {
    if ((*hit)[HIT_TYPE].o&HIT_CELL) return 0;
    hit_node *hit_t=(hit_node *)(*hit)[HIT_VALUES+1].p;
    hit_node *hit_b=(hit_node *)(*hit)[HIT_VALUES+2].p;
    ordinal retval=0;
    if (hit_t[HIT_TYPE].o==HIT_DIVIDER) retval+=merge_hit_leaves((hit_node **)&((*hit)[HIT_VALUES+1].p));
    if (hit_b[HIT_TYPE].o==HIT_DIVIDER) retval+=merge_hit_leaves((hit_node **)&((*hit)[HIT_VALUES+2].p));
    hit_t=(hit_node *)(*hit)[HIT_VALUES+1].p;
    hit_b=(hit_node *)(*hit)[HIT_VALUES+2].p;
    if (hit_t[HIT_TYPE].o!=HIT_FULL_INTERP) return(retval);
    if (hit_b[HIT_TYPE].o!=HIT_FULL_INTERP) return(retval);
    int i;
    int boundary_cell=0;
    ordinal num_of_corners;
    num_of_corners=1<<merge_dim;
    for (i=0;i<num_of_corners;i++) if (isnan(hit_t[HIT_VALUES+2*merge_dim+i].s)) boundary_cell=1;
    for (i=0;i<num_of_corners;i++) if (isnan(hit_b[HIT_VALUES+2*merge_dim+i].s)) boundary_cell=1;
    if (boundary_cell) return(retval);
    #Dinfo: "   Cells!" 
    #Dinfo: "Trying to merge: %d (type1=%d, type2=%d)" (*hit)[HIT_DIM].o hit_t[HIT_TYPE].o hit_b[HIT_TYPE].o
    float max_error=0;
    ordinal split_dim=(*hit)[HIT_DIM].o;
    float b=1/(hit_t[HIT_VALUES+2*split_dim+1].s);
    float a=1/(hit_b[HIT_VALUES+2*split_dim+1].s);
    float weight_top=a/(a+b);
    float weight_bottom=b/(a+b);
    int mask=1<<split_dim;
    float failed_M,failed_I;
    #Dinfo: "   a=%g b=%g split_dim=%d mask=%d" a b split_dim mask
    for (i=0;i<num_of_corners;i++) {
        if (!(i&mask)) continue;
        int j=i-mask;
        float T=hit_t[HIT_VALUES+2*merge_dim+i].s;
        float B=hit_b[HIT_VALUES+2*merge_dim+j].s;
        float M=hit_b[HIT_VALUES+2*merge_dim+i].s;
        float I=T*weight_top+B*weight_bottom;
        if (M!=hit_t[HIT_VALUES+2*merge_dim+j].s) {
            #Error: "Mismatched hypercubes: %g!=%g" M hit_t[HIT_VALUES+2*merge_dim+j].s
        }
        float error=fabs(I/M-1)*100;
        #Dinfo: "T=%g B=%g M=%g I=%g E=%g" T B M I error
        //if (fabs(I-M)<1e-9) error=0;
        if (error>max_error) max_error=error;
    }
    #Dinfo: "max_error=%g" max_error
    if (max_error>1) return retval;
    free(*hit);
    *hit=(hit_node *)malloc(sizeof(hit_node)*(2+2*merge_dim+num_of_corners));
    (*hit)[HIT_TYPE].o=HIT_FULL_INTERP;
    (*hit)[HIT_DIM].o=num_of_corners;
    for (i=0;i<merge_dim;i++) {
        (*hit)[HIT_VALUES+i*2].s=hit_b[HIT_VALUES+i*2].s;
        if (i==split_dim) {
            (*hit)[HIT_VALUES+i*2+1].s=1/(1/hit_b[HIT_VALUES+i*2+1].s+1/hit_t[HIT_VALUES+i*2+1].s);
        } else {
            (*hit)[HIT_VALUES+i*2+1].s=hit_b[HIT_VALUES+i*2+1].s;
        }
    }	
    for (i=0;i<num_of_corners;i++) {
        if (i&mask) {
            (*hit)[HIT_VALUES+2*merge_dim+i].s=hit_t[HIT_VALUES+2*merge_dim+i].s;
        } else {
            (*hit)[HIT_VALUES+2*merge_dim+i].s=hit_b[HIT_VALUES+2*merge_dim+i].s;
        }
    }
    #Dinfo: "MERGED!"
    for (i=0;i<2+2*merge_dim+num_of_corners;i++) {
        #Dinfo: "%d) %g   %g   =>   %g" i hit_b[i].s hit_t[i].s (*hit)[i].s
    }
    free(hit_t);
    free(hit_b);
    retval++;
    return(retval);
}
static int tcl_heatmap (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    if (argc!=4) {
        #Error: "heatmap requires list of coordinates, list of pallete and output file name"
        return TCL_ERROR;
    }
    int ARGC;
    char **ARGV;
    Tcl_SplitList(interp,argv[1],&ARGC,&ARGV);
    if (ARGC%3) {
        #Error: "heatmap list of coordinates size must divide by 3"
        return TCL_ERROR;
    }
    int count=ARGC/3;
    float *data=(float *)malloc(sizeof(float)*ARGC);
    int i;
    for (i=0;i<ARGC;i++) data[i]=atof(ARGV[i]);
    free(ARGV);
    Tcl_SplitList(interp,argv[2],&ARGC,&ARGV);
    int *pal=(int *)malloc(sizeof(int)*ARGC);
    float *key=(float *)malloc(sizeof(float)*(ARGC+1));
    for (i=0;i<ARGC;i++) pal[i]=strtol(ARGV[i],NULL,16);
    create_heatmap(data,count,pal,ARGC,key,argv[3]);
    free(data);
    free(ARGV);
    for (i=0;i<=ARGC;i++) tcl_append_float(interp,key[i]);
    free(key);
    return TCL_OK;
}
int register_tcl_functions(Tcl_Interp *interp) {
    ctree=new_node(NULL,0);
    Ctree=new_context(NULL,NULL,0);
    Context=Ctree;
    ctree->ctype=ctype_string;
    //context=ctree;
    context_stack_pointer=0;
    Tcl_CreateCommand(interp, "polish", tcl_polish, NULL, NULL);
    Tcl_CreateCommand(interp, "peel", tcl_peel, NULL, NULL);
    Tcl_CreateCommand(interp, "fork", tcl_fork, NULL, NULL);
    Tcl_CreateCommand(interp, "array_set", array_set, NULL, NULL);
    Tcl_CreateCommand(interp, "array_get", array_get, NULL, NULL);
    Tcl_CreateCommand(interp, "LUT_list", LUT_list, NULL, NULL);
    Tcl_CreateCommand(interp, "array_data", array_data, NULL, NULL);
    Tcl_CreateCommand(interp, "timer_report", tcl_timer_report, NULL, NULL);
    Tcl_CreateCommand(interp, "LUT_set_legend", LUT_set_legend, NULL, NULL);
    Tcl_CreateCommand(interp, "LUT_get_legend", LUT_get_legend, NULL, NULL);
    Tcl_CreateCommand(interp, "LUT_get_dim", LUT_get_dim, NULL, NULL);
    Tcl_CreateCommand(interp, "LUT_get_size", LUT_get_size, NULL, NULL);
    Tcl_CreateCommand(interp, "list_bytecode", tcl_list_bytecode, NULL, NULL);
    Tcl_CreateCommand(interp, "array2hit", LUT2hit, NULL, NULL);
    Tcl_CreateCommand(interp, "enable_hit", tcl_enable_hit, NULL, NULL);
    Tcl_CreateCommand(interp, "sizer", tcl_sizer, NULL, NULL);
    Tcl_CreateCommand(interp, "verbose", tcl_verbose, NULL, NULL);
    Tcl_CreateCommand(interp, "network_mode", network_mode, NULL, NULL);
    Tcl_CreateCommand(interp, "network_update", network_update, NULL, NULL);
    Tcl_CreateCommand(interp, "add_network_node", tcl_add_network_node, NULL, NULL);
    Tcl_CreateCommand(interp, ">>", send_task_to_node, NULL, NULL);
    Tcl_CreateCommand(interp, "<<", tcl_send_task_to_base, NULL, NULL);
    Tcl_CreateCommand(interp, "@", tcl_ctree, NULL, NULL);
    Tcl_CreateCommand(interp, "%", eval_task_from_node, NULL, NULL);
    Tcl_CreateCommand(interp, "node_release", node_release, NULL, NULL);
    Tcl_CreateCommand(interp, "network_task_done", network_task_done, NULL, NULL);
    Tcl_CreateCommand(interp, "usage",tcl_resource_usage , NULL, NULL);
    Tcl_CreateCommand(interp, "array_save", LUT_save, NULL, NULL);
    Tcl_CreateCommand(interp, "array_load", LUT_load, NULL, NULL);
    #ifdef SPICE_COMPILATION
    Tcl_CreateCommand(interp, "dc_analysis", tcl_dc_analysis, NULL, NULL);
    Tcl_CreateCommand(interp, "alter_param", alter_param, NULL, NULL);
    Tcl_CreateCommand(interp, "set_param", set_param, NULL, NULL);
    Tcl_CreateCommand(interp, "get_circuits", get_circuits, NULL, NULL);
    Tcl_CreateCommand(interp, "get_ckt_tree", get_ckt_tree, NULL, NULL);
    Tcl_CreateCommand(interp, "get_ckt_lines", get_ckt_lines, NULL, NULL);
    Tcl_CreateCommand(interp, "set_ckt_lines", set_ckt_lines, NULL, NULL);
    Tcl_CreateCommand(interp, "get_ckt_devices", get_ckt_devices, NULL, NULL);
    Tcl_CreateCommand(interp, "get_spice_data", get_spice_data, NULL, NULL);
    Tcl_CreateCommand(interp, "set_spice_var", set_spice_var, NULL, NULL);
    Tcl_CreateCommand(interp, "get_vectors", get_vectors, NULL, NULL);
    Tcl_CreateCommand(interp, "get_var", get_var, NULL, NULL);
    Tcl_CreateCommand(interp, "set_var", set_var, NULL, NULL);
    Tcl_CreateCommand(interp, "baseline_characterization_slice", baseline_characterization_slice, NULL, NULL);
    Tcl_CreateCommand(interp, "save_characterization_slice", save_characterization_slice, NULL, NULL);
    Tcl_CreateCommand(interp, "save_characterization_slice_differential", save_characterization_slice_differential, NULL, NULL);
    Tcl_CreateCommand(interp, "save_characterization_slice_delta", save_characterization_slice_delta, NULL, NULL);
    Tcl_CreateCommand(interp, "save_characterization_slice_delta_differential", save_characterization_slice_delta_differential, NULL, NULL);
    Tcl_CreateCommand(interp, "load_characterization_slice", load_characterization_slice, NULL, NULL);
    #endif
    Tcl_CreateCommand(interp, "generate_lit", tcl_generate_lit, NULL, NULL);
    Tcl_CreateCommand(interp, "normalize_ids", normalize_ids, NULL, NULL);
    Tcl_CreateCommand(interp, "open_bin", tcl_open_bin, NULL, NULL);
    Tcl_CreateCommand(interp, "close_bin", tcl_close_bin, NULL, NULL);
    Tcl_CreateCommand(interp, "write_bin", tcl_write_bin, NULL, NULL);
    Tcl_CreateCommand(interp, "read_bin", tcl_read_bin, NULL, NULL);
    Tcl_CreateCommand(interp, "ginfo", gamma_info, NULL, NULL);
    Tcl_CreateCommand(interp, "heatmap", tcl_heatmap, NULL, NULL);
    OpenFileForReading=NULL;
    OpenFileForWriting=NULL;
    #Foreach: type {Info Warning Error Print Nl Token Dinfo Dwarning Derror Dprint Dtoken Dnl} {
        Tcl_CreateCommand(interp, "$type:", tcl_$type, NULL, NULL);
    }
    #Foreach: global_var $::global_c_variables {
        $global_var=0.0;
    }
}
int execute_main_commands(Tcl_Interp *interp,int argc,char *argv[]) {
    int i;
    this_process_forked=0;
    int this_is_a_network_node=0;
    for (i=1;i<argc;i++) {
        if (argv[i][0]=='-') {
            if (strcmp(argv[i],"-base")==0) {
                this_is_a_network_node=1;
                if (i+1>=argc) {
                    #Error: "-base requires port"
                    exit(1);
                }
                init_ip(atoi(argv[i+1]));
                i++;
                network_node_type=net_mode_base;
                if (Tcl_EvalFile(interp,"src/base.tcl")==TCL_ERROR) {
                    Tcl_Eval(interp,"puts $errorInfo");
                    exit(1);
                }
                continue;
            }
            if (strcmp(argv[i],"-node")==0) {
                this_is_a_network_node=1;
                if (i+2>=argc) {
                    #Error: "-node requires host name and port"
                    exit(1);
                }
                network_node_type=net_mode_node;
                set_base_ip(argv[i+1],atoi(argv[i+2]));
                init_ip(atoi(argv[i+2]));
                i+=2;
                char buffer[NETWORK_BEFFER_SIZE];
                sprintf(buffer,"add_network_node %s %d",my_ip,my_port);
                send_task_to_base(buffer);
                network_wait_loop(interp);
                continue;
            }
        }
        if (argv[i][0]=='-') break;
        #Info: "Running RAMSpice Script: %s start: \[clock format \[clock seconds\]\]" argv[i]
        if (Tcl_EvalFile(interp,argv[i])==TCL_ERROR) {
            Tcl_Eval(interp,"puts $errorInfo");
        }
        #Info: "Done sourcing Tcl script: %s" argv[i]
        if (get_Tcl_counter) {
            #Info: "Average Interpolation CPU time: %ld ns" (1e3*get_Tcl_timer)/get_Tcl_counter
        }
    }
    if ((network_node_type!=net_mode_null)&&(this_is_a_network_node)) {
        init_ip(my_port);
        network_wait_loop(interp);
    }
}


