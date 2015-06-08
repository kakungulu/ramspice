# \
exec $RAMSPICE/ramspice $0 $argv
puts "Content-type: text/html\n"
puts "<!DOCTYPE html>"

##########################################################################
######### Read input
##########################################################################
if {[info exists ::env(REQUEST_METHOD)]} {
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
} else {
    if {[info exists ::env(QUERY_STRING)]} {
        foreach field [split $::env(QUERY_STRING) &] {
            lassign [split $field =] var val
            set ::opt($var) $val
        }
    } else {
        get_opts
        default ::opt(out) /tmp/out.html
        set ::HTML [open $::opt(out) w]
    }
}
##########################################################################


set user default
if {[info exists ::env(REMOTE_ADDR)]} {
    set user $::env(REMOTE_ADDR)
}
set session default
if {[info exists ::env(HTTP_X_FORWARDED_FOR)]} {
    set session [lindex $::env(HTTP_X_FORWARDED_FOR) end]
}

set unknown {
    if {[regexp {^<} $args]} {
        regsub -all {\\\"} $args "\"" html_line 
        puts $html_line 
        return
    }
}
append unknown [info body unknown]
proc unknown args $unknown



default ::opt(data) $::env(RAMSPICE)/Gamma/Web/cgi/GammaCGIData.tcl

if {[file exists $::opt(data)]} {
    source $::opt(data)
}

set authentication_required 1

if {[file exists session-$session.tcl]} {
    if {[clock seconds]-[file mtime session-$session.tcl]<15*60} {
        source session-$session.tcl
        set authentication_required 0
    }
}
set authentication_warning {}
if {[info exists ::opt(authentication_user)]} {
    if {$::opt(submit)=="signup"} {
        set authentication_required 0
	set DATA($::opt(authentication_user),pwd) $::opt(authentication_psw)
    } else {
        if {![info exists DATA($::opt(authentication_user),pwd)]} {
	    set authentication_warning "No such user account in the system. Retry user name or sign up."
        } elseif {$DATA($::opt(authentication_user),pwd)!="$::opt(authentication_psw)"} {
	    set authentication_warning "User and password did not match. Retry or sign up."
	} else {
            set authentication_required 0
	}
    }
    if {!$authentication_required} {
        set user $::opt(authentication_user)
        set O [open session-$session.tcl w]
	puts $O [list set user [set user]]
	close $O
    }
}
if {[file exists user-$user.tcl]} {
    source user-$user.tcl
}
if {$authentication_required} {
    <html><body>
    <h2>Welcome to the Circuit Sizing Web Tool</h2>
    if {$authentication_warning!={}} {
        <h3>$authentication_warning</h3>
    }
    <form> User name: <input type="text" name="authentication_user">
    <br> Password: <input type="password" name="authentication_psw">
    <BUTTON name="submit" value="submit" type="submit">Send</BUTTON>
    <BUTTON name="submit" value="signup" type="submit">Sign Up</BUTTON>
    </form>     
    </body></html>
    exit
}






if {![info exists ::env(QUERY_STRING)]} {
    close $::HTML
}
set O [open $::opt(data) w]
puts $O [list array set DATA [array get DATA]]
close $O
set O [open user-$user.tcl w]
puts $O [list array set USER [array get USER]]
close $O

exit
