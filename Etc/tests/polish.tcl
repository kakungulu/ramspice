# \
exec $RAMSPICE/ramspice $0 $argv
get_opts

set polish_expr [DERIVE a (1-3)*a]
Info: polish_expr=$polish_expr
Info: simplified=[polish2expr $polish_expr]

exit
