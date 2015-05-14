#!/bin/tcsh
setenv PATH /opt/centos/devtoolset-1.0/root/usr/bin/:$PATH
g++ -L /usr/bin/lib -lm -ltcl8.5  -ldl  -ldb-4.7  /tmp/gamma_build/object_files-debug/*.o -o /home/ystatter/elgon/bin/gamma-debug | & tee -a log
