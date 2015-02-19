# \
exec $RAMSPICE/ramspice $0 $argv
get_opts

set ::html_body {}
proc Style {name config} {
    regsub -all @ {
        append ::html_body "<p class=\"@\">\n"
        append ::html_body "$args\n"
        append ::html_body "</p>\n"
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
    font-size 12px
    line-height 200%
    code {
        set text [lindex $args 0]
        regsub -all {\s+} [join [split [uplevel [list subst $text]] \n]] " " text
        append ::html_body "<p class=\"Body\">\n"
        append ::html_body "$text\n"
        append ::html_body "</p>\n"
    }
}
Style Chapter {
    inherit Body
    font-size 36px
    code {
        regsub -all {\s+} [join [split $args \n]] " " text
        append ::html_body "<p class=\"Chapter\">\n"
        append ::html_body "Chapter $::report_index: $text\n"
        append ::html_body "</p>\n"
    }
}
Style Title {
    inherit Body
    font-size 18px
    code {
        regsub -all {\s+} [join [split $args \n]] " " text
        append ::html_body "<p class=\"Chapter\">\n"
        append ::html_body "$::report_index $text\n"
        append ::html_body "</p>\n"
    }
}
Style CodeTitle {
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
        append ::html_body "<p class=\"CodeTitle\">\n"
        append ::html_body $code_title
        append ::html_body "</p>\n"

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
        append ::html_body "<p class=\"Code\">\n"
        append ::html_body "$final_text\n"
        append ::html_body "</p>\n"
    }
}


######################################## Test text
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
generate_report $::opt(to)
exit


