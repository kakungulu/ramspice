#include "ramspice_types.h"

/*
 * Structures for model: real_delay
 *
 * Automatically generated by cmpp preprocessor
 *
 * !!! DO NOT EDIT !!!
 *
 */


#include "ngspice/ngspice.h"
#include <stdio.h>
#include "ngspice/devdefs.h"
#include "ngspice/ifsim.h"
#include "ngspice/mifdefs.h"
#include "ngspice/mifproto.h"
#include "ngspice/mifparse.h"


static IFparm MIFmPTable[] = {
    IOP("delay", 0, IF_REAL, "delay from clk to out"),
};


static Mif_Port_Type_t MIFportEnum0[] = {
	MIF_USER_DEFINED,
};


static char *MIFportStr0[] = {
	"real",
};


static Mif_Port_Type_t MIFportEnum1[] = {
	MIF_DIGITAL,
};


static char *MIFportStr1[] = {
	"d",
};


static Mif_Port_Type_t MIFportEnum2[] = {
	MIF_USER_DEFINED,
};


static char *MIFportStr2[] = {
	"real",
};


static Mif_Conn_Info_t MIFconnTable[] = {
  {
    "in",
    "input",
    MIF_IN,
    MIF_USER_DEFINED,
    "real",
    1,
    MIFportEnum0,
    MIFportStr0,
    MIF_FALSE,
    MIF_FALSE,
    0,
    MIF_FALSE,
    0,
    MIF_FALSE,
  },
  {
    "clk",
    "clock",
    MIF_IN,
    MIF_DIGITAL,
    "d",
    1,
    MIFportEnum1,
    MIFportStr1,
    MIF_FALSE,
    MIF_FALSE,
    0,
    MIF_FALSE,
    0,
    MIF_FALSE,
  },
  {
    "out",
    "output",
    MIF_OUT,
    MIF_USER_DEFINED,
    "real",
    1,
    MIFportEnum2,
    MIFportStr2,
    MIF_FALSE,
    MIF_FALSE,
    0,
    MIF_FALSE,
    0,
    MIF_FALSE,
  },
};


static Mif_Param_Info_t MIFparamTable[] = {
  {
    "delay",
    "delay from clk to out",
    MIF_REAL,
    MIF_TRUE,
    {MIF_FALSE, 0, 1.000000e-09, {0.0, 0.0}, NULL},
    MIF_TRUE,
    {MIF_FALSE, 0, 1.000000e-15, {0.0, 0.0}, NULL},
    MIF_FALSE,
    {MIF_FALSE, 0, 0.0, {0.0, 0.0}, NULL},
    MIF_FALSE,
    MIF_FALSE,
    0,
    MIF_FALSE,
    0,
    MIF_FALSE,
    0,
    MIF_TRUE,
  },
};


extern void ucm_real_delay(Mif_Private_t *);

static int val_terms             = 0;
static int val_numNames          = 0;
static int val_numInstanceParms  = 0;
static int val_numModelParms     = 1;
static int val_sizeofMIFinstance = sizeof(MIFinstance);
static int val_sizeofMIFmodel    = sizeof(MIFmodel);

SPICEdev ucm_real_delay_info = {
    { "real_delay",
      "A Z ** -1 block working on real data",
      &val_terms,
      &val_numNames,
      NULL,
      &val_numInstanceParms,
      NULL,
      &val_numModelParms,
      MIFmPTable,
      ucm_real_delay,
      3,
      MIFconnTable,
      1,
      MIFparamTable,
      0,
      NULL,
      0,         /* flags */
    },
NULL,          
MIFmParam,     
MIFload,       
MIFsetup,      
MIFunsetup,    
NULL,          
NULL,          
MIFtrunc,      
NULL,          
MIFload,       
NULL,          
MIFdestroy,    
MIFmDelete,    
MIFdelete,     
NULL,          
MIFask,        
MIFmAsk,       
NULL,          
MIFconvTest,   
NULL,          
NULL,          
NULL,          
NULL,          
NULL,          
NULL,          
NULL,          
NULL,          
NULL,          
#ifdef CIDER   
NULL,          
NULL,          
#endif         
&val_sizeofMIFinstance,
&val_sizeofMIFmodel,

};



