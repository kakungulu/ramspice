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


#ifndef	M_PI
#  define M_PI       3.14159265358979323846
#endif
#ifndef	M_E
#  define M_E  	     2.7182818284590452354
#endif
#ifndef	M_LOG2E
#  define M_LOG2E    1.4426950408889634074
#endif
#ifndef	M_LOG10E
#  define M_LOG10E   0.43429448190325182765
#endif


/*
 *  IEEE Floating point
 */

#define MAX_EXP_ARG	709.0

#ifndef DBL_EPSILON
# define DBL_EPSILON	2.2204460492503131e-16
#endif
#ifndef DBL_MAX
# define DBL_MAX	1.79769313486231e+308
#endif
#ifndef DBL_MIN
# define DBL_MIN	2.22507385850721e-308
#endif
#ifndef SHRT_MAX
# define SHRT_MAX	32766
#endif
#ifndef INT_MAX
# define INT_MAX	2147483646
#endif
#ifndef LONG_MAX
# define LONG_MAX	2147483646
#endif




#else
#Foreach: var $::global_c_variables {
    extern float $var;
}

#endif



