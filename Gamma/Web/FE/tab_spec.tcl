  proc define_properties {table} {
      set ::property_list {}
      foreach {name html unit min max step} $table {
          lappend ::property_list $name
	  foreach field {html unit min max step} {
              set ::properties($name,$field) [set $field]
          }
      }
  }
  
  <script> 
      puts $::HTML {window.onload = initForm; }
      set tech_list {}
      foreach tech [array names ::tech_names] {
          append tech_list "\"$tech\""
      }
      set topology_js_list {}
      set topology_list {}
      set ::spec_js_code {}
      set ::ajax_send_code {}
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
	  append ::ajax_send_code "if (selected_topology==\"$topology\") \{\n    url = \"?ajax=1&selected_tech=\" + escape(selected_tech) + \"&selected_topology=\" + escape(selected_topology)"
	  append ::spec_js_code "   document.getElementById(\"SpecForm\").innerHTML='"
	  append ::spec_js_code {<form action="#" id="SpecForm" onChange = "SendSpecToServer();">}
	  append ::spec_js_code "<table><tr><td colspan=\"3\"><b>Specifications:</b></td><td rowspan=\"[expr [llength $::topologies($topology,properties)]+1]\">"
	  set ::web_output ::spec_js_code
	  draw_schematic $topology
	  set ::web_output 1
	  append ::spec_js_code "</td></tr>"
	  set LaunchDisabled true
	  foreach property $::property_list {
	      set value {}
	      if {[info exists ::SESSION($property)]} {
	          set value "value=\"$::SESSION($property)\""
		  set LaunchDisabled false
	      }
	      append ::spec_js_code "<tr><td><b>$::topologies($topology,$property,html)</b></td><td><input size=\"8\" type=\"number\" id=\"$property\"  $value onChange=\"SendSpecToServer()\;\"></td><td><b>$::topologies($topology,$property,unit)</b></td></tr>"
	      append ::ajax_send_code "+ \"&$property=\" + escape(document.getElementById(\"$property\").value)"
	  }
	  set ::web_output ::button_icon
	  draw_schematic $topology 32
	  set ::web_output 1
	  append ::spec_js_code "<tr><td colspan=\"3\" align=\"center\"><button type=\"button\" formid=\"SpecForm\" id=\"SubmitSpec\" disabled=\"$LaunchDisabled\" onclick=\"LaunchJob()\;\">$::button_icon Get Circuits</button></td></tr>"
	  append ::spec_js_code "</table>"
	  append ::spec_js_code "</form>'\;\n\}"
	  append ::ajax_send_code "\;\n\}"
      }
      regsub -all {""} $tech_list {","} tech_list
      regsub -all {""} $topology_js_list {","} topology_js_list
      puts $::HTML "var tech_array = \[$tech_list\]\;"
      puts $::HTML "var topology_array = \[$topology_js_list\]\;"
      function LaunchJob() { 
          // Build the URL to connect to 
          var url = "?ajax=1&launch=1"
         // Open a connection to the server 
          xhr.open ("GET", url, true); 
          // Setup a function for the server to run when it is done 
    //      xhr.onreadystatechange = updatePage; 
         // Send the request 
          xhr.send(null); 
    } 
       function SendSpecToServer() { 
	    document.getElementById("SubmitSpec").disabled=false\;
           // Build the URL to connect to 
          var url = ""
	  $::ajax_send_code
         // Open a connection to the server 
          xhr.open ("GET", url, true); 
          // Setup a function for the server to run when it is done 
    //      xhr.onreadystatechange = updatePage; 
         // Send the request 
          xhr.send(null); 
    } 
   function UpdateTech() {
	if (document.getElementById("TechSelectForm").selectedIndex>=0) {
	    selected_tech = tech_array\[document.getElementById("TechSelectForm").selectedIndex\]\;
	    document.getElementById("TechRequest").innerHTML="<b>Technology:</b>"\;
	    if (selected_topology=="none") {
    	        document.getElementById("TopologyRequest").innerHTML="<font color=red>Now, select topology:</font>"\;
	    }
	}
      }
      function UpdateTopology() {
	if (document.getElementById("TopologySelectForm").selectedIndex>=0) {
	    selected_topology = topology_array\[document.getElementById("TopologySelectForm").selectedIndex\]\;
	    document.getElementById("TopologyRequest").innerHTML="<b>Topology:</b>"\;
	    $::spec_js_code
	}
      }
      
      set ::restore_session_code {}
      if {[info exists ::SESSION(selected_tech)]} {
          append ::restore_session_code "i=[lsearch [array names ::tech_names] $::SESSION(selected_tech)]\;\n"
          append ::restore_session_code "selected_tech=\"$::SESSION(selected_tech)\"\;\n"
          append ::restore_session_code "document.getElementById(\"TechSelectForm\").selectedIndex\=i\;\n"
          append ::restore_session_code "document.getElementById(\"TechRequest\").innerHTML=\"<b>Technology:</b>\"\;\n"
      }
      if {[info exists ::SESSION(selected_topology)]} {
          append ::restore_session_code "i=[lsearch $topology_list $::SESSION(selected_topology)]\;\n"
          append ::restore_session_code "selected_topology=\"$::SESSION(selected_topology)\"\;"
          append ::restore_session_code "document.getElementById(\"TopologySelectForm\").selectedIndex\=i\;"
          append ::restore_session_code "document.getElementById(\"TopologyRequest\").innerHTML=\"<b>Topology:</b>\"\;\n$::spec_js_code"
      }
      function initForm() {
              var i=-1;
	      document.getElementById("TechSelectForm").selectedIndex = -1\;
	      document.getElementById("TechSelectForm").onchange = UpdateTech\;
	      document.getElementById("TopologySelectForm").selectedIndex = -1\;
	      document.getElementById("TopologySelectForm").onchange = UpdateTopology\;
	      $::restore_session_code
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
