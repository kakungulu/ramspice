#!/usr/bin/tclsh8.5

if {![info exists ::env(RAMSPICE)]} {
    set ::env(RAMSPICE) [pwd]
}
if {[file exists $::env(RAMSPICE)/ramspice]} {
    file delete $::env(RAMSPICE)/ramspice
}
file link -s ramspice $::env(RAMSPICE)/bin/ramspice-$argv

