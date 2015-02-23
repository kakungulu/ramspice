# \
exec $RAMSPICE/ramspice $0 $argv
get_opts
default ::opt(from) test

set ::html_body {}
proc Style {name config} {
    regsub -all @ {
        HTML "<p class=\"@\">\n"
        HTML "$args\n"
        HTML "</p>\n"
    } $name ::Style($name,code)
    foreach {field value} $config {
        if {$field=="inherit"} {
            foreach key [array names ::Style $value,*] {
                set preperty [lindex [split $key ,] end]
                set ::Style($name,$preperty) $::Style($key)
            }
            continue
        }
        set ::Style($name,$field) $value
    }
    Info: defining $name
    proc $name args $::Style($name,code)
}
proc HTML {args} {
    if {[llength $args]==1} {
        set args [lindex $args 0]
    }
    append ::html_body "$args"
}
set ::report_index_list 0
set unknown {
    if {[regexp {^(\*+)(.*)$} $args -> bullet payload]} {
        set indent [string length $bullet]
        incr indent -1
        set index [lindex $::report_index_list $indent]
        if {$index=={}} {
            set index 0
        }
        incr index
        incr indent -1
        set ::report_index_list [concat [lrange $::report_index_list 0 $indent] $index]
        set ::report_index [join $::report_index_list .]
        return [uplevel $payload]
    }
}
append unknown [info body unknown]
proc unknown args $unknown

proc generate_report {filename} {
    set O [open /tmp/tmp.html w]
    puts $O <html>
    puts $O <head>
    puts $O "<style type=\"text/css\">"
    foreach style_key [array names ::Style *,code] {
        set style [lindex [split $style_key ,] 0]
        puts $O "    p.$style \{"
        foreach key [array names ::Style $style,*] {
            skip {$key=="$style,code"}
            set field [lindex [split $key ,] end]
            puts $O "        $field: $::Style($key);"
        }
        puts $O "    \}"
        puts $O "    $style \{"
        foreach key [array names ::Style $style,*] {
            skip {$key=="$style,code"}
            set field [lindex [split $key ,] end]
            puts $O "        $field: $::Style($key);"
        }
        puts $O "    \}"
    }
    puts $O </style>
    puts $O </head>
    puts $O <body>
    puts $O $::html_body
    puts $O </body>
    puts $O </html>
    close $O
    if {[catch {exec /usr/bin/wkhtmltopdf-amd64 toc /tmp/tmp.html /tmp/tmp.html $filename} msg]} {
        Warning: $msg
    }
}

###################################### Basic Styles

Style Body {
    font-family "GaramondNo8"
    white-space pre-wrap
    font-size 14px
    line-height 200%
    code {
        set text [lindex $args 0]
        regsub -all {\s+} [join [split [uplevel [list subst $text]] \n]] " " text
        HTML "<p class=\"Body\">$text</p>"
    }
}
Style Chapter {
    inherit Body
    font-size 36px
    code {
        regsub -all {\s+} [join [split $args \n]] " " text
        HTML "<p class=\"Chapter\">\n"
        HTML "Chapter $::report_index: $text\n"
        HTML "</p>\n"
    }
}
Style Title {
    inherit Body
    font-size 18px
    code {
        regsub -all {\s+} [join [split $args \n]] " " text
        HTML "<p class=\"Chapter\">\n"
        HTML "$::report_index $text</p>\n"
    }
}
Style CodeTitle {
    inherit Title
}
Style TableTitle {
    inherit Title
}
Style Code {
    white-space pre-wrap
    line-height 100%
    font-family Inconsolata
    font-size 12px
    code {
	set code_title $::report_index
	append code_title " "
	append code_title [lrange $args 0 end-1]
        HTML "<p class=\"CodeTitle\">\n"
        HTML $code_title
        HTML "</p>\n"

	set text [lindex $args end]
        regsub -all {\<} $text "\\&#60;" text
        regsub -all {\>} $text "\\&#62;" text
	set final_text {}
	foreach line [split $text \n] {
	    foreach command [info commands] {
	        regsub "^(\\s*)($command)(\\s.*)\$" $line {\1<b>\2</b>\3} line 
	        regsub "^(.*\\\[)($command)(\\s.*)\$" $line {\1<b>\2</b>\3} line 
	    }
	    append final_text "$line\n"
	}
        HTML "<p class=\"Code\">\n"
        HTML "$final_text\n"
        HTML "</p>\n"
    }
}

Style table {
    display table
    border-collapse separate
    border-spacing 0
    border-color black
    border "\"1pt solid black\""
    code {
        set title [lindex $args 0]
	set header [lrange $args 1 end-1]
	set content [lindex $args end]
        HTML "<p class=\"TableTitle\">Table $::report_index: $title</p>"
	HTML <table border=1>
	HTML <tr>
	foreach head $header {
	    HTML "<td><b>$head</b></td>"
	}
	set i 0
	foreach entry $content {
	    if {$i%[llength $header]==0} {
	        HTML </tr><tr>
	    }
	    HTML "<td>$entry</td>"
	    incr i
	}
	HTML </tr>
	HTML </table>
    }
}
######################################## Test text
if {$::opt(from)=="test"} {
* Chapter Introduction
Body {
    Electronic design automation tools played <b>[clock format [clock seconds]]</b> a central role in enabling the Moore's Law miniaturization of VLSI integrated circuits. Designers' productivity in the digital 
    design domains has increased dramatically, because of continuous improvements in the software tool algorithms and the machines that run them. 
}
** Code Example Procedure {
    proc generate_report {filename} {
        set O [open /tmp/tmp.html w]
        puts $O <html>
        puts $O <head>
        puts $O "<style type=\"text/css\">"
        foreach style_key [array names ::Style *,code] {
            set style [lindex [split $style_key ,] 0]
            puts $O "    p.$style \{"
            foreach key [array names ::Style $style,*] {
                skip {$key=="$style,code"}
                set field [lindex [split $key ,] end]
                puts $O "        $field: $::Style($key);"
            }
            puts $O "    \}"
        }
        puts $O </style>
        puts $O </head>
        puts $O <body>
        puts $O $::html_body
        puts $O </body>
        puts $O </html>
        close $O
        if {[catch {exec /usr/bin/wkhtmltopdf-amd64 /tmp/tmp.html $filename} msg]} {
            Info: $msg
        }
    }
}
} else {
    source $::opt(from)
}
generate_report $::opt(to)
exit


