# \
exec $RAMSPICE/ramspice $0 $argv
set ::heatmap_pallete {
    #a50026
    #d73027
    #f46d43
    #fdae61
    #fee090
    #ffffbf
    #e0f3f8
    #abd9e9
    #74add1
    #4575b4
    #313695
}
set ::heatmap_pallete {
    #FF0000
    #E02000
    #D04000
    #A06000
    #909000
    #60A000
    #00C040
    #008080
    #0040C0
    #0020D0
    #0000FF
}
set ::heatmap_pallete {
    #a50026
    #d73027
    #f46d43
    #fdae61
    #fee08b
    #ffffbf
    #d9ef8b
    #a6d96a
    #66bd63
    #1a9850
    #006837
}
set ::heatmap_pallete {
    #0042f8
    #42b4fd
    #6bf9bd
    #6cf73a
    #def63c
    #fad336
    #f0731f
    #f04f18
}

proc heatmap {data {rez_x 100} {rez_y 100} {rez_z {}}} {
    if {$rez_z=={}} {
        set rez_z [llength $::heatmap_pallete]
    }
    Info: Front size=[expr [llength $data]/3] points
    foreach {x y z} $data {
        default min_x $x
        default max_x $x
        default min_y $y
        default max_y $y
        default min_z $z
        default max_z $z
        foreach dim {x y z} {
            if {[set min_$dim]>[set $dim]} {
                set min_$dim [set $dim]
            }
            if {[set max_$dim]<[set $dim]} {
                set max_$dim [set $dim]
            }
        }
    }
    foreach dim {x y z} {
        Info: $dim=([set min_$dim],[set max_$dim])
    }	
    array set scaled_data {}
    foreach {x y z} $data {
        foreach dim {x y z} {
            set scaled_$dim [expr int(([set rez_$dim]-1)*([set $dim]-[set min_$dim])/([set max_$dim]-[set min_$dim]))]
        }
        default scaled_data($scaled_x,$scaled_y) $scaled_z
        if {$scaled_data($scaled_x,$scaled_y)>$scaled_z} {
            set scaled_data($scaled_x,$scaled_y) $scaled_z
        }
    }
    for {set x 0} {$x<$rez_x} {incr x} {
        for {set y 0} {$y<$rez_y} {incr y} {
            skip {[info exists scaled_data($x,$y)]} 
            set total_weight 0
            set total_z 0
            foreach neighbour [array names scaled_data] {
                lassign [split $neighbour ,] nb_x nb_y
                set weight [expr 1.0/(($x-$nb_x)*($x-$nb_x)+($y-$nb_y)*($y-$nb_y))]
                set total_z [expr $total_z+$weight*$scaled_data($neighbour)]
                set total_weight [expr $total_weight+$weight]
            }
            set interpolated_data($x,$y) [expr int($total_z/$total_weight)]
        }
	Info: $x/$rez_x
    }
    foreach interpolated [array names interpolated_data] {
        set scaled_data($interpolated) $interpolated_data($interpolated)
    }
    <svg width=800 height=800> 
    set xstep [expr 800.0/$rez_x]
    set ystep [expr 800.0/$rez_y]
    for {set y $rez_y;incr y -1} {$y>=0} {incr y -1} {
        for {set x 0} {$x<$rez_x} {incr x} {
            set color [lindex $::heatmap_pallete $scaled_data($x,$y)]
            <rect x=[expr $x*$xstep] y=[expr $y*$ystep] width=$xstep height=$ystep fill=$color />
        }
    }
    </svg>
}
return
set ::HTML [open par.html w]
<!DOCTYPE html>
<html>
<body>
heatmap {
    2 2 3 
    8 2 8 
    2 8 8
    8 8 3
}
</body>
</html>
close $::HTML

exit

