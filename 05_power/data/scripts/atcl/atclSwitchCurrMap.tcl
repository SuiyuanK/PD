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

proc atclSwitchCurrMap_help {} {
puts "USAGE
atclSwitchCurrMap [-static | -dynamic | -rampup] ?-h? ?-m?
"
}

proc atclSwitchCurrMap_manpage {} {
puts "
SYNOPSIS
- Apache-AE TCL utility to display switch current map
USAGE
- atclSwitchCurrMap [-static | -dynamic | -rampup] ?-h? ?-m?
Options
	[-static | -dynamic | -rampup] : Type of analysis done. (Required)
	?-h? : Help (Optional)
	?-m? : Manpage (Optional)
"
}
  
proc atclSwitchCurrMap {args} {
set argv [split $args]
set argc [llength $argv]


for {set j 0} {$j < $argc} {incr j 1} {
        if {[regexp -nocase {\-static} [lindex $argv $j]]} {
                set flag "static"
		set filename "adsRpt/Static/switch_static.rpt" 
		set ind 4 
        } elseif  {[regexp -nocase {\-dynamic} [lindex $argv $j]]} {
                set flag "dynamic"
		set filename "adsRpt/Dynamic/switch_dynamic.rpt"
		set ind 4
        } elseif  {[regexp -nocase {\-rampup} [lindex $argv $j]]} {
                set flag "rampup"
		set filename "adsRpt/Dynamic/switch_dynamic.rpt" 
		set ind 2
        } elseif  {[regexp {\-h} [lindex $argv $j]]} {
                atclSwitchCurrMap_help;return
        } elseif  {[regexp {\-m} [lindex $argv $j]]} {
                atclSwitchCurrMap_manpage;return
        }
}

if {![info exists flag]} {
	puts "Please use one of -static, -dynamic or -rampup options"
	return
}

if {![file exists $filename]} {
	puts "Please perform $flag analysis first"
	return
}

config viewlayer -name instance -style invisible
config viewlayer -name all  -style invisible
config viewpad -type all -mode off


set SW [open $filename r 0666]
while { [gets $SW line] >=0 } {
	if {[regexp {^#} $line]} {
	} else {
	regsub -all -- {[[:space:]]+} $line " " line
	set line [split $line]
	if {[regexp -nocase {OFF}  [lindex $line $ind]]} {
		set swcurr([lindex $line 0]) 0
		lappend currlist 0
	} else {
		if {$flag == "static"} {
                        set swcurr([lindex $line 0]) [expr [lindex $line $ind] * 0.001]
                        lappend currlist [expr [lindex $line $ind] * 0.001]
		} else {
			set swcurr([lindex $line 0]) [lindex $line $ind]
			lappend currlist [lindex $line $ind]
		}
	}
	}
}
close $SW

set bins 20
set OUT [open atclSwitchCurrtemp.out w]
set currlist [lsort -real $currlist]
set len [llength $currlist]
set min [lindex $currlist 0]
set max [lindex $currlist [expr $len - 1]]
#puts "[expr $max - $min]"
set binsize [expr [expr $max - $min]/ double($bins)]
#puts "binsize = $binsize, min = $min, max = $max"
for {set i 1} {$i <= $bins} {incr i 1} { 
	set lowrange($i) [expr $min + [expr [expr $i-1] * $binsize]]
	set highrange($i) [expr $lowrange($i) + $binsize]
	puts $OUT "[format %e   $lowrange($i)] [format %e   $highrange($i)]"
}
close $OUT

array set color {
1 #15317E
2 #2554C7
3 #306EFF
4 #3BB9FF
5 #50EBEC
6 #307D7E
7 #617C58
8 #347C17
9 #00FF00
10 #B1FB17
11 #FFFF00
12 #FDD017
13 #F88017
14 #E56717
15 #C35617
16 #F75D59
17 #E55451
18 #FF0000
19 #F62217
20 #E41B17
}
foreach {inst curr} [array get swcurr] {
	for {set i 1} {$i <= $bins} {incr i 1} {
		if {$i ==1} {
			if {$curr >= $lowrange($i) && $curr <= $highrange($i)} {
        	                select add $inst -color $color($i) -linewidth 200
	                }
		} else {
			if {$curr > $lowrange($i) && $curr <= $highrange($i)} {
				select add $inst -color $color($i) -linewidth 200
			}
		}
	}
}

set apache [exec which redhawk]
regsub -all -- {bin\/redhawk} $apache "scripts/atcl" apache
if {[catch {exec wish $apache/Frame.tcl  & }]} {}
}; ### End of proc atclSwitchCurr



