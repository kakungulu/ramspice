#!/usr/bin/tclsh8.5

proc detect_large_files {file} {
    if {[file isdirectory $file]} {
        foreach file [glob -nocomplain $file/*] {
	    detect_large_files $file
	}
	return
    }
    if {[string match *.db $file]} return
    if {[file size $file]>50*1024*1024} {
        puts [file normalize $file]
    }
}

detect_large_files .
