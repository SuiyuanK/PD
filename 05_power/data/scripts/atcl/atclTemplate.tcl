# $Revision: 1.145 $

#########################################################################
#
# Apache Design Solutions, Inc.
#
# atclTemplate.tcl is an Apache-AE TCL utility for ...
#
# Usage: 
#	atclTemplate -i <input_file> -o <output_file> \[-h\] \[-m\]
#
# Copyright 2007 Apache Design Solutions, Inc.
# All rights reserved.
#
# Revision history
#
# Rev 1.0 
# - Created by Kawo Lee 08/03/07
# - Initial version
#
#########################################################################


proc atclTemplate_manpage {} {
	puts "
SYNOPSIS
        Apache-AE TCL utility for ...

USAGE
        atclTemplate \[option_arguments\]

        Options:
        -i <input_file>   Input file of ... (required)
        -o <output_file>  Outpu file of ... (required)
	\[-h\] 		  command usage
	\[-m\]		  man page
"
}

proc atclTemplate_help {} {
	puts "Usage: atclTemplate -i <input_file> -o <output_file> \[-h\] \[-m\]"
}

proc atclTemplate { args } {
	
	# Process command arguments
	# Possible flags are: -i, -o, -h* and -m*
	set argv [split $args]
	if {[llength $argv] == 0 } { set argv "-h" }
	set state flag
	set inputf ""
	set outputf ""
	foreach arg $argv {
		switch -- $state {
			flag {
				switch -glob -- $arg {
					-h* { atclTemplate_help ; return }
					-m* { atclTemplate_manpage ; return }
					-i  { set state inputflag }
					-o  { set state outputflag }
					default { error "actl Error: unknow flag $arg" }
				}
			}
			inputflat {
				set inputf $arg
				set state flag
			}
			outputflag {
				set outputf $arg
				set state flag
			}
		}
	}

	# Check required options
	if {![info exists inputf] || ![info exists outputf]} {
		puts "Missing required option(s) or value(s)"
		atclTemplate_help
		return
	}
        
		
#-------------
# Main
#-------------

    ....
    ....

}
