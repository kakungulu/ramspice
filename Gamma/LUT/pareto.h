#ifndef PARETO_TABLES
#define PARETO_TABLES
#include "ramspice_types.h"
#include <math.h>
typedef struct {
    char **properties;
    ordinal num_of_properties;
    char **sizes;
    ordinal num_of_sizes;
    float *content;  
    ordinal num_of_entries;
    ordinal max_num_of_entries;
} PAT;

void save_pareto(PAT *p,FILE *O);
void load_pareto(PAT *p);
void add_property(PAT *p,char *name);
void add_size(PAT *p,char *name);
ordinal add_entry(PAT *p,float *sizes,float *properties);
PAT *new_pareto(void);
ordinal *filter_front(PAT *p,float *properties);
#endif
