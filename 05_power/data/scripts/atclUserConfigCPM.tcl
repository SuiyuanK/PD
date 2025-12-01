#$Revision : 1.2$
#Modified by Uday , on 19-04-12 , output file is .sp and not .sp.inc. 
# $Revision: 1.2 $

#########################################################################
#
# atclUserConfigCPM.tcl is an Apache-AE TCL utility which creates CPM based on the sequence that is input by the user
#
#
# Usage: source atclUserConfigCPM.tcl
#        create_config_cpm -user_file <user_input_sequence_file> -cpm <baseline_cpm> -o <outpu_filename>
#
#Example: create_config_cpm -cpm PowerModel.sp.inc -user_file sequence.txt
#
# Copyright © 2010 Apache Design Solutions, Inc.
# All  rights reserved.
#
# Revision history
#
# Rev 1.0
# -Initial script
# - Created by Mithun K S Rao on Oct8 2010
#
#########################################################################

proc atclTemplate_manpage {} {
        puts "

SYNOPSIS
	atclUserConfigCPM.tcl is an Apache-AE TCL utility which creates CPM based on the sequence that is input by the user
USAGE
        atclUserConfigCPM.tcl \[option_arguments\]
        Options:
        -user_file <filename>          User input sequence file
        -cpm <filename>                Pointer to baseline CPM run                
        -o <output_file>               Specify the output file name
        \[-h\]                         command usage
        \[-man\]                       man page
"
}

proc atclTemplate_help {} {
        puts "Usage: create_config_cpm -user_file <user_input_sequence_file> -cpm <baseline_cpm> -o <outpu_filename>" 
}


proc create_config_cpm { args } {
        set argv [split $args]
        set state flag
        set cpmfile " "
        set inputfile " "
        set outputfile "user_configurable_cpm.sp"
     

        foreach arg $argv {
                switch -- $state {
                        flag {
                                switch -glob -- $arg {
                                        -h* { atclTemplate_help ; return }
                                        -man { atclTemplate_manpage ; return }
                                        -user_file { set state userfile }
                                        -cpm { set state cpmfile }
                                        -o { set state outputf }
                                        default { error "actl Error: unknow flag $arg" }
                                }
                        }
                        userfile {
                                set inputfile $arg
				set state flag
                        }   
                        cpmfile {
                                set cpmfile $arg
                                set state flag
                        }
                        outputf {
                                set outputfile $arg
                                set state flag
                        }
                }
        }

puts "-INFO- Creating the user configurable CPM ..."
 if { [ catch { exec perl user_configurable_cpm.pl -user_file $inputfile -cpm $cpmfile -o $outputfile  } err_variable ] } {
         puts stderr $err_variable
                 puts "Errors occured while generating CPM."
                         }  else {
                                 puts "Finished generating CPM."
                                       }
    puts "-INFO- Completed  CPM creation..."

}

