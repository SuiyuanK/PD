## Usage: 
#	atcl_atclResDebug -vddb <powerbump_instance_name> -vssb <groundbump_instance_name> -c <clamp_instance_name> -d <dir_name_with the path> \[-h\] \[-m\]
#
# Copyright 2008 Apache Design Solutions, Inc.
# All rights reserved.
#
# Revision history
#
# Rev 1.0 
# - Created by Roshan & Gireesh 01/02/08
# - Initial version
#
#########################################################################




#variable ref#
#############
# rule           anywhere                    :rule nanme
# type            anywhere                   :type name
# net_dom        inside each loop            : domain names user inputed
##############################################################################
# if rule name 						          	     #
# then no need of B2C or B2B take file esd_<rulename>.rpt	             #
# else check the type and get the files			          	     #
# else error out file not found					             #
##############################################################################
# if type is not set						             #
# then give the message pls define the type			             #
# else if type B2B						             #
# set the column readind index varibales accordingly		             #
# else if type B2C	          					     #
# set the column readind index varibales accordingly          		     #
# else dipaly the message pls give typea as BUMP2BUMP or BUMP2CLAMP          #
##############################################################################

proc atclResHisto_manpage {} {
	puts "
SYNOPSIS
        Apache-AE TCL utility for displaying histogram of BUMP2BUMP OR BUMP2CLAMP paths which falls under different resistance range
	

USAGE
        atclResHisto \[option_arguments\]

        Options:
        -net <net names separated by commas> Histogram of specified net domains are displayed
	-power 				     Histogram of all power domains in the design is displayed
	-ground 		             Histogram of all ground domains in the design is displayed
	-all                                 Histogram of all domains in the design is displayed
	-loop 			  	     Histogram of all Bump to Bump loop resistance is displayed.This will work only if type is BUMP2BUMP
	-parallel			     Shows  histogram of effective parallel resistance of all Bump to Bump loops.This will work only if type is BUMP2BUMP
	-type <BUMP2BUMP | C2I | C2I_MACRO -macro <macro_name> > (MUST)Type of ESD check performed
	-rule_name <name of the esd_rule>    (OPTIONAL)Name of the user defined esd rule
	-res_min                             shows histogram for resistance value above the specified value
	-res_max                             shows histogram for resistance value below the specified value
	-bin_size                             sets the bin size for x axis
	-phase  <2|3>                         2 supports Pathfinder phase 2  and 3 supports pathfinder phase 3.By deafult the value is 3
	-esd_dir <results directory>
	\[-h\] 		  command usage
	\[-m\]		  man page

SAMPLE USAGE	
                  atclResHisto -net vddcx_1,vssx_0 -type BUMP2CLAMP -rule_name rules1
		  atclResHisto -power -ground -type BUMP2CLAMP
		  atclResHisto -parallel -type BUMP2BUMP
"
}

proc atclResHisto_help {} {
	puts "USAGE FORMAT \n atclResHisto \[ -net <net_names separated by comma(,)> | -power  | -ground  | -loop | -parallel | -all\]\? -type <BUMP2BUMP | C2I |C2I_MACRO -macro <macro_name>> \[-rule_name <esd_rule_name> \] \[-bin_size<bin size of x axis>\] \[-res_min <min threshold resistance value>\] \[-res_max <max threshold resistance value>\]\[-h\] \[-man\]"
}


proc atclResHisto { args } {  
set argv [split $args]
set state flag_s
set flag_power 0
set flag_ground 0
set flag_all 0
set flag_names 0
set flag_parallel 0
set flag_loop 0
set flag_curve 0
set bin_size 0.05
set res_min 0
set res_max 1000000
set phase 3
set dir "adsRpt/ESD"

global env
set env(gnuplot) "./gnuplot"
set vssb "a"
set vddb "a"
set clamps "a"
set pad "a"
set phase 3


foreach arg $argv {

		
			switch -- $state {
				flag_s {
					switch -glob -- $arg {

						-man { atclResHisto_manpage ; return }
						-h* { atclResHisto_help ; return }
						-curve {set flag_curve 1; set state flag_s}
						-net { set state names_s}	
						-all {set flag_all 1;set state flag_s}
						-loop {set flag_loop 1;set state flag_s}
						-power {  set flag_power 1;set state flag_s }
						-ground {  set flag_ground 1;set state flag_s}
						-parallel {set flag_parallel 1; set state flag_s}
						-type {set state type_s}
						-rule_name {set state rule_s}
						-gnuplot {set state gnu_s;}
						-macro {set state macro_s}
						-bin_size {set state bin_s}
						-res_min {set state res_min_s}
						-res_max {set state res_max_s}
						-phase { set state phase_s }
						-esd_dir { set state dir_s }
						default {puts "ERROR: usage is wrong"; puts "CORRECT USAGE IS" ; atclResHisto_help ; return}
						
						
						

					}
				}
				
				
				phase_s {
					set phase $arg
					set state flag_s
					if {$phase != 2 } {
						if { $phase != 3} {
							puts "ERROR: invalid phase option.Supported only for 2 and 3"
						}
						
					}
					
				}
				dir_s {
				
					set dir  $arg
					set state flag_s
				
				}
				res_max_s {
				
					set res_max $arg
					set state flag_s
				
				}
				res_min_s {
				
					set res_min $arg
					set state flag_s
				
				}
				bin_s {
					set bin_size $arg
					set state flag_s
					
				
				}
				macro_s {
				
				
					set macro $arg
					set state flag_s
				
				}
				
				gnu_s {
				
					set gnu_path $arg
					set state flag_s
				}
				type_s {
				
					set type $arg
					set state flag_s
				
				}
				rule_s {
					set rule $arg
					set state flag_s
				
				}

				net_s {
					set state flag_s
					
				}				
				
				names_s { 
					
					
					set state flag_s
					set net_names $arg
					set nets [split $net_names ","]
					set flag_names 1
					
					
				}
				
				
					 

			}
			
		}



if {![info exists type]}  {
# pls put usage page here
puts  "ERROR: Type of the esd_rule is not specified"
return;

}
if { $type eq "C2I_MACRO" && ![info exists macro] } {

	puts "please provide the option -macro <macro_name>"
	return
}

# getting the right file to read open
if {![info exists rule]} {
set rule "no_rule_file"
if { $type ne "C2I" } {
puts "INFO: rule file is not given"

#set rule "no_user_input"
}
}



if { [file exists ./$dir/esd_$rule.rpt]} {

 set report_file "esd_$rule.rpt"
 puts "INFO: found rule file"
 
} elseif { $type eq "BUMP2BUMP"} {

	
	set report_file "esd_B2B.rpt"
}  elseif { $type eq "C2I" } {


	set report_file "esd_fail.rpt"



} elseif { $type eq "C2I_MACRO"  } {


	set report_file "esd_fail.rpt"
} else {

	puts "ERROR: Rule type $type not found. \n Rule type  should be BUMP2BUMP or C2I or C2I_MACRO"
	
	return
}

# getting the right file to read close
#setting the correct value to nets
set nets ""
if {$flag_power == 1} {
	lappend  nets "power"
	
}

if {$flag_ground == 1} {
	lappend nets "ground"
	
}

if {$flag_all == 1 } {
	lappend nets "all"
}
if {$flag_loop == 1} {
	lappend nets "loop"
}
if {$flag_parallel == 1 } {

	lappend nets "parallel"
}
if {$flag_names == 1} {

	
	foreach net_dom [split $net_names ","] {
	
		lappend nets $net_dom
	}
}
if { $type eq "C2I_MACRO" && $flag_loop == 1 } {


	puts "ERROR: -loop option is not supported with -type C2I_MACRO"
	return
}

if {$flag_power !=1 && $flag_ground != 1 && $flag_all != 1 && $flag_parallel != 1 && $flag_names != 1 && $flag_loop != 1} {
puts "ERROR : No suitable options found to display the histogram \n
please use the option -net <net names separated by commas> or -power or -ground or -all or -parallel\n"
atclResHisto_help
return
}



#set fp [open "delete" w]
#set fp2 [open "delete2" w]
set report_file ""		
if {$type eq "BUMP2BUMP"} {
 
set files { esd_fail.rpt esd_pass.rpt }

foreach report_file $files {
#set vssb "a"
#set vddb "a"
#set clamps "a"

#puts "files is $report_file"
if { [catch {set b2b_f [open "./$dir/$report_file" r] } ] == 0} {
} else {
	puts "ERROR: $report_file not found \n Please do ESD check"
	return
}

#set new [open  "del" w]

 
	#opening the new file for histogram input and reading all res values according to net domain and range of res_values
#set found_pad 0
	while {[gets $b2b_f b2b_line] >= 0} {	
		regsub -all {\t}  $b2b_line " " line1
        	regsub -all -- {[[:space:]]+} $line1 " " b2b_line
		
		regsub -all {\(} $b2b_line "" temp3
		regsub -all {\)} $temp3 "" b2b_line
		
		
		
	if { ![ regexp {^\#} $b2b_line ] } {
		regsub -all {\t}  $b2b_line " " line1
        	regsub -all -- {[[:space:]]+} $line1 " " b2b_line
		
		regsub -all {\(} $b2b_line "" temp3
		regsub -all {\)} $temp3 "" $b2b_line
		set b2b_data [split $b2b_line]
		
		if {[regexp {^BUMP PAIR} $b2b_line]} {
		
		 
			
			set net_d1 [lindex $b2b_data 6]
			set net_d2 [lindex $b2b_data 12]
			set vss_bump [lindex $b2b_data 2]
			set vdd_bump [lindex $b2b_data 8]
				
				#checking the duplication of vss bump
				set flag_dup 0
				
				foreach v $vssb {
				
				
				set temp [lindex $b2b_data 2]
				
				if {$temp == $v} {
				set flag_dup 1
				
				break
				}
				}
				if {$flag_dup != 1} {
					lappend vssb $temp
				}
				
				
				set flag_dup 0
				
				foreach v $vddb {
				
				
				set temp [lindex $b2b_data 8]
				
				if {$temp == $v} {
				set flag_dup 1
				
				break
				}
				}
				if {$flag_dup != 1} {
					lappend vddb $temp
				}
				set flag_dup 0
				
			
		}
		if { [regexp {^FAIL:} $b2b_line]  || [regexp {^PASS:} $b2b_line] } {
		
			#used for net names
			if {$flag_names == 1 || $flag_power == 1 || $flag_ground == 1 || $flag_all ==1 || $flag_loop == 1 } {
								
								


				set flag_dup 0
				
				foreach v $clamps {
				
				
				set temp [lindex $b2b_data 4]
				
				if {$temp == $v} {
				set flag_dup 1
				
				break
				}
				}
				if {$flag_dup != 1} {
					lappend clamps $temp
				}
				set flag_dup 0
				
				
			

				set resist [lindex $b2b_data 2]
				set net_dom $net_d1
				set clamp_name [lindex $b2b_data 4]
				#puts $fp "res1($net_dom,$vss_bump,$clamp_name)"
				set res1($net_dom,$vss_bump,$clamp_name) $resist
				set res1(ground,$vss_bump,$clamp_name) $resist
				set res1(all,$vss_bump,$clamp_name) $resist

				
				
							
				
				
				set resist [lindex $b2b_data 3]
				set net_dom $net_d2
				#puts $fp "res1($net_dom,$vdd_bump,$clamp_name) "
				set res1($net_dom,$vdd_bump,$clamp_name) $resist
				set res1(power,$vdd_bump,$clamp_name) $resist
				set res1(all,$vdd_bump,$clamp_name) $resist
				lappend res(loop) [lindex $b2b_data 1]
				
				
			}
			
			
			#used for power nets
			
					
				
		}
		if { [regexp {^PARALLEL} $b2b_line] } {
		
			set resist [lindex $b2b_data 2]
			lappend res(parallel)  $resist
		
		
			
		}
		
	
	
	
			
	}
		
	}
	
	#puts $new "$vssb"
	#puts $new "$vddb"
	#puts $new "$clamps"
	}
	
	set bumps $vssb 
	foreach a $vddb {
	lappend bumps $a

	
	}
	
	
	
	
	# making  res for B2B
	if {$flag_names ==1 || $flag_power ==1 || $flag_ground==1 || $flag_all == 1} {
	#puts "nets are $nets"
	foreach net $nets {
	
		foreach bump $bumps {
	
			foreach clamp $clamps {
				#puts $new "out $clamp"
				
				if { [info exists res1($net,$bump,$clamp) ]} {
				#puts $fp2 "res1($net,$bump,$clamp)"
#				puts $new "in loop net $net $bump $clamp"
				#puts $new " $bump and $res1($net,$bump,$clamp)"
				lappend res($net) $res1($net,$bump,$clamp)
				#puts "net is $net"
				
				
				}
 			}
		
		}


	
	}
	}
	#making res for B2B
	
close $b2b_f
#close $new

set a [array names res]

#close $fp
#close $fp2
} elseif  { $type eq "C2I" } {

set res(all) ""
set res(ground) ""
set res(power) ""
set files { esd_fail.rpt esd_pass.rpt }
set temp1 [ open "temp" w ]
foreach file $files {


if { [catch {set c2i_f [open "./$dir/$file" r] } ] == 0} {
} else {
	puts "ERROR: $file not found \n Please do ESD check"
	return
}

#set new [open  "del" w]


 
	
	while {[gets $c2i_f c2i_line] >= 0} {	
	
	
	if { [ regexp {^[0-9]} $c2i_line ] } {
	
		
		regsub -all {\t}  $c2i_line " " line1
        	regsub -all -- {[[:space:]]+} $line1 " " c2i_line
		set c2i_data [split $c2i_line]
		
		
		
		if { $phase == 2 } {
			set net_d1 [lindex $c2i_data 3]
			set net_d2 [lindex $c2i_data 7]
			set vss_pin [lindex $c2i_data 6]
			set vdd_pin [lindex $c2i_data 2]
			set inst [lindex $c2i_data 0]
				
			set resist [lindex $c2i_data 4]
			
		} else {
			set net_d1 [lindex $c2i_data 5]
			set net_d2 [lindex $c2i_data 11]
			set vss_pin [lindex $c2i_data 12]
			set vdd_pin [lindex $c2i_data 6]
			set inst [lindex $c2i_data 13]
				
			set resist [lindex $c2i_data 1]
		
		}
			if  {$resist ne "-" && $resist ne ""} {
			lappend res(all) $resist
			lappend res(power) $resist
			puts $temp1 "$resist"
			
			if { [ info exists res($net_d1)] } {
			lappend res($net_d1) $resist
			} else {
			set res($net_d1) $resist
			}
			}
	if { $phase == 2 } {
			set resist [lindex $c2i_data 8]
		} else {
		
			set resist [lindex $c2i_data 7]
		
		}
			if  {$resist ne "-" && $resist ne ""} {
			

			lappend res(all) $resist
			lappend res(ground) $resist
			if { [ info exists res($net_d2) ] } {
			lappend res($net_d2) $resist
			} else {
			set res($net_d2) $resist
			}
			}
			
			if { $phase == 2 } {
				set resist [lindex $c2i_data 1]
			} else {
				set resist [lindex $c2i_data 0]
			}
			if  {$resist ne "-" && $resist ne ""} {
			if { [ info exists res(loop) ] } {
			lappend res(loop) $resist
			} else {
			set res(loop) $resist
			}
			}
			
			
			
		
	
	
	
			
	}
		
	}
	
	
close $c2i_f



#close $new
} 
close $temp1



} elseif  { $type eq "C2I_MACRO" } {
 
set files { esd_fail.rpt esd_pass.rpt }
set res(all) ""
set res(power) ""
set res(ground) ""

foreach file $files {


if { [catch {set c2i_f [open "./$dir/$file" r] } ] == 0} {
} else {
	puts "ERROR: $file not found \n Please do ESD check"
	return
}

#set new [open  "del" w]

 
	set flagf 0
	while { [gets $c2i_f c2i_line] >= 0} {	
	
	
		if { [regexp {^INST} $c2i_line ] || [regexp {^[0-9]} $c2i_line ] } {
		regsub -all {\t}  $c2i_line " " line1
        	regsub -all -- {[[:space:]]+} $line1 " " c2i_line
		set c2i_data [split $c2i_line]
		
		if { [regexp {^\#} $c2i_line] || [regexp {^INST} $c2i_line] } {
         	
			
          		set flagf 0
			
			

        	}
		if { [regexp "$macro" $c2i_line] } {
         
          		set flagf 1
			
			

       		 }

       		 
   
   		#puts $flagf
      		if { ![regexp "$macro" $c2i_line] && $flagf == 1 && $c2i_line ne "" } {
		
		
		
		 	
			set vdd_nets [ get net * -glob -type power ]
			set vss_nets [ get net * -glob -type ground ]
			if { $phase == 2 } {
			set net [lindex $c2i_data 1]
			set resist [lindex $c2i_data 2]
			} else {
				set net [lindex $c2i_data 4]
				set resist [lindex $c2i_data 0]
			
			}
			
			if { [ info exists res($net)] } {
			lappend res($net) $resist
			} else {
			set res($net) $resist	
			}

			lappend res(all) $resist
			
			if  { [lsearch $vdd_nets $net] != -1 }	{
			
				if { [info exists res(power)] } { 
					lappend res(power) $resist
				} else {
				
					set res(power) $resist
				}
			}
			
			if { [lsearch $vss_nets $net] != -1 } {
			
				if { [info exists res(ground)] } { 
					lappend res(ground) $resist
				} else {
				
					set res(ground) $resist
				}
			}	
						
		
	
	
	
			
	}
	
		
	}
	
	}
	
	
close $c2i_f



#close $new
}

}




 # ERROR out if net name is not present
if {$flag_names == 1} {


	
	foreach input_net $nets {

		puts "nets i $net"
		set flag_present 0
		foreach present_net [array names res] {
				puts "present net $present_net"
			if {$present_net == $input_net} {
			
			     set flag_present 1
			     break
			}
			
		}
		if {$flag_present != 1} {
			puts "ERROR: Net $input_net is not present in the ESD reports"
			return
		}
	}



}


# setting parameters to find teh range values
 set large_num_inst 0
 set large_i 0
 set b_size $bin_size
 set ini_range1 0
 
#getting the number of resistances in a particular range of resistance
#initializing num_inst 0

foreach net_dom $nets {


           for {set i 1} {$i <10000} { incr i;} {
	   
	   	set num_inst($i,$net_dom) 0
	   
	   }





}
 foreach net_dom $nets {

set flag_r 0
set f 0


set sorted_res [lsort $res($net_dom)]
 	foreach res_val $sorted_res {
		
		
		for {set i 1} {$i <200000} { incr i;} {
		
			
			set r1 [expr ($i-1)*$b_size/1.000]
			set r2 [expr $i*$b_size/1.000]
			set range1 [expr $r1*1.000]
			set range2 [expr $r2*1.000]
			set f 0
			
			if { $range2 >= $res_max } {
				break
			}
			
			if  {$range2 >= $res_min && $range2 <= $res_max } {
			 if { $flag_r == 0 } {
			 
			 	set ini_range1 $range1
				set ini_range2 $range2
				set flag_r 1
			 }
			
			
			if { ($res_val >= $range1)&& ($res_val < $range2)} {
			
				#puts "$range1 >= $res_val < $range2 "
				if { [catch  {incr num_inst($i,$net_dom)}] != 0 } {
				
					set num_inst($i,$net_dom) 1
				}
				if { $i > $large_i} {
				
					set large_i $i
				}
				if {$num_inst($i,$net_dom) > $large_num_inst} {
				
					set large_num_inst $num_inst($i,$net_dom)
				}
				
				break
				
				
		
			}
			
			}
		}
	}
	
	set size [array size  num_inst]
	
	
 }

 set y_max_range $large_num_inst
 set x_max_range [expr $large_i * $b_size]
 set y_max_range [expr $y_max_range+20]

 
#all graph related files are inside hist directory



exec mkdir -p ./.hist



foreach net_domains $nets {


	

# creating each histogram file for each user specified domains
regsub -all "/" $net_domains "_" tmp

set histin_f [open "./.hist/hist_$tmp" w]





for {set i 0} {$i <= $large_i} {incr i} {

	set res_range [expr $i*$b_size]
#	puts "outside $res_range $ini_range2"
if { [info exists ini_range2 ] } {
	if {$res_range >= $ini_range2} {
#	puts "inside $res_range $ini_range2"
	if {[catch {info exists $num_inst($i,$net_domains)}]==0} {
	
		set prev_range [expr $res_range-$b_size]
		if {$flag_curve == 0 } {
		puts $histin_f "$prev_range $num_inst($i,$net_domains)"
		}
		puts $histin_f "$res_range $num_inst($i,$net_domains)"
		
		
			
		
	}
	}
} else {
puts "INFO: No resistance path found for the specified paths "
return
}
	
	
}
close $histin_f

}

set histin_f [open "./.hist/hist_$tmp" r]
set histin_cont [read $histin_f]
close $histin_f
if { $histin_cont ne ""} {
#creating the file whihc conatins code for plotting graph.


set graph_f [open "./.hist/plot_graph" w]

set file "exec xgraph -P -lw 2 -x resistance_in_ohms -y No:of_Paths"
foreach  net_domains $nets {
regsub -all "/" $net_domains "_" tmp
	lappend file ./.hist/hist_$tmp

}
lappend file "&"

puts $graph_f "$file "
close $graph_f
if { [catch {source ./.hist/plot_graph}] == 0} {
} else {
	puts "ERROR : Xgraph is not available in this machine to plot the graph "
	return
}

puts "Histogram created successfully"
} else {
	puts "No resistance path found for the specified paths "
}

}
