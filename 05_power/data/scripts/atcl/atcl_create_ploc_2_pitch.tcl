############################################################################################################
#USAGE:
#atcl_create_ploc_2_pitch -layer <layer_name> -pitch1 <x_pitch_value> -pitch2 <y_pitch value> -net <net_name> -region <region bbox> -file <required output file name> -place_ploc <specify 1 for placing plocs automatically> \[-h\] \[-m\]"
# Copyright 2008 Apache Design Solutions, Inc.
# All rights reserved.
#
# Revision history
#
# Rev 1.0 
# - Created by Nithin 17/04/2014
# - Initial version
#
#####################################################################################################################################################


proc atcl_atclCreatePloc_manpage {} {
        puts "
SYNOPSIS
        Apache-AE TCL utility for creating plocs on the specfied metal layer and region at specfied pitch 
        

USAGE
        atcl_create_ploc_2_pitch \[option_arguments\]

        Options:
        -layer <layer_name>                Used to specify the layer in which ploc should be placed 
        -pitch1 <pitch_value>               Used to specify the horizontal distance between plocs.Default value 120um
   	-pitch2 <pitch value>		   Used to specify the vertical distance between the plocs. Default value 120um
        -net <net_name>                    Used to specify the net were ploc should be placed.Default all nets will be used
        -region <region bbox>              Used to specify the region were ploc should be placed
        -file <required output filename>   Name of the file to be created .If not mentioned default filename(pad.eco) will be used
        -place_ploc                        Place plocs automatically if set to 1  
        -xoffset                            Used to give an offset for placing ploc
        -direction			   Specify the direction of the wire that needs to be used,(h for horizontal,v for vertical). Default is both 
	-use_net_name			   Enable use_net_name option in eco add pad 
	-direction			   Provide the direction of the wire
        \[-h\]                             command usage
        \[-m\]                             man page
        -yoffset                           offset from bottom
SAMPLE USAGE    
                  atcl_create_ploc_2_pitch -layer MET7 -net VDD -pitch1 120 -pitch2 120
"
}
###################################################################################################################################
proc atcl_atclCreatePloc_help {} {
        puts "atcl_create_ploc_2_pitch -layer <layer_name> -pitch1 <x pitch_value> -pitch2 <y pitch value> -net <net_name> -region <region bbox> -xoffset <horizontal offsetvalue> -yoffset <vertical offset> -use_net_name  0|1 -file <required output file name> -direction <specify h or v >-place_ploc <specify 1 for placing plocs automatically> \[-h\] \[-m\]"
}
####################################################################################################################################################
proc atcl_create_ploc_2_pitch {args} {
set argv [split $args]
set state flag_s
set flag_use_net ""
set direction ""
set dir_comp ""
#set region ""
set i 0
foreach arg $argv {
                        switch -- $state {
                                flag_s {
                                        switch -glob -- $arg {
                                                -h* { atcl_atclCreatePloc_help ; return }
                                                -m* { atcl_atclCreatePloc_manpage ; return }
                                                -layer { set state layer_s }
                                                -pitch1 { set state pitch1_s }
                                                -pitch2 { set state pitch2_s }
                                                -net { set state net_s }
                                                -region { set state region_s }
                                                -file { set state file_s }
                                                -place_ploc { set state place_ploc_s }
                                                -direction { set state direction_s }
                                                -xoffset { set state offset_s }
						-use_net_name { set state use_net_name_s }
                                                -yoffset { set state yoffset_s }                               
	 }
                                }
				use_net_name_s {
					set use_net_name $arg
					set flag_use_net $use_net_name
                                        set state flag_s
				}
                                layer_s {
                                        set layer $arg
                                        set state flag_s
                                }
                                pitch1_s {
                                        set pitch1 $arg
                                        set state flag_s
                                }
                                pitch2_s {
                                        set pitch2 $arg
                                        set state flag_s
                                }

                                net_s {
                                        set net $arg
                                        set state flag_s
                                }
                                file_s {
                                        set file $arg
                                        set state flag_s
                                }
                                region_s {
                                     set region [concat $region $arg]
set i [expr $i+1]
if {$i == 4} {
                                       set state flag_s
}  
                                      
                                       }
                                place_ploc_s {
                                       set place_ploc $arg
                                       set state flag_s
                                       }
                                direction_s {
                                       set direction  $arg
                                       set state flag_s
				       puts "direction=$direction"
                                       }
                                offset_s {
                                       set offset $arg
                                       set state flag_s
                                }
				yoffset_s {
					set yoffset $arg
					set state flag_s
}
}
}
set flag_all_net 0
if {![info exists layer]}  {
puts  "ERROR: Please mention the layer"
return;
} else {
set metal [get design -layers -type metal]
set metals [split $metal " "]
foreach m $metals {
set is_metal($m) 1
}
if {![info exists is_metal($layer)] } {
puts "ERROR:No layer named $layer in the design "
return ;
}
}
if {![info exists pitch1]} {
puts "INFO: Pitch value not given .Default value 120um will be used"
set pitch1 120
}
if {![info exists pitch2]} {
puts "INFO: Pitch value not given .Default value 120um will be used"
set pitch2 120
}

if {![info exists offset]} {
puts "INFO: Offset value not given .Default value 0 will be used"
set offset 0
}
if {![info exists yoffset]} {
puts "INFO: Y-offset value not given.Default value 0 will be used"
set yoffset 0
}
if {![info exists net]} {
puts "INFO: Nets not specified.Plocs will be added in all nets in the design"
set flag_all_net 1
set net "all"
}
if {![info exists region]} {
puts "INFO: Region not specified .Entire die will be considerd"
set region [get design -bbox]
regsub -all {\t}  $region " " line1
regsub -all -- {[[:space:]]+} $line1 " " line2
set co_ord [split $line2 " "]
set x1 [lindex $co_ord 0]
set y1 [lindex $co_ord 1]
set x2 [lindex $co_ord 2]
set y2 [lindex $co_ord 3]
puts "INFO :Region co-ordintes are $x1 $y1 $x2 $y2"
} else {
set co_ord [split $region " "]
set x1 [lindex $co_ord 0]
set y1 [lindex $co_ord 1]
set x2 [lindex $co_ord 2]
set y2 [lindex $co_ord 3]
puts "INFO :Region co-ordintes are $x1 $y1 $x2 $y2"
}

if {![info exists file]} {
puts "INFO: File name not specified .Default file name will be used"
set file "pad.eco"
}

if {![info exists place_ploc]} {
puts "INFO: Plocs will not be placed.Only output file will be created "
set place_ploc 0
if { [ catch { config refresh no} ] == 0 } {
config refresh no
}
}
regsub -all {\{} $net "" line1
regsub -all {\}} $line1 "" line2
regsub -all -- {[[:space:]]+} $line2 "" net
set xloc [expr $offset + $x1]
set all_xloc $xloc
set yloc [expr $yoffset + $y1]
set all_yloc $yloc
while {1} {
set xloc [expr $pitch1 + $xloc]
if {$xloc <= $x2} {
lappend all_xloc $xloc
} else {break}
}
while {1} {
set yloc [expr $yloc + $pitch2]
if { $yloc <= $y2} {
lappend all_yloc $yloc
} else {break}
}
#puts "x location are $all_xloc"
#puts "y location are $all_yloc"
set powernet [get net * -glob -type power]
set gndnet [get net * -glob -type ground]
foreach power $powernet {
set net_type_pwr($power) 1
}
foreach gnd $gndnet {
set net_type_gnd($gnd) 1
}
if {[info exists net_type_pwr($net)] != 1  && [info exists net_type_gnd($net)] != 1 && [string compare "all" $net]  !=0} {
puts "ERROR: Net specified is not a valid power or ground net"
return;
}
set flag_loc 0
set flag_layer 0
set flag_net 0
global add_count
set add_count 0
#global total_count
#set total_count 0
exec rm -rf adsRpt/$file
set fp1 [open "adsRpt/$file" w]
close $fp1
set fp [open "adsRpt/$file" a]
if { [ catch { config refresh no } ] == 0 } {
puts $fp " config refresh no"
}
if {$flag_all_net == 1} {
set wires [get wire * -glob -layer $layer]
} else {
set wires [get wire * -glob -net $net -layer $layer]
}
regsub -all {\)}  $wires " " line1
regsub -all {\(}  $line1 " " line2
regsub -all {\,}  $line2 " " line
regsub -all {\t}  $line " " line1
regsub -all -- {[[:space:]]+} $line1 " " wires
if { $direction eq "h" } {
	 set dir_comp "HORIZONTAL"
	} elseif { $direction eq "v" } {
	 set dir_comp "VERTICAL" 
	} else {
	 set dir_comp "ALL"
	}
select clearall
set count 0
set i_temp 0
foreach i $wires {
set words [split $i " "]
set dir [lindex $words 7]
set width [lindex $words 3]
set length [lindex $words 4]
set lx [lindex $words 5]
set ly [lindex $words 6]
if {$dir eq "HORIZONTAL"} {
set ux [expr $lx + $length]
set uy [expr $ly + $width]
} elseif {$dir eq "VERTICAL"} {
set ux [expr $lx + $width]
set uy [expr $ly + $length]
} else {
continue
}
#puts "lx=$lx ly=$ly ux=$ux uy=$uy"
set gnet [lindex $words 1]
if { [ info exists net_type_pwr($gnet) ] } {
set net_type "POWER"
} elseif { [ info exists net_type_gnd($gnet) ] } {
set net_type "GROUND"
} else {
puts "INFO: $gnet not power or ground "
set net_type ""
}
if {$dir_comp eq "ALL" || $dir_comp eq $dir} {
foreach x  $all_xloc {

foreach y $all_yloc {
if {$x <= $ux && $x >= $lx && $y <= $uy && $y >= $ly } {
if { $flag_use_net == 1 } {
puts $fp "if  { \[ catch {eco add pad -metal $layer -type $net_type -x $x -y $y -use_net_name } \] == 0 } { 
          incr add_count
          }"
} else {
puts $fp "if  { \[ catch {eco add pad -metal $layer -type $net_type -x $x -y $y } \] == 0 } { 
          incr add_count
          }"
}
incr count
set flag_net 1
if { $place_ploc == 0 } {
marker add -position $x $y
}
}
}
}
}
}
if {$flag_net == 0} {
puts "ERROR: No Ploc can be placed either due to no wire geometry present on given layer of given net or settings are wrong"
config refresh yes
return;
}
puts "INFO: Number of valid ploc location $count"
if { [ catch { config refresh yes } ] == 0 } {
puts $fp " config refresh yes"
}
close $fp
if {$place_ploc == 1 } {
 puts "INFO:Started placing plocs in $layer"
  source adsRpt/$file
  puts "INFO:Finished placing plocs in $layer "
   puts  "INFO : Total number of plocs generated : $count"
 puts  "INFO :Total number of plocs successfully  placed : $add_count"
  } else {
  puts "INFO :Please source adsRpt/$file for placing plocs"
  }
if {[catch { config refresh yes } ] == 0} {
config refresh yes
}
if {[catch { config refresh yes } ] == 0} {
config refresh yes
}
}


