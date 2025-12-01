#########################################################################
#
# Apache Design Solutions, Inc.
#
# atcl_createGSC.tcl is the script for dumping gsc file
#
# Copyright 2009-2010 Apache Design Solutions, Inc.
# All rights reserved.
#
# Revision history
#
# Created by Roshan Roy
# Revised by Nithin A Valentine
#ver 1.1 base version
#ver 1.2 added -mode switch, added 1-1 range as CLOCK_TOGGLE, dumping log file as createGSC.log 
#ver 1.3 script now takes care that all states belonging to the same switching state are being used
#ver 1.4 takes care of the curly bracket at the begining of a cell and at the end of a cell, also dumps out createGSC_droppes_insts.rpt
#ver 1.5 optimized the run time 
#ver 1.6 added option to give seed for the selection of states
#ver 1.7 seed value 1 is the default option
#ver 1.8 removed the puts info on GUI for cells not in the design to improve the run time
#ver 1.9 added some debug code to debug the run time issue in Aragorn
#ver 1.10 rewrote the randomness code added by joe to improve the run time in Aragorn
#ver 1.12 modified the script to improve performance with redhawk 12.2.3p3
#ver 1.13 modified the script to improve performance with RedHawk 13.2.1p1
#########################################################################


proc atcl_createGSC_man { } {

        puts "
SYNOPSIS
        Command used for running atcl_createGSC

USAGE
        atcl_createGSC \[option_arguments\]

        Options:
        -cell_list : Specify input file having the list of cell names with cell size
	Format \"cell_name cell_size\"
	
        -state_config:  Specify input file which tells how much percenatge of the total flop tray insatnces are in which state
	FORMAT \"Perc_of_instances Switching1%-switching2%\"
	
        -state_list : Specify the names of states to be used and to which switching category, it belongs to and also the corresponding cell name
	FORMAT \"cell_name state_name switching1%-switching2%\"
	
	-mode : specify the mode in which you are anlaysing the design \[FUNC/SCAN\]. Default value FUNC
	-seed : specify the seed value for random state selection. Default value is 1
	-o : filename of the gscfile to be created (Default: file.gsc)
        \[-h\]  Provide Help on Usage (optional)
       
"
}

proc atcl_createGSC { args } {
license rhe_mode on


set log_file [open "createGSC.log" w]
set output_file "file.gsc"
set state flag
set mode "FUNC"
set cell_list_file ""
set state_config_file ""
set state_list_file ""
set seedvalue 1
set debug_value 0
set detailed_log 0
set argv [split $args]
	foreach arg $argv {
		switch -- $state {
			flag {
				switch -glob -- $arg {
					-h* { atcl_createGSC_man ; return }
					-m* { atcl_createGSC_man ; return }
					-cell_list { set state state_cell_list }
					-state_config { set state state_config }	
					-state_list  { set state state_list}
					-seed { set state state_seed}
					-mode  { set state state_mode}
					-debug {set state state_d_debug}
					-log { set state state_detailed_log } 
					-o  { set state state_out_file}
					
					default { error "atcl_createGSC Error: unknown flag $arg" }
				}
			}
			state_seed {
				set seedvalue $arg
				set state flag

			}
			state_detailed_log {
				set detailed_log $arg
				set state flag
			}
			state_d_debug {
				set debug_value $arg
				set state flag
			}
			state_mode {
				set mode $arg
				set state flag

			}
			state_config {
				set state_config_file $arg
				set state flag

			}
			state_cell_list {
				set cell_list_file $arg
				set state flag
			}
			state_list {
			set state_list_file $arg
			set state flag
			
			}
			state_out_file {
				set output_file $arg
				set state flag
			}
			
		}
	}
config cmdlog off

	if {![file exists $state_config_file] } {
		error " please input the state_config_file using -state_config option \n Please use -h option for help"
		
	}
	if {![file exists $state_list_file] } {
		error "please input the state_list_file using -state_list option \n Please use -h option for help"
		
	}
	if {![file exists $cell_list_file] } {
		error " please input the cell_list_file using -cell_list option \n Please use -h option for help"
		
	}
	if {[file exists $output_file] } {
		exec rm -rf $output_file
		#error " The given output file $output_file already exists"
		
	}

	set db_fp [open "./.debug.txt" w]
	
	#if { $debug_value == 1 } { puts $db_fp "cells present in the design" } 
	set cell_list_fp [open "$cell_list_file" r]
	puts "INFO: Reading cell list file"
	set systime [clock seconds]
	set time_now [clock format $systime]
	 puts $log_file "INFO: Reading cell list file at $time_now" 
	while {[gets $cell_list_fp line] >= 0} {
	##flush stdout
 flush $log_file
 flush $db_fp
		
		if {![regexp {^[\#]} $line] } {
		regsub -all {\t}  $line " " line1
		regsub -all -- {[[:space:]]+} $line1 " " line
			
			set words [split $line]
			set cell_name [lindex $words 0]
			set cell_size [lindex $words 1]
			set size($cell_name) $cell_size
			

#			set inst [get instofcell $cell_name]
#			if {$inst ne "" } { 
#			#only if that cell exist in the design, take that into consideration
#			
#				if { $debug_value == 1 } { puts $db_fp "$cell_name" } 
#				#storing the size of available cells in design
#				if { [info exists cell_sizes] } {
#				
#			
#			
#					if { ![info exists sel($cell_size)] } {
#						lappend cell_sizes $cell_size
#						set sel($cell_size) 1
#					}
#			
#				} else {
##					puts "first $cell_size"
#					set cell_sizes $cell_size
#				}
#			
#				#storing the name of instances
#				if { ![info exists insts($cell_size)] } {
#				set total_insts [split $inst]
#				foreach inst $total_insts {
#				set insts($cell_size) $inst
#				}
#				} else {
#					set total_insts [split $inst]
#					foreach inst $total_insts {
#					lappend insts($cell_size) $inst
#					}
#				}
#			}

		}

	}
	close $cell_list_fp
	
	

	#storing all states to state{$cell}{lt}{ut}
	set ini_time [clock seconds]
	set comp_time_1 [expr $ini_time+1800]
		
	
	set state_list_fp [open "$state_list_file" r]
	puts "INFO: Reading state list file "
	set systime [clock seconds]
	set time_now [clock format $systime]
	puts $log_file "INFO: Reading state list file at $time_now"
#puts "Date 0 = [exec date]\n"
set inst_cid [get inst_by_cid * -glob]
set instances{} ""
set design_cell_list ""
set search_flag ""
set master_cell_list{} "" 
foreach i $inst_cid {
	set name_of_cell [get inst_by_cid $i -master]
    set search_flag [lsearch $design_cell_list $name_of_cell]
    if { $search_flag == -1 } {
        lappend design_cell_list $name_of_cell
        set instances($name_of_cell) $i
    } else {
        lappend instances($name_of_cell) $i
        }
    }

#    puts "Date 1 = [exec date]\n"
	while {[gets $state_list_fp line] >= 0} {
	##flush stdout
	flush $log_file
	flush $db_fp
	
		if {![regexp {^[\#]} $line] } {
		regsub -all {\t}  $line " " line1
		regsub -all -- {[[:space:]]+} $line1 " " line	
		
		
			
			set words [split $line]
			set cell_name [lindex $words 0]
			set state_name [lindex $words 1]
			
			set range [lindex $words 2]
			set ranges [split $range "-"]
			set ut [lindex $ranges 1]
			set lt [lindex $ranges 0]
			
			if { (($ut == 0 ) && ($lt == 0))|| (($ut==1) && ($lt==1)) } {
			} else {
			if {  $mode eq "SCAN" } {
				if { ![ regexp -all {^SCAN} $state_name ] } { 
				 	continue
				}
			}
			if {  $mode eq "FUNC" } {
				if { [ regexp -all {^SCAN} $state_name ] } { 
					continue
				}
			}
			}			
			
			#puts "hi $state_name hello"
			#set state($cell_name,$lt,$ut) $words
			#if { $debug_value == 1 } { puts $db_fp "before cell is $cell_name" } 
			if {$cell_name ne ""  && $cell_name ne "{}"} {
			if {![info exists instances($cell_name) ]} {
			#if { [catch { set inst [get inst_by_cid * -glob -master $cell_name] } ] == 0 } {
			#set instances($cell_name) $inst
			#} else {
                #puts "Here\n";
                set inst ""
#				puts "INFO : $cell_name  cannot be found in the design"
				set systime [clock seconds]
				set time_now [clock format $systime]
				if {$detailed_log ==1 } { puts $log_file "INFO : $cell_name  cannot be found in the design at $time_now" }
			#}
			} else {
			set inst $instances($cell_name)
			}
			#if { $debug_value == 1 } { puts $db_fp "after cell is $cell_name" } 
			
			if {$inst ne ""  && $inst ne "{}"} {
			if { ![info exists cell_state($cell_name,$lt,$ut)] } {
			set cell_state($cell_name,$lt,$ut) $state_name
			} else {
			lappend cell_state($cell_name,$lt,$ut) $state_name
			}
			if { $debug_value == 1 } { puts $db_fp "after set the state $cell_name" } 
			if {![info exists sel($cell_name)]} {
			set sel($cell_name) 1
			if { $debug_value == 1 } { puts $db_fp "after 1 cond" } 
			if { [catch { set a $size($cell_name) } ] == 0 } {
			if { $debug_value == 1 } { puts $db_fp "after 2 cond" } 
			if { [info exists cell_sizes] } {
				if { $debug_value == 1 } { puts $db_fp "after 3 cond" } 
				if {![info exists sel($a)]} {
				lappend cell_sizes $a
				if { $debug_value == 1 } { puts $db_fp "lappendig cell_sizes" } 
				set sel($a) 1
				}
			} else {
			if { $debug_value == 1 } { puts $db_fp "after init cell_sizes" } 
				set cell_sizes $a
				set sel($a) 1
			}
			
			
			
				if {[info exists insts($a)]} {
					set total_insts [split $inst]
					set l [llength $total_insts]
					#puts "cell_name $cell_name num $l"
					foreach inst $total_insts {
					lappend insts($a) $inst
					}
					
				} else {
					set insts($a) ""
					set total_insts [split $inst]
					set l [llength $total_insts]
					#puts "cell_name $cell_name num $l"
					foreach inst $total_insts {
					lappend insts($a) $inst
					}
				}
				
			} else {
#				puts "INFO: cell size of $cell_name cannot be found in cell list file."
				set systime [clock seconds]
				set time_now [clock format $systime]
				if {$detailed_log ==1 } { puts $log_file "INFO: cell size of $cell_name cannot be found in cell list file. at $time_now" }
				
			}
			}
			
			} else {
				if {[info exists printed($cell_name)]} {
				} else {
#				puts "INFO : $cell_name cannot be found in the design"
				set systime [clock seconds]
				set time_now [clock format $systime]
				if {$detailed_log ==1 } { puts $log_file "INFO : $cell_name cannot be found in the design at $time_now" }
				set printed($cell_name) 1
				}
			}
			
			
			}
			
			
			
			
		}
		
		
		
	}
	close $state_list_fp
#    puts "Date 2 = [exec date]\n"

	
	global sum_insts
	set sum_insts 0
	if {![info exists cell_sizes]} {

	puts "WARNING :None of the cells given in cell_list file is present in the design"
	if {[file exists $output_file]} {
		exec rm -rf $output_file
	}

	return
	
	}

	foreach cell_size $cell_sizes {

	if { [info exists insts($cell_size) ] } {
	set total_insts [llength $insts($cell_size) ]

	set sum_insts [expr $sum_insts+$total_insts]
	}
	}


	

	puts "Seed value $seedvalue specified"
  	puts "Instance will be selected based on seed $seedvalue"
 	expr srand($seedvalue)
		
		set ini_time [clock seconds]
		set comp_time [expr $ini_time+1200]
		
	set gsc_file_fp [open "$output_file" w]
	set state_config_fp [open "$state_config_file" r]
	puts "INFO: Reading state config file"
	set systime [clock seconds]
	set time_now [clock format $systime]
	puts $log_file "INFO: Reading state config file at $time_now "
	puts "Total No: of instances from the config file : $sum_insts"
	set systime [clock seconds]
	set time_now [clock format $systime]
	puts $log_file "Total No: of instances from the config file : $sum_insts at $time_now"
    flush $gsc_file_fp
    puts $gsc_file_fp "#EXACT_INSTANCE_NAME_MATCH" 
	while {[gets $state_config_fp line] >= 0} {
	##flush stdout
	flush $log_file
	flush $db_fp
	
		if {![regexp {^[\#]} $line] } {
		regsub -all {\t}  $line " " line1
		regsub -all -- {[[:space:]]+} $line1 " " line
			
			set words [split $line]
			set perc [lindex $words 0]
			if {$perc eq "" } {
				break
			}
			
			set range [lindex $words 1]
			set ranges [split $range "-"]
			set ut_in [lindex $ranges 1]
			set lt_in [lindex $ranges 0]
			
			

		 if { $debug_value == 1 } { puts $db_fp "percentage is $perc, sum of insts $sum_insts in line $line"  } 
		 flush $db_fp
		set num [expr $perc*$sum_insts/100 ]
		
		set c 0
		#this count the num of instances assigned with particular switching perc
		set count 0
		if { $debug_value == 1 } { puts $db_fp "num $num count $count" } 
	#asign oe instance each  from each cell_size
	#for {set i 0} { $i <= $sum_insts } {incr i } {  } 
    set nums ""
    for {set i 0} {$i<$sum_insts} {incr i} {lappend nums $i}
    for {set i 0} {$i<$sum_insts} {incr i} {
      set j [expr {int(rand()*$sum_insts)}]
      set temp [lindex $nums $j]
      set nums [lset nums $j [lindex $nums $i]]
      set nums [lset nums $i $temp]
   }

	foreach i $nums {  
	if {$count > $num || $num == 0} {
	break
	}
	##flush stdout
	flush $log_file
	flush $db_fp
	 if { $debug_value == 1 } { puts $db_fp "$line inside for loop $i"  } 
	foreach cell_size $cell_sizes {
	 if { $debug_value == 1 } { puts $db_fp "cell_size is $cell_size" }
	
#		if {$count <= [llength $insts($cell_size) ] } 
		
		if { [catch { set inst_gsc [ lindex $insts($cell_size) $i ] } ] == 0 } {
		if { $debug_value == 1 } { puts $db_fp " hi  $cell_size inst name is $inst_gsc"  }
		regsub {^\{+} $inst_gsc {} temp
		regsub {\}+$} $temp {} inst_gsc
		if {$inst_gsc ne "{}" && $inst_gsc ne "" } {
		#if { $debug_value == 1 } { puts $db_fp "instance name is $insts($cell_size) and $inst_gsc" } 
		if { [ catch {set cell [get inst_by_cid $inst_gsc -master ]} ] ==  0} { 
		set elems [array names cell_state $cell,*,*]
		 if { $debug_value == 1 } { puts $db_fp "inst $inst_gsc is valid and element of cell $cell are \n $elems"  } 
		foreach elem [array names cell_state $cell,*,*] {
		##flush stdout
		flush $log_file
		flush $db_fp
		
			set elem_line [split $elem ","]	
			set lt [lindex $elem_line 1]
			set ut [lindex $elem_line 2]
			set systime [clock seconds]
			if { $debug_value == 1 } { puts $db_fp "comtime $comp_time systime $systime" } 
		if {$comp_time <= $systime} {
		#puts "exiting before completion from up"
		
		}
			if { $debug_value == 1 } { puts $db_fp  "before gsc $lt_in and $ut_in and elem lt= $lt elem ut = $ut cell is $cell" } 
			
			if { ($lt_in==1 && $lt == 1) && ($ut_in == 1 && $ut == 1 )} {
				set gsc_state $cell_state($cell,$lt,$ut)
				if { ![info exists gsc_sel($inst_gsc)] } {
				##flush stdout
				flush $log_file
				flush $db_fp
				if { $debug_value == 1 } { puts $db_fp "insde gsc" } 
				#if {[file exists $output_file]} {
				#set gsc_file_fp [open "$output_file" a]
				#} else {
				#set gsc_file_fp [open "$output_file" w]
				#}
				flush $gsc_file_fp
                set inst_gsc_name [get inst_by_cid $inst_gsc -name]
				puts $gsc_file_fp "$inst_gsc_name $gsc_state "
				if {[info exists gsc_file_content]} {
				#lappend gsc_file_content "\n $inst_gsc $gsc_state"
				} else {
				#set gsc_file_content "\n $inst_gsc $gsc_state"
				}
				flush $gsc_file_fp
				#close $gsc_file_fp
				set gsc_sel($inst_gsc) 1
				incr count
				
				}
				break
			}

				if { ($lt_in == 1 ) && ($ut_in == 1 ) } {
				} else {
				if {$lt_in > $lt  && $ut_in <= $ut} {
			
				set gsc_states $cell_state($cell,$lt,$ut)
				set h [expr [llength $gsc_states] ]
				set rand_num [expr $h*rand()]
				set index [expr int($rand_num)]
				if { [catch { set gsc_state [lindex $gsc_states $index] } ] == 0 } {
				} else {
					break
				}
				if { $debug_value == 1 } { puts $db_fp "cell list for $cell $gsc_states threshold $lt $ut state is $gsc_state and index $index h is $h rand_num is $rand_num" } 
				
				#include a condition on seraching SCAN word on the state and decide whether to assign or not dependin go the mode inout
				
				
				if { ![info exists gsc_sel($inst_gsc)] } {
				##flush stdout
				flush $log_file
				flush $db_fp	
				if { $debug_value == 1 } { puts $db_fp "insde gsc not zero" } 
				#if {[file exists $output_file]} {
#				set gsc_file_fp [open "$output_file" a]
#				} else {
#				set gsc_file_fp [open "$output_file" w]
#				}
				flush $gsc_file_fp
                set inst_gsc_name [get inst_by_cid $inst_gsc -name]
				puts $gsc_file_fp "$inst_gsc_name $gsc_state "
				if {[info exists gsc_file_content]} {
				#lappend gsc_file_content "\n $inst_gsc $gsc_state"
				} else {
				#set gsc_file_content "\n $inst_gsc $gsc_state"
				}
				flush $gsc_file_fp
				#close $gsc_file_fp
				set gsc_sel($inst_gsc) 1
				incr count
				
				}
				if { $debug_value == 1 } { puts $db_fp "state is $gsc_state and count is $count and nume is $num"  } 
				
				
				break
			}
			}

			if { ($lt_in==0 && $lt == 0) && ($ut_in == 0 && $ut == 0 )} {
				set gsc_state $cell_state($cell,$lt,$ut)
				if { ![info exists gsc_sel($inst_gsc)] } {
				##flush stdout
				flush $log_file
				flush $db_fp
				if { $debug_value == 1 } { puts $db_fp "insde gsc" } 
				#if {[file exists $output_file]} {
				#set gsc_file_fp [open "$output_file" a]
				#} else {
				#set gsc_file_fp [open "$output_file" w]
				#}
				flush $gsc_file_fp
                set inst_gsc_name [get inst_by_cid $inst_gsc -name]
				puts $gsc_file_fp "$inst_gsc_name $gsc_state "
				if {[info exists gsc_file_content]} {
				#lappend gsc_file_content "\n $inst_gsc $gsc_state"
				} else {
				#set gsc_file_content "\n $inst_gsc $gsc_state"
				}
				flush $gsc_file_fp
				#close $gsc_file_fp
				set gsc_sel($inst_gsc) 1
				incr count
				
				}
				break
			}
			
		}
		}
		}
		
#		
		}
		set systime [clock seconds]
		if {$comp_time <= $systime} {
		#puts "exiting before completion"
		#return
		}
		
		}
	
	}
	puts "Total num of instances assigned for the line $line in config file $count"
	set systime [clock seconds]
	set time_now [clock format $systime]
	##flush stdout
	flush $log_file
	flush $db_fp
	puts $log_file "Total num of instances assigned for the line $line in config file $count at $time_now" 
		
	}

	}
	close $state_config_fp
	set dropped_file [open "createGSC_dropped_insts.rpt" w]
	flush $dropped_file
	puts $dropped_file "#This file reports the instances which are dropped by the script"
	puts $dropped_file "#inst_name cell_name  cell_size"
	puts "Instances which were dropped by the script are present in file createGSC_dropped_insts.rpt"
	set systime [clock seconds]
	set time_now [clock format $systime]
	##flush stdout
	flush $log_file
	flush $db_fp
	puts $log_file "Instances which were dropped by the script are present in file createGSC_dropped_insts.rpt at $time_now" 
	foreach cell_size $cell_sizes {
		foreach inst $insts($cell_size) {
			regsub {^\{+} $inst {} temp
			regsub {\}+$} $temp {} inst
			
			if { [ catch { set mas [get inst_by_cid $inst -master ] }  ] == 0 } {
			} else {
			set mas "-"
			}

			if {![info exists gsc_sel($inst)]} {
			##flush stdout
			flush $dropped_file
            set inst_name [get inst_by_cid $inst -name] 
			puts $dropped_file "$inst_name $mas $cell_size"
			flush $dropped_file

			}
		}
	}
	close $dropped_file 
				
	
	

close $db_fp	
flush $gsc_file_fp
puts $gsc_file_fp "#END_EXACT_INSTANCE_NAME_MATCH"
close $gsc_file_fp
puts "INFO: Finished creating the gsc file"
set systime [clock seconds]
set time_now [clock format $systime]
puts $log_file "INFO: Finished creating the gsc file at $time_now" 
close $log_file


license rhe_mode off	
}
