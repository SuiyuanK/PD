# $Revision: 1.145 $
#########################################################################
#
# atclget_instance.tcl is an Apache-AE TCL utility for printing instances in a recatangular region
#
# Usage:
# atclget_instance -o <output_file> -bbox "<x1 y1 x2 y2>"\[-help 1\] 
# Default outputfile is aget_instance.txt.<x1,y1> is expected to be lower left corner & <x2,y2> is th upper right corner.
# Copyright  2008 Apache Design Solutions, Inc.
# All rights reserved.
#
# Revision history
#
# Rev 1.0
# - Created by Kiran Joseph on 12/02/08
# - Initial version
#
########################################################################




proc atclget_instance {args} {

array set opt [concat {-bbox {} -o ""   -help 0} $args]
   set rect $opt(-bbox)

   set outfile $opt(-o)
   set help $opt(-help)
    if {$help !=0} {
       puts "\nThis function is for printing instances in a rectangular region."
       puts "-o  <Specify the output file name here , default is get_instance.out>"
	return
   		}
		
#-------------
# Main
#-------------
	if {$rect == ""} {
	#puts " no bbox \n"
	set rect [ query top -bbox ]
	set rect  "$rect"
	}
  
  if {$outfile == "" } {
set outfile aget_instance.txt
 	}

   set RPT [open "$outfile" w]    

set x1 [lindex $rect 0]
set y1 [lindex $rect 1]
set x2 [lindex $rect 2]
set y2 [lindex $rect 3]

set design_n [ query top -name  ]


#puts "\n$x1 , $x2 , $y1 , $y2 \n"
puts $RPT "# instance_name cell_name\n"
set PT2 [open "adsRpt/$design_n.power.rpt" r]

while {[gets $PT2 line3 ]>0} {


	set words [split $line3 " "]
	set x [lindex $words 8]
	set y [lindex $words 9]
	set cell [lindex $words 0]
	set inst [lindex $words 1]
	
	if { $x >= $x1 } {
	if { $x <= $x2  } {
	if { $y >= $y1 } {
	if { $y <= $y2 } {
	puts $RPT "$cell $inst \n" 	

	}
	}
	}
	}


				}
close $RPT
close $PT2
}
