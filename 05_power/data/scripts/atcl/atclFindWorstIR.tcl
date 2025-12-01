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

proc atclFindWorstIR_help {} {
puts "
USAGE
	atclFindWorstIR -met <METAL1, METAL2, ...> -net <VDD1|VSS1, VDD2|VSS2, ...> -\[POWER|GROUND\] -o <output file name> -h -m
"
}

proc atclFindWorstIR_manpage {} {
puts "
SYNOPSIS
	Apache TCL utility to fing worst IR drop/bounce on VDD/VSS nets 
USAGE
        atclFindWorstIR -met <METAL1, METAL2, ...> -net <VDD1|VSS1, VDD2|VSS2, ...> -\[POWER|GROUND\] -o <output file name> -h -m
OPTIONS
	-met <METAL1, METAL2, ...> : Comma separated list of metal layer names (Required)
	-net <VDD1|VSS1, VDD2|VSS2, ...> : Comma separated list of VDD|VSS net names (Required. Dont group VDD and VSS nets in same run)
	-\[POWER|GROUND\] : Specifies if nets specified in -net are POWER or GROUND (Required)
	-o <output file name : Optional
	-h : Help (Optional)
	-m : Manpage (Optional)
"
}

proc atclFindWorstIR { args } {
set outflag 0
set isPower 0
set isGround 0
regsub -all -- {[[:space:]]+} $args " " args
set argv [split $args]
set argc [llength $argv]
for {set j 0} {$j < $argc} {incr j 1} {
	if {[regexp {\-met} [lindex $argv $j]]} {
		for {set i [expr $j + 1]} {$i < $argc} {incr i 1} {
			if {![regexp {\-} [lindex $argv $i]] } {
				lappend metals [lindex $argv $i]
			} else {
				break
			}
                }
        } elseif {[regexp {\-net} [lindex $argv $j]]} {
                for {set i [expr $j + 1]} {$i < $argc} {incr i 1} {
                        if {![regexp {\-} [lindex $argv $i]] } {
				lappend nets [lindex $argv $i]
                        } else {
                                break
                        }
                }
        } elseif {[regexp {\-o} [lindex $argv $j]]} {
		set outflag 1
		set outfile [lindex $argv [expr $j + 1]]
	} elseif {[regexp {\-POWER} [lindex $argv $j]]} {
		set isPower 1
	} elseif {[regexp {\-GROUND} [lindex $argv $j]]} {
		set isGround 1
	} elseif {[regexp {\-h} [lindex $argv $j]]} {
		atclFindWorstIR_help; return;
	} elseif {[regexp {\-m} [lindex $argv $j]]} {
		atclFindWorstIR_manpage; return;
	}
} 

##############################################
set dirs [glob adsRpt/Static/*]
set len [llength $dirs]
for  {set i 0} {$i < $len} {incr i} {
        set f [lindex $dirs $i]
        if {[regexp {.*\.ir$} $f]} {
                set filename $f
        }
}
##############################################
regsub -all -- {[[:space:]]+} $metals "" metals
set metals [split $metals ","]
regsub -all -- {[[:space:]]+} $nets "" nets
set nets [split $nets ","]

if {$outflag == 1} {
	set OUTFILE [open $outfile w 0666]
	puts $OUTFILE "#voltage  #ideal_volt   #net       #x_y_location     #layer_name" 
} else {
	puts "#voltage  #ideal_volt   #net       #x_y_location     #layer_name"
}
for {set n 0} {$n < [llength $nets]} {incr n 1} {
	for {set m 0} {$m < [llength $metals]} {incr m 1} {
		if {[catch {exec grep [lindex $metals $m] $filename | grep [lindex $nets $n]}] == 0} {
			if {$isPower == 1} {
				exec grep [lindex $metals $m] $filename | grep [lindex $nets $n] | sort -n > atclFindWorstIR.log
			} elseif {$isGround == 1} {
				exec grep [lindex $metals $m] $filename | grep [lindex $nets $n] | sort -n -r > atclFindWorstIR.log
			}
			if {$outflag == 1} {
				puts $OUTFILE "[exec head -1 atclFindWorstIR.log]"
			} else {
				puts	"[exec head -1 atclFindWorstIR.log]"
			}
		}
	}
}

if {$outflag == 1} {
	close $OUTFILE
}
file delete -force atclFindWorstIR.log
};### End of proc






