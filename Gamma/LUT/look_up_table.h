#ifndef LOOKUP_TABLE
#define LOOKUP_TABLE
#define SLOPES_BUFFER_SIZE 1024*1024
#include "Gamma/Data/ctree.h"
#include "Gamma/virtual_machine.h"
int get_transistor_bin(LUT *i_a,float L,float W);
struct linear_interpolation_table{
    ordinal dim;    // the number of dimensions or the length of size[]
    ordinal *size; // an array of integers, the number of bits per dimension. 
    ordinal *index_weight; // an array of integers, the index-weight of each dimension.
    ordinal volume; 
    float *baseline;  
    float *inv_step;
    float *content; // The array payload
} ;
float generate_lit(LUT *a,linear_interpolation_table *L,ordinal i_index);
void new_linear_interpolation_table(LUT *a);
typedef struct {
    float lower_margin[$::MAXDIM];
    float upper_margin[$::MAXDIM];
    float hyper_volume;
    float *interpolation_buffer;
} cluster;
#For: {set i 0} {$i<$::MAXDIM} {incr i} {
    float lut_interpolation_$i(void *a,float *coord);
    void lut_gamma_interpolation_$i(void *a);
    void lut_gamma_gradient_$i(void *a);
    float lut_cluster_interpolation_$i(LUT *a,float *coord,cluster **i_cluster);
    float gamma_gcc_interpolate_$i(
        void *i_a
        #For: {set j 0} {$j<$i} {incr j} {
            ,float c$j
	}
    );
    float positive_gamma_gcc_interpolate_$i(
        void *i_a
        #For: {set j 0} {$j<$i} {incr j} {
            ,float c$j
	}
    );
    float negative_gamma_gcc_interpolate_$i(
        void *i_a
        #For: {set j 0} {$j<$i} {incr j} {
            ,float c$j
	}
    );
    float gamma_gcc_interpolateg_$i(
        void *i_a
        #For: {set j 0} {$j<$i} {incr j} {
            ,float c$j
	}
        #For: {set j 0} {$j<$i} {incr j} {
            ,float *p$j
	}
    );
}
void composite_gamma_gcc_interpolate_4(void *i_a_ids,void *i_a_gm,void *i_a_ro,float *gm, float *go, float *Ids,float c0,float c1,float c2,float c3, float c4);
void composite_gamma_gcc_interpolate_2p3(int bin,void *i_a_ids,void *i_a_gm,void *i_a_go,void *i_a_gb,float *gb,float *gm, float *go, float *Ids,float c0,float c1,float c2,float c3, float c4);
float feasibility(
#Foreach: input $::sizer_inputs {
    float $input, 
}
#Foreach: parameter $::sizer_parameters {
    float *$parameter,
    LUT *${parameter}_LUT,
} 
float *Gain, float *Area, float *fc, float tolerance
);
float sizer(
    #Foreach: input {Vgs Vds Vbs L W} {
        float *$input, float min_$input, float max_$input,
    }
    #Foreach: parameter $::sizer_parameters {
        float *$parameter,
	LUT *${parameter}_LUT,
    } 
    float *Gain, float *Area, float *fc, float tolerance
);
extern FC *bytecode_buffer;
extern ordinal bytecode_buffer_index;
#endif

