proc atclPlotPowerMap_manpage {} {
 
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


proc atclPlotPowerMap_help {} {

	puts "Usage: atclPowerAssign -net <net_name> \[-help <1>\] \[-man <1>\]\n"
 	return
} 
 

proc atclPlotPowerMap {args} {
 
 	set mode 1
	set argv [split $args]
 	foreach arg $argv {
  		switch -glob -- $arg {
   			-h* {atclPlotPowerMap_help;return}
   			-m* {atclPlotPowerMap_manpage;return}
  		}
 	}  
 	array set opt [concat {-net "NET" -help 0 -man 0} $args]
 	set net $opt(-net)
 	set help $opt(-help)
 	set man $opt(-man)
 	if { $net == "NET"} {
		puts "Specify the voltage domain for which power map is to be plotted\n"
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
	for {set j 0} {$j<$k1} {incr j} {
		if {$j>=1} {
			set line [split $lines2($j)]
			set pin_name [lindex $line 34]
			set nets [lindex $line 25]
			if {$pin_name != ""} {
				set lines($pin_name) [split $lines2($j)]
				if {$nets == $net} {
					set total_power($pin_name) [expr [lindex $line 26] + 0]
					set total_current($pin_name) [expr [lindex $line 36] +0]
					set cumulative_power [expr $cumulative_power + $total_power($pin_name)]
					set cumulative_current [expr $cumulative_current + $total_current($pin_name)]
					incr count
				}
			}			
		} 	
	}
	if { $count == 0 } {
		puts "Net $net is not found in the design"
		return
	}
	puts "$count"	
	puts "Cumulative power=$cumulative_power\nCumulative Current=$cumulative_current"
	
	set file [glob "adsPower/*.power"]
	set number [exec wc -l $file]
	set line_number [lindex $number 0]
	if { [catch {generate mmx_pin_info -o output} err] } {
			puts "Please use a version which supports the tcl command \"generate mmx_pin\""
			return
	}		
	set file1 [open "output" r]
	set k 0
	while {[gets $file1 line] >= 0} {
		set lines1($k) $line	
		incr k
	}
	close $file1
	for {set j 0} {$j<$k} {incr j} {
		if {$j >= 1} {
			set line [split $lines1($j)]
			set pin_name [lindex $line 0] 
			set include($pin_name) 0
			set x [lindex $line 1]
			set x_l [split $x "("]
			set x_location($pin_name) [lindex $x_l 1]
			set y [lindex $line 2]
			set y_l [split $y ")"]
			set y_location($pin_name) [lindex $y_l 0]
		}
	}
	
	set pow [lsort [array get total_power]]
	set length [expr [llength $pow] - 1]
	set powe [lreplace $pow $count $length]
	set power [lsort -real -increasing $powe] 	
	set min [lindex $power 0]
	set max [lindex $power [expr $count - 1]]
	set bucket [expr $count/7]
	
	set value_bucket1 [lindex $power $bucket]
	puts "Between $min and $value_bucket1 : Color - White"
	set file1 [open "white.rpt" w+]
	puts $file1 "#<pin_name> <X_location> <Y-location> <Power>"
	set value_bucket2 [lindex $power [expr $bucket * 2]]
	puts "Between $value_bucket1 and $value_bucket2 : Color - Green"
	set file2 [open "green.rpt" w+]
	puts $file2 "#<pin_name> <X_location> <Y-location> <Power>"
	set value_bucket3 [lindex $power [expr $bucket * 3]]
	puts "Between $value_bucket2 and $value_bucket3 : Color -Blue"
	set file3 [open "blue.rpt" w+]
	puts $file3 "#<pin_name> <X_location> <Y-location> <Power>"
	set value_bucket4 [lindex $power [expr $bucket * 4]]
	puts "Between $value_bucket3 and $value_bucket4 : Color - Yellow"
	set file4 [open "yellow.rpt" w+]
	puts $file4 "#<pin_name> <X_location> <Y-location> <Power>"
	set value_bucket5 [lindex $power [expr $bucket * 5]]
	puts "Between $value_bucket4 and $value_bucket5 : Color - Orange"
	set file5 [open "orange.rpt" w+]
	puts $file5 "#<pin_name> <X_location> <Y-location> <Power>"
	set value_bucket6 [lindex $power [expr $bucket * 6]]
	puts "Between $value_bucket5 and $value_bucket6 : Color - Pink"
	set file6 [open "pink.rpt" w+]
	puts $file6 "#<pin_name> <X_location> <Y-location> <Power>"
	puts "Between $value_bucket6 and $max : Color - Red"
	set file7 [open "red.rpt" w+]
	puts $file7 "#<pin_name> <X_location> <Y-location> <Power>"
	marker delete -all
	config viewlayer  -name all -style invisible
	refresh
	foreach pin_name [array names total_power] {
		set power_value $total_power($pin_name)
		set flag($pin_name) 0
		if { $power_value <= $value_bucket1 && $flag($pin_name) == 0 } {
			marker add -position $x_location($pin_name) $y_location($pin_name)  -color white -size 2
			set flag($pin_name) 1
			puts $file1 "$pin_name $x_location($pin_name) $y_location($pin_name) $total_power($pin_name)"
		}	
		if { $power_value <= $value_bucket2 && $flag($pin_name) == 0 } {
			marker add -position $x_location($pin_name) $y_location($pin_name)  -color green -size 2
			set flag($pin_name) 1
			puts $file2 "$pin_name $x_location($pin_name) $y_location($pin_name) $total_power($pin_name)"
		}
		if { $power_value <= $value_bucket3 && $flag($pin_name) == 0 } {
			marker add -position $x_location($pin_name) $y_location($pin_name)  -color blue -size 2
			set flag($pin_name) 1
			puts $file3 "$pin_name $x_location($pin_name) $y_location($pin_name) $total_power($pin_name)"
		}
		if { $power_value <= $value_bucket4 && $flag($pin_name) == 0 } {
			marker add -position $x_location($pin_name) $y_location($pin_name)  -color yellow -size 2
			set flag($pin_name) 1
			puts $file4 "$pin_name $x_location($pin_name) $y_location($pin_name) $total_power($pin_name)"
		}
		if { $power_value <= $value_bucket5 && $flag($pin_name) == 0 } {
			marker add -position $x_location($pin_name) $y_location($pin_name)  -color orange -size 2
			set flag($pin_name) 1
			puts $file5 "$pin_name $x_location($pin_name) $y_location($pin_name) $total_power($pin_name)"
		}
		if { $power_value <= $value_bucket6 && $flag($pin_name) == 0 } {
			marker add -position $x_location($pin_name) $y_location($pin_name)  -color pink -size 2
			set flag($pin_name) 1
			puts $file6 "$pin_name $x_location($pin_name) $y_location($pin_name) $total_power($pin_name)"
		}
		if { $power_value >= $value_bucket6 && $flag($pin_name) == 0 } {
			marker add -position $x_location($pin_name) $y_location($pin_name)  -color red -size 2
			set flag($pin_name) 1
			puts $file7 "$pin_name $x_location($pin_name) $y_location($pin_name) $total_power($pin_name)"
		}
	}
	close $file1
	close $file2
	close $file3
	close $file4
	close $file5
	close $file6
	close $file7	
}			

