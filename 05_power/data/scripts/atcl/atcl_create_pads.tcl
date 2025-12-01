
proc atcl_atclCreatePloc_manpage {} {
        puts "
SYNOPSIS
        Apache-AE TCL utility for creating plocs on the specfied metal layer and region at specfied pitch 
        

USAGE
        atcl_create_pads \[option_arguments\]

        Options:
        -layer <layer_name>                Used to specify the layer in which ploc should be placed 
        -pitch <pitch_value>               Used to specify the distance between plocs.Default value 120um
        -net <net_name>                    Used to specify the net were ploc should be placed.Default all nets will be used
        -region <region bbox>              Used to specify the region were ploc should be placed
        -file <required output filename>   Name of the file to be created .If not mentioned default filename(pad.eco) will be used
        -place_ploc                        Place plocs automatically if set to 1  
        -offset                            Used to give an offset for placing ploc
	-use_net_name			   Enable use_net_name option in eco add pad 
        -pad_suffix                        User can specify the pad name to be used. Integers are concatenated with suffix to make it unique. When enabled utility wont be able to place plocs (place_ploc 1), instead write out a file pad.ploc.
        -group_name                        Used to specify how the pads needs to be grouped in package side. Added as 6th column in pad.ploc file.
        \[-h\]                             command usage
        \[-m\]                             man page

SAMPLE USAGE    
                  atcl_create_ploc -layer MET7 -net VDD -pitch 120 
"
}
###################################################################################################################################
proc atcl_atclCreatePloc_help {} {
    puts "atcl_create_pads -layer <layer_name> -pitch <pitch_value> -net <net_name> -region <bbox {x1,y1,x2,y2}> -offset < offsetvalue> -pad_suffix <suffix> -group_name <pad grouping name> -use_net_name  0|1 -file <required output file name> -place_ploc <specify 1 for placing plocs automatically> \[-h\] \[-m\]"
}
####################################################################################################################################################
proc atcl_create_pads {args} {
set argv [split $args]
set state flag_s
set flag_use_net ""
set use_suffix 0
set use_group 0
foreach arg $argv {
                        switch -- $state {
                                flag_s {
                                        switch -glob -- $arg {
                                                -h* { atcl_atclCreatePloc_help ; return }
                                                -m* { atcl_atclCreatePloc_manpage ; return }
                                                -layer { set state layer_s }
                                                -pitch { set state pitch_s }
                                                -net { set state net_s }
                                                -region { set state region_s }
                                                -file { set state file_s }
                                                -place_ploc { set state place_ploc_s }
                                                -offset { set state offset_s }
						-use_net_name { set state use_net_name_s }
                                                -pad_suffix { set state pad_suffix_s }
                                                -group_name { set state group_name_s }

                                        }
                                }
				use_net_name_s {
                                    set use_net_name $arg
                                    set flag_use_net $use_net_name
                                    puts "Flag = $flag_use_net\n";
                      		}
                                pad_suffix_s {
                                    set pad_suffix $arg
                                    set use_suffix 1
                                    puts "INFO: When suffix is specified plocs cannot be placed. pad location will be stored in pad.ploc file"
                                    set state flag_s
                                }
                                group_name_s {
                                    set group_name $arg
                                    set use_group 1
                                    puts "INFO: Used to specify the grouping of pads to be done for package side connection. User also needs to provide a suffix string to use this switch"
                                    set state flag_s
                                }
                                layer_s {
                                        set layer $arg
                                        set state flag_s
                                }
                                pitch_s {
                                        set pitch $arg
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
                                       set region $arg
                                       set state flag_s
                                       }
                                place_ploc_s {
                                       set place_ploc $arg
                                       set state flag_s
                                       }
                                offset_s {
                                       set offset $arg
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

if {![info exists pitch]} {
puts "INFO: Pitch value not given .Default value 120um will be used"
set pitch 120
}

if {![info exists offset]} {
puts "INFO: Offset value not given .Default value 0 will be used"
set offset 0
}

if {![info exists net]} {
puts "INFO: Nets not specified.Plocs will be added in all nets in the design"
set flag_all_net 1
set net "all"
}

#puts "$layer $pitch $net $region"
#return
set region_flag 0
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
set region_flag 1
set co_ord [split $region ',']
set x1 [lindex $co_ord 0]
set y1 [lindex $co_ord 1]
set x2 [lindex $co_ord 2]
set y2 [lindex $co_ord 3]
puts "INFO :Region co-ordintes are $x1 $y1 $x2 $y2"
}
#return
if {![info exists file]} {
puts "INFO: File name not specified .Default file name will be used"
    if { $use_suffix == 1 } { set file "pad.ploc"} else {set file "pad.eco"}
}

if {![info exists place_ploc]} {
puts "INFO: Plocs will not be placed.Only output file will be created "
set place_ploc 0
if { [ catch { config refresh no} ] == 0 } {
config refresh no
}
}
#Removing the flower braces returned by redhawk when net name is with a aquare bracket 
regsub -all {\{} $net "" line1
regsub -all {\}} $line1 "" line2
regsub -all -- {[[:space:]]+} $line2 "" net
#Storing all nets in the design in a variable#
set powernet [get net * -glob -type power]
set gndnet [get net * -glob -type ground]

foreach power $powernet {
set net_type_pwr($power) 1
}
foreach gnd $gndnet {
set net_type_gnd($gnd) 1
}
exec rm -rf ./out.txt
if {$flag_all_net == 0} {
if {[info exist net_type_pwr($net)] || [info exist net_type_gnd($net)]} {
puts "$net found in database"
if {[catch {get wire * -glob -layer $layer -net $net -o out.txt}]} {puts "Error while getting wire"
return
}
} else { puts "net not found in database, please enter correct net name"
return
}
} else {
if {[catch {get wire * -glob -layer $layer -o out.txt}]} {puts "Error while getting wire"
return
}
}
#return
set flag_loc 0
#set flag_pitch 0
set flag_layer 0
set flag_net 0
global add_count
set add_count 0
global total_count
set total_count 0
exec rm -rf adsRpt/$file
set fp1 [open "adsRpt/$file" w]
close $fp1
set fp [open "adsRpt/$file" a]
if { [ catch { config refresh no } ] == 0 } {
puts $fp " config refresh no"
}
#set dbg [open "dbg" w]
#PROCESSING STARTS HERE#
set fz [open "out.txt" r]
#Looping through all wires in the design #
while 1 {
gets $fz wires

if [eof $fz] break
if {[regexp {(^#|^$)} $wires]} {
continue
}

regsub -all {\)}  $wires " " line1
regsub -all {\(}  $line1 " " line2
regsub -all {\,}  $line2 " " line
regsub -all {\t}  $line " " line1
regsub -all -- {[[:space:]]+} $line1 " " i

        set words [split $i " "] 
	set dir [ lindex $words 7]
        set wid [lindex $words 3]
        set len [lindex $words 4]
	set glayer [lindex $words 2]
	set t_net [lindex $words 1]
if {[info exists net_type_pwr($t_net)]} {set net_type power
} else { set net_type ground }
if { $len < $wid } { 
set temp $len
set len $wid
set wid $temp

if {[string compare $dir VERTICAL] == 0} { set dir "HORIZONTAL"
} else {set dir "VERTICAL"}
}
        
set llx [lindex $words 5]
set lly [lindex $words 6]

if {[string compare $dir HORIZONTAL] == 0} {
                set pad_yloc [expr {$lly +double($wid)/2}]
                set pad_xloc [expr $x1 + $offset]
                set lrx [expr {$llx + $len}]
		if {$region_flag ==1 } {
                    if {$pad_yloc < $y1 || $pad_yloc > $y2} { continue }
                }
                while {$pad_xloc < $x2} {
                    if {$pad_xloc < $llx} {set pad_xloc [ expr $pad_xloc + $pitch ] continue } 
                    set flag_loc 1
                    incr total_count
                    if { $use_suffix ==1 } {
                        if { $net_type == "power" } {set n_type POWER} else  {set n_type GROUND}
                        if { $use_group == 1} { puts $fp "$pad_suffix$total_count $pad_xloc $pad_yloc $glayer $n_type $group_name"} else {puts $fp "$pad_suffix$total_count $pad_xloc $pad_yloc $glayer $n_type"}
                    } else {
                        if { $flag_use_net == 1 } {
                            puts $fp "if  { \[ catch {eco add pad -metal $glayer -type $net_type -x $pad_xloc -y $pad_yloc -use_net_name } \] == 0 } {"
                            puts $fp "incr add_count }"
                        } else {
                            puts $fp "if  { \[ catch {eco add pad -metal $glayer -type $net_type -x $pad_xloc -y $pad_yloc } \] == 0 } {" 
                            puts $fp "incr add_count }"
                        }
                    }
                    if { $place_ploc == 0 } {
                            marker add -position $pad_xloc $pad_yloc
                    }
                    set pad_xloc [ expr $pad_xloc + $pitch ]
                }
} else {
                set pad_xloc [expr {$llx + double($wid)/2}]
                set pad_yloc [expr $y1 +$offset]
		set uly [expr {$lly + $len}]
		if {$region_flag == 1} {
                    if {$pad_xloc < $x1 || $pad_xloc > $x2} { continue }
                }
                while {$pad_yloc < $y2} {
                    if { $pad_yloc < $lly } { set pad_yloc [ expr $pad_yloc + $pitch ] continue }
		    set flag_loc 1
                    incr total_count
                    if { $use_suffix ==1 } {
                        if { $net_type == "power" } {set n_type POWER} else  {set n_type GROUND}
                        if { $use_group == 1} {puts $fp "$pad_suffix$total_count $pad_xloc $pad_yloc $glayer $n_type $group_name" } else {puts $fp "$pad_suffix$total_count $pad_xloc $pad_yloc $glayer $n_type" }
                    } else {
                        if { $flag_use_net == 1} {
                            puts $fp "if  { \[catch { eco add pad -metal $glayer -type $net_type -x $pad_xloc -y $pad_yloc -use_net_name } \] == 0 } { incr add_count	}"
                        } else {  
                            puts $fp "if  { \[catch { eco add pad -metal $glayer -type $net_type -x $pad_xloc -y $pad_yloc} \] == 0 } { incr add_count }"
                        }
                    }
                    if { $place_ploc == 0 } {
                        marker add -position $pad_xloc $pad_yloc
                    }
                        set pad_yloc [ expr $pad_yloc + $pitch ]
                }
}
#while loop main
                                        }
if {$flag_loc == 0 } {
puts "ERROR:No wire segments in the region"
return ;
}
if { [ catch { config refresh yes } ] == 0 } {
puts $fp " config refresh yes"
}

close $fp
#close $dbg
if {$place_ploc == 1 } {
 puts "INFO:Started placing plocs in $layer"
  source adsRpt/$file
  puts "INFO:Finished placing plocs in $layer "
   puts  "INFO : Total number of plocs generated : $total_count"
 puts  "INFO :Total number of plocs successfully  placed : $add_count"
  } else {
  puts "INFO :Please check adsRpt/$file for placing plocs"
  }
if { [ catch { config refresh yes } ] == 0 } {
config refresh yes
 }
if { [ catch { config refresh yes } ] == 0 } {
config refresh yes
}
}
#exec rm -rf ./out.txt

