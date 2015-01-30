#include <stdlib.h>
#include <stdio.h>
#include <math.h>
typedef union {
    float F; 
    int32_t I;
    unsigned char C[4];
} FC;
typedef union {
    double D; 
    unsigned char C[8];
} DC;
void main() {
    FC X;
    X.I=10283<<8;
    X.C[0]=0;
    printf("%d\n",X.I>>8);
    X.F=4.5;
    X.C[0]=0;
    printf("%g\n",X.F);
}

