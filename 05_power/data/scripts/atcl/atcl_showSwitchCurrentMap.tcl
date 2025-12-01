#########################################################################
#
# Apache Design Solutions, Inc.
#
# atcl_showSwitchCurrentMap.tcl is an Apache-AE TCL utility for highlighting the switch current distribution on the GUI.
#
# Usage: 
#	atcl_showSwitchCurrentMap -report_file <output_file> -gif_file <output_gif_file>\[-h\] \[-m\]
#
# Copyright 2008 Apache Design Solutions, Inc.
# All rights reserved.
#
# Revision history
#
# $Revision: 1.145 $
# - Created by Sankar 01/02/08
# - Initial version
#
#########################################################################



proc atcl_showSwitchCurrentMap_manpage {} {
	puts "
SYNOPSIS
        Apache-AE TCL utility for highlighting the switch current distribution on the GUI

USAGE
        atcl_showSwitchCurrentMap \[option_arguments\]

        Options:
        -report_file <output_file>  Output report file(optional)(By default it is in showSwitchcTurnOn.rpt)
	-gif_file <output_gif_file> optional(By default it wont be created)
	-run <static|dynamic|rampup>
	\[-h\] 		  command usage
	\[-m\]		  man page
"
}

proc atcl_showSwitchCurrentMap_help {} {
	puts "atcl_showSwitchCurrentMap -report_file <output_file> -gif_file <output_gif_file>-run <static|dynamic|rampup>\[-h\] \[-m\]"
}


proc atcl_showSwitchCurrentMap { args } {
	# Process command arguments
	set argv [split $args]
	set state flag
	set run_flag 0
	set run_state ""
	set outputf "showSwitchCurrentMap.rpt"
	set makegif 0
	foreach arg $argv {
		switch -- $state {
			flag {
				switch -glob -- $arg {
					-h* { atcl_showSwitchCurrentMap_help ; return }
					-m* { atcl_showSwitchCurrentMap_manpage ; return }
					-report_file  { set state outputflag }
					-gif_file {set state gifflag }
					-run {set state runflag}
					default { error "atcl_showSwitchCurrentMap Error: unknown flag $arg" }
					
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
			runflag {
			set run_state $arg
			set state flag
			set run_flag 1
			}
			
		}
	}

	

if { $run_state eq "dynamic" || $run_state eq "static" || $run_state eq "" || $run_state eq "rampup"  } {

} else {
atcl_showSwitchCurrentMap_help
return
}

if { $run_state eq "dynamic" || $run_state eq "static" || $run_state eq "" } {
set column 4
} 

if { $run_state eq "rampup" } {
set column 2
set file "adsRpt/Static/switch_static.rpt"
}

if { $run_state eq "static" } {
if  { [ file exists adsRpt/Static/switch_static.rpt ] } {
set file "adsRpt/Static/switch_static.rpt"
} else {
puts "ERROR : File adsRpt/Static/switch_static.rpt not found"
return
}
}

if { $run_state eq "dynamic" || $run_state eq "rampup"} {
if  { [ file exists adsRpt/Dynamic/switch_dynamic.rpt ] } {
set file "adsRpt/Dynamic/switch_dynamic.rpt"
} else {
puts "ERROR : File adsRpt/Dynamic/switch_dynamic.rpt not found"
return
}
}
	 
	 
if { $run_state eq "" } {
if  { [ file exists adsRpt/Dynamic/switch_dynamic.rpt ] } {
set file "adsRpt/Dynamic/switch_dynamic.rpt"
} else {
puts "ERROR : Run mode set to dynamic by default.File adsRpt/Dynamic/switch_dynamic.rpt not found"
puts "INFO : Use -run switch to specify if the run is static,dynamic or rampup"
atcl_showSwitchCurrentMap_help
return
}
}   
    
#set the envirronment in the GUI
set cnt 0
select clearall
config viewlayer  -name all -style invisible
set PT [open "$file" r] 

while {[gets $PT line ]>0  } {


	if { [regexp -all {\#} $line] } {
	} else {
	
	
	regsub -all {\t}  $line " " line1
        regsub -all -- {[[:space:]]+} $line1 " " line2
	set words [split $line2 " "]
	
	
	set current [lindex $words $column ]
	
	
	set inst [lindex $words 0]
	
	set currents($inst) $current	
	set insts($current) $inst
	incr cnt
	
		}
	}
		
close $PT


set  crnt [lsort -real -increasing [array names insts] ]


set min [lindex $crnt 0]
set length [llength $crnt]
set last [expr $length - 1 ]
set max [lindex $crnt $last]
set bucketsize [expr ($max-$min)/14]

set RPT [ open "$outputf" w ]


foreach instance  [array names currents] {

  set m $currents($instance)

  
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

      Between $min A and [expr $min +  0.25*$bucketsize] A COLOR WHITE
      Between [expr $min +  0.25*$bucketsize] A and [expr $min +  2*$bucketsize] A COLOR BLUE
      Between [expr $min +  2*$bucketsize] A and [expr $min +  5*$bucketsize] A COLOR GREEN
      Between [expr $min +  5*$bucketsize] A and [expr $min +  8*$bucketsize] A COLOR YELLOW	
      Between [expr $min +  8*$bucketsize] A and [expr $min +  11*$bucketsize] A COLOR ORANGE
      Between [expr $min +  11*$bucketsize] A and [expr $min +  14*$bucketsize] A COLOR RED
"
	close $RPT
	
	}
	
 
