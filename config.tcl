###############################################
#                                             #
# Configuration File For RAMSPICE Compilation #
# Edit with Care!!!                           #
#                                             #
###############################################


set ::MAXDIM 8
set ::ANALYSIS_NESTING_DEPTH 5
# C files that shouldn't be compiled alone, because they are meant to be included in others
set ::exclude {
    parse-bison.c
    inpptree-parser.c
    dlmain.c
    cmexport.c
    inp2dot.c
}

# The preprocessor fails on those and no point in complicating it for those particular corner cases 
set ::bypass_preprocessor {
    mod_lex.c
    ifs_lex.c
}
set ::dot_commands {
    noise op dc ac pz tf tran sens options
}
# Special for BSIM3v32. The fields in the transistor descript structure are listed for direct interface code.
set ::bsim3v32_structure_fields {
    ueff    thetavth    von    vdsat    cgdo    cgso    vjsm    IsEvjsm    vjdm    IsEvjdm    l    w    m    drainArea    sourceArea    drainSquares    sourceSquares    drainPerimeter    sourcePerimeter    sourceConductance    drainConductance
    delvto    mulu0    vth0    vfb    vfbzb    u0temp    tconst    icVBS    icVDS    icVGS    qinv    cd    cbs    cbd    csub    gm    gds    gmbs    gbd    gbs    gbbs    gbgs    gbds     cggb    cgdb    cgsb    cbgb    cbdb    cbsb    cdgb
    cddb    cdsb    capbd    capbs    cqgb    cqdb    cqsb    cqbb    qgate    qbulk    qdrn    gtau    gtg    gtd    gts    gtb    rds      Vgsteff    Vdseff    Abulk    AbovVgst2Vtm
}
set ::bsim4v5_structure_fields {
    ueff     thetavth      von     vdsat     cgdo     qgdo     cgso     qgso     grbsb     grbdb     grbpb     grbps     grbpd     vjsmFwd     vjsmRev     vjdmFwd     vjdmRev     XExpBVS     XExpBVD     SslpFwd     SslpRev     DslpFwd     DslpRev
    IVjsmFwd     IVjsmRev     IVjdmFwd     IVjdmRev     grgeltd     Pseff     Pdeff     Aseff     Adeff     l     w     drainArea     sourceArea     drainSquares     sourceSquares     drainPerimeter     sourcePerimeter     sourceConductance
    drainConductance     sa     sb     sd     sca     scb     scc     sc     rbdb     rbsb     rbpb     rbps     rbpd     delvto     xgw     ngcon     u0temp     vsattemp     vth0     vfb     vfbzb     vtfbphi1     vtfbphi2     k2     vbsc     k2ox
    eta0     icVDS     icVGS     icVBS     nf     m     Vgsteff     vgs_eff     vgd_eff     dvgs_eff_dvg     dvgd_eff_dvg     Vdseff     nstar     Abulk     EsatL     AbovVgst2Vtm     qinv     cd     cbs     cbd     csub     Igidl     Igisl     gm
    gds     gmbs     gbd     gbs     gbbs     gbgs     gbds     ggidld     ggidlg     ggidls     ggidlb     ggisld     ggislg     ggisls     ggislb     Igcs     gIgcsg     gIgcsd     gIgcss     gIgcsb     Igcd     gIgcdg     gIgcdd     gIgcds     gIgcdb
    Igs     gIgsg     gIgss     Igd     gIgdg     gIgdd     Igb     gIgbg     gIgbd     gIgbs     gIgbb     grdsw     IdovVds     gcrg     gcrgd     gcrgg     gcrgs     gcrgb     gstot     gstotd     gstotg     gstots     gstotb     gdtot     gdtotd
    gdtotg     gdtots     gdtotb     cggb     cgdb     cgsb     cbgb     cbdb     cbsb     cdgb     cddb     cdsb     csgb     csdb     cssb     cgbb     cdbb     csbb     cbbb     capbd     capbs     cqgb     cqdb     cqsb     cqbb     qgate
    qbulk     qdrn     qsrc      qchqs     taunet     gtau     gtg     gtd     gts     gtb     SjctTempRevSatCur     DjctTempRevSatCur     SswTempRevSatCur     DswTempRevSatCur     SswgTempRevSatCur     DswgTempRevSatCur 
}
set ::bsim3v32_model_fields {
    tox toxm cdsc cdscb cdscd cit nfactor xj vsat at a0 ags a1 a2 keta nsub npeak ngate gamma1 gamma2 vbx vbm xt k1 kt1 kt1l kt2 k2 k3 k3b w0 nlx dvt0 dvt1 dvt2 dvt0w dvt1w dvt2w drout dsub  ua ua1 ub ub1 uc uc1 u0 ute voff delta rdsw
    prwg prwb prt eta0 etab pclm pdibl1 pdibl2 pdiblb pscbe1 pscbe2 pvag wr dwg dwb b0 b1 alpha0 alpha1 beta0 ijth vfb elm cgsl cgdl ckappa cf vfbcv clc cle dwc dlc noff voffcv acde moin tcj tcjsw tcjswg tpb tpbsw tpbswg xl xw hdif ldif ld 
    rd rs rdc rsc wmlt lcdsc lcdscb lcdscd lcit lnfactor lxj lvsat lat la0 lags la1 la2 lketa lnsub lnpeak lngate lgamma1 lgamma2 lvbx lvbm lxt lk1 lkt1 lkt1l lkt2 lk2 lk3 lk3b lw0 lnlx ldvt0 ldvt1 ldvt2 ldvt0w ldvt1w ldvt2w ldrout ldsub 
    lvth0 lua lua1 lub lub1 luc luc1 lu0 lute lvoff ldelta lrdsw lprwg lprwb lprt leta0 letab lpclm lpdibl1 lpdibl2 lpdiblb lpscbe1 lpscbe2 lpvag lwr ldwg ldwb lb0 lb1 lalpha0 lalpha1 lbeta0 lvfb lelm lcgsl lcgdl lckappa lcf lclc lcle lvfbcv 
    lnoff lvoffcv lacde lmoin wcdsc wcdscb wcdscd wcit wnfactor wxj wvsat wat wa0 wags wa1 wa2 wketa wnsub wnpeak wngate wgamma1 wgamma2 wvbx wvbm wxt wk1 wkt1 wkt1l wkt2 wk2 wk3 wk3b ww0 wnlx wdvt0 wdvt1 wdvt2 wdvt0w wdvt1w wdvt2w wdrout wdsub 
    wvth0 wua wua1 wub wub1 wuc wuc1 wu0 wute wvoff wdelta wrdsw wprwg wprwb wprt weta0 wetab wpclm wpdibl1 wpdibl2 wpdiblb wpscbe1 wpscbe2 wpvag wwr wdwg wdwb wb0 wb1 walpha0 walpha1 wbeta0 wvfb welm wcgsl wcgdl wckappa wcf wclc wcle wvfbcv wnoff 
    wvoffcv wacde wmoin pcdsc pcdscb pcdscd pcit pnfactor pxj pvsat pat pa0 pags pa1 pa2 pketa pnsub pnpeak pngate pgamma1 pgamma2 pvbx pvbm pxt pk1 pkt1 pkt1l pkt2 pk2 pk3 pk3b pw0 pnlx pdvt0 pdvt1 pdvt2 pdvt0w pdvt1w pdvt2w pdrout pdsub pvth0 pua 
    pua1 pub pub1 puc puc1 pu0 pute pvoff pdelta prdsw pprwg pprwb pprt peta0 petab ppclm ppdibl1 ppdibl2 ppdiblb ppscbe1 ppscbe2 ppvag pwr pdwg pdwb pb0 pb1 palpha0 palpha1 pbeta0 pvfb pelm pcgsl pcgdl pckappa pcf pclc pcle pvfbcv pnoff pvoffcv pacde 
    pmoin  tnom cgso cgdo cgbo xpart cFringOut cFringMax  sheetResistance jctSatCurDensity jctSidewallSatCurDensity bulkJctPotential bulkJctBotGradingCoeff bulkJctSideGradingCoeff bulkJctGateSideGradingCoeff sidewallJctPotential GatesidewallJctPotential 
    unitAreaJctCap unitLengthSidewallJctCap unitLengthGateSidewallJctCap jctEmissionCoeff jctTempExponent  Lint Ll Llc Lln Lw Lwc Lwn Lwl Lwlc Lmin Lmax  Wint Wl Wlc Wln Ww Wwc Wwn Wwl Wwlc Wmin Wmax  vtm cox cof1 cof2 cof3 cof4 vcrit factor1 PhiB 
    PhiBSW PhiBSWG jctTempSatCurDensity jctSidewallTempSatCurDensity unitAreaTempJctCap unitLengthSidewallTempJctCap unitLengthGateSidewallTempJctCap  oxideTrapDensityA oxideTrapDensityB oxideTrapDensityC em ef af kf  vgsMax vgdMax vgbMax vdsMax vbsMax vbdMax 
}
set ::bsim4v5_model_fields {
 toxe toxp toxm dtox epsrox cdsc cdscb cdscd cit nfactor xj vsat at a0 ags a1 a2 keta nsub ndep nsd phin ngate gamma1 gamma2 vbx vbm xt k1 kt1 kt1l kt2 k2 k3 k3b w0 dvtp0 dvtp1 lpe0 lpeb dvt0 dvt1 dvt2 dvt0w dvt1w dvt2w drout dsub eu ua ua1 
 ub ub1 uc uc1 ud ud1 up lp u0 ute voff tvoff minv voffl delta rdsw rdswmin rdwmin rswmin rsw rdw prwg prwb prt eta0 etab pclm pdibl1 pdibl2 pdiblb fprout pdits pditsd pditsl pscbe1 pscbe2 pvag wr dwg dwb b0 b1 alpha0 alpha1 beta0 agidl bgidl cgidl egidl 
 aigc bigc cigc aigsd bigsd cigsd aigbacc bigbacc cigbacc aigbinv bigbinv cigbinv nigc nigbacc nigbinv ntox eigbinv pigcd poxedge toxref ijthdfwd ijthsfwd ijthdrev ijthsrev xjbvd xjbvs bvd bvs jtss jtsd jtssws jtsswd jtsswgs jtsswgd njts njtssw njtsswg xtss 
 xtsd xtssws xtsswd xtsswgs xtsswgd tnjts tnjtssw tnjtsswg vtss vtsd vtssws vtsswd vtsswgs vtsswgd xrcrg1 xrcrg2 lambda vtl lc xn vfbsdoff lintnoi tvfbsdoff vfb gbmin rbdb rbsb rbpb rbps rbpd rbps0 rbpsl rbpsw rbpsnf rbpd0 rbpdl rbpdw rbpdnf rbpbx0 
 rbpbxl rbpbxw rbpbxnf rbpby0 rbpbyl rbpbyw rbpbynf rbsbx0 rbsby0 rbdbx0 rbdby0 rbsdbxl rbsdbxw rbsdbxnf rbsdbyl rbsdbyw rbsdbynf tnoia tnoib rnoia rnoib ntnoi cgsl cgdl ckappas ckappad cf vfbcv clc cle dwc dlc xw xl dlcig dwj noff voffcv acde moin 
 tcj tcjsw tcjswg tpb tpbsw tpbswg dmcg dmci dmdg dmcgt xgw xgl rshg ngcon lcdsc lcdscb lcdscd lcit lnfactor lxj lvsat lat la0 lags la1 la2 lketa lnsub lndep lnsd lphin lngate lgamma1 lgamma2 lvbx lvbm lxt lk1 lkt1 lkt1l lkt2 lk2 lk3 lk3b lw0 ldvtp0 
 ldvtp1 llpe0 llpeb ldvt0 ldvt1 ldvt2 ldvt0w ldvt1w ldvt2w ldrout ldsub lvth0 lua lua1 lub lub1 luc luc1 lud lud1 lup llp lu0 leu lute lvoff ltvoff lminv ldelta lrdsw lrsw lrdw lprwg lprwb lprt leta0 letab lpclm lpdibl1 lpdibl2 lpdiblb lfprout lpdits 
 lpditsd lpscbe1 lpscbe2 lpvag lwr ldwg ldwb lb0 lb1 lalpha0 lalpha1 lbeta0 lvfb lagidl lbgidl lcgidl legidl laigc lbigc lcigc laigsd lbigsd lcigsd laigbacc lbigbacc lcigbacc laigbinv lbigbinv lcigbinv lnigc lnigbacc lnigbinv lntox leigbinv lpigcd 
 lpoxedge lxrcrg1 lxrcrg2 llambda lvtl lxn lvfbsdoff ltvfbsdoff lcgsl lcgdl lckappas lckappad lcf lclc lcle lvfbcv lnoff lvoffcv lacde lmoin wcdsc wcdscb wcdscd wcit wnfactor wxj wvsat wat wa0 wags wa1 wa2 wketa wnsub wndep wnsd wphin wngate wgamma1 
 wgamma2 wvbx wvbm wxt wk1 wkt1 wkt1l wkt2 wk2 wk3 wk3b ww0 wdvtp0 wdvtp1 wlpe0 wlpeb wdvt0 wdvt1 wdvt2 wdvt0w wdvt1w wdvt2w wdrout wdsub wvth0 wua wua1 wub wub1 wuc wuc1 wud wud1 wup wlp wu0 weu wute wvoff wtvoff wminv wdelta wrdsw wrsw wrdw wprwg 
 wprwb wprt weta0 wetab wpclm wpdibl1 wpdibl2 wpdiblb wfprout wpdits wpditsd wpscbe1 wpscbe2 wpvag wwr wdwg wdwb wb0 wb1 walpha0 walpha1 wbeta0 wvfb wagidl wbgidl wcgidl wegidl waigc wbigc wcigc waigsd wbigsd wcigsd waigbacc wbigbacc wcigbacc waigbinv 
 wbigbinv wcigbinv wnigc wnigbacc wnigbinv wntox weigbinv wpigcd wpoxedge wxrcrg1 wxrcrg2 wlambda wvtl wxn wvfbsdoff wtvfbsdoff wcgsl wcgdl wckappas wckappad wcf wclc wcle wvfbcv wnoff wvoffcv wacde wmoin pcdsc pcdscb pcdscd pcit pnfactor pxj pvsat pat 
 pa0 pags pa1 pa2 pketa pnsub pndep pnsd pphin pngate pgamma1 pgamma2 pvbx pvbm pxt pk1 pkt1 pkt1l pkt2 pk2 pk3 pk3b pw0 pdvtp0 pdvtp1 plpe0 plpeb pdvt0 pdvt1 pdvt2 pdvt0w pdvt1w pdvt2w pdrout pdsub pvth0 pua pua1 pub pub1 puc puc1 pud pud1 pup plp pu0 
 peu pute pvoff ptvoff pminv pdelta prdsw prsw prdw pprwg pprwb pprt peta0 petab ppclm ppdibl1 ppdibl2 ppdiblb pfprout ppdits ppditsd ppscbe1 ppscbe2 ppvag pwr pdwg pdwb pb0 pb1 palpha0 palpha1 pbeta0 pvfb pagidl pbgidl pcgidl pegidl paigc pbigc pcigc 
 paigsd pbigsd pcigsd paigbacc pbigbacc pcigbacc paigbinv pbigbinv pcigbinv pnigc pnigbacc pnigbinv pntox peigbinv ppigcd ppoxedge pxrcrg1 pxrcrg2 plambda pvtl pxn pvfbsdoff ptvfbsdoff pcgsl pcgdl pckappas pckappad pcf pclc pcle pvfbcv pnoff pvoffcv 
 pacde pmoin tnom cgso cgdo cgbo xpart cFringOut cFringMax sheetResistance SjctSatCurDensity DjctSatCurDensity SjctSidewallSatCurDensity DjctSidewallSatCurDensity SjctGateSidewallSatCurDensity DjctGateSidewallSatCurDensity SbulkJctPotential DbulkJctPotential 
 SbulkJctBotGradingCoeff DbulkJctBotGradingCoeff SbulkJctSideGradingCoeff DbulkJctSideGradingCoeff SbulkJctGateSideGradingCoeff DbulkJctGateSideGradingCoeff SsidewallJctPotential DsidewallJctPotential SGatesidewallJctPotential DGatesidewallJctPotential 
 SunitAreaJctCap DunitAreaJctCap SunitLengthSidewallJctCap DunitLengthSidewallJctCap SunitLengthGateSidewallJctCap DunitLengthGateSidewallJctCap SjctEmissionCoeff DjctEmissionCoeff SjctTempExponent DjctTempExponent njtstemp njtsswtemp njtsswgtemp Lint 
 Ll Llc Lln Lw Lwc Lwn Lwl Lwlc Lmin Lmax Wint Wl Wlc Wln Ww Wwc Wwn Wwl Wwlc Wmin Wmax saref sbref wlod ku0 kvsat kvth0 tku0 llodku0 wlodku0 llodvth wlodvth lku0 wku0 pku0 lkvth0 wkvth0 pkvth0 stk2 lodk2 steta0 lodeta0 web wec kvth0we k2we ku0we scref 
 wpemod lkvth0we lk2we lku0we wkvth0we wk2we wku0we pkvth0we pk2we pku0we vtm vtm0 coxe coxp cof1 cof2 cof3 cof4 vcrit factor1 PhiBS PhiBSWS PhiBSWGS SjctTempSatCurDensity SjctSidewallTempSatCurDensity SjctGateSidewallTempSatCurDensity PhiBD PhiBSWD 
 PhiBSWGD DjctTempSatCurDensity DjctSidewallTempSatCurDensity DjctGateSidewallTempSatCurDensity SunitAreaTempJctCap DunitAreaTempJctCap SunitLengthSidewallTempJctCap DunitLengthSidewallTempJctCap SunitLengthGateSidewallTempJctCap DunitLengthGateSidewallTempJctCap 
 oxideTrapDensityA oxideTrapDensityB oxideTrapDensityC em ef af kf vgsMax vgdMax vgbMax vdsMax vbsMax vbdMax 
}

# There's a lot of interesting stuff inside the huge function that calculated the OP of transistors. The following scalars are used to create a shadow list of structures that record that data. 

# Naturally, I would have loved to add those to the transistor instance structure itself and access them directly like the original fields. However, for some reason, any change to the transistor-instance structure resulted 
# in data corruption and ultimately a seg-fault. This is still a mystery. Suspect: some redundancy in overlapping structures makes any move of the fields create misalignment 
# (e.g. a 'next' field in a parent structure gives way to a new field in child structure and the program goes off rails when looping on a list).
# I didn't have time to analyze this. It wouldn't happen in C++!

set ::bsim3v32_internal_calculation_vars {
    SourceSatCurrent DrainSatCurrent ag0 qgd qgs qgb von cbhat VgstNVt ExpVgst cdrain cdhat cdreq ceqbd ceqbs ceqqb ceqqd ceqqg ceq geq czbd czbdsw czbdswg czbs czbssw czbsswg evbd evbs arg sarg delvbd delvbs 
    delvds delvgd delvgs Vfbeff dVfbeff_dVg dVfbeff_dVd dVfbeff_dVb V3 V4 gcbdb gcbgb gcbsb gcddb gcdgb gcdsb gcgdb gcggb gcgsb gcsdb gcsgb gcssb MJ MJSW MJSWG vbd vbs vds vgb vgd vgs vgdo qgate 
    qbulk qdrn qsrc qinoi cqgate cqbulk cqdrn Vds Vgs Vbs Gmbs FwdSum RevSum Vgs_eff Vfb dVfb_dVb dVfb_dVd Phis dPhis_dVb sqrtPhis dsqrtPhis_dVb Vth dVth_dVb dVth_dVd Vgst dVgst_dVg 
    dVgst_dVb dVgs_eff_dVg Nvtm Vtm n dn_dVb dn_dVd voffcv noff dnoff_dVd dnoff_dVb ExpArg V0 CoxWLcen QovCox LINK DeltaPhi dDeltaPhi_dVg dDeltaPhi_dVd dDeltaPhi_dVb Cox Tox Tcen dTcen_dVg dTcen_dVd dTcen_dVb 
    Ccen Coxeff dCoxeff_dVg dCoxeff_dVd dCoxeff_dVb Denomi dDenomi_dVg dDenomi_dVd dDenomi_dVb ueff dueff_dVg dueff_dVd dueff_dVb Esat Vdsat EsatL dEsatL_dVg dEsatL_dVd dEsatL_dVb dVdsat_dVg dVdsat_dVb dVdsat_dVd 
    Vasat dAlphaz_dVg dAlphaz_dVb dVasat_dVg dVasat_dVb dVasat_dVd Va dVa_dVd dVa_dVg dVa_dVb Vbseff dVbseff_dVb VbseffCV dVbseffCV_dVb Arg1 One_Third_CoxWL Two_Third_CoxWL Alphaz CoxWL T0 dT0_dVg dT0_dVd dT0_dVb T1 
    dT1_dVg dT1_dVd dT1_dVb T2 dT2_dVg dT2_dVd dT2_dVb T3 dT3_dVg dT3_dVd dT3_dVb T4 T5 T6 T7 T8 T9 T10 T11 T12 tmp Abulk dAbulk_dVb Abulk0 dAbulk0_dVb VACLM dVACLM_dVg 
    dVACLM_dVd dVACLM_dVb VADIBL dVADIBL_dVg dVADIBL_dVd dVADIBL_dVb Xdep dXdep_dVb lt1 dlt1_dVb ltw dltw_dVb Delt_vth dDelt_vth_dVb Theta0 dTheta0_dVb TempRatio tmp1 tmp2 tmp3 tmp4 DIBL_Sft dDIBL_Sft_dVd Lambda 
    dLambda_dVg Idtot Ibtot a1 ScalingFactor Vgsteff dVgsteff_dVg dVgsteff_dVd dVgsteff_dVb Vdseff dVdseff_dVg dVdseff_dVd dVdseff_dVb VdseffCV dVdseffCV_dVg dVdseffCV_dVd dVdseffCV_dVb diffVds dAbulk_dVg beta 
    dbeta_dVg dbeta_dVd dbeta_dVb gche dgche_dVg dgche_dVd dgche_dVb fgche1 dfgche1_dVg dfgche1_dVd dfgche1_dVb fgche2 dfgche2_dVg dfgche2_dVd dfgche2_dVb Idl dIdl_dVg dIdl_dVd dIdl_dVb Idsa dIdsa_dVg dIdsa_dVd 
    dIdsa_dVb Ids Gm Gds Gmb Isub Gbd Gbg Gbb VASCBE dVASCBE_dVg dVASCBE_dVd dVASCBE_dVb CoxWovL Rds dRds_dVg dRds_dVb WVCox WVCoxRds Vgst2Vtm VdsatCV dVdsatCV_dVg dVdsatCV_dVb Leff Weff dWeff_dVg 
    dWeff_dVb AbulkCV dAbulkCV_dVb qgdo qgso cgdo cgso qcheq qdef gqdef cqdef cqcheq gtau_diff gtau_drift gcqdb gcqsb gcqgb gcqbb dxpart sxpart ggtg ggtd ggts ggtb ddxpart_dVd ddxpart_dVg ddxpart_dVb ddxpart_dVs 
    dsxpart_dVd dsxpart_dVg dsxpart_dVb dsxpart_dVs gbspsp gbbdp gbbsp gbspg gbspb gbspdp gbdpdp gbdpg gbdpb gbdpsp Cgg Cgd Cgb Cdg Cdd Cds Csg Csd Css Csb Cbg Cbd Cbb Cgg1 Cgb1 Cgd1 Cbg1 Cbb1 Cbd1
    Qac0 Qsub0 dQac0_dVg dQac0_dVd dQac0_dVb dQsub0_dVg dQsub0_dVd dQsub0_dVb m 
}
set ::bsim4v5_internal_calculation_vars {
    ceqgstot dgstot_dvd dgstot_dvg dgstot_dvs dgstot_dvb ceqgdtot dgdtot_dvd dgdtot_dvg dgdtot_dvs dgdtot_dvb gstot gstotd gstotg gstots gstotb gspr Rs Rd gdtot gdtotd gdtotg gdtots gdtotb gdpr vgs_eff vgd_eff dvgs_eff_dvg dvgd_eff_dvg
    dRs_dvg dRd_dvg dRs_dvb dRd_dvb dT0_dvg dT1_dvb dT3_dvg dT3_dvb vses vdes vdedo delvses delvded delvdes Isestot cseshat Idedtot cdedhat geltd gcrg gcrgg gcrgd gcrgs gcrgb ceqgcrg
    vges vgms vgedo vgmdo vged vgmd delvged delvgmd delvges delvgms vgmb gcgmgmb gcgmdb gcgmsb gcdgmb gcsgmb gcgmbb gcbgmb qgmb qgmid ceqqgmid vbd vbs vds vgb vgd vgs vgdo
    vdbs vdbd vsbs vsbdo vsbd delvdbs delvdbd delvsbs delvbd_jct delvbs_jct vbs_jct vbd_jct SourceSatCurrent DrainSatCurrent ag0 qgb von cbhat VgstNVt ExpVgst ceqqb ceqqd ceqqg ceqqjd ceqqjs ceq geq cdrain cdhat ceqdrn ceqbd ceqbs ceqjd ceqjs gjbd gjbs
    czbd czbdsw czbdswg czbs czbssw czbsswg evbd evbs arg sarg delvbd delvbs delvds delvgd delvgs Vfbeff dVfbeff_dVg dVfbeff_dVb V3 V4 gcbdb gcbgb gcbsb gcddb gcdgb gcdsb gcgdb gcggb gcgsb gcsdb gcgbb gcdbb gcsbb gcbbb
    gcdbdb gcsbsb gcsgb gcssb MJD MJSWD MJSWGD MJS MJSWS MJSWGS qgate qbulk qdrn qsrc cqgate cqbody cqdrn Vdb Vds Vgs Vbs Gmbs FwdSum RevSum Igidl Ggidld Ggidlg Ggidlb Voxacc dVoxacc_dVg dVoxacc_dVb
    Voxdepinv dVoxdepinv_dVg dVoxdepinv_dVd dVoxdepinv_dVb VxNVt ExpVxNVt Vaux dVaux_dVg dVaux_dVd dVaux_dVb Igc dIgc_dVg dIgc_dVd dIgc_dVb Igcs dIgcs_dVg dIgcs_dVd dIgcs_dVb Igcd dIgcd_dVg dIgcd_dVd dIgcd_dVb
    Igs dIgs_dVg dIgs_dVs Igd dIgd_dVg dIgd_dVd Igbacc dIgbacc_dVg dIgbacc_dVb Igbinv dIgbinv_dVg dIgbinv_dVd dIgbinv_dVb Pigcd dPigcd_dVg dPigcd_dVd dPigcd_dVb Istoteq gIstotg gIstotd gIstots gIstotb Idtoteq gIdtotg gIdtotd gIdtots gIdtotb
    Ibtoteq gIbtotg gIbtotd gIbtots gIbtotb Igtoteq gIgtotg gIgtotd gIgtots gIgtotb Igstot cgshat Igdtot cgdhat Igbtot cgbhat Vgs_eff Vfb Vth_NarrowW Phis dPhis_dVb sqrtPhis dsqrtPhis_dVb Vth dVth_dVb dVth_dVd
    Vgst dVgst_dVg dVgst_dVb dVgs_eff_dVg Nvtms Nvtmd Vtm Vtm0 n dn_dVb dn_dVd voffcv noff dnoff_dVd dnoff_dVb V0 CoxWLcen QovCox LINK DeltaPhi dDeltaPhi_dVg VgDP dVgDP_dVg Cox Tox Tcen dTcen_dVg dTcen_dVd dTcen_dVb
    Ccen Coxeff dCoxeff_dVd dCoxeff_dVg dCoxeff_dVb Denomi dDenomi_dVg dDenomi_dVd dDenomi_dVb ueff dueff_dVg dueff_dVd dueff_dVb Esat Vdsat EsatL dEsatL_dVg dEsatL_dVd dEsatL_dVb dVdsat_dVg dVdsat_dVb dVdsat_dVd Vasat dAlphaz_dVg dAlphaz_dVb 
    dVasat_dVg dVasat_dVb dVasat_dVd Va dVa_dVd dVa_dVg dVa_dVb Vbseff dVbseff_dVb VbseffCV dVbseffCV_dVb Arg1 One_Third_CoxWL Two_Third_CoxWL Alphaz CoxWL T0 dT0_dVg dT0_dVd dT0_dVb T1 dT1_dVg dT1_dVd dT1_dVb
    T2 dT2_dVg dT2_dVd dT2_dVb T3 dT3_dVg dT3_dVd dT3_dVb T4 dT4_dVd dT4_dVb T5 dT5_dVg dT5_dVd dT5_dVb T6 dT6_dVg dT6_dVd dT6_dVb T7 dT7_dVg dT7_dVd dT7_dVb T8 dT8_dVg dT8_dVd dT8_dVb T9 dT9_dVg dT9_dVd dT9_dVb
    T10 dT10_dVg dT10_dVb dT10_dVd T11 T12 T13 T14 tmp Abulk dAbulk_dVb Abulk0 dAbulk0_dVb Cclm dCclm_dVg dCclm_dVd dCclm_dVb FP dFP_dVg PvagTerm dPvagTerm_dVg dPvagTerm_dVd dPvagTerm_dVb VADITS dVADITS_dVg dVADITS_dVd
    Lpe_Vb dDITS_Sft_dVb dDITS_Sft_dVd VACLM dVACLM_dVg dVACLM_dVd dVACLM_dVb VADIBL dVADIBL_dVg dVADIBL_dVd dVADIBL_dVb Xdep dXdep_dVb lt1 dlt1_dVb ltw dltw_dVb Delt_vth dDelt_vth_dVb Theta0 dTheta0_dVb TempRatio tmp1 tmp2 tmp3 tmp4
    DIBL_Sft dDIBL_Sft_dVd Lambda dLambda_dVg Idtot Ibtot a1 ScalingFactor Vgsteff dVgsteff_dVg dVgsteff_dVd dVgsteff_dVb Vdseff dVdseff_dVg dVdseff_dVd dVdseff_dVb VdseffCV dVdseffCV_dVg dVdseffCV_dVd dVdseffCV_dVb 
    diffVds dAbulk_dVg beta dbeta_dVg dbeta_dVd dbeta_dVb gche dgche_dVg dgche_dVd dgche_dVb fgche1 dfgche1_dVg dfgche1_dVd dfgche1_dVb fgche2 dfgche2_dVg dfgche2_dVd dfgche2_dVb Idl dIdl_dVg dIdl_dVd dIdl_dVb
    Idsa dIdsa_dVg dIdsa_dVd dIdsa_dVb Ids Gm Gds Gmb devbs_dvb devbd_dvb Isub Gbd Gbg Gbb VASCBE dVASCBE_dVg dVASCBE_dVd dVASCBE_dVb CoxeffWovL Rds dRds_dVg dRds_dVb WVCox WVCoxRds
    Vgst2Vtm VdsatCV Leff Weff dWeff_dVg dWeff_dVb AbulkCV dAbulkCV_dVb qcheq qdef gqdef cqdef cqcheq gcqdb gcqsb gcqgb gcqbb dxpart sxpart ggtg ggtd ggts ggtb
    ddxpart_dVd ddxpart_dVg ddxpart_dVb ddxpart_dVs dsxpart_dVd dsxpart_dVg dsxpart_dVb dsxpart_dVs gbspsp gbbdp gbbsp gbspg gbspb gbspdp gbdpdp gbdpg gbdpb gbdpsp qgdo qgso cgdo cgso Cgg Cgd Cgb Cdg Cdd Cds
    Csg Csd Css Csb Cbg Cbd Cbb Cgg1 Cgb1 Cgd1 Cbg1 Cbb1 Cbd1 Qac0 Qsub0 dQac0_dVg dQac0_dVb dQsub0_dVg dQsub0_dVd dQsub0_dVb ggidld ggidlg ggidlb ggislg ggislb ggisls Igisl Ggislg Ggislb Ggisls Nvtmrs Nvtmrssw Nvtmrsswg
    vs Fsevl dvs_dVg dvs_dVd dvs_dVb dFsevl_dVg dFsevl_dVd dFsevl_dVb vgdx vgsx m
}


# All these are scalar-typed. Use them in code directly (Do not re-declare!) and they are visible in Tcl via ::spice::get_spice_data command.
set ::global_c_variables {
    Captured_Thermal_Noise
    Captured_Ssi 
    Captured_EffFreq
    Captured_Quick_Noise
    Captured_Cgs
    Captured_Cgd
}
set ::sizer_parameters_no_ids {gm go Vt Nth Nflicker sigmaVt}
set ::sizer_parameters [concat Ids $::sizer_parameters_no_ids]
set ::sizer_voltage_inputs {Vgs Vds Vbs}
set ::sizer_geo_inputs {L W}
set ::sizer_inputs [concat $::sizer_voltage_inputs $::sizer_geo_inputs]
array set ::sizer_steps {
	Vgs  1e-3
	Vds   1e-3
	Vbs   1e-3
	L   5e-10
	W  5e-10
}
array set ::sizer_parameter_dim {
    Ids	4
    gm	4
    go	4
    Vt	1
    Nth	4
    Nflicker	4
    sigmaVt	1
}
set ::DotCamelVirtualMachineBatchSize [expr 1024*1024*16]
set ::DotCamelVirtualMachineStackSize [expr 1024*1024*16]
