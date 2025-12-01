# $Revision: 1.1 $
#########################################################################
#
# print_instance.tcl is an Apache-AE TCL utility for printing instances that are switching
#
# Usage:
# print_instance -o <output_file> \[-h\] 
# It expects a file print_instance.pl is the RH run directory for execcution.
# Copyright  2007 Apache Design Solutions, Inc.
# All rights reserved.
#
# Revision history
#
# Rev 1.0
# - Created by Kiran Joseph on 03/01/08
# - Initial version
#
########################################################################




proc print_instance {args} {

array set opt [concat {-o ""   -help 0} $args]

   set outfile $opt(-o)
   set help $opt(-help)
    if {$help !=0} {
       puts "\nThis function is for printing switching activity of instances."
       puts "-o  <Specify the output file name here , default is print_instance.out>"
return
   }
       
       if {$outfile == "" } {
set outfile print_instance.out
 }


open $outfile w+

    set bbox [ condition get -xy ] 
    set time [ condition get -time ]
    set bbox2 [split $bbox  " "]
    set time2 [split $time  " "]

    set c 0
set count 0 
foreach bb $bbox2  {
 set count [ expr $count+1 ]
   if { $count == 3 } {
     set x2 [ expr $bb ]
   }
  if { $count == 4 } {
set y2 [ expr  $bb ]  
  }
}        
 
foreach tt $time2 {
  if {$c ==1} {
 set end [ expr  $tt ]
  }
if {$c ==0} {
 set start [ expr  $tt ]
}
 set c [ expr $c + 1 ]
}

set design_n [ query top -name  ]

set root [ pwd ]


if {($end != 0) && ( $x2 != 0 ) }  {
  
  exec perl print_instance.pl -design $design_n  -d  $root  -bbox "$bbox2" -start $start -end $end -outfile $outfile
} 

if {($end != 0) && ( $x2 == 0 ) }  {
   exec perl print_instance.pl -design $design_n  -d  $root   -start $start -end $end -outfile $outfile
puts timenoxy
     
}

if {($end == 0) && ( $x2 != 0 ) }  {
  
puts notimexy
 exec perl print_instance.pl -design $design_n  -d  $root   -bbox $bbox2   -outfile $outfile
}
if {($end == 0) && ( $x2 == 0 ) }  {
puts "$design_n , $root ,$outfile "
puts notimenoxy
  exec perl print_instance.pl -design $design_n  -d  $root  -outfile $outfile

}




}
