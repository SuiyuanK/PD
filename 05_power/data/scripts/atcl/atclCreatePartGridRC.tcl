#########################################################################
#
# Apache Design Solutions, Inc.
#
# Copyright 2009 Apache Design Solutions, Inc.
# All rights reserved.
#
# File Name : atclCreatePartGridRC.tcl
#
# Creation Date : Nov 18, 2009
#
# Created By : Devesh Nema (devesh@apache-da.com) 
#
# Revision history
#
# 	Last Modified : Wed 18 Nov 2009 05:32:33 PM PST
#
#########################################################################
proc atclCreatePartGridRC_help {} {
puts "atclCreatePartGridRC -partfile <file name> -gsr <file name> -design <design name>? ?-h? ?-m?"
}

proc atclCreatePartGridRC_manpage {} {
puts "
SYNOPSIS
        Apache-AE TCL utility to generate grid RC model for chip partitions
                                                                                                                                                            
USAGE
	atclCreatePartGridRC -partfile <file name> -gsr <file name> -design <design name>? ?-h? ?-m?
                                                                                                                                                            
   Options:
        -partfile <file name> : file with partition names and co-ordinates (Required, format explained below)
	-gsr <file name> : GSR file (Required)
	-design <design name> : Top level design name (Required) 
	-h : Help
        -m : Man page


-partfile <file name> : Format for this file is as follows:

*************************************************************************************
<partition name> <llx> <lly> <urx> <ury>
*************************************************************************************
"
}




proc atclCreatePartGridRC { args } {
set argv [split $args]
set argc [llength $argv]

# set default #####################
# END of set default #####################

for {set j 0} {$j < $argc} {incr j 1} {
	if {[regexp {\-partfile} [lindex $argv $j]]} {
		set partfile [lindex $argv [expr $j + 1]]
        } elseif  {[regexp {\-gsr} [lindex $argv $j]]} {
                set ingsrfile [lindex $argv [expr $j + 1]]
        } elseif  {[regexp {\-design} [lindex $argv $j]]} {
                set design [lindex $argv [expr $j + 1]]
        } elseif  {[regexp {\-h} [lindex $argv $j]]} {
                atclCreatePartGridRC_help;return
        } elseif  {[regexp {\-m} [lindex $argv $j]]} {
                atclCreatePartGridRC_manpage;return
        }
}

if {![info exists partfile] || ![info exists ingsrfile]} {
	puts "\n GSR file and file with partition co-ordinates are required"
	return
}
if {![info exists design]} {
	puts "\n Top level design name is required"
	return
}

# Parse the conf file ############################
set CONF [open $partfile r]
while { [gets $CONF line] >=0 } {
        if {[regexp {^\s*$} $line] || [regexp {^#} $line] } {
        } else {
		set line [string trim $line]
	        regsub -all -- {^[[:space:]]+} $line "" line
	        regsub -all -- {[[:space:]]+} $line " " line
	        set line [split $line]
		set partname [lindex $line 0]
		set llx [lindex $line 1]
		set lly [lindex $line 2]
		set urx [lindex $line 3]
		set ury [lindex $line 4]
		set partarr($partname) [list $llx $lly $urx $ury]
	}
}
close $CONF

foreach {k v} [array get partarr] {
	set outgsrfile "atclCreatePartGridRC\_$k.gsr"
	set tclfile "tclPartitionGridRC\_$k.tcl"
	exec cp $ingsrfile $outgsrfile
	set OUTGSR [open $outgsrfile a]
	set TCL [open $tclfile w]
	puts $OUTGSR "
	IMPORT_REGION {
	$design
		{
			[lindex $v 0] [lindex $v 1] [lindex $v 2] [lindex $v 3]
		}
	}
	"
	puts $TCL "
	setup design $outgsrfile
	perform pwrcalc
	perform extraction -power -ground -c
	perform powermodel -grid RC -o atclCreatePartGridRC\_$k.spi_rc
	exit
	"
	close $OUTGSR
	close $TCL
	puts "Running grid-RC reduction for partition $k ([lindex $v 0] [lindex $v 1] [lindex $v 2] [lindex $v 3])"
	exec redhawk -f $tclfile
	puts "grid-RC model generated: atclCreatePartGridRC\_$k.spi_rc"
	file delete -force $outgsrfile
	file delete -force $tclfile
}
}
