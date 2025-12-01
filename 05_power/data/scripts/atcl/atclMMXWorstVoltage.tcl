#########################################################################
#
# Apache Design Solutions, Inc.
#
# Copyright 2008 Apache Design Solutions, Inc.
# All rights reserved.
#
# Revision history
#
# - Created by Devesh Nema
#
#########################################################################

proc atclMMXWorstVoltage_help {} {
puts "USAGE
atclMMXWorstVoltage ?-o <output file name>? ?-h? ?-m?
"
}

proc atclMMXWorstVoltage_manpage {} {
puts "
SYNOPSIS 
- APACHE-AE TCL utility to report worst drop/bounce on each domain at each dynamic time step
- USAGE atclMMXWorstVoltage ?-o <output file name>? ?-h? ?-m?
- Options
	?-o <output file name>? : Optional output file name. Default output is MMXWorstVoltage.out
	\[-h\] : Help
	\[-m\] : Manpage
"
}

proc atclMMXWorstVoltage { args } {
set argv [split $args]
set argc [llength $argv]

set outfile "MMXWorstVoltage.out"
for {set j 0} {$j < $argc} {incr j 1} {
	if {[regexp -nocase {\-o} [lindex $argv $j]]} {
        	set outfile [lindex $argv [expr $j + 1]]
        } elseif  {[regexp -nocase {\-h} [lindex $argv $j]]} {
                atclMMXWorstVoltage_help;return
        } elseif  {[regexp -nocase {\-m} [lindex $argv $j]]} {
                atclMMXWorstVoltage_manpage;return
	}
}

set OUT [open $outfile w]
set PVI [open .apache/pvi_frame_temporal.out r]

#Read the first line
gets $PVI line
regsub -all -- {[[:space:]]+} $line " " line
set line [split $line]
set start_time [lindex $line 0]
set end_time   [lindex $line 1]
set step_size  [lindex $line 2]

#puts "start_time [lindex $line 0]"
#puts "end_time   [lindex $line 1]"
#puts "step_size  [lindex $line 2]"

#Read the second line
gets $PVI line
regsub -all -- {[[:space:]]+} $line " " line
set line [split $line]
set n_frames [lindex $line 0]

#puts "n_frames [lindex $line 0]"

#Read the third line
gets $PVI line
regsub -all -- {[[:space:]]+} $line " " line
set line [split $line]
set n_insts    [lindex $line 0]
set n_pininsts [lindex $line 1]

#puts "n_insts    [lindex $line 0]"
#puts "n_pininsts [lindex $line 1]"

#Read the fourth line, i.e. instance line. Assuming only one instance
gets $PVI line
regsub -all -- {[[:space:]]+} $line " " line
set line [split $line]
set inst_id    [lindex $line 1]
set n_vddpins  [lindex $line 2]
set n_vsspins  [lindex $line 3]

#puts "inst_id    [lindex $line 1]"
#puts "n_vddpins  [lindex $line 2]"
#puts "n_vsspins  [lindex $line 3]"

############################################################################################
# Read the GSR to get the VDD and VSS net names
set file [lindex [glob -nocomplain -directory .apache *.gsr] 0]
#puts "$file"
set GSR [open $file r]
while {[gets $GSR gline] >= 0} {
	regsub -all -- {[[:space:]]+} $gline " " gline
        set gline [split $gline]
	if {[regexp {VDD_NETS} $gline]} {
		gets $GSR gline
		while {![regexp "\}" $gline]} {
			if {![regexp {^#} $gline]} {
				regsub -all -- {[[:space:]]+} $gline " " gline
			        set gline [split $gline]
				lappend vddnets [lindex $gline 0]
			}
			gets $GSR gline
		}
	} elseif {[regexp {GND_NETS} $gline]} {
                gets $GSR gline
                while {![regexp "\}" $gline]} {
			if {![regexp {^#} $gline]} {
                        	regsub -all -- {[[:space:]]+} $gline " " gline
	                        set gline [split $gline]
	                        lappend vssnets [lindex $gline 0]
			}
	                gets $GSR gline
		}
	}
}

#puts "$vddnets"
#puts "$vssnets"
set n_vddnets [llength $vddnets]
set n_vssnets [llength $vssnets]
for  {set k 0} {$k < $n_vddnets} {incr k 1} {
	set vddnetpincount($k) 0
}
for  {set k 0} {$k < $n_vssnets} {incr k 1} {
        set vssnetpincount($k) 0
}
set str "count"
close $GSR
############################################################################################

# Read all the VDD pin names for the instance
for {set k 1} {$k <= $n_vddpins} {incr k 1} {
	gets $PVI line
	regsub -all -- {[[:space:]]+} $line " " line
	set line [split $line]
	foreach vddnet $vddnets {
		if {$vddnet ==  [lindex [split [lindex $line 0] "."] 0]} {
                       set vddnetpincount([lsearch $vddnets $vddnet]) [expr $vddnetpincount([lsearch $vddnets $vddnet]) + 1]
                }

	}
}

# Read all the VSS pin names for the instance
for {set k 1} {$k <= $n_vsspins} {incr k 1} {
        gets $PVI line
        regsub -all -- {[[:space:]]+} $line " " line
        set line [split $line]
        foreach vssnet $vssnets {
                if {$vssnet == [lindex [split [lindex $line 0] "."] 0]} {
                        set vssnetpincount([lsearch $vssnets $vssnet]) [expr $vssnetpincount([lsearch $vssnets $vssnet]) + 1]
                }
        }
}

#foreach {pinid count} [array get vddnetpincount] {
#       puts "pinid : $pinid ; count : $count"
#}
#puts "%%%%%%%%%%%%%%%%%"
#foreach {pinid count} [array get vssnetpincount] {
#       puts "pinid : $pinid ; count : $count"
#}



#puts "pinnamelist $pinnamelist"

#Read the voltages at each frame for all the pins
for {set i 1} {$i <= $n_frames} {incr i 1} {
	gets $PVI line
        regsub -all -- {[[:space:]]+} $line " " line
        set line [split $line]
	set fframe [lindex $line 1]
	lappend framelist $fframe
	for {set j 1} {$j <= $n_vddpins} {incr j 1} {
		gets $PVI line
	        regsub -all -- {[[:space:]]+} $line " " line
        	set line [split $line]
		set vddlist($fframe,$j) [lindex $line 0]
	}
	for {set j 1} {$j <= $n_vsspins} {incr j 1} {
                gets $PVI line
                regsub -all -- {[[:space:]]+} $line " " line
                set line [split $line]
                set vsslist($fframe,$j) [lindex $line 0]
        }

}


close $PVI


#puts "VDD list"
#foreach {ff pinid} [array get vddlist] {
	#puts "ff : $ff ; pinid : $pinid"
#}
#puts "VSS list"
#foreach {ff pinid} [array get vsslist] {
        #puts "ff : $ff ; pinid : $pinid"
#}

#puts "framelist $framelist"

# Find the minimum VDD voltage in each frame
puts $OUT "################### VDD Pins ######################"
	for {set i 0} {$i < $n_vddnets} {incr i 1} {
	puts $OUT "# [lindex $vddnets $i]"
	puts $OUT "#Timestep    Min. Volt"
	foreach ff $framelist {
#		puts "i = $i"
		if {$i == 0} {
			set start [expr [expr $vddnetpincount($i) * [expr $i + 1]] - [expr $vddnetpincount($i) - 1]]	
	                set end  [expr  $vddnetpincount($i) * [expr $i + 1]]
		} else {
			set start [expr [expr $vddnetpincount([expr $i - 1]) * [expr $i + 1]] - [expr $vddnetpincount([expr $i - 1]) - 1]]
	                set end  [expr  $vddnetpincount($i) * [expr $i + 1]]
		}
#		puts "start = $start, end = $end"
		set minvolt $vddlist($ff,$start)
		for {set j $start} {$j <= $end} {incr j 1} {
			if {$vddlist($ff,$j) <= $minvolt} {
	                        set minvolt $vddlist($ff,$j)
        	        }
		}
	puts $OUT "$ff  $minvolt"
	}
	}


puts $OUT "################### VSS Pins ######################"
# Find the maximum VSS voltage in each frame
        for {set i 0} {$i < $n_vssnets} {incr i 1} {
	puts $OUT "# [lindex $vssnets $i]"
	puts $OUT "#Timestep    Max. Volt"
	foreach ff $framelist {
#		puts "i = $i"
		if {$i == 0} {
	                set start [expr [expr $vssnetpincount($i) * [expr $i + 1]] - [expr $vssnetpincount($i) - 1]]
                        set end  [expr [expr  $vssnetpincount($i) + $start] - 1]
		} else {
			set start [expr [expr $vssnetpincount([expr $i - 1]) * [expr $i + 1]] - [expr $vssnetpincount([expr $i - 1]) - 1]]
                        set end  [expr [expr  $vssnetpincount($i) + $start] - 1]
		}
#		puts "start = $start, end = $end"
                set maxvolt $vsslist($ff,$start)
                for {set j $start} {$j <= $end} {incr j 1} {
                        if {$vsslist($ff,$j) >= $maxvolt} {
                                set maxvolt $vsslist($ff,$j)
                        }
                }
        puts $OUT "$ff  $maxvolt"
        }
	}


close $OUT
		
puts "Output file generated : $outfile"
}; ##end of proc atclMMXWorstVoltage


