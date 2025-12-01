# $Revision: 1.145 $

#########################################################################
#
# Apache Design Solutions, Inc.
#
# Copyright 2007 Apache Design Solutions, Inc.
# All rights reserved.
#
# Revision history
#
# - Created by Aveek Sarkar 10-30-2007
# - Initial version
#
#########################################################################

proc atclPlocDelete_manpage {} {
        puts "
SYNOPSIS
        TCL command to delete ploc from user specified region
USAGE
        atclPlocDelete ll_x ll_y ur_x ur_y

	Creates a file: user_pad_delete.tcl that can be sourced in RedHawk.

        Options:
	None
"
}



proc atclPlocDelete {args } {
    set argv [split $args]


    if {[llength $argv] < 4 } { 

	atclPlocDelete_manpage
	return
    } else {

	set ll_x [lindex $argv 0]
	set ll_y [lindex $argv 1]
	set ur_x [lindex $argv 2]
	set ur_y [lindex $argv 3]

	puts "Delete region $ll_x $ll_y $ur_x $ur_y"

    }
    regexp {(\S+)} [ lindex [ gsr get PAD_FILES ] 1 ] pad_file
    puts "Found $pad_file"

    set PLOC [ open $pad_file r ]
    set OUT  [ open "user_pad_delete.tcl" w ]
    foreach line [ split [read $PLOC] \n ] {
	if { [regexp {[POWER|GROUND]} $line] } { 
	    set ploc_name [ lindex $line 0 ]
	    set ploc_x    [ lindex $line 1 ]
	    set ploc_y    [ lindex $line 2 ]

	    if { $ploc_x >= $ll_x && $ploc_x <= $ur_x && $ploc_y >= $ll_y && $ploc_y <= $ur_y } {
		puts "Match found: $ploc_name at $ploc_x and $ploc_y"
		puts $OUT "eco delete pad $ploc_name"
	    }

	}
    }
close $OUT
puts "Please source user_pad_delete.tcl inside RedHawk to remove these pads"
}





