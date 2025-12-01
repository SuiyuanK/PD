# $Revision: 1.3 $

#########################################################################
#
# atcl_disable_high_freq is an Apache-AE TCL utility for disabling the instances whose frequency is equal to or above a certain cut off frequency
#
# Usage: source atcl_disable_high_freq.tcl
#        atcl_disable_high_freq -cutoff <cut off frequency>
#
#
# Copyright  2009 Apache Design Solutions, Inc.
# All  rights reserved.
#
# Revision history
#
# Rev 1.0
# - Created by Mithun K S Rao on August09 2009
# - Initial version
#
#########################################################################

proc atclTemplate_manpage {} {
        puts "

SYNOPSIS
atcl_disable_high_freq is an Apache-AE TCL utility for disabling the instances whose frequency is equal to or above a certain cut off frequency

USAGE
        atcl_disable_high_freq \[option_arguments\]
        Options:
        -cutoff <cut off freq in Hz>         Specify the cut off frequency for disabling the instances
        \[-h\]                               command usage
        \[-man\]                             man page
"
}

proc atclTemplate_help {} {
        puts "Usage: atcl_disable_high_freq -cutoff 10e9" 
}


proc atcl_disable_high_freq { args } {
        set argv [split $args]
        set state flag
	set type " "
        set outputfile "cutoff_instances.txt"

        foreach arg $argv {
                switch -- $state {
                        flag {
                                switch -glob -- $arg {
                                        -h* { atclTemplate_help ; return }
                                        -man { atclTemplate_manpage ; return }
                                        -cutoff  { set state cutofffreq }
                                        -o { set state outputf }
                                        default { error "actl Error: unknow flag $arg" }
                                }
                        }
                        cutofffreq {
                                set cut_off_freq $arg
                                set state flag
                        }
                        outputf {
                                set outputfile $arg
                                set state flag
                        }
                }
        }

config cmdlog off

set INSTFILE [open "$outputfile" w]

set instlist [get inst * -glob]

puts "Cut off frequecy specified is: $cut_off_freq, disabling instances equal to or above the cut off frequency"

foreach instance $instlist {
if { [catch { get inst $instance -freq }] == 0} {
set freq [get inst $instance -freq]
 if { $freq >= $cut_off_freq } {
     puts $INSTFILE "$instance 0"
    }
 }
}

close $INSTFILE
gsr set INSTANCE_TOGGLE_RATE_FILE cutoff_instances.txt

config cmdlog off
}


