#!/bin/tcsh
setenv PATH /opt/centos/devtoolset-1.0/root/usr/bin/:$PATH
/home/yishai/ramspice/GammaCC/circuit_compiler.tcl -topology cs_nmos | & tee -a log
~/auto_indent.tcl /home/yishai/ramspice/Etc/Templates/cs_nmos/cs_nmos.c
/home/yishai/ramspice/GammaCC/circuit_compiler.tcl -topology diffpair_pmos | & tee -a log
~/auto_indent.tcl /home/yishai/ramspice/Etc/Templates/diffpair_pmos/diffpair_pmos.c
/home/yishai/ramspice/GammaCC/circuit_compiler.tcl -topology diffpair_output_nmos | & tee -a log
~/auto_indent.tcl /home/yishai/ramspice/Etc/Templates/diffpair_output_nmos/diffpair_output_nmos.c
/home/yishai/ramspice/GammaCC/circuit_compiler.tcl -topology diffpair_nmos | & tee -a log
~/auto_indent.tcl /home/yishai/ramspice/Etc/Templates/diffpair_nmos/diffpair_nmos.c
/home/yishai/ramspice/GammaCC/circuit_compiler.tcl -topology cs_pmos | & tee -a log
~/auto_indent.tcl /home/yishai/ramspice/Etc/Templates/cs_pmos/cs_pmos.c
/home/yishai/ramspice/GammaCC/circuit_compiler.tcl -topology diffpair_output_pmos | & tee -a log
~/auto_indent.tcl /home/yishai/ramspice/Etc/Templates/diffpair_output_pmos/diffpair_output_pmos.c
/home/yishai/ramspice/GammaCC/circuit_compiler.tcl -topology op_amp_inst | & tee -a log
~/auto_indent.tcl /home/yishai/ramspice/Etc/Templates/op_amp_inst/op_amp_inst.c
