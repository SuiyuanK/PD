# $Revision: 1.148 $
 
#########################################################################
#
# atclviewgds.tcl is an Apache-AE TCL utility for viewing gds2def output
#
# Usage: type the following in Redhawk command window
#       source /home/prabin/tcl_scripts/atclviewgds.tcl 
#       
#
# Copyright © 2008 Apache Design Solutions, Inc.
# All  rights reserved.
#
# Revision history
#
# Rev 1.0
# - Created by Prabin K Prince on Feb 21 2008
# - Initial version
#
#########################################################################


proc atclTemplate_manpage {} {
	puts "
SYNOPSIS
        Apache-AE TCL utility for viewing gds2def output

USAGE
        atclviewgds \[option_arguments\]

        Options:
        -dir <gds2def directory>   this should contain lef def and gds files
        -cell <gds2def cell name>  gds2def cell name
	-layermap <layermap file> this option supports only new layermap format
	-norun <0/1> To do setup design or not
	\[-h\] 		  command usage
	\[-m\]		  man page
"
}

proc atclTemplate_help {} {
	puts "Usage: atclviewgds -dir <gds2def directory> ?-cell <gds2def cellname> ?-layermap <layermap file> ?-norun <0/1> \[-h\] \[-m\]"
}


proc atclviewgds { args } {
	set argv [split $args]
	if {[llength $argv] == 0 } { set argv "-h" }
	set state flag
	set inputf ""
#	set outputf ""
	set norun 0
	foreach arg $argv {
		switch -- $state {
			flag {
				switch -glob -- $arg {
					-h* { atclTemplate_help ; return }
					-m* { atclTemplate_manpage ; return }
					-dir  { set state inputflag }
					-cell  { set state outputflag }
					-layermap { set state layermapflag }
					-norun  { set state norunflag }
					default { error "actl Error: unknow flag $arg" }
				}
			}
			layermapflag {
			        set layermapf $arg
#				puts "$layermapf"
				set state flag
			}
			inputflag {
				set inputf $arg
				set state flag
			}
			outputflag {
				set outputf $arg
				set state flag
			}
			norunflag {
			set norun $arg
			set state flag
			}
		}
	}
	

if {[info exists outputf]} {
set temp $inputf
#puts "$temp"
set cell $outputf
set pratio_pattern "_adsgds.pratio"
set pratio $cell$pratio_pattern
if [file exists $inputf/$pratio] then {
set lef_pattern "_adsgds.lef"
set def_pattern "_adsgds.def"
set lef $outputf$lef_pattern
set def $outputf$def_pattern
if {![file exists $inputf/$lef]} then { puts "file $inputf/$lef doesn't exist" }
if {![file exists $inputf/$def]} then { puts "file $inputf/$def doesn't exist" }
} else {
set lef_pattern "_adsgds.lef"
set def_pattern ".def"
set lef $outputf$lef_pattern
set def $outputf$def_pattern
if {![file exists $inputf/$lef]} then { puts "file $inputf/$lef doesn't exist" }
if {![file exists $inputf/$def]} then { puts "file $inputf/$def doesn't exist" }
}
}
if {![info exists outputf]} {
set temp $inputf
set list1 [ exec ls $temp/ ]
foreach data $list1 { 
if { [regexp -all -nocase {lef} $data ] } {
set lef $data 
#puts "$lef" 
regexp -all -nocase {([a-z A-Z \_ 0-9]*)_adsgds.lef} $data -> cell
#puts "$cell"
}
if { [regexp -all -nocase {def} $data ] } {
set def $data 
#puts "$def"
}
}
if {![file exists $inputf/$lef]} then { puts "file $inputf/$lef doesn't exist" }
if {![file exists $inputf/$def]} then { puts "file $inputf/$def doesn't exist" }
}
if {![info exists layermapf]} {
#puts "not"
set met_pattern METAL
set min 0
set ground 0
set number 0
set metal 0
set via_number 0
set power 0
set via 0
set index 0
set max 0
set via_max 0
set pattern _adsgds.def
set file $cell$pattern


set PT [open "$temp/$def" r] 
while {[gets $PT line ]>= 0  } {
#puts "hello"


regexp -all -nocase {\+ ROUTED ((m[a-z]*)([0-9]*))} $line -> metal met_pattern number

regexp -all -nocase {NEW ((m[a-z]*)([0-9]*))} $line -> metal met_pattern number

regexp -all -nocase {LAYER ((m[a-z]*)([0-9]*))} $line -> metal met_pattern number
if { $number > 0} {
#puts "$metal $number"
}
if { $number > $max } {
set max $number
}
if { $number > $min } {
set min $number
}
set die "dielectric"
set die_layer $die$number
#puts "$metal $number $die_layer"
  if {![info exists metal_layer($number)]}  {
    set metal_layer($number) 0
  }
  set metal_layer($number) $metal
  
  if {![info exists dielectric_layer($number)]}  {
    set dielectric_layer($number) 0
  }
  set dielectric_layer($number) $die_layer
#puts "$metal_layer($number) $dielectric_layer($number) $number"

if { [regexp -all -nocase {RECT v[a-z]*[0-9]*} $line]} {
regexp -all -nocase {RECT (v[a-z]*(([0-9])[0-9]*))} $line -> via via_number index
#puts "$via $via_number $index"
if { $index > $via_max } {
set via_max $index
}
  if {![info exists via_layer($index)]}  {
    set via_layer($index) 0
  }
  set via_layer($index) $via
# puts "$via_layer($index) $index" 
}



if { [regexp -all -nocase {SPECIALNETS} $line]} {
while {[gets $PT line ]>= 0  } {
if { [regexp -all -nocase {\- (\S*)} $line]} {
regexp -all -nocase {\- (\S*)} $line -> vdd
#puts "$power $vdd "
}
regexp -all -nocase {\+ ROUTED ((m[a-z]*)([0-9]*))} $line -> metal met_pattern number
regexp -all -nocase {NEW ((m[a-z]*)([0-9]*))} $line -> metal met_pattern number
if { $number > 0} {
#puts "$metal $number"
}
if { $number > $max } {
set max $number
}
if { $number > $min } {
set min $number
}
set die "dielectric"
set die_layer $die$number
#puts "$metal $number $die_layer"
  if {![info exists metal_layer($number)]}  {
    set metal_layer($number) 0
  }
  set metal_layer($number) $metal
  
  if {![info exists dielectric_layer($number)]}  {
    set dielectric_layer($number) 0
  }
  set dielectric_layer($number) $die_layer




 if { [regexp -all -nocase {\+ USE POWER} $line]} {
 incr power
 if {![info exists vdd_nets($power)]}  {
   set vdd_nets($power) 0
 }
 
  set vdd_nets($power) $vdd
#  puts "$vdd_nets($power) $power "
 }
 
 
  if { [regexp -all -nocase {\+ USE GROUND} $line]} {
 incr ground
 if {![info exists gnd_nets($ground)]}  {
   set gnd_nets($ground) 0
 }
 
  set gnd_nets($ground) $vdd
#  puts "$gnd_nets($ground) $ground "
 }
 
 
if { [regexp -all -nocase {END SPECIALNETS} $line]} {
#puts "hello"
break
}
}

}
}
close $PT

set fd1 [open "tech_tcl1.lef" "w"]
puts  $fd1 "VERSION 5.4 ;"
puts  $fd1 "NAMESCASESENSITIVE ON ;"
puts  $fd1 "BUSBITCHARS \"[]\" ;"
puts  $fd1 "DIVIDERCHAR \"/\"  ;\n"
puts  $fd1 "UNITS"
puts  $fd1 "DATABASE MICRONS 2000  ;"
puts  $fd1 "END UNITS\n"
puts  $fd1 "MANUFACTURINGGRID 0.005 ;"
puts  $fd1 "USEMINSPACING OBS OFF ;\n"
 
foreach layer [array names metal_layer] {
if {![info exists via_layer($layer)]}  {
if { $metal_layer($layer) > 0} {
puts  $fd1 "LAYER $metal_layer($layer)"
puts  $fd1 "TYPE ROUTING ;"
puts  $fd1 "END $metal_layer($layer)\n"
# puts "$layer $metal_layer($layer) $dielectric_layer($layer)"
}
}
if {[info exists via_layer($layer)]} {
if { $metal_layer($layer) > 0} {
#puts "$layer $metal_layer($layer) $dielectric_layer($layer) $via_layer($layer)"
puts  $fd1 "LAYER $metal_layer($layer)"
puts  $fd1 "TYPE ROUTING ;"
puts  $fd1 "END $metal_layer($layer)\n"
}
if { $via_layer($layer) > 0} {
puts  $fd1 "LAYER $via_layer($layer)"
puts  $fd1 "TYPE CUT ;"
puts  $fd1 "END $via_layer($layer)\n"
}
}
}
puts  $fd1 "END LIBRARY"

close $fd1
#puts "pattern $met_pattern"

set fd2 [open "apache_tcl1.tech" "w"]
puts $fd2 "units {"
puts $fd2 "  capacitance 1p"
puts $fd2 "  inductance  1n"
puts $fd2 "  resistance  1"
puts $fd2 "  length      1u"
puts $fd2 "  current     1m"
puts $fd2 "  voltage     1"
puts $fd2 "  power       1"
puts $fd2 "  time        1n"
puts $fd2 "  frequency   1me"
puts $fd2 "}\n"
for {set i $max } { $i >0 } { set i [expr {$i - 1}]} {
if {[info exists metal_layer($i)]}  {
puts  $fd2 "metal $metal_layer($i)"
puts  $fd2 "\{"
puts  $fd2 "Thickness   0.699"
puts  $fd2 "EM          4.95"
puts  $fd2 "above      $dielectric_layer($i)"
puts  $fd2 "\}"
}
if {![info exists metal_layer($i)]}  {
set met_layer $met_pattern$i
puts  $fd2 "metal $met_layer"
puts  $fd2 "\{"
puts  $fd2 "Thickness   0.699"
puts  $fd2 "EM          4.95"
puts  $fd2 "above      dielectric$i"
puts  $fd2 "\}"
}
} 
for {set i $via_max } { $i >0 } { set i [expr {$i - 1}]} {
if {[info exists via_layer($i)]} { 
puts  $fd2 "via $via_layer($i)"
puts  $fd2 "\{"
puts  $fd2 "  Width       { 0.19 }"
puts  $fd2 "  Resistance  0.8229"
puts  $fd2 "  EM          0.199"
set j [expr {$i + 1}]
puts  $fd2 "  UpperLayer  $metal_layer($j)"
puts  $fd2 "  LowerLayer  $metal_layer($i)"
puts  $fd2 "\}"
}
}
set i [expr {$max + 1}] 
puts  $fd2 "dielectric dielectric$i"
puts  $fd2 "\{"
puts  $fd2 "  constant    8.1"
puts  $fd2 "  thickness   3"
puts  $fd2 "  above       dielectric$max"
puts  $fd2 "\}"
#puts "$max"
for {set i $max } { $i >0 } { set i [expr {$i - 1} ]} {
puts  $fd2 "dielectric dielectric$i"
puts  $fd2 "\{"
puts  $fd2 "  constant    8.1"
puts  $fd2 "  thickness   3"
set j [expr {$i - 1}]
if { $j != 0 } {
puts  $fd2 "  above       dielectric$j"
}
if { $j == 0} {
puts  $fd2 "   Height      0.0 "
}
puts  $fd2 "\}"
}
close $fd2
exec mkdir -p lib
set pattern "1.gsr"
set gsr $cell$pattern
set fd3 [open "$gsr" "w"]
puts $fd3 "VDD_NETS \{"
for {set k $power} { $k > 0} { set k [expr {$k - 1}]} {
puts $fd3 "$vdd_nets($k) 1"
}
puts $fd3 "\}"
puts $fd3 "GND_NETS \{"
for {set k $ground} { $k > 0} { set k [expr {$k - 1}]} {
puts $fd3 "$gnd_nets($k) 0"
}
puts $fd3 "\}"
puts $fd3 "IGNORE_UNDEFINED_LAYER 1"
puts $fd3 "IGNORE_TECH_ERROR 1"
puts $fd3 "IGNORE_DEF_ERROR 1"
puts $fd3 "IGNORE_PGARC_ERROR 1"
puts $fd3 "TOGGLE_RATE 0.3"
puts $fd3 "FREQ 300e6"
puts $fd3 "INPUT_TRANSITION 20ps"
puts $fd3 "STOP_DEF_LEF_MISMATCH 0"
puts $fd3 "ADD_LEF_CELL_FOR_POWER 1"
puts $fd3 "IGNORE_GDSMEM_ERROR 1"
puts $fd3 "TECH_FILE ./apache_tcl1.tech"
puts $fd3 "LEF_FILES \{"
puts $fd3 "./tech_tcl1.lef"
puts $fd3 "$temp/$lef"
puts $fd3 "\}"
puts $fd3 "GDS_CELLS \{"
puts $fd3 " $cell $temp"
puts $fd3 "\}"
puts $fd3 "ADD_PLOC_FROM_TOP_DEF 1"
puts $fd3 "LIB_FILES \{"
puts $fd3 "./lib/"
puts $fd3 "\}"
close $fd3
if {$norun == 0} {
setup design $gsr
}
} else {
#puts "hello"
set power 0
set ground 0
set met_count 0
set via_count 0
set PT0 [open "$layermapf" r] 
while {[gets $PT0 line1 ]>= 0  } {
regsub { [" "]*} $line1 { } line2
regsub {\t} $line2 { } line
#puts "$line"
set words [split $line " "]
set x1 [lindex $words 1]
set x0 [lindex $words 0]
set x2 [lindex $words 2]
if {[regexp -all -nocase {\#} $x0 ]} { continue }
if {[regexp -all -nocase {temp} $x1 ]} { continue }
if {[regexp -all -nocase {BOOLEAN} $x0 ]} {
if {[regexp -all -nocase {nw} $x2]} { 
set nwell [lindex $words 1]
puts "NWELL $nwell"
}
}
if {![regexp -all -nocase {BOOLEAN} $x0 ]} {
if {[regexp -all -nocase {nw} $x1]} { 
set nwell [lindex $words 0]
puts "NWELL $nwell"}
}


if {[regexp -all -nocase {BOOLEAN} $x0 ]} {
if {[regexp -all -nocase {pw} $x2]} { 
set pwell [lindex $words 1]
puts "PWELL $pwell"
}
}
if {![regexp -all -nocase {BOOLEAN} $x0 ]} {
if {[regexp -all -nocase {pw} $x1]} { 
set pwell [lindex $words 0]
puts "PWELL $pwell"}
}

if {[regexp -all -nocase {BOOLEAN} $x0 ]} {
if {[regexp -all -nocase {pd} $x2]} { 
set pdiff [lindex $words 1]
puts "PDIFF $pdiff"
}
}
if {![regexp -all -nocase {BOOLEAN} $x0 ]} {

if {[regexp -all -nocase {pd} $x1]} { 
set pdiff [lindex $words 0]
puts "PDIFF $pdiff"}
}


if {[regexp -all -nocase {BOOLEAN} $x0 ]} {
if {[regexp -all -nocase {nd} $x2]} { 
set ndiff [lindex $words 1]
puts "NDIFF $ndiff"
}
}
if {![regexp -all -nocase {BOOLEAN} $x0 ]} {

if {[regexp -all -nocase {nd} $x1]} { 
set ndiff [lindex $words 0]
puts "NDIFF $ndiff"}
}

if {[regexp -all -nocase {BOOLEAN} $x0 ]} {
if {[regexp -all -nocase {contact} $x2]} { 
set cont [lindex $words 1]
puts "CONTACT $cont"
}
}
if {![regexp -all -nocase {BOOLEAN} $x0 ]} {

if {[regexp -all -nocase {contact} $x1]} { 
set cont [lindex $words 0]
puts "CONTACT $cont"}
}


if {[regexp -all -nocase {BOOLEAN} $x0 ]} {
if {[regexp -all -nocase {poly} $x2]} { 
set poly [lindex $words 1]
puts "POLY $poly"
}
}
if {![regexp -all -nocase {BOOLEAN} $x0 ]} {

if {[regexp -all -nocase {poly} $x1]} { 
set poly [lindex $words 0]
puts "POLY $poly"}
}

if {[regexp -all -nocase {BOOLEAN} $x0 ]} {
if {[regexp -all -nocase {^m$} $x2]} { 
set met [lindex $words 1]
puts "METAL $met"
incr met_count
  if {![info exists metal($met_count)]}  {
    set metal($met_count) 0
  }
  set metal($met_count) $met
  
}
}
if {![regexp -all -nocase {BOOLEAN} $x0 ]} {

if {[regexp -all -nocase {^m$} $x1]} { 
set met [lindex $words 0]
puts "METAL $met"
incr met_count
  if {![info exists metal($met_count)]}  {
    set metal($met_count) 0
  }
  set metal($met_count) $met
}
}


if {[regexp -all -nocase {BOOLEAN} $x0 ]} {
if {[regexp -all -nocase {^v$} $x2]} { 
set v [lindex $words 1]
puts "VIA $v"
incr via_count
  if {![info exists via($via_count)]}  {
    set via($via_count) 0
  }
  set via($via_count) $v
}
}
if {![regexp -all -nocase {BOOLEAN} $x0 ]} {

if {[regexp -all -nocase {^v$} $x1]} { 
set v [lindex $words 0]
puts "VIA $v"
incr via_count
  if {![info exists via($via_count)]}  {
    set via($via_count) 0
  }
  set via($via_count) $v
}
}


}
set fd2 [open "apache_tcl.tech" "w"]

puts  $fd2 "units \{"
puts  $fd2 "  capacitance 1p"
puts  $fd2 "  inductance  1n"
puts  $fd2 "  resistance  1"
puts  $fd2 "  length      1u"
puts  $fd2 "  current     1m"
puts  $fd2 "  voltage     1"
puts  $fd2 "  power       1"
puts  $fd2 "  time        1n"
puts  $fd2 "  frequency   1me"
puts  $fd2 "\}\n"

if {[info exists pwell]}  {
puts  $fd2 "metal $pwell"
puts  $fd2 "\{"
puts  $fd2 "  Width \{ 0.14 \}"
puts  $fd2 "  Spacing \{ \{ 0.10 \} \}"
puts  $fd2 "  Resistance 0.179"
puts  $fd2 "  Thickness 0.15"
puts  $fd2 "  EM 1.041"
puts  $fd2 "  Height 0.15"
puts  $fd2 "\}"
}

if {[info exists nwell]}  {
puts  $fd2 "metal $nwell"
puts  $fd2 "\{"
puts  $fd2 "  Width \{ 0.14 \}"
puts  $fd2 "  Spacing \{ \{ 0.10 \} \}"
puts  $fd2 "  Resistance 0.179"
puts  $fd2 "  Thickness 0.15"
puts  $fd2 "  EM 1.041"
puts  $fd2 "  Height 0.35"
puts  $fd2 "\}"
}

if {[info exists poly]}  {
puts  $fd2 "metal $poly"
puts  $fd2 "\{"
puts  $fd2 "  Width \{ 0.14 \}"
puts  $fd2 "  Spacing \{ \{ 0.10 \} \}"
puts  $fd2 "  Resistance 0.179"
puts  $fd2 "  Thickness 0.15"
puts  $fd2 "  EM 1.041"
puts  $fd2 "  Height 0.65"
puts  $fd2 "\}"
}

if {[info exists pdiff]}  {
puts  $fd2 "metal $pdiff"
puts  $fd2 "\{"
puts  $fd2 "  Width \{ 0.14 \}"
puts  $fd2 "  Spacing \{ \{ 0.10 \} \}"
puts  $fd2 "  Resistance 0.179"
puts  $fd2 "  Thickness 0.15"
puts  $fd2 "  EM 1.041"
puts  $fd2 "  Height 0.9"
puts  $fd2 "\}"
}

if {[info exists ndiff]}  {
puts  $fd2 "metal $ndiff"
puts  $fd2 "\{"
puts  $fd2 "  Width \{ 0.14 \}"
puts  $fd2 "  Spacing \{ \{ 0.10 \} \}"
puts  $fd2 "  Resistance 0.179"
puts  $fd2 "  Thickness 0.20"
puts  $fd2 "  EM 1.041"
puts  $fd2 "  Height 1.1"
puts  $fd2 "\}"
}
for {set i 1} {$i<=$met_count} {incr i} {
puts  $fd2 "metal $metal($i)"
puts  $fd2 "\{"
puts  $fd2 "  Width \{ 0.14 \}"
puts  $fd2 "  Spacing \{ \{ 0.12 \} \}"
puts  $fd2 "  Resistance 0.179"
puts  $fd2 "  Thickness 0.20"
puts  $fd2 "  EM 1.041"
puts  $fd2 "  Height [expr {$i + 1 }]"
puts  $fd2 "\}"
}
if {[info exists cont]} then {
puts  $fd2 "via $cont"
puts  $fd2 "\{"
puts  $fd2 "  EM 1.921e-1"
puts  $fd2 "  Resistance 6.092"
puts  $fd2 "  Width \{ 0.13 \}"
puts  $fd2 "  UpperLayer $metal(1)"
if {([info exists ndiff] && [info exists pdiff])}  {
puts  $fd2 "  LowerLayer $ndiff $pdiff"
} else { if {[info exists ndiff]}  {
puts  $fd2 "  LowerLayer $ndiff"
} else { if {[info exists pdiff]} {
puts  $fd2 "  LowerLayer $pdiff "
}
}
}
puts  $fd2 "\}"
}
for {set i 1} {$i<=$via_count} {incr i} {
puts  $fd2 "via $via($i)"
puts  $fd2 "\{"
puts  $fd2 " Resistance 6.092"
puts  $fd2 " EM 1.211e-1"
puts  $fd2 " Width \{ 0.13 \}"
puts  $fd2 " UpperLayer $metal([expr {$i + 1}])"
puts  $fd2 " LowerLayer $metal($i)"
puts  $fd2 " \}"
}
puts  $fd2 "dielectric dielectric0"
puts  $fd2 "\{"
puts  $fd2 " constant 4.4"
puts  $fd2 " thickness 0.15"
puts  $fd2 " Height 0"
puts  $fd2 "\}"
puts  $fd2 "dielectric dielectric01"
puts  $fd2 "\{"
puts  $fd2 " constant 4.4"
puts  $fd2 " thickness 0.15"
puts  $fd2 " Height 0.95"
puts  $fd2 "\}"

puts  $fd2 "dielectric dielectric012"
puts  $fd2 "\{"
puts  $fd2 " constant 4.4"
puts  $fd2 " thickness 0.15"
puts  $fd2 " Height 1.25"
puts  $fd2 "\}"


for {set i 1} {$i<=$met_count} {incr i} {
puts  $fd2 "dielectric dielectric$i"
puts  $fd2 "\{"
puts  $fd2 " constant 4.4"
puts  $fd2 " thickness 0.15"
puts  $fd2 " Height [expr {$i + 0.5 + 1}]"
puts  $fd2 "\}"
}

puts  $fd2 "dielectric dielectric[expr {$met_count + 1}]"
puts  $fd2 "\{"
puts  $fd2 " constant 4.4"
puts  $fd2 " thickness 0.15"
puts  $fd2 " Height [expr {$met_count + 1 + 0.5 + 1}]"
puts  $fd2 "\}"
close $fd2

set PT1 [open "$temp/$def" r] 
while {[gets $PT1 line ]>= 0  } {




if { [regexp -all -nocase {SPECIALNETS} $line]} {
while {[gets $PT1 line ]>= 0  } {
if { [regexp -all -nocase {\- (\S*)} $line]} {
regexp -all -nocase {\- (\S*)} $line -> vdd
#puts "$power $vdd "
}


 if { [regexp -all -nocase {\+ USE POWER} $line]} {
 incr power
 if {![info exists vdd_nets($power)]}  {
   set vdd_nets($power) 0
 }
 
  set vdd_nets($power) $vdd
  puts "$vdd_nets($power) $power "
 }
 
 
  if { [regexp -all -nocase {\+ USE GROUND} $line]} {
 incr ground
 if {![info exists gnd_nets($ground)]}  {
   set gnd_nets($ground) 0
 }
 
  set gnd_nets($ground) $vdd
  puts "$gnd_nets($ground) $ground "
 }
 
 
if { [regexp -all -nocase {END SPECIALNETS} $line]} {
#puts "hello"
break
}
}

}


}

exec mkdir -p lib
set pattern "1.gsr"
set gsr $cell$pattern
set fd3 [open "$gsr" "w"]
puts $fd3 "VDD_NETS \{"
for {set k $power} { $k > 0} { set k [expr {$k - 1}]} {
puts $fd3 "$vdd_nets($k) 1"
}
puts $fd3 "\}"
puts $fd3 "GND_NETS \{"
for {set k $ground} { $k > 0} { set k [expr {$k - 1}]} {
puts $fd3 "$gnd_nets($k) 0"
}
puts $fd3 "\}"
puts $fd3 "IGNORE_UNDEFINED_LAYER 1"
puts $fd3 "IGNORE_PGARC_ERROR 1"
puts $fd3 "IGNORE_TECH_ERROR 1"
puts $fd3 "IGNORE_DEF_ERROR 1"
puts $fd3 "TOGGLE_RATE 0.3"
puts $fd3 "FREQ 300e6"
puts $fd3 "INPUT_TRANSITION 20ps"
puts $fd3 "STOP_DEF_LEF_MISMATCH 0"
puts $fd3 "ADD_LEF_CELL_FOR_POWER 1"
puts $fd3 "IGNORE_GDSMEM_ERROR 1"
puts $fd3 "TECH_FILE ./apache_tcl.tech"
puts $fd3 "GDS_CELLS \{"
puts $fd3 "$cell $temp"
puts $fd3 "\}"
puts $fd3 "ADD_PLOC_FROM_TOP_DEF 1"
puts $fd3 "LIB_FILES \{"
puts $fd3 "./lib/"
puts $fd3 "\}"
close $fd3
if {$norun == 0} {
setup design $gsr
}
}

}
