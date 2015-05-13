#include "ramspice_types.h"
/**********
Copyright 1990 Regents of the University of California.  All rights reserved.
Author: 1987 Gary W. Ng
Modified: 2000 AlansFixes
**********/

#include "ngspice/ngspice.h"
#include "mos1defs.h"
#include "ngspice/cktdefs.h"
#include "ngspice/iferrmsg.h"
#include "ngspice/noisedef.h"
#include "ngspice/suffix.h"

/*
* MOS1noise (mode, operation, firstModel, ckt, data, OnDens)
*    This routine names and evaluates all of the noise sources
*    associated with MOSFET's.  It starts with the model *firstModel and
*    traverses all of its insts.  It then proceeds to any other models
*    on the linked list.  The total output noise density generated by
*    all of the MOSFET's is summed with the variable "OnDens".
*/


int
MOS1noise (int mode, int operation, GENmodel *genmodel, CKTcircuit *ckt,
Ndata *data, double *OnDens)
{
    NOISEAN *job = (NOISEAN *) ckt->CKTcurJob;
    
    MOS1model *firstModel = (MOS1model *) genmodel;
    MOS1model *model;
    MOS1instance *inst;
    char name[N_MXVLNTH];
    double coxSquared;
    double tempOnoise;
    double tempInoise;
    double noizDens[MOS1NSRCS];
    double lnNdens[MOS1NSRCS];
    int i;
    
    /* define the names of the noise sources */
    
    static char *MOS1nNames[MOS1NSRCS] = {       /* Note that we have to keep the order */
        "_rd",              /* noise due to rd */        /* consistent with thestrchr definitions */
        "_rs",              /* noise due to rs */        /* in MOS1defs.h */
        "_id",              /* noise due to id */
        "_1overf",          /* flicker (1/f) noise */
        ""                  /* total transistor noise */
    };
    
    for (model=firstModel; model != NULL; model=model->MOS1nextModel) {
        
        /* Oxide capacitance can be zero in MOS level 1.  Since this will give us problems in our 1/f */
        /* noise model, we ASSUME an actual "tox" of 1e-7 */
        
        if (model->MOS1oxideCapFactor == 0.0) {
            coxSquared = 3.9 * 8.854214871e-12 / 1e-7;
        } else {
            coxSquared = model->MOS1oxideCapFactor;
        }
        coxSquared *= coxSquared;
        for (inst=model->MOS1instances; inst != NULL; inst=inst->MOS1nextInstance) {
            
            switch (operation) {
                
                case N_OPEN:
                
                /* see if we have to to produce a summary report */
                /* if so, name all the noise generators */
                
                if (job->NStpsSm != 0) {
                    switch (mode) {
                        
                        case N_DENS:
                        for (i=0; i < MOS1NSRCS; i++) {
                            (void)sprintf(name,"onoise_%s%s",inst->MOS1name,MOS1nNames[i]);
                            
                            data->namelist = TREALLOC(IFuid, data->namelist, data->numPlots + 1);
                            if (!data->namelist) return(E_NOMEM);
                            SPfrontEnd->IFnewUid (ckt,
                            &(data->namelist[data->numPlots++]),
                            NULL, name, UID_OTHER, NULL);
                            /* we've added one more plot */
                            
                            
                        }
                        break;
                        
                        case INT_NOIZ:
                        for (i=0; i < MOS1NSRCS; i++) {
                            (void)sprintf(name,"onoise_total_%s%s",inst->MOS1name,MOS1nNames[i]);
                            
                            
                            data->namelist = TREALLOC(IFuid, data->namelist, data->numPlots + 1);
                            if (!data->namelist) return(E_NOMEM);
                            SPfrontEnd->IFnewUid (ckt,
                            &(data->namelist[data->numPlots++]),
                            NULL, name, UID_OTHER, NULL);
                            /* we've added one more plot */
                            
                            
                            (void)sprintf(name,"inoise_total_%s%s",inst->MOS1name,MOS1nNames[i]);
                            
                            
                            data->namelist = TREALLOC(IFuid, data->namelist, data->numPlots + 1);
                            if (!data->namelist) return(E_NOMEM);
                            SPfrontEnd->IFnewUid (ckt,
                            &(data->namelist[data->numPlots++]),
                            NULL, name, UID_OTHER, NULL);
                            /* we've added one more plot */
                            
                            
                        }
                        break;
                    }
                }
                break;
                
                case N_CALC:
                switch (mode) {
                    
                    case N_DENS:
                    NevalSrc(&noizDens[MOS1RDNOIZ],&lnNdens[MOS1RDNOIZ],
                    ckt,THERMNOISE,inst->MOS1dNodePrime,inst->MOS1dNode,
                    inst->MOS1drainConductance);
                    
                    NevalSrc(&noizDens[MOS1RSNOIZ],&lnNdens[MOS1RSNOIZ],
                    ckt,THERMNOISE,inst->MOS1sNodePrime,inst->MOS1sNode,
                    inst->MOS1sourceConductance);
                    
                    NevalSrc(&noizDens[MOS1IDNOIZ],&lnNdens[MOS1IDNOIZ],
                    ckt,THERMNOISE,inst->MOS1dNodePrime,inst->MOS1sNodePrime,
                    (2.0/3.0 * fabs(inst->MOS1gm)));
                    
                    NevalSrc(&noizDens[MOS1FLNOIZ], NULL, ckt,
                    N_GAIN,inst->MOS1dNodePrime, inst->MOS1sNodePrime,
                    (double)0.0);
                    noizDens[MOS1FLNOIZ] *= model->MOS1fNcoef * 
                    exp(model->MOS1fNexp *
                    log(MAX(fabs(inst->MOS1cd),N_MINLOG))) /
                    (data->freq * inst->MOS1w * 
                    inst->MOS1m *
                    (inst->MOS1l - 2*model->MOS1latDiff) * coxSquared);
                    lnNdens[MOS1FLNOIZ] = 
                    log(MAX(noizDens[MOS1FLNOIZ],N_MINLOG));
                    
                    noizDens[MOS1TOTNOIZ] = noizDens[MOS1RDNOIZ] +
                    noizDens[MOS1RSNOIZ] +
                    noizDens[MOS1IDNOIZ] +
                    noizDens[MOS1FLNOIZ];
                    lnNdens[MOS1TOTNOIZ] = 
                    log(MAX(noizDens[MOS1TOTNOIZ], N_MINLOG));
                    
                    *OnDens += noizDens[MOS1TOTNOIZ];
                    
                    if (data->delFreq == 0.0) { 
                        
                        /* if we haven't done any previous integration, we need to */
                        /* initialize our "history" variables                      */
                        
                        for (i=0; i < MOS1NSRCS; i++) {
                            inst->MOS1nVar[LNLSTDENS][i] = lnNdens[i];
                        }
                        
                        /* clear out our integration variables if it's the first pass */
                        
                        if (data->freq == job->NstartFreq) {
                            for (i=0; i < MOS1NSRCS; i++) {
                                inst->MOS1nVar[OUTNOIZ][i] = 0.0;
                                inst->MOS1nVar[INNOIZ][i] = 0.0;
                            }
                        }
                    } else {   /* data->delFreq != 0.0 (we have to integrate) */
                        for (i=0; i < MOS1NSRCS; i++) {
                            if (i != MOS1TOTNOIZ) {
                                tempOnoise = Nintegrate(noizDens[i], lnNdens[i],
                                inst->MOS1nVar[LNLSTDENS][i], data);
                                tempInoise = Nintegrate(noizDens[i] * data->GainSqInv ,
                                lnNdens[i] + data->lnGainInv,
                                inst->MOS1nVar[LNLSTDENS][i] + data->lnGainInv,
                                data);
                                inst->MOS1nVar[LNLSTDENS][i] = lnNdens[i];
                                data->outNoiz += tempOnoise;
                                data->inNoise += tempInoise;
                                if (job->NStpsSm != 0) {
                                    inst->MOS1nVar[OUTNOIZ][i] += tempOnoise;
                                    inst->MOS1nVar[OUTNOIZ][MOS1TOTNOIZ] += tempOnoise;
                                    inst->MOS1nVar[INNOIZ][i] += tempInoise;
                                    inst->MOS1nVar[INNOIZ][MOS1TOTNOIZ] += tempInoise;
                                }
                            }
                        }
                    }
                    if (data->prtSummary) {
                        for (i=0; i < MOS1NSRCS; i++) {     /* print a summary report */
                            data->outpVector[data->outNumber++] = noizDens[i];
                        }
                    }
                    break;
                    
                    case INT_NOIZ:        /* already calculated, just output */
                    if (job->NStpsSm != 0) {
                        for (i=0; i < MOS1NSRCS; i++) {
                            data->outpVector[data->outNumber++] = inst->MOS1nVar[OUTNOIZ][i];
                            data->outpVector[data->outNumber++] = inst->MOS1nVar[INNOIZ][i];
                        }
                    }    /* if */
                    break;
                }    /* switch (mode) */
                break;
                
                case N_CLOSE:
                return (OK);         /* do nothing, the main calling routine will close */
                break;               /* the plots */
            }    /* switch (operation) */
        }    /* for inst */
    }    /* for model */
    
    return(OK);
}


