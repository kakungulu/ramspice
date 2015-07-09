# \
exec $RAMSPICE/ramspice $0 $argv
set O [open ~/tst w]
puts $O 123
close $O
set ::HTML [open ~/out.html w]
set web_output 1
<h3> $::env(QUERY_STRING)</h3>


close $::HTML
exit
