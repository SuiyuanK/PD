#########################################################################
#
# Apache Design Solutions, Inc.
#
# Copyright 2008 Apache Design Solutions, Inc.
# All rights reserved.
#
# Revision history
#
# - Created by Devesh Nema 
#
#########################################################################

proc atclAddVias_help {} {
puts "atclAddVias -toplayer <layer name> -bottomlayer <layer name> -window <llx lly urx ury> -spacing <spacing between centre of vias> -direction <h|v> ?-h?"
}

proc atclAddVias { args } {
set argv [split $args]
set argc [llength $argv]

if {$argc == 0} {
	atclAddVias_help; return
}

for {set j 0} {$j < $argc} {incr j 1} {
        if {[regexp {\-toplayer} [lindex $argv $j]]} {
                set toplayer [lindex $argv [expr $j + 1]]
        } elseif  {[regexp {\-bottomlayer} [lindex $argv $j]]} {
                set bottomlayer [lindex $argv [expr $j + 1]]
        } elseif  {[regexp {\-window} [lindex $argv $j]]} {
                set x1 [lindex $argv [expr $j + 1]]
                set y1 [lindex $argv [expr $j + 2]]
                set x2 [lindex $argv [expr $j + 3]]
                set y2 [lindex $argv [expr $j + 4]]
        } elseif  {[regexp {\-spacing} [lindex $argv $j]]} {
                set spacing [lindex $argv [expr $j + 1]]
        } elseif  {[regexp {\-direction} [lindex $argv $j]]} {
                set direction [lindex $argv [expr $j + 1]]
        } elseif  {[regexp {\-h} [lindex $argv $j]]} {
		atclAddVias_help; return
	}
}

if {![info exists toplayer]} {
	puts "Top layer is required"
	return
}
if {![info exists bottomlayer]} {
        puts "Bottom layer is required"
        return
}
if {![info exists x1] || ![info exists y1] || ![info exists x2] || ![info exists y2] } {
        puts "Window is required"
        return
}
if {![info exists spacing]} {
        puts "Spacing is required"
        return
}
if {![info exists direction]} {
        puts "Direction is required"
        return
}


if {$direction == "h"} {
       set y [expr $y1 + [expr [expr $y2 - $y1] / 2]]
       set d [expr $x1 + 1]
       while {$d < [expr $x2 - 1]} {
               eco add via -x $d -y $y -toplayer $toplayer -bottomlayer $bottomlayer
	       set d [expr $d + $spacing]
       }
}

if {$direction == "v"} {
        set x [expr $x1 + [expr [expr $x2 - $x1] / 2]]
	set d [expr $y1 + 1]
        while {$d < [expr $y2 - 1]} {
                eco add via -x $x -y $d -toplayer $toplayer -bottomlayer $bottomlayer
	        set d [expr $d + $spacing]
        }
}

}


