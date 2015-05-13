#!/bin/tcsh
setenv PATH /opt/centos/devtoolset-1.0/root/usr/bin/:$PATH
g++ -L /usr/bin/lib -lm -ltcl8.5  -ldl  -ldb-4.7  /tmp/ramspice_build/object_files-silent/*.o -o /home/ystatter/elgon/bin/ramspice-silent | & tee -a log
