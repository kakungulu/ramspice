# \
exec $RAMSPICE/ramspice $0 $argv
##########################################################################
######### Read input
##########################################################################
set fe_path $::env(RAMSPICE)/Gamma/Web/FE
set ::process_path $fe_path/gamma_process
if {![file exists $::process_path]} {
    file mkdir $::process_path
}
set authenticate 0
set ::HTML [open /tmp/jobs.html w]
set ::web_output 1
set method [string tolower $::env(REQUEST_METHOD)]
if {$method=="post"} {
    foreach field [split [read stdin] &] {
        lassign [split $field =] var val
        set ::opt($var) $val
    }
} else {
    foreach field [split $::env(QUERY_STRING) &] {
        lassign [split $field =] var val
        set ::opt($var) $val
    }
}
set ::session $::env(HTTP_X_FORWARDED_FOR)
set ::sessions_path $fe_path/gamma_sessions
<!doctype html>
<html lang="en" >
<head><meta http-equiv="refresh" content="10" />
  <meta charset="utf-8" >
  <title>Gamma Circuit Size Mapper</title>
  <link rel="stylesheet" href=" //code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css" >
  <link rel="stylesheet" href="http://www.engr.colostate.edu/~ystatter/cgi-bin/ramspice/Gamma/Web/FE/gamma_style.css" >
  <script src=" //code.jquery.com/jquery-1.10.2.js" ></script>
  <script src=" //code.jquery.com/ui/1.11.4/jquery-ui.js" ></script>
</head>
<body>
set active_list {}
#set sleep_until [clock seconds]
#incr sleep_until 5
#while {$sleep_until>[clock seconds]} {}
foreach signal_file [glob -nocomplain $::process_path/active_*.tcl] {
    array unset ::header
    source $signal_file
    skip {![info exists ::header]} 
    skip {$::header(user)!=$::opt(user)}
    lappend active_list $signal_file
}
if {$active_list!={}} {
    set i 0
    <h3>Active Optimizations:</h3>
    <table border="1" > <tr><td><b>Name</b></td><td><b>Started on</b></td><td><b>Terminate</b></td>
    </tr>
    foreach signal_file $active_list {
        array unset ::header
        source $signal_file
        if {[regexp {^\s*$} $::header(Name)]} {
            set ::header(Name) "No Name"
        }
        puts $::HTML "<tr><td>"
	if {$::opt(win)=="analysis"} {
            <input type="radio" name="Select$i" value="Select$i" > $::header(Name)
	} else {
	    puts $::HTML $::header(Name)
	}
	puts $::HTML "</td><td>[clock format [file atime $signal_file]]</td><td><button id=\"Terminate$i\" value=\"\" onclick=\"Terminate('Terminate$i')\;\">"
        puts $::HTML "<svg enable-background=\"new 0 0 300 300\" height=\"32px\" id=\"Layer_1\" version=\"1.1\" viewBox=\"0 0 300 300\" width=\"32px\" xml:space=\"preserve\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" ><g><path d=\"M151.338,14.8c-74.557,0-134.996,60.44-134.996,135.002c0,74.554,60.439,134.998,134.996,134.998   c74.556,0,135.004-60.443,135.004-134.998C286.342,75.241,225.894,14.8,151.338,14.8z M151.338,265.714   c-64.013,0-115.908-51.901-115.908-115.912c0-64.018,51.895-115.911,115.908-115.911c64.016,0,115.909,51.894,115.909,115.911   C267.247,213.813,215.354,265.714,151.338,265.714z\" fill=\"#BF3D27\" /><circle cx=\"151.341\" cy=\"149.802\" fill=\"#BF3D27\" r=\"104.428\" /><polygon fill=\"#FFFFFF\" points=\"213.878,180.6 182.131,212.344 151.338,181.547 120.541,212.344 88.799,180.6 119.586,149.802    88.799,119.013 120.541,87.256 151.338,118.058 182.131,87.256 213.878,119.013 183.077,149.802  \" /></g></svg>"
	</button></td>
	</tr>
	incr i
    }
    </table>
}
</body>
</html>
close $::HTML
