proc set_mutex_inst {num  filename} {
perform gridcheck  
set fp [open "tem.txt" w]

set in [open $filename r]
set contents [read $in ]
close $in

foreach inst $contents {
 if { [catch {get inst $inst -resistance }] ==0 } {
                               set resistance [get inst $inst -resistance ] 
                               set array($inst)  $resistance 
                               puts $fp "$inst $resistance "
                                                   }
                        }
close $fp 
#exec   sort -k2 -g -r tem.txt
set fp [open "sorted.txt" w]
puts  $fp [rhe_nx::rhe_sort tem.txt 2 decreasing] 
close $fp


set gscfile [gsr get GSC_FILE]
set line [split $gscfile]
set path [lindex $line 2 ] 
set check [lindex $line 3 ]
set fp [open "sorted.txt" r]
if {  $check == "#" }  {
    set fp_gsc [open ".apache/GSC_FILE"  a ]
                     }  else   {
                               if { $path == ".apache/GSC_FILE" } {
                                 set fp_gsc [open  ".apache/GSC_FILE" a]
                                  } elseif { $path != ".apache/GSC_FILE" } {
                                     exec cp $path   .apache/GSC_FILE 
                                    set fp_gsc [open  ".apache/GSC_FILE" a]
                                       }
                              }                      
                          
while { [ gets $fp lines ] >= 0 } {
set line [split $lines]
set first_element [lindex $line 0]
    if { $first_element !=  {}  }  { 
                       if [expr $num < 0 ]      {
                                     puts -nonewline $fp_gsc  $first_element 
                                     puts -nonewline $fp_gsc  "\t" 
                                     puts -nonewline $fp_gsc "STANDBY" 
                                     puts -nonewline $fp_gsc  "\n"
                                                 }
                       if [expr $num > 0 ]       {
                                      puts -nonewline $fp_gsc  $first_element
                                     puts -nonewline $fp_gsc  "\t"
                                     puts -nonewline $fp_gsc "TOGGLE"
                                     puts -nonewline $fp_gsc  "\n"
                                                 } 
                       if { !$num }            {
                                     puts -nonewline $fp_gsc  $first_element
                                     puts -nonewline $fp_gsc  "\t"
                                     puts -nonewline $fp_gsc "STANDBY"
                                     puts -nonewline $fp_gsc  "\n"
                                                }
                                         set num [expr $num -1] 
                                    }
                                 }
close $fp 
close $fp_gsc 
exec rm tem.txt 
exec rm sorted.txt                               
import gsc   .apache/GSC_FILE   
   }
