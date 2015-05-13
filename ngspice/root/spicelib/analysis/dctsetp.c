#include "ramspice_types.h"
/**********
Copyright 1990 Regents of the University of California.  All rights reserved.
Author: 1985 Thomas L. Quarles
**********/

#include "ngspice/ngspice.h"
#include "ngspice/ifsim.h"
#include "ngspice/iferrmsg.h"
#include "ngspice/trcvdefs.h"
#include "ngspice/cktdefs.h"

#include "analysis.h"

/* ARGSUSED */
int 
DCTsetParm(CKTcircuit *ckt, JOB *anal, int which, IFvalue *value)
{
    TRCV *job = (TRCV *) anal;

    NG_IGNORE(ckt);
    switch(which) {
#For: {set i 0} {$i<$::ANALYSIS_NESTING_DEPTH} {incr i} {
    #tcl set j [expr $i+1]
    case DCT_START$j:
        job->TRCVvStart[$i] = value->rValue;
        job->TRCVnestLevel = MAX($i, job->TRCVnestLevel);
        job->TRCVset[$i] = TRUE;
        break;

    case DCT_STOP$j:
        job->TRCVvStop[$i] = value->rValue;
        job->TRCVnestLevel = MAX($i, job->TRCVnestLevel);
        job->TRCVset[$i] = TRUE;
        break;

    case DCT_STEP$j:
        job->TRCVvStep[$i] = value->rValue;
        job->TRCVnestLevel = MAX($i, job->TRCVnestLevel);
        job->TRCVset[$i] = TRUE;
        break;

    case DCT_NAME$j:
        job->TRCVvName[$i] = value->uValue;
        job->TRCVnestLevel = MAX($i, job->TRCVnestLevel);
        job->TRCVset[$i] = TRUE;
        break;

    case DCT_TYPE$j:
        job->TRCVvType[$i] = value->iValue;
        job->TRCVnestLevel = MAX($i, job->TRCVnestLevel);
        job->TRCVset[$i] = TRUE;
        break;
}

    default:
        return(E_BADPARM);
    }
    return(OK);
}


static IFparm DCTparms[] = {
#For: {set i 1} {$i<=$::ANALYSIS_NESTING_DEPTH} {incr i} {
    { "start$i",     DCT_START$i, IF_SET|IF_REAL,     "starting voltage/current"},
    { "stop$i",      DCT_STOP$i,  IF_SET|IF_REAL,     "ending voltage/current" },
    { "step$i",      DCT_STEP$i,  IF_SET|IF_REAL,     "voltage/current step" },
    { "name$i",      DCT_NAME$i,  IF_SET|IF_INSTANCE, "name of source to step" },
    { "type$i",      DCT_TYPE$i,  IF_SET|IF_INTEGER,  "type of source to step" },
}
};

SPICEanalysis DCTinfo  = {
    { 
        "DC",
        "D.C. Transfer curve analysis",

        NUMELEMS(DCTparms),
        DCTparms
    },
    sizeof(TRCV),
    SWEEPDOMAIN,
    1,
    DCTsetParm,
    DCTaskQuest,
    NULL,
    DCtrCurv
};


