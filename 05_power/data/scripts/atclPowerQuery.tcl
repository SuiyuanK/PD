#$Revision: 1.7 $

################################################################################################################
# Name       : atclPowerQuery.tcl
# Description: It dumps out the power/current for selected voltage domains
# Author     : Nikhil.A.Nair , email : nikhil@apache-da.com
################################################################################################################

proc atclPowerQuery_manpage {} {
 
 	puts "\nSYNOPSIS\n"
 	puts "Apache-AE TCL utility for querying power or current for selected voltage domains within a region\n\n"
 	puts "USAGE\n"
 	puts "atclPowerAssign \[option_arguments\]\n"
 	puts "\n\tOptions:\n"
 	puts "\t-net <voltage_domain> The voltage domain for which the power or current is to be scaled\n"
 	puts "\t-bbox <x1 y1 x2 y2> The region for which the power or current is to be queried\n"
	puts "\t-help command usage\n"
 	puts "\t-man man page\n"
 	return
} 


proc atclPowerQuery_help {} {

	puts "Usage: atclPowerQuery -net <net_name> -bbox <x1 y1 x2 y2> \[-help <1>\] \[-man <1>\]\n"
 	return
} 
 

proc atclPowerQuery {args} {
 
 	set mode 1
	set argv [split $args]
 	foreach arg $argv {
  		switch -glob -- $arg {
   			-h* {atclPowerQuery_help;return}
   			-m* {atclPowerQuery_manpage;return}
  		}
 	}  
 	array set opt [concat {-net "NET" -bbox "" -help 0 -man 0} $args]
 	set net $opt(-net)
 	set bbox $opt(-bbox)
 	set help $opt(-help)
 	set man $opt(-man)
 	if { $net == "NET"} {
		puts "Specify the voltage domain for which power or current is to be scaled\n"
		return
	}
	if { $bbox == "" } {
		set region_all 1
	}
	if { $bbox != "" } {
		set region_all 0
		set regions [split $bbox]
		set x1_loc [lindex $regions 0]
		set y1_loc [lindex $regions 1]
		set x2_loc [lindex $regions 2]
		set y2_loc [lindex $regions 3]
		puts "bbox \"$x1_loc $y1_loc $x2_loc $y2_loc\""
		if {$x1_loc >= $x2_loc || $y1_loc >= $y2_loc} {
			puts "Invalid bounding box"
			return
		}	
	}
	set file [glob "adsPower/*.power"]
	set number [exec wc -l $file]
	set line_number [lindex $number 0]
	if {![file exists output]} {
		if { [catch { dump mmx_pin_info -o output }  err] } {
				puts "Please use a version which supports the tcl command \"dump mmx_pin_info\""
				return
		}
	}	
	set file1 [open "output" r]
	set k 0
	while {[gets $file1 line] >= 0} {
		set lines1($k) $line	
		incr k
	}
	close $file1
	set count 0
	for {set j 0} {$j<$k} {incr j} {
		if {[regexp -nocase {adsU1:} $lines1($j)] == 1} {
			regsub { [" "]*} $lines1($j) { } lines2($j)
			regsub {\t} $lines2($j) { } lines1($j)
			set line1 [regexp -inline -all -- {\S+} $lines1($j)]
			set line [split $lines1($j)]
			set lin [split [lindex $line 0] ":"]
			set inst_name [lindex $lin 0]
			set pin_name [lindex $lin 1]
			set net_name [lindex [split $pin_name "."] 0]
			set include($inst_name,$pin_name) 0
			set x [lindex $lines1($j) 3]
			set x_l [split $x "("]
			set x_loc1 [lindex $x_l 1]
			set y [lindex $lines1($j) 4]
			set y_l [split $y ")"]
			set y_loc1 [lindex $y_l 0]
			set x [lindex $lines1($j) 5]
			set x_l [split $x "("]
			set x_loc2 [lindex $x_l 1]
			set y [lindex $lines1($j) 6]
			set y_l [split $y ")"]
			set y_loc2 [lindex $y_l 0]
			set x_sum [expr $x_loc1 + $x_loc2]
			set y_sum [expr $y_loc1 + $y_loc2]
			set x_loc [expr $x_sum / 2]
			set y_loc [expr $y_sum / 2]
			if { $region_all == 0} {
				if { $x_loc>=$x1_loc && $x_loc<=$x2_loc && $y_loc>=$y1_loc && $y_loc<=$y2_loc } {
					#puts "$inst_name $pin_name $x_loc $y_loc"
					set include($inst_name,$pin_name) 1
					incr count
				}
			} elseif { $region_all == 1 } {	
				set include($inst_name,$pin_name) 1
				incr count
			}			
		}
	}
	
	if { $count == 0 } {
		puts "No transistor pins found in this region"
		return
	}
			
	set file [glob "adsPower/*.power"]
	set file1 [open $file r]
	set k1 0
	while {[gets $file1 line] >= 0} {
		set lines2($k1) $line	
		incr k1
	}
	close $file1
	set count 0
	set cumulative_power 0
	set cumulative_current 0
	set file1 [open "queried_xtors" w+]
	for {set j 0} {$j<$k1} {incr j} {
		if {$j>=1} {
			set line [split $lines2($j)]
			set pin_name [lindex $line 34]
			set nets [lindex $line 25]
			if {$pin_name != ""} {
				set lines($inst_name,$pin_name) [split $lines2($j)]
				if {[info exists include($inst_name,$pin_name)]} {
					if { $include($inst_name,$pin_name) == 1 } {
						if {$nets == $net} {
						 	set total_power [expr [lindex $line 26] + 0]
							set total_current [expr [lindex $line 36] +0]
					 		set cumulative_power [expr $cumulative_power + $total_power]
							set cumulative_current [expr $cumulative_current + $total_current]
							incr count
							puts $file1 "$inst_name $pin_name $total_power $total_current"
						}	
					}
				}
			}			
		} 	
	}
	close $file1
	if { $count == 0 } {
		puts "Net $net is not found within the bounding box"
		return
	}	
	puts "Cumulative power=$cumulative_power\nCumulative Current=$cumulative_current"
}			

