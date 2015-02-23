#ifndef CTREE
#define CTREE
#include <tcl.h>
#include <unistd.h>
#include <setjmp.h>
#include <signal.h>
#include "ngspice/config.h"
#include "ngspice/macros.h"
#include "frontend/parser/complete.h"
#include "ngspice/ngspice.h"
//#include "ngspice/sharedspice.h"
#include "ngspice/defines.h"
#include "frontend/signal_handler.h"
#include "frontend/quote.h"
#include "frontend/variable.h"
#include "frontend/plotting/plotting.h"
#include "frontend/plotting/pvec.h"
#include "frontend/numparam/general.h"
#include "frontend/numparam/numparam.h"
#include "ngspice/wordlist.h"
#include <sys/socket.h>
#include <netdb.h>
#include <netinet/in.h>
#include <stdio.h>
#include "ngspice/iferrmsg.h"
#include "ngspice/ftedefs.h"
#include "ngspice/devdefs.h"
#include "spicelib/devices/dev.h"
#include "spicelib/analysis/analysis.h"
#include "misc/ivars.h"
#include "misc/misc_time.h"
#include "data.h"
#include <sys/time.h>
#include <sys/resource.h>
#include <signal.h>
#include <db.h>
#include <time.h>
#include "frontend/outitf.h"
#define TCL_CMDPROCARGS(clientData, interp, argc, argv)                 \
    (ClientData clientData, Tcl_Interp *interp, int argc, CONST84 char *argv[])
#define TCLSPICE_name    "spice"
#define TCLSPICE_prefix  "spice::"
#define TCLSPICE_namespace "spice"
#define TCLSPICE_version "25.1"
#define STDIN_FILENO    0
#define STDOUT_FILENO   1
#define STDERR_FILENO   2
#define DEFAULT_NUM_OF_SUBCONTEXTS 4
#define MIN_IDS 1e-50
#define MAXDIM 10
#define MAXCUBE 1<<MAXDIM
typedef void (*sighandler)(int);

typedef enum {
    rtype_void,
    rtype_string,
    rtype_real,
    rtype_vector,
    rtype_array,
    rtype_structure,
    rtype_function,
    rtype_remote,
    rtype_layout
} RTYPE;

typedef enum {
    ctype_void,
    ctype_integer,
    ctype_character,
    ctype_string,
    ctype_real,
    ctype_array,
    ctype_node
} CTYPE;
typedef struct context context;
struct context {
        context **children;
        context *parent;
	ordinal num_of_children;
	ordinal max_num_of_children;
	ordinal sibling_order;
	CTYPE value_type;
	so_union value;
	char *name;
};


typedef struct node node;
struct node {
        node *children[16];
        RTYPE rtype;
        CTYPE ctype;
	void *value;
	node *structure;
	node *parent;
	node *child;
	node *next;
	node *last;
	char *name;
	int index;
	struct sockaddr_in *remote;
};
typedef union {
   float s;
   ordinal o;
   void *p;
} hit_node;
 
#define HIT_TYPE 0
#define HIT_DIM  1
#define HIT_VALUES  2
#define HIT_CELL  1<<7

#tcl set flag_base 1
#define HIT_DIVIDER 0
#Foreach: flag {FULL_INTERP LIN_INTERP CFULL_INTERP CLIN_INTERP} {
    #tcl set flag_value [expr $flag_base|(1<<7)]
    #define HIT_$flag ${flag_value}
    #tcl set flag_base [expr $flag_base<<1]
}
ordinal array2hit_partial_legend_top[$MAXDIM];
ordinal array2hit_partial_legend_bottom[$MAXDIM];
typedef struct  linear_interpolation_table linear_interpolation_table;
typedef struct {
    char *name; // Identifying string, no longer necessary
    ordinal dim;    // the number of dimensions or the length of size[]
    ordinal size[$::MAXDIM]; // an array of integers, the range of indices per dimension. 
    float *legend[$::MAXDIM]; // an array of arrays of the real values of the coordinates 
    float physical_factor[$::MAXDIM]; // array of factors to convert physical values to indices
    float hypercube_volume;
    ordinal sizer[$::MAXDIM];
    float *content; // The array payload
    ordinal neighbors[1<<$::MAXDIM];
    linear_interpolation_table *LIT;
    hit_node *hit;
    unsigned char *hit_bytecode;
    ordinal hit_bytecode_size;
    float (*interpolate)(void *a,float *coord);
    float (*gamma_interpolate)(void *a);
} LUT;
float global_coord[$MAXDIM];
void serial_LUT(LUT *i_LUT);
void serial_read_LUT(LUT *i_LUT);
typedef enum {
    it_linear,
    it_interaction,
    it_lagrange
} InterpolationType;
typedef struct network_node network_node;
struct network_node {
    char host_ip[32];
    int port;
    network_node *next;
    network_node *last;
};
network_node *network_node_root;
int node_sock;
typedef union {
   float d;
   long l;
} DL;
void delete_context(context *);
void delete_array(LUT *);
LUT *get_LUT(char *i_context);
LUT *get_LUT_quiet(char *i_context);
node *new_node();
context *new_context(context *i_parent, char *i_name,void *i_value,CTYPE i_type);
int resolve_string_char(char i_char,node **i_node);
int resolve_string_token(char *i_token,node **i_node);
int resolve_key(char *i_key,node **i_node,float **array_entry);
void tcl_append_long(Tcl_Interp *interp,long in_int);
void tcl_append_int(Tcl_Interp *interp,int in_int); 
void tcl_append_float(Tcl_Interp *interp,float in_int);
node *add_array_context(char *i_key,node **i_node);
ordinal add_sub_context(context *i_parent,context *i_child);
void map_slice_separation(LUT *a,ordinal **separation);
hit_node *array2hit(LUT *a,ordinal **separation,int degree);
ordinal merge_hit_leaves(hit_node **hit);
ordinal merge_hit_dividers(hit_node **hit);
ordinal count_hit_bytecode(hit_node *hit);
float bc2scalar(unsigned char *c,ordinal index);
ordinal bc2ordinal(unsigned char *c,ordinal index);
void compile_bytecode(hit_node *hit);
hit_node *linearize_hit_leaf(hit_node *hit_t,ordinal *stats);
int hit_enabled;
void list_hit(hit_node *hit,int level);
ordinal merge_dim;
// Tcl Commands
static int get_circuits(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int get_ckt_tree(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int get_ckt_lines(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int set_ckt_lines(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int get_ckt_devices(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int get_spice_data(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int get_vectors(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int get_var(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int set_var(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_fork(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int array_set(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int array_get(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int array_list(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int array_data(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int array_set_legend(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int array_get_legend(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int array_get_dim(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int array_get_size(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int array_linearize(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int alter_param(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int network_mode(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int network_update(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_add_network_node(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int send_task_to_node(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_send_task_to_base(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_ctree(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int eval_task_from_node(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int node_release(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int network_task_done(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int set_param(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int get_Ids(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int LUT2hit(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_enable_hit(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
static int tcl_list_hit (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
float Ids_estimation(float Va,float Vt,float Vgs,float Vds,float WbyL,float temp);

int register_tcl_functions(Tcl_Interp *interp);
node *ctree; 
context *Ctree;
context *Context; 
//node *context; 
int resolve_real_token_less_thit(char *i_token,node **i_node);
int resolve_real_token_greater_thit(char *i_token,node **i_node);
#define CONTEXT_STACK_SIZE 256
#define NETWORK_BEFFER_SIZE 64*1024
#define HOSTNAME_SIZE 64
#define CLIENT_COUNT 1024
node *context_stack[CONTEXT_STACK_SIZE];
int context_stack_pointer;
char my_ip[HOSTNAME_SIZE];
wordlist *args2wordlist(int argc, char **argv);
int my_port;
char base_ip[32];
int base_port;
struct sockaddr_in my_addr;
struct sockaddr_in node_addr;
struct sockaddr_in server_addr;
static int send_task_to_base(char *code);
network_node *get_network_node(int index);
int network_task_handle;
static int set_base_ip(char *host,int port);
int network_loop;
static int init_ip(int temp_port);
static int network_wait_loop(Tcl_Interp *interp);
static int add_network_node (char *host,int port);
static int tcp_send(network_node *n,char *code);
static int tcp_send_no_fork(network_node *n,char *code);
typedef enum {net_mode_null, net_mode_base, net_mode_node} net_mode;
int vector_buffer_allocation;
char *vector_buffer;
net_mode network_node_type;
int execute_main_commands(Tcl_Interp *interp,int argc,char *argv[]);
int Spice_Init(Tcl_Interp *interp);
int SIMinit(IFfrontEnd *frontEnd, IFsimulator **simulator);
float debug_entries[MAXDIM];
int debug_entries_index;
float get_Ids_timer;
ordinal get_Ids_counter;
struct plot *save_slice_base;
int this_process_forked;
#endif


