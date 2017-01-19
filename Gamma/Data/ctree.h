#ifndef CTREE
#define CTREE
#include <tcl.h>
#include <unistd.h>
#include <setjmp.h>
#include <signal.h>
#include <math.h>
#include "ramspice_types.h"
#include <sys/socket.h>
#include <netdb.h>
#include <netinet/in.h>
#include <stdio.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <signal.h>
#include <time.h>
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
    ctype_LUT,
    ctype_PAT,
    ctype_POLY,
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
    float (*gamma_gradient)(void *a);
} LUT;

#Foreach: type $::vector_types {
    typedef struct {
        $type *content;
	ordinal num_of;
	ordinal max_num_of;
    } vector_$type;
    vector_$type *new_vector_$type();
    void add_entry_vector_$type(vector_$type *v,$type e);
    $type get_entry_vector_$type(vector_$type *v,ordinal i);
    int delete_entry_vector_$type(vector_$type *v,ordinal i);
    void write_vector_$type(FILE *O,vector_$type *v);
    vector_$type *read_vector_$type();
}
typedef struct {
    ordinal id;
    ordinal flags;
    vector_float *sizes;
    vector_float *properties;
} PAT_entry;

void write_pointer_PAT_entry(FILE *O,PAT_entry *p);
PAT_entry *read_pointer_PAT_entry();
#Foreach: type $::vector_pointer_types {
    typedef struct {
        $type **content;
	ordinal num_of;
	ordinal max_num_of;
    } vector_pointer_$type;
    vector_pointer_$type *new_vector_pointer_$type();
    void add_entry_vector_pointer_$type(vector_pointer_$type *v,$type *e);
    $type *get_entry_vector_pointer_$type(vector_pointer_$type *v,ordinal i);
    int delete_entry_vector_pointer_$type(vector_pointer_$type *v,ordinal i);
    void write_vector_pointer_$type(FILE *O,vector_pointer_$type *v);
    vector_pointer_$type *read_vector_pointer_$type();
}
typedef struct {
    ordinal id_counter;
    vector_pointer_PAT_entry *content;
    vector_pointer_char *sizes;
    vector_pointer_char *properties;
    vector_int *factors;
    vector_float *margins;
} PAT;
typedef struct {
    float x;
    float y;
} PAT_graph_pixel;    
int compare_pat_graph_pixels(const void *i, const void *j);
typedef struct POLY POLY;
struct POLY {
    char *expression;
    vector_float *polynomial;
    POLY *denom;
};
PAT *new_PAT();
PAT *get_PAT(char *i_context);
POLY *get_POLY(char *i_context);
void pat_unique(PAT *p,float f);
void write_pointer_PAT(FILE *O,PAT *p);
PAT *read_pointer_PAT();
void pat_graph(FILE *O,PAT *p,int x,int y);
void pat_stars(PAT *p);
POLY *new_POLY();
void link_POLY(POLY *p);
float calc_polynomial(vector_float *p);
float calc_POLY(POLY *p);
float derive_POLY(POLY *p,void *by_var);
float root_POLY(POLY *p,void *by_var,float init);
void write_pointer_POLY(FILE *O,POLY *p);
POLY *read_pointer_POLY();
ordinal add_pat_array(PAT *p,float *sizes,float *properties);
ordinal add_pat_entry(PAT *p,vector_float *sizes,vector_float *properties);

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
PAT *get_PAT(char *i_context);
PAT *get_PAT_quiet(char *i_context);
POLY *get_POLY(char *i_context);
POLY *get_POLY_quiet(char *i_context);
node *new_node();
context *new_context(context *i_parent, char *i_name,CTYPE i_type);
int resolve_string_char(char i_char,node **i_node);
int resolve_string_token(char *i_token,node **i_node);
int resolve_key(char *i_key,node **i_node,float **array_entry);
void tcl_append_long(Tcl_Interp *interp,long in_int);
void tcl_append_int(Tcl_Interp *interp,int in_int); 
void tcl_append_float(Tcl_Interp *interp,float in_int);
node *add_array_context(char *i_key,node **i_node);
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
static int tcl_polish (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
float Ids_estimation(float Va,float Vt,float Vgs,float Vds,float WbyL,float temp);
void expr2polish(char *expr_in,int start,int end);
void expr2derive(char *by,char *expr_in,int start,int end);

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
context *create_context(char *i_key);
int context_stack_pointer;
char my_ip[HOSTNAME_SIZE];
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
float debug_entries[MAXDIM];
int debug_entries_index;
float get_Tcl_timer;
ordinal get_Tcl_counter;
struct plot *save_slice_base;
int this_process_forked;
char *det_calc_M[256][256];
char *det_calc_y[256];
int det_calc_avoid_cols[256];
// General Purpose scratch buffer
char result_buffer[1024*1024*1024];
long result_position;
float (*vos)(float isize,float area);
#endif


