
#########################################################################
#
# Apache Design Solutions, Inc.
#
# atcl_showPratioMap.tcl is an Apache-AE TCL utility for highlighting the pratio distribution on the GUI.
#
# Usage:
#       atcl_showPratioMap -dir <output directory> -net <netname>(optional:.By defaults  all nets are higlighted )\[-h\] \[-m\]
#
# Copyright 2008 Apache Design Solutions, Inc.
# All rights reserved.
#
# Revision history
#
# Author : Nikhil, Email: nikhil @apache-da.com,Sankar, Email: sankar@apache-da.com
# - Initial version
#
#########################################################################

proc atcl_showPratioMap_manpage {} {
        puts "
SYNOPSIS
        Apache-AE TCL utility for highlighting the pratio distribution on the GUI

USAGE
        atcl_showPratioMap \[option_arguments\]

        Options:
        -dir <input directory i.e the directory which has the pratio and lef files> 
	-cell < the name of the cell >
        -net <netname e.g VDD,VSS,VDD1 ..by  default it will highlight Pratios of all the  nets .
        \[-h\]            command usage
        \[-m\]            man page
"
}
proc  atcl_showPratioMap_help {} {
        puts "atcl_showPratioMap -dir <input directory(directory where the  pratio and lef files are present.By default it looks for pratio and lef files in the current directory> -net <netname> -cell < the gds2def cellname> -gif_file <gif file name> (optional:.By defaults  all nets are higlighted)\[-h\] \[-m\]"
}




proc atcl_showPratioMap { args } {


# Process command arguments
        set argv [split $args]
        set state flag
         set makegif 0
	 set out_put 0
	 set netflag 0
	 set outputf ./
	 set cell_flag  0
        foreach arg $argv {
                switch -- $state {
                        flag {
                                switch -glob -- $arg {
                                        -h* { atcl_showPratioMap_help ; return }
                                        -m* { atcl_showPratioMap_manpage ; return }
                                        -dir  { set state outputflag }
					-net {  set state netnameflag }
                                        -gif_file {set state gifflag }
					-cell { set state cellflag }
                                        default { error "atcl_showPratioMap Error: unknown flag $arg" }
					
                                }
                        }
			netnameflag {
			set net_name $arg
			set netflag 1
			set state flag
			}
			
                        outputflag {
                                set outputf $arg
                                set state flag
				set  out_put 1
                        }
                        gifflag {
                        set giffile $arg
                        set makegif 1
                        set state flag
                        }
			
			cellflag {
			set cell_name $arg
			set cell_flag  1
			set state flag
			}

                }
        }


if {  $out_put == 0 && $outputf == "" } {
puts "Error : Please enter the dir i.e the path to the directory which has pratio and lef files\n"

}
#Read LEF file#
if {$cell_flag == 1 } {


set file  [ glob -directory $outputf "$cell_name\_adsgds.lef"]

} else {
set file  [ glob -directory $outputf "*adsgds.lef"]
if { [llength $file ] > 1 } {

puts  "ERROR : Multiple lef files in the same directory : please use the cell  option"

}
if [file exists $file] {
} else {
puts "Error :The lef file doesnt exists in the directory you have specified"
}
}


if { $file == "" } {
puts  "lef file not present in the directory specified"
}

set lef [open $file r]
set i 0
while {[gets $lef line] >= 0} {
	set lines($i) $line	
	incr i
}
close $lef

puts "Reading LEF : $file"


#Read pratio file if only one  net name is given#

if { $cell_flag == 1 } {

set file  [glob -directory $outputf "$cell_name\_adsgds.pratio"]
} else {
set file  [ glob -directory $outputf "*adsgds.pratio"]

if { [llength $file ] > 1 } {

puts  "ERROR : Multiple pratio files in the same directory : please use the cell  option"

}

if [file exists $file] {
} else {
puts "Error :The lef file doesnt exists in the dir directory you have specified"
}

}
if { $file == "" } {
puts  "pratio file not present in the directory specified"
}

puts "Reading Pratio File : $file"
set pratio [open $file r]
set k 0
while {[gets $pratio line] >= 0} {
	set lines1($k) $line	
	incr k
}	
close $pratio
set pratio_start 0
set startpin 0
set foundpin 0
for {set j 0} {$j<$k} {incr j} {
	set line [split $lines1($j)]
	set word1 [lindex $line 0]
	set word2 [lindex $line 1]
	if {$word1 == "#pin"} {
	
	if  { $netflag == 1 } {
	
		if { $word2 == $net_name } {
		
		lappend nets $net_name
		set foundpin 1
		set pratio_start 1
		set startpin 0
		
		}
	
	} 
	
	if  { $netflag == 0 } {
		
		set netname1 $word2
		lappend nets $netname1
		#if {$netname1 == "VDD" || $netname1 == "VSS"} {
		set foundpin 1
		set pratio_start 1
		set startpin 0	
		
		#}
		
		}
		
	}
	
	
		
	if {$pratio_start == 1 || $startpin == 1} { 
		
		
		if { $word1 == "#pin" && $startpin == 1 && $netflag == 1 && $word2 != $net_name } {
		    
		    set startpin 0
		    set pratio_start 0
		    
		    }
		    
	if { $word1 != "#pin" } {
	
			set pratio_start 0
			set startpin 1	
			
			if { $word1 == 0 && $netflag == 0 } {
			
			set temp $netname1
			
			} 
			if { $word1 == 0 && $netflag == 1 } {
			
			set temp $net_name
			}
			
			if { $word1 !=0 && $netflag == 0 } {
			
			set temp $netname1.gds$word1
			
			}
			if { $word1 !=0 && $netflag == 1 } {
			set temp $net_name.gds$word1
			}
			
			
			set ratios($temp) $word2 
			set ratios1($word2) $temp
			#puts "$ratios1($word2) $temp\n"	
		     
		    
	}
	
	}		
}
if { $foundpin == 0 } { 
	puts "ERROR : PIN not Found\n"
	}

 

#close $file1
set start 0




for {set j 0} {$j<$i} {incr j} {
		
	set line [split $lines($j)]
	set word1 [lindex $line 1]
	set word2 [lindex $line 2]
	set word3 [lindex $line 3]
	set word4 [lindex $line 4]
	set word5 [lindex $line 5]
	if { $word1 == "PIN" } {
	
	if { [regexp -all {.gds} $word2 ] } {
	        
		set start 1
		set temps $word2
		
		}
	
	foreach hhh $nets {
		
	if { $word2 == $hhh } {
	
	set start 1
	set temps $word2
	
	}
	
	}
		
		}
		
		
	if { $word1 == "RECT" && $start == 1 } {
	
	
						
			set x_location($temps) $word2
			set y_location($temps) $word3
			
									
			
	}
	
	if {$word1 == "END" && $start == 1} {
		 set start 0
		
	} 
			

}



set  volt [lsort -real -increasing [array names ratios1] ]


set min [lindex $volt 0]
set length [llength $volt]
set last1 [expr $length - 1 ]
set max [lindex $volt $last1]
set bucketsize [expr ($max-$min)/14 ]


marker delete -all
config viewlayer  -name all -style invisible
config viewlayer  -name instance -style outline
 


set temp2 [ lsort [array names ratios]]





foreach instance  $temp2 {



  set m $ratios($instance)
  
 
 
   if { $m == $min && $min == 0} {
      marker add -position $x_location($instance) $y_location($instance)  -color white -name white
   
   } elseif { $m == $min && $min != 0} {
    marker add -position $x_location($instance) $y_location($instance)  -color #737CA1 -name 737CA1
     
   }
   

   if { $m >$min && $m < [expr $min +  0.25* $bucketsize] } {
    #puts "$instance $m $x_location($instance) $y_location($instance)"
    marker add -position $x_location($instance) $y_location($instance)  -color #737CA1 -name 737CA1
   
  }


  if { $m >= [expr $min +  0.25*$bucketsize] && $m < [expr $min +  2*$bucketsize] } {
   
  marker add -position $x_location($instance) $y_location($instance)  -color #0009FF -name 0009FF
   
  }


  if { $m >= [expr $min +  2*$bucketsize] && $m < [expr $min +  5*$bucketsize] } {

   marker add -position $x_location($instance) $y_location($instance)  -color green -name green
   
  }

  if { $m >= [expr $min +  5*$bucketsize] && $m < [expr $min +  8*$bucketsize] } {
   marker add -position $x_location($instance) $y_location($instance)  -color yellow -name yellow
   
  }
if { $m >= [expr $min +  8*$bucketsize] && $m < [expr $min +  11*$bucketsize] } {
   marker add -position $x_location($instance) $y_location($instance)  -color orange -name orange
   
   }

  if { $m >= [expr $min +  (11*$bucketsize)] } {
  
   marker add -position $x_location($instance) $y_location($instance)  -color red -name red
   
  }
  }


if  { $makegif == 1 } {
dump gif -map SA -o $giffile

}

puts "
PINS $nets and  their Pratios are displayed 
COLOR MAP:
      If Pratio = 0 ( Note : Pratio is equal to zero for Decaps ) COLOR WHITE
      Between $min  and [expr $min +  0.25*$bucketsize]  COLOR SLATE
      Between [expr $min +  0.25*$bucketsize]  and [expr $min +  2*$bucketsize]  COLOR BLUE
      Between [expr $min +  2*$bucketsize]  and [expr $min +  5*$bucketsize] COLOR GREEN
      Between [expr $min +  5*$bucketsize]  and [expr $min +  8*$bucketsize]  COLOR YELLOW
      Between [expr $min +  8*$bucketsize]  and [expr $min +  11*$bucketsize]  COLOR ORANGE
      Between [expr $min +  11*$bucketsize]  and $max  COLOR RED
"
        

        


}
