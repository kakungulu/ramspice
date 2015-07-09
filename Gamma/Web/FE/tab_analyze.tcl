namespace eval ::Analysis {
}
proc analysis {name title code} {
    set ::analyses($name) $title
    proc ::Analysis::$name {} $code
}


analysis 2D "Tradeoff between Two Performance Properties" {
}
analysis 3D "Heat Map of an Objective Property vs. Two Performance Properties" {
}
<script>
set AnalysisTitles {}
foreach alaysis [array names ::analyses] {
    append AnalysisTitles "\"$::analyses($alaysis)\""
}
regsub -all {""} $AnalysisTitles {","}  AnalysisTitles 
puts $::HTML "var AnalysisTitles=\[$AnalysisTitles\]\;"
function UpdateAnalysis() {
    document.getElementById("AnalysisTitle").innerHTML=AnalysisTitles\[document.getElementById("AnalysisSelectForm").selectedIndex\]\;
}
</script>
<form action="#">
     <select id="AnalysisSelectForm">
      set i 0
      foreach alaysis [array names ::analyses] {
          puts $::HTML "<option id=\"analysis$i\" value=\"$i\" title=\"$::analyses($alaysis)\" >$alaysis</option>"
          incr i
      }
  </select>   

</form>
<p id="AnalysisTitle"></p>
<table><tr><td>

</td><td id="AnalysisSchematic" ></td></tr><tr><td><iframe id="AnalysisJobWindow" seamless src="http://www.engr.colostate.edu/usr-bin/cgiwrap/ystatter/gamma_jobs?win=analysis&user=$::SESSION(user)"></iframe></td></tr></table>
if {![file exists ~ystatter/public_html/analyses/$::active_analysis]} {
    set O [open ~ystatter/public_html/analyses/$::active_analysis w]
    puts $O "<html><head><meta http-equiv=\"refresh\" content=\"5\" /></head>"
    puts $O <body>
    puts $O "<h1> No Analysis Yet</h1>"
    puts $O </body>
    puts $O </html>
    close $O
}
