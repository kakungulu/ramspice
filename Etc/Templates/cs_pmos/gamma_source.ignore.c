#include <tcl.h>
#include <stdio.h>
#include <stdlib.h>
#include "ctree.h"
#include "look_up_table.h"
// Some global pointers to keep reference of the contexts this object manipulates
float *Pcs_pmos_circuits_PAT;
float *Pconfig_pat_size_target;
float *Psize_L;
float *Psize_L_min;
float *Psize_L_max;
float *Psize_W;
float *Psize_W_max;
float *Psize_iref;
float *Psize_iref_min;
float *Psize_iref_max;
float *Psize_L_step;
float *Psize_W_step;
float *Psize_iref_step;
float *Pmax_Adc;
float *Pparam_unique;
float *Ppat_size_target;
float *Pout_V;
float *Pvdd_V;
float *Pin_V;
float *Pparam_in;
float *P0_V;
float *Pconfig_op_iterations;
float *Pconfig_kcl_th;
float *Plook_up_tables_pch_Ids_ss_LUT;
float *Plook_up_tables_pch_gm_ss_LUT;
float *Plook_up_tables_pch_ro_ss_LUT;
float *Ppin_gm;
float *Ppin_go;
float *Ppin_Ids;
float *PDet;
float *PTed;
float *Ppin_Nt_unit;
float *P_look_up_tables_pch_thermal_noise_ss_LUT;
float *Ppin_dNt_dvgs;
float *Ppin_dNt_dvds;
float *Ppin_dNt_dvbs;
float *Ppin_dNt_dl;
float *Ppin_Nt;
float *Ppin_Nf_unit;
float *P_look_up_tables_pch_flicker_noise_ss_LUT;
float *Ppin_dNf_dvgs;
float *Ppin_dNf_dvds;
float *Ppin_dNf_dvbs;
float *Ppin_dNf_dl;
float *Ppin_Nf;
float *Pproperty_Adc;
float *Pproperty_CMRR;
float *Pproperty_PSRR;
float *Pproperty_Rout;
float *Ppin_cgs;
float *Plook_up_tables_pch_cox;
float *Ppin_cgs_out;
float *Ppin_cgd;
float *Ppin_cgd_out;
float *Ps;
float *Pproperty_BW_s;
float *Pp1;
float *Pproperty_BW;
float *Pp2;
float *Pproperty_ts;
float *Pproperty_Cin;
float *Pproperty_PM;
float *Ppin_noise_trans;
float *Pproperty_Nt;
float *Pproperty_Nt_L;
float *Ppin_noise_trans_L;
float *Ppin_Nt_L;
float *Pproperty_Nt_W;
float *Ppin_noise_trans_W;
float *Ppin_Nt_W;
float *Pproperty_Nt_iref;
float *Ppin_noise_trans_iref;
float *Ppin_Nt_iref;
float *Pproperty_Nf;
float *Pproperty_Nf_L;
float *Ppin_Nf_L;
float *Pproperty_Nf_W;
float *Ppin_Nf_W;
float *Pproperty_Nf_iref;
float *Ppin_Nf_iref;
float *Pproperty_fc;
float *Pproperty_Area;
float *Pparam_area_spacing;
float *Pproperty_Vos;
float *Pproperty_Power;
float *Pcircuit_breed_id;
float *Pcircuit_breed_target;
float cs_pmos_circuits_PAT;
float config_pat_size_target;
float size_L;
float size_L_min;
float size_L_max;
float size_W;
float size_W_max;
float size_iref;
float size_iref_min;
float size_iref_max;
float size_L_step;
float size_W_step;
float size_iref_step;
float max_Adc;
float param_unique;
float pat_size_target;
float out_V;
float vdd_V;
float in_V;
float param_in;
float CONST_0_V;
float config_op_iterations;
float config_kcl_th;
float look_up_tables_pch_Ids_ss_LUT;
float look_up_tables_pch_gm_ss_LUT;
float look_up_tables_pch_ro_ss_LUT;
float pin_gm;
float pin_go;
float pin_Ids;
float Det;
float Ted;
float pin_Nt_unit;
float _look_up_tables_pch_thermal_noise_ss_LUT;
float pin_dNt_dvgs;
float pin_dNt_dvds;
float pin_dNt_dvbs;
float pin_dNt_dl;
float pin_Nt;
float pin_Nf_unit;
float _look_up_tables_pch_flicker_noise_ss_LUT;
float pin_dNf_dvgs;
float pin_dNf_dvds;
float pin_dNf_dvbs;
float pin_dNf_dl;
float pin_Nf;
float property_Adc;
float property_CMRR;
float property_PSRR;
float property_Rout;
float pin_cgs;
float look_up_tables_pch_cox;
float pin_cgs_out;
float pin_cgd;
float pin_cgd_out;
float s;
float property_BW_s;
float p1;
float property_BW;
float p2;
float property_ts;
float property_Cin;
float property_PM;
float pin_noise_trans;
float property_Nt;
float property_Nt_L;
float pin_noise_trans_L;
float pin_Nt_L;
float property_Nt_W;
float pin_noise_trans_W;
float pin_Nt_W;
float property_Nt_iref;
float pin_noise_trans_iref;
float pin_Nt_iref;
float property_Nf;
float property_Nf_L;
float pin_Nf_L;
float property_Nf_W;
float pin_Nf_W;
float property_Nf_iref;
float pin_Nf_iref;
float property_fc;
float property_Area;
float param_area_spacing;
float property_Vos;
float property_Power;
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
    size_L_step=*Psize_L_step;
    size_W_step=*Psize_W_step;
    size_iref_step=*Psize_iref_step;
    max_Adc=*Pmax_Adc;
    param_unique=*Pparam_unique;
    pat_size_target=*Ppat_size_target;
    out_V=*Pout_V;
    vdd_V=*Pvdd_V;
    in_V=*Pin_V;
    param_in=*Pparam_in;
    CONST_0_V=*P0_V;
    config_op_iterations=*Pconfig_op_iterations;
    config_kcl_th=*Pconfig_kcl_th;
    pin_gm=*Ppin_gm;
    pin_go=*Ppin_go;
    pin_Ids=*Ppin_Ids;
    Det=*PDet;
    Ted=*PTed;
    pin_Nt_unit=*Ppin_Nt_unit;
    pin_dNt_dvgs=*Ppin_dNt_dvgs;
    pin_dNt_dvds=*Ppin_dNt_dvds;
    pin_dNt_dvbs=*Ppin_dNt_dvbs;
    pin_dNt_dl=*Ppin_dNt_dl;
    pin_Nt=*Ppin_Nt;
    pin_Nf_unit=*Ppin_Nf_unit;
    pin_dNf_dvgs=*Ppin_dNf_dvgs;
    pin_dNf_dvds=*Ppin_dNf_dvds;
    pin_dNf_dvbs=*Ppin_dNf_dvbs;
    pin_dNf_dl=*Ppin_dNf_dl;
    pin_Nf=*Ppin_Nf;
    property_Adc=*Pproperty_Adc;
    property_CMRR=*Pproperty_CMRR;
    property_PSRR=*Pproperty_PSRR;
    property_Rout=*Pproperty_Rout;
    pin_cgs=*Ppin_cgs;
    look_up_tables_pch_cox=*Plook_up_tables_pch_cox;
    pin_cgs_out=*Ppin_cgs_out;
    pin_cgd=*Ppin_cgd;
    pin_cgd_out=*Ppin_cgd_out;
    s=*Ps;
    property_BW_s=*Pproperty_BW_s;
    p1=*Pp1;
    property_BW=*Pproperty_BW;
    p2=*Pp2;
    property_ts=*Pproperty_ts;
    property_Cin=*Pproperty_Cin;
    property_PM=*Pproperty_PM;
    pin_noise_trans=*Ppin_noise_trans;
    property_Nt=*Pproperty_Nt;
    property_Nt_L=*Pproperty_Nt_L;
    pin_noise_trans_L=*Ppin_noise_trans_L;
    pin_Nt_L=*Ppin_Nt_L;
    property_Nt_W=*Pproperty_Nt_W;
    pin_noise_trans_W=*Ppin_noise_trans_W;
    pin_Nt_W=*Ppin_Nt_W;
    property_Nt_iref=*Pproperty_Nt_iref;
    pin_noise_trans_iref=*Ppin_noise_trans_iref;
    pin_Nt_iref=*Ppin_Nt_iref;
    property_Nf=*Pproperty_Nf;
    property_Nf_L=*Pproperty_Nf_L;
    pin_Nf_L=*Ppin_Nf_L;
    property_Nf_W=*Pproperty_Nf_W;
    pin_Nf_W=*Ppin_Nf_W;
    property_Nf_iref=*Pproperty_Nf_iref;
    pin_Nf_iref=*Ppin_Nf_iref;
    property_fc=*Pproperty_fc;
    property_Area=*Pproperty_Area;
    param_area_spacing=*Pparam_area_spacing;
    property_Vos=*Pproperty_Vos;
    property_Power=*Pproperty_Power;
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
    *Psize_L_step=size_L_step;
    *Psize_W_step=size_W_step;
    *Psize_iref_step=size_iref_step;
    *Pmax_Adc=max_Adc;
    *Pparam_unique=param_unique;
    *Ppat_size_target=pat_size_target;
    *Pout_V=out_V;
    *Pvdd_V=vdd_V;
    *Pin_V=in_V;
    *Pparam_in=param_in;
    *P0_V=CONST_0_V;
    *Pconfig_op_iterations=config_op_iterations;
    *Pconfig_kcl_th=config_kcl_th;
    *Ppin_gm=pin_gm;
    *Ppin_go=pin_go;
    *Ppin_Ids=pin_Ids;
    *PDet=Det;
    *PTed=Ted;
    *Ppin_Nt_unit=pin_Nt_unit;
    *Ppin_dNt_dvgs=pin_dNt_dvgs;
    *Ppin_dNt_dvds=pin_dNt_dvds;
    *Ppin_dNt_dvbs=pin_dNt_dvbs;
    *Ppin_dNt_dl=pin_dNt_dl;
    *Ppin_Nt=pin_Nt;
    *Ppin_Nf_unit=pin_Nf_unit;
    *Ppin_dNf_dvgs=pin_dNf_dvgs;
    *Ppin_dNf_dvds=pin_dNf_dvds;
    *Ppin_dNf_dvbs=pin_dNf_dvbs;
    *Ppin_dNf_dl=pin_dNf_dl;
    *Ppin_Nf=pin_Nf;
    *Pproperty_Adc=property_Adc;
    *Pproperty_CMRR=property_CMRR;
    *Pproperty_PSRR=property_PSRR;
    *Pproperty_Rout=property_Rout;
    *Ppin_cgs=pin_cgs;
    *Plook_up_tables_pch_cox=look_up_tables_pch_cox;
    *Ppin_cgs_out=pin_cgs_out;
    *Ppin_cgd=pin_cgd;
    *Ppin_cgd_out=pin_cgd_out;
    *Ps=s;
    *Pproperty_BW_s=property_BW_s;
    *Pp1=p1;
    *Pproperty_BW=property_BW;
    *Pp2=p2;
    *Pproperty_ts=property_ts;
    *Pproperty_Cin=property_Cin;
    *Pproperty_PM=property_PM;
    *Ppin_noise_trans=pin_noise_trans;
    *Pproperty_Nt=property_Nt;
    *Pproperty_Nt_L=property_Nt_L;
    *Ppin_noise_trans_L=pin_noise_trans_L;
    *Ppin_Nt_L=pin_Nt_L;
    *Pproperty_Nt_W=property_Nt_W;
    *Ppin_noise_trans_W=pin_noise_trans_W;
    *Ppin_Nt_W=pin_Nt_W;
    *Pproperty_Nt_iref=property_Nt_iref;
    *Ppin_noise_trans_iref=pin_noise_trans_iref;
    *Ppin_Nt_iref=pin_Nt_iref;
    *Pproperty_Nf=property_Nf;
    *Pproperty_Nf_L=property_Nf_L;
    *Ppin_Nf_L=pin_Nf_L;
    *Pproperty_Nf_W=property_Nf_W;
    *Ppin_Nf_W=pin_Nf_W;
    *Pproperty_Nf_iref=property_Nf_iref;
    *Ppin_Nf_iref=pin_Nf_iref;
    *Pproperty_fc=property_fc;
    *Pproperty_Area=property_Area;
    *Pparam_area_spacing=param_area_spacing;
    *Pproperty_Vos=property_Vos;
    *Pproperty_Power=property_Power;
    *Pcircuit_breed_id=circuit_breed_id;
    *Pcircuit_breed_target=circuit_breed_target;
    return TCL_OK;
}
static int tcl_gamma_op_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    //            Tcl_ResetResult(interp);
    out_V=vdd_V/2;
    in_V=param_in;
    vdd_V=1.1;
    CONST_0_V=0;
    // Calculating circuit operating point:
    int op_it=0;
    float leak=1e3;
    float node_step=0;
    for (op_it=0;(op_it<config_op_iterations)&&(leak>config_kcl_th);op_it++) {
        if (op_it>100) return TCL_ERROR;
        float previous_out_dc=out_V;
        composite_gamma_gcc_interpolate_4(Plook_up_tables_pch_Ids_ss_LUT,Plook_up_tables_pch_gm_ss_LUT,Plook_up_tables_pch_ro_ss_LUT,&(pin_gm),&(pin_go),&(pin_Ids),(in_V)-(vdd_V),(out_V)-(vdd_V),(vdd_V)-(vdd_V),size_L,size_W);
        pin_Ids=-pin_Ids;
        if (pin_gm==0) pin_gm=1e-6;
        if (pin_go==0) pin_go=1e-6;
        // Updating node voltages
        leak=0;
        node_step=0.1*(-size_iref-pin_Ids)/(pin_go);
        if (node_step<-0.1) node_step=-0.1;
        if (node_step>0.1) node_step=0.1;
        out_V+=node_step;
        leak+=fabs(-size_iref-pin_Ids);
        if (out_V<0) out_V=0;
        if (out_V>1.1) out_V=1.1;
    }
    Det=(-pin_go);
    Ted=1/Det;
    if (!isfinite(out_V)) return TCL_ERROR;
    if (out_V==0) return TCL_ERROR;
    if (out_V==1.1) return TCL_ERROR;
    if (vdd_V<out_V) return TCL_ERROR;
    pin_Nt_unit=gamma_gcc_interpolateg_4(P_look_up_tables_pch_thermal_noise_ss_LUT,(in_V-vdd_V),(out_V-vdd_V),0,size_L,&pin_dNt_dvgs,&pin_dNt_dvds,&pin_dNt_dvbs,&pin_dNt_dl);
    pin_Nt=pin_Nt_unit*sqrt(pin_gm);
    if (!isfinite(pin_Nt))  return TCL_ERROR;
    pin_Nf_unit=gamma_gcc_interpolateg_4(P_look_up_tables_pch_flicker_noise_ss_LUT,(in_V-vdd_V),(out_V-vdd_V),0,size_L,&pin_dNf_dvgs,&pin_dNf_dvds,&pin_dNf_dvbs,&pin_dNf_dl);
    pin_Nf=pin_Nf_unit*pin_gm*pin_gm/(size_W*size_L);
    if (!isfinite(pin_Nf))  return TCL_ERROR;
    property_Adc=Ted*(pin_gm);
    property_CMRR=property_Adc;
    property_PSRR=Ted*(((-pin_go)-pin_gm));
    property_Adc=fabs(property_Adc);
    if (property_Adc<1) return TCL_ERROR;
    property_Rout=fabs(((-(-1)))*Ted);
    pin_cgs=0.66666*look_up_tables_pch_cox*size_L*size_W;
    if (!isfinite(pin_cgs))  return TCL_ERROR;
    pin_cgs_out=0;
    pin_cgd=0.33333*look_up_tables_pch_cox*size_L*size_W;
    if (!isfinite(pin_cgd))  return TCL_ERROR;
    pin_cgd_out=0;
    // Miller Effect
    pin_cgd_out=pin_cgd*(1+(pin_go)/pin_gm);
    pin_cgd*=1+pin_gm/(pin_go);
    s=-1;
    int BW_it;
    for (BW_it=0;BW_it<5;BW_it++)  s-=((-(pin_go+pin_cgd_out*s)))/((-pin_cgd_out));
    property_BW_s=(-pin_cgd_out);
    p1=-s;
    property_BW=p1/(2*3.141592656);
    if (!isfinite(property_BW))  return TCL_ERROR;
    if (property_BW<0)  return TCL_ERROR;
    s-=1e3;
    for (BW_it=0;BW_it<20;BW_it++)  s-=(((-(pin_go+pin_cgd_out*s)))*(s+p1-5e2))/(((-pin_cgd_out))*(s+p1-5e2)-((-(pin_go+pin_cgd_out*s))));
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
    property_Cin=pin_cgd+pin_cgs;
    property_PM=(property_BW/9.76e8)+(property_Adc-21)-sqrt(size_L*size_W)/5e-7-size_iref*2.5e4;
    property_PM=(property_PM*180/3.1415)/2.16+29-1.4-0.75/2;
    while (property_PM<0) property_PM+=360;
    while (property_PM>360) property_PM-=360;
    pin_noise_trans=Ted*((-(-1)))/property_Adc;
    property_Nt=pin_noise_trans*pin_noise_trans*pin_Nt;
    property_Nt_L=2*pin_noise_trans*pin_noise_trans_L*pin_Nt+pin_noise_trans*pin_noise_trans*pin_Nt_L;
    property_Nt_W=2*pin_noise_trans*pin_noise_trans_W*pin_Nt+pin_noise_trans*pin_noise_trans*pin_Nt_W;
    property_Nt_iref=2*pin_noise_trans*pin_noise_trans_iref*pin_Nt+pin_noise_trans*pin_noise_trans*pin_Nt_iref;
    property_Nf=pin_noise_trans*pin_noise_trans*pin_Nf;
    property_Nf_L=2*pin_noise_trans*pin_noise_trans_L*pin_Nf+pin_noise_trans*pin_noise_trans*pin_Nf_L;
    property_Nf_W=2*pin_noise_trans*pin_noise_trans_W*pin_Nf+pin_noise_trans*pin_noise_trans*pin_Nf_W;
    property_Nf_iref=2*pin_noise_trans*pin_noise_trans_iref*pin_Nf+pin_noise_trans*pin_noise_trans*pin_Nf_iref;
    property_fc=property_Nf/property_Nt;
    property_Area=1e12*(size_W*(size_L+param_area_spacing));
    float single_transistor_vos;
    property_Vos=0;
    single_transistor_vos=vos(-pin_Ids*size_L/size_W);
    property_Vos+=single_transistor_vos*single_transistor_vos;
    property_Vos=1e-3*sqrt(property_Vos);
    property_Power=0;
    property_Power+=fabs(pin_Ids*((out_V)-(vdd_V)));
    property_Adc=20*log10(fabs(property_Adc));
    property_CMRR=20*log10(fabs(property_CMRR));
    property_CMRR=property_Adc-property_CMRR;
    property_PSRR=20*log10(fabs(property_PSRR));
    property_PSRR=property_Adc-property_PSRR;
    if (max_Adc<property_Adc) max_Adc=property_Adc;
    PAT *p=(PAT *)Pcs_pmos_circuits_PAT;
    float sizes[4];
    sizes[0]=size_L;
    sizes[1]=size_W;
    sizes[2]=size_iref;
    sizes[3]=out_V;
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
    PAT *p=(PAT *)Pcs_pmos_circuits_PAT;
    while (p->content->num_of<config_pat_size_target) {
        printf("PAT size=%d/%d\n",p->content->num_of,config_pat_size_target);
        size_L=size_L_min+random()*(size_L_max-size_L_min)/RAND_MAX;
        size_W=size_L+random()*(size_W_max-size_L)/RAND_MAX;
        size_iref=size_iref_min+random()*(size_iref_max-size_iref_min)/RAND_MAX;
        if (tcl_gamma_op_cmd(CD,NULL,0,NULL)==TCL_ERROR) continue;
    }
    return TCL_OK;
}
static int tcl_gamma_breed_cmd(ClientData clientData,Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    ClientData CD;
    int i,viable;
    PAT *p=(PAT *)Pcs_pmos_circuits_PAT;
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
    int i;
    PAT *p=(PAT *)Pcs_pmos_circuits_PAT;
    long int r;
    float step;
    while (1) {
        if (p->content->num_of>config_pat_size_target) break;
        int sweep_size=p->content->num_of;
        for (i=0;i<sweep_size;i++) {
            size_L=p->content->content[i]->sizes->content[0];
            size_W=p->content->content[i]->sizes->content[1];
            size_iref=p->content->content[i]->sizes->content[2];
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
    PAT *p=(PAT *)Pcs_pmos_circuits_PAT;
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
        if (tcl_gamma_op_cmd(CD,NULL,0,NULL)==TCL_ERROR) continue;
        if (p->content->num_of>=breed_count+circuit_breed_target) break;
    }
    return TCL_OK;
}
// Initializing cTree references and registering the tcl_gamma_op_cmd command as ::C::cs_pmos
int Gamma_Init(Tcl_Interp *interp) {
    if (Tcl_InitStubs(interp, TCL_VERSION, 0) == NULL) {
        return TCL_ERROR;
    }
    float *array_entry;
    context *c;
    Pcs_pmos_circuits_PAT=(float *)get_PAT("cs_pmos:circuits");
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
    c=create_context("size:L:step");
    Psize_L_step=(float *)(&c->value.s);
    c=create_context("size:W:step");
    Psize_W_step=(float *)(&c->value.s);
    c=create_context("size:iref:step");
    Psize_iref_step=(float *)(&c->value.s);
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
    c=create_context("0:V");
    P0_V=(float *)(&c->value.s);
    c=create_context("config:op_iterations");
    Pconfig_op_iterations=(float *)(&c->value.s);
    c=create_context("config:kcl_th");
    Pconfig_kcl_th=(float *)(&c->value.s);
    Plook_up_tables_pch_Ids_ss_LUT=(float *)get_LUT("look_up_tables:pch:Ids:ss");
    Plook_up_tables_pch_gm_ss_LUT=(float *)get_LUT("look_up_tables:pch:gm:ss");
    Plook_up_tables_pch_ro_ss_LUT=(float *)get_LUT("look_up_tables:pch:ro:ss");
    c=create_context("pin:gm");
    Ppin_gm=(float *)(&c->value.s);
    c=create_context("pin:go");
    Ppin_go=(float *)(&c->value.s);
    c=create_context("pin:Ids");
    Ppin_Ids=(float *)(&c->value.s);
    c=create_context("Det");
    PDet=(float *)(&c->value.s);
    c=create_context("Ted");
    PTed=(float *)(&c->value.s);
    c=create_context("pin:Nt_unit");
    Ppin_Nt_unit=(float *)(&c->value.s);
    P_look_up_tables_pch_thermal_noise_ss_LUT=(float *)get_LUT(":look_up_tables:pch:thermal_noise:ss");
    c=create_context("pin:dNt_dvgs");
    Ppin_dNt_dvgs=(float *)(&c->value.s);
    c=create_context("pin:dNt_dvds");
    Ppin_dNt_dvds=(float *)(&c->value.s);
    c=create_context("pin:dNt_dvbs");
    Ppin_dNt_dvbs=(float *)(&c->value.s);
    c=create_context("pin:dNt_dl");
    Ppin_dNt_dl=(float *)(&c->value.s);
    c=create_context("pin:Nt");
    Ppin_Nt=(float *)(&c->value.s);
    c=create_context("pin:Nf_unit");
    Ppin_Nf_unit=(float *)(&c->value.s);
    P_look_up_tables_pch_flicker_noise_ss_LUT=(float *)get_LUT(":look_up_tables:pch:flicker_noise:ss");
    c=create_context("pin:dNf_dvgs");
    Ppin_dNf_dvgs=(float *)(&c->value.s);
    c=create_context("pin:dNf_dvds");
    Ppin_dNf_dvds=(float *)(&c->value.s);
    c=create_context("pin:dNf_dvbs");
    Ppin_dNf_dvbs=(float *)(&c->value.s);
    c=create_context("pin:dNf_dl");
    Ppin_dNf_dl=(float *)(&c->value.s);
    c=create_context("pin:Nf");
    Ppin_Nf=(float *)(&c->value.s);
    c=create_context("property:Adc");
    Pproperty_Adc=(float *)(&c->value.s);
    c=create_context("property:CMRR");
    Pproperty_CMRR=(float *)(&c->value.s);
    c=create_context("property:PSRR");
    Pproperty_PSRR=(float *)(&c->value.s);
    c=create_context("property:Rout");
    Pproperty_Rout=(float *)(&c->value.s);
    c=create_context("pin:cgs");
    Ppin_cgs=(float *)(&c->value.s);
    c=create_context("look_up_tables:pch:cox");
    Plook_up_tables_pch_cox=(float *)(&c->value.s);
    c=create_context("pin:cgs_out");
    Ppin_cgs_out=(float *)(&c->value.s);
    c=create_context("pin:cgd");
    Ppin_cgd=(float *)(&c->value.s);
    c=create_context("pin:cgd_out");
    Ppin_cgd_out=(float *)(&c->value.s);
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
    c=create_context("property:Cin");
    Pproperty_Cin=(float *)(&c->value.s);
    c=create_context("property:PM");
    Pproperty_PM=(float *)(&c->value.s);
    c=create_context("pin:noise_trans");
    Ppin_noise_trans=(float *)(&c->value.s);
    c=create_context("property:Nt");
    Pproperty_Nt=(float *)(&c->value.s);
    c=create_context("property:Nt:L");
    Pproperty_Nt_L=(float *)(&c->value.s);
    c=create_context("pin:noise_trans:L");
    Ppin_noise_trans_L=(float *)(&c->value.s);
    c=create_context("pin:Nt:L");
    Ppin_Nt_L=(float *)(&c->value.s);
    c=create_context("property:Nt:W");
    Pproperty_Nt_W=(float *)(&c->value.s);
    c=create_context("pin:noise_trans:W");
    Ppin_noise_trans_W=(float *)(&c->value.s);
    c=create_context("pin:Nt:W");
    Ppin_Nt_W=(float *)(&c->value.s);
    c=create_context("property:Nt:iref");
    Pproperty_Nt_iref=(float *)(&c->value.s);
    c=create_context("pin:noise_trans:iref");
    Ppin_noise_trans_iref=(float *)(&c->value.s);
    c=create_context("pin:Nt:iref");
    Ppin_Nt_iref=(float *)(&c->value.s);
    c=create_context("property:Nf");
    Pproperty_Nf=(float *)(&c->value.s);
    c=create_context("property:Nf:L");
    Pproperty_Nf_L=(float *)(&c->value.s);
    c=create_context("pin:Nf:L");
    Ppin_Nf_L=(float *)(&c->value.s);
    c=create_context("property:Nf:W");
    Pproperty_Nf_W=(float *)(&c->value.s);
    c=create_context("pin:Nf:W");
    Ppin_Nf_W=(float *)(&c->value.s);
    c=create_context("property:Nf:iref");
    Pproperty_Nf_iref=(float *)(&c->value.s);
    c=create_context("pin:Nf:iref");
    Ppin_Nf_iref=(float *)(&c->value.s);
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
