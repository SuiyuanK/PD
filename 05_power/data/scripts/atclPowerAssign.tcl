#$Revision: 1.15 $

################################################################################################################
# Name       : atclPowerAssign.tcl
# Description: It scales the power/current for selected voltage domains
# Author     : Nikhil.A.Nair , email : nikhil@apache-da.com
################################################################################################################

proc atclPowerAssign_manpage {} {
 
 	puts "\nSYNOPSIS\n"
 	puts "Apache-AE TCL utility for scaling power or current for selected voltage domains\n\n"
 	puts "USAGE\n"
 	puts "atclPowerAssign \[option_arguments\]\n"
 	puts "\n\tOptions:\n"
 	puts "\t-net <voltage_domain> Specify the voltage domain for which the power or current is to be scaled\n"
 	puts "\t-pwr <Power in Watts> Specify the target power\n"
 	puts "\t-i <Current in Amps> Specify the target current. Cannot use this option along with -pwr\n"
 	puts "\t-bbox <x1 y1 x2 y2>/current_zoom Specify the region(x1,y1 and x2,y2) for which the power or current is to be scaled/Zoom into a region(in the GUI) for which power or current is to be scaled\n"
	puts "\t-reset It will restore the original adsPower/*.nets.adsLib.power file created during perform pwrcalc\n"
	puts "\t-undo It will undo the previous power assignment performed\n"
	puts "\t-done It will import adsPower, perform extraction and perform static analysis\n"
	puts "\t-help command usage\n"
 	puts "\t-man man page\n"
 	return
} 


proc atclPowerAssign_help {} {

	puts "Usage: atclPowerAssign -net <net_name> -pwr <Power in Watts> -i <Current in Amps> -bbox <x1 y1 x2 y2>/current_zoom -file <area_power file> \[-reset\] \[-undo\] \[-done\] \[-help \] \[-man \]\n"
 	return
} 
 
proc atclPowerAssign_reset {} {

	set file [glob "adsPower/*.nets.adsLib.power"]
	file copy -force -- adsPower/power.first $file
	puts "Restored the initial $file file"
}

proc atclPowerAssign_undo {} {

	set file [glob "adsPower/*.nets.adsLib.power"]
	file copy -force -- adsPower/power $file
	puts "Restored the previous $file file"
}

proc atclPowerAssign_done {} {

	puts "import power adsPower"
	import power adsPower
	puts "perform extraction -power -ground"
	perform extraction -power -ground
	puts "perform analysis -static"
	perform analysis -static
}			

proc atclPowerAssign_multipleAssignments {args} {
	
	array set opt [concat {-file "FILE"} $args]
 	set file_hier $opt(-file)
 	
	if { $file_hier != "FILE" } {
		set file [open $file_hier r]
	} else {
		puts "Please mention the file containing the power information"
		return
	}	
			
	set k 0
	while {[gets $file line] >= 0} {
		set lines($k) $line	
		incr k
	}
	close $file
	set j 0
	set j1 0
	set j2 0
	set full 0
	set vdd_nets [gsr get VDD_NETS]
	set vdd [split $vdd_nets "\n"]
	set vdd_num [llength $vdd] 
	for {set i1 1} {$i1 < [expr $vdd_num -2]} {incr i1} {
		set vdd_net($i1) [lindex [split [lindex $vdd $i1]] 0]
		puts "$vdd_net($i1)"
	}	
	set vss_nets [gsr get GND_NETS]
	set vss [split $vss_nets "\n"]
	set vss_num [llength $vss] 
	for {set i2 1} {$i2 < [expr $vss_num -2]} {incr i2} {
		set vss_net($i2) [lindex [split [lindex $vss $i2]] 0]
		puts "$vss_net($i2)"
	}
	for {set i 0} {$i<$k} {incr  i} {
		if {[regexp -nocase {FULLCHIP} $lines($i)] == 1} {
			regsub {^( )*} $lines($i) {} line2
			regsub {^(|\t)*} $line2 {} line1
			set line1 [regexp -inline -all -- {\S+} $lines($i)]
			set line [split $line1]
			set word($j) [lindex $line 1]
			if {![regexp {^\#} $line]} {
				if {[regexp -nocase {FULLCHIP} $word($j)]} {
					set net1($full) [lindex $line 3]
					for {set x 1} {$x < $i1} {incr x} {
						if {$net1($full)==$vdd_net($x)} {
							set net_status 1
						}
					}
					for {set x 1} {$x < $i2} {incr x} {
						if {$net1($full)==$vss_net($x)} {
							set net_status 0
						}
					}
					if {$net_status==1} {		
						set pwr1($net1($full)) [lindex $line 2]
						if {![info exists diff($net1($full))]} {
							set diff_pwr($net1($full)) $pwr1($net1($full))
						} else {
							set diff_pwr($net1($full)) [expr $diff_pwr($net1($full)) + $pwr1($net1($full))]
						}		
						incr full
					}
					if {$net_status==0} {		
						set cur1($net1($full)) [lindex $line 2]
						if {![info exists diff_cur($net1($full))]} {
							set diff_cur($net1($full)) $cur1($net1($full))
						} else {
							set diff_cur($net1($full)) [expr $diff_cur($net1($full)) + $cur1($net1($full))]
						}		
						incr full
					}	
				}	
				if {[regexp -nocase {REGION} $word($j)]} {
					set x1($j1) [lindex $line 2]
					set y1($j1) [lindex $line 3]
					set x2($j1) [lindex $line 4]
					set y2($j1) [lindex $line 5]
					set net($j1) [lindex $line 7]
					set block($j1) $word($j1)
					set net_status 2
					for {set x 1} {$x < $i1} {incr x} {
						if {$net($j1)==$vdd_net($x)} {
							set net_status 1
						}
					}
					for {set x 1} {$x < $i2} {incr x} {
						if {$net($j1)==$vss_net($x)} {
							set net_status 0
						}
					}
					if {$net_status==1} {
						set pwr($j1) [lindex $line 6]
						#puts "$pwr($j1) is power"
						if {![info exists diff_pwr($net($j1))]} {
							set diff_pwr($net($j1)) 0
						}
						#set diff_pwr($net($j1)) [expr $diff_pwr($net($j1)) - $pwr($j1)]
						incr j1
					}
					if {$net_status==0} {
						set cur($j1) [lindex $line 6]
						#puts "$cur($j1) is current"
						if {![info exists diff_cur($net($j1))]} {
							set diff_cur($net($j1)) 0
						}
						#set diff_cur($net($j1)) [expr $diff_cur($net($j1)) - $cur($j1)]
						incr j1
					}	
				}
				if {[regexp -nocase {INST} $word($j)]} {
					set block_name [lindex $line 2]
					set nets($j2) [lindex $line 4]
					set xtor($j2) $block_name
					for {set x 1} {$x < $i1} {incr x} {
						if {$nets($j2)==$vdd_net($x)} {
							set net_status 1
						}
					}
					for {set x 1} {$x < $i2} {incr x} {
						if {$nets($j2)==$vss_net($x)} {
							set net_status 0
						}
					}
					if {$net_status==1} {
						set pwrs($j2) [lindex $line 3]
						if {![info exists diff_pwr($nets($j2))]} {
							set diff_pwr($nets($j2)) 0
						}	
						set diff_pwr($nets($j2)) [expr $diff_pwr($nets($j2)) - $pwrs($j2)]
						incr j2
					}
					if {$net_status==0} {
						set curs($j2) [lindex $line 3]
						if {![info exists diff_cur($nets($j2))]} {
							set diff_cur($nets($j2)) 0
						}	
						set diff_cur($nets($j2)) [expr $diff_cur($nets($j2)) - $curs($j2)]
						incr j2
					}	
				}
			incr j
			}				
		}
	}
	set i11 0
	set i12 0
	set num 0
	for {set i 0} {$i < $j1} {incr i} {
		for {set k1 0} {$k1 < $j1} {incr k1} {
			if {$i == 0 && $k1 == 1} {
				#puts "$x1($i) $y1($i) $x2($i) $y2($i) and $x1($k1) $y1($k1) $x2($k1) $y2($k1)"
			}	
			if {$i != $k1} {
				if {$y1($k1) >= $y2($i) || $y1($i) >= $y2($k1)} {
				} elseif {$x1($k1) >= $x2($i) || $x1($i) >= $x2($k1)} {
				} else {
					if { $num == 0 && $net($k1)==$net($i)} {
						puts "Warning : Some blocks are overlapping"
						incr num
					}		
				}
				if {$x1($k1) >= $x2($i) || $x1($i) >= $x2($k1)} {
				} elseif {$y1($k1) >= $y2($i) || $y1($i) >= $y2($k1)} {
				} else {
					if {$num == 0 && $net($k1)==$net($i)} {
						puts "Warning : Some blocks are overlapping"
						incr num
					}	
				}
				if {$x1($i) <= $x1($k1) && $x2($i) >= $x2($k1) && $y1($i) <= $y1($k1) && $y2($i) >= $y2($k1)} {
					if {$net($k1) == $net($i)} {
						lappend inside($i) $k1
					}
				}
				if {$x1($k1) <= $x1($i) && $x2($k1) >= $x2($i) && $y1($k1) <= $y1($i) && $y2($k1) >= $y2($i)} {
					if {$net($k1) == $net($i)} {
						lappend inside($k1) $i
					}
				}
			}			
		}
		if {[info exists inside($i)]} {
			#puts "$inside($i)"
		}
	}			
		
	set highest 1
	for {set p 0} {$p < $highest} {incr p} {
		for {set i 0} {$i < $j1} {incr i} {
			if {![info exists hier($i)]} { 
				set hier($i) 1
				set region($i) $i
			}	
			if {[info exists inside($i)]} {
				for {set z 0} {$z < $j1} {incr z} {
					if {$net($z) == $net($i)} {
						set let [lsearch $inside($i) $z]
						if {$let >= 0} {
							if {$p==0 || $hier($z) == $hier($i)} {
								set hier($z) [expr $hier($i) + 1]
							#puts "Inside block$i with hier $hier($i) is block$z with hier $hier($z)"
							}
							set region($z) $region($i)
							if {$hier($z) >= $highest} {
								set highest $hier($z)
							}	
						}	
					}
				}		
			}	
		}
		#puts "$highest is the highest hierarchy in the 1st iteration"
		for {set i [expr $j1 - 1]} {$i >= 0} {incr i -1} {
			if {![info exists hier($i)]} { 
				set hier($i) 1
				set region($i) $i
			}	
			if {[info exists inside($i)]} {
				for {set z [expr $j1 - 1]} {$z >= 0} {incr z -1} {
					if {$net($z) == $net($i)} {
						set let [lsearch $inside($i) $z]
						if {$let >= 0} {
							if {$hier($z) == $hier($i)} {
								set hier($z) [expr $hier($i) + 1]
							}
							#puts "Inside block$i with hier $hier($i) is block$z with hier $hier($z)"
							set region($z) $region($i)
							if {$hier($z) >= $highest} {
								set highest $hier($z)
							}	
						}	
					}
				}
			}
		}		
		#puts "$highest is the highest hierarchy in the second iteration"
	}		
			
	for {set z $highest} {$z >= 1} {incr z -1} {
		for {set i 0} {$i < $j1} {incr i} {
			if {$z == 1} {
				if {[info exists diff_pwr($net($i))]} {
					if {$hier($i) == 1} {
						set diff_pwr($net($i)) [expr $diff_pwr($net($i)) - $pwr($i)]
					}
					if {$diff_pwr($net($i)) < 0 && [info exists pwr1($net($i))]} {
						puts "The Fullchip Power is less than Sum of the Powers assigned to the regions for net $net($i)"
						return
					}	
				}
				if {[info exists diff_cur($net($i))]} {
					if {$hier($i) == 1} {
						set diff_cur($net($i)) [expr $diff_cur($net($i)) - $cur($i)]
					}
					if {$diff_cur($net($i)) < 0 && [info exists cur1($net($i))]} {
						puts "The Fullchip Current is less than Sum of the currents assigned to the regions for net $net($i)"
						return
					}	
				}
			}		
			if {$hier($i) == $z} {
				for {set x 1} {$x < $i1} {incr x} {
					if {$net($i) == $vdd_net($x)} {
						if {[info exists inside($i)]} {
							set power($i) $pwr($i)
							for {set s 0} {$s < $k} {incr s} {
								set let [lsearch $inside($i) $s]
								if {$let >= 0} {
				 					if {$hier($i) == [expr $hier($s)-1]} {
									 	set power($i) [expr $power($i) - $pwr($s)]
									}
								}
							}
							puts "\n\natclPowerAssign -net $net($i) -pwr $power($i) -bbox \"$x1($i) $y1($i) $x2($i) $y2($i)\" -hier $z"
							#puts "$full is value of full"
							#return
							atclPowerAssign -net $net($i) -pwr $power($i) -bbox "$x1($i) $y1($i) $x2($i) $y2($i)" -hier $z
							#atclPowerQuery -net $net($i) -bbox "$x1($i) $y1($i) $x2($i) $y2($i)"  
						} else {
							puts "\n\natclPowerAssign -net $net($i) -pwr $pwr($i) -bbox \"$x1($i) $y1($i) $x2($i) $y2($i)\" -hier $z"
							atclPowerAssign -net $net($i) -pwr $pwr($i) -bbox "$x1($i) $y1($i) $x2($i) $y2($i)" -hier $z
							#atclPowerQuery -net $net($i) -bbox "$x1($i) $y1($i) $x2($i) $y2($i)"
						}
					}		
				}
				for {set x 1} {$x < $i2} {incr x} {
					if {$net($i) == $vss_net($x)} {
						if {[info exists inside($i)]} {
							set current($i) $cur($i)
							for {set s 0} {$s < $k} {incr s} {
								set let [lsearch $inside($i) $s]
								if {$let >= 0} {
									if {$hier($i) == [expr $hier($s)-1]} {
									 	set current($i) [expr $current($i) - $cur($s)]
									}
								}
							}
							puts "\n\natclPowerAssign -net $net($i) -i $current($i) -bbox \"$x1($i) $y1($i) $x2($i) $y2($i)\" -hier $z"
							atclPowerAssign -net $net($i) -i $current($i) -bbox "$x1($i) $y1($i) $x2($i) $y2($i)" -hier $z
							#atclPowerQuery -net $net($i) -bbox "$x1($i) $y1($i) $x2($i) $y2($i)"
						} else {
							puts "\n\natclPowerAssign -net $net($i) -i $cur($i) -bbox \"$x1($i) $y1($i) $x2($i) $y2($i)\" -hier $z"
							atclPowerAssign -net $net($i) -i $cur($i) -bbox "$x1($i) $y1($i) $x2($i) $y2($i)" -hier $z
							#atclPowerQuery -net $net($i) -bbox "$x1($i) $y1($i) $x2($i) $y2($i)"
						}
					}		
				}
			}
		}
	}
	for {set i 0} {$i < $full} {incr i} {
		if {[info exists diff_pwr($net1($i))] == 1} {
			if {$diff_pwr($net1($i)) < 0} {
				puts "The Fullchip Power is less than Sum of the Powers assigned to the regions for net $net1($i)"
				return
			}	
		}
		if {[info exists diff_cur($net1($i))] == 1} {
			if {$diff_cur($net1($i)) < 0} {
				puts "The Fullchip Current is less than Sum of the Currents assigned to the regions for net $net1($i)"
				return
			}	
		}
	}
	
	#return		
	for {set k1 0} {$k1<$j2} { incr k1} {
		if {[regexp -nocase {INST} $word($k1)]} {
			if {$i12<$j2} {
				for {set x 1} {$x < $i1} {incr x} {
					if {$nets($i12)==$vdd_net($x)} {
						set net_status 1
					}
				}
				for {set x 1} {$x < $i2} {incr x} {
					if {$nets($i12)==$vss_net($x)} {
						set net_status 0
					}
				}
				if {$net_status==1} {
					puts "\n\natclPowerAssign -net $nets($i12) -pwr $pwrs($i12) -block $xtor($i12)"
					atclPowerAssign -net $nets($i12) -pwr $pwrs($i12) -block $xtor($i12)
					incr i12
				}
				if {$net_status==1} {
					puts "\n\natclPowerAssign -net $nets($i12) -i $curs($i12) -block $xtor($i12)"
					atclPowerAssign -net $nets($i12) -i $curs($i12) -block $xtor($i12)
					incr i12
				}	
			}	
		}
	}
	for {set i 0} {$i < $full} {incr i} {
		for {set x 1} {$x < $i1} {incr x} {
			if {$net1($i)==$vdd_net($x)} {
				set net_status 1
			}
		}
		for {set x 1} {$x < $i2} {incr x} {
			if {$net1($i)==$vss_net($x)} {
				set net_status 0
			}
		}
		if {$net_status==1} {
			if {[info exists diff_pwr($net1($i))] == 1} {
				if {$i == [expr $full - 1]} {
					puts "\n\natclPowerAssign -net $net1($i) -pwr $diff_pwr($net1($i)) -rest 2"
					atclPowerAssign -net $net1($i) -pwr $diff_pwr($net1($i)) -rest 2
					#atclPowerQuery 	-net $net1($i)
				} else {	
					puts "\n\natclPowerAssign -net $net1($i) -pwr $diff_pwr($net1($i)) -rest 1"
					atclPowerAssign -net $net1($i) -pwr $diff_pwr($net1($i)) -rest 1
					#atclPowerQuery 	-net $net1($i)	
				}	
			}
		}
		if {$net_status==0} {
			if {[info exists diff_cur($net1($i))] == 1} {
				if {$i == [expr $full - 1]} {
					puts "\n\natclPowerAssign -net $net1($i) -i $diff_cur($net1($i)) -rest 2"
					atclPowerAssign -net $net1($i) -i $diff_cur($net1($i)) -rest 2
					#atclPowerQuery 	-net $net1($i)
				} else {	
					puts "\n\natclPowerAssign -net $net1($i) -i $diff_cur($net1($i)) -rest 1"
					atclPowerAssign -net $net1($i) -i $diff_cur($net1($i)) -rest 1
					#atclPowerQuery 	-net $net1($i)
				}	
			}
		}	
	}		
}
			
	
proc atclPowerAssign {args} {
 
 	set mode 1
	set argv [split $args]
 	foreach arg $argv {
  		switch -glob -- $arg {
   			-help {atclPowerAssign_help;return}
   			-m* {atclPowerAssign_manpage;return}
			-reset {atclPowerAssign_reset;return}
			-undo {atclPowerAssign_undo;return}
			-done {atclPowerAssign_done;return}
			-clear {atclPowerAssignClear;return}
		}
 	}  
 	array set opt [concat {-net "NET" -pwr "POWER" -i "CURRENT" -bbox "" -rest "REST" -file "FILE" -block "BLOCK" -hier "HIER" -done 0 -help 0 -man 0} $args]
 	set net $opt(-net)
 	set pwr $opt(-pwr)
 	set i $opt(-i)
	set bbox $opt(-bbox)
	set done $opt(-done)
 	set help $opt(-help)
 	set man $opt(-man)
	set rest $opt(-rest)
	set xtor $opt(-block)
	set file $opt(-file)
	set hier $opt(-hier)
	
	if { $file != "FILE" } {
		atclPowerAssign_multipleAssignments -file $file
		return
	}	
	if { $net == "NET"} {
		puts "Specify the voltage domain for which power or current is to be scaled\n"
		return
	}
	if { $pwr == "POWER" && $i == "CURRENT"} {
		puts "Specify power or current for the specified voltage domain\n"
		return
	}
	if { $pwr != "POWER" && $i != "CURRENT"} {
		puts "Cannot specify both power and current for the specified voltage domain\n"
		return
	}		
	if { $pwr != "POWER" && $i == "CURRENT"} {
		set mode 1
	}
	if { $pwr == "POWER" && $i != "CURRENT"} {
		set mode 2
	}
	set region_all 2
	if { $bbox == "" && $xtor == "BLOCK" } {
		set region_all 1
	}
	if { $bbox != "" } {
		set region_all 0
		if {$bbox == "current_zoom"} {
			set bbox [zoom get]
		}	
		set regions [split $bbox]
		set x1_loc [lindex $regions 0]
		set y1_loc [lindex $regions 1]
		set x2_loc [lindex $regions 2]
		set y2_loc [lindex $regions 3]
		if {$x1_loc >= $x2_loc || $y1_loc >= $y2_loc} {
			puts "Invalid bounding box"
			return
		}	
	}
	global var
	global not_include
	global hier_include	
	set file [glob "adsPower/*nets.adsLib.power"]
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
	#if {![info exists hier]} {
	#	set hier 1
	#}	
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
			if {$rest == "REST"} {
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
					#puts "Entered the loop"
					if { $x_loc>=$x1_loc && $x_loc<=$x2_loc && $y_loc>=$y1_loc && $y_loc<=$y2_loc && $net_name == $net} {
						if {$hier ne "HIER"} {
							if {![info exists hier_include($inst_name,$pin_name)]} {
								set include($inst_name,$pin_name) 1
								set not_include($inst_name,$pin_name) 0
								set hier_include($inst_name,$pin_name) 1
							} elseif {$hier_include($inst_name,$pin_name) == 1} {
									set include($inst_name,$pin_name) 0
									set not_include($inst_name,$pin_name) 0
							} 
							incr count
						} elseif {$hier eq "HIER"} { 
							set include($inst_name,$pin_name) 1
							set not_include($inst_name,$pin_name) 0
							incr count
						}	
					} elseif {![info exists not_include($inst_name,$pin_name)]} {
						set not_include($inst_name,$pin_name) 1
					}
				} elseif { $region_all == 1 } {
					set include($inst_name,$pin_name) 1
					incr count
				} elseif { $xtor != "BLOCK"} {
					regsub -all {\[} $xtor {\\[} xt
					regsub -all {\]} $xt {\\]} xtor
					if { [regexp "$xtor" $lines1($j)] } {
						set include($inst_name,$pin_name) 1
						set not_include($inst_name,$pin_name) 0
						incr count
					} elseif {![info exists not_include($inst_name,$pin_name)]} {
						set not_include($inst_name,$pin_name) 1
					}
				}
			} elseif {$rest == 1 || $rest == 2} {
				if {$not_include($inst_name,$pin_name) == 1} {
					set include($inst_name,$pin_name) 1
					incr count
				}
				if {[info exists not_include($inst_name,$pin_name)] &&  $rest == 2} {
					unset not_include($inst_name,$pin_name)	
				}
				if {[info exists hier_include($inst_name,$pin_name)] &&  $rest == 2} {
					unset hier_include($inst_name,$pin_name)	
				}
			}
		}
	}
	if { $count == 0 } {
		puts "$count is the count"
		puts "\n\nERROR : No transistor pins found in this region"
		puts "\n\nINFO : Before the next power Assignment, please do \"atclPowerAssign -clear\""
		return
	}
	
	set count 0		
	set file [glob "adsPower/*.nets.adsLib.power"]
	set file1 [open $file r]
	set k1 0
	while {[gets $file1 line] >= 0} {
		set lines2($k1) $line	
		incr k1
	}
	close $file1
	if ![info exists var] {
		file copy -force -- $file adsPower/power.first
		set var 1
	}	
	file copy -force -- $file adsPower/power
	set zero_count 0
	set cumulative_power 0
	set cumulative_current 0
	set file1 [open "$file" w+]
	for {set j 0} {$j<$k1} {incr j} {
		if {$j>=1} {
			if {[regexp -nocase {adsU1} $lines2($j)] == 1} {
				set line [split $lines2($j)]
				set inst_name [lindex $line 0]
				set pin_name [lindex $line 34]
				set nets [lindex $line 25]
				if {$pin_name != "" && $nets == $net} {
					set lines($inst_name,$pin_name) [split $lines2($j)]
					if {$include($inst_name,$pin_name) == 1} {
						if {$pwr != "POWER" && $nets == $net} {
						 	set vdd_domain($inst_name,$pin_name) [lindex $line 25]
						 	set total_power [expr [lindex $line 26] + 0]
						 	if { $total_power == 0 } {
								incr zero_count
							}
							if {$vdd_domain($inst_name,$pin_name) == $net && $mode == 1 } {
								set cumulative_power [expr $cumulative_power + $total_power]
								incr count
							}
						} elseif {$i != "CURRENT" && $nets == $net} {	
							set vss_domain($inst_name,$pin_name) [lindex $line 25]
							set current [expr [lindex $line 36] + 0]
							if { $current == 0 } {
								incr zero_count
							}	
							if {$vss_domain($inst_name,$pin_name) == $net && $mode == 2} {	
								set cumulative_current [expr $cumulative_current + $current]
								incr count
							}
						}
					}
				}
			}				
		} else {
			puts $file1 "$lines2($j)"
		}	
	}
	if { $count == 0 } {
		puts "\n\nERROR : Net $net is not found within the bounding box"
		file copy -force -- adsPower/power $file
		puts "\n\nINFO : Before the next power Assignment, please do \"atclPowerAssign -clear\""
		return
	}
	if {$mode == 1 && $cumulative_power != 0} {
		set power_scaling_factor [expr $pwr/$cumulative_power]
	} elseif {$mode == 2 && $cumulative_current != 0} {
		set current_scaling_factor [expr $i/$cumulative_current]
	} else {
		if { $cumulative_power == 0 && $mode ==1 } {
			puts "\n\nERROR : All transistors in the specified region have 0 power. Scaling not possible. Power assignment failed."
			file copy -force -- adsPower/power $file 
			puts "\n\nINFO : Before the next power Assignment, please do \"atclPowerAssign -clear\""
			return
		} 	
		if { $cumulative_current== 0 && $mode ==2 } {
			puts "\n\nERROR : All transistors in the specified region have 0 current. Scaling not possible. Current assignment failed."
			file copy -force -- adsPower/power $file 
			puts "\n\nINFO : Before the next power Assignment, please do \"atclPowerAssign -clear\""
			return
		} 	
	}
	set percentage [expr ($zero_count * 100) / $count]
	set non_zero_count [expr $count - $zero_count]
	set new [open "modified_pins.rpt" w+]
	puts $new "<pin_name> <net_name> <old_value> <modified_value>"
	set new1 [open "unmodified_pins.rpt" w+]
	puts $new1 "<pin_name> <net_name> <old_value> <modified_value>"
	set final_power 0
	set final_current 0
	for {set j 1} {$j<$k1} {incr j} {
		if {[regexp -nocase {adsU1} $lines2($j)] == 1} {
			set lin [split $lines2($j)]
			set line [lindex $lin 34]
			set nets [lindex $lin 25]
			set inst_name [lindex $lin 0]
			if {$include($inst_name,$line)==1} {
				if {$pwr != "POWER" && $nets == $net} {
					if {$nets == $net && $mode == 1} {
						set c01 [lindex $lin 1]
						set c10 [lindex $lin 2]
						set metric [lindex $lin 26]
						set met1 [lindex $lin 27]
						set current [lindex $lin 36]
						set met2 [lindex $lin 37]
						set met [expr $power_scaling_factor * $metric]
						set current1 [expr $power_scaling_factor * $current]
						set c01_new [expr $power_scaling_factor * $c01]
						set c10_new [expr $power_scaling_factor * $c10]
						set leakage [expr $power_scaling_factor * $met2]
						set final_power [expr $final_power + $met]
						set lin1 [lreplace $lin 1 2 $c01_new $c10_new]
						set lin $lin1
						set lin1 [lreplace $lin 26 27 $met $met1]
						set lin $lin1
						set lin1 [lreplace $lin 36 37 $current1 $leakage]
						puts $new "$line $vdd_domain($inst_name,$line) $metric $met"
					}
				} elseif {$i != "CURRENT" && $nets == $net} {
					if {$nets == $net && $mode == 2} {
						set c01 [lindex $lin 1]
						set c10 [lindex $lin 2]
						set metric [lindex $lin 26]
						set met1 [lindex $lin 27]
						set current [lindex $lin 36]
						set met2 [lindex $lin 37]
						set met [expr $current_scaling_factor * $metric]
						set current1 [expr $current_scaling_factor * $current]
						set c01_new [expr $current_scaling_factor * $c01]
						set c10_new [expr $current_scaling_factor * $c10]
						set leakage [expr $current_scaling_factor * $met2]
						set lin1 [lreplace $lin 1 2 $c01_new $c10_new]
						set lin $lin1
						set lin1 [lreplace $lin 26 27 $met $met1]
						set lin $lin1
						set lin1 [lreplace $lin 36 37 $current1 $leakage]
						set final_current [expr $final_current + $current1]					
						puts $new "$line $vss_domain($inst_name,$line) $metric $met"
					}
				} else {
					set lin1 $lines2($j)
					puts $new1 "$lin1"
				}	
			} else {
				set lin1 $lines2($j)
				puts $new1 "$lin1"
			}
			puts $file1 "$lin1"
		} else {
			set lin1 $lines2($j)
			puts $file1 "$lin1"
		}
	}
	close $file1
	if {$rest == "REST" && $xtor == "BLOCK" && $region_all == 0} {
		puts "\n\nbbox \"$x1_loc $y1_loc $x2_loc $y2_loc\"\n"
	}	
	if {$mode == 1} {		
		puts "\nTarget Power = $pwr W\nCumulative Power = $cumulative_power W\nPower Scaling Factor = $power_scaling_factor \nFinal Cumulative Power = $final_power W\n\n"
	}
	if {$mode == 2} {	
		if { $cumulative_current == 0 } {
			puts "ERROR : All transistors in the specified region have 0 current. Scaling not possible. Current assignment failed."
			file copy -force -- adsPower/power $file
			puts "\n\nINFO : Before the next power Assignment, please do \"atclPowerAssign -clear\""
			return
		} 
		puts "\nTarget Current = $i A\nCumulative Current = $cumulative_current A\nCurrent Scaling Factor = $current_scaling_factor \nFinal Cumulative Current = $final_current A\n\n"
	}
	if { $percentage >= 90 } {
		puts "\n\nWARNING : More than 90% of transistors in the specified region have zero power. Scaling applied to only $non_zero_count transistors. Please verify the power assignment."
	}
	puts "\n\nINFO : Before the next power Assignment, please do \"atclPowerAssign -clear\""
	puts "\n\nINFO : After the power Assignment is finished, please do \"atclPowerAssign -done\""	
	if { $rest == 2 } {
		atclPowerAssignClear
	}
}	

proc atclPowerAssignClear {} {
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
			if {[info exists hier_include($inst_name,$pin_name)]} {
				unset hier_include($inst_name,$pin_name)	
			}			
		}
	}
}
		

