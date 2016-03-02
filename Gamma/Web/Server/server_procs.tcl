
namespace eval SERVE {}

proc xml {cmd args} {
    set xml "<$cmd>"
    foreach param value [lrange $args 0 end-1] {
	appned xml " $para=\"$value\""
    }
    append xml [lindex $args end]
    append xml "</$cmd>"
    $xml
}

proc ::SERVE::get_schematic {topo} {
        source $::env(RAMSPICE)/Etc/Templates/$topo/data.tcl
    	<SchematicDef>
	    <SchemaRow>
	        foreach {type flip rotate name} $::topologies($topo,schematic) {
		     if {$type=="nl"} {
	                 </SchemaRow>
	                 <SchemaRow>
			 continue
		     }
		     <SchemaBlock type="$type" flip="$flip" rotate="$rotate" name="$name" />
		}
	    </SchemaRow>
	</SchematicDef>
}

proc ::SERVE::get_topologies {} {
    proc define_sizers {data} {
        array unset ::sizers_data
	set ::sizers_list {}
	foreach {param transistors min max unit} $data {
	    lappend ::sizers_list $param
	    foreach var {transistors min max unit} {
	        set ::sizers_data($param,$var) [set $var] 
	    }
	}
    }
    foreach topology_data [glob $::env(RAMSPICE)/Etc/Templates/*/data.tcl] {
         set topo [file tail [file dirname $topology_data]]
	 <Topology name="$topo">
	 ::SERVE::get_schematic $topo
	 foreach param $::sizers_list {
	     set description "$param (no description)"
	     if {[string index $param 0]=="L"} {
	          set description "Length of $::sizers_data($param,transistors)"
	     }
	     if {[string index $param 0]=="W"} {
	          set description "Width of $::sizers_data($param,transistors)"
	     }
	     if {[string index $param 0]=="I"} {
	          set description "[string totitle [string range $param 1 end]] current"
	     }
	     if {[string index $param 0]=="V"} {
	          set description "[string totitle [string range $param 1 end]] voltage"
	     }
	     <Sizer literal="$param" description="$description" unit="$::sizers_data($param,unit)"/>
	 }
	 </Topology>
    }
}

proc ::SERVE::plot_pareto {X Y} {
}

proc ::SERVE::SET {array_name args} {
    set addr $::SERVICE(addr)
    foreach {var val} $args {
        eval "set ::$array_name\($addr,$var\) \"$val\""
    }
    
}
proc ::SERVE::GET {array_name args} {
    set addr $::SERVICE(addr)
    <$array_name>
    foreach {var val} [array get $array_name $addr,*] {
        regsub $addr, $var {} var
	
	
    }
    </$array_name>
}

