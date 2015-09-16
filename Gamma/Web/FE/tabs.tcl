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
set authenticate 1
set ::HTML [open out.html w]
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
        # skip {[info exists ::opt($var)]}
        set ::opt($var) $val
    }
}
Info: QUERY_STRING=$::env(QUERY_STRING)
foreach key [array names ::opt] {
    Info: OPT $key=$::opt($key)
}
set ::session $::env(HTTP_X_FORWARDED_FOR)
set ::sessions_path $fe_path/gamma_sessions
set ::heatmap_pallet {0xa50026 0xd73027 0xf46d43 0xfdae61 0xfee090 0xffffbf 0xe0f3f8 0xabd9e9 0x74add1 0x4575b4 0x313695}
source $::env(RAMSPICE)/Gamma/Web/FE/gamma_procs.tcl
array set ::colors {
    gray #F2F2F3
    green #1FDA9A
    red #EE4B3E
    orange #E9BC1B
    yellow #F5EACD 
    
    red #a50026 
    orange #fdae61
    yellow #fee090 
    gray #e0f3f8
    bg #ffffbf
    blue 0x313695
}
if {![file exists $::sessions_path]} {
    file mkdir $::sessions_path
}
Info: $::env(REQUEST_METHOD)
Info: sessions_path=$::sessions_path $authenticate
if {[info exists ::opt(authentication_user)]} {
    Info: authentication request from $::opt(authentication_user)
    if {[file exists $fe_path/users.tcl]} {
        source $fe_path/users.tcl
        if {$::passwords($::opt(authentication_user))==$::opt(authentication_psw)} {
            set ::SESSION(ip) $::session
            set ::SESSION(user) $::opt(authentication_user)
            set authenticate 0
        }
    }
}
default ::SESSION(ip) {}
Info: sessions_path=$::sessions_path $authenticate
foreach session_file [glob -nocomplain $::sessions_path/*.tcl] {
    Info: $session_file [expr [clock seconds]-[file mtime $session_file]]
    skip {[clock seconds]-[file mtime $session_file]>15*60}
    array unset ::SESSION
    source $session_file
    default  ::SESSION(ip) 
    Info: ip=$::SESSION(ip) =?= $::session
    if {$::SESSION(ip)==$::session} {
        set authenticate 0
        set ::active_session [file tail $session_file]
        break
    }	    
}
if {![info exists ::active_session]} {
    for {set i 0} {[file exists $::sessions_path/$i.tcl]} {incr i} {}
    set ::active_session $i.tcl
    
}
if {[info exists ::opt(ajax_cmd)]} {
    textbox $::opt(ajax_cmd)
    source $fe_path/$::opt(ajax_cmd).tcl
    close $::HTML
    return
}

if {$authenticate} {
    <!doctype html>
    <html lang="en">
    <head>
    <meta charset="utf-8">
    <title>Gamma Circuit Size Mapper</title>
    </head>
    <body>
    <form method="post"> User name: <input type="text" name="authentication_user">
    <br> Password: <input type="password" name="authentication_psw">
    <BUTTON name="submit" value="submit" type="submit">Send</BUTTON>
    </form>     
    </body></html>
    close $::HTML
    return
}
array set ::config {
    analysis_timeout 5*60
}
default ::opt(authentication_user) {}
default ::SESSION(user) $::opt(authentication_user)

if {[file exists $fe_path/$::SESSION(user).tcl]} {
    source $fe_path/$::SESSION(user).tcl
}
if {![info exists ::active_session]} {
    for {set i 0} {[file exists $::sessions_path/$i.tcl]} {incr i} {}
    set ::active_session $i.tcl
    
}
set ::active_analysis [file rootname $::active_session].html
set ::SESSION(ip) $::session
save_session
set ::USER default
source schematic_lib.tcl
foreach tech_dir [glob $::env(RAMSPICE)/Etc/Tech_DB/*] {
    skip {![file isdirectory $tech_dir]}
    skip {![file exists $tech_dir/data.tcl]}
    set techname [file tail $tech_dir]
    source $tech_dir/data.tcl
    set ::tech_names($techname) $title
}
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Gamma Circuit Size Mapper</title>
<link rel="stylesheet" href="//code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css">
<link rel="stylesheet" href="http://www.engr.colostate.edu/~ystatter/cgi-bin/ramspice/Gamma/Web/FE/gamma_style.css">
<script src="//code.jquery.com/jquery-1.10.2.js"></script>
<script src="//code.jquery.com/ui/1.11.4/jquery-ui.js"></script>
<script src="http://www.engr.colostate.edu/~ystatter/simple-slider.js"></script>
<link href="http://www.engr.colostate.edu/~ystatter/simple-slider.css" rel="stylesheet" type="text/css" />
<link href="http://www.engr.colostate.edu/~ystatter//simple-slider-volume.css" rel="stylesheet" type="text/css" />  
#  <link rel="stylesheet" href="/resources/demos/style.css">
<script> 
default ::SESSION(selected_axes) "none%2Cnone%2Cnone%2C"
set ::selected_axes_list {}
foreach axis [regsub -all {%2C} $::SESSION(selected_axes) " "] i {0 1 2} default {Adc Rout none} {
    if {$axis=="none"} {
        set axis $default
    }
    lappend ::selected_axes_list $axis
}
regsub -all { } $::selected_axes_list {","} ::selected_axes_list
puts $::HTML "var selected=\[\"$::selected_axes_list\"\];"
set ::property_list {
    Adc
    CMRR
    PSRR
    Vos
    Rout
    BW
    ts
    Nt
    fc
    Area
    Power
}
foreach property $::property_list {
    default ::SESSION($property) ""
    puts $::HTML "var $property='$::SESSION($property)';"
}

puts $::HTML {
    $(function() {
        $( "#tabs" ).tabs();
    });  
    var selected_tech="none";
    var selected_topology="none";
    var axes=["X","Y","Z"];
    var X_is_sizer=0;
    var Y_is_sizer=0;
    //      var selected=["none","none","none"];
    var selected_g=[];
    var selected_circuits=[];
    var xhr; 
    var focus_circuit='none';
    var updateSpecTable = function () {};
    var UpdateFocusOn=function() {};
    if (window.ActiveXObject) { 
        xhr = new ActiveXObject ("Microsoft.XMLHTTP"); 
    } 
    else if (window.XMLHttpRequest) { 
        xhr = new XMLHttpRequest (); 
    } 
    $("[data-slider]")
    .each(function () {
        var input = $(this);
        $("<span>")
        .addClass("output")
        .insertAfter($(this));
    })
    .bind("slider:ready slider:changed", function (event, data) {
        $(this)
        .nextAll(".output:first")
        .html(data.value.toFixed(3));
    });
    </script>
    <style>
    table {
        border-collapse: collapse;
    }
    
    .tableFormatter
    {
        width:100%;
        vertical-align:top;
        text-align:center;
    }  
    </style>
    </head>
}
<body bgcolor=$::colors(green)>

<div id="tabs">
<ul>
<li><a href="#tab1"><svg enable-background="new 0 0 64 64" id="Layer_3" height="32px" width="64px" style="enable-background:new 0 0 64 64" ><path d="M8,6.021V3c0-1.654-1.346-3-3-3S2,1.346,2,3v3.021   C0.792,6.936,0,8.369,0,10s0.792,3.064,2,3.977V29c0,1.654,1.346,3,3,3s3-1.346,3-3V13.977c1.208-0.912,2-2.346,2-3.977   S9.208,6.936,8,6.021z M4,3c0-0.553,0.447-1,1-1s1,0.447,1,1v2.1C5.677,5.035,5.343,5,5,5S4.323,5.035,4,5.1V3z M6,29   c0,0.553-0.447,1-1,1s-1-0.447-1-1V14.898C4.323,14.965,4.657,15,5,15s0.677-0.035,1-0.102V29z M7.865,10.84   c-0.016,0.053-0.03,0.105-0.049,0.158c-0.095,0.264-0.217,0.514-0.378,0.736c-0.004,0.006-0.01,0.01-0.014,0.016	c-0.174,0.238-0.381,0.449-0.616,0.627c-0.004,0.004-0.007,0.006-0.01,0.008c-0.241,0.182-0.51,0.328-0.799,0.43   C5.686,12.928,5.353,13,5,13s-0.686-0.072-1-0.186c-0.289-0.102-0.558-0.248-0.799-0.43c-0.003-0.002-0.006-0.004-0.01-0.008   c-0.235-0.178-0.442-0.389-0.616-0.627c-0.004-0.006-0.01-0.01-0.014-0.016c-0.161-0.223-0.283-0.473-0.378-0.736   c-0.019-0.053-0.033-0.105-0.049-0.158C2.055,10.572,2,10.293,2,10c0-0.295,0.055-0.574,0.135-0.842   c0.016-0.053,0.03-0.105,0.049-0.156C2.278,8.738,2.4,8.488,2.562,8.264c0.004-0.006,0.01-0.01,0.014-0.016   c0.174-0.236,0.381-0.449,0.616-0.627c0.004-0.002,0.007-0.006,0.01-0.008C3.442,7.434,3.711,7.287,4,7.184   C4.314,7.072,4.647,7,5,7s0.686,0.072,1,0.184c0.289,0.104,0.558,0.25,0.799,0.43c0.003,0.002,0.006,0.006,0.01,0.008   c0.235,0.178,0.442,0.391,0.616,0.627c0.004,0.006,0.01,0.01,0.014,0.016C7.6,8.488,7.722,8.738,7.816,9.002	C7.835,9.053,7.85,9.105,7.865,9.158C7.945,9.426,8,9.705,8,10C8,10.293,7.945,10.572,7.865,10.84z" fill="#333333" fill-rule="evenodd"/><path clip-rule="evenodd" d="M30,6.021V3c0-1.654-1.346-3-3-3s-3,1.346-3,3v3.021   C22.791,6.936,22,8.369,22,10s0.791,3.064,2,3.977V29c0,1.654,1.346,3,3,3s3-1.346,3-3V13.977c1.207-0.912,2-2.346,2-3.977	S31.207,6.936,30,6.021z M26,3c0-0.553,0.447-1,1-1s1,0.447,1,1v2.1C27.676,5.035,27.342,5,27,5c-0.344,0-0.678,0.035-1,0.1V3z    M28,29c0,0.553-0.447,1-1,1s-1-0.447-1-1V14.898C26.322,14.965,26.656,15,27,15c0.342,0,0.676-0.035,1-0.102V29z M29.865,10.84   c-0.016,0.053-0.031,0.105-0.049,0.158c-0.096,0.264-0.217,0.514-0.379,0.736c-0.004,0.006-0.01,0.01-0.014,0.016   c-0.174,0.238-0.381,0.449-0.615,0.627c-0.004,0.004-0.008,0.006-0.01,0.008c-0.242,0.182-0.51,0.328-0.799,0.43   C27.686,12.928,27.352,13,27,13c-0.354,0-0.686-0.072-1-0.186c-0.289-0.102-0.559-0.248-0.799-0.43   c-0.004-0.002-0.006-0.004-0.01-0.008c-0.236-0.178-0.443-0.389-0.617-0.627c-0.004-0.006-0.01-0.01-0.014-0.016   c-0.16-0.223-0.283-0.473-0.377-0.736c-0.02-0.053-0.033-0.105-0.049-0.158C24.055,10.572,24,10.293,24,10   c0-0.295,0.055-0.574,0.135-0.842c0.016-0.053,0.029-0.105,0.049-0.156c0.094-0.264,0.217-0.514,0.377-0.738   c0.004-0.006,0.01-0.01,0.014-0.016c0.174-0.236,0.381-0.449,0.617-0.627c0.004-0.002,0.006-0.006,0.01-0.008   c0.24-0.18,0.51-0.326,0.799-0.43C26.314,7.072,26.646,7,27,7c0.352,0,0.686,0.072,1,0.184c0.289,0.104,0.557,0.25,0.799,0.43   c0.002,0.002,0.006,0.006,0.01,0.008c0.234,0.178,0.441,0.391,0.615,0.627c0.004,0.006,0.01,0.01,0.014,0.016   c0.162,0.225,0.283,0.475,0.379,0.738c0.018,0.051,0.033,0.104,0.049,0.156C29.945,9.426,30,9.705,30,10   C30,10.293,29.945,10.572,29.865,10.84z" fill="#333333" fill-rule="evenodd"/><path clip-rule="evenodd" d="M19,18.021V3c0-1.654-1.346-3-3-3s-3,1.346-3,3v15.021   c-1.208,0.914-2,2.348-2,3.979s0.792,3.064,2,3.977V29c0,1.654,1.346,3,3,3s3-1.346,3-3v-3.023c1.207-0.912,2-2.346,2-3.977   S20.207,18.936,19,18.021z M15,3c0-0.553,0.447-1,1-1c0.553,0,1,0.447,1,1v14.1c-0.324-0.064-0.658-0.1-1-0.1	c-0.343,0-0.677,0.035-1,0.1V3z M17,29c0,0.553-0.447,1-1,1c-0.553,0-1-0.447-1-1v-2.102C15.323,26.965,15.657,27,16,27   c0.342,0,0.676-0.035,1-0.102V29z M18.865,22.84c-0.016,0.053-0.031,0.105-0.049,0.158c-0.096,0.264-0.217,0.514-0.379,0.736   c-0.004,0.006-0.01,0.01-0.014,0.016c-0.174,0.238-0.381,0.449-0.615,0.627c-0.004,0.004-0.008,0.006-0.01,0.008	c-0.242,0.182-0.51,0.328-0.799,0.43C16.686,24.928,16.352,25,16,25c-0.353,0-0.686-0.072-1-0.186   c-0.289-0.102-0.558-0.248-0.799-0.43c-0.003-0.002-0.006-0.004-0.01-0.008c-0.235-0.178-0.442-0.389-0.616-0.627   c-0.004-0.006-0.01-0.01-0.014-0.016c-0.161-0.223-0.283-0.473-0.378-0.736c-0.019-0.053-0.033-0.105-0.049-0.158   C13.055,22.572,13,22.293,13,22c0-0.295,0.055-0.574,0.135-0.842c0.016-0.053,0.03-0.105,0.049-0.156   c0.095-0.264,0.217-0.514,0.378-0.738c0.004-0.006,0.01-0.01,0.014-0.016c0.174-0.236,0.381-0.449,0.616-0.627   c0.004-0.002,0.007-0.006,0.01-0.008c0.241-0.18,0.51-0.326,0.799-0.43C15.314,19.072,15.647,19,16,19c0.352,0,0.686,0.072,1,0.184   c0.289,0.104,0.557,0.25,0.799,0.43c0.002,0.002,0.006,0.006,0.01,0.008c0.234,0.178,0.441,0.391,0.615,0.627   c0.004,0.006,0.01,0.01,0.014,0.016c0.162,0.225,0.283,0.475,0.379,0.738c0.018,0.051,0.033,0.104,0.049,0.156   C18.945,21.426,19,21.705,19,22C19,22.293,18.945,22.572,18.865,22.84z" fill="#333333" fill-rule="evenodd"/></g></svg>Analyze</a></li>
<li><a href="#tab3"><svg height="32px" id="Layer_5" style="enable-background:new 0 0 64 64" version="1.1" viewBox="3 3 78 78" width="64px" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><path d="M12,3.005v17.996H0v44.494c0,5.247,4.253,9.5,9.5,9.5h59c5.25,0,9.5-4.25,9.5-9.5V3.005H12z M72,65.495c0,1.93-1.57,3.5-3.5,3.5h-59c-1.93,0-3.5-1.57-3.5-3.5V27.001h6v29.994c0,1.66,1.34,3,3,3s3-1.34,3-3V9.005h54V65.495z" style="fill:#333F4F" />	  <rect height="11.997" style="fill:#333F4F" width="42" x="24" y="14.995"/>	   <rect height="3" style="fill:#333F4F" width="18" x="24" y="32.998"/>        <rect height="3" style="fill:#333F4F" width="18" x="48" y="32.998"/>	   <rect height="3" style="fill:#333F4F" width="18" x="24" y="40.997"/>        <rect height="3" style="fill:#333F4F" width="18" x="48" y="40.997"/>	   <rect height="3" style="fill:#333F4F" width="18" x="24" y="48.998"/>        <rect height="3" style="fill:#333F4F" width="18" x="48" y="48.998"/>	   <rect height="3" style="fill:#333F4F" width="18" x="24" y="56.998"/>        <rect height="3" style="fill:#333F4F" width="18" x="48" y="56.998"/></svg>Report </a></li>
<li><a href="#tab4"><svg enable-background="new 0 0 64 64" id="Layer_6" height="32px" width="64px" version="1.1" viewBox="0 0 64 64"  xmlns="http://www.w3.org/2000/svg"><path d="M57.997 39.714c3.737-3.596 6.61-9.926 5.893-16.183-.72-6.256-6.612-14.96-15.882-16.83S27.6 3.75 17.755 7.564s-15.162 9.28-16.67 14.313S-1.575 35.11 6.4 41.943s24 6.4 24 6.4 4.17 3.597 8.84 6.402 13.294 4.675 14.516 4.172c1.222-.503.79-2.23.862-3.165.072-.935 0 0-2.084-2.877s-3.306-8.343-2.946-8.56c.358-.214 4.67-1.005 8.407-4.6zm-11.833-.67c.43.43 3.21 3.45 3.018 3.74-.192.287-1.34.095-1.533.43-.194.337-.29.864-.29.864s-2.97-4.843-3.45-4.89c-.477-.05-1.53-.29-1.29.718.24 1.007 4.885 6.33 5.125 6.665.24.338 1.437 3.79 2.78 5.85 1.34 2.064 2.06 2.687 1.628 2.687-.43 0-1.485.288-1.725-.24-.24-.527-9.39-14.193-10.06-14.385-.672-.19-1.342.05-1.007.53.336.478 9.918 13.57 9.918 13.57s-2.587-.72-3.21-1.2c-.623-.48-8.24-12.515-8.767-12.755-.526-.24-1.724.48-1.245.91.48.433 8 11.22 8 11.22s-3.593-1.294-4.12-2.06c-.527-.768-5.51-9.255-6.084-9.543s-1.053.192-.957.48c.096.287 5.94 8.438 5.653 8.39-.287-.048-3.066-1.534-4.024-3.02-.958-1.487-1.34-2.734-1.82-2.782-.48-.048-1.39.384-1.533.192-.144-.192-2.683-3.452-3.114-3.404-.43.048-.575.527-.287.91.286.385 1.724 2.446 1.292 2.446-.43 0-1.006.288-1.39-.048-.382-.336-2.442-3.165-3.16-2.973-.72.192-1.15.815-.768 1.103.383.288 1.58 1.63 1.102 1.678-.48.048-8.527-.288-14.228-3.644-5.702-3.356-8.05-6.665-8.72-9.974-.67-3.31 1.15-8.775 1.15-8.775.91-2.588 2.97-5.753 7.042-8.486 4.072-2.733 7.905-5.37 17.63-6.33 9.725-.958 18.252-.91 25.582 3.885 7.33 4.794 8.432 10.788 8.72 11.843.286 1.055.574 2.83.382 2.493-.192-.336-1.533-1.582-1.868-1.103-.335.48-.766.096-.24.815.527.72 2.06 1.822 2.108 2.302.048.48.048 2.062-.287 1.774-.336-.288-2.396-2.973-2.923-2.493-.527.48-.91.576-.43.912.478.336 2.825 2.733 2.825 3.31 0 .574 0 1.342-.43 1.054-.433-.29-2.924-3.74-3.21-3.26s-.91.43-.625.91c.287.48 3.258 3.45 3.21 4.027-.048.575-.43 1.295-.575 1.007-.144-.287-2.683-3.5-3.21-3.356-.527.144-.767.384-.623.91.144.528 3.258 3.357 2.97 3.79-.287.43-.575 1.198-.814.862-.24-.336-2.922-4.076-3.497-4.028-.576.048-1.15.384-.672.96.48.574 3.64 3.643 3.45 4.267-.193.622-.672 1.63-1.15 1.294-.48-.336-4.17-4.89-4.456-4.795-.287.095-1.293.48-.67 1.006.622.528 3.975 4.22 3.688 4.65-.287.433-.91 1.535-1.293 1.152s-3.69-5.227-4.216-5.035c-.526.19-1.197.24-.765.958.43.72 3.88 4.556 3.64 4.844-.24.29-.91 1.152-1.484.672-.574-.48-3.305-4.89-3.832-4.7-.53.194-1.295.77-.864 1.2zM12.58 15.93c-1.053.096-6.083 3.404-7.33 6.28s-.102 6.844.145 7.05c.575.48 1.63-.048 1.246-.96-.38-.91-.285-2.684.337-5.37.623-2.684 5.126-5.322 5.797-5.753.67-.43.862-1.342-.192-1.247zm40.722-.19c.575.48.91-.097 1.102-.624.192-.528-.43-1.822-3.21-3.548s-9.29-2.12-9.82-1.055c-.097.192-.145 1.055.43 1.2s2.78.19 5.51.287c2.73.094 5.413 3.26 5.988 3.74zm-35.355 5.99c-3.497 1.726-2.97 6.138-1.39 7.576 1.582 1.44 4.552 1.39 6.42.384 1.87-1.007 3.354-3.07 1.438-5.658-1.917-2.59-5.447-2.806-6.468-2.302zm5.365 5.994c-.48.67-3.785 1.39-4.455 1.103-.67-.29-1.964-2.878.527-3.74.673-.234 2.3-.29 3.162.335s1.246 1.63.766 2.3zm8.544-5.148c-.07.037-.136.08-.208.113-1.677.767-2.3 3.02-2.156 3.644.144.623.575 3.117 3.21 3.932s5.94-.048 7.042-1.247c1.102-1.2 1.773-3.693-.048-5.66-1.767-1.907-5.478-2.01-7.84-.783zm6.02 6.107c-1.15.623-3.64.623-4.168.24-.527-.384-2.156-3.02.958-4.172 1.223-.45 3.258.145 4.264.816 1.006.672.096 2.494-1.054 3.117zM48.08 29.74c2.3 1.15 4.12.48 5.413-.384 1.293-.863 2.252-2.54.575-5.61-1.677-3.07-5.626-2.56-7.186-1.055-2.682 2.59-1.1 5.9 1.198 7.05zm.575-4.124c.522-.375 2.395-.384 3.4 0 1.007.384 1.917 1.534 1.103 2.062-.814.528-2.395 1.63-3.737 1.247-1.34-.384-2.632-1.966-.764-3.31z"/></svg>Chat </a></li>
<li><a href="#tab5"><svg height="32px" id="Layer_7" style="enable-background:new 0 0 64 64" version="1.1" viewBox="3 3 78 78" width="64px" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><path d="M78.197,37.708l-3.726-16.331l-9.873-1.097l-2.511-3.15l1.131-9.865L48.122,0l-7.008,7.028h-4.031  L30.073,0L14.979,7.266l1.131,9.865l-2.511,3.15l-9.873,1.097L0,37.708l8.413,5.271l0.898,3.928l-5.299,8.397l10.45,13.098  l9.365-3.293l3.632,1.749l3.262,9.375h16.754l3.262-9.375l3.632-1.749l9.365,3.293l10.45-13.098l-5.299-8.397l0.897-3.928  L78.197,37.708z M66.833,54.897l-5.13,6.43l-7.693-2.705l-8.12,3.911l-2.68,7.699h-8.223l-2.68-7.699l-8.12-3.911l-7.693,2.705  l-5.13-6.43L15.717,48l-2.01-8.784l-6.908-4.329l1.829-8.017l8.109-0.901l5.617-7.046l-0.93-8.101l7.41-3.567l5.758,5.773h9.012  l5.757-5.773l7.411,3.566l-0.93,8.101l5.617,7.046l8.109,0.901l1.829,8.017l-6.91,4.329L62.481,48L66.833,54.897z M39.099,23.587  c-8.286,0-15,6.713-15,15s6.714,15,15,15s15-6.713,15-15S47.385,23.587,39.099,23.587z M39.099,49.087c-5.79,0-10.5-4.71-10.5-10.5  s4.71-10.5,10.5-10.5s10.5,4.71,10.5,10.5S44.889,49.087,39.099,49.087z" style="fill:#333F4F"/></svg>Configure </a></li>
<li><a href="#tab6"><svg enable-background="new 0 0 64 64" id="Layer_8" height="32px" width="64px" style="enable-background:new 0 0 64 64" ><title/><defs><path d="M0,11 C0,4.92486745 4.92486745,0 11,0 C17.0751325,0 22,4.92486745 22,11 C22,17.0751325 17.0751325,22 11,22 C4.92486745,22 0,17.0751325 0,11 L0,11 Z M21,11 C21,5.47715225 16.5228478,1 11,1 C5.47715225,1 1,5.47715225 1,11 C1,16.5228478 5.47715225,21 11,21 C16.5228478,21 21,16.5228478 21,11 L21,11 Z M11.25,7.5 C11.940356,7.5 12.5,6.94035595 12.5,6.25 C12.5,5.55964405 11.940356,5 11.25,5 C10.559644,5 10,5.55964405 10,6.25 C10,6.94035595 10.559644,7.5 11.25,7.5 L11.25,7.5 Z M8.5,8.5 L8.5,9.5 L10,9.5 L10,16.5 L8.5,16.5 L8.5,17.5 L14,17.5 L14,16.5 L12.5,16.5 L12.5,8.5 L8.5,8.5 L8.5,8.5 Z" id="path-1"/></defs><g fill="none" fill-rule="evenodd" id="miu" stroke="none" stroke-width="1"><g id="circle_info_more-information_detail_outline_stroke"><use fill="#000000" fill-rule="evenodd" xlink:href="#path-1"/><use fill="none" xlink:href="#path-1"/></g></g></svg>Help </a></li>
</ul>
<div id="tab1">
<p>
source $fe_path/tab_spec.tcl
</p>
</div>
<div id="tab3">
<p>
source $fe_path/tab_report.tcl
</p>
</div>
<div id="tab4">
<p>
source $fe_path/tab_chat.tcl
</p>
</div>
<div id="tab5">
<p>
source $fe_path/tab_configure.tcl
</p>
</div>
<div id="tab6">
<p>
source $fe_path/tab_info.tcl
</p>
</div>
</div>


</body>
</html>
close $::HTML
