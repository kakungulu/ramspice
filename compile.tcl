#!/usr/bin/tclsh8.5
source $::env(RAMSPICE)/config.tcl
set ::exclude {
    parse-bison.c
    inpptree-parser.c
    dlmain.c
    cmexport.c
    inp2dot.c
}
set ::bypass_preprocessor {
    mod_lex.c
    ifs_lex.c
}
set preprocessed /tmp/ramspice_build/preprocessed
set object_files /tmp/ramspice_build/object_files
set target_name $::env(RAMSPICE)/ramspice
set SP_PREPROCESS_FLAG ""
if {[lsearch $argv -sp] != -1} {
    set target_name $::env(RAMSPICE)/ramspice_sp
    set object_files [file join [file dirname $object_files] object_files_sp]
    set SP_PREPROCESS_FLAG "-D SINGLE_PRECISION"
}
namespace eval ::templates:: {}
proc c {} {
    return [clock format [clock seconds]]
}
source $::env(RAMSPICE)/templates.tcl
source $::env(RAMSPICE)/unknown.tcl


# DotCamel support comes in here:
source $::env(RAMSPICE)/DotCamel/virtual_machine.tcl
set O [open $::env(RAMSPICE)/DotCamel/DotCamelCommands.h w]
puts $O "#ifndef DotCamelCommands"
puts $O "#define DotCamelCommands"
puts $O "#include \"ramspice_types.h\""
puts $O "#include \"DotCamel/virtual_machine.h\""
close $O
set O [open $::env(RAMSPICE)/DotCamel/DotCamelCommands.c w]
puts $O "#include \"DotCamel/DotCamelCommands.h\""
close $O
source $::env(RAMSPICE)/DotCamel/DotCamelCommands.tcl
DotCamelTclInterface
set O [open $::env(RAMSPICE)/DotCamel/DotCamelCommands.h a]
puts $O "#endif"
close $O

###############
# Make sure all scratch paths are there
foreach var {preprocessed object_files} {
    set pwd [pwd]
    cd /
    foreach dir [file split [set $var]] {
        if {$dir=={}} continue
        if {![file exists $dir]} {
            file mkdir $dir
        }
        cd $dir
    }
    cd $pwd
}
###############
# Preprocessed code files are beutified automatically
# Procedure to figure out indentation. 
proc count_braces {line minvar maxvar} {
    upvar $minvar min
    upvar $maxvar max
    set max 0
    set min 0
    set count 0
    for {set i 0} {$i < [string length $line]} {incr i} {
        set c [string index $line $i]
        if {$c=="\\"} {
            incr i
            continue
        }
        if {$c=="\{"} {
            incr count
        }
        if {$c=="\}"} {
            incr count -1
        }
        if {$count<$min} {
            set min $count
        }
        if {$count>$max} {
            set max $count
        }
    }
    return $count
}
###############
# Code print-outs need to go through this procedure
proc print_line {line} {
    regsub -all {^\s*} $line {} line
    if {[string length $line]==0} return
    if {[regexp {^\S+:\s*$} $line]} {
        puts $::templates::O $line
	return
    }
    set increment [count_braces $line min max]
    if {$min<0} {
        incr ::rank $min
        puts -nonewline $::templates::O [string repeat "    " $::rank]
        incr ::rank [expr -$min]
    } else {
        puts -nonewline $::templates::O [string repeat "    " $::rank]
    }
    incr ::rank $increment
    puts $::templates::O $line
}

###############
# The preprocessor extends gcc's built in preprocessor by calling Tcl procedures on thew fly
# All 'original' proprocessor directives should have either of the following format:
#   #tcl <free-style Tcl code>    example: #tcl puts "Warning: compiling this line"
#   #[A-Z]\S+: <arg1>...<argN>    example: #Info: "Starting %s" progname
# Use the templates.tcl script as reference to how a preprocessor-directive-definition should look like.
proc tcl_preprocessor {c_code} {
    set mode direct
    set bracket_rank 0
    foreach line [split $c_code \n] {
        if {[regexp {^\s*\/\/} $line]} {
            print_line $line
            continue
        }
	# Sometimes you can find Tcl code inside C. Don't pre-substitute variables in those.
        if {[regexp {^\s*Tcl_Eval} $line]} {
            print_line $line
            continue
        }
	# Gather all code inside a Tcl preprocessing directive according to bracket nesting
        if {$mode=="tcl"} {
            incr bracket_rank [regexp -all {\{} $line]
            incr bracket_rank -[regexp -all {\}} $line]
            append template_body \n
            append template_body $line
	    # If this is the end of the block, send what you got to the preprocessor to evaluate and change mode
            if {$bracket_rank==0} {
                set mode direct
                uplevel #0 $template_body
            }
            continue
        } 
	# Identify a beginning of Tcl preprocessed block
        if {[regexp {^\s*\#tcl\s+(.*)$} $line -> tcl_command] || [regexp {^\s*\#([A-Z]\S+: .*)$} $line -> tcl_command]} {
            set mode tcl
            set bracket_rank [regexp -all {\{} $line]
            incr bracket_rank -[regexp -all {\}} $line]
            set template_body $tcl_command
	    # one-liners can be precessed here
            if {$bracket_rank==0} {
                set mode direct
                uplevel #0 $template_body
            }
            continue
        }
     # Substitute Tcl variables everywhere else.
	while {[regexp {\$\{(:*[a-zA-Z0-9_]+)\}} $line -> varname] } {
	    if {[uplevel "info exists $varname"] && ![uplevel "array exists $varname"]} {
		regsub -all "\\\$\\\{$varname\\\}" $line [uplevel "set $varname"] line
	    } else {
		regsub -all "\\\$\\\{$varname\\\}" $line "\$`$varname" line
	    }
	}
        while {[regexp {\$(:*[a-zA-Z0-9_]+)} $line -> varname] } {
            if {[uplevel "info exists $varname"] && ![uplevel "array exists $varname"]} {
                regsub -all "\\\$$varname" $line [uplevel "set $varname"] line
            } else {
                regsub -all "\\\$$varname" $line "\$`$varname" line
            }
        }
        regsub -all {\$`} $line {\$} line
	# print simplified and substituted lines here
        print_line $line
    }
}
proc tcl_preprocessor {c_code} {
    set bracket_rank 0
    set lines [split $c_code \n]
    for {set i 0} {$i<[llength $lines]} {incr i ; set line [lindex $lines $i]} {
        set line [lindex $lines $i]
        if {[regexp {^\s*\/\/} $line]} {
            print_line $line
            continue
        }
	# Sometimes you can find Tcl code inside C. Don't pre-substitute variables in those.
        if {[regexp {^\s*Tcl_Eval} $line]} {
            print_line $line
            continue
        }
	# Identify a beginning of Tcl preprocessed block
        if {[regexp {^\s*\#tcl\s+(.*)$} $line -> tcl_command] || [regexp {^\s*\#([A-Z]\S+: .*)$} $line -> tcl_command]} {
            set bracket_rank [regexp -all {\{} $line]
            incr bracket_rank -[regexp -all {\}} $line]
            set template_body $tcl_command
	    # one-liners can be precessed here
	    while {($bracket_rank!=0)&&($i<[llength $lines])} {
	        incr i
		set line [lindex $lines $i]
                append template_body \n
                append template_body $line
                incr bracket_rank [regexp -all {\{} $line]
                incr bracket_rank -[regexp -all {\}} $line]
	    }
	    uplevel #0 $template_body
            continue
        }
     # Substitute Tcl variables everywhere else.
	while {[regexp {\$\{(:*[a-zA-Z0-9_]+)\}} $line -> varname] } {
	    if {[uplevel "info exists $varname"] && ![uplevel "array exists $varname"]} {
		regsub -all "\\\$\\\{$varname\\\}" $line [uplevel "set $varname"] line
	    } else {
		regsub -all "\\\$\\\{$varname\\\}" $line "\$`$varname" line
	    }
	}
        while {[regexp {\$(:*[a-zA-Z0-9_]+)} $line -> varname] } {
            if {[uplevel "info exists $varname"] && ![uplevel "array exists $varname"]} {
                regsub -all "\\\$$varname" $line [uplevel "set $varname"] line
            } else {
                regsub -all "\\\$$varname" $line "\$`$varname" line
            }
        }
        regsub -all {\$`} $line {\$} line
	# print simplified and substituted lines here
        print_line $line
    }
}
set O [open log w]
puts $O "#[clock format [clock seconds]]"
close $O
set O [open compile.tcsh w]
puts $O "#!/bin/tcsh"
puts $O "setenv PATH /opt/centos/devtoolset-1.0/root/usr/bin/:\$PATH"
set pre_c "/usr/bin/gcc -I${preprocessed} -I. -lm -ltcl8.5  -g -O5 -Wall -Wextra -Wmissing-prototypes -Wstrict-prototypes -Wnested-externs -Wold-style-definition -Wredundant-decls -Wconversion -I/usr/include/c++/4.4.4/x86_64-redhat-linux -I${preprocessed}/BerkeleyDB.6.0/include -IBerkeleyDB.6.0/include -ldb-6.0  -I${preprocessed}/maths/poly -Imaths/poly -I${preprocessed}/frontend -Ifrontend -I${preprocessed}/spicelib/devices -Ispicelib/devices -I${preprocessed}/xspice/icm/analog -Ixspice/icm/analog $SP_PREPROCESS_FLAG -D SENSDEBUG -D X_DISPLAY_MISSING -D CIDER -D SIMULATOR -c"
set pre_cpp "/usr/bin/g++  -I${preprocessed} -lm -ltcl8.5  -g -O5 -Wall -Wextra -fpermissive -Wredundant-decls -Wconversion -I${preprocessed}/BerkeleyDB.6.0/include -I${preprocessed}/maths/poly -I${preprocessed}/frontend -I${preprocessed}/spicelib/devices -I${preprocessed}/xspice/icm/analog -D X_DISPLAY_MISSING -D CIDER -D SIMULATOR -D HAVE_DECL_BASENAME $SP_PREPROCESS_FLAG -c"
puts "Info: Expanding templates"
array set mtimes {}
set copied_filenames {}
foreach path {. */ */*/ */*/*/ */*/*/*/} {
    foreach file [glob -nocomplain $path/*.vm.tcl] {
        source $file
    }
}   
foreach path {. */ */*/ */*/*/ */*/*/*/} {
    foreach file [glob -nocomplain $path/*.h $path/*.c $path/*.cpp] {
        set filename [file tail $file]
        set fileext [file extension $file]
        set fileroot [file rootname $filename]
        set tmpdir [join [concat ${preprocessed} [lrange [split [file dirname [file normalize $file]] /] [llength [split [pwd] /]] end]] /]
        if {[string match test_* $filename]} continue
        if {![file exists $tmpdir]} {
            file mkdir $tmpdir
        }
	set target_file $fileroot$fileext
	set alternate_index 0
	while {[lsearch $copied_filenames $target_file]!=-1} {
	    set target_file $fileroot$alternate_index$fileext
	    incr alternate_index
	}
	lappend copied_filenames $target_file
	set target_file $tmpdir/$target_file
        set mtimes($target_file) [file mtime $file]
	if {[lsearch $::bypass_preprocessor $filename]!=-1} {
	    file copy -force $file $tmpdir
	    continue
	}
	if {[file exists  $target_file]} {
	    if {[file mtime $target_file]>[file mtime $file]} continue
	}
	puts "Info: Preprocessing $file to $target_file"
        set I [open $file r]
        set ::templates::O [open $target_file w]
        set ::rank 0
        tcl_preprocessor [read $I]
        close $::templates::O
        close $I
    }
}    
puts "Info: Creating compilation script [c]"
foreach path [list ${preprocessed} ${preprocessed}/*/ ${preprocessed}/*/*/ ${preprocessed}/*/*/*/ ${preprocessed}/*/*/*/*/] {
    foreach file [glob -nocomplain $path/*.c $path/*.cpp] {
        set filename [file tail $file]
        set fileext [file extension $file]
        set fileroot [file rootname $filename]
        set tmpdir [join [concat ${preprocessed} [lrange [split [file dirname [file normalize $file]] /] [llength [split [pwd] /]] end]] /]
        if {[string match ${preprocessed}/bdb* $file]} continue
        if {[string match test_* $filename]} continue
        if {[lsearch $argv $filename]==-1} {
            if {[lsearch $::exclude $filename]!=-1} {
              #  puts "Info: skipping $file [c]"
                if {[file exists $object_files/$fileroot.o]} {
                    puts "Info: deleting $fileroot.o [c]"
                    file delete $object_files/$fileroot.o
                }
                continue
            }    
            if {([file exists $object_files/$fileroot.o])&&([info exists mtimes($file)])} {
                if {[file mtime $object_files/$fileroot.o]>=$mtimes($file)} {
                    continue
                }
            }
        }
        puts $O "echo \"Info: compiling $file\""
        switch $fileext {
            .c {
                puts $O "$pre_c $file | & tee -a log"
                puts $O "mv $fileroot.o $object_files"
            }
            .cpp {
                puts $O "$pre_cpp $file | & tee -a log"
                puts $O "mv $fileroot.o $object_files"
            }
            default {
                puts "Error: undefined file extension $file"
            }
        }
    }
}
close $O

set O [open link.tcsh w]
puts $O "#!/bin/tcsh"
puts $O "setenv PATH /opt/centos/devtoolset-1.0/root/usr/bin/:\$PATH"
puts $O "g++ -L BerkeleyDB.6.0/lib/ -L /usr/bin/lib -lm -ltcl8.5  -ldl  -ldb-4.7  $object_files/*.o -o $target_name | & tee -a log"
close $O
if {![file exists $object_files]} {
    file mkdir $object_files
}
exec chmod +x ./compile.tcsh
exec chmod +x ./link.tcsh

puts "Info: Compiling [c]"
exec ./compile.tcsh
puts "Info: Linking [c]"
exec ./link.tcsh
file delete compile.tcsh
file delete link.tcsh


