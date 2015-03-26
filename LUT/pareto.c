#include "pareto.h"
PAT *new_pareto(void) {
    PAT *p=(PAT *)malloc(sizeof(PAT));
    p->num_of_entries=0;
    p->max_num_of_entries=0;
    p->properties=NULL;
    p->num_of_properties=0;
    p->num_of_sizes=0;
    p->sizes=NULL;
    p->content=NULL;
}

//    char **properties;
//    char **sizes;
//    float *content;  
//    ordinal num_of_entries;
//    ordinal max_num_of_entries;

void save_pareto(PAT *p,FILE *O) {
    ordinal i=0;
    write_ordinal(O,p->num_of_properties);
    for (i=0;i<p->num_of_properties;i++) write_string(O,p->properties[i]);
    write_ordinal(O,p->num_of_sizes);
    for (i=0;i<p->num_of_sizes;i++) write_string(O,p->sizes[i]);
    write_ordinal(O,p->num_of_entries);
    for (i=0;i<p->num_of_entries;i++) write_float(O,p->content[i]);
}
void load_pareto(PAT *p) {
    ordinal i;
    p->num_of_properties=read_ordinal();
    p->properties=(char **)malloc(sizeof(char *)*p->num_of_properties);
    for (i=0;i<p->num_of_properties;i++) p->properties[i]=copy_string();
    p->num_of_sizes=read_ordinal();
    p->sizes=(char **)malloc(sizeof(char *)*p->num_of_sizes);
    for (i=0;i<p->num_of_sizes;i++) p->sizes[i]=copy_string();
    p->num_of_entries=read_ordinal();
    p->content=(float *)malloc(sizeof(float)*p->num_of_entries*(p->num_of_properties+p->num_of_sizes));
    for (i=0;i<p->num_of_entries*(p->num_of_properties+p->num_of_sizes);i++) p->content[i]=read_float();
}

void add_property(PAT *p,char *name) {
    ordinal num_of_properties=0;
    ordinal v=1;
    if (p->properties==NULL) {
        p->properties=(char **)malloc(sizeof(char *));
	p->properties[0]=strdup(name);
	p->num_of_properties++;
    } else {
        for (num_of_properties=0;num_of_properties<p->num_of_properties;num_of_properties++) if (num_of_properties>v) v*=2;
        if (num_of_properties+1>v) {
	    v*=2;
	    char **new_properties=(char **)malloc(sizeof(char *)*v+1);
	    int j;
	    for (j=0;j<num_of_properties;j++) new_properties[j]=p->properties[j];
	    free(p->properties);
	    p->properties=new_properties;
        }
        p->properties[num_of_properties]=strdup(name);
        p->num_of_properties++;
    }
    float *widened_content=(float *)malloc(sizeof(float)*p->max_num_of_entries*(p->num_of_properties+p->num_of_sizes));
    ordinal i,j;
    for (j=0;j<p->num_of_entries;j++) {
        for (i=0;i<p->num_of_properties-1;i++) widened_content[j*(p->num_of_properties+p->num_of_sizes)+i]=p->content[j*(p->num_of_properties-1+p->num_of_sizes)+i];
	widened_content[j*(p->num_of_properties+p->num_of_sizes)+p->num_of_properties-1]=NAN;
        for (i=0;i<p->num_of_sizes;i++) widened_content[j*(p->num_of_properties+p->num_of_sizes)+p->num_of_properties+i]=p->content[j*(p->num_of_properties-1+p->num_of_sizes)+p->num_of_properties-1+i];
    }
    free(p->content);
    p->content=widened_content;
}
void add_size(PAT *p,char *name) {
    ordinal num_of_sizes=0;
    ordinal v=1;
    if (p->sizes==NULL) {
        p->sizes=(char **)malloc(sizeof(char *));
	p->sizes[0]=strdup(name);
	p->num_of_sizes++;
    } else {
        for (num_of_sizes=0;num_of_sizes<p->num_of_sizes;num_of_sizes++) if (num_of_sizes>v) v*=2;
        if (num_of_sizes+1>v) {
	    v*=2;
	    char **new_sizes=(char **)malloc(sizeof(char *)*v+1);
	    int j;
	    for (j=0;j<num_of_sizes;j++) new_sizes[j]=p->sizes[j];
	    free(p->sizes);
	    p->sizes=new_sizes;
        }
        p->sizes[num_of_sizes]=strdup(name);
        p->num_of_sizes++;
    }
    float *widened_content=(float *)malloc(sizeof(float)*p->max_num_of_entries*(p->num_of_sizes+p->num_of_sizes));
    ordinal i,j;
    for (j=0;j<p->num_of_entries;j++) {
        for (i=0;i<p->num_of_properties;i++) widened_content[j*(p->num_of_properties+p->num_of_sizes)+i]=p->content[j*(p->num_of_sizes-1+p->num_of_properties)+i];
        for (i=0;i<p->num_of_sizes-1;i++) widened_content[j*(p->num_of_sizes+p->num_of_properties)+p->num_of_properties+i]=p->content[j*(p->num_of_sizes-1+p->num_of_properties)+p->num_of_properties+i];
	widened_content[j*(p->num_of_sizes+p->num_of_sizes)+p->num_of_sizes-1]=NAN;
    }
    free(p->content);
    p->content=widened_content;
}
// Need to add the pareto events: dominates, dominated
ordinal add_entry(PAT *p,float *sizes,float *properties) {
    if (p->num_of_entries+1>p->max_num_of_entries) {
        p->max_num_of_entries*=2;
	float *new_content=(float *)malloc(sizeof(float)*p->max_num_of_entries*(p->num_of_properties+p->num_of_sizes));
	ordinal i;
	for (i=0;i<p->num_of_entries*(p->num_of_properties+p->num_of_sizes);i++) new_content[i]=p->content[i];
	free(p->content);
	p->content=new_content;
    }
    ordinal i;
    for (i=0;i<p->num_of_properties;i++) p->content[p->num_of_entries*(p->num_of_properties+p->num_of_sizes)+i]=properties[i];
    for (i=0;i<p->num_of_sizes;i++) p->content[p->num_of_entries*(p->num_of_properties+p->num_of_sizes)+p->num_of_properties+i]=sizes[i];
}

ordinal *filter_front(PAT *p,float *properties) {
    ordinal i,j;
    for (i=0;i<p->num_of_entries;i++) {
        int dominates=1,dominated=1;
	for (j=0;j<p->num_of_properties;j++) {
	     if (properties[j]<p->content[i*(p->num_of_properties+p->num_of_sizes)+j]) dominates=0;
	     if (properties[j]>p->content[i*(p->num_of_properties+p->num_of_sizes)+j]) dominated=0;
	}    
//	if (dominated
    }
}

