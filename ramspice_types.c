#include "ramspice_types.h"
#include <stdio.h>
/*
ordinal s2o(float i_scalar) {
    ordinal max=64;
    ordinal min=0;
    while (max-1>min) {
        ordinal mid=(max+min)/2;
        if (mid<i_scalar) {
	    min=mid;
	} else {
	    max=mid;
	}
    }
    return max;
}
*/
ordinal s2o(float i_f) {
    #Info: "s2o %g %ld" i_f (ordinal)(i_f-0.5)
    return *(ordinal *)(&i_f);
}
float log_ten(float x) {
#ifdef SINGLE_PRECISION
    return (log10f(x));
#else
    return (log10(x));
#endif    
}
float absolute(float x) {
#ifdef SINGLE_PRECISION
       return (fabsf(x));
#else
       return (fabs(x));
#endif    
}
