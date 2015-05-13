# \
exec $RAMSPICE/ramspice $0 $argv

get_opts

default opt(tech) tsmc018
default opt(device) nch
ETA [llength [glob -nocomplain $::env(RAMSPICE)/Tech_DB/$::opt(tech)/4d/*:*:*:*/$::opt(tech)_$::opt(device)_ids.db]]
foreach rez_path [glob -nocomplain $::env(RAMSPICE)/Tech_DB/$::opt(tech)/4d/*:*:*:*] {
    skip {![file exists $rez_path/$::opt(tech)_$::opt(device)_ids.db]}
    ETA
    Info: Collecting [file tail $rez_path]
    set O [open /tmp/tmp.csh w]
    puts $O "#!/bin/tcsh"
    puts $O "$::env(RAMSPICE)/utils/4d_collect_random_sample.tcl -topv 1.8 -tech $::opt(tech) -device $::opt(device) -process ss -size 500 -source $rez_path -interpolation LUT | tee /tmp/log"
    close $O
    exec chmod 777 /tmp/tmp.csh
    exec /tmp/tmp.csh
}

