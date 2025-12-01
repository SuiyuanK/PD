# $Revision: 2.3 $

#########################################################################
#
# Ansys, Inc.
#
# atclExec.tcl is a TCL wrapper for in-tool perl script execution
#
# Usage: 
#	atclExec <perl_script_name> <args>
#
# Copyright 2018 Ansys, Inc.
# All rights reserved.
#
# Revision history
#
# Rev 1.0 
# - Created by Xiang Mao 08/21/18
# - Initial version
#########################################################################

proc atclExec_help {} {
	puts "Usage: atclExec <script_name> \[option_arguments\]"
}

proc atclExec { args } {
	global env
	# Process command arguments
	set argv [split $args]
	if {[llength $argv] == 0 || [regexp {\-h} [lindex $argv 0]]} {
		atclExec_help; return
	}

	set perl_name [lindex $argv 0]
	set argv [lreplace $argv 0 0]
	# find and exec the perl
	exec perl "$env(APACHEROOT)/scripts/$perl_name.pl" {*}$argv
}
