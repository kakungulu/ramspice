#ifndef MATRIX_ENGINE
#define MATRIX_ENGINE
typedef struct {
    float coef;
    vector_int *vars;
    void *next;
} POLY_LINK;
POLY_LINK *new_poly_link(float coef,int var);
typedef struct {
    int size;
    POLY_LINK **M;
    vector_pointer_char *matrix_variables;
} MATRIX;
MATRIX *MAT;
#endif
