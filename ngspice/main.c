#include "ramspice_types.h"
/* Copyright 1990
   Regents of the University of California.
   All rights reserved.

   Author: 1985 Wayne A. Christopher

   The main routine for ngspice
*/
#include "ngspice/ngspice.h"
#include "Gamma/Data/ctree.h"
#include "Gamma/LUT/look_up_table.h"
#include "ngspice/MC/tcl_input.h"
//#include "Analysis/dc_analysis.h"
#ifdef HAVE_ASPRINTF
# ifdef HAVE_LIBIBERTY_H /* asprintf */
#  include <libiberty.h>
# elif defined(__MINGW32__) || defined(__SUNPRO_C) /* we have asprintf, but not libiberty.h */
#  include <stdarg.h>
   extern int asprintf(char **out, const char *fmt, ...);
   extern int vasprintf(char **out, const char *fmt, va_list ap);
# endif
#endif

#include <setjmp.h>
#include <signal.h>

/* Added GNU Readline Support 11/3/97 -- Andrew Veliath <veliaa@rpi.edu> */
/* from spice3f4 patch to ng-spice. jmr */
#ifdef HAVE_GNUREADLINE
# include <readline/readline.h>
# include <readline/history.h>
#endif

/* SJB added editline support 2005-05-05 */
#ifdef HAVE_BSDEDITLINE
# include <editline/readline.h>
 extern VFunction *rl_event_hook;    /* missing from editline/readline.h */
 extern int rl_catch_signals;        /* missing from editline/readline.h */
#endif

#include "ngspice/iferrmsg.h"
#include "ngspice/ftedefs.h"
#include "ngspice/devdefs.h"
#include "spicelib/devices/dev.h"
#include "spicelib/analysis/analysis.h"
#include "misc/ivars.h"
#include "misc/misc_time.h"
#include <signal.h>

#if defined(HAS_WINGUI) || defined(_MSC_VER) || defined(__MINGW32__)
# include "misc/mktemp.h"
#endif

#if defined(HAVE_GETOPT_LONG) && defined(HAVE_GETOPT_H)
# include <getopt.h>
#else
# include "misc/getopt_bsd.h"
#endif

#include "frontend/spiceif.h"
#include "frontend/resource.h"
#include "frontend/variable.h"
#include "frontend/display.h"  /* added by SDB to pick up Input() fcn */
#include "frontend/signal_handler.h"
#include "frontend/misccoms.h"
#include "ngspice/compatmode.h"
/* saj xspice headers */
#ifdef XSPICE
# include "ngspice/ipctiein.h"
# include "ngspice/mif.h"
# include "ngspice/enh.h"
# include "ngspice/mifproto.h"
# include "ngspice/evtproto.h"
#endif

#ifdef CIDER
# include "ngspice/numenum.h"
# include "maths/misc/accuracy.h"
#endif

#if defined(HAVE_GNUREADLINE) || defined(HAVE_BSDEDITLINE)
 char history_file[512] = {'\0'};
 static char *application_name;
#endif
#include "Gamma/Data/ctree_spice.h"

/* Undefine this next line for debug tracing */
/* #define TRACE */

/* Main options */
static bool ft_servermode = FALSE;
bool ft_batchmode = FALSE;
bool ft_pipemode = FALSE;
bool rflag = FALSE; /* has rawfile */

/* Frontend options */
bool ft_intrpt = FALSE;     /* Set by the (void) signal handlers. TRUE = we've been interrupted. */
bool ft_setflag = FALSE;    /* TRUE = Don't abort simulation after an interrupt. */
char *ft_rawfile = "rawspice.raw";

#ifdef HAS_WINGUI
 extern void winmessage(char *new_msg); /* display a message box (defined in winmain.c)*/
 extern void SetSource( char *Name);    /* display the source file name in the source window */
 extern int  xmain(int argc, char **argv);
 FILE *flogp = NULL;         /* log file ('-o logfile' command line option) */
#else
 bool orflag = FALSE; /* global for -o option */
#endif

FILE *slogp = NULL;          /* soa log file ('--soa-log file' command line option) */

/* Frontend and circuit options */
IFsimulator *ft_sim = NULL;

char *errRtn;     /* name of the routine declaring error */
char *errMsg = NULL;     /* descriptive message about what went wrong */
char *cp_program; /* program name 'ngspice' */


/* Globals definitions for Machine Accuracy Limits
 * (needed by CIDER)
 */
double BMin;                /* lower limit for B(x) */
double BMax;                /* upper limit for B(x) */
double ExpLim;              /* limit for exponential */
double Accuracy;            /* accuracy of the machine */
double MuLim, MutLim;

#ifdef CIDER
/* Global debug flags from CIDER, soon they will become
 * spice variables :)
 */
BOOLEAN ONEacDebug   = FALSE;
BOOLEAN ONEdcDebug   = TRUE;
BOOLEAN ONEtranDebug = TRUE;
BOOLEAN ONEjacDebug  = FALSE;

BOOLEAN TWOacDebug   = FALSE;
BOOLEAN TWOdcDebug   = TRUE;
BOOLEAN TWOtranDebug = TRUE;
BOOLEAN TWOjacDebug  = FALSE;

/* CIDER Global Variable Declarations */

int BandGapNarrowing;
int TempDepMobility, ConcDepMobility, FieldDepMobility, TransDepMobility;
int SurfaceMobility, MatchingMobility, MobDeriv;
int CCScattering;
int Srh, Auger, ConcDepLifetime, AvalancheGen;
int FreezeOut = FALSE;
int OneCarrier;

int MaxIterations = 100;
int AcAnalysisMethod = DIRECT;

double Temp, RelTemp, Vt;
double RefPsi;/* potential at Infinity */
double EpsNorm, VNorm, NNorm, LNorm, TNorm, JNorm, GNorm, ENorm;

 /* end cider globals */
#endif /* CIDER */

struct variable *(*if_getparam)(CKTcircuit *ckt, char **name, char *param, int ind, int do_model);

/* static functions */

static void sp_shutdown(int exitval);
static void app_rl_readlines(void);

#if defined(HAVE_GNUREADLINE) || defined(HAVE_BSDEDITLINE)
 static char *prompt(void);
#endif

#ifndef X_DISPLAY_MISSING
# include "frontend/plotting/x11.h"
# ifdef HAVE_GNUREADLINE
   static int app_event_func(void);
# endif
# ifdef HAVE_BSDEDITLINE
   static void app_event_func(void);
# endif
#endif

static void show_help(void);
static void show_version(void);
static bool read_initialisation_file(char *dir, char *name);

#ifdef SIMULATOR
static void append_to_stream(FILE *dest, FILE *source);
#endif


extern IFsimulator SIMinfo;

#ifdef SIMULATOR

const bool ft_nutmeg = FALSE;
extern struct comm spcp_coms[ ];
struct comm *cp_coms = spcp_coms;

extern int OUTpBeginPlot(CKTcircuit *,JOB *,IFuid,IFuid,int,int,IFuid *,int,runDesc **);
extern int OUTpData(runDesc *,IFvalue *,IFvalue *);
extern int OUTwBeginPlot(CKTcircuit *,JOB *,IFuid,IFuid,int,int,IFuid *,int,runDesc **);
extern int OUTwReference(void *,IFvalue *,void **);
extern int OUTwData(runDesc *,int,IFvalue *,void *), OUTwEnd(runDesc *), OUTendPlot(runDesc *);
extern int OUTbeginDomain(runDesc *,IFuid,int,IFvalue *);
extern int OUTendDomain(runDesc *), OUTstopnow(void);
extern void OUTerror(int,char *,IFuid *);
extern int OUTattributes(runDesc *,IFuid,int,IFvalue *);

extern void initw(void);
extern IFfrontEnd nutmeginfo;
char *prog_name;
void init_error (char *program_name)
{
   prog_name = program_name;
}



/* Print an error message to stderr */

void print_error(const char *fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);

    fprintf(stderr, "%s: ", prog_name);
    vfprintf(stderr, fmt, ap);
    fprintf(stderr, "\n");

    va_end(ap);
}



/* Convert a string to all lower case */

void str_to_lower(char *s)
{
    int     i;
    char    c;

    for(i = 0; (c = s[i]) != '\0'; i++)
        if(isalpha(c))
            if(isupper(c))
                s[i] = (char) tolower(c);
}

#define MAX_PATH_LEN 1024
FILE *fopen_cmpp(const char **path_p, const char *mode)
{
    const char *path = *path_p;

    char buf[MAX_PATH_LEN+1];

    if(path[0] != '/') {
        const char *e = getenv((*mode == 'w') ? "CMPP_ODIR" : "CMPP_IDIR");
        if(e) {
            if(strlen(e) + 1 + strlen(path) < sizeof(buf)) {
                strcpy(buf, e);
                strcat(buf, "/");
                strcat(buf, path);
                path = buf;
            } else {
                path = NULL;
            }
        }
    }

    *path_p = strdup(path);

    return fopen(path, mode);
}


#else /* SIMULATOR */

const bool ft_nutmeg = TRUE;
extern struct comm nutcp_coms[ ];
struct comm *cp_coms = nutcp_coms;
extern IFfrontEnd nutmeginfo;

/* -------------------------------------------------------------------------- */
int
if_run(CKTcircuit *t, char *w, wordlist *s, INPtables *b)
{
    NG_IGNORE(b);
    NG_IGNORE(s);
    NG_IGNORE(w);
    NG_IGNORE(t);

    return (0);
}

/* -------------------------------------------------------------------------- */
int
if_sens_run(CKTcircuit *t, wordlist *args, INPtables *tab)
{
    NG_IGNORE(tab);
    NG_IGNORE(args);
    NG_IGNORE(t);

    return (0);
}

/* -------------------------------------------------------------------------- */
void
if_dump(CKTcircuit *ckt, FILE *fp)
{
    NG_IGNORE(fp);
    NG_IGNORE(ckt);

    return;
}

/* -------------------------------------------------------------------------- */
CKTcircuit *
if_inpdeck(struct line *deck, INPtables **tab)
{
    NG_IGNORE(tab);
    NG_IGNORE(deck);
    return NULL;
}

/* -------------------------------------------------------------------------- */
int
if_option(CKTcircuit *ckt, char *name, enum cp_types type, void *value)
{
    NG_IGNORE(value);
    NG_IGNORE(type);
    NG_IGNORE(name);
    NG_IGNORE(ckt);

    return 0;
}

/* -------------------------------------------------------------------------- */
void if_cktfree(CKTcircuit *ckt, INPtables *tab)
{
    NG_IGNORE(tab);
    NG_IGNORE(ckt);

    return;
}

/* -------------------------------------------------------------------------- */
void if_setndnames(char *line)
{
    NG_IGNORE(line);
}

/* -------------------------------------------------------------------------- */
char *
if_errstring(int code)
{
    NG_IGNORE(code);
    return ("spice error");
}

/* -------------------------------------------------------------------------- */
void
if_setparam_model(CKTcircuit *ckt, char **name, char *val)
{
    NG_IGNORE(val);
    NG_IGNORE(name);
    NG_IGNORE(ckt);

    return;
}

void
if_setparam(CKTcircuit *ckt, char **name, char *param, struct dvec *val, int do_model)
{
    NG_IGNORE(do_model);
    NG_IGNORE(val);
    NG_IGNORE(param);
    NG_IGNORE(name);
    NG_IGNORE(ckt);

    return;
}

/* -------------------------------------------------------------------------- */
bool
if_tranparams(struct circ *ckt, double *start, double *stop, double *step)
{
    NG_IGNORE(step);
    NG_IGNORE(stop);
    NG_IGNORE(start);
    NG_IGNORE(ckt);

    return (FALSE);
}

/* -------------------------------------------------------------------------- */
struct variable *
if_getstat(CKTcircuit *ckt, char *name)
{
    NG_IGNORE(name);
    NG_IGNORE(ckt);

    return (NULL);
}

void com_snload(wordlist *wl) { NG_IGNORE(wl); }
void com_snsave(wordlist *wl) { NG_IGNORE(wl); }

void SMPprint( SMPmatrix *n1 , char *n2)
{
    NG_IGNORE(n1);
    NG_IGNORE(n2);

    return;
}

void SMPprintRHS( SMPmatrix *n1, char *n2 , scalar* n3 , scalar* n4)
{
    NG_IGNORE(n1);
    NG_IGNORE(n2);
    NG_IGNORE(n3);
    NG_IGNORE(n4);

    return;
}

void spice_destroy_devices(void)
{
}

#endif /* SIMULATOR */

#ifndef SIMULATOR

#ifdef XSPICE
/* saj to get nutmeg to compile, not nice but necessary */
Ipc_Tiein_t  g_ipc;
Ipc_Status_t ipc_send_errchk(void ) {
  Ipc_Status_t x = IPC_STATUS_OK;
  return(x);
}
Ipc_Status_t ipc_get_line(char *str , int *len , Ipc_Wait_t wait ){
  Ipc_Status_t x = IPC_STATUS_OK;
  NG_IGNORE(str);
  NG_IGNORE(len);
  NG_IGNORE(wait);

  return(x);
}
struct line *ENHtranslate_poly(struct line *deck){
  NG_IGNORE(deck);
  return(NULL);
}
int load_opus(char *name){
  NG_IGNORE(name);
  return(1);
}
char  *MIFgettok(char **s){
  NG_IGNORE(s);
  return(NULL);
}
void EVTprint(wordlist *wl){
  NG_IGNORE(wl);
  return;
}
struct dvec *EVTfindvec(char *node){
  NG_IGNORE(node);
  return NULL;
}
#endif /* XSPICE */

#endif /* SIMULATOR */

char *hlp_filelist[] = { "ngspice", 0 };


/* allocate space for global constants in 'CONST.h' */

double CONSTroot2;
double CONSTvt0;
double CONSTKoverQ;
double CONSTe;
IFfrontEnd *SPfrontEnd = NULL;
int DEVmaxnum = 0;

/* -------------------------------------------------------------------------- */
/* Set a compatibility flag.
   Currently available are flags for:
   - ngspice (standard)
   - a commercial simulator
   - Spice3
   - all compatibility stuff
*/
COMPATMODE_T ngspice_compat_mode(void)
{
   char behaviour[80] ;

   if( cp_getvar("ngbehavior", CP_STRING, behaviour)){
      if (strcasecmp(behaviour, "all")==0)
         return( COMPATMODE_ALL ) ;
      if (strcasecmp(behaviour, "hs")==0)
         return( COMPATMODE_HS ) ;
      if (strcasecmp(behaviour, "ps")==0)
         return( COMPATMODE_PS ) ;
      if (strcasecmp(behaviour, "spice3")==0)
         return( COMPATMODE_SPICE3 ) ;
   }
   return(COMPATMODE_ALL) ;
} /* end ngspice_compat_mode() */

/* -------------------------------------------------------------------------- */
int
SIMinit(IFfrontEnd *frontEnd, IFsimulator **simulator)
{
#ifdef SIMULATOR
    spice_init_devices();
    SIMinfo.numDevices = DEVmaxnum = num_devices();
    SIMinfo.devices = devices_ptr();
    SIMinfo.numAnalyses = spice_num_analysis();
    SIMinfo.analyses = (IFanalysis **)spice_analysis_ptr(); /* va: we recast, because we use
                                                             * only the public part
                                 */

#ifdef CIDER
/* Evaluates limits of machine accuracy for CIDER */
    evalAccLimits();
#endif /* CIDER */

#endif /* SIMULATOR */

    SPfrontEnd = frontEnd;
    *simulator = &SIMinfo;
    CONSTroot2 = sqrt(2.);
    CONSTvt0 = CONSTboltz * (27 /* deg c */ + CONSTCtoK ) / CHARGE;
    CONSTKoverQ = CONSTboltz / CHARGE;
    CONSTe = exp(1.0);
    return(OK);
}


/* -------------------------------------------------------------------------- */
/* Shutdown gracefully. */
static void
sp_shutdown(int exitval)
{
    destroy_ivars();
#ifdef HAS_WINGUI
    if (exitval == EXIT_BAD)
        winmessage("Fatal error in SPICE");
    else if (exitval == EXIT_INFO)
        winmessage("Information during setup, see main window!");
#endif
    if  (exitval == EXIT_INFO) exitval = EXIT_NORMAL;
    exit (exitval);
}

/* -------------------------------------------------------------------------- */

#if defined(HAVE_GNUREADLINE) || defined(HAVE_BSDEDITLINE)
/* Adapted ../lib/cp/lexical.c:prompt() for GNU Readline -- Andrew Veliath <veliaa@rpi.edu> */
static char *
prompt(void)
{
    static char pbuf[128];
    char *p = pbuf, *s;

    if (cp_interactive == FALSE)
        return NULL;    /* NULL means no prompt */

    s = get_alt_prompt();
    if(s==NULL)
    s = cp_promptstring;
    if(s==NULL)
    s = "->";

    while (*s) {
      switch (strip(*s)) {
        case '!':
#if defined(HAVE_BSDEDITLINE) && 0
          {
            /* SJB In the present version of editline (v2.9)
              it seems that where_history() is broken.
              This is a hack that works round this problem.
              WARNING: It may fail to work in the future
              as it relies on undocumented structure */
            /* some years later, it fails indeed, (v2.11 on debian) */
            int where = 0;
            HIST_ENTRY *he = current_history();
            if(he!=NULL) where = *(int*)(he->data);
            p += sprintf(p, "%d", where + 1);
          }
#else
          p += sprintf(p, "%d", where_history() + 1);
#endif  /* HAVE_BSDEDITLINE*/
          break;
        case '\\':
          if (s[1])
              p += sprintf(p, "%c", strip(*++s));
          default:
              *p = (char) strip(*s); ++p;
          break;
      }
      s++;
    }
    *p = 0;
    return pbuf;
}
#endif /* HAVE_GNUREADLINE || HAVE_BSDEDITLINE */

#ifndef X_DISPLAY_MISSING
#ifdef HAVE_GNUREADLINE
/* -------------------------------------------------------------------------- */
/* Process device events in Readline's hook since there is no where
   else to do it now - AV */
static int
app_event_func(void)
/* called by GNU readline periodically to know what to do about keypresses */
{
    static REQUEST reqst = { char_option, 0 };
    reqst.fp = rl_instream;
    X11_Input(&reqst, NULL);
    return 0;
}
#endif /* HAVE_GNUREADLINE */

#ifdef HAVE_BSDEDITLINE
/* -------------------------------------------------------------------------- */
/* Process device events in Editline's hook.
   similar to the readline function above but returns void */
static void
app_event_func(void)
/* called by GNU readline periodically to know what to do about keypresses */
{
    static REQUEST reqst = { char_option, 0 };
    reqst.fp = rl_instream;
    X11_Input(&reqst, NULL);
}
#endif /* HAVE_BSDEDITLINE */
#endif

/* -------------------------------------------------------------------------- */
/* This is the command processing loop for spice and nutmeg.
   The function is called even when GNU readline is unavailable, in which
   case it falls back to repeatable calling cp_evloop()
   SJB 26th April 2005 */
static void
app_rl_readlines(void)
{
#if defined(HAVE_GNUREADLINE) || defined(HAVE_BSDEDITLINE)
    /* GNU Readline Support -- Andrew Veliath <veliaa@rpi.edu> */
    char *line, *expanded_line;

    /* ---  set up readline params --- */
    strcpy(history_file, getenv("HOME"));
    strcat(history_file, "/.");
    strcat(history_file, application_name);
    strcat(history_file, "_history");

    using_history();
    read_history(history_file);

    rl_readline_name = application_name;
    rl_instream = cp_in;
    rl_outstream = cp_out;
#ifndef X_DISPLAY_MISSING
    if(dispdev->Input == X11_Input)
        rl_event_hook = app_event_func;
#endif
    rl_catch_signals = 0;   /* disable signal handling  */

    /* sjb - what to do for editline?
       This variable is not supported by editline. */
#if defined(HAVE_GNUREADLINE)
    rl_catch_sigwinch = 1;  /* allow readline to respond to resized windows  */
#endif

    /* note that we want some mechanism to detect ctrl-D and expand it to exit */
    for (;;) {
       history_set_pos(history_length);

       if (SETJMP(jbuf, 1))    /* Set location to jump to after handling SIGINT (ctrl-C)  */
           ft_sigintr_cleanup();

       line = readline(prompt());

       if (!line) {
           cp_evloop("quit");
           continue;
       }

       if (*line) {
           int s = history_expand(line, &expanded_line);

           if (s == 2) {
               fprintf(stderr, "-> %s\n", expanded_line);
           } else if (s == -1) {
               fprintf(stderr, "readline: %s\n", expanded_line);
           } else {
               cp_evloop(expanded_line);
               add_history(expanded_line);
           }
           free(expanded_line);
       }

       free(line);
    }
    /* History gets written in ../fte/misccoms.c com_quit */

#else
    while (cp_evloop(NULL) == 1) ;
#endif /* defined(HAVE_GNUREADLINE) || defined(HAVE_BSDEDITLINE) */
}


/* -------------------------------------------------------------------------- */
static void
show_help(void)
{
    printf("Usage: %s [OPTION]... [FILE]...\n"
       "Simulate the electical circuits in FILE.\n"
       "\n"
       "  -a  --autorun             run the loaded netlist\n"
       "  -b, --batch               process FILE in batch mode\n"
       "  -c, --circuitfile=FILE    set the circuitfile\n"
       "  -i, --interactive         run in interactive mode\n"
       "  -n, --no-spiceinit        don't load the local or user's config file\n"
       "  -o, --output=FILE         set the outputfile\n"
       "  -p, --pipe                run in I/O pipe mode\n"
       "  -q, --completion          activate command completion\n"
       "  -r, --rawfile=FILE        set the rawfile output\n"
       "      --soa-log=FILE        set the outputfile for SOA warnings\n"
       "  -s, --server              run spice as a server process\n"
       "  -t, --term=TERM           set the terminal type\n"
       "  -h, --help                display this help and exit\n"
       "  -v, --version             output version information and exit\n"
       "\n"
       "Report bugs to %s.\n", cp_program, Bug_Addr);
}

/* -------------------------------------------------------------------------- */
static void
show_version(void)
{
    printf("%s compiled from %s revision %s\n"
       "Written originally by Berkeley University\n"
       "Currently maintained by the NGSpice Project\n\n"
       "Copyright (C) 1985-1996,"
       "  The Regents of the University of California\n"
       "Copyright (C) 1999-2011,"
       "  The NGSpice Project\n", cp_program, PACKAGE, VERSION);
}

#ifdef SIMULATOR
/* -------------------------------------------------------------------------- */
static void
append_to_stream(FILE *dest, FILE *source)
{
    char buf[BSIZE_SP];
    size_t n;

    while ((n = fread(buf, 1, BSIZE_SP, source)) > 0)
      fwrite(buf, n, 1, dest);
}
#endif /* SIMULATOR */

/* -------------------------------------------------------------------------- */
/* Read an initialisation file.
   dir    is the directory (use NULL or "" for current directory)
   name   is the initialisation file's name
   Return TRUE on success
   SJB 25th April 2005 */
static bool
read_initialisation_file(char *dir, char *name)
{
#ifndef HAVE_UNISTD_H
    FILE *fp = NULL;
#endif /* not HAVE_UNISTD_H */
    char *path;
    bool result = FALSE;

    /* check name */
    if(name==NULL || name[0]=='\0')
        return FALSE;   /* Fail; name needed */

    /* contruct the full path */
    if(dir == NULL || dir[0]=='\0') {
      path = name;
    } else {
#ifdef HAVE_ASPRINTF
      asprintf(&path, "%s" DIR_PATHSEP "%s", dir, name);
      if(path==NULL) return FALSE;    /* memory allocation error */
#else /* ~ HAVE_ASPRINTF */
      path = TMALLOC(char, 2 + strlen(dir) + strlen(name));
      if(path==NULL) return FALSE;    /* memory allocation error */
      sprintf(path, "%s" DIR_PATHSEP "%s", dir, name);
#endif /* HAVE_ASPRINTF */
    }

    /* now access the file */
#ifdef HAVE_UNISTD_H
    if (access(path, R_OK) == 0) {
#else
    if ((fp = fopen(path, "r")) != NULL) {
        (void) fclose(fp);
#endif /* HAVE_UNISTD_H */
        inp_source(path);
#ifdef TRACE
        printf("Init file: '%s'\n", path);
#endif /* TRACE */
        result = TRUE;  /* loaded okay */
    }

    /* if dir was not NULL and not empty then we allocated memory above */
    if(dir!=NULL && dir[0] !='\0')
#ifdef HAVE_ASPRINTF
        free(path);
#else
    tfree(path);
#endif /* HAVE_ASPRINTF */

    return result;
}

/* -------------------------------------------------------------------------- */

static void
print_news(void)
{
    if (News_File && *News_File) {
        char* fname = cp_tildexpand(News_File); /*DG  Memory leak */
        FILE *fp = fopen(fname, "r");
        tfree(fname);
        if (fp) {
            char buf[BSIZE_SP];
            while (fgets(buf, BSIZE_SP, fp))
                fputs(buf, stdout);
            (void) fclose(fp);
        }
    }
}


#ifdef HAS_WINGUI
#define main xmain
#endif
int
main(int argc, char **argv)
{
    char log_file[BSIZE_SP];
    char soa_log_file[BSIZE_SP];
    volatile bool readinit = TRUE;
    bool istty = TRUE;
    bool iflag = FALSE;
    bool qflag = FALSE;
    FILE * volatile circuit_file;
    bool oflag = FALSE;
    bool srflag = FALSE;
    interp=Tcl_CreateInterp();
    Tcl_Init(interp);
    vector_buffer_allocation=1024;
    vector_buffer=(char *)malloc(vector_buffer_allocation);
    network_node_type=net_mode_null;
    Spice_Init(interp);
#ifdef TRACE
    /* this is used to detect memory leaks during debugging */
    /* added by SDB during debug . . . . */
    /* mtrace(); */
#endif

#ifdef TRACE
    /* this is also used for memory leak plugging . . . */
    /* added by SDB during debug . . . . */
    /* mwDoFlush(1); */
#endif

    /* MFB tends to jump to 0 on errors.  This tends to catch it. */
    {
        static int started = 0;
        if (started++) {
            fprintf(cp_err, "main: Internal Error: jump to zero\n");
            sp_shutdown(EXIT_BAD);
        }
    }

#if defined(HAVE_GNUREADLINE) || defined(HAVE_BSDEDITLINE)
    application_name = strrchr(argv[0], '/');
    if (application_name)
        application_name ++;
    else
        application_name = argv[0];
#endif

    ivars(argv[0]);

    cp_in  = stdin;
    cp_out = stdout;
    cp_err = stderr;

    circuit_file = stdin;

#if defined(HAVE_ISATTY) && !defined(HAS_WINGUI)
    istty = (bool) isatty(fileno(stdin));
#endif

    init_time( );

    {
        int rv = SIMinit(&nutmeginfo, &ft_sim);
        if(rv != OK) {
            ft_sperror(rv, "SIMinit");
            sp_shutdown(EXIT_BAD);
        }
    }

    cp_program = ft_sim->simulator;

    srand((unsigned int) getpid());
    TausSeed();
    if (Tcl_Eval(interp,"if {![info exists ::env(RAMSPICE)]} {set ::env(RAMSPICE) [pwd]}")==TCL_ERROR) {
        Tcl_Eval(interp,"puts $errorInfo");
    };
    if (Tcl_Eval(interp,"puts \"RAMSPICE=$::env(RAMSPICE)\"")==TCL_ERROR) {
        Tcl_Eval(interp,"puts $errorInfo");
    };
    Tcl_Eval(interp, "namespace eval " TCLSPICE_namespace " { }");
    /* Get information on memory status upon startup.
       Would like to do this later, but cpinit evals commands.
       fcn is in resource.c */
    init_rlimits( );

    /* Have to initialize cp now.
       fcn is in cpitf.c*/
    ft_cpinit();

    /*register functions*/
    int i;
    char *key;
    char buf[256];
    Tcl_CmdInfo infoPtr;
    register_tcl_functions(interp);
    register_tcl_input_functions(interp);
    init_tcl_gamma(interp);
    register_gamma_functions(interp);
    Tcl_Eval(interp,"set ::argv {}");
    char args_buf[1024*64];
    for (i=0;i<argc;i++) {
        sprintf(args_buf,"lappend ::argv %s",argv[i]);
	Tcl_Eval(interp,args_buf);
    }
    if (Tcl_Eval(interp,"source $::env(RAMSPICE)/.ramspice.tcl")==TCL_ERROR) {
        Tcl_Eval(interp,"puts $errorInfo");
    };
    execute_main_commands(interp,argc,argv);
    
    // Execute stdin input code here:
    ordinal input_code_size=1024*1024;
    char *input_code;
    char c;
    ordinal input_code_index=0;
    input_code=(char *)malloc(sizeof(char)*input_code_size);
    while (!feof(stdin)) {
        if (input_code_index>=input_code_size-1) {
	    char *new_input_code=(char *)malloc(sizeof(char)*input_code_size*2);
	    ordinal i;
	    for (i=0;i<input_code_index;i++) new_input_code[i]=input_code[i];
	    input_code_size*=2;
	    free(input_code);
	    input_code=new_input_code;
	}
	input_code[input_code_index++]=fgetc(stdin);
    }
    input_code[input_code_index]=0;
    if (Tcl_Eval(interp,input_code)==TCL_ERROR) {
        Tcl_Eval(interp,"puts $errorInfo");
    };
    Tcl_Eval(interp,"puts \"Bye! ; exit");
    fflush(stdout);
    exit(0);
}


