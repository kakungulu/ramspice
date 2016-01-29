#include "ngspice/ngspice.h"
#include "ngspice/cktdefs.h"
#include "ngspice/root/spicelib/devices/bsim4v5/bsim4v5def.h"
#include "Gamma/BSIM/4v5/bsim4v5_gamma_calc.h"
#include "ngspice/trandefs.h"
#include "ngspice/const.h"
#include "ngspice/sperror.h"
#include "ngspice/devdefs.h"
#include "ngspice/suffix.h"
/*
#define MAX_EXP 2.688117142e+43
#define MIN_EXP 3.720075976e-44
#define EXP_THRESHOLD 100.0
*/
#define MAX_EXP 5.834617425e14
#define MIN_EXP 1.713908431e-15
#define EXP_THRESHOLD 34.0
#define EPSSI 1.03594e-10
#define Charge_q 1.60219e-19
#define DELTA_1 0.02
#define DELTA_2 0.02
#define DELTA_3 0.02
#define DELTA_4 0.02
#define MM  3  /* smooth coeff */
#define Kb 1.3806226e-23
#define KboQ 8.617087e-5 
#define EPS0 8.85418e-12
#define EPSSI 1.03594e-10
#define PI 3.141592654
#define MAX_EXP 5.834617425e14
#define MIN_EXP 1.713908431e-15
#define EXP_THRESHOLD 34.0
#define Charge_q 1.60219e-19
#define DELTA  1.0E-9
#define DEXP(A,B) {                                                        \
    if (A > EXP_THRESHOLD) {                                           \
        B = MAX_EXP*(1.0+(A)-EXP_THRESHOLD);                           \
    } else if (A < -EXP_THRESHOLD)  {                                  \
        B = MIN_EXP;                                                   \
    } else   {                                                         \
        B = exp(A);                                                    \
    }                                                                  \
}
#define DEXP3(A,B,C) {                                                         \
    if (A > EXP_THRESHOLD) {                                              \
        B = MAX_EXP*(1.0+(A)-EXP_THRESHOLD);                              \
        C = MAX_EXP;                                                      \
    } else if (A < -EXP_THRESHOLD)  {                                     \
        B = MIN_EXP;                                                      \
        C = 0;                                                            \
    } else   {                                                            \
        B = exp(A);                                                       \
        C = B;                                                            \
    }                                                                     \
}
static int
BSIM4v5DioIjthVjmEval_Gamma(
double Nvtm, double Ijth, double Isb, double XExpBV,
double *Vjm)
{
    double Tb, Tc, EVjmovNv;
    
    Tc = XExpBV;
    Tb = 1.0 + Ijth / Isb - Tc;
    EVjmovNv = 0.5 * (Tb + sqrt(Tb * Tb + 4.0 * Tc));
    *Vjm = Nvtm * log(EVjmovNv);
    
    return 0;
}

#tcl source $::env(RAMSPICE)/Etc/Tech_DB/tsmc040/binning_tsmc040.tcl
#tcl source $::env(RAMSPICE)/Etc/Tech_DB/tsmc040/tsmc040.tcl
#Foreach: ::type {nch pch} {
    #tcl set ::t [string index $::type 0]
    #Foreach: ::corner {ss tt ff} {
        #tcl set ::TEMP [expr 273.15+$::corner_to_temp($::corner)]
        #For: {set ::section 1} {[info exists ::bin($::t,$::section,lmin)]} {incr ::section} {
            #tcl skip {[array names ::TECH $::type,$::corner,$::section,*]=={}}
            void Gamma_tsmc040_Calc_${::type}_${::corner}_${::section}(float Vgs_in,float Vds_in,float Vbs_in,float L_in,float W_in,float M_in
            #Foreach: pointer $::bsim_access_fields {
                ,float *${pointer}_out
            } 
            ) { 
                int Mode=MODEINITJCT|MODEDCOP|MODEAC;
                BSIM4v5instance instance;
                struct bsim4v5SizeDependParam instance_pParam;
                BSIM4v5instance *here=&instance;
                here->pParam=&instance_pParam;
		here->BSIM4v5off=0;
		here->BSIM4v5states=0;
                here->BSIM4v5l = L_in;
                here->BSIM4v5w = W_in;
                here->BSIM4v5m = M_in;
                here->BSIM4v5nf = 1.0;
                here->BSIM4v5min = 0; /* integer */
                here->BSIM4v5icVDS = Vds_in;
                here->BSIM4v5icVGS = Vgs_in;
                here->BSIM4v5icVBS = Vbs_in;
                here->BSIM4v5drainArea = 0.0;
                here->BSIM4v5drainPerimeter = 0.0;
                here->BSIM4v5drainSquares = 1.0;
                here->BSIM4v5sourceArea = 0.0;
                here->BSIM4v5sourcePerimeter = 0.0;
                here->BSIM4v5sourceSquares = 1.0;
                here->BSIM4v5sa = 0.0;
                here->BSIM4v5sb = 0.0;
                here->BSIM4v5sd = 0.0;
                here->BSIM4v5rbdb = ${::TECH($::type,$::corner,$::section,rbdb)}; /* in ohm */
                here->BSIM4v5rbsb = ${::TECH($::type,$::corner,$::section,rbsb)};
                here->BSIM4v5rbpb = ${::TECH($::type,$::corner,$::section,rbpb)};
                here->BSIM4v5rbps = ${::TECH($::type,$::corner,$::section,rbps)};
                here->BSIM4v5rbpd = ${::TECH($::type,$::corner,$::section,rbpd)};
                here->BSIM4v5delvto = 0.0;
                here->BSIM4v5xgw = ${::TECH($::type,$::corner,$::section,xgw)};
                here->BSIM4v5ngcon = ${::TECH($::type,$::corner,$::section,ngcon)};
                
                
                /* Process instance model selectors, some
                * may override their global counterparts
                */
                here->BSIM4v5rbodyMod = ${::TECH($::type,$::corner,$::section,rbodyMod)};
                here->BSIM4v5rgateMod = ${::TECH($::type,$::corner,$::section,rgateMod)};
                here->BSIM4v5geoMod = ${::TECH($::type,$::corner,$::section,geoMod)};
                here->BSIM4v5rgeoMod = ${::TECH($::type,$::corner,$::section,rgeoMod)};
                here->BSIM4v5trnqsMod = ${::TECH($::type,$::corner,$::section,trnqsMod)};
                here->BSIM4v5acnqsMod = ${::TECH($::type,$::corner,$::section,acnqsMod)};
                
                /* stress effect */
                here->BSIM4v5sa = 0.0;
                here->BSIM4v5sb = 0.0;
                here->BSIM4v5sd = 2 * ${::TECH($::type,$::corner,$::section,dmcg)};
                /* Well Proximity Effect  */
                here->BSIM4v5sca = 0.0;
                here->BSIM4v5scb = 0.0;
                here->BSIM4v5scc = 0.0;
                here->BSIM4v5sc = 0.0; /* m */
                
                double ceqgstot, dgstot_dvd, dgstot_dvg, dgstot_dvs, dgstot_dvb;
                double ceqgdtot, dgdtot_dvd, dgdtot_dvg, dgdtot_dvs, dgdtot_dvb;
                double gstot, gstotd, gstotg, gstots, gstotb, gspr, Rs, Rd;
                double gdtot, gdtotd, gdtotg, gdtots, gdtotb, gdpr;
                double vgs_eff, vgd_eff, dvgs_eff_dvg, dvgd_eff_dvg;
                double dRs_dvg, dRd_dvg, dRs_dvb, dRd_dvb;
                double dT0_dvg, dT1_dvb, dT3_dvg, dT3_dvb;
                double vses, vdes, vdedo, delvses, delvded, delvdes;
                double Isestot=0.0, cseshat=0.0, Idedtot=0.0, cdedhat=0.0;
                #ifndef NEWCONV
                double tol0, tol1, tol2, tol3, tol4, tol5, tol6;
                #endif
                
                double geltd, gcrg, gcrgg, gcrgd, gcrgs, gcrgb, ceqgcrg;
                double vges, vgms, vgedo, vgmdo, vged, vgmd, delvged, delvgmd;
                double delvges, delvgms, vgmb;
                double gcgmgmb=0.0, gcgmdb=0.0, gcgmsb=0.0, gcdgmb, gcsgmb;
                double gcgmbb=0.0, gcbgmb, qgmb, qgmid=0.0, ceqqgmid;
                
                double vbd, vbs, vds, vgb, vgd, vgs, vgdo;
                #ifndef PREDICTOR
                double xfact;
                #endif
                double vdbs, vdbd, vsbs, vsbdo, vsbd;
                double delvdbs, delvdbd, delvsbs;
                double delvbd_jct, delvbs_jct, vbs_jct, vbd_jct;
                
                double SourceSatCurrent, DrainSatCurrent;
                double ag0, qgb, von, cbhat=0.0, VgstNVt, ExpVgst;
                double ceqqb, ceqqd, ceqqg, ceqqjd=0.0, ceqqjs=0.0, ceq, geq;
                double cdrain, cdhat=0.0, ceqdrn, ceqbd, ceqbs, ceqjd, ceqjs, gjbd, gjbs;
                double czbd, czbdsw, czbdswg, czbs, czbssw, czbsswg, evbd, evbs, arg, sarg;
                double delvbd, delvbs, delvds, delvgd, delvgs;
                double Vfbeff, dVfbeff_dVg, dVfbeff_dVb, V3, V4;
                double gcbdb, gcbgb, gcbsb, gcddb, gcdgb, gcdsb, gcgdb, gcggb, gcgsb, gcsdb;
                double gcgbb, gcdbb, gcsbb, gcbbb;
                double gcdbdb, gcsbsb;
                double gcsgb, gcssb, MJD, MJSWD, MJSWGD, MJS, MJSWS, MJSWGS;
                double qgate=0.0, qbulk=0.0, qdrn=0.0, qsrc, cqgate, cqbody, cqdrn;
                double Vdb, Vds, Vgs, Vbs, Gmbs, FwdSum, RevSum;
                double Igidl, Ggidld, Ggidlg, Ggidlb;
                double Voxacc=0.0, dVoxacc_dVg=0.0, dVoxacc_dVb=0.0;
                double Voxdepinv=0.0, dVoxdepinv_dVg=0.0, dVoxdepinv_dVd=0.0, dVoxdepinv_dVb=0.0;
                double VxNVt=0.0, ExpVxNVt, Vaux=0.0, dVaux_dVg=0.0, dVaux_dVd=0.0, dVaux_dVb=0.0;
                double Igc, dIgc_dVg, dIgc_dVd, dIgc_dVb;
                double Igcs, dIgcs_dVg, dIgcs_dVd, dIgcs_dVb;
                double Igcd, dIgcd_dVg, dIgcd_dVd, dIgcd_dVb;
                double Igs, dIgs_dVg, dIgs_dVs, Igd, dIgd_dVg, dIgd_dVd;
                double Igbacc, dIgbacc_dVg, dIgbacc_dVb;
                double Igbinv, dIgbinv_dVg, dIgbinv_dVd, dIgbinv_dVb;
                double Pigcd, dPigcd_dVg, dPigcd_dVd, dPigcd_dVb;
                double Istoteq, gIstotg, gIstotd, gIstots, gIstotb;
                double Idtoteq, gIdtotg, gIdtotd, gIdtots, gIdtotb;
                double Ibtoteq, gIbtotg, gIbtotd, gIbtots, gIbtotb;
                double Igtoteq, gIgtotg, gIgtotd, gIgtots, gIgtotb;
                double Igstot=0.0, cgshat=0.0, Igdtot=0.0, cgdhat=0.0, Igbtot=0.0, cgbhat=0.0;
                double Vgs_eff, Vfb=0.0, Vth_NarrowW;
                double Phis, dPhis_dVb, sqrtPhis, dsqrtPhis_dVb, Vth, dVth_dVb, dVth_dVd;
                double Vgst, dVgst_dVg, dVgst_dVb, dVgs_eff_dVg, Nvtms, Nvtmd;
                double Vtm;
                double n, dn_dVb, dn_dVd, voffcv, noff, dnoff_dVd, dnoff_dVb;
                double V0, CoxWLcen, QovCox, LINK;
                double DeltaPhi, dDeltaPhi_dVg, VgDP, dVgDP_dVg;
                double Cox, Tox, Tcen, dTcen_dVg, dTcen_dVd, dTcen_dVb;
                double Ccen, Coxeff, dCoxeff_dVd, dCoxeff_dVg, dCoxeff_dVb;
                double Denomi, dDenomi_dVg, dDenomi_dVd, dDenomi_dVb;
                double ueff, dueff_dVg, dueff_dVd, dueff_dVb; 
                double Esat, Vdsat;
                double EsatL, dEsatL_dVg, dEsatL_dVd, dEsatL_dVb;
                double dVdsat_dVg, dVdsat_dVb, dVdsat_dVd, Vasat, dAlphaz_dVg, dAlphaz_dVb; 
                double dVasat_dVg, dVasat_dVb, dVasat_dVd, Va, dVa_dVd, dVa_dVg, dVa_dVb; 
                double Vbseff, dVbseff_dVb, VbseffCV, dVbseffCV_dVb; 
                double Arg1, One_Third_CoxWL, Two_Third_CoxWL, Alphaz, CoxWL; 
                double T0=0.0, dT0_dVg, dT0_dVd, dT0_dVb;
                double T1, dT1_dVg, dT1_dVd, dT1_dVb;
                double T2, dT2_dVg, dT2_dVd, dT2_dVb;
                double T3, dT3_dVg, dT3_dVd, dT3_dVb;
                double T4, dT4_dVd, dT4_dVb;
                double T5, dT5_dVg, dT5_dVd, dT5_dVb;
                double T6, dT6_dVg, dT6_dVd, dT6_dVb;
                double T7, dT7_dVg, dT7_dVd, dT7_dVb;
                double T8, dT8_dVg, dT8_dVd, dT8_dVb;
                double T9, dT9_dVg, dT9_dVd, dT9_dVb;
                double T10, dT10_dVg, dT10_dVb, dT10_dVd; 
                double T11, T12, T13, T14;
                double tmp, Abulk, dAbulk_dVb, Abulk0, dAbulk0_dVb;
                double Cclm, dCclm_dVg, dCclm_dVd, dCclm_dVb;
                double FP, dFP_dVg, PvagTerm, dPvagTerm_dVg, dPvagTerm_dVd, dPvagTerm_dVb;
                double VADITS, dVADITS_dVg, dVADITS_dVd;
                double Lpe_Vb, dDITS_Sft_dVb, dDITS_Sft_dVd;
                double VACLM, dVACLM_dVg, dVACLM_dVd, dVACLM_dVb;
                double VADIBL, dVADIBL_dVg, dVADIBL_dVd, dVADIBL_dVb;
                double Xdep, dXdep_dVb, lt1, dlt1_dVb, ltw, dltw_dVb, Delt_vth, dDelt_vth_dVb;
                double Theta0, dTheta0_dVb;
                double TempRatio, tmp1, tmp2, tmp3, tmp4;
                double DIBL_Sft, dDIBL_Sft_dVd, Lambda, dLambda_dVg;
                double Idtot, Ibtot, a1;
                
                double Vgsteff, dVgsteff_dVg, dVgsteff_dVd, dVgsteff_dVb; 
                double Vdseff, dVdseff_dVg, dVdseff_dVd, dVdseff_dVb; 
                double VdseffCV, dVdseffCV_dVg, dVdseffCV_dVd, dVdseffCV_dVb; 
                double diffVds, dAbulk_dVg;
                double beta, dbeta_dVg, dbeta_dVd, dbeta_dVb;
                double gche, dgche_dVg, dgche_dVd, dgche_dVb;
                double fgche1, dfgche1_dVg, dfgche1_dVd, dfgche1_dVb;
                double fgche2, dfgche2_dVg, dfgche2_dVd, dfgche2_dVb;
                double Idl, dIdl_dVg, dIdl_dVd, dIdl_dVb;
                double Idsa, dIdsa_dVg, dIdsa_dVd, dIdsa_dVb;
                double Ids, Gm, Gds, Gmb, devbs_dvb, devbd_dvb;
                double Isub, Gbd, Gbg, Gbb;
                double VASCBE, dVASCBE_dVg, dVASCBE_dVd, dVASCBE_dVb;
                double CoxeffWovL;
                double Rds, dRds_dVg, dRds_dVb, WVCox, WVCoxRds;
                double Vgst2Vtm, VdsatCV;
                double Leff, Weff, dWeff_dVg, dWeff_dVb;
                double AbulkCV, dAbulkCV_dVb;
                double qcheq, qdef, gqdef=0.0, cqdef=0.0, cqcheq=0.0;
                double gcqdb=0.0, gcqsb=0.0, gcqgb=0.0, gcqbb=0.0;
                double dxpart, sxpart, ggtg, ggtd, ggts, ggtb;
                double ddxpart_dVd, ddxpart_dVg, ddxpart_dVb, ddxpart_dVs;
                double dsxpart_dVd, dsxpart_dVg, dsxpart_dVb, dsxpart_dVs;
                double gbspsp, gbbdp, gbbsp, gbspg, gbspb, gbspdp; 
                double gbdpdp, gbdpg, gbdpb, gbdpsp; 
                double qgdo, qgso, cgdo, cgso;
                double Cgg, Cgd, Cgb, Cdg, Cdd, Cds;
                double Csg, Csd, Css, Csb, Cbg, Cbd, Cbb;
                double Cgg1, Cgb1, Cgd1, Cbg1, Cbb1, Cbd1, Qac0, Qsub0;
                double dQac0_dVg, dQac0_dVb, dQsub0_dVg, dQsub0_dVd, dQsub0_dVb;
                double ggidld, ggidlg, ggidlb, ggislg, ggislb, ggisls;
                double Igisl, Ggislg, Ggislb, Ggisls;
                double Nvtmrs, Nvtmrssw, Nvtmrsswg;
                double capbd;
                double capbs;
                double cgbo;
                double omega;
                double gmr;
                double gmbsr;
                double gdsr;
                double gmi;
                double gmbsi;
                double gdsi;
                double Cddr;
                double Cdgr;
                double Cdsr;
                double Cdbr;
                double Cddi;
                double Cdgi;
                double Cdsi;
                double Cdbi;
                double Csdr;
                double Csgr;
                double Cssr;
                double Csbr;
                double Csdi;
                double Csgi;
                double Cssi;
                double Csbi;
                double Cgdr;
                double Cggr;
                double Cgsr;
                double Cgbr;
                double Cgdi;
                double Cggi;
                double Cgsi;
                double Cgbi;
                double Gmr;
                double Gmbsr;
                double FwdSumr;
                double RevSumr;
                double Gmi;
                double Gmbsi;
                double FwdSumi;
                double RevSumi;
                double xcgmgmb;
                double xcgmdb;
                double xcgmsb;
                double xcgmbb;
                double xcdgmb;
                double xcsgmb;
                double xcbgmb;
                double xcggbr;
                double xcgdbr;
                double xcgsbr;
                double xcgbbr;
                double xcdgbr;
                double xcsgbr;
                double xcbgb;
                double xcddbr;
                double xcdsbr;
                double xcsdbr;
                double xcssbr;
                double xcdbbr;
                double xcsbbr;
                double xcbdb;
                double xcbsb;
                double xcdbdb;
                double xcsbsb;
                double xcbbb;
                double xcdgbi;
                double xcsgbi;
                double xcddbi;
                double xcdsbi;
                double xcsdbi;
                double xcssbi;
                double xcdbbi;
                double xcsbbi;
                double xcggbi;
                double xcgdbi;
                double xcgsbi;
                double xcgbbi;
                double Inv_L, Inv_W, Inv_LW;
                double vs, Fsevl, dvs_dVg, dvs_dVd, dvs_dVb, dFsevl_dVg, dFsevl_dVd, dFsevl_dVb;
                double vgdx, vgsx;
                struct bsim4v5SizeDependParam *pParam;
                int ByPass, ChargeComputationNeeded, error, Check, Check1, Check2, bodymode;
                
                double m;
                double deta0_lod, dk2_lod;        
		double delTemp = $::TEMP - ${::TECH($::type,$::corner,$::section,tnom)};
                double dumPs, dumPd, dumAs, dumAd, PowWeffWr;
                double DMCGeff, DMCIeff, DMDGeff;
		double Tnom = ${::TECH($::type,$::corner,$::section,tnom)};
                double Vtm0 = KboQ * Tnom;
                double Eg0 = 1.16 - 7.02e-4 * Tnom * Tnom / (Tnom + 1108.0);
                double ni = 1.45e10 * (Tnom / 300.15) * sqrt(Tnom / 300.15) * exp(21.5565981 - Eg0 / (2.0 * Vtm0));        
		double TRatio = $::TEMP / Tnom;

                int i;
                // Stand-ins for unneeded SPICE BSIM variables
                double cktState0[256]; // ckt->state0
                double cktState1[256];
                double cktState2[256];
                double RHSOld[]={0}; // ckt->CKTrhsOld
                double Delta=0; // Delta
                double DeltaOld[7];
                double CKT_CKTbypass=0; 
                double CKT_CKTreltol=0.001; 
                double CKT_CKTvoltTol=1e-06; 
                int CKT_CKTnoncon=0; 
                double CKT_CKTabstol=1e-12;
                double CKT_CKTgmin=1e-12;
                double CKT_CKTag[]={0,0,0,0,0,0,0};
                
                #tcl set ScalingFactor  1.0e-9
                ChargeComputationNeeded =  
                ((Mode & (MODEAC | MODETRAN | MODEINITSMSIG)) ||
                ((Mode & MODETRANOP) && (Mode & MODEUIC)))
                ? 1 : 0;
                ChargeComputationNeeded = 1;
                Check = Check1 = Check2 = 1;
                ByPass = 0;
                pParam = here->pParam;
                /* stress effect */
                double Ldrn = here->BSIM4v5l;
                double Wdrn = here->BSIM4v5w / here->BSIM4v5nf;
                pParam->Length = here->BSIM4v5l;
                pParam->Width = here->BSIM4v5w;
                pParam->NFinger = here->BSIM4v5nf;
                double Lnew = here->BSIM4v5l  + ${::TECH($::type,$::corner,$::section,xl)} ;
                double Wnew = here->BSIM4v5w / here->BSIM4v5nf + ${::TECH($::type,$::corner,$::section,xw)};
                
                T0 = pow(Lnew, ${::TECH($::type,$::corner,$::section,Lln)});
                T1 = pow(Wnew, ${::TECH($::type,$::corner,$::section,Lwn)});
                tmp1 = ${::TECH($::type,$::corner,$::section,Ll)} / T0 + ${::TECH($::type,$::corner,$::section,Lw)} / T1
                + ${::TECH($::type,$::corner,$::section,Lwl)} / (T0 * T1);
                pParam->BSIM4v5dl = ${::TECH($::type,$::corner,$::section,Lint)} + tmp1;
                tmp2 = ${::TECH($::type,$::corner,$::section,Llc)} / T0 + ${::TECH($::type,$::corner,$::section,Lwc)} / T1
                + ${::TECH($::type,$::corner,$::section,Lwlc)} / (T0 * T1);
                pParam->BSIM4v5dlc = ${::TECH($::type,$::corner,$::section,dlc)} + tmp2;
                
                T2 = pow(Lnew, ${::TECH($::type,$::corner,$::section,Wln)});
                T3 = pow(Wnew, ${::TECH($::type,$::corner,$::section,Wwn)});
                tmp1 = ${::TECH($::type,$::corner,$::section,Wl)} / T2 + ${::TECH($::type,$::corner,$::section,Ww)} / T3
                + ${::TECH($::type,$::corner,$::section,Wwl)} / (T2 * T3);
                pParam->BSIM4v5dw = ${::TECH($::type,$::corner,$::section,Wint)} + tmp1;
                tmp2 = ${::TECH($::type,$::corner,$::section,Wlc)} / T2 + ${::TECH($::type,$::corner,$::section,Wwc)} / T3
                + ${::TECH($::type,$::corner,$::section,Wwlc)} / (T2 * T3); 
                pParam->BSIM4v5dwc = ${::TECH($::type,$::corner,$::section,dwc)} + tmp2;
                pParam->BSIM4v5dwj = ${::TECH($::type,$::corner,$::section,dwj)} + tmp2;
                
                pParam->BSIM4v5leff = Lnew - 2.0 * pParam->BSIM4v5dl;
                if (pParam->BSIM4v5leff <= 0.0)
                {   
		    #Error: "Effective channel length <= 0"
                    return(E_BADPARM);
                }
                
                pParam->BSIM4v5weff = Wnew - 2.0 * pParam->BSIM4v5dw;
                if (pParam->BSIM4v5weff <= 0.0)
                {   
 		    #Error: "Effective channel width <= 0"
                   return(E_BADPARM);
                }
                
                pParam->BSIM4v5leffCV = Lnew - 2.0 * pParam->BSIM4v5dlc;
                if (pParam->BSIM4v5leffCV <= 0.0)
                {   
                    #Error: "Effective channel length for C-V <= 0"
                    return(E_BADPARM);
                }
                
                pParam->BSIM4v5weffCV = Wnew - 2.0 * pParam->BSIM4v5dwc;
                if (pParam->BSIM4v5weffCV <= 0.0)
                {   
                    #Error: "Effective channel width for C-V <= 0"
                    return(E_BADPARM);
                }
                
                pParam->BSIM4v5weffCJ = Wnew - 2.0 * pParam->BSIM4v5dwj;
                if (pParam->BSIM4v5weffCJ <= 0.0)
                {   
                    #Error: "Effective channel width for S/D junctions <= 0"
                    return(E_BADPARM);
                }
                
                
                if (${::TECH($::type,$::corner,$::section,binUnit)} == 1)
                {   Inv_L = 1.0e-6 / pParam->BSIM4v5leff;
                    Inv_W = 1.0e-6 / pParam->BSIM4v5weff;
                    Inv_LW = 1.0e-12 / (pParam->BSIM4v5leff
                    * pParam->BSIM4v5weff);
                }
                else
                {   Inv_L = 1.0 / pParam->BSIM4v5leff;
                    Inv_W = 1.0 / pParam->BSIM4v5weff;
                    Inv_LW = 1.0 / (pParam->BSIM4v5leff
                    * pParam->BSIM4v5weff);
                }
                pParam->BSIM4v5cdsc = ${::TECH($::type,$::corner,$::section,cdsc)}
                + ${::TECH($::type,$::corner,$::section,lcdsc)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wcdsc)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pcdsc)} * Inv_LW;
                pParam->BSIM4v5cdscb = ${::TECH($::type,$::corner,$::section,cdscb)}
                + ${::TECH($::type,$::corner,$::section,lcdscb)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wcdscb)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pcdscb)} * Inv_LW; 
                
                pParam->BSIM4v5cdscd = ${::TECH($::type,$::corner,$::section,cdscd)}
                + ${::TECH($::type,$::corner,$::section,lcdscd)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wcdscd)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pcdscd)} * Inv_LW; 
                
                pParam->BSIM4v5cit = ${::TECH($::type,$::corner,$::section,cit)}
                + ${::TECH($::type,$::corner,$::section,lcit)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wcit)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pcit)} * Inv_LW;
                pParam->BSIM4v5nfactor = ${::TECH($::type,$::corner,$::section,nfactor)}
                + ${::TECH($::type,$::corner,$::section,lnfactor)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wnfactor)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pnfactor)} * Inv_LW;
                pParam->BSIM4v5xj = ${::TECH($::type,$::corner,$::section,xj)}
                + ${::TECH($::type,$::corner,$::section,lxj)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wxj)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pxj)} * Inv_LW;
                pParam->BSIM4v5vsat = ${::TECH($::type,$::corner,$::section,vsat)}
                + ${::TECH($::type,$::corner,$::section,lvsat)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wvsat)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pvsat)} * Inv_LW;
                pParam->BSIM4v5at = ${::TECH($::type,$::corner,$::section,at)}
                + ${::TECH($::type,$::corner,$::section,lat)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wat)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pat)} * Inv_LW;
                pParam->BSIM4v5a0 = ${::TECH($::type,$::corner,$::section,a0)}
                + ${::TECH($::type,$::corner,$::section,la0)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wa0)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pa0)} * Inv_LW; 
                
                pParam->BSIM4v5ags = ${::TECH($::type,$::corner,$::section,ags)}
                + ${::TECH($::type,$::corner,$::section,lags)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wags)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pags)} * Inv_LW;
                
                pParam->BSIM4v5a1 = ${::TECH($::type,$::corner,$::section,a1)}
                + ${::TECH($::type,$::corner,$::section,la1)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wa1)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pa1)} * Inv_LW;
                pParam->BSIM4v5a2 = ${::TECH($::type,$::corner,$::section,a2)}
                + ${::TECH($::type,$::corner,$::section,la2)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wa2)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pa2)} * Inv_LW;
                pParam->BSIM4v5keta = ${::TECH($::type,$::corner,$::section,keta)}
                + ${::TECH($::type,$::corner,$::section,lketa)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wketa)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pketa)} * Inv_LW;
                pParam->BSIM4v5nsub = ${::TECH($::type,$::corner,$::section,nsub)}
                + ${::TECH($::type,$::corner,$::section,lnsub)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wnsub)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pnsub)} * Inv_LW;
                pParam->BSIM4v5ndep = ${::TECH($::type,$::corner,$::section,ndep)}
                + ${::TECH($::type,$::corner,$::section,lndep)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wndep)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pndep)} * Inv_LW;
                pParam->BSIM4v5nsd = ${::TECH($::type,$::corner,$::section,nsd)}
                + ${::TECH($::type,$::corner,$::section,lnsd)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wnsd)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pnsd)} * Inv_LW;
                pParam->BSIM4v5phin = ${::TECH($::type,$::corner,$::section,phin)}
                + ${::TECH($::type,$::corner,$::section,lphin)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wphin)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pphin)} * Inv_LW;
                pParam->BSIM4v5ngate = ${::TECH($::type,$::corner,$::section,ngate)}
                + ${::TECH($::type,$::corner,$::section,lngate)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wngate)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pngate)} * Inv_LW;
                pParam->BSIM4v5gamma1 = ${::TECH($::type,$::corner,$::section,gamma1)}
                + ${::TECH($::type,$::corner,$::section,lgamma1)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wgamma1)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pgamma1)} * Inv_LW;
                pParam->BSIM4v5gamma2 = ${::TECH($::type,$::corner,$::section,gamma2)}
                + ${::TECH($::type,$::corner,$::section,lgamma2)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wgamma2)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pgamma2)} * Inv_LW;
                pParam->BSIM4v5vbx = ${::TECH($::type,$::corner,$::section,vbx)}
                + ${::TECH($::type,$::corner,$::section,lvbx)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wvbx)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pvbx)} * Inv_LW;
                pParam->BSIM4v5vbm = ${::TECH($::type,$::corner,$::section,vbm)}
                + ${::TECH($::type,$::corner,$::section,lvbm)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wvbm)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pvbm)} * Inv_LW;
                pParam->BSIM4v5xt = ${::TECH($::type,$::corner,$::section,xt)}
                + ${::TECH($::type,$::corner,$::section,lxt)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wxt)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pxt)} * Inv_LW;
                pParam->BSIM4v5vfb = ${::TECH($::type,$::corner,$::section,vfb)}
                + ${::TECH($::type,$::corner,$::section,lvfb)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wvfb)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pvfb)} * Inv_LW;
                pParam->BSIM4v5k1 = ${::TECH($::type,$::corner,$::section,k1)}
                + ${::TECH($::type,$::corner,$::section,lk1)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wk1)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pk1)} * Inv_LW;
                pParam->BSIM4v5kt1 = ${::TECH($::type,$::corner,$::section,kt1)}
                + ${::TECH($::type,$::corner,$::section,lkt1)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wkt1)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pkt1)} * Inv_LW;
                pParam->BSIM4v5kt1l = ${::TECH($::type,$::corner,$::section,kt1l)}
                + ${::TECH($::type,$::corner,$::section,lkt1l)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wkt1l)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pkt1l)} * Inv_LW;
                pParam->BSIM4v5k2 = ${::TECH($::type,$::corner,$::section,k2)}
                + ${::TECH($::type,$::corner,$::section,lk2)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wk2)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pk2)} * Inv_LW;
                pParam->BSIM4v5kt2 = ${::TECH($::type,$::corner,$::section,kt2)}
                + ${::TECH($::type,$::corner,$::section,lkt2)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wkt2)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pkt2)} * Inv_LW;
                pParam->BSIM4v5k3 = ${::TECH($::type,$::corner,$::section,k3)}
                + ${::TECH($::type,$::corner,$::section,lk3)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wk3)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pk3)} * Inv_LW;
                pParam->BSIM4v5k3b = ${::TECH($::type,$::corner,$::section,k3b)}
                + ${::TECH($::type,$::corner,$::section,lk3b)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wk3b)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pk3b)} * Inv_LW;
                pParam->BSIM4v5w0 = ${::TECH($::type,$::corner,$::section,w0)}
                + ${::TECH($::type,$::corner,$::section,lw0)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,ww0)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pw0)} * Inv_LW;
                pParam->BSIM4v5lpe0 = ${::TECH($::type,$::corner,$::section,lpe0)}
                + ${::TECH($::type,$::corner,$::section,llpe0)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wlpe0)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,plpe0)} * Inv_LW;
                pParam->BSIM4v5lpeb = ${::TECH($::type,$::corner,$::section,lpeb)}
                + ${::TECH($::type,$::corner,$::section,llpeb)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wlpeb)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,plpeb)} * Inv_LW;
                pParam->BSIM4v5dvtp0 = ${::TECH($::type,$::corner,$::section,dvtp0)}
                + ${::TECH($::type,$::corner,$::section,ldvtp0)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wdvtp0)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pdvtp0)} * Inv_LW;
                pParam->BSIM4v5dvtp1 = ${::TECH($::type,$::corner,$::section,dvtp1)}
                + ${::TECH($::type,$::corner,$::section,ldvtp1)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wdvtp1)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pdvtp1)} * Inv_LW;
                pParam->BSIM4v5dvt0 = ${::TECH($::type,$::corner,$::section,dvt0)}
                + ${::TECH($::type,$::corner,$::section,ldvt0)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wdvt0)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pdvt0)} * Inv_LW;
                pParam->BSIM4v5dvt1 = ${::TECH($::type,$::corner,$::section,dvt1)}
                + ${::TECH($::type,$::corner,$::section,ldvt1)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wdvt1)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pdvt1)} * Inv_LW;
                pParam->BSIM4v5dvt2 = ${::TECH($::type,$::corner,$::section,dvt2)}
                + ${::TECH($::type,$::corner,$::section,ldvt2)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wdvt2)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pdvt2)} * Inv_LW;
                pParam->BSIM4v5dvt0w = ${::TECH($::type,$::corner,$::section,dvt0w)}
                + ${::TECH($::type,$::corner,$::section,ldvt0w)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wdvt0w)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pdvt0w)} * Inv_LW;
                pParam->BSIM4v5dvt1w = ${::TECH($::type,$::corner,$::section,dvt1w)}
                + ${::TECH($::type,$::corner,$::section,ldvt1w)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wdvt1w)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pdvt1w)} * Inv_LW;
                pParam->BSIM4v5dvt2w = ${::TECH($::type,$::corner,$::section,dvt2w)}
                + ${::TECH($::type,$::corner,$::section,ldvt2w)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wdvt2w)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pdvt2w)} * Inv_LW;
                pParam->BSIM4v5drout = ${::TECH($::type,$::corner,$::section,drout)}
                + ${::TECH($::type,$::corner,$::section,ldrout)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wdrout)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pdrout)} * Inv_LW;
                pParam->BSIM4v5dsub = ${::TECH($::type,$::corner,$::section,dsub)}
                + ${::TECH($::type,$::corner,$::section,ldsub)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wdsub)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pdsub)} * Inv_LW;
                pParam->BSIM4v5vth0 = ${::TECH($::type,$::corner,$::section,vth0)}
                + ${::TECH($::type,$::corner,$::section,lvth0)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wvth0)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pvth0)} * Inv_LW;
                pParam->BSIM4v5ua = ${::TECH($::type,$::corner,$::section,ua)}
                + ${::TECH($::type,$::corner,$::section,lua)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wua)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pua)} * Inv_LW;
                pParam->BSIM4v5ua1 = ${::TECH($::type,$::corner,$::section,ua1)}
                + ${::TECH($::type,$::corner,$::section,lua1)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wua1)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pua1)} * Inv_LW;
                pParam->BSIM4v5ub = ${::TECH($::type,$::corner,$::section,ub)}
                + ${::TECH($::type,$::corner,$::section,lub)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wub)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pub)} * Inv_LW;
                pParam->BSIM4v5ub1 = ${::TECH($::type,$::corner,$::section,ub1)}
                + ${::TECH($::type,$::corner,$::section,lub1)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wub1)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pub1)} * Inv_LW;
                pParam->BSIM4v5uc = ${::TECH($::type,$::corner,$::section,uc)}
                + ${::TECH($::type,$::corner,$::section,luc)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wuc)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,puc)} * Inv_LW;
                pParam->BSIM4v5uc1 = ${::TECH($::type,$::corner,$::section,uc1)}
                + ${::TECH($::type,$::corner,$::section,luc1)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wuc1)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,puc1)} * Inv_LW;
                pParam->BSIM4v5ud = ${::TECH($::type,$::corner,$::section,ud)}
                + ${::TECH($::type,$::corner,$::section,lud)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wud)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pud)} * Inv_LW;
                pParam->BSIM4v5ud1 = ${::TECH($::type,$::corner,$::section,ud1)}
                + ${::TECH($::type,$::corner,$::section,lud1)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wud1)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pud1)} * Inv_LW;
                pParam->BSIM4v5up = ${::TECH($::type,$::corner,$::section,up)}
                + ${::TECH($::type,$::corner,$::section,lup)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wup)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pup)} * Inv_LW;
                pParam->BSIM4v5lp = ${::TECH($::type,$::corner,$::section,lp)}
                + ${::TECH($::type,$::corner,$::section,llp)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wlp)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,plp)} * Inv_LW;
                pParam->BSIM4v5eu = ${::TECH($::type,$::corner,$::section,eu)}
                + ${::TECH($::type,$::corner,$::section,leu)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,weu)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,peu)} * Inv_LW;
                pParam->BSIM4v5u0 = ${::TECH($::type,$::corner,$::section,u0)}
                + ${::TECH($::type,$::corner,$::section,lu0)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wu0)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pu0)} * Inv_LW;
                pParam->BSIM4v5ute = ${::TECH($::type,$::corner,$::section,ute)}
                + ${::TECH($::type,$::corner,$::section,lute)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wute)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pute)} * Inv_LW;
                pParam->BSIM4v5voff = ${::TECH($::type,$::corner,$::section,voff)}
                + ${::TECH($::type,$::corner,$::section,lvoff)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wvoff)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pvoff)} * Inv_LW;
                pParam->BSIM4v5tvoff = ${::TECH($::type,$::corner,$::section,tvoff)}
                + ${::TECH($::type,$::corner,$::section,ltvoff)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wtvoff)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,ptvoff)} * Inv_LW;
                pParam->BSIM4v5minv = ${::TECH($::type,$::corner,$::section,minv)}
                + ${::TECH($::type,$::corner,$::section,lminv)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wminv)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pminv)} * Inv_LW;
                pParam->BSIM4v5fprout = ${::TECH($::type,$::corner,$::section,fprout)}
                + ${::TECH($::type,$::corner,$::section,lfprout)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wfprout)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pfprout)} * Inv_LW;
                pParam->BSIM4v5pdits = ${::TECH($::type,$::corner,$::section,pdits)}
                + ${::TECH($::type,$::corner,$::section,lpdits)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wpdits)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,ppdits)} * Inv_LW;
                pParam->BSIM4v5pditsd = ${::TECH($::type,$::corner,$::section,pditsd)}
                + ${::TECH($::type,$::corner,$::section,lpditsd)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wpditsd)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,ppditsd)} * Inv_LW;
                pParam->BSIM4v5delta = ${::TECH($::type,$::corner,$::section,delta)}
                + ${::TECH($::type,$::corner,$::section,ldelta)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wdelta)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pdelta)} * Inv_LW;
                pParam->BSIM4v5rdsw = ${::TECH($::type,$::corner,$::section,rdsw)}
                + ${::TECH($::type,$::corner,$::section,lrdsw)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wrdsw)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,prdsw)} * Inv_LW;
                pParam->BSIM4v5rdw = ${::TECH($::type,$::corner,$::section,rdw)}
                + ${::TECH($::type,$::corner,$::section,lrdw)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wrdw)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,prdw)} * Inv_LW;
                pParam->BSIM4v5rsw = ${::TECH($::type,$::corner,$::section,rsw)}
                + ${::TECH($::type,$::corner,$::section,lrsw)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wrsw)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,prsw)} * Inv_LW;
                pParam->BSIM4v5prwg = ${::TECH($::type,$::corner,$::section,prwg)}
                + ${::TECH($::type,$::corner,$::section,lprwg)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wprwg)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pprwg)} * Inv_LW;
                pParam->BSIM4v5prwb = ${::TECH($::type,$::corner,$::section,prwb)}
                + ${::TECH($::type,$::corner,$::section,lprwb)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wprwb)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pprwb)} * Inv_LW;
                pParam->BSIM4v5prt = ${::TECH($::type,$::corner,$::section,prt)}
                + ${::TECH($::type,$::corner,$::section,lprt)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wprt)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pprt)} * Inv_LW;
                pParam->BSIM4v5eta0 = ${::TECH($::type,$::corner,$::section,eta0)}
                + ${::TECH($::type,$::corner,$::section,leta0)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,weta0)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,peta0)} * Inv_LW;
                //if (pParam->BSIM4v5eta0<0.0) pParam->BSIM4v5eta0 = ${::TECH($::type,$::corner,$::section,eta0)};
                pParam->BSIM4v5etab = ${::TECH($::type,$::corner,$::section,etab)}
                + ${::TECH($::type,$::corner,$::section,letab)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wetab)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,petab)} * Inv_LW;
                pParam->BSIM4v5pclm = ${::TECH($::type,$::corner,$::section,pclm)}
                + ${::TECH($::type,$::corner,$::section,lpclm)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wpclm)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,ppclm)} * Inv_LW;
                //Info: "Pclm=%g+%g*%g+%g*%g+%g*%g=%g" ${::TECH($::type,$::corner,$::section,pclm)} ${::TECH($::type,$::corner,$::section,lpclm)} Inv_L ${::TECH($::type,$::corner,$::section,wpclm)} Inv_W ${::TECH($::type,$::corner,$::section,ppclm)} Inv_LW pParam->BSIM4v5pclm
                //if (pParam->BSIM4v5pclm<0.0) pParam->BSIM4v5pclm=${::TECH($::type,$::corner,$::section,pclm)};
                //Info: "Pclm=%g" pParam->BSIM4v5pclm
                pParam->BSIM4v5pdibl1 = ${::TECH($::type,$::corner,$::section,pdibl1)}
                + ${::TECH($::type,$::corner,$::section,lpdibl1)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wpdibl1)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,ppdibl1)} * Inv_LW;
                pParam->BSIM4v5pdibl2 = ${::TECH($::type,$::corner,$::section,pdibl2)}
                + ${::TECH($::type,$::corner,$::section,lpdibl2)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wpdibl2)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,ppdibl2)} * Inv_LW;
                pParam->BSIM4v5pdiblb = ${::TECH($::type,$::corner,$::section,pdiblb)}
                + ${::TECH($::type,$::corner,$::section,lpdiblb)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wpdiblb)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,ppdiblb)} * Inv_LW;
                pParam->BSIM4v5pscbe1 = ${::TECH($::type,$::corner,$::section,pscbe1)}
                + ${::TECH($::type,$::corner,$::section,lpscbe1)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wpscbe1)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,ppscbe1)} * Inv_LW;
                pParam->BSIM4v5pscbe2 = ${::TECH($::type,$::corner,$::section,pscbe2)}
                + ${::TECH($::type,$::corner,$::section,lpscbe2)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wpscbe2)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,ppscbe2)} * Inv_LW;
                pParam->BSIM4v5pvag = ${::TECH($::type,$::corner,$::section,pvag)}
                + ${::TECH($::type,$::corner,$::section,lpvag)} * Inv_L 
                + ${::TECH($::type,$::corner,$::section,wpvag)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,ppvag)} * Inv_LW;
                pParam->BSIM4v5wr = ${::TECH($::type,$::corner,$::section,wr)}
                + ${::TECH($::type,$::corner,$::section,lwr)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wwr)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pwr)} * Inv_LW;
                pParam->BSIM4v5dwg = ${::TECH($::type,$::corner,$::section,dwg)}
                + ${::TECH($::type,$::corner,$::section,ldwg)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wdwg)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pdwg)} * Inv_LW;
                pParam->BSIM4v5dwb = ${::TECH($::type,$::corner,$::section,dwb)}
                + ${::TECH($::type,$::corner,$::section,ldwb)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wdwb)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pdwb)} * Inv_LW;
                pParam->BSIM4v5b0 = ${::TECH($::type,$::corner,$::section,b0)}
                + ${::TECH($::type,$::corner,$::section,lb0)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wb0)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pb0)} * Inv_LW;
                pParam->BSIM4v5b1 = ${::TECH($::type,$::corner,$::section,b1)}
                + ${::TECH($::type,$::corner,$::section,lb1)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wb1)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pb1)} * Inv_LW;
                pParam->BSIM4v5alpha0 = ${::TECH($::type,$::corner,$::section,alpha0)}
                + ${::TECH($::type,$::corner,$::section,lalpha0)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,walpha0)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,palpha0)} * Inv_LW;
                pParam->BSIM4v5alpha1 = ${::TECH($::type,$::corner,$::section,alpha1)}
                + ${::TECH($::type,$::corner,$::section,lalpha1)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,walpha1)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,palpha1)} * Inv_LW;
                pParam->BSIM4v5beta0 = ${::TECH($::type,$::corner,$::section,beta0)}
                + ${::TECH($::type,$::corner,$::section,lbeta0)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wbeta0)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pbeta0)} * Inv_LW;
                
                pParam->BSIM4v5agidl = ${::TECH($::type,$::corner,$::section,agidl)}
                + ${::TECH($::type,$::corner,$::section,lagidl)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wagidl)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pagidl)} * Inv_LW;
                pParam->BSIM4v5bgidl = ${::TECH($::type,$::corner,$::section,bgidl)}
                + ${::TECH($::type,$::corner,$::section,lbgidl)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wbgidl)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pbgidl)} * Inv_LW;
                pParam->BSIM4v5cgidl = ${::TECH($::type,$::corner,$::section,cgidl)}
                + ${::TECH($::type,$::corner,$::section,lcgidl)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wcgidl)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pcgidl)} * Inv_LW;
                pParam->BSIM4v5egidl = ${::TECH($::type,$::corner,$::section,egidl)}
                + ${::TECH($::type,$::corner,$::section,legidl)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wegidl)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pegidl)} * Inv_LW;
                pParam->BSIM4v5aigc = ${::TECH($::type,$::corner,$::section,aigc)}
                + ${::TECH($::type,$::corner,$::section,laigc)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,waigc)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,paigc)} * Inv_LW;
                pParam->BSIM4v5bigc = ${::TECH($::type,$::corner,$::section,bigc)}
                + ${::TECH($::type,$::corner,$::section,lbigc)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wbigc)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pbigc)} * Inv_LW;
                pParam->BSIM4v5cigc = ${::TECH($::type,$::corner,$::section,cigc)}
                + ${::TECH($::type,$::corner,$::section,lcigc)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wcigc)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pcigc)} * Inv_LW;
                pParam->BSIM4v5aigsd = ${::TECH($::type,$::corner,$::section,aigsd)}
                + ${::TECH($::type,$::corner,$::section,laigsd)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,waigsd)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,paigsd)} * Inv_LW;
                pParam->BSIM4v5bigsd = ${::TECH($::type,$::corner,$::section,bigsd)}
                + ${::TECH($::type,$::corner,$::section,lbigsd)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wbigsd)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pbigsd)} * Inv_LW;
                pParam->BSIM4v5cigsd = ${::TECH($::type,$::corner,$::section,cigsd)}
                + ${::TECH($::type,$::corner,$::section,lcigsd)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wcigsd)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pcigsd)} * Inv_LW;
                pParam->BSIM4v5aigbacc = ${::TECH($::type,$::corner,$::section,aigbacc)}
                + ${::TECH($::type,$::corner,$::section,laigbacc)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,waigbacc)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,paigbacc)} * Inv_LW;
                pParam->BSIM4v5bigbacc = ${::TECH($::type,$::corner,$::section,bigbacc)}
                + ${::TECH($::type,$::corner,$::section,lbigbacc)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wbigbacc)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pbigbacc)} * Inv_LW;
                pParam->BSIM4v5cigbacc = ${::TECH($::type,$::corner,$::section,cigbacc)}
                + ${::TECH($::type,$::corner,$::section,lcigbacc)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wcigbacc)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pcigbacc)} * Inv_LW;
                pParam->BSIM4v5aigbinv = ${::TECH($::type,$::corner,$::section,aigbinv)}
                + ${::TECH($::type,$::corner,$::section,laigbinv)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,waigbinv)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,paigbinv)} * Inv_LW;
                pParam->BSIM4v5bigbinv = ${::TECH($::type,$::corner,$::section,bigbinv)}
                + ${::TECH($::type,$::corner,$::section,lbigbinv)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wbigbinv)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pbigbinv)} * Inv_LW;
                pParam->BSIM4v5cigbinv = ${::TECH($::type,$::corner,$::section,cigbinv)}
                + ${::TECH($::type,$::corner,$::section,lcigbinv)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wcigbinv)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pcigbinv)} * Inv_LW;
                pParam->BSIM4v5nigc = ${::TECH($::type,$::corner,$::section,nigc)}
                + ${::TECH($::type,$::corner,$::section,lnigc)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wnigc)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pnigc)} * Inv_LW;
                pParam->BSIM4v5nigbacc = ${::TECH($::type,$::corner,$::section,nigbacc)}
                + ${::TECH($::type,$::corner,$::section,lnigbacc)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wnigbacc)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pnigbacc)} * Inv_LW;
                pParam->BSIM4v5nigbinv = ${::TECH($::type,$::corner,$::section,nigbinv)}
                + ${::TECH($::type,$::corner,$::section,lnigbinv)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wnigbinv)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pnigbinv)} * Inv_LW;
                pParam->BSIM4v5ntox = ${::TECH($::type,$::corner,$::section,ntox)}
                + ${::TECH($::type,$::corner,$::section,lntox)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wntox)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pntox)} * Inv_LW;
                pParam->BSIM4v5eigbinv = ${::TECH($::type,$::corner,$::section,eigbinv)}
                + ${::TECH($::type,$::corner,$::section,leigbinv)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,weigbinv)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,peigbinv)} * Inv_LW;
                pParam->BSIM4v5pigcd = ${::TECH($::type,$::corner,$::section,pigcd)}
                + ${::TECH($::type,$::corner,$::section,lpigcd)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wpigcd)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,ppigcd)} * Inv_LW;
                pParam->BSIM4v5poxedge = ${::TECH($::type,$::corner,$::section,poxedge)}
                + ${::TECH($::type,$::corner,$::section,lpoxedge)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wpoxedge)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,ppoxedge)} * Inv_LW;
                pParam->BSIM4v5xrcrg1 = ${::TECH($::type,$::corner,$::section,xrcrg1)}
                + ${::TECH($::type,$::corner,$::section,lxrcrg1)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wxrcrg1)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pxrcrg1)} * Inv_LW;
                pParam->BSIM4v5xrcrg2 = ${::TECH($::type,$::corner,$::section,xrcrg2)}
                + ${::TECH($::type,$::corner,$::section,lxrcrg2)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wxrcrg2)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pxrcrg2)} * Inv_LW;
                pParam->BSIM4v5lambda = ${::TECH($::type,$::corner,$::section,lambda)}
                + ${::TECH($::type,$::corner,$::section,llambda)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wlambda)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,plambda)} * Inv_LW;
                pParam->BSIM4v5vtl = ${::TECH($::type,$::corner,$::section,vtl)}
                + ${::TECH($::type,$::corner,$::section,lvtl)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wvtl)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pvtl)} * Inv_LW;
                pParam->BSIM4v5xn = ${::TECH($::type,$::corner,$::section,xn)}
                + ${::TECH($::type,$::corner,$::section,lxn)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wxn)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pxn)} * Inv_LW;
                pParam->BSIM4v5vfbsdoff = ${::TECH($::type,$::corner,$::section,vfbsdoff)}
                + ${::TECH($::type,$::corner,$::section,lvfbsdoff)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wvfbsdoff)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pvfbsdoff)} * Inv_LW;
                pParam->BSIM4v5tvfbsdoff = ${::TECH($::type,$::corner,$::section,tvfbsdoff)}
                + ${::TECH($::type,$::corner,$::section,ltvfbsdoff)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wtvfbsdoff)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,ptvfbsdoff)} * Inv_LW;
                
                pParam->BSIM4v5cgsl = ${::TECH($::type,$::corner,$::section,cgsl)}
                + ${::TECH($::type,$::corner,$::section,lcgsl)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wcgsl)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pcgsl)} * Inv_LW;
                pParam->BSIM4v5cgdl = ${::TECH($::type,$::corner,$::section,cgdl)}
                + ${::TECH($::type,$::corner,$::section,lcgdl)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wcgdl)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pcgdl)} * Inv_LW;
                pParam->BSIM4v5ckappas = ${::TECH($::type,$::corner,$::section,ckappas)}
                + ${::TECH($::type,$::corner,$::section,lckappas)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wckappas)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pckappas)} * Inv_LW;
                pParam->BSIM4v5ckappad = ${::TECH($::type,$::corner,$::section,ckappad)}
                + ${::TECH($::type,$::corner,$::section,lckappad)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wckappad)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pckappad)} * Inv_LW;
                pParam->BSIM4v5cf = ${::TECH($::type,$::corner,$::section,cf)}
                + ${::TECH($::type,$::corner,$::section,lcf)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wcf)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pcf)} * Inv_LW;
                pParam->BSIM4v5clc = ${::TECH($::type,$::corner,$::section,clc)}
                + ${::TECH($::type,$::corner,$::section,lclc)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wclc)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pclc)} * Inv_LW;
                pParam->BSIM4v5cle = ${::TECH($::type,$::corner,$::section,cle)}
                + ${::TECH($::type,$::corner,$::section,lcle)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wcle)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pcle)} * Inv_LW;
                pParam->BSIM4v5vfbcv = ${::TECH($::type,$::corner,$::section,vfbcv)}
                + ${::TECH($::type,$::corner,$::section,lvfbcv)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wvfbcv)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pvfbcv)} * Inv_LW;
                pParam->BSIM4v5acde = ${::TECH($::type,$::corner,$::section,acde)}
                + ${::TECH($::type,$::corner,$::section,lacde)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wacde)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pacde)} * Inv_LW;
                pParam->BSIM4v5moin = ${::TECH($::type,$::corner,$::section,moin)}
                + ${::TECH($::type,$::corner,$::section,lmoin)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wmoin)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pmoin)} * Inv_LW;
                pParam->BSIM4v5noff = ${::TECH($::type,$::corner,$::section,noff)}
                + ${::TECH($::type,$::corner,$::section,lnoff)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wnoff)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pnoff)} * Inv_LW;
                pParam->BSIM4v5voffcv = ${::TECH($::type,$::corner,$::section,voffcv)}
                + ${::TECH($::type,$::corner,$::section,lvoffcv)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wvoffcv)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pvoffcv)} * Inv_LW;
                pParam->BSIM4v5kvth0we = ${::TECH($::type,$::corner,$::section,kvth0we)}
                + ${::TECH($::type,$::corner,$::section,lkvth0we)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wkvth0we)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pkvth0we)} * Inv_LW;
                pParam->BSIM4v5k2we = ${::TECH($::type,$::corner,$::section,k2we)}
                + ${::TECH($::type,$::corner,$::section,lk2we)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wk2we)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pk2we)} * Inv_LW;
                pParam->BSIM4v5ku0we = ${::TECH($::type,$::corner,$::section,ku0we)}
                + ${::TECH($::type,$::corner,$::section,lku0we)} * Inv_L
                + ${::TECH($::type,$::corner,$::section,wku0we)} * Inv_W
                + ${::TECH($::type,$::corner,$::section,pku0we)} * Inv_LW;
                
                pParam->BSIM4v5abulkCVfactor = 1.0 + pow((pParam->BSIM4v5clc
                / pParam->BSIM4v5leffCV),
                pParam->BSIM4v5cle);
                
                T0 = (TRatio - 1.0);
                
                PowWeffWr = pow(pParam->BSIM4v5weffCJ * 1.0e6, pParam->BSIM4v5wr) * here->BSIM4v5nf;
                
                T1 = T2 = T3 = T4 = 0.0;
                if(${::TECH($::type,$::corner,$::section,tempMod)} == 0) {
                    pParam->BSIM4v5ua = pParam->BSIM4v5ua + pParam->BSIM4v5ua1 * T0;
                    pParam->BSIM4v5ub = pParam->BSIM4v5ub + pParam->BSIM4v5ub1 * T0;
                    pParam->BSIM4v5uc = pParam->BSIM4v5uc + pParam->BSIM4v5uc1 * T0;
                    pParam->BSIM4v5ud = pParam->BSIM4v5ud + pParam->BSIM4v5ud1 * T0;
                    pParam->BSIM4v5vsattemp = pParam->BSIM4v5vsat - pParam->BSIM4v5at * T0;
                    T10 = pParam->BSIM4v5prt * T0;
                    if(${::TECH($::type,$::corner,$::section,rdsMod)}) {
                        /* External Rd(V) */
                        T1 = pParam->BSIM4v5rdw + T10;
                        T2 = ${::TECH($::type,$::corner,$::section,rdwmin)} + T10;
                        /* External Rs(V) */
                        T3 = pParam->BSIM4v5rsw + T10;
                        T4 = ${::TECH($::type,$::corner,$::section,rswmin)} + T10;
                    }
                    /* Internal Rds(V) in IV */
                    pParam->BSIM4v5rds0 = (pParam->BSIM4v5rdsw + T10)
                    * here->BSIM4v5nf / PowWeffWr;
                    pParam->BSIM4v5rdswmin = (${::TECH($::type,$::corner,$::section,rdswmin)} + T10)
                    * here->BSIM4v5nf / PowWeffWr;
                } else { /* tempMod = 1, 2 */
                    pParam->BSIM4v5ua = pParam->BSIM4v5ua * (1.0 + pParam->BSIM4v5ua1 * delTemp) ;
                    pParam->BSIM4v5ub = pParam->BSIM4v5ub * (1.0 + pParam->BSIM4v5ub1 * delTemp);
                    pParam->BSIM4v5uc = pParam->BSIM4v5uc * (1.0 + pParam->BSIM4v5uc1 * delTemp);
                    pParam->BSIM4v5ud = pParam->BSIM4v5ud * (1.0 + pParam->BSIM4v5ud1 * delTemp);
                    pParam->BSIM4v5vsattemp = pParam->BSIM4v5vsat * (1.0 - pParam->BSIM4v5at * delTemp);
                    T10 = 1.0 + pParam->BSIM4v5prt * delTemp;
                    if(${::TECH($::type,$::corner,$::section,rdsMod)}) {
                        /* External Rd(V) */
                        T1 = pParam->BSIM4v5rdw * T10;
                        T2 = ${::TECH($::type,$::corner,$::section,rdwmin)} * T10;
                        /* External Rs(V) */
                        T3 = pParam->BSIM4v5rsw * T10;
                        T4 = ${::TECH($::type,$::corner,$::section,rswmin)} * T10;
                    }
                    /* Internal Rds(V) in IV */
                    pParam->BSIM4v5rds0 = pParam->BSIM4v5rdsw * T10 * here->BSIM4v5nf / PowWeffWr;
                    pParam->BSIM4v5rdswmin = ${::TECH($::type,$::corner,$::section,rdswmin)} * T10 * here->BSIM4v5nf / PowWeffWr;
                }
                if (T1 < 0.0)
                {   T1 = 0.0;
                    printf("Warning: Rdw at current temperature is negative; set to 0.\n");
                }
                if (T2 < 0.0)
                {   T2 = 0.0;
                    printf("Warning: Rdwmin at current temperature is negative; set to 0.\n");
                }
                pParam->BSIM4v5rd0 = T1 / PowWeffWr;
                pParam->BSIM4v5rdwmin = T2 / PowWeffWr;
                if (T3 < 0.0)
                {   T3 = 0.0;
                    printf("Warning: Rsw at current temperature is negative; set to 0.\n");
                }
                if (T4 < 0.0)
                {   T4 = 0.0;
                    printf("Warning: Rswmin at current temperature is negative; set to 0.\n");
                }
                pParam->BSIM4v5rs0 = T3 / PowWeffWr;
                pParam->BSIM4v5rswmin = T4 / PowWeffWr;
                
                if (pParam->BSIM4v5u0 > 1.0) 
                pParam->BSIM4v5u0 = pParam->BSIM4v5u0 / 1.0e4;
                
                /* mobility channel length dependence */
                T5 = 1.0 - pParam->BSIM4v5up * exp( - pParam->BSIM4v5leff / pParam->BSIM4v5lp);
                pParam->BSIM4v5u0temp = pParam->BSIM4v5u0 * T5
                * pow(TRatio, pParam->BSIM4v5ute); 
                if (pParam->BSIM4v5eu < 0.0)
                {   pParam->BSIM4v5eu = 0.0;
                    printf("Warning: eu has been negative; reset to 0.0.\n");
                }
                
                pParam->BSIM4v5vfbsdoff = pParam->BSIM4v5vfbsdoff * (1.0 + pParam->BSIM4v5tvfbsdoff * delTemp);
                pParam->BSIM4v5voff = pParam->BSIM4v5voff * (1.0 + pParam->BSIM4v5tvoff * delTemp);
                
                /* Source End Velocity Limit  */
                if((${::TECH($::type,$::corner,$::section,vtlGiven)}) && (${::TECH($::type,$::corner,$::section,vtl)} > 0.0) )
                {  
                    if(${::TECH($::type,$::corner,$::section,lc)} < 0.0) pParam->BSIM4v5lc = 0.0;
                    else   pParam->BSIM4v5lc = ${::TECH($::type,$::corner,$::section,lc)} ;
                    T0 = pParam->BSIM4v5leff / (pParam->BSIM4v5xn * pParam->BSIM4v5leff + pParam->BSIM4v5lc);
                    pParam->BSIM4v5tfactor = (1.0 - T0) / (1.0 + T0 );
                }
                
                pParam->BSIM4v5cgdo = (${::TECH($::type,$::corner,$::section,cgdo)} + pParam->BSIM4v5cf)
                * pParam->BSIM4v5weffCV;
                pParam->BSIM4v5cgso = (${::TECH($::type,$::corner,$::section,cgso)} + pParam->BSIM4v5cf)
                * pParam->BSIM4v5weffCV;
                pParam->BSIM4v5cgbo = ${::TECH($::type,$::corner,$::section,cgbo)} * pParam->BSIM4v5leffCV * here->BSIM4v5nf;
                
                if (!${::TECH($::type,$::corner,$::section,ndepGiven)} && ${::TECH($::type,$::corner,$::section,gamma1Given)})
                {   T0 = pParam->BSIM4v5gamma1 * ${::TECH($::type,$::corner,$::section,coxe)};
                    pParam->BSIM4v5ndep = 3.01248e22 * T0 * T0;
                }
                
                pParam->BSIM4v5phi = Vtm0 * log(pParam->BSIM4v5ndep / ni)
                + pParam->BSIM4v5phin + 0.4;
                
                pParam->BSIM4v5sqrtPhi = sqrt(pParam->BSIM4v5phi);
                pParam->BSIM4v5phis3 = pParam->BSIM4v5sqrtPhi * pParam->BSIM4v5phi;
                
                pParam->BSIM4v5Xdep0 = sqrt(2.0 * EPSSI / (Charge_q
                * pParam->BSIM4v5ndep * 1.0e6))
                * pParam->BSIM4v5sqrtPhi; 
                pParam->BSIM4v5sqrtXdep0 = sqrt(pParam->BSIM4v5Xdep0);
                pParam->BSIM4v5litl = sqrt(3.0 * pParam->BSIM4v5xj
                * ${::TECH($::type,$::corner,$::section,toxe)});
                pParam->BSIM4v5vbi = Vtm0 * log(pParam->BSIM4v5nsd
                * pParam->BSIM4v5ndep / (ni * ni));
                
                if (pParam->BSIM4v5ngate > 0.0)
                {   pParam->BSIM4v5vfbsd = Vtm0 * log(pParam->BSIM4v5ngate
                    / pParam->BSIM4v5nsd);
                }
                else
                pParam->BSIM4v5vfbsd = 0.0;
                
                pParam->BSIM4v5cdep0 = sqrt(Charge_q * EPSSI
                * pParam->BSIM4v5ndep * 1.0e6 / 2.0
                / pParam->BSIM4v5phi);
                
                pParam->BSIM4v5ToxRatio = exp(pParam->BSIM4v5ntox
                * log(${::TECH($::type,$::corner,$::section,toxref)} / ${::TECH($::type,$::corner,$::section,toxe)}))
                / ${::TECH($::type,$::corner,$::section,toxe)} / ${::TECH($::type,$::corner,$::section,toxe)};
                pParam->BSIM4v5ToxRatioEdge = exp(pParam->BSIM4v5ntox
                * log(${::TECH($::type,$::corner,$::section,toxref)}
                / (${::TECH($::type,$::corner,$::section,toxe)} * pParam->BSIM4v5poxedge)))
                / ${::TECH($::type,$::corner,$::section,toxe)} / ${::TECH($::type,$::corner,$::section,toxe)}
                / pParam->BSIM4v5poxedge / pParam->BSIM4v5poxedge;
                pParam->BSIM4v5Aechvb = (${::TECH($::type,$::corner,$::section,type)} == NMOS) ? 4.97232e-7 : 3.42537e-7;
                pParam->BSIM4v5Bechvb = (${::TECH($::type,$::corner,$::section,type)} == NMOS) ? 7.45669e11 : 1.16645e12;
                pParam->BSIM4v5AechvbEdge = pParam->BSIM4v5Aechvb * pParam->BSIM4v5weff
                * ${::TECH($::type,$::corner,$::section,dlcig)} * pParam->BSIM4v5ToxRatioEdge;
                pParam->BSIM4v5BechvbEdge = -pParam->BSIM4v5Bechvb
                * ${::TECH($::type,$::corner,$::section,toxe)} * pParam->BSIM4v5poxedge;
                pParam->BSIM4v5Aechvb *= pParam->BSIM4v5weff * pParam->BSIM4v5leff
                * pParam->BSIM4v5ToxRatio;
                pParam->BSIM4v5Bechvb *= -${::TECH($::type,$::corner,$::section,toxe)};
                
                
                pParam->BSIM4v5mstar = 0.5 + atan(pParam->BSIM4v5minv) / PI;
                pParam->BSIM4v5voffcbn =  pParam->BSIM4v5voff + ${::TECH($::type,$::corner,$::section,voffl)} / pParam->BSIM4v5leff;
                
                pParam->BSIM4v5ldeb = sqrt(EPSSI * Vtm0 / (Charge_q
                * pParam->BSIM4v5ndep * 1.0e6)) / 3.0;
                pParam->BSIM4v5acde *= pow((pParam->BSIM4v5ndep / 2.0e16), -0.25);
                
                
                if (${::TECH($::type,$::corner,$::section,k1Given)} || ${::TECH($::type,$::corner,$::section,k2Given)})
                {   if (!${::TECH($::type,$::corner,$::section,k1Given)})
                    {
                        pParam->BSIM4v5k1 = 0.53;
                    }
                    if (!${::TECH($::type,$::corner,$::section,k2Given)})
                    {
                        pParam->BSIM4v5k2 = -0.0186;
                    }
                }
                else
                {   if (!${::TECH($::type,$::corner,$::section,vbxGiven)})
                    pParam->BSIM4v5vbx = pParam->BSIM4v5phi - 7.7348e-4 
                    * pParam->BSIM4v5ndep
                    * pParam->BSIM4v5xt * pParam->BSIM4v5xt;
                    if (pParam->BSIM4v5vbx > 0.0)
                    pParam->BSIM4v5vbx = -pParam->BSIM4v5vbx;
                    if (pParam->BSIM4v5vbm > 0.0)
                    pParam->BSIM4v5vbm = -pParam->BSIM4v5vbm;
                    
                    if (!${::TECH($::type,$::corner,$::section,gamma1Given)})
                    pParam->BSIM4v5gamma1 = 5.753e-12
                    * sqrt(pParam->BSIM4v5ndep)
                    / ${::TECH($::type,$::corner,$::section,coxe)};
                    if (!${::TECH($::type,$::corner,$::section,gamma2Given)})
                    pParam->BSIM4v5gamma2 = 5.753e-12
                    * sqrt(pParam->BSIM4v5nsub)
                    / ${::TECH($::type,$::corner,$::section,coxe)};
                    
                    T0 = pParam->BSIM4v5gamma1 - pParam->BSIM4v5gamma2;
                    T1 = sqrt(pParam->BSIM4v5phi - pParam->BSIM4v5vbx)
                    - pParam->BSIM4v5sqrtPhi;
                    T2 = sqrt(pParam->BSIM4v5phi * (pParam->BSIM4v5phi
                    - pParam->BSIM4v5vbm)) - pParam->BSIM4v5phi;
                    pParam->BSIM4v5k2 = T0 * T1 / (2.0 * T2 + pParam->BSIM4v5vbm);
                    pParam->BSIM4v5k1 = pParam->BSIM4v5gamma2 - 2.0
                    * pParam->BSIM4v5k2 * sqrt(pParam->BSIM4v5phi
                    - pParam->BSIM4v5vbm);
                }
                
                if (!${::TECH($::type,$::corner,$::section,vfbGiven)})
                {   if (${::TECH($::type,$::corner,$::section,vth0Given)})
                    {   pParam->BSIM4v5vfb = ${::TECH($::type,$::corner,$::section,type)} * pParam->BSIM4v5vth0
                        - pParam->BSIM4v5phi - pParam->BSIM4v5k1
                        * pParam->BSIM4v5sqrtPhi;
                    }
                    else
                    {   pParam->BSIM4v5vfb = -1.0;
                    }
                }
                if (!${::TECH($::type,$::corner,$::section,vth0Given)})
                {   pParam->BSIM4v5vth0 = ${::TECH($::type,$::corner,$::section,type)} * (pParam->BSIM4v5vfb
                    + pParam->BSIM4v5phi + pParam->BSIM4v5k1
                    * pParam->BSIM4v5sqrtPhi);
                }
                
                pParam->BSIM4v5k1ox = pParam->BSIM4v5k1 * ${::TECH($::type,$::corner,$::section,toxe)}
                / ${::TECH($::type,$::corner,$::section,toxm)};
                
                tmp = sqrt(EPSSI / (${::TECH($::type,$::corner,$::section,epsrox)} * EPS0)
                * ${::TECH($::type,$::corner,$::section,toxe)} * pParam->BSIM4v5Xdep0);
                T0 = pParam->BSIM4v5dsub * pParam->BSIM4v5leff / tmp;
                if (T0 < EXP_THRESHOLD)
                {   T1 = exp(T0);
                    T2 = T1 - 1.0;
                    T3 = T2 * T2;
                    T4 = T3 + 2.0 * T1 * MIN_EXP;
                    pParam->BSIM4v5theta0vb0 = T1 / T4;
                }
                else
                pParam->BSIM4v5theta0vb0 = 1.0 / (MAX_EXP - 2.0);
                
                T0 = pParam->BSIM4v5drout * pParam->BSIM4v5leff / tmp;
                if (T0 < EXP_THRESHOLD)
                {   T1 = exp(T0);
                    T2 = T1 - 1.0;
                    T3 = T2 * T2;
                    T4 = T3 + 2.0 * T1 * MIN_EXP;
                    T5 = T1 / T4;
                }
                else
                T5 = 1.0 / (MAX_EXP - 2.0); /* 3.0 * MIN_EXP omitted */
                pParam->BSIM4v5thetaRout = pParam->BSIM4v5pdibl1 * T5
                + pParam->BSIM4v5pdibl2;
                
                tmp = sqrt(pParam->BSIM4v5Xdep0);
                tmp1 = pParam->BSIM4v5vbi - pParam->BSIM4v5phi;
                tmp2 = ${::TECH($::type,$::corner,$::section,factor1)} * tmp;
                
                T0 = pParam->BSIM4v5dvt1w * pParam->BSIM4v5weff
                * pParam->BSIM4v5leff / tmp2;
                if (T0 < EXP_THRESHOLD)
                {   T1 = exp(T0);
                    T2 = T1 - 1.0;
                    T3 = T2 * T2;
                    T4 = T3 + 2.0 * T1 * MIN_EXP;
                    T8 = T1 / T4;
                }
                else
                T8 = 1.0 / (MAX_EXP - 2.0);
                T0 = pParam->BSIM4v5dvt0w * T8;
                T8 = T0 * tmp1;
                
                T0 = pParam->BSIM4v5dvt1 * pParam->BSIM4v5leff / tmp2;
                if (T0 < EXP_THRESHOLD)
                {   T1 = exp(T0);
                    T2 = T1 - 1.0;
                    T3 = T2 * T2;
                    T4 = T3 + 2.0 * T1 * MIN_EXP;
                    T9 = T1 / T4;
                } 
                else
                T9 = 1.0 / (MAX_EXP - 2.0);
                T9 = pParam->BSIM4v5dvt0 * T9 * tmp1;
                
                T4 = ${::TECH($::type,$::corner,$::section,toxe)} * pParam->BSIM4v5phi
                / (pParam->BSIM4v5weff + pParam->BSIM4v5w0);
                
                T0 = sqrt(1.0 + pParam->BSIM4v5lpe0 / pParam->BSIM4v5leff);
                if((${::TECH($::type,$::corner,$::section,tempMod)} == 1) || (${::TECH($::type,$::corner,$::section,tempMod)} == 0))
                T3 = (pParam->BSIM4v5kt1 + pParam->BSIM4v5kt1l / pParam->BSIM4v5leff)
                * (TRatio - 1.0);
                if(${::TECH($::type,$::corner,$::section,tempMod)} == 2)
                T3 = - pParam->BSIM4v5kt1 * (TRatio - 1.0);
                
                T5 = pParam->BSIM4v5k1ox * (T0 - 1.0) * pParam->BSIM4v5sqrtPhi
                + T3;
                pParam->BSIM4v5vfbzbfactor = - T8 - T9 + pParam->BSIM4v5k3 * T4 + T5
                - pParam->BSIM4v5phi - pParam->BSIM4v5k1 * pParam->BSIM4v5sqrtPhi;
                
                /* stress effect */
                
                double wlod = ${::TECH($::type,$::corner,$::section,wlod)};
                if (${::TECH($::type,$::corner,$::section,wlod)} < 0.0)
                {   fprintf(stderr, "Warning: WLOD = %g is less than 0. 0.0 is used\n",${::TECH($::type,$::corner,$::section,wlod)});
                    wlod = 0.0;
                }
                T0 = pow(Lnew, ${::TECH($::type,$::corner,$::section,llodku0)});
                double W_tmp = Wnew + wlod;
                T1 = pow(W_tmp, ${::TECH($::type,$::corner,$::section,wlodku0)});
                tmp1 = ${::TECH($::type,$::corner,$::section,lku0)} / T0 + ${::TECH($::type,$::corner,$::section,wku0)} / T1
                + ${::TECH($::type,$::corner,$::section,pku0)} / (T0 * T1);
                pParam->BSIM4v5ku0 = 1.0 + tmp1;
                
                T0 = pow(Lnew, ${::TECH($::type,$::corner,$::section,llodvth)});
                T1 = pow(W_tmp, ${::TECH($::type,$::corner,$::section,wlodvth)});
                tmp1 = ${::TECH($::type,$::corner,$::section,lkvth0)} / T0 + ${::TECH($::type,$::corner,$::section,wkvth0)} / T1
                + ${::TECH($::type,$::corner,$::section,pkvth0)} / (T0 * T1);
                pParam->BSIM4v5kvth0 = 1.0 + tmp1;
                pParam->BSIM4v5kvth0 = sqrt(pParam->BSIM4v5kvth0*pParam->BSIM4v5kvth0 + DELTA);
                
                T0 = (TRatio - 1.0);
                pParam->BSIM4v5ku0temp = pParam->BSIM4v5ku0 * (1.0 + ${::TECH($::type,$::corner,$::section,tku0)} *T0) + DELTA;
                
                double Inv_saref = 1.0/(${::TECH($::type,$::corner,$::section,saref)} + 0.5*Ldrn);
                double Inv_sbref = 1.0/(${::TECH($::type,$::corner,$::section,sbref)} + 0.5*Ldrn);
                pParam->BSIM4v5inv_od_ref = Inv_saref + Inv_sbref;
                pParam->BSIM4v5rho_ref = ${::TECH($::type,$::corner,$::section,ku0)} / pParam->BSIM4v5ku0temp * pParam->BSIM4v5inv_od_ref;
                
                /*  stress effect */
                if( (here->BSIM4v5sa > 0.0) && (here->BSIM4v5sb > 0.0) && 
                ((here->BSIM4v5nf == 1.0) || ((here->BSIM4v5nf > 1.0) && (here->BSIM4v5sd > 0.0))) )
                {	double  Inv_sa = 0;
                    double Inv_sb = 0;
                    
                    double kvsat = ${::TECH($::type,$::corner,$::section,kvsat)};
                    if (${::TECH($::type,$::corner,$::section,kvsat)} < -1.0 )
                    {   fprintf(stderr, "Warning: KVSAT = %g is too small; -1.0 is used.\n",${::TECH($::type,$::corner,$::section,kvsat)});
                        kvsat = -1.0;
                    }
                    if (${::TECH($::type,$::corner,$::section,kvsat)} > 1.0)
                    {   fprintf(stderr, "Warning: KVSAT = %g is too big; 1.0 is used.\n",${::TECH($::type,$::corner,$::section,kvsat)});
                        kvsat = 1.0;
                    }
                    
                    for(i = 0; i < here->BSIM4v5nf; i++){
                        T0 = 1.0 / here->BSIM4v5nf / (here->BSIM4v5sa + 0.5*Ldrn + i * (here->BSIM4v5sd +Ldrn));
                        T1 = 1.0 / here->BSIM4v5nf / (here->BSIM4v5sb + 0.5*Ldrn + i * (here->BSIM4v5sd +Ldrn));
                        Inv_sa += T0;
                        Inv_sb += T1;
                    }
                    double Inv_ODeff = Inv_sa + Inv_sb; 
                    double rho = ${::TECH($::type,$::corner,$::section,ku0)} / pParam->BSIM4v5ku0temp * Inv_ODeff;
                    T0 = (1.0 + rho)/(1.0 + pParam->BSIM4v5rho_ref);
                    here->BSIM4v5u0temp = pParam->BSIM4v5u0temp * T0;
                    
                    T1 = (1.0 + kvsat * rho)/(1.0 + kvsat * pParam->BSIM4v5rho_ref);
                    here->BSIM4v5vsattemp = pParam->BSIM4v5vsattemp * T1;
                    
                    double OD_offset = Inv_ODeff - pParam->BSIM4v5inv_od_ref;
                    double dvth0_lod = ${::TECH($::type,$::corner,$::section,kvth0)} / pParam->BSIM4v5kvth0 * OD_offset;
                    dk2_lod = ${::TECH($::type,$::corner,$::section,stk2)} / pow(pParam->BSIM4v5kvth0, ${::TECH($::type,$::corner,$::section,lodk2)}) *
                    OD_offset;
                    deta0_lod = ${::TECH($::type,$::corner,$::section,steta0)} / pow(pParam->BSIM4v5kvth0, ${::TECH($::type,$::corner,$::section,lodeta0)}) *
                    OD_offset;
                    here->BSIM4v5vth0 = pParam->BSIM4v5vth0 + dvth0_lod;
                    
                    here->BSIM4v5eta0 = pParam->BSIM4v5eta0 + deta0_lod;
                    here->BSIM4v5k2 = pParam->BSIM4v5k2 + dk2_lod;
                } else {
                    here->BSIM4v5u0temp = pParam->BSIM4v5u0temp;
                    here->BSIM4v5vth0 = pParam->BSIM4v5vth0;
                    here->BSIM4v5vsattemp = pParam->BSIM4v5vsattemp;
                    here->BSIM4v5eta0 = pParam->BSIM4v5eta0;
                    here->BSIM4v5k2 = pParam->BSIM4v5k2;
                }
                
                /*  Well Proximity Effect  */
                if (${::TECH($::type,$::corner,$::section,wpemod)})   
                { if( (!here->BSIM4v5scaGiven) && (!here->BSIM4v5scbGiven) && (!here->BSIM4v5sccGiven) )
                    {   if((here->BSIM4v5scGiven) && (here->BSIM4v5sc > 0.0) )
                        {   T1 = here->BSIM4v5sc + Wdrn;
                            T2 = 1.0 / ${::TECH($::type,$::corner,$::section,scref)};
                            here->BSIM4v5sca = ${::TECH($::type,$::corner,$::section,scref)} * ${::TECH($::type,$::corner,$::section,scref)} 
                            / (here->BSIM4v5sc * T1);		
                            here->BSIM4v5scb = ( (0.1 * here->BSIM4v5sc + 0.01 * ${::TECH($::type,$::corner,$::section,scref)}) 
                            * exp(-10.0 * here->BSIM4v5sc * T2)  
                            - (0.1 * T1 + 0.01 * ${::TECH($::type,$::corner,$::section,scref)}) 
                            * exp(-10.0 * T1 * T2) ) / Wdrn;
                            here->BSIM4v5scc = ( (0.05 * here->BSIM4v5sc + 0.0025 * ${::TECH($::type,$::corner,$::section,scref)})
                            * exp(-20.0 * here->BSIM4v5sc * T2)  
                            - (0.05 * T1 + 0.0025 * ${::TECH($::type,$::corner,$::section,scref)}) 
                            * exp(-20.0 * T1 * T2) ) / Wdrn;
                        } else { 
                            //fprintf(stderr, "Warning: No WPE as none of SCA, SCB, SCC, SC is given and/or SC not positive.\n");
                        }
                    }
                    double sceff = here->BSIM4v5sca + ${::TECH($::type,$::corner,$::section,web)} * here->BSIM4v5scb 
                    + ${::TECH($::type,$::corner,$::section,wec)} * here->BSIM4v5scc;
                    here->BSIM4v5vth0 += pParam->BSIM4v5kvth0we * sceff;
                    here->BSIM4v5k2 +=  pParam->BSIM4v5k2we * sceff;
                    T3 =  1.0 + pParam->BSIM4v5ku0we * sceff;
                    if (T3 <= 0.0) 
                    { 	
                        fprintf(stderr, "Warning: ku0we = %g is negatively too high. Negative mobility! \n", T3);
                        T3 = 0.0;
                    }
                    here->BSIM4v5u0temp *= T3; 
                }
                
                /* adding delvto  */
                here->BSIM4v5vth0 += here->BSIM4v5delvto;
                here->BSIM4v5vfb = pParam->BSIM4v5vfb + ${::TECH($::type,$::corner,$::section,type)} * here->BSIM4v5delvto;
                
                /* Instance variables calculation  */ 
                T3 = ${::TECH($::type,$::corner,$::section,type)} * here->BSIM4v5vth0
                - here->BSIM4v5vfb - pParam->BSIM4v5phi;
                T4 = T3 + T3;
                T5 = 2.5 * T3;
                here->BSIM4v5vtfbphi1 = (${::TECH($::type,$::corner,$::section,type)} == NMOS) ? T4 : T5;
                if (here->BSIM4v5vtfbphi1 < 0.0)
                here->BSIM4v5vtfbphi1 = 0.0;
                
                here->BSIM4v5vtfbphi2 = 4.0 * T3;
                if (here->BSIM4v5vtfbphi2 < 0.0)
                here->BSIM4v5vtfbphi2 = 0.0;
                
                if (here->BSIM4v5k2 < 0.0)
                {   T0 = 0.5 * pParam->BSIM4v5k1 / here->BSIM4v5k2;
                    here->BSIM4v5vbsc = 0.9 * (pParam->BSIM4v5phi - T0 * T0);
                    if (here->BSIM4v5vbsc > -3.0)
                    here->BSIM4v5vbsc = -3.0;
                    else if (here->BSIM4v5vbsc < -30.0)
                    here->BSIM4v5vbsc = -30.0;
                }
                else
                here->BSIM4v5vbsc = -30.0;
                if (here->BSIM4v5vbsc > pParam->BSIM4v5vbm)
                here->BSIM4v5vbsc = pParam->BSIM4v5vbm;
                here->BSIM4v5k2ox = here->BSIM4v5k2 * ${::TECH($::type,$::corner,$::section,toxe)}
                / ${::TECH($::type,$::corner,$::section,toxm)};
                
                here->BSIM4v5vfbzb = pParam->BSIM4v5vfbzbfactor 
                +  ${::TECH($::type,$::corner,$::section,type)} * here->BSIM4v5vth0 ;
                
                here->BSIM4v5cgso = pParam->BSIM4v5cgso;
                here->BSIM4v5cgdo = pParam->BSIM4v5cgdo;
                double lnl = log(pParam->BSIM4v5leff * 1.0e6);
                double lnw = log(pParam->BSIM4v5weff * 1.0e6);
                double lnnf = log(here->BSIM4v5nf);
                
                bodymode = 5;
                if( ( !${::TECH($::type,$::corner,$::section,rbps0Given)}) || 
                ( !${::TECH($::type,$::corner,$::section,rbpd0Given)}) )
                bodymode = 1;
                else 
                if( (!${::TECH($::type,$::corner,$::section,rbsbx0Given)} && !${::TECH($::type,$::corner,$::section,rbsby0Given)}) ||
                (!${::TECH($::type,$::corner,$::section,rbdbx0Given)} && !${::TECH($::type,$::corner,$::section,rbdby0Given)}) )
                bodymode = 3;
                
                if(here->BSIM4v5rbodyMod == 2)
                {
                    if (bodymode == 5)
                    { 
                        double rbsbx =  exp( log(${::TECH($::type,$::corner,$::section,rbsbx0)}) + ${::TECH($::type,$::corner,$::section,rbsdbxl)} * lnl +  
                        ${::TECH($::type,$::corner,$::section,rbsdbxw)} * lnw + ${::TECH($::type,$::corner,$::section,rbsdbxnf)} * lnnf );
                        double rbsby =  exp( log(${::TECH($::type,$::corner,$::section,rbsby0)}) + ${::TECH($::type,$::corner,$::section,rbsdbyl)} * lnl +  
                        ${::TECH($::type,$::corner,$::section,rbsdbyw)} * lnw + ${::TECH($::type,$::corner,$::section,rbsdbynf)} * lnnf );
                        here->BSIM4v5rbsb = rbsbx * rbsby / (rbsbx + rbsby);
                        
                        
                        double rbdbx =  exp( log(${::TECH($::type,$::corner,$::section,rbdbx0)}) + ${::TECH($::type,$::corner,$::section,rbsdbxl)} * lnl +  
                        ${::TECH($::type,$::corner,$::section,rbsdbxw)} * lnw + ${::TECH($::type,$::corner,$::section,rbsdbxnf)} * lnnf );
                        double rbdby =  exp( log(${::TECH($::type,$::corner,$::section,rbdby0)}) + ${::TECH($::type,$::corner,$::section,rbsdbyl)} * lnl +  
                        ${::TECH($::type,$::corner,$::section,rbsdbyw)} * lnw + ${::TECH($::type,$::corner,$::section,rbsdbynf)} * lnnf );
                        here->BSIM4v5rbdb = rbdbx * rbdby / (rbdbx + rbdby);
                    }
                    
                    if ((bodymode == 3)|| (bodymode == 5)) 
                    {
                        here->BSIM4v5rbps = exp( log(${::TECH($::type,$::corner,$::section,rbps0)}) + ${::TECH($::type,$::corner,$::section,rbpsl)} * lnl +  
                        ${::TECH($::type,$::corner,$::section,rbpsw)} * lnw + ${::TECH($::type,$::corner,$::section,rbpsnf)} * lnnf );
                        here->BSIM4v5rbpd = exp( log(${::TECH($::type,$::corner,$::section,rbpd0)}) + ${::TECH($::type,$::corner,$::section,rbpdl)} * lnl +  
                        ${::TECH($::type,$::corner,$::section,rbpdw)} * lnw + ${::TECH($::type,$::corner,$::section,rbpdnf)} * lnnf );
                    }
                    
                    double rbpbx =  exp( log(${::TECH($::type,$::corner,$::section,rbpbx0)}) + ${::TECH($::type,$::corner,$::section,rbpbxl)} * lnl +  
                    ${::TECH($::type,$::corner,$::section,rbpbxw)} * lnw + ${::TECH($::type,$::corner,$::section,rbpbxnf)} * lnnf );
                    double rbpby =  exp( log(${::TECH($::type,$::corner,$::section,rbpby0)}) + ${::TECH($::type,$::corner,$::section,rbpbyl)} * lnl +  
                    ${::TECH($::type,$::corner,$::section,rbpbyw)} * lnw + ${::TECH($::type,$::corner,$::section,rbpbynf)} * lnnf );
                    here->BSIM4v5rbpb = rbpbx*rbpby/(rbpbx + rbpby);
                }
                
                
                if ((here->BSIM4v5rbodyMod == 1 ) || ((here->BSIM4v5rbodyMod == 2 ) && (bodymode == 5)) )
                {   if (here->BSIM4v5rbdb < 1.0e-3)
                    here->BSIM4v5grbdb = 1.0e3; /* in mho */
                    else
                    here->BSIM4v5grbdb = ${::TECH($::type,$::corner,$::section,gbmin)} + 1.0 / here->BSIM4v5rbdb;
                    if (here->BSIM4v5rbpb < 1.0e-3)
                    here->BSIM4v5grbpb = 1.0e3;
                    else
                    here->BSIM4v5grbpb = ${::TECH($::type,$::corner,$::section,gbmin)} + 1.0 / here->BSIM4v5rbpb;
                    if (here->BSIM4v5rbps < 1.0e-3)
                    here->BSIM4v5grbps = 1.0e3;
                    else
                    here->BSIM4v5grbps = ${::TECH($::type,$::corner,$::section,gbmin)} + 1.0 / here->BSIM4v5rbps;
                    if (here->BSIM4v5rbsb < 1.0e-3)
                    here->BSIM4v5grbsb = 1.0e3;
                    else
                    here->BSIM4v5grbsb = ${::TECH($::type,$::corner,$::section,gbmin)} + 1.0 / here->BSIM4v5rbsb;
                    if (here->BSIM4v5rbpd < 1.0e-3)
                    here->BSIM4v5grbpd = 1.0e3;
                    else
                    here->BSIM4v5grbpd = ${::TECH($::type,$::corner,$::section,gbmin)} + 1.0 / here->BSIM4v5rbpd;
                    
                }
                
                if((here->BSIM4v5rbodyMod == 2) && (bodymode == 3)) 
                {   
                    here->BSIM4v5grbdb = here->BSIM4v5grbsb = ${::TECH($::type,$::corner,$::section,gbmin)};
                    if (here->BSIM4v5rbpb < 1.0e-3)
                    here->BSIM4v5grbpb = 1.0e3;
                    else
                    here->BSIM4v5grbpb = ${::TECH($::type,$::corner,$::section,gbmin)} + 1.0 / here->BSIM4v5rbpb;
                    if (here->BSIM4v5rbps < 1.0e-3)
                    here->BSIM4v5grbps = 1.0e3;
                    else
                    here->BSIM4v5grbps = ${::TECH($::type,$::corner,$::section,gbmin)} + 1.0 / here->BSIM4v5rbps;
                    if (here->BSIM4v5rbpd < 1.0e-3)
                    here->BSIM4v5grbpd = 1.0e3;
                    else
                    here->BSIM4v5grbpd = ${::TECH($::type,$::corner,$::section,gbmin)} + 1.0 / here->BSIM4v5rbpd;
                }
                
                if((here->BSIM4v5rbodyMod == 2) && (bodymode == 1)) 
                {   
                    here->BSIM4v5grbdb = here->BSIM4v5grbsb = ${::TECH($::type,$::corner,$::section,gbmin)};
                    here->BSIM4v5grbps = here->BSIM4v5grbpd = 1.0e3;
                    if (here->BSIM4v5rbpb < 1.0e-3)
                    here->BSIM4v5grbpb = 1.0e3;
                    else
                    here->BSIM4v5grbpb = ${::TECH($::type,$::corner,$::section,gbmin)} + 1.0 / here->BSIM4v5rbpb;
                }
                
                
                /* 
                * Process geomertry dependent parasitics
                */
                
                here->BSIM4v5grgeltd = ${::TECH($::type,$::corner,$::section,rshg)} * (here->BSIM4v5xgw
                + pParam->BSIM4v5weffCJ / 3.0 / here->BSIM4v5ngcon) /
                (here->BSIM4v5ngcon * here->BSIM4v5nf *
                (Lnew - ${::TECH($::type,$::corner,$::section,xgl)}));
                if (here->BSIM4v5grgeltd > 0.0)
                here->BSIM4v5grgeltd = 1.0 / here->BSIM4v5grgeltd;
                else
                {   here->BSIM4v5grgeltd = 1.0e3; /* mho */
                    if (here->BSIM4v5rgateMod != 0)
                    printf("Warning: The gate conductance reset to 1.0e3 mho.\n");
                }
                
                DMCGeff = ${::TECH($::type,$::corner,$::section,dmcg)} - ${::TECH($::type,$::corner,$::section,dmcgt)};
                DMCIeff = ${::TECH($::type,$::corner,$::section,dmci)};
                DMDGeff = ${::TECH($::type,$::corner,$::section,dmdg)} - ${::TECH($::type,$::corner,$::section,dmcgt)};

                if (here->BSIM4v5sourcePerimeterGiven)
                {   if (${::TECH($::type,$::corner,$::section,perMod)} == 0)
                    here->BSIM4v5Pseff = here->BSIM4v5sourcePerimeter;
                    else
                    here->BSIM4v5Pseff = here->BSIM4v5sourcePerimeter 
                    - pParam->BSIM4v5weffCJ * here->BSIM4v5nf;
                }
                else
                BSIM4v5PAeffGeo(here->BSIM4v5nf, here->BSIM4v5geoMod, here->BSIM4v5min, 
                pParam->BSIM4v5weffCJ, DMCGeff, DMCIeff, DMDGeff,
                &(here->BSIM4v5Pseff), &dumPd, &dumAs, &dumAd);
                
                if (here->BSIM4v5drainPerimeterGiven)
                {   if (${::TECH($::type,$::corner,$::section,perMod)} == 0)
                    here->BSIM4v5Pdeff = here->BSIM4v5drainPerimeter;
                    else
                    here->BSIM4v5Pdeff = here->BSIM4v5drainPerimeter 
                    - pParam->BSIM4v5weffCJ * here->BSIM4v5nf;
                }
                else
                BSIM4v5PAeffGeo(here->BSIM4v5nf, here->BSIM4v5geoMod, here->BSIM4v5min,
                pParam->BSIM4v5weffCJ, DMCGeff, DMCIeff, DMDGeff,
                &dumPs, &(here->BSIM4v5Pdeff), &dumAs, &dumAd);
                
                if (here->BSIM4v5sourceAreaGiven)
                here->BSIM4v5Aseff = here->BSIM4v5sourceArea;
                else
                BSIM4v5PAeffGeo(here->BSIM4v5nf, here->BSIM4v5geoMod, here->BSIM4v5min,
                pParam->BSIM4v5weffCJ, DMCGeff, DMCIeff, DMDGeff,
                &dumPs, &dumPd, &(here->BSIM4v5Aseff), &dumAd);
                
                if (here->BSIM4v5drainAreaGiven)
                here->BSIM4v5Adeff = here->BSIM4v5drainArea;
                else
                BSIM4v5PAeffGeo(here->BSIM4v5nf, here->BSIM4v5geoMod, here->BSIM4v5min,
                pParam->BSIM4v5weffCJ, DMCGeff, DMCIeff, DMDGeff,
                &dumPs, &dumPd, &dumAs, &(here->BSIM4v5Adeff));
                
                /* Processing S/D resistance and conductance below */
                if(here->BSIM4v5sNodePrime != here->BSIM4v5sNode)
                {
                    here->BSIM4v5sourceConductance = 0.0;
                    if(here->BSIM4v5sourceSquaresGiven)
                    {
                        here->BSIM4v5sourceConductance = ${::TECH($::type,$::corner,$::section,sheetResistance)}
                        * here->BSIM4v5sourceSquares;
                    } else if (here->BSIM4v5rgeoMod > 0)
                    {
                        BSIM4v5RdseffGeo(here->BSIM4v5nf, here->BSIM4v5geoMod,
                        here->BSIM4v5rgeoMod, here->BSIM4v5min,
                        pParam->BSIM4v5weffCJ, ${::TECH($::type,$::corner,$::section,sheetResistance)},
                        DMCGeff, DMCIeff, DMDGeff, 1, &(here->BSIM4v5sourceConductance));
                    } else
                    {
                        here->BSIM4v5sourceConductance = 0.0;
                    }
                    
                    if (here->BSIM4v5sourceConductance > 0.0)
                    here->BSIM4v5sourceConductance = 1.0
                    / here->BSIM4v5sourceConductance;
                    else
                    {
                        here->BSIM4v5sourceConductance = 1.0e3; /* mho */
                        printf ("Warning: Source conductance reset to 1.0e3 mho.\n");
                    }
                } else
                {
                    here->BSIM4v5sourceConductance = 0.0;
                }
                
                if(here->BSIM4v5dNodePrime != here->BSIM4v5dNode)
                {
                    here->BSIM4v5drainConductance = 0.0;
                    if(here->BSIM4v5drainSquaresGiven)
                    {
                        here->BSIM4v5drainConductance = ${::TECH($::type,$::corner,$::section,sheetResistance)}
                        * here->BSIM4v5drainSquares;
                    } else if (here->BSIM4v5rgeoMod > 0)
                    {
                        BSIM4v5RdseffGeo(here->BSIM4v5nf, here->BSIM4v5geoMod,
                        here->BSIM4v5rgeoMod, here->BSIM4v5min,
                        pParam->BSIM4v5weffCJ, ${::TECH($::type,$::corner,$::section,sheetResistance)},
                        DMCGeff, DMCIeff, DMDGeff, 0, &(here->BSIM4v5drainConductance));
                    } else
                    {
                        here->BSIM4v5drainConductance = 0.0;
                    }
                    
                    if (here->BSIM4v5drainConductance > 0.0)
                    here->BSIM4v5drainConductance = 1.0
                    / here->BSIM4v5drainConductance;
                    else
                    {
                        here->BSIM4v5drainConductance = 1.0e3; /* mho */
                        printf ("Warning: Drain conductance reset to 1.0e3 mho.\n");
                    }
                } else
                {
                    here->BSIM4v5drainConductance = 0.0;
                }
                
                /* End of Rsd processing */
                
                
                Nvtms = ${::TECH($::type,$::corner,$::section,vtm)} * ${::TECH($::type,$::corner,$::section,SjctEmissionCoeff)};
                if ((here->BSIM4v5Aseff <= 0.0) && (here->BSIM4v5Pseff <= 0.0))
                {   SourceSatCurrent = 1.0e-14;
                }
                else
                {   SourceSatCurrent = here->BSIM4v5Aseff * ${::TECH($::type,$::corner,$::section,SjctTempSatCurDensity)}
                    + here->BSIM4v5Pseff * ${::TECH($::type,$::corner,$::section,SjctSidewallTempSatCurDensity)}
                    + pParam->BSIM4v5weffCJ * here->BSIM4v5nf
                    * ${::TECH($::type,$::corner,$::section,SjctGateSidewallTempSatCurDensity)};
                }
                if (SourceSatCurrent > 0.0)
                {   switch(${::TECH($::type,$::corner,$::section,dioMod)})
                    {   case 0:
                        if ((${::TECH($::type,$::corner,$::section,bvs)} / Nvtms) > EXP_THRESHOLD)
                        here->BSIM4v5XExpBVS = ${::TECH($::type,$::corner,$::section,xjbvs)} * MIN_EXP;
                        else
                        here->BSIM4v5XExpBVS = ${::TECH($::type,$::corner,$::section,xjbvs)} * exp(-${::TECH($::type,$::corner,$::section,bvs)} / Nvtms);	
                        break;
                        case 1:
                        BSIM4v5DioIjthVjmEval_Gamma(Nvtms, ${::TECH($::type,$::corner,$::section,ijthsfwd)}, SourceSatCurrent, 
                        0.0, &(here->BSIM4v5vjsmFwd));
                        here->BSIM4v5IVjsmFwd = SourceSatCurrent * exp(here->BSIM4v5vjsmFwd / Nvtms);
                        break;
                        case 2:
                        if ((${::TECH($::type,$::corner,$::section,bvs)} / Nvtms) > EXP_THRESHOLD)
                        {   here->BSIM4v5XExpBVS = ${::TECH($::type,$::corner,$::section,xjbvs)} * MIN_EXP;
                            tmp = MIN_EXP;
                        }
                        else
                        {   here->BSIM4v5XExpBVS = exp(-${::TECH($::type,$::corner,$::section,bvs)} / Nvtms);
                            tmp = here->BSIM4v5XExpBVS;
                            here->BSIM4v5XExpBVS *= ${::TECH($::type,$::corner,$::section,xjbvs)};	
                        }
                        
                        BSIM4v5DioIjthVjmEval_Gamma(Nvtms, ${::TECH($::type,$::corner,$::section,ijthsfwd)}, SourceSatCurrent, 
                        here->BSIM4v5XExpBVS, &(here->BSIM4v5vjsmFwd));
                        T0 = exp(here->BSIM4v5vjsmFwd / Nvtms);
                        here->BSIM4v5IVjsmFwd = SourceSatCurrent * (T0 - here->BSIM4v5XExpBVS / T0
                        + here->BSIM4v5XExpBVS - 1.0);
                        here->BSIM4v5SslpFwd = SourceSatCurrent
                        * (T0 + here->BSIM4v5XExpBVS / T0) / Nvtms;
                        
                        T2 = ${::TECH($::type,$::corner,$::section,ijthsrev)} / SourceSatCurrent;
                        if (T2 < 1.0)
                        {   T2 = 10.0;
                            fprintf(stderr, "Warning: ijthsrev too small and set to 10 times IsbSat.\n");
                        } 
                        here->BSIM4v5vjsmRev = -${::TECH($::type,$::corner,$::section,bvs)}
                        - Nvtms * log((T2 - 1.0) / ${::TECH($::type,$::corner,$::section,xjbvs)});
                        T1 = ${::TECH($::type,$::corner,$::section,xjbvs)} * exp(-(${::TECH($::type,$::corner,$::section,bvs)}
                        + here->BSIM4v5vjsmRev) / Nvtms);
                        here->BSIM4v5IVjsmRev = SourceSatCurrent * (1.0 + T1);
                        here->BSIM4v5SslpRev = -SourceSatCurrent * T1 / Nvtms;
                        break;
                        default:
                        printf("Specified dioMod = %d not matched\n", ${::TECH($::type,$::corner,$::section,dioMod)});
                    }
                }
                
                Nvtmd = ${::TECH($::type,$::corner,$::section,vtm)} * ${::TECH($::type,$::corner,$::section,DjctEmissionCoeff)};
                if ((here->BSIM4v5Adeff <= 0.0) && (here->BSIM4v5Pdeff <= 0.0))
                {   DrainSatCurrent = 1.0e-14;
                }
                else
                {   DrainSatCurrent = here->BSIM4v5Adeff * ${::TECH($::type,$::corner,$::section,DjctTempSatCurDensity)}
                    + here->BSIM4v5Pdeff * ${::TECH($::type,$::corner,$::section,DjctSidewallTempSatCurDensity)}
                    + pParam->BSIM4v5weffCJ * here->BSIM4v5nf
                    * ${::TECH($::type,$::corner,$::section,DjctGateSidewallTempSatCurDensity)};
                }
                if (DrainSatCurrent > 0.0)
                {   switch(${::TECH($::type,$::corner,$::section,dioMod)})
                    {   case 0:
                        if ((${::TECH($::type,$::corner,$::section,bvd)} / Nvtmd) > EXP_THRESHOLD)
                        here->BSIM4v5XExpBVD = ${::TECH($::type,$::corner,$::section,xjbvd)} * MIN_EXP;
                        else
                        here->BSIM4v5XExpBVD = ${::TECH($::type,$::corner,$::section,xjbvd)} * exp(-${::TECH($::type,$::corner,$::section,bvd)} / Nvtmd);
                        break;
                        case 1:
                        BSIM4v5DioIjthVjmEval_Gamma(Nvtmd, ${::TECH($::type,$::corner,$::section,ijthdfwd)}, DrainSatCurrent,
                        0.0, &(here->BSIM4v5vjdmFwd));
                        here->BSIM4v5IVjdmFwd = DrainSatCurrent * exp(here->BSIM4v5vjdmFwd / Nvtmd);
                        break;
                        case 2:
                        if ((${::TECH($::type,$::corner,$::section,bvd)} / Nvtmd) > EXP_THRESHOLD)
                        {   here->BSIM4v5XExpBVD = ${::TECH($::type,$::corner,$::section,xjbvd)} * MIN_EXP;
                            tmp = MIN_EXP;
                        }
                        else
                        {   here->BSIM4v5XExpBVD = exp(-${::TECH($::type,$::corner,$::section,bvd)} / Nvtmd);
                            tmp = here->BSIM4v5XExpBVD;
                            here->BSIM4v5XExpBVD *= ${::TECH($::type,$::corner,$::section,xjbvd)};
                        }
                        
                        BSIM4v5DioIjthVjmEval_Gamma(Nvtmd, ${::TECH($::type,$::corner,$::section,ijthdfwd)}, DrainSatCurrent,
                        here->BSIM4v5XExpBVD, &(here->BSIM4v5vjdmFwd));
                        T0 = exp(here->BSIM4v5vjdmFwd / Nvtmd);
                        here->BSIM4v5IVjdmFwd = DrainSatCurrent * (T0 - here->BSIM4v5XExpBVD / T0
                        + here->BSIM4v5XExpBVD - 1.0);
                        here->BSIM4v5DslpFwd = DrainSatCurrent
                        * (T0 + here->BSIM4v5XExpBVD / T0) / Nvtmd;
                        
                        T2 = ${::TECH($::type,$::corner,$::section,ijthdrev)} / DrainSatCurrent;
                        if (T2 < 1.0) 
                        {   T2 = 10.0;
                            fprintf(stderr, "Warning: ijthdrev too small and set to 10 times IdbSat.\n");
                        }
                        here->BSIM4v5vjdmRev = -${::TECH($::type,$::corner,$::section,bvd)}
                        - Nvtmd * log((T2 - 1.0) / ${::TECH($::type,$::corner,$::section,xjbvd)}); /* bugfix */
                        T1 = ${::TECH($::type,$::corner,$::section,xjbvd)} * exp(-(${::TECH($::type,$::corner,$::section,bvd)}
                        + here->BSIM4v5vjdmRev) / Nvtmd);
                        here->BSIM4v5IVjdmRev = DrainSatCurrent * (1.0 + T1);
                        here->BSIM4v5DslpRev = -DrainSatCurrent * T1 / Nvtmd;
                        break;
                        default:
                        printf("Specified dioMod = %d not matched\n", ${::TECH($::type,$::corner,$::section,dioMod)});
                    }
                }
                
                /* GEDL current reverse bias */
                T0 = (TRatio - 1.0);
                T7 = Eg0 / ${::TECH($::type,$::corner,$::section,vtm)} * T0;
                T9 = ${::TECH($::type,$::corner,$::section,xtss)} * T7;
                DEXP(T9, T1);
                T9 = ${::TECH($::type,$::corner,$::section,xtsd)} * T7;
                DEXP(T9, T2);
                T9 = ${::TECH($::type,$::corner,$::section,xtssws)} * T7;
                DEXP(T9, T3);
                T9 = ${::TECH($::type,$::corner,$::section,xtsswd)} * T7;
                DEXP(T9, T4);
                T9 = ${::TECH($::type,$::corner,$::section,xtsswgs)} * T7;
                DEXP(T9, T5);
                T9 = ${::TECH($::type,$::corner,$::section,xtsswgd)} * T7;
                DEXP(T9, T6);
                
                T10 = pParam->BSIM4v5weffCJ * here->BSIM4v5nf;
                here->BSIM4v5SjctTempRevSatCur = T1 * here->BSIM4v5Aseff * ${::TECH($::type,$::corner,$::section,jtss)};
                here->BSIM4v5DjctTempRevSatCur = T2 * here->BSIM4v5Adeff * ${::TECH($::type,$::corner,$::section,jtsd)};
                here->BSIM4v5SswTempRevSatCur = T3 * here->BSIM4v5Pseff * ${::TECH($::type,$::corner,$::section,jtssws)};
                here->BSIM4v5DswTempRevSatCur = T4 * here->BSIM4v5Pdeff * ${::TECH($::type,$::corner,$::section,jtsswd)};
                here->BSIM4v5SswgTempRevSatCur = T5 * T10 * ${::TECH($::type,$::corner,$::section,jtsswgs)};
                here->BSIM4v5DswgTempRevSatCur = T6 * T10 * ${::TECH($::type,$::corner,$::section,jtsswgd)};
                
                if ((Mode & MODEINITSMSIG))
                {   vds = *(cktState0 + here->BSIM4v5vds);
                    vgs = *(cktState0 + here->BSIM4v5vgs);
                    vbs = *(cktState0 + here->BSIM4v5vbs);
                    vges = *(cktState0 + here->BSIM4v5vges);
                    vgms = *(cktState0 + here->BSIM4v5vgms);
                    vdbs = *(cktState0 + here->BSIM4v5vdbs);
                    vsbs = *(cktState0 + here->BSIM4v5vsbs);
                    vses = *(cktState0 + here->BSIM4v5vses);
                    vdes = *(cktState0 + here->BSIM4v5vdes);
                    
                    qdef = *(cktState0 + here->BSIM4v5qdef);
                }
                else if ((Mode & MODEINITTRAN))
                {   vds = *(cktState1 + here->BSIM4v5vds);
                    vgs = *(cktState1 + here->BSIM4v5vgs);
                    vbs = *(cktState1 + here->BSIM4v5vbs);
                    vges = *(cktState1 + here->BSIM4v5vges);
                    vgms = *(cktState1 + here->BSIM4v5vgms);
                    vdbs = *(cktState1 + here->BSIM4v5vdbs);
                    vsbs = *(cktState1 + here->BSIM4v5vsbs);
                    vses = *(cktState1 + here->BSIM4v5vses);
                    vdes = *(cktState1 + here->BSIM4v5vdes);
                    
                    qdef = *(cktState1 + here->BSIM4v5qdef);
                }
                else if ((Mode & MODEINITJCT) && !here->BSIM4v5off)
                {   vds = ${::TECH($::type,$::corner,$::section,type)} * here->BSIM4v5icVDS;
                    vgs = vges = vgms = ${::TECH($::type,$::corner,$::section,type)} * here->BSIM4v5icVGS;
                    vbs = vdbs = vsbs = ${::TECH($::type,$::corner,$::section,type)} * here->BSIM4v5icVBS;
                    if (vds > 0.0)
                    {   vdes = vds + 0.01;
                        vses = -0.01;
                    }
                    else if (vds < 0.0)
                    {   vdes = vds - 0.01;
                        vses = 0.01;
                    }
                    else
                    vdes = vses = 0.0;
                    
                    qdef = 0.0;
                    
                    if ((vds == 0.0) && (vgs == 0.0) && (vbs == 0.0) &&
                    ((Mode & (MODETRAN | MODEAC|MODEDCOP |
                    MODEDCTRANCURVE)) || (!(Mode & MODEUIC))))
                    {   vds = 0.1;
                        vdes = 0.11;
                        vses = -0.01;
                        vgs = vges = vgms = ${::TECH($::type,$::corner,$::section,type)} 
                        * here->BSIM4v5vth0 + 0.1;
                        vbs = vdbs = vsbs = 0.0;
                    }
                }
                else if ((Mode & (MODEINITJCT | MODEINITFIX)) && 
                (here->BSIM4v5off)) 
                {   
                    vds = vgs = vbs = vges = vgms = 0.0;
                    vdbs = vsbs = vdes = vses = qdef = 0.0;
                }
                else
                {
                    #ifndef PREDICTOR
                    if ((Mode & MODEINITPRED))
                    {   xfact = Delta / DeltaOld[1];
                        *(cktState0 + here->BSIM4v5vds) = 
                        *(cktState1 + here->BSIM4v5vds);
                        vds = (1.0 + xfact)* (*(cktState1 + here->BSIM4v5vds))
                        - (xfact * (*(cktState2 + here->BSIM4v5vds)));
                        *(cktState0 + here->BSIM4v5vgs) = 
                        *(cktState1 + here->BSIM4v5vgs);
                        vgs = (1.0 + xfact)* (*(cktState1 + here->BSIM4v5vgs))
                        - (xfact * (*(cktState2 + here->BSIM4v5vgs)));
                        *(cktState0 + here->BSIM4v5vges) =
                        *(cktState1 + here->BSIM4v5vges);
                        vges = (1.0 + xfact)* (*(cktState1 + here->BSIM4v5vges))
                        - (xfact * (*(cktState2 + here->BSIM4v5vges)));
                        *(cktState0 + here->BSIM4v5vgms) =
                        *(cktState1 + here->BSIM4v5vgms);
                        vgms = (1.0 + xfact)* (*(cktState1 + here->BSIM4v5vgms))
                        - (xfact * (*(cktState2 + here->BSIM4v5vgms)));
                        *(cktState0 + here->BSIM4v5vbs) = 
                        *(cktState1 + here->BSIM4v5vbs);
                        vbs = (1.0 + xfact)* (*(cktState1 + here->BSIM4v5vbs))
                        - (xfact * (*(cktState2 + here->BSIM4v5vbs)));
                        *(cktState0 + here->BSIM4v5vbd) = 
                        *(cktState0 + here->BSIM4v5vbs)
                        - *(cktState0 + here->BSIM4v5vds);
                        *(cktState0 + here->BSIM4v5vdbs) =
                        *(cktState1 + here->BSIM4v5vdbs);
                        vdbs = (1.0 + xfact)* (*(cktState1 + here->BSIM4v5vdbs))
                        - (xfact * (*(cktState2 + here->BSIM4v5vdbs)));
                        *(cktState0 + here->BSIM4v5vdbd) =
                        *(cktState0 + here->BSIM4v5vdbs)
                        - *(cktState0 + here->BSIM4v5vds);
                        *(cktState0 + here->BSIM4v5vsbs) =
                        *(cktState1 + here->BSIM4v5vsbs);
                        vsbs = (1.0 + xfact)* (*(cktState1 + here->BSIM4v5vsbs))
                        - (xfact * (*(cktState2 + here->BSIM4v5vsbs)));
                        *(cktState0 + here->BSIM4v5vses) =
                        *(cktState1 + here->BSIM4v5vses);
                        vses = (1.0 + xfact)* (*(cktState1 + here->BSIM4v5vses))
                        - (xfact * (*(cktState2 + here->BSIM4v5vses)));
                        *(cktState0 + here->BSIM4v5vdes) =
                        *(cktState1 + here->BSIM4v5vdes);
                        vdes = (1.0 + xfact)* (*(cktState1 + here->BSIM4v5vdes))
                        - (xfact * (*(cktState2 + here->BSIM4v5vdes)));
                        
                        *(cktState0 + here->BSIM4v5qdef) =
                        *(cktState1 + here->BSIM4v5qdef);
                        qdef = (1.0 + xfact)* (*(cktState1 + here->BSIM4v5qdef))
                        -(xfact * (*(cktState2 + here->BSIM4v5qdef)));
                    }
                    else
                    {
                        #endif /* PREDICTOR */
                        vds = ${::TECH($::type,$::corner,$::section,type)}
                        * (*(RHSOld + here->BSIM4v5dNodePrime)
                        - *(RHSOld + here->BSIM4v5sNodePrime));
                        vgs = ${::TECH($::type,$::corner,$::section,type)}
                        * (*(RHSOld + here->BSIM4v5gNodePrime) 
                        - *(RHSOld + here->BSIM4v5sNodePrime));
                        vbs = ${::TECH($::type,$::corner,$::section,type)}
                        * (*(RHSOld + here->BSIM4v5bNodePrime)
                        - *(RHSOld + here->BSIM4v5sNodePrime));
                        vges = ${::TECH($::type,$::corner,$::section,type)}
                        * (*(RHSOld + here->BSIM4v5gNodeExt)
                        - *(RHSOld + here->BSIM4v5sNodePrime));
                        vgms = ${::TECH($::type,$::corner,$::section,type)}
                        * (*(RHSOld + here->BSIM4v5gNodeMid)
                        - *(RHSOld + here->BSIM4v5sNodePrime));
                        vdbs = ${::TECH($::type,$::corner,$::section,type)}
                        * (*(RHSOld + here->BSIM4v5dbNode)
                        - *(RHSOld + here->BSIM4v5sNodePrime));
                        vsbs = ${::TECH($::type,$::corner,$::section,type)}
                        * (*(RHSOld + here->BSIM4v5sbNode)
                        - *(RHSOld + here->BSIM4v5sNodePrime));
                        vses = ${::TECH($::type,$::corner,$::section,type)}
                        * (*(RHSOld + here->BSIM4v5sNode)
                        - *(RHSOld + here->BSIM4v5sNodePrime));
                        vdes = ${::TECH($::type,$::corner,$::section,type)}
                        * (*(RHSOld + here->BSIM4v5dNode)
                        - *(RHSOld + here->BSIM4v5sNodePrime));
                        qdef = ${::TECH($::type,$::corner,$::section,type)}
                        * (*(RHSOld + here->BSIM4v5qNode));
                        #ifndef PREDICTOR
                    }
                    #endif /* PREDICTOR */
                    vgdo = *(cktState0 + here->BSIM4v5vgs)
                    - *(cktState0 + here->BSIM4v5vds);
                    vgedo = *(cktState0 + here->BSIM4v5vges)
                    - *(cktState0 + here->BSIM4v5vds);
                    vgmdo = *(cktState0 + here->BSIM4v5vgms)
                    - *(cktState0 + here->BSIM4v5vds);
                    
                    vbd = vbs - vds;
                    vdbd = vdbs - vds;
                    vgd = vgs - vds;
                    vged = vges - vds;
                    vgmd = vgms - vds;
                    
                    delvbd = vbd - *(cktState0 + here->BSIM4v5vbd);
                    delvdbd = vdbd - *(cktState0 + here->BSIM4v5vdbd);
                    delvgd = vgd - vgdo;
                    delvged = vged - vgedo;
                    delvgmd = vgmd - vgmdo;
                    
                    delvds = vds - *(cktState0 + here->BSIM4v5vds);
                    delvgs = vgs - *(cktState0 + here->BSIM4v5vgs);
                    delvges = vges - *(cktState0 + here->BSIM4v5vges);
                    delvgms = vgms - *(cktState0 + here->BSIM4v5vgms);
                    delvbs = vbs - *(cktState0 + here->BSIM4v5vbs);
                    delvdbs = vdbs - *(cktState0 + here->BSIM4v5vdbs);
                    delvsbs = vsbs - *(cktState0 + here->BSIM4v5vsbs);
                    
                    delvses = vses - (*(cktState0 + here->BSIM4v5vses));
                    vdedo = *(cktState0 + here->BSIM4v5vdes)
                    - *(cktState0 + here->BSIM4v5vds);
                    delvdes = vdes - *(cktState0 + here->BSIM4v5vdes);
                    delvded = vdes - vds - vdedo;
                    
                    delvbd_jct = (!here->BSIM4v5rbodyMod) ? delvbd : delvdbd;
                    delvbs_jct = (!here->BSIM4v5rbodyMod) ? delvbs : delvsbs;
                    if (here->BSIM4v5mode >= 0)
                    {   Idtot = here->BSIM4v5cd + here->BSIM4v5csub - here->BSIM4v5cbd
                        + here->BSIM4v5Igidl;
                        cdhat = Idtot - here->BSIM4v5gbd * delvbd_jct
                        + (here->BSIM4v5gmbs + here->BSIM4v5gbbs + here->BSIM4v5ggidlb) * delvbs
                        + (here->BSIM4v5gm + here->BSIM4v5gbgs + here->BSIM4v5ggidlg) * delvgs 
                        + (here->BSIM4v5gds + here->BSIM4v5gbds + here->BSIM4v5ggidld) * delvds;
                        Ibtot = here->BSIM4v5cbs + here->BSIM4v5cbd 
                        - here->BSIM4v5Igidl - here->BSIM4v5Igisl - here->BSIM4v5csub;
                        cbhat = Ibtot + here->BSIM4v5gbd * delvbd_jct
                        + here->BSIM4v5gbs * delvbs_jct - (here->BSIM4v5gbbs + here->BSIM4v5ggidlb)
                        * delvbs - (here->BSIM4v5gbgs + here->BSIM4v5ggidlg) * delvgs
                        - (here->BSIM4v5gbds + here->BSIM4v5ggidld - here->BSIM4v5ggisls) * delvds 
                        - here->BSIM4v5ggislg * delvgd - here->BSIM4v5ggislb* delvbd;
                        
                        Igstot = here->BSIM4v5Igs + here->BSIM4v5Igcs;
                        cgshat = Igstot + (here->BSIM4v5gIgsg + here->BSIM4v5gIgcsg) * delvgs
                        + here->BSIM4v5gIgcsd * delvds + here->BSIM4v5gIgcsb * delvbs;
                        
                        Igdtot = here->BSIM4v5Igd + here->BSIM4v5Igcd;
                        cgdhat = Igdtot + here->BSIM4v5gIgdg * delvgd + here->BSIM4v5gIgcdg * delvgs
                        + here->BSIM4v5gIgcdd * delvds + here->BSIM4v5gIgcdb * delvbs;
                        
                        Igbtot = here->BSIM4v5Igb;
                        cgbhat = here->BSIM4v5Igb + here->BSIM4v5gIgbg * delvgs + here->BSIM4v5gIgbd
                        * delvds + here->BSIM4v5gIgbb * delvbs;
                    }
                    else
                    {   Idtot = here->BSIM4v5cd + here->BSIM4v5cbd - here->BSIM4v5Igidl; /* bugfix */
                        cdhat = Idtot + here->BSIM4v5gbd * delvbd_jct + here->BSIM4v5gmbs 
                        * delvbd + here->BSIM4v5gm * delvgd 
                        - (here->BSIM4v5gds + here->BSIM4v5ggidls) * delvds 
                        - here->BSIM4v5ggidlg * delvgs - here->BSIM4v5ggidlb * delvbs;
                        Ibtot = here->BSIM4v5cbs + here->BSIM4v5cbd 
                        - here->BSIM4v5Igidl - here->BSIM4v5Igisl - here->BSIM4v5csub;
                        cbhat = Ibtot + here->BSIM4v5gbs * delvbs_jct + here->BSIM4v5gbd 
                        * delvbd_jct - (here->BSIM4v5gbbs + here->BSIM4v5ggislb) * delvbd
                        - (here->BSIM4v5gbgs + here->BSIM4v5ggislg) * delvgd
                        + (here->BSIM4v5gbds + here->BSIM4v5ggisld - here->BSIM4v5ggidls) * delvds
                        - here->BSIM4v5ggidlg * delvgs - here->BSIM4v5ggidlb * delvbs; 
                        
                        Igstot = here->BSIM4v5Igs + here->BSIM4v5Igcd;
                        cgshat = Igstot + here->BSIM4v5gIgsg * delvgs + here->BSIM4v5gIgcdg * delvgd
                        - here->BSIM4v5gIgcdd * delvds + here->BSIM4v5gIgcdb * delvbd;
                        
                        Igdtot = here->BSIM4v5Igd + here->BSIM4v5Igcs;
                        cgdhat = Igdtot + (here->BSIM4v5gIgdg + here->BSIM4v5gIgcsg) * delvgd
                        - here->BSIM4v5gIgcsd * delvds + here->BSIM4v5gIgcsb * delvbd;
                        
                        Igbtot = here->BSIM4v5Igb;
                        cgbhat = here->BSIM4v5Igb + here->BSIM4v5gIgbg * delvgd - here->BSIM4v5gIgbd
                        * delvds + here->BSIM4v5gIgbb * delvbd;
                    }
                    Isestot = here->BSIM4v5gstot * (*(cktState0 + here->BSIM4v5vses));
                    cseshat = Isestot + here->BSIM4v5gstot * delvses
                    + here->BSIM4v5gstotd * delvds + here->BSIM4v5gstotg * delvgs
                    + here->BSIM4v5gstotb * delvbs;
                    
                    Idedtot = here->BSIM4v5gdtot * vdedo;
                    cdedhat = Idedtot + here->BSIM4v5gdtot * delvded
                    + here->BSIM4v5gdtotd * delvds + here->BSIM4v5gdtotg * delvgs
                    + here->BSIM4v5gdtotb * delvbs;
                    
                    
                    #ifndef NOBYPASS
                    /* Following should be one IF statement, but some C compilers 
                    * can't handle that all at once, so we split it into several
                    * successive IF's */
                    
                    if ((!(Mode & MODEINITPRED)) && (CKT_CKTbypass))
                    if ((fabs(delvds) < (CKT_CKTreltol * MAX(fabs(vds),
                    fabs(*(cktState0 + here->BSIM4v5vds))) + CKT_CKTvoltTol)))
                    if ((fabs(delvgs) < (CKT_CKTreltol * MAX(fabs(vgs),
                    fabs(*(cktState0 + here->BSIM4v5vgs))) + CKT_CKTvoltTol)))
                    if ((fabs(delvbs) < (CKT_CKTreltol * MAX(fabs(vbs),
                    fabs(*(cktState0 + here->BSIM4v5vbs))) + CKT_CKTvoltTol)))
                    if ((fabs(delvbd) < (CKT_CKTreltol * MAX(fabs(vbd),
                    fabs(*(cktState0 + here->BSIM4v5vbd))) + CKT_CKTvoltTol)))
                    if ((here->BSIM4v5rgateMod == 0) || (here->BSIM4v5rgateMod == 1) 
                    || (fabs(delvges) < (CKT_CKTreltol * MAX(fabs(vges),
                    fabs(*(cktState0 + here->BSIM4v5vges))) + CKT_CKTvoltTol)))
                    if ((here->BSIM4v5rgateMod != 3) || (fabs(delvgms) < (CKT_CKTreltol
                    * MAX(fabs(vgms), fabs(*(cktState0 + here->BSIM4v5vgms)))
                    + CKT_CKTvoltTol)))
                    if ((!here->BSIM4v5rbodyMod) || (fabs(delvdbs) < (CKT_CKTreltol
                    * MAX(fabs(vdbs), fabs(*(cktState0 + here->BSIM4v5vdbs)))
                    + CKT_CKTvoltTol)))
                    if ((!here->BSIM4v5rbodyMod) || (fabs(delvdbd) < (CKT_CKTreltol
                    * MAX(fabs(vdbd), fabs(*(cktState0 + here->BSIM4v5vdbd)))
                    + CKT_CKTvoltTol)))
                    if ((!here->BSIM4v5rbodyMod) || (fabs(delvsbs) < (CKT_CKTreltol
                    * MAX(fabs(vsbs), fabs(*(cktState0 + here->BSIM4v5vsbs)))
                    + CKT_CKTvoltTol)))
                    if ((!${::TECH($::type,$::corner,$::section,rdsMod)}) || (fabs(delvses) < (CKT_CKTreltol
                    * MAX(fabs(vses), fabs(*(cktState0 + here->BSIM4v5vses)))
                    + CKT_CKTvoltTol)))
                    if ((!${::TECH($::type,$::corner,$::section,rdsMod)}) || (fabs(delvdes) < (CKT_CKTreltol
                    * MAX(fabs(vdes), fabs(*(cktState0 + here->BSIM4v5vdes)))
                    + CKT_CKTvoltTol)))
                    if ((fabs(cdhat - Idtot) < CKT_CKTreltol
                    * MAX(fabs(cdhat), fabs(Idtot)) + CKT_CKTabstol))
                    if ((fabs(cbhat - Ibtot) < CKT_CKTreltol
                    * MAX(fabs(cbhat), fabs(Ibtot)) + CKT_CKTabstol))
                    if ((!${::TECH($::type,$::corner,$::section,igcMod)}) || ((fabs(cgshat - Igstot) < CKT_CKTreltol
                    * MAX(fabs(cgshat), fabs(Igstot)) + CKT_CKTabstol)))
                    if ((!${::TECH($::type,$::corner,$::section,igcMod)}) || ((fabs(cgdhat - Igdtot) < CKT_CKTreltol
                    * MAX(fabs(cgdhat), fabs(Igdtot)) + CKT_CKTabstol)))
                    if ((!${::TECH($::type,$::corner,$::section,igbMod)}) || ((fabs(cgbhat - Igbtot) < CKT_CKTreltol
                    * MAX(fabs(cgbhat), fabs(Igbtot)) + CKT_CKTabstol)))
                    if ((!${::TECH($::type,$::corner,$::section,rdsMod)}) || ((fabs(cseshat - Isestot) < CKT_CKTreltol
                    * MAX(fabs(cseshat), fabs(Isestot)) + CKT_CKTabstol)))
                    if ((!${::TECH($::type,$::corner,$::section,rdsMod)}) || ((fabs(cdedhat - Idedtot) < CKT_CKTreltol
                    * MAX(fabs(cdedhat), fabs(Idedtot)) + CKT_CKTabstol)))
                    {   vds = *(cktState0 + here->BSIM4v5vds);
                        vgs = *(cktState0 + here->BSIM4v5vgs);
                        vbs = *(cktState0 + here->BSIM4v5vbs);
                        vges = *(cktState0 + here->BSIM4v5vges);
                        vgms = *(cktState0 + here->BSIM4v5vgms);
                        
                        vbd = *(cktState0 + here->BSIM4v5vbd);
                        vdbs = *(cktState0 + here->BSIM4v5vdbs);
                        vdbd = *(cktState0 + here->BSIM4v5vdbd);
                        vsbs = *(cktState0 + here->BSIM4v5vsbs);
                        vses = *(cktState0 + here->BSIM4v5vses);
                        vdes = *(cktState0 + here->BSIM4v5vdes);
                        
                        vgd = vgs - vds;
                        vgb = vgs - vbs;
                        vged = vges - vds;
                        vgmd = vgms - vds;
                        vgmb = vgms - vbs;
                        
                        vbs_jct = (!here->BSIM4v5rbodyMod) ? vbs : vsbs;
                        vbd_jct = (!here->BSIM4v5rbodyMod) ? vbd : vdbd;
                        
                        /*** qdef should not be kept fixed even if vgs, vds & vbs has converged 
                        ****               qdef = *(cktState0 + here->BSIM4v5qdef);  
                        ***/
                        cdrain = here->BSIM4v5cd;
                        
                        if ((Mode & (MODETRAN | MODEAC)) || 
                        ((Mode & MODETRANOP) && 
                        (Mode & MODEUIC)))
                        {   ByPass = 1;
                            
                            qgate = here->BSIM4v5qgate;
                            qbulk = here->BSIM4v5qbulk;
                            qdrn = here->BSIM4v5qdrn;
                            cgdo = here->BSIM4v5cgdo;
                            qgdo = here->BSIM4v5qgdo;
                            cgso = here->BSIM4v5cgso;
                            qgso = here->BSIM4v5qgso;
                            
                            goto line_${::type}_${::corner}_${::section}_755;
                        }
                        else
                        goto line_${::type}_${::corner}_${::section}_850;
                    }
                    #endif /*NOBYPASS*/
                    
                    von = here->BSIM4v5von;
                    if (*(cktState0 + here->BSIM4v5vds) >= 0.0)
                    {   vgs = DEVfetlim(vgs, *(cktState0 + here->BSIM4v5vgs), von);
                        vds = vgs - vgd;
                        vds = DEVlimvds(vds, *(cktState0 + here->BSIM4v5vds));
                        vgd = vgs - vds;
                        if (here->BSIM4v5rgateMod == 3)
                        {   vges = DEVfetlim(vges, *(cktState0 + here->BSIM4v5vges), von);
                            vgms = DEVfetlim(vgms, *(cktState0 + here->BSIM4v5vgms), von);
                            vged = vges - vds;
                            vgmd = vgms - vds;
                        }
                        else if ((here->BSIM4v5rgateMod == 1) || (here->BSIM4v5rgateMod == 2))
                        {   vges = DEVfetlim(vges, *(cktState0 + here->BSIM4v5vges), von);
                            vged = vges - vds;
                        }
                        
                        if (${::TECH($::type,$::corner,$::section,rdsMod)})
                        {   vdes = DEVlimvds(vdes, *(cktState0 + here->BSIM4v5vdes));
                            vses = -DEVlimvds(-vses, -(*(cktState0 + here->BSIM4v5vses)));
                        }
                        
                    }
                    else
                    {   vgd = DEVfetlim(vgd, vgdo, von);
                        vds = vgs - vgd;
                        vds = -DEVlimvds(-vds, -(*(cktState0 + here->BSIM4v5vds)));
                        vgs = vgd + vds;
                        
                        if (here->BSIM4v5rgateMod == 3)
                        {   vged = DEVfetlim(vged, vgedo, von);
                            vges = vged + vds;
                            vgmd = DEVfetlim(vgmd, vgmdo, von);
                            vgms = vgmd + vds;
                        }
                        if ((here->BSIM4v5rgateMod == 1) || (here->BSIM4v5rgateMod == 2))
                        {   vged = DEVfetlim(vged, vgedo, von);
                            vges = vged + vds;
                        }
                        
                        if (${::TECH($::type,$::corner,$::section,rdsMod)})
                        {   vdes = -DEVlimvds(-vdes, -(*(cktState0 + here->BSIM4v5vdes)));
                            vses = DEVlimvds(vses, *(cktState0 + here->BSIM4v5vses));
                        }
                    }
                    
                    if (vds >= 0.0)
                    {   vbs = DEVpnjlim(vbs, *(cktState0 + here->BSIM4v5vbs),
                        CONSTvt0, ${::TECH($::type,$::corner,$::section,vcrit)}, &Check);
                        vbd = vbs - vds;
                        if (here->BSIM4v5rbodyMod)
                        {   vdbs = DEVpnjlim(vdbs, *(cktState0 + here->BSIM4v5vdbs),
                            CONSTvt0, ${::TECH($::type,$::corner,$::section,vcrit)}, &Check1);
                            vdbd = vdbs - vds;
                            vsbs = DEVpnjlim(vsbs, *(cktState0 + here->BSIM4v5vsbs),
                            CONSTvt0, ${::TECH($::type,$::corner,$::section,vcrit)}, &Check2);
                            if ((Check1 == 0) && (Check2 == 0))
                            Check = 0;
                            else 
                            Check = 1;
                        }
                    }
                    else
                    {   vbd = DEVpnjlim(vbd, *(cktState0 + here->BSIM4v5vbd),
                        CONSTvt0, ${::TECH($::type,$::corner,$::section,vcrit)}, &Check); 
                        vbs = vbd + vds;
                        if (here->BSIM4v5rbodyMod)
                        {   vdbd = DEVpnjlim(vdbd, *(cktState0 + here->BSIM4v5vdbd),
                            CONSTvt0, ${::TECH($::type,$::corner,$::section,vcrit)}, &Check1);
                            vdbs = vdbd + vds;
                            vsbdo = *(cktState0 + here->BSIM4v5vsbs)
                            - *(cktState0 + here->BSIM4v5vds);
                            vsbd = vsbs - vds;
                            vsbd = DEVpnjlim(vsbd, vsbdo, CONSTvt0, ${::TECH($::type,$::corner,$::section,vcrit)}, &Check2);
                            vsbs = vsbd + vds;
                            if ((Check1 == 0) && (Check2 == 0))
                            Check = 0;
                            else
                            Check = 1;
                        }
                    }
                }
                /* Calculate DC currents and their derivatives */
                vbd = vbs - vds;
                vgd = vgs - vds;
                vgb = vgs - vbs;
                vged = vges - vds;
                vgmd = vgms - vds;
                vgmb = vgms - vbs;
                vdbd = vdbs - vds;
                
                vbs_jct = (!here->BSIM4v5rbodyMod) ? vbs : vsbs;
                vbd_jct = (!here->BSIM4v5rbodyMod) ? vbd : vdbd;
                
                /* Source/drain junction diode DC model begins */
                Nvtms = ${::TECH($::type,$::corner,$::section,vtm)} * ${::TECH($::type,$::corner,$::section,SjctEmissionCoeff)};
                if ((here->BSIM4v5Aseff <= 0.0) && (here->BSIM4v5Pseff <= 0.0))
                {   SourceSatCurrent = 1.0e-14;
                }
                else
                {   SourceSatCurrent = here->BSIM4v5Aseff * ${::TECH($::type,$::corner,$::section,SjctTempSatCurDensity)}
                    + here->BSIM4v5Pseff * ${::TECH($::type,$::corner,$::section,SjctSidewallTempSatCurDensity)}
                    + pParam->BSIM4v5weffCJ * here->BSIM4v5nf
                    * ${::TECH($::type,$::corner,$::section,SjctGateSidewallTempSatCurDensity)};
                }
                
                if (SourceSatCurrent <= 0.0)
                {   here->BSIM4v5gbs = CKT_CKTgmin;
                    here->BSIM4v5cbs = here->BSIM4v5gbs * vbs_jct;
                }
                else
                {   switch(${::TECH($::type,$::corner,$::section,dioMod)})
                    {   case 0:
                        evbs = exp(vbs_jct / Nvtms);
                        T1 = ${::TECH($::type,$::corner,$::section,xjbvs)} * exp(-(${::TECH($::type,$::corner,$::section,bvs)} + vbs_jct) / Nvtms);
                        /* WDLiu: Magic T1 in this form; different from BSIM4v5 beta. */
                        here->BSIM4v5gbs = SourceSatCurrent * (evbs + T1) / Nvtms + CKT_CKTgmin;
                        here->BSIM4v5cbs = SourceSatCurrent * (evbs + here->BSIM4v5XExpBVS
                        - T1 - 1.0) + CKT_CKTgmin * vbs_jct;
                        break;
                        case 1:
                        T2 = vbs_jct / Nvtms;
                        if (T2 < -EXP_THRESHOLD)
                        {   here->BSIM4v5gbs = CKT_CKTgmin;
                            here->BSIM4v5cbs = SourceSatCurrent * (MIN_EXP - 1.0)
                            + CKT_CKTgmin * vbs_jct;
                        }
                        else if (vbs_jct <= here->BSIM4v5vjsmFwd)
                        {   evbs = exp(T2);
                            here->BSIM4v5gbs = SourceSatCurrent * evbs / Nvtms + CKT_CKTgmin;
                            here->BSIM4v5cbs = SourceSatCurrent * (evbs - 1.0)
                            + CKT_CKTgmin * vbs_jct;
                        }
                        else
                        {   T0 = here->BSIM4v5IVjsmFwd / Nvtms;
                            here->BSIM4v5gbs = T0 + CKT_CKTgmin;
                            here->BSIM4v5cbs = here->BSIM4v5IVjsmFwd - SourceSatCurrent + T0 
                            * (vbs_jct - here->BSIM4v5vjsmFwd) + CKT_CKTgmin * vbs_jct;
                        }	
                        break;
                        case 2:
                        if (vbs_jct < here->BSIM4v5vjsmRev)
                        {   T0 = vbs_jct / Nvtms;
                            if (T0 < -EXP_THRESHOLD)
                            {    evbs = MIN_EXP;
                                devbs_dvb = 0.0;
                            }
                            else
                            {    evbs = exp(T0);
                                devbs_dvb = evbs / Nvtms;
                            }
                            
                            T1 = evbs - 1.0;
                            T2 = here->BSIM4v5IVjsmRev + here->BSIM4v5SslpRev
                            * (vbs_jct - here->BSIM4v5vjsmRev);
                            here->BSIM4v5gbs = devbs_dvb * T2 + T1 * here->BSIM4v5SslpRev + CKT_CKTgmin;
                            here->BSIM4v5cbs = T1 * T2 + CKT_CKTgmin * vbs_jct;
                        }         
                        else if (vbs_jct <= here->BSIM4v5vjsmFwd)
                        {   T0 = vbs_jct / Nvtms;
                            if (T0 < -EXP_THRESHOLD)
                            {    evbs = MIN_EXP;
                                devbs_dvb = 0.0;
                            }
                            else
                            {    evbs = exp(T0);
                                devbs_dvb = evbs / Nvtms;
                            }
                            
                            T1 = (${::TECH($::type,$::corner,$::section,bvs)} + vbs_jct) / Nvtms;
                            if (T1 > EXP_THRESHOLD)
                            {   T2 = MIN_EXP;
                                T3 = 0.0;
                            }
                            else
                            {   T2 = exp(-T1);
                                T3 = -T2 /Nvtms;
                            }
                            here->BSIM4v5gbs = SourceSatCurrent * (devbs_dvb - ${::TECH($::type,$::corner,$::section,xjbvs)} * T3)
                            + CKT_CKTgmin;
                            here->BSIM4v5cbs = SourceSatCurrent * (evbs + here->BSIM4v5XExpBVS - 1.0
                            - ${::TECH($::type,$::corner,$::section,xjbvs)} * T2) + CKT_CKTgmin * vbs_jct;
                        }
                        else
                        {   here->BSIM4v5gbs = here->BSIM4v5SslpFwd + CKT_CKTgmin;
                            here->BSIM4v5cbs = here->BSIM4v5IVjsmFwd + here->BSIM4v5SslpFwd * (vbs_jct
                            - here->BSIM4v5vjsmFwd) + CKT_CKTgmin * vbs_jct;
                        }
                        break;
                        default: break;
                    }
                }
                
                Nvtmd = ${::TECH($::type,$::corner,$::section,vtm)} * ${::TECH($::type,$::corner,$::section,DjctEmissionCoeff)};
                if ((here->BSIM4v5Adeff <= 0.0) && (here->BSIM4v5Pdeff <= 0.0))
                {   DrainSatCurrent = 1.0e-14;
                }
                else
                {   DrainSatCurrent = here->BSIM4v5Adeff * ${::TECH($::type,$::corner,$::section,DjctTempSatCurDensity)}
                    + here->BSIM4v5Pdeff * ${::TECH($::type,$::corner,$::section,DjctSidewallTempSatCurDensity)}
                    + pParam->BSIM4v5weffCJ * here->BSIM4v5nf
                    * ${::TECH($::type,$::corner,$::section,DjctGateSidewallTempSatCurDensity)};
                }
                
                if (DrainSatCurrent <= 0.0)
                {   here->BSIM4v5gbd = CKT_CKTgmin;
                    here->BSIM4v5cbd = here->BSIM4v5gbd * vbd_jct;
                }
                else
                {   switch(${::TECH($::type,$::corner,$::section,dioMod)})
                    {   case 0:
                        evbd = exp(vbd_jct / Nvtmd);
                        T1 = ${::TECH($::type,$::corner,$::section,xjbvd)} * exp(-(${::TECH($::type,$::corner,$::section,bvd)} + vbd_jct) / Nvtmd);
                        /* WDLiu: Magic T1 in this form; different from BSIM4v5 beta. */
                        here->BSIM4v5gbd = DrainSatCurrent * (evbd + T1) / Nvtmd + CKT_CKTgmin;
                        here->BSIM4v5cbd = DrainSatCurrent * (evbd + here->BSIM4v5XExpBVD
                        - T1 - 1.0) + CKT_CKTgmin * vbd_jct;
                        break;
                        case 1:
                        T2 = vbd_jct / Nvtmd;
                        if (T2 < -EXP_THRESHOLD)
                        {   here->BSIM4v5gbd = CKT_CKTgmin;
                            here->BSIM4v5cbd = DrainSatCurrent * (MIN_EXP - 1.0)
                            + CKT_CKTgmin * vbd_jct;
                        }
                        else if (vbd_jct <= here->BSIM4v5vjdmFwd)
                        {   evbd = exp(T2);
                            here->BSIM4v5gbd = DrainSatCurrent * evbd / Nvtmd + CKT_CKTgmin;
                            here->BSIM4v5cbd = DrainSatCurrent * (evbd - 1.0)
                            + CKT_CKTgmin * vbd_jct;
                        }
                        else
                        {   T0 = here->BSIM4v5IVjdmFwd / Nvtmd;
                            here->BSIM4v5gbd = T0 + CKT_CKTgmin;
                            here->BSIM4v5cbd = here->BSIM4v5IVjdmFwd - DrainSatCurrent + T0
                            * (vbd_jct - here->BSIM4v5vjdmFwd) + CKT_CKTgmin * vbd_jct;
                        }
                        break;
                        case 2:
                        if (vbd_jct < here->BSIM4v5vjdmRev)
                        {   T0 = vbd_jct / Nvtmd;
                            if (T0 < -EXP_THRESHOLD)
                            {    evbd = MIN_EXP;
                                devbd_dvb = 0.0;
                            }
                            else
                            {    evbd = exp(T0);
                                devbd_dvb = evbd / Nvtmd;
                            }
                            
                            T1 = evbd - 1.0;
                            T2 = here->BSIM4v5IVjdmRev + here->BSIM4v5DslpRev
                            * (vbd_jct - here->BSIM4v5vjdmRev);
                            here->BSIM4v5gbd = devbd_dvb * T2 + T1 * here->BSIM4v5DslpRev + CKT_CKTgmin;
                            here->BSIM4v5cbd = T1 * T2 + CKT_CKTgmin * vbd_jct;
                        }
                        else if (vbd_jct <= here->BSIM4v5vjdmFwd)
                        {   T0 = vbd_jct / Nvtmd;
                            if (T0 < -EXP_THRESHOLD)
                            {    evbd = MIN_EXP;
                                devbd_dvb = 0.0;
                            }
                            else
                            {    evbd = exp(T0);
                                devbd_dvb = evbd / Nvtmd;
                            }
                            
                            T1 = (${::TECH($::type,$::corner,$::section,bvd)} + vbd_jct) / Nvtmd;
                            if (T1 > EXP_THRESHOLD)
                            {   T2 = MIN_EXP;
                                T3 = 0.0;
                            }
                            else
                            {   T2 = exp(-T1);
                                T3 = -T2 /Nvtmd;
                            }     
                            here->BSIM4v5gbd = DrainSatCurrent * (devbd_dvb - ${::TECH($::type,$::corner,$::section,xjbvd)} * T3)
                            + CKT_CKTgmin;
                            here->BSIM4v5cbd = DrainSatCurrent * (evbd + here->BSIM4v5XExpBVD - 1.0
                            - ${::TECH($::type,$::corner,$::section,xjbvd)} * T2) + CKT_CKTgmin * vbd_jct;
                        }
                        else
                        {   here->BSIM4v5gbd = here->BSIM4v5DslpFwd + CKT_CKTgmin;
                            here->BSIM4v5cbd = here->BSIM4v5IVjdmFwd + here->BSIM4v5DslpFwd * (vbd_jct
                            - here->BSIM4v5vjdmFwd) + CKT_CKTgmin * vbd_jct;
                        }
                        break;
                        default: break;
                    }
                } 
                /* trap-assisted tunneling and recombination current for reverse bias  */
                Nvtmrssw = ${::TECH($::type,$::corner,$::section,vtm0)} * ${::TECH($::type,$::corner,$::section,njtsswtemp)};
                Nvtmrsswg = ${::TECH($::type,$::corner,$::section,vtm0)} * ${::TECH($::type,$::corner,$::section,njtsswgtemp)};
                Nvtmrs = ${::TECH($::type,$::corner,$::section,vtm0)} * ${::TECH($::type,$::corner,$::section,njtstemp)};
                
                if ((${::TECH($::type,$::corner,$::section,vtss)} - vbs_jct) < (${::TECH($::type,$::corner,$::section,vtss)} * 1e-3))
                { T9 = 1.0e3; 
                    T0 = - vbs_jct / Nvtmrs * T9;
                    DEXP3(T0, T1, T10);
                    dT1_dVb = T10 / Nvtmrs * T9; 
                } else {
                    T9 = 1.0 / (${::TECH($::type,$::corner,$::section,vtss)} - vbs_jct);
                    T0 = -vbs_jct / Nvtmrs * ${::TECH($::type,$::corner,$::section,vtss)} * T9;
                    dT0_dVb = ${::TECH($::type,$::corner,$::section,vtss)} / Nvtmrs * (T9 + vbs_jct * T9 * T9) ;
                    DEXP3(T0, T1, T10);
                    dT1_dVb = T10 * dT0_dVb;
                }
                
                if ((${::TECH($::type,$::corner,$::section,vtsd)} - vbd_jct) < (${::TECH($::type,$::corner,$::section,vtsd)} * 1e-3) )
                { T9 = 1.0e3;
                    T0 = -vbd_jct / Nvtmrs * T9;
                    DEXP3(T0, T2, T10);
                    dT2_dVb = T10 / Nvtmrs * T9; 
                } else {
                    T9 = 1.0 / (${::TECH($::type,$::corner,$::section,vtsd)} - vbd_jct);
                    T0 = -vbd_jct / Nvtmrs * ${::TECH($::type,$::corner,$::section,vtsd)} * T9;
                    dT0_dVb = ${::TECH($::type,$::corner,$::section,vtsd)} / Nvtmrs * (T9 + vbd_jct * T9 * T9) ;
                    DEXP3(T0, T2, T10);
                    dT2_dVb = T10 * dT0_dVb;
                }
                
                if ((${::TECH($::type,$::corner,$::section,vtssws)} - vbs_jct) < (${::TECH($::type,$::corner,$::section,vtssws)} * 1e-3) )
                { T9 = 1.0e3; 
                    T0 = -vbs_jct / Nvtmrssw * T9;
                    DEXP3(T0, T3, T10);
                    dT3_dVb = T10 / Nvtmrssw * T9; 
                } else {
                    T9 = 1.0 / (${::TECH($::type,$::corner,$::section,vtssws)} - vbs_jct);
                    T0 = -vbs_jct / Nvtmrssw * ${::TECH($::type,$::corner,$::section,vtssws)} * T9;
                    dT0_dVb = ${::TECH($::type,$::corner,$::section,vtssws)} / Nvtmrssw * (T9 + vbs_jct * T9 * T9) ;
                    DEXP3(T0, T3, T10);
                    dT3_dVb = T10 * dT0_dVb;
                }
                
                if ((${::TECH($::type,$::corner,$::section,vtsswd)} - vbd_jct) < (${::TECH($::type,$::corner,$::section,vtsswd)} * 1e-3) )
                { T9 = 1.0e3; 
                    T0 = -vbd_jct / Nvtmrssw * T9;
                    DEXP3(T0, T4, T10);
                    dT4_dVb = T10 / Nvtmrssw * T9; 
                } else {
                    T9 = 1.0 / (${::TECH($::type,$::corner,$::section,vtsswd)} - vbd_jct);
                    T0 = -vbd_jct / Nvtmrssw * ${::TECH($::type,$::corner,$::section,vtsswd)} * T9;
                    dT0_dVb = ${::TECH($::type,$::corner,$::section,vtsswd)} / Nvtmrssw * (T9 + vbd_jct * T9 * T9) ;
                    DEXP3(T0, T4, T10);
                    dT4_dVb = T10 * dT0_dVb;
                }
                
                if ((${::TECH($::type,$::corner,$::section,vtsswgs)} - vbs_jct) < (${::TECH($::type,$::corner,$::section,vtsswgs)} * 1e-3) )
                { T9 = 1.0e3; 
                    T0 = -vbs_jct / Nvtmrsswg * T9;
                    DEXP3(T0, T5, T10);
                    dT5_dVb = T10 / Nvtmrsswg * T9; 
                } else {
                    T9 = 1.0 / (${::TECH($::type,$::corner,$::section,vtsswgs)} - vbs_jct);
                    T0 = -vbs_jct / Nvtmrsswg * ${::TECH($::type,$::corner,$::section,vtsswgs)} * T9;
                    dT0_dVb = ${::TECH($::type,$::corner,$::section,vtsswgs)} / Nvtmrsswg * (T9 + vbs_jct * T9 * T9) ;
                    DEXP3(T0, T5, T10);
                    dT5_dVb = T10 * dT0_dVb;
                }
                
                if ((${::TECH($::type,$::corner,$::section,vtsswgd)} - vbd_jct) < (${::TECH($::type,$::corner,$::section,vtsswgd)} * 1e-3) )
                { T9 = 1.0e3; 
                    T0 = -vbd_jct / Nvtmrsswg * T9;
                    DEXP3(T0, T6, T10);
                    dT6_dVb = T10 / Nvtmrsswg * T9; 
                } else {
                    T9 = 1.0 / (${::TECH($::type,$::corner,$::section,vtsswgd)} - vbd_jct);
                    T0 = -vbd_jct / Nvtmrsswg * ${::TECH($::type,$::corner,$::section,vtsswgd)} * T9;
                    dT0_dVb = ${::TECH($::type,$::corner,$::section,vtsswgd)} / Nvtmrsswg * (T9 + vbd_jct * T9 * T9) ;
                    DEXP3(T0, T6, T10);
                    dT6_dVb = T10 * dT0_dVb;
                }
                
                here->BSIM4v5gbs += here->BSIM4v5SjctTempRevSatCur * dT1_dVb
                + here->BSIM4v5SswTempRevSatCur * dT3_dVb
                + here->BSIM4v5SswgTempRevSatCur * dT5_dVb; 
                here->BSIM4v5cbs -= here->BSIM4v5SjctTempRevSatCur * (T1 - 1.0)
                + here->BSIM4v5SswTempRevSatCur * (T3 - 1.0)
                + here->BSIM4v5SswgTempRevSatCur * (T5 - 1.0); 
                here->BSIM4v5gbd += here->BSIM4v5DjctTempRevSatCur * dT2_dVb
                + here->BSIM4v5DswTempRevSatCur * dT4_dVb
                + here->BSIM4v5DswgTempRevSatCur * dT6_dVb; 
                here->BSIM4v5cbd -= here->BSIM4v5DjctTempRevSatCur * (T2 - 1.0) 
                + here->BSIM4v5DswTempRevSatCur * (T4 - 1.0)
                + here->BSIM4v5DswgTempRevSatCur * (T6 - 1.0); 
                
                /* End of diode DC model */
                
                if (vds >= 0.0)
                {   here->BSIM4v5mode = 1;
                    Vds = vds;
                    Vgs = vgs;
                    Vbs = vbs;
                    Vdb = vds - vbs;  /* WDLiu: for GIDL */
                }
                else
                {   here->BSIM4v5mode = -1;
                    Vds = -vds;
                    Vgs = vgd;
                    Vbs = vbd;
                    Vdb = -vbs;
                }
                
                T0 = Vbs - here->BSIM4v5vbsc - 0.001;
                T1 = sqrt(T0 * T0 - 0.004 * here->BSIM4v5vbsc);
                if (T0 >= 0.0)
                {   Vbseff = here->BSIM4v5vbsc + 0.5 * (T0 + T1);
                    dVbseff_dVb = 0.5 * (1.0 + T0 / T1);
                }
                else
                {   T2 = -0.002 / (T1 - T0);
                    Vbseff = here->BSIM4v5vbsc * (1.0 + T2);
                    dVbseff_dVb = T2 * here->BSIM4v5vbsc / T1;
                }
                
                /* JX: Correction to forward body bias  */
                T9 = 0.95 * pParam->BSIM4v5phi;
                T0 = T9 - Vbseff - 0.001;
                T1 = sqrt(T0 * T0 + 0.004 * T9);
                Vbseff = T9 - 0.5 * (T0 + T1);
                dVbseff_dVb *= 0.5 * (1.0 + T0 / T1);
                
                Phis = pParam->BSIM4v5phi - Vbseff;
                dPhis_dVb = -1.0;
                sqrtPhis = sqrt(Phis);
                dsqrtPhis_dVb = -0.5 / sqrtPhis; 
                
                Xdep = pParam->BSIM4v5Xdep0 * sqrtPhis / pParam->BSIM4v5sqrtPhi;
                dXdep_dVb = (pParam->BSIM4v5Xdep0 / pParam->BSIM4v5sqrtPhi)
                * dsqrtPhis_dVb;
                
                Leff = pParam->BSIM4v5leff;
                Vtm = ${::TECH($::type,$::corner,$::section,vtm)};
                Vtm0 = ${::TECH($::type,$::corner,$::section,vtm0)};
                
                /* Vth Calculation */
                T3 = sqrt(Xdep);
                V0 = pParam->BSIM4v5vbi - pParam->BSIM4v5phi;
                
                T0 = pParam->BSIM4v5dvt2 * Vbseff;
                if (T0 >= - 0.5)
                {   T1 = 1.0 + T0;
                    T2 = pParam->BSIM4v5dvt2;
                }
                else
                {   T4 = 1.0 / (3.0 + 8.0 * T0);
                    T1 = (1.0 + 3.0 * T0) * T4; 
                    T2 = pParam->BSIM4v5dvt2 * T4 * T4;
                }
                lt1 = ${::TECH($::type,$::corner,$::section,factor1)} * T3 * T1;
                dlt1_dVb = ${::TECH($::type,$::corner,$::section,factor1)} * (0.5 / T3 * T1 * dXdep_dVb + T3 * T2);
                
                T0 = pParam->BSIM4v5dvt2w * Vbseff;
                if (T0 >= - 0.5)
                {   T1 = 1.0 + T0;
                    T2 = pParam->BSIM4v5dvt2w;
                }
                else
                {   T4 = 1.0 / (3.0 + 8.0 * T0);
                    T1 = (1.0 + 3.0 * T0) * T4; 
                    T2 = pParam->BSIM4v5dvt2w * T4 * T4;
                }
                ltw = ${::TECH($::type,$::corner,$::section,factor1)} * T3 * T1;
                dltw_dVb = ${::TECH($::type,$::corner,$::section,factor1)} * (0.5 / T3 * T1 * dXdep_dVb + T3 * T2);
                
                T0 = pParam->BSIM4v5dvt1 * Leff / lt1;
                if (T0 < EXP_THRESHOLD)
                {   T1 = exp(T0);
                    T2 = T1 - 1.0;
                    T3 = T2 * T2;
                    T4 = T3 + 2.0 * T1 * MIN_EXP;
                    Theta0 = T1 / T4;
                    dT1_dVb = -T0 * T1 * dlt1_dVb / lt1;
                    dTheta0_dVb = dT1_dVb * (T4 - 2.0 * T1 * (T2 + MIN_EXP)) / T4 / T4;
                }
                else
                {   Theta0 = 1.0 / (MAX_EXP - 2.0); /* 3.0 * MIN_EXP omitted */
                    dTheta0_dVb = 0.0;
                }
                here->BSIM4v5thetavth = pParam->BSIM4v5dvt0 * Theta0;
                Delt_vth = here->BSIM4v5thetavth * V0;
                dDelt_vth_dVb = pParam->BSIM4v5dvt0 * dTheta0_dVb * V0;
                
                T0 = pParam->BSIM4v5dvt1w * pParam->BSIM4v5weff * Leff / ltw;
                if (T0 < EXP_THRESHOLD)
                {   T1 = exp(T0);
                    T2 = T1 - 1.0;
                    T3 = T2 * T2;
                    T4 = T3 + 2.0 * T1 * MIN_EXP;
                    T5 = T1 / T4;
                    dT1_dVb = -T0 * T1 * dltw_dVb / ltw; 
                    dT5_dVb = dT1_dVb * (T4 - 2.0 * T1 * (T2 + MIN_EXP)) / T4 / T4;
                }
                else
                {   T5 = 1.0 / (MAX_EXP - 2.0); /* 3.0 * MIN_EXP omitted */
                    dT5_dVb = 0.0;
                }
                T0 = pParam->BSIM4v5dvt0w * T5;
                T2 = T0 * V0;
                dT2_dVb = pParam->BSIM4v5dvt0w * dT5_dVb * V0;
                
                TempRatio =  $::TEMP / ${::TECH($::type,$::corner,$::section,tnom)} - 1.0;
                T0 = sqrt(1.0 + pParam->BSIM4v5lpe0 / Leff);
                T1 = pParam->BSIM4v5k1ox * (T0 - 1.0) * pParam->BSIM4v5sqrtPhi
                + (pParam->BSIM4v5kt1 + pParam->BSIM4v5kt1l / Leff
                + pParam->BSIM4v5kt2 * Vbseff) * TempRatio;
                Vth_NarrowW = ${::TECH($::type,$::corner,$::section,toxe)} * pParam->BSIM4v5phi
                / (pParam->BSIM4v5weff + pParam->BSIM4v5w0);
                
                T3 = here->BSIM4v5eta0 + pParam->BSIM4v5etab * Vbseff;
                if (T3 < 1.0e-4)
                {   T9 = 1.0 / (3.0 - 2.0e4 * T3);
                    T3 = (2.0e-4 - T3) * T9;
                    T4 = T9 * T9;
                }
                else
                {   T4 = 1.0;
                }
                dDIBL_Sft_dVd = T3 * pParam->BSIM4v5theta0vb0;
                DIBL_Sft = dDIBL_Sft_dVd * Vds;
                
                Lpe_Vb = sqrt(1.0 + pParam->BSIM4v5lpeb / Leff);
                
                Vth = ${::TECH($::type,$::corner,$::section,type)} * here->BSIM4v5vth0 + (pParam->BSIM4v5k1ox * sqrtPhis
                - pParam->BSIM4v5k1 * pParam->BSIM4v5sqrtPhi) * Lpe_Vb
                - here->BSIM4v5k2ox * Vbseff - Delt_vth - T2 + (pParam->BSIM4v5k3
                + pParam->BSIM4v5k3b * Vbseff) * Vth_NarrowW + T1 - DIBL_Sft;
                
                dVth_dVb = Lpe_Vb * pParam->BSIM4v5k1ox * dsqrtPhis_dVb - here->BSIM4v5k2ox
                - dDelt_vth_dVb - dT2_dVb + pParam->BSIM4v5k3b * Vth_NarrowW
                - pParam->BSIM4v5etab * Vds * pParam->BSIM4v5theta0vb0 * T4
                + pParam->BSIM4v5kt2 * TempRatio;
                dVth_dVd = -dDIBL_Sft_dVd;
                
                
                /* Calculate n */
                tmp1 = EPSSI / Xdep;
                here->BSIM4v5nstar = ${::TECH($::type,$::corner,$::section,vtm)} / Charge_q * (${::TECH($::type,$::corner,$::section,coxe)}
                + tmp1 + pParam->BSIM4v5cit);  
                tmp2 = pParam->BSIM4v5nfactor * tmp1;
                tmp3 = pParam->BSIM4v5cdsc + pParam->BSIM4v5cdscb * Vbseff
                + pParam->BSIM4v5cdscd * Vds;
                tmp4 = (tmp2 + tmp3 * Theta0 + pParam->BSIM4v5cit) / ${::TECH($::type,$::corner,$::section,coxe)};
                if (tmp4 >= -0.5)
                {   n = 1.0 + tmp4;
                    dn_dVb = (-tmp2 / Xdep * dXdep_dVb + tmp3 * dTheta0_dVb
                    + pParam->BSIM4v5cdscb * Theta0) / ${::TECH($::type,$::corner,$::section,coxe)};
                    dn_dVd = pParam->BSIM4v5cdscd * Theta0 / ${::TECH($::type,$::corner,$::section,coxe)};
                }
                else
                {   T0 = 1.0 / (3.0 + 8.0 * tmp4);
                    n = (1.0 + 3.0 * tmp4) * T0;
                    T0 *= T0;
                    dn_dVb = (-tmp2 / Xdep * dXdep_dVb + tmp3 * dTheta0_dVb
                    + pParam->BSIM4v5cdscb * Theta0) / ${::TECH($::type,$::corner,$::section,coxe)} * T0;
                    dn_dVd = pParam->BSIM4v5cdscd * Theta0 / ${::TECH($::type,$::corner,$::section,coxe)} * T0;
                }
                
                
                /* Vth correction for Pocket implant */
                if (pParam->BSIM4v5dvtp0 > 0.0)
                {   T0 = -pParam->BSIM4v5dvtp1 * Vds;
                    if (T0 < -EXP_THRESHOLD)
                    {   T2 = MIN_EXP;
                        dT2_dVd = 0.0;
                    }
                    else
                    {   T2 = exp(T0);
                        dT2_dVd = -pParam->BSIM4v5dvtp1 * T2;
                    }
                    
                    T3 = Leff + pParam->BSIM4v5dvtp0 * (1.0 + T2);
                    dT3_dVd = pParam->BSIM4v5dvtp0 * dT2_dVd;
                    if (${::TECH($::type,$::corner,$::section,tempMod)} < 2)
                    {
                        T4 = Vtm * log(Leff / T3);
                        dT4_dVd = -Vtm * dT3_dVd / T3;
                    }
                    else
                    {
                        T4 = ${::TECH($::type,$::corner,$::section,vtm0)} * log(Leff / T3);
                        dT4_dVd = -${::TECH($::type,$::corner,$::section,vtm0)} * dT3_dVd / T3;
                    }
                    dDITS_Sft_dVd = dn_dVd * T4 + n * dT4_dVd;
                    dDITS_Sft_dVb = T4 * dn_dVb;
                    
                    Vth -= n * T4;
                    dVth_dVd -= dDITS_Sft_dVd;
                    dVth_dVb -= dDITS_Sft_dVb;
                }
                here->BSIM4v5von = Vth;
                
                
                /* Poly Gate Si Depletion Effect */
                T0 = here->BSIM4v5vfb + pParam->BSIM4v5phi;
                
                BSIM4v5polyDepletion(T0, pParam->BSIM4v5ngate, ${::TECH($::type,$::corner,$::section,coxe)}, vgs, &vgs_eff, &dvgs_eff_dvg);
                
                BSIM4v5polyDepletion(T0, pParam->BSIM4v5ngate, ${::TECH($::type,$::corner,$::section,coxe)}, vgd, &vgd_eff, &dvgd_eff_dvg);
                
                if(here->BSIM4v5mode>0) {
                    Vgs_eff = vgs_eff;
                    dVgs_eff_dVg = dvgs_eff_dvg;
                } else {
                    Vgs_eff = vgd_eff;
                    dVgs_eff_dVg = dvgd_eff_dvg;
                }
                here->BSIM4v5vgs_eff = vgs_eff;
                here->BSIM4v5vgd_eff = vgd_eff;
                here->BSIM4v5dvgs_eff_dvg = dvgs_eff_dvg;
                here->BSIM4v5dvgd_eff_dvg = dvgd_eff_dvg;
                
                
                Vgst = Vgs_eff - Vth;
                
                /* Calculate Vgsteff */
                T0 = n * Vtm;
                T1 = pParam->BSIM4v5mstar * Vgst;
                T2 = T1 / T0;
                if (T2 > EXP_THRESHOLD)
                {   T10 = T1;
                    dT10_dVg = pParam->BSIM4v5mstar * dVgs_eff_dVg;
                    dT10_dVd = -dVth_dVd * pParam->BSIM4v5mstar;
                    dT10_dVb = -dVth_dVb * pParam->BSIM4v5mstar;
                }
                else if (T2 < -EXP_THRESHOLD)
                {   T10 = Vtm * log(1.0 + MIN_EXP);
                    dT10_dVg = 0.0;
                    dT10_dVd = T10 * dn_dVd;
                    dT10_dVb = T10 * dn_dVb;
                    T10 *= n;
                }
                else
                {   ExpVgst = exp(T2);
                    T3 = Vtm * log(1.0 + ExpVgst);
                    T10 = n * T3;
                    dT10_dVg = pParam->BSIM4v5mstar * ExpVgst / (1.0 + ExpVgst);
                    dT10_dVb = T3 * dn_dVb - dT10_dVg * (dVth_dVb + Vgst * dn_dVb / n);
                    dT10_dVd = T3 * dn_dVd - dT10_dVg * (dVth_dVd + Vgst * dn_dVd / n);
                    dT10_dVg *= dVgs_eff_dVg;
                }
                
                T1 = pParam->BSIM4v5voffcbn - (1.0 - pParam->BSIM4v5mstar) * Vgst;
                T2 = T1 / T0;
                if (T2 < -EXP_THRESHOLD)
                {   T3 = ${::TECH($::type,$::corner,$::section,coxe)} * MIN_EXP / pParam->BSIM4v5cdep0;
                    T9 = pParam->BSIM4v5mstar + T3 * n;
                    dT9_dVg = 0.0;
                    dT9_dVd = dn_dVd * T3;
                    dT9_dVb = dn_dVb * T3;
                }
                else if (T2 > EXP_THRESHOLD)
                {   T3 = ${::TECH($::type,$::corner,$::section,coxe)} * MAX_EXP / pParam->BSIM4v5cdep0;
                    T9 = pParam->BSIM4v5mstar + T3 * n;
                    dT9_dVg = 0.0;
                    dT9_dVd = dn_dVd * T3;
                    dT9_dVb = dn_dVb * T3;
                }
                else
                {   ExpVgst = exp(T2);
                    T3 = ${::TECH($::type,$::corner,$::section,coxe)} / pParam->BSIM4v5cdep0;
                    T4 = T3 * ExpVgst;
                    T5 = T1 * T4 / T0;
                    T9 = pParam->BSIM4v5mstar + n * T4;
                    dT9_dVg = T3 * (pParam->BSIM4v5mstar - 1.0) * ExpVgst / Vtm;
                    dT9_dVb = T4 * dn_dVb - dT9_dVg * dVth_dVb - T5 * dn_dVb;
                    dT9_dVd = T4 * dn_dVd - dT9_dVg * dVth_dVd - T5 * dn_dVd;
                    dT9_dVg *= dVgs_eff_dVg;
                }
                
                here->BSIM4v5Vgsteff = Vgsteff = T10 / T9;
                T11 = T9 * T9;
                dVgsteff_dVg = (T9 * dT10_dVg - T10 * dT9_dVg) / T11;
                dVgsteff_dVd = (T9 * dT10_dVd - T10 * dT9_dVd) / T11;
                dVgsteff_dVb = (T9 * dT10_dVb - T10 * dT9_dVb) / T11;
                
                /* Calculate Effective Channel Geometry */
                T9 = sqrtPhis - pParam->BSIM4v5sqrtPhi;
                Weff = pParam->BSIM4v5weff - 2.0 * (pParam->BSIM4v5dwg * Vgsteff 
                + pParam->BSIM4v5dwb * T9); 
                dWeff_dVg = -2.0 * pParam->BSIM4v5dwg;
                dWeff_dVb = -2.0 * pParam->BSIM4v5dwb * dsqrtPhis_dVb;
                
                if (Weff < 2.0e-8) /* to avoid the discontinuity problem due to Weff*/
                {   T0 = 1.0 / (6.0e-8 - 2.0 * Weff);
                    Weff = 2.0e-8 * (4.0e-8 - Weff) * T0;
                    T0 *= T0 * 4.0e-16;
                    dWeff_dVg *= T0;
                    dWeff_dVb *= T0;
                }
                
                if (${::TECH($::type,$::corner,$::section,rdsMod)} == 1)
                Rds = dRds_dVg = dRds_dVb = 0.0;
                else
                {   T0 = 1.0 + pParam->BSIM4v5prwg * Vgsteff;
                    dT0_dVg = -pParam->BSIM4v5prwg / T0 / T0;
                    T1 = pParam->BSIM4v5prwb * T9;
                    dT1_dVb = pParam->BSIM4v5prwb * dsqrtPhis_dVb;
                    
                    T2 = 1.0 / T0 + T1;
                    T3 = T2 + sqrt(T2 * T2 + 0.01); /* 0.01 = 4.0 * 0.05 * 0.05 */
                    dT3_dVg = 1.0 + T2 / (T3 - T2);
                    dT3_dVb = dT3_dVg * dT1_dVb;
                    dT3_dVg *= dT0_dVg;
                    
                    T4 = pParam->BSIM4v5rds0 * 0.5;
                    Rds = pParam->BSIM4v5rdswmin + T3 * T4;
                    dRds_dVg = T4 * dT3_dVg;
                    dRds_dVb = T4 * dT3_dVb;
                    
                    if (Rds > 0.0)
                    here->BSIM4v5grdsw = 1.0 / Rds; 
                    else
                    here->BSIM4v5grdsw = 0.0;
                }
                
                /* Calculate Abulk */
                T9 = 0.5 * pParam->BSIM4v5k1ox * Lpe_Vb / sqrtPhis;
                T1 = T9 + here->BSIM4v5k2ox - pParam->BSIM4v5k3b * Vth_NarrowW;
                dT1_dVb = -T9 / sqrtPhis * dsqrtPhis_dVb;
                
                T9 = sqrt(pParam->BSIM4v5xj * Xdep);
                tmp1 = Leff + 2.0 * T9;
                T5 = Leff / tmp1; 
                tmp2 = pParam->BSIM4v5a0 * T5;
                tmp3 = pParam->BSIM4v5weff + pParam->BSIM4v5b1; 
                tmp4 = pParam->BSIM4v5b0 / tmp3;
                T2 = tmp2 + tmp4;
                dT2_dVb = -T9 / tmp1 / Xdep * dXdep_dVb;
                T6 = T5 * T5;
                T7 = T5 * T6;
                
                Abulk0 = 1.0 + T1 * T2; 
                dAbulk0_dVb = T1 * tmp2 * dT2_dVb + T2 * dT1_dVb;
                
                T8 = pParam->BSIM4v5ags * pParam->BSIM4v5a0 * T7;
                dAbulk_dVg = -T1 * T8;
                Abulk = Abulk0 + dAbulk_dVg * Vgsteff; 
                dAbulk_dVb = dAbulk0_dVb - T8 * Vgsteff * (dT1_dVb
                + 3.0 * T1 * dT2_dVb);
                
                if (Abulk0 < 0.1) /* added to avoid the problems caused by Abulk0 */
                {   T9 = 1.0 / (3.0 - 20.0 * Abulk0);
                    Abulk0 = (0.2 - Abulk0) * T9;
                    dAbulk0_dVb *= T9 * T9;
                }
                
                if (Abulk < 0.1)
                {   T9 = 1.0 / (3.0 - 20.0 * Abulk);
                    Abulk = (0.2 - Abulk) * T9;
                    T10 = T9 * T9;
                    dAbulk_dVb *= T10;
                    dAbulk_dVg *= T10;
                }
                here->BSIM4v5Abulk = Abulk;
                
                T2 = pParam->BSIM4v5keta * Vbseff;
                if (T2 >= -0.9)
                {   T0 = 1.0 / (1.0 + T2);
                    dT0_dVb = -pParam->BSIM4v5keta * T0 * T0;
                }
                else
                {   T1 = 1.0 / (0.8 + T2);
                    T0 = (17.0 + 20.0 * T2) * T1;
                    dT0_dVb = -pParam->BSIM4v5keta * T1 * T1;
                }
                dAbulk_dVg *= T0;
                dAbulk_dVb = dAbulk_dVb * T0 + Abulk * dT0_dVb;
                dAbulk0_dVb = dAbulk0_dVb * T0 + Abulk0 * dT0_dVb;
                Abulk *= T0;
                Abulk0 *= T0;
                
                /* Mobility calculation */
                if (${::TECH($::type,$::corner,$::section,mobMod)} == 0)
                {   T0 = Vgsteff + Vth + Vth;
                    T2 = pParam->BSIM4v5ua + pParam->BSIM4v5uc * Vbseff;
                    T3 = T0 / ${::TECH($::type,$::corner,$::section,toxe)};
                    T6 = pParam->BSIM4v5ud / T3 / T3 * Vth * Vth;
                    T5 = T3 * (T2 + pParam->BSIM4v5ub * T3) + T6;
                    T7 = - 2.0 * T6 / T0;
                    dDenomi_dVg = (T2 + 2.0 * pParam->BSIM4v5ub * T3) / ${::TECH($::type,$::corner,$::section,toxe)} + T7;
                    dDenomi_dVd = dDenomi_dVg * 2.0 * dVth_dVd;
                    dDenomi_dVb = dDenomi_dVg * 2.0 * dVth_dVb + pParam->BSIM4v5uc * T3;
                }
                else if (${::TECH($::type,$::corner,$::section,mobMod)} == 1)
                {   T0 = Vgsteff + Vth + Vth;
                    T2 = 1.0 + pParam->BSIM4v5uc * Vbseff;
                    T3 = T0 / ${::TECH($::type,$::corner,$::section,toxe)};
                    T4 = T3 * (pParam->BSIM4v5ua + pParam->BSIM4v5ub * T3);
                    T6 = pParam->BSIM4v5ud / T3 / T3 * Vth * Vth;
                    T5 = T4 * T2 + T6;
                    T7 = - 2.0 * T6 / T0;
                    dDenomi_dVg = (pParam->BSIM4v5ua + 2.0 * pParam->BSIM4v5ub * T3) * T2
                    / ${::TECH($::type,$::corner,$::section,toxe)} + T7;
                    dDenomi_dVd = dDenomi_dVg * 2.0 * dVth_dVd;
                    dDenomi_dVb = dDenomi_dVg * 2.0 * dVth_dVb + pParam->BSIM4v5uc * T4;
                }
                else
                {   T0 = (Vgsteff + here->BSIM4v5vtfbphi1) / ${::TECH($::type,$::corner,$::section,toxe)};
                    T1 = exp(pParam->BSIM4v5eu * log(T0));
                    dT1_dVg = T1 * pParam->BSIM4v5eu / T0 / ${::TECH($::type,$::corner,$::section,toxe)};
                    T2 = pParam->BSIM4v5ua + pParam->BSIM4v5uc * Vbseff;
                    T3 = T0 / ${::TECH($::type,$::corner,$::section,toxe)};
                    T6 = pParam->BSIM4v5ud / T3 / T3 * Vth * Vth;
                    T5 = T1 * T2 + T6;
                    T7 = - 2.0 * T6 / T0;
                    dDenomi_dVg = T2 * dT1_dVg + T7;
                    dDenomi_dVd = 0.0;
                    dDenomi_dVb = T1 * pParam->BSIM4v5uc;
                }
                
                if (T5 >= -0.8)
                {   Denomi = 1.0 + T5;
                }
                else
                {   T9 = 1.0 / (7.0 + 10.0 * T5);
                    Denomi = (0.6 + T5) * T9;
                    T9 *= T9;
                    dDenomi_dVg *= T9;
                    dDenomi_dVd *= T9;
                    dDenomi_dVb *= T9;
                }
                
                here->BSIM4v5ueff = ueff = here->BSIM4v5u0temp / Denomi;
                T9 = -ueff / Denomi;
                dueff_dVg = T9 * dDenomi_dVg;
                dueff_dVd = T9 * dDenomi_dVd;
                dueff_dVb = T9 * dDenomi_dVb;
                
                /* Saturation Drain Voltage  Vdsat */
                WVCox = Weff * here->BSIM4v5vsattemp * ${::TECH($::type,$::corner,$::section,coxe)};
                WVCoxRds = WVCox * Rds; 
                
                Esat = 2.0 * here->BSIM4v5vsattemp / ueff;
                here->BSIM4v5EsatL = EsatL = Esat * Leff;
                T0 = -EsatL /ueff;
                dEsatL_dVg = T0 * dueff_dVg;
                dEsatL_dVd = T0 * dueff_dVd;
                dEsatL_dVb = T0 * dueff_dVb;
                
                /* Sqrt() */
                a1 = pParam->BSIM4v5a1;
                if (a1 == 0.0)
                {   Lambda = pParam->BSIM4v5a2;
                    dLambda_dVg = 0.0;
                }
                else if (a1 > 0.0)
                {   T0 = 1.0 - pParam->BSIM4v5a2;
                    T1 = T0 - pParam->BSIM4v5a1 * Vgsteff - 0.0001;
                    T2 = sqrt(T1 * T1 + 0.0004 * T0);
                    Lambda = pParam->BSIM4v5a2 + T0 - 0.5 * (T1 + T2);
                    dLambda_dVg = 0.5 * pParam->BSIM4v5a1 * (1.0 + T1 / T2);
                }
                else
                {   T1 = pParam->BSIM4v5a2 + pParam->BSIM4v5a1 * Vgsteff - 0.0001;
                    T2 = sqrt(T1 * T1 + 0.0004 * pParam->BSIM4v5a2);
                    Lambda = 0.5 * (T1 + T2);
                    dLambda_dVg = 0.5 * pParam->BSIM4v5a1 * (1.0 + T1 / T2);
                }
                
                Vgst2Vtm = Vgsteff + 2.0 * Vtm;
                if (Rds > 0)
                {   tmp2 = dRds_dVg / Rds + dWeff_dVg / Weff;
                    tmp3 = dRds_dVb / Rds + dWeff_dVb / Weff;
                }
                else
                {   tmp2 = dWeff_dVg / Weff;
                    tmp3 = dWeff_dVb / Weff;
                }
                if ((Rds == 0.0) && (Lambda == 1.0))
                {   T0 = 1.0 / (Abulk * EsatL + Vgst2Vtm);
                    tmp1 = 0.0;
                    T1 = T0 * T0;
                    T2 = Vgst2Vtm * T0;
                    T3 = EsatL * Vgst2Vtm;
                    Vdsat = T3 * T0;
                    
                    dT0_dVg = -(Abulk * dEsatL_dVg + EsatL * dAbulk_dVg + 1.0) * T1;
                    dT0_dVd = -(Abulk * dEsatL_dVd) * T1; 
                    dT0_dVb = -(Abulk * dEsatL_dVb + dAbulk_dVb * EsatL) * T1;   
                    
                    dVdsat_dVg = T3 * dT0_dVg + T2 * dEsatL_dVg + EsatL * T0;
                    dVdsat_dVd = T3 * dT0_dVd + T2 * dEsatL_dVd;
                    dVdsat_dVb = T3 * dT0_dVb + T2 * dEsatL_dVb;   
                }
                else
                {   tmp1 = dLambda_dVg / (Lambda * Lambda);
                    T9 = Abulk * WVCoxRds;
                    T8 = Abulk * T9;
                    T7 = Vgst2Vtm * T9;
                    T6 = Vgst2Vtm * WVCoxRds;
                    T0 = 2.0 * Abulk * (T9 - 1.0 + 1.0 / Lambda); 
                    dT0_dVg = 2.0 * (T8 * tmp2 - Abulk * tmp1
                    + (2.0 * T9 + 1.0 / Lambda - 1.0) * dAbulk_dVg);
                    
                    dT0_dVb = 2.0 * (T8 * (2.0 / Abulk * dAbulk_dVb + tmp3)
                    + (1.0 / Lambda - 1.0) * dAbulk_dVb);
                    dT0_dVd = 0.0; 
                    T1 = Vgst2Vtm * (2.0 / Lambda - 1.0) + Abulk * EsatL + 3.0 * T7;
                    
                    dT1_dVg = (2.0 / Lambda - 1.0) - 2.0 * Vgst2Vtm * tmp1
                    + Abulk * dEsatL_dVg + EsatL * dAbulk_dVg + 3.0 * (T9
                    + T7 * tmp2 + T6 * dAbulk_dVg);
                    dT1_dVb = Abulk * dEsatL_dVb + EsatL * dAbulk_dVb
                    + 3.0 * (T6 * dAbulk_dVb + T7 * tmp3);
                    dT1_dVd = Abulk * dEsatL_dVd;
                    
                    T2 = Vgst2Vtm * (EsatL + 2.0 * T6);
                    dT2_dVg = EsatL + Vgst2Vtm * dEsatL_dVg
                    + T6 * (4.0 + 2.0 * Vgst2Vtm * tmp2);
                    dT2_dVb = Vgst2Vtm * (dEsatL_dVb + 2.0 * T6 * tmp3);
                    dT2_dVd = Vgst2Vtm * dEsatL_dVd;
                    
                    T3 = sqrt(T1 * T1 - 2.0 * T0 * T2);
                    Vdsat = (T1 - T3) / T0;
                    
                    dT3_dVg = (T1 * dT1_dVg - 2.0 * (T0 * dT2_dVg + T2 * dT0_dVg))
                    / T3;
                    dT3_dVd = (T1 * dT1_dVd - 2.0 * (T0 * dT2_dVd + T2 * dT0_dVd))
                    / T3;
                    dT3_dVb = (T1 * dT1_dVb - 2.0 * (T0 * dT2_dVb + T2 * dT0_dVb))
                    / T3;
                    
                    dVdsat_dVg = (dT1_dVg - (T1 * dT1_dVg - dT0_dVg * T2
                    - T0 * dT2_dVg) / T3 - Vdsat * dT0_dVg) / T0;
                    dVdsat_dVb = (dT1_dVb - (T1 * dT1_dVb - dT0_dVb * T2
                    - T0 * dT2_dVb) / T3 - Vdsat * dT0_dVb) / T0;
                    dVdsat_dVd = (dT1_dVd - (T1 * dT1_dVd - T0 * dT2_dVd) / T3) / T0;
                }
                here->BSIM4v5vdsat = Vdsat;
                
                /* Calculate Vdseff */
                T1 = Vdsat - Vds - pParam->BSIM4v5delta;
                dT1_dVg = dVdsat_dVg;
                dT1_dVd = dVdsat_dVd - 1.0;
                dT1_dVb = dVdsat_dVb;
                
                T2 = sqrt(T1 * T1 + 4.0 * pParam->BSIM4v5delta * Vdsat);
                T0 = T1 / T2;
                T9 = 2.0 * pParam->BSIM4v5delta;
                T3 = T9 / T2;
                dT2_dVg = T0 * dT1_dVg + T3 * dVdsat_dVg;
                dT2_dVd = T0 * dT1_dVd + T3 * dVdsat_dVd;
                dT2_dVb = T0 * dT1_dVb + T3 * dVdsat_dVb;
                
                if (T1 >= 0.0)
                {   Vdseff = Vdsat - 0.5 * (T1 + T2);
                    dVdseff_dVg = dVdsat_dVg - 0.5 * (dT1_dVg + dT2_dVg);
                    dVdseff_dVd = dVdsat_dVd - 0.5 * (dT1_dVd + dT2_dVd);
                    dVdseff_dVb = dVdsat_dVb - 0.5 * (dT1_dVb + dT2_dVb);
                }
                else
                {   T4 = T9 / (T2 - T1);
                    T5 = 1.0 - T4;
                    T6 = Vdsat * T4 / (T2 - T1);
                    Vdseff = Vdsat * T5;
                    dVdseff_dVg = dVdsat_dVg * T5 + T6 * (dT2_dVg - dT1_dVg);
                    dVdseff_dVd = dVdsat_dVd * T5 + T6 * (dT2_dVd - dT1_dVd);
                    dVdseff_dVb = dVdsat_dVb * T5 + T6 * (dT2_dVb - dT1_dVb);
                }
                
                if (Vds == 0.0)
                {  Vdseff = 0.0;
                    dVdseff_dVg = 0.0;
                    dVdseff_dVb = 0.0; 
                }
                
                if (Vdseff > Vds)
                Vdseff = Vds;
                diffVds = Vds - Vdseff;
                here->BSIM4v5Vdseff = Vdseff;
                
                /* Velocity Overshoot */
                if((${::TECH($::type,$::corner,$::section,lambdaGiven)}) && (${::TECH($::type,$::corner,$::section,lambda)} > 0.0) )
                {  
                    T1 =  Leff * ueff;
                    T2 = pParam->BSIM4v5lambda / T1;
                    T3 = -T2 / T1 * Leff;
                    dT2_dVd = T3 * dueff_dVd;
                    dT2_dVg = T3 * dueff_dVg;
                    dT2_dVb = T3 * dueff_dVb;
                    T5 = 1.0 / (Esat * pParam->BSIM4v5litl);
                    T4 = -T5 / EsatL;
                    dT5_dVg = dEsatL_dVg * T4;
                    dT5_dVd = dEsatL_dVd * T4; 
                    dT5_dVb = dEsatL_dVb * T4; 
                    T6 = 1.0 + diffVds  * T5;
                    dT6_dVg = dT5_dVg * diffVds - dVdseff_dVg * T5;
                    dT6_dVd = dT5_dVd * diffVds + (1.0 - dVdseff_dVd) * T5;
                    dT6_dVb = dT5_dVb * diffVds - dVdseff_dVb * T5;
                    T7 = 2.0 / (T6 * T6 + 1.0);
                    T8 = 1.0 - T7;
                    T9 = T6 * T7 * T7;
                    dT8_dVg = T9 * dT6_dVg;
                    dT8_dVd = T9 * dT6_dVd;
                    dT8_dVb = T9 * dT6_dVb;
                    T10 = 1.0 + T2 * T8;
                    dT10_dVg = dT2_dVg * T8 + T2 * dT8_dVg;
                    dT10_dVd = dT2_dVd * T8 + T2 * dT8_dVd;
                    dT10_dVb = dT2_dVb * T8 + T2 * dT8_dVb;
                    if(T10 == 1.0)
                    dT10_dVg = dT10_dVd = dT10_dVb = 0.0;
                    
                    dEsatL_dVg *= T10;
                    dEsatL_dVg += EsatL * dT10_dVg;
                    dEsatL_dVd *= T10;
                    dEsatL_dVd += EsatL * dT10_dVd;
                    dEsatL_dVb *= T10;
                    dEsatL_dVb += EsatL * dT10_dVb;
                    EsatL *= T10;
                    here->BSIM4v5EsatL = EsatL;
                }
                
                /* Calculate Vasat */
                tmp4 = 1.0 - 0.5 * Abulk * Vdsat / Vgst2Vtm;
                T9 = WVCoxRds * Vgsteff;
                T8 = T9 / Vgst2Vtm;
                T0 = EsatL + Vdsat + 2.0 * T9 * tmp4;
                
                T7 = 2.0 * WVCoxRds * tmp4;
                dT0_dVg = dEsatL_dVg + dVdsat_dVg + T7 * (1.0 + tmp2 * Vgsteff)
                - T8 * (Abulk * dVdsat_dVg - Abulk * Vdsat / Vgst2Vtm
                + Vdsat * dAbulk_dVg);   
                
                dT0_dVb = dEsatL_dVb + dVdsat_dVb + T7 * tmp3 * Vgsteff
                - T8 * (dAbulk_dVb * Vdsat + Abulk * dVdsat_dVb);
                dT0_dVd = dEsatL_dVd + dVdsat_dVd - T8 * Abulk * dVdsat_dVd;
                
                T9 = WVCoxRds * Abulk; 
                T1 = 2.0 / Lambda - 1.0 + T9; 
                dT1_dVg = -2.0 * tmp1 +  WVCoxRds * (Abulk * tmp2 + dAbulk_dVg);
                dT1_dVb = dAbulk_dVb * WVCoxRds + T9 * tmp3;
                
                Vasat = T0 / T1;
                dVasat_dVg = (dT0_dVg - Vasat * dT1_dVg) / T1;
                dVasat_dVb = (dT0_dVb - Vasat * dT1_dVb) / T1;
                dVasat_dVd = dT0_dVd / T1;
                
                /* Calculate Idl first */
                tmp1 = here->BSIM4v5vtfbphi2;
                tmp2 = 2.0e8 * ${::TECH($::type,$::corner,$::section,toxp)};
                dT0_dVg = 1.0 / tmp2;
                T0 = (Vgsteff + tmp1) * dT0_dVg;
                
                tmp3 = exp(0.7 * log(T0));
                T1 = 1.0 + tmp3;
                T2 = 0.7 * tmp3 / T0;
                Tcen = 1.9e-9 / T1;
                dTcen_dVg = -Tcen * T2 * dT0_dVg / T1;
                
                Coxeff = EPSSI * ${::TECH($::type,$::corner,$::section,coxp)}
                / (EPSSI + ${::TECH($::type,$::corner,$::section,coxp)} * Tcen);
                dCoxeff_dVg = -Coxeff * Coxeff * dTcen_dVg / EPSSI;
                
                CoxeffWovL = Coxeff * Weff / Leff;
                beta = ueff * CoxeffWovL;
                T3 = ueff / Leff;
                dbeta_dVg = CoxeffWovL * dueff_dVg + T3
                * (Weff * dCoxeff_dVg + Coxeff * dWeff_dVg);
                dbeta_dVd = CoxeffWovL * dueff_dVd;
                dbeta_dVb = CoxeffWovL * dueff_dVb + T3 * Coxeff * dWeff_dVb;
                
                here->BSIM4v5AbovVgst2Vtm = Abulk / Vgst2Vtm;
                T0 = 1.0 - 0.5 * Vdseff * here->BSIM4v5AbovVgst2Vtm;
                dT0_dVg = -0.5 * (Abulk * dVdseff_dVg
                - Abulk * Vdseff / Vgst2Vtm + Vdseff * dAbulk_dVg) / Vgst2Vtm;
                dT0_dVd = -0.5 * Abulk * dVdseff_dVd / Vgst2Vtm;
                dT0_dVb = -0.5 * (Abulk * dVdseff_dVb + dAbulk_dVb * Vdseff)
                / Vgst2Vtm;
                
                fgche1 = Vgsteff * T0;
                dfgche1_dVg = Vgsteff * dT0_dVg + T0;
                dfgche1_dVd = Vgsteff * dT0_dVd;
                dfgche1_dVb = Vgsteff * dT0_dVb;
                
                T9 = Vdseff / EsatL;
                fgche2 = 1.0 + T9;
                dfgche2_dVg = (dVdseff_dVg - T9 * dEsatL_dVg) / EsatL;
                dfgche2_dVd = (dVdseff_dVd - T9 * dEsatL_dVd) / EsatL;
                dfgche2_dVb = (dVdseff_dVb - T9 * dEsatL_dVb) / EsatL;
                
                gche = beta * fgche1 / fgche2;
                dgche_dVg = (beta * dfgche1_dVg + fgche1 * dbeta_dVg
                - gche * dfgche2_dVg) / fgche2;
                dgche_dVd = (beta * dfgche1_dVd + fgche1 * dbeta_dVd
                - gche * dfgche2_dVd) / fgche2;
                dgche_dVb = (beta * dfgche1_dVb + fgche1 * dbeta_dVb
                - gche * dfgche2_dVb) / fgche2;
                
                T0 = 1.0 + gche * Rds;
                Idl = gche / T0;
                T1 = (1.0 - Idl * Rds) / T0;
                T2 = Idl * Idl;
                dIdl_dVg = T1 * dgche_dVg - T2 * dRds_dVg;
                dIdl_dVd = T1 * dgche_dVd;
                dIdl_dVb = T1 * dgche_dVb - T2 * dRds_dVb;
                
                /* Calculate degradation factor due to pocket implant */
                
                if (pParam->BSIM4v5fprout <= 0.0)
                {   FP = 1.0;
                    dFP_dVg = 0.0;
                }
                else
                {   T9 = pParam->BSIM4v5fprout * sqrt(Leff) / Vgst2Vtm;
                    FP = 1.0 / (1.0 + T9);
                    dFP_dVg = FP * FP * T9 / Vgst2Vtm;
                }
                
                /* Calculate VACLM */
                T8 = pParam->BSIM4v5pvag / EsatL;
                T9 = T8 * Vgsteff;
                if (T9 > -0.9)
                {   PvagTerm = 1.0 + T9;
                    dPvagTerm_dVg = T8 * (1.0 - Vgsteff * dEsatL_dVg / EsatL);
                    dPvagTerm_dVb = -T9 * dEsatL_dVb / EsatL;
                    dPvagTerm_dVd = -T9 * dEsatL_dVd / EsatL;
                }
                else
                {   T4 = 1.0 / (17.0 + 20.0 * T9);
                    PvagTerm = (0.8 + T9) * T4;
                    T4 *= T4;
                    dPvagTerm_dVg = T8 * (1.0 - Vgsteff * dEsatL_dVg / EsatL) * T4;
                    T9 *= T4 / EsatL;
                    dPvagTerm_dVb = -T9 * dEsatL_dVb;
                    dPvagTerm_dVd = -T9 * dEsatL_dVd;
                }
                
                if ((pParam->BSIM4v5pclm > MIN_EXP) && (diffVds > 1.0e-10))
                {   T0 = 1.0 + Rds * Idl;
                    dT0_dVg = dRds_dVg * Idl + Rds * dIdl_dVg;
                    dT0_dVd = Rds * dIdl_dVd;
                    dT0_dVb = dRds_dVb * Idl + Rds * dIdl_dVb;
                    
                    T2 = Vdsat / Esat;
                    T1 = Leff + T2;
                    dT1_dVg = (dVdsat_dVg - T2 * dEsatL_dVg / Leff) / Esat;
                    dT1_dVd = (dVdsat_dVd - T2 * dEsatL_dVd / Leff) / Esat;
                    dT1_dVb = (dVdsat_dVb - T2 * dEsatL_dVb / Leff) / Esat;
                    
                    Cclm = FP * PvagTerm * T0 * T1 / (pParam->BSIM4v5pclm * pParam->BSIM4v5litl);
                    dCclm_dVg = Cclm * (dFP_dVg / FP + dPvagTerm_dVg / PvagTerm
                    + dT0_dVg / T0 + dT1_dVg / T1);
                    dCclm_dVb = Cclm * (dPvagTerm_dVb / PvagTerm + dT0_dVb / T0
                    + dT1_dVb / T1);
                    dCclm_dVd = Cclm * (dPvagTerm_dVd / PvagTerm + dT0_dVd / T0
                    + dT1_dVd / T1);
                    VACLM = Cclm * diffVds;
                    
                    dVACLM_dVg = dCclm_dVg * diffVds - dVdseff_dVg * Cclm;
                    dVACLM_dVb = dCclm_dVb * diffVds - dVdseff_dVb * Cclm;
                    dVACLM_dVd = dCclm_dVd * diffVds + (1.0 - dVdseff_dVd) * Cclm;
                }
                else
                {   VACLM = Cclm = MAX_EXP;
                    dVACLM_dVd = dVACLM_dVg = dVACLM_dVb = 0.0;
                    dCclm_dVd = dCclm_dVg = dCclm_dVb = 0.0;
                }
                
                /* Calculate VADIBL */
                if (pParam->BSIM4v5thetaRout > MIN_EXP)
                {   T8 = Abulk * Vdsat;
                    T0 = Vgst2Vtm * T8;
                    dT0_dVg = Vgst2Vtm * Abulk * dVdsat_dVg + T8
                    + Vgst2Vtm * Vdsat * dAbulk_dVg;
                    dT0_dVb = Vgst2Vtm * (dAbulk_dVb * Vdsat + Abulk * dVdsat_dVb);
                    dT0_dVd = Vgst2Vtm * Abulk * dVdsat_dVd;
                    
                    T1 = Vgst2Vtm + T8;
                    dT1_dVg = 1.0 + Abulk * dVdsat_dVg + Vdsat * dAbulk_dVg;
                    dT1_dVb = Abulk * dVdsat_dVb + dAbulk_dVb * Vdsat;
                    dT1_dVd = Abulk * dVdsat_dVd;
                    
                    T9 = T1 * T1;
                    T2 = pParam->BSIM4v5thetaRout;
                    VADIBL = (Vgst2Vtm - T0 / T1) / T2;
                    dVADIBL_dVg = (1.0 - dT0_dVg / T1 + T0 * dT1_dVg / T9) / T2;
                    dVADIBL_dVb = (-dT0_dVb / T1 + T0 * dT1_dVb / T9) / T2;
                    dVADIBL_dVd = (-dT0_dVd / T1 + T0 * dT1_dVd / T9) / T2;
                    
                    T7 = pParam->BSIM4v5pdiblb * Vbseff;
                    if (T7 >= -0.9)
                    {   T3 = 1.0 / (1.0 + T7);
                        VADIBL *= T3;
                        dVADIBL_dVg *= T3;
                        dVADIBL_dVb = (dVADIBL_dVb - VADIBL * pParam->BSIM4v5pdiblb)
                        * T3;
                        dVADIBL_dVd *= T3;
                    }
                    else
                    {   T4 = 1.0 / (0.8 + T7);
                        T3 = (17.0 + 20.0 * T7) * T4;
                        dVADIBL_dVg *= T3;
                        dVADIBL_dVb = dVADIBL_dVb * T3
                        - VADIBL * pParam->BSIM4v5pdiblb * T4 * T4;
                        dVADIBL_dVd *= T3;
                        VADIBL *= T3;
                    }
                    
                    dVADIBL_dVg = dVADIBL_dVg * PvagTerm + VADIBL * dPvagTerm_dVg;
                    dVADIBL_dVb = dVADIBL_dVb * PvagTerm + VADIBL * dPvagTerm_dVb;
                    dVADIBL_dVd = dVADIBL_dVd * PvagTerm + VADIBL * dPvagTerm_dVd;
                    VADIBL *= PvagTerm;
                }
                else
                {   VADIBL = MAX_EXP;
                    dVADIBL_dVd = dVADIBL_dVg = dVADIBL_dVb = 0.0;
                }
                
                /* Calculate Va */
                Va = Vasat + VACLM;
                dVa_dVg = dVasat_dVg + dVACLM_dVg;
                dVa_dVb = dVasat_dVb + dVACLM_dVb;
                dVa_dVd = dVasat_dVd + dVACLM_dVd;
                
                /* Calculate VADITS */
                T0 = pParam->BSIM4v5pditsd * Vds;
                if (T0 > EXP_THRESHOLD)
                {   T1 = MAX_EXP;
                    dT1_dVd = 0;
                }
                else
                {   T1 = exp(T0);
                    dT1_dVd = T1 * pParam->BSIM4v5pditsd;
                }
                
                if (pParam->BSIM4v5pdits > MIN_EXP)
                {   T2 = 1.0 + ${::TECH($::type,$::corner,$::section,pditsl)} * Leff;
                    VADITS = (1.0 + T2 * T1) / pParam->BSIM4v5pdits;
                    dVADITS_dVg = VADITS * dFP_dVg;
                    dVADITS_dVd = FP * T2 * dT1_dVd / pParam->BSIM4v5pdits;
                    VADITS *= FP;
                }
                else
                {   VADITS = MAX_EXP;
                    dVADITS_dVg = dVADITS_dVd = 0;
                }
                
                /* Calculate VASCBE */
                if (pParam->BSIM4v5pscbe2 > 0.0)
                {   if (diffVds > pParam->BSIM4v5pscbe1 * pParam->BSIM4v5litl
                    / EXP_THRESHOLD)
                    {   T0 =  pParam->BSIM4v5pscbe1 * pParam->BSIM4v5litl / diffVds;
                        VASCBE = Leff * exp(T0) / pParam->BSIM4v5pscbe2;
                        T1 = T0 * VASCBE / diffVds;
                        dVASCBE_dVg = T1 * dVdseff_dVg;
                        dVASCBE_dVd = -T1 * (1.0 - dVdseff_dVd);
                        dVASCBE_dVb = T1 * dVdseff_dVb;
                    }
                    else
                    {   VASCBE = MAX_EXP * Leff/pParam->BSIM4v5pscbe2;
                        dVASCBE_dVg = dVASCBE_dVd = dVASCBE_dVb = 0.0;
                    }
                }
                else
                {   VASCBE = MAX_EXP;
                    dVASCBE_dVg = dVASCBE_dVd = dVASCBE_dVb = 0.0;
                }
                
                /* Add DIBL to Ids */
                T9 = diffVds / VADIBL;
                T0 = 1.0 + T9;
                Idsa = Idl * T0;
                dIdsa_dVg = T0 * dIdl_dVg - Idl * (dVdseff_dVg + T9 * dVADIBL_dVg) / VADIBL;
                dIdsa_dVd = T0 * dIdl_dVd + Idl
                * (1.0 - dVdseff_dVd - T9 * dVADIBL_dVd) / VADIBL;
                dIdsa_dVb = T0 * dIdl_dVb - Idl * (dVdseff_dVb + T9 * dVADIBL_dVb) / VADIBL;
                
                /* Add DITS to Ids */
                T9 = diffVds / VADITS;
                T0 = 1.0 + T9;
                dIdsa_dVg = T0 * dIdsa_dVg - Idsa * (dVdseff_dVg + T9 * dVADITS_dVg) / VADITS;
                dIdsa_dVd = T0 * dIdsa_dVd + Idsa 
                * (1.0 - dVdseff_dVd - T9 * dVADITS_dVd) / VADITS;
                dIdsa_dVb = T0 * dIdsa_dVb - Idsa * dVdseff_dVb / VADITS;
                Idsa *= T0;
                
                /* Add CLM to Ids */
                T0 = log(Va / Vasat);
                dT0_dVg = dVa_dVg / Va - dVasat_dVg / Vasat;
                dT0_dVb = dVa_dVb / Va - dVasat_dVb / Vasat;
                dT0_dVd = dVa_dVd / Va - dVasat_dVd / Vasat;
                T1 = T0 / Cclm;
                T9 = 1.0 + T1;
                dT9_dVg = (dT0_dVg - T1 * dCclm_dVg) / Cclm;
                dT9_dVb = (dT0_dVb - T1 * dCclm_dVb) / Cclm;
                dT9_dVd = (dT0_dVd - T1 * dCclm_dVd) / Cclm;
                
                dIdsa_dVg = dIdsa_dVg * T9 + Idsa * dT9_dVg;
                dIdsa_dVb = dIdsa_dVb * T9 + Idsa * dT9_dVb;
                dIdsa_dVd = dIdsa_dVd * T9 + Idsa * dT9_dVd;
                Idsa *= T9;
                
                /* Substrate current begins */
                tmp = pParam->BSIM4v5alpha0 + pParam->BSIM4v5alpha1 * Leff;
                if ((tmp <= 0.0) || (pParam->BSIM4v5beta0 <= 0.0))
                {   Isub = Gbd = Gbb = Gbg = 0.0;
                }
                else
                {   T2 = tmp / Leff;
                    if (diffVds > pParam->BSIM4v5beta0 / EXP_THRESHOLD)
                    {   T0 = -pParam->BSIM4v5beta0 / diffVds;
                        T1 = T2 * diffVds * exp(T0);
                        T3 = T1 / diffVds * (T0 - 1.0);
                        dT1_dVg = T3 * dVdseff_dVg;
                        dT1_dVd = T3 * (dVdseff_dVd - 1.0);
                        dT1_dVb = T3 * dVdseff_dVb;
                    }
                    else
                    {   T3 = T2 * MIN_EXP;
                        T1 = T3 * diffVds;
                        dT1_dVg = -T3 * dVdseff_dVg;
                        dT1_dVd = T3 * (1.0 - dVdseff_dVd);
                        dT1_dVb = -T3 * dVdseff_dVb;
                    }
                    T4 = Idsa * Vdseff;
                    Isub = T1 * T4;
                    Gbg = T1 * (dIdsa_dVg * Vdseff + Idsa * dVdseff_dVg)
                    + T4 * dT1_dVg;
                    Gbd = T1 * (dIdsa_dVd * Vdseff + Idsa * dVdseff_dVd)
                    + T4 * dT1_dVd;
                    Gbb = T1 * (dIdsa_dVb * Vdseff + Idsa * dVdseff_dVb)
                    + T4 * dT1_dVb;
                    
                    Gbd += Gbg * dVgsteff_dVd;
                    Gbb += Gbg * dVgsteff_dVb;
                    Gbg *= dVgsteff_dVg;
                    Gbb *= dVbseff_dVb;
                }
                here->BSIM4v5csub = Isub;
                here->BSIM4v5gbbs = Gbb;
                here->BSIM4v5gbgs = Gbg;
                here->BSIM4v5gbds = Gbd;
                
                /* Add SCBE to Ids */
                T9 = diffVds / VASCBE;
                T0 = 1.0 + T9;
                Ids = Idsa * T0;
                
                Gm = T0 * dIdsa_dVg - Idsa 
                * (dVdseff_dVg + T9 * dVASCBE_dVg) / VASCBE;
                Gds = T0 * dIdsa_dVd + Idsa 
                * (1.0 - dVdseff_dVd - T9 * dVASCBE_dVd) / VASCBE;
                Gmb = T0 * dIdsa_dVb - Idsa
                * (dVdseff_dVb + T9 * dVASCBE_dVb) / VASCBE;
                
                
                tmp1 = Gds + Gm * dVgsteff_dVd;
                tmp2 = Gmb + Gm * dVgsteff_dVb;
                tmp3 = Gm;
                
                Gm = (Ids * dVdseff_dVg + Vdseff * tmp3) * dVgsteff_dVg;
                Gds = Ids * (dVdseff_dVd + dVdseff_dVg * dVgsteff_dVd)
                + Vdseff * tmp1;
                Gmb = (Ids * (dVdseff_dVb + dVdseff_dVg * dVgsteff_dVb)
                + Vdseff * tmp2) * dVbseff_dVb;
                
                cdrain = Ids * Vdseff;
                
                /* Source End Velocity Limit  */
                if((${::TECH($::type,$::corner,$::section,vtlGiven)}) && (${::TECH($::type,$::corner,$::section,vtl)} > 0.0) ) {
                    T12 = 1.0 / Leff / CoxeffWovL;
                    T11 = T12 / Vgsteff;
                    T10 = -T11 / Vgsteff;
                    vs = cdrain * T11; /* vs */
                    dvs_dVg = Gm * T11 + cdrain * T10 * dVgsteff_dVg;
                    dvs_dVd = Gds * T11 + cdrain * T10 * dVgsteff_dVd;
                    dvs_dVb = Gmb * T11 + cdrain * T10 * dVgsteff_dVb;
                    T0 = 2 * MM;
                    T1 = vs / (pParam->BSIM4v5vtl * pParam->BSIM4v5tfactor);
                    if(T1 > 0.0)  
                    {	T2 = 1.0 + exp(T0 * log(T1));
                        T3 = (T2 - 1.0) * T0 / vs; 
                        Fsevl = 1.0 / exp(log(T2)/ T0);
                        dT2_dVg = T3 * dvs_dVg;
                        dT2_dVd = T3 * dvs_dVd;
                        dT2_dVb = T3 * dvs_dVb;
                        T4 = -1.0 / T0 * Fsevl / T2;
                        dFsevl_dVg = T4 * dT2_dVg;
                        dFsevl_dVd = T4 * dT2_dVd;
                        dFsevl_dVb = T4 * dT2_dVb;
                    } else {
                        Fsevl = 1.0;
                        dFsevl_dVg = 0.0;
                        dFsevl_dVd = 0.0;
                        dFsevl_dVb = 0.0;
                    }
                    Gm *=Fsevl;
                    Gm += cdrain * dFsevl_dVg;
                    Gmb *=Fsevl;
                    Gmb += cdrain * dFsevl_dVb;
                    Gds *=Fsevl;
                    Gds += cdrain * dFsevl_dVd;
                    
                    cdrain *= Fsevl; 
                } 
                
                here->BSIM4v5gds = Gds;
                here->BSIM4v5gm = Gm;
                here->BSIM4v5gmbs = Gmb;
                here->BSIM4v5IdovVds = Ids;
                if( here->BSIM4v5IdovVds <= 1.0e-9) here->BSIM4v5IdovVds = 1.0e-9;
                
                /* Calculate Rg */
                if ((here->BSIM4v5rgateMod > 1) ||
                (here->BSIM4v5trnqsMod != 0) || (here->BSIM4v5acnqsMod != 0))
                {   T9 = pParam->BSIM4v5xrcrg2 * ${::TECH($::type,$::corner,$::section,vtm)};
                    T0 = T9 * beta;
                    dT0_dVd = (dbeta_dVd + dbeta_dVg * dVgsteff_dVd) * T9;
                    dT0_dVb = (dbeta_dVb + dbeta_dVg * dVgsteff_dVb) * T9;
                    dT0_dVg = dbeta_dVg * T9;
                    
                    here->BSIM4v5gcrg = pParam->BSIM4v5xrcrg1 * ( T0 + Ids);
                    here->BSIM4v5gcrgd = pParam->BSIM4v5xrcrg1 * (dT0_dVd + tmp1);
                    here->BSIM4v5gcrgb = pParam->BSIM4v5xrcrg1 * (dT0_dVb + tmp2)
                    * dVbseff_dVb;	
                    here->BSIM4v5gcrgg = pParam->BSIM4v5xrcrg1 * (dT0_dVg + tmp3)
                    * dVgsteff_dVg;
                    
                    if (here->BSIM4v5nf != 1.0)
                    {   here->BSIM4v5gcrg *= here->BSIM4v5nf; 
                        here->BSIM4v5gcrgg *= here->BSIM4v5nf;
                        here->BSIM4v5gcrgd *= here->BSIM4v5nf;
                        here->BSIM4v5gcrgb *= here->BSIM4v5nf;
                    }
                    
                    if (here->BSIM4v5rgateMod == 2)
                    {   T10 = here->BSIM4v5grgeltd * here->BSIM4v5grgeltd;
                        T11 = here->BSIM4v5grgeltd + here->BSIM4v5gcrg;
                        here->BSIM4v5gcrg = here->BSIM4v5grgeltd * here->BSIM4v5gcrg / T11;
                        T12 = T10 / T11 / T11;
                        here->BSIM4v5gcrgg *= T12;
                        here->BSIM4v5gcrgd *= T12;
                        here->BSIM4v5gcrgb *= T12;
                    }
                    here->BSIM4v5gcrgs = -(here->BSIM4v5gcrgg + here->BSIM4v5gcrgd
                    + here->BSIM4v5gcrgb);
                }
                
                
                /* Calculate bias-dependent external S/D resistance */
                if (${::TECH($::type,$::corner,$::section,rdsMod)})
                {   /* Rs(V) */
                    T0 = vgs - pParam->BSIM4v5vfbsd;
                    T1 = sqrt(T0 * T0 + 1.0e-4);
                    vgs_eff = 0.5 * (T0 + T1);
                    dvgs_eff_dvg = vgs_eff / T1;
                    
                    T0 = 1.0 + pParam->BSIM4v5prwg * vgs_eff;
                    dT0_dvg = -pParam->BSIM4v5prwg / T0 / T0 * dvgs_eff_dvg;
                    T1 = -pParam->BSIM4v5prwb * vbs;
                    dT1_dvb = -pParam->BSIM4v5prwb;
                    
                    T2 = 1.0 / T0 + T1;
                    T3 = T2 + sqrt(T2 * T2 + 0.01);
                    dT3_dvg = T3 / (T3 - T2);
                    dT3_dvb = dT3_dvg * dT1_dvb;
                    dT3_dvg *= dT0_dvg;
                    
                    T4 = pParam->BSIM4v5rs0 * 0.5;
                    Rs = pParam->BSIM4v5rswmin + T3 * T4;
                    dRs_dvg = T4 * dT3_dvg;
                    dRs_dvb = T4 * dT3_dvb;
                    
                    T0 = 1.0 + here->BSIM4v5sourceConductance * Rs;
                    here->BSIM4v5gstot = here->BSIM4v5sourceConductance / T0;
                    T0 = -here->BSIM4v5gstot * here->BSIM4v5gstot;
                    dgstot_dvd = 0.0; /* place holder */
                    dgstot_dvg = T0 * dRs_dvg;
                    dgstot_dvb = T0 * dRs_dvb;
                    dgstot_dvs = -(dgstot_dvg + dgstot_dvb + dgstot_dvd);
                    
                    /* Rd(V) */
                    T0 = vgd - pParam->BSIM4v5vfbsd;
                    T1 = sqrt(T0 * T0 + 1.0e-4);
                    vgd_eff = 0.5 * (T0 + T1);
                    dvgd_eff_dvg = vgd_eff / T1;
                    
                    T0 = 1.0 + pParam->BSIM4v5prwg * vgd_eff;
                    dT0_dvg = -pParam->BSIM4v5prwg / T0 / T0 * dvgd_eff_dvg;
                    T1 = -pParam->BSIM4v5prwb * vbd;
                    dT1_dvb = -pParam->BSIM4v5prwb;
                    
                    T2 = 1.0 / T0 + T1;
                    T3 = T2 + sqrt(T2 * T2 + 0.01);
                    dT3_dvg = T3 / (T3 - T2);
                    dT3_dvb = dT3_dvg * dT1_dvb;
                    dT3_dvg *= dT0_dvg;
                    
                    T4 = pParam->BSIM4v5rd0 * 0.5;
                    Rd = pParam->BSIM4v5rdwmin + T3 * T4;
                    dRd_dvg = T4 * dT3_dvg;
                    dRd_dvb = T4 * dT3_dvb;
                    
                    T0 = 1.0 + here->BSIM4v5drainConductance * Rd;
                    here->BSIM4v5gdtot = here->BSIM4v5drainConductance / T0;
                    T0 = -here->BSIM4v5gdtot * here->BSIM4v5gdtot;
                    dgdtot_dvs = 0.0;
                    dgdtot_dvg = T0 * dRd_dvg;
                    dgdtot_dvb = T0 * dRd_dvb;
                    dgdtot_dvd = -(dgdtot_dvg + dgdtot_dvb + dgdtot_dvs);
                    
                    here->BSIM4v5gstotd = vses * dgstot_dvd;
                    here->BSIM4v5gstotg = vses * dgstot_dvg;
                    here->BSIM4v5gstots = vses * dgstot_dvs;
                    here->BSIM4v5gstotb = vses * dgstot_dvb;
                    
                    T2 = vdes - vds;
                    here->BSIM4v5gdtotd = T2 * dgdtot_dvd;
                    here->BSIM4v5gdtotg = T2 * dgdtot_dvg;
                    here->BSIM4v5gdtots = T2 * dgdtot_dvs;
                    here->BSIM4v5gdtotb = T2 * dgdtot_dvb;
                }
                else /* WDLiu: for bypass */
                {   here->BSIM4v5gstot = here->BSIM4v5gstotd = here->BSIM4v5gstotg = 0.0;
                    here->BSIM4v5gstots = here->BSIM4v5gstotb = 0.0;
                    here->BSIM4v5gdtot = here->BSIM4v5gdtotd = here->BSIM4v5gdtotg = 0.0;
                    here->BSIM4v5gdtots = here->BSIM4v5gdtotb = 0.0;
                }
                
                /* Calculate GIDL current */
                vgs_eff = here->BSIM4v5vgs_eff;
                dvgs_eff_dvg = here->BSIM4v5dvgs_eff_dvg;
                T0 = 3.0 * ${::TECH($::type,$::corner,$::section,toxe)};
                
                T1 = (vds - vgs_eff - pParam->BSIM4v5egidl ) / T0;
                if ((pParam->BSIM4v5agidl <= 0.0) || (pParam->BSIM4v5bgidl <= 0.0)
                || (T1 <= 0.0) || (pParam->BSIM4v5cgidl <= 0.0) || (vbd > 0.0))
                Igidl = Ggidld = Ggidlg = Ggidlb = 0.0;
                else {
                    dT1_dVd = 1.0 / T0;
                    dT1_dVg = -dvgs_eff_dvg * dT1_dVd;
                    T2 = pParam->BSIM4v5bgidl / T1;
                    if (T2 < 100.0)
                    {   Igidl = pParam->BSIM4v5agidl * pParam->BSIM4v5weffCJ * T1 * exp(-T2);
                        T3 = Igidl * (1.0 + T2) / T1;
                        Ggidld = T3 * dT1_dVd;
                        Ggidlg = T3 * dT1_dVg;
                    }
                    else
                    {   Igidl = pParam->BSIM4v5agidl * pParam->BSIM4v5weffCJ * 3.720075976e-44;
                        Ggidld = Igidl * dT1_dVd;
                        Ggidlg = Igidl * dT1_dVg;
                        Igidl *= T1;
                    }
                    
                    T4 = vbd * vbd;
                    T5 = -vbd * T4;
                    T6 = pParam->BSIM4v5cgidl + T5;
                    T7 = T5 / T6;
                    T8 = 3.0 * pParam->BSIM4v5cgidl * T4 / T6 / T6;
                    Ggidld = Ggidld * T7 + Igidl * T8;
                    Ggidlg = Ggidlg * T7;
                    Ggidlb = -Igidl * T8;
                    Igidl *= T7;
                }
                here->BSIM4v5Igidl = Igidl;
                here->BSIM4v5ggidld = Ggidld;
                here->BSIM4v5ggidlg = Ggidlg;
                here->BSIM4v5ggidlb = Ggidlb;
                
                /* Calculate GISL current  */
                vgd_eff = here->BSIM4v5vgd_eff;
                dvgd_eff_dvg = here->BSIM4v5dvgd_eff_dvg;
                
                T1 = (-vds - vgd_eff - pParam->BSIM4v5egidl ) / T0;
                
                if ((pParam->BSIM4v5agidl <= 0.0) || (pParam->BSIM4v5bgidl <= 0.0)
                || (T1 <= 0.0) || (pParam->BSIM4v5cgidl <= 0.0) || (vbs > 0.0))
                Igisl = Ggisls = Ggislg = Ggislb = 0.0;
                else {
                    dT1_dVd = 1.0 / T0;
                    dT1_dVg = -dvgd_eff_dvg * dT1_dVd;
                    T2 = pParam->BSIM4v5bgidl / T1;
                    if (T2 < 100.0) 
                    {   Igisl = pParam->BSIM4v5agidl * pParam->BSIM4v5weffCJ * T1 * exp(-T2);
                        T3 = Igisl * (1.0 + T2) / T1;
                        Ggisls = T3 * dT1_dVd;
                        Ggislg = T3 * dT1_dVg;
                    }
                    else 
                    {   Igisl = pParam->BSIM4v5agidl * pParam->BSIM4v5weffCJ * 3.720075976e-44;
                        Ggisls = Igisl * dT1_dVd;
                        Ggislg = Igisl * dT1_dVg;
                        Igisl *= T1;
                    }
                    
                    T4 = vbs * vbs;
                    T5 = -vbs * T4;
                    T6 = pParam->BSIM4v5cgidl + T5;
                    T7 = T5 / T6;
                    T8 = 3.0 * pParam->BSIM4v5cgidl * T4 / T6 / T6;
                    Ggisls = Ggisls * T7 + Igisl * T8;
                    Ggislg = Ggislg * T7;
                    Ggislb = -Igisl * T8;
                    Igisl *= T7;
                }
                here->BSIM4v5Igisl = Igisl;
                here->BSIM4v5ggisls = Ggisls;
                here->BSIM4v5ggislg = Ggislg;
                here->BSIM4v5ggislb = Ggislb;
                
                
                /* Calculate gate tunneling current */
                if ((${::TECH($::type,$::corner,$::section,igcMod)} != 0) || (${::TECH($::type,$::corner,$::section,igbMod)} != 0))
                {   Vfb = here->BSIM4v5vfbzb;
                    V3 = Vfb - Vgs_eff + Vbseff - DELTA_3;
                    if (Vfb <= 0.0)
                    T0 = sqrt(V3 * V3 - 4.0 * DELTA_3 * Vfb);
                    else
                    T0 = sqrt(V3 * V3 + 4.0 * DELTA_3 * Vfb);
                    T1 = 0.5 * (1.0 + V3 / T0);
                    Vfbeff = Vfb - 0.5 * (V3 + T0);
                    dVfbeff_dVg = T1 * dVgs_eff_dVg;
                    dVfbeff_dVb = -T1; /* WDLiu: -No surprise? No. -Good! */
                    
                    Voxacc = Vfb - Vfbeff;
                    dVoxacc_dVg = -dVfbeff_dVg;
                    dVoxacc_dVb = -dVfbeff_dVb;
                    if (Voxacc < 0.0) /* WDLiu: Avoiding numerical instability. */
                    Voxacc = dVoxacc_dVg = dVoxacc_dVb = 0.0;
                    
                    T0 = 0.5 * pParam->BSIM4v5k1ox;
                    T3 = Vgs_eff - Vfbeff - Vbseff - Vgsteff;
                    if (pParam->BSIM4v5k1ox == 0.0)
                    Voxdepinv = dVoxdepinv_dVg = dVoxdepinv_dVd
                    = dVoxdepinv_dVb = 0.0;
                    else if (T3 < 0.0)
                    {   Voxdepinv = -T3;
                        dVoxdepinv_dVg = -dVgs_eff_dVg + dVfbeff_dVg
                        + dVgsteff_dVg;
                        dVoxdepinv_dVd = dVgsteff_dVd;
                        dVoxdepinv_dVb = dVfbeff_dVb + 1.0 + dVgsteff_dVb;
                    }
                    else
                    {   T1 = sqrt(T0 * T0 + T3);
                        T2 = T0 / T1;
                        Voxdepinv = pParam->BSIM4v5k1ox * (T1 - T0);
                        dVoxdepinv_dVg = T2 * (dVgs_eff_dVg - dVfbeff_dVg
                        - dVgsteff_dVg);
                        dVoxdepinv_dVd = -T2 * dVgsteff_dVd;
                        dVoxdepinv_dVb = -T2 * (dVfbeff_dVb + 1.0 + dVgsteff_dVb);
                    }
                    
                    Voxdepinv += Vgsteff;
                    dVoxdepinv_dVg += dVgsteff_dVg;
                    dVoxdepinv_dVd += dVgsteff_dVd;
                    dVoxdepinv_dVb += dVgsteff_dVb;
                }
                
                if(${::TECH($::type,$::corner,$::section,tempMod)} < 2)
                tmp = Vtm;
                else /* ${::TECH($::type,$::corner,$::section,tempMod)} = 2 */
                tmp = Vtm0;
                if (${::TECH($::type,$::corner,$::section,igcMod)})
                {   T0 = tmp * pParam->BSIM4v5nigc;
                    if(${::TECH($::type,$::corner,$::section,igcMod)} == 1) {
                        VxNVt = (Vgs_eff - ${::TECH($::type,$::corner,$::section,type)} * here->BSIM4v5vth0) / T0;
                        if (VxNVt > EXP_THRESHOLD)
                        {   Vaux = Vgs_eff - ${::TECH($::type,$::corner,$::section,type)} * here->BSIM4v5vth0;
                            dVaux_dVg = dVgs_eff_dVg;
                            dVaux_dVd = 0.0;
                            dVaux_dVb = 0.0;
                        }
                    } else if (${::TECH($::type,$::corner,$::section,igcMod)} == 2) {
                        VxNVt = (Vgs_eff - here->BSIM4v5von) / T0;
                        if (VxNVt > EXP_THRESHOLD)
                        {   Vaux = Vgs_eff - here->BSIM4v5von;
                            dVaux_dVg = dVgs_eff_dVg;
                            dVaux_dVd = -dVth_dVd;
                            dVaux_dVb = -dVth_dVb;
                        }
                    } 
                    if (VxNVt < -EXP_THRESHOLD)
                    {   Vaux = T0 * log(1.0 + MIN_EXP);
                        dVaux_dVg = dVaux_dVd = dVaux_dVb = 0.0;
                    }
                    else if ((VxNVt >= -EXP_THRESHOLD) && (VxNVt <= EXP_THRESHOLD))
                    {   ExpVxNVt = exp(VxNVt);
                        Vaux = T0 * log(1.0 + ExpVxNVt);
                        dVaux_dVg = ExpVxNVt / (1.0 + ExpVxNVt);
                        if(${::TECH($::type,$::corner,$::section,igcMod)} == 1) {
                            dVaux_dVd = 0.0;
                            dVaux_dVb = 0.0;
                        } else if (${::TECH($::type,$::corner,$::section,igcMod)} == 2) {
                            dVaux_dVd = -dVgs_eff_dVg * dVth_dVd;
                            dVaux_dVb = -dVgs_eff_dVg * dVth_dVb;
                        }
                        dVaux_dVg *= dVgs_eff_dVg;
                    }
                    
                    T2 = Vgs_eff * Vaux;
                    dT2_dVg = dVgs_eff_dVg * Vaux + Vgs_eff * dVaux_dVg;
                    dT2_dVd = Vgs_eff * dVaux_dVd;
                    dT2_dVb = Vgs_eff * dVaux_dVb;
                    
                    T11 = pParam->BSIM4v5Aechvb;
                    T12 = pParam->BSIM4v5Bechvb;
                    T3 = pParam->BSIM4v5aigc * pParam->BSIM4v5cigc
                    - pParam->BSIM4v5bigc;
                    T4 = pParam->BSIM4v5bigc * pParam->BSIM4v5cigc;
                    T5 = T12 * (pParam->BSIM4v5aigc + T3 * Voxdepinv
                    - T4 * Voxdepinv * Voxdepinv);
                    
                    if (T5 > EXP_THRESHOLD)
                    {   T6 = MAX_EXP;
                        dT6_dVg = dT6_dVd = dT6_dVb = 0.0;
                    }
                    else if (T5 < -EXP_THRESHOLD)
                    {   T6 = MIN_EXP;
                        dT6_dVg = dT6_dVd = dT6_dVb = 0.0;
                    }
                    else
                    {   T6 = exp(T5);
                        dT6_dVg = T6 * T12 * (T3 - 2.0 * T4 * Voxdepinv);
                        dT6_dVd = dT6_dVg * dVoxdepinv_dVd;
                        dT6_dVb = dT6_dVg * dVoxdepinv_dVb;
                        dT6_dVg *= dVoxdepinv_dVg;
                    }
                    
                    Igc = T11 * T2 * T6;
                    dIgc_dVg = T11 * (T2 * dT6_dVg + T6 * dT2_dVg);
                    dIgc_dVd = T11 * (T2 * dT6_dVd + T6 * dT2_dVd);
                    dIgc_dVb = T11 * (T2 * dT6_dVb + T6 * dT2_dVb);
                    
                    if (${::TECH($::type,$::corner,$::section,pigcdGiven)})
                    {   Pigcd = pParam->BSIM4v5pigcd;
                        dPigcd_dVg = dPigcd_dVd = dPigcd_dVb = 0.0;
                    }
                    else
                    {   T11 = pParam->BSIM4v5Bechvb * ${::TECH($::type,$::corner,$::section,toxe)};
                        T12 = Vgsteff + 1.0e-20;
                        T13 = T11 / T12 / T12;
                        T14 = -T13 / T12;
                        Pigcd = T13 * (1.0 - 0.5 * Vdseff / T12); 
                        dPigcd_dVg = T14 * (2.0 + 0.5 * (dVdseff_dVg
                        - 3.0 * Vdseff / T12));
                        dPigcd_dVd = 0.5 * T14 * dVdseff_dVd;
                        dPigcd_dVb = 0.5 * T14 * dVdseff_dVb;
                    }
                    
                    T7 = -Pigcd * Vdseff; /* bugfix */
                    dT7_dVg = -Vdseff * dPigcd_dVg - Pigcd * dVdseff_dVg;
                    dT7_dVd = -Vdseff * dPigcd_dVd - Pigcd * dVdseff_dVd + dT7_dVg * dVgsteff_dVd;
                    dT7_dVb = -Vdseff * dPigcd_dVb - Pigcd * dVdseff_dVb + dT7_dVg * dVgsteff_dVb;
                    dT7_dVg *= dVgsteff_dVg;
                    dT7_dVb *= dVbseff_dVb;
                    T8 = T7 * T7 + 2.0e-4;
                    dT8_dVg = 2.0 * T7;
                    dT8_dVd = dT8_dVg * dT7_dVd;
                    dT8_dVb = dT8_dVg * dT7_dVb;
                    dT8_dVg *= dT7_dVg;
                    
                    if (T7 > EXP_THRESHOLD)
                    {   T9 = MAX_EXP;
                        dT9_dVg = dT9_dVd = dT9_dVb = 0.0;
                    }
                    else if (T7 < -EXP_THRESHOLD)
                    {   T9 = MIN_EXP;
                        dT9_dVg = dT9_dVd = dT9_dVb = 0.0;
                    }
                    else
                    {   T9 = exp(T7);
                        dT9_dVg = T9 * dT7_dVg;
                        dT9_dVd = T9 * dT7_dVd;
                        dT9_dVb = T9 * dT7_dVb;
                    }
                    
                    T0 = T8 * T8;
                    T1 = T9 - 1.0 + 1.0e-4;
                    T10 = (T1 - T7) / T8;
                    dT10_dVg = (dT9_dVg - dT7_dVg - T10 * dT8_dVg) / T8;
                    dT10_dVd = (dT9_dVd - dT7_dVd - T10 * dT8_dVd) / T8;
                    dT10_dVb = (dT9_dVb - dT7_dVb - T10 * dT8_dVb) / T8;
                    
                    Igcs = Igc * T10;
                    dIgcs_dVg = dIgc_dVg * T10 + Igc * dT10_dVg;
                    dIgcs_dVd = dIgc_dVd * T10 + Igc * dT10_dVd;
                    dIgcs_dVb = dIgc_dVb * T10 + Igc * dT10_dVb;
                    
                    T1 = T9 - 1.0 - 1.0e-4;
                    T10 = (T7 * T9 - T1) / T8;
                    dT10_dVg = (dT7_dVg * T9 + (T7 - 1.0) * dT9_dVg
                    - T10 * dT8_dVg) / T8;
                    dT10_dVd = (dT7_dVd * T9 + (T7 - 1.0) * dT9_dVd
                    - T10 * dT8_dVd) / T8;
                    dT10_dVb = (dT7_dVb * T9 + (T7 - 1.0) * dT9_dVb
                    - T10 * dT8_dVb) / T8;
                    Igcd = Igc * T10;
                    dIgcd_dVg = dIgc_dVg * T10 + Igc * dT10_dVg;
                    dIgcd_dVd = dIgc_dVd * T10 + Igc * dT10_dVd;
                    dIgcd_dVb = dIgc_dVb * T10 + Igc * dT10_dVb;
                    
                    here->BSIM4v5Igcs = Igcs;
                    here->BSIM4v5gIgcsg = dIgcs_dVg;
                    here->BSIM4v5gIgcsd = dIgcs_dVd;
                    here->BSIM4v5gIgcsb =  dIgcs_dVb * dVbseff_dVb;
                    here->BSIM4v5Igcd = Igcd;
                    here->BSIM4v5gIgcdg = dIgcd_dVg;
                    here->BSIM4v5gIgcdd = dIgcd_dVd;
                    here->BSIM4v5gIgcdb = dIgcd_dVb * dVbseff_dVb;
                    
                    T0 = vgs - (pParam->BSIM4v5vfbsd + pParam->BSIM4v5vfbsdoff);
                    vgs_eff = sqrt(T0 * T0 + 1.0e-4);
                    dvgs_eff_dvg = T0 / vgs_eff;
                    
                    T2 = vgs * vgs_eff;
                    dT2_dVg = vgs * dvgs_eff_dvg + vgs_eff;
                    T11 = pParam->BSIM4v5AechvbEdge;
                    T12 = pParam->BSIM4v5BechvbEdge;
                    T3 = pParam->BSIM4v5aigsd * pParam->BSIM4v5cigsd
                    - pParam->BSIM4v5bigsd;
                    T4 = pParam->BSIM4v5bigsd * pParam->BSIM4v5cigsd;
                    T5 = T12 * (pParam->BSIM4v5aigsd + T3 * vgs_eff
                    - T4 * vgs_eff * vgs_eff);
                    if (T5 > EXP_THRESHOLD)
                    {   T6 = MAX_EXP;
                        dT6_dVg = 0.0;
                    }
                    else if (T5 < -EXP_THRESHOLD)
                    {   T6 = MIN_EXP;
                        dT6_dVg = 0.0;
                    }
                    else
                    {   T6 = exp(T5);
                        dT6_dVg = T6 * T12 * (T3 - 2.0 * T4 * vgs_eff)
                        * dvgs_eff_dvg;
                    }
                    Igs = T11 * T2 * T6;
                    dIgs_dVg = T11 * (T2 * dT6_dVg + T6 * dT2_dVg);
                    dIgs_dVs = -dIgs_dVg;
                    
                    
                    T0 = vgd - (pParam->BSIM4v5vfbsd + pParam->BSIM4v5vfbsdoff);
                    vgd_eff = sqrt(T0 * T0 + 1.0e-4);
                    dvgd_eff_dvg = T0 / vgd_eff;
                    
                    T2 = vgd * vgd_eff;
                    dT2_dVg = vgd * dvgd_eff_dvg + vgd_eff;
                    T5 = T12 * (pParam->BSIM4v5aigsd + T3 * vgd_eff
                    - T4 * vgd_eff * vgd_eff);
                    if (T5 > EXP_THRESHOLD)
                    {   T6 = MAX_EXP;
                        dT6_dVg = 0.0;
                    }
                    else if (T5 < -EXP_THRESHOLD)
                    {   T6 = MIN_EXP;
                        dT6_dVg = 0.0;
                    }
                    else
                    {   T6 = exp(T5);
                        dT6_dVg = T6 * T12 * (T3 - 2.0 * T4 * vgd_eff)
                        * dvgd_eff_dvg;
                    }
                    Igd = T11 * T2 * T6;
                    dIgd_dVg = T11 * (T2 * dT6_dVg + T6 * dT2_dVg);
                    dIgd_dVd = -dIgd_dVg;
                    
                    here->BSIM4v5Igs = Igs;
                    here->BSIM4v5gIgsg = dIgs_dVg;
                    here->BSIM4v5gIgss = dIgs_dVs;
                    here->BSIM4v5Igd = Igd;
                    here->BSIM4v5gIgdg = dIgd_dVg;
                    here->BSIM4v5gIgdd = dIgd_dVd;
                }
                else
                {   here->BSIM4v5Igcs = here->BSIM4v5gIgcsg = here->BSIM4v5gIgcsd
                    = here->BSIM4v5gIgcsb = 0.0;
                    here->BSIM4v5Igcd = here->BSIM4v5gIgcdg = here->BSIM4v5gIgcdd
                    = here->BSIM4v5gIgcdb = 0.0;
                    here->BSIM4v5Igs = here->BSIM4v5gIgsg = here->BSIM4v5gIgss = 0.0;
                    here->BSIM4v5Igd = here->BSIM4v5gIgdg = here->BSIM4v5gIgdd = 0.0;
                }
                
                if (${::TECH($::type,$::corner,$::section,igbMod)})
                {   T0 = tmp * pParam->BSIM4v5nigbacc;
                    T1 = -Vgs_eff + Vbseff + Vfb;
                    VxNVt = T1 / T0;
                    if (VxNVt > EXP_THRESHOLD)
                    {   Vaux = T1;
                        dVaux_dVg = -dVgs_eff_dVg;
                        dVaux_dVb = 1.0;
                    }
                    else if (VxNVt < -EXP_THRESHOLD)
                    {   Vaux = T0 * log(1.0 + MIN_EXP);
                        dVaux_dVg = dVaux_dVb = 0.0;
                    }
                    else
                    {   ExpVxNVt = exp(VxNVt);
                        Vaux = T0 * log(1.0 + ExpVxNVt);
                        dVaux_dVb = ExpVxNVt / (1.0 + ExpVxNVt); 
                        dVaux_dVg = -dVaux_dVb * dVgs_eff_dVg;
                    }
                    
                    T2 = (Vgs_eff - Vbseff) * Vaux;
                    dT2_dVg = dVgs_eff_dVg * Vaux + (Vgs_eff - Vbseff) * dVaux_dVg;
                    dT2_dVb = -Vaux + (Vgs_eff - Vbseff) * dVaux_dVb;
                    
                    T11 = 4.97232e-7 * pParam->BSIM4v5weff
                    * pParam->BSIM4v5leff * pParam->BSIM4v5ToxRatio;
                    T12 = -7.45669e11 * ${::TECH($::type,$::corner,$::section,toxe)};
                    T3 = pParam->BSIM4v5aigbacc * pParam->BSIM4v5cigbacc
                    - pParam->BSIM4v5bigbacc;
                    T4 = pParam->BSIM4v5bigbacc * pParam->BSIM4v5cigbacc;
                    T5 = T12 * (pParam->BSIM4v5aigbacc + T3 * Voxacc
                    - T4 * Voxacc * Voxacc);
                    
                    if (T5 > EXP_THRESHOLD)
                    {   T6 = MAX_EXP;
                        dT6_dVg = dT6_dVb = 0.0;
                    }
                    else if (T5 < -EXP_THRESHOLD)
                    {   T6 = MIN_EXP;
                        dT6_dVg = dT6_dVb = 0.0;
                    }
                    else
                    {   T6 = exp(T5);
                        dT6_dVg = T6 * T12 * (T3 - 2.0 * T4 * Voxacc);
                        dT6_dVb = dT6_dVg * dVoxacc_dVb;
                        dT6_dVg *= dVoxacc_dVg;
                    }
                    
                    Igbacc = T11 * T2 * T6;
                    dIgbacc_dVg = T11 * (T2 * dT6_dVg + T6 * dT2_dVg);
                    dIgbacc_dVb = T11 * (T2 * dT6_dVb + T6 * dT2_dVb);
                    
                    
                    T0 = tmp * pParam->BSIM4v5nigbinv;
                    T1 = Voxdepinv - pParam->BSIM4v5eigbinv;
                    VxNVt = T1 / T0;
                    if (VxNVt > EXP_THRESHOLD)
                    {   Vaux = T1;
                        dVaux_dVg = dVoxdepinv_dVg;
                        dVaux_dVd = dVoxdepinv_dVd;
                        dVaux_dVb = dVoxdepinv_dVb;
                    }
                    else if (VxNVt < -EXP_THRESHOLD)
                    {   Vaux = T0 * log(1.0 + MIN_EXP);
                        dVaux_dVg = dVaux_dVd = dVaux_dVb = 0.0;
                    }
                    else
                    {   ExpVxNVt = exp(VxNVt);
                        Vaux = T0 * log(1.0 + ExpVxNVt);
                        dVaux_dVg = ExpVxNVt / (1.0 + ExpVxNVt);
                        dVaux_dVd = dVaux_dVg * dVoxdepinv_dVd;
                        dVaux_dVb = dVaux_dVg * dVoxdepinv_dVb;
                        dVaux_dVg *= dVoxdepinv_dVg;
                    }
                    
                    T2 = (Vgs_eff - Vbseff) * Vaux;
                    dT2_dVg = dVgs_eff_dVg * Vaux + (Vgs_eff - Vbseff) * dVaux_dVg;
                    dT2_dVd = (Vgs_eff - Vbseff) * dVaux_dVd;
                    dT2_dVb = -Vaux + (Vgs_eff - Vbseff) * dVaux_dVb;
                    
                    T11 *= 0.75610;
                    T12 *= 1.31724;
                    T3 = pParam->BSIM4v5aigbinv * pParam->BSIM4v5cigbinv
                    - pParam->BSIM4v5bigbinv;
                    T4 = pParam->BSIM4v5bigbinv * pParam->BSIM4v5cigbinv;
                    T5 = T12 * (pParam->BSIM4v5aigbinv + T3 * Voxdepinv
                    - T4 * Voxdepinv * Voxdepinv);
                    
                    if (T5 > EXP_THRESHOLD)
                    {   T6 = MAX_EXP;
                        dT6_dVg = dT6_dVd = dT6_dVb = 0.0;
                    }
                    else if (T5 < -EXP_THRESHOLD)
                    {   T6 = MIN_EXP;
                        dT6_dVg = dT6_dVd = dT6_dVb = 0.0;
                    }
                    else
                    {   T6 = exp(T5);
                        dT6_dVg = T6 * T12 * (T3 - 2.0 * T4 * Voxdepinv);
                        dT6_dVd = dT6_dVg * dVoxdepinv_dVd;
                        dT6_dVb = dT6_dVg * dVoxdepinv_dVb;
                        dT6_dVg *= dVoxdepinv_dVg;
                    }
                    
                    Igbinv = T11 * T2 * T6;
                    dIgbinv_dVg = T11 * (T2 * dT6_dVg + T6 * dT2_dVg);
                    dIgbinv_dVd = T11 * (T2 * dT6_dVd + T6 * dT2_dVd);
                    dIgbinv_dVb = T11 * (T2 * dT6_dVb + T6 * dT2_dVb);
                    
                    here->BSIM4v5Igb = Igbinv + Igbacc;
                    here->BSIM4v5gIgbg = dIgbinv_dVg + dIgbacc_dVg;
                    here->BSIM4v5gIgbd = dIgbinv_dVd;
                    here->BSIM4v5gIgbb = (dIgbinv_dVb + dIgbacc_dVb) * dVbseff_dVb;
                }
                else
                {  here->BSIM4v5Igb = here->BSIM4v5gIgbg = here->BSIM4v5gIgbd
                    = here->BSIM4v5gIgbs = here->BSIM4v5gIgbb = 0.0;   
                } /* End of Gate current */
                
                if (here->BSIM4v5nf != 1.0)
                {   cdrain *= here->BSIM4v5nf;
                    here->BSIM4v5gds *= here->BSIM4v5nf;
                    here->BSIM4v5gm *= here->BSIM4v5nf;
                    here->BSIM4v5gmbs *= here->BSIM4v5nf;
                    here->BSIM4v5IdovVds *= here->BSIM4v5nf;
                    
                    here->BSIM4v5gbbs *= here->BSIM4v5nf;
                    here->BSIM4v5gbgs *= here->BSIM4v5nf;
                    here->BSIM4v5gbds *= here->BSIM4v5nf;
                    here->BSIM4v5csub *= here->BSIM4v5nf;
                    
                    here->BSIM4v5Igidl *= here->BSIM4v5nf;
                    here->BSIM4v5ggidld *= here->BSIM4v5nf;
                    here->BSIM4v5ggidlg *= here->BSIM4v5nf;
                    here->BSIM4v5ggidlb *= here->BSIM4v5nf;
                    
                    here->BSIM4v5Igisl *= here->BSIM4v5nf;
                    here->BSIM4v5ggisls *= here->BSIM4v5nf;
                    here->BSIM4v5ggislg *= here->BSIM4v5nf;
                    here->BSIM4v5ggislb *= here->BSIM4v5nf;
                    
                    here->BSIM4v5Igcs *= here->BSIM4v5nf;
                    here->BSIM4v5gIgcsg *= here->BSIM4v5nf;
                    here->BSIM4v5gIgcsd *= here->BSIM4v5nf;
                    here->BSIM4v5gIgcsb *= here->BSIM4v5nf;
                    here->BSIM4v5Igcd *= here->BSIM4v5nf;
                    here->BSIM4v5gIgcdg *= here->BSIM4v5nf;
                    here->BSIM4v5gIgcdd *= here->BSIM4v5nf;
                    here->BSIM4v5gIgcdb *= here->BSIM4v5nf;
                    
                    here->BSIM4v5Igs *= here->BSIM4v5nf;
                    here->BSIM4v5gIgsg *= here->BSIM4v5nf;
                    here->BSIM4v5gIgss *= here->BSIM4v5nf;
                    here->BSIM4v5Igd *= here->BSIM4v5nf;
                    here->BSIM4v5gIgdg *= here->BSIM4v5nf;
                    here->BSIM4v5gIgdd *= here->BSIM4v5nf;
                    
                    here->BSIM4v5Igb *= here->BSIM4v5nf;
                    here->BSIM4v5gIgbg *= here->BSIM4v5nf;
                    here->BSIM4v5gIgbd *= here->BSIM4v5nf;
                    here->BSIM4v5gIgbb *= here->BSIM4v5nf;
                }
                
                here->BSIM4v5ggidls = -(here->BSIM4v5ggidld + here->BSIM4v5ggidlg
                + here->BSIM4v5ggidlb);
                here->BSIM4v5ggisld = -(here->BSIM4v5ggisls + here->BSIM4v5ggislg
                + here->BSIM4v5ggislb);
                here->BSIM4v5gIgbs = -(here->BSIM4v5gIgbg + here->BSIM4v5gIgbd
                + here->BSIM4v5gIgbb);
                here->BSIM4v5gIgcss = -(here->BSIM4v5gIgcsg + here->BSIM4v5gIgcsd
                + here->BSIM4v5gIgcsb);
                here->BSIM4v5gIgcds = -(here->BSIM4v5gIgcdg + here->BSIM4v5gIgcdd
                + here->BSIM4v5gIgcdb);
                here->BSIM4v5cd = cdrain;
                
                
                if (${::TECH($::type,$::corner,$::section,tnoiMod)} == 0)
                {   Abulk = Abulk0 * pParam->BSIM4v5abulkCVfactor;
                    Vdsat = Vgsteff / Abulk;
                    T0 = Vdsat - Vds - DELTA_4;
                    T1 = sqrt(T0 * T0 + 4.0 * DELTA_4 * Vdsat);
                    if (T0 >= 0.0)
                    Vdseff = Vdsat - 0.5 * (T0 + T1);
                    else
                    {   T3 = (DELTA_4 + DELTA_4) / (T1 - T0);
                        T4 = 1.0 - T3;
                        T5 = Vdsat * T3 / (T1 - T0);
                        Vdseff = Vdsat * T4;
                    }
                    if (Vds == 0.0)
                    Vdseff = 0.0;
                    
                    T0 = Abulk * Vdseff;
                    T1 = 12.0 * (Vgsteff - 0.5 * T0 + 1.0e-20);
                    T2 = Vdseff / T1;
                    T3 = T0 * T2;
                    here->BSIM4v5qinv = Coxeff * pParam->BSIM4v5weffCV * here->BSIM4v5nf
                    * pParam->BSIM4v5leffCV
                    * (Vgsteff - 0.5 * T0 + Abulk * T3);
                }
                
                /*
                *  BSIM4v5 C-V begins
                */
                
                if ((${::TECH($::type,$::corner,$::section,xpart)} < 0) || (!ChargeComputationNeeded))
                {   qgate  = qdrn = qsrc = qbulk = 0.0;
                    here->BSIM4v5cggb = here->BSIM4v5cgsb = here->BSIM4v5cgdb = 0.0;
                    here->BSIM4v5cdgb = here->BSIM4v5cdsb = here->BSIM4v5cddb = 0.0;
                    here->BSIM4v5cbgb = here->BSIM4v5cbsb = here->BSIM4v5cbdb = 0.0;
                    here->BSIM4v5csgb = here->BSIM4v5cssb = here->BSIM4v5csdb = 0.0;
                    here->BSIM4v5cgbb = here->BSIM4v5csbb = here->BSIM4v5cdbb = here->BSIM4v5cbbb = 0.0;
                    here->BSIM4v5cqdb = here->BSIM4v5cqsb = here->BSIM4v5cqgb 
                    = here->BSIM4v5cqbb = 0.0;
                    here->BSIM4v5gtau = 0.0;
                    goto finished_${::type}_${::corner}_${::section};
                }
                else if (${::TECH($::type,$::corner,$::section,capMod)} == 0)
                {
                    if (Vbseff < 0.0)
                    {   Vbseff = Vbs;
                        dVbseff_dVb = 1.0;
                    }
                    else
                    {   Vbseff = pParam->BSIM4v5phi - Phis;
                        dVbseff_dVb = -dPhis_dVb;
                    }
                    
                    Vfb = pParam->BSIM4v5vfbcv;
                    Vth = Vfb + pParam->BSIM4v5phi + pParam->BSIM4v5k1ox * sqrtPhis; 
                    Vgst = Vgs_eff - Vth;
                    dVth_dVb = pParam->BSIM4v5k1ox * dsqrtPhis_dVb; 
                    dVgst_dVb = -dVth_dVb;
                    dVgst_dVg = dVgs_eff_dVg; 
                    
                    CoxWL = ${::TECH($::type,$::corner,$::section,coxe)} * pParam->BSIM4v5weffCV
                    * pParam->BSIM4v5leffCV * here->BSIM4v5nf;
                    Arg1 = Vgs_eff - Vbseff - Vfb;
                    
                    if (Arg1 <= 0.0)
                    {   qgate = CoxWL * Arg1;
                        qbulk = -qgate;
                        qdrn = 0.0;
                        
                        here->BSIM4v5cggb = CoxWL * dVgs_eff_dVg;
                        here->BSIM4v5cgdb = 0.0;
                        here->BSIM4v5cgsb = CoxWL * (dVbseff_dVb - dVgs_eff_dVg);
                        
                        here->BSIM4v5cdgb = 0.0;
                        here->BSIM4v5cddb = 0.0;
                        here->BSIM4v5cdsb = 0.0;
                        
                        here->BSIM4v5cbgb = -CoxWL * dVgs_eff_dVg;
                        here->BSIM4v5cbdb = 0.0;
                        here->BSIM4v5cbsb = -here->BSIM4v5cgsb;
                    } /* Arg1 <= 0.0, end of accumulation */
                    else if (Vgst <= 0.0)
                    {   T1 = 0.5 * pParam->BSIM4v5k1ox;
                        T2 = sqrt(T1 * T1 + Arg1);
                        qgate = CoxWL * pParam->BSIM4v5k1ox * (T2 - T1);
                        qbulk = -qgate;
                        qdrn = 0.0;
                        
                        T0 = CoxWL * T1 / T2;
                        here->BSIM4v5cggb = T0 * dVgs_eff_dVg;
                        here->BSIM4v5cgdb = 0.0;
                        here->BSIM4v5cgsb = T0 * (dVbseff_dVb - dVgs_eff_dVg);
                        
                        here->BSIM4v5cdgb = 0.0;
                        here->BSIM4v5cddb = 0.0;
                        here->BSIM4v5cdsb = 0.0;
                        
                        here->BSIM4v5cbgb = -here->BSIM4v5cggb;
                        here->BSIM4v5cbdb = 0.0;
                        here->BSIM4v5cbsb = -here->BSIM4v5cgsb;
                    } /* Vgst <= 0.0, end of depletion */
                    else
                    {   One_Third_CoxWL = CoxWL / 3.0;
                        Two_Third_CoxWL = 2.0 * One_Third_CoxWL;
                        
                        AbulkCV = Abulk0 * pParam->BSIM4v5abulkCVfactor;
                        dAbulkCV_dVb = pParam->BSIM4v5abulkCVfactor * dAbulk0_dVb;
                        Vdsat = Vgst / AbulkCV;
                        dVdsat_dVg = dVgs_eff_dVg / AbulkCV;
                        dVdsat_dVb = - (Vdsat * dAbulkCV_dVb + dVth_dVb)/ AbulkCV; 
                        
                        if (${::TECH($::type,$::corner,$::section,xpart)} > 0.5)
                        {   /* 0/100 Charge partition model */
                            if (Vdsat <= Vds)
                            {   /* saturation region */
                                T1 = Vdsat / 3.0;
                                qgate = CoxWL * (Vgs_eff - Vfb
                                - pParam->BSIM4v5phi - T1);
                                T2 = -Two_Third_CoxWL * Vgst;
                                qbulk = -(qgate + T2);
                                qdrn = 0.0;
                                
                                here->BSIM4v5cggb = One_Third_CoxWL * (3.0
                                - dVdsat_dVg) * dVgs_eff_dVg;
                                T2 = -One_Third_CoxWL * dVdsat_dVb;
                                here->BSIM4v5cgsb = -(here->BSIM4v5cggb + T2);
                                here->BSIM4v5cgdb = 0.0;
                                
                                here->BSIM4v5cdgb = 0.0;
                                here->BSIM4v5cddb = 0.0;
                                here->BSIM4v5cdsb = 0.0;
                                
                                here->BSIM4v5cbgb = -(here->BSIM4v5cggb
                                - Two_Third_CoxWL * dVgs_eff_dVg);
                                T3 = -(T2 + Two_Third_CoxWL * dVth_dVb);
                                here->BSIM4v5cbsb = -(here->BSIM4v5cbgb + T3);
                                here->BSIM4v5cbdb = 0.0;
                            }
                            else
                            {   /* linear region */
                                Alphaz = Vgst / Vdsat;
                                T1 = 2.0 * Vdsat - Vds;
                                T2 = Vds / (3.0 * T1);
                                T3 = T2 * Vds;
                                T9 = 0.25 * CoxWL;
                                T4 = T9 * Alphaz;
                                T7 = 2.0 * Vds - T1 - 3.0 * T3;
                                T8 = T3 - T1 - 2.0 * Vds;
                                qgate = CoxWL * (Vgs_eff - Vfb 
                                - pParam->BSIM4v5phi - 0.5 * (Vds - T3));
                                T10 = T4 * T8;
                                qdrn = T4 * T7;
                                qbulk = -(qgate + qdrn + T10);
                                
                                T5 = T3 / T1;
                                here->BSIM4v5cggb = CoxWL * (1.0 - T5 * dVdsat_dVg)
                                * dVgs_eff_dVg;
                                T11 = -CoxWL * T5 * dVdsat_dVb;
                                here->BSIM4v5cgdb = CoxWL * (T2 - 0.5 + 0.5 * T5);
                                here->BSIM4v5cgsb = -(here->BSIM4v5cggb + T11
                                + here->BSIM4v5cgdb);
                                T6 = 1.0 / Vdsat;
                                dAlphaz_dVg = T6 * (1.0 - Alphaz * dVdsat_dVg);
                                dAlphaz_dVb = -T6 * (dVth_dVb + Alphaz * dVdsat_dVb);
                                T7 = T9 * T7;
                                T8 = T9 * T8;
                                T9 = 2.0 * T4 * (1.0 - 3.0 * T5);
                                here->BSIM4v5cdgb = (T7 * dAlphaz_dVg - T9
                                * dVdsat_dVg) * dVgs_eff_dVg;
                                T12 = T7 * dAlphaz_dVb - T9 * dVdsat_dVb;
                                here->BSIM4v5cddb = T4 * (3.0 - 6.0 * T2 - 3.0 * T5);
                                here->BSIM4v5cdsb = -(here->BSIM4v5cdgb + T12
                                + here->BSIM4v5cddb);
                                
                                T9 = 2.0 * T4 * (1.0 + T5);
                                T10 = (T8 * dAlphaz_dVg - T9 * dVdsat_dVg)
                                * dVgs_eff_dVg;
                                T11 = T8 * dAlphaz_dVb - T9 * dVdsat_dVb;
                                T12 = T4 * (2.0 * T2 + T5 - 1.0); 
                                T0 = -(T10 + T11 + T12);
                                
                                here->BSIM4v5cbgb = -(here->BSIM4v5cggb
                                + here->BSIM4v5cdgb + T10);
                                here->BSIM4v5cbdb = -(here->BSIM4v5cgdb 
                                + here->BSIM4v5cddb + T12);
                                here->BSIM4v5cbsb = -(here->BSIM4v5cgsb
                                + here->BSIM4v5cdsb + T0);
                            }
                        }
                        else if (${::TECH($::type,$::corner,$::section,xpart)} < 0.5)
                        {   /* 40/60 Charge partition model */
                            if (Vds >= Vdsat)
                            {   /* saturation region */
                                T1 = Vdsat / 3.0;
                                qgate = CoxWL * (Vgs_eff - Vfb
                                - pParam->BSIM4v5phi - T1);
                                T2 = -Two_Third_CoxWL * Vgst;
                                qbulk = -(qgate + T2);
                                qdrn = 0.4 * T2;
                                
                                here->BSIM4v5cggb = One_Third_CoxWL * (3.0 
                                - dVdsat_dVg) * dVgs_eff_dVg;
                                T2 = -One_Third_CoxWL * dVdsat_dVb;
                                here->BSIM4v5cgsb = -(here->BSIM4v5cggb + T2);
                                here->BSIM4v5cgdb = 0.0;
                                
                                T3 = 0.4 * Two_Third_CoxWL;
                                here->BSIM4v5cdgb = -T3 * dVgs_eff_dVg;
                                here->BSIM4v5cddb = 0.0;
                                T4 = T3 * dVth_dVb;
                                here->BSIM4v5cdsb = -(T4 + here->BSIM4v5cdgb);
                                
                                here->BSIM4v5cbgb = -(here->BSIM4v5cggb 
                                - Two_Third_CoxWL * dVgs_eff_dVg);
                                T3 = -(T2 + Two_Third_CoxWL * dVth_dVb);
                                here->BSIM4v5cbsb = -(here->BSIM4v5cbgb + T3);
                                here->BSIM4v5cbdb = 0.0;
                            }
                            else
                            {   /* linear region  */
                                Alphaz = Vgst / Vdsat;
                                T1 = 2.0 * Vdsat - Vds;
                                T2 = Vds / (3.0 * T1);
                                T3 = T2 * Vds;
                                T9 = 0.25 * CoxWL;
                                T4 = T9 * Alphaz;
                                qgate = CoxWL * (Vgs_eff - Vfb - pParam->BSIM4v5phi
                                - 0.5 * (Vds - T3));
                                
                                T5 = T3 / T1;
                                here->BSIM4v5cggb = CoxWL * (1.0 - T5 * dVdsat_dVg)
                                * dVgs_eff_dVg;
                                tmp = -CoxWL * T5 * dVdsat_dVb;
                                here->BSIM4v5cgdb = CoxWL * (T2 - 0.5 + 0.5 * T5);
                                here->BSIM4v5cgsb = -(here->BSIM4v5cggb 
                                + here->BSIM4v5cgdb + tmp);
                                
                                T6 = 1.0 / Vdsat;
                                dAlphaz_dVg = T6 * (1.0 - Alphaz * dVdsat_dVg);
                                dAlphaz_dVb = -T6 * (dVth_dVb + Alphaz * dVdsat_dVb);
                                
                                T6 = 8.0 * Vdsat * Vdsat - 6.0 * Vdsat * Vds
                                + 1.2 * Vds * Vds;
                                T8 = T2 / T1;
                                T7 = Vds - T1 - T8 * T6;
                                qdrn = T4 * T7;
                                T7 *= T9;
                                tmp = T8 / T1;
                                tmp1 = T4 * (2.0 - 4.0 * tmp * T6
                                + T8 * (16.0 * Vdsat - 6.0 * Vds));
                                
                                here->BSIM4v5cdgb = (T7 * dAlphaz_dVg - tmp1
                                * dVdsat_dVg) * dVgs_eff_dVg;
                                T10 = T7 * dAlphaz_dVb - tmp1 * dVdsat_dVb;
                                here->BSIM4v5cddb = T4 * (2.0 - (1.0 / (3.0 * T1
                                * T1) + 2.0 * tmp) * T6 + T8
                                * (6.0 * Vdsat - 2.4 * Vds));
                                here->BSIM4v5cdsb = -(here->BSIM4v5cdgb 
                                + T10 + here->BSIM4v5cddb);
                                
                                T7 = 2.0 * (T1 + T3);
                                qbulk = -(qgate - T4 * T7);
                                T7 *= T9;
                                T0 = 4.0 * T4 * (1.0 - T5);
                                T12 = (-T7 * dAlphaz_dVg - here->BSIM4v5cdgb
                                - T0 * dVdsat_dVg) * dVgs_eff_dVg;
                                T11 = -T7 * dAlphaz_dVb - T10 - T0 * dVdsat_dVb;
                                T10 = -4.0 * T4 * (T2 - 0.5 + 0.5 * T5) 
                                - here->BSIM4v5cddb;
                                tmp = -(T10 + T11 + T12);
                                
                                here->BSIM4v5cbgb = -(here->BSIM4v5cggb 
                                + here->BSIM4v5cdgb + T12);
                                here->BSIM4v5cbdb = -(here->BSIM4v5cgdb
                                + here->BSIM4v5cddb + T10);  
                                here->BSIM4v5cbsb = -(here->BSIM4v5cgsb
                                + here->BSIM4v5cdsb + tmp);
                            }
                        }
                        else
                        {   /* 50/50 partitioning */
                            if (Vds >= Vdsat)
                            {   /* saturation region */
                                T1 = Vdsat / 3.0;
                                qgate = CoxWL * (Vgs_eff - Vfb
                                - pParam->BSIM4v5phi - T1);
                                T2 = -Two_Third_CoxWL * Vgst;
                                qbulk = -(qgate + T2);
                                qdrn = 0.5 * T2;
                                
                                here->BSIM4v5cggb = One_Third_CoxWL * (3.0
                                - dVdsat_dVg) * dVgs_eff_dVg;
                                T2 = -One_Third_CoxWL * dVdsat_dVb;
                                here->BSIM4v5cgsb = -(here->BSIM4v5cggb + T2);
                                here->BSIM4v5cgdb = 0.0;
                                
                                here->BSIM4v5cdgb = -One_Third_CoxWL * dVgs_eff_dVg;
                                here->BSIM4v5cddb = 0.0;
                                T4 = One_Third_CoxWL * dVth_dVb;
                                here->BSIM4v5cdsb = -(T4 + here->BSIM4v5cdgb);
                                
                                here->BSIM4v5cbgb = -(here->BSIM4v5cggb 
                                - Two_Third_CoxWL * dVgs_eff_dVg);
                                T3 = -(T2 + Two_Third_CoxWL * dVth_dVb);
                                here->BSIM4v5cbsb = -(here->BSIM4v5cbgb + T3);
                                here->BSIM4v5cbdb = 0.0;
                            }
                            else
                            {   /* linear region */
                                Alphaz = Vgst / Vdsat;
                                T1 = 2.0 * Vdsat - Vds;
                                T2 = Vds / (3.0 * T1);
                                T3 = T2 * Vds;
                                T9 = 0.25 * CoxWL;
                                T4 = T9 * Alphaz;
                                qgate = CoxWL * (Vgs_eff - Vfb - pParam->BSIM4v5phi
                                - 0.5 * (Vds - T3));
                                
                                T5 = T3 / T1;
                                here->BSIM4v5cggb = CoxWL * (1.0 - T5 * dVdsat_dVg)
                                * dVgs_eff_dVg;
                                tmp = -CoxWL * T5 * dVdsat_dVb;
                                here->BSIM4v5cgdb = CoxWL * (T2 - 0.5 + 0.5 * T5);
                                here->BSIM4v5cgsb = -(here->BSIM4v5cggb 
                                + here->BSIM4v5cgdb + tmp);
                                
                                T6 = 1.0 / Vdsat;
                                dAlphaz_dVg = T6 * (1.0 - Alphaz * dVdsat_dVg);
                                dAlphaz_dVb = -T6 * (dVth_dVb + Alphaz * dVdsat_dVb);
                                
                                T7 = T1 + T3;
                                qdrn = -T4 * T7;
                                qbulk = - (qgate + qdrn + qdrn);
                                T7 *= T9;
                                T0 = T4 * (2.0 * T5 - 2.0);
                                
                                here->BSIM4v5cdgb = (T0 * dVdsat_dVg - T7
                                * dAlphaz_dVg) * dVgs_eff_dVg;
                                T12 = T0 * dVdsat_dVb - T7 * dAlphaz_dVb;
                                here->BSIM4v5cddb = T4 * (1.0 - 2.0 * T2 - T5);
                                here->BSIM4v5cdsb = -(here->BSIM4v5cdgb + T12
                                + here->BSIM4v5cddb);
                                
                                here->BSIM4v5cbgb = -(here->BSIM4v5cggb
                                + 2.0 * here->BSIM4v5cdgb);
                                here->BSIM4v5cbdb = -(here->BSIM4v5cgdb
                                + 2.0 * here->BSIM4v5cddb);
                                here->BSIM4v5cbsb = -(here->BSIM4v5cgsb
                                + 2.0 * here->BSIM4v5cdsb);
                            } /* end of linear region */
                        } /* end of 50/50 partition */
                    } /* end of inversion */
                } /* end of capMod=0 */ 
                else
                {   if (Vbseff < 0.0)
                    {   VbseffCV = Vbseff;
                        dVbseffCV_dVb = 1.0;
                    }
                    else
                    {   VbseffCV = pParam->BSIM4v5phi - Phis;
                        dVbseffCV_dVb = -dPhis_dVb;
                    }
                    
                    CoxWL = ${::TECH($::type,$::corner,$::section,coxe)} * pParam->BSIM4v5weffCV
                    * pParam->BSIM4v5leffCV * here->BSIM4v5nf;
                    
                    /* Seperate VgsteffCV with noff and voffcv */
                    noff = n * pParam->BSIM4v5noff;
                    dnoff_dVd = pParam->BSIM4v5noff * dn_dVd;
                    dnoff_dVb = pParam->BSIM4v5noff * dn_dVb;
                    T0 = Vtm * noff;
                    voffcv = pParam->BSIM4v5voffcv;
                    VgstNVt = (Vgst - voffcv) / T0;
                    
                    if (VgstNVt > EXP_THRESHOLD)
                    {   Vgsteff = Vgst - voffcv;
                        dVgsteff_dVg = dVgs_eff_dVg;
                        dVgsteff_dVd = -dVth_dVd;
                        dVgsteff_dVb = -dVth_dVb;
                    }
                    else if (VgstNVt < -EXP_THRESHOLD)
                    {   Vgsteff = T0 * log(1.0 + MIN_EXP);
                        dVgsteff_dVg = 0.0;
                        dVgsteff_dVd = Vgsteff / noff;
                        dVgsteff_dVb = dVgsteff_dVd * dnoff_dVb;
                        dVgsteff_dVd *= dnoff_dVd;
                    }
                    else
                    {   ExpVgst = exp(VgstNVt);
                        Vgsteff = T0 * log(1.0 + ExpVgst);
                        dVgsteff_dVg = ExpVgst / (1.0 + ExpVgst);
                        dVgsteff_dVd = -dVgsteff_dVg * (dVth_dVd + (Vgst - voffcv)
                        / noff * dnoff_dVd) + Vgsteff / noff * dnoff_dVd;
                        dVgsteff_dVb = -dVgsteff_dVg * (dVth_dVb + (Vgst - voffcv)
                        / noff * dnoff_dVb) + Vgsteff / noff * dnoff_dVb;
                        dVgsteff_dVg *= dVgs_eff_dVg;
                    } /* End of VgsteffCV */
                    
                    
                    if (${::TECH($::type,$::corner,$::section,capMod)} == 1)
                    {   Vfb = here->BSIM4v5vfbzb;
                        V3 = Vfb - Vgs_eff + VbseffCV - DELTA_3;
                        if (Vfb <= 0.0)
                        T0 = sqrt(V3 * V3 - 4.0 * DELTA_3 * Vfb);
                        else
                        T0 = sqrt(V3 * V3 + 4.0 * DELTA_3 * Vfb);
                        
                        T1 = 0.5 * (1.0 + V3 / T0);
                        Vfbeff = Vfb - 0.5 * (V3 + T0);
                        dVfbeff_dVg = T1 * dVgs_eff_dVg;
                        dVfbeff_dVb = -T1 * dVbseffCV_dVb;
                        Qac0 = CoxWL * (Vfbeff - Vfb);
                        dQac0_dVg = CoxWL * dVfbeff_dVg;
                        dQac0_dVb = CoxWL * dVfbeff_dVb;
                        
                        T0 = 0.5 * pParam->BSIM4v5k1ox;
                        T3 = Vgs_eff - Vfbeff - VbseffCV - Vgsteff;
                        if (pParam->BSIM4v5k1ox == 0.0)
                        {   T1 = 0.0;
                            T2 = 0.0;
                        }
                        else if (T3 < 0.0)
                        {   T1 = T0 + T3 / pParam->BSIM4v5k1ox;
                            T2 = CoxWL;
                        }
                        else
                        {   T1 = sqrt(T0 * T0 + T3);
                            T2 = CoxWL * T0 / T1;
                        }
                        
                        Qsub0 = CoxWL * pParam->BSIM4v5k1ox * (T1 - T0);
                        
                        dQsub0_dVg = T2 * (dVgs_eff_dVg - dVfbeff_dVg - dVgsteff_dVg);
                        dQsub0_dVd = -T2 * dVgsteff_dVd;
                        dQsub0_dVb = -T2 * (dVfbeff_dVb + dVbseffCV_dVb 
                        + dVgsteff_dVb);
                        
                        AbulkCV = Abulk0 * pParam->BSIM4v5abulkCVfactor;
                        dAbulkCV_dVb = pParam->BSIM4v5abulkCVfactor * dAbulk0_dVb;
                        VdsatCV = Vgsteff / AbulkCV;
                        
                        T0 = VdsatCV - Vds - DELTA_4;
                        dT0_dVg = 1.0 / AbulkCV;
                        dT0_dVb = -VdsatCV * dAbulkCV_dVb / AbulkCV; 
                        T1 = sqrt(T0 * T0 + 4.0 * DELTA_4 * VdsatCV);
                        dT1_dVg = (T0 + DELTA_4 + DELTA_4) / T1;
                        dT1_dVd = -T0 / T1;
                        dT1_dVb = dT1_dVg * dT0_dVb;
                        dT1_dVg *= dT0_dVg;
                        if (T0 >= 0.0)
                        {   VdseffCV = VdsatCV - 0.5 * (T0 + T1);
                            dVdseffCV_dVg = 0.5 * (dT0_dVg - dT1_dVg);
                            dVdseffCV_dVd = 0.5 * (1.0 - dT1_dVd);
                            dVdseffCV_dVb = 0.5 * (dT0_dVb - dT1_dVb);
                        }
                        else
                        {   T3 = (DELTA_4 + DELTA_4) / (T1 - T0);
                            T4 = 1.0 - T3;
                            T5 = VdsatCV * T3 / (T1 - T0);
                            VdseffCV = VdsatCV * T4;
                            dVdseffCV_dVg = dT0_dVg * T4 + T5 * (dT1_dVg - dT0_dVg);
                            dVdseffCV_dVd = T5 * (dT1_dVd + 1.0);
                            dVdseffCV_dVb = dT0_dVb * (1.0 - T5) + T5 * dT1_dVb;
                        }
                        
                        if (Vds == 0.0)
                        {  VdseffCV = 0.0;
                            dVdseffCV_dVg = 0.0;
                            dVdseffCV_dVb = 0.0;
                        }
                        
                        T0 = AbulkCV * VdseffCV;
                        T1 = 12.0 * (Vgsteff - 0.5 * T0 + 1.0e-20);
                        T2 = VdseffCV / T1;
                        T3 = T0 * T2;
                        
                        T4 = (1.0 - 12.0 * T2 * T2 * AbulkCV);
                        T5 = (6.0 * T0 * (4.0 * Vgsteff - T0) / (T1 * T1) - 0.5);
                        T6 = 12.0 * T2 * T2 * Vgsteff;
                        
                        qgate = CoxWL * (Vgsteff - 0.5 * VdseffCV + T3);
                        Cgg1 = CoxWL * (T4 + T5 * dVdseffCV_dVg);
                        Cgd1 = CoxWL * T5 * dVdseffCV_dVd + Cgg1 * dVgsteff_dVd;
                        Cgb1 = CoxWL * (T5 * dVdseffCV_dVb + T6 * dAbulkCV_dVb)
                        + Cgg1 * dVgsteff_dVb;
                        Cgg1 *= dVgsteff_dVg;
                        
                        T7 = 1.0 - AbulkCV;
                        qbulk = CoxWL * T7 * (0.5 * VdseffCV - T3);
                        T4 = -T7 * (T4 - 1.0);
                        T5 = -T7 * T5;
                        T6 = -(T7 * T6 + (0.5 * VdseffCV - T3));
                        Cbg1 = CoxWL * (T4 + T5 * dVdseffCV_dVg);
                        Cbd1 = CoxWL * T5 * dVdseffCV_dVd + Cbg1 * dVgsteff_dVd;
                        Cbb1 = CoxWL * (T5 * dVdseffCV_dVb + T6 * dAbulkCV_dVb)
                        + Cbg1 * dVgsteff_dVb;
                        Cbg1 *= dVgsteff_dVg;
                        
                        if (${::TECH($::type,$::corner,$::section,xpart)} > 0.5)
                        {   /* 0/100 Charge petition model */
                            T1 = T1 + T1;
                            qsrc = -CoxWL * (0.5 * Vgsteff + 0.25 * T0
                            - T0 * T0 / T1);
                            T7 = (4.0 * Vgsteff - T0) / (T1 * T1);
                            T4 = -(0.5 + 24.0 * T0 * T0 / (T1 * T1));
                            T5 = -(0.25 * AbulkCV - 12.0 * AbulkCV * T0 * T7);
                            T6 = -(0.25 * VdseffCV - 12.0 * T0 * VdseffCV * T7);
                            Csg = CoxWL * (T4 + T5 * dVdseffCV_dVg);
                            Csd = CoxWL * T5 * dVdseffCV_dVd + Csg * dVgsteff_dVd;
                            Csb = CoxWL * (T5 * dVdseffCV_dVb + T6 * dAbulkCV_dVb)
                            + Csg * dVgsteff_dVb;
                            Csg *= dVgsteff_dVg;
                        }
                        else if (${::TECH($::type,$::corner,$::section,xpart)} < 0.5)
                        {   /* 40/60 Charge petition model */
                            T1 = T1 / 12.0;
                            T2 = 0.5 * CoxWL / (T1 * T1);
                            T3 = Vgsteff * (2.0 * T0 * T0 / 3.0 + Vgsteff
                            * (Vgsteff - 4.0 * T0 / 3.0))
                            - 2.0 * T0 * T0 * T0 / 15.0;
                            qsrc = -T2 * T3;
                            T7 = 4.0 / 3.0 * Vgsteff * (Vgsteff - T0)
                            + 0.4 * T0 * T0;
                            T4 = -2.0 * qsrc / T1 - T2 * (Vgsteff * (3.0
                            * Vgsteff - 8.0 * T0 / 3.0)
                            + 2.0 * T0 * T0 / 3.0);
                            T5 = (qsrc / T1 + T2 * T7) * AbulkCV;
                            T6 = (qsrc / T1 * VdseffCV + T2 * T7 * VdseffCV);
                            Csg = (T4 + T5 * dVdseffCV_dVg);
                            Csd = T5 * dVdseffCV_dVd + Csg * dVgsteff_dVd;
                            Csb = (T5 * dVdseffCV_dVb + T6 * dAbulkCV_dVb)
                            + Csg * dVgsteff_dVb;
                            Csg *= dVgsteff_dVg;
                        }
                        else
                        {   /* 50/50 Charge petition model */
                            qsrc = -0.5 * (qgate + qbulk);
                            Csg = -0.5 * (Cgg1 + Cbg1);
                            Csb = -0.5 * (Cgb1 + Cbb1); 
                            Csd = -0.5 * (Cgd1 + Cbd1); 
                        }
                        
                        qgate += Qac0 + Qsub0;
                        qbulk -= (Qac0 + Qsub0);
                        qdrn = -(qgate + qbulk + qsrc);
                        
                        Cgg = dQac0_dVg + dQsub0_dVg + Cgg1;
                        Cgd = dQsub0_dVd + Cgd1;
                        Cgb = dQac0_dVb + dQsub0_dVb + Cgb1;
                        
                        Cbg = Cbg1 - dQac0_dVg - dQsub0_dVg;
                        Cbd = Cbd1 - dQsub0_dVd;
                        Cbb = Cbb1 - dQac0_dVb - dQsub0_dVb;
                        
                        Cgb *= dVbseff_dVb;
                        Cbb *= dVbseff_dVb;
                        Csb *= dVbseff_dVb;
                        
                        here->BSIM4v5cggb = Cgg;
                        here->BSIM4v5cgsb = -(Cgg + Cgd + Cgb);
                        here->BSIM4v5cgdb = Cgd;
                        here->BSIM4v5cdgb = -(Cgg + Cbg + Csg);
                        here->BSIM4v5cdsb = (Cgg + Cgd + Cgb + Cbg + Cbd + Cbb
                        + Csg + Csd + Csb);
                        here->BSIM4v5cddb = -(Cgd + Cbd + Csd);
                        here->BSIM4v5cbgb = Cbg;
                        here->BSIM4v5cbsb = -(Cbg + Cbd + Cbb);
                        here->BSIM4v5cbdb = Cbd;
                    } 
                    
                    /* Charge-Thickness capMod (CTM) begins */
                    else if (${::TECH($::type,$::corner,$::section,capMod)} == 2)
                    {   V3 = here->BSIM4v5vfbzb - Vgs_eff + VbseffCV - DELTA_3;
                        if (here->BSIM4v5vfbzb <= 0.0)
                        T0 = sqrt(V3 * V3 - 4.0 * DELTA_3 * here->BSIM4v5vfbzb);
                        else
                        T0 = sqrt(V3 * V3 + 4.0 * DELTA_3 * here->BSIM4v5vfbzb);
                        
                        T1 = 0.5 * (1.0 + V3 / T0);
                        Vfbeff = here->BSIM4v5vfbzb - 0.5 * (V3 + T0);
                        dVfbeff_dVg = T1 * dVgs_eff_dVg;
                        dVfbeff_dVb = -T1 * dVbseffCV_dVb;
                        
                        Cox = ${::TECH($::type,$::corner,$::section,coxp)};
                        Tox = 1.0e8 * ${::TECH($::type,$::corner,$::section,toxp)};
                        T0 = (Vgs_eff - VbseffCV - here->BSIM4v5vfbzb) / Tox;
                        dT0_dVg = dVgs_eff_dVg / Tox;
                        dT0_dVb = -dVbseffCV_dVb / Tox;
                        
                        tmp = T0 * pParam->BSIM4v5acde;
                        if ((-EXP_THRESHOLD < tmp) && (tmp < EXP_THRESHOLD))
                        {   Tcen = pParam->BSIM4v5ldeb * exp(tmp);
                            dTcen_dVg = pParam->BSIM4v5acde * Tcen;
                            dTcen_dVb = dTcen_dVg * dT0_dVb;
                            dTcen_dVg *= dT0_dVg;
                        }
                        else if (tmp <= -EXP_THRESHOLD)
                        {   Tcen = pParam->BSIM4v5ldeb * MIN_EXP;
                            dTcen_dVg = dTcen_dVb = 0.0;
                        }
                        else
                        {   Tcen = pParam->BSIM4v5ldeb * MAX_EXP;
                            dTcen_dVg = dTcen_dVb = 0.0;
                        }
                        
                        LINK = 1.0e-3 * ${::TECH($::type,$::corner,$::section,toxp)};
                        V3 = pParam->BSIM4v5ldeb - Tcen - LINK;
                        V4 = sqrt(V3 * V3 + 4.0 * LINK * pParam->BSIM4v5ldeb);
                        Tcen = pParam->BSIM4v5ldeb - 0.5 * (V3 + V4);
                        T1 = 0.5 * (1.0 + V3 / V4);
                        dTcen_dVg *= T1;
                        dTcen_dVb *= T1;
                        
                        Ccen = EPSSI / Tcen;
                        T2 = Cox / (Cox + Ccen);
                        Coxeff = T2 * Ccen;
                        T3 = -Ccen / Tcen;
                        dCoxeff_dVg = T2 * T2 * T3;
                        dCoxeff_dVb = dCoxeff_dVg * dTcen_dVb;
                        dCoxeff_dVg *= dTcen_dVg;
                        CoxWLcen = CoxWL * Coxeff / ${::TECH($::type,$::corner,$::section,coxe)};
                        
                        Qac0 = CoxWLcen * (Vfbeff - here->BSIM4v5vfbzb);
                        QovCox = Qac0 / Coxeff;
                        dQac0_dVg = CoxWLcen * dVfbeff_dVg
                        + QovCox * dCoxeff_dVg;
                        dQac0_dVb = CoxWLcen * dVfbeff_dVb 
                        + QovCox * dCoxeff_dVb;
                        
                        T0 = 0.5 * pParam->BSIM4v5k1ox;
                        T3 = Vgs_eff - Vfbeff - VbseffCV - Vgsteff;
                        if (pParam->BSIM4v5k1ox == 0.0)
                        {   T1 = 0.0;
                            T2 = 0.0;
                        }
                        else if (T3 < 0.0)
                        {   T1 = T0 + T3 / pParam->BSIM4v5k1ox;
                            T2 = CoxWLcen;
                        }
                        else
                        {   T1 = sqrt(T0 * T0 + T3);
                            T2 = CoxWLcen * T0 / T1;
                        }
                        
                        Qsub0 = CoxWLcen * pParam->BSIM4v5k1ox * (T1 - T0);
                        QovCox = Qsub0 / Coxeff;
                        dQsub0_dVg = T2 * (dVgs_eff_dVg - dVfbeff_dVg - dVgsteff_dVg)
                        + QovCox * dCoxeff_dVg;
                        dQsub0_dVd = -T2 * dVgsteff_dVd;
                        dQsub0_dVb = -T2 * (dVfbeff_dVb + dVbseffCV_dVb + dVgsteff_dVb)
                        + QovCox * dCoxeff_dVb;
                        
                        /* Gate-bias dependent delta Phis begins */
                        if (pParam->BSIM4v5k1ox <= 0.0)
                        {   Denomi = 0.25 * pParam->BSIM4v5moin * Vtm;
                            T0 = 0.5 * pParam->BSIM4v5sqrtPhi;
                        }
                        else
                        {   Denomi = pParam->BSIM4v5moin * Vtm 
                            * pParam->BSIM4v5k1ox * pParam->BSIM4v5k1ox;
                            T0 = pParam->BSIM4v5k1ox * pParam->BSIM4v5sqrtPhi;
                        }
                        T1 = 2.0 * T0 + Vgsteff;
                        
                        DeltaPhi = Vtm * log(1.0 + T1 * Vgsteff / Denomi);
                        dDeltaPhi_dVg = 2.0 * Vtm * (T1 -T0) / (Denomi + T1 * Vgsteff);
                        /* End of delta Phis */
                        
                        /* VgDP = Vgsteff - DeltaPhi */
                        T0 = Vgsteff - DeltaPhi - 0.001;
                        dT0_dVg = 1.0 - dDeltaPhi_dVg;
                        T1 = sqrt(T0 * T0 + Vgsteff * 0.004);
                        VgDP = 0.5 * (T0 + T1);
                        dVgDP_dVg = 0.5 * (dT0_dVg + (T0 * dT0_dVg + 0.002) / T1);                  
                        
                        Tox += Tox; /* WDLiu: Tcen reevaluated below due to different Vgsteff */
                        T0 = (Vgsteff + here->BSIM4v5vtfbphi2) / Tox;
                        tmp = exp(0.7 * log(T0));
                        T1 = 1.0 + tmp;
                        T2 = 0.7 * tmp / (T0 * Tox);
                        Tcen = 1.9e-9 / T1;
                        dTcen_dVg = -Tcen * T2 / T1;
                        dTcen_dVd = dTcen_dVg * dVgsteff_dVd;
                        dTcen_dVb = dTcen_dVg * dVgsteff_dVb;
                        dTcen_dVg *= dVgsteff_dVg;
                        
                        Ccen = EPSSI / Tcen;
                        T0 = Cox / (Cox + Ccen);
                        Coxeff = T0 * Ccen;
                        T1 = -Ccen / Tcen;
                        dCoxeff_dVg = T0 * T0 * T1;
                        dCoxeff_dVd = dCoxeff_dVg * dTcen_dVd;
                        dCoxeff_dVb = dCoxeff_dVg * dTcen_dVb;
                        dCoxeff_dVg *= dTcen_dVg;
                        CoxWLcen = CoxWL * Coxeff / ${::TECH($::type,$::corner,$::section,coxe)};
                        
                        AbulkCV = Abulk0 * pParam->BSIM4v5abulkCVfactor;
                        dAbulkCV_dVb = pParam->BSIM4v5abulkCVfactor * dAbulk0_dVb;
                        VdsatCV = VgDP / AbulkCV;
                        
                        T0 = VdsatCV - Vds - DELTA_4;
                        dT0_dVg = dVgDP_dVg / AbulkCV;
                        dT0_dVb = -VdsatCV * dAbulkCV_dVb / AbulkCV;
                        T1 = sqrt(T0 * T0 + 4.0 * DELTA_4 * VdsatCV);
                        dT1_dVg = (T0 + DELTA_4 + DELTA_4) / T1;
                        dT1_dVd = -T0 / T1;
                        dT1_dVb = dT1_dVg * dT0_dVb;
                        dT1_dVg *= dT0_dVg;
                        if (T0 >= 0.0)
                        {   VdseffCV = VdsatCV - 0.5 * (T0 + T1);
                            dVdseffCV_dVg = 0.5 * (dT0_dVg - dT1_dVg);
                            dVdseffCV_dVd = 0.5 * (1.0 - dT1_dVd);
                            dVdseffCV_dVb = 0.5 * (dT0_dVb - dT1_dVb);
                        }
                        else
                        {   T3 = (DELTA_4 + DELTA_4) / (T1 - T0);
                            T4 = 1.0 - T3;
                            T5 = VdsatCV * T3 / (T1 - T0);
                            VdseffCV = VdsatCV * T4;
                            dVdseffCV_dVg = dT0_dVg * T4 + T5 * (dT1_dVg - dT0_dVg);
                            dVdseffCV_dVd = T5 * (dT1_dVd + 1.0);
                            dVdseffCV_dVb = dT0_dVb * (1.0 - T5) + T5 * dT1_dVb;
                        }
                        
                        if (Vds == 0.0)
                        {  VdseffCV = 0.0;
                            dVdseffCV_dVg = 0.0;
                            dVdseffCV_dVb = 0.0;
                        }
                        
                        T0 = AbulkCV * VdseffCV;
                        T1 = VgDP;
                        T2 = 12.0 * (T1 - 0.5 * T0 + 1.0e-20);
                        T3 = T0 / T2;
                        T4 = 1.0 - 12.0 * T3 * T3;
                        T5 = AbulkCV * (6.0 * T0 * (4.0 * T1 - T0) / (T2 * T2) - 0.5);
                        T6 = T5 * VdseffCV / AbulkCV;
                        
                        qgate = CoxWLcen * (T1 - T0 * (0.5 - T3));
                        QovCox = qgate / Coxeff;
                        Cgg1 = CoxWLcen * (T4 * dVgDP_dVg 
                        + T5 * dVdseffCV_dVg);
                        Cgd1 = CoxWLcen * T5 * dVdseffCV_dVd + Cgg1 
                        * dVgsteff_dVd + QovCox * dCoxeff_dVd;
                        Cgb1 = CoxWLcen * (T5 * dVdseffCV_dVb + T6 * dAbulkCV_dVb) 
                        + Cgg1 * dVgsteff_dVb + QovCox * dCoxeff_dVb;
                        Cgg1 = Cgg1 * dVgsteff_dVg + QovCox * dCoxeff_dVg;
                        
                        
                        T7 = 1.0 - AbulkCV;
                        T8 = T2 * T2;
                        T9 = 12.0 * T7 * T0 * T0 / (T8 * AbulkCV);
                        T10 = T9 * dVgDP_dVg;
                        T11 = -T7 * T5 / AbulkCV;
                        T12 = -(T9 * T1 / AbulkCV + VdseffCV * (0.5 - T0 / T2));
                        
                        qbulk = CoxWLcen * T7 * (0.5 * VdseffCV - T0 * VdseffCV / T2);
                        QovCox = qbulk / Coxeff;
                        Cbg1 = CoxWLcen * (T10 + T11 * dVdseffCV_dVg);
                        Cbd1 = CoxWLcen * T11 * dVdseffCV_dVd + Cbg1
                        * dVgsteff_dVd + QovCox * dCoxeff_dVd; 
                        Cbb1 = CoxWLcen * (T11 * dVdseffCV_dVb + T12 * dAbulkCV_dVb)
                        + Cbg1 * dVgsteff_dVb + QovCox * dCoxeff_dVb;
                        Cbg1 = Cbg1 * dVgsteff_dVg + QovCox * dCoxeff_dVg;
                        
                        if (${::TECH($::type,$::corner,$::section,xpart)} > 0.5)
                        {   /* 0/100 partition */
                            qsrc = -CoxWLcen * (T1 / 2.0 + T0 / 4.0 
                            - 0.5 * T0 * T0 / T2);
                            QovCox = qsrc / Coxeff;
                            T2 += T2;
                            T3 = T2 * T2;
                            T7 = -(0.25 - 12.0 * T0 * (4.0 * T1 - T0) / T3);
                            T4 = -(0.5 + 24.0 * T0 * T0 / T3) * dVgDP_dVg;
                            T5 = T7 * AbulkCV;
                            T6 = T7 * VdseffCV;
                            
                            Csg = CoxWLcen * (T4 + T5 * dVdseffCV_dVg);
                            Csd = CoxWLcen * T5 * dVdseffCV_dVd + Csg * dVgsteff_dVd
                            + QovCox * dCoxeff_dVd;
                            Csb = CoxWLcen * (T5 * dVdseffCV_dVb + T6 * dAbulkCV_dVb)
                            + Csg * dVgsteff_dVb + QovCox * dCoxeff_dVb;
                            Csg = Csg * dVgsteff_dVg + QovCox * dCoxeff_dVg;
                        }
                        else if (${::TECH($::type,$::corner,$::section,xpart)} < 0.5)
                        {   /* 40/60 partition */
                            T2 = T2 / 12.0;
                            T3 = 0.5 * CoxWLcen / (T2 * T2);
                            T4 = T1 * (2.0 * T0 * T0 / 3.0 + T1 * (T1 - 4.0 
                            * T0 / 3.0)) - 2.0 * T0 * T0 * T0 / 15.0;
                            qsrc = -T3 * T4;
                            QovCox = qsrc / Coxeff;
                            T8 = 4.0 / 3.0 * T1 * (T1 - T0) + 0.4 * T0 * T0;
                            T5 = -2.0 * qsrc / T2 - T3 * (T1 * (3.0 * T1 - 8.0 
                            * T0 / 3.0) + 2.0 * T0 * T0 / 3.0);
                            T6 = AbulkCV * (qsrc / T2 + T3 * T8);
                            T7 = T6 * VdseffCV / AbulkCV; 
                            
                            Csg = T5 * dVgDP_dVg + T6 * dVdseffCV_dVg; 
                            Csd = Csg * dVgsteff_dVd + T6 * dVdseffCV_dVd 
                            + QovCox * dCoxeff_dVd;
                            Csb = Csg * dVgsteff_dVb + T6 * dVdseffCV_dVb 
                            + T7 * dAbulkCV_dVb + QovCox * dCoxeff_dVb; 
                            Csg = Csg * dVgsteff_dVg + QovCox * dCoxeff_dVg;
                        }
                        else
                        {   /* 50/50 partition */
                            qsrc = -0.5 * qgate;
                            Csg = -0.5 * Cgg1;
                            Csd = -0.5 * Cgd1; 
                            Csb = -0.5 * Cgb1; 
                        }
                        
                        qgate += Qac0 + Qsub0 - qbulk;
                        qbulk -= (Qac0 + Qsub0);
                        qdrn = -(qgate + qbulk + qsrc);
                        
                        Cbg = Cbg1 - dQac0_dVg - dQsub0_dVg;
                        Cbd = Cbd1 - dQsub0_dVd;
                        Cbb = Cbb1 - dQac0_dVb - dQsub0_dVb;
                        
                        Cgg = Cgg1 - Cbg;
                        Cgd = Cgd1 - Cbd;
                        Cgb = Cgb1 - Cbb;
                        
                        Cgb *= dVbseff_dVb;
                        Cbb *= dVbseff_dVb;
                        Csb *= dVbseff_dVb;
                        
                        here->BSIM4v5cggb = Cgg;
                        here->BSIM4v5cgsb = -(Cgg + Cgd + Cgb);
                        here->BSIM4v5cgdb = Cgd;
                        here->BSIM4v5cdgb = -(Cgg + Cbg + Csg);
                        here->BSIM4v5cdsb = (Cgg + Cgd + Cgb + Cbg + Cbd + Cbb
                        + Csg + Csd + Csb);
                        here->BSIM4v5cddb = -(Cgd + Cbd + Csd);
                        here->BSIM4v5cbgb = Cbg;
                        here->BSIM4v5cbsb = -(Cbg + Cbd + Cbb);
                        here->BSIM4v5cbdb = Cbd;
                    }  /* End of CTM */
                }
                
                here->BSIM4v5csgb = - here->BSIM4v5cggb - here->BSIM4v5cdgb - here->BSIM4v5cbgb;
                here->BSIM4v5csdb = - here->BSIM4v5cgdb - here->BSIM4v5cddb - here->BSIM4v5cbdb;
                here->BSIM4v5cssb = - here->BSIM4v5cgsb - here->BSIM4v5cdsb - here->BSIM4v5cbsb;
                here->BSIM4v5cgbb = - here->BSIM4v5cgdb - here->BSIM4v5cggb - here->BSIM4v5cgsb;
                here->BSIM4v5cdbb = - here->BSIM4v5cddb - here->BSIM4v5cdgb - here->BSIM4v5cdsb;
                here->BSIM4v5cbbb = - here->BSIM4v5cbgb - here->BSIM4v5cbdb - here->BSIM4v5cbsb;
                here->BSIM4v5csbb = - here->BSIM4v5cgbb - here->BSIM4v5cdbb - here->BSIM4v5cbbb;
                here->BSIM4v5qgate = qgate;
                here->BSIM4v5qbulk = qbulk;
                here->BSIM4v5qdrn = qdrn;
                here->BSIM4v5qsrc = -(qgate + qbulk + qdrn);
                
                /* NQS begins */
                if ((here->BSIM4v5trnqsMod) || (here->BSIM4v5acnqsMod))
                {   here->BSIM4v5qchqs = qcheq = -(qbulk + qgate);
                    here->BSIM4v5cqgb = -(here->BSIM4v5cggb + here->BSIM4v5cbgb);
                    here->BSIM4v5cqdb = -(here->BSIM4v5cgdb + here->BSIM4v5cbdb);
                    here->BSIM4v5cqsb = -(here->BSIM4v5cgsb + here->BSIM4v5cbsb);
                    here->BSIM4v5cqbb = -(here->BSIM4v5cqgb + here->BSIM4v5cqdb
                    + here->BSIM4v5cqsb);
                    
                    CoxWL = ${::TECH($::type,$::corner,$::section,coxe)} * pParam->BSIM4v5weffCV * here->BSIM4v5nf
                    * pParam->BSIM4v5leffCV;
                    T1 = here->BSIM4v5gcrg / CoxWL; /* 1 / tau */
                    here->BSIM4v5gtau = T1 * $ScalingFactor;
                    
                    if (here->BSIM4v5acnqsMod)
                    here->BSIM4v5taunet = 1.0 / T1;
                    
                    *(cktState0 + here->BSIM4v5qcheq) = qcheq;
                    if (Mode & MODEINITTRAN)
                    *(cktState1 + here->BSIM4v5qcheq) =
                    *(cktState0 + here->BSIM4v5qcheq);
                    if (here->BSIM4v5trnqsMod)
                    {   error = 0;
                        if (error)
                        return(error);
                    }
                }
                
                
                finished_${::type}_${::corner}_${::section}: 
                
                /* Calculate junction C-V */
                if (ChargeComputationNeeded)
                {   czbd = ${::TECH($::type,$::corner,$::section,DunitAreaTempJctCap)} * here->BSIM4v5Adeff; /* bug fix */
                    czbs = ${::TECH($::type,$::corner,$::section,SunitAreaTempJctCap)} * here->BSIM4v5Aseff;
                    czbdsw = ${::TECH($::type,$::corner,$::section,DunitLengthSidewallTempJctCap)} * here->BSIM4v5Pdeff;
                    czbdswg = ${::TECH($::type,$::corner,$::section,DunitLengthGateSidewallTempJctCap)}
                    * pParam->BSIM4v5weffCJ * here->BSIM4v5nf;
                    czbssw = ${::TECH($::type,$::corner,$::section,SunitLengthSidewallTempJctCap)} * here->BSIM4v5Pseff;
                    czbsswg = ${::TECH($::type,$::corner,$::section,SunitLengthGateSidewallTempJctCap)}
                    * pParam->BSIM4v5weffCJ * here->BSIM4v5nf;
                    
                    MJS = ${::TECH($::type,$::corner,$::section,SbulkJctBotGradingCoeff)};
                    MJSWS = ${::TECH($::type,$::corner,$::section,SbulkJctSideGradingCoeff)};
                    MJSWGS = ${::TECH($::type,$::corner,$::section,SbulkJctGateSideGradingCoeff)};
                    
                    MJD = ${::TECH($::type,$::corner,$::section,DbulkJctBotGradingCoeff)};
                    MJSWD = ${::TECH($::type,$::corner,$::section,DbulkJctSideGradingCoeff)};
                    MJSWGD = ${::TECH($::type,$::corner,$::section,DbulkJctGateSideGradingCoeff)};
                    
                    /* Source Bulk Junction */
                    if (vbs_jct == 0.0)
                    {   
                        
                        *(cktState0 + here->BSIM4v5qbs) = 0.0;
                        here->BSIM4v5capbs = czbs + czbssw + czbsswg;
                    }
                    else if (vbs_jct < 0.0)
                    {   if (czbs > 0.0)
                        {   arg = 1.0 - vbs_jct / ${::TECH($::type,$::corner,$::section,PhiBS)};
                            if (MJS == 0.5)
                            sarg = 1.0 / sqrt(arg);
                            else
                            sarg = exp(-MJS * log(arg));
                            *(cktState0 + here->BSIM4v5qbs) = ${::TECH($::type,$::corner,$::section,PhiBS)} * czbs 
                            * (1.0 - arg * sarg) / (1.0 - MJS);
                            here->BSIM4v5capbs = czbs * sarg;
                        }
                        else
                        {   
                            *(cktState0 + here->BSIM4v5qbs) = 0.0;
                            here->BSIM4v5capbs = 0.0;
                        }
                        if (czbssw > 0.0)
                        {   arg = 1.0 - vbs_jct / ${::TECH($::type,$::corner,$::section,PhiBSWS)};
                            if (MJSWS == 0.5)
                            sarg = 1.0 / sqrt(arg);
                            else
                            sarg = exp(-MJSWS * log(arg));
                            *(cktState0 + here->BSIM4v5qbs) += ${::TECH($::type,$::corner,$::section,PhiBSWS)} * czbssw
                            * (1.0 - arg * sarg) / (1.0 - MJSWS);
                            here->BSIM4v5capbs += czbssw * sarg;
                        }
                        if (czbsswg > 0.0)
                        {   arg = 1.0 - vbs_jct / ${::TECH($::type,$::corner,$::section,PhiBSWGS)};
                            if (MJSWGS == 0.5)
                            sarg = 1.0 / sqrt(arg);
                            else
                            sarg = exp(-MJSWGS * log(arg));
                            *(cktState0 + here->BSIM4v5qbs) += ${::TECH($::type,$::corner,$::section,PhiBSWGS)} * czbsswg
                            * (1.0 - arg * sarg) / (1.0 - MJSWGS);
                            here->BSIM4v5capbs += czbsswg * sarg;
                        }
                        
                    }
                    else
                    {   T0 = czbs + czbssw + czbsswg;
                        T1 = vbs_jct * (czbs * MJS / ${::TECH($::type,$::corner,$::section,PhiBS)} + czbssw * MJSWS 
                        / ${::TECH($::type,$::corner,$::section,PhiBSWS)} + czbsswg * MJSWGS / ${::TECH($::type,$::corner,$::section,PhiBSWGS)});    
                        *(cktState0 + here->BSIM4v5qbs) = vbs_jct * (T0 + 0.5 * T1);
                        here->BSIM4v5capbs = T0 + T1;
                    }
                    
                    /* Drain Bulk Junction */
                    if (vbd_jct == 0.0)
                    {   *(cktState0 + here->BSIM4v5qbd) = 0.0;
                        here->BSIM4v5capbd = czbd + czbdsw + czbdswg;
                    }
                    else if (vbd_jct < 0.0)
                    {   if (czbd > 0.0)
                        {   arg = 1.0 - vbd_jct / ${::TECH($::type,$::corner,$::section,PhiBD)};
                            if (MJD == 0.5)
                            sarg = 1.0 / sqrt(arg);
                            else
                            sarg = exp(-MJD * log(arg));
                            *(cktState0 + here->BSIM4v5qbd) = ${::TECH($::type,$::corner,$::section,PhiBD)}* czbd 
                            * (1.0 - arg * sarg) / (1.0 - MJD);
                            here->BSIM4v5capbd = czbd * sarg;
                        }
                        else
                        {   *(cktState0 + here->BSIM4v5qbd) = 0.0;
                            here->BSIM4v5capbd = 0.0;
                        }
                        if (czbdsw > 0.0)
                        {   arg = 1.0 - vbd_jct / ${::TECH($::type,$::corner,$::section,PhiBSWD)};
                            if (MJSWD == 0.5)
                            sarg = 1.0 / sqrt(arg);
                            else
                            sarg = exp(-MJSWD * log(arg));
                            *(cktState0 + here->BSIM4v5qbd) += ${::TECH($::type,$::corner,$::section,PhiBSWD)} * czbdsw 
                            * (1.0 - arg * sarg) / (1.0 - MJSWD);
                            here->BSIM4v5capbd += czbdsw * sarg;
                        }
                        if (czbdswg > 0.0)
                        {   arg = 1.0 - vbd_jct / ${::TECH($::type,$::corner,$::section,PhiBSWGD)};
                            if (MJSWGD == 0.5)
                            sarg = 1.0 / sqrt(arg);
                            else
                            sarg = exp(-MJSWGD * log(arg));
                            *(cktState0 + here->BSIM4v5qbd) += ${::TECH($::type,$::corner,$::section,PhiBSWGD)} * czbdswg
                            * (1.0 - arg * sarg) / (1.0 - MJSWGD);
                            here->BSIM4v5capbd += czbdswg * sarg;
                        }
                    }
                    else
                    {   T0 = czbd + czbdsw + czbdswg;
                        T1 = vbd_jct * (czbd * MJD / ${::TECH($::type,$::corner,$::section,PhiBD)} + czbdsw * MJSWD
                        / ${::TECH($::type,$::corner,$::section,PhiBSWD)} + czbdswg * MJSWGD / ${::TECH($::type,$::corner,$::section,PhiBSWGD)});
                        *(cktState0 + here->BSIM4v5qbd) = vbd_jct * (T0 + 0.5 * T1);
                        here->BSIM4v5capbd = T0 + T1; 
                    }
                }
                
                
                /*
                *  check convergence
                */
                
                if ((here->BSIM4v5off == 0) || (!(Mode & MODEINITFIX)))
                {   if (Check == 1)
                    {   CKT_CKTnoncon++;
                        #ifndef NEWCONV
                    } 
                    else
                    {   if (here->BSIM4v5mode >= 0)
                        {   Idtot = here->BSIM4v5cd + here->BSIM4v5csub
                            + here->BSIM4v5Igidl - here->BSIM4v5cbd;
                        }
                        else
                        {   Idtot = here->BSIM4v5cd + here->BSIM4v5cbd - here->BSIM4v5Igidl; /* bugfix */
                        }
                        tol0 = CKT_CKTreltol * MAX(fabs(cdhat), fabs(Idtot))
                        + CKT_CKTabstol;
                        tol1 = CKT_CKTreltol * MAX(fabs(cseshat), fabs(Isestot))
                        + CKT_CKTabstol;
                        tol2 = CKT_CKTreltol * MAX(fabs(cdedhat), fabs(Idedtot))
                        + CKT_CKTabstol;
                        tol3 = CKT_CKTreltol * MAX(fabs(cgshat), fabs(Igstot))
                        + CKT_CKTabstol;
                        tol4 = CKT_CKTreltol * MAX(fabs(cgdhat), fabs(Igdtot))
                        + CKT_CKTabstol;
                        tol5 = CKT_CKTreltol * MAX(fabs(cgbhat), fabs(Igbtot))
                        + CKT_CKTabstol;
                        if ((fabs(cdhat - Idtot) >= tol0) || (fabs(cseshat - Isestot) >= tol1)
                        || (fabs(cdedhat - Idedtot) >= tol2))
                        {   CKT_CKTnoncon++;
                        }
                        else if ((fabs(cgshat - Igstot) >= tol3) || (fabs(cgdhat - Igdtot) >= tol4)
                        || (fabs(cgbhat - Igbtot) >= tol5))
                        {   CKT_CKTnoncon++;
                        }
                        else
                        {   Ibtot = here->BSIM4v5cbs + here->BSIM4v5cbd
                            - here->BSIM4v5Igidl - here->BSIM4v5Igisl - here->BSIM4v5csub;
                            tol6 = CKT_CKTreltol * MAX(fabs(cbhat), fabs(Ibtot))
                            + CKT_CKTabstol;
                            if (fabs(cbhat - Ibtot) > tol6)
                            {   CKT_CKTnoncon++;
                            }
                        }
                        #endif /* NEWCONV */
                    }
                }
                *(cktState0 + here->BSIM4v5vds) = vds;
                *(cktState0 + here->BSIM4v5vgs) = vgs;
                *(cktState0 + here->BSIM4v5vbs) = vbs;
                *(cktState0 + here->BSIM4v5vbd) = vbd;
                *(cktState0 + here->BSIM4v5vges) = vges;
                *(cktState0 + here->BSIM4v5vgms) = vgms;
                *(cktState0 + here->BSIM4v5vdbs) = vdbs;
                *(cktState0 + here->BSIM4v5vdbd) = vdbd;
                *(cktState0 + here->BSIM4v5vsbs) = vsbs;
                *(cktState0 + here->BSIM4v5vses) = vses;
                *(cktState0 + here->BSIM4v5vdes) = vdes;
                *(cktState0 + here->BSIM4v5qdef) = qdef;
                
                
                if (!ChargeComputationNeeded)
                goto line_${::type}_${::corner}_${::section}_850; 
                
                if (here->BSIM4v5rgateMod == 3) 
                {   
                    vgdx = vgmd; 
                    vgsx = vgms;
                }  
                else  /* For rgateMod == 0, 1 and 2 */
                {
                    vgdx = vgd;
                    vgsx = vgs;
                }
                if (${::TECH($::type,$::corner,$::section,capMod)} == 0) 
                {  
                    cgdo = pParam->BSIM4v5cgdo; 
                    qgdo = pParam->BSIM4v5cgdo * vgdx;
                    cgso = pParam->BSIM4v5cgso;
                    qgso = pParam->BSIM4v5cgso * vgsx;
                }
                else /* For both capMod == 1 and 2 */
                {   T0 = vgdx + DELTA_1;
                    T1 = sqrt(T0 * T0 + 4.0 * DELTA_1);
                    T2 = 0.5 * (T0 - T1);
                    
                    T3 = pParam->BSIM4v5weffCV * pParam->BSIM4v5cgdl;
                    T4 = sqrt(1.0 - 4.0 * T2 / pParam->BSIM4v5ckappad); 
                    cgdo = pParam->BSIM4v5cgdo + T3 - T3 * (1.0 - 1.0 / T4)
                    * (0.5 - 0.5 * T0 / T1);
                    qgdo = (pParam->BSIM4v5cgdo + T3) * vgdx - T3 * (T2
                    + 0.5 * pParam->BSIM4v5ckappad * (T4 - 1.0));
                    
                    T0 = vgsx + DELTA_1;
                    T1 = sqrt(T0 * T0 + 4.0 * DELTA_1);
                    T2 = 0.5 * (T0 - T1);
                    T3 = pParam->BSIM4v5weffCV * pParam->BSIM4v5cgsl;
                    T4 = sqrt(1.0 - 4.0 * T2 / pParam->BSIM4v5ckappas);
                    cgso = pParam->BSIM4v5cgso + T3 - T3 * (1.0 - 1.0 / T4)
                    * (0.5 - 0.5 * T0 / T1);
                    qgso = (pParam->BSIM4v5cgso + T3) * vgsx - T3 * (T2
                    + 0.5 * pParam->BSIM4v5ckappas * (T4 - 1.0));
                }
                
                if (here->BSIM4v5nf != 1.0)
                {   cgdo *= here->BSIM4v5nf;
                    cgso *= here->BSIM4v5nf;
                    qgdo *= here->BSIM4v5nf;
                    qgso *= here->BSIM4v5nf;
                }	
                here->BSIM4v5cgdo = cgdo;
                here->BSIM4v5qgdo = qgdo;
                here->BSIM4v5cgso = cgso;
                here->BSIM4v5qgso = qgso;
                
                #ifndef NOBYPASS
                line_${::type}_${::corner}_${::section}_755:
                #endif
                ag0 = CKT_CKTag[0];
                if (here->BSIM4v5mode > 0)
                {   if (here->BSIM4v5trnqsMod == 0)
                    {   qdrn -= qgdo;
                        if (here->BSIM4v5rgateMod == 3)
                        {   gcgmgmb = (cgdo + cgso + pParam->BSIM4v5cgbo) * ag0;
                            gcgmdb = -cgdo * ag0;
                            gcgmsb = -cgso * ag0;
                            gcgmbb = -pParam->BSIM4v5cgbo * ag0;
                            
                            gcdgmb = gcgmdb;
                            gcsgmb = gcgmsb;
                            gcbgmb = gcgmbb;
                            
                            gcggb = here->BSIM4v5cggb * ag0;
                            gcgdb = here->BSIM4v5cgdb * ag0;
                            gcgsb = here->BSIM4v5cgsb * ag0;   
                            gcgbb = -(gcggb + gcgdb + gcgsb);
                            
                            gcdgb = here->BSIM4v5cdgb * ag0;
                            gcsgb = -(here->BSIM4v5cggb + here->BSIM4v5cbgb
                            + here->BSIM4v5cdgb) * ag0;
                            gcbgb = here->BSIM4v5cbgb * ag0;
                            
                            qgmb = pParam->BSIM4v5cgbo * vgmb;
                            qgmid = qgdo + qgso + qgmb;
                            qbulk -= qgmb;
                            qsrc = -(qgate + qgmid + qbulk + qdrn);
                        }
                        else
                        {   gcggb = (here->BSIM4v5cggb + cgdo + cgso
                            + pParam->BSIM4v5cgbo ) * ag0;
                            gcgdb = (here->BSIM4v5cgdb - cgdo) * ag0;
                            gcgsb = (here->BSIM4v5cgsb - cgso) * ag0;
                            gcgbb = -(gcggb + gcgdb + gcgsb);
                            
                            gcdgb = (here->BSIM4v5cdgb - cgdo) * ag0;
                            gcsgb = -(here->BSIM4v5cggb + here->BSIM4v5cbgb
                            + here->BSIM4v5cdgb + cgso) * ag0;
                            gcbgb = (here->BSIM4v5cbgb - pParam->BSIM4v5cgbo) * ag0;
                            
                            gcdgmb = gcsgmb = gcbgmb = 0.0;
                            
                            qgb = pParam->BSIM4v5cgbo * vgb;
                            qgate += qgdo + qgso + qgb;
                            qbulk -= qgb;
                            qsrc = -(qgate + qbulk + qdrn);
                        }
                        gcddb = (here->BSIM4v5cddb + here->BSIM4v5capbd + cgdo) * ag0;
                        gcdsb = here->BSIM4v5cdsb * ag0;
                        
                        gcsdb = -(here->BSIM4v5cgdb + here->BSIM4v5cbdb
                        + here->BSIM4v5cddb) * ag0;
                        gcssb = (here->BSIM4v5capbs + cgso - (here->BSIM4v5cgsb
                        + here->BSIM4v5cbsb + here->BSIM4v5cdsb)) * ag0;
                        
                        if (!here->BSIM4v5rbodyMod)
                        {   gcdbb = -(gcdgb + gcddb + gcdsb + gcdgmb);
                            gcsbb = -(gcsgb + gcsdb + gcssb + gcsgmb);
                            gcbdb = (here->BSIM4v5cbdb - here->BSIM4v5capbd) * ag0;
                            gcbsb = (here->BSIM4v5cbsb - here->BSIM4v5capbs) * ag0;
                            gcdbdb = 0.0; gcsbsb = 0.0;
                        }
                        else
                        {   gcdbb  = -(here->BSIM4v5cddb + here->BSIM4v5cdgb 
                            + here->BSIM4v5cdsb) * ag0;
                            gcsbb = -(gcsgb + gcsdb + gcssb + gcsgmb)
                            + here->BSIM4v5capbs * ag0;
                            gcbdb = here->BSIM4v5cbdb * ag0;
                            gcbsb = here->BSIM4v5cbsb * ag0;
                            
                            gcdbdb = -here->BSIM4v5capbd * ag0;
                            gcsbsb = -here->BSIM4v5capbs * ag0;
                        }
                        gcbbb = -(gcbdb + gcbgb + gcbsb + gcbgmb);
                        
                        ggtg = ggtd = ggtb = ggts = 0.0;
                        sxpart = 0.6;
                        dxpart = 0.4;
                        ddxpart_dVd = ddxpart_dVg = ddxpart_dVb = ddxpart_dVs = 0.0;
                        dsxpart_dVd = dsxpart_dVg = dsxpart_dVb = dsxpart_dVs = 0.0;
                    }
                    else
                    {   qcheq = here->BSIM4v5qchqs;
                        CoxWL = ${::TECH($::type,$::corner,$::section,coxe)} * pParam->BSIM4v5weffCV * here->BSIM4v5nf
                        * pParam->BSIM4v5leffCV;
                        T0 = qdef * $ScalingFactor / CoxWL;
                        
                        ggtg = here->BSIM4v5gtg = T0 * here->BSIM4v5gcrgg;
                        ggtd = here->BSIM4v5gtd = T0 * here->BSIM4v5gcrgd;
                        ggts = here->BSIM4v5gts = T0 * here->BSIM4v5gcrgs;
                        ggtb = here->BSIM4v5gtb = T0 * here->BSIM4v5gcrgb;
                        gqdef = $ScalingFactor * ag0;
                        
                        gcqgb = here->BSIM4v5cqgb * ag0;
                        gcqdb = here->BSIM4v5cqdb * ag0;
                        gcqsb = here->BSIM4v5cqsb * ag0;
                        gcqbb = here->BSIM4v5cqbb * ag0;
                        
                        if (fabs(qcheq) <= 1.0e-5 * CoxWL)
                        {   if (${::TECH($::type,$::corner,$::section,xpart)} < 0.5)
                            {   dxpart = 0.4;
                            }
                            else if (${::TECH($::type,$::corner,$::section,xpart)} > 0.5)
                            {   dxpart = 0.0;
                            }
                            else
                            {   dxpart = 0.5;
                            }
                            ddxpart_dVd = ddxpart_dVg = ddxpart_dVb
                            = ddxpart_dVs = 0.0;
                        }
                        else
                        {   dxpart = qdrn / qcheq;
                            Cdd = here->BSIM4v5cddb;
                            Csd = -(here->BSIM4v5cgdb + here->BSIM4v5cddb
                            + here->BSIM4v5cbdb);
                            ddxpart_dVd = (Cdd - dxpart * (Cdd + Csd)) / qcheq;
                            Cdg = here->BSIM4v5cdgb;
                            Csg = -(here->BSIM4v5cggb + here->BSIM4v5cdgb
                            + here->BSIM4v5cbgb);
                            ddxpart_dVg = (Cdg - dxpart * (Cdg + Csg)) / qcheq;
                            
                            Cds = here->BSIM4v5cdsb;
                            Css = -(here->BSIM4v5cgsb + here->BSIM4v5cdsb
                            + here->BSIM4v5cbsb);
                            ddxpart_dVs = (Cds - dxpart * (Cds + Css)) / qcheq;
                            
                            ddxpart_dVb = -(ddxpart_dVd + ddxpart_dVg + ddxpart_dVs);
                        }
                        sxpart = 1.0 - dxpart;
                        dsxpart_dVd = -ddxpart_dVd;
                        dsxpart_dVg = -ddxpart_dVg;
                        dsxpart_dVs = -ddxpart_dVs;
                        dsxpart_dVb = -(dsxpart_dVd + dsxpart_dVg + dsxpart_dVs);
                        
                        if (here->BSIM4v5rgateMod == 3)
                        {   gcgmgmb = (cgdo + cgso + pParam->BSIM4v5cgbo) * ag0;
                            gcgmdb = -cgdo * ag0;
                            gcgmsb = -cgso * ag0;
                            gcgmbb = -pParam->BSIM4v5cgbo * ag0;
                            
                            gcdgmb = gcgmdb;
                            gcsgmb = gcgmsb;
                            gcbgmb = gcgmbb;
                            
                            gcdgb = gcsgb = gcbgb = 0.0;
                            gcggb = gcgdb = gcgsb = gcgbb = 0.0;
                            
                            qgmb = pParam->BSIM4v5cgbo * vgmb;
                            qgmid = qgdo + qgso + qgmb;
                            qgate = 0.0;
                            qbulk = -qgmb;
                            qdrn = -qgdo;
                            qsrc = -(qgmid + qbulk + qdrn);
                        }
                        else
                        {   gcggb = (cgdo + cgso + pParam->BSIM4v5cgbo ) * ag0;
                            gcgdb = -cgdo * ag0;
                            gcgsb = -cgso * ag0;
                            gcgbb = -pParam->BSIM4v5cgbo * ag0;
                            
                            gcdgb = gcgdb;
                            gcsgb = gcgsb;
                            gcbgb = gcgbb;
                            gcdgmb = gcsgmb = gcbgmb = 0.0;
                            
                            qgb = pParam->BSIM4v5cgbo * vgb;
                            qgate = qgdo + qgso + qgb;
                            qbulk = -qgb;
                            qdrn = -qgdo;
                            qsrc = -(qgate + qbulk + qdrn);
                        }
                        
                        gcddb = (here->BSIM4v5capbd + cgdo) * ag0;
                        gcdsb = gcsdb = 0.0;
                        gcssb = (here->BSIM4v5capbs + cgso) * ag0;
                        
                        if (!here->BSIM4v5rbodyMod)
                        {   gcdbb = -(gcdgb + gcddb + gcdgmb);
                            gcsbb = -(gcsgb + gcssb + gcsgmb);
                            gcbdb = -here->BSIM4v5capbd * ag0;
                            gcbsb = -here->BSIM4v5capbs * ag0;
                            gcdbdb = 0.0; gcsbsb = 0.0;
                        }
                        else
                        {   gcdbb = gcsbb = gcbdb = gcbsb = 0.0;
                            gcdbdb = -here->BSIM4v5capbd * ag0;
                            gcsbsb = -here->BSIM4v5capbs * ag0;
                        }
                        gcbbb = -(gcbdb + gcbgb + gcbsb + gcbgmb);
                    }
                }
                else
                {   if (here->BSIM4v5trnqsMod == 0)
                    {   qsrc = qdrn - qgso;
                        if (here->BSIM4v5rgateMod == 3)
                        {   gcgmgmb = (cgdo + cgso + pParam->BSIM4v5cgbo) * ag0;
                            gcgmdb = -cgdo * ag0;
                            gcgmsb = -cgso * ag0;
                            gcgmbb = -pParam->BSIM4v5cgbo * ag0;
                            
                            gcdgmb = gcgmdb;
                            gcsgmb = gcgmsb;
                            gcbgmb = gcgmbb;
                            
                            gcggb = here->BSIM4v5cggb * ag0;
                            gcgdb = here->BSIM4v5cgsb * ag0;
                            gcgsb = here->BSIM4v5cgdb * ag0;
                            gcgbb = -(gcggb + gcgdb + gcgsb);
                            
                            gcdgb = -(here->BSIM4v5cggb + here->BSIM4v5cbgb
                            + here->BSIM4v5cdgb) * ag0;
                            gcsgb = here->BSIM4v5cdgb * ag0;
                            gcbgb = here->BSIM4v5cbgb * ag0;
                            
                            qgmb = pParam->BSIM4v5cgbo * vgmb;
                            qgmid = qgdo + qgso + qgmb;
                            qbulk -= qgmb;
                            qdrn = -(qgate + qgmid + qbulk + qsrc);
                        }
                        else
                        {   gcggb = (here->BSIM4v5cggb + cgdo + cgso
                            + pParam->BSIM4v5cgbo ) * ag0;
                            gcgdb = (here->BSIM4v5cgsb - cgdo) * ag0;
                            gcgsb = (here->BSIM4v5cgdb - cgso) * ag0;
                            gcgbb = -(gcggb + gcgdb + gcgsb);
                            
                            gcdgb = -(here->BSIM4v5cggb + here->BSIM4v5cbgb
                            + here->BSIM4v5cdgb + cgdo) * ag0;
                            gcsgb = (here->BSIM4v5cdgb - cgso) * ag0;
                            gcbgb = (here->BSIM4v5cbgb - pParam->BSIM4v5cgbo) * ag0;
                            
                            gcdgmb = gcsgmb = gcbgmb = 0.0;
                            
                            qgb = pParam->BSIM4v5cgbo * vgb;
                            qgate += qgdo + qgso + qgb;
                            qbulk -= qgb;
                            qdrn = -(qgate + qbulk + qsrc);
                        }
                        gcddb = (here->BSIM4v5capbd + cgdo - (here->BSIM4v5cgsb
                        + here->BSIM4v5cbsb + here->BSIM4v5cdsb)) * ag0;
                        gcdsb = -(here->BSIM4v5cgdb + here->BSIM4v5cbdb
                        + here->BSIM4v5cddb) * ag0;
                        
                        gcsdb = here->BSIM4v5cdsb * ag0;
                        gcssb = (here->BSIM4v5cddb + here->BSIM4v5capbs + cgso) * ag0;
                        
                        if (!here->BSIM4v5rbodyMod)
                        {   gcdbb = -(gcdgb + gcddb + gcdsb + gcdgmb);
                            gcsbb = -(gcsgb + gcsdb + gcssb + gcsgmb);
                            gcbdb = (here->BSIM4v5cbsb - here->BSIM4v5capbd) * ag0;
                            gcbsb = (here->BSIM4v5cbdb - here->BSIM4v5capbs) * ag0;
                            gcdbdb = 0.0; gcsbsb = 0.0;
                        }
                        else
                        {   gcdbb = -(gcdgb + gcddb + gcdsb + gcdgmb)
                            + here->BSIM4v5capbd * ag0;
                            gcsbb = -(here->BSIM4v5cddb + here->BSIM4v5cdgb
                            + here->BSIM4v5cdsb) * ag0;
                            gcbdb = here->BSIM4v5cbsb * ag0;
                            gcbsb = here->BSIM4v5cbdb * ag0;
                            gcdbdb = -here->BSIM4v5capbd * ag0;
                            gcsbsb = -here->BSIM4v5capbs * ag0;
                        }
                        gcbbb = -(gcbgb + gcbdb + gcbsb + gcbgmb);
                        
                        ggtg = ggtd = ggtb = ggts = 0.0;
                        sxpart = 0.4;
                        dxpart = 0.6;
                        ddxpart_dVd = ddxpart_dVg = ddxpart_dVb = ddxpart_dVs = 0.0;
                        dsxpart_dVd = dsxpart_dVg = dsxpart_dVb = dsxpart_dVs = 0.0;
                    }
                    else
                    {   qcheq = here->BSIM4v5qchqs;
                        CoxWL = ${::TECH($::type,$::corner,$::section,coxe)} * pParam->BSIM4v5weffCV * here->BSIM4v5nf
                        * pParam->BSIM4v5leffCV;
                        T0 = qdef * $ScalingFactor / CoxWL;
                        ggtg = here->BSIM4v5gtg = T0 * here->BSIM4v5gcrgg;
                        ggts = here->BSIM4v5gts = T0 * here->BSIM4v5gcrgd;
                        ggtd = here->BSIM4v5gtd = T0 * here->BSIM4v5gcrgs;
                        ggtb = here->BSIM4v5gtb = T0 * here->BSIM4v5gcrgb;
                        gqdef = $ScalingFactor * ag0;
                        
                        gcqgb = here->BSIM4v5cqgb * ag0;
                        gcqdb = here->BSIM4v5cqsb * ag0;
                        gcqsb = here->BSIM4v5cqdb * ag0;
                        gcqbb = here->BSIM4v5cqbb * ag0;
                        
                        if (fabs(qcheq) <= 1.0e-5 * CoxWL)
                        {   if (${::TECH($::type,$::corner,$::section,xpart)} < 0.5)
                            {   sxpart = 0.4;
                            }
                            else if (${::TECH($::type,$::corner,$::section,xpart)} > 0.5)
                            {   sxpart = 0.0;
                            }
                            else
                            {   sxpart = 0.5;
                            }
                            dsxpart_dVd = dsxpart_dVg = dsxpart_dVb
                            = dsxpart_dVs = 0.0;
                        }
                        else
                        {   sxpart = qdrn / qcheq;
                            Css = here->BSIM4v5cddb;
                            Cds = -(here->BSIM4v5cgdb + here->BSIM4v5cddb
                            + here->BSIM4v5cbdb);
                            dsxpart_dVs = (Css - sxpart * (Css + Cds)) / qcheq;
                            Csg = here->BSIM4v5cdgb;
                            Cdg = -(here->BSIM4v5cggb + here->BSIM4v5cdgb
                            + here->BSIM4v5cbgb);
                            dsxpart_dVg = (Csg - sxpart * (Csg + Cdg)) / qcheq;
                            
                            Csd = here->BSIM4v5cdsb;
                            Cdd = -(here->BSIM4v5cgsb + here->BSIM4v5cdsb
                            + here->BSIM4v5cbsb);
                            dsxpart_dVd = (Csd - sxpart * (Csd + Cdd)) / qcheq;
                            
                            dsxpart_dVb = -(dsxpart_dVd + dsxpart_dVg + dsxpart_dVs);
                        }
                        dxpart = 1.0 - sxpart;
                        ddxpart_dVd = -dsxpart_dVd;
                        ddxpart_dVg = -dsxpart_dVg;
                        ddxpart_dVs = -dsxpart_dVs;
                        ddxpart_dVb = -(ddxpart_dVd + ddxpart_dVg + ddxpart_dVs);
                        
                        if (here->BSIM4v5rgateMod == 3)
                        {   gcgmgmb = (cgdo + cgso + pParam->BSIM4v5cgbo) * ag0;
                            gcgmdb = -cgdo * ag0;
                            gcgmsb = -cgso * ag0;
                            gcgmbb = -pParam->BSIM4v5cgbo * ag0;
                            
                            gcdgmb = gcgmdb;
                            gcsgmb = gcgmsb;
                            gcbgmb = gcgmbb;
                            
                            gcdgb = gcsgb = gcbgb = 0.0;
                            gcggb = gcgdb = gcgsb = gcgbb = 0.0;
                            
                            qgmb = pParam->BSIM4v5cgbo * vgmb;
                            qgmid = qgdo + qgso + qgmb;
                            qgate = 0.0;
                            qbulk = -qgmb;
                            qdrn = -qgdo;
                            qsrc = -qgso;
                        }
                        else
                        {   gcggb = (cgdo + cgso + pParam->BSIM4v5cgbo ) * ag0;
                            gcgdb = -cgdo * ag0;
                            gcgsb = -cgso * ag0;
                            gcgbb = -pParam->BSIM4v5cgbo * ag0;
                            
                            gcdgb = gcgdb;
                            gcsgb = gcgsb;
                            gcbgb = gcgbb;
                            gcdgmb = gcsgmb = gcbgmb = 0.0;
                            
                            qgb = pParam->BSIM4v5cgbo * vgb;
                            qgate = qgdo + qgso + qgb;
                            qbulk = -qgb;
                            qdrn = -qgdo;
                            qsrc = -qgso;
                        }
                        
                        gcddb = (here->BSIM4v5capbd + cgdo) * ag0;
                        gcdsb = gcsdb = 0.0;
                        gcssb = (here->BSIM4v5capbs + cgso) * ag0;
                        if (!here->BSIM4v5rbodyMod)
                        {   gcdbb = -(gcdgb + gcddb + gcdgmb);
                            gcsbb = -(gcsgb + gcssb + gcsgmb);
                            gcbdb = -here->BSIM4v5capbd * ag0;
                            gcbsb = -here->BSIM4v5capbs * ag0;
                            gcdbdb = 0.0; gcsbsb = 0.0;
                        }
                        else
                        {   gcdbb = gcsbb = gcbdb = gcbsb = 0.0;
                            gcdbdb = -here->BSIM4v5capbd * ag0;
                            gcsbsb = -here->BSIM4v5capbs * ag0;
                        }
                        gcbbb = -(gcbdb + gcbgb + gcbsb + gcbgmb);
                    }
                }
                
                
                if (here->BSIM4v5trnqsMod)
                {   *(cktState0 + here->BSIM4v5qcdump) = qdef * $ScalingFactor;
                    if (Mode & MODEINITTRAN)
                    *(cktState1 + here->BSIM4v5qcdump) =
                    *(cktState0 + here->BSIM4v5qcdump);
                    error = 0;
                    if (error)
                    return(error);
                }
                
                if (ByPass) goto line_${::type}_${::corner}_${::section}_860;
                
                *(cktState0 + here->BSIM4v5qg) = qgate;
                *(cktState0 + here->BSIM4v5qd) = qdrn
                - *(cktState0 + here->BSIM4v5qbd);
                *(cktState0 + here->BSIM4v5qs) = qsrc
                - *(cktState0 + here->BSIM4v5qbs);
                if (here->BSIM4v5rgateMod == 3)
                *(cktState0 + here->BSIM4v5qgmid) = qgmid;
                
                if (!here->BSIM4v5rbodyMod)
                {   *(cktState0 + here->BSIM4v5qb) = qbulk
                    + *(cktState0 + here->BSIM4v5qbd)
                    + *(cktState0 + here->BSIM4v5qbs);
                }
                else
                *(cktState0 + here->BSIM4v5qb) = qbulk;
                
                
                /* Store small signal parameters */
                if (Mode & MODEINITSMSIG)
                {   goto line_${::type}_${::corner}_${::section}_1000;
                }
                
                if (!ChargeComputationNeeded)
                goto line_${::type}_${::corner}_${::section}_850;
                
                if (Mode & MODEINITTRAN)
                {   *(cktState1 + here->BSIM4v5qb) =
                    *(cktState0 + here->BSIM4v5qb);
                    *(cktState1 + here->BSIM4v5qg) =
                    *(cktState0 + here->BSIM4v5qg);
                    *(cktState1 + here->BSIM4v5qd) =
                    *(cktState0 + here->BSIM4v5qd);
                    if (here->BSIM4v5rgateMod == 3)
                    *(cktState1 + here->BSIM4v5qgmid) =
                    *(cktState0 + here->BSIM4v5qgmid);
                    if (here->BSIM4v5rbodyMod)
                    {   *(cktState1 + here->BSIM4v5qbs) =
                        *(cktState0 + here->BSIM4v5qbs);
                        *(cktState1 + here->BSIM4v5qbd) =
                        *(cktState0 + here->BSIM4v5qbd);
                    }
                }
                
                error = 0;
                if (error) 
                return(error);
                error = 0;
                if (error) 
                return(error);
                error = 0;
                if (error) 
                return(error);
                
                if (here->BSIM4v5rgateMod == 3)
                {   error = 0;
                    if (error) return(error);
                }
                
                if (here->BSIM4v5rbodyMod)
                {   error = 0;
                    if (error) 
                    return(error);
                    error = 0;
                    if (error) 
                    return(error);
                }
                
                goto line_${::type}_${::corner}_${::section}_860;
                
                
                line_${::type}_${::corner}_${::section}_850:
                /* Zero gcap and ceqcap if (!ChargeComputationNeeded) */
                ceqqg = ceqqb = ceqqd = 0.0;
                ceqqjd = ceqqjs = 0.0;
                cqcheq = cqdef = 0.0;
                
                gcdgb = gcddb = gcdsb = gcdbb = 0.0;
                gcsgb = gcsdb = gcssb = gcsbb = 0.0;
                gcggb = gcgdb = gcgsb = gcgbb = 0.0;
                gcbdb = gcbgb = gcbsb = gcbbb = 0.0;
                
                gcgmgmb = gcgmdb = gcgmsb = gcgmbb = 0.0;
                gcdgmb = gcsgmb = gcbgmb = ceqqgmid = 0.0;
                gcdbdb = gcsbsb = 0.0;
                
                gqdef = gcqgb = gcqdb = gcqsb = gcqbb = 0.0;
                ggtg = ggtd = ggtb = ggts = 0.0;
                sxpart = (1.0 - (dxpart = (here->BSIM4v5mode > 0) ? 0.4 : 0.6));
                ddxpart_dVd = ddxpart_dVg = ddxpart_dVb = ddxpart_dVs = 0.0;
                dsxpart_dVd = dsxpart_dVg = dsxpart_dVb = dsxpart_dVs = 0.0;
                
                if (here->BSIM4v5trnqsMod)
                {   CoxWL = ${::TECH($::type,$::corner,$::section,coxe)} * pParam->BSIM4v5weffCV * here->BSIM4v5nf
                    * pParam->BSIM4v5leffCV;
                    T1 = here->BSIM4v5gcrg / CoxWL;
                    here->BSIM4v5gtau = T1 * $ScalingFactor;
                }
                else
                here->BSIM4v5gtau = 0.0;
                
                goto line_${::type}_${::corner}_${::section}_900;
                
                
                line_${::type}_${::corner}_${::section}_860:
                /* Calculate equivalent charge current */
                
                cqgate = *(cktState0 + here->BSIM4v5cqg);
                cqbody = *(cktState0 + here->BSIM4v5cqb);
                cqdrn = *(cktState0 + here->BSIM4v5cqd);
                
                ceqqg = cqgate - gcggb * vgb + gcgdb * vbd + gcgsb * vbs;
                ceqqd = cqdrn - gcdgb * vgb - gcdgmb * vgmb + (gcddb + gcdbdb)
                * vbd - gcdbdb * vbd_jct + gcdsb * vbs;
                ceqqb = cqbody - gcbgb * vgb - gcbgmb * vgmb
                + gcbdb * vbd + gcbsb * vbs;
                
                
                if (here->BSIM4v5rgateMod == 3)
                ceqqgmid = *(cktState0 + here->BSIM4v5cqgmid)
                + gcgmdb * vbd + gcgmsb * vbs - gcgmgmb * vgmb;
                else
                ceqqgmid = 0.0;	
                
                if (here->BSIM4v5rbodyMod)
                {   ceqqjs = *(cktState0 + here->BSIM4v5cqbs) + gcsbsb * vbs_jct;
                    ceqqjd = *(cktState0 + here->BSIM4v5cqbd) + gcdbdb * vbd_jct; 
                }
                
                if (here->BSIM4v5trnqsMod)
                {   T0 = ggtg * vgb - ggtd * vbd - ggts * vbs;
                    ceqqg += T0;
                    T1 = qdef * here->BSIM4v5gtau;
                    ceqqd -= dxpart * T0 + T1 * (ddxpart_dVg * vgb - ddxpart_dVd
                    * vbd - ddxpart_dVs * vbs);
                    cqdef = *(cktState0 + here->BSIM4v5cqcdump) - gqdef * qdef;
                    cqcheq = *(cktState0 + here->BSIM4v5cqcheq)
                    - (gcqgb * vgb - gcqdb * vbd - gcqsb * vbs) + T0;
                }
                
                if (Mode & MODEINITTRAN)
                {   *(cktState1 + here->BSIM4v5cqb) =
                    *(cktState0 + here->BSIM4v5cqb);
                    *(cktState1 + here->BSIM4v5cqg) =
                    *(cktState0 + here->BSIM4v5cqg);
                    *(cktState1 + here->BSIM4v5cqd) =
                    *(cktState0 + here->BSIM4v5cqd);
                    
                    if (here->BSIM4v5rgateMod == 3)
                    *(cktState1 + here->BSIM4v5cqgmid) =
                    *(cktState0 + here->BSIM4v5cqgmid);
                    
                    if (here->BSIM4v5rbodyMod)
                    {   *(cktState1 + here->BSIM4v5cqbs) =
                        *(cktState0 + here->BSIM4v5cqbs);
                        *(cktState1 + here->BSIM4v5cqbd) =
                        *(cktState0 + here->BSIM4v5cqbd);
                    }
                }
                
                
                /*
                *  Load current vector
                */
                
                line_${::type}_${::corner}_${::section}_900:
                if (here->BSIM4v5mode >= 0)
                {   Gm = here->BSIM4v5gm;
                    Gmbs = here->BSIM4v5gmbs;
                    FwdSum = Gm + Gmbs;
                    RevSum = 0.0;
                    
                    ceqdrn = ${::TECH($::type,$::corner,$::section,type)} * (cdrain - here->BSIM4v5gds * vds
                    - Gm * vgs - Gmbs * vbs);
                    ceqbd = ${::TECH($::type,$::corner,$::section,type)} * (here->BSIM4v5csub + here->BSIM4v5Igidl
                    - (here->BSIM4v5gbds + here->BSIM4v5ggidld) * vds
                    - (here->BSIM4v5gbgs + here->BSIM4v5ggidlg) * vgs
                    - (here->BSIM4v5gbbs + here->BSIM4v5ggidlb) * vbs);
                    ceqbs = ${::TECH($::type,$::corner,$::section,type)} * (here->BSIM4v5Igisl + here->BSIM4v5ggisls * vds 
                    - here->BSIM4v5ggislg * vgd - here->BSIM4v5ggislb * vbd);
                    
                    gbbdp = -(here->BSIM4v5gbds);
                    gbbsp = here->BSIM4v5gbds + here->BSIM4v5gbgs + here->BSIM4v5gbbs; 
                    
                    gbdpg = here->BSIM4v5gbgs;
                    gbdpdp = here->BSIM4v5gbds;
                    gbdpb = here->BSIM4v5gbbs;
                    gbdpsp = -(gbdpg + gbdpdp + gbdpb);
                    
                    gbspg = 0.0;
                    gbspdp = 0.0;
                    gbspb = 0.0;
                    gbspsp = 0.0;
                    
                    if (${::TECH($::type,$::corner,$::section,igcMod)})
                    {   gIstotg = here->BSIM4v5gIgsg + here->BSIM4v5gIgcsg;
                        gIstotd = here->BSIM4v5gIgcsd;
                        gIstots = here->BSIM4v5gIgss + here->BSIM4v5gIgcss;
                        gIstotb = here->BSIM4v5gIgcsb;
                        Istoteq = ${::TECH($::type,$::corner,$::section,type)} * (here->BSIM4v5Igs + here->BSIM4v5Igcs
                        - gIstotg * vgs - here->BSIM4v5gIgcsd * vds
                        - here->BSIM4v5gIgcsb * vbs);
                        
                        gIdtotg = here->BSIM4v5gIgdg + here->BSIM4v5gIgcdg;
                        gIdtotd = here->BSIM4v5gIgdd + here->BSIM4v5gIgcdd;
                        gIdtots = here->BSIM4v5gIgcds;
                        gIdtotb = here->BSIM4v5gIgcdb;
                        Idtoteq = ${::TECH($::type,$::corner,$::section,type)} * (here->BSIM4v5Igd + here->BSIM4v5Igcd
                        - here->BSIM4v5gIgdg * vgd - here->BSIM4v5gIgcdg * vgs
                        - here->BSIM4v5gIgcdd * vds - here->BSIM4v5gIgcdb * vbs);
                    }
                    else
                    {   gIstotg = gIstotd = gIstots = gIstotb = Istoteq = 0.0;
                        gIdtotg = gIdtotd = gIdtots = gIdtotb = Idtoteq = 0.0;
                    }
                    
                    if (${::TECH($::type,$::corner,$::section,igbMod)})
                    {   gIbtotg = here->BSIM4v5gIgbg;
                        gIbtotd = here->BSIM4v5gIgbd;
                        gIbtots = here->BSIM4v5gIgbs;
                        gIbtotb = here->BSIM4v5gIgbb;
                        Ibtoteq = ${::TECH($::type,$::corner,$::section,type)} * (here->BSIM4v5Igb
                        - here->BSIM4v5gIgbg * vgs - here->BSIM4v5gIgbd * vds
                        - here->BSIM4v5gIgbb * vbs);
                    }
                    else
                    gIbtotg = gIbtotd = gIbtots = gIbtotb = Ibtoteq = 0.0;
                    
                    if ((${::TECH($::type,$::corner,$::section,igcMod)} != 0) || (${::TECH($::type,$::corner,$::section,igbMod)} != 0))
                    {   gIgtotg = gIstotg + gIdtotg + gIbtotg;
                        gIgtotd = gIstotd + gIdtotd + gIbtotd ;
                        gIgtots = gIstots + gIdtots + gIbtots;
                        gIgtotb = gIstotb + gIdtotb + gIbtotb;
                        Igtoteq = Istoteq + Idtoteq + Ibtoteq; 
                    }
                    else
                    gIgtotg = gIgtotd = gIgtots = gIgtotb = Igtoteq = 0.0;
                    
                    
                    if (here->BSIM4v5rgateMod == 2)
                    T0 = vges - vgs;
                    else if (here->BSIM4v5rgateMod == 3)
                    T0 = vgms - vgs;
                    if (here->BSIM4v5rgateMod > 1)
                    {   gcrgd = here->BSIM4v5gcrgd * T0;
                        gcrgg = here->BSIM4v5gcrgg * T0;
                        gcrgs = here->BSIM4v5gcrgs * T0;
                        gcrgb = here->BSIM4v5gcrgb * T0;
                        ceqgcrg = -(gcrgd * vds + gcrgg * vgs
                        + gcrgb * vbs);
                        gcrgg -= here->BSIM4v5gcrg;
                        gcrg = here->BSIM4v5gcrg;
                    }
                    else
                    ceqgcrg = gcrg = gcrgd = gcrgg = gcrgs = gcrgb = 0.0;
                }
                else
                {   Gm = -here->BSIM4v5gm;
                    Gmbs = -here->BSIM4v5gmbs;
                    FwdSum = 0.0;
                    RevSum = -(Gm + Gmbs);
                    
                    ceqdrn = (0-(${::TECH($::type,$::corner,$::section,type)})) * (cdrain + here->BSIM4v5gds * vds
                    + Gm * vgd + Gmbs * vbd);
                    
                    ceqbs = ${::TECH($::type,$::corner,$::section,type)} * (here->BSIM4v5csub + here->BSIM4v5Igisl 
                    + (here->BSIM4v5gbds + here->BSIM4v5ggisls) * vds
                    - (here->BSIM4v5gbgs + here->BSIM4v5ggislg) * vgd
                    - (here->BSIM4v5gbbs + here->BSIM4v5ggislb) * vbd);
                    ceqbd = ${::TECH($::type,$::corner,$::section,type)} * (here->BSIM4v5Igidl - here->BSIM4v5ggidld * vds 
                    - here->BSIM4v5ggidlg * vgs - here->BSIM4v5ggidlb * vbs);
                    
                    gbbsp = -(here->BSIM4v5gbds);
                    gbbdp = here->BSIM4v5gbds + here->BSIM4v5gbgs + here->BSIM4v5gbbs; 
                    
                    gbdpg = 0.0;
                    gbdpsp = 0.0;
                    gbdpb = 0.0;
                    gbdpdp = 0.0;
                    
                    gbspg = here->BSIM4v5gbgs;
                    gbspsp = here->BSIM4v5gbds;
                    gbspb = here->BSIM4v5gbbs;
                    gbspdp = -(gbspg + gbspsp + gbspb);
                    
                    if (${::TECH($::type,$::corner,$::section,igcMod)})
                    {   gIstotg = here->BSIM4v5gIgsg + here->BSIM4v5gIgcdg;
                        gIstotd = here->BSIM4v5gIgcds;
                        gIstots = here->BSIM4v5gIgss + here->BSIM4v5gIgcdd;
                        gIstotb = here->BSIM4v5gIgcdb;
                        Istoteq = ${::TECH($::type,$::corner,$::section,type)} * (here->BSIM4v5Igs + here->BSIM4v5Igcd
                        - here->BSIM4v5gIgsg * vgs - here->BSIM4v5gIgcdg * vgd
                        + here->BSIM4v5gIgcdd * vds - here->BSIM4v5gIgcdb * vbd);
                        
                        gIdtotg = here->BSIM4v5gIgdg + here->BSIM4v5gIgcsg;
                        gIdtotd = here->BSIM4v5gIgdd + here->BSIM4v5gIgcss;
                        gIdtots = here->BSIM4v5gIgcsd;
                        gIdtotb = here->BSIM4v5gIgcsb;
                        Idtoteq = ${::TECH($::type,$::corner,$::section,type)} * (here->BSIM4v5Igd + here->BSIM4v5Igcs
                        - (here->BSIM4v5gIgdg + here->BSIM4v5gIgcsg) * vgd
                        + here->BSIM4v5gIgcsd * vds - here->BSIM4v5gIgcsb * vbd);
                    }
                    else
                    {   gIstotg = gIstotd = gIstots = gIstotb = Istoteq = 0.0;
                        gIdtotg = gIdtotd = gIdtots = gIdtotb = Idtoteq = 0.0;
                    }
                    
                    if (${::TECH($::type,$::corner,$::section,igbMod)})
                    {   gIbtotg = here->BSIM4v5gIgbg;
                        gIbtotd = here->BSIM4v5gIgbs;
                        gIbtots = here->BSIM4v5gIgbd;
                        gIbtotb = here->BSIM4v5gIgbb;
                        Ibtoteq = ${::TECH($::type,$::corner,$::section,type)} * (here->BSIM4v5Igb
                        - here->BSIM4v5gIgbg * vgd + here->BSIM4v5gIgbd * vds
                        - here->BSIM4v5gIgbb * vbd);
                    }
                    else
                    gIbtotg = gIbtotd = gIbtots = gIbtotb = Ibtoteq = 0.0;
                    
                    if ((${::TECH($::type,$::corner,$::section,igcMod)} != 0) || (${::TECH($::type,$::corner,$::section,igbMod)} != 0))
                    {   gIgtotg = gIstotg + gIdtotg + gIbtotg;
                        gIgtotd = gIstotd + gIdtotd + gIbtotd ;
                        gIgtots = gIstots + gIdtots + gIbtots;
                        gIgtotb = gIstotb + gIdtotb + gIbtotb;
                        Igtoteq = Istoteq + Idtoteq + Ibtoteq;
                    }
                    else
                    gIgtotg = gIgtotd = gIgtots = gIgtotb = Igtoteq = 0.0;
                    
                    
                    if (here->BSIM4v5rgateMod == 2)
                    T0 = vges - vgs;
                    else if (here->BSIM4v5rgateMod == 3)
                    T0 = vgms - vgs;
                    if (here->BSIM4v5rgateMod > 1)
                    {   gcrgd = here->BSIM4v5gcrgs * T0;
                        gcrgg = here->BSIM4v5gcrgg * T0;
                        gcrgs = here->BSIM4v5gcrgd * T0;
                        gcrgb = here->BSIM4v5gcrgb * T0;
                        ceqgcrg = -(gcrgg * vgd - gcrgs * vds
                        + gcrgb * vbd);
                        gcrgg -= here->BSIM4v5gcrg;
                        gcrg = here->BSIM4v5gcrg;
                    }
                    else
                    ceqgcrg = gcrg = gcrgd = gcrgg = gcrgs = gcrgb = 0.0;
                }
                
                if (${::TECH($::type,$::corner,$::section,rdsMod)} == 1)
                {   ceqgstot = ${::TECH($::type,$::corner,$::section,type)} * (here->BSIM4v5gstotd * vds
                    + here->BSIM4v5gstotg * vgs + here->BSIM4v5gstotb * vbs);
                    /* WDLiu: ceqgstot flowing away from sNodePrime */
                    gstot = here->BSIM4v5gstot;
                    gstotd = here->BSIM4v5gstotd;
                    gstotg = here->BSIM4v5gstotg;
                    gstots = here->BSIM4v5gstots - gstot;
                    gstotb = here->BSIM4v5gstotb;
                    
                    ceqgdtot = (0-(${::TECH($::type,$::corner,$::section,type)})) * (here->BSIM4v5gdtotd * vds
                    + here->BSIM4v5gdtotg * vgs + here->BSIM4v5gdtotb * vbs);
                    /* WDLiu: ceqgdtot defined as flowing into dNodePrime */
                    gdtot = here->BSIM4v5gdtot;
                    gdtotd = here->BSIM4v5gdtotd - gdtot;
                    gdtotg = here->BSIM4v5gdtotg;
                    gdtots = here->BSIM4v5gdtots;
                    gdtotb = here->BSIM4v5gdtotb;
                }
                else
                {   gstot = gstotd = gstotg = gstots = gstotb = ceqgstot = 0.0;
                    gdtot = gdtotd = gdtotg = gdtots = gdtotb = ceqgdtot = 0.0;
                }
                
                if (${::TECH($::type,$::corner,$::section,type)} > 0)
                {   ceqjs = (here->BSIM4v5cbs - here->BSIM4v5gbs * vbs_jct);
                    ceqjd = (here->BSIM4v5cbd - here->BSIM4v5gbd * vbd_jct);
                }
                else
                {   ceqjs = -(here->BSIM4v5cbs - here->BSIM4v5gbs * vbs_jct); 
                    ceqjd = -(here->BSIM4v5cbd - here->BSIM4v5gbd * vbd_jct);
                    ceqqg = -ceqqg;
                    ceqqd = -ceqqd;
                    ceqqb = -ceqqb;
                    ceqgcrg = -ceqgcrg;
                    
                    if (here->BSIM4v5trnqsMod)
                    {   cqdef = -cqdef;
                        cqcheq = -cqcheq;
                    }
                    
                    if (here->BSIM4v5rbodyMod)
                    {   ceqqjs = -ceqqjs;
                        ceqqjd = -ceqqjd;
                    }
                    
                    if (here->BSIM4v5rgateMod == 3)
                    ceqqgmid = -ceqqgmid;
                }
                line_${::type}_${::corner}_${::section}_1000:
                
                capbd = here->BSIM4v5capbd;
                capbs = here->BSIM4v5capbs;
                cgso = here->BSIM4v5cgso;
                cgdo = here->BSIM4v5cgdo;
                cgbo = pParam->BSIM4v5cgbo;
                
                Csd = -(here->BSIM4v5cddb + here->BSIM4v5cgdb + here->BSIM4v5cbdb);
                Csg = -(here->BSIM4v5cdgb + here->BSIM4v5cggb + here->BSIM4v5cbgb);
                Css = -(here->BSIM4v5cdsb + here->BSIM4v5cgsb + here->BSIM4v5cbsb);
                if (here->BSIM4v5acnqsMod)
                {   T0 = omega * here->BSIM4v5taunet;
                    T1 = T0 * T0;
                    T2 = 1.0 / (1.0 + T1);
                    T3 = T0 * T2;
                    
                    gmr = here->BSIM4v5gm * T2;
                    gmbsr = here->BSIM4v5gmbs * T2;
                    gdsr = here->BSIM4v5gds * T2;
                    
                    gmi = -here->BSIM4v5gm * T3;
                    gmbsi = -here->BSIM4v5gmbs * T3;
                    gdsi = -here->BSIM4v5gds * T3;
                    
                    Cddr = here->BSIM4v5cddb * T2;
                    Cdgr = here->BSIM4v5cdgb * T2;
                    Cdsr = here->BSIM4v5cdsb * T2;
                    Cdbr = -(Cddr + Cdgr + Cdsr);
                    
                    /* WDLiu: Cxyi mulitplied by jomega below, and actually to be of conductance */
                    Cddi = here->BSIM4v5cddb * T3 * omega;
                    Cdgi = here->BSIM4v5cdgb * T3 * omega;
                    Cdsi = here->BSIM4v5cdsb * T3 * omega;
                    Cdbi = -(Cddi + Cdgi + Cdsi);
                    
                    Csdr = Csd * T2;
                    Csgr = Csg * T2;
                    Cssr = Css * T2;
                    Csbr = -(Csdr + Csgr + Cssr);
                    
                    Csdi = Csd * T3 * omega;
                    Csgi = Csg * T3 * omega;
                    Cssi = Css * T3 * omega;
                    Csbi = -(Csdi + Csgi + Cssi);
                    
                    Cgdr = -(Cddr + Csdr + here->BSIM4v5cbdb);
                    Cggr = -(Cdgr + Csgr + here->BSIM4v5cbgb);
                    Cgsr = -(Cdsr + Cssr + here->BSIM4v5cbsb);
                    Cgbr = -(Cgdr + Cggr + Cgsr);
                    
                    Cgdi = -(Cddi + Csdi);
                    Cggi = -(Cdgi + Csgi);
                    Cgsi = -(Cdsi + Cssi);
                    Cgbi = -(Cgdi + Cggi + Cgsi);
                }
                else /* QS */  
                {   gmr = here->BSIM4v5gm;
                    gmbsr = here->BSIM4v5gmbs;
                    gdsr = here->BSIM4v5gds;
                    gmi = gmbsi = gdsi = 0.0;
                    
                    Cddr = here->BSIM4v5cddb;
                    Cdgr = here->BSIM4v5cdgb;
                    Cdsr = here->BSIM4v5cdsb;
                    Cdbr = -(Cddr + Cdgr + Cdsr);
                    Cddi = Cdgi = Cdsi = Cdbi = 0.0;
                    
                    Csdr = Csd;
                    Csgr = Csg;
                    Cssr = Css;
                    Csbr = -(Csdr + Csgr + Cssr);
                    Csdi = Csgi = Cssi = Csbi = 0.0;
                    
                    Cgdr = here->BSIM4v5cgdb;
                    Cggr = here->BSIM4v5cggb;
                    Cgsr = here->BSIM4v5cgsb;
                    Cgbr = -(Cgdr + Cggr + Cgsr);
                    Cgdi = Cggi = Cgsi = Cgbi = 0.0;
                }
                
                
                if (here->BSIM4v5mode >= 0) 
                {   Gmr = gmr;
                    Gmbsr = gmbsr;
                    FwdSumr = Gmr + Gmbsr;
                    RevSumr = 0.0;
                    Gmi = gmi;
                    Gmbsi = gmbsi;
                    FwdSumi = Gmi + Gmbsi;
                    RevSumi = 0.0;
                    
                    gbbdp = -(here->BSIM4v5gbds);
                    gbbsp = here->BSIM4v5gbds + here->BSIM4v5gbgs + here->BSIM4v5gbbs;
                    gbdpg = here->BSIM4v5gbgs;
                    gbdpdp = here->BSIM4v5gbds;
                    gbdpb = here->BSIM4v5gbbs;
                    gbdpsp = -(gbdpg + gbdpdp + gbdpb);
                    
                    gbspdp = 0.0;
                    gbspg = 0.0;
                    gbspb = 0.0;
                    gbspsp = 0.0;
                    
                    if (${::TECH($::type,$::corner,$::section,igcMod)})
                    {   gIstotg = here->BSIM4v5gIgsg + here->BSIM4v5gIgcsg;
                        gIstotd = here->BSIM4v5gIgcsd;
                        gIstots = here->BSIM4v5gIgss + here->BSIM4v5gIgcss;
                        gIstotb = here->BSIM4v5gIgcsb;
                        
                        gIdtotg = here->BSIM4v5gIgdg + here->BSIM4v5gIgcdg;
                        gIdtotd = here->BSIM4v5gIgdd + here->BSIM4v5gIgcdd;
                        gIdtots = here->BSIM4v5gIgcds;
                        gIdtotb = here->BSIM4v5gIgcdb;
                    }
                    else
                    {   gIstotg = gIstotd = gIstots = gIstotb = 0.0;
                        gIdtotg = gIdtotd = gIdtots = gIdtotb = 0.0;
                    }
                    
                    if (${::TECH($::type,$::corner,$::section,igbMod)})
                    {   gIbtotg = here->BSIM4v5gIgbg;
                        gIbtotd = here->BSIM4v5gIgbd;
                        gIbtots = here->BSIM4v5gIgbs;
                        gIbtotb = here->BSIM4v5gIgbb;
                    }
                    else
                    gIbtotg = gIbtotd = gIbtots = gIbtotb = 0.0;
                    
                    if ((${::TECH($::type,$::corner,$::section,igcMod)} != 0) || (${::TECH($::type,$::corner,$::section,igbMod)} != 0))
                    {   gIgtotg = gIstotg + gIdtotg + gIbtotg;
                        gIgtotd = gIstotd + gIdtotd + gIbtotd ;
                        gIgtots = gIstots + gIdtots + gIbtots;
                        gIgtotb = gIstotb + gIdtotb + gIbtotb;
                    }
                    else
                    gIgtotg = gIgtotd = gIgtots = gIgtotb = 0.0;
                    
                    if (here->BSIM4v5rgateMod == 2)
                    T0 = *(cktState0 + here->BSIM4v5vges)
                    - *(cktState0 + here->BSIM4v5vgs);
                    else if (here->BSIM4v5rgateMod == 3)
                    T0 = *(cktState0 + here->BSIM4v5vgms)
                    - *(cktState0 + here->BSIM4v5vgs);
                    if (here->BSIM4v5rgateMod > 1)
                    {   gcrgd = here->BSIM4v5gcrgd * T0;
                        gcrgg = here->BSIM4v5gcrgg * T0;
                        gcrgs = here->BSIM4v5gcrgs * T0;
                        gcrgb = here->BSIM4v5gcrgb * T0;
                        gcrgg -= here->BSIM4v5gcrg;
                        gcrg = here->BSIM4v5gcrg;
                    }
                    else
                    gcrg = gcrgd = gcrgg = gcrgs = gcrgb = 0.0;
                    
                    if (here->BSIM4v5rgateMod == 3)
                    {   xcgmgmb = (cgdo + cgso + pParam->BSIM4v5cgbo) * omega;
                        xcgmdb = -cgdo * omega;
                        xcgmsb = -cgso * omega;
                        xcgmbb = -pParam->BSIM4v5cgbo * omega;
                        
                        xcdgmb = xcgmdb;
                        xcsgmb = xcgmsb;
                        xcbgmb = xcgmbb;
                        
                        xcggbr = Cggr * omega;
                        xcgdbr = Cgdr * omega;
                        xcgsbr = Cgsr * omega;
                        xcgbbr = -(xcggbr + xcgdbr + xcgsbr);
                        
                        xcdgbr = Cdgr * omega;
                        xcsgbr = Csgr * omega;
                        xcbgb = here->BSIM4v5cbgb * omega;
                    }
                    else
                    {   xcggbr = (Cggr + cgdo + cgso + pParam->BSIM4v5cgbo ) * omega;
                        xcgdbr = (Cgdr - cgdo) * omega;
                        xcgsbr = (Cgsr - cgso) * omega;
                        xcgbbr = -(xcggbr + xcgdbr + xcgsbr);
                        
                        xcdgbr = (Cdgr - cgdo) * omega;
                        xcsgbr = (Csgr - cgso) * omega;
                        xcbgb = (here->BSIM4v5cbgb - pParam->BSIM4v5cgbo) * omega;
                        
                        xcdgmb = xcsgmb = xcbgmb = 0.0;
                    }
                    xcddbr = (Cddr + here->BSIM4v5capbd + cgdo) * omega;
                    xcdsbr = Cdsr * omega;
                    xcsdbr = Csdr * omega;
                    xcssbr = (here->BSIM4v5capbs + cgso + Cssr) * omega;
                    
                    if (!here->BSIM4v5rbodyMod)
                    {   xcdbbr = -(xcdgbr + xcddbr + xcdsbr + xcdgmb);
                        xcsbbr = -(xcsgbr + xcsdbr + xcssbr + xcsgmb);
                        
                        xcbdb = (here->BSIM4v5cbdb - here->BSIM4v5capbd) * omega;
                        xcbsb = (here->BSIM4v5cbsb - here->BSIM4v5capbs) * omega;
                        xcdbdb = 0.0;
                    }
                    else
                    {   xcdbbr = Cdbr * omega;
                        xcsbbr = -(xcsgbr + xcsdbr + xcssbr + xcsgmb)
                        + here->BSIM4v5capbs * omega;
                        
                        xcbdb = here->BSIM4v5cbdb * omega;
                        xcbsb = here->BSIM4v5cbsb * omega;
                        
                        xcdbdb = -here->BSIM4v5capbd * omega;
                        xcsbsb = -here->BSIM4v5capbs * omega;
                    }
                    xcbbb = -(xcbdb + xcbgb + xcbsb + xcbgmb);
                    
                    xcdgbi = Cdgi;
                    xcsgbi = Csgi;
                    xcddbi = Cddi;
                    xcdsbi = Cdsi;
                    xcsdbi = Csdi;
                    xcssbi = Cssi;
                    xcdbbi = Cdbi;
                    xcsbbi = Csbi;
                    xcggbi = Cggi;
                    xcgdbi = Cgdi;
                    xcgsbi = Cgsi;
                    xcgbbi = Cgbi;
                } 
                else /* Reverse mode */
                {   Gmr = -gmr;
                    Gmbsr = -gmbsr;
                    FwdSumr = 0.0;
                    RevSumr = -(Gmr + Gmbsr);
                    Gmi = -gmi;
                    Gmbsi = -gmbsi;
                    FwdSumi = 0.0;
                    RevSumi = -(Gmi + Gmbsi);
                    
                    gbbsp = -(here->BSIM4v5gbds);
                    gbbdp = here->BSIM4v5gbds + here->BSIM4v5gbgs + here->BSIM4v5gbbs;
                    
                    gbdpg = 0.0;
                    gbdpsp = 0.0;
                    gbdpb = 0.0;
                    gbdpdp = 0.0;
                    
                    gbspg = here->BSIM4v5gbgs;
                    gbspsp = here->BSIM4v5gbds;
                    gbspb = here->BSIM4v5gbbs;
                    gbspdp = -(gbspg + gbspsp + gbspb);
                    
                    if (${::TECH($::type,$::corner,$::section,igcMod)})
                    {   gIstotg = here->BSIM4v5gIgsg + here->BSIM4v5gIgcdg;
                        gIstotd = here->BSIM4v5gIgcds;
                        gIstots = here->BSIM4v5gIgss + here->BSIM4v5gIgcdd;
                        gIstotb = here->BSIM4v5gIgcdb;
                        
                        gIdtotg = here->BSIM4v5gIgdg + here->BSIM4v5gIgcsg;
                        gIdtotd = here->BSIM4v5gIgdd + here->BSIM4v5gIgcss;
                        gIdtots = here->BSIM4v5gIgcsd;
                        gIdtotb = here->BSIM4v5gIgcsb;
                    }
                    else
                    {   gIstotg = gIstotd = gIstots = gIstotb = 0.0;
                        gIdtotg = gIdtotd = gIdtots = gIdtotb  = 0.0;
                    }
                    
                    if (${::TECH($::type,$::corner,$::section,igbMod)})
                    {   gIbtotg = here->BSIM4v5gIgbg;
                        gIbtotd = here->BSIM4v5gIgbs;
                        gIbtots = here->BSIM4v5gIgbd;
                        gIbtotb = here->BSIM4v5gIgbb;
                    }
                    else
                    gIbtotg = gIbtotd = gIbtots = gIbtotb = 0.0;
                    
                    if ((${::TECH($::type,$::corner,$::section,igcMod)} != 0) || (${::TECH($::type,$::corner,$::section,igbMod)} != 0))
                    {   gIgtotg = gIstotg + gIdtotg + gIbtotg;
                        gIgtotd = gIstotd + gIdtotd + gIbtotd ;
                        gIgtots = gIstots + gIdtots + gIbtots;
                        gIgtotb = gIstotb + gIdtotb + gIbtotb;
                    }
                    else
                    gIgtotg = gIgtotd = gIgtots = gIgtotb = 0.0;
                    
                    if (here->BSIM4v5rgateMod == 2)
                    T0 = *(cktState0 + here->BSIM4v5vges)
                    - *(cktState0 + here->BSIM4v5vgs);
                    else if (here->BSIM4v5rgateMod == 3)
                    T0 = *(cktState0 + here->BSIM4v5vgms)
                    - *(cktState0 + here->BSIM4v5vgs);
                    if (here->BSIM4v5rgateMod > 1)
                    {   gcrgd = here->BSIM4v5gcrgs * T0;
                        gcrgg = here->BSIM4v5gcrgg * T0;
                        gcrgs = here->BSIM4v5gcrgd * T0;
                        gcrgb = here->BSIM4v5gcrgb * T0;
                        gcrgg -= here->BSIM4v5gcrg;
                        gcrg = here->BSIM4v5gcrg;
                    }
                    else
                    gcrg = gcrgd = gcrgg = gcrgs = gcrgb = 0.0;
                    
                    if (here->BSIM4v5rgateMod == 3)
                    {   xcgmgmb = (cgdo + cgso + pParam->BSIM4v5cgbo) * omega;
                        xcgmdb = -cgdo * omega;
                        xcgmsb = -cgso * omega;
                        xcgmbb = -pParam->BSIM4v5cgbo * omega;
                        
                        xcdgmb = xcgmdb;
                        xcsgmb = xcgmsb;
                        xcbgmb = xcgmbb;
                        
                        xcggbr = Cggr * omega;
                        xcgdbr = Cgsr * omega;
                        xcgsbr = Cgdr * omega;
                        xcgbbr = -(xcggbr + xcgdbr + xcgsbr);
                        
                        xcdgbr = Csgr * omega;
                        xcsgbr = Cdgr * omega;
                        xcbgb = here->BSIM4v5cbgb * omega;
                    }
                    else
                    {   xcggbr = (Cggr + cgdo + cgso + pParam->BSIM4v5cgbo ) * omega;
                        xcgdbr = (Cgsr - cgdo) * omega;
                        xcgsbr = (Cgdr - cgso) * omega;
                        xcgbbr = -(xcggbr + xcgdbr + xcgsbr);
                        
                        xcdgbr = (Csgr - cgdo) * omega;
                        xcsgbr = (Cdgr - cgso) * omega;
                        xcbgb = (here->BSIM4v5cbgb - pParam->BSIM4v5cgbo) * omega;
                        
                        xcdgmb = xcsgmb = xcbgmb = 0.0;
                    }
                    xcddbr = (here->BSIM4v5capbd + cgdo + Cssr) * omega;
                    xcdsbr = Csdr * omega;
                    xcsdbr = Cdsr * omega;
                    xcssbr = (Cddr + here->BSIM4v5capbs + cgso) * omega;
                    
                    if (!here->BSIM4v5rbodyMod)
                    {   xcdbbr = -(xcdgbr + xcddbr + xcdsbr + xcdgmb);
                        xcsbbr = -(xcsgbr + xcsdbr + xcssbr + xcsgmb);
                        
                        xcbdb = (here->BSIM4v5cbsb - here->BSIM4v5capbd) * omega;
                        xcbsb = (here->BSIM4v5cbdb - here->BSIM4v5capbs) * omega;
                        xcdbdb = 0.0;
                    }
                    else
                    {   xcdbbr = -(xcdgbr + xcddbr + xcdsbr + xcdgmb)
                        + here->BSIM4v5capbd * omega;
                        xcsbbr = Cdbr * omega;
                        
                        xcbdb = here->BSIM4v5cbsb * omega;
                        xcbsb = here->BSIM4v5cbdb * omega;
                        xcdbdb = -here->BSIM4v5capbd * omega;
                        xcsbsb = -here->BSIM4v5capbs * omega;
                    }
                    xcbbb = -(xcbgb + xcbdb + xcbsb + xcbgmb);
                    
                    xcdgbi = Csgi;
                    xcsgbi = Cdgi;
                    xcddbi = Cssi;
                    xcdsbi = Csdi;
                    xcsdbi = Cdsi;
                    xcssbi = Cddi;
                    xcdbbi = Csbi;
                    xcsbbi = Cdbi;
                    xcggbi = Cggi;
                    xcgdbi = Cgsi;
                    xcgsbi = Cgdi;
                    xcgbbi = Cgbi;
                }
                if (${::TECH($::type,$::corner,$::section,rdsMod)} == 1)
                {   gstot = here->BSIM4v5gstot;
                    gstotd = here->BSIM4v5gstotd;
                    gstotg = here->BSIM4v5gstotg;
                    gstots = here->BSIM4v5gstots - gstot;
                    gstotb = here->BSIM4v5gstotb;
                    
                    gdtot = here->BSIM4v5gdtot;
                    gdtotd = here->BSIM4v5gdtotd - gdtot;
                    gdtotg = here->BSIM4v5gdtotg;
                    gdtots = here->BSIM4v5gdtots;
                    gdtotb = here->BSIM4v5gdtotb;
                }
                else
                {   gstot = gstotd = gstotg = gstots = gstotb = 0.0;
                    gdtot = gdtotd = gdtotg = gdtots = gdtotb = 0.0;
                }
                double cd;
                double model;
                double Leffsq;
                double esat;
                double DelClm;
                double EffFreq;
                double freq;
                double temp;
                double N0;
                double Nl;
                double Ssi;
                cd = fabs(here->BSIM4v5cd);
                Leff = pParam->BSIM4v5leff - 2.0 * ${::TECH($::type,$::corner,$::section,lintnoi)};
                Leffsq = Leff * Leff;
                esat = 2.0 * here->BSIM4v5vsattemp / here->BSIM4v5ueff;
                if(${::TECH($::type,$::corner,$::section,em)}<=0.0) DelClm = 0.0; /* flicker noise modified -JX  */
                else {
                    T0 = ((((Vds - here->BSIM4v5Vdseff) / pParam->BSIM4v5litl)
                    + ${::TECH($::type,$::corner,$::section,em)}) / esat);
                    DelClm = pParam->BSIM4v5litl * log (MAX(T0, N_MINLOG));
                    if (DelClm < 0.0)        DelClm = 0.0;  /* bugfix */
                }
                EffFreq = pow(freq, ${::TECH($::type,$::corner,$::section,ef)});
                T1 = CHARGE * CHARGE * CONSTboltz * cd * $::TEMP * here->BSIM4v5ueff;
                T2 = 1.0e10 * EffFreq * here->BSIM4v5Abulk * ${::TECH($::type,$::corner,$::section,coxe)} * Leffsq;
                N0 = ${::TECH($::type,$::corner,$::section,coxe)} * here->BSIM4v5Vgsteff / CHARGE;
                Nl = ${::TECH($::type,$::corner,$::section,coxe)} * here->BSIM4v5Vgsteff
                * (1.0 - here->BSIM4v5AbovVgst2Vtm * here->BSIM4v5Vdseff) / CHARGE;
                
                T3 = ${::TECH($::type,$::corner,$::section,oxideTrapDensityA)}
                * log(MAX(((N0 + here->BSIM4v5nstar) / (Nl + here->BSIM4v5nstar)), N_MINLOG));
                T4 = ${::TECH($::type,$::corner,$::section,oxideTrapDensityB)} * (N0 - Nl);
                T5 = ${::TECH($::type,$::corner,$::section,oxideTrapDensityC)} * 0.5 * (N0 * N0 - Nl * Nl);
                
                T6 = CONSTboltz * $::TEMP * cd * cd;
                T7 = 1.0e10 * EffFreq * Leffsq * pParam->BSIM4v5weff * here->BSIM4v5nf;
                T8 = ${::TECH($::type,$::corner,$::section,oxideTrapDensityA)} + ${::TECH($::type,$::corner,$::section,oxideTrapDensityB)} * Nl
                + ${::TECH($::type,$::corner,$::section,oxideTrapDensityC)} * Nl * Nl;
                T9 = (Nl + here->BSIM4v5nstar) * (Nl + here->BSIM4v5nstar);
                Ssi = T1 / T2 * (T3 + T4 + T5) + T6 / T7 * DelClm * T8 / T9;
                Captured_Ssi=Ssi;
                Captured_EffFreq=EffFreq;
                Captured_Thermal_Noise = 4 * CONSTboltz * $::TEMP * here->BSIM4v5gds;
                #Foreach: pointer $::bsim_access_fields {
                    *${pointer}_out=$pointer;
                } 
//                *Gds_out=here->BSIM4v5gds;
 //               *Gm_out=here->BSIM4v5gm;
  //              *Gmb_out=here->BSIM4v5gmbs;
   //             *Ids_out=here->BSIM4v5IdovVds;
            }
        }
    }
}
void register_tsmc040() {
            #For: {set ::section 1} {[info exists ::bin($::t,$::section,lmin)]} {incr ::section} {
		#tcl set corner_index 0
	        #Foreach: corner {ss tt ff} {
		    #tcl set corner_index
		    #tcl set type_index 0
		    #Foreach: type {nch pch} {
		        #tcl set index [expr 6*($::section-1)+2*$corner_index+$type_index]
			Gamma_tsmc040_Calc_Functions[$index]=Gamma_tsmc040_Calc_${type}_${corner}_${::section};
			#tcl incr type_index
		    }
		    #tcl incr corner_index
		}
	    }

}
void Gamma_tsmc040_Calc(int type,int corner,float Vgs_in,float Vds_in,float Vbs_in,float L_in,float W_in
		#Foreach: pointer $::bsim_access_fields {
		    ,float *${pointer}_out
		} 
) {
    float M=ceilf(W_in/(L_in*10));
    float W=W_in/M;
    float L=L_in;
    int section;
    #tcl set path $::env(RAMSPICE)
    #include "$path/Etc/Tech_DB/tsmc040/sort_tsmc040"
    int index=6*section+2*corner+type;
    Gamma_tsmc040_Calc_Functions[index](Vgs_in,Vds_in,Vbs_in,L,W,M		
    #Foreach: pointer $::bsim_access_fields {
		    ,${pointer}_out
		} 
);
}

