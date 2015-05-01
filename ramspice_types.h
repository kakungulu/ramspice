#include <tcl.h>
#include <inttypes.h>
#ifndef RAMSPICE_TYPES
#define RAMSPICE_TYPES
int verbose;
    typedef int32_t ordinal;
    typedef float scalar;
    #define NAN_MASK   0xFFF00000
    #define NAN_VALUE   0x7FF00000
    #define NAN_UNMASK 0x000FFFFF
    #define BYTES_PER_SCALAR 4
    #define SCALAR_TO_ORDINAL_CONVERSION_BITS 16
    #define MAX_SCALAR 0X7FEFFFFF
    #define MIN_SCALAR 0XFFEFFFFF
    typedef float half_scalar;
typedef union {
    ordinal o;
    double s;
    unsigned char b[BYTES_PER_SCALAR];
    half_scalar h[2];
    void *v;
} so_union;
ordinal s2o(float i_scalar);
char tcl_print_buffer[1024*1024]; 
Tcl_Interp *interp;
#Foreach: var $::global_c_variables {
    float $var;
}
float log_ten(float x);
typedef union {
    float F; 
    int32_t I; 
    void *P;
    void (*func)();
    unsigned char C[4];
} FC;
typedef union {
    double F; 
    int64_t I; 
    void *P;
    void (*func)();
    unsigned char C[8];
} DC;
#define BYTES_PER_FLOAT 4
#define BYTES_PER_DOUBLE BYTES_PER_FLOAT*2
#else
#Foreach: var $::global_c_variables {
    extern float $var;
}

#endif



