#!/usr/bin/tclsh8.5


proc scalar2double {file} {
    if {[file isdirectory $file]} {
        foreach sub_file [glob -nocomplain $file/*] {
	    scalar2double $sub_file
	}
	return
    }
    set I [open $file r]
    set O [open /tmp/tmp w+]
    while {[gets $I line]>=0} {
        regsub -all scalar $line double line
	puts $O $line
    }
    close $O
    close $I
    file copy -force /tmp/tmp $file
}

scalar2double $argv


