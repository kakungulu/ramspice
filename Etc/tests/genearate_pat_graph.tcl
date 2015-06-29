# \
exec $RAMSPICE/ramspice $0 $argv
proc gen_pat_graph {P1 P2 args} {
    set script1 {
        <script src="//cdnjs.cloudflare.com/ajax/libs/dygraph/1.1.1/dygraph-combined.js"></script>
        
        <!-- load the d3.js library -->    
        <script src="http://d3js.org/d3.v3.min.js"></script>
        
        <script>
        
        // Set the dimensions of the canvas / graph
        var margin = {top: 30, right: 20, bottom: 30, left: 50},
        width = 600 - margin.left - margin.right,
        height = 270 - margin.top - margin.bottom;
        
        // Set the ranges
        var x = d3.scale.linear().range([0, width]);
        var y = d3.scale.linear().range([height, 0]);
        
        // Define the axes
        var xAxis = d3.svg.axis().scale(x)
        .orient("bottom").ticks(5);
        
        var yAxis = d3.svg.axis().scale(y)
        .orient("left").ticks(5);
        
        // Define the line
        var valueline = d3.svg.line()
        .x(function(d) { return x(d.@P1); })
        .y(function(d) { return y(d.@P2); });
        
        // Adds the svg canvas
        var svg = d3.select("body")
        .append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform", 
        "translate(" + margin.left + "," + margin.top + ")");
        
       
    }
    regsub -all @P1 $script1 $P1 script1
    regsub -all @P2 $script1 $P2 script1
    puts $::HTML $script1
    set script2 {
        // Get the data
        d3.csv("data@i.csv", function(error, data) {
            data.forEach(function(d) {
                d.@P1 = d.@P1;
                d.@P2 = +d.@P2;
            });
            
            // Scale the range of the data
            x.domain(d3.extent(data, function(d) { return d.@P1; }));
            y.domain([0, d3.max(data, function(d) { return d.@P2; })]);
            
            
        });
    }
    set i 0
    foreach p $args {
        regsub -all @P1 $script2 $P1 script1
        regsub -all @P2 $script1 $P2 script1
        regsub -all @i $script1 $i script1
        puts $::HTML $script1
        @ $p PAT graph /tmp/data$i.csv $P1 $P2
	incr i
    }
    set script3 {
        // Get the data
        d3.csv("data@i.csv", function(error, data) {
            data.forEach(function(d) {
                d.@P1 = d.@P1;
                d.@P2 = +d.@P2;
            });
            
            
            // Add the valueline path.
            svg.append("path")  .attr("class", "line@i")   .attr("d", valueline(data));
            // Add the X Axis
            svg.append("g")     .attr("class", "x axis")  .attr("transform", "translate(0," + height + ")")  .call(xAxis);
            
            // Add the Y Axis
            svg.append("g")     .attr("class", "y axis")  .call(yAxis);
        });
    }
    set i 0
    foreach p $args {
        regsub -all @P1 $script3 $P1 script1
        regsub -all @P2 $script1 $P2 script1
        regsub -all @i $script1 $i script1
        puts $::HTML $script1
	incr i
    }
    </script>
}
return
get_opts
default ::opt(size) 1000

for {set j 0} {$j<3} {incr j} {
@ p${j}((a,b,c|-A,-B,C)) !
for {set i 0} {$i<$::opt(size)/($j*10+1)} {incr i} {
    set a [expr rand()]
    set b [expr rand()]
    set c [expr rand()]
    set A [expr rand()]
    set B [expr rand()]
    set C [expr rand()]
    @ p$j <<< [list $a $b $c] [list $A $B $C] 
}
}
html open /tmp/t.html
<!DOCTYPE html>
<html>
<meta charset="utf-8">
<style>
puts $::HTML {
    body {
        font: 10px sans-serif;
    }
    .axis path,
    .axis line {
        fill: none;
        stroke: #000;
        shape-rendering: crispEdges;
    }
    
    .line0 {
        fill: none;
        stroke: green;
        stroke-width: 1.5px;
    }
    .line1 {
        fill: none;
        stroke: steelblue;
        stroke-width: 1.5px;
    }
    .line2 {
        fill: none;
        stroke: red;
        stroke-width: 1.5px;
    }
}
</style>

<body>
gen_pat_graph A B p0 p1 p2 
</body></html>
html close

exit


