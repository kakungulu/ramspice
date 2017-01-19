
        #include <tcl.h>
        #include <stdio.h>
        #include <stdlib.h>
        #include "Gamma/Data/ctree.h"
        #include "Gamma/LUT/look_up_table.h"
        #include "Gamma/Web/heatmap/heatmap.h"
        // Some global pointers to keep reference of the contexts this object manipulates
        float *Pparam_iref;
float *Pparam_rload;
float *Pparam_in;
float *Pparam_vdd;
float *Psize_L;
float *Psize_W;
float *Psize_iref;
float *Psize_rin;
float *Pproperty_Adc;
float *Pproperty_CMRR;
float *Pcs_nmos_circuits_PAT;
float *Pcs_nmos_config_pat_size_target;
float *Psize_L_min;
float *Psize_L_max;
float *Pcs_nmos_size_L;
float *Psize_W_max;
float *Pcs_nmos_size_W;
float *Psize_iref_min;
float *Psize_iref_max;
float *Pcs_nmos_size_iref;
float *Psize_rin_min;
float *Psize_rin_max;
float *Pcs_nmos_size_rin;
float *Psize_L_step;
float *Psize_W_step;
float *Psize_iref_step;
float *Psize_rin_step;
float *Pcs_nmos_max_Adc;
float *Pcs_nmos_param_unique;
float *Pcs_nmos_pat_size_target;
float *Pcs_nmos_size_L_step;
float *Pcs_nmos_size_W_step;
float *Pcs_nmos_size_iref_step;
float *Pcs_nmos_size_rin_step;
float *Pcs_nmos_circuit_breed_id;
float *Pcs_nmos_circuit_breed_target;
float *Pcs_nmos_mode_freash_op;
float *Pcs_nmos_status_index;
float *Pcs_nmos_config_size_L;
float *Pcs_nmos_config_size_W;
float *Pcs_nmos_config_size_iref;
float *Pcs_nmos_config_size_rin;
float *Pcs_nmos_vdd_V;
float *Pcs_nmos_0_V;
float *Pcs_nmos_status_fail;
float *Pcs_nmos_design_feedback;
float *Pn_ref_bin;
float *Pn_ref_W;
float *Pn_ref_L;
float *Plook_up_tables_nch_binning_LUT;
float *Pcs_nmos_leak;
float *Pcs_nmos_config_op_iterations;
float *Pcs_nmos_config_kcl_th;
float *Pcs_nmos_config_design_feedback_th;
float *Pout_V;
float *Pn_ref_go;
float *Pn_ref_gm;
float *Pn_ref_gb;
float *Pn_ref_Ids;
float *Pmid_V;
float *P0_V;
float *Pcs_nmos_look_up_tables_nch_go_ss_CONTEXT;
float *Pcs_nmos_look_up_tables_nch_gm_ss_CONTEXT;
float *Pcs_nmos_look_up_tables_nch_gb_ss_CONTEXT;
float *Pcs_nmos_look_up_tables_nch_Ids_ss_CONTEXT;
float *Pcs_nmos_Gds_in_mid;
float *Pcs_nmos_config_kcl_step;
float *PGds_in_mid;
float *Pin_V;
float *Pcs_nmos_property_Adc;
float *Pcs_nmos_property_CMRR;
float *Pcs_nmos_property_PSRR;
float *Pcs_nmos_config_fail_on_properties;
float *Pcs_nmos_property_Rout;
float *Ps;
float *Pn_ref_cgg;
float *Pn_ref_cgd;
float *Pn_ref_cdg;
float *Pn_ref_cdd;
float *Pn_ref_Ideq;
float *Pcs_nmos_property_BW;
float *Pcs_nmos_property_BW_s;
float *Pcs_nmos_p1;
float *Pcs_nmos_p2;
float *Pcs_nmos_property_ts;
float *Pcs_nmos_property_PM;
float *Pn_ref_dNt_dvgs;
float *Pn_ref_dNt_dvds;
float *Pn_ref_dNt_dvbs;
float *Pn_ref_dNt_dl;
float *Pn_ref_Nt_unit;
float *P_look_up_tables_nch_thermal_noise_ss_LUT;
float *Pn_ref_Nt;
float *Pn_ref_dNf_dvgs;
float *Pn_ref_dNf_dvds;
float *Pn_ref_dNf_dvbs;
float *Pn_ref_dNf_dl;
float *Pn_ref_Nf_unit;
float *P_look_up_tables_nch_flicker_noise_ss_LUT;
float *Pn_ref_Nf;
float *Pcs_nmos_property_Nt;
float *Pcs_nmos_property_Nf;
float *Pcs_nmos_property_fc;
float *Pcs_nmos_property_TotalNoise;
float *Pcs_nmos_property_Area;
float *Pcs_nmos_property_Vos;
float *Pcs_nmos_property_Power;
float *Pcs_nmos_config_shift_Adc;
float *Pcs_nmos_config_factor_Adc;
float *Pcs_nmos_config_shift_CMRR;
float *Pcs_nmos_config_factor_CMRR;

        float param_iref;
float param_rload;
float param_in;
float param_vdd;
float size_L;
float size_W;
float size_iref;
float size_rin;
float property_Adc;
float property_CMRR;
float cs_nmos_circuits_PAT;
float cs_nmos_config_pat_size_target;
float size_L_min;
float size_L_max;
float cs_nmos_size_L;
float size_W_max;
float cs_nmos_size_W;
float size_iref_min;
float size_iref_max;
float cs_nmos_size_iref;
float size_rin_min;
float size_rin_max;
float cs_nmos_size_rin;
float size_L_step;
float size_W_step;
float size_iref_step;
float size_rin_step;
float cs_nmos_max_Adc;
float cs_nmos_param_unique;
float cs_nmos_pat_size_target;
float cs_nmos_size_L_step;
float cs_nmos_size_W_step;
float cs_nmos_size_iref_step;
float cs_nmos_size_rin_step;
float cs_nmos_circuit_breed_id;
float cs_nmos_circuit_breed_target;
float cs_nmos_mode_freash_op;
float cs_nmos_status_index;
float cs_nmos_config_size_L;
float cs_nmos_config_size_W;
float cs_nmos_config_size_iref;
float cs_nmos_config_size_rin;
float cs_nmos_vdd_V;
float cs_nmos_0_V;
float cs_nmos_status_fail;
float cs_nmos_design_feedback;
float n_ref_bin;
float n_ref_W;
float n_ref_L;
float look_up_tables_nch_binning_LUT;
float cs_nmos_leak;
float cs_nmos_config_op_iterations;
float cs_nmos_config_kcl_th;
float cs_nmos_config_design_feedback_th;
float out_V;
float n_ref_go;
float n_ref_gm;
float n_ref_gb;
float n_ref_Ids;
float mid_V;
float CONST_0_V;
float cs_nmos_look_up_tables_nch_go_ss_CONTEXT;
float cs_nmos_look_up_tables_nch_gm_ss_CONTEXT;
float cs_nmos_look_up_tables_nch_gb_ss_CONTEXT;
float cs_nmos_look_up_tables_nch_Ids_ss_CONTEXT;
float cs_nmos_Gds_in_mid;
float cs_nmos_config_kcl_step;
float Gds_in_mid;
float in_V;
float cs_nmos_property_Adc;
float cs_nmos_property_CMRR;
float cs_nmos_property_PSRR;
float cs_nmos_config_fail_on_properties;
float cs_nmos_property_Rout;
float s;
float n_ref_cgg;
float n_ref_cgd;
float n_ref_cdg;
float n_ref_cdd;
float n_ref_Ideq;
float cs_nmos_property_BW;
float cs_nmos_property_BW_s;
float cs_nmos_p1;
float cs_nmos_p2;
float cs_nmos_property_ts;
float cs_nmos_property_PM;
float n_ref_dNt_dvgs;
float n_ref_dNt_dvds;
float n_ref_dNt_dvbs;
float n_ref_dNt_dl;
float n_ref_Nt_unit;
float _look_up_tables_nch_thermal_noise_ss_LUT;
float n_ref_Nt;
float n_ref_dNf_dvgs;
float n_ref_dNf_dvds;
float n_ref_dNf_dvbs;
float n_ref_dNf_dl;
float n_ref_Nf_unit;
float _look_up_tables_nch_flicker_noise_ss_LUT;
float n_ref_Nf;
float cs_nmos_property_Nt;
float cs_nmos_property_Nf;
float cs_nmos_property_fc;
float cs_nmos_property_TotalNoise;
float cs_nmos_property_Area;
float cs_nmos_property_Vos;
float cs_nmos_property_Power;
float cs_nmos_config_shift_Adc;
float cs_nmos_config_factor_Adc;
float cs_nmos_config_shift_CMRR;
float cs_nmos_config_factor_CMRR;

        // The compiled function
        static int tcl_gamma_cs_nmos_import_cmd(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
	    Gamma_cs_nmos_Init(interp);
            param_iref=*Pparam_iref;
param_rload=*Pparam_rload;
param_in=*Pparam_in;
param_vdd=*Pparam_vdd;
size_L=*Psize_L;
size_W=*Psize_W;
size_iref=*Psize_iref;
size_rin=*Psize_rin;
property_Adc=*Pproperty_Adc;
property_CMRR=*Pproperty_CMRR;
cs_nmos_config_pat_size_target=*Pcs_nmos_config_pat_size_target;
size_L_min=*Psize_L_min;
size_L_max=*Psize_L_max;
cs_nmos_size_L=*Pcs_nmos_size_L;
size_W_max=*Psize_W_max;
cs_nmos_size_W=*Pcs_nmos_size_W;
size_iref_min=*Psize_iref_min;
size_iref_max=*Psize_iref_max;
cs_nmos_size_iref=*Pcs_nmos_size_iref;
size_rin_min=*Psize_rin_min;
size_rin_max=*Psize_rin_max;
cs_nmos_size_rin=*Pcs_nmos_size_rin;
size_L_step=*Psize_L_step;
size_W_step=*Psize_W_step;
size_iref_step=*Psize_iref_step;
size_rin_step=*Psize_rin_step;
cs_nmos_max_Adc=*Pcs_nmos_max_Adc;
cs_nmos_param_unique=*Pcs_nmos_param_unique;
cs_nmos_pat_size_target=*Pcs_nmos_pat_size_target;
cs_nmos_size_L_step=*Pcs_nmos_size_L_step;
cs_nmos_size_W_step=*Pcs_nmos_size_W_step;
cs_nmos_size_iref_step=*Pcs_nmos_size_iref_step;
cs_nmos_size_rin_step=*Pcs_nmos_size_rin_step;
cs_nmos_circuit_breed_id=*Pcs_nmos_circuit_breed_id;
cs_nmos_circuit_breed_target=*Pcs_nmos_circuit_breed_target;
cs_nmos_mode_freash_op=*Pcs_nmos_mode_freash_op;
cs_nmos_status_index=*Pcs_nmos_status_index;
cs_nmos_config_size_L=*Pcs_nmos_config_size_L;
cs_nmos_config_size_W=*Pcs_nmos_config_size_W;
cs_nmos_config_size_iref=*Pcs_nmos_config_size_iref;
cs_nmos_config_size_rin=*Pcs_nmos_config_size_rin;
cs_nmos_vdd_V=*Pcs_nmos_vdd_V;
cs_nmos_0_V=*Pcs_nmos_0_V;
cs_nmos_status_fail=*Pcs_nmos_status_fail;
cs_nmos_design_feedback=*Pcs_nmos_design_feedback;
n_ref_bin=*Pn_ref_bin;
n_ref_W=*Pn_ref_W;
n_ref_L=*Pn_ref_L;
cs_nmos_leak=*Pcs_nmos_leak;
cs_nmos_config_op_iterations=*Pcs_nmos_config_op_iterations;
cs_nmos_config_kcl_th=*Pcs_nmos_config_kcl_th;
cs_nmos_config_design_feedback_th=*Pcs_nmos_config_design_feedback_th;
out_V=*Pout_V;
n_ref_go=*Pn_ref_go;
n_ref_gm=*Pn_ref_gm;
n_ref_gb=*Pn_ref_gb;
n_ref_Ids=*Pn_ref_Ids;
mid_V=*Pmid_V;
CONST_0_V=*P0_V;
cs_nmos_Gds_in_mid=*Pcs_nmos_Gds_in_mid;
cs_nmos_config_kcl_step=*Pcs_nmos_config_kcl_step;
Gds_in_mid=*PGds_in_mid;
in_V=*Pin_V;
cs_nmos_property_Adc=*Pcs_nmos_property_Adc;
cs_nmos_property_CMRR=*Pcs_nmos_property_CMRR;
cs_nmos_property_PSRR=*Pcs_nmos_property_PSRR;
cs_nmos_config_fail_on_properties=*Pcs_nmos_config_fail_on_properties;
cs_nmos_property_Rout=*Pcs_nmos_property_Rout;
s=*Ps;
n_ref_cgg=*Pn_ref_cgg;
n_ref_cgd=*Pn_ref_cgd;
n_ref_cdg=*Pn_ref_cdg;
n_ref_cdd=*Pn_ref_cdd;
n_ref_Ideq=*Pn_ref_Ideq;
cs_nmos_property_BW=*Pcs_nmos_property_BW;
cs_nmos_property_BW_s=*Pcs_nmos_property_BW_s;
cs_nmos_p1=*Pcs_nmos_p1;
cs_nmos_p2=*Pcs_nmos_p2;
cs_nmos_property_ts=*Pcs_nmos_property_ts;
cs_nmos_property_PM=*Pcs_nmos_property_PM;
n_ref_dNt_dvgs=*Pn_ref_dNt_dvgs;
n_ref_dNt_dvds=*Pn_ref_dNt_dvds;
n_ref_dNt_dvbs=*Pn_ref_dNt_dvbs;
n_ref_dNt_dl=*Pn_ref_dNt_dl;
n_ref_Nt_unit=*Pn_ref_Nt_unit;
n_ref_Nt=*Pn_ref_Nt;
n_ref_dNf_dvgs=*Pn_ref_dNf_dvgs;
n_ref_dNf_dvds=*Pn_ref_dNf_dvds;
n_ref_dNf_dvbs=*Pn_ref_dNf_dvbs;
n_ref_dNf_dl=*Pn_ref_dNf_dl;
n_ref_Nf_unit=*Pn_ref_Nf_unit;
n_ref_Nf=*Pn_ref_Nf;
cs_nmos_property_Nt=*Pcs_nmos_property_Nt;
cs_nmos_property_Nf=*Pcs_nmos_property_Nf;
cs_nmos_property_fc=*Pcs_nmos_property_fc;
cs_nmos_property_TotalNoise=*Pcs_nmos_property_TotalNoise;
cs_nmos_property_Area=*Pcs_nmos_property_Area;
cs_nmos_property_Vos=*Pcs_nmos_property_Vos;
cs_nmos_property_Power=*Pcs_nmos_property_Power;
cs_nmos_config_shift_Adc=*Pcs_nmos_config_shift_Adc;
cs_nmos_config_factor_Adc=*Pcs_nmos_config_factor_Adc;
cs_nmos_config_shift_CMRR=*Pcs_nmos_config_shift_CMRR;
cs_nmos_config_factor_CMRR=*Pcs_nmos_config_factor_CMRR;

            return TCL_OK;
        }
        static int tcl_gamma_cs_nmos_export_cmd(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
            *Pparam_iref=param_iref;
*Pparam_rload=param_rload;
*Pparam_in=param_in;
*Pparam_vdd=param_vdd;
*Psize_L=size_L;
*Psize_W=size_W;
*Psize_iref=size_iref;
*Psize_rin=size_rin;
*Pproperty_Adc=property_Adc;
*Pproperty_CMRR=property_CMRR;
*Pcs_nmos_config_pat_size_target=cs_nmos_config_pat_size_target;
*Psize_L_min=size_L_min;
*Psize_L_max=size_L_max;
*Pcs_nmos_size_L=cs_nmos_size_L;
*Psize_W_max=size_W_max;
*Pcs_nmos_size_W=cs_nmos_size_W;
*Psize_iref_min=size_iref_min;
*Psize_iref_max=size_iref_max;
*Pcs_nmos_size_iref=cs_nmos_size_iref;
*Psize_rin_min=size_rin_min;
*Psize_rin_max=size_rin_max;
*Pcs_nmos_size_rin=cs_nmos_size_rin;
*Psize_L_step=size_L_step;
*Psize_W_step=size_W_step;
*Psize_iref_step=size_iref_step;
*Psize_rin_step=size_rin_step;
*Pcs_nmos_max_Adc=cs_nmos_max_Adc;
*Pcs_nmos_param_unique=cs_nmos_param_unique;
*Pcs_nmos_pat_size_target=cs_nmos_pat_size_target;
*Pcs_nmos_size_L_step=cs_nmos_size_L_step;
*Pcs_nmos_size_W_step=cs_nmos_size_W_step;
*Pcs_nmos_size_iref_step=cs_nmos_size_iref_step;
*Pcs_nmos_size_rin_step=cs_nmos_size_rin_step;
*Pcs_nmos_circuit_breed_id=cs_nmos_circuit_breed_id;
*Pcs_nmos_circuit_breed_target=cs_nmos_circuit_breed_target;
*Pcs_nmos_mode_freash_op=cs_nmos_mode_freash_op;
*Pcs_nmos_status_index=cs_nmos_status_index;
*Pcs_nmos_config_size_L=cs_nmos_config_size_L;
*Pcs_nmos_config_size_W=cs_nmos_config_size_W;
*Pcs_nmos_config_size_iref=cs_nmos_config_size_iref;
*Pcs_nmos_config_size_rin=cs_nmos_config_size_rin;
*Pcs_nmos_vdd_V=cs_nmos_vdd_V;
*Pcs_nmos_0_V=cs_nmos_0_V;
*Pcs_nmos_status_fail=cs_nmos_status_fail;
*Pcs_nmos_design_feedback=cs_nmos_design_feedback;
*Pn_ref_bin=n_ref_bin;
*Pn_ref_W=n_ref_W;
*Pn_ref_L=n_ref_L;
*Pcs_nmos_leak=cs_nmos_leak;
*Pcs_nmos_config_op_iterations=cs_nmos_config_op_iterations;
*Pcs_nmos_config_kcl_th=cs_nmos_config_kcl_th;
*Pcs_nmos_config_design_feedback_th=cs_nmos_config_design_feedback_th;
*Pout_V=out_V;
*Pn_ref_go=n_ref_go;
*Pn_ref_gm=n_ref_gm;
*Pn_ref_gb=n_ref_gb;
*Pn_ref_Ids=n_ref_Ids;
*Pmid_V=mid_V;
*P0_V=CONST_0_V;
*Pcs_nmos_Gds_in_mid=cs_nmos_Gds_in_mid;
*Pcs_nmos_config_kcl_step=cs_nmos_config_kcl_step;
*PGds_in_mid=Gds_in_mid;
*Pin_V=in_V;
*Pcs_nmos_property_Adc=cs_nmos_property_Adc;
*Pcs_nmos_property_CMRR=cs_nmos_property_CMRR;
*Pcs_nmos_property_PSRR=cs_nmos_property_PSRR;
*Pcs_nmos_config_fail_on_properties=cs_nmos_config_fail_on_properties;
*Pcs_nmos_property_Rout=cs_nmos_property_Rout;
*Ps=s;
*Pn_ref_cgg=n_ref_cgg;
*Pn_ref_cgd=n_ref_cgd;
*Pn_ref_cdg=n_ref_cdg;
*Pn_ref_cdd=n_ref_cdd;
*Pn_ref_Ideq=n_ref_Ideq;
*Pcs_nmos_property_BW=cs_nmos_property_BW;
*Pcs_nmos_property_BW_s=cs_nmos_property_BW_s;
*Pcs_nmos_p1=cs_nmos_p1;
*Pcs_nmos_p2=cs_nmos_p2;
*Pcs_nmos_property_ts=cs_nmos_property_ts;
*Pcs_nmos_property_PM=cs_nmos_property_PM;
*Pn_ref_dNt_dvgs=n_ref_dNt_dvgs;
*Pn_ref_dNt_dvds=n_ref_dNt_dvds;
*Pn_ref_dNt_dvbs=n_ref_dNt_dvbs;
*Pn_ref_dNt_dl=n_ref_dNt_dl;
*Pn_ref_Nt_unit=n_ref_Nt_unit;
*Pn_ref_Nt=n_ref_Nt;
*Pn_ref_dNf_dvgs=n_ref_dNf_dvgs;
*Pn_ref_dNf_dvds=n_ref_dNf_dvds;
*Pn_ref_dNf_dvbs=n_ref_dNf_dvbs;
*Pn_ref_dNf_dl=n_ref_dNf_dl;
*Pn_ref_Nf_unit=n_ref_Nf_unit;
*Pn_ref_Nf=n_ref_Nf;
*Pcs_nmos_property_Nt=cs_nmos_property_Nt;
*Pcs_nmos_property_Nf=cs_nmos_property_Nf;
*Pcs_nmos_property_fc=cs_nmos_property_fc;
*Pcs_nmos_property_TotalNoise=cs_nmos_property_TotalNoise;
*Pcs_nmos_property_Area=cs_nmos_property_Area;
*Pcs_nmos_property_Vos=cs_nmos_property_Vos;
*Pcs_nmos_property_Power=cs_nmos_property_Power;
*Pcs_nmos_config_shift_Adc=cs_nmos_config_shift_Adc;
*Pcs_nmos_config_factor_Adc=cs_nmos_config_factor_Adc;
*Pcs_nmos_config_shift_CMRR=cs_nmos_config_shift_CMRR;
*Pcs_nmos_config_factor_CMRR=cs_nmos_config_factor_CMRR;

            return TCL_OK;
        }
        static int tcl_gamma_cs_nmos_op_cmd(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
            //            Tcl_ResetResult(interp);
            if (cs_nmos_mode_freash_op) {
}
cs_nmos_status_index=0;
if(cs_nmos_config_size_L!=0) cs_nmos_size_L=cs_nmos_config_size_L;
if(cs_nmos_config_size_W!=0) cs_nmos_size_W=cs_nmos_config_size_W;
if(cs_nmos_config_size_iref!=0) cs_nmos_size_iref=cs_nmos_config_size_iref;
if(cs_nmos_config_size_rin!=0) cs_nmos_size_rin=cs_nmos_config_size_rin;
cs_nmos_vdd_V=1.1;
cs_nmos_0_V=0;
// Calculating circuit operating point:
int op_it=0;
cs_nmos_status_fail=-1;
cs_nmos_design_feedback=1000;
n_ref_bin=get_transistor_bin(Plook_up_tables_nch_binning_LUT,n_ref_L,n_ref_W);
cs_nmos_leak=1e3;
float node_step=0;
for (op_it=0;(op_it<cs_nmos_config_op_iterations)&&((cs_nmos_leak>cs_nmos_config_kcl_th)||(cs_nmos_design_feedback>cs_nmos_config_design_feedback_th));op_it++) {
float previous_out_dc=out_V;
composite_gamma_gcc_interpolate_2p3(n_ref_bin,Pcs_nmos_look_up_tables_nch_Ids_ss_CONTEXT,Pcs_nmos_look_up_tables_nch_gm_ss_CONTEXT,Pcs_nmos_look_up_tables_nch_go_ss_CONTEXT,Pcs_nmos_look_up_tables_nch_gb_ss_CONTEXT,&(n_ref_gb),&(n_ref_gm),&(n_ref_go),&(n_ref_Ids),(mid_V)-(CONST_0_V),(out_V)-(CONST_0_V),(CONST_0_V)-(CONST_0_V),size_L,size_W);
if (n_ref_Ids<0) n_ref_Ids=0;
if (n_ref_Ids>1e-3) n_ref_Ids=1e-3;
cs_nmos_Gds_in_mid=1.0/size_rin;
if (n_ref_gm==0) n_ref_gm=1e-6;
if (n_ref_go==0) n_ref_go=1e-6;
// Updating node voltages
cs_nmos_leak=0;
node_step=cs_nmos_config_kcl_step*(0)/(Gds_in_mid);
if (node_step<-0.02) node_step=-0.02;
if (node_step>0.02) node_step=0.02;
in_V+=node_step;
if (fabs(0)>cs_nmos_leak) cs_nmos_leak=fabs(0);
if (in_V<0) in_V=0;
if (in_V>1.1) in_V=1.1;
node_step=cs_nmos_config_kcl_step*(0)/(Gds_in_mid);
if (node_step<-0.02) node_step=-0.02;
if (node_step>0.02) node_step=0.02;
mid_V+=node_step;
if (fabs(0)>cs_nmos_leak) cs_nmos_leak=fabs(0);
if (mid_V<0) mid_V=0;
if (mid_V>1.1) mid_V=1.1;
node_step=cs_nmos_config_kcl_step*(size_iref-n_ref_Ids)/(n_ref_go);
if (node_step<-0.02) node_step=-0.02;
if (node_step>0.02) node_step=0.02;
out_V+=node_step;
if (fabs(size_iref-n_ref_Ids)>cs_nmos_leak) cs_nmos_leak=fabs(size_iref-n_ref_Ids);
if (out_V<0) out_V=0;
if (out_V>1.1) out_V=1.1;
cs_nmos_design_feedback=0;
}
if (op_it>=cs_nmos_config_op_iterations) {cs_nmos_status_fail=cs_nmos_leak; return TCL_ERROR;}
if (CONST_0_V>out_V) {cs_nmos_status_fail=3; return TCL_ERROR;}
float W,M;
double Det=(-(-Gds_in_mid*(-n_ref_go)));
double Ted=1/Det;
cs_nmos_property_Adc=Ted*((-(-0)));
cs_nmos_property_CMRR=cs_nmos_property_Adc;
cs_nmos_property_PSRR=Ted*((-(-0)));
cs_nmos_property_Adc=fabs(cs_nmos_property_Adc);
if ((cs_nmos_property_Adc<1)&&(cs_nmos_config_fail_on_properties)) {cs_nmos_status_fail=2; return TCL_ERROR;}
cs_nmos_property_Rout=fabs(((-(-Gds_in_mid)))*Ted);
//AC output: (-((-Gds_in_mid)*(n_ref_gm+n_ref_cdg*s)*(-param_in)-(Gds_in_mid+n_ref_cgg*s)*(-(size_iref-n_ref_Ideq))))/(-((-(Gds_in_mid+n_ref_cgg*s)*(-(n_ref_go+n_ref_cdd*s)))+n_ref_cgd*s*(-(n_ref_gm+n_ref_cdg*s))))
//AC gain: (-(-0))/(-((-(Gds_in_mid+n_ref_cgg*s)*(-(n_ref_go+n_ref_cdd*s)))+n_ref_cgd*s*(-(n_ref_gm+n_ref_cdg*s))))
float s=-1;
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
      sdr=-(-(Gds_in_mid*(-n_ref_go)-n_ref_cgg*W*(-n_ref_cdd*W))-(n_ref_cgd*W*(-n_ref_cdg*W)));
      sdi=-(-(Gds_in_mid*(-n_ref_cdd*W)+n_ref_cgg*W*(-n_ref_go))+n_ref_cgd*W*(-n_ref_gm));
      BW_Mag=(snr*snr+sni*sni)/(sdr*sdr+sdi*sdi);
      if (W==0) BW_Mag0=BW_Mag;
      if (W==0) W=1; else W*=1.01;
}
cs_nmos_property_BW=fabs(W/(2*3.141592656));
for (BW_it=0;BW_it<5;BW_it++)  s-=((-((-(Gds_in_mid+n_ref_cgg*s)*(-(n_ref_go+n_ref_cdd*s)))+n_ref_cgd*s*(-(n_ref_gm+n_ref_cdg*s)))))/((-0));
cs_nmos_property_BW_s=(-0);
cs_nmos_p1=-s;
if (!isfinite(cs_nmos_property_BW))  {cs_nmos_status_fail=8; return TCL_ERROR;}
s-=1e3;
for (BW_it=0;BW_it<20;BW_it++)  s-=(((-((-(Gds_in_mid+n_ref_cgg*s)*(-(n_ref_go+n_ref_cdd*s)))+n_ref_cgd*s*(-(n_ref_gm+n_ref_cdg*s)))))*(s+cs_nmos_p1-5e2))/(((-0))*(s+cs_nmos_p1-5e2)-((-((-(Gds_in_mid+n_ref_cgg*s)*(-(n_ref_go+n_ref_cdd*s)))+n_ref_cgd*s*(-(n_ref_gm+n_ref_cdg*s))))));
cs_nmos_p2=-s;
if (!isfinite(cs_nmos_p1)) {
    cs_nmos_property_ts=1/cs_nmos_property_BW;
} else if (!isfinite(cs_nmos_p2)) {
    cs_nmos_property_ts=-log(0.02)/cs_nmos_p1;
} else {
    float A1=-cs_nmos_p2/(-cs_nmos_p1+cs_nmos_p2);
    float A2=-cs_nmos_p1/(-cs_nmos_p1+cs_nmos_p2);
    cs_nmos_property_ts=0;
    for (BW_it=0;BW_it<10;BW_it++) cs_nmos_property_ts-=(0.02+A1*exp(-cs_nmos_p1*cs_nmos_property_ts)+A2*exp(-cs_nmos_p2*cs_nmos_property_ts))/(-cs_nmos_p1*A1*exp(-cs_nmos_p1*cs_nmos_property_ts)-cs_nmos_p2*A2*exp(-cs_nmos_p2*cs_nmos_property_ts));
}
if (!isfinite(cs_nmos_property_ts)) {
    cs_nmos_property_ts=1/cs_nmos_property_BW;
}
while (BW_Mag>4) {
      snr=0;
      sni=0;
      sdr=-(-(Gds_in_mid*(-n_ref_go)-n_ref_cgg*W*(-n_ref_cdd*W))-(n_ref_cgd*W*(-n_ref_cdg*W)));
      sdi=-(-(Gds_in_mid*(-n_ref_cdd*W)+n_ref_cgg*W*(-n_ref_go))+n_ref_cgd*W*(-n_ref_gm));
      BW_Mag=(snr*snr+sni*sni)/(sdr*sdr+sdi*sdi);
      W*=1.01;
}
cs_nmos_property_PM=180-180*(atan(sni/snr)-atan(sdi/sdr))/3.1415926;
n_ref_Nt_unit=gamma_gcc_interpolateg_4(P_look_up_tables_nch_thermal_noise_ss_LUT,mid_V,out_V,CONST_0_V,size_L,&n_ref_dNt_dvgs,&n_ref_dNt_dvds,&n_ref_dNt_dvbs,&n_ref_dNt_dl);
n_ref_Nt=n_ref_Nt_unit*n_ref_go;
if (!isfinite(n_ref_Nt))  {cs_nmos_status_fail=5; return TCL_ERROR;}
n_ref_Nf_unit=gamma_gcc_interpolateg_4(P_look_up_tables_nch_flicker_noise_ss_LUT,mid_V,out_V,CONST_0_V,size_L,&n_ref_dNf_dvgs,&n_ref_dNf_dvds,&n_ref_dNf_dvbs,&n_ref_dNf_dl);
n_ref_Nf=n_ref_Nf_unit*n_ref_go*n_ref_go/(size_W*size_L);
if (!isfinite(n_ref_Nf))  {cs_nmos_status_fail=6; return TCL_ERROR;}
float current_transfer_n_ref=Ted*((-(-Gds_in_mid)))/cs_nmos_property_Adc;
cs_nmos_property_Nt=(current_transfer_n_ref*current_transfer_n_ref*n_ref_Nt)/cs_nmos_property_Adc;
cs_nmos_property_Nf=(current_transfer_n_ref*current_transfer_n_ref*n_ref_Nf)/cs_nmos_property_Adc;
cs_nmos_property_fc=cs_nmos_property_Nf/cs_nmos_property_Nt;
cs_nmos_property_TotalNoise=(log(2*cs_nmos_property_BW)*cs_nmos_property_Nf+2*cs_nmos_property_BW*cs_nmos_property_Nt);
cs_nmos_property_Area=1e12*(size_W*size_L);
float single_transistor_vos;
cs_nmos_property_Vos=0;
cs_nmos_property_Vos=1e-3*sqrt(cs_nmos_property_Vos);
cs_nmos_property_Power=0;
cs_nmos_property_Power+=fabs(n_ref_Ids*((out_V)-(CONST_0_V)));
cs_nmos_property_Adc=20*log10(fabs(cs_nmos_property_Adc));
cs_nmos_property_CMRR=20*log10(fabs(cs_nmos_property_CMRR));
cs_nmos_property_CMRR=cs_nmos_property_Adc-cs_nmos_property_CMRR;
if (cs_nmos_max_Adc<cs_nmos_property_Adc) cs_nmos_max_Adc=cs_nmos_property_Adc;
PAT *p=(PAT *)Pcs_nmos_circuits_PAT;
float sizes[4];
sizes[0]=cs_nmos_size_L;
sizes[1]=cs_nmos_size_W;
sizes[2]=cs_nmos_size_iref;
sizes[3]=cs_nmos_size_rin;
float properties[2];
if ((cs_nmos_config_factor_Adc!=0)||(cs_nmos_config_shift_Adc!=0)) cs_nmos_property_Adc=cs_nmos_property_Adc*cs_nmos_config_factor_Adc+cs_nmos_config_shift_Adc;
properties[0]=cs_nmos_property_Adc;
if ((cs_nmos_config_factor_CMRR!=0)||(cs_nmos_config_shift_CMRR!=0)) cs_nmos_property_CMRR=cs_nmos_property_CMRR*cs_nmos_config_factor_CMRR+cs_nmos_config_shift_CMRR;
properties[1]=cs_nmos_property_CMRR;
cs_nmos_status_fail=op_it;
cs_nmos_status_index=add_pat_array(p,sizes,properties);

            return TCL_OK;
        }
        //      static int tcl_gamma_grad_cmd(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
            //            Tcl_ResetResult(interp);
            //          GRAD_CODE_GOES_HERE
            //         return TCL_OK;
        //    }
        static int tcl_gamma_cs_nmos_heatmap_cmd(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
            int i,j;
ClientData CD;
if ((argc!=15)&&(argc!=14)&&(argc!=13)) {
    #Error: "%s: usage: %s <x context> <minX> <maxX> <stepX> <y context> <minY> <maxY> <stepY> <z context> <pixel width> <pixel height> <pallet> [<pallet mode> {[<pass threshold>]}]" argv[0] argv[0]
    return TCL_ERROR;
}
    float *pX=(float *)&(create_context(argv[1]))->value.s;
    float *pY=(float *)&(create_context(argv[5]))->value.s;
    float *pZ=(float *)&(create_context(argv[7]))->value.s;
    float *PX=NULL;
if (strcmp(argv[1],"param:iref")==0) PX=&(param_iref);
if (strcmp(argv[1],"param:rload")==0) PX=&(param_rload);
if (strcmp(argv[1],"param:in")==0) PX=&(param_in);
if (strcmp(argv[1],"param:vdd")==0) PX=&(param_vdd);
if (strcmp(argv[1],"size:L")==0) PX=&(size_L);
if (strcmp(argv[1],"size:W")==0) PX=&(size_W);
if (strcmp(argv[1],"size:iref")==0) PX=&(size_iref);
if (strcmp(argv[1],"size:rin")==0) PX=&(size_rin);
if (strcmp(argv[1],"property:Adc")==0) PX=&(property_Adc);
if (strcmp(argv[1],"property:CMRR")==0) PX=&(property_CMRR);
if (PX==NULL) {
    #Error: "%s: context %s is not available for heatmap generation." argv[0] argv[1]
    return TCL_ERROR;
}
float minX=atof(argv[2]);
float maxX=atof(argv[3]);
float stepX=atof(argv[4]);
    float *PY=NULL;
if (strcmp(argv[5],"param:iref")==0) PY=&(param_iref);
if (strcmp(argv[5],"param:rload")==0) PY=&(param_rload);
if (strcmp(argv[5],"param:in")==0) PY=&(param_in);
if (strcmp(argv[5],"param:vdd")==0) PY=&(param_vdd);
if (strcmp(argv[5],"size:L")==0) PY=&(size_L);
if (strcmp(argv[5],"size:W")==0) PY=&(size_W);
if (strcmp(argv[5],"size:iref")==0) PY=&(size_iref);
if (strcmp(argv[5],"size:rin")==0) PY=&(size_rin);
if (strcmp(argv[5],"property:Adc")==0) PY=&(property_Adc);
if (strcmp(argv[5],"property:CMRR")==0) PY=&(property_CMRR);
if (PY==NULL) {
    #Error: "%s: context %s is not available for heatmap generation." argv[0] argv[1]
    return TCL_ERROR;
}
float minY=atof(argv[6]);
float maxY=atof(argv[7]);
float stepY=atof(argv[8]);
    float *PZ=NULL;
if (strcmp(argv[7],"param:iref")==0) PZ=&(param_iref);
if (strcmp(argv[7],"param:rload")==0) PZ=&(param_rload);
if (strcmp(argv[7],"param:in")==0) PZ=&(param_in);
if (strcmp(argv[7],"param:vdd")==0) PZ=&(param_vdd);
if (strcmp(argv[7],"size:L")==0) PZ=&(size_L);
if (strcmp(argv[7],"size:W")==0) PZ=&(size_W);
if (strcmp(argv[7],"size:iref")==0) PZ=&(size_iref);
if (strcmp(argv[7],"size:rin")==0) PZ=&(size_rin);
if (strcmp(argv[7],"property:Adc")==0) PZ=&(property_Adc);
if (strcmp(argv[7],"property:CMRR")==0) PZ=&(property_CMRR);
if (PZ==NULL) {
    #Error: "%s: context %s is not available for heatmap generation." argv[0] argv[1]
    return TCL_ERROR;
}
int width=(int)(maxX-minX)/stepX+1;
int height=(int)(maxY-minY)/stepY+1;
int ARGC;
char **ARGV;
Tcl_SplitList(interp,argv[12],&ARGC,&ARGV);
int *pal=(int *)malloc(sizeof(int)*ARGC);
for (i=0;i<ARGC;i++) pal[i]=atoi(ARGV[i]);
heatmap *hm=new_heatmap(width,height,atoi(argv[10]),atoi(argv[11]),pal,ARGC);
int mode=-1;
float th=0;
if (argc==13) mode=HM_TH_MODE_FLAT; else {
if (strcmp(argv[13],"flat")==0) mode=HM_TH_MODE_FLAT;
if (strcmp(argv[13],"snap")==0) mode=HM_TH_MODE_SNAP;
if (strcmp(argv[13],"half")==0) mode=HM_TH_MODE_HALF;
}
if (mode==-1) {
	#Error: "%s: pallet mode %s is not available for heatmap generation. Use flat, snap or half" argv[0] argv[13]
	return TCL_ERROR;
}
if ((mode!=HM_TH_MODE_FLAT)&&(argc!=15)) {
	#Error: "%s: pallet mode %s requires a threshold for passing specifications." argv[0] argv[13]
	return TCL_ERROR;
} else th=atof(argv[14]);
float X,Y;
i=0;
for (X=minX;X<=maxX;X+=stepX) {
    j=0;
    for (Y=minY;Y<=maxY;Y+=stepY) {
        *PX=X;
        *PY=Y;
        tcl_gamma_cs_nmos_op_cmd(CD,NULL,0,NULL);
        set_heatmap_pixel(hm,i,j,*PZ);
        j++;
    }
    i++;
}
heatmap_thresholds(hm,mode,th);
char *out_channel_name=Tcl_GetVar(interp,"::HTML",0);
FILE *HTML;
Tcl_GetOpenFile(interp,out_channel_name,1,0,&HTML);
plot_heatmap(hm,0,0,HTML);

            return TCL_OK;
        }
        static int tcl_gamma_cs_nmos_random_cmd(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
            ClientData CD;
PAT *p=(PAT *)Pcs_nmos_circuits_PAT;
while (p->content->num_of<cs_nmos_config_pat_size_target) {
cs_nmos_size_L=size_L_min+random()*(size_L_max-size_L_min)/RAND_MAX;
cs_nmos_size_W=size_L+random()*(size_W_max-size_L)/RAND_MAX;
cs_nmos_size_iref=size_iref_min+random()*(size_iref_max-size_iref_min)/RAND_MAX;
cs_nmos_size_rin=size_rin_min+random()*(size_rin_max-size_rin_min)/RAND_MAX;
if (tcl_gamma_cs_nmos_op_cmd(CD,NULL,0,NULL)==TCL_ERROR) continue;
}

            return TCL_OK;
        }
        static int tcl_gamma_cs_nmos_breed_cmd(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
            ClientData CD;
int i,viable;
PAT *p=(PAT *)Pcs_nmos_circuits_PAT;
int more_to_breed=1;
while (more_to_breed&&(p->content->num_of<cs_nmos_pat_size_target)) {
more_to_breed=0;
int sweep_size=p->content->num_of;
for (i=0;i<sweep_size;i++) {
if (p->content->content[i]->flags) continue;
p->content->content[i]->flags=1;
more_to_breed++;
cs_nmos_size_L=p->content->content[i]->sizes->content[0];
cs_nmos_size_W=p->content->content[i]->sizes->content[1];
cs_nmos_size_iref=p->content->content[i]->sizes->content[2];
cs_nmos_size_rin=p->content->content[i]->sizes->content[3];
cs_nmos_size_L=cs_nmos_size_L+cs_nmos_size_L_step;
viable=1;
if ((cs_nmos_size_L>=size_L_min)&&(cs_nmos_size_L<=size_L_max)) {
tcl_gamma_cs_nmos_op_cmd(CD,NULL,0,NULL);
}
cs_nmos_size_L=cs_nmos_size_L-2*cs_nmos_size_L_step;
viable=1;
if ((cs_nmos_size_L>=size_L_min)&&(cs_nmos_size_L<=size_L_max)) {
tcl_gamma_cs_nmos_op_cmd(CD,NULL,0,NULL);
}
cs_nmos_size_L=cs_nmos_size_L+cs_nmos_size_L_step;
cs_nmos_size_W=cs_nmos_size_W+cs_nmos_size_W_step;
viable=1;
if ((cs_nmos_size_W>=size_L)&&(cs_nmos_size_W<=size_W_max)) {
tcl_gamma_cs_nmos_op_cmd(CD,NULL,0,NULL);
}
cs_nmos_size_W=cs_nmos_size_W-2*cs_nmos_size_W_step;
viable=1;
if ((cs_nmos_size_W>=size_L)&&(cs_nmos_size_W<=size_W_max)) {
tcl_gamma_cs_nmos_op_cmd(CD,NULL,0,NULL);
}
cs_nmos_size_W=cs_nmos_size_W+cs_nmos_size_W_step;
cs_nmos_size_iref=cs_nmos_size_iref+cs_nmos_size_iref_step;
viable=1;
if ((cs_nmos_size_iref>=size_iref_min)&&(cs_nmos_size_iref<=size_iref_max)) {
tcl_gamma_cs_nmos_op_cmd(CD,NULL,0,NULL);
}
cs_nmos_size_iref=cs_nmos_size_iref-2*cs_nmos_size_iref_step;
viable=1;
if ((cs_nmos_size_iref>=size_iref_min)&&(cs_nmos_size_iref<=size_iref_max)) {
tcl_gamma_cs_nmos_op_cmd(CD,NULL,0,NULL);
}
cs_nmos_size_iref=cs_nmos_size_iref+cs_nmos_size_iref_step;
cs_nmos_size_rin=cs_nmos_size_rin+cs_nmos_size_rin_step;
viable=1;
if ((cs_nmos_size_rin>=size_rin_min)&&(cs_nmos_size_rin<=size_rin_max)) {
tcl_gamma_cs_nmos_op_cmd(CD,NULL,0,NULL);
}
cs_nmos_size_rin=cs_nmos_size_rin-2*cs_nmos_size_rin_step;
viable=1;
if ((cs_nmos_size_rin>=size_rin_min)&&(cs_nmos_size_rin<=size_rin_max)) {
tcl_gamma_cs_nmos_op_cmd(CD,NULL,0,NULL);
}
cs_nmos_size_rin=cs_nmos_size_rin+cs_nmos_size_rin_step;
if (p->content->num_of%100==0) {
	printf("		%ld/%g=%g%%\n",p->content->num_of,cs_nmos_pat_size_target,100*p->content->num_of/cs_nmos_pat_size_target);
	fflush(stdout);
	if (cs_nmos_param_unique>0) {
	    pat_unique(p,cs_nmos_param_unique);
}
}
}
printf("	Done %ld/%g=%g%% (%ld visited)\n",p->content->num_of,cs_nmos_pat_size_target,100*p->content->num_of/cs_nmos_pat_size_target,more_to_breed);
}

            return TCL_OK;
        }
        static int tcl_gamma_cs_nmos_random_breed_cmd(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
            ClientData CD;
int i,j;
PAT *p=(PAT *)Pcs_nmos_circuits_PAT;
long int r;
float step;
while (1) {
    if (p->content->num_of>cs_nmos_config_pat_size_target) break;
int sweep_size=p->content->num_of;
for (i=0;i<sweep_size;i++) {
cs_nmos_size_L=p->content->content[i]->sizes->content[0];
cs_nmos_size_W=p->content->content[i]->sizes->content[1];
cs_nmos_size_iref=p->content->content[i]->sizes->content[2];
cs_nmos_size_rin=p->content->content[i]->sizes->content[3];
while (1) {
step=(2.0*random()/RAND_MAX-1)*size_L_step;
if (cs_nmos_size_L+step<size_L_min) continue;
if (cs_nmos_size_L+step>size_L_max) continue;
break;
}
cs_nmos_size_L+=step;
while (1) {
step=(2.0*random()/RAND_MAX-1)*size_W_step;
if (cs_nmos_size_W+step<size_L) continue;
if (cs_nmos_size_W+step>size_W_max) continue;
break;
}
cs_nmos_size_W+=step;
while (1) {
step=(2.0*random()/RAND_MAX-1)*size_iref_step;
if (cs_nmos_size_iref+step<size_iref_min) continue;
if (cs_nmos_size_iref+step>size_iref_max) continue;
break;
}
cs_nmos_size_iref+=step;
while (1) {
step=(2.0*random()/RAND_MAX-1)*size_rin_step;
if (cs_nmos_size_rin+step<size_rin_min) continue;
if (cs_nmos_size_rin+step>size_rin_max) continue;
break;
}
cs_nmos_size_rin+=step;
int pre_volume=p->content->num_of;
if (tcl_gamma_cs_nmos_op_cmd(CD,NULL,0,NULL)==TCL_ERROR) {i--; continue;}
if (pre_volume==p->content->num_of) {i--; continue;}
if (p->content->num_of%1000==0) {
    printf("               %ld/%g=%g%% max gain=%g\n",p->content->num_of,cs_nmos_config_pat_size_target,100*p->content->num_of/cs_nmos_config_pat_size_target,cs_nmos_max_Adc);
    printf("               %ld/%g=%g%%\n",p->content->num_of,cs_nmos_config_pat_size_target,100*p->content->num_of/cs_nmos_config_pat_size_target);
    fflush(stdout);
    if (cs_nmos_param_unique>0) {
        pat_unique(p,cs_nmos_param_unique);
    printf("               post unique: %ld/%g=%g%%\n",p->content->num_of,cs_nmos_config_pat_size_target,100*p->content->num_of/cs_nmos_config_pat_size_target);
    if (p->content->num_of>0.92*cs_nmos_config_pat_size_target) break;
}
}
    if (p->content->num_of>cs_nmos_config_pat_size_target) break;
}
    if (p->content->num_of>cs_nmos_config_pat_size_target) break;
}

            return TCL_OK;
        }
        static int tcl_gamma_cs_nmos_random_breed_single_cmd(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]) {
            ClientData CD;
int i;
PAT *p=(PAT *)Pcs_nmos_circuits_PAT;
int more_to_breed=0;
long int r;
long int breed_count=p->content->num_of;
long int watchdog=0;
float step;
int sweep_size=p->content->num_of;
int searched_id=(int)cs_nmos_circuit_breed_id;
for (i=0;i<p->content->num_of;i++) {
    if (p->content->content[i]->id==searched_id) break;
}
printf("Found circuit id %d at index %d\n",searched_id,i);
while (watchdog++<10000) {
cs_nmos_size_L=p->content->content[i]->sizes->content[0];
cs_nmos_size_W=p->content->content[i]->sizes->content[1];
cs_nmos_size_iref=p->content->content[i]->sizes->content[2];
cs_nmos_size_rin=p->content->content[i]->sizes->content[3];
while (1) {
step=(2.0*random()/RAND_MAX-1)*size_L_step;
if (cs_nmos_size_L+step<size_L_min) continue;
if (cs_nmos_size_L+step>size_L_max) continue;
break;
}
cs_nmos_size_L+=step;
while (1) {
step=(2.0*random()/RAND_MAX-1)*size_W_step;
if (cs_nmos_size_W+step<size_L) continue;
if (cs_nmos_size_W+step>size_W_max) continue;
break;
}
cs_nmos_size_W+=step;
while (1) {
step=(2.0*random()/RAND_MAX-1)*size_iref_step;
if (cs_nmos_size_iref+step<size_iref_min) continue;
if (cs_nmos_size_iref+step>size_iref_max) continue;
break;
}
cs_nmos_size_iref+=step;
while (1) {
step=(2.0*random()/RAND_MAX-1)*size_rin_step;
if (cs_nmos_size_rin+step<size_rin_min) continue;
if (cs_nmos_size_rin+step>size_rin_max) continue;
break;
}
cs_nmos_size_rin+=step;
if (tcl_gamma_cs_nmos_op_cmd(CD,NULL,0,NULL)==TCL_ERROR) continue;
if (p->content->num_of>=breed_count+cs_nmos_circuit_breed_target) break;
}

            return TCL_OK;
        }
        // Initializing cTree references and registering the tcl_gamma_op_cmd command as ::C::cs_nmos
        int Gamma_cs_nmos_Init(Tcl_Interp *interp) {
            float *array_entry;
            context *c;
            c=create_context("param:iref");
Pparam_iref=(float *)(&c->value.s);
c=create_context("param:rload");
Pparam_rload=(float *)(&c->value.s);
c=create_context("param:in");
Pparam_in=(float *)(&c->value.s);
c=create_context("param:vdd");
Pparam_vdd=(float *)(&c->value.s);
c=create_context("size:L");
Psize_L=(float *)(&c->value.s);
c=create_context("size:W");
Psize_W=(float *)(&c->value.s);
c=create_context("size:iref");
Psize_iref=(float *)(&c->value.s);
c=create_context("size:rin");
Psize_rin=(float *)(&c->value.s);
c=create_context("property:Adc");
Pproperty_Adc=(float *)(&c->value.s);
c=create_context("property:CMRR");
Pproperty_CMRR=(float *)(&c->value.s);
Pcs_nmos_circuits_PAT=(float *)get_PAT("cs_nmos:circuits");
c=create_context("cs_nmos:config:pat_size_target");
Pcs_nmos_config_pat_size_target=(float *)(&c->value.s);
c=create_context("size:L:min");
Psize_L_min=(float *)(&c->value.s);
c=create_context("size:L:max");
Psize_L_max=(float *)(&c->value.s);
c=create_context("cs_nmos:size:L");
Pcs_nmos_size_L=(float *)(&c->value.s);
c=create_context("size:W:max");
Psize_W_max=(float *)(&c->value.s);
c=create_context("cs_nmos:size:W");
Pcs_nmos_size_W=(float *)(&c->value.s);
c=create_context("size:iref:min");
Psize_iref_min=(float *)(&c->value.s);
c=create_context("size:iref:max");
Psize_iref_max=(float *)(&c->value.s);
c=create_context("cs_nmos:size:iref");
Pcs_nmos_size_iref=(float *)(&c->value.s);
c=create_context("size:rin:min");
Psize_rin_min=(float *)(&c->value.s);
c=create_context("size:rin:max");
Psize_rin_max=(float *)(&c->value.s);
c=create_context("cs_nmos:size:rin");
Pcs_nmos_size_rin=(float *)(&c->value.s);
c=create_context("size:L:step");
Psize_L_step=(float *)(&c->value.s);
c=create_context("size:W:step");
Psize_W_step=(float *)(&c->value.s);
c=create_context("size:iref:step");
Psize_iref_step=(float *)(&c->value.s);
c=create_context("size:rin:step");
Psize_rin_step=(float *)(&c->value.s);
c=create_context("cs_nmos:max_Adc");
Pcs_nmos_max_Adc=(float *)(&c->value.s);
c=create_context("cs_nmos:param:unique");
Pcs_nmos_param_unique=(float *)(&c->value.s);
c=create_context("cs_nmos:pat_size_target");
Pcs_nmos_pat_size_target=(float *)(&c->value.s);
c=create_context("cs_nmos:size:L:step");
Pcs_nmos_size_L_step=(float *)(&c->value.s);
c=create_context("cs_nmos:size:W:step");
Pcs_nmos_size_W_step=(float *)(&c->value.s);
c=create_context("cs_nmos:size:iref:step");
Pcs_nmos_size_iref_step=(float *)(&c->value.s);
c=create_context("cs_nmos:size:rin:step");
Pcs_nmos_size_rin_step=(float *)(&c->value.s);
c=create_context("cs_nmos:circuit_breed_id");
Pcs_nmos_circuit_breed_id=(float *)(&c->value.s);
c=create_context("cs_nmos:circuit_breed_target");
Pcs_nmos_circuit_breed_target=(float *)(&c->value.s);
c=create_context("cs_nmos:mode:freash_op");
Pcs_nmos_mode_freash_op=(float *)(&c->value.s);
c=create_context("cs_nmos:status:index");
Pcs_nmos_status_index=(float *)(&c->value.s);
c=create_context("cs_nmos:config:size:L");
Pcs_nmos_config_size_L=(float *)(&c->value.s);
c=create_context("cs_nmos:config:size:W");
Pcs_nmos_config_size_W=(float *)(&c->value.s);
c=create_context("cs_nmos:config:size:iref");
Pcs_nmos_config_size_iref=(float *)(&c->value.s);
c=create_context("cs_nmos:config:size:rin");
Pcs_nmos_config_size_rin=(float *)(&c->value.s);
c=create_context("cs_nmos:vdd:V");
Pcs_nmos_vdd_V=(float *)(&c->value.s);
c=create_context("cs_nmos:0:V");
Pcs_nmos_0_V=(float *)(&c->value.s);
c=create_context("cs_nmos:status:fail");
Pcs_nmos_status_fail=(float *)(&c->value.s);
c=create_context("cs_nmos:design_feedback");
Pcs_nmos_design_feedback=(float *)(&c->value.s);
c=create_context("n_ref:bin");
Pn_ref_bin=(float *)(&c->value.s);
c=create_context("n_ref:W");
Pn_ref_W=(float *)(&c->value.s);
c=create_context("n_ref:L");
Pn_ref_L=(float *)(&c->value.s);
Plook_up_tables_nch_binning_LUT=(float *)get_LUT("nch:binning");
c=create_context("cs_nmos:leak");
Pcs_nmos_leak=(float *)(&c->value.s);
c=create_context("cs_nmos:config:op_iterations");
Pcs_nmos_config_op_iterations=(float *)(&c->value.s);
c=create_context("cs_nmos:config:kcl_th");
Pcs_nmos_config_kcl_th=(float *)(&c->value.s);
c=create_context("cs_nmos:config:design_feedback_th");
Pcs_nmos_config_design_feedback_th=(float *)(&c->value.s);
c=create_context("out:V");
Pout_V=(float *)(&c->value.s);
c=create_context("n_ref:go");
Pn_ref_go=(float *)(&c->value.s);
c=create_context("n_ref:gm");
Pn_ref_gm=(float *)(&c->value.s);
c=create_context("n_ref:gb");
Pn_ref_gb=(float *)(&c->value.s);
c=create_context("n_ref:Ids");
Pn_ref_Ids=(float *)(&c->value.s);
c=create_context("mid:V");
Pmid_V=(float *)(&c->value.s);
c=create_context("0:V");
P0_V=(float *)(&c->value.s);
c=create_context("cs_nmos:look_up_tables:nch:go:ss");
Pcs_nmos_look_up_tables_nch_go_ss_CONTEXT=(float *)&c;
c=create_context("cs_nmos:look_up_tables:nch:gm:ss");
Pcs_nmos_look_up_tables_nch_gm_ss_CONTEXT=(float *)&c;
c=create_context("cs_nmos:look_up_tables:nch:gb:ss");
Pcs_nmos_look_up_tables_nch_gb_ss_CONTEXT=(float *)&c;
c=create_context("cs_nmos:look_up_tables:nch:Ids:ss");
Pcs_nmos_look_up_tables_nch_Ids_ss_CONTEXT=(float *)&c;
c=create_context("cs_nmos:Gds_in_mid");
Pcs_nmos_Gds_in_mid=(float *)(&c->value.s);
c=create_context("cs_nmos:config:kcl_step");
Pcs_nmos_config_kcl_step=(float *)(&c->value.s);
c=create_context("Gds_in_mid");
PGds_in_mid=(float *)(&c->value.s);
c=create_context("in:V");
Pin_V=(float *)(&c->value.s);
c=create_context("cs_nmos:property:Adc");
Pcs_nmos_property_Adc=(float *)(&c->value.s);
c=create_context("cs_nmos:property:CMRR");
Pcs_nmos_property_CMRR=(float *)(&c->value.s);
c=create_context("cs_nmos:property:PSRR");
Pcs_nmos_property_PSRR=(float *)(&c->value.s);
c=create_context("cs_nmos:config:fail_on_properties");
Pcs_nmos_config_fail_on_properties=(float *)(&c->value.s);
c=create_context("cs_nmos:property:Rout");
Pcs_nmos_property_Rout=(float *)(&c->value.s);
c=create_context("s");
Ps=(float *)(&c->value.s);
c=create_context("n_ref:cgg");
Pn_ref_cgg=(float *)(&c->value.s);
c=create_context("n_ref:cgd");
Pn_ref_cgd=(float *)(&c->value.s);
c=create_context("n_ref:cdg");
Pn_ref_cdg=(float *)(&c->value.s);
c=create_context("n_ref:cdd");
Pn_ref_cdd=(float *)(&c->value.s);
c=create_context("n_ref:Ideq");
Pn_ref_Ideq=(float *)(&c->value.s);
c=create_context("cs_nmos:property:BW");
Pcs_nmos_property_BW=(float *)(&c->value.s);
c=create_context("cs_nmos:property:BW:s");
Pcs_nmos_property_BW_s=(float *)(&c->value.s);
c=create_context("cs_nmos:p1");
Pcs_nmos_p1=(float *)(&c->value.s);
c=create_context("cs_nmos:p2");
Pcs_nmos_p2=(float *)(&c->value.s);
c=create_context("cs_nmos:property:ts");
Pcs_nmos_property_ts=(float *)(&c->value.s);
c=create_context("cs_nmos:property:PM");
Pcs_nmos_property_PM=(float *)(&c->value.s);
c=create_context("n_ref:dNt_dvgs");
Pn_ref_dNt_dvgs=(float *)(&c->value.s);
c=create_context("n_ref:dNt_dvds");
Pn_ref_dNt_dvds=(float *)(&c->value.s);
c=create_context("n_ref:dNt_dvbs");
Pn_ref_dNt_dvbs=(float *)(&c->value.s);
c=create_context("n_ref:dNt_dl");
Pn_ref_dNt_dl=(float *)(&c->value.s);
c=create_context("n_ref:Nt_unit");
Pn_ref_Nt_unit=(float *)(&c->value.s);
P_look_up_tables_nch_thermal_noise_ss_LUT=(float *)get_LUT(":look_up_tables:nch:thermal_noise:ss");
c=create_context("n_ref:Nt");
Pn_ref_Nt=(float *)(&c->value.s);
c=create_context("n_ref:dNf_dvgs");
Pn_ref_dNf_dvgs=(float *)(&c->value.s);
c=create_context("n_ref:dNf_dvds");
Pn_ref_dNf_dvds=(float *)(&c->value.s);
c=create_context("n_ref:dNf_dvbs");
Pn_ref_dNf_dvbs=(float *)(&c->value.s);
c=create_context("n_ref:dNf_dl");
Pn_ref_dNf_dl=(float *)(&c->value.s);
c=create_context("n_ref:Nf_unit");
Pn_ref_Nf_unit=(float *)(&c->value.s);
P_look_up_tables_nch_flicker_noise_ss_LUT=(float *)get_LUT(":look_up_tables:nch:flicker_noise:ss");
c=create_context("n_ref:Nf");
Pn_ref_Nf=(float *)(&c->value.s);
c=create_context("cs_nmos:property:Nt");
Pcs_nmos_property_Nt=(float *)(&c->value.s);
c=create_context("cs_nmos:property:Nf");
Pcs_nmos_property_Nf=(float *)(&c->value.s);
c=create_context("cs_nmos:property:fc");
Pcs_nmos_property_fc=(float *)(&c->value.s);
c=create_context("cs_nmos:property:TotalNoise");
Pcs_nmos_property_TotalNoise=(float *)(&c->value.s);
c=create_context("cs_nmos:property:Area");
Pcs_nmos_property_Area=(float *)(&c->value.s);
c=create_context("cs_nmos:property:Vos");
Pcs_nmos_property_Vos=(float *)(&c->value.s);
c=create_context("cs_nmos:property:Power");
Pcs_nmos_property_Power=(float *)(&c->value.s);
c=create_context("cs_nmos:config:shift:Adc");
Pcs_nmos_config_shift_Adc=(float *)(&c->value.s);
c=create_context("cs_nmos:config:factor:Adc");
Pcs_nmos_config_factor_Adc=(float *)(&c->value.s);
c=create_context("cs_nmos:config:shift:CMRR");
Pcs_nmos_config_shift_CMRR=(float *)(&c->value.s);
c=create_context("cs_nmos:config:factor:CMRR");
Pcs_nmos_config_factor_CMRR=(float *)(&c->value.s);

            return TCL_OK;
        }
        int Gamma_cs_nmos_Register(Tcl_Interp *interp) {
            Tcl_CreateCommand(interp, "::Gamma::cs_nmos::heatmap", tcl_gamma_cs_nmos_heatmap_cmd, NULL, NULL);
            Tcl_CreateCommand(interp, "::Gamma::cs_nmos::random", tcl_gamma_cs_nmos_random_cmd, NULL, NULL);
            Tcl_CreateCommand(interp, "::Gamma::cs_nmos::random_breed", tcl_gamma_cs_nmos_random_breed_cmd, NULL, NULL);
            Tcl_CreateCommand(interp, "::Gamma::cs_nmos::random_breed_single", tcl_gamma_cs_nmos_random_breed_single_cmd, NULL, NULL);
            Tcl_CreateCommand(interp, "::Gamma::cs_nmos::breed", tcl_gamma_cs_nmos_breed_cmd, NULL, NULL);
            Tcl_CreateCommand(interp, "::Gamma::cs_nmos::op", tcl_gamma_cs_nmos_op_cmd, NULL, NULL);
            Tcl_CreateCommand(interp, "::Gamma::cs_nmos::import", tcl_gamma_cs_nmos_import_cmd, NULL, NULL);
            Tcl_CreateCommand(interp, "::Gamma::cs_nmos::export", tcl_gamma_cs_nmos_export_cmd, NULL, NULL);
            return TCL_OK;
        }
    
