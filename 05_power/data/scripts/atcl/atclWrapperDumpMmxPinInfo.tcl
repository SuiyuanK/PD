#########################################################################
#
# Apache Design Solutions, Inc.
# 
# Usage:
# atclWrapperDumpMmxPinInfo -o <output_file> \[-h\] \[-m\]
# 
# Copyright 2008 Apache Design Solutions, Inc.
# All rights reserved.
#
# Revision history
#
# - Created by Vineeth 
#
#########################################################################
proc atclWrapperDumpMmxPinInfo_manpage {} {
puts "

SYNOPSIS
Apache-AE TCL wrapper for the command \"dump mmx_pin_info\" to get a better formatted
report file.

USAGE
atclWrapperDumpMmxPinInfo \[option_arguments\]

Options:
-o <output_file> path of the output report file.

All other options for the command \"dump mmx_pin_info\" can be used:
-box, -avg_volt_tw, -report_disconnect, -o, -wstpgarc, -leakage, -inst_file, -j -n

\[-h\] command usage
\[-m\] man page
"
}

proc atclWrapperDumpMmxPinInfo_help {} {
puts "Usage: atclWrapperDumpMmxPinInfo -o <output_file> \[-box\], \[-avg_volt_tw\], \[-report_disconnect\], \[-wstpgarc\], \[-leakage\], \[-inst_file\], \[-j\], \[-n\], \[-h\], \[-m\]"
}

proc atclWrapperDumpMmxPinInfo {args} {

set argv [split $args];
if {[llength $argv] == 0 } { set argv "-h" }
set state flag_s;
foreach arg $argv { switch -- $state {
                                flag_s {
                                        switch -glob -- $arg {
                                                		-h* { atclWrapperDumpMmxPinInfo_help ; return }
								-m* { atclWrapperDumpMmxPinInfo_manpage ; return }
								-o { set state output}
                                               		      }
                                	}
                                 output {   
                                        set output_f $arg
                                        set state flag_s
                                	}
                       
				      }
		   }

# Open temporary output files
set temp_dump_f $output_f
append temp_dump_f _tmp_dump
set temp_sort_f $output_f
append temp_sort_f _tmp_sort
set command_f $output_f
append command_f _cmd.sh
regsub {\-o\s+\S+} $args "" options
# Initial dump mmx_pin_info
set command "dump mmx_pin_info -o $temp_dump_f"
append command " $options"
eval $command
# Sort dump mmx_pin_info file by avg_volt_tw
set FP [open $command_f w]
puts $FP "grep \"^#\" $temp_dump_f > $temp_sort_f"
puts $FP "grep -v \"^#\" $temp_dump_f | sort -k 6 -n -r >> $temp_sort_f"
close $FP
exec chmod +x $command_f
exec bash $command_f
# Get max length of each column
set llidx0_max 0
set llidx1_max 1
set llidx2_max 2
set llidx3_max 3
set llidx4_max 4
set llidx5_max 5
set in_f [open $temp_sort_f r]
while {[gets $in_f line] >= 0} {
    if {![regexp {^\#Time} $line]} {
        set lidx [split $line { }]
        set llidx0 [string length [lindex $lidx 0]]
        if {$llidx0 > $llidx0_max} {set llidx0_max $llidx0}
        set llidx1 [string length [lindex $lidx 1]]
        if {$llidx1 > $llidx1_max} {set llidx1_max $llidx1}
        set llidx2 [string length [lindex $lidx 2]]
        if {$llidx2 > $llidx2_max} {set llidx2_max $llidx2}
        set llidx3 [string length [lindex $lidx 3]]
        if {$llidx3 > $llidx3_max} {set llidx3_max $llidx3}
        set llidx4 [string length [lindex $lidx 4]]
        if {$llidx4 > $llidx4_max} {set llidx4_max $llidx4}
        set llidx5 [string length [lindex $lidx 5]]
        if {$llidx5 > $llidx5_max} {set llidx5_max $llidx5}
    }
}
close $in_f
# Write formated output file
set in_f [open $temp_sort_f r]
set out_f [open $output_f w]
while {[gets $in_f line] >= 0} {
    if {[regexp {^\#Time} $line]} {
        puts $out_f $line
    } elseif {[regexp {^\#} $line]} {
        set lidx [split $line { }]
        puts $out_f "[format "%-$llidx0_max\s%2s%$llidx1_max\s%2s%$llidx2_max\s%2s%$llidx3_max\s%1s%$llidx4_max\s%1s%$llidx5_max\s%2s%-1s" [lindex $lidx 0] { } [lindex $lidx 1] { } [lindex $lidx 2] { } [lindex $lidx 3] { } [lindex $lidx 4] { } [lindex $lidx 5] { } [lindex $lidx 6]]"
    } else {
        set lidx [split $line { }]
        puts $out_f "[format "%-$llidx0_max\s%2s%$llidx1_max\.4f%2s%$llidx2_max\.4f%2s%$llidx3_max\s%1s%$llidx4_max\s%1s%$llidx5_max\.4f%2s%-1s" [lindex $lidx 0] { } [lindex $lidx 1] { } [lindex $lidx 2] { } [lindex $lidx 3] { } [lindex $lidx 4] { } [lindex $lidx 5] { } [lindex $lidx 6]]"
    }
}
close $in_f
close $out_f
exec rm -rf $temp_dump_f $temp_sort_f $command_f
}
