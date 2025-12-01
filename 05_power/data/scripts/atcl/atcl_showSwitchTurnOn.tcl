# $Revision: 1.145 $

#########################################################################
#
# Apache Design Solutions, Inc.
#
# atcl_showSwitchTurnOn.tcl is an Apache-AE TCL utility for highlighting the switches on the GUI in the order in which they are turned on.
#
# Usage: 
#	atcl_showSwitchTurnOn -switch_master_list <input_file> -report_file <output_file> -simulation_time <simulation_time> -movie_file <output_gif_file>\[-h\] \[-m\]
#
# Copyright 2008 Apache Design Solutions, Inc.
# All rights reserved.
#
# Revision history
#
# Rev 1.0 
# - Created by Sankar 30/01/08
# - Initial version
#
#########################################################################


proc atcl_showSwitchTurnOn_manpage {} {
	puts "
SYNOPSIS
        Apache-AE TCL utility for highlighting the switches on the GUI in the order in which they are turned on.

USAGE
        atcl_showSwitchTurnOn \[option_arguments\]

        Options:
        -switch_master_list <input_file>   Input file having switch master cell names (optional)
        -report_file <output_file>  Output report file(optional)(By default it is in showSwitchcTurnOn.rpt)
	-simulation_time <simulation_time_in_seconds> optional(By default it will take simulation time to be 60 seconds)
	-time_step <no: of time points to be displayed at once> by default its value is 10
	-movie_file <output_gif_file> optional(By default it wont be created)
	-frame_rate <the  delay between frames in the movie > (By default it is 10)
	-start_time <the start time for the  interval for which the switching is to be shown>
	-end_time <the end time for the  interval for which the switching is to be shown>
	-pin_name <1/2> {1 for smaller switch ( e.g PON) : 2 for larger switch (e.g PGOODIN)(By default its 1)}
	\[-h\] 		  command usage
	\[-m\]		  man page
"
}

proc atcl_showSwitchTurnOn_help {} {
	puts "Usage: atcl_showSwitchTurnOn -switch_master_list <input_file> -report_file <output_report_file> -simulation_time <simulation_time_in_seconds> -movie_file <output_gif_file> -time_step<no: of time points to be displayed at once> -frame_rate <the  delay between frames in the movie > -start_time <the start time for the  interval for which the switching is to be shown> -end_time <the end time for the  interval for which the switching is to be shown> -pin_name <1/2>\[-h\] \[-m\]"
}

proc atcl_showSwitchTurnOn { args } {
	# Process command arguments
	# Possible flags are: -i, -o,-t,-h* and -m*
	set argv [split $args]
	#if { [llength $argv] == 0 } { set argv "-h" }
	set state flag
	#set inputf ""
	set outputf "showSwitchTurnOn.rpt"
	set usertime 60
	set movie 0
	set inputflg 0
	set framerate 10
	set startsimtime1 0
	set endsimtime1 0
	set pinname 1
	set color yellow
	set time_step 10
	set timestep 0
	foreach arg $argv {
		switch -- $state {
			flag {
				switch -glob -- $arg {
					-h* { atcl_showSwitchTurnOn_help ; return }
					-m { atcl_showSwitchTurnOn_manpage ; return }
					-simulation_time { set state usertimeflag }
					-time_step { set state usertimestep }	
					-switch_master_list  { set state inputflag }
					-report_file  { set state outputflag }
					-movie_file {set state movieflag }
					-frame_rate {set state frameflag}
					-start_time { set state startflag}
					-end_time { set state endflag}
					-pin_name {set  state pinflag }
					default { error "atcl_showSwitchTurnOn Error: unknown flag $arg" }
				}
			}
			inputflag {
				set inputf $arg
				set state flag
				set inputflg 1
			}
			outputflag {
				set outputf $arg
				set state flag
			}
			usertimeflag {
			set usertime $arg
			set state flag
			}
			usertimestep {
			set time_step $arg
			set timestep 1
			set state flag
			}
			movieflag {
			set moviefile $arg
			set movie 1
			set state flag
			}
			frameflag {
			set framerate $arg
			set state flag
			}
			startflag {
			set startsimtime $arg
			set  startsimtime1 1
			set state flag
			}
			endflag {
			set endsimtime $arg
			set  endsimtime1 1
			set state flag
			}
			pinflag {
			set pinname $arg
			set state flag
			}
			
		}
	}

	
	if {$pinname == 2} {
	set color white
	
	}
	
	
        

#-------------
# Main
#-------------
#set the envirronment in the GUI

marker delete -all
select clearall
config viewlayer  -name  all -style invisible
config viewlayer -name instance -style outline
set RPT [open "$outputf" w] 
#open report file for writing 

if { $inputflg == 1} {
set PT [open "$inputf" r] 

#open input sample file for reading master cell names
#read the instances belonging to the master cell names and store them in an array inputinst#
set j 0
while {[gets $PT line1] > 0} {
	set temp [get instofcell $line1]
	puts "Instance: $line1 No of Instances: [llength $temp]\n"
	foreach i $temp {
	set inputinst($j) $i
	incr j	
	}	
}
close $PT
}



#open mapping file ".apache/apache.imap which maps instances and mapping numbers# 
set PT2 [open ".apache/apache.imap" r]
while {[gets $PT2 line3 ]>0} {
	set words [split $line3 " "]
	set mapnum [lindex $words 0]
	set inst [lindex $words 1]
	set x $inst
	if {[regexp -all {/adsU1 } $x]} {
	} else {
	
	set instname($mapnum) $x	
	}
	}
	#create a hash witht key as mapnumber and instancename as value#
close $PT2	
	
#open and process ".apache/apache.dsw " to create a hash "map" with key as  mapnum and value as s/wtime and  finally create a  hash "swtim" with instancename as  key and s/wtime as value#
set PT1 [open ".apache/apache.dsw" r]
while {[gets $PT1 line2 ]>0} {
	set words [split $line2 " "]
	set mapnum [lindex $words 0]
	if { $pinname == 1} {
	set swtime [lindex $words 3]
	set map($mapnum) $swtime 
	set swtim($instname($mapnum)) $swtime
	}
	if { $pinname == 2} {
	set swtime [lindex $words 4]
	set map($mapnum) $swtime 
	set swtim($instname($mapnum)) $swtime
	}
				
	
	}
#puts "Finished reading imap"
close $PT1
if { $inputflg == 1 } {

set arr [array names inputinst] 
#read all array elements from inpuinst into a list#
#create a new hash only for input instances with inputinstsw with swtime as key and input instance as its value #

foreach f $arr {
 set inputinstsw($swtim($inputinst($f))) $inputinst($f)
 set timingsame($inputinst($f)) $swtim($inputinst($f))
 }

}

if { $inputflg == 0 } {
set arr [ array names swtim ] 
foreach f $arr {
 set inputinstsw($swtim($f)) $f
 set timingsame($f) $swtim($f)
 
 }

}

set naming [array names timingsame]


set sortsw [lsort -real -increasing [array names inputinstsw]]

#sort the  keys in accordance with s/w time #
#perform calculations to exactly recreate the s/w scenario within the user specified time by time scaling#
set min [lindex $sortsw 0]

if { $startsimtime1 == 1 } {

set min $startsimtime
foreach rrr $sortsw {

if {$rrr >= $startsimtime  } {
lappend foundones1 $rrr

}

}
set sortsw $foundones1
}

set length [llength $sortsw]
set last [expr $length - 1 ]
set max [lindex $sortsw $last]

if { $endsimtime1 == 1 } {

set max $endsimtime
foreach rrr $sortsw {

if {$rrr <= $endsimtime  } {
lappend foundones2 $rrr

}

}
set sortsw $foundones2

}

set find [llength $sortsw]
if { $find == 0} {
puts "$find instances found  in the given time interval"
}
set totalsw [expr int($max-$min)]
set ind 0
set firstinstsw $min
set finalgiffiles ""
set counter 0


#settimng value of time step so as to get 100 gifs in movie
set total_time_steps [llength $sortsw]
if { $movie == 1 && $timestep == 0 && $total_time_steps > 100 } {

	set time_step [expr $total_time_steps/50]
	
}


foreach m $sortsw {

foreach kkk $naming {

if {$timingsame($kkk)==$m} {
incr counter
set nextinstsw $timingsame($kkk)
set period [expr int($nextinstsw - $firstinstsw)]
set gap [expr (1000*$usertime*$period*1000/$totalsw)/1000]
set flag [expr $counter%$time_step]
if { $flag == 0 } {

if {$movie == 1} {
exec mkdir -p temp
dump gif -map SA -o temp/$ind.gif
append finalgiffiles " $ind.gif "
incr ind
} else {
	after $gap
}
}
puts $RPT "$kkk $m\n" 
#puts  "$kkk $m\n"
# write to report file #

#add marker for more visibility in GUI#
set temp [ query inst -bbox $inputinstsw($m) ]
marker add -position [lindex $temp 12] [lindex $temp 13] -color $color

select add $kkk -color $color ;



set firstinstsw $timingsame($kkk)
#set temp1 [ incr ind ]
#set nextinstsw [ lindex $sortsw $temp1 ] 
#set period [expr int($nextinstsw - $firstinstsw)]
#set gap [expr (1000*$usertime*$period*1000/$totalsw)/1000]


#execute next statement after a time gap#

}


}

}

close $RPT




if {$movie == 1} {
set SRC [open "sourceme" w] 
puts $SRC "cd temp\ngifsicle --delay $framerate $finalgiffiles -o ../$moviefile\ncd ..\n"
close $SRC
puts "Sometimes you  may get an error that gifsicle does not exist on your system.Install Gifsicle and set the  path to  gifsicle and run the command 'source sourceme' to create the gif later\n" 
#exec sh sourceme

} 

}
