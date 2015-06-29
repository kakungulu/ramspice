  <script> 
      puts $::HTML {window.onload = initForm; }
      set tech_list {}
      foreach tech [array names ::tech_names] {
          append tech_list "\"$tech\""
      }
      set topology_js_list {}
      set topology_list {}
      set ::spec_js_code {}
      foreach topology_path [glob $::env(RAMSPICE)/Etc/Templates/*] {
          skip {![file exists $topology_path/data.tcl]}
          set topology [file tail $topology_path]
	  append topology_js_list "\"$topology\""
	  lappend topology_list $topology
	  array unset ::properties
	  source $topology_path/data.tcl
	  set ::topologies($topology,properties) {}
	  foreach key [array names ::properties *,html] {
	      lappend ::topologies($topology,properties) [lindex [split $key ,] 0]
	  }
	  foreach key [array names ::properties] {
	      set ::topologies($topology,$key) $::properties($key)
	  }
	  append ::spec_js_code "if (selected_topology==\"$topology\") \{\n"
	  append ::spec_js_code "   document.getElementById(\"SpecForm\").innerHTML='"
	  append ::spec_js_code {<form action="#">}
	  append ::spec_js_code "<table><tr><td colspan=\"3\"><b>Specifications</b></td><td rowspan=\"[expr [llength $::topologies($topology,properties)]+1]\">"
	  set ::web_output ::spec_js_code
	  draw_schematic $topology
	  set ::web_output 1
	  append ::spec_js_code "</td></tr>"
	  foreach property $::topologies($topology,properties) {
	      append ::spec_js_code "<tr><td><b>$::topologies($topology,$property,html)</b></td><td><input width=\"8\" type=\"number\" id=\"$property\"></td><td><b>$::topologies($topology,$property,unit)</b></td></tr>"
	  }
	  append ::spec_js_code "</table>"
	  append ::spec_js_code "</form>'\;\n\}"
      }
      regsub -all {""} $tech_list {","} tech_list
      regsub -all {""} $topology_js_list {","} topology_js_list
      puts $::HTML "var tech_array = \[$tech_list\]\;"
      puts $::HTML "var topology_array = \[$topology_js_list\]\;"
      function UpdateTech() {
	if (document.getElementById("TechSelectForm").selectedIndex>=0) {
	    selected_tech = tech_array\[document.getElementById("TechSelectForm").selectedIndex\]\;
	    document.getElementById("TechRequest").innerHTML="Selected technology:"\;
	    if (selected_topology=="none") {
    	        document.getElementById("TopologyRequest").innerHTML="<font color=red>Now, select topology:</font>"\;
	    }
	}
      }
      function UpdateTopology() {
	if (document.getElementById("TopologySelectForm").selectedIndex>=0) {
	    selected_topology = topology_array\[document.getElementById("TopologySelectForm").selectedIndex\]\;
	    document.getElementById("TopologyRequest").innerHTML="Selected topology:"\;
	    $::spec_js_code
	}
      }
      function initForm() {
	      document.getElementById("TechSelectForm").selectedIndex = -1\;
	      document.getElementById("TechSelectForm").onchange = UpdateTech\;
	      document.getElementById("TopologySelectForm").selectedIndex = -1\;
	      document.getElementById("TopologySelectForm").onchange = UpdateTopology\;
      }
  </script>
  <table> 
  <tr>
  <td id="TechRequest"><font color=red>First, Select Technology:</font></td>
  <td>
<form action="#">
  <select id="TechSelectForm">
      set i 0
      foreach tech [array names ::tech_names] {
          puts $::HTML "<option value=\"$i\">$::tech_names($tech)</option>"
          incr i
      }
  </select>
</form>
  </td>
  </tr>
  <tr>
  <td id="TopologyRequest">
  puts $::HTML "&nbsp;"
  </td>
  <td>
  <select id="TopologySelectForm">
      set i 0
      foreach topology $topology_list {
          source $::env(RAMSPICE)/Etc/Templates/$topology/data.tcl
          puts $::HTML "<option value=\"$i\">$input_type $title</option>"
          incr i
      }
  </select>
  </td>
  </tr>
  <tr><td id="SpecForm" colspan="2">
  </td></tr>
  </table>	
  </div>
