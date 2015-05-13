#include "ramspice_types.h"
/**********
* Copyright 1990 Regents of the University of California. All rights reserved.
* File: b3.c
* Author: 1995 Min-Chie Jeng and Mansun Chan. 
* Modified by Paolo Nenzi 2002
**********/

/* 
* Release Notes: 
* BSIM3v1v3.1,   Released by yuhua  96/12/08
*/


#include "ngspice/ngspice.h"
#include "ngspice/devdefs.h"
#include "bsim3v1def.h"
#include "ngspice/suffix.h"

IFparm BSIM3v1pTable[] = { /* parameters */
    IOP( "l",   BSIM3v1_L,      IF_REAL   , "Length"),
    IOP( "w",   BSIM3v1_W,      IF_REAL   , "Width"),
    IOP( "m",   BSIM3v1_M,      IF_REAL   , "Parallel multiplier"),
    IOP( "ad",  BSIM3v1_AD,     IF_REAL   , "Drain area"),
    IOP( "as",  BSIM3v1_AS,     IF_REAL   , "Source area"),
    IOP( "pd",  BSIM3v1_PD,     IF_REAL   , "Drain perimeter"),
    IOP( "ps",  BSIM3v1_PS,     IF_REAL   , "Source perimeter"),
    IOP( "nrd", BSIM3v1_NRD,    IF_REAL   , "Number of squares in drain"),
    IOP( "nrs", BSIM3v1_NRS,    IF_REAL   , "Number of squares in source"),
    IOP( "off", BSIM3v1_OFF,    IF_FLAG   , "Device is initially off"),
    IOP( "nqsmod", BSIM3v1_NQSMOD, IF_INTEGER, "Non-quasi-static model selector"),
    IP( "ic",  BSIM3v1_IC,     IF_REALVEC , "Vector of DS,GS,BS initial voltages"),
    OP( "gmbs",         BSIM3v1_GMBS,       IF_REAL,    "Gmb"),
    OP( "gm",           BSIM3v1_GM,         IF_REAL,    "Gm"),
    OP( "gds",          BSIM3v1_GDS,        IF_REAL,    "Gds"),
    OP( "vdsat",        BSIM3v1_VDSAT,      IF_REAL,    "Vdsat"),
    OP( "vth",          BSIM3v1_VON,        IF_REAL,    "Vth"),
    OP( "id",           BSIM3v1_CD,         IF_REAL,    "Ids"),
    OP( "vbs",          BSIM3v1_VBS,        IF_REAL,    "Vbs"),
    OP( "vgs",          BSIM3v1_VGS,        IF_REAL,    "Vgs"),
    OP( "vds",          BSIM3v1_VDS,        IF_REAL,    "Vds"),
};

IFparm BSIM3v1mPTable[] = { /* model parameters */
    IOP( "capmod", BSIM3v1_MOD_CAPMOD, IF_INTEGER, "Capacitance model selector"),
    IOP( "nqsmod", BSIM3v1_MOD_NQSMOD, IF_INTEGER, "Non-quasi-static model selector"),
    IOP( "mobmod", BSIM3v1_MOD_MOBMOD, IF_INTEGER, "Mobility model selector"),
    IOP( "noimod", BSIM3v1_MOD_NOIMOD, IF_INTEGER, "Noise model selector"),
    IOP( "paramchk", BSIM3v1_MOD_PARAMCHK, IF_INTEGER, "Model parameter checking selector"),
    IOP( "binunit", BSIM3v1_MOD_BINUNIT, IF_INTEGER, "Bin  unit  selector"),
    IOP( "version", BSIM3v1_MOD_VERSION, IF_REAL, " parameter for model version"),
    IOP( "tox", BSIM3v1_MOD_TOX, IF_REAL, "Gate oxide thickness in meters"),
    
    IOP( "cdsc", BSIM3v1_MOD_CDSC, IF_REAL, "Drain/Source and channel coupling capacitance"),
    IOP( "cdscb", BSIM3v1_MOD_CDSCB, IF_REAL, "Body-bias dependence of cdsc"), 
    IOP( "cdscd", BSIM3v1_MOD_CDSCD, IF_REAL, "Drain-bias dependence of cdsc"), 
    IOP( "cit", BSIM3v1_MOD_CIT, IF_REAL, "Interface state capacitance"),
    IOP( "nfactor", BSIM3v1_MOD_NFACTOR, IF_REAL, "Subthreshold swing Coefficient"),
    IOP( "xj", BSIM3v1_MOD_XJ, IF_REAL, "Junction depth in meters"),
    IOP( "vsat", BSIM3v1_MOD_VSAT, IF_REAL, "Saturation velocity at tnom"),
    IOP( "at", BSIM3v1_MOD_AT, IF_REAL, "Temperature coefficient of vsat"),
    IOP( "a0", BSIM3v1_MOD_A0, IF_REAL, "Non-uniform depletion width effect coefficient."), 
    IOP( "ags", BSIM3v1_MOD_AGS, IF_REAL, "Gate bias  coefficient of Abulk."), 
    IOP( "a1", BSIM3v1_MOD_A1, IF_REAL, "Non-saturation effect coefficient"),
    IOP( "a2", BSIM3v1_MOD_A2, IF_REAL, "Non-saturation effect coefficient"),
    IOP( "keta", BSIM3v1_MOD_KETA, IF_REAL, "Body-bias coefficient of non-uniform depletion width effect."),
    IOP( "nsub", BSIM3v1_MOD_NSUB, IF_REAL, "Substrate doping concentration"),
    IOP( "nch", BSIM3v1_MOD_NPEAK, IF_REAL, "Channel doping concentration"),
    IOP( "ngate", BSIM3v1_MOD_NGATE, IF_REAL, "Poly-gate doping concentration"),
    IOP( "gamma1", BSIM3v1_MOD_GAMMA1, IF_REAL, "Vth body coefficient"),
    IOP( "gamma2", BSIM3v1_MOD_GAMMA2, IF_REAL, "Vth body coefficient"),
    IOP( "vbx", BSIM3v1_MOD_VBX, IF_REAL, "Vth transition body Voltage"),
    IOP( "vbm", BSIM3v1_MOD_VBM, IF_REAL, "Maximum body voltage"),
    
    IOP( "xt", BSIM3v1_MOD_XT, IF_REAL, "Doping depth"),
    IOP( "k1", BSIM3v1_MOD_K1, IF_REAL, "Bulk effect coefficient 1"),
    IOP( "kt1", BSIM3v1_MOD_KT1, IF_REAL, "Temperature coefficient of Vth"),
    IOP( "kt1l", BSIM3v1_MOD_KT1L, IF_REAL, "Temperature coefficient of Vth"),
    IOP( "kt2",  BSIM3v1_MOD_KT2, IF_REAL, "Body-coefficient of kt1"),
    IOP( "k2",   BSIM3v1_MOD_K2,  IF_REAL, "Bulk effect coefficient 2"),
    IOP( "k3",   BSIM3v1_MOD_K3,  IF_REAL, "Narrow width effect coefficient"),
    IOP( "k3b",  BSIM3v1_MOD_K3B, IF_REAL, "Body effect coefficient of k3"),
    IOP( "w0",   BSIM3v1_MOD_W0,  IF_REAL, "Narrow width effect parameter"),
    IOP( "nlx",  BSIM3v1_MOD_NLX, IF_REAL, "Lateral non-uniform doping effect"),
    IOP( "dvt0", BSIM3v1_MOD_DVT0, IF_REAL, "Short channel effect coeff. 0"),
    IOP( "dvt1", BSIM3v1_MOD_DVT1, IF_REAL, "Short channel effect coeff. 1"),
    IOP( "dvt2", BSIM3v1_MOD_DVT2, IF_REAL, "Short channel effect coeff. 2"),
    IOP( "dvt0w", BSIM3v1_MOD_DVT0W, IF_REAL, "Narrow Width coeff. 0"),
    IOP( "dvt1w", BSIM3v1_MOD_DVT1W, IF_REAL, "Narrow Width effect coeff. 1"),
    IOP( "dvt2w", BSIM3v1_MOD_DVT2W, IF_REAL, "Narrow Width effect coeff. 2"),
    IOP( "drout", BSIM3v1_MOD_DROUT, IF_REAL, "DIBL coefficient of output resistance"),
    IOP( "dsub", BSIM3v1_MOD_DSUB, IF_REAL, "DIBL coefficient in the subthreshold region"),
    IOP( "vth0", BSIM3v1_MOD_VTH0, IF_REAL,"Threshold voltage"),
    IOP( "vtho", BSIM3v1_MOD_VTH0, IF_REAL,"Threshold voltage"),
    IOP( "ua", BSIM3v1_MOD_UA, IF_REAL, "Linear gate dependence of mobility"),
    IOP( "ua1", BSIM3v1_MOD_UA1, IF_REAL, "Temperature coefficient of ua"),
    IOP( "ub", BSIM3v1_MOD_UB, IF_REAL, "Quadratic gate dependence of mobility"),
    IOP( "ub1", BSIM3v1_MOD_UB1, IF_REAL, "Temperature coefficient of ub"),
    IOP( "uc", BSIM3v1_MOD_UC, IF_REAL, "Body-bias dependence of mobility"),
    IOP( "uc1", BSIM3v1_MOD_UC1, IF_REAL, "Temperature coefficient of uc"),
    IOP( "u0", BSIM3v1_MOD_U0, IF_REAL, "Low-field mobility at Tnom"),
    IOP( "ute", BSIM3v1_MOD_UTE, IF_REAL, "Temperature coefficient of mobility"),
    IOP( "voff", BSIM3v1_MOD_VOFF, IF_REAL, "Threshold voltage offset"),
    IOP( "tnom", BSIM3v1_MOD_TNOM, IF_REAL, "Parameter measurement temperature"),
    IOP( "cgso", BSIM3v1_MOD_CGSO, IF_REAL, "Gate-source overlap capacitance per width"),
    IOP( "cgdo", BSIM3v1_MOD_CGDO, IF_REAL, "Gate-drain overlap capacitance per width"),
    IOP( "cgbo", BSIM3v1_MOD_CGBO, IF_REAL, "Gate-bulk overlap capacitance per length"),
    IOP( "xpart", BSIM3v1_MOD_XPART, IF_REAL, "Channel charge partitioning"),
    IOP( "elm", BSIM3v1_MOD_ELM, IF_REAL, "Non-quasi-static Elmore Constant Parameter"),
    IOP( "delta", BSIM3v1_MOD_DELTA, IF_REAL, "Effective Vds parameter"),
    IOP( "rsh", BSIM3v1_MOD_RSH, IF_REAL, "Source-drain sheet resistance"),
    IOP( "rdsw", BSIM3v1_MOD_RDSW, IF_REAL, "Source-drain resistance per width"),    
    
    IOP( "prwg", BSIM3v1_MOD_PRWG, IF_REAL, "Gate-bias effect on parasitic resistance "),    
    IOP( "prwb", BSIM3v1_MOD_PRWB, IF_REAL, "Body-effect on parasitic resistance "),    
    
    IOP( "prt", BSIM3v1_MOD_PRT, IF_REAL, "Temperature coefficient of parasitic resistance "),    
    IOP( "eta0", BSIM3v1_MOD_ETA0, IF_REAL, "Subthreshold region DIBL coefficient"),
    IOP( "etab", BSIM3v1_MOD_ETAB, IF_REAL, "Subthreshold region DIBL coefficient"),
    IOP( "pclm", BSIM3v1_MOD_PCLM, IF_REAL, "Channel length modulation Coefficient"),
    IOP( "pdiblc1", BSIM3v1_MOD_PDIBL1, IF_REAL, "Drain-induced barrier lowering coefficient"),   
    IOP( "pdiblc2", BSIM3v1_MOD_PDIBL2, IF_REAL, "Drain-induced barrier lowering coefficient"),   
    IOP( "pdiblcb", BSIM3v1_MOD_PDIBLB, IF_REAL, "Body-effect on drain-induced barrier lowering"),   
    IOP( "pscbe1", BSIM3v1_MOD_PSCBE1, IF_REAL, "Substrate current body-effect coefficient"),   
    IOP( "pscbe2", BSIM3v1_MOD_PSCBE2, IF_REAL, "Substrate current body-effect coefficient"),   
    IOP( "pvag", BSIM3v1_MOD_PVAG, IF_REAL, "Gate dependence of output resistance parameter"),   
    IOP( "js", BSIM3v1_MOD_JS, IF_REAL, "Source/drain junction reverse saturation current density"),
    IOP( "jsw", BSIM3v1_MOD_JSW, IF_REAL, "Sidewall junction reverse saturation current density"),
    IOP( "pb", BSIM3v1_MOD_PB, IF_REAL, "Source/drain junction built-in potential"),
    IOP( "nj", BSIM3v1_MOD_NJ, IF_REAL, "Source/drain junction emission coefficient"),
    IOP( "xti", BSIM3v1_MOD_XTI, IF_REAL, "Junction current temperature exponent"),
    IOP( "mj", BSIM3v1_MOD_MJ, IF_REAL, "Source/drain bottom junction capacitance grading coefficient"),
    IOP( "pbsw", BSIM3v1_MOD_PBSW, IF_REAL, "Source/drain sidewall junction capacitance built in potential"),
    IOP( "mjsw", BSIM3v1_MOD_MJSW, IF_REAL, "Source/drain sidewall junction capacitance grading coefficient"),
    IOP( "pbswg", BSIM3v1_MOD_PBSWG, IF_REAL, "Source/drain (gate side) sidewall junction capacitance built in potential"),
    IOP( "mjswg", BSIM3v1_MOD_MJSWG, IF_REAL, "Source/drain (gate side) sidewall junction capacitance grading coefficient"),
    IOP( "cj", BSIM3v1_MOD_CJ, IF_REAL, "Source/drain bottom junction capacitance per unit area"),
    IOP( "vfbcv", BSIM3v1_MOD_VFBCV, IF_REAL, "Flat Band Voltage parameter for capmod=0 only"),
    IOP( "cjsw", BSIM3v1_MOD_CJSW, IF_REAL, "Source/drain sidewall junction capacitance per unit periphery"),
    
    IOP( "cjswg", BSIM3v1_MOD_CJSWG, IF_REAL, "Source/drain (gate side) sidewall junction capacitance per unit width"),
    IOP( "lint", BSIM3v1_MOD_LINT, IF_REAL, "Length reduction parameter"),
    IOP( "ll",   BSIM3v1_MOD_LL, IF_REAL, "Length reduction parameter"),
    IOP( "lln",  BSIM3v1_MOD_LLN, IF_REAL, "Length reduction parameter"),
    IOP( "lw",   BSIM3v1_MOD_LW,  IF_REAL, "Length reduction parameter"),
    IOP( "lwn",  BSIM3v1_MOD_LWN, IF_REAL, "Length reduction parameter"),
    IOP( "lwl",  BSIM3v1_MOD_LWL, IF_REAL, "Length reduction parameter"),
    IOP( "lmin", BSIM3v1_MOD_LMIN, IF_REAL, "Minimum length for the model"),
    IOP( "lmax", BSIM3v1_MOD_LMAX, IF_REAL, "Maximum length for the model"),
    
    IOP( "wr",   BSIM3v1_MOD_WR, IF_REAL, "Width dependence of rds"),
    IOP( "wint", BSIM3v1_MOD_WINT, IF_REAL, "Width reduction parameter"),
    IOP( "dwg",  BSIM3v1_MOD_DWG, IF_REAL, "Width reduction parameter"),
    IOP( "dwb",  BSIM3v1_MOD_DWB, IF_REAL, "Width reduction parameter"),
    
    IOP( "wl",   BSIM3v1_MOD_WL, IF_REAL, "Width reduction parameter"),
    IOP( "wln",  BSIM3v1_MOD_WLN, IF_REAL, "Width reduction parameter"),
    IOP( "ww",   BSIM3v1_MOD_WW, IF_REAL, "Width reduction parameter"),
    IOP( "wwn",  BSIM3v1_MOD_WWN, IF_REAL, "Width reduction parameter"),
    IOP( "wwl",  BSIM3v1_MOD_WWL, IF_REAL, "Width reduction parameter"),
    IOP( "wmin", BSIM3v1_MOD_WMIN, IF_REAL, "Minimum width for the model"),
    IOP( "wmax", BSIM3v1_MOD_WMAX, IF_REAL, "Maximum width for the model"),
    
    IOP( "b0",  BSIM3v1_MOD_B0, IF_REAL, "Abulk narrow width parameter"),
    IOP( "b1",  BSIM3v1_MOD_B1, IF_REAL, "Abulk narrow width parameter"),
    
    IOP( "cgsl", BSIM3v1_MOD_CGSL, IF_REAL, "New C-V model parameter"),
    IOP( "cgdl", BSIM3v1_MOD_CGDL, IF_REAL, "New C-V model parameter"),
    IOP( "ckappa", BSIM3v1_MOD_CKAPPA, IF_REAL, "New C-V model parameter"),
    IOP( "cf",  BSIM3v1_MOD_CF, IF_REAL, "Fringe capacitance parameter"),
    IOP( "clc", BSIM3v1_MOD_CLC, IF_REAL, "Vdsat parameter for C-V model"),
    IOP( "cle", BSIM3v1_MOD_CLE, IF_REAL, "Vdsat parameter for C-V model"),
    IOP( "dwc", BSIM3v1_MOD_DWC, IF_REAL, "Delta W for C-V model"),
    IOP( "dlc", BSIM3v1_MOD_DLC, IF_REAL, "Delta L for C-V model"),
    
    IOP( "alpha0", BSIM3v1_MOD_ALPHA0, IF_REAL, "substrate current model parameter"),
    IOP( "beta0", BSIM3v1_MOD_BETA0, IF_REAL, "substrate current model parameter"),
    
    IOP( "lcdsc",  BSIM3v1_MOD_LCDSC, IF_REAL, "Length dependence of cdsc"),
    IOP( "lcdscb", BSIM3v1_MOD_LCDSCB, IF_REAL, "Length dependence of cdscb"),
    IOP( "lcdscd", BSIM3v1_MOD_LCDSCD, IF_REAL, "Length dependence of cdscd"),
    IOP( "lcit",   BSIM3v1_MOD_LCIT,  IF_REAL, "Length dependence of cit"),
    IOP( "lnfactor", BSIM3v1_MOD_LNFACTOR, IF_REAL, "Length dependence of nfactor"),
    IOP( "lxj", BSIM3v1_MOD_LXJ, IF_REAL, "Length dependence of xj"),
    IOP( "lvsat", BSIM3v1_MOD_LVSAT, IF_REAL, "Length dependence of vsat"),
    IOP( "lat", BSIM3v1_MOD_LAT, IF_REAL, "Length dependence of at"),
    IOP( "la0", BSIM3v1_MOD_LA0, IF_REAL, "Length dependence of a0"), 
    IOP( "lags", BSIM3v1_MOD_LAGS, IF_REAL, "Length dependence of ags"), 
    IOP( "la1", BSIM3v1_MOD_LA1, IF_REAL, "Length dependence of a1"),
    IOP( "la2", BSIM3v1_MOD_LA2, IF_REAL, "Length dependence of a2"),
    IOP( "lketa", BSIM3v1_MOD_LKETA, IF_REAL, "Length dependence of keta"),
    IOP( "lnsub", BSIM3v1_MOD_LNSUB, IF_REAL, "Length dependence of nsub"),
    IOP( "lnch",  BSIM3v1_MOD_LNPEAK, IF_REAL, "Length dependence of nch"),
    IOP( "lngate", BSIM3v1_MOD_LNGATE, IF_REAL, "Length dependence of ngate"),
    IOP( "lgamma1", BSIM3v1_MOD_LGAMMA1, IF_REAL, "Length dependence of gamma1"),
    IOP( "lgamma2", BSIM3v1_MOD_LGAMMA2, IF_REAL, "Length dependence of gamma2"),
    IOP( "lvbx", BSIM3v1_MOD_LVBX, IF_REAL, "Length dependence of vbx"),
    IOP( "lvbm", BSIM3v1_MOD_LVBM, IF_REAL, "Length dependence of vbm"),
    IOP( "lxt",  BSIM3v1_MOD_LXT,  IF_REAL, "Length dependence of xt"),
    IOP( "lk1",   BSIM3v1_MOD_LK1,  IF_REAL, "Length dependence of k1"),
    IOP( "lkt1",  BSIM3v1_MOD_LKT1, IF_REAL, "Length dependence of kt1"),
    IOP( "lkt1l", BSIM3v1_MOD_LKT1L, IF_REAL, "Length dependence of kt1l"),
    IOP( "lkt2",  BSIM3v1_MOD_LKT2, IF_REAL, "Length dependence of kt2"),
    IOP( "lk2",   BSIM3v1_MOD_LK2,  IF_REAL, "Length dependence of k2"),
    IOP( "lk3",   BSIM3v1_MOD_LK3,  IF_REAL, "Length dependence of k3"),
    IOP( "lk3b",  BSIM3v1_MOD_LK3B, IF_REAL, "Length dependence of k3b"),
    IOP( "lw0",   BSIM3v1_MOD_LW0,  IF_REAL, "Length dependence of w0"),
    IOP( "lnlx",  BSIM3v1_MOD_LNLX, IF_REAL, "Length dependence of nlx"),
    IOP( "ldvt0", BSIM3v1_MOD_LDVT0, IF_REAL, "Length dependence of dvt0"),
    IOP( "ldvt1", BSIM3v1_MOD_LDVT1, IF_REAL, "Length dependence of dvt1"),
    IOP( "ldvt2", BSIM3v1_MOD_LDVT2, IF_REAL, "Length dependence of dvt2"),
    IOP( "ldvt0w", BSIM3v1_MOD_LDVT0W, IF_REAL, "Length dependence of dvt0w"),
    IOP( "ldvt1w", BSIM3v1_MOD_LDVT1W, IF_REAL, "Length dependence of dvt1w"),
    IOP( "ldvt2w", BSIM3v1_MOD_LDVT2W, IF_REAL, "Length dependence of dvt2w"),
    IOP( "ldrout", BSIM3v1_MOD_LDROUT, IF_REAL, "Length dependence of drout"),
    IOP( "ldsub", BSIM3v1_MOD_LDSUB, IF_REAL, "Length dependence of dsub"),
    IOP( "lvth0", BSIM3v1_MOD_LVTH0, IF_REAL,"Length dependence of vto"),
    IOP( "lvtho", BSIM3v1_MOD_LVTH0, IF_REAL,"Length dependence of vto"),
    IOP( "lua",  BSIM3v1_MOD_LUA, IF_REAL, "Length dependence of ua"),
    IOP( "lua1", BSIM3v1_MOD_LUA1, IF_REAL, "Length dependence of ua1"),
    IOP( "lub", BSIM3v1_MOD_LUB, IF_REAL, "Length dependence of ub"),
    IOP( "lub1", BSIM3v1_MOD_LUB1, IF_REAL, "Length dependence of ub1"),
    IOP( "luc",  BSIM3v1_MOD_LUC, IF_REAL, "Length dependence of uc"),
    IOP( "luc1", BSIM3v1_MOD_LUC1, IF_REAL, "Length dependence of uc1"),
    IOP( "lu0",  BSIM3v1_MOD_LU0, IF_REAL, "Length dependence of u0"),
    IOP( "lute", BSIM3v1_MOD_LUTE, IF_REAL, "Length dependence of ute"),
    IOP( "lvoff", BSIM3v1_MOD_LVOFF, IF_REAL, "Length dependence of voff"),
    IOP( "lelm", BSIM3v1_MOD_LELM, IF_REAL, "Length dependence of elm"),
    IOP( "ldelta", BSIM3v1_MOD_LDELTA, IF_REAL, "Length dependence of delta"),
    IOP( "lrdsw", BSIM3v1_MOD_LRDSW,  IF_REAL, "Length dependence of rdsw "),    
    
    IOP( "lprwg", BSIM3v1_MOD_LPRWG,  IF_REAL, "Length dependence of prwg "),    
    IOP( "lprwb", BSIM3v1_MOD_LPRWB,  IF_REAL, "Length dependence of prwb "),    
    
    IOP( "lprt", BSIM3v1_MOD_LPRT, IF_REAL, "Length dependence of prt "),    
    IOP( "leta0", BSIM3v1_MOD_LETA0, IF_REAL, "Length dependence of eta0"),   
    IOP( "letab", BSIM3v1_MOD_LETAB, IF_REAL, "Length dependence of etab"),   
    IOP( "lpclm", BSIM3v1_MOD_LPCLM, IF_REAL, "Length dependence of pclm"),   
    IOP( "lpdiblc1", BSIM3v1_MOD_LPDIBL1, IF_REAL, "Length dependence of pdiblc1"),   
    IOP( "lpdiblc2", BSIM3v1_MOD_LPDIBL2, IF_REAL, "Length dependence of pdiblc2"),   
    IOP( "lpdiblcb", BSIM3v1_MOD_LPDIBLB, IF_REAL, "Length dependence of pdiblcb"),   
    IOP( "lpscbe1",  BSIM3v1_MOD_LPSCBE1, IF_REAL, "Length dependence of pscbe1"),   
    IOP( "lpscbe2",  BSIM3v1_MOD_LPSCBE2, IF_REAL, "Length dependence of pscbe2"),   
    IOP( "lpvag", BSIM3v1_MOD_LPVAG, IF_REAL, "Length dependence of pvag"),   
    IOP( "lwr",  BSIM3v1_MOD_LWR, IF_REAL, "Length dependence of wr"),
    IOP( "ldwg", BSIM3v1_MOD_LDWG, IF_REAL, "Length dependence of dwg"),
    IOP( "ldwb", BSIM3v1_MOD_LDWB, IF_REAL, "Length dependence of dwb"),
    IOP( "lb0",  BSIM3v1_MOD_LB0, IF_REAL, "Length dependence of b0"),
    IOP( "lb1",  BSIM3v1_MOD_LB1, IF_REAL, "Length dependence of b1"),
    IOP( "lcgsl", BSIM3v1_MOD_LCGSL, IF_REAL, "Length dependence of cgsl"),
    IOP( "lcgdl", BSIM3v1_MOD_LCGDL, IF_REAL, "Length dependence of cgdl"),
    IOP( "lckappa", BSIM3v1_MOD_LCKAPPA, IF_REAL, "Length dependence of ckappa"),
    IOP( "lcf",  BSIM3v1_MOD_LCF,  IF_REAL, "Length dependence of cf"),
    IOP( "lclc", BSIM3v1_MOD_LCLC, IF_REAL, "Length dependence of clc"),
    IOP( "lcle", BSIM3v1_MOD_LCLE, IF_REAL, "Length dependence of cle"),
    IOP( "lalpha0", BSIM3v1_MOD_LALPHA0, IF_REAL, "Length dependence of alpha0"),
    IOP( "lbeta0", BSIM3v1_MOD_LBETA0, IF_REAL, "Length dependence of beta0"),
    IOP( "lvfbcv", BSIM3v1_MOD_LVFBCV, IF_REAL, "Length dependence of vfbcv"),
    IOP( "wcdsc",  BSIM3v1_MOD_WCDSC, IF_REAL, "Width dependence of cdsc"),
    IOP( "wcdscb", BSIM3v1_MOD_WCDSCB, IF_REAL, "Width dependence of cdscb"),  
    IOP( "wcdscd", BSIM3v1_MOD_WCDSCD, IF_REAL, "Width dependence of cdscd"),  
    IOP( "wcit",   BSIM3v1_MOD_WCIT,  IF_REAL, "Width dependence of cit"),
    IOP( "wnfactor", BSIM3v1_MOD_WNFACTOR, IF_REAL, "Width dependence of nfactor"),
    IOP( "wxj", BSIM3v1_MOD_WXJ, IF_REAL, "Width dependence of xj"),
    IOP( "wvsat", BSIM3v1_MOD_WVSAT, IF_REAL, "Width dependence of vsat"),
    IOP( "wat", BSIM3v1_MOD_WAT, IF_REAL, "Width dependence of at"),
    IOP( "wa0", BSIM3v1_MOD_WA0, IF_REAL, "Width dependence of a0"), 
    IOP( "wags", BSIM3v1_MOD_WAGS, IF_REAL, "Width dependence of ags"), 
    IOP( "wa1", BSIM3v1_MOD_WA1, IF_REAL, "Width dependence of a1"),
    IOP( "wa2", BSIM3v1_MOD_WA2, IF_REAL, "Width dependence of a2"),
    IOP( "wketa", BSIM3v1_MOD_WKETA, IF_REAL, "Width dependence of keta"),
    IOP( "wnsub", BSIM3v1_MOD_WNSUB, IF_REAL, "Width dependence of nsub"),
    IOP( "wnch",  BSIM3v1_MOD_WNPEAK, IF_REAL, "Width dependence of nch"),
    IOP( "wngate", BSIM3v1_MOD_WNGATE, IF_REAL, "Width dependence of ngate"),
    IOP( "wgamma1", BSIM3v1_MOD_WGAMMA1, IF_REAL, "Width dependence of gamma1"),
    IOP( "wgamma2", BSIM3v1_MOD_WGAMMA2, IF_REAL, "Width dependence of gamma2"),
    IOP( "wvbx", BSIM3v1_MOD_WVBX, IF_REAL, "Width dependence of vbx"),
    IOP( "wvbm", BSIM3v1_MOD_WVBM, IF_REAL, "Width dependence of vbm"),
    IOP( "wxt",  BSIM3v1_MOD_WXT,  IF_REAL, "Width dependence of xt"),
    IOP( "wk1",   BSIM3v1_MOD_WK1,  IF_REAL, "Width dependence of k1"),
    IOP( "wkt1",  BSIM3v1_MOD_WKT1, IF_REAL, "Width dependence of kt1"),
    IOP( "wkt1l", BSIM3v1_MOD_WKT1L, IF_REAL, "Width dependence of kt1l"),
    IOP( "wkt2",  BSIM3v1_MOD_WKT2, IF_REAL, "Width dependence of kt2"),
    IOP( "wk2",   BSIM3v1_MOD_WK2,  IF_REAL, "Width dependence of k2"),
    IOP( "wk3",   BSIM3v1_MOD_WK3,  IF_REAL, "Width dependence of k3"),
    IOP( "wk3b",  BSIM3v1_MOD_WK3B, IF_REAL, "Width dependence of k3b"),
    IOP( "ww0",   BSIM3v1_MOD_WW0,  IF_REAL, "Width dependence of w0"),
    IOP( "wnlx",  BSIM3v1_MOD_WNLX, IF_REAL, "Width dependence of nlx"),
    IOP( "wdvt0", BSIM3v1_MOD_WDVT0, IF_REAL, "Width dependence of dvt0"),
    IOP( "wdvt1", BSIM3v1_MOD_WDVT1, IF_REAL, "Width dependence of dvt1"),
    IOP( "wdvt2", BSIM3v1_MOD_WDVT2, IF_REAL, "Width dependence of dvt2"),
    IOP( "wdvt0w", BSIM3v1_MOD_WDVT0W, IF_REAL, "Width dependence of dvt0w"),
    IOP( "wdvt1w", BSIM3v1_MOD_WDVT1W, IF_REAL, "Width dependence of dvt1w"),
    IOP( "wdvt2w", BSIM3v1_MOD_WDVT2W, IF_REAL, "Width dependence of dvt2w"),
    IOP( "wdrout", BSIM3v1_MOD_WDROUT, IF_REAL, "Width dependence of drout"),
    IOP( "wdsub", BSIM3v1_MOD_WDSUB, IF_REAL, "Width dependence of dsub"),
    IOP( "wvth0", BSIM3v1_MOD_WVTH0, IF_REAL,"Width dependence of vto"),
    IOP( "wvtho", BSIM3v1_MOD_WVTH0, IF_REAL,"Width dependence of vto"),
    IOP( "wua",  BSIM3v1_MOD_WUA, IF_REAL, "Width dependence of ua"),
    IOP( "wua1", BSIM3v1_MOD_WUA1, IF_REAL, "Width dependence of ua1"),
    IOP( "wub", BSIM3v1_MOD_WUB, IF_REAL, "Width dependence of ub"),
    IOP( "wub1", BSIM3v1_MOD_WUB1, IF_REAL, "Width dependence of ub1"),
    IOP( "wuc",  BSIM3v1_MOD_WUC, IF_REAL, "Width dependence of uc"),
    IOP( "wuc1", BSIM3v1_MOD_WUC1, IF_REAL, "Width dependence of uc1"),
    IOP( "wu0",  BSIM3v1_MOD_WU0, IF_REAL, "Width dependence of u0"),
    IOP( "wute", BSIM3v1_MOD_WUTE, IF_REAL, "Width dependence of ute"),
    IOP( "wvoff", BSIM3v1_MOD_WVOFF, IF_REAL, "Width dependence of voff"),
    IOP( "welm", BSIM3v1_MOD_WELM, IF_REAL, "Width dependence of elm"),
    IOP( "wdelta", BSIM3v1_MOD_WDELTA, IF_REAL, "Width dependence of delta"),
    IOP( "wrdsw", BSIM3v1_MOD_WRDSW,  IF_REAL, "Width dependence of rdsw "),
    
    IOP( "wprwg", BSIM3v1_MOD_WPRWG,  IF_REAL, "Width dependence of prwg "),
    IOP( "wprwb", BSIM3v1_MOD_WPRWB,  IF_REAL, "Width dependence of prwb "),
    
    IOP( "wprt", BSIM3v1_MOD_WPRT, IF_REAL, "Width dependence of prt"),
    IOP( "weta0", BSIM3v1_MOD_WETA0, IF_REAL, "Width dependence of eta0"),   
    IOP( "wetab", BSIM3v1_MOD_WETAB, IF_REAL, "Width dependence of etab"),   
    IOP( "wpclm", BSIM3v1_MOD_WPCLM, IF_REAL, "Width dependence of pclm"),   
    IOP( "wpdiblc1", BSIM3v1_MOD_WPDIBL1, IF_REAL, "Width dependence of pdiblc1"),   
    IOP( "wpdiblc2", BSIM3v1_MOD_WPDIBL2, IF_REAL, "Width dependence of pdiblc2"),   
    IOP( "wpdiblcb", BSIM3v1_MOD_WPDIBLB, IF_REAL, "Width dependence of pdiblcb"),   
    IOP( "wpscbe1",  BSIM3v1_MOD_WPSCBE1, IF_REAL, "Width dependence of pscbe1"),   
    IOP( "wpscbe2",  BSIM3v1_MOD_WPSCBE2, IF_REAL, "Width dependence of pscbe2"),   
    IOP( "wpvag", BSIM3v1_MOD_WPVAG, IF_REAL, "Width dependence of pvag"),   
    IOP( "wwr",  BSIM3v1_MOD_WWR, IF_REAL, "Width dependence of wr"),
    IOP( "wdwg", BSIM3v1_MOD_WDWG, IF_REAL, "Width dependence of dwg"),
    IOP( "wdwb", BSIM3v1_MOD_WDWB, IF_REAL, "Width dependence of dwb"),
    IOP( "wb0",  BSIM3v1_MOD_WB0, IF_REAL, "Width dependence of b0"),
    IOP( "wb1",  BSIM3v1_MOD_WB1, IF_REAL, "Width dependence of b1"),
    IOP( "wcgsl", BSIM3v1_MOD_WCGSL, IF_REAL, "Width dependence of cgsl"),
    IOP( "wcgdl", BSIM3v1_MOD_WCGDL, IF_REAL, "Width dependence of cgdl"),
    IOP( "wckappa", BSIM3v1_MOD_WCKAPPA, IF_REAL, "Width dependence of ckappa"),
    IOP( "wcf",  BSIM3v1_MOD_WCF,  IF_REAL, "Width dependence of cf"),
    IOP( "wclc", BSIM3v1_MOD_WCLC, IF_REAL, "Width dependence of clc"),
    IOP( "wcle", BSIM3v1_MOD_WCLE, IF_REAL, "Width dependence of cle"),
    IOP( "walpha0", BSIM3v1_MOD_WALPHA0, IF_REAL, "Width dependence of alpha0"),
    IOP( "wbeta0", BSIM3v1_MOD_WBETA0, IF_REAL, "Width dependence of beta0"),
    IOP( "wvfbcv", BSIM3v1_MOD_WVFBCV, IF_REAL, "Width dependence of vfbcv"),
    
    IOP( "pcdsc",  BSIM3v1_MOD_PCDSC, IF_REAL, "Cross-term dependence of cdsc"),
    IOP( "pcdscb", BSIM3v1_MOD_PCDSCB, IF_REAL, "Cross-term dependence of cdscb"), 
    IOP( "pcdscd", BSIM3v1_MOD_PCDSCD, IF_REAL, "Cross-term dependence of cdscd"),
    IOP( "pcit",   BSIM3v1_MOD_PCIT,  IF_REAL, "Cross-term dependence of cit"),
    IOP( "pnfactor", BSIM3v1_MOD_PNFACTOR, IF_REAL, "Cross-term dependence of nfactor"),
    IOP( "pxj", BSIM3v1_MOD_PXJ, IF_REAL, "Cross-term dependence of xj"),
    IOP( "pvsat", BSIM3v1_MOD_PVSAT, IF_REAL, "Cross-term dependence of vsat"),
    IOP( "pat", BSIM3v1_MOD_PAT, IF_REAL, "Cross-term dependence of at"),
    IOP( "pa0", BSIM3v1_MOD_PA0, IF_REAL, "Cross-term dependence of a0"), 
    IOP( "pags", BSIM3v1_MOD_PAGS, IF_REAL, "Cross-term dependence of ags"),
    IOP( "pa1", BSIM3v1_MOD_PA1, IF_REAL, "Cross-term dependence of a1"),
    IOP( "pa2", BSIM3v1_MOD_PA2, IF_REAL, "Cross-term dependence of a2"),
    IOP( "pketa", BSIM3v1_MOD_PKETA, IF_REAL, "Cross-term dependence of keta"),
    IOP( "pnsub", BSIM3v1_MOD_PNSUB, IF_REAL, "Cross-term dependence of nsub"),
    IOP( "pnch",  BSIM3v1_MOD_PNPEAK, IF_REAL, "Cross-term dependence of nch"),
    IOP( "pngate", BSIM3v1_MOD_PNGATE, IF_REAL, "Cross-term dependence of ngate"),
    IOP( "pgamma1", BSIM3v1_MOD_PGAMMA1, IF_REAL, "Cross-term dependence of gamma1"),
    IOP( "pgamma2", BSIM3v1_MOD_PGAMMA2, IF_REAL, "Cross-term dependence of gamma2"),
    IOP( "pvbx", BSIM3v1_MOD_PVBX, IF_REAL, "Cross-term dependence of vbx"),
    IOP( "pvbm", BSIM3v1_MOD_PVBM, IF_REAL, "Cross-term dependence of vbm"),
    IOP( "pxt",  BSIM3v1_MOD_PXT,  IF_REAL, "Cross-term dependence of xt"),
    IOP( "pk1",   BSIM3v1_MOD_PK1,  IF_REAL, "Cross-term dependence of k1"),
    IOP( "pkt1",  BSIM3v1_MOD_PKT1, IF_REAL, "Cross-term dependence of kt1"),
    IOP( "pkt1l", BSIM3v1_MOD_PKT1L, IF_REAL, "Cross-term dependence of kt1l"),
    IOP( "pkt2",  BSIM3v1_MOD_PKT2, IF_REAL, "Cross-term dependence of kt2"),
    IOP( "pk2",   BSIM3v1_MOD_PK2,  IF_REAL, "Cross-term dependence of k2"),
    IOP( "pk3",   BSIM3v1_MOD_PK3,  IF_REAL, "Cross-term dependence of k3"),
    IOP( "pk3b",  BSIM3v1_MOD_PK3B, IF_REAL, "Cross-term dependence of k3b"),
    IOP( "pw0",   BSIM3v1_MOD_PW0,  IF_REAL, "Cross-term dependence of w0"),
    IOP( "pnlx",  BSIM3v1_MOD_PNLX, IF_REAL, "Cross-term dependence of nlx"),
    IOP( "pdvt0", BSIM3v1_MOD_PDVT0, IF_REAL, "Cross-term dependence of dvt0"),
    IOP( "pdvt1", BSIM3v1_MOD_PDVT1, IF_REAL, "Cross-term dependence of dvt1"),
    IOP( "pdvt2", BSIM3v1_MOD_PDVT2, IF_REAL, "Cross-term dependence of dvt2"),
    IOP( "pdvt0w", BSIM3v1_MOD_PDVT0W, IF_REAL, "Cross-term dependence of dvt0w"),
    IOP( "pdvt1w", BSIM3v1_MOD_PDVT1W, IF_REAL, "Cross-term dependence of dvt1w"),
    IOP( "pdvt2w", BSIM3v1_MOD_PDVT2W, IF_REAL, "Cross-term dependence of dvt2w"),
    IOP( "pdrout", BSIM3v1_MOD_PDROUT, IF_REAL, "Cross-term dependence of drout"),
    IOP( "pdsub", BSIM3v1_MOD_PDSUB, IF_REAL, "Cross-term dependence of dsub"),
    IOP( "pvth0", BSIM3v1_MOD_PVTH0, IF_REAL,"Cross-term dependence of vto"),
    IOP( "pvtho", BSIM3v1_MOD_PVTH0, IF_REAL,"Cross-term dependence of vto"),
    IOP( "pua",  BSIM3v1_MOD_PUA, IF_REAL, "Cross-term dependence of ua"),
    IOP( "pua1", BSIM3v1_MOD_PUA1, IF_REAL, "Cross-term dependence of ua1"),
    IOP( "pub", BSIM3v1_MOD_PUB, IF_REAL, "Cross-term dependence of ub"),
    IOP( "pub1", BSIM3v1_MOD_PUB1, IF_REAL, "Cross-term dependence of ub1"),
    IOP( "puc",  BSIM3v1_MOD_PUC, IF_REAL, "Cross-term dependence of uc"),
    IOP( "puc1", BSIM3v1_MOD_PUC1, IF_REAL, "Cross-term dependence of uc1"),
    IOP( "pu0",  BSIM3v1_MOD_PU0, IF_REAL, "Cross-term dependence of u0"),
    IOP( "pute", BSIM3v1_MOD_PUTE, IF_REAL, "Cross-term dependence of ute"),
    IOP( "pvoff", BSIM3v1_MOD_PVOFF, IF_REAL, "Cross-term dependence of voff"),
    IOP( "pelm", BSIM3v1_MOD_PELM, IF_REAL, "Cross-term dependence of elm"),
    IOP( "pdelta", BSIM3v1_MOD_PDELTA, IF_REAL, "Cross-term dependence of delta"),
    IOP( "prdsw", BSIM3v1_MOD_PRDSW,  IF_REAL, "Cross-term dependence of rdsw "),    
    
    IOP( "pprwg", BSIM3v1_MOD_PPRWG,  IF_REAL, "Cross-term dependence of prwg "),    
    IOP( "pprwb", BSIM3v1_MOD_PPRWB,  IF_REAL, "Cross-term dependence of prwb "),    
    
    IOP( "pprt", BSIM3v1_MOD_PPRT, IF_REAL, "Cross-term dependence of prt "),
    IOP( "peta0", BSIM3v1_MOD_PETA0, IF_REAL, "Cross-term dependence of eta0"),
    IOP( "petab", BSIM3v1_MOD_PETAB, IF_REAL, "Cross-term dependence of etab"),
    IOP( "ppclm", BSIM3v1_MOD_PPCLM, IF_REAL, "Cross-term dependence of pclm"),
    IOP( "ppdiblc1", BSIM3v1_MOD_PPDIBL1, IF_REAL, "Cross-term dependence of pdiblc1"),
    IOP( "ppdiblc2", BSIM3v1_MOD_PPDIBL2, IF_REAL, "Cross-term dependence of pdiblc2"),
    IOP( "ppdiblcb", BSIM3v1_MOD_PPDIBLB, IF_REAL, "Cross-term dependence of pdiblcb"),
    IOP( "ppscbe1",  BSIM3v1_MOD_PPSCBE1, IF_REAL, "Cross-term dependence of pscbe1"),
    IOP( "ppscbe2",  BSIM3v1_MOD_PPSCBE2, IF_REAL, "Cross-term dependence of pscbe2"),
    IOP( "ppvag", BSIM3v1_MOD_PPVAG, IF_REAL, "Cross-term dependence of pvag"),   
    IOP( "pwr",  BSIM3v1_MOD_PWR, IF_REAL, "Cross-term dependence of wr"),
    IOP( "pdwg", BSIM3v1_MOD_PDWG, IF_REAL, "Cross-term dependence of dwg"),
    IOP( "pdwb", BSIM3v1_MOD_PDWB, IF_REAL, "Cross-term dependence of dwb"),
    IOP( "pb0",  BSIM3v1_MOD_PB0, IF_REAL, "Cross-term dependence of b0"),
    IOP( "pb1",  BSIM3v1_MOD_PB1, IF_REAL, "Cross-term dependence of b1"),
    IOP( "pcgsl", BSIM3v1_MOD_PCGSL, IF_REAL, "Cross-term dependence of cgsl"),
    IOP( "pcgdl", BSIM3v1_MOD_PCGDL, IF_REAL, "Cross-term dependence of cgdl"),
    IOP( "pckappa", BSIM3v1_MOD_PCKAPPA, IF_REAL, "Cross-term dependence of ckappa"),
    IOP( "pcf",  BSIM3v1_MOD_PCF,  IF_REAL, "Cross-term dependence of cf"),
    IOP( "pclc", BSIM3v1_MOD_PCLC, IF_REAL, "Cross-term dependence of clc"),
    IOP( "pcle", BSIM3v1_MOD_PCLE, IF_REAL, "Cross-term dependence of cle"),
    IOP( "palpha0", BSIM3v1_MOD_PALPHA0, IF_REAL, "Cross-term dependence of alpha0"),
    IOP( "pbeta0", BSIM3v1_MOD_PBETA0, IF_REAL, "Cross-term dependence of beta0"),
    IOP( "pvfbcv", BSIM3v1_MOD_PVFBCV, IF_REAL, "Cross-term dependence of vfbcv"),
    
    IOP( "noia", BSIM3v1_MOD_NOIA, IF_REAL, "Flicker noise parameter"),
    IOP( "noib", BSIM3v1_MOD_NOIB, IF_REAL, "Flicker noise parameter"),
    IOP( "noic", BSIM3v1_MOD_NOIC, IF_REAL, "Flicker noise parameter"),
    IOP( "em", BSIM3v1_MOD_EM, IF_REAL, "Flicker noise parameter"),
    IOP( "ef", BSIM3v1_MOD_EF, IF_REAL, "Flicker noise frequency exponent"),
    IOP( "af", BSIM3v1_MOD_AF, IF_REAL, "Flicker noise exponent"),
    IOP( "kf", BSIM3v1_MOD_KF, IF_REAL, "Flicker noise coefficient"),
    
    IP( "nmos", BSIM3v1_MOD_NMOS,  IF_FLAG, "Flag to indicate NMOS"),
    IP( "pmos", BSIM3v1_MOD_PMOS,  IF_FLAG, "Flag to indicate PMOS"),
    /* serban */
    IOP( "hdif", BSIM3v1_MOD_HDIF,  IF_REAL, "S/D junction extension"),
};

char *BSIM3v1names[] = {
    "Drain",
    "Gate",
    "Source",
    "Bulk",
    "Charge"
};

int	BSIM3v1nSize = NUMELEMS(BSIM3v1names);
int	BSIM3v1pTSize = NUMELEMS(BSIM3v1pTable);
int	BSIM3v1mPTSize = NUMELEMS(BSIM3v1mPTable);
int	BSIM3v1iSize = sizeof(BSIM3v1instance);
int	BSIM3v1mSize = sizeof(BSIM3v1model);





