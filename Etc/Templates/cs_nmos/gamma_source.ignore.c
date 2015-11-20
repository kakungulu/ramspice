#include <tcl.h>
#include <stdio.h>
#include <stdlib.h>
#include "ctree.h"
#include "look_up_table.h"
// Some global pointers to keep reference of the contexts this object manipulates
float *Pcs_nmos_circuits_PAT;
float *Pconfig_pat_size_target;
float *Psize_L;
float *Psize_L_min;
float *Psize_L_max;
float *Psize_W;
float *Psize_W_max;
float *Psize_iref;
float *Psize_iref_min;
float *Psize_iref_max;
float *Psize_rin;
float *Psize_rin_min;
float *Psize_rin_max;
float *Psize_L_step;
float *Psize_W_step;
float *Psize_iref_step;
float *Psize_rin_step;
float *Pmax_Adc;
float *Pparam_unique;
float *Ppat_size_target;
float *Pout_V;
float *Pvdd_V;
float *Pin_V;
float *Pparam_in;
float *Pmid_V;
float *Pconfig_size_L;
float *Pconfig_size_W;
float *Pconfig_size_iref;
float *Pconfig_size_rin;
float *P0_V;
float *Pstatus_fail;
float *Pdesign_feedback;
float *Pleak;
float *Pconfig_op_iterations;
float *Pconfig_kcl_th;
float *Pconfig_design_feedback_th;
float *Plook_up_tables_nch_Ids_ss_LUT;
float *Plook_up_tables_nch_gm_ss_LUT;
float *Plook_up_tables_nch_ro_ss_LUT;
float *Pn_ref_gm;
float *Pn_ref_go;
float *Pn_ref_Ids;
float *PGds_in_mid;
float *Pconfig_kcl_step;
float *PDet;
float *PTed;
float *Pproperty_Adc;
float *Pproperty_CMRR;
float *Pproperty_PSRR;
float *Pconfig_fail_on_properties;
float *Pn_ref_Nt_unit;
float *P_look_up_tables_nch_thermal_noise_ss_LUT;
float *Pn_ref_dNt_dvgs;
float *Pn_ref_dNt_dvds;
float *Pn_ref_dNt_dvbs;
float *Pn_ref_dNt_dl;
float *Pn_ref_Nt;
float *Pn_ref_Nf_unit;
float *P_look_up_tables_nch_flicker_noise_ss_LUT;
float *Pn_ref_dNf_dvgs;
float *Pn_ref_dNf_dvds;
float *Pn_ref_dNf_dvbs;
float *Pn_ref_dNf_dl;
float *Pn_ref_Nf;
float *Pproperty_Rout;
float *Pn_ref_cgs;
float *Plook_up_tables_nch_cox;
float *Pn_ref_cgs_out;
float *Pn_ref_cgd;
float *Pn_ref_cgd_out;
float *Ps;
float *Pproperty_BW_s;
float *Pp1;
float *Pproperty_BW;
float *Pp2;
float *Pproperty_ts;
float *Pn_ref_noise_trans;
float *Pproperty_Nt;
float *Pproperty_Nt_L;
float *Pn_ref_noise_trans_L;
float *Pn_ref_Nt_L;
float *Pproperty_Nt_W;
float *Pn_ref_noise_trans_W;
float *Pn_ref_Nt_W;
float *Pproperty_Nt_iref;
float *Pn_ref_noise_trans_iref;
float *Pn_ref_Nt_iref;
float *Pproperty_Nt_rin;
float *Pn_ref_noise_trans_rin;
float *Pn_ref_Nt_rin;
float *Pproperty_Nf;
float *Pproperty_Nf_L;
float *Pn_ref_Nf_L;
float *Pproperty_Nf_W;
float *Pn_ref_Nf_W;
float *Pproperty_Nf_iref;
float *Pn_ref_Nf_iref;
float *Pproperty_Nf_rin;
float *Pn_ref_Nf_rin;
float *Pproperty_fc;
float *Pproperty_Area;
float *Pparam_area_spacing;
float *Pproperty_Vos;
float *Pproperty_Power;
float *Pproperty_PM;
float *Pproperty_Cin;
float *Pcircuit_breed_id;
float *Pcircuit_breed_target;
float cs_nmos_circuits_PAT;
float config_pat_size_target;
float size_L;
float size_L_min;
float size_L_max;
float size_W;
float size_W_max;
float size_iref;
float size_iref_min;
float size_iref_max;
float size_rin;
float size_rin_min;
float size_rin_max;
float size_L_step;
float size_W_step;
float size_iref_step;
float size_rin_step;
float max_Adc;
float param_unique;
float pat_size_target;
float out_V;
float vdd_V;
float in_V;
float param_in;
float mid_V;
float config_size_L;
float config_size_W;
float config_size_iref;
float config_size_rin;
float CONST_0_V;
float status_fail;
float design_feedback;
float leak;
float config_op_iterations;
float config_kcl_th;
float config_design_feedback_th;
float look_up_tables_nch_Ids_ss_LUT;
float look_up_tables_nch_gm_ss_LUT;
float look_up_tables_nch_ro_ss_LUT;
float n_ref_gm;
float n_ref_go;
float n_ref_Ids;
float Gds_in_mid;
float config_kcl_step;
float Det;
float Ted;
float property_Adc;
float property_CMRR;
float property_PSRR;
float config_fail_on_properties;
float n_ref_Nt_unit;
float _look_up_tables_nch_thermal_noise_ss_LUT;
float n_ref_dNt_dvgs;
float n_ref_dNt_dvds;
float n_ref_dNt_dvbs;
float n_ref_dNt_dl;
float n_ref_Nt;
float n_ref_Nf_unit;
float _look_up_tables_nch_flicker_noise_ss_LUT;
float n_ref_dNf_dvgs;
float n_ref_dNf_dvds;
float n_ref_dNf_dvbs;
float n_ref_dNf_dl;
float n_ref_Nf;
float property_Rout;
float n_ref_cgs;
float look_up_tables_nch_cox;
float n_ref_cgs_out;
float n_ref_cgd;
float n_ref_cgd_out;
float s;
float property_BW_s;
float p1;
float property_BW;
float p2;
float property_ts;
float n_ref_noise_trans;
float property_Nt;
float property_Nt_L;
float n_ref_noise_trans_L;
float n_ref_Nt_L;
float property_Nt_W;
float n_ref_noise_trans_W;
float n_ref_Nt_W;
float property_Nt_iref;
float n_ref_noise_trans_iref;
float n_ref_Nt_iref;
float property_Nt_rin;
float n_ref_noise_trans_rin;
float n_ref_Nt_rin;
float property_Nf;
float property_Nf_L;
float n_ref_Nf_L;
float property_Nf_W;
float n_ref_Nf_W;
float property_Nf_iref;
float n_ref_Nf_iref;
float property_Nf_rin;
float n_ref_Nf_rin;
float property_fc;
float property_Area;
float param_area_spacing;
float property_Vos;
float property_Power;
float property_PM;
float property_Cin;
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
    size_L=*Psize_L;
    size_L_min=*Psize_L_min;
    size_L_max=*Psize_L_max;
    size_W=*Psize_W;
    size_W_max=*Psize_W_max;
    size_iref=*Psize_iref;
    size_iref_min=*Psize_iref_min;
    size_iref_max=*Psize_iref_max;
    size_rin=*Psize_rin;
    size_rin_min=*Psize_rin_min;
    size_rin_max=*Psize_rin_max;
    size_L_step=*Psize_L_step;
    size_W_step=*Psize_W_step;
    size_iref_step=*Psize_iref_step;
    size_rin_step=*Psize_rin_step;
    max_Adc=*Pmax_Adc;
    param_unique=*Pparam_unique;
    pat_size_target=*Ppat_size_target;
    out_V=*Pout_V;
    vdd_V=*Pvdd_V;
    in_V=*Pin_V;
    param_in=*Pparam_in;
    mid_V=*Pmid_V;
    config_size_L=*Pconfig_size_L;
    config_size_W=*Pconfig_size_W;
    config_size_iref=*Pconfig_size_iref;
    config_size_rin=*Pconfig_size_rin;
    CONST_0_V=*P0_V;
    status_fail=*Pstatus_fail;
    design_feedback=*Pdesign_feedback;
    leak=*Pleak;
    config_op_iterations=*Pconfig_op_iterations;
    config_kcl_th=*Pconfig_kcl_th;
    config_design_feedback_th=*Pconfig_design_feedback_th;
    n_ref_gm=*Pn_ref_gm;
    n_ref_go=*Pn_ref_go;
    n_ref_Ids=*Pn_ref_Ids;
    Gds_in_mid=*PGds_in_mid;
    config_kcl_step=*Pconfig_kcl_step;
    Det=*PDet;
    Ted=*PTed;
    property_Adc=*Pproperty_Adc;
    property_CMRR=*Pproperty_CMRR;
    property_PSRR=*Pproperty_PSRR;
    config_fail_on_properties=*Pconfig_fail_on_properties;
    n_ref_Nt_unit=*Pn_ref_Nt_unit;
    n_ref_dNt_dvgs=*Pn_ref_dNt_dvgs;
    n_ref_dNt_dvds=*Pn_ref_dNt_dvds;
    n_ref_dNt_dvbs=*Pn_ref_dNt_dvbs;
    n_ref_dNt_dl=*Pn_ref_dNt_dl;
    n_ref_Nt=*Pn_ref_Nt;
    n_ref_Nf_unit=*Pn_ref_Nf_unit;
    n_ref_dNf_dvgs=*Pn_ref_dNf_dvgs;
    n_ref_dNf_dvds=*Pn_ref_dNf_dvds;
    n_ref_dNf_dvbs=*Pn_ref_dNf_dvbs;
    n_ref_dNf_dl=*Pn_ref_dNf_dl;
    n_ref_Nf=*Pn_ref_Nf;
    property_Rout=*Pproperty_Rout;
    n_ref_cgs=*Pn_ref_cgs;
    look_up_tables_nch_cox=*Plook_up_tables_nch_cox;
    n_ref_cgs_out=*Pn_ref_cgs_out;
    n_ref_cgd=*Pn_ref_cgd;
    n_ref_cgd_out=*Pn_ref_cgd_out;
    s=*Ps;
    property_BW_s=*Pproperty_BW_s;
    p1=*Pp1;
    property_BW=*Pproperty_BW;
    p2=*Pp2;
    property_ts=*Pproperty_ts;
    n_ref_noise_trans=*Pn_ref_noise_trans;
    property_Nt=*Pproperty_Nt;
    property_Nt_L=*Pproperty_Nt_L;
    n_ref_noise_trans_L=*Pn_ref_noise_trans_L;
    n_ref_Nt_L=*Pn_ref_Nt_L;
    property_Nt_W=*Pproperty_Nt_W;
    n_ref_noise_trans_W=*Pn_ref_noise_trans_W;
    n_ref_Nt_W=*Pn_ref_Nt_W;
    property_Nt_iref=*Pproperty_Nt_iref;
    n_ref_noise_trans_iref=*Pn_ref_noise_trans_iref;
    n_ref_Nt_iref=*Pn_ref_Nt_iref;
    property_Nt_rin=*Pproperty_Nt_rin;
    n_ref_noise_trans_rin=*Pn_ref_noise_trans_rin;
    n_ref_Nt_rin=*Pn_ref_Nt_rin;
    property_Nf=*Pproperty_Nf;
    property_Nf_L=*Pproperty_Nf_L;
    n_ref_Nf_L=*Pn_ref_Nf_L;
    property_Nf_W=*Pproperty_Nf_W;
    n_ref_Nf_W=*Pn_ref_Nf_W;
    property_Nf_iref=*Pproperty_Nf_iref;
    n_ref_Nf_iref=*Pn_ref_Nf_iref;
    property_Nf_rin=*Pproperty_Nf_rin;
    n_ref_Nf_rin=*Pn_ref_Nf_rin;
    property_fc=*Pproperty_fc;
    property_Area=*Pproperty_Area;
    param_area_spacing=*Pparam_area_spacing;
    property_Vos=*Pproperty_Vos;
    property_Power=*Pproperty_Power;
    property_PM=*Pproperty_PM;
    property_Cin=*Pproperty_Cin;
    circuit_breed_id=*Pcircuit_breed_id;
    circuit_breed_target=*Pcircuit_breed_target;
    return TCL_OK;
}
static int tcl_gamma_export_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    *Pconfig_pat_size_target=config_pat_size_target;
    *Psize_L=size_L;
    *Psize_L_min=size_L_min;
    *Psize_L_max=size_L_max;
    *Psize_W=size_W;
    *Psize_W_max=size_W_max;
    *Psize_iref=size_iref;
    *Psize_iref_min=size_iref_min;
    *Psize_iref_max=size_iref_max;
    *Psize_rin=size_rin;
    *Psize_rin_min=size_rin_min;
    *Psize_rin_max=size_rin_max;
    *Psize_L_step=size_L_step;
    *Psize_W_step=size_W_step;
    *Psize_iref_step=size_iref_step;
    *Psize_rin_step=size_rin_step;
    *Pmax_Adc=max_Adc;
    *Pparam_unique=param_unique;
    *Ppat_size_target=pat_size_target;
    *Pout_V=out_V;
    *Pvdd_V=vdd_V;
    *Pin_V=in_V;
    *Pparam_in=param_in;
    *Pmid_V=mid_V;
    *Pconfig_size_L=config_size_L;
    *Pconfig_size_W=config_size_W;
    *Pconfig_size_iref=config_size_iref;
    *Pconfig_size_rin=config_size_rin;
    *P0_V=CONST_0_V;
    *Pstatus_fail=status_fail;
    *Pdesign_feedback=design_feedback;
    *Pleak=leak;
    *Pconfig_op_iterations=config_op_iterations;
    *Pconfig_kcl_th=config_kcl_th;
    *Pconfig_design_feedback_th=config_design_feedback_th;
    *Pn_ref_gm=n_ref_gm;
    *Pn_ref_go=n_ref_go;
    *Pn_ref_Ids=n_ref_Ids;
    *PGds_in_mid=Gds_in_mid;
    *Pconfig_kcl_step=config_kcl_step;
    *PDet=Det;
    *PTed=Ted;
    *Pproperty_Adc=property_Adc;
    *Pproperty_CMRR=property_CMRR;
    *Pproperty_PSRR=property_PSRR;
    *Pconfig_fail_on_properties=config_fail_on_properties;
    *Pn_ref_Nt_unit=n_ref_Nt_unit;
    *Pn_ref_dNt_dvgs=n_ref_dNt_dvgs;
    *Pn_ref_dNt_dvds=n_ref_dNt_dvds;
    *Pn_ref_dNt_dvbs=n_ref_dNt_dvbs;
    *Pn_ref_dNt_dl=n_ref_dNt_dl;
    *Pn_ref_Nt=n_ref_Nt;
    *Pn_ref_Nf_unit=n_ref_Nf_unit;
    *Pn_ref_dNf_dvgs=n_ref_dNf_dvgs;
    *Pn_ref_dNf_dvds=n_ref_dNf_dvds;
    *Pn_ref_dNf_dvbs=n_ref_dNf_dvbs;
    *Pn_ref_dNf_dl=n_ref_dNf_dl;
    *Pn_ref_Nf=n_ref_Nf;
    *Pproperty_Rout=property_Rout;
    *Pn_ref_cgs=n_ref_cgs;
    *Plook_up_tables_nch_cox=look_up_tables_nch_cox;
    *Pn_ref_cgs_out=n_ref_cgs_out;
    *Pn_ref_cgd=n_ref_cgd;
    *Pn_ref_cgd_out=n_ref_cgd_out;
    *Ps=s;
    *Pproperty_BW_s=property_BW_s;
    *Pp1=p1;
    *Pproperty_BW=property_BW;
    *Pp2=p2;
    *Pproperty_ts=property_ts;
    *Pn_ref_noise_trans=n_ref_noise_trans;
    *Pproperty_Nt=property_Nt;
    *Pproperty_Nt_L=property_Nt_L;
    *Pn_ref_noise_trans_L=n_ref_noise_trans_L;
    *Pn_ref_Nt_L=n_ref_Nt_L;
    *Pproperty_Nt_W=property_Nt_W;
    *Pn_ref_noise_trans_W=n_ref_noise_trans_W;
    *Pn_ref_Nt_W=n_ref_Nt_W;
    *Pproperty_Nt_iref=property_Nt_iref;
    *Pn_ref_noise_trans_iref=n_ref_noise_trans_iref;
    *Pn_ref_Nt_iref=n_ref_Nt_iref;
    *Pproperty_Nt_rin=property_Nt_rin;
    *Pn_ref_noise_trans_rin=n_ref_noise_trans_rin;
    *Pn_ref_Nt_rin=n_ref_Nt_rin;
    *Pproperty_Nf=property_Nf;
    *Pproperty_Nf_L=property_Nf_L;
    *Pn_ref_Nf_L=n_ref_Nf_L;
    *Pproperty_Nf_W=property_Nf_W;
    *Pn_ref_Nf_W=n_ref_Nf_W;
    *Pproperty_Nf_iref=property_Nf_iref;
    *Pn_ref_Nf_iref=n_ref_Nf_iref;
    *Pproperty_Nf_rin=property_Nf_rin;
    *Pn_ref_Nf_rin=n_ref_Nf_rin;
    *Pproperty_fc=property_fc;
    *Pproperty_Area=property_Area;
    *Pparam_area_spacing=param_area_spacing;
    *Pproperty_Vos=property_Vos;
    *Pproperty_Power=property_Power;
    *Pproperty_PM=property_PM;
    *Pproperty_Cin=property_Cin;
    *Pcircuit_breed_id=circuit_breed_id;
    *Pcircuit_breed_target=circuit_breed_target;
    return TCL_OK;
}
static int tcl_gamma_op_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    //            Tcl_ResetResult(interp);
    out_V=vdd_V/2;
    in_V=param_in;
    mid_V=vdd_V/2;
    if(config_size_L!=0) size_L=config_size_L;
    if(config_size_W!=0) size_W=config_size_W;
    if(config_size_iref!=0) size_iref=config_size_iref;
    if(config_size_rin!=0) size_rin=config_size_rin;
    vdd_V=1.1;
    CONST_0_V=0;
    // Calculating circuit operating point:
    int op_it=0;
    status_fail=-1;
    design_feedback=1000;
    leak=1e3;
    float node_step=0;
    for (op_it=0;(op_it<config_op_iterations)&&((leak>config_kcl_th)||(design_feedback>config_design_feedback_th));op_it++) {
        float previous_out_dc=out_V;
        composite_gamma_gcc_interpolate_4(Plook_up_tables_nch_Ids_ss_LUT,Plook_up_tables_nch_gm_ss_LUT,Plook_up_tables_nch_ro_ss_LUT,&(n_ref_gm),&(n_ref_go),&(n_ref_Ids),(mid_V)-(CONST_0_V),(out_V)-(CONST_0_V),(CONST_0_V)-(CONST_0_V),size_L,size_W);
        Gds_in_mid=1.0/size_rin;
        if (n_ref_gm==0) n_ref_gm=1e-6;
        if (n_ref_go==0) n_ref_go=1e-6;
        // Updating node voltages
        leak=0;
        node_step=config_kcl_step*(0)/(Gds_in_mid);
        if (node_step<-0.02) node_step=-0.02;
        if (node_step>0.02) node_step=0.02;
        in_V+=node_step;
        if (fabs(0)>leak) leak=fabs(0);
        if (in_V<0) in_V=0;
        if (in_V>1.1) in_V=1.1;
        node_step=config_kcl_step*(0)/(Gds_in_mid);
        if (node_step<-0.02) node_step=-0.02;
        if (node_step>0.02) node_step=0.02;
        mid_V+=node_step;
        if (fabs(0)>leak) leak=fabs(0);
        if (mid_V<0) mid_V=0;
        if (mid_V>1.1) mid_V=1.1;
        node_step=config_kcl_step*(size_iref-n_ref_Ids)/(n_ref_go);
        if (node_step<-0.02) node_step=-0.02;
        if (node_step>0.02) node_step=0.02;
        out_V+=node_step;
        if (fabs(size_iref-n_ref_Ids)>leak) leak=fabs(size_iref-n_ref_Ids);
        if (out_V<0) out_V=0;
        if (out_V>1.1) out_V=1.1;
        design_feedback=0;
    }
    if (op_it>=config_op_iterations) {status_fail=1; return TCL_ERROR;}
    Det=(-(-Gds_in_mid*(-n_ref_go)));
    Ted=1/Det;
    property_Adc=Ted*((-(-Gds_in_mid)*n_ref_gm));
    property_CMRR=property_Adc;
    property_PSRR=Ted*((-(-0)));
    property_Adc=fabs(property_Adc);
    if ((property_Adc<1)&&(config_fail_on_properties)) {status_fail=2; return TCL_ERROR;}
    if (CONST_0_V>out_V) {status_fail=3; return TCL_ERROR;}
    n_ref_Nt_unit=gamma_gcc_interpolateg_4(P_look_up_tables_nch_thermal_noise_ss_LUT,mid_V,out_V,CONST_0_V,size_L,&n_ref_dNt_dvgs,&n_ref_dNt_dvds,&n_ref_dNt_dvbs,&n_ref_dNt_dl);
    n_ref_Nt=n_ref_Nt_unit*sqrt(n_ref_gm);
    if (!isfinite(n_ref_Nt))  {status_fail=5; return TCL_ERROR;}
    n_ref_Nf_unit=gamma_gcc_interpolateg_4(P_look_up_tables_nch_flicker_noise_ss_LUT,mid_V,out_V,CONST_0_V,size_L,&n_ref_dNf_dvgs,&n_ref_dNf_dvds,&n_ref_dNf_dvbs,&n_ref_dNf_dl);
    n_ref_Nf=n_ref_Nf_unit*n_ref_gm*n_ref_gm/(size_W*size_L);
    if (!isfinite(n_ref_Nf))  {status_fail=6; return TCL_ERROR;}
    property_Rout=fabs(((-(-Gds_in_mid)))*Ted);
    n_ref_cgs=0.66666*look_up_tables_nch_cox*size_L*size_W;
    if (!isfinite(n_ref_cgs))  {status_fail=7; return TCL_ERROR;}
    n_ref_cgs_out=0;
    n_ref_cgd=0.33333*look_up_tables_nch_cox*size_L*size_W;
    if (!isfinite(n_ref_cgd))  {status_fail=7; return TCL_ERROR;}
    n_ref_cgd_out=0;
    // Miller Effect
    n_ref_cgd_out=n_ref_cgd*(1+(n_ref_go)/n_ref_gm);
    n_ref_cgd*=1+n_ref_gm/(n_ref_go);
    s=-1;
    int BW_it;
    for (BW_it=0;BW_it<5;BW_it++)  s-=((-(-((Gds_in_mid+n_ref_cgs*s)+n_ref_cgd*s)*(-(n_ref_go+n_ref_cgd_out*s)))))/((-(-((n_ref_cgs+n_ref_cgd)*(-(n_ref_go+n_ref_cgd_out*s))+((Gds_in_mid+n_ref_cgs*s)+n_ref_cgd*s)*(-n_ref_cgd_out)))));
    property_BW_s=(-(-((n_ref_cgs+n_ref_cgd)*(-(n_ref_go+n_ref_cgd_out*s))+((Gds_in_mid+n_ref_cgs*s)+n_ref_cgd*s)*(-n_ref_cgd_out))));
    p1=-s;
    property_BW=fabs(p1/(2*3.141592656));
    if (!isfinite(property_BW))  {status_fail=8; return TCL_ERROR;}
    s-=1e3;
    for (BW_it=0;BW_it<20;BW_it++)  s-=(((-(-((Gds_in_mid+n_ref_cgs*s)+n_ref_cgd*s)*(-(n_ref_go+n_ref_cgd_out*s)))))*(s+p1-5e2))/(((-(-((n_ref_cgs+n_ref_cgd)*(-(n_ref_go+n_ref_cgd_out*s))+((Gds_in_mid+n_ref_cgs*s)+n_ref_cgd*s)*(-n_ref_cgd_out)))))*(s+p1-5e2)-((-(-((Gds_in_mid+n_ref_cgs*s)+n_ref_cgd*s)*(-(n_ref_go+n_ref_cgd_out*s))))));
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
    n_ref_noise_trans=Ted*((-(-Gds_in_mid)))/property_Adc;
    property_Nt=n_ref_noise_trans*n_ref_noise_trans*n_ref_Nt;
    property_Nt_L=2*n_ref_noise_trans*n_ref_noise_trans_L*n_ref_Nt+n_ref_noise_trans*n_ref_noise_trans*n_ref_Nt_L;
    property_Nt_W=2*n_ref_noise_trans*n_ref_noise_trans_W*n_ref_Nt+n_ref_noise_trans*n_ref_noise_trans*n_ref_Nt_W;
    property_Nt_iref=2*n_ref_noise_trans*n_ref_noise_trans_iref*n_ref_Nt+n_ref_noise_trans*n_ref_noise_trans*n_ref_Nt_iref;
    property_Nt_rin=2*n_ref_noise_trans*n_ref_noise_trans_rin*n_ref_Nt+n_ref_noise_trans*n_ref_noise_trans*n_ref_Nt_rin;
    property_Nf=n_ref_noise_trans*n_ref_noise_trans*n_ref_Nf;
    property_Nf_L=2*n_ref_noise_trans*n_ref_noise_trans_L*n_ref_Nf+n_ref_noise_trans*n_ref_noise_trans*n_ref_Nf_L;
    property_Nf_W=2*n_ref_noise_trans*n_ref_noise_trans_W*n_ref_Nf+n_ref_noise_trans*n_ref_noise_trans*n_ref_Nf_W;
    property_Nf_iref=2*n_ref_noise_trans*n_ref_noise_trans_iref*n_ref_Nf+n_ref_noise_trans*n_ref_noise_trans*n_ref_Nf_iref;
    property_Nf_rin=2*n_ref_noise_trans*n_ref_noise_trans_rin*n_ref_Nf+n_ref_noise_trans*n_ref_noise_trans*n_ref_Nf_rin;
    property_fc=property_Nf/property_Nt;
    property_Area=1e12*(size_W*(size_L+param_area_spacing));
    float single_transistor_vos;
    property_Vos=0;
    property_Vos=1e-3*sqrt(property_Vos);
    property_Power=0;
    property_Power+=fabs(n_ref_Ids*((out_V)-(CONST_0_V)));
    property_Adc=20*log10(fabs(property_Adc));
    property_CMRR=20*log10(fabs(property_CMRR));
    property_CMRR=property_Adc-property_CMRR;
    property_PSRR=20*log10(fabs(property_PSRR));
    property_PSRR=property_Adc-property_PSRR;
    if (max_Adc<property_Adc) max_Adc=property_Adc;
    PAT *p=(PAT *)Pcs_nmos_circuits_PAT;
    float sizes[6];
    sizes[0]=size_L;
    sizes[1]=size_W;
    sizes[2]=size_iref;
    sizes[3]=size_rin;
    sizes[4]=out_V;
    sizes[5]=mid_V;
    float properties[14];
    properties[0]=property_Adc;
    properties[1]=property_CMRR;
    properties[2]=property_PSRR;
    properties[3]=property_Rout;
    properties[4]=property_BW;
    properties[5]=property_PM;
    properties[6]=property_Cin;
    properties[7]=property_ts;
    properties[8]=property_Nt;
    properties[9]=property_Nf;
    properties[10]=property_fc;
    properties[11]=property_Vos;
    properties[12]=property_Area;
    properties[13]=property_Power;
    status_fail=10;
    add_pat_array(p,sizes,properties);
    return TCL_OK;
}
//      static int tcl_gamma_grad_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    //            Tcl_ResetResult(interp);
    //          GRAD_CODE_GOES_HERE
    //         return TCL_OK;
//    }
static int tcl_gamma_random_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    ClientData CD;
    PAT *p=(PAT *)Pcs_nmos_circuits_PAT;
    while (p->content->num_of<config_pat_size_target) {
        size_L=size_L_min+random()*(size_L_max-size_L_min)/RAND_MAX;
        size_W=size_L+random()*(size_W_max-size_L)/RAND_MAX;
        size_iref=size_iref_min+random()*(size_iref_max-size_iref_min)/RAND_MAX;
        size_rin=size_rin_min+random()*(size_rin_max-size_rin_min)/RAND_MAX;
        if (tcl_gamma_op_cmd(CD,NULL,0,NULL)==TCL_ERROR) continue;
    }
    return TCL_OK;
}
static int tcl_gamma_breed_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    ClientData CD;
    int i,viable;
    PAT *p=(PAT *)Pcs_nmos_circuits_PAT;
    int more_to_breed=1;
    while (more_to_breed&&(p->content->num_of<pat_size_target)) {
        more_to_breed=0;
        int sweep_size=p->content->num_of;
        for (i=0;i<sweep_size;i++) {
            if (p->content->content[i]->flags) continue;
            p->content->content[i]->flags=1;
            more_to_breed++;
            size_L=p->content->content[i]->sizes->content[0];
            size_W=p->content->content[i]->sizes->content[1];
            size_iref=p->content->content[i]->sizes->content[2];
            size_rin=p->content->content[i]->sizes->content[3];
            size_L=size_L+size_L_step;
            viable=1;
            if ((size_L>=size_L_min)&&(size_L<=size_L_max)) {
                tcl_gamma_op_cmd(CD,NULL,0,NULL);
            }
            size_L=size_L-2*size_L_step;
            viable=1;
            if ((size_L>=size_L_min)&&(size_L<=size_L_max)) {
                tcl_gamma_op_cmd(CD,NULL,0,NULL);
            }
            size_L=size_L+size_L_step;
            size_W=size_W+size_W_step;
            viable=1;
            if ((size_W>=size_L)&&(size_W<=size_W_max)) {
                tcl_gamma_op_cmd(CD,NULL,0,NULL);
            }
            size_W=size_W-2*size_W_step;
            viable=1;
            if ((size_W>=size_L)&&(size_W<=size_W_max)) {
                tcl_gamma_op_cmd(CD,NULL,0,NULL);
            }
            size_W=size_W+size_W_step;
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
            size_rin=size_rin+size_rin_step;
            viable=1;
            if ((size_rin>=size_rin_min)&&(size_rin<=size_rin_max)) {
                tcl_gamma_op_cmd(CD,NULL,0,NULL);
            }
            size_rin=size_rin-2*size_rin_step;
            viable=1;
            if ((size_rin>=size_rin_min)&&(size_rin<=size_rin_max)) {
                tcl_gamma_op_cmd(CD,NULL,0,NULL);
            }
            size_rin=size_rin+size_rin_step;
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
    PAT *p=(PAT *)Pcs_nmos_circuits_PAT;
    long int r;
    float step;
    while (1) {
        if (p->content->num_of>config_pat_size_target) break;
        int sweep_size=p->content->num_of;
        for (i=0;i<sweep_size;i++) {
            size_L=p->content->content[i]->sizes->content[0];
            size_W=p->content->content[i]->sizes->content[1];
            size_iref=p->content->content[i]->sizes->content[2];
            size_rin=p->content->content[i]->sizes->content[3];
            while (1) {
                step=(2.0*random()/RAND_MAX-1)*size_L_step;
                if (size_L+step<size_L_min) continue;
                if (size_L+step>size_L_max) continue;
                break;
            }
            size_L+=step;
            while (1) {
                step=(2.0*random()/RAND_MAX-1)*size_W_step;
                if (size_W+step<size_L) continue;
                if (size_W+step>size_W_max) continue;
                break;
            }
            size_W+=step;
            while (1) {
                step=(2.0*random()/RAND_MAX-1)*size_iref_step;
                if (size_iref+step<size_iref_min) continue;
                if (size_iref+step>size_iref_max) continue;
                break;
            }
            size_iref+=step;
            while (1) {
                step=(2.0*random()/RAND_MAX-1)*size_rin_step;
                if (size_rin+step<size_rin_min) continue;
                if (size_rin+step>size_rin_max) continue;
                break;
            }
            size_rin+=step;
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
    PAT *p=(PAT *)Pcs_nmos_circuits_PAT;
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
        size_L=p->content->content[i]->sizes->content[0];
        size_W=p->content->content[i]->sizes->content[1];
        size_iref=p->content->content[i]->sizes->content[2];
        size_rin=p->content->content[i]->sizes->content[3];
        while (1) {
            step=(2.0*random()/RAND_MAX-1)*size_L_step;
            if (size_L+step<size_L_min) continue;
            if (size_L+step>size_L_max) continue;
            break;
        }
        size_L+=step;
        while (1) {
            step=(2.0*random()/RAND_MAX-1)*size_W_step;
            if (size_W+step<size_L) continue;
            if (size_W+step>size_W_max) continue;
            break;
        }
        size_W+=step;
        while (1) {
            step=(2.0*random()/RAND_MAX-1)*size_iref_step;
            if (size_iref+step<size_iref_min) continue;
            if (size_iref+step>size_iref_max) continue;
            break;
        }
        size_iref+=step;
        while (1) {
            step=(2.0*random()/RAND_MAX-1)*size_rin_step;
            if (size_rin+step<size_rin_min) continue;
            if (size_rin+step>size_rin_max) continue;
            break;
        }
        size_rin+=step;
        if (tcl_gamma_op_cmd(CD,NULL,0,NULL)==TCL_ERROR) continue;
        if (p->content->num_of>=breed_count+circuit_breed_target) break;
    }
    return TCL_OK;
}
// Initializing cTree references and registering the tcl_gamma_op_cmd command as ::C::cs_nmos
int Gamma_Init(Tcl_Interp *interp) {
    if (Tcl_InitStubs(interp, TCL_VERSION, 0) == NULL) {
        return TCL_ERROR;
    }
    float *array_entry;
    context *c;
    Pcs_nmos_circuits_PAT=(float *)get_PAT("cs_nmos:circuits");
    c=create_context("config:pat_size_target");
    Pconfig_pat_size_target=(float *)(&c->value.s);
    c=create_context("size:L");
    Psize_L=(float *)(&c->value.s);
    c=create_context("size:L:min");
    Psize_L_min=(float *)(&c->value.s);
    c=create_context("size:L:max");
    Psize_L_max=(float *)(&c->value.s);
    c=create_context("size:W");
    Psize_W=(float *)(&c->value.s);
    c=create_context("size:W:max");
    Psize_W_max=(float *)(&c->value.s);
    c=create_context("size:iref");
    Psize_iref=(float *)(&c->value.s);
    c=create_context("size:iref:min");
    Psize_iref_min=(float *)(&c->value.s);
    c=create_context("size:iref:max");
    Psize_iref_max=(float *)(&c->value.s);
    c=create_context("size:rin");
    Psize_rin=(float *)(&c->value.s);
    c=create_context("size:rin:min");
    Psize_rin_min=(float *)(&c->value.s);
    c=create_context("size:rin:max");
    Psize_rin_max=(float *)(&c->value.s);
    c=create_context("size:L:step");
    Psize_L_step=(float *)(&c->value.s);
    c=create_context("size:W:step");
    Psize_W_step=(float *)(&c->value.s);
    c=create_context("size:iref:step");
    Psize_iref_step=(float *)(&c->value.s);
    c=create_context("size:rin:step");
    Psize_rin_step=(float *)(&c->value.s);
    c=create_context("max_Adc");
    Pmax_Adc=(float *)(&c->value.s);
    c=create_context("param:unique");
    Pparam_unique=(float *)(&c->value.s);
    c=create_context("pat_size_target");
    Ppat_size_target=(float *)(&c->value.s);
    c=create_context("out:V");
    Pout_V=(float *)(&c->value.s);
    c=create_context("vdd:V");
    Pvdd_V=(float *)(&c->value.s);
    c=create_context("in:V");
    Pin_V=(float *)(&c->value.s);
    c=create_context("param:in");
    Pparam_in=(float *)(&c->value.s);
    c=create_context("mid:V");
    Pmid_V=(float *)(&c->value.s);
    c=create_context("config:size:L");
    Pconfig_size_L=(float *)(&c->value.s);
    c=create_context("config:size:W");
    Pconfig_size_W=(float *)(&c->value.s);
    c=create_context("config:size:iref");
    Pconfig_size_iref=(float *)(&c->value.s);
    c=create_context("config:size:rin");
    Pconfig_size_rin=(float *)(&c->value.s);
    c=create_context("0:V");
    P0_V=(float *)(&c->value.s);
    c=create_context("status:fail");
    Pstatus_fail=(float *)(&c->value.s);
    c=create_context("design_feedback");
    Pdesign_feedback=(float *)(&c->value.s);
    c=create_context("leak");
    Pleak=(float *)(&c->value.s);
    c=create_context("config:op_iterations");
    Pconfig_op_iterations=(float *)(&c->value.s);
    c=create_context("config:kcl_th");
    Pconfig_kcl_th=(float *)(&c->value.s);
    c=create_context("config:design_feedback_th");
    Pconfig_design_feedback_th=(float *)(&c->value.s);
    Plook_up_tables_nch_Ids_ss_LUT=(float *)get_LUT("look_up_tables:nch:Ids:ss");
    Plook_up_tables_nch_gm_ss_LUT=(float *)get_LUT("look_up_tables:nch:gm:ss");
    Plook_up_tables_nch_ro_ss_LUT=(float *)get_LUT("look_up_tables:nch:ro:ss");
    c=create_context("n_ref:gm");
    Pn_ref_gm=(float *)(&c->value.s);
    c=create_context("n_ref:go");
    Pn_ref_go=(float *)(&c->value.s);
    c=create_context("n_ref:Ids");
    Pn_ref_Ids=(float *)(&c->value.s);
    c=create_context("Gds_in_mid");
    PGds_in_mid=(float *)(&c->value.s);
    c=create_context("config:kcl_step");
    Pconfig_kcl_step=(float *)(&c->value.s);
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
    c=create_context("n_ref:Nt_unit");
    Pn_ref_Nt_unit=(float *)(&c->value.s);
    P_look_up_tables_nch_thermal_noise_ss_LUT=(float *)get_LUT(":look_up_tables:nch:thermal_noise:ss");
    c=create_context("n_ref:dNt_dvgs");
    Pn_ref_dNt_dvgs=(float *)(&c->value.s);
    c=create_context("n_ref:dNt_dvds");
    Pn_ref_dNt_dvds=(float *)(&c->value.s);
    c=create_context("n_ref:dNt_dvbs");
    Pn_ref_dNt_dvbs=(float *)(&c->value.s);
    c=create_context("n_ref:dNt_dl");
    Pn_ref_dNt_dl=(float *)(&c->value.s);
    c=create_context("n_ref:Nt");
    Pn_ref_Nt=(float *)(&c->value.s);
    c=create_context("n_ref:Nf_unit");
    Pn_ref_Nf_unit=(float *)(&c->value.s);
    P_look_up_tables_nch_flicker_noise_ss_LUT=(float *)get_LUT(":look_up_tables:nch:flicker_noise:ss");
    c=create_context("n_ref:dNf_dvgs");
    Pn_ref_dNf_dvgs=(float *)(&c->value.s);
    c=create_context("n_ref:dNf_dvds");
    Pn_ref_dNf_dvds=(float *)(&c->value.s);
    c=create_context("n_ref:dNf_dvbs");
    Pn_ref_dNf_dvbs=(float *)(&c->value.s);
    c=create_context("n_ref:dNf_dl");
    Pn_ref_dNf_dl=(float *)(&c->value.s);
    c=create_context("n_ref:Nf");
    Pn_ref_Nf=(float *)(&c->value.s);
    c=create_context("property:Rout");
    Pproperty_Rout=(float *)(&c->value.s);
    c=create_context("n_ref:cgs");
    Pn_ref_cgs=(float *)(&c->value.s);
    c=create_context("look_up_tables:nch:cox");
    Plook_up_tables_nch_cox=(float *)(&c->value.s);
    c=create_context("n_ref:cgs_out");
    Pn_ref_cgs_out=(float *)(&c->value.s);
    c=create_context("n_ref:cgd");
    Pn_ref_cgd=(float *)(&c->value.s);
    c=create_context("n_ref:cgd_out");
    Pn_ref_cgd_out=(float *)(&c->value.s);
    c=create_context("s");
    Ps=(float *)(&c->value.s);
    c=create_context("property:BW:s");
    Pproperty_BW_s=(float *)(&c->value.s);
    c=create_context("p1");
    Pp1=(float *)(&c->value.s);
    c=create_context("property:BW");
    Pproperty_BW=(float *)(&c->value.s);
    c=create_context("p2");
    Pp2=(float *)(&c->value.s);
    c=create_context("property:ts");
    Pproperty_ts=(float *)(&c->value.s);
    c=create_context("n_ref:noise_trans");
    Pn_ref_noise_trans=(float *)(&c->value.s);
    c=create_context("property:Nt");
    Pproperty_Nt=(float *)(&c->value.s);
    c=create_context("property:Nt:L");
    Pproperty_Nt_L=(float *)(&c->value.s);
    c=create_context("n_ref:noise_trans:L");
    Pn_ref_noise_trans_L=(float *)(&c->value.s);
    c=create_context("n_ref:Nt:L");
    Pn_ref_Nt_L=(float *)(&c->value.s);
    c=create_context("property:Nt:W");
    Pproperty_Nt_W=(float *)(&c->value.s);
    c=create_context("n_ref:noise_trans:W");
    Pn_ref_noise_trans_W=(float *)(&c->value.s);
    c=create_context("n_ref:Nt:W");
    Pn_ref_Nt_W=(float *)(&c->value.s);
    c=create_context("property:Nt:iref");
    Pproperty_Nt_iref=(float *)(&c->value.s);
    c=create_context("n_ref:noise_trans:iref");
    Pn_ref_noise_trans_iref=(float *)(&c->value.s);
    c=create_context("n_ref:Nt:iref");
    Pn_ref_Nt_iref=(float *)(&c->value.s);
    c=create_context("property:Nt:rin");
    Pproperty_Nt_rin=(float *)(&c->value.s);
    c=create_context("n_ref:noise_trans:rin");
    Pn_ref_noise_trans_rin=(float *)(&c->value.s);
    c=create_context("n_ref:Nt:rin");
    Pn_ref_Nt_rin=(float *)(&c->value.s);
    c=create_context("property:Nf");
    Pproperty_Nf=(float *)(&c->value.s);
    c=create_context("property:Nf:L");
    Pproperty_Nf_L=(float *)(&c->value.s);
    c=create_context("n_ref:Nf:L");
    Pn_ref_Nf_L=(float *)(&c->value.s);
    c=create_context("property:Nf:W");
    Pproperty_Nf_W=(float *)(&c->value.s);
    c=create_context("n_ref:Nf:W");
    Pn_ref_Nf_W=(float *)(&c->value.s);
    c=create_context("property:Nf:iref");
    Pproperty_Nf_iref=(float *)(&c->value.s);
    c=create_context("n_ref:Nf:iref");
    Pn_ref_Nf_iref=(float *)(&c->value.s);
    c=create_context("property:Nf:rin");
    Pproperty_Nf_rin=(float *)(&c->value.s);
    c=create_context("n_ref:Nf:rin");
    Pn_ref_Nf_rin=(float *)(&c->value.s);
    c=create_context("property:fc");
    Pproperty_fc=(float *)(&c->value.s);
    c=create_context("property:Area");
    Pproperty_Area=(float *)(&c->value.s);
    c=create_context("param:area_spacing");
    Pparam_area_spacing=(float *)(&c->value.s);
    c=create_context("property:Vos");
    Pproperty_Vos=(float *)(&c->value.s);
    c=create_context("property:Power");
    Pproperty_Power=(float *)(&c->value.s);
    c=create_context("property:PM");
    Pproperty_PM=(float *)(&c->value.s);
    c=create_context("property:Cin");
    Pproperty_Cin=(float *)(&c->value.s);
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
