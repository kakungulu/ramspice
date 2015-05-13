#include "ramspice_types.h"
#include <stdio.h>
#include <stdlib.h>
#include "Gamma/Data/ctree.h"
#include "tcl_input.h"
#include "ngspice/ftedefs.h"
#include "ngspice/ifsim.h"
#include "ngspice/inpdefs.h"
#include "ngspice/inpmacs.h"
#include "ngspice/fteext.h"
#include "spicelib/parser/inpxx.h"
#include "ngspice/ngspice.h"
#include "ngspice/ifsim.h"
#include "ngspice/sperror.h"
#include "ngspice/cktdefs.h"
#include "ngspice/hash.h"
#include "spicelib/parser/inp2dot.c"
#Foreach: bsim_version {3v32 4v5} {
    #include "spicelib/devices/bsim${bsim_version}/bsim${bsim_version}def.h"
}
extern struct circ *ft_curckt;

static int
tcl_list_insts (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    if (argc!=1) {
        #Error: "usage: %s " argv[0]
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    struct circ *ckt=ft_curckt;
    int j;
    GENmodel *m;
    GENinstance *inst;
    for (j=0;j<63;j++)
    for (m=ckt->ci_ckt->CKThead[j];m;m=m->GENnextModel)
    for (inst=m->GENinstances;inst;inst=inst->GENnextInstance) {
        Tcl_AppendElement(interp,m->GENmodName);
        Tcl_AppendElement(interp,inst->GENname);
    }	
    return TCL_OK;
}
#Foreach: bsim_version {3v32 4v5} {
static int
tcl_bsim_${bsim_version} (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    struct rusage start;
    struct rusage end;
    getrusage(RUSAGE_SELF,&start);
    if (argc<4) {
        #Error: "usage: %s <inst name> <field> <new value> <required field1>...<required fieldN>" argv[0]
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    struct circ *ckt=ft_curckt;
    int j;
    GENmodel *m;
    GENinstance *inst;
    GENmodel *found_model=NULL;
    BSIM${bsim_version}instance *found_inst=NULL;
    BSIM${bsim_version}InnerCalc *InnerCalc;
    
    for (j=0;j<63;j++)
    for (m=ckt->ci_ckt->CKThead[j];m;m=m->GENnextModel)
    for (inst=m->GENinstances;inst;inst=inst->GENnextInstance) {
        if (strcmp(inst->GENname,argv[1])) continue;
        found_model=m;
        found_inst=(BSIM${bsim_version}instance *)inst;
    }	
    if (!found_inst) {
        #Error: "(%s) Couldn't find instance %s" argv[0] argv[1]
        return TCL_ERROR;
    }
    #Foreach: field [set ::bsim${bsim_version}_structure_fields] {
        if (strcmp("$field",argv[2])==0) found_inst->BSIM${bsim_version}$field=atof(argv[3]);
    }
    int i;
    BSIM${bsim_version}temp(found_model,ckt->ci_ckt);
    for (i=0;i<5;i++) BSIM${bsim_version}load(found_model,ckt->ci_ckt);
    for (i=0;i<argc-4;i++) {
        char *field=argv[i+4];
        #Foreach: field [set ::bsim${bsim_version}_structure_fields] {
            if (strcmp("$field",field)==0) {
                tcl_append_float(interp,found_inst->BSIM${bsim_version}$field);
                continue;
            }
        }
	InnerCalc=get_bsim${bsim_version}_inner_calc(found_inst);
        #Foreach: var [set ::bsim${bsim_version}_internal_calculation_vars] {
            if (strcmp("$var",field)==0) { 
                tcl_append_float(interp,InnerCalc->$var);
                continue;
            }
        }
    }
    getrusage(RUSAGE_SELF,&end);
    get_Tcl_timer+=1000000*(end.ru_utime.tv_sec-start.ru_utime.tv_sec)+end.ru_utime.tv_usec-start.ru_utime.tv_usec;
    get_Tcl_counter++;
    return TCL_OK;
}
}
double get_rand_distribution_uniform(double midval,double radius) {
    double minval=midval-radius;
    double maxval=midval+radius;
    return(rand()*1.0/RAND_MAX*(maxval-minval)+minval);
}
double get_rand_distribution_gauss(double mean,double std) {
    double u1=rand()*1.0/RAND_MAX;
    double u2=rand()*1.0/RAND_MAX;
    double z1=sqrt(-2*log(u1))*cos(2*3.141592656*u2);
    return(z1*std+mean);
}
#Foreach: bsim_version {3v32 4v5} {
static int
tcl_monte_carlo_${bsim_version} (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    if ((argc!=5)&&(argc!=4)) {
        #Error: "usage: %s <iterations> <MC config context> <targets> [<operation>]" argv[0]
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    struct circ *ct=ft_curckt;
    if (ct==NULL) {
        #Error: "(%s) no circuit yet" argv[0]
        return TCL_ERROR;
    }
    CKTcircuit* ckt=ct->ci_ckt;
    ordinal iterations=atol(argv[1]);
    ordinal index;
    context *c;
    if (resolve_context(argv[2],&c,NULL)==0) {
        #Error: "(%s) Can't find context for monte-carlo configuration: %s" argv[0] argv[2]
        return TCL_ERROR;
    }
    int j;
    GENmodel *m;
    GENinstance *inst;
    GENmodel *found_model=NULL;
    BSIM${bsim_version}instance *found_inst=NULL;
    BSIM${bsim_version}InnerCalc *InnerCalc;
    // Structure to hold a distribution per parameter that gets treated as random variable
    typedef struct {
        double (*rand_function)(double,double); // pointer to randomizer funcion
        double *param; // The random variable
        double arg1,arg2; // arguments to the randomizer
    } distribution;
    ordinal num_of_mc_distributions=0;
    ordinal num_of_found_models=0;
    // First, count the number of random variables and models that get analyzed
    for (j=0;j<63;j++)
    for (m=ckt->CKThead[j];m;m=m->GENnextModel) {
        int model_index;
        for (model_index=0;model_index<c->num_of_children;model_index++) {
            if (strcmp(m->GENmodName,c->children[model_index]->name)) continue;
	    num_of_found_models++;
            for (inst=m->GENinstances;inst;inst=inst->GENnextInstance) {
	        // Make sure there's an inner-calculation structure for each BSIM instance
		// Trying to augment BSIM${bsim_version}instance failed! probably because there are redundant declarations somewhere that cause a modified structure to corrupt the database.
		get_bsim${bsim_version}_inner_calc(inst);
	        num_of_mc_distributions+=c->children[model_index]->num_of_children;
	    }	
        }	
    }	
    // Static for now. NGSPICE came with only 62 devices, so 256 places for transistor models should be enough
    GENmodel *found_models[256];
    distribution *mc_distributions=(distribution *)malloc(sizeof(distribution)*num_of_mc_distributions);
    ordinal dist_index=0;
    ordinal model_count=0;
    // Populate the random-variable array with crossed data from MC configuration and the circuit
    for (j=0;j<63;j++)
    for (m=ckt->CKThead[j];m;m=m->GENnextModel) {
        int model_index;
        for (model_index=0;model_index<c->num_of_children;model_index++) {
            if (strcmp(m->GENmodName,c->children[model_index]->name)) continue;
	    found_models[model_count++]=m;
            int k;
	    
            for (inst=m->GENinstances;inst;inst=inst->GENnextInstance) for (k=0;k<c->children[model_index]->num_of_children;k++) {
	        // Support distribution factors that depend on transistor's parameters by copying the parameters' values to the Tcl interpreter.
	        found_inst=(BSIM${bsim_version}instance *)inst;
     	        char value[256];
                #Foreach: field [set ::bsim${bsim_version}_structure_fields] {
		    sprintf(value,"%e",found_inst->BSIM${bsim_version}$field);
		    if (Tcl_SetVar(interp,"BSIM_$field",value,TCL_GLOBAL_ONLY)==TCL_ERROR) {
			return TCL_ERROR;
		    }
	        }
		// General definitions get to be evaluated as free-style Tcl code here:
		//Info: "Evaluating parameters for intance %s of model %s: %s" found_inst->BSIM${bsim_version}name c->children[model_index]->name c->children[model_index]->value.v
	        Tcl_Eval(interp,c->children[model_index]->value.v);
                #Foreach: field [set ::bsim${bsim_version}_structure_fields] {
                    if (strcmp(c->children[model_index]->children[k]->name,"$field")==0) {
                        mc_distributions[dist_index].param=&(found_inst->BSIM${bsim_version}$field);
                        #Foreach: distribution {gauss uniform} {
                            if (strcmp(c->children[model_index]->children[k]->children[0]->value.v,"$distribution")==0) {
			        #Info: "Assigning distribution $distribution to instance param %s" c->children[model_index]->children[k]->name 
			        mc_distributions[dist_index].rand_function=get_rand_distribution_$distribution;
			    }	
                        }
			// In most cases, the mean value of the distribution comes from the circuit itself.
			if (strcmp(c->children[model_index]->children[k]->children[1]->value.v,"*")==0) {
			    mc_distributions[dist_index].arg1=found_inst->BSIM${bsim_version}$field;
			} else {
                            Tcl_ExprDouble(interp,c->children[model_index]->children[k]->children[1]->value.v,&(mc_distributions[dist_index].arg1));
			}
			// The stddev comes from the configuration. There may be a need to replace the double with a formula support.
			Tcl_ExprDouble(interp,c->children[model_index]->children[k]->children[2]->value.v,&(mc_distributions[dist_index].arg2));
			//Info: "Distribution %s=%s(%e,%e)" c->children[model_index]->children[k]->name c->children[model_index]->children[k]->children[0]->value.v mc_distributions[dist_index].arg1 mc_distributions[dist_index].arg2
                        dist_index++;
                    }
                }
                #Foreach: field [set ::bsim${bsim_version}_model_fields] {
                    if (strcmp(c->children[model_index]->children[k]->name,"$field")==0) {
                        mc_distributions[dist_index].param=&(found_inst->BSIM${bsim_version}modPtr->BSIM${bsim_version}$field);
                        #Foreach: distribution {gauss uniform} {
                            if (strcmp(c->children[model_index]->children[k]->children[0]->value.v,"$distribution")==0) {
			        #Info: "Assigning distribution $distribution to model param %s" c->children[model_index]->children[k]->name 
			        mc_distributions[dist_index].rand_function=get_rand_distribution_$distribution;
			    }	
                        }
			// In most cases, the mean value of the distribution comes from the circuit itself.
			if (strcmp(c->children[model_index]->children[k]->children[1]->value.v,"*")==0) {
			    mc_distributions[dist_index].arg1=found_inst->BSIM${bsim_version}modPtr->BSIM${bsim_version}$field;
			} else {
                            Tcl_ExprDouble(interp,c->children[model_index]->children[k]->children[1]->value.v,&(mc_distributions[dist_index].arg1));
			}
			// The stddev comes from the configuration. There may be a need to replace the double with a formula support.
			Tcl_ExprDouble(interp,c->children[model_index]->children[k]->children[2]->value.v,&(mc_distributions[dist_index].arg2));
			//Info: "Distribution %s=%s(%e,%e)" c->children[model_index]->children[k]->name c->children[model_index]->children[k]->children[0]->value.v mc_distributions[dist_index].arg1 mc_distributions[dist_index].arg2
                        dist_index++;
                    }
                }
            }
        }	
    }	
    // The data MC collects statistics on is parsed here
    int ARGC;
    char **ARGV;
    Tcl_SplitList(interp,argv[3],&ARGC,&ARGV);
    if (ARGC%2) {
        #Error: "(%s) Statistical targets list require an even-length list <inst1> <field1>...<instN> <fieldN>" argv[0]
        free(ARGV);
        return TCL_ERROR;
    }
    // Allocate space for the statistics
    double **targets=(double **)malloc(sizeof(double *)*ARGC/2);
    double *stats=(double *)malloc(sizeof(double)*iterations*ARGC/2);
    int k;
    ordinal target_index=0;
    // Gather pointers to the statistics data points
    for (k=0;k<ARGC;k+=2) {
        char *inst_name=ARGV[k];
        char *field_name=ARGV[k+1];
        for (j=0;j<63;j++)
        for (m=ckt->CKThead[j];m;m=m->GENnextModel)
        for (inst=m->GENinstances;inst;inst=inst->GENnextInstance) {
            if (strcmp(inst->GENname,inst_name)) continue;
	    found_inst=(BSIM${bsim_version}instance *)inst;
	    #Foreach: field [set ::bsim${bsim_version}_structure_fields] {
	        if (strcmp("$field",field_name)==0) targets[k/2]=&(found_inst->BSIM${bsim_version}$field);
	    }
	    InnerCalc=get_bsim${bsim_version}_inner_calc(found_inst);
            #Foreach: var [set ::bsim${bsim_version}_internal_calculation_vars] {
                if (strcmp("$var",field_name)==0) targets[k/2]=&(InnerCalc->$var); 
            }
        }	
    }
    free(ARGV);
    #Info: "Running Monte Carlo analysis.  %d parameters, %d statistical data points, population size=%d" num_of_mc_distributions ARGC/2 iterations
    // The run itself
    int percent_done=0;
    for (index=0;index<iterations;index++) {
        if (index*10/iterations>percent_done) {
	    percent_done=index*10/iterations;
            #Info: "%d%% done" percent_done*10
	}
        for (j=0;j<num_of_mc_distributions;j++) {
	    *(mc_distributions[j].param)=((mc_distributions[j].rand_function))(mc_distributions[j].arg1,mc_distributions[j].arg2);
	}    
	if (argc==5) {
	    if (Tcl_Eval(interp,argv[4])==TCL_ERROR) {
	        Tcl_Eval(interp,"Error: $::errorInfo");
		return TCL_ERROR;
	    }
	} else {
	    int k;
	    for (k=0;k<num_of_found_models;k++) {
               BSIM${bsim_version}temp(found_models[k],ckt);
	       int i;
               for (i=0;i<5;i++) BSIM${bsim_version}load(found_models[k],ckt);
	    }
	}
	for (j=0;j<ARGC/2;j++) stats[ARGC*index/2+j]=*(targets[j]);
    }
    // Calculate average and stddev for each data point
    for (j=0;j<ARGC/2;j++) {
       double average=0;
       for (index=0;index<iterations;index++) average+=stats[ARGC*index/2+j];
       average/=iterations;
       double stddev=0;
       for (index=0;index<iterations;index++) stddev+=(stats[ARGC*index/2+j]-average)*(stats[ARGC*index/2+j]-average);
       stddev/=iterations;
       stddev=sqrt(stddev);
       tcl_append_float(interp,average);
       tcl_append_float(interp,stddev);
    }
    free(stats);
    free(targets);
    return TCL_OK;  
}
}
#Foreach: command $::dot_commands {
    //    static int dot_$command(char *line, CKTcircuit *ckt, INPtables *tab, card *current,TSKtask *task, CKTnode *gnode, JOB *foo);
    static int
    tcl_dot_$command (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
        if (argc<2) {
            printf("Error: usage: %s <arg0>...<argN> \n",argv[0]);
            return TCL_ERROR;
        }
        Tcl_ResetResult(interp);
        int i;
        int length=0;
        for (i=1;i<argc;i++) length+=strlen(argv[i])+1;
        char type=argv[1][0];
        if ((type<='Z')&&(type>='A')) type+='z'-'Z';
        struct circ *ckt=ft_curckt; 
        GENinstance *fast=NULL;
        CKTnode *gnode;
        CKTfndNode(ckt->ci_ckt, &gnode, "0");
        INPtables *tab=ckt->ci_symtab;
        card c;
        c.line=(char *)malloc(sizeof(char)*length);
        int pos=0;
        for (i=1;i<argc;i++) pos+=sprintf(&(c.line[pos]),"%s ",argv[i]);
        JOB *foo = NULL;
        dot_$command(c.line,ckt->ci_ckt,tab,&c,ckt->ci_defTask,gnode,ckt->ci_ckt->CKTcurJob);
        return TCL_OK;
    }
}
static int
tcl_fe_add_instance (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    if (argc<2) {
        printf("Error: usage: %s <device name> [<arg1>...<argN>] \n",argv[0]);
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    int i;
    int length=0;
    for (i=1;i<argc;i++) length+=strlen(argv[i])+1;
    char type=argv[1][0];
    if ((type<='Z')&&(type>='A')) type+='z'-'Z';
    struct circ *ckt=ft_curckt; 
    GENinstance *fast=NULL;
    CKTnode *gnode;
    CKTfndNode(ckt->ci_ckt, &gnode, "0");
    INPtables *tab=ckt->ci_symtab;
    nghash_func_t *hash_func=ckt->ci_ckt->DEVnameHash->hash_func;
    ckt->ci_ckt->DEVnameHash->hash_func=NGHASH_FUNC_STR;
    nghash_compare_func_t *comp_func=ckt->ci_ckt->DEVnameHash->compare_func;
    ckt->ci_ckt->DEVnameHash->compare_func=NGHASH_DEF_CMP(NGHASH_FUNC_STR);
    // Maybe this call is to modify a device:
    fast=nghash_find(ckt->ci_ckt->DEVnameHash,argv[1]);
    if (fast) {
        #Info: "(%s) Device %s exists. Modifying %s" argv[0] argv[1] argv[2]
        IFvalue ptemp;
        if (argc!=4) {
            #Error: "(%s) Device %s exists. To modify value, use %s %s <field> <new value>" argv[0] argv[1] argv[0] argv[1]
            return TCL_ERROR;
        }
        int type=fast->GENmodPtr->GENmodType;
        ptemp.rValue=atof(argv[3]);
        INPpName(argv[2], &ptemp, ckt, type, fast);
        return TCL_OK;
    }
    //Nope, this is a new device. Use lowlevel parser from here on.
    card c;
    c.line=(char *)malloc(sizeof(char)*length);
    int pos=0;
    for (i=1;i<argc;i++) pos+=sprintf(&(c.line[pos]),"%s ",argv[i]);
    switch(type) {
        //       case 'a': INP2A(ckt->ci_ckt,tab,&c); break;
        case 'b': INP2B(ckt->ci_ckt,tab,&c); break;
        case 'c': INP2C(ckt->ci_ckt,tab,&c); break;
        case 'd': INP2D(ckt->ci_ckt,tab,&c); break;
        case 'e': INP2E(ckt->ci_ckt,tab,&c); break;
        case 'f': INP2F(ckt->ci_ckt,tab,&c); break;
        case 'g': INP2G(ckt->ci_ckt,tab,&c); break;
        case 'h': INP2H(ckt->ci_ckt,tab,&c); break;
        case 'i': INP2I(ckt->ci_ckt,tab,&c); break;
        case 'j': INP2J(ckt->ci_ckt,tab,&c); break;
        case 'k': INP2K(ckt->ci_ckt,tab,&c); break;
        case 'l': INP2L(ckt->ci_ckt,tab,&c); break;
        case 'm': INP2M(ckt->ci_ckt,tab,&c); break;
        //       case 'n': INP2N(ckt->ci_ckt,tab,&c); break;
        case 'o': INP2O(ckt->ci_ckt,tab,&c); break;
        case 'p': INP2P(ckt->ci_ckt,tab,&c); break;
        case 'q': INP2Q(ckt->ci_ckt,tab,&c,gnode); break;
        case 'r': INP2R(ckt->ci_ckt,tab,&c); break;
        case 's': INP2S(ckt->ci_ckt,tab,&c); break;
        case 't': INP2T(ckt->ci_ckt,tab,&c); break;
        case 'u': INP2U(ckt->ci_ckt,tab,&c); break;
        case 'v': INP2V(ckt->ci_ckt,tab,&c); break;
        case 'w': INP2W(ckt->ci_ckt,tab,&c); break;
        //       case 'x': INP2X(ckt->ci_ckt,tab,&c); break;
        case 'y': INP2Y(ckt->ci_ckt,tab,&c); break;
        case 'z': INP2Z(ckt->ci_ckt,tab,&c); break;
        default: printf("Error: (%s) Doesn't have any use for %c\n",argv[0],type);
    }
    free(c.line);
    ckt->ci_ckt->DEVnameHash->hash_func=hash_func;
    ckt->ci_ckt->DEVnameHash->compare_func=comp_func;
    return TCL_OK;  
}
static int
tcl_sweep (ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
    if (argc!=4) {
        printf("Error: usage: %s { <var1> <field1>...<varN> <fieldN>} {<value1>...<valueN>} <result_vector_name>\n",argv[0]);
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    Tcl_Eval(interp,"::spice::op"); 
    int ARGC;
    char **ARGV;
    struct circ *ckt=ft_curckt;
    Tcl_SplitList(interp,argv[1],&ARGC,&ARGV);
    if (ARGC%2) {
        printf("Error: (%s) first argument must be an even-length list of vars and fields. \n",argv[0]);
        return TCL_ERROR;
    }
    int NumOfVars=ARGC/2;
    int *type=(int *)malloc(sizeof(int)*NumOfVars);
    int *parameter_id=(int *)malloc(sizeof(int)*NumOfVars);
    GENinstance **fast=(GENinstance **)malloc(sizeof(GENinstance *)*NumOfVars);
    int i,j;
    for (i=0;i<NumOfVars;i++) {
        fast[i]=NULL;
        char *device=ARGV[2*i];
        char *parm=ARGV[2*i+1];
        CKTnode *gnode;
        CKTfndNode(ckt->ci_ckt, &gnode, "0");
        INPtables *tab=ckt->ci_symtab;
        nghash_func_t *hash_func=ckt->ci_ckt->DEVnameHash->hash_func;
        ckt->ci_ckt->DEVnameHash->hash_func=NGHASH_FUNC_STR;
        nghash_compare_func_t *comp_func=ckt->ci_ckt->DEVnameHash->compare_func;
        ckt->ci_ckt->DEVnameHash->compare_func=NGHASH_DEF_CMP(NGHASH_FUNC_STR);
        // Maybe this call is to modify a device:
        fast[i]=nghash_find(ckt->ci_ckt->DEVnameHash,device);
        ckt->ci_ckt->DEVnameHash->hash_func=hash_func;
        ckt->ci_ckt->DEVnameHash->compare_func=comp_func;
        if (!fast[i]) {
            printf("Error: (%s) device %s not found\n",argv[0],device);
            printf("     Available devices:\n");
            int j;
            for (j=0;ckt->ci_ckt->CKThead[j];j++) {
                GENmodel *m=ckt->ci_ckt->CKThead[j];
                while (m) {
                    GENinstance *inst=m->GENinstances;
                    while (inst) {
                        printf("        %s\n",inst->GENname);
                        inst=inst->GENnextInstance;
                    }
                    m=m->GENnextModel;
                }
            }
            exit;
            return TCL_ERROR;
        }
        IFvalue ptemp;
        if (argc!=4) {
            printf("Error: (%s) Device %s exists. To modify value, use %s %s <field> <new value>\n",argv[0],argv[1],argv[0],argv[1]);
            return TCL_ERROR;
        }
        type[i]=fast[i]->GENmodPtr->GENmodType;
        parameter_id[i]=-1;
        for (j=0;j < *(ft_sim->devices[type[i]]->numInstanceParms); j++) {
            if (strcmp(parm,ft_sim->devices[type[i]]->instanceParms[j].keyword) == 0) {
                parameter_id[i]=ft_sim->devices[type[i]]->instanceParms[j].id;
                break;
            }
        }   
        if (parameter_id[i]==-1) {
            printf("Error: (%s) parameter %s not found for device %s\n",argv[0],parm,device);
            printf("     Available parameters:\n");
            for (j=0;j < *(ft_sim->devices[type[i]]->numInstanceParms); j++) {
                printf("         %s\n",ft_sim->devices[type[i]]->instanceParms[j].keyword);
            }
            return TCL_ERROR;
        }
    }
    Tcl_SplitList(interp,argv[2],&ARGC,&ARGV);
    if (ARGC%NumOfVars) {
        printf("Error: (%s) second argument must be a list of length which is a multiplication of NumOfVars=%d\n",argv[0],NumOfVars);
        return TCL_ERROR;
    }
    char *vector_name=argv[3];
    struct dvec *d=plot_cur->pl_dvecs;
    struct dvec *V=NULL;
    while (d) {
        if(strcmp(vector_name,d->v_name)==0) { V=d; break;}
        d = d->v_next;
    }
    if (V==NULL) {
        printf("Error: (%s) did not get a valid vector name %s\n",argv[0],vector_name);
        printf("     Available vectors:\n");
        d=plot_cur->pl_dvecs;
        while (d) {
            printf("	 %s\n",d->v_name);
            d = d->v_next;
        }
        return TCL_ERROR;
    }
    double *results=(double *)malloc(sizeof(double)*(ARGC/NumOfVars));
    for (i=0;i<ARGC;i+=NumOfVars) {
        for (j=0;j<NumOfVars;j++) {
            int k=i+j;
            IFvalue value;
            value.rValue=atof(ARGV[k]);
            ft_sim->setInstanceParm (ckt->ci_ckt, fast[j], parameter_id[j], &value, NULL);
        }
        Tcl_Eval(interp,"::spice::op"); 
        d=plot_cur->pl_dvecs;
        while (d) {
            if(strcmp(vector_name,d->v_name)==0) { 
                results[i/NumOfVars]=d->v_realdata[0];
                break;
            }
            d = d->v_next;
        }
        if (!d) {
            printf("Error: (%s) did not get a valid vector name %s in iteration %d\n",argv[0],vector_name,i/NumOfVars);
            return TCL_ERROR;
        }
    }
    for (i=0;i<ARGC/NumOfVars;i++) tcl_append_float(interp,results[i]);
    free(results);
    return TCL_OK;
}
int register_tcl_input_functions(Tcl_Interp *interp) {
    Tcl_CreateCommand(interp, "list_insts", tcl_list_insts, NULL, NULL);
    #Foreach: bsim_version {3v32 4v5} {
        Tcl_CreateCommand(interp, "bsim_${bsim_version}", tcl_bsim_${bsim_version}, NULL, NULL);
        Tcl_CreateCommand(interp, "monte_carlo_${bsim_version}", tcl_monte_carlo_${bsim_version}, NULL, NULL);
    }
    Tcl_CreateCommand(interp, "add_instance", tcl_fe_add_instance, NULL, NULL);
    Tcl_CreateCommand(interp, "sweep", tcl_sweep, NULL, NULL);
    #Foreach: command $::dot_commands {
        Tcl_CreateCommand(interp, "dot_$command", tcl_dot_$command, NULL, NULL);
    }
}



