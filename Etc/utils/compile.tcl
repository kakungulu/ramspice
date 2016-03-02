#!/usr/bin/tclsh8.5
source $::env(RAMSPICE)/Etc/utils/config.tcl
namespace eval ::templates:: {}
proc c {} {
    return [clock format [clock seconds]]
}
set ::compilation_time [clock seconds]
source $::env(RAMSPICE)/Etc/utils/templates.tcl
source $::env(RAMSPICE)/Etc/utils/unknown.tcl
array set ::opt {
    bins {ramspice gamma}
    targets {regular silent debug}
}
set ::opt(bins) ramspice
set ::opt(targets) regular
array set ::bin2flag {
    ramspice SPICE_COMPILATION gamma GAMMA_COMPILATION
}
array set ::target2flag {
    regular TCL_MSG_REG silent TCL_MSG_SILENT debug TCL_MSG_DEBUG
}
set flag {}
foreach arg $argv {
    if {[regexp {^\-(.*)$} $arg -> flag]} continue
    if {![info exists ::opt($flag)]} {
        Error: Available flags are [array names ::opt]
        exit
    }
    set ::opt($flag) $arg
}
# Gamma support comes in here:
set gamma_c_mtime 0
if {[file exists $::env(RAMSPICE)/Gamma/Gamma.c]} {
    set gamma_c_mtime [file mtime $::env(RAMSPICE)/Gamma/Gamma.c]
}
if {($gamma_c_mtime< [file mtime $::env(RAMSPICE)/Gamma/Gamma.tcl])||($gamma_c_mtime< [file mtime $::env(RAMSPICE)/Gamma/virtual_machine.tcl]) } {
    source $::env(RAMSPICE)/Gamma/virtual_machine.tcl
    set O [open $::env(RAMSPICE)/Gamma/Gamma.h w]
    puts $O "#ifndef Gamma"
    puts $O "#define Gamma"
    puts $O "#include \"ramspice_types.h\""
    puts $O "#include \"Gamma/virtual_machine.h\""
    #puts $O "#include <tcl.h>"
    close $O
    set O [open $::env(RAMSPICE)/Gamma/Gamma.c w]
    puts $O "#include <stdio.h>"
    puts $O "#include <stdlib.h>"
    puts $O "#include \"Data/ctree.h\""
    puts $O "#include \"Gamma/Gamma.h\""
    close $O
    source $::env(RAMSPICE)/Gamma/Gamma.tcl
    GammaTclInterface
    set O [open $::env(RAMSPICE)/Gamma/Gamma.h a]
    puts $O "#endif"
    close $O
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
    set bracket_rank 0
    set lines [split $c_code \n]
    set num_of_vars [regexp -all {\$} $lines]
    if {$num_of_vars} {
        #        puts "Info: File contains $num_of_vars variables"
    }
    for {set i 0} {$i<[llength $lines]} {incr i ; set line [lindex $lines $i]} {
        set line [lindex $lines $i]
        #	    puts "$i/[llength $lines] $line"
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
        if {[regexp {^\s*\#tcl\s+(.*)$} $line -> tcl_command] || [regexp {^\s*\#([A-Z]\S+:.*)$} $line -> tcl_command]} {
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
        while {[regexp {\$\{(:*[a-zA-Z0-9_]+)\(([^\(\)]+)\)\}} $line both varname key] } {
            set subst_key [subst $key]
            # puts "$i Subst? $varname\($key\)"
            #           if {![uplevel "info exists $varname\($subst_key\)"]} {
                #	        uplevel "set $varname\($subst_key\) 0"
            #	    }
            if {[uplevel "info exists $varname\($subst_key\)"]} {
                set val [lindex [uplevel "array get $varname $subst_key"] 1]
                # puts "$i Substituting $both with $val"
                regsub -all {\$} $key "\\\$" key
                regsub -all "\\\$\\\{$varname\\\($key\\\)\\\}" $line $val line
                # puts "$i YES line after=$line"
            } else {
                regsub -all $both $line "\$`$varname\($key\)" line
                puts "$i NO line after=$line"
                exit
            }
        }
        while {[regexp {\$\{(:*[a-zA-Z0-9_]+)\}} $line -> varname] } {
            # # puts "Subst? $varname"
            if {[uplevel "info exists $varname"] && ![uplevel "array exists $varname"]} {
                set val [uplevel "set $varname"]
                # # puts "Info: Substituting $varname with $val"
                regsub -all "\\\$\\\{$varname\\\}" $line $val line
            } else {
                regsub -all "\\\$\\\{$varname\\\}" $line "\$`$varname" line
            }
        }
        while {[regexp {\$(:*[a-zA-Z0-9_]+)} $line -> varname] } {
            # # puts "Subst? $varname"
            if {[uplevel "info exists $varname"] && ![uplevel "array exists $varname"]} {
                set val [uplevel "set $varname"]
                # # puts "Info: Substituting $varname with  $val"
                regsub -all "\\\$$varname" $line $val line
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
if {![file exists $::env(RAMSPICE)/bin]} {
    file mkdir $::env(RAMSPICE)/bin
}
proc all_paths {{dir .} {visited {}}} {
    set retval $visited
    lappend retval $dir
    foreach path [glob -nocomplain $dir/*] {
        if {![file isdirectory $path]} continue
        if {[lsearch $retval $path]!=-1} continue
        set retval [all_paths $path $retval]
    }
    return $retval
}
if {![file exists ~/public_html]} {
    file mkdir ~/public_html
}
# Look for new netlists

set uncompiled_topologies {}
set CC [open $::env(RAMSPICE)/cc.csh w]
puts $CC "#!/bin/tcsh"
puts $CC "setenv PATH /opt/centos/devtoolset-1.0/root/usr/bin/:\$PATH"
foreach netlist_file [glob -nocomplain $::env(RAMSPICE)/Etc/Topologies/*.gsp] {
    set topology [file rootname [file tail $netlist_file]]
    if {![file exists $::env(RAMSPICE)/Etc/Templates/$topology]} {
        file mkdir $::env(RAMSPICE)/Etc/Templates/$topology
    }
    set compile_topology 0
    if {![file exists $::env(RAMSPICE)/Etc/Templates/$topology/$topology.c]} {
        set compile_topology 1
    } elseif {[file mtime $::env(RAMSPICE)/Etc/Templates/$topology/$topology.c]<[file mtime $netlist_file]} {
        set compile_topology 1
    }
    if {$compile_topology} {
        lappend uncompiled_topologies $topology
        puts $CC "$::env(RAMSPICE)/GammaCC/circuit_compiler.tcl -topology $topology | & tee -a log"
        puts $CC "~/auto_indent.tcl $::env(RAMSPICE)/Etc/Templates/$topology/$topology.c"
    }
}
close $CC
set CC [open $::env(RAMSPICE)/Gamma/Data/init_gamma.ignore.c w]
foreach netlist_file [glob -nocomplain $::env(RAMSPICE)/Etc/Topologies/*.gsp] {
    set topology [file rootname [file tail $netlist_file]]
    if {![file exists $::env(RAMSPICE)/Etc/Templates/$topology/$topology.c]} continue
    puts $CC "Gamma_${topology}_Init(interp);"
}    
close $CC
set CC [open $::env(RAMSPICE)/Gamma/Data/register_gamma.ignore.c w]
foreach netlist_file [glob -nocomplain $::env(RAMSPICE)/Etc/Topologies/*.gsp] {
    set topology [file rootname [file tail $netlist_file]]
    if {![file exists $::env(RAMSPICE)/Etc/Templates/$topology/$topology.c]} continue
    puts $CC "Gamma_${topology}_Register(interp);"
}    
close $CC
set CC [open $::env(RAMSPICE)/Gamma/Data/init_gamma.ignore.h w]
puts $CC "#ifndef INIT_GAMMA"
puts $CC "#define INIT_GAMMA"
foreach netlist_file [glob -nocomplain $::env(RAMSPICE)/Etc/Topologies/*.gsp] {
    set topology [file rootname [file tail $netlist_file]]
    if {![file exists $::env(RAMSPICE)/Etc/Templates/$topology/$topology.c]} continue
    set I [open $::env(RAMSPICE)/Etc/Templates/$topology/$topology.c r]
    while {[gets $I line]>=0} { 
        if {![regexp {^int\s+(\S+)\s+\{\s*$} $line -> cmd]} continue
        puts $CC "$cmd;"
    }
}    
puts $CC "#endif"
close $CC
if {$uncompiled_topologies!={}} {
    puts "Info: $uncompiled_topologies need compiling. Run cc.csh after this and rerun comp."
} else {
    set new_gamma_c_files 0
    foreach netlist_file [glob -nocomplain $::env(RAMSPICE)/Etc/Topologies/*.gsp] {
        set topology [file rootname [file tail $netlist_file]]
        if {[file mtime $::env(RAMSPICE)/Etc/Templates/$topology/$topology.c]>[file mtime $::env(RAMSPICE)/Gamma/Data/ctree.c]} {
            set new_gamma_c_files 1
            break
        }
    }
    if {$new_gamma_c_files} {
        exec touch $::env(RAMSPICE)/Gamma/Data/ctree.c
    }
}	
exec chmod +x $::env(RAMSPICE)/cc.csh

foreach binary $::opt(bins) {
    set binary_flag $::bin2flag($binary)
    foreach target $::opt(targets) {
        set target_flag $::target2flag($target)
        # foreach binary {ramspice } binary_flag {SPICE_COMPILATION } 
        #   foreach target [list  debug] target_flag { TCL_MSG_DEBUG} 
        define_message_templates
        set preprocessed /tmp/${binary}_build/preprocessed-$target
        set object_files /tmp/${binary}_build/object_files-$target
        set target_name $::env(RAMSPICE)/bin/${binary}-$target
        ###############
        # Make sure all scratch paths are there
        foreach var {preprocessed object_files } {
            set pwd [pwd]
            cd /
            foreach dir [file split [set $var]] {
                if {$dir=={}} continue
                if {![file exists $dir]} {
                    puts "Info: new build dir: $dir"
                    file mkdir $dir
                }
                cd $dir
            }
            cd $pwd
        }
        
        set O [open compile${binary}-$target.tcsh w]
        puts $O "#!/bin/tcsh"
        puts $O "setenv PATH /opt/centos/devtoolset-1.0/root/usr/bin/:\$PATH"
        set pre_c "/usr/bin/gcc -I${preprocessed}  -fPIC -lm -ltcl8.5  -g -O5 -D $binary_flag -Wall -Wextra -Wmissing-prototypes -Wstrict-prototypes -Wnested-externs -Wold-style-definition -Wredundant-decls -Wconversion -I${preprocessed} -I${preprocessed}/ngspice/root -I/usr/include/c++/4.4.4/x86_64-redhat-linux -ldb-6.0 -I${preprocessed}/ngspice/root/maths/poly -I${preprocessed}/ngspice/root/frontend -I${preprocessed}/ngspice/root/spicelib/devices -I${preprocessed}/ngspice/root/xspice/icm/analog -D SENSDEBUG -D X_DISPLAY_MISSING -D CIDER -D SIMULATOR -c"
        set pre_cpp "/usr/bin/g++  -I${preprocessed} -fPIC -lm -ltcl8.5  -g -O5 -D $binary_flag -Wall -Wextra -fpermissive -Wredundant-decls -Wconversion -I${preprocessed} -I${preprocessed}/ngspice/root/maths/poly -I${preprocessed}/ngspice/root/frontend -I${preprocessed}/ngspice/root/spicelib/devices -I${preprocessed}/ngspice/root/xspice/icm/analog -D X_DISPLAY_MISSING -D CIDER -D SIMULATOR -D HAVE_DECL_BASENAME -c"
        array set mtimes {}
        set copied_filenames {}
        foreach path [all_paths] {
            foreach file [glob -nocomplain $path/*.vm.tcl] {
                source $file
            }
        }   
        set skip_compilation 1
        foreach path [all_paths] {
            if {$binary=="gamma" && [string match *spice* $path]} continue
            foreach file [glob -nocomplain $path/*.h $path/*.c $path/*.cpp] {
                if {$binary=="ramspice" && [string match *Gamma/main.c $file]} continue
                if {[string match *.ignore.c $file]} continue
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
                    #	    puts "Warning: $target_file is renamed"
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
                set skip_compilation 0
                set I [open $file r]
                set ::templates::O [open $target_file w]
                set ::rank 0
                tcl_preprocessor [read $I]
                close $::templates::O
                close $I
            }
        }    
        if {$skip_compilation} {
            puts "Info: ${binary}-${target} is up to date"
            continue
        }
        puts "Info: Creating compilation script [c]"
        foreach path [all_paths ${preprocessed}] {
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
        puts $O exit
        close $O
        
        set O [open link${binary}-$target.tcsh w]
        puts $O "#!/bin/tcsh"
        puts $O "setenv PATH /opt/centos/devtoolset-1.0/root/usr/bin/:\$PATH"
        puts $O "echo \"Info: $object_files links to $target_name\""
        puts $O "g++ -L /usr/bin/lib -lm -ltcl8.5  -ldl $object_files/*.o -o $target_name | & tee -a log"
        puts $O exit
        close $O
        if {![file exists $object_files]} {
            file mkdir $object_files
        }
        exec chmod +x ./compile${binary}-$target.tcsh
        exec chmod +x ./link${binary}-$target.tcsh
        
        puts "Info: Compiling [c]"
        catch {exec ./compile${binary}-$target.tcsh}
	set I [open log r]
	while {[gets $I line]>=0} {
	    if {![regexp {error:} $line]} continue
	    if {[regexp {Derror:} $line]} continue
	    puts $line
	}
	close $I
        puts "Info: Linking [c]"
        catch {exec ./link${binary}-$target.tcsh}
        #        file delete compile${binary}-$target.tcsh
        #        file delete link${binary}-$target.tcsh
    }
    if {![file exists $::env(RAMSPICE)/${binary}]} {
        file link -s ${binary} bin/${binary}-regular
    }
}
exit
