foreach file [glob ngspice/*.h] {
    set I [open $file r]
    set C [read $I]
    close $I
    set O [open $file w]
    foreach line [split $C \n] {
        regsub -all {^(\s*)#include\s+\\"} $line {\1#include "} line
        regsub -all {^(\s*)#include\s+\"ngspice/} $line {\1#include \"} line
        puts $O $line
    }
    close $O
}


