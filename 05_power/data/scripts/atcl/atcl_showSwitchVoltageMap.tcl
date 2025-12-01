#########################################################################
#
# Apache Design Solutions, Inc.
#
# atcl_showSwitchVoltageMap.tcl is an Apache-AE TCL utility for highlighting the switch voltage distribution on the GUI.
#
# Usage: 
#	atcl_showSwitchVoltageMap -report_file <output_file> -gif_file <output_gif_file>\[-h\] \[-m\]
#
# Copyright 2008 Apache Design Solutions, Inc.
# All rights reserved.
#
# Revision history
#
# Rev 1.0 
# - Created by Sankar 01/02/08
# - Initial version
#
#########################################################################



proc atcl_showSwitchVoltageMap_manpage {} {
	puts "
SYNOPSIS
        Apache-AE TCL utility for highlighting the switch voltage distribution on the GUI

USAGE
        atcl_showSwitchVoltageMap \[option_arguments\]

        Options:
        -report_file <output_file>  Output report file(optional)(By default it is in showSwitchVoltageMap.rpt)
	-gif_file <output_gif_file> optional(By default it wont be created)
	\[-h\] 		  command usage
	\[-m\]		  man page
"
}

proc atcl_showSwitchVoltageMap_help {} {
	puts "atcl_showSwitchVoltageMap -report_file <output_file> -gif_file <output_gif_file>\[-h\] \[-m\]"
}


proc atcl_showSwitchVoltageMap { args } {
	# Process command arguments
	set argv [split $args]
	set state flag
	set outputf "showSwitchVoltageMap.rpt"
	set makegif 0
	foreach arg $argv {
		switch -- $state {
			flag {
				switch -glob -- $arg {
					-h* { atcl_showSwitchVoltageMap_help ; return }
					-m* { atcl_showSwitchVoltageMap_manpage ; return }
					-report_file  { set state outputflag }
					-gif_file {set state gifflag }
					default { error "atcl_showSwitchVoltageMap Error: unknown flag $arg" }
				}
			}
			outputflag {
				set outputf $arg
				set state flag
			}
			gifflag {
			set giffile $arg
			set makegif 1
			set state flag
			}
			
		}
	}

	



	        
#set the envirronment in the GUI
select clearall
config viewlayer  -name all -style invisible
set PT [open "adsRpt/Dynamic/switch_dynamic.rpt" r] 
while {[gets $PT line ]>0  } {


	if { [regexp -all {\#} $line] } {
	} else {
	set words [split $line " "]
	set x [lindex $words 0]
	regsub -all {header} $x "" y
	regsub -all {footer} $y "" inst
	
	set voltage [lindex $words 4]
	set voltages($inst) $voltage	
	set insts($voltage) $inst
		
		}
	}
		
close $PT


set  volt [lsort -real -increasing [array names insts] ]


set min [lindex $volt 0]
set length [llength $volt]
set last [expr $length - 1 ]
set max [lindex $volt $last]
set bucketsize [expr ($max-$min)/14]

set RPT [ open "$outputf" w ]


foreach instance  [array names voltages] {

  set m $voltages($instance)

  
   if { $m < [expr $min +  0.25* $bucketsize] } {

    select add $instance -color white -linewidth 200
    puts $RPT " $instance $m white"
  }


  if { $m >= [expr $min +  0.25*$bucketsize] && $m < [expr $min +  2*$bucketsize] } {
   #puts "$m"
   select add $instance -color #0009FF -linewidth 200
   puts $RPT " $instance $m pink"
  }


  if { $m >= [expr $min +  2*$bucketsize] && $m < [expr $min +  5*$bucketsize] } {

   select add $instance -color green -linewidth 200
   puts $RPT " $instance $m green"
  }

  if { $m >= [expr $min +  5*$bucketsize] && $m < [expr $min +  8*$bucketsize] } {
   select add $instance -color yellow -linewidth 200
   puts $RPT " $instance $m yellow"
  }

  if { $m >= [expr $min +  8*$bucketsize] && $m < [expr $min +  11*$bucketsize] } {
   select add $instance -color orange -linewidth 200
   puts $RPT " $instance $m orange"
   }



  if { $m >= [expr $min +  (11*$bucketsize)] } {
  #puts "$insts($m)"
   select add $instance -color red -linewidth 200
   puts $RPT " $instance $m red"
  }



}

if  { $makegif == 1 } {
dump gif -map SA -o $giffile

}

puts "
COLOR MAP:

      Between $min V and [expr $min +  0.25*$bucketsize] V COLOR WHITE
      Between [expr $min +  0.25*$bucketsize] V and [expr $min +  2*$bucketsize] V COLOR BLUE
      Between [expr $min +  2*$bucketsize] V and [expr $min +  5*$bucketsize]V COLOR GREEN
      Between [expr $min +  5*$bucketsize] V and [expr $min +  8*$bucketsize] V COLOR YELLOW	
      Between [expr $min +  8*$bucketsize] V and [expr $min +  11*$bucketsize] V COLOR ORANGE
      Between [expr $min +  11*$bucketsize] V and [expr $min +  14*$bucketsize] V COLOR RED
"
	close $RPT
	
	}
	
 
