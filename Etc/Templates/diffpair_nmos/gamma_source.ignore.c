#include <tcl.h>
#include <stdio.h>
#include <stdlib.h>
#include "ctree.h"
#include "look_up_table.h"
// Some global pointers to keep reference of the contexts this object manipulates
float *Pdiffpair_nmos_circuits_PAT;
float *Pconfig_pat_size_target;
float *Psize_iref;
float *Psize_iref_min;
float *Psize_iref_max;
float *Psize_Lp;
float *Psize_Lp_min;
float *Psize_Lp_max;
float *Psize_Wp;
float *Psize_Wp_max;
float *Psize_Ln;
float *Psize_Ln_min;
float *Psize_Ln_max;
float *Psize_Wn;
float *Psize_Wn_max;
float *Psize_Ls;
float *Psize_Ls_min;
float *Psize_Ls_max;
float *Psize_iref_step;
float *Psize_Lp_step;
float *Psize_Wp_step;
float *Psize_Ln_step;
float *Psize_Wn_step;
float *Psize_Ls_step;
float *Pmax_Adc;
float *Pparam_unique;
float *Ppat_size_target;
float *Pmode_freash_op;
float *Poutm_V;
float *Pvdd_V;
float *Poutp_V;
float *Pinp_V;
float *Pparam_inp;
float *Ptail_V;
float *Pinn_V;
float *Pparam_inn;
float *Pvbias_V;
float *Pstatus_index;
float *Pconfig_size_iref;
float *Pconfig_size_Lp;
float *Pconfig_size_Wp;
float *Pconfig_size_Ln;
float *Pconfig_size_Wn;
float *Pconfig_size_Ls;
float *P0_V;
float *Pstatus_fail;
float *Pdesign_feedback;
float *Pp_1_bin;
float *Plook_up_tables_pch_binning_LUT;
float *Pp_1_L;
float *Pp_1_W;
float *Pp_2_bin;
float *Pp_2_L;
float *Pp_2_W;
float *Pnin_1_bin;
float *Plook_up_tables_nch_binning_LUT;
float *Pnin_1_L;
float *Pnin_1_W;
float *Pnin_2_bin;
float *Pnin_2_L;
float *Pnin_2_W;
float *Pntail_bin;
float *Pntail_L;
float *Pntail_W;
float *Pnref_bin;
float *Pnref_L;
float *Pnref_W;
float *Pleak;
float *Pconfig_op_iterations;
float *Pconfig_kcl_th;
float *Pconfig_design_feedback_th;
float *Plook_up_tables_pch_Ids_ss_CONTEXT;
float *Plook_up_tables_pch_gm_ss_CONTEXT;
float *Plook_up_tables_pch_go_ss_CONTEXT;
float *Plook_up_tables_pch_gb_ss_CONTEXT;
float *Pp_1_gb;
float *Pp_1_gm;
float *Pp_1_go;
float *Pp_1_Ids;
float *Pp_2_gb;
float *Pp_2_gm;
float *Pp_2_go;
float *Pp_2_Ids;
float *Plook_up_tables_nch_Ids_ss_CONTEXT;
float *Plook_up_tables_nch_gm_ss_CONTEXT;
float *Plook_up_tables_nch_go_ss_CONTEXT;
float *Plook_up_tables_nch_gb_ss_CONTEXT;
float *Pnin_1_gb;
float *Pnin_1_gm;
float *Pnin_1_go;
float *Pnin_1_Ids;
float *Pnin_2_gb;
float *Pnin_2_gm;
float *Pnin_2_go;
float *Pnin_2_Ids;
float *Pntail_gb;
float *Pntail_gm;
float *Pntail_go;
float *Pntail_Ids;
float *Pnref_gb;
float *Pnref_gm;
float *Pnref_go;
float *Pnref_Ids;
float *Pconfig_kcl_step;
float *Pp_1_gmb;
float *Pp_1_cdd;
float *Pp_1_cdg;
float *Pp_1_cds;
float *Pp_1_cdb;
float *Pp_1_csd;
float *Pp_1_csg;
float *Pp_1_css;
float *Pp_1_csb;
float *Pp_1_cgd;
float *Pp_1_cgg;
float *Pp_1_cgs;
float *Pp_1_cgb;
float *Pp_2_gmb;
float *Pp_2_cdd;
float *Pp_2_cdg;
float *Pp_2_cds;
float *Pp_2_cdb;
float *Pp_2_csd;
float *Pp_2_csg;
float *Pp_2_css;
float *Pp_2_csb;
float *Pp_2_cgd;
float *Pp_2_cgg;
float *Pp_2_cgs;
float *Pp_2_cgb;
float *Pnin_1_gmb;
float *Pnin_1_cdd;
float *Pnin_1_cdg;
float *Pnin_1_cds;
float *Pnin_1_cdb;
float *Pnin_1_csd;
float *Pnin_1_csg;
float *Pnin_1_css;
float *Pnin_1_csb;
float *Pnin_1_cgd;
float *Pnin_1_cgg;
float *Pnin_1_cgs;
float *Pnin_1_cgb;
float *Pnin_2_gmb;
float *Pnin_2_cdd;
float *Pnin_2_cdg;
float *Pnin_2_cds;
float *Pnin_2_cdb;
float *Pnin_2_csd;
float *Pnin_2_csg;
float *Pnin_2_css;
float *Pnin_2_csb;
float *Pnin_2_cgd;
float *Pnin_2_cgg;
float *Pnin_2_cgs;
float *Pnin_2_cgb;
float *Pntail_gmb;
float *Pntail_cdd;
float *Pntail_cdg;
float *Pntail_cds;
float *Pntail_cdb;
float *Pntail_csd;
float *Pntail_csg;
float *Pntail_css;
float *Pntail_csb;
float *Pntail_cgd;
float *Pntail_cgg;
float *Pntail_cgs;
float *Pntail_cgb;
float *Pnref_gmb;
float *Pnref_cdd;
float *Pnref_cdg;
float *Pnref_cds;
float *Pnref_cdb;
float *Pnref_csd;
float *Pnref_csg;
float *Pnref_css;
float *Pnref_csb;
float *Pnref_cgd;
float *Pnref_cgg;
float *Pnref_cgs;
float *Pnref_cgb;
float *PDet;
float *PTed;
float *Pproperty_Adc;
float *Pproperty_CMRR;
float *Pproperty_PSRR;
float *Pconfig_fail_on_properties;
float *Pproperty_Rout;
float *Ps;
float *Pproperty_BW;
float *Pproperty_BW_s;
float *Pp1;
float *Pp2;
float *Pproperty_ts;
float *Pproperty_Cin;
float *Pproperty_PM;
float *Pp_1_Nt_unit;
float *P_look_up_tables_pch_thermal_noise_ss_LUT;
float *Pp_1_dNt_dvgs;
float *Pp_1_dNt_dvds;
float *Pp_1_dNt_dvbs;
float *Pp_1_dNt_dl;
float *Pp_1_Nt;
float *Pp_1_Nf_unit;
float *P_look_up_tables_pch_flicker_noise_ss_LUT;
float *Pp_1_dNf_dvgs;
float *Pp_1_dNf_dvds;
float *Pp_1_dNf_dvbs;
float *Pp_1_dNf_dl;
float *Pp_1_Nf;
float *Pp_2_Nt_unit;
float *Pp_2_dNt_dvgs;
float *Pp_2_dNt_dvds;
float *Pp_2_dNt_dvbs;
float *Pp_2_dNt_dl;
float *Pp_2_Nt;
float *Pp_2_Nf_unit;
float *Pp_2_dNf_dvgs;
float *Pp_2_dNf_dvds;
float *Pp_2_dNf_dvbs;
float *Pp_2_dNf_dl;
float *Pp_2_Nf;
float *Pnin_1_Nt_unit;
float *P_look_up_tables_nch_thermal_noise_ss_LUT;
float *Pnin_1_dNt_dvgs;
float *Pnin_1_dNt_dvds;
float *Pnin_1_dNt_dvbs;
float *Pnin_1_dNt_dl;
float *Pnin_1_Nt;
float *Pnin_1_Nf_unit;
float *P_look_up_tables_nch_flicker_noise_ss_LUT;
float *Pnin_1_dNf_dvgs;
float *Pnin_1_dNf_dvds;
float *Pnin_1_dNf_dvbs;
float *Pnin_1_dNf_dl;
float *Pnin_1_Nf;
float *Pnin_2_Nt_unit;
float *Pnin_2_dNt_dvgs;
float *Pnin_2_dNt_dvds;
float *Pnin_2_dNt_dvbs;
float *Pnin_2_dNt_dl;
float *Pnin_2_Nt;
float *Pnin_2_Nf_unit;
float *Pnin_2_dNf_dvgs;
float *Pnin_2_dNf_dvds;
float *Pnin_2_dNf_dvbs;
float *Pnin_2_dNf_dl;
float *Pnin_2_Nf;
float *Pntail_Nt_unit;
float *Pntail_dNt_dvgs;
float *Pntail_dNt_dvds;
float *Pntail_dNt_dvbs;
float *Pntail_dNt_dl;
float *Pntail_Nt;
float *Pntail_Nf_unit;
float *Pntail_dNf_dvgs;
float *Pntail_dNf_dvds;
float *Pntail_dNf_dvbs;
float *Pntail_dNf_dl;
float *Pntail_Nf;
float *Pnref_Nt_unit;
float *Pnref_dNt_dvgs;
float *Pnref_dNt_dvds;
float *Pnref_dNt_dvbs;
float *Pnref_dNt_dl;
float *Pnref_Nt;
float *Pnref_Nf_unit;
float *Pnref_dNf_dvgs;
float *Pnref_dNf_dvds;
float *Pnref_dNf_dvbs;
float *Pnref_dNf_dl;
float *Pnref_Nf;
float *Pproperty_Nt;
float *Pproperty_Nf;
float *Pproperty_fc;
float *Pproperty_TotalNoise;
float *Pproperty_Area;
float *Pproperty_Vos;
float *Pproperty_Power;
float *Pconfig_factor_Adc;
float *Pconfig_shift_Adc;
float *Pconfig_factor_CMRR;
float *Pconfig_shift_CMRR;
float *Pconfig_factor_PSRR;
float *Pconfig_shift_PSRR;
float *Pconfig_factor_Rout;
float *Pconfig_shift_Rout;
float *Pconfig_factor_BW;
float *Pconfig_shift_BW;
float *Pconfig_factor_PM;
float *Pconfig_shift_PM;
float *Pconfig_factor_Cin;
float *Pconfig_shift_Cin;
float *Pconfig_factor_ts;
float *Pconfig_shift_ts;
float *Pconfig_factor_Nt;
float *Pconfig_shift_Nt;
float *Pconfig_factor_Nf;
float *Pconfig_shift_Nf;
float *Pconfig_factor_TotalNoise;
float *Pconfig_shift_TotalNoise;
float *Pconfig_factor_fc;
float *Pconfig_shift_fc;
float *Pconfig_factor_Vos;
float *Pconfig_shift_Vos;
float *Pconfig_factor_Area;
float *Pconfig_shift_Area;
float *Pconfig_factor_Power;
float *Pconfig_shift_Power;
float *Pcircuit_breed_id;
float *Pcircuit_breed_target;
float diffpair_nmos_circuits_PAT;
float config_pat_size_target;
float size_iref;
float size_iref_min;
float size_iref_max;
float size_Lp;
float size_Lp_min;
float size_Lp_max;
float size_Wp;
float size_Wp_max;
float size_Ln;
float size_Ln_min;
float size_Ln_max;
float size_Wn;
float size_Wn_max;
float size_Ls;
float size_Ls_min;
float size_Ls_max;
float size_iref_step;
float size_Lp_step;
float size_Wp_step;
float size_Ln_step;
float size_Wn_step;
float size_Ls_step;
float max_Adc;
float param_unique;
float pat_size_target;
float mode_freash_op;
float outm_V;
float vdd_V;
float outp_V;
float inp_V;
float param_inp;
float tail_V;
float inn_V;
float param_inn;
float vbias_V;
float status_index;
float config_size_iref;
float config_size_Lp;
float config_size_Wp;
float config_size_Ln;
float config_size_Wn;
float config_size_Ls;
float CONST_0_V;
float status_fail;
float design_feedback;
float p_1_bin;
float look_up_tables_pch_binning_LUT;
float p_1_L;
float p_1_W;
float p_2_bin;
float p_2_L;
float p_2_W;
float nin_1_bin;
float look_up_tables_nch_binning_LUT;
float nin_1_L;
float nin_1_W;
float nin_2_bin;
float nin_2_L;
float nin_2_W;
float ntail_bin;
float ntail_L;
float ntail_W;
float nref_bin;
float nref_L;
float nref_W;
float leak;
float config_op_iterations;
float config_kcl_th;
float config_design_feedback_th;
float look_up_tables_pch_Ids_ss_CONTEXT;
float look_up_tables_pch_gm_ss_CONTEXT;
float look_up_tables_pch_go_ss_CONTEXT;
float look_up_tables_pch_gb_ss_CONTEXT;
float p_1_gb;
float p_1_gm;
float p_1_go;
float p_1_Ids;
float p_2_gb;
float p_2_gm;
float p_2_go;
float p_2_Ids;
float look_up_tables_nch_Ids_ss_CONTEXT;
float look_up_tables_nch_gm_ss_CONTEXT;
float look_up_tables_nch_go_ss_CONTEXT;
float look_up_tables_nch_gb_ss_CONTEXT;
float nin_1_gb;
float nin_1_gm;
float nin_1_go;
float nin_1_Ids;
float nin_2_gb;
float nin_2_gm;
float nin_2_go;
float nin_2_Ids;
float ntail_gb;
float ntail_gm;
float ntail_go;
float ntail_Ids;
float nref_gb;
float nref_gm;
float nref_go;
float nref_Ids;
float config_kcl_step;
float p_1_gmb;
float p_1_cdd;
float p_1_cdg;
float p_1_cds;
float p_1_cdb;
float p_1_csd;
float p_1_csg;
float p_1_css;
float p_1_csb;
float p_1_cgd;
float p_1_cgg;
float p_1_cgs;
float p_1_cgb;
float p_2_gmb;
float p_2_cdd;
float p_2_cdg;
float p_2_cds;
float p_2_cdb;
float p_2_csd;
float p_2_csg;
float p_2_css;
float p_2_csb;
float p_2_cgd;
float p_2_cgg;
float p_2_cgs;
float p_2_cgb;
float nin_1_gmb;
float nin_1_cdd;
float nin_1_cdg;
float nin_1_cds;
float nin_1_cdb;
float nin_1_csd;
float nin_1_csg;
float nin_1_css;
float nin_1_csb;
float nin_1_cgd;
float nin_1_cgg;
float nin_1_cgs;
float nin_1_cgb;
float nin_2_gmb;
float nin_2_cdd;
float nin_2_cdg;
float nin_2_cds;
float nin_2_cdb;
float nin_2_csd;
float nin_2_csg;
float nin_2_css;
float nin_2_csb;
float nin_2_cgd;
float nin_2_cgg;
float nin_2_cgs;
float nin_2_cgb;
float ntail_gmb;
float ntail_cdd;
float ntail_cdg;
float ntail_cds;
float ntail_cdb;
float ntail_csd;
float ntail_csg;
float ntail_css;
float ntail_csb;
float ntail_cgd;
float ntail_cgg;
float ntail_cgs;
float ntail_cgb;
float nref_gmb;
float nref_cdd;
float nref_cdg;
float nref_cds;
float nref_cdb;
float nref_csd;
float nref_csg;
float nref_css;
float nref_csb;
float nref_cgd;
float nref_cgg;
float nref_cgs;
float nref_cgb;
float Det;
float Ted;
float property_Adc;
float property_CMRR;
float property_PSRR;
float config_fail_on_properties;
float property_Rout;
float s;
float property_BW;
float property_BW_s;
float p1;
float p2;
float property_ts;
float property_Cin;
float property_PM;
float p_1_Nt_unit;
float _look_up_tables_pch_thermal_noise_ss_LUT;
float p_1_dNt_dvgs;
float p_1_dNt_dvds;
float p_1_dNt_dvbs;
float p_1_dNt_dl;
float p_1_Nt;
float p_1_Nf_unit;
float _look_up_tables_pch_flicker_noise_ss_LUT;
float p_1_dNf_dvgs;
float p_1_dNf_dvds;
float p_1_dNf_dvbs;
float p_1_dNf_dl;
float p_1_Nf;
float p_2_Nt_unit;
float p_2_dNt_dvgs;
float p_2_dNt_dvds;
float p_2_dNt_dvbs;
float p_2_dNt_dl;
float p_2_Nt;
float p_2_Nf_unit;
float p_2_dNf_dvgs;
float p_2_dNf_dvds;
float p_2_dNf_dvbs;
float p_2_dNf_dl;
float p_2_Nf;
float nin_1_Nt_unit;
float _look_up_tables_nch_thermal_noise_ss_LUT;
float nin_1_dNt_dvgs;
float nin_1_dNt_dvds;
float nin_1_dNt_dvbs;
float nin_1_dNt_dl;
float nin_1_Nt;
float nin_1_Nf_unit;
float _look_up_tables_nch_flicker_noise_ss_LUT;
float nin_1_dNf_dvgs;
float nin_1_dNf_dvds;
float nin_1_dNf_dvbs;
float nin_1_dNf_dl;
float nin_1_Nf;
float nin_2_Nt_unit;
float nin_2_dNt_dvgs;
float nin_2_dNt_dvds;
float nin_2_dNt_dvbs;
float nin_2_dNt_dl;
float nin_2_Nt;
float nin_2_Nf_unit;
float nin_2_dNf_dvgs;
float nin_2_dNf_dvds;
float nin_2_dNf_dvbs;
float nin_2_dNf_dl;
float nin_2_Nf;
float ntail_Nt_unit;
float ntail_dNt_dvgs;
float ntail_dNt_dvds;
float ntail_dNt_dvbs;
float ntail_dNt_dl;
float ntail_Nt;
float ntail_Nf_unit;
float ntail_dNf_dvgs;
float ntail_dNf_dvds;
float ntail_dNf_dvbs;
float ntail_dNf_dl;
float ntail_Nf;
float nref_Nt_unit;
float nref_dNt_dvgs;
float nref_dNt_dvds;
float nref_dNt_dvbs;
float nref_dNt_dl;
float nref_Nt;
float nref_Nf_unit;
float nref_dNf_dvgs;
float nref_dNf_dvds;
float nref_dNf_dvbs;
float nref_dNf_dl;
float nref_Nf;
float property_Nt;
float property_Nf;
float property_fc;
float property_TotalNoise;
float property_Area;
float property_Vos;
float property_Power;
float config_factor_Adc;
float config_shift_Adc;
float config_factor_CMRR;
float config_shift_CMRR;
float config_factor_PSRR;
float config_shift_PSRR;
float config_factor_Rout;
float config_shift_Rout;
float config_factor_BW;
float config_shift_BW;
float config_factor_PM;
float config_shift_PM;
float config_factor_Cin;
float config_shift_Cin;
float config_factor_ts;
float config_shift_ts;
float config_factor_Nt;
float config_shift_Nt;
float config_factor_Nf;
float config_shift_Nf;
float config_factor_TotalNoise;
float config_shift_TotalNoise;
float config_factor_fc;
float config_shift_fc;
float config_factor_Vos;
float config_shift_Vos;
float config_factor_Area;
float config_shift_Area;
float config_factor_Power;
float config_shift_Power;
float circuit_breed_id;
float circuit_breed_target;
// The compiled function
float vos(float isize) {
    float x = property_Area;
    float y = isize;
    float a,b,c,d,e,f,g,h,i,j,k;
    if((x >=0) && (y <= 60)) {
        //Date= Feb 21, 2012
        //Time= 11:11:46 AM
        //File Source= c:_tradeoffresults0nm_char_stdev_40n_nch_ss_-40_ln_g_size_gr_0__isize_lt_60.xls
        //Data= offset_stdev_40n_nch_ss_-40_ln_g_size_gr_0__isize_lt_60.xls : (1)offset_std
        a = 12.8855796266630426;
        b = -5.41083764511328898;
        c = -1.30763085764638906;
        d = 0.313643695922134216;
        e = 0.093119070398655552;
        f = 0.000152253934602799006;
        g = 0.027558789121119705;
        h = -0.0908038658897388513;
        i = -0.00736092968454125981;
        j = 0.00997803516051362148;
        return (a+b*logf(x)+c*pow((logf(x)),2)+d*pow((logf(x)),3)+e*pow((logf(x)),4)+f*pow((logf(x)),5)+g*logf(y)+h*pow((logf(y)),2)+i*pow((logf(y)),3)+j*pow((logf(y)),4))/1000;
    } else if((x <= 0) && (y <= 60)) {
        //Date= Feb 21, 2012
        //Time= 11:23:06 AM
        //File Source= c:_tradeoffresults0nm_char_stdev_40n_nch_ss_-40_ln_g_size_lt_0_isize_lt_60.xls
        //Data= offset_stdev_40n_nch_ss_-40_ln_g_size_lt_0_isize_lt_60.xls : (1)offset_std
        a = 2.93660485783974259;
        b = -0.332364084793881404;
        c = 0.00766917418689004997;
        d = 0.0815859439577785321;
        e = -0.0511853190713728586;
        f = 0.0146507924776217549;
        g = -0.00248296699178136492;
        return (expf(a+b*x+c*pow(x,2)+d*pow(y,(1.5))+e*pow(y,2)+f*pow(y,2)*logf(y)+g*pow(y,(2.5))))/1000;
    } else if((x > 0) && (y > 60)) {
        //Date= Feb 21, 2012
        //Time= 11:29:50 AM
        //File Source= c:_tradeoffresults0nm_char_stdev_40n_nch_ss_-40_ln_g_size_gr_0_isize_gr_60.xls
        //Data= offset_stdev_40n_nch_ss_-40_ln_g_size_gr_0_isize_gr_60.xls : (1)offset_std
        a = 0.0245510804148098408;
        b = 0.00571642685094725414;
        c = -0.038594299737104845;
        d = -0.00293384210596431143;
        e = 0.0164401882567682581;
        return (1/(a+b*pow(x,(2.5))+c*expf(-x)+d*y+e*y/logf(y)))/1000;
    } else {
        //Date= Feb 21, 2012
        //Time= 11:34:55 AM
        //File Source= c:_tradeoffresults0nm_char_stdev_40n_nch_ss_-40_ln_g_size_lt_0_isize_gr_60.xls
        //Data= offset_stdev_40n_nch_ss_-40_ln_g_size_lt_0_isize_gr_60.xls : (1)offset_std
        a = 16.2036851911088104;
        b = 0.21279234971619464;
        c = -1.7053361877790996;
        d = -0.00746030946920476022;
        e = -0.118672118503179062;
        f = 0.0131583901472111854;
        g = -0.138292160061225562;
        h = 1.76686418477095332e-05;
        i = 0.000389109336629294047;
        j = -0.000674088087058916077;
        k = 0.00383260060449367847;
        return (((a+c*x+e*y+g*pow(x,2)+i*pow(y,2)+k*x*y)/(1+b*x+d*y+f*pow(x,2)+h*pow(y,2)+j*x*y))/1000);
    }
}
static int tcl_gamma_import_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    config_pat_size_target=*Pconfig_pat_size_target;
    size_iref=*Psize_iref;
    size_iref_min=*Psize_iref_min;
    size_iref_max=*Psize_iref_max;
    size_Lp=*Psize_Lp;
    size_Lp_min=*Psize_Lp_min;
    size_Lp_max=*Psize_Lp_max;
    size_Wp=*Psize_Wp;
    size_Wp_max=*Psize_Wp_max;
    size_Ln=*Psize_Ln;
    size_Ln_min=*Psize_Ln_min;
    size_Ln_max=*Psize_Ln_max;
    size_Wn=*Psize_Wn;
    size_Wn_max=*Psize_Wn_max;
    size_Ls=*Psize_Ls;
    size_Ls_min=*Psize_Ls_min;
    size_Ls_max=*Psize_Ls_max;
    size_iref_step=*Psize_iref_step;
    size_Lp_step=*Psize_Lp_step;
    size_Wp_step=*Psize_Wp_step;
    size_Ln_step=*Psize_Ln_step;
    size_Wn_step=*Psize_Wn_step;
    size_Ls_step=*Psize_Ls_step;
    max_Adc=*Pmax_Adc;
    param_unique=*Pparam_unique;
    pat_size_target=*Ppat_size_target;
    mode_freash_op=*Pmode_freash_op;
    outm_V=*Poutm_V;
    vdd_V=*Pvdd_V;
    outp_V=*Poutp_V;
    inp_V=*Pinp_V;
    param_inp=*Pparam_inp;
    tail_V=*Ptail_V;
    inn_V=*Pinn_V;
    param_inn=*Pparam_inn;
    vbias_V=*Pvbias_V;
    status_index=*Pstatus_index;
    config_size_iref=*Pconfig_size_iref;
    config_size_Lp=*Pconfig_size_Lp;
    config_size_Wp=*Pconfig_size_Wp;
    config_size_Ln=*Pconfig_size_Ln;
    config_size_Wn=*Pconfig_size_Wn;
    config_size_Ls=*Pconfig_size_Ls;
    CONST_0_V=*P0_V;
    status_fail=*Pstatus_fail;
    design_feedback=*Pdesign_feedback;
    p_1_bin=*Pp_1_bin;
    p_1_L=*Pp_1_L;
    p_1_W=*Pp_1_W;
    p_2_bin=*Pp_2_bin;
    p_2_L=*Pp_2_L;
    p_2_W=*Pp_2_W;
    nin_1_bin=*Pnin_1_bin;
    nin_1_L=*Pnin_1_L;
    nin_1_W=*Pnin_1_W;
    nin_2_bin=*Pnin_2_bin;
    nin_2_L=*Pnin_2_L;
    nin_2_W=*Pnin_2_W;
    ntail_bin=*Pntail_bin;
    ntail_L=*Pntail_L;
    ntail_W=*Pntail_W;
    nref_bin=*Pnref_bin;
    nref_L=*Pnref_L;
    nref_W=*Pnref_W;
    leak=*Pleak;
    config_op_iterations=*Pconfig_op_iterations;
    config_kcl_th=*Pconfig_kcl_th;
    config_design_feedback_th=*Pconfig_design_feedback_th;
    p_1_gb=*Pp_1_gb;
    p_1_gm=*Pp_1_gm;
    p_1_go=*Pp_1_go;
    p_1_Ids=*Pp_1_Ids;
    p_2_gb=*Pp_2_gb;
    p_2_gm=*Pp_2_gm;
    p_2_go=*Pp_2_go;
    p_2_Ids=*Pp_2_Ids;
    nin_1_gb=*Pnin_1_gb;
    nin_1_gm=*Pnin_1_gm;
    nin_1_go=*Pnin_1_go;
    nin_1_Ids=*Pnin_1_Ids;
    nin_2_gb=*Pnin_2_gb;
    nin_2_gm=*Pnin_2_gm;
    nin_2_go=*Pnin_2_go;
    nin_2_Ids=*Pnin_2_Ids;
    ntail_gb=*Pntail_gb;
    ntail_gm=*Pntail_gm;
    ntail_go=*Pntail_go;
    ntail_Ids=*Pntail_Ids;
    nref_gb=*Pnref_gb;
    nref_gm=*Pnref_gm;
    nref_go=*Pnref_go;
    nref_Ids=*Pnref_Ids;
    config_kcl_step=*Pconfig_kcl_step;
    p_1_gmb=*Pp_1_gmb;
    p_1_cdd=*Pp_1_cdd;
    p_1_cdg=*Pp_1_cdg;
    p_1_cds=*Pp_1_cds;
    p_1_cdb=*Pp_1_cdb;
    p_1_csd=*Pp_1_csd;
    p_1_csg=*Pp_1_csg;
    p_1_css=*Pp_1_css;
    p_1_csb=*Pp_1_csb;
    p_1_cgd=*Pp_1_cgd;
    p_1_cgg=*Pp_1_cgg;
    p_1_cgs=*Pp_1_cgs;
    p_1_cgb=*Pp_1_cgb;
    p_2_gmb=*Pp_2_gmb;
    p_2_cdd=*Pp_2_cdd;
    p_2_cdg=*Pp_2_cdg;
    p_2_cds=*Pp_2_cds;
    p_2_cdb=*Pp_2_cdb;
    p_2_csd=*Pp_2_csd;
    p_2_csg=*Pp_2_csg;
    p_2_css=*Pp_2_css;
    p_2_csb=*Pp_2_csb;
    p_2_cgd=*Pp_2_cgd;
    p_2_cgg=*Pp_2_cgg;
    p_2_cgs=*Pp_2_cgs;
    p_2_cgb=*Pp_2_cgb;
    nin_1_gmb=*Pnin_1_gmb;
    nin_1_cdd=*Pnin_1_cdd;
    nin_1_cdg=*Pnin_1_cdg;
    nin_1_cds=*Pnin_1_cds;
    nin_1_cdb=*Pnin_1_cdb;
    nin_1_csd=*Pnin_1_csd;
    nin_1_csg=*Pnin_1_csg;
    nin_1_css=*Pnin_1_css;
    nin_1_csb=*Pnin_1_csb;
    nin_1_cgd=*Pnin_1_cgd;
    nin_1_cgg=*Pnin_1_cgg;
    nin_1_cgs=*Pnin_1_cgs;
    nin_1_cgb=*Pnin_1_cgb;
    nin_2_gmb=*Pnin_2_gmb;
    nin_2_cdd=*Pnin_2_cdd;
    nin_2_cdg=*Pnin_2_cdg;
    nin_2_cds=*Pnin_2_cds;
    nin_2_cdb=*Pnin_2_cdb;
    nin_2_csd=*Pnin_2_csd;
    nin_2_csg=*Pnin_2_csg;
    nin_2_css=*Pnin_2_css;
    nin_2_csb=*Pnin_2_csb;
    nin_2_cgd=*Pnin_2_cgd;
    nin_2_cgg=*Pnin_2_cgg;
    nin_2_cgs=*Pnin_2_cgs;
    nin_2_cgb=*Pnin_2_cgb;
    ntail_gmb=*Pntail_gmb;
    ntail_cdd=*Pntail_cdd;
    ntail_cdg=*Pntail_cdg;
    ntail_cds=*Pntail_cds;
    ntail_cdb=*Pntail_cdb;
    ntail_csd=*Pntail_csd;
    ntail_csg=*Pntail_csg;
    ntail_css=*Pntail_css;
    ntail_csb=*Pntail_csb;
    ntail_cgd=*Pntail_cgd;
    ntail_cgg=*Pntail_cgg;
    ntail_cgs=*Pntail_cgs;
    ntail_cgb=*Pntail_cgb;
    nref_gmb=*Pnref_gmb;
    nref_cdd=*Pnref_cdd;
    nref_cdg=*Pnref_cdg;
    nref_cds=*Pnref_cds;
    nref_cdb=*Pnref_cdb;
    nref_csd=*Pnref_csd;
    nref_csg=*Pnref_csg;
    nref_css=*Pnref_css;
    nref_csb=*Pnref_csb;
    nref_cgd=*Pnref_cgd;
    nref_cgg=*Pnref_cgg;
    nref_cgs=*Pnref_cgs;
    nref_cgb=*Pnref_cgb;
    Det=*PDet;
    Ted=*PTed;
    property_Adc=*Pproperty_Adc;
    property_CMRR=*Pproperty_CMRR;
    property_PSRR=*Pproperty_PSRR;
    config_fail_on_properties=*Pconfig_fail_on_properties;
    property_Rout=*Pproperty_Rout;
    s=*Ps;
    property_BW=*Pproperty_BW;
    property_BW_s=*Pproperty_BW_s;
    p1=*Pp1;
    p2=*Pp2;
    property_ts=*Pproperty_ts;
    property_Cin=*Pproperty_Cin;
    property_PM=*Pproperty_PM;
    p_1_Nt_unit=*Pp_1_Nt_unit;
    p_1_dNt_dvgs=*Pp_1_dNt_dvgs;
    p_1_dNt_dvds=*Pp_1_dNt_dvds;
    p_1_dNt_dvbs=*Pp_1_dNt_dvbs;
    p_1_dNt_dl=*Pp_1_dNt_dl;
    p_1_Nt=*Pp_1_Nt;
    p_1_Nf_unit=*Pp_1_Nf_unit;
    p_1_dNf_dvgs=*Pp_1_dNf_dvgs;
    p_1_dNf_dvds=*Pp_1_dNf_dvds;
    p_1_dNf_dvbs=*Pp_1_dNf_dvbs;
    p_1_dNf_dl=*Pp_1_dNf_dl;
    p_1_Nf=*Pp_1_Nf;
    p_2_Nt_unit=*Pp_2_Nt_unit;
    p_2_dNt_dvgs=*Pp_2_dNt_dvgs;
    p_2_dNt_dvds=*Pp_2_dNt_dvds;
    p_2_dNt_dvbs=*Pp_2_dNt_dvbs;
    p_2_dNt_dl=*Pp_2_dNt_dl;
    p_2_Nt=*Pp_2_Nt;
    p_2_Nf_unit=*Pp_2_Nf_unit;
    p_2_dNf_dvgs=*Pp_2_dNf_dvgs;
    p_2_dNf_dvds=*Pp_2_dNf_dvds;
    p_2_dNf_dvbs=*Pp_2_dNf_dvbs;
    p_2_dNf_dl=*Pp_2_dNf_dl;
    p_2_Nf=*Pp_2_Nf;
    nin_1_Nt_unit=*Pnin_1_Nt_unit;
    nin_1_dNt_dvgs=*Pnin_1_dNt_dvgs;
    nin_1_dNt_dvds=*Pnin_1_dNt_dvds;
    nin_1_dNt_dvbs=*Pnin_1_dNt_dvbs;
    nin_1_dNt_dl=*Pnin_1_dNt_dl;
    nin_1_Nt=*Pnin_1_Nt;
    nin_1_Nf_unit=*Pnin_1_Nf_unit;
    nin_1_dNf_dvgs=*Pnin_1_dNf_dvgs;
    nin_1_dNf_dvds=*Pnin_1_dNf_dvds;
    nin_1_dNf_dvbs=*Pnin_1_dNf_dvbs;
    nin_1_dNf_dl=*Pnin_1_dNf_dl;
    nin_1_Nf=*Pnin_1_Nf;
    nin_2_Nt_unit=*Pnin_2_Nt_unit;
    nin_2_dNt_dvgs=*Pnin_2_dNt_dvgs;
    nin_2_dNt_dvds=*Pnin_2_dNt_dvds;
    nin_2_dNt_dvbs=*Pnin_2_dNt_dvbs;
    nin_2_dNt_dl=*Pnin_2_dNt_dl;
    nin_2_Nt=*Pnin_2_Nt;
    nin_2_Nf_unit=*Pnin_2_Nf_unit;
    nin_2_dNf_dvgs=*Pnin_2_dNf_dvgs;
    nin_2_dNf_dvds=*Pnin_2_dNf_dvds;
    nin_2_dNf_dvbs=*Pnin_2_dNf_dvbs;
    nin_2_dNf_dl=*Pnin_2_dNf_dl;
    nin_2_Nf=*Pnin_2_Nf;
    ntail_Nt_unit=*Pntail_Nt_unit;
    ntail_dNt_dvgs=*Pntail_dNt_dvgs;
    ntail_dNt_dvds=*Pntail_dNt_dvds;
    ntail_dNt_dvbs=*Pntail_dNt_dvbs;
    ntail_dNt_dl=*Pntail_dNt_dl;
    ntail_Nt=*Pntail_Nt;
    ntail_Nf_unit=*Pntail_Nf_unit;
    ntail_dNf_dvgs=*Pntail_dNf_dvgs;
    ntail_dNf_dvds=*Pntail_dNf_dvds;
    ntail_dNf_dvbs=*Pntail_dNf_dvbs;
    ntail_dNf_dl=*Pntail_dNf_dl;
    ntail_Nf=*Pntail_Nf;
    nref_Nt_unit=*Pnref_Nt_unit;
    nref_dNt_dvgs=*Pnref_dNt_dvgs;
    nref_dNt_dvds=*Pnref_dNt_dvds;
    nref_dNt_dvbs=*Pnref_dNt_dvbs;
    nref_dNt_dl=*Pnref_dNt_dl;
    nref_Nt=*Pnref_Nt;
    nref_Nf_unit=*Pnref_Nf_unit;
    nref_dNf_dvgs=*Pnref_dNf_dvgs;
    nref_dNf_dvds=*Pnref_dNf_dvds;
    nref_dNf_dvbs=*Pnref_dNf_dvbs;
    nref_dNf_dl=*Pnref_dNf_dl;
    nref_Nf=*Pnref_Nf;
    property_Nt=*Pproperty_Nt;
    property_Nf=*Pproperty_Nf;
    property_fc=*Pproperty_fc;
    property_TotalNoise=*Pproperty_TotalNoise;
    property_Area=*Pproperty_Area;
    property_Vos=*Pproperty_Vos;
    property_Power=*Pproperty_Power;
    config_factor_Adc=*Pconfig_factor_Adc;
    config_shift_Adc=*Pconfig_shift_Adc;
    config_factor_CMRR=*Pconfig_factor_CMRR;
    config_shift_CMRR=*Pconfig_shift_CMRR;
    config_factor_PSRR=*Pconfig_factor_PSRR;
    config_shift_PSRR=*Pconfig_shift_PSRR;
    config_factor_Rout=*Pconfig_factor_Rout;
    config_shift_Rout=*Pconfig_shift_Rout;
    config_factor_BW=*Pconfig_factor_BW;
    config_shift_BW=*Pconfig_shift_BW;
    config_factor_PM=*Pconfig_factor_PM;
    config_shift_PM=*Pconfig_shift_PM;
    config_factor_Cin=*Pconfig_factor_Cin;
    config_shift_Cin=*Pconfig_shift_Cin;
    config_factor_ts=*Pconfig_factor_ts;
    config_shift_ts=*Pconfig_shift_ts;
    config_factor_Nt=*Pconfig_factor_Nt;
    config_shift_Nt=*Pconfig_shift_Nt;
    config_factor_Nf=*Pconfig_factor_Nf;
    config_shift_Nf=*Pconfig_shift_Nf;
    config_factor_TotalNoise=*Pconfig_factor_TotalNoise;
    config_shift_TotalNoise=*Pconfig_shift_TotalNoise;
    config_factor_fc=*Pconfig_factor_fc;
    config_shift_fc=*Pconfig_shift_fc;
    config_factor_Vos=*Pconfig_factor_Vos;
    config_shift_Vos=*Pconfig_shift_Vos;
    config_factor_Area=*Pconfig_factor_Area;
    config_shift_Area=*Pconfig_shift_Area;
    config_factor_Power=*Pconfig_factor_Power;
    config_shift_Power=*Pconfig_shift_Power;
    circuit_breed_id=*Pcircuit_breed_id;
    circuit_breed_target=*Pcircuit_breed_target;
    return TCL_OK;
}
static int tcl_gamma_export_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    *Pconfig_pat_size_target=config_pat_size_target;
    *Psize_iref=size_iref;
    *Psize_iref_min=size_iref_min;
    *Psize_iref_max=size_iref_max;
    *Psize_Lp=size_Lp;
    *Psize_Lp_min=size_Lp_min;
    *Psize_Lp_max=size_Lp_max;
    *Psize_Wp=size_Wp;
    *Psize_Wp_max=size_Wp_max;
    *Psize_Ln=size_Ln;
    *Psize_Ln_min=size_Ln_min;
    *Psize_Ln_max=size_Ln_max;
    *Psize_Wn=size_Wn;
    *Psize_Wn_max=size_Wn_max;
    *Psize_Ls=size_Ls;
    *Psize_Ls_min=size_Ls_min;
    *Psize_Ls_max=size_Ls_max;
    *Psize_iref_step=size_iref_step;
    *Psize_Lp_step=size_Lp_step;
    *Psize_Wp_step=size_Wp_step;
    *Psize_Ln_step=size_Ln_step;
    *Psize_Wn_step=size_Wn_step;
    *Psize_Ls_step=size_Ls_step;
    *Pmax_Adc=max_Adc;
    *Pparam_unique=param_unique;
    *Ppat_size_target=pat_size_target;
    *Pmode_freash_op=mode_freash_op;
    *Poutm_V=outm_V;
    *Pvdd_V=vdd_V;
    *Poutp_V=outp_V;
    *Pinp_V=inp_V;
    *Pparam_inp=param_inp;
    *Ptail_V=tail_V;
    *Pinn_V=inn_V;
    *Pparam_inn=param_inn;
    *Pvbias_V=vbias_V;
    *Pstatus_index=status_index;
    *Pconfig_size_iref=config_size_iref;
    *Pconfig_size_Lp=config_size_Lp;
    *Pconfig_size_Wp=config_size_Wp;
    *Pconfig_size_Ln=config_size_Ln;
    *Pconfig_size_Wn=config_size_Wn;
    *Pconfig_size_Ls=config_size_Ls;
    *P0_V=CONST_0_V;
    *Pstatus_fail=status_fail;
    *Pdesign_feedback=design_feedback;
    *Pp_1_bin=p_1_bin;
    *Pp_1_L=p_1_L;
    *Pp_1_W=p_1_W;
    *Pp_2_bin=p_2_bin;
    *Pp_2_L=p_2_L;
    *Pp_2_W=p_2_W;
    *Pnin_1_bin=nin_1_bin;
    *Pnin_1_L=nin_1_L;
    *Pnin_1_W=nin_1_W;
    *Pnin_2_bin=nin_2_bin;
    *Pnin_2_L=nin_2_L;
    *Pnin_2_W=nin_2_W;
    *Pntail_bin=ntail_bin;
    *Pntail_L=ntail_L;
    *Pntail_W=ntail_W;
    *Pnref_bin=nref_bin;
    *Pnref_L=nref_L;
    *Pnref_W=nref_W;
    *Pleak=leak;
    *Pconfig_op_iterations=config_op_iterations;
    *Pconfig_kcl_th=config_kcl_th;
    *Pconfig_design_feedback_th=config_design_feedback_th;
    *Pp_1_gb=p_1_gb;
    *Pp_1_gm=p_1_gm;
    *Pp_1_go=p_1_go;
    *Pp_1_Ids=p_1_Ids;
    *Pp_2_gb=p_2_gb;
    *Pp_2_gm=p_2_gm;
    *Pp_2_go=p_2_go;
    *Pp_2_Ids=p_2_Ids;
    *Pnin_1_gb=nin_1_gb;
    *Pnin_1_gm=nin_1_gm;
    *Pnin_1_go=nin_1_go;
    *Pnin_1_Ids=nin_1_Ids;
    *Pnin_2_gb=nin_2_gb;
    *Pnin_2_gm=nin_2_gm;
    *Pnin_2_go=nin_2_go;
    *Pnin_2_Ids=nin_2_Ids;
    *Pntail_gb=ntail_gb;
    *Pntail_gm=ntail_gm;
    *Pntail_go=ntail_go;
    *Pntail_Ids=ntail_Ids;
    *Pnref_gb=nref_gb;
    *Pnref_gm=nref_gm;
    *Pnref_go=nref_go;
    *Pnref_Ids=nref_Ids;
    *Pconfig_kcl_step=config_kcl_step;
    *Pp_1_gmb=p_1_gmb;
    *Pp_1_cdd=p_1_cdd;
    *Pp_1_cdg=p_1_cdg;
    *Pp_1_cds=p_1_cds;
    *Pp_1_cdb=p_1_cdb;
    *Pp_1_csd=p_1_csd;
    *Pp_1_csg=p_1_csg;
    *Pp_1_css=p_1_css;
    *Pp_1_csb=p_1_csb;
    *Pp_1_cgd=p_1_cgd;
    *Pp_1_cgg=p_1_cgg;
    *Pp_1_cgs=p_1_cgs;
    *Pp_1_cgb=p_1_cgb;
    *Pp_2_gmb=p_2_gmb;
    *Pp_2_cdd=p_2_cdd;
    *Pp_2_cdg=p_2_cdg;
    *Pp_2_cds=p_2_cds;
    *Pp_2_cdb=p_2_cdb;
    *Pp_2_csd=p_2_csd;
    *Pp_2_csg=p_2_csg;
    *Pp_2_css=p_2_css;
    *Pp_2_csb=p_2_csb;
    *Pp_2_cgd=p_2_cgd;
    *Pp_2_cgg=p_2_cgg;
    *Pp_2_cgs=p_2_cgs;
    *Pp_2_cgb=p_2_cgb;
    *Pnin_1_gmb=nin_1_gmb;
    *Pnin_1_cdd=nin_1_cdd;
    *Pnin_1_cdg=nin_1_cdg;
    *Pnin_1_cds=nin_1_cds;
    *Pnin_1_cdb=nin_1_cdb;
    *Pnin_1_csd=nin_1_csd;
    *Pnin_1_csg=nin_1_csg;
    *Pnin_1_css=nin_1_css;
    *Pnin_1_csb=nin_1_csb;
    *Pnin_1_cgd=nin_1_cgd;
    *Pnin_1_cgg=nin_1_cgg;
    *Pnin_1_cgs=nin_1_cgs;
    *Pnin_1_cgb=nin_1_cgb;
    *Pnin_2_gmb=nin_2_gmb;
    *Pnin_2_cdd=nin_2_cdd;
    *Pnin_2_cdg=nin_2_cdg;
    *Pnin_2_cds=nin_2_cds;
    *Pnin_2_cdb=nin_2_cdb;
    *Pnin_2_csd=nin_2_csd;
    *Pnin_2_csg=nin_2_csg;
    *Pnin_2_css=nin_2_css;
    *Pnin_2_csb=nin_2_csb;
    *Pnin_2_cgd=nin_2_cgd;
    *Pnin_2_cgg=nin_2_cgg;
    *Pnin_2_cgs=nin_2_cgs;
    *Pnin_2_cgb=nin_2_cgb;
    *Pntail_gmb=ntail_gmb;
    *Pntail_cdd=ntail_cdd;
    *Pntail_cdg=ntail_cdg;
    *Pntail_cds=ntail_cds;
    *Pntail_cdb=ntail_cdb;
    *Pntail_csd=ntail_csd;
    *Pntail_csg=ntail_csg;
    *Pntail_css=ntail_css;
    *Pntail_csb=ntail_csb;
    *Pntail_cgd=ntail_cgd;
    *Pntail_cgg=ntail_cgg;
    *Pntail_cgs=ntail_cgs;
    *Pntail_cgb=ntail_cgb;
    *Pnref_gmb=nref_gmb;
    *Pnref_cdd=nref_cdd;
    *Pnref_cdg=nref_cdg;
    *Pnref_cds=nref_cds;
    *Pnref_cdb=nref_cdb;
    *Pnref_csd=nref_csd;
    *Pnref_csg=nref_csg;
    *Pnref_css=nref_css;
    *Pnref_csb=nref_csb;
    *Pnref_cgd=nref_cgd;
    *Pnref_cgg=nref_cgg;
    *Pnref_cgs=nref_cgs;
    *Pnref_cgb=nref_cgb;
    *PDet=Det;
    *PTed=Ted;
    *Pproperty_Adc=property_Adc;
    *Pproperty_CMRR=property_CMRR;
    *Pproperty_PSRR=property_PSRR;
    *Pconfig_fail_on_properties=config_fail_on_properties;
    *Pproperty_Rout=property_Rout;
    *Ps=s;
    *Pproperty_BW=property_BW;
    *Pproperty_BW_s=property_BW_s;
    *Pp1=p1;
    *Pp2=p2;
    *Pproperty_ts=property_ts;
    *Pproperty_Cin=property_Cin;
    *Pproperty_PM=property_PM;
    *Pp_1_Nt_unit=p_1_Nt_unit;
    *Pp_1_dNt_dvgs=p_1_dNt_dvgs;
    *Pp_1_dNt_dvds=p_1_dNt_dvds;
    *Pp_1_dNt_dvbs=p_1_dNt_dvbs;
    *Pp_1_dNt_dl=p_1_dNt_dl;
    *Pp_1_Nt=p_1_Nt;
    *Pp_1_Nf_unit=p_1_Nf_unit;
    *Pp_1_dNf_dvgs=p_1_dNf_dvgs;
    *Pp_1_dNf_dvds=p_1_dNf_dvds;
    *Pp_1_dNf_dvbs=p_1_dNf_dvbs;
    *Pp_1_dNf_dl=p_1_dNf_dl;
    *Pp_1_Nf=p_1_Nf;
    *Pp_2_Nt_unit=p_2_Nt_unit;
    *Pp_2_dNt_dvgs=p_2_dNt_dvgs;
    *Pp_2_dNt_dvds=p_2_dNt_dvds;
    *Pp_2_dNt_dvbs=p_2_dNt_dvbs;
    *Pp_2_dNt_dl=p_2_dNt_dl;
    *Pp_2_Nt=p_2_Nt;
    *Pp_2_Nf_unit=p_2_Nf_unit;
    *Pp_2_dNf_dvgs=p_2_dNf_dvgs;
    *Pp_2_dNf_dvds=p_2_dNf_dvds;
    *Pp_2_dNf_dvbs=p_2_dNf_dvbs;
    *Pp_2_dNf_dl=p_2_dNf_dl;
    *Pp_2_Nf=p_2_Nf;
    *Pnin_1_Nt_unit=nin_1_Nt_unit;
    *Pnin_1_dNt_dvgs=nin_1_dNt_dvgs;
    *Pnin_1_dNt_dvds=nin_1_dNt_dvds;
    *Pnin_1_dNt_dvbs=nin_1_dNt_dvbs;
    *Pnin_1_dNt_dl=nin_1_dNt_dl;
    *Pnin_1_Nt=nin_1_Nt;
    *Pnin_1_Nf_unit=nin_1_Nf_unit;
    *Pnin_1_dNf_dvgs=nin_1_dNf_dvgs;
    *Pnin_1_dNf_dvds=nin_1_dNf_dvds;
    *Pnin_1_dNf_dvbs=nin_1_dNf_dvbs;
    *Pnin_1_dNf_dl=nin_1_dNf_dl;
    *Pnin_1_Nf=nin_1_Nf;
    *Pnin_2_Nt_unit=nin_2_Nt_unit;
    *Pnin_2_dNt_dvgs=nin_2_dNt_dvgs;
    *Pnin_2_dNt_dvds=nin_2_dNt_dvds;
    *Pnin_2_dNt_dvbs=nin_2_dNt_dvbs;
    *Pnin_2_dNt_dl=nin_2_dNt_dl;
    *Pnin_2_Nt=nin_2_Nt;
    *Pnin_2_Nf_unit=nin_2_Nf_unit;
    *Pnin_2_dNf_dvgs=nin_2_dNf_dvgs;
    *Pnin_2_dNf_dvds=nin_2_dNf_dvds;
    *Pnin_2_dNf_dvbs=nin_2_dNf_dvbs;
    *Pnin_2_dNf_dl=nin_2_dNf_dl;
    *Pnin_2_Nf=nin_2_Nf;
    *Pntail_Nt_unit=ntail_Nt_unit;
    *Pntail_dNt_dvgs=ntail_dNt_dvgs;
    *Pntail_dNt_dvds=ntail_dNt_dvds;
    *Pntail_dNt_dvbs=ntail_dNt_dvbs;
    *Pntail_dNt_dl=ntail_dNt_dl;
    *Pntail_Nt=ntail_Nt;
    *Pntail_Nf_unit=ntail_Nf_unit;
    *Pntail_dNf_dvgs=ntail_dNf_dvgs;
    *Pntail_dNf_dvds=ntail_dNf_dvds;
    *Pntail_dNf_dvbs=ntail_dNf_dvbs;
    *Pntail_dNf_dl=ntail_dNf_dl;
    *Pntail_Nf=ntail_Nf;
    *Pnref_Nt_unit=nref_Nt_unit;
    *Pnref_dNt_dvgs=nref_dNt_dvgs;
    *Pnref_dNt_dvds=nref_dNt_dvds;
    *Pnref_dNt_dvbs=nref_dNt_dvbs;
    *Pnref_dNt_dl=nref_dNt_dl;
    *Pnref_Nt=nref_Nt;
    *Pnref_Nf_unit=nref_Nf_unit;
    *Pnref_dNf_dvgs=nref_dNf_dvgs;
    *Pnref_dNf_dvds=nref_dNf_dvds;
    *Pnref_dNf_dvbs=nref_dNf_dvbs;
    *Pnref_dNf_dl=nref_dNf_dl;
    *Pnref_Nf=nref_Nf;
    *Pproperty_Nt=property_Nt;
    *Pproperty_Nf=property_Nf;
    *Pproperty_fc=property_fc;
    *Pproperty_TotalNoise=property_TotalNoise;
    *Pproperty_Area=property_Area;
    *Pproperty_Vos=property_Vos;
    *Pproperty_Power=property_Power;
    *Pconfig_factor_Adc=config_factor_Adc;
    *Pconfig_shift_Adc=config_shift_Adc;
    *Pconfig_factor_CMRR=config_factor_CMRR;
    *Pconfig_shift_CMRR=config_shift_CMRR;
    *Pconfig_factor_PSRR=config_factor_PSRR;
    *Pconfig_shift_PSRR=config_shift_PSRR;
    *Pconfig_factor_Rout=config_factor_Rout;
    *Pconfig_shift_Rout=config_shift_Rout;
    *Pconfig_factor_BW=config_factor_BW;
    *Pconfig_shift_BW=config_shift_BW;
    *Pconfig_factor_PM=config_factor_PM;
    *Pconfig_shift_PM=config_shift_PM;
    *Pconfig_factor_Cin=config_factor_Cin;
    *Pconfig_shift_Cin=config_shift_Cin;
    *Pconfig_factor_ts=config_factor_ts;
    *Pconfig_shift_ts=config_shift_ts;
    *Pconfig_factor_Nt=config_factor_Nt;
    *Pconfig_shift_Nt=config_shift_Nt;
    *Pconfig_factor_Nf=config_factor_Nf;
    *Pconfig_shift_Nf=config_shift_Nf;
    *Pconfig_factor_TotalNoise=config_factor_TotalNoise;
    *Pconfig_shift_TotalNoise=config_shift_TotalNoise;
    *Pconfig_factor_fc=config_factor_fc;
    *Pconfig_shift_fc=config_shift_fc;
    *Pconfig_factor_Vos=config_factor_Vos;
    *Pconfig_shift_Vos=config_shift_Vos;
    *Pconfig_factor_Area=config_factor_Area;
    *Pconfig_shift_Area=config_shift_Area;
    *Pconfig_factor_Power=config_factor_Power;
    *Pconfig_shift_Power=config_shift_Power;
    *Pcircuit_breed_id=circuit_breed_id;
    *Pcircuit_breed_target=circuit_breed_target;
    return TCL_OK;
}
static int tcl_gamma_op_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    //            Tcl_ResetResult(interp);
    if (mode_freash_op) {
        outm_V=vdd_V/2;
        outp_V=vdd_V/2;
        inp_V=param_inp;
        tail_V=vdd_V/2;
        inn_V=param_inn;
        vbias_V=vdd_V/2;
    }
    status_index=0;
    if(config_size_iref!=0) size_iref=config_size_iref;
    if(config_size_Lp!=0) size_Lp=config_size_Lp;
    if(config_size_Wp!=0) size_Wp=config_size_Wp;
    if(config_size_Ln!=0) size_Ln=config_size_Ln;
    if(config_size_Wn!=0) size_Wn=config_size_Wn;
    if(config_size_Ls!=0) size_Ls=config_size_Ls;
    vdd_V=1.1;
    CONST_0_V=0;
    // Calculating circuit operating point:
    int op_it=0;
    status_fail=-1;
    design_feedback=1000;
    p_1_bin=get_transistor_bin(Plook_up_tables_pch_binning_LUT,p_1_L,p_1_W);
    p_2_bin=get_transistor_bin(Plook_up_tables_pch_binning_LUT,p_2_L,p_2_W);
    nin_1_bin=get_transistor_bin(Plook_up_tables_nch_binning_LUT,nin_1_L,nin_1_W);
    nin_2_bin=get_transistor_bin(Plook_up_tables_nch_binning_LUT,nin_2_L,nin_2_W);
    ntail_bin=get_transistor_bin(Plook_up_tables_nch_binning_LUT,ntail_L,ntail_W);
    nref_bin=get_transistor_bin(Plook_up_tables_nch_binning_LUT,nref_L,nref_W);
    leak=1e3;
    float node_step=0;
    for (op_it=0;(op_it<config_op_iterations)&&((leak>config_kcl_th)||(design_feedback>config_design_feedback_th));op_it++) {
        float previous_out_dc=outp_V;
        composite_gamma_gcc_interpolate_2p3(p_1_bin,Plook_up_tables_pch_Ids_ss_CONTEXT,Plook_up_tables_pch_gm_ss_CONTEXT,Plook_up_tables_pch_go_ss_CONTEXT,Plook_up_tables_pch_gb_ss_CONTEXT,&(p_1_gb),&(p_1_gm),&(p_1_go),&(p_1_Ids),(outm_V)-(vdd_V),(outm_V)-(vdd_V),(vdd_V)-(vdd_V),size_Lp,size_Wp);
        if (p_1_Ids<0) p_1_Ids=0;
        if (p_1_Ids>1e-3) p_1_Ids=1e-3;
        p_1_Ids=-p_1_Ids;
        composite_gamma_gcc_interpolate_2p3(p_2_bin,Plook_up_tables_pch_Ids_ss_CONTEXT,Plook_up_tables_pch_gm_ss_CONTEXT,Plook_up_tables_pch_go_ss_CONTEXT,Plook_up_tables_pch_gb_ss_CONTEXT,&(p_2_gb),&(p_2_gm),&(p_2_go),&(p_2_Ids),(outm_V)-(vdd_V),(outp_V)-(vdd_V),(vdd_V)-(vdd_V),size_Lp,size_Wp);
        if (p_2_Ids<0) p_2_Ids=0;
        if (p_2_Ids>1e-3) p_2_Ids=1e-3;
        p_2_Ids=-p_2_Ids;
        composite_gamma_gcc_interpolate_2p3(nin_1_bin,Plook_up_tables_nch_Ids_ss_CONTEXT,Plook_up_tables_nch_gm_ss_CONTEXT,Plook_up_tables_nch_go_ss_CONTEXT,Plook_up_tables_nch_gb_ss_CONTEXT,&(nin_1_gb),&(nin_1_gm),&(nin_1_go),&(nin_1_Ids),(inp_V)-(tail_V),(outm_V)-(tail_V),(CONST_0_V)-(tail_V),size_Ln,size_Wn);
        if (nin_1_Ids<0) nin_1_Ids=0;
        if (nin_1_Ids>1e-3) nin_1_Ids=1e-3;
        composite_gamma_gcc_interpolate_2p3(nin_2_bin,Plook_up_tables_nch_Ids_ss_CONTEXT,Plook_up_tables_nch_gm_ss_CONTEXT,Plook_up_tables_nch_go_ss_CONTEXT,Plook_up_tables_nch_gb_ss_CONTEXT,&(nin_2_gb),&(nin_2_gm),&(nin_2_go),&(nin_2_Ids),(inn_V)-(tail_V),(outp_V)-(tail_V),(CONST_0_V)-(tail_V),size_Ln,size_Wn);
        if (nin_2_Ids<0) nin_2_Ids=0;
        if (nin_2_Ids>1e-3) nin_2_Ids=1e-3;
        composite_gamma_gcc_interpolate_2p3(ntail_bin,Plook_up_tables_nch_Ids_ss_CONTEXT,Plook_up_tables_nch_gm_ss_CONTEXT,Plook_up_tables_nch_go_ss_CONTEXT,Plook_up_tables_nch_gb_ss_CONTEXT,&(ntail_gb),&(ntail_gm),&(ntail_go),&(ntail_Ids),(vbias_V)-(CONST_0_V),(tail_V)-(CONST_0_V),(CONST_0_V)-(CONST_0_V),size_Ls,size_Ls*2*size_Wn/size_Ln);
        if (ntail_Ids<0) ntail_Ids=0;
        if (ntail_Ids>1e-3) ntail_Ids=1e-3;
        composite_gamma_gcc_interpolate_2p3(nref_bin,Plook_up_tables_nch_Ids_ss_CONTEXT,Plook_up_tables_nch_gm_ss_CONTEXT,Plook_up_tables_nch_go_ss_CONTEXT,Plook_up_tables_nch_gb_ss_CONTEXT,&(nref_gb),&(nref_gm),&(nref_go),&(nref_Ids),(vbias_V)-(CONST_0_V),(vbias_V)-(CONST_0_V),(CONST_0_V)-(CONST_0_V),size_Ls,size_Ls*2*size_Wn/size_Ln);
        if (nref_Ids<0) nref_Ids=0;
        if (nref_Ids>1e-3) nref_Ids=1e-3;
        if (p_1_gm==0) p_1_gm=1e-6;
        if (p_1_go==0) p_1_go=1e-6;
        if (p_2_gm==0) p_2_gm=1e-6;
        if (p_2_go==0) p_2_go=1e-6;
        if (nin_1_gm==0) nin_1_gm=1e-6;
        if (nin_1_go==0) nin_1_go=1e-6;
        if (nin_2_gm==0) nin_2_gm=1e-6;
        if (nin_2_go==0) nin_2_go=1e-6;
        if (ntail_gm==0) ntail_gm=1e-6;
        if (ntail_go==0) ntail_go=1e-6;
        if (nref_gm==0) nref_gm=1e-6;
        if (nref_go==0) nref_go=1e-6;
        // Updating node voltages
        leak=0;
        node_step=config_kcl_step*(-nin_1_Ids-p_1_Ids)/(p_1_go+nin_1_go);
        if (node_step<-0.02) node_step=-0.02;
        if (node_step>0.02) node_step=0.02;
        outm_V+=node_step;
        if (fabs(-nin_1_Ids-p_1_Ids)>leak) leak=fabs(-nin_1_Ids-p_1_Ids);
        if (outm_V<0) outm_V=0;
        if (outm_V>1.1) outm_V=1.1;
        node_step=config_kcl_step*(-nin_2_Ids-p_2_Ids)/(p_2_go+nin_2_go);
        if (node_step<-0.02) node_step=-0.02;
        if (node_step>0.02) node_step=0.02;
        outp_V+=node_step;
        if (fabs(-nin_2_Ids-p_2_Ids)>leak) leak=fabs(-nin_2_Ids-p_2_Ids);
        if (outp_V<0) outp_V=0;
        if (outp_V>1.1) outp_V=1.1;
        node_step=config_kcl_step*(-ntail_Ids+nin_2_Ids+nin_1_Ids)/(nin_1_go+nin_1_gb+nin_2_go+nin_2_gb+ntail_go);
        if (node_step<-0.02) node_step=-0.02;
        if (node_step>0.02) node_step=0.02;
        tail_V+=node_step;
        if (fabs(-ntail_Ids+nin_2_Ids+nin_1_Ids)>leak) leak=fabs(-ntail_Ids+nin_2_Ids+nin_1_Ids);
        if (tail_V<0) tail_V=0;
        if (tail_V>1.1) tail_V=1.1;
        node_step=config_kcl_step*(-nref_Ids+size_iref)/(nref_go);
        if (node_step<-0.02) node_step=-0.02;
        if (node_step>0.02) node_step=0.02;
        vbias_V+=node_step;
        if (fabs(-nref_Ids+size_iref)>leak) leak=fabs(-nref_Ids+size_iref);
        if (vbias_V<0) vbias_V=0;
        if (vbias_V>1.1) vbias_V=1.1;
        design_feedback=0;
    }
    if (op_it>=config_op_iterations) {status_fail=leak; return TCL_ERROR;}
    if (vdd_V<outm_V) {status_fail=4; return TCL_ERROR;}
    if (vdd_V<outp_V) {status_fail=4; return TCL_ERROR;}
    if (tail_V>outm_V) {status_fail=3; return TCL_ERROR;}
    if (tail_V>outp_V) {status_fail=3; return TCL_ERROR;}
    if (CONST_0_V>tail_V) {status_fail=3; return TCL_ERROR;}
    if (CONST_0_V>vbias_V) {status_fail=3; return TCL_ERROR;}
    float W,M;
    float L;
    int section;
    Gamma_tsmc040_Calc(1,0,(outm_V)-(vdd_V),(outm_V)-(vdd_V),(vdd_V)-(vdd_V),size_Lp,size_Wp
    ,&(p_1_Ids)
    ,&(p_1_gm)
    ,&(p_1_gmb)
    ,&(p_1_go)
    ,&(p_1_cdd)
    ,&(p_1_cdg)
    ,&(p_1_cds)
    ,&(p_1_cdb)
    ,&(p_1_csd)
    ,&(p_1_csg)
    ,&(p_1_css)
    ,&(p_1_csb)
    ,&(p_1_cgd)
    ,&(p_1_cgg)
    ,&(p_1_cgs)
    ,&(p_1_cgb)
    );
    Gamma_tsmc040_Calc(1,0,(outm_V)-(vdd_V),(outp_V)-(vdd_V),(vdd_V)-(vdd_V),size_Lp,size_Wp
    ,&(p_2_Ids)
    ,&(p_2_gm)
    ,&(p_2_gmb)
    ,&(p_2_go)
    ,&(p_2_cdd)
    ,&(p_2_cdg)
    ,&(p_2_cds)
    ,&(p_2_cdb)
    ,&(p_2_csd)
    ,&(p_2_csg)
    ,&(p_2_css)
    ,&(p_2_csb)
    ,&(p_2_cgd)
    ,&(p_2_cgg)
    ,&(p_2_cgs)
    ,&(p_2_cgb)
    );
    Gamma_tsmc040_Calc(0,0,(inp_V)-(tail_V),(outm_V)-(tail_V),(CONST_0_V)-(tail_V),size_Ln,size_Wn
    ,&(nin_1_Ids)
    ,&(nin_1_gm)
    ,&(nin_1_gmb)
    ,&(nin_1_go)
    ,&(nin_1_cdd)
    ,&(nin_1_cdg)
    ,&(nin_1_cds)
    ,&(nin_1_cdb)
    ,&(nin_1_csd)
    ,&(nin_1_csg)
    ,&(nin_1_css)
    ,&(nin_1_csb)
    ,&(nin_1_cgd)
    ,&(nin_1_cgg)
    ,&(nin_1_cgs)
    ,&(nin_1_cgb)
    );
    Gamma_tsmc040_Calc(0,0,(inn_V)-(tail_V),(outp_V)-(tail_V),(CONST_0_V)-(tail_V),size_Ln,size_Wn
    ,&(nin_2_Ids)
    ,&(nin_2_gm)
    ,&(nin_2_gmb)
    ,&(nin_2_go)
    ,&(nin_2_cdd)
    ,&(nin_2_cdg)
    ,&(nin_2_cds)
    ,&(nin_2_cdb)
    ,&(nin_2_csd)
    ,&(nin_2_csg)
    ,&(nin_2_css)
    ,&(nin_2_csb)
    ,&(nin_2_cgd)
    ,&(nin_2_cgg)
    ,&(nin_2_cgs)
    ,&(nin_2_cgb)
    );
    Gamma_tsmc040_Calc(0,0,(vbias_V)-(CONST_0_V),(tail_V)-(CONST_0_V),(CONST_0_V)-(CONST_0_V),size_Ls,size_Ls*2*size_Wn/size_Ln
    ,&(ntail_Ids)
    ,&(ntail_gm)
    ,&(ntail_gmb)
    ,&(ntail_go)
    ,&(ntail_cdd)
    ,&(ntail_cdg)
    ,&(ntail_cds)
    ,&(ntail_cdb)
    ,&(ntail_csd)
    ,&(ntail_csg)
    ,&(ntail_css)
    ,&(ntail_csb)
    ,&(ntail_cgd)
    ,&(ntail_cgg)
    ,&(ntail_cgs)
    ,&(ntail_cgb)
    );
    Gamma_tsmc040_Calc(0,0,(vbias_V)-(CONST_0_V),(vbias_V)-(CONST_0_V),(CONST_0_V)-(CONST_0_V),size_Ls,size_Ls*2*size_Wn/size_Ln
    ,&(nref_Ids)
    ,&(nref_gm)
    ,&(nref_gmb)
    ,&(nref_go)
    ,&(nref_cdd)
    ,&(nref_cdg)
    ,&(nref_cds)
    ,&(nref_cdb)
    ,&(nref_csd)
    ,&(nref_csg)
    ,&(nref_css)
    ,&(nref_csb)
    ,&(nref_cgd)
    ,&(nref_cgg)
    ,&(nref_cgs)
    ,&(nref_cgb)
    );
    Det=(-(((p_1_go+p_1_gm)+nin_1_go)*((p_2_go+nin_2_go)*((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_2_go)+nin_2_gm)+nin_2_gb)+ntail_go)*(nref_go+nref_gm)-(((-nin_2_go)-nin_2_gm)-nin_2_gb)*(-nin_2_go)*(nref_go+nref_gm))+(((-nin_1_go)-nin_1_gm)-nin_1_gb)*(p_2_gm*(-nin_2_go)*(nref_go+nref_gm)-(p_2_go+nin_2_go)*(-nin_1_go)*(nref_go+nref_gm))));
    Ted=1/Det;
    double der_p=(-0);
    double der_n=(-0);
    property_Adc=0.5*Ted*(fabs(der_p)+fabs(der_n));
    property_CMRR=Ted*(fabs(der_p)-fabs(der_n));
    property_PSRR=Ted*((-0));
    property_Adc=fabs(property_Adc);
    if ((property_Adc<1)&&(config_fail_on_properties)) {status_fail=2; return TCL_ERROR;}
    property_Rout=fabs(((-(((p_1_go+p_1_gm)+nin_1_go)*((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_2_go)+nin_2_gm)+nin_2_gb)+ntail_go)*(nref_go+nref_gm)+(((-nin_1_go)-nin_1_gm)-nin_1_gb)*(-(-nin_1_go)*(nref_go+nref_gm)))))*Ted);
    s=-1;
    int BW_it;
    W=0;
    float BW_Mag0=1;
    float BW_Mag=1;
    float snr;
    float sni;
    float sdr;
    float sdi;
    while ((BW_Mag0/BW_Mag)<2) {
        snr=0;
        sni=0;
        sdr=-((p_1_go+p_1_gm+nin_1_go)*((p_2_go+nin_2_go)*((nin_1_go+nin_1_gm+nin_1_gb+nin_2_go+nin_2_gm+nin_2_gb+ntail_go)*(nref_go+nref_gm)-(nin_1_css*W+nin_2_css*W+ntail_cdd*W)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+ntail_cdg*W*ntail_cgd*W)-(p_2_cdd*W+nin_2_cdd*W)*((nin_1_go+nin_1_gm+nin_1_gb+nin_2_go+nin_2_gm+nin_2_gb+ntail_go)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+(nin_1_css*W+nin_2_css*W+ntail_cdd*W)*(nref_go+nref_gm)-ntail_gm*ntail_cgd*W)-((-nin_2_go-nin_2_gm-nin_2_gb)*(-nin_2_go)-nin_2_cds*W*nin_2_csd*W)*(nref_go+nref_gm)-((-nin_2_go-nin_2_gm-nin_2_gb)*nin_2_csd*W+nin_2_cds*W*(-nin_2_go))*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W))-(p_1_cgd*W+p_1_cgg*W+p_1_cdd*W+p_1_cdg*W+p_2_cgg*W+nin_1_cdd*W)*((p_2_go+nin_2_go)*((nin_1_go+nin_1_gm+nin_1_gb+nin_2_go+nin_2_gm+nin_2_gb+ntail_go)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+(nin_1_css*W+nin_2_css*W+ntail_cdd*W)*(nref_go+nref_gm)-ntail_gm*ntail_cgd*W)+(p_2_cdd*W+nin_2_cdd*W)*((nin_1_go+nin_1_gm+nin_1_gb+nin_2_go+nin_2_gm+nin_2_gb+ntail_go)*(nref_go+nref_gm)-(nin_1_css*W+nin_2_css*W+ntail_cdd*W)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+ntail_cdg*W*ntail_cgd*W)-((-nin_2_go-nin_2_gm-nin_2_gb)*(-nin_2_go)-nin_2_cds*W*nin_2_csd*W)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+((-nin_2_go-nin_2_gm-nin_2_gb)*nin_2_csd*W+nin_2_cds*W*(-nin_2_go))*(nref_go+nref_gm))+(p_2_cgd*W*(p_2_gm*((nin_1_go+nin_1_gm+nin_1_gb+nin_2_go+nin_2_gm+nin_2_gb+ntail_go)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+(nin_1_css*W+nin_2_css*W+ntail_cdd*W)*(nref_go+nref_gm)-ntail_gm*ntail_cgd*W)+p_2_cdg*W*((nin_1_go+nin_1_gm+nin_1_gb+nin_2_go+nin_2_gm+nin_2_gb+ntail_go)*(nref_go+nref_gm)-(nin_1_css*W+nin_2_css*W+ntail_cdd*W)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+ntail_cdg*W*ntail_cgd*W)-((-nin_2_go-nin_2_gm-nin_2_gb)*(-nin_1_go)-nin_2_cds*W*nin_1_csd*W)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+((-nin_2_go-nin_2_gm-nin_2_gb)*nin_1_csd*W+nin_2_cds*W*(-nin_1_go))*(nref_go+nref_gm)))+(-nin_1_go-nin_1_gm-nin_1_gb)*((p_2_gm*(-nin_2_go)-p_2_cdg*W*nin_2_csd*W)*(nref_go+nref_gm)-(p_2_gm*nin_2_csd*W+p_2_cdg*W*(-nin_2_go))*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)-((p_2_go+nin_2_go)*(-nin_1_go)-(p_2_cdd*W+nin_2_cdd*W)*nin_1_csd*W)*(nref_go+nref_gm)-((p_2_go+nin_2_go)*nin_1_csd*W+(p_2_cdd*W+nin_2_cdd*W)*(-nin_1_go))*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W))-nin_1_cds*W*((p_2_gm*(-nin_2_go)-p_2_cdg*W*nin_2_csd*W)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+(p_2_gm*nin_2_csd*W+p_2_cdg*W*(-nin_2_go))*(nref_go+nref_gm)-((p_2_go+nin_2_go)*(-nin_1_go)-(p_2_cdd*W+nin_2_cdd*W)*nin_1_csd*W)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+((p_2_go+nin_2_go)*nin_1_csd*W+(p_2_cdd*W+nin_2_cdd*W)*(-nin_1_go))*(nref_go+nref_gm)));
        sdi=-((p_1_go+p_1_gm+nin_1_go)*((p_2_go+nin_2_go)*((nin_1_go+nin_1_gm+nin_1_gb+nin_2_go+nin_2_gm+nin_2_gb+ntail_go)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+(nin_1_css*W+nin_2_css*W+ntail_cdd*W)*(nref_go+nref_gm)-ntail_gm*ntail_cgd*W)+(p_2_cdd*W+nin_2_cdd*W)*((nin_1_go+nin_1_gm+nin_1_gb+nin_2_go+nin_2_gm+nin_2_gb+ntail_go)*(nref_go+nref_gm)-(nin_1_css*W+nin_2_css*W+ntail_cdd*W)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+ntail_cdg*W*ntail_cgd*W)-((-nin_2_go-nin_2_gm-nin_2_gb)*(-nin_2_go)-nin_2_cds*W*nin_2_csd*W)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+((-nin_2_go-nin_2_gm-nin_2_gb)*nin_2_csd*W+nin_2_cds*W*(-nin_2_go))*(nref_go+nref_gm))+(p_1_cgd*W+p_1_cgg*W+p_1_cdd*W+p_1_cdg*W+p_2_cgg*W+nin_1_cdd*W)*((p_2_go+nin_2_go)*((nin_1_go+nin_1_gm+nin_1_gb+nin_2_go+nin_2_gm+nin_2_gb+ntail_go)*(nref_go+nref_gm)-(nin_1_css*W+nin_2_css*W+ntail_cdd*W)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+ntail_cdg*W*ntail_cgd*W)-(p_2_cdd*W+nin_2_cdd*W)*((nin_1_go+nin_1_gm+nin_1_gb+nin_2_go+nin_2_gm+nin_2_gb+ntail_go)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+(nin_1_css*W+nin_2_css*W+ntail_cdd*W)*(nref_go+nref_gm)-ntail_gm*ntail_cgd*W)-((-nin_2_go-nin_2_gm-nin_2_gb)*(-nin_2_go)-nin_2_cds*W*nin_2_csd*W)*(nref_go+nref_gm)-((-nin_2_go-nin_2_gm-nin_2_gb)*nin_2_csd*W+nin_2_cds*W*(-nin_2_go))*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W))-p_2_cgd*W*(p_2_gm*((nin_1_go+nin_1_gm+nin_1_gb+nin_2_go+nin_2_gm+nin_2_gb+ntail_go)*(nref_go+nref_gm)-(nin_1_css*W+nin_2_css*W+ntail_cdd*W)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+ntail_cdg*W*ntail_cgd*W)-p_2_cdg*W*((nin_1_go+nin_1_gm+nin_1_gb+nin_2_go+nin_2_gm+nin_2_gb+ntail_go)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+(nin_1_css*W+nin_2_css*W+ntail_cdd*W)*(nref_go+nref_gm)-ntail_gm*ntail_cgd*W)-((-nin_2_go-nin_2_gm-nin_2_gb)*(-nin_1_go)-nin_2_cds*W*nin_1_csd*W)*(nref_go+nref_gm)-((-nin_2_go-nin_2_gm-nin_2_gb)*nin_1_csd*W+nin_2_cds*W*(-nin_1_go))*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W))+(-nin_1_go-nin_1_gm-nin_1_gb)*((p_2_gm*(-nin_2_go)-p_2_cdg*W*nin_2_csd*W)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+(p_2_gm*nin_2_csd*W+p_2_cdg*W*(-nin_2_go))*(nref_go+nref_gm)-((p_2_go+nin_2_go)*(-nin_1_go)-(p_2_cdd*W+nin_2_cdd*W)*nin_1_csd*W)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+((p_2_go+nin_2_go)*nin_1_csd*W+(p_2_cdd*W+nin_2_cdd*W)*(-nin_1_go))*(nref_go+nref_gm))+nin_1_cds*W*((p_2_gm*(-nin_2_go)-p_2_cdg*W*nin_2_csd*W)*(nref_go+nref_gm)-(p_2_gm*nin_2_csd*W+p_2_cdg*W*(-nin_2_go))*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)-((p_2_go+nin_2_go)*(-nin_1_go)-(p_2_cdd*W+nin_2_cdd*W)*nin_1_csd*W)*(nref_go+nref_gm)-((p_2_go+nin_2_go)*nin_1_csd*W+(p_2_cdd*W+nin_2_cdd*W)*(-nin_1_go))*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)));
        BW_Mag=(snr*snr+sni*sni)/(sdr*sdr+sdi*sdi);
        if (W==0) BW_Mag0=BW_Mag;
        if (W==0) W=1; else W*=1.01;
    }
    property_BW=fabs(W/(2*3.141592656));
    for (BW_it=0;BW_it<5;BW_it++)  s-=((-((((((((((p_1_go+p_1_gm)+p_1_cgd*s)+p_1_cgg*s)+p_1_cdd*s)+p_1_cdg*s)+p_2_cgg*s)+nin_1_go)+nin_1_cdd*s)*((((p_2_go+p_2_cdd*s)+nin_2_go)+nin_2_cdd*s)*((((((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_1_css*s)+nin_2_go)+nin_2_gm)+nin_2_gb)+nin_2_css*s)+ntail_go)+ntail_cdd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)-(ntail_gm+ntail_cdg*s)*ntail_cgd*s)-((((-nin_2_go)-nin_2_gm)-nin_2_gb)+nin_2_cds*s)*((-nin_2_go)+nin_2_csd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s))-p_2_cgd*s*((p_2_gm+p_2_cdg*s)*((((((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_1_css*s)+nin_2_go)+nin_2_gm)+nin_2_gb)+nin_2_css*s)+ntail_go)+ntail_cdd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)-(ntail_gm+ntail_cdg*s)*ntail_cgd*s)-((((-nin_2_go)-nin_2_gm)-nin_2_gb)+nin_2_cds*s)*((-nin_1_go)+nin_1_csd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)))+((((-nin_1_go)-nin_1_gm)-nin_1_gb)+nin_1_cds*s)*((p_2_gm+p_2_cdg*s)*((-nin_2_go)+nin_2_csd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)-(((p_2_go+p_2_cdd*s)+nin_2_go)+nin_2_cdd*s)*((-nin_1_go)+nin_1_csd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)))))/((-((((((((p_1_cgd+p_1_cgg)+p_1_cdd)+p_1_cdg)+p_2_cgg)+nin_1_cdd)*((((p_2_go+p_2_cdd*s)+nin_2_go)+nin_2_cdd*s)*((((((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_1_css*s)+nin_2_go)+nin_2_gm)+nin_2_gb)+nin_2_css*s)+ntail_go)+ntail_cdd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)-(ntail_gm+ntail_cdg*s)*ntail_cgd*s)-((((-nin_2_go)-nin_2_gm)-nin_2_gb)+nin_2_cds*s)*((-nin_2_go)+nin_2_csd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s))+((((((((p_1_go+p_1_gm)+p_1_cgd*s)+p_1_cgg*s)+p_1_cdd*s)+p_1_cdg*s)+p_2_cgg*s)+nin_1_go)+nin_1_cdd*s)*(((p_2_cdd+nin_2_cdd)*((((((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_1_css*s)+nin_2_go)+nin_2_gm)+nin_2_gb)+nin_2_css*s)+ntail_go)+ntail_cdd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)-(ntail_gm+ntail_cdg*s)*ntail_cgd*s)+(((p_2_go+p_2_cdd*s)+nin_2_go)+nin_2_cdd*s)*((((nin_1_css+nin_2_css)+ntail_cdd)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)+(((((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_1_css*s)+nin_2_go)+nin_2_gm)+nin_2_gb)+nin_2_css*s)+ntail_go)+ntail_cdd*s)*((((ntail_cgg+nref_cgd)+nref_cgg)+nref_cdd)+nref_cdg))-(ntail_cdg*ntail_cgd*s+(ntail_gm+ntail_cdg*s)*ntail_cgd)))-((nin_2_cds*((-nin_2_go)+nin_2_csd*s)+((((-nin_2_go)-nin_2_gm)-nin_2_gb)+nin_2_cds*s)*nin_2_csd)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)+((((-nin_2_go)-nin_2_gm)-nin_2_gb)+nin_2_cds*s)*((-nin_2_go)+nin_2_csd*s)*((((ntail_cgg+nref_cgd)+nref_cgg)+nref_cdd)+nref_cdg))))-(p_2_cgd*((p_2_gm+p_2_cdg*s)*((((((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_1_css*s)+nin_2_go)+nin_2_gm)+nin_2_gb)+nin_2_css*s)+ntail_go)+ntail_cdd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)-(ntail_gm+ntail_cdg*s)*ntail_cgd*s)-((((-nin_2_go)-nin_2_gm)-nin_2_gb)+nin_2_cds*s)*((-nin_1_go)+nin_1_csd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s))+p_2_cgd*s*((p_2_cdg*((((((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_1_css*s)+nin_2_go)+nin_2_gm)+nin_2_gb)+nin_2_css*s)+ntail_go)+ntail_cdd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)-(ntail_gm+ntail_cdg*s)*ntail_cgd*s)+(p_2_gm+p_2_cdg*s)*((((nin_1_css+nin_2_css)+ntail_cdd)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)+(((((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_1_css*s)+nin_2_go)+nin_2_gm)+nin_2_gb)+nin_2_css*s)+ntail_go)+ntail_cdd*s)*((((ntail_cgg+nref_cgd)+nref_cgg)+nref_cdd)+nref_cdg))-(ntail_cdg*ntail_cgd*s+(ntail_gm+ntail_cdg*s)*ntail_cgd)))-((nin_2_cds*((-nin_1_go)+nin_1_csd*s)+((((-nin_2_go)-nin_2_gm)-nin_2_gb)+nin_2_cds*s)*nin_1_csd)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)+((((-nin_2_go)-nin_2_gm)-nin_2_gb)+nin_2_cds*s)*((-nin_1_go)+nin_1_csd*s)*((((ntail_cgg+nref_cgd)+nref_cgg)+nref_cdd)+nref_cdg)))))+(nin_1_cds*((p_2_gm+p_2_cdg*s)*((-nin_2_go)+nin_2_csd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)-(((p_2_go+p_2_cdd*s)+nin_2_go)+nin_2_cdd*s)*((-nin_1_go)+nin_1_csd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s))+((((-nin_1_go)-nin_1_gm)-nin_1_gb)+nin_1_cds*s)*(((p_2_cdg*((-nin_2_go)+nin_2_csd*s)+(p_2_gm+p_2_cdg*s)*nin_2_csd)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)+(p_2_gm+p_2_cdg*s)*((-nin_2_go)+nin_2_csd*s)*((((ntail_cgg+nref_cgd)+nref_cgg)+nref_cdd)+nref_cdg))-(((p_2_cdd+nin_2_cdd)*((-nin_1_go)+nin_1_csd*s)+(((p_2_go+p_2_cdd*s)+nin_2_go)+nin_2_cdd*s)*nin_1_csd)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)+(((p_2_go+p_2_cdd*s)+nin_2_go)+nin_2_cdd*s)*((-nin_1_go)+nin_1_csd*s)*((((ntail_cgg+nref_cgd)+nref_cgg)+nref_cdd)+nref_cdg)))))));
    property_BW_s=(-((((((((p_1_cgd+p_1_cgg)+p_1_cdd)+p_1_cdg)+p_2_cgg)+nin_1_cdd)*((((p_2_go+p_2_cdd*s)+nin_2_go)+nin_2_cdd*s)*((((((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_1_css*s)+nin_2_go)+nin_2_gm)+nin_2_gb)+nin_2_css*s)+ntail_go)+ntail_cdd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)-(ntail_gm+ntail_cdg*s)*ntail_cgd*s)-((((-nin_2_go)-nin_2_gm)-nin_2_gb)+nin_2_cds*s)*((-nin_2_go)+nin_2_csd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s))+((((((((p_1_go+p_1_gm)+p_1_cgd*s)+p_1_cgg*s)+p_1_cdd*s)+p_1_cdg*s)+p_2_cgg*s)+nin_1_go)+nin_1_cdd*s)*(((p_2_cdd+nin_2_cdd)*((((((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_1_css*s)+nin_2_go)+nin_2_gm)+nin_2_gb)+nin_2_css*s)+ntail_go)+ntail_cdd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)-(ntail_gm+ntail_cdg*s)*ntail_cgd*s)+(((p_2_go+p_2_cdd*s)+nin_2_go)+nin_2_cdd*s)*((((nin_1_css+nin_2_css)+ntail_cdd)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)+(((((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_1_css*s)+nin_2_go)+nin_2_gm)+nin_2_gb)+nin_2_css*s)+ntail_go)+ntail_cdd*s)*((((ntail_cgg+nref_cgd)+nref_cgg)+nref_cdd)+nref_cdg))-(ntail_cdg*ntail_cgd*s+(ntail_gm+ntail_cdg*s)*ntail_cgd)))-((nin_2_cds*((-nin_2_go)+nin_2_csd*s)+((((-nin_2_go)-nin_2_gm)-nin_2_gb)+nin_2_cds*s)*nin_2_csd)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)+((((-nin_2_go)-nin_2_gm)-nin_2_gb)+nin_2_cds*s)*((-nin_2_go)+nin_2_csd*s)*((((ntail_cgg+nref_cgd)+nref_cgg)+nref_cdd)+nref_cdg))))-(p_2_cgd*((p_2_gm+p_2_cdg*s)*((((((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_1_css*s)+nin_2_go)+nin_2_gm)+nin_2_gb)+nin_2_css*s)+ntail_go)+ntail_cdd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)-(ntail_gm+ntail_cdg*s)*ntail_cgd*s)-((((-nin_2_go)-nin_2_gm)-nin_2_gb)+nin_2_cds*s)*((-nin_1_go)+nin_1_csd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s))+p_2_cgd*s*((p_2_cdg*((((((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_1_css*s)+nin_2_go)+nin_2_gm)+nin_2_gb)+nin_2_css*s)+ntail_go)+ntail_cdd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)-(ntail_gm+ntail_cdg*s)*ntail_cgd*s)+(p_2_gm+p_2_cdg*s)*((((nin_1_css+nin_2_css)+ntail_cdd)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)+(((((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_1_css*s)+nin_2_go)+nin_2_gm)+nin_2_gb)+nin_2_css*s)+ntail_go)+ntail_cdd*s)*((((ntail_cgg+nref_cgd)+nref_cgg)+nref_cdd)+nref_cdg))-(ntail_cdg*ntail_cgd*s+(ntail_gm+ntail_cdg*s)*ntail_cgd)))-((nin_2_cds*((-nin_1_go)+nin_1_csd*s)+((((-nin_2_go)-nin_2_gm)-nin_2_gb)+nin_2_cds*s)*nin_1_csd)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)+((((-nin_2_go)-nin_2_gm)-nin_2_gb)+nin_2_cds*s)*((-nin_1_go)+nin_1_csd*s)*((((ntail_cgg+nref_cgd)+nref_cgg)+nref_cdd)+nref_cdg)))))+(nin_1_cds*((p_2_gm+p_2_cdg*s)*((-nin_2_go)+nin_2_csd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)-(((p_2_go+p_2_cdd*s)+nin_2_go)+nin_2_cdd*s)*((-nin_1_go)+nin_1_csd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s))+((((-nin_1_go)-nin_1_gm)-nin_1_gb)+nin_1_cds*s)*(((p_2_cdg*((-nin_2_go)+nin_2_csd*s)+(p_2_gm+p_2_cdg*s)*nin_2_csd)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)+(p_2_gm+p_2_cdg*s)*((-nin_2_go)+nin_2_csd*s)*((((ntail_cgg+nref_cgd)+nref_cgg)+nref_cdd)+nref_cdg))-(((p_2_cdd+nin_2_cdd)*((-nin_1_go)+nin_1_csd*s)+(((p_2_go+p_2_cdd*s)+nin_2_go)+nin_2_cdd*s)*nin_1_csd)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)+(((p_2_go+p_2_cdd*s)+nin_2_go)+nin_2_cdd*s)*((-nin_1_go)+nin_1_csd*s)*((((ntail_cgg+nref_cgd)+nref_cgg)+nref_cdd)+nref_cdg))))));
    p1=-s;
    if (!isfinite(property_BW))  {status_fail=8; return TCL_ERROR;}
    s-=1e3;
    for (BW_it=0;BW_it<20;BW_it++)  s-=(((-((((((((((p_1_go+p_1_gm)+p_1_cgd*s)+p_1_cgg*s)+p_1_cdd*s)+p_1_cdg*s)+p_2_cgg*s)+nin_1_go)+nin_1_cdd*s)*((((p_2_go+p_2_cdd*s)+nin_2_go)+nin_2_cdd*s)*((((((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_1_css*s)+nin_2_go)+nin_2_gm)+nin_2_gb)+nin_2_css*s)+ntail_go)+ntail_cdd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)-(ntail_gm+ntail_cdg*s)*ntail_cgd*s)-((((-nin_2_go)-nin_2_gm)-nin_2_gb)+nin_2_cds*s)*((-nin_2_go)+nin_2_csd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s))-p_2_cgd*s*((p_2_gm+p_2_cdg*s)*((((((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_1_css*s)+nin_2_go)+nin_2_gm)+nin_2_gb)+nin_2_css*s)+ntail_go)+ntail_cdd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)-(ntail_gm+ntail_cdg*s)*ntail_cgd*s)-((((-nin_2_go)-nin_2_gm)-nin_2_gb)+nin_2_cds*s)*((-nin_1_go)+nin_1_csd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)))+((((-nin_1_go)-nin_1_gm)-nin_1_gb)+nin_1_cds*s)*((p_2_gm+p_2_cdg*s)*((-nin_2_go)+nin_2_csd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)-(((p_2_go+p_2_cdd*s)+nin_2_go)+nin_2_cdd*s)*((-nin_1_go)+nin_1_csd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)))))*(s+p1-5e2))/(((-((((((((p_1_cgd+p_1_cgg)+p_1_cdd)+p_1_cdg)+p_2_cgg)+nin_1_cdd)*((((p_2_go+p_2_cdd*s)+nin_2_go)+nin_2_cdd*s)*((((((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_1_css*s)+nin_2_go)+nin_2_gm)+nin_2_gb)+nin_2_css*s)+ntail_go)+ntail_cdd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)-(ntail_gm+ntail_cdg*s)*ntail_cgd*s)-((((-nin_2_go)-nin_2_gm)-nin_2_gb)+nin_2_cds*s)*((-nin_2_go)+nin_2_csd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s))+((((((((p_1_go+p_1_gm)+p_1_cgd*s)+p_1_cgg*s)+p_1_cdd*s)+p_1_cdg*s)+p_2_cgg*s)+nin_1_go)+nin_1_cdd*s)*(((p_2_cdd+nin_2_cdd)*((((((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_1_css*s)+nin_2_go)+nin_2_gm)+nin_2_gb)+nin_2_css*s)+ntail_go)+ntail_cdd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)-(ntail_gm+ntail_cdg*s)*ntail_cgd*s)+(((p_2_go+p_2_cdd*s)+nin_2_go)+nin_2_cdd*s)*((((nin_1_css+nin_2_css)+ntail_cdd)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)+(((((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_1_css*s)+nin_2_go)+nin_2_gm)+nin_2_gb)+nin_2_css*s)+ntail_go)+ntail_cdd*s)*((((ntail_cgg+nref_cgd)+nref_cgg)+nref_cdd)+nref_cdg))-(ntail_cdg*ntail_cgd*s+(ntail_gm+ntail_cdg*s)*ntail_cgd)))-((nin_2_cds*((-nin_2_go)+nin_2_csd*s)+((((-nin_2_go)-nin_2_gm)-nin_2_gb)+nin_2_cds*s)*nin_2_csd)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)+((((-nin_2_go)-nin_2_gm)-nin_2_gb)+nin_2_cds*s)*((-nin_2_go)+nin_2_csd*s)*((((ntail_cgg+nref_cgd)+nref_cgg)+nref_cdd)+nref_cdg))))-(p_2_cgd*((p_2_gm+p_2_cdg*s)*((((((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_1_css*s)+nin_2_go)+nin_2_gm)+nin_2_gb)+nin_2_css*s)+ntail_go)+ntail_cdd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)-(ntail_gm+ntail_cdg*s)*ntail_cgd*s)-((((-nin_2_go)-nin_2_gm)-nin_2_gb)+nin_2_cds*s)*((-nin_1_go)+nin_1_csd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s))+p_2_cgd*s*((p_2_cdg*((((((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_1_css*s)+nin_2_go)+nin_2_gm)+nin_2_gb)+nin_2_css*s)+ntail_go)+ntail_cdd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)-(ntail_gm+ntail_cdg*s)*ntail_cgd*s)+(p_2_gm+p_2_cdg*s)*((((nin_1_css+nin_2_css)+ntail_cdd)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)+(((((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_1_css*s)+nin_2_go)+nin_2_gm)+nin_2_gb)+nin_2_css*s)+ntail_go)+ntail_cdd*s)*((((ntail_cgg+nref_cgd)+nref_cgg)+nref_cdd)+nref_cdg))-(ntail_cdg*ntail_cgd*s+(ntail_gm+ntail_cdg*s)*ntail_cgd)))-((nin_2_cds*((-nin_1_go)+nin_1_csd*s)+((((-nin_2_go)-nin_2_gm)-nin_2_gb)+nin_2_cds*s)*nin_1_csd)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)+((((-nin_2_go)-nin_2_gm)-nin_2_gb)+nin_2_cds*s)*((-nin_1_go)+nin_1_csd*s)*((((ntail_cgg+nref_cgd)+nref_cgg)+nref_cdd)+nref_cdg)))))+(nin_1_cds*((p_2_gm+p_2_cdg*s)*((-nin_2_go)+nin_2_csd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)-(((p_2_go+p_2_cdd*s)+nin_2_go)+nin_2_cdd*s)*((-nin_1_go)+nin_1_csd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s))+((((-nin_1_go)-nin_1_gm)-nin_1_gb)+nin_1_cds*s)*(((p_2_cdg*((-nin_2_go)+nin_2_csd*s)+(p_2_gm+p_2_cdg*s)*nin_2_csd)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)+(p_2_gm+p_2_cdg*s)*((-nin_2_go)+nin_2_csd*s)*((((ntail_cgg+nref_cgd)+nref_cgg)+nref_cdd)+nref_cdg))-(((p_2_cdd+nin_2_cdd)*((-nin_1_go)+nin_1_csd*s)+(((p_2_go+p_2_cdd*s)+nin_2_go)+nin_2_cdd*s)*nin_1_csd)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)+(((p_2_go+p_2_cdd*s)+nin_2_go)+nin_2_cdd*s)*((-nin_1_go)+nin_1_csd*s)*((((ntail_cgg+nref_cgd)+nref_cgg)+nref_cdd)+nref_cdg)))))))*(s+p1-5e2)-((-((((((((((p_1_go+p_1_gm)+p_1_cgd*s)+p_1_cgg*s)+p_1_cdd*s)+p_1_cdg*s)+p_2_cgg*s)+nin_1_go)+nin_1_cdd*s)*((((p_2_go+p_2_cdd*s)+nin_2_go)+nin_2_cdd*s)*((((((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_1_css*s)+nin_2_go)+nin_2_gm)+nin_2_gb)+nin_2_css*s)+ntail_go)+ntail_cdd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)-(ntail_gm+ntail_cdg*s)*ntail_cgd*s)-((((-nin_2_go)-nin_2_gm)-nin_2_gb)+nin_2_cds*s)*((-nin_2_go)+nin_2_csd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s))-p_2_cgd*s*((p_2_gm+p_2_cdg*s)*((((((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_1_css*s)+nin_2_go)+nin_2_gm)+nin_2_gb)+nin_2_css*s)+ntail_go)+ntail_cdd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)-(ntail_gm+ntail_cdg*s)*ntail_cgd*s)-((((-nin_2_go)-nin_2_gm)-nin_2_gb)+nin_2_cds*s)*((-nin_1_go)+nin_1_csd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)))+((((-nin_1_go)-nin_1_gm)-nin_1_gb)+nin_1_cds*s)*((p_2_gm+p_2_cdg*s)*((-nin_2_go)+nin_2_csd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s)-(((p_2_go+p_2_cdd*s)+nin_2_go)+nin_2_cdd*s)*((-nin_1_go)+nin_1_csd*s)*((((((ntail_cgg*s+nref_go)+nref_gm)+nref_cgd*s)+nref_cgg*s)+nref_cdd*s)+nref_cdg*s))))));
    p2=-s;
    if (!isfinite(p1)) {
        property_ts=1/property_BW;
    } else if (!isfinite(p2)) {
        property_ts=-log(0.02)/p1;
    } else {
        float A1=-p2/(-p1+p2);
        float A2=-p1/(-p1+p2);
        property_ts=0;
        for (BW_it=0;BW_it<10;BW_it++) property_ts-=(0.02+A1*exp(-p1*property_ts)+A2*exp(-p2*property_ts))/(-p1*A1*exp(-p1*property_ts)-p2*A2*exp(-p2*property_ts));
    }
    if (!isfinite(property_ts)) {
        property_ts=1/property_BW;
    }
    property_Cin=nin_1_cgd+nin_1_cgs;
    property_PM=(property_BW/9.76e8)+(property_Adc-21)-sqrt(size_Ln*size_Wn)/5e-7-size_iref*2.5e4;
    property_PM=(property_PM*180/3.1415)/2.16+29-1.4-0.75/2;
    while (property_PM<0) property_PM+=360;
    while (fabs(property_PM)>180) property_PM-=360;
    property_PM=fabs(property_PM);
    while (BW_Mag>4) {
        snr=0;
        sni=0;
        sdr=-((p_1_go+p_1_gm+nin_1_go)*((p_2_go+nin_2_go)*((nin_1_go+nin_1_gm+nin_1_gb+nin_2_go+nin_2_gm+nin_2_gb+ntail_go)*(nref_go+nref_gm)-(nin_1_css*W+nin_2_css*W+ntail_cdd*W)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+ntail_cdg*W*ntail_cgd*W)-(p_2_cdd*W+nin_2_cdd*W)*((nin_1_go+nin_1_gm+nin_1_gb+nin_2_go+nin_2_gm+nin_2_gb+ntail_go)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+(nin_1_css*W+nin_2_css*W+ntail_cdd*W)*(nref_go+nref_gm)-ntail_gm*ntail_cgd*W)-((-nin_2_go-nin_2_gm-nin_2_gb)*(-nin_2_go)-nin_2_cds*W*nin_2_csd*W)*(nref_go+nref_gm)-((-nin_2_go-nin_2_gm-nin_2_gb)*nin_2_csd*W+nin_2_cds*W*(-nin_2_go))*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W))-(p_1_cgd*W+p_1_cgg*W+p_1_cdd*W+p_1_cdg*W+p_2_cgg*W+nin_1_cdd*W)*((p_2_go+nin_2_go)*((nin_1_go+nin_1_gm+nin_1_gb+nin_2_go+nin_2_gm+nin_2_gb+ntail_go)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+(nin_1_css*W+nin_2_css*W+ntail_cdd*W)*(nref_go+nref_gm)-ntail_gm*ntail_cgd*W)+(p_2_cdd*W+nin_2_cdd*W)*((nin_1_go+nin_1_gm+nin_1_gb+nin_2_go+nin_2_gm+nin_2_gb+ntail_go)*(nref_go+nref_gm)-(nin_1_css*W+nin_2_css*W+ntail_cdd*W)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+ntail_cdg*W*ntail_cgd*W)-((-nin_2_go-nin_2_gm-nin_2_gb)*(-nin_2_go)-nin_2_cds*W*nin_2_csd*W)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+((-nin_2_go-nin_2_gm-nin_2_gb)*nin_2_csd*W+nin_2_cds*W*(-nin_2_go))*(nref_go+nref_gm))+(p_2_cgd*W*(p_2_gm*((nin_1_go+nin_1_gm+nin_1_gb+nin_2_go+nin_2_gm+nin_2_gb+ntail_go)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+(nin_1_css*W+nin_2_css*W+ntail_cdd*W)*(nref_go+nref_gm)-ntail_gm*ntail_cgd*W)+p_2_cdg*W*((nin_1_go+nin_1_gm+nin_1_gb+nin_2_go+nin_2_gm+nin_2_gb+ntail_go)*(nref_go+nref_gm)-(nin_1_css*W+nin_2_css*W+ntail_cdd*W)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+ntail_cdg*W*ntail_cgd*W)-((-nin_2_go-nin_2_gm-nin_2_gb)*(-nin_1_go)-nin_2_cds*W*nin_1_csd*W)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+((-nin_2_go-nin_2_gm-nin_2_gb)*nin_1_csd*W+nin_2_cds*W*(-nin_1_go))*(nref_go+nref_gm)))+(-nin_1_go-nin_1_gm-nin_1_gb)*((p_2_gm*(-nin_2_go)-p_2_cdg*W*nin_2_csd*W)*(nref_go+nref_gm)-(p_2_gm*nin_2_csd*W+p_2_cdg*W*(-nin_2_go))*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)-((p_2_go+nin_2_go)*(-nin_1_go)-(p_2_cdd*W+nin_2_cdd*W)*nin_1_csd*W)*(nref_go+nref_gm)-((p_2_go+nin_2_go)*nin_1_csd*W+(p_2_cdd*W+nin_2_cdd*W)*(-nin_1_go))*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W))-nin_1_cds*W*((p_2_gm*(-nin_2_go)-p_2_cdg*W*nin_2_csd*W)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+(p_2_gm*nin_2_csd*W+p_2_cdg*W*(-nin_2_go))*(nref_go+nref_gm)-((p_2_go+nin_2_go)*(-nin_1_go)-(p_2_cdd*W+nin_2_cdd*W)*nin_1_csd*W)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+((p_2_go+nin_2_go)*nin_1_csd*W+(p_2_cdd*W+nin_2_cdd*W)*(-nin_1_go))*(nref_go+nref_gm)));
        sdi=-((p_1_go+p_1_gm+nin_1_go)*((p_2_go+nin_2_go)*((nin_1_go+nin_1_gm+nin_1_gb+nin_2_go+nin_2_gm+nin_2_gb+ntail_go)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+(nin_1_css*W+nin_2_css*W+ntail_cdd*W)*(nref_go+nref_gm)-ntail_gm*ntail_cgd*W)+(p_2_cdd*W+nin_2_cdd*W)*((nin_1_go+nin_1_gm+nin_1_gb+nin_2_go+nin_2_gm+nin_2_gb+ntail_go)*(nref_go+nref_gm)-(nin_1_css*W+nin_2_css*W+ntail_cdd*W)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+ntail_cdg*W*ntail_cgd*W)-((-nin_2_go-nin_2_gm-nin_2_gb)*(-nin_2_go)-nin_2_cds*W*nin_2_csd*W)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+((-nin_2_go-nin_2_gm-nin_2_gb)*nin_2_csd*W+nin_2_cds*W*(-nin_2_go))*(nref_go+nref_gm))+(p_1_cgd*W+p_1_cgg*W+p_1_cdd*W+p_1_cdg*W+p_2_cgg*W+nin_1_cdd*W)*((p_2_go+nin_2_go)*((nin_1_go+nin_1_gm+nin_1_gb+nin_2_go+nin_2_gm+nin_2_gb+ntail_go)*(nref_go+nref_gm)-(nin_1_css*W+nin_2_css*W+ntail_cdd*W)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+ntail_cdg*W*ntail_cgd*W)-(p_2_cdd*W+nin_2_cdd*W)*((nin_1_go+nin_1_gm+nin_1_gb+nin_2_go+nin_2_gm+nin_2_gb+ntail_go)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+(nin_1_css*W+nin_2_css*W+ntail_cdd*W)*(nref_go+nref_gm)-ntail_gm*ntail_cgd*W)-((-nin_2_go-nin_2_gm-nin_2_gb)*(-nin_2_go)-nin_2_cds*W*nin_2_csd*W)*(nref_go+nref_gm)-((-nin_2_go-nin_2_gm-nin_2_gb)*nin_2_csd*W+nin_2_cds*W*(-nin_2_go))*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W))-p_2_cgd*W*(p_2_gm*((nin_1_go+nin_1_gm+nin_1_gb+nin_2_go+nin_2_gm+nin_2_gb+ntail_go)*(nref_go+nref_gm)-(nin_1_css*W+nin_2_css*W+ntail_cdd*W)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+ntail_cdg*W*ntail_cgd*W)-p_2_cdg*W*((nin_1_go+nin_1_gm+nin_1_gb+nin_2_go+nin_2_gm+nin_2_gb+ntail_go)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+(nin_1_css*W+nin_2_css*W+ntail_cdd*W)*(nref_go+nref_gm)-ntail_gm*ntail_cgd*W)-((-nin_2_go-nin_2_gm-nin_2_gb)*(-nin_1_go)-nin_2_cds*W*nin_1_csd*W)*(nref_go+nref_gm)-((-nin_2_go-nin_2_gm-nin_2_gb)*nin_1_csd*W+nin_2_cds*W*(-nin_1_go))*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W))+(-nin_1_go-nin_1_gm-nin_1_gb)*((p_2_gm*(-nin_2_go)-p_2_cdg*W*nin_2_csd*W)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+(p_2_gm*nin_2_csd*W+p_2_cdg*W*(-nin_2_go))*(nref_go+nref_gm)-((p_2_go+nin_2_go)*(-nin_1_go)-(p_2_cdd*W+nin_2_cdd*W)*nin_1_csd*W)*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)+((p_2_go+nin_2_go)*nin_1_csd*W+(p_2_cdd*W+nin_2_cdd*W)*(-nin_1_go))*(nref_go+nref_gm))+nin_1_cds*W*((p_2_gm*(-nin_2_go)-p_2_cdg*W*nin_2_csd*W)*(nref_go+nref_gm)-(p_2_gm*nin_2_csd*W+p_2_cdg*W*(-nin_2_go))*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)-((p_2_go+nin_2_go)*(-nin_1_go)-(p_2_cdd*W+nin_2_cdd*W)*nin_1_csd*W)*(nref_go+nref_gm)-((p_2_go+nin_2_go)*nin_1_csd*W+(p_2_cdd*W+nin_2_cdd*W)*(-nin_1_go))*(ntail_cgg*W+nref_cgd*W+nref_cgg*W+nref_cdd*W+nref_cdg*W)));
        BW_Mag=(snr*snr+sni*sni)/(sdr*sdr+sdi*sdi);
        W*=1.01;
    }
    property_PM=180-180*(atan(sni/snr)-atan(sdi/sdr))/3.1415926;
    p_1_Nt_unit=gamma_gcc_interpolateg_4(P_look_up_tables_pch_thermal_noise_ss_LUT,(outm_V-vdd_V),(outm_V-vdd_V),0,size_Lp,&p_1_dNt_dvgs,&p_1_dNt_dvds,&p_1_dNt_dvbs,&p_1_dNt_dl);
    p_1_Nt=p_1_Nt_unit*p_1_go;
    if (!isfinite(p_1_Nt))  {status_fail=5; return TCL_ERROR;}
    p_1_Nf_unit=gamma_gcc_interpolateg_4(P_look_up_tables_pch_flicker_noise_ss_LUT,(outm_V-vdd_V),(outm_V-vdd_V),0,size_Lp,&p_1_dNf_dvgs,&p_1_dNf_dvds,&p_1_dNf_dvbs,&p_1_dNf_dl);
    p_1_Nf=p_1_Nf_unit*p_1_go*p_1_go/(size_Wp*size_Lp);
    if (!isfinite(p_1_Nf))  {status_fail=6; return TCL_ERROR;}
    p_2_Nt_unit=gamma_gcc_interpolateg_4(P_look_up_tables_pch_thermal_noise_ss_LUT,(outm_V-vdd_V),(outp_V-vdd_V),0,size_Lp,&p_2_dNt_dvgs,&p_2_dNt_dvds,&p_2_dNt_dvbs,&p_2_dNt_dl);
    p_2_Nt=p_2_Nt_unit*p_2_go;
    if (!isfinite(p_2_Nt))  {status_fail=5; return TCL_ERROR;}
    p_2_Nf_unit=gamma_gcc_interpolateg_4(P_look_up_tables_pch_flicker_noise_ss_LUT,(outm_V-vdd_V),(outp_V-vdd_V),0,size_Lp,&p_2_dNf_dvgs,&p_2_dNf_dvds,&p_2_dNf_dvbs,&p_2_dNf_dl);
    p_2_Nf=p_2_Nf_unit*p_2_go*p_2_go/(size_Wp*size_Lp);
    if (!isfinite(p_2_Nf))  {status_fail=6; return TCL_ERROR;}
    nin_1_Nt_unit=gamma_gcc_interpolateg_4(P_look_up_tables_nch_thermal_noise_ss_LUT,(inp_V-tail_V),(outm_V-tail_V),(-tail_V),size_Ln,&nin_1_dNt_dvgs,&nin_1_dNt_dvds,&nin_1_dNt_dvbs,&nin_1_dNt_dl);
    nin_1_Nt=nin_1_Nt_unit*nin_1_go;
    if (!isfinite(nin_1_Nt))  {status_fail=5; return TCL_ERROR;}
    nin_1_Nf_unit=gamma_gcc_interpolateg_4(P_look_up_tables_nch_flicker_noise_ss_LUT,(inp_V-tail_V),(outm_V-tail_V),(-tail_V),size_Ln,&nin_1_dNf_dvgs,&nin_1_dNf_dvds,&nin_1_dNf_dvbs,&nin_1_dNf_dl);
    nin_1_Nf=nin_1_Nf_unit*nin_1_go*nin_1_go/(size_Wn*size_Ln);
    if (!isfinite(nin_1_Nf))  {status_fail=6; return TCL_ERROR;}
    nin_2_Nt_unit=gamma_gcc_interpolateg_4(P_look_up_tables_nch_thermal_noise_ss_LUT,(inn_V-tail_V),(outp_V-tail_V),(-tail_V),size_Ln,&nin_2_dNt_dvgs,&nin_2_dNt_dvds,&nin_2_dNt_dvbs,&nin_2_dNt_dl);
    nin_2_Nt=nin_2_Nt_unit*nin_2_go;
    if (!isfinite(nin_2_Nt))  {status_fail=5; return TCL_ERROR;}
    nin_2_Nf_unit=gamma_gcc_interpolateg_4(P_look_up_tables_nch_flicker_noise_ss_LUT,(inn_V-tail_V),(outp_V-tail_V),(-tail_V),size_Ln,&nin_2_dNf_dvgs,&nin_2_dNf_dvds,&nin_2_dNf_dvbs,&nin_2_dNf_dl);
    nin_2_Nf=nin_2_Nf_unit*nin_2_go*nin_2_go/(size_Wn*size_Ln);
    if (!isfinite(nin_2_Nf))  {status_fail=6; return TCL_ERROR;}
    ntail_Nt_unit=gamma_gcc_interpolateg_4(P_look_up_tables_nch_thermal_noise_ss_LUT,vbias_V,tail_V,CONST_0_V,size_Ls,&ntail_dNt_dvgs,&ntail_dNt_dvds,&ntail_dNt_dvbs,&ntail_dNt_dl);
    ntail_Nt=ntail_Nt_unit*ntail_go;
    if (!isfinite(ntail_Nt))  {status_fail=5; return TCL_ERROR;}
    ntail_Nf_unit=gamma_gcc_interpolateg_4(P_look_up_tables_nch_flicker_noise_ss_LUT,vbias_V,tail_V,CONST_0_V,size_Ls,&ntail_dNf_dvgs,&ntail_dNf_dvds,&ntail_dNf_dvbs,&ntail_dNf_dl);
    ntail_Nf=ntail_Nf_unit*ntail_go*ntail_go/(size_Ls*2*size_Wn/size_Ln*size_Ls);
    if (!isfinite(ntail_Nf))  {status_fail=6; return TCL_ERROR;}
    nref_Nt_unit=gamma_gcc_interpolateg_4(P_look_up_tables_nch_thermal_noise_ss_LUT,vbias_V,vbias_V,CONST_0_V,size_Ls,&nref_dNt_dvgs,&nref_dNt_dvds,&nref_dNt_dvbs,&nref_dNt_dl);
    nref_Nt=nref_Nt_unit*nref_go;
    if (!isfinite(nref_Nt))  {status_fail=5; return TCL_ERROR;}
    nref_Nf_unit=gamma_gcc_interpolateg_4(P_look_up_tables_nch_flicker_noise_ss_LUT,vbias_V,vbias_V,CONST_0_V,size_Ls,&nref_dNf_dvgs,&nref_dNf_dvds,&nref_dNf_dvbs,&nref_dNf_dl);
    nref_Nf=nref_Nf_unit*nref_go*nref_go/(size_Ls*2*size_Wn/size_Ln*size_Ls);
    if (!isfinite(nref_Nf))  {status_fail=6; return TCL_ERROR;}
    float current_transfer_p_1=Ted*((-(-(p_2_gm*((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_2_go)+nin_2_gm)+nin_2_gb)+ntail_go)*(nref_go+nref_gm)-(((-nin_2_go)-nin_2_gm)-nin_2_gb)*(-nin_1_go)*(nref_go+nref_gm)))))/property_Adc;
    float current_transfer_p_2=Ted*((-(((p_1_go+p_1_gm)+nin_1_go)*((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_2_go)+nin_2_gm)+nin_2_gb)+ntail_go)*(nref_go+nref_gm)+(((-nin_1_go)-nin_1_gm)-nin_1_gb)*(-(-nin_1_go)*(nref_go+nref_gm)))))/property_Adc;
    float current_transfer_nin_1=Ted*((-((((p_1_go+p_1_gm)+nin_1_go)*(-(((-nin_2_go)-nin_2_gm)-nin_2_gb)*(nref_go+nref_gm))-(p_2_gm*((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_2_go)+nin_2_gm)+nin_2_gb)+ntail_go)*(nref_go+nref_gm)-(((-nin_2_go)-nin_2_gm)-nin_2_gb)*(-nin_1_go)*(nref_go+nref_gm)))+(((-nin_1_go)-nin_1_gm)-nin_1_gb)*p_2_gm*(nref_go+nref_gm))))/property_Adc;
    float current_transfer_nin_2=Ted*((-(((p_1_go+p_1_gm)+nin_1_go)*(((((((nin_1_go+nin_1_gm)+nin_1_gb)+nin_2_go)+nin_2_gm)+nin_2_gb)+ntail_go)*(nref_go+nref_gm)-(((-nin_2_go)-nin_2_gm)-nin_2_gb)*(nref_go+nref_gm))+(((-nin_1_go)-nin_1_gm)-nin_1_gb)*(p_2_gm*(nref_go+nref_gm)-(-nin_1_go)*(nref_go+nref_gm)))))/property_Adc;
    float current_transfer_ntail=Ted*((-(((p_1_go+p_1_gm)+nin_1_go)*(-(((-nin_2_go)-nin_2_gm)-nin_2_gb)*(nref_go+nref_gm))+(((-nin_1_go)-nin_1_gm)-nin_1_gb)*p_2_gm*(nref_go+nref_gm))))/property_Adc;
    float current_transfer_nref=Ted*((-(((p_1_go+p_1_gm)+nin_1_go)*(-(((-nin_2_go)-nin_2_gm)-nin_2_gb)*(-ntail_gm))+(((-nin_1_go)-nin_1_gm)-nin_1_gb)*p_2_gm*(-ntail_gm))))/property_Adc;
    property_Nt=(current_transfer_p_1*current_transfer_p_1*p_1_Nt+current_transfer_p_2*current_transfer_p_2*p_2_Nt+current_transfer_nin_1*current_transfer_nin_1*nin_1_Nt+current_transfer_nin_2*current_transfer_nin_2*nin_2_Nt+current_transfer_ntail*current_transfer_ntail*ntail_Nt+current_transfer_nref*current_transfer_nref*nref_Nt)/property_Adc;
    property_Nf=(current_transfer_p_1*current_transfer_p_1*p_1_Nf+current_transfer_p_2*current_transfer_p_2*p_2_Nf+current_transfer_nin_1*current_transfer_nin_1*nin_1_Nf+current_transfer_nin_2*current_transfer_nin_2*nin_2_Nf+current_transfer_ntail*current_transfer_ntail*ntail_Nf+current_transfer_nref*current_transfer_nref*nref_Nf)/property_Adc;
    property_fc=property_Nf/property_Nt;
    property_TotalNoise=(log(2*property_BW)*property_Nf+2*property_BW*property_Nt);
    property_TotalNoise/=2;
    property_Area=1e12*(size_Wp*size_Lp+size_Wp*size_Lp+size_Wn*size_Ln+size_Wn*size_Ln+size_Ls*2*size_Wn/size_Ln*size_Ls+size_Ls*2*size_Wn/size_Ln*size_Ls);
    float single_transistor_vos;
    property_Vos=0;
    single_transistor_vos=vos(nin_1_Ids*size_Ln/size_Wn);
    property_Vos+=single_transistor_vos*single_transistor_vos;
    single_transistor_vos=vos(nin_2_Ids*size_Ln/size_Wn);
    property_Vos+=single_transistor_vos*single_transistor_vos;
    property_Vos=1e-3*sqrt(property_Vos);
    property_Power=0;
    property_Power+=fabs(p_1_Ids*((outm_V)-(vdd_V)));
    property_Power+=fabs(p_2_Ids*((outp_V)-(vdd_V)));
    property_Power+=fabs(nin_1_Ids*((outm_V)-(tail_V)));
    property_Power+=fabs(nin_2_Ids*((outp_V)-(tail_V)));
    property_Power+=fabs(ntail_Ids*((tail_V)-(CONST_0_V)));
    property_Power+=fabs(nref_Ids*((vbias_V)-(CONST_0_V)));
    property_Adc=20*log10(fabs(property_Adc));
    property_CMRR=20*log10(fabs(property_CMRR));
    property_CMRR=property_Adc-property_CMRR;
    property_PSRR=20*log10(fabs(property_PSRR));
    property_PSRR=property_Adc-property_PSRR;
    if (max_Adc<property_Adc) max_Adc=property_Adc;
    PAT *p=(PAT *)Pdiffpair_nmos_circuits_PAT;
    float sizes[10];
    sizes[0]=size_iref;
    sizes[1]=size_Lp;
    sizes[2]=size_Wp;
    sizes[3]=size_Ln;
    sizes[4]=size_Wn;
    sizes[5]=size_Ls;
    sizes[6]=outm_V;
    sizes[7]=outp_V;
    sizes[8]=tail_V;
    sizes[9]=vbias_V;
    float properties[15];
    if ((config_factor_Adc!=0)||(config_shift_Adc!=0)) property_Adc=property_Adc*config_factor_Adc+config_shift_Adc;
    properties[0]=property_Adc;
    if ((config_factor_CMRR!=0)||(config_shift_CMRR!=0)) property_CMRR=property_CMRR*config_factor_CMRR+config_shift_CMRR;
    properties[1]=property_CMRR;
    if ((config_factor_PSRR!=0)||(config_shift_PSRR!=0)) property_PSRR=property_PSRR*config_factor_PSRR+config_shift_PSRR;
    properties[2]=property_PSRR;
    if ((config_factor_Rout!=0)||(config_shift_Rout!=0)) property_Rout=property_Rout*config_factor_Rout+config_shift_Rout;
    properties[3]=property_Rout;
    if ((config_factor_BW!=0)||(config_shift_BW!=0)) property_BW=property_BW*config_factor_BW+config_shift_BW;
    properties[4]=property_BW;
    if ((config_factor_PM!=0)||(config_shift_PM!=0)) property_PM=property_PM*config_factor_PM+config_shift_PM;
    properties[5]=property_PM;
    if ((config_factor_Cin!=0)||(config_shift_Cin!=0)) property_Cin=property_Cin*config_factor_Cin+config_shift_Cin;
    properties[6]=property_Cin;
    if ((config_factor_ts!=0)||(config_shift_ts!=0)) property_ts=property_ts*config_factor_ts+config_shift_ts;
    properties[7]=property_ts;
    if ((config_factor_Nt!=0)||(config_shift_Nt!=0)) property_Nt=property_Nt*config_factor_Nt+config_shift_Nt;
    properties[8]=property_Nt;
    if ((config_factor_Nf!=0)||(config_shift_Nf!=0)) property_Nf=property_Nf*config_factor_Nf+config_shift_Nf;
    properties[9]=property_Nf;
    if ((config_factor_TotalNoise!=0)||(config_shift_TotalNoise!=0)) property_TotalNoise=property_TotalNoise*config_factor_TotalNoise+config_shift_TotalNoise;
    properties[10]=property_TotalNoise;
    if ((config_factor_fc!=0)||(config_shift_fc!=0)) property_fc=property_fc*config_factor_fc+config_shift_fc;
    properties[11]=property_fc;
    if ((config_factor_Vos!=0)||(config_shift_Vos!=0)) property_Vos=property_Vos*config_factor_Vos+config_shift_Vos;
    properties[12]=property_Vos;
    if ((config_factor_Area!=0)||(config_shift_Area!=0)) property_Area=property_Area*config_factor_Area+config_shift_Area;
    properties[13]=property_Area;
    if ((config_factor_Power!=0)||(config_shift_Power!=0)) property_Power=property_Power*config_factor_Power+config_shift_Power;
    properties[14]=property_Power;
    status_fail=op_it;
    status_index=add_pat_array(p,sizes,properties);
    return TCL_OK;
}
//      static int tcl_gamma_grad_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    //            Tcl_ResetResult(interp);
    //          GRAD_CODE_GOES_HERE
    //         return TCL_OK;
//    }
static int tcl_gamma_random_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    ClientData CD;
    PAT *p=(PAT *)Pdiffpair_nmos_circuits_PAT;
    while (p->content->num_of<config_pat_size_target) {
        size_iref=size_iref_min+random()*(size_iref_max-size_iref_min)/RAND_MAX;
        size_Lp=size_Lp_min+random()*(size_Lp_max-size_Lp_min)/RAND_MAX;
        size_Wp=size_Lp+random()*(size_Wp_max-size_Lp)/RAND_MAX;
        size_Ln=size_Ln_min+random()*(size_Ln_max-size_Ln_min)/RAND_MAX;
        size_Wn=size_Ln+random()*(size_Wn_max-size_Ln)/RAND_MAX;
        size_Ls=size_Ls_min+random()*(size_Ls_max-size_Ls_min)/RAND_MAX;
        if (tcl_gamma_op_cmd(CD,NULL,0,NULL)==TCL_ERROR) continue;
    }
    return TCL_OK;
}
static int tcl_gamma_breed_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    ClientData CD;
    int i,viable;
    PAT *p=(PAT *)Pdiffpair_nmos_circuits_PAT;
    int more_to_breed=1;
    while (more_to_breed&&(p->content->num_of<pat_size_target)) {
        more_to_breed=0;
        int sweep_size=p->content->num_of;
        for (i=0;i<sweep_size;i++) {
            if (p->content->content[i]->flags) continue;
            p->content->content[i]->flags=1;
            more_to_breed++;
            size_iref=p->content->content[i]->sizes->content[0];
            size_Lp=p->content->content[i]->sizes->content[1];
            size_Wp=p->content->content[i]->sizes->content[2];
            size_Ln=p->content->content[i]->sizes->content[3];
            size_Wn=p->content->content[i]->sizes->content[4];
            size_Ls=p->content->content[i]->sizes->content[5];
            size_iref=size_iref+size_iref_step;
            viable=1;
            if ((size_iref>=size_iref_min)&&(size_iref<=size_iref_max)) {
                tcl_gamma_op_cmd(CD,NULL,0,NULL);
            }
            size_iref=size_iref-2*size_iref_step;
            viable=1;
            if ((size_iref>=size_iref_min)&&(size_iref<=size_iref_max)) {
                tcl_gamma_op_cmd(CD,NULL,0,NULL);
            }
            size_iref=size_iref+size_iref_step;
            size_Lp=size_Lp+size_Lp_step;
            viable=1;
            if ((size_Lp>=size_Lp_min)&&(size_Lp<=size_Lp_max)) {
                tcl_gamma_op_cmd(CD,NULL,0,NULL);
            }
            size_Lp=size_Lp-2*size_Lp_step;
            viable=1;
            if ((size_Lp>=size_Lp_min)&&(size_Lp<=size_Lp_max)) {
                tcl_gamma_op_cmd(CD,NULL,0,NULL);
            }
            size_Lp=size_Lp+size_Lp_step;
            size_Wp=size_Wp+size_Wp_step;
            viable=1;
            if ((size_Wp>=size_Lp)&&(size_Wp<=size_Wp_max)) {
                tcl_gamma_op_cmd(CD,NULL,0,NULL);
            }
            size_Wp=size_Wp-2*size_Wp_step;
            viable=1;
            if ((size_Wp>=size_Lp)&&(size_Wp<=size_Wp_max)) {
                tcl_gamma_op_cmd(CD,NULL,0,NULL);
            }
            size_Wp=size_Wp+size_Wp_step;
            size_Ln=size_Ln+size_Ln_step;
            viable=1;
            if ((size_Ln>=size_Ln_min)&&(size_Ln<=size_Ln_max)) {
                tcl_gamma_op_cmd(CD,NULL,0,NULL);
            }
            size_Ln=size_Ln-2*size_Ln_step;
            viable=1;
            if ((size_Ln>=size_Ln_min)&&(size_Ln<=size_Ln_max)) {
                tcl_gamma_op_cmd(CD,NULL,0,NULL);
            }
            size_Ln=size_Ln+size_Ln_step;
            size_Wn=size_Wn+size_Wn_step;
            viable=1;
            if ((size_Wn>=size_Ln)&&(size_Wn<=size_Wn_max)) {
                tcl_gamma_op_cmd(CD,NULL,0,NULL);
            }
            size_Wn=size_Wn-2*size_Wn_step;
            viable=1;
            if ((size_Wn>=size_Ln)&&(size_Wn<=size_Wn_max)) {
                tcl_gamma_op_cmd(CD,NULL,0,NULL);
            }
            size_Wn=size_Wn+size_Wn_step;
            size_Ls=size_Ls+size_Ls_step;
            viable=1;
            if ((size_Ls>=size_Ls_min)&&(size_Ls<=size_Ls_max)) {
                tcl_gamma_op_cmd(CD,NULL,0,NULL);
            }
            size_Ls=size_Ls-2*size_Ls_step;
            viable=1;
            if ((size_Ls>=size_Ls_min)&&(size_Ls<=size_Ls_max)) {
                tcl_gamma_op_cmd(CD,NULL,0,NULL);
            }
            size_Ls=size_Ls+size_Ls_step;
            if (p->content->num_of%100==0) {
                printf("               %ld/%g=%g%%\n",p->content->num_of,pat_size_target,100*p->content->num_of/pat_size_target);
                fflush(stdout);
                if (param_unique>0) {
                    pat_unique(p,param_unique);
                }
            }
        }
        printf("   Done %ld/%g=%g%% (%ld visited)\n",p->content->num_of,pat_size_target,100*p->content->num_of/pat_size_target,more_to_breed);
    }
    return TCL_OK;
}
static int tcl_gamma_random_breed_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    ClientData CD;
    int i,j;
    PAT *p=(PAT *)Pdiffpair_nmos_circuits_PAT;
    long int r;
    float step;
    while (1) {
        if (p->content->num_of>config_pat_size_target) break;
        int sweep_size=p->content->num_of;
        for (i=0;i<sweep_size;i++) {
            size_iref=p->content->content[i]->sizes->content[0];
            size_Lp=p->content->content[i]->sizes->content[1];
            size_Wp=p->content->content[i]->sizes->content[2];
            size_Ln=p->content->content[i]->sizes->content[3];
            size_Wn=p->content->content[i]->sizes->content[4];
            size_Ls=p->content->content[i]->sizes->content[5];
            while (1) {
                step=(2.0*random()/RAND_MAX-1)*size_iref_step;
                if (size_iref+step<size_iref_min) continue;
                if (size_iref+step>size_iref_max) continue;
                break;
            }
            size_iref+=step;
            while (1) {
                step=(2.0*random()/RAND_MAX-1)*size_Lp_step;
                if (size_Lp+step<size_Lp_min) continue;
                if (size_Lp+step>size_Lp_max) continue;
                break;
            }
            size_Lp+=step;
            while (1) {
                step=(2.0*random()/RAND_MAX-1)*size_Wp_step;
                if (size_Wp+step<size_Lp) continue;
                if (size_Wp+step>size_Wp_max) continue;
                break;
            }
            size_Wp+=step;
            while (1) {
                step=(2.0*random()/RAND_MAX-1)*size_Ln_step;
                if (size_Ln+step<size_Ln_min) continue;
                if (size_Ln+step>size_Ln_max) continue;
                break;
            }
            size_Ln+=step;
            while (1) {
                step=(2.0*random()/RAND_MAX-1)*size_Wn_step;
                if (size_Wn+step<size_Ln) continue;
                if (size_Wn+step>size_Wn_max) continue;
                break;
            }
            size_Wn+=step;
            while (1) {
                step=(2.0*random()/RAND_MAX-1)*size_Ls_step;
                if (size_Ls+step<size_Ls_min) continue;
                if (size_Ls+step>size_Ls_max) continue;
                break;
            }
            size_Ls+=step;
            int pre_volume=p->content->num_of;
            if (tcl_gamma_op_cmd(CD,NULL,0,NULL)==TCL_ERROR) {i--; continue;}
            if (pre_volume==p->content->num_of) {i--; continue;}
            if (p->content->num_of%1000==0) {
                printf("               %ld/%g=%g%% max gain=%g\n",p->content->num_of,config_pat_size_target,100*p->content->num_of/config_pat_size_target,max_Adc);
                printf("               %ld/%g=%g%%\n",p->content->num_of,config_pat_size_target,100*p->content->num_of/config_pat_size_target);
                fflush(stdout);
                if (param_unique>0) {
                    pat_unique(p,param_unique);
                    printf("               post unique: %ld/%g=%g%%\n",p->content->num_of,config_pat_size_target,100*p->content->num_of/config_pat_size_target);
                    if (p->content->num_of>0.92*config_pat_size_target) break;
                }
            }
            if (p->content->num_of>config_pat_size_target) break;
        }
        if (p->content->num_of>config_pat_size_target) break;
    }
    return TCL_OK;
}
static int tcl_gamma_random_breed_single_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    ClientData CD;
    int i;
    PAT *p=(PAT *)Pdiffpair_nmos_circuits_PAT;
    int more_to_breed=0;
    long int r;
    long int breed_count=p->content->num_of;
    long int watchdog=0;
    float step;
    int sweep_size=p->content->num_of;
    int searched_id=(int)circuit_breed_id;
    for (i=0;i<p->content->num_of;i++) {
        if (p->content->content[i]->id==searched_id) break;
    }
    printf("Found circuit id %d at index %d\n",searched_id,i);
    while (watchdog++<10000) {
        size_iref=p->content->content[i]->sizes->content[0];
        size_Lp=p->content->content[i]->sizes->content[1];
        size_Wp=p->content->content[i]->sizes->content[2];
        size_Ln=p->content->content[i]->sizes->content[3];
        size_Wn=p->content->content[i]->sizes->content[4];
        size_Ls=p->content->content[i]->sizes->content[5];
        while (1) {
            step=(2.0*random()/RAND_MAX-1)*size_iref_step;
            if (size_iref+step<size_iref_min) continue;
            if (size_iref+step>size_iref_max) continue;
            break;
        }
        size_iref+=step;
        while (1) {
            step=(2.0*random()/RAND_MAX-1)*size_Lp_step;
            if (size_Lp+step<size_Lp_min) continue;
            if (size_Lp+step>size_Lp_max) continue;
            break;
        }
        size_Lp+=step;
        while (1) {
            step=(2.0*random()/RAND_MAX-1)*size_Wp_step;
            if (size_Wp+step<size_Lp) continue;
            if (size_Wp+step>size_Wp_max) continue;
            break;
        }
        size_Wp+=step;
        while (1) {
            step=(2.0*random()/RAND_MAX-1)*size_Ln_step;
            if (size_Ln+step<size_Ln_min) continue;
            if (size_Ln+step>size_Ln_max) continue;
            break;
        }
        size_Ln+=step;
        while (1) {
            step=(2.0*random()/RAND_MAX-1)*size_Wn_step;
            if (size_Wn+step<size_Ln) continue;
            if (size_Wn+step>size_Wn_max) continue;
            break;
        }
        size_Wn+=step;
        while (1) {
            step=(2.0*random()/RAND_MAX-1)*size_Ls_step;
            if (size_Ls+step<size_Ls_min) continue;
            if (size_Ls+step>size_Ls_max) continue;
            break;
        }
        size_Ls+=step;
        if (tcl_gamma_op_cmd(CD,NULL,0,NULL)==TCL_ERROR) continue;
        if (p->content->num_of>=breed_count+circuit_breed_target) break;
    }
    return TCL_OK;
}
// Initializing cTree references and registering the tcl_gamma_op_cmd command as ::C::diffpair_nmos
int Gamma_Init(Tcl_Interp *interp) {
    if (Tcl_InitStubs(interp, TCL_VERSION, 0) == NULL) {
        return TCL_ERROR;
    }
    float *array_entry;
    context *c;
    Pdiffpair_nmos_circuits_PAT=(float *)get_PAT("diffpair_nmos:circuits");
    c=create_context("config:pat_size_target");
    Pconfig_pat_size_target=(float *)(&c->value.s);
    c=create_context("size:iref");
    Psize_iref=(float *)(&c->value.s);
    c=create_context("size:iref:min");
    Psize_iref_min=(float *)(&c->value.s);
    c=create_context("size:iref:max");
    Psize_iref_max=(float *)(&c->value.s);
    c=create_context("size:Lp");
    Psize_Lp=(float *)(&c->value.s);
    c=create_context("size:Lp:min");
    Psize_Lp_min=(float *)(&c->value.s);
    c=create_context("size:Lp:max");
    Psize_Lp_max=(float *)(&c->value.s);
    c=create_context("size:Wp");
    Psize_Wp=(float *)(&c->value.s);
    c=create_context("size:Wp:max");
    Psize_Wp_max=(float *)(&c->value.s);
    c=create_context("size:Ln");
    Psize_Ln=(float *)(&c->value.s);
    c=create_context("size:Ln:min");
    Psize_Ln_min=(float *)(&c->value.s);
    c=create_context("size:Ln:max");
    Psize_Ln_max=(float *)(&c->value.s);
    c=create_context("size:Wn");
    Psize_Wn=(float *)(&c->value.s);
    c=create_context("size:Wn:max");
    Psize_Wn_max=(float *)(&c->value.s);
    c=create_context("size:Ls");
    Psize_Ls=(float *)(&c->value.s);
    c=create_context("size:Ls:min");
    Psize_Ls_min=(float *)(&c->value.s);
    c=create_context("size:Ls:max");
    Psize_Ls_max=(float *)(&c->value.s);
    c=create_context("size:iref:step");
    Psize_iref_step=(float *)(&c->value.s);
    c=create_context("size:Lp:step");
    Psize_Lp_step=(float *)(&c->value.s);
    c=create_context("size:Wp:step");
    Psize_Wp_step=(float *)(&c->value.s);
    c=create_context("size:Ln:step");
    Psize_Ln_step=(float *)(&c->value.s);
    c=create_context("size:Wn:step");
    Psize_Wn_step=(float *)(&c->value.s);
    c=create_context("size:Ls:step");
    Psize_Ls_step=(float *)(&c->value.s);
    c=create_context("max_Adc");
    Pmax_Adc=(float *)(&c->value.s);
    c=create_context("param:unique");
    Pparam_unique=(float *)(&c->value.s);
    c=create_context("pat_size_target");
    Ppat_size_target=(float *)(&c->value.s);
    c=create_context("mode:freash_op");
    Pmode_freash_op=(float *)(&c->value.s);
    c=create_context("outm:V");
    Poutm_V=(float *)(&c->value.s);
    c=create_context("vdd:V");
    Pvdd_V=(float *)(&c->value.s);
    c=create_context("outp:V");
    Poutp_V=(float *)(&c->value.s);
    c=create_context("inp:V");
    Pinp_V=(float *)(&c->value.s);
    c=create_context("param:inp");
    Pparam_inp=(float *)(&c->value.s);
    c=create_context("tail:V");
    Ptail_V=(float *)(&c->value.s);
    c=create_context("inn:V");
    Pinn_V=(float *)(&c->value.s);
    c=create_context("param:inn");
    Pparam_inn=(float *)(&c->value.s);
    c=create_context("vbias:V");
    Pvbias_V=(float *)(&c->value.s);
    c=create_context("status:index");
    Pstatus_index=(float *)(&c->value.s);
    c=create_context("config:size:iref");
    Pconfig_size_iref=(float *)(&c->value.s);
    c=create_context("config:size:Lp");
    Pconfig_size_Lp=(float *)(&c->value.s);
    c=create_context("config:size:Wp");
    Pconfig_size_Wp=(float *)(&c->value.s);
    c=create_context("config:size:Ln");
    Pconfig_size_Ln=(float *)(&c->value.s);
    c=create_context("config:size:Wn");
    Pconfig_size_Wn=(float *)(&c->value.s);
    c=create_context("config:size:Ls");
    Pconfig_size_Ls=(float *)(&c->value.s);
    c=create_context("0:V");
    P0_V=(float *)(&c->value.s);
    c=create_context("status:fail");
    Pstatus_fail=(float *)(&c->value.s);
    c=create_context("design_feedback");
    Pdesign_feedback=(float *)(&c->value.s);
    c=create_context("p_1:bin");
    Pp_1_bin=(float *)(&c->value.s);
    Plook_up_tables_pch_binning_LUT=(float *)get_LUT("look_up_tables:pch:binning");
    c=create_context("p_1:L");
    Pp_1_L=(float *)(&c->value.s);
    c=create_context("p_1:W");
    Pp_1_W=(float *)(&c->value.s);
    c=create_context("p_2:bin");
    Pp_2_bin=(float *)(&c->value.s);
    c=create_context("p_2:L");
    Pp_2_L=(float *)(&c->value.s);
    c=create_context("p_2:W");
    Pp_2_W=(float *)(&c->value.s);
    c=create_context("nin_1:bin");
    Pnin_1_bin=(float *)(&c->value.s);
    Plook_up_tables_nch_binning_LUT=(float *)get_LUT("look_up_tables:nch:binning");
    c=create_context("nin_1:L");
    Pnin_1_L=(float *)(&c->value.s);
    c=create_context("nin_1:W");
    Pnin_1_W=(float *)(&c->value.s);
    c=create_context("nin_2:bin");
    Pnin_2_bin=(float *)(&c->value.s);
    c=create_context("nin_2:L");
    Pnin_2_L=(float *)(&c->value.s);
    c=create_context("nin_2:W");
    Pnin_2_W=(float *)(&c->value.s);
    c=create_context("ntail:bin");
    Pntail_bin=(float *)(&c->value.s);
    c=create_context("ntail:L");
    Pntail_L=(float *)(&c->value.s);
    c=create_context("ntail:W");
    Pntail_W=(float *)(&c->value.s);
    c=create_context("nref:bin");
    Pnref_bin=(float *)(&c->value.s);
    c=create_context("nref:L");
    Pnref_L=(float *)(&c->value.s);
    c=create_context("nref:W");
    Pnref_W=(float *)(&c->value.s);
    c=create_context("leak");
    Pleak=(float *)(&c->value.s);
    c=create_context("config:op_iterations");
    Pconfig_op_iterations=(float *)(&c->value.s);
    c=create_context("config:kcl_th");
    Pconfig_kcl_th=(float *)(&c->value.s);
    c=create_context("config:design_feedback_th");
    Pconfig_design_feedback_th=(float *)(&c->value.s);
    c=create_context("look_up_tables:pch:Ids:ss");
    Plook_up_tables_pch_Ids_ss_CONTEXT=(float *)&c;
    c=create_context("look_up_tables:pch:gm:ss");
    Plook_up_tables_pch_gm_ss_CONTEXT=(float *)&c;
    c=create_context("look_up_tables:pch:go:ss");
    Plook_up_tables_pch_go_ss_CONTEXT=(float *)&c;
    c=create_context("look_up_tables:pch:gb:ss");
    Plook_up_tables_pch_gb_ss_CONTEXT=(float *)&c;
    c=create_context("p_1:gb");
    Pp_1_gb=(float *)(&c->value.s);
    c=create_context("p_1:gm");
    Pp_1_gm=(float *)(&c->value.s);
    c=create_context("p_1:go");
    Pp_1_go=(float *)(&c->value.s);
    c=create_context("p_1:Ids");
    Pp_1_Ids=(float *)(&c->value.s);
    c=create_context("p_2:gb");
    Pp_2_gb=(float *)(&c->value.s);
    c=create_context("p_2:gm");
    Pp_2_gm=(float *)(&c->value.s);
    c=create_context("p_2:go");
    Pp_2_go=(float *)(&c->value.s);
    c=create_context("p_2:Ids");
    Pp_2_Ids=(float *)(&c->value.s);
    c=create_context("look_up_tables:nch:Ids:ss");
    Plook_up_tables_nch_Ids_ss_CONTEXT=(float *)&c;
    c=create_context("look_up_tables:nch:gm:ss");
    Plook_up_tables_nch_gm_ss_CONTEXT=(float *)&c;
    c=create_context("look_up_tables:nch:go:ss");
    Plook_up_tables_nch_go_ss_CONTEXT=(float *)&c;
    c=create_context("look_up_tables:nch:gb:ss");
    Plook_up_tables_nch_gb_ss_CONTEXT=(float *)&c;
    c=create_context("nin_1:gb");
    Pnin_1_gb=(float *)(&c->value.s);
    c=create_context("nin_1:gm");
    Pnin_1_gm=(float *)(&c->value.s);
    c=create_context("nin_1:go");
    Pnin_1_go=(float *)(&c->value.s);
    c=create_context("nin_1:Ids");
    Pnin_1_Ids=(float *)(&c->value.s);
    c=create_context("nin_2:gb");
    Pnin_2_gb=(float *)(&c->value.s);
    c=create_context("nin_2:gm");
    Pnin_2_gm=(float *)(&c->value.s);
    c=create_context("nin_2:go");
    Pnin_2_go=(float *)(&c->value.s);
    c=create_context("nin_2:Ids");
    Pnin_2_Ids=(float *)(&c->value.s);
    c=create_context("ntail:gb");
    Pntail_gb=(float *)(&c->value.s);
    c=create_context("ntail:gm");
    Pntail_gm=(float *)(&c->value.s);
    c=create_context("ntail:go");
    Pntail_go=(float *)(&c->value.s);
    c=create_context("ntail:Ids");
    Pntail_Ids=(float *)(&c->value.s);
    c=create_context("nref:gb");
    Pnref_gb=(float *)(&c->value.s);
    c=create_context("nref:gm");
    Pnref_gm=(float *)(&c->value.s);
    c=create_context("nref:go");
    Pnref_go=(float *)(&c->value.s);
    c=create_context("nref:Ids");
    Pnref_Ids=(float *)(&c->value.s);
    c=create_context("config:kcl_step");
    Pconfig_kcl_step=(float *)(&c->value.s);
    c=create_context("p_1:gmb");
    Pp_1_gmb=(float *)(&c->value.s);
    c=create_context("p_1:cdd");
    Pp_1_cdd=(float *)(&c->value.s);
    c=create_context("p_1:cdg");
    Pp_1_cdg=(float *)(&c->value.s);
    c=create_context("p_1:cds");
    Pp_1_cds=(float *)(&c->value.s);
    c=create_context("p_1:cdb");
    Pp_1_cdb=(float *)(&c->value.s);
    c=create_context("p_1:csd");
    Pp_1_csd=(float *)(&c->value.s);
    c=create_context("p_1:csg");
    Pp_1_csg=(float *)(&c->value.s);
    c=create_context("p_1:css");
    Pp_1_css=(float *)(&c->value.s);
    c=create_context("p_1:csb");
    Pp_1_csb=(float *)(&c->value.s);
    c=create_context("p_1:cgd");
    Pp_1_cgd=(float *)(&c->value.s);
    c=create_context("p_1:cgg");
    Pp_1_cgg=(float *)(&c->value.s);
    c=create_context("p_1:cgs");
    Pp_1_cgs=(float *)(&c->value.s);
    c=create_context("p_1:cgb");
    Pp_1_cgb=(float *)(&c->value.s);
    c=create_context("p_2:gmb");
    Pp_2_gmb=(float *)(&c->value.s);
    c=create_context("p_2:cdd");
    Pp_2_cdd=(float *)(&c->value.s);
    c=create_context("p_2:cdg");
    Pp_2_cdg=(float *)(&c->value.s);
    c=create_context("p_2:cds");
    Pp_2_cds=(float *)(&c->value.s);
    c=create_context("p_2:cdb");
    Pp_2_cdb=(float *)(&c->value.s);
    c=create_context("p_2:csd");
    Pp_2_csd=(float *)(&c->value.s);
    c=create_context("p_2:csg");
    Pp_2_csg=(float *)(&c->value.s);
    c=create_context("p_2:css");
    Pp_2_css=(float *)(&c->value.s);
    c=create_context("p_2:csb");
    Pp_2_csb=(float *)(&c->value.s);
    c=create_context("p_2:cgd");
    Pp_2_cgd=(float *)(&c->value.s);
    c=create_context("p_2:cgg");
    Pp_2_cgg=(float *)(&c->value.s);
    c=create_context("p_2:cgs");
    Pp_2_cgs=(float *)(&c->value.s);
    c=create_context("p_2:cgb");
    Pp_2_cgb=(float *)(&c->value.s);
    c=create_context("nin_1:gmb");
    Pnin_1_gmb=(float *)(&c->value.s);
    c=create_context("nin_1:cdd");
    Pnin_1_cdd=(float *)(&c->value.s);
    c=create_context("nin_1:cdg");
    Pnin_1_cdg=(float *)(&c->value.s);
    c=create_context("nin_1:cds");
    Pnin_1_cds=(float *)(&c->value.s);
    c=create_context("nin_1:cdb");
    Pnin_1_cdb=(float *)(&c->value.s);
    c=create_context("nin_1:csd");
    Pnin_1_csd=(float *)(&c->value.s);
    c=create_context("nin_1:csg");
    Pnin_1_csg=(float *)(&c->value.s);
    c=create_context("nin_1:css");
    Pnin_1_css=(float *)(&c->value.s);
    c=create_context("nin_1:csb");
    Pnin_1_csb=(float *)(&c->value.s);
    c=create_context("nin_1:cgd");
    Pnin_1_cgd=(float *)(&c->value.s);
    c=create_context("nin_1:cgg");
    Pnin_1_cgg=(float *)(&c->value.s);
    c=create_context("nin_1:cgs");
    Pnin_1_cgs=(float *)(&c->value.s);
    c=create_context("nin_1:cgb");
    Pnin_1_cgb=(float *)(&c->value.s);
    c=create_context("nin_2:gmb");
    Pnin_2_gmb=(float *)(&c->value.s);
    c=create_context("nin_2:cdd");
    Pnin_2_cdd=(float *)(&c->value.s);
    c=create_context("nin_2:cdg");
    Pnin_2_cdg=(float *)(&c->value.s);
    c=create_context("nin_2:cds");
    Pnin_2_cds=(float *)(&c->value.s);
    c=create_context("nin_2:cdb");
    Pnin_2_cdb=(float *)(&c->value.s);
    c=create_context("nin_2:csd");
    Pnin_2_csd=(float *)(&c->value.s);
    c=create_context("nin_2:csg");
    Pnin_2_csg=(float *)(&c->value.s);
    c=create_context("nin_2:css");
    Pnin_2_css=(float *)(&c->value.s);
    c=create_context("nin_2:csb");
    Pnin_2_csb=(float *)(&c->value.s);
    c=create_context("nin_2:cgd");
    Pnin_2_cgd=(float *)(&c->value.s);
    c=create_context("nin_2:cgg");
    Pnin_2_cgg=(float *)(&c->value.s);
    c=create_context("nin_2:cgs");
    Pnin_2_cgs=(float *)(&c->value.s);
    c=create_context("nin_2:cgb");
    Pnin_2_cgb=(float *)(&c->value.s);
    c=create_context("ntail:gmb");
    Pntail_gmb=(float *)(&c->value.s);
    c=create_context("ntail:cdd");
    Pntail_cdd=(float *)(&c->value.s);
    c=create_context("ntail:cdg");
    Pntail_cdg=(float *)(&c->value.s);
    c=create_context("ntail:cds");
    Pntail_cds=(float *)(&c->value.s);
    c=create_context("ntail:cdb");
    Pntail_cdb=(float *)(&c->value.s);
    c=create_context("ntail:csd");
    Pntail_csd=(float *)(&c->value.s);
    c=create_context("ntail:csg");
    Pntail_csg=(float *)(&c->value.s);
    c=create_context("ntail:css");
    Pntail_css=(float *)(&c->value.s);
    c=create_context("ntail:csb");
    Pntail_csb=(float *)(&c->value.s);
    c=create_context("ntail:cgd");
    Pntail_cgd=(float *)(&c->value.s);
    c=create_context("ntail:cgg");
    Pntail_cgg=(float *)(&c->value.s);
    c=create_context("ntail:cgs");
    Pntail_cgs=(float *)(&c->value.s);
    c=create_context("ntail:cgb");
    Pntail_cgb=(float *)(&c->value.s);
    c=create_context("nref:gmb");
    Pnref_gmb=(float *)(&c->value.s);
    c=create_context("nref:cdd");
    Pnref_cdd=(float *)(&c->value.s);
    c=create_context("nref:cdg");
    Pnref_cdg=(float *)(&c->value.s);
    c=create_context("nref:cds");
    Pnref_cds=(float *)(&c->value.s);
    c=create_context("nref:cdb");
    Pnref_cdb=(float *)(&c->value.s);
    c=create_context("nref:csd");
    Pnref_csd=(float *)(&c->value.s);
    c=create_context("nref:csg");
    Pnref_csg=(float *)(&c->value.s);
    c=create_context("nref:css");
    Pnref_css=(float *)(&c->value.s);
    c=create_context("nref:csb");
    Pnref_csb=(float *)(&c->value.s);
    c=create_context("nref:cgd");
    Pnref_cgd=(float *)(&c->value.s);
    c=create_context("nref:cgg");
    Pnref_cgg=(float *)(&c->value.s);
    c=create_context("nref:cgs");
    Pnref_cgs=(float *)(&c->value.s);
    c=create_context("nref:cgb");
    Pnref_cgb=(float *)(&c->value.s);
    c=create_context("Det");
    PDet=(float *)(&c->value.s);
    c=create_context("Ted");
    PTed=(float *)(&c->value.s);
    c=create_context("property:Adc");
    Pproperty_Adc=(float *)(&c->value.s);
    c=create_context("property:CMRR");
    Pproperty_CMRR=(float *)(&c->value.s);
    c=create_context("property:PSRR");
    Pproperty_PSRR=(float *)(&c->value.s);
    c=create_context("config:fail_on_properties");
    Pconfig_fail_on_properties=(float *)(&c->value.s);
    c=create_context("property:Rout");
    Pproperty_Rout=(float *)(&c->value.s);
    c=create_context("s");
    Ps=(float *)(&c->value.s);
    c=create_context("property:BW");
    Pproperty_BW=(float *)(&c->value.s);
    c=create_context("property:BW:s");
    Pproperty_BW_s=(float *)(&c->value.s);
    c=create_context("p1");
    Pp1=(float *)(&c->value.s);
    c=create_context("p2");
    Pp2=(float *)(&c->value.s);
    c=create_context("property:ts");
    Pproperty_ts=(float *)(&c->value.s);
    c=create_context("property:Cin");
    Pproperty_Cin=(float *)(&c->value.s);
    c=create_context("property:PM");
    Pproperty_PM=(float *)(&c->value.s);
    c=create_context("p_1:Nt_unit");
    Pp_1_Nt_unit=(float *)(&c->value.s);
    P_look_up_tables_pch_thermal_noise_ss_LUT=(float *)get_LUT(":look_up_tables:pch:thermal_noise:ss");
    c=create_context("p_1:dNt_dvgs");
    Pp_1_dNt_dvgs=(float *)(&c->value.s);
    c=create_context("p_1:dNt_dvds");
    Pp_1_dNt_dvds=(float *)(&c->value.s);
    c=create_context("p_1:dNt_dvbs");
    Pp_1_dNt_dvbs=(float *)(&c->value.s);
    c=create_context("p_1:dNt_dl");
    Pp_1_dNt_dl=(float *)(&c->value.s);
    c=create_context("p_1:Nt");
    Pp_1_Nt=(float *)(&c->value.s);
    c=create_context("p_1:Nf_unit");
    Pp_1_Nf_unit=(float *)(&c->value.s);
    P_look_up_tables_pch_flicker_noise_ss_LUT=(float *)get_LUT(":look_up_tables:pch:flicker_noise:ss");
    c=create_context("p_1:dNf_dvgs");
    Pp_1_dNf_dvgs=(float *)(&c->value.s);
    c=create_context("p_1:dNf_dvds");
    Pp_1_dNf_dvds=(float *)(&c->value.s);
    c=create_context("p_1:dNf_dvbs");
    Pp_1_dNf_dvbs=(float *)(&c->value.s);
    c=create_context("p_1:dNf_dl");
    Pp_1_dNf_dl=(float *)(&c->value.s);
    c=create_context("p_1:Nf");
    Pp_1_Nf=(float *)(&c->value.s);
    c=create_context("p_2:Nt_unit");
    Pp_2_Nt_unit=(float *)(&c->value.s);
    c=create_context("p_2:dNt_dvgs");
    Pp_2_dNt_dvgs=(float *)(&c->value.s);
    c=create_context("p_2:dNt_dvds");
    Pp_2_dNt_dvds=(float *)(&c->value.s);
    c=create_context("p_2:dNt_dvbs");
    Pp_2_dNt_dvbs=(float *)(&c->value.s);
    c=create_context("p_2:dNt_dl");
    Pp_2_dNt_dl=(float *)(&c->value.s);
    c=create_context("p_2:Nt");
    Pp_2_Nt=(float *)(&c->value.s);
    c=create_context("p_2:Nf_unit");
    Pp_2_Nf_unit=(float *)(&c->value.s);
    c=create_context("p_2:dNf_dvgs");
    Pp_2_dNf_dvgs=(float *)(&c->value.s);
    c=create_context("p_2:dNf_dvds");
    Pp_2_dNf_dvds=(float *)(&c->value.s);
    c=create_context("p_2:dNf_dvbs");
    Pp_2_dNf_dvbs=(float *)(&c->value.s);
    c=create_context("p_2:dNf_dl");
    Pp_2_dNf_dl=(float *)(&c->value.s);
    c=create_context("p_2:Nf");
    Pp_2_Nf=(float *)(&c->value.s);
    c=create_context("nin_1:Nt_unit");
    Pnin_1_Nt_unit=(float *)(&c->value.s);
    P_look_up_tables_nch_thermal_noise_ss_LUT=(float *)get_LUT(":look_up_tables:nch:thermal_noise:ss");
    c=create_context("nin_1:dNt_dvgs");
    Pnin_1_dNt_dvgs=(float *)(&c->value.s);
    c=create_context("nin_1:dNt_dvds");
    Pnin_1_dNt_dvds=(float *)(&c->value.s);
    c=create_context("nin_1:dNt_dvbs");
    Pnin_1_dNt_dvbs=(float *)(&c->value.s);
    c=create_context("nin_1:dNt_dl");
    Pnin_1_dNt_dl=(float *)(&c->value.s);
    c=create_context("nin_1:Nt");
    Pnin_1_Nt=(float *)(&c->value.s);
    c=create_context("nin_1:Nf_unit");
    Pnin_1_Nf_unit=(float *)(&c->value.s);
    P_look_up_tables_nch_flicker_noise_ss_LUT=(float *)get_LUT(":look_up_tables:nch:flicker_noise:ss");
    c=create_context("nin_1:dNf_dvgs");
    Pnin_1_dNf_dvgs=(float *)(&c->value.s);
    c=create_context("nin_1:dNf_dvds");
    Pnin_1_dNf_dvds=(float *)(&c->value.s);
    c=create_context("nin_1:dNf_dvbs");
    Pnin_1_dNf_dvbs=(float *)(&c->value.s);
    c=create_context("nin_1:dNf_dl");
    Pnin_1_dNf_dl=(float *)(&c->value.s);
    c=create_context("nin_1:Nf");
    Pnin_1_Nf=(float *)(&c->value.s);
    c=create_context("nin_2:Nt_unit");
    Pnin_2_Nt_unit=(float *)(&c->value.s);
    c=create_context("nin_2:dNt_dvgs");
    Pnin_2_dNt_dvgs=(float *)(&c->value.s);
    c=create_context("nin_2:dNt_dvds");
    Pnin_2_dNt_dvds=(float *)(&c->value.s);
    c=create_context("nin_2:dNt_dvbs");
    Pnin_2_dNt_dvbs=(float *)(&c->value.s);
    c=create_context("nin_2:dNt_dl");
    Pnin_2_dNt_dl=(float *)(&c->value.s);
    c=create_context("nin_2:Nt");
    Pnin_2_Nt=(float *)(&c->value.s);
    c=create_context("nin_2:Nf_unit");
    Pnin_2_Nf_unit=(float *)(&c->value.s);
    c=create_context("nin_2:dNf_dvgs");
    Pnin_2_dNf_dvgs=(float *)(&c->value.s);
    c=create_context("nin_2:dNf_dvds");
    Pnin_2_dNf_dvds=(float *)(&c->value.s);
    c=create_context("nin_2:dNf_dvbs");
    Pnin_2_dNf_dvbs=(float *)(&c->value.s);
    c=create_context("nin_2:dNf_dl");
    Pnin_2_dNf_dl=(float *)(&c->value.s);
    c=create_context("nin_2:Nf");
    Pnin_2_Nf=(float *)(&c->value.s);
    c=create_context("ntail:Nt_unit");
    Pntail_Nt_unit=(float *)(&c->value.s);
    c=create_context("ntail:dNt_dvgs");
    Pntail_dNt_dvgs=(float *)(&c->value.s);
    c=create_context("ntail:dNt_dvds");
    Pntail_dNt_dvds=(float *)(&c->value.s);
    c=create_context("ntail:dNt_dvbs");
    Pntail_dNt_dvbs=(float *)(&c->value.s);
    c=create_context("ntail:dNt_dl");
    Pntail_dNt_dl=(float *)(&c->value.s);
    c=create_context("ntail:Nt");
    Pntail_Nt=(float *)(&c->value.s);
    c=create_context("ntail:Nf_unit");
    Pntail_Nf_unit=(float *)(&c->value.s);
    c=create_context("ntail:dNf_dvgs");
    Pntail_dNf_dvgs=(float *)(&c->value.s);
    c=create_context("ntail:dNf_dvds");
    Pntail_dNf_dvds=(float *)(&c->value.s);
    c=create_context("ntail:dNf_dvbs");
    Pntail_dNf_dvbs=(float *)(&c->value.s);
    c=create_context("ntail:dNf_dl");
    Pntail_dNf_dl=(float *)(&c->value.s);
    c=create_context("ntail:Nf");
    Pntail_Nf=(float *)(&c->value.s);
    c=create_context("nref:Nt_unit");
    Pnref_Nt_unit=(float *)(&c->value.s);
    c=create_context("nref:dNt_dvgs");
    Pnref_dNt_dvgs=(float *)(&c->value.s);
    c=create_context("nref:dNt_dvds");
    Pnref_dNt_dvds=(float *)(&c->value.s);
    c=create_context("nref:dNt_dvbs");
    Pnref_dNt_dvbs=(float *)(&c->value.s);
    c=create_context("nref:dNt_dl");
    Pnref_dNt_dl=(float *)(&c->value.s);
    c=create_context("nref:Nt");
    Pnref_Nt=(float *)(&c->value.s);
    c=create_context("nref:Nf_unit");
    Pnref_Nf_unit=(float *)(&c->value.s);
    c=create_context("nref:dNf_dvgs");
    Pnref_dNf_dvgs=(float *)(&c->value.s);
    c=create_context("nref:dNf_dvds");
    Pnref_dNf_dvds=(float *)(&c->value.s);
    c=create_context("nref:dNf_dvbs");
    Pnref_dNf_dvbs=(float *)(&c->value.s);
    c=create_context("nref:dNf_dl");
    Pnref_dNf_dl=(float *)(&c->value.s);
    c=create_context("nref:Nf");
    Pnref_Nf=(float *)(&c->value.s);
    c=create_context("property:Nt");
    Pproperty_Nt=(float *)(&c->value.s);
    c=create_context("property:Nf");
    Pproperty_Nf=(float *)(&c->value.s);
    c=create_context("property:fc");
    Pproperty_fc=(float *)(&c->value.s);
    c=create_context("property:TotalNoise");
    Pproperty_TotalNoise=(float *)(&c->value.s);
    c=create_context("property:Area");
    Pproperty_Area=(float *)(&c->value.s);
    c=create_context("property:Vos");
    Pproperty_Vos=(float *)(&c->value.s);
    c=create_context("property:Power");
    Pproperty_Power=(float *)(&c->value.s);
    c=create_context("config:factor:Adc");
    Pconfig_factor_Adc=(float *)(&c->value.s);
    c=create_context("config:shift:Adc");
    Pconfig_shift_Adc=(float *)(&c->value.s);
    c=create_context("config:factor:CMRR");
    Pconfig_factor_CMRR=(float *)(&c->value.s);
    c=create_context("config:shift:CMRR");
    Pconfig_shift_CMRR=(float *)(&c->value.s);
    c=create_context("config:factor:PSRR");
    Pconfig_factor_PSRR=(float *)(&c->value.s);
    c=create_context("config:shift:PSRR");
    Pconfig_shift_PSRR=(float *)(&c->value.s);
    c=create_context("config:factor:Rout");
    Pconfig_factor_Rout=(float *)(&c->value.s);
    c=create_context("config:shift:Rout");
    Pconfig_shift_Rout=(float *)(&c->value.s);
    c=create_context("config:factor:BW");
    Pconfig_factor_BW=(float *)(&c->value.s);
    c=create_context("config:shift:BW");
    Pconfig_shift_BW=(float *)(&c->value.s);
    c=create_context("config:factor:PM");
    Pconfig_factor_PM=(float *)(&c->value.s);
    c=create_context("config:shift:PM");
    Pconfig_shift_PM=(float *)(&c->value.s);
    c=create_context("config:factor:Cin");
    Pconfig_factor_Cin=(float *)(&c->value.s);
    c=create_context("config:shift:Cin");
    Pconfig_shift_Cin=(float *)(&c->value.s);
    c=create_context("config:factor:ts");
    Pconfig_factor_ts=(float *)(&c->value.s);
    c=create_context("config:shift:ts");
    Pconfig_shift_ts=(float *)(&c->value.s);
    c=create_context("config:factor:Nt");
    Pconfig_factor_Nt=(float *)(&c->value.s);
    c=create_context("config:shift:Nt");
    Pconfig_shift_Nt=(float *)(&c->value.s);
    c=create_context("config:factor:Nf");
    Pconfig_factor_Nf=(float *)(&c->value.s);
    c=create_context("config:shift:Nf");
    Pconfig_shift_Nf=(float *)(&c->value.s);
    c=create_context("config:factor:TotalNoise");
    Pconfig_factor_TotalNoise=(float *)(&c->value.s);
    c=create_context("config:shift:TotalNoise");
    Pconfig_shift_TotalNoise=(float *)(&c->value.s);
    c=create_context("config:factor:fc");
    Pconfig_factor_fc=(float *)(&c->value.s);
    c=create_context("config:shift:fc");
    Pconfig_shift_fc=(float *)(&c->value.s);
    c=create_context("config:factor:Vos");
    Pconfig_factor_Vos=(float *)(&c->value.s);
    c=create_context("config:shift:Vos");
    Pconfig_shift_Vos=(float *)(&c->value.s);
    c=create_context("config:factor:Area");
    Pconfig_factor_Area=(float *)(&c->value.s);
    c=create_context("config:shift:Area");
    Pconfig_shift_Area=(float *)(&c->value.s);
    c=create_context("config:factor:Power");
    Pconfig_factor_Power=(float *)(&c->value.s);
    c=create_context("config:shift:Power");
    Pconfig_shift_Power=(float *)(&c->value.s);
    c=create_context("circuit_breed_id");
    Pcircuit_breed_id=(float *)(&c->value.s);
    c=create_context("circuit_breed_target");
    Pcircuit_breed_target=(float *)(&c->value.s);
    Tcl_CreateObjCommand(interp, "::C::random", tcl_gamma_random_cmd, NULL, NULL);
    Tcl_CreateObjCommand(interp, "::C::random_breed", tcl_gamma_random_breed_cmd, NULL, NULL);
    Tcl_CreateObjCommand(interp, "::C::random_breed_single", tcl_gamma_random_breed_single_cmd, NULL, NULL);
    Tcl_CreateObjCommand(interp, "::C::breed", tcl_gamma_breed_cmd, NULL, NULL);
    // Tcl_CreateObjCommand(interp, "::C::grad", tcl_gamma_grad_cmd, NULL, NULL);
    Tcl_CreateObjCommand(interp, "::C::op", tcl_gamma_op_cmd, NULL, NULL);
    Tcl_CreateObjCommand(interp, "::C::import", tcl_gamma_import_cmd, NULL, NULL);
    Tcl_CreateObjCommand(interp, "::C::export", tcl_gamma_export_cmd, NULL, NULL);
    return TCL_OK;
}
