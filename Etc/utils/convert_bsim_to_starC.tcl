# \
exec $RAMSPICE/ramspice $0 $argv
get_opts

array set ::version_to_level {
    49 3v0
    49 3v1
    49 3v2
    49 3v3
    49 3v32
    54 4v0
    54 4v1
    54 4v2
    54 4v3
    54 4v4
    54 4v5
    54 4v6
    54 4v7
}

default ::opt(tech) tsmc040
default ::opt(family) tsmc040
default ::opt(tcl_tech_file) $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/$::opt(tech).tcl
if {[file exists $::opt(tcl_tech_file)]} {
    source $::opt(tcl_tech_file)
} else {
    set I [open $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/$::opt(tech).sp r]
    set tech_data ""
    while {[gets $I line]>=0} {
        if {[regexp {^\s*.model} $line]} {
            append tech_data "\n"
        }
        append tech_data $line
    }
    close $I
    regsub -all {\+} $tech_data {} tech_data
    regsub -all {\=} $tech_data {} tech_data
    regsub -all {\(} $tech_data "\{" tech_data
    regsub -all {\)} $tech_data "\}" tech_data
    proc .model {name - payload} {
        lassign [split $name _] type corner bin
        foreach {param value} $payload {
            set ::TECH($type,$corner,$bin,$param) $value
        }
    }
    eval $tech_data
    set O [open $::env(RAMSPICE)/Etc/Tech_DB/$::opt(tech)/$::opt(tech).tcl w]
    puts $O [list array set ::TECH [array get ::TECH]]
    close $O
}

set any_key [lindex [arra names ::TECH *,level] 0]
set level $::TECH($any_key)
default ::opt(version) $::version_to_level($level)



exit



