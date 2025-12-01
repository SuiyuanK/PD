proc atcl_set_dynamic_frame_size_help { } {

puts "USAGE : atcl_set_dynamic_frame_size"

}

proc atcl_set_dynamic_frame_size { args } {

set argv [split $args]
set state flag

foreach arg $argv {

 switch -- $state {
                        flag {
                                switch -glob -- $arg {
                               
			       	        -h* { atcl_set_dynamic_frame_size_help ; return ; }
			                
                                }
			}	
			
			}

}

set mode [ lindex [ get analysis_mode ] 1 ]

if { $mode eq "VCD" } {
puts "ERROR : Script Not Applicable to VCD Testcases"
return

}

set vars [ get stage ]
foreach var $vars {

set var_present($var) 1 

}

if { ![ info exists var_present(PWR_READY) ] } {

puts "ERROR : Power Calculation Not Done."
return

}

if { [ file exists adsRpt/power_summary.rpt ] } {

set fp [ open "adsRpt/power_summary.rpt" r ]
set found_time 0

while { [ gets $fp line ] >= 0 } {

if { [ regexp -nocase "Recommended dynamic simulation time" $line ] } {
set words [ split $line ]
set design_dominant_time [ lindex $words 4 ]
set found_time 1
}


}

close $fp


if { $found_time == 1 } {
if { $design_dominant_time ne "" } {
regsub -all "psec" $design_dominant_time "" design_dominant_time1
set temp [ expr $design_dominant_time1*1e-12 ]
#set design_dominant_frequency [  expr 1/($temp) ]
#set tmp [ expr int($design_dominant_frequency*100*1.0) ]
#set design_dominant_frequency [  expr $tmp*1.0/100 ]

} else {
puts "INFO : Could Not Set DYNAMIC_FRAME_SIZE"
}
} else {
puts "INFO : Could Not Set DYNAMIC_FRAME_SIZE"
}


if { [ catch { gsr set DYNAMIC_FRAME_SIZE $temp } ] == 0 } {

puts "INFO : DYNAMIC_FRAME_SIZE SET To $design_dominant_time1 ps"
} else {

puts "INFO : Could Not Set DYNAMIC_FRAME_SIZE"
}

} else {
puts "ERROR : Power Calculation Not Done.The file adsRpt/power_summary.rpt is not available"
return
}

}
