#!/usr/bin/tclsh8.5

set draft /tmp/tagging_draft
if {![file exists $draft]} {
    file mkdir $draft
}
regsub -all {:} [join [concat TAG $::env(HOSTNAME) [clock format [clock seconds]]] _] {_} tag_ver
set O [open $draft/$tag_ver.tcl w]
puts $O "#!/usr/bin/tclsh8.5"
puts $O {
    proc % {path filename content} {
        if {![file exists $path]&&$path!=""} {
	    file mkdir $path
	}
	regsub {^/+} $path/$filename {} filename
	puts "Extracting $filename"
	set O [open $filename w]
	puts $O $content
	close $O
	exec chmod +x $filename
    }
}
set zip_list [list exec /bin/gzip -9 $draft/$tag_ver.tcl]
set zip_index 0
foreach path {. */ */*/ */*/*/ */*/*/*/} {
    foreach file [glob -nocomplain $path/*.{h,c,cpp,tcl,tcsh,html,htm,lib,txt,sp} $path/.*.{h,c,cpp,tcl,tcsh,html,htm,lib,txt,sp} $path/setup $path/rssh] {
        set filename [file tail $file]
	if {[string match *TAG* $filename]} continue
	set path [join [lrange [split [file dirname [file normalize $file]] /] [llength [split [pwd] /]] end] /]
	puts "Tagging [file normalize $file]"
	set I [open $file r]
	puts $O [list % $path $filename [read $I]]
	close $I
    }
}    
close $O
eval $zip_list
# exec /usr/bin/scp $tag_ver.tcl.gz ystatter@linux1.engr.colostate.edu:mengo
if {![file exists ~/TAGS]} {
    file mkdir ~/TAGS
}
file copy $draft/$tag_ver.tcl.gz ~/TAGS
file delete $draft/$tag_ver.tcl.gz



