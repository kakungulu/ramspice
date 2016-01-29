# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
default ::opt(tech) tsmc040
set ::bsim_access_fields {Ids Gm Gmb Gds Cddr Cdgr Cdsr Cdbr Csdr Csgr Cssr Csbr Cgdr Cggr Cgsr Cgbr}

array set units {
    I A
    G Mho
    C F
}
foreach var $::bsim_access_fields val [get_bsim_tsmc040 nch ss 1.1 1.1 0 100e-9 200e-9] {
    Info: $var=[eng $val $units([string index $var 0])]
}

exit
