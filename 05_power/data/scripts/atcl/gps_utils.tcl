# Reading the inputs
proc gps_distribute_std_current { args } {
global instance_togglefile 
global instance_loadfile 
global constraintfile 
global clean1 
global designname
global session
unset -nocomplain session 
unset -nocomplain instance_togglefile 
unset -nocomplain instance_loadfile 
unset -nocomplain constraintfile 
unset -nocomplain clean1 
unset -nocomplain designname
global cur_dir
global extra_gsr
set cur_dir [exec pwd]
set state flag
set argv [split $args]
set batch 0
foreach arg $argv {

                switch -- $state {
                        flag {
                                switch -glob -- $arg {

                                        -constraint_file { set state constraint }
					-assign_switching {set state instance_toggle}                                        
					-design_name {set state d_name}                                        
					-cleanup {set state clean_state}
					-add_gsr_settings {set state gsr_settings}
					-batch_mode {set state batchmode}
					-create_inst {set state ci}
					-session {set state sess}	
                                }
                        }

                        constraint {
			global constraintfile 
                        set  constraintfile $arg
			set state flag
                        }
                        instance_toggle {
			global instance_togglefile
                        set  instance_togglefile $arg
                        set state flag
                        }
                        clean_state {
                        set  clean1 $arg
                        set state flag
                        }
                        d_name {
			global designname
                        set  designname $arg
                        set state flag
                        }
                        gsr_settings {
                        set  add_gsr_set $arg
			set state flag
                        }
                        batchmode {
                        set  batch $arg
			set state flag
			}
                        ci {
                        set  createinst $arg
			set state flag
			}
			sess {
			global session
                        set  session $arg
			set state flag
			}

                }

}
if {![info exists session]} {
global session
set session p
}
if {[info exists constraintfile]} {
if {![info exists createinst]} {
set createinst 1
}
if {[info exists designname]} {
string trim $designname
global dn
set dn "/work/$designname"
global cc
#set session "$cc"
#regsub "$dn" $session "" session
#regsub "::" $session "" session
} else {
puts "Please provide the design name to proceed further"
return
}
global cellheight
global cellwidth
global cellname  
global vdd_pin   
global vss_pin   
global metal_vdd 
global metal_vss 
global reg_bbox  
global count_include 
global count_exclude 
global count_cell 
global count_vddpin 
global count_vsspin 
global count_aplcurent 
global count_aplcap 
global count_pwl_file
global count_spec
global frequency 
global pwlfile   
global pwlcell   
global aplfile_current 
global aplfile_cap 
global orientation 
global coverage
unset -nocomplain cellheight
unset -nocomplain cellwidth
unset -nocomplain cellname  
unset -nocomplain vdd_pin   
unset -nocomplain vss_pin   
unset -nocomplain metal_vdd 
unset -nocomplain metal_vss 
unset -nocomplain reg_bbox  
unset -nocomplain count_cell 
unset -nocomplain count_vddpin 
unset -nocomplain count_vsspin 
unset -nocomplain count_pwl_file 
unset -nocomplain count_aplcurent 
unset -nocomplain count_aplcap 
unset -nocomplain count_include 
unset -nocomplain count_exclude 
unset -nocomplain count_spec
unset -nocomplain frequency 
unset -nocomplain pwlfile   
unset -nocomplain pwlcell   
unset -nocomplain aplfile_current 
unset -nocomplain aplfile_cap 
unset -nocomplain orientation 
unset -nocomplain coverage
if {[info exists clean1]} {
if {$clean1 == 1} {
if {[catch { exec rm -rf .clean.tcl}]} {}
set cleanfile [open ".clean.tcl" "w"]
puts $cleanfile "auto_gui_update off"
if { [catch { db query $dn insts -type stdcell -o .duminstfile}] == 0 } {
db foreach del_inst "query $dn insts" {
puts $cleanfile "db delete $del_inst"
}
}
if { [catch { db query $dn regions  -o .duminstfile}] == 0 } {
db foreach del_inst "query $dn regions" {
puts $cleanfile "db delete $del_inst"
}
}
puts $cleanfile "auto_gui_update on"
puts $cleanfile "refresh_gui"
close $cleanfile
source .clean.tcl
}
} else {
if { [catch { db query $dn insts -type stdcell  -o .duminstfile}] == 1 } {
puts "There are instances in the design. Please use -cleanup 1 to proceed further"
return
}
}
 
set input_file [open "$constraintfile" "r"]

global count_spec
set count_spec 0
while  {[gets $input_file read_line]>=0} {
string trim $read_line
	if {$read_line ne " " } {
			if {[regexp -nocase "^#start" $read_line]} {
			incr count_spec 1
			set input_file [read_constraint $input_file]
			}
	}
}
gps_create_instances
global outfile
puts $outfile "auto_gui_update on"
puts $outfile "refresh_gui"
close $outfile
if {$createinst == 1} {
			global session
source ./adsRpt/$dn/$session/.std_create.tcl
}
}
if {[info exists instance_togglefile]} {
global dn
global tgl_spec_count  
global tgl_inst_count  
global tgl_inst  
global tgl_bbox_count
global tgl_bbox
global tgl_cell_count
global no_region
global load_new
global gsc_type 
global slew_rise
global slew_fall
unset -nocomplain gsc_type 
unset -nocomplain slew_rise
unset -nocomplain slew_fall
unset -nocomplain load_new
unset -nocomplain no_region
unset -nocomplain tgl_spec_count  
unset -nocomplain tgl_inst_count  
unset -nocomplain tgl_inst  
unset -nocomplain tgl_bbox_count
unset -nocomplain tgl_bbox
unset -nocomplain tgl_cell_count
global aplfile_cap
pwl_to_apl
power_assign
read_load_file1
puts $extra_gsr "PARA_CALC_POWER 0"
if {[info exists add_gsr_set]} {
if {[file exists $add_gsr_set]} {
set add_gsr_file [open $add_gsr_set "r"]
while {[gets $add_gsr_file read_gsr_file] >= 0} {
string trim $read_gsr_file
puts $extra_gsr $read_gsr_file
}
} else {
puts "Please provide the correct file path for additional gsr settings"
}
}
global stafile_inst
close $stafile_inst
puts $extra_gsr "\}"
close $extra_gsr
global session
global dn
source ./adsRpt/$dn/$session/.extra.gsr
edit_def_proc
global session
if {[catch { exec rm -rf .source_file2}]} {}
set sf [open "./adsRpt/$dn/$session/.source_file2" "w"]
global env

puts $sf "cd $cur_dir/adsRpt/$dn/p/DropAndEM/Dynamic"
if {$batch == 1} {
puts $sf "$env(APACHEROOT)/bin/redhawk -b *tcl &"
} else {
puts $sf "$env(APACHEROOT)/bin/redhawk -f *tcl &"
} 
puts $sf "cd -"
close $sf
exec bash ./adsRpt/$dn/$session/.source_file2 &
} 
}
proc read_constraint { input_file } {
global count_spec
global count_aplcurent 
global count_aplcap 
global count_exclude
global count_include
global include
global exclude
global count_pwl_file
set include($count_spec) 0
set exclude($count_spec) 0
global count_cell_width
global count_cell_height
global count_cell
global count_vsspin
global count_vddpin
set count_vsspin($count_spec) 0
set count_vddpin($count_spec) 0
set count_cell($count_spec) 0
set count_cell_height($count_spec) 0
set count_cell_width($count_spec) 0
set count_aplcurent($count_spec) 0
set count_aplcap($count_spec) 0
set count_exclude($count_spec) 0
set count_include($count_spec) 0
set count_pwl_file($count_spec) 0
set count_e 0
set count_i 0
unset -nocomplain cellheight
unset -nocomplain cellwidth
while  {[gets $input_file read_line]>=0} {
string trim $read_line
	if {$read_line ne " " } {
				
		if {[regexp -nocase "^#end" $read_line]} {
		return $input_file
		}
		if {[regexp -nocase "^cell_name" $read_line ] } {
		regsub  {\[^} $read_line "" read_line
                regsub  {\]^} $read_line "" read_line
                regsub  -all {\{|\}} $read_line "" read_line
                regsub  {:} $read_line "" read_line
                regsub -all -- {[[:space:]]+} $read_line " " read_line
		set read_line [split $read_line]
                regsub  -all -- {\{|\}} $read_line "" read_line
		set count_cel [llength $read_line]
		global cellname
		for {set i 1} {$i<$count_cel} {incr i} {
		incr count_cell($count_spec)
		set cellname($count_spec,$count_cell($count_spec)) [lindex $read_line $i]
		
		}
		}
		if {[regexp -nocase "^cell_height" $read_line ] } {
		regsub  {\[^} $read_line " " read_line
                regsub  {\]^} $read_line " " read_line
                regsub  {\{|\}} $read_line "" read_line
                regsub  {:} $read_line " " read_line
                regsub -all -- {[[:space:]]+} $read_line " " read_line
		set read_line [split $read_line]
                regsub -all -- {\{|\}} $read_line "" read_line
		set count_celheight [llength $read_line]
		global cellheight
		for {set i 1} {$i<$count_celheight} {incr i} {
		incr count_cell_height($count_spec)
		set cellheight($count_spec,$count_cell_height($count_spec)) [lindex $read_line $i]
		}
		}
		if {[regexp -nocase "^cell_width" $read_line ] } {
		regsub  {\[^} $read_line " " read_line
                regsub  {\]^} $read_line " " read_line
                regsub  {\{|\}} $read_line "" read_line
                regsub  {:} $read_line " " read_line
                regsub -all -- {[[:space:]]+} $read_line " " read_line
		set read_line [split $read_line]
                regsub -all --  {\{|\}} $read_line "" read_line
		global cellwidth
		set count_celwidth [llength $read_line]
		for {set i 1} {$i<$count_celwidth} {incr i} {
		incr count_cell_width($count_spec)
		set cellwidth($count_spec,$count_cell_width($count_spec)) [lindex $read_line $i]
		}
		}
		if {[regexp -nocase "^pwl" $read_line ] } {
		regsub  {\[^} $read_line " " read_line
                regsub  {\]^} $read_line " " read_line
                regsub -all -- {[[:space:]]+} $read_line " " read_line
		set read_line [split $read_line]
                regsub  -all -- {\{|\}} $read_line "" read_line
		global pwlfile
		global count_pwl_file
		global pwlcell
		incr count_pwl_file($count_spec)
		set pwlfile($count_spec,$count_pwl_file($count_spec)) [lindex $read_line 2]

		set pwlcell($count_spec,$count_pwl_file($count_spec)) [lindex $read_line 1]
		}
		if {[regexp -nocase "^frequency" $read_line ] } {
		regsub  {\[^} $read_line " " read_line
                regsub  {\]^} $read_line " " read_line
                regsub -all -- {[[:space:]]+} $read_line " " read_line
		set read_line [split $read_line]
                regsub  -all -- {\{|\}} $read_line "" read_line
		global frequency
		set frequency($count_spec) [lindex $read_line 1]
		}
		if {[regexp -nocase "^vdd_pin" $read_line ] } {
		regsub  {\[^} $read_line " " read_line
                regsub  {\]^} $read_line " " read_line
                regsub  {\{|\}} $read_line "" read_line
                regsub  {:} $read_line " " read_line
                regsub  -all {,} $read_line " " read_line
                regsub -all -- {[[:space:]]+} $read_line " " read_line
		set read_line [split $read_line]
                regsub  -all -- {\{|\}} $read_line "" read_line
		global vdd_pin
		set count_vdd_pin1 [llength $read_line]
		global metal_vdd
		for {set i 1} {$i<$count_vdd_pin1} {incr i 2} { 
		incr count_vddpin($count_spec) 
		set vdd_pin($count_spec,$count_vddpin($count_spec)) [lindex $read_line $i]
		set metal_vdd($count_spec,$count_vddpin($count_spec)) [lindex $read_line [expr {$i+1}]]
		}
		}
		
		if {[regexp -nocase "^vss_pin" $read_line ] } {
		regsub  {\[^} $read_line " " read_line
                regsub  {\]^} $read_line " " read_line
                regsub  {\{|\}} $read_line "" read_line
                regsub  {:} $read_line " " read_line
                regsub -all -- {,} $read_line " " read_line
                regsub -all -- {[[:space:]]+} $read_line " " read_line
                regsub  {\{|\}} $read_line "" read_line
		set read_line [split $read_line]
                regsub  -all -- {\{|\}} $read_line "" read_line
		global vss_pin
		set count_vss_pin1 [llength $read_line]
		global metal_vss
		for {set i 1} {$i<$count_vss_pin1} {incr i 2} { 
		incr count_vsspin($count_spec) 
		set vss_pin($count_spec,$count_vsspin($count_spec)) [lindex $read_line $i]
		set metal_vss($count_spec,$count_vsspin($count_spec)) [lindex $read_line [expr {$i+1}]]
		}
		}
		if {[regexp -nocase "^apl_current" $read_line ] } {
		regsub  {\[^} $read_line " " read_line
                regsub  {\]^} $read_line " " read_line
                regsub -all -- {[[:space:]]+} $read_line " " read_line
		set read_line [split $read_line]
                regsub  -all -- {\{|\}} $read_line "" read_line
		global aplfile_current
		set count_aplfile_current [llength $read_line]
		for {set i 1} {$i<$count_aplfile_current} {incr i} {
		incr count_aplcurent($count_spec)
		global cur_dir
		set aplfile_current($count_spec,$count_aplcurent($count_spec)) "[lindex $read_line 1]"
		if {![regexp $cur_dir $aplfile_current($count_spec,$count_aplcurent($count_spec))]} {
			set aplfile_current($count_spec,$count_aplcurent($count_spec)) "$cur_dir/$aplfile_current($count_spec,$count_aplcurent($count_spec))"
		}
		}
		}
		if {[regexp -nocase "^apl_cap" $read_line ] } {
		regsub  {\[^} $read_line " " read_line
                regsub  {\]^} $read_line " " read_line
                regsub -all -- {[[:space:]]+} $read_line " " read_line
		global aplfile_cap
		set read_line [split $read_line]
                regsub  -all -- {\{|\}} $read_line "" read_line
		set count_aplfile_cap [llength $read_line]
		for {set i 1} {$i<$count_aplfile_cap} {incr i} {
		incr count_aplcap($count_spec)
		set aplfile_cap($count_spec,$count_aplcap($count_spec)) [lindex $read_line 1]
		if {![regexp  $cur_dir$aplfile_cap($count_spec,$count_aplcap($count_spec))]} {
			set aplfile_cap($count_spec,$count_aplcap($count_spec)) "$cur_dir/$aplfile_cap($count_spec,$count_aplcap($count_spec))"
		}
		}
		}
		if {[regexp -nocase "^orientation" $read_line ] } {
		regsub  {\[^} $read_line " " read_line
                regsub  {\]^} $read_line " " read_line
                regsub -all -- {[[:space:]]+} $read_line " " read_line
		set read_line [split $read_line]
                regsub  -all -- {\{|\}} $read_line "" read_line
		global orientation
		set orientation($count_spec) [lindex $read_line 1]
		}
		if {[regexp -nocase "^coverage" $read_line ] } {
		regsub  {\[^} $read_line " " read_line
                regsub  {\]^} $read_line " " read_line
                regsub -all -- {[[:space:]]+} $read_line " " read_line
		set read_line [split $read_line]
		global coverage
		set coverage($count_spec) [lindex $read_line 1]
		}
		if {[regexp -nocase "^exclude" $read_line ] } {
		regsub  {\[^} $read_line " " read_line
                regsub  {\]^} $read_line " " read_line
                regsub -all -- {[[:space:]]+} $read_line " " read_line
		set read_line [split $read_line]
                regsub  -all -- {\{|\}} $read_line "" read_line
		global reg_bbox
		set reg_bbox($count_spec,$count_e,0) "[lindex $read_line 1] [lindex $read_line 2] [lindex $read_line 3]  [lindex $read_line 4]"
		incr count_e
		set exclude($count_spec) 1
		set count_exclude($count_spec) $count_e
		}
		if {[regexp -nocase "^include" $read_line ] } {
		regsub  {\[^} $read_line " " read_line
                regsub  {\]^} $read_line " " read_line
                regsub -all -- {[[:space:]]+} $read_line " " read_line
		set read_line [split $read_line]
                regsub  -all -- {\{|\}} $read_line "" read_line
		global reg_bbox
		set reg_bbox($count_spec,$count_i,1) "[lindex $read_line 1] [lindex $read_line 2] [lindex $read_line 3]  [lindex $read_line 4]"
		incr count_i
		set include($count_spec) 1
		set count_include($count_spec) $count_i
		}
			
	}
	
	}
}
proc create_lef {count i} {
global cellname
global cellheight
global  cellwidth
global vdd_pin
global vss_pin
global metal_vdd
global metal_vss
global outfile2
global cur_dir
global session
global dn
if {[catch { exec rm -rf ./adsRpt/$dn/$session/.$cellname($count,$i).lef}]} {}
set lef [open "./adsRpt/$dn/$session/.$cellname($count,$i).lef" "w"]
puts $outfile2 "data read lefs {$cur_dir/adsRpt/$dn/$session/.$cellname($count,$i).lef}"
puts $lef "VERSION 5.2 ;\nNAMESCASESENSITIVE ON ;\nDIVIDERCHAR \"/\" ;\nBUSBITCHARS \"[]\" ;\n"
puts $lef "UNITS\n    DATABASE MICRONS 1000 ;\nEND UNITS\n\n"
puts $lef "MACRO $cellname($count,$i)\n  CLASS CORE ;\n  ORIGIN 0.00 0.00 ;\n  FOREIGN $cellname($count,$i) 0.00 0.00 ;\n  SYMMETRY x y ; SITE core ;\n  SIZE $cellwidth($count,$i) BY $cellheight($count,$i) ;"
puts $lef "  PIN i\n    DIRECTION INPUT ;\n  END i"
puts $lef "  PIN o\n    DIRECTION OUTPUT ;\n  END o"
set pin_height "[expr {$cellheight($count,$i)*0.01}]"
puts $lef "  PIN $vdd_pin($count,$i)\n    SHAPE ABUTMENT ;\n    USE POWER ;\n    PORT\n      LAYER $metal_vdd($count,$i) ;\n      RECT 0 [expr {$cellheight($count,$i)-$pin_height}] $cellwidth($count,$i) $cellheight($count,$i) ;\n    END\n  END $vdd_pin($count,$i)"
puts $lef "  PIN $vss_pin($count,$i)\n    SHAPE ABUTMENT ;\n    USE GROUND ;\n    PORT\n      LAYER $metal_vss($count,$i) ;\n      RECT 0 0 $cellwidth($count,$i) $pin_height ;\n    END\n  END $vss_pin($count,$i)"
puts $lef "END $cellname($count,$i)"
puts $lef "END LIBRARY"
close $lef
}
proc gps_create_instances {} {
global count_spec
global count_vddpin 
global count_vsspin 
global coverage
global orientation
global cellname
global cellheight
global cellwidth
global count_exclude
global count_include
global include
global exclude
global reg_bbox
global vdd_pin
global vss_pin
global dn
global session
global count_orient
global orient
global x1_exc
global x2_exc
global y1_exc
global y2_exc
global region_create
global count_cell
global count_cell_width
global count_cell_height
global outfile
global outfile2
if {[catch { exec rm -rf ./adsRpt/$dn/$session/.std_create.tcl}]} {}
if {[catch { exec rm -rf ./adsRpt/$dn/$session/.read_lefs.tcl}]} {}
set outfile [open "./adsRpt/$dn/$session/.std_create.tcl" "w"]
set outfile2 [open "./adsRpt/$dn/$session/.read_lefs.tcl" "w"]
puts $outfile "auto_gui_update off"

for {set count 1} {$count <= $count_spec} {incr count} {

	set tot_width($count) 0
	if {![info exists orientation($count)]}	{
	set orientation($count) N
	}
	if {![info exists coverage($count)]} {
	set coverage($count) 100
	}
	set tot_height($count) 0
	if {$count_cell($count) > 0} {
	set countcell $count_cell($count)
	} else {
	if {$count_cell_width($count)> 0 && $count_cell_height($count) > 0} {
	if {$count_cell_width($count) == $count_cell_height($count)} {
	set countcell $count_cell_width($count)
	} else { 
	puts "Please provide cell height and cel width in same number"
	return
	}
	} else {
	puts "Please provide cell information"
	return
	}
	}
	if {$count_vddpin($count) != $count_cell($count) || $count_vsspin($count) != $count_cell($count) } {
	puts "Please provide the current number of vdd/vss pins and the corresponding metal layers"
	return
	}
	for {set i 1} {$i<=$countcell} {incr i} {
	if { [info exists cellheight($count,$i)] && [info exists cellwidth($count,$i)]} {
	if {![info exists cellname($count,$i)]} {
	puts "Please Provide the cell information for $count spec"
	return
	}
	set region_create($count) 1
	create_lef $count $i
        } elseif {![info exists cellheight($count,$i)] || ![info exists cellwidth($count,$i)]} {
	set region_create($count) 0
	set cellheight($count,$i) "[db query /work/$cellname($count,$i) height]"
	set cellwidth($count,$i) "[db query /work/$cellname($count,$i) width]"
	set cellheight($count,$i) [format %0.3f $cellheight($count,$i)]
	set cellwidth($count,$i) [format %0.3f $cellwidth($count,$i)]
	}
	set tot_width($count) [expr {$cellwidth($count,$i) + $tot_width($count)}] 
	if {$tot_height($count) < $cellheight($count,$i) } {	
	set tot_height($count) $cellheight($count,$i)
	}
        }
 
	}
	close $outfile2
	source ./adsRpt/$dn/$session/.read_lefs.tcl
for {set count 1} {$count <= $count_spec} {incr count} {
		
	global fullwidth
	global fullheight
	set fullheight "[db query $dn height]"
	set fullwidth "[db query $dn width]"
	set fullheight [format %0.3f $fullheight]
	set fullwidth [format %0.3f $fullwidth]
	if {  $include($count) == 1  } {
	set count_region $count_include($count)
	set inc 1
	} elseif {  $exclude($count) == 1 } {
	set count_region $count_exclude($count)
	set inc 0
	} else { 
	set inc 2
	set count_region 1
	set reg_bbox($count,0,2) "[db query $dn bbox]"
	}
	string trim $orientation($count)
	if { $orientation($count) eq "N" } {
	set orient(0) N
	set orient(1) FS 
	} elseif {$orientation($count) eq "S"} {
	set orient(0) S
	set orient(1) FN 
	}
	if {[info exists count_region]} {
	set r_c 1
	for {set c_f 0} {$c_f < $count_region} {incr c_f} {
	set count_orient 0
	if { $inc == 1 || $inc == 2  } {
		
	set region_bbox($count,$c_f) $reg_bbox($count,$c_f,$inc)		
	regsub -all {\{|\}} $region_bbox($count,$c_f) "" region_bbox($count,$c_f)
	string trim $region_bbox($count,$c_f)
	split $region_bbox($count,$c_f)
	regsub -all {\{|\}} $region_bbox($count,$c_f) " " region_bbox($count,$c_f)
	set x1 [lindex $region_bbox($count,$c_f) 0]
	regsub -all {\{|\}} $x1 " " x1
	set x1 [format %0.3f $x1]
	set y1 [lindex $region_bbox($count,$c_f) 1]
	set y1 [format %0.3f $y1]
	set x2 [lindex $region_bbox($count,$c_f) 2]
	set x2 [format %0.3f $x2]
	set y2 [lindex $region_bbox($count,$c_f) 3]
	regsub -all {\{|\}} $y2 " " y2
	set y2 [format %0.3f $y2]
	set tot_length [expr {$x2-$x1}]
	set cove_per [expr {$coverage($count)*0.01}]
	set uncove_per [expr {1-$cove_per}]
	set ava_length [expr {$cove_per*$tot_length}]
	set uncover_length [expr {$uncove_per*$tot_length}]
	set ava_inst [expr {$ava_length/$tot_width($count)}]
	global space_req
	set ava_inst  [format %0.3f $ava_inst]
	#if { [expr ($ava_inst - int($ava_inst))] < 0.5} {
	#set spaces_req [expr floor($ava_inst)-1]
	#} else {
	#set spaces_req [expr ceil($ava_inst)-1]
	#}
	set spaces_req [expr ceil($ava_inst)-1]
	set space_req [expr $uncover_length/$spaces_req]
	 
	for {set i $y1 } { $i <= [expr {$y2-$tot_height($count)}] } { set i [expr {$i+$tot_height($count)} ]} {
		set c_c 1
		for {set j $x1 } {$j<= [expr {$x2-$tot_width($count)}] } {set j [expr {$j+$tot_width($count)+$space_req}]} {
		global instance_org_x
		global instance_org_y
		set j_cell $j
		for {set i_cell 1} {$i_cell<=$count_cell($count)} {incr i_cell} {
		set instance_name "$dn/inst_$cellname($count,$i_cell)\_$i_cell\_$r_c\_$c_c\_$count" 
		set instance_org_x($instance_name) "$j_cell" 		
		set instance_org_y($instance_name) "$i" 		
		puts $outfile "db create inst $dn -name inst_$cellname($count,$i_cell)\_$i_cell\_$r_c\_$c_c\_$count -master /work/$cellname($count,$i_cell) -loc { $j_cell $i } -orient $orient($count_orient)"
		set count_1 [expr {$count-1}]
		set j_cell [expr $j_cell+$cellwidth($count,$i_cell)]
		}
		incr c_c 
		set j [format %0.3f $j]
		}
	set last_j $j
	for {set i_lc 1} {$i_lc<=$count_cell($count)} {incr i_lc} {
	if {$last_j<= [expr {$x2-$cellwidth($count,$i_lc)}]} {
		set instance_name "$dn/inst_$cellname($count,$i_lc)\_$i_cell\_$r_c\_$c_c\_$count" 
		set instance_org_x($instance_name) "$j" 		
		set instance_org_y($instance_name) "$i" 		
		puts $outfile "db create inst $dn -name inst_$cellname($count,$i_lc)\_$i_cell\_$r_c\_$c_c\_$count -master /work/$cellname($count,$i_lc) -loc { $last_j $i } -orient $orient($count_orient)"
	incr c_c 
	set last_j [expr {$last_j+$cellwidth($count,$i_lc)}]
	
	}	
	}
	incr r_c 
	set count_orient [expr {$count_orient ? 0 : 1} ]
	set i [format %0.3f $i]
	}
	} else {
	set region_bbox($count,$c_f) $reg_bbox($count,$c_f,$inc)		
	regsub -all {\{|\}} $region_bbox($count,$c_f) "" region_bbox($count,$c_f)
	string trim $region_bbox($count,$c_f)
	split $region_bbox($count,$c_f)
	set x1_exc($c_f) [lindex $region_bbox($count,$c_f) 0]
	regsub -all {\{|\}} $x1_exc($c_f) " " x1_exc($c_f)
	set x1_exc($c_f) [format %0.3f $x1_exc($c_f)]
	set y1_exc($c_f) [lindex $region_bbox($count,$c_f) 1]
	set y1_exc($c_f) [format %0.3f $y1_exc($c_f)]
	set x2_exc($c_f) [lindex $region_bbox($count,$c_f) 2]
	set x2_exc($c_f) [format %0.3f $x2_exc($c_f)]
	set y2_exc($c_f) [lindex $region_bbox($count,$c_f) 3]
	regsub -all {\{|\}} $y2_exc($c_f) " " y2_exc($c_f)
	set y2_exc($c_f) [format %0.3f $y2_exc($c_f)]
	}
	}
	exclude_region_proc $count
	}
}
db foreach net1 "query $dn nets -type power" {
regsub "$dn/net:" $net1 "" name_net1
puts -nonewline $outfile "db edit $net1 -name $name_net1 -logical_conn {"
for {set count 1} {$count <= $count_spec} {incr count} {
for {set i 1} {$i<=$count_cell($count)} {incr i} {
puts -nonewline $outfile "{*$cellname($count,$i)*_$count $vdd_pin($count,$i)} "
}
}
puts  $outfile "}"
}
db foreach net2 "query $dn nets -type ground" {
regsub "$dn/net:" $net2 "" name_net2 
puts -nonewline $outfile "db edit $net2 -name $name_net2 -logical_conn {"
for {set count 1} {$count <= $count_spec} {incr count} {
for {set i 1} {$i<=$count_cell($count)} {incr i} {
puts -nonewline $outfile "{*$cellname($count,$i)*_$count $vss_pin($count,$i)} "
}
}
puts  $outfile "}"
}
}
 
proc exclude_region_proc {c1} {
global count_cell
global coverage
global fullwidth
global fullheight
global region_create
global count_spec
global orientation
global cellname
global cellheight
global cellwidth
global count_exclude
global count_include
global include
global exclude
global reg_bbox
global dn
global count_orient
global orient
global x1_exc
global x2_exc
global y1_exc
global y2_exc
global space_req
global outfile
set full_bbox [db query $dn bbox]
regsub -all {\{|\}} $full_bbox " " full_bbox
set l_x [lindex $full_bbox 0]
set l_y [lindex $full_bbox 1]
if { [info exists count_exclude] } {
if { $count_exclude($c1) > 0} {
set tot_height($c1) 0
set tot_width($c1) 0
set small_width $fullwidth
for {set i 1} {$i<=$count_cell($c1)} {incr i} {
set tot_width($c1) [expr {$cellwidth($c1,$i)+$tot_width($c1)}]
if {$small_width > $cellwidth($c1,$i) } {	
set small_width $cellwidth($c1,$i)
}
if {$tot_height($c1) < $cellheight($c1,$i) } {	
set tot_height($c1) $cellheight($c1,$i)
}
} 
	set exclude_area 0	
	for {set ip 0} {$ip < $count_exclude($c1)} {incr ip} {
	set exclude_area1 [expr {[expr {$x2_exc($ip)-$x1_exc($ip)}]*[expr {$y2_exc($ip)-$y1_exc($ip)}]}]
	set exclude_area [expr {$exclude_area + $exclude_area1}]
	}
	set tot_cell_area [expr {$tot_width($c1)*$tot_height($c1)}]
	set tot_area [expr {[expr {$fullwidth*$fullheight}]-$exclude_area}]
	set cove_per [expr {$coverage($c1)*0.01}]
	set uncove_per [expr {1-$cove_per}]
	set ava_area [expr {$cove_per*$tot_area}]
	set uncover_area [expr {$uncove_per*$tot_area}]
	
	set ava_inst [expr {$ava_area/$tot_cell_area}]

	global space_req
	if { [expr ($ava_inst - int($ava_inst))] < 0.5} {
	set spaces_req [expr floor($ava_inst)-1]
	} else {
	set spaces_req [expr ceil($ava_inst)-1]
	}
	set space_req [expr $uncover_area/$spaces_req]
	set space_req [expr $space_req/$tot_height($c1)] 
		set r_c 1
	set f_c_h [expr {$fullheight-$tot_height($c1)}]
	set f_c_w [expr {$fullwidth-$tot_width($c1)}]
	for {set i_e $l_y } { $i_e <= $f_c_h } { set i_e [expr {$i_e+$tot_height($c1)}] } {
		set c_c 1
		for {set j_e $l_x } {$j_e<= $f_c_w } {set j_e [expr {$j_e+$tot_width($c1)+$space_req}] } {
		global instance_org_x
		global instance_org_y
		set j_cell $j_e
		for {set i_cell 1} {$i_cell<=$count_cell($c1)} {incr i_cell} {
		set exc($c1) 0
		for {set ip 0} {$ip < $count_exclude($c1)} {incr ip} {
		set x1 $x1_exc($ip)
		set y1 $y1_exc($ip)
		set x2 $x2_exc($ip)
		set y2 $y2_exc($ip)
		set y1_c [expr $y1-$cellheight($c1,$i_cell)]
		set x1_c [expr $x1-$cellwidth($c1,$i_cell)]
		if { $i_e > $y1_c && $j_cell > $x1_c && $j_cell <= $x2  && $i_e <= $y2 } {
		incr exc($c1) 
		}
		
		}
		if {$exc($c1) == 0} {
		set instance_name "$dn/inst_$cellname($c1,$i_cell)\_$i_cell\_$r_c\_$c_c\_$c1" 
		set instance_org_x($instance_name) "$j_cell" 		
		set instance_org_y($instance_name) "$i_e" 		
		puts $outfile "db create inst $dn -name inst_$cellname($c1,$i_cell)\_$i_cell\_$r_c\_$c_c\_$c1 -master /work/$cellname($c1,$i_cell) -loc { $j_cell $i_e } -orient $orient($count_orient)"
		flush $outfile
		set j_cell [expr {$j_cell+$cellwidth($c1,$i_cell)}]
		}
		}
		incr c_c
		set j_e [format %0.3f $j_e]
		}
	set last_j $j_e
	for {set i_lc 1} {$i_lc<=$count_cell($c1)} {incr i_lc} {
		if {$last_j < $f_c_w} {
		set exc($c1) 0

		for {set ip 0} {$ip < $count_exclude($c1)} {incr ip} {
		set x1 $x1_exc($ip)
		set y1 $y1_exc($ip)
		set x2 $x2_exc($ip)
		set y2 $y2_exc($ip)
		set y1_c [expr $y1-$cellheight($c1,$i_lc)]
		set x1_c [expr $x1-$cellwidth($c1,$i_lc)]
		if { $i_e > $y1_c && $last_j > $x1_c && $last_j <= $x2  && $i_e <= $y2 } {
		incr exc($c1) 
		}
		}
		if {$exc($c1) == 0} {
		global instance_org_x
		global instance_org_y
		set j_cell $last_j
		set instance_name "$dn/inst_$cellname($c1,$i_lc)\_$i_cell\_$r_c\_$c_c\_$c1" 
		set instance_org_x($instance_name) "$last_j" 		
		set instance_org_y($instance_name) "$i_e" 		
		puts $outfile "db create inst $dn -name inst_$cellname($c1,$i_lc)\_$i_cell\_$r_c\_$c_c\_$c1 -master /work/$cellname($c1,$i_lc) -loc { $last_j $i_e } -orient $orient($count_orient)"
		flush $outfile
		set last_j [expr {$last_j+$cellwidth($c1,$i_lc)}]
		}
		incr c_c
		set last_j [format %0.3f $last_j]
	}
	}	
		incr r_c 
		set i_e [format %0.3f $i_e]
		set count_orient [expr {$count_orient ? 0 : 1} ]
		} 
	}
       	}

}

proc pwl_to_apl {} {
global cur_dir
global designname
global cellname
global count_cell
global count_pwl_file
global env
global pwlfile
global pwlcell
global pwlaplfile_current
global vdd_pin
global vss_pin
global count_spec
global count_pwlaplcurent
global session
global dn
if {[catch { exec rm -rf ./adsRpt/$dn/$session/.pwltoapl}]} {}
set pwl_apl [open "./adsRpt/$dn/$session/.pwltoapl" "w"]
for {set count 1} {$count <= $count_spec} {incr count} {
set count_pwlaplcurent($count) 0
for {set i 1} {$i<=$count_pwl_file($count)} {incr i} {
	if { [info exists pwlfile($count,$i)] } {
		if { [file exists $pwlfile($count,$i)] } {
		set read_pwl [open "$pwlfile($count,$i)" "r"]
		while {[gets $read_pwl read_line_pwl]>=0} {
		set words [split $read_line_pwl " "]

     		if { [lindex $words 0] == "+" && ![regexp {\)} $read_line_pwl] } {
        	set temp_t2 [lindex $words 1];   
	  	} 
        	if { [lindex $words 1] == "0e-12" } {
        	set t_1 0
        	} elseif {[regexp {\)} $read_line_pwl]} {
        	set t_2 $temp_t2;
        	set duration [expr $t_2-$t_1-0.000000000001]
		}
		}
		close $read_pwl
		if { [catch {db query /work/$pwlcell($count,$i) pins}]== 0} {	
		set vdd_pin_name "[db query /work/$pwlcell($count,$i) pins -type power]"
		split $vdd_pin_name
		set vdd_pin_name [lindex $vdd_pin_name 0]
		global dn
		regsub "/work/$pwlcell($count,$i)/pin:" $vdd_pin_name "" vdd_pin_name 
		set vss_pin_name "[db query /work/$pwlcell($count,$i) pins -type ground]"
		split $vss_pin_name
		set vss_pin_name [lindex $vss_pin_name 0]
		regsub "$dn/$pwlcell($count,$i)/pin:" $vdd_pin_name "" vdd_pin_name 
		set vss_pin_name [lindex $vss_pin_name 0]
		} 
		if {[catch { exec rm -rf ./adsRpt/$dn/$session/.$count\_$pwlcell($count,$i).cfg}]} {}
		set pwl_config [open "./adsRpt/$dn/$session/.$count\_$pwlcell($count,$i).cfg" "w"]
		puts $pwl_config "CELL $cellname($count,$i) \{\nFILENAME \{\n $pwlfile($count,$i) $vdd_pin($count,$i)=1\n\}\n"
		puts $pwl_config "VDD_PIN $vdd_pin($count,$i)\nVSS_PIN $vss_pin($count,$i)\n"
		puts $pwl_config "SIM_TIME \{\nREAD 0 \nWRITE 0\n\}\n"
		puts $pwl_config "DURATION $duration\n\n"
		puts $pwl_config "LEAKAGE 0\n\}"
		close $pwl_config
		incr count_pwlaplcurent($count)
		set pwlaplfile_current($count,$count_pwlaplcurent($count)) "$cur_dir/./adsRpt/$dn/$session/.$count\_$pwlcell($count,$i)\.current"
		puts $pwl_apl "$env(APACHEROOT)/bin/sim2iprof ./adsRpt/$dn/$session/.$count\_$pwlcell($count,$i).cfg -o ./adsRpt/$dn/$session/.$count\_$pwlcell($count,$i)\.current"		
		} else {
		puts "Please provide the valid pwl file for $count spec"
		}

}
}
}
		close $pwl_apl
		exec bash ./adsRpt/$dn/$session/.pwltoapl
}
proc power_assign {} {
global count_spec
global instance_togglefile
global no_region
global cellheight
global cellwidth
global region_create
global frequency
global cur_dir
global cellname
global dn
global session
global metal_vdd
global metal_vss
global aplfile_current
global aplfile_cap
global env
global vdd_pin
global vss_pin
global extra_gsr
global count_aplcurent 
global count_aplcap 
global count_pwl_file
global count_cell
if {[catch { exec rm -rf ./adsRpt/$dn/$session/.extra.gsr}]} {}
set extra_gsr [open "./adsRpt/$dn/$session/.extra.gsr" "w"]
puts $extra_gsr "config set additional_gsr_settings \{\n"
puts $extra_gsr "BPA_CONN_MARGIN 0.2"
puts $extra_gsr "GSC_FILE $cur_dir/adsRpt/$dn/$session/.INSTANCE_TOGGLE_file_inst"
puts $extra_gsr "APL_FILES \{ "
 	if {[info exists instance_togglefile ]} {
		if {[file exists $instance_togglefile]} {
		global trfile_inst
		global tglfile
		if {[catch { exec rm -rf ./adsRpt/$dn/$session/.INSTANCE_TOGGLE_file_inst}]} {}
		set trfile_inst [open "./adsRpt/$dn/$session/.INSTANCE_TOGGLE_file_inst" "w"]
		puts $trfile_inst "* DISABLE"
		set tglfile [open "$instance_togglefile" "r"]
		global tgl_spec_count
		set tgl_spec_count 0
		while { [gets $tglfile read_tglfile] >= 0 } {
		string trim $read_tglfile
			if {[regexp -nocase "^#start" $read_tglfile] } {
			incr tgl_spec_count	
			global tgl_inst_count
			global tgl_bbox_count
			global tgl_cell_count
			set tgl_inst_count($tgl_spec_count) 0
			set tgl_cell_count($tgl_spec_count) 0
			set tgl_bbox_count($tgl_spec_count) 0
			set tglfile [read_tgl_spec ]
			}  
		}		
		
		assign_toggle_proc
		close $trfile_inst
		close $tglfile
} else {
	puts "Please point to the correct Switching file"
	}
	
}
for {set count 1} {$count <= $count_spec} {incr count} {
global count_cell

for {set i 1} {$i<=$count_aplcurent($count)} {incr i} {
	if { [info exists aplfile_current($count,$i)] } {
	string trim $aplfile_current($count,$i)
 	puts $extra_gsr "$aplfile_current($count,$i) current"		
	}	 	
}
for {set i 1} {$i<=$count_aplcap($count)} {incr i} {
	if { [info exists aplfile_cap($count,$i)] } {
	string trim $aplfile_cap($count,$i)
 	puts $extra_gsr "$aplfile_cap($count,$i) cap"		
	}	 	
}
global count_pwlaplcurent
global pwlaplfile_current
for {set i 1} {$i<=$count_pwlaplcurent($count)} {incr i} {
	if { [info exists pwlaplfile_current($count,$i)] } {
	string trim $pwlaplfile_current($count,$i)
 	puts $extra_gsr "$pwlaplfile_current($count,$i) current"		
	}	 	
}
}
puts $extra_gsr "\}"
puts $extra_gsr "USER_STA_FILE $cur_dir/./adsRpt/$dn/$session/.user_sta_file_inst"

global stafile_inst
if {[catch { exec rm -rf ./adsRpt/$dn/$session/.user_sta_file_inst}]} {}
set stafile_inst [open "./adsRpt/$dn/$session/.user_sta_file_inst" "w"]	

for {set count 1} {$count <= $count_spec} {incr count} {

for {set i 1} {$i<=$count_cell($count)} {incr i} {
	db foreach instance_list "query $dn insts -master /work/$cellname($count,$i)" {
	regsub "$dn/" $instance_list "" instance_list1
	puts $stafile_inst "$instance_list1 TW 0 0 $frequency($count)"
	}
	}
	}
	
}
proc read_tgl_spec {} {
global tgl_spec_count
global tglfile
global tgl_inst_count
global tgl_bbox_count
global tgl_cell_count
set tgl_inst_count($tgl_spec_count) 0
set tgl_cell_count($tgl_spec_count) 0
set tgl_bbox_count($tgl_spec_count) 0
	 	  while {[gets $tglfile read_tglfile] >= 0} {
			string trim $read_tglfile
			if {[regexp -nocase "^#end spec" $read_tglfile]} {
			return $tglfile
			} else {
			if {[regexp -nocase "^instances" $read_tglfile] } {
			set tglfile [read_toggle_file $tglfile 1]
			}
			if {[regexp -nocase "^cells" $read_tglfile] } {
			set tglfile [read_toggle_file $tglfile 2]
			}
			if {[regexp -nocase "^bbox" $read_tglfile] } {
			set tglfile [read_toggle_file $tglfile 3]
			}
			if {[regexp -nocase "^gsc_type" $read_tglfile] } {
			global gsc_type
			set  gsc_type($tgl_spec_count)  "[lindex $read_tglfile 1]"
			}
				
		  }
		}
}
proc read_toggle_file { tr_file type} {
global tgl_inst_count
global tgl_bbox_count
global tgl_cell_count
global tgl_spec_count
if {$type == 1} {
	while { [gets $tr_file read_tr_file ] >= 0} {
	if {[regexp "^end instances" $read_tr_file]} {
	return $tr_file
	} else {

	string trim $read_tr_file
	incr tgl_inst_count($tgl_spec_count)
	global tgl_inst
	set tgl_inst($tgl_spec_count,$tgl_inst_count($tgl_spec_count)) $read_tr_file
	}
	}
}

if {$type == 2} {
	while { [gets $tr_file read_tr_file ] >= 0} {
	if {[regexp "^end cell" $read_tr_file]} {
	return $tr_file
	} else {
	string trim $read_tr_file
	incr tgl_cell_count($tgl_spec_count)
		global cell_tr
	set cell_tr($tgl_spec_count,$tgl_cell_count($tgl_spec_count)) [lindex $read_tr_file 0]

	}
	}
}
 
if {$type == 3} {
	while { [gets $tr_file read_tr_file ] >= 0} {
	if {[regexp "^end bbox" $read_tr_file]} {
	return $tr_file
	} else {
	string trim $read_tr_file
	incr tgl_bbox_count($tgl_spec_count)
global tgl_bbox
	set tgl_bbox($tgl_spec_count,$tgl_bbox_count($tgl_spec_count)) $read_tr_file  
	}
	}
}
return $tr_file
}

proc assign_toggle_proc {} {
global gsc_type
global instance_org_x
global instance_org_y
global dn
global tgl_inst_count
global tgl_bbox_count
global tgl_cell_count
global tgl_inst
global cell_tr
global tgl_bbox
global tgl_spec_count
global trfile
global trfile_inst
for {set i 1} {$i<= $tgl_spec_count} {incr i} {
if {$tgl_bbox_count($i) == 0} {
set tgl_bbox_c 1
set tgl_bbox($i,1) "[db query $dn bbox]"
regsub -all {\{|\}} $tgl_bbox($i,1) "" tgl_bbox($i,1)
} else {
set tgl_bbox_c $tgl_bbox_count($i)
}
if {$tgl_cell_count($i) == 0} {
db foreach inst1 "query $dn insts -type stdcell" {
	incr tgl_inst_count($i)
	set tgl_inst($i,$tgl_inst_count($i)) "$inst1"	
	}
db foreach inst1 "query $dn regions" {
	incr tgl_inst_count($i)
	set tgl_inst($i,$tgl_inst_count($i)) "$inst1"	
	}
} else {
for {set ii 1} {$ii <= $tgl_cell_count($i)} {incr ii} {
	db foreach inst1 "query $dn insts -master /work/$cell_tr($i,$ii)" {
	incr tgl_inst_count($i)
	set tgl_inst($i,$tgl_inst_count($i)) "$inst1"	
	}
	}
}
for {set i_c 1} {$i_c <= $tgl_bbox_c} {incr i_c} {
	string trim $tgl_bbox($i,$i_c)
	set x1_tr "[lindex $tgl_bbox($i,$i_c) 0]"
	set y1_tr "[lindex $tgl_bbox($i,$i_c) 1]"
	set x2_tr "[lindex $tgl_bbox($i,$i_c) 2]"
	set y2_tr "[lindex $tgl_bbox($i,$i_c) 3]"
	for {set i_inst 1} {$i_inst <= $tgl_inst_count($i)} {incr i_inst} {
	set instances "$tgl_inst($i,$i_inst)"
	if {$instance_org_x($instances) >= $x1_tr && $instance_org_y($instances) >=$y1_tr && $instance_org_x($instances) <= $x2_tr && $instance_org_y($instances) <=$y2_tr} {
	regsub "$dn/" $instances "" instances1
	if {[info exists gsc_type($i)]} {
	if {[llength $gsc_type($i)]!=0} {
	puts $trfile_inst "$instances1 $gsc_type($i)"
	}
	}
	}
	}

}

}


}

proc read_load_file1 {} {
global count_spec_load
set count_spec_load 0
global instance_togglefile
global loadfile
set loadfile [open "$instance_togglefile" "r"]
while {[gets $loadfile read_loadfile] >= 0} {
                regsub -all -- {[[:space:]]+} $read_loadfile " " read_loadfile
		regsub -all {\{|\}} $read_loadfile "" read_loadfile
			string trim $read_loadfile
			
			if {[regexp -nocase "^#start" $read_loadfile] } {
			incr count_spec_load
		global c_load_bbox
		global c_load_inst
		global c_load_cell
		set c_load_bbox($count_spec_load) 0
		set c_load_inst($count_spec_load) 1
		set c_load_cell($count_spec_load) 0
			set read_loadfile [read_load_file $read_loadfile ]
			}
	}
assign_load_proc
}
proc read_load_file {read_loadfile} {
global loadfile
global count_spec_load
global c_load
set c_load 0
while {[gets $loadfile read_loadfile] >= 0} {
			string trim $read_loadfile
			if {[regexp -nocase "^#end spec" $read_loadfile] } {
			return $read_loadfile			
			} else {
			if {[regexp -nocase "^instances" $read_loadfile] } {
			set read_loadfile [read_load $read_loadfile 1]
			}
			if {[regexp -nocase "^cells" $read_loadfile] } {
			set read_loadfile [read_load $read_loadfile 2]
			}
			if {[regexp -nocase "^bbox" $read_loadfile] } {
			set read_loadfile [read_load $read_loadfile 3]
			}
			if {[regexp -nocase "^load" $read_loadfile] } {
global load_new
			set load_new($count_spec_load) "[lindex $read_loadfile 1]"
			}
			if {[regexp -nocase "^slew" $read_loadfile] } {
global slew_rise 
global slew_fall 
			set slew_rise($count_spec_load) "[lindex $read_loadfile 1]"
			set slew_fall($count_spec_load) "[lindex $read_loadfile 2]"
			}
			}		
		  }
}
proc read_load {read_loadline l_c} {
global count_spec_load
global loadfile
global c_load_bbox
global c_load_inst
global c_load_cell
global count_spec_load
while {[gets $loadfile read_loadline]>=0} {

	string trim $read_loadline
	if {$read_loadline ne " " } {
	if {$l_c == 3} {
		if {[regexp -nocase "^end bbox" $read_loadline]} {
		return $read_loadline
		} else {
                regsub -all -- {[[:space:]]+} $read_loadline " " read_loadline
		regsub -all {\{|\}} $read_loadline "" read_loadline
		incr c_load_bbox($count_spec_load) 
		global l_x1
		global l_y1
		global l_x2
		global l_y2
		set l_x1($count_spec_load,$c_load_bbox($count_spec_load)) [lindex $read_loadline 0]
		set l_y1($count_spec_load,$c_load_bbox($count_spec_load)) [lindex $read_loadline 1]
		set l_x2($count_spec_load,$c_load_bbox($count_spec_load)) [lindex $read_loadline 2]
		set l_y2($count_spec_load,$c_load_bbox($count_spec_load)) [lindex $read_loadline 3]
		}
	}
	if {$l_c == 2} {
		if {[regexp -nocase "^end cells" $read_loadline]} {
		return $read_loadline
		} else {
                regsub -all -- {[[:space:]]+} $read_loadline " " read_loadline
		regsub -all {\{|\}} $read_loadline "" read_loadline
		incr c_load_cell($count_spec_load)
		global celll
		set celll($count_spec_load,$c_load_cell($count_spec_load)) [lindex $read_loadline 0]
		}
	}
	if {$l_c == 1} {
		if {[regexp -nocase "^end instances" $read_loadline]} {
		return $read_loadline
		} else {
                regsub -all -- {[[:space:]]+} $read_loadline " " read_loadline
		regsub -all {\{|\}} $read_loadline "" read_loadline
		global instll
		set instll($count_spec_load,$c_load_inst($count_spec_load)) [lindex $read_loadline 0]
		incr c_load_inst($count_spec_load)
		}
	}
}
}
} 
proc assign_load_proc { } {
global stafile_inst
global slew_rise 
global slew_fall 
global load_new
global instance_org_x
global instance_org_y
global c_load_bbox
global c_load_inst
global c_load_cell
global celll
global l_x1
global l_y1
global l_x2
global l_y2
global count_spec_load
global dn
global extra_gsr
puts $extra_gsr "PRIMARY_OUTPUT_LOAD_CAPS {"
for {set csl $count_spec_load} {$csl >= 1} {set csl [expr {$csl-1}]} {
if {$c_load_bbox($csl) == 0} {
set full_bbox($csl,1) "[db query $dn bbox]"
                regsub -all -- {[[:space:]]+} $full_bbox($csl,1) " " full_bbox($csl,1) 
		regsub -all {\{|\}} $full_bbox($csl,1) " " full_bbox($csl,1)
split $full_bbox($csl,1)
 		set c_load_bbox($csl) 1
		set l_x1($csl,$c_load_bbox($csl)) [lindex $full_bbox($csl,1) 0]
		set l_y1($csl,$c_load_bbox($csl)) [lindex $full_bbox($csl,1) 1]
		set l_x2($csl,$c_load_bbox($csl)) [lindex $full_bbox($csl,1) 2]
		set l_y2($csl,$c_load_bbox($csl)) [lindex $full_bbox($csl,1) 3]	

}
if {$c_load_cell($csl) == 0} {
		
		db foreach instill "query $dn insts -type stdcell" {
		regsub "$dn/" $instill "" instill
		set instll($csl,$c_load_inst($csl)) $instill
		incr c_load_inst($csl)
		}
} else {
	for {set clc 1} {$clc<=$c_load_cell($csl)} {incr clc} {
		db foreach instill "query $dn insts -master /work/$celll($csl,$clc)" {
		regsub "$dn/" $instill "" instill
		set instll($csl,$c_load_inst($csl)) $instill
		incr c_load_inst($csl)
		}
	}

}
#for {set i 1} {$i<=$c_load_bbox($csl)} {incr i} 
#for {set j 1} {$j<$c_load_inst($csl)} {incr j} 
for {set i $c_load_bbox($csl)} {$i>=1} {set i [expr {$i-1}]} {
for {set j [expr {$c_load_inst($csl)-1}]} {$j>= 1} {set j [expr {$j-1}]} {
set inst_l $instll($csl,$j)
string trim $inst_l
if {$instance_org_x($dn/$inst_l) >= $l_x1($csl,$i) && $instance_org_y($dn/$inst_l) >= $l_y1($csl,$i) && $instance_org_x($dn/$inst_l) <= $l_x2($csl,$i) && $instance_org_y($dn/$inst_l) <= $l_y2($csl,$i)} {
if {[info exists load_new($csl)]} {
puts $extra_gsr "net_$inst_l $load_new($csl)" 
}
if {[info exists slew_rise($csl)] && [info exists slew_fall($csl)]} {
puts $stafile_inst "$inst_l SL $slew_rise($csl) $slew_fall($csl)"
}
}
} 
}

}
puts $extra_gsr "}"
} 
proc edit_def_proc {} {
global dn
global cur_dir
global designname
global session
if {[catch { exec rm -rf $cur_dir/adsRpt/$dn/$session/.netfile}]} {}
set netfile [open "$cur_dir/adsRpt/$dn/$session/.netfile" "w"]
puts $netfile "NETS 123 ;" 
set c 0
set start 0
puts $netfile "\n"
set edit_def 0
db foreach insta "query $dn insts -type stdcell" {
set edit_def 1
if {$start == 0} {

set start 1
set c 1
regsub "$dn/" $insta "" inst_a
set instl($c) $inst_a
set cellnamea($instl($c)) "[db query $insta master]"
set ip_name($instl($c)) "[db query $cellnamea($instl($c)) pins -type signal -dir input]"
set op_name($instl($c)) "[db query $cellnamea($instl($c)) pins -type signal -dir output]"
split $ip_name($instl($c))
split $op_name($instl($c))
set ip_p_n($instl($c)) [lindex $ip_name($instl($c)) 0]
regsub "$cellnamea($instl($c))/pin:" $ip_p_n($instl($c)) "" ip_p_n($instl($c)) 
set op_p_n($instl($c)) [lindex $op_name($instl($c)) 0]
regsub "$cellnamea($instl($c))/pin:" $op_p_n($instl($c)) "" op_p_n($instl($c)) 
set first_inst $inst_a 
} else {
set c [expr {$c ? 0 : 1} ]
regsub "$dn/" $insta "" inst_a
set instl($c) $inst_a
set last_inst $inst_a
set cellnamea($instl($c)) "[db query $insta master]"
set ip_name($instl($c)) "[db query $cellnamea($instl($c)) pins -type signal -dir input]"
set op_name($instl($c)) "[db query $cellnamea($instl($c)) pins -type signal -dir output]"
split $ip_name($instl($c))
split $op_name($instl($c))
set ip_p_n($instl($c)) [lindex $ip_name($instl($c)) 0]
regsub "$cellnamea($instl($c))/pin:" $ip_p_n($instl($c)) "" ip_p_n($instl($c)) 
set op_p_n($instl($c)) [lindex $op_name($instl($c)) 0]
regsub "$cellnamea($instl($c))/pin:" $op_p_n($instl($c)) "" op_p_n($instl($c)) 
set second $c
set first [expr {$c ? 0 : 1}]
puts $netfile "- net_$instl($first) ( $instl($first) $op_p_n($instl($first)) ) ( $instl($second) $ip_p_n($instl($second)) )"
flush $netfile
puts $netfile "  + USE SIGNAL ;"

}
}
if {$edit_def == 1} {
puts $netfile "- net_$last_inst ( $last_inst $op_p_n($last_inst) ) ( $first_inst $ip_p_n($first_inst) )"
puts $netfile "  + USE SIGNAL ;"
puts $netfile "END NETS"
close $netfile
rh perform analysis $dn -dynamic -dump_setup_only
set design_name "$dn"
regsub "/work/" $design_name "" design_name
if {[catch { exec rm -rf ./adsRpt/$dn/$session/.source_file}]} {}
set out1 [open "./adsRpt/$dn/$session/.source_file" "w"]
puts $out1 "sed -i 's/^INCLUDE/#INCLUDE/g' $cur_dir/adsRpt/$dn/$session/DropAndEM/Dynamic/$design_name\.gsr"
puts $out1 "sed -i '/^NETS/,/END NETS/d' $cur_dir/adsRpt/$dn/$session/DropAndEM/Dynamic/$design_name\.def"
puts $out1 "sed -i '/END SPECIALNETS/r adsRpt\/$dn\/$session\/.netfile' $cur_dir/adsRpt/$dn/$session/DropAndEM/Dynamic/$design_name\.def"
close $out1
exec bash ./adsRpt/$dn/$session/.source_file
}
}

proc gps_create_Rampup_setup { args } {
# Start Reading Arguments
set state flag
regsub -all -- {[[:space:]]+} $args " " args
set argv [split $args]
global output_dir
foreach arg $argv {
 	
                switch -- $state {
                        flag {
                                switch -glob -- $arg {
                               
                                        -i { set state input }
                                        -out_dir { set state output }
					
						
                                }
			}	
			
			input {
			set input_constraint_file $arg
			set state flag
			}
			
			output {
			set output_dir $arg
			set state flag
			}
			
					
			
		}
			
}
global spec_count
global Constraint_file
global dynamic_simulation_time
global dynamic_time_step
global spec_name
global power_spec_name
global power_spec_id
global bbox
global cell_type
global master_cell
global area
global Net_Pin_Layer_Domain
global timing_type
global timing_model_type
global capacitance_type
global capacitance_model_type
global sequence_type
global switch_interval_delay
global path_files
global cap_value
global name_cap_res_files
global Net_pin_info
global Net_info
global Pin_info
global Layer_info
global Domain_info
global line
global lines
global extra_gsr
global path_files_count
global name_cap_res_files_count
global Net_Pin_Layer_info_count
global switch_info_count
global switch_cell_info
global path_switch_files
global read_line
global rect
global log
global errorInfo
set log [open "$output_dir/log_file" "w"]
set Constraint_file [open $input_constraint_file "r"]
set spec_count 0
while { [gets $Constraint_file read_line] >= 0 } {
 if { $read_line ne "" } {
	
	if { [ regexp "#GLOBAL_SETTINGS" $read_line ]} {
		set Constraint_file [ read_global_settings_proc $Constraint_file ]
 		}
		
	if { [ regexp "#SPEC_SETTINGS" $read_line ]} {
	incr spec_count	
		set Constraint_file [ read_spec_settings_proc $Constraint_file $spec_count]
 		}
		
	
	}
}	
if { $spec_count == 0 } {
puts "NO SPEC Settings are provided."
puts $log "NO SPEC Settings are provided."
return
}

create_extra_gsr 
}
proc read_global_settings_proc { Constraint_file } {
global dynamic_simulation_time
global dynamic_time_step
global log
while { [gets $Constraint_file read_line] >= 0} {
	
	if { [ regexp "#END_GLOBAL_SETTINGS" $read_line] } {
	break	
	} 
	if { [ regexp "DYNAMIC_SIMULATION_TIME" $read_line]} {
			
		regsub ":" $read_line " " read_line
		regsub  {\[^} $read_line " " read_line
		regsub  {\]^} $read_line " " read_line
		regsub -all -- {[[:space:]]+} $read_line " " read_line
		set read_lines [split $read_line]
		set dynamic_simulation_time "[lindex $read_lines 1]"
		}
	if { [ regexp "DYNAMIC_TIME_STEP" $read_line]} {
		
		regsub ":" $read_line " " read_line
		regsub -all -- {[[:space:]]+} $read_line " " read_line
		set read_lines [split $read_line]
		set dynamic_time_step [lindex $read_lines 1] 
	
	
		}
	if { [ regexp "ENABLE_RAMPUP_FOR_DOMAIN" $read_line]} {
		
		set Constraint_file [read_gsc_settings_proc $Constraint_file ]
	
		}
	}
return $Constraint_file	
}
proc read_gsc_settings_proc { Constraint_file } {
global output_dir
set gsc_file [open "$output_dir/design.gsc" "w"]
while { [gets $Constraint_file read_line] >= 0 } {
	
if { $read_line ne "" } {
	if { [ regexp "#END_ENABLE_RAMPUP_FOR_DOMAIN" $read_line] } {
		
	break	
	} else {
		
		regsub ":" $read_line " " read_line
		regsub  {\[^} $read_line " " read_line
		regsub  {\]^} $read_line " " read_line
		regsub -all -- {[[:space:]]+} $read_line " " read_line
		set read_lines [split $read_line]
		set read_lines4 [lindex $read_lines 2]
		if {  $read_lines4 == 1 } {
		puts $gsc_file "* [lindex $read_lines 1] POWERUP"
		}
		if { $read_lines4 == 0 } {
		puts $gsc_file "* [lindex $read_lines 1] DISABLE"
		}
		
	} 
	}
	
}
	close $gsc_file
return $Constraint_file
}
 
proc read_spec_settings_proc { Constraint_file spec_count} {
global spec_name
global power_spec_name
global power_spec_id
global bbox
global cell_type
global master_cell
global area
global Net_Pin_Layer_Domain
global switch_info_count
global sitch_cell_info
global rect
global log
while { [gets $Constraint_file read_line] >= 0 } {
string trim $read_line
	if { [ regexp "#END_SPEC_SETTINGS" $read_line] } {
	break	
	} 
	if { [regexp "#SPEC_NAME"  $read_line ]} {
		regsub ":" $read_line " " read_line
		regsub -all -- {[[:space:]]+} $read_line " " read_line
		
		set read_lines [split $read_line]
		
	set spec_name($spec_count) "[lindex $read_lines 1]"
	}
	if { [regexp "#POWER_SPEC"  $read_line ]} {
		regsub ":" $read_line " " read_line
		regsub -all -- {[[:space:]]+} $read_line " " read_line
		regsub -all { [ ( ] } $read_line " " read_line
		regsub -all { [ )]} $read_line " " read_line
		regsub {^[\ ]*} $read_line "" read_line
		regsub {[\ ]*$} $read_line "" read_line
		set read_lines [split $read_line]
			
	
	set power_spec_id($spec_count) "[lindex $read_lines 1]"
	set power_spec_name($spec_count) "[lindex $read_lines 2]"
	
	}
	if { [regexp "#BBOX"  $read_line ]} {
	string trim $read_line
		regsub ":" $read_line " " read_line
		regsub -all { [ ( ] } $read_line " " read_line
		regsub -all {[( ] } $read_line " " read_line
		regsub -all { [ )]} $read_line " " read_line
		regsub -all { [ ) ] } $read_line " " read_line
		regsub {^[\ ]*} $read_line "" read_line
		regsub {[\ ]*$} $read_line "" read_line
 		regsub -all -- {[[:space:]]+} $read_line " " read_line
		set read_lines [split $read_line]
	#set bbox($spec_count) "[lindex $read_lines 1] [lindex $read_lines 2] [lindex $read_lines 3] [lindex $read_lines 4]"
	set bbox($spec_count) [lrange $read_lines 1 end]
	string trim $bbox($spec_count) 
	
	}
	if { [regexp "#CELL_TYPE"  $read_line ]} {
		regsub ":" $read_line " " read_line
		regsub -all -- {[[:space:]]+} $read_line " " read_line
		set read_lines [split $read_line]
	set cell_type($spec_count) "[lindex $read_lines 1]"
	if { [regexp -nocase "rectilinear"  $cell_type($spec_count) ]} {
		find_bbox_rect_proc $spec_count	
	}
	}
	if { [regexp "#MASTER_CELL"  $read_line ]} {
		regsub ":" $read_line " " read_line
		regsub -all -- {[[:space:]]+} $read_line " " read_line
		set read_lines [split $read_line]
	set master_cell($spec_count) "[lindex $read_lines 1]"
	
	}
	if { [regexp "#AREA"  $read_line ]} {
		regsub ":" $read_line " " read_line
		regsub -all -- {[[:space:]]+} $read_line " " read_line
		set read_lines [split $read_line]
	set area($spec_count) "[lindex $read_line 1]"
	}
	if { [regexp "^#BEGIN_SWITCH_CELL_DEFINITION"  $read_line ]} {
	
		set Constraint_file  [read_switch_info_proc $Constraint_file $spec_count]
	}	
	if { [regexp "#NET_PIN_LAYER_DOMAIN"  $read_line ]} {
	
		set Constraint_file  [read_net_pin_layer_info_proc $Constraint_file $spec_count]
	}	
	if { [regexp "#TIMING_MODELLING"  $read_line ]} {
		
		set Constraint_file  [read_timing_settings_proc $Constraint_file $spec_count ]
	}
		
	if { [regexp "#CAPACITANCE_MODELLING" $read_line ]} {
	
		
	
		set Constraint_file  [read_capacitance_settings_proc $Constraint_file $spec_count ]
	}	
}
return $Constraint_file 
}
proc find_bbox_rect_proc {  speccount } {
global bbox
global rect
global log
set min_x [lindex $bbox($speccount) 0]
set min_y [lindex $bbox($speccount) 1]
set max_x [lindex $bbox($speccount) 0]
set max_y [lindex $bbox($speccount) 1]
#set b_box($speccount) [split $bbox($speccount)]
set length_coor  [llength $bbox($speccount)]
set i 0
while {$i <= 1} {
set j 0
while {$j< $length_coor} {
if { $i == "0" } {
if {$min_x > [lindex $bbox($speccount) [expr $i+$j]]} {
	set min_x [lindex $bbox($speccount) [expr $i+$j]]
}
if {$max_x < [lindex $bbox($speccount) [expr $i+$j]]} {
	set max_x [lindex $bbox($speccount) [expr $i+$j]]
}
}
if { $i == "1" } {
if {$min_y > [lindex $bbox($speccount) [expr $i+$j]]} {
	set min_y [lindex $bbox($speccount) [expr $i+$j]]
}
if {$max_y < [lindex $bbox($speccount) [expr $i+$j]]} {
	set max_y [lindex $bbox($speccount) [expr $i+$j]]
}
}
set j [expr $j+2]
}
incr i
}
set rect($speccount) "$min_x $min_y $max_x $max_y"
}
proc read_switch_info_proc { Constraint_file spec_count } {
global switch_info_count
global switch_cell_info
global log
set switch_info_count($spec_count) 0 
set count 0
while { [gets $Constraint_file read_line] >= 0 } {	
string trim $read_line
	if { [ regexp "#END_BEGIN_SWITCH_CELL_DEFINITION" $read_line] } {
	
	break	
	} else {
		regsub ":" $read_line " " read_line
		regsub -all -- {[[:space:]]+} $read_line " " read_line
		set read_lines [split $read_line]
	 	set switch_cell_info($spec_count,$count) "[lindex $read_lines 0] [lindex $read_lines 1] [lindex $read_lines 2] [lindex $read_lines 3] [lindex $read_lines 4] "
	 	incr count	
		
	} 
	}
set switch_info_count($spec_count) $count 
	return $Constraint_file
}
proc read_net_pin_layer_info_proc { Constraint_file spec_count } {
global Net_Pin_Layer_info_count
set count 0
global Net_info
global Pin_info
global Layer_info
global Domain_info
global Net_pin_info
global log
while { [gets $Constraint_file read_line] >= 0 } {	
string trim $read_line
#puts "DEBUG $read_line"
	if { [ regexp "#END_NET_PIN_LAYER_DOMAIN" $read_line] } {
	
	break	
	} else {
		string trim $read_line
		regsub ":" $read_line " " read_line
		regsub -all -- {[[:space:]]+} $read_line " " read_line
		regsub {^\s*} $read_line "" read_line
		regsub {\s$} $read_line "" read_line
		set read_lines [split $read_line]
	 	set Net_info($spec_count,$count) "[lindex $read_lines 0]"
	 	set Pin_info($spec_count,$count) "[lindex $read_lines 1]"
		if { $Pin_info($spec_count,$count) == "-"} {
		
	 	set Pin_info($spec_count,$count)  $Net_info($spec_count,$count)
		}
		
	 	set Layer_info($spec_count,$count) "[lindex $read_lines 2]"
		set Domain_info($spec_count,$count) "[lindex $read_lines 3]"
		set Net_pin_info($Net_info($spec_count,$count)) $Pin_info($spec_count,$count) 	
		incr count	
	} 
	}
set Net_Pin_Layer_info_count($spec_count) $count 
	return $Constraint_file
}
proc read_timing_settings_proc { Constraint_file spec_count} {
global timing_type
global timing_model_type
global log
while { [gets $Constraint_file read_line] >= 0 } {	
string trim $read_line
	if { [ regexp "#END_TIMING_MODELLING" $read_line] } {
	break	
	} 
	if { [regexp "#TYPE"  $read_line ]} {
		regsub ":" $read_line " " read_line
		regsub -all -- {[[:space:]]+} $read_line " " read_line
		set read_lines [split $read_line]
	set timing_type($spec_count) "[lindex $read_line 1]"
	}
	if { [regexp "#MODEL_TYPE"  $read_line ]} {
		regsub ":" $read_line " " read_line
		regsub -all -- {[[:space:]]+} $read_line " " read_line
		set read_lines [split $read_line]
	set timing_model_type($spec_count) "[lindex $read_lines 1]"
	
	set Constraint_file  [read_timing_modelling_proc $Constraint_file $timing_type($spec_count) $timing_model_type($spec_count) $spec_count]
	}
}
return $Constraint_file
}
 
proc read_capacitance_settings_proc { Constraint_file spec_count} {
global capacitance_type
global capacitance_model_type
global log
while { [gets $Constraint_file read_line] >= 0 } {
string trim $read_line
#puts "read_capacitance_settings $read_line"
	if { [ regexp "#END_CAPACITANCE_MODELLING" $read_line] } {
	break	
	} 
	if { [regexp "#TYPE"  $read_line ]} {
		regsub ":" $read_line " " read_line
		regsub -all -- {[[:space:]]+} $read_line " " read_line
		set read_lines [split $read_line]
	set capacitance_type($spec_count) "[lindex $read_lines 1]"
	}
	if { [regexp "#MODEL_TYPE"  $read_line ]} {
		regsub ":" $read_line " " read_line
		regsub -all -- {[[:space:]]+} $read_line " " read_line
		set read_lines [split $read_line]
	set capacitance_model_type($spec_count) "[lindex $read_lines 1]"
	
	
	set Constraint_file  [read_capacitance_modelling_proc $Constraint_file $capacitance_type($spec_count) $capacitance_model_type($spec_count) $spec_count]
	
	}
}
return $Constraint_file
}
proc read_timing_modelling_proc { Constraint_file timingtype timingmodeltype spec_count} {
global sequence_type
global switch_interval_delay
global log
while { [gets $Constraint_file read_line] >= 0 } {
string trim $read_line
if { [regexp "TIMING_FILE" $timingtype] } {
if { [regexp "USER_STA_FILE" $timingmodeltype] || [regexp "STA_FILE" $timingmodeltype]} { 
			
	 
	
	
	
	if { [regexp "#PATH"  $read_line ]} {
	set Constraint_file  [read_path_proc $Constraint_file  $spec_count $timingtype $timingmodeltype ]
	break		
	}
	
	 	
	
	}
	}
 
if { [regexp "SWITCHING_SEQUENCE" $timingtype ] } {
	
	
	if { [regexp "SEQUENCE_ORDER_FILE" $timingmodeltype ]  || [regexp "PREDEFINED_SWITCHING_SEQUENCE" $timingmodeltype ]} {
	
	if { [regexp "#SEQUENCE_TYPE"  $read_line ]} {
		
		regsub ":" $read_line " " read_line
		regsub -all -- {[[:space:]]+} $read_line " " read_line
		set read_lines [split $read_line]
	set sequence_type($spec_count) "[lindex $read_lines 1]"
	}
	if { [regexp "#PATH"  $read_line ]} {
		set Constraint_file  [read_path_proc $Constraint_file $spec_count $timingtype $timingmodeltype ]
		
	}
	
	if { [regexp "#SWITCH_INTERVAL_DELAY"  $read_line ]} {
			
		regsub ":" $read_line " " read_line
		regsub -all -- {[[:space:]]+} $read_line " " read_line
		set read_lines [split $read_line]
		set switch_interval_delay($spec_count) "[lindex $read_lines 1]e-12"
	break 
	
}
	}
}
} 
return $Constraint_file		
}
proc read_path_proc { Constraint_file spec_count type model_type} {
set count 0
global path_files_count
global path_files
global path_switch_files
global log
while { [gets $Constraint_file read_line] >= 0 } {
string trim $read_line
	if { $read_line ne ""} {
	if { [regexp "#END_PATH" $read_line ] } {
	
	break
	} else {
		regsub ":" $read_line " " read_line
		regsub -all -- {[[:space:]]+} $read_line " " read_line
	if {[regexp "SWITCHING_SEQUENCE" $type] || [regexp "PWCAP_DATA" $model_type]} {
	
	set path_switch_files($spec_count,$type,$model_type,$count) $read_line  
	
	incr count
} else {	
	set path_files($spec_count,$type,$model_type,$count) $read_line  
	incr count
	}
	}	
	}
	}
set path_files_count($spec_count,$type,$model_type) $count
	return $Constraint_file
}
proc read_capacitance_modelling_proc { Constraint_file capacitancetype capacitancemodeltype spec_count } {
global log
global cap_value
while { [gets $Constraint_file read_line] >= 0 } {
string trim $read_line
if { [regexp "^CDEV" $capacitancetype] } {
if { [regexp "CAP_PER_UNIT_AREA" $capacitancemodeltype]} { 
			
	 
	if { [regexp "#CAP_VALUE"  $read_line ]} {
		regsub ":" $read_line " " $read_line
		regsub -all -- {[[:space:]]+} $read_line " " read_line
		set read_lines [split $read_line]
		set cap_value($spec_count)  "[lindex $read_lines 1]"
	break	
	}
	 	
	
	}
if { [regexp "USER_SPECIFIED" $capacitancemodeltype]} { 
			
	
	
	
	if { [regexp "#NAME_CAP_RES_LEAK"  $read_line ]} {
	
		set Constraint_file  [read_name_cap_res_proc $Constraint_file $spec_count $capacitancetype]
	break
	}
	 	
	
	}
if { [regexp "CAP_FILE" $capacitancemodeltype]} { 
			
	 
	if { [regexp "#PATH"  $read_line ]} {
	
		set Constraint_file  [read_path_proc $Constraint_file $spec_count $capacitancetype $capacitancemodeltype]
	break
	}
	}
 
}
if { [regexp "^PWCDEV" $capacitancetype] } {
if { [regexp "PWCAP_DATA" $capacitancemodeltype]} { 
			
	 
	
	if { [regexp "#PATH"  $read_line ]} {
		set Constraint_file  [read_path_proc $Constraint_file $spec_count $capacitancetype $capacitancemodeltype]
		 read_pwcap_res_proc $Constraint_file $spec_count $capacitancetype $capacitancemodeltype
		
	break
	} 	
	
	}
if { [regexp "PWCAP_FILE" $capacitancemodeltype]} { 
			
	 
	if { [regexp "#PATH"  $read_line ]} {
		
		set Constraint_file  [read_path_proc $Constraint_file $spec_count $capacitancetype $capacitancemodeltype]
	break
	}
	}
}
}
return $Constraint_file
}
proc read_name_cap_res_proc { Constraintfile spec_count type } {
global name_cap_res_files_count
global name_cap_res_files
global log
set count 0
set name_cap_res_files_count($spec_count,$type) 0
while { [gets $Constraintfile read_line] >= 0 } {
string trim $read_line
	if { $read_line ne "" } {
	if { [regexp -nocase "voltage_value" $Constraintfile ] } {
	#puts "DEBUG ANUSHA"
	continue
	}
	if { [regexp "END_NAME_CAP_RES_LEAK" $read_line ] } {
	
	break
	} else {
		
		regsub ":" $read_line " " read_line
	
		regsub {^\s*} $read_line "" read_line
		regsub {\s$} $read_line "" read_line
		regsub -all -- {[[:space:]]+} $read_line " " read_line
	
		set read_lines [split $read_line]
	 	set name_cap_res_files($spec_count,$type,$count) "[lindex $read_lines 0] [lindex $read_lines 1] [lindex $read_lines 2] [lindex $read_lines 3]"
	
	incr count  
	}
	
}
set name_cap_res_files_count($spec_count,$type) $count
}
return $Constraintfile
}
 
proc read_pwcap_res_proc { Constraint_file spec_count type model_type} {
global pwcap_res_files_count
global pwcap_res_files
global path_switch_files
global vdd_arc
global vss_arc
global log
set count 0
set pwcap_data_file [open "$path_switch_files($spec_count,$type,$model_type,$count)" "r"]
while { [gets $pwcap_data_file pwcap_line] >= 0 } {
string trim $pwcap_line
	if { $pwcap_line ne "" } {
	if { [regexp -nocase "voltage_value" $pwcap_line ] } {
continue	
	
	
}	
	if { [regexp -nocase "^arc" $pwcap_line ] } {
	
		regsub ":" $pwcap_line " " pwcap_line 
		regsub "#" $pwcap_line " " pwcap_line 
		regsub {[\ ]*$} $pwcap_line "" pwcap_line
		regsub {^[\ ]*} $pwcap_line "" pwcap_line
		regsub -all -- {[[:space:]]+} $pwcap_line " " pwcap_line
	
	set  pwcap_lines [split $pwcap_line]
		set vdd_arc($spec_count) [lindex $pwcap_lines 1]
		set vss_arc($spec_count) [lindex $pwcap_lines 2]
	
		incr count  
		set  pwcap_data_file [read_name_cap_res_proc $pwcap_data_file $spec_count $type]
	break
	}
	
}
}
}
 
proc create_extra_gsr {} {
global spec_count
global dynamic_simulation_time
global dynamic_time_step
global spec_name
global power_spec_name
global power_spec_id
global bbox
global cell_type
global master_cell
global area
global Net_Pin_Layer_Domain
global timing_type
global timing_model_type
global capacitance_type
global capacitance_model_type
global sequence_type
global switch_interval_delay
global path_files
global cap_value
global name_cap_res_files
global Net_Pin_Layer_Domain
global path_files_count
global name_cap_res_files_count
global Net_Pin_Layer_info_count
global Net_info
global Pin_info
global Layer_info
global Domain_info
global switch_info_count
global switch_cell_info
global path_switch_files
global output_dir
global Net_pin_info
global log
global rect
global env
file delete -force -- $output_dir/*timing
file delete -force -- $output_dir/*txt
file delete -force -- $output_dir/*cdev
set extra_gsr [open "$output_dir/extra.gsr" "w"]
puts -nonewline $extra_gsr  "DYNAMIC_SIMULATION_TIME $dynamic_simulation_time"
puts $extra_gsr "e-09\n\n"
puts -nonewline $extra_gsr  "DYNAMIC_TIME_STEP $dynamic_time_step"
puts $extra_gsr "e-012"
puts $extra_gsr "\n\nGSC_FILE $output_dir/design.gsc"
set length_spec_count "$spec_count" 
puts  $extra_gsr "\n\nSTA_FILE \{"
while { $length_spec_count > 0 } {
if { [regexp "^STA_FILE" $timing_model_type($length_spec_count) ] } {
set count 0
	
	puts  $extra_gsr "$master_cell($length_spec_count)  $path_files($length_spec_count,TIMING_FILE,STA_FILE,$count)"
	
}
set length_spec_count [expr $length_spec_count-1]
}
puts  $extra_gsr "\}"
puts  -nonewline $extra_gsr "\n\nUSER_STA_FILE "
	create_timing_files 
	create_combined_user_sta_files_proc  
puts  $extra_gsr "$output_dir/user_sta_file_comb.timing"
puts $extra_gsr "APL_FILES \{"
create_apl_files 
set cell_map [ open "$output_dir/cell_mapping_file" w ]
set length_spec_count "$spec_count"
while {$length_spec_count > 0} {
if {[regexp "^CDEV" $capacitance_type($length_spec_count)] && ([regexp -nocase "block" $cell_type($length_spec_count)] || [regexp -nocase "fullchip" $cell_type($length_spec_count)] || [regexp  -nocase "region" $cell_type($length_spec_count)] )} {
set count_path [expr $path_files_count($length_spec_count,$capacitance_type($length_spec_count),$capacitance_model_type($length_spec_count))-1]
	while {$count_path >= 0 } {
	
puts $cell_map "CELL_MAPPING \{\n"
 set cdev_files($master_cell($length_spec_count),$spec_name($length_spec_count)) $path_files($length_spec_count,$capacitance_type($length_spec_count),$capacitance_model_type($length_spec_count),$count_path)
puts $cell_map "$master_cell($length_spec_count) $spec_name($length_spec_count)"
	set count_path [expr $count_path-1]
puts $cell_map "\n\}\n" ;
}	
}
set length_spec_count [expr $length_spec_count-1]
}
close $cell_map 
set cdev_file_count [ llength [ array names cdev_files ] ]
set curr_dir [pwd]
cd $output_dir 
if {$cdev_file_count > 1 } {
set tmp_file [ open "$output_dir/tmp_cmd" w ]
puts -nonewline $tmp_file "$env(APACHEROOT)/bin/aplmerge -c "
foreach my_cdev_file [ array names cdev_files ] {
puts -nonewline $tmp_file "$cdev_files($my_cdev_file) "
}
puts -nonewline $tmp_file "-o $output_dir/merged.cdev"
close $tmp_file
if { [ catch { exec bash $output_dir/tmp_cmd } ] == 0} {
} else {
global errorInfo
#puts $log "APL FILES creation $errorInfo\n"
#puts "Merging cdev file unsuccessful"
}
}
if {$cdev_file_count == 1 } {
foreach my_cdev_file [ array names cdev_files ] {
if { [ catch { file copy -force $cdev_files($my_cdev_file) $output_dir/merged.cdev } ] == 0 } {
}
}
}
if { [ file exists $output_dir/merged.cdev ] } {
puts "Merging cdev files is succesfull"
puts $log "Merging APL files is succesfull"
puts "INFO : Started renaming cells using aplcopy"
puts $log "INFO : Started renaming cells using aplcopy"
set tmp_cmd1 [ open "$output_dir/aplcopy.cmd" w ]
puts $tmp_cmd1 "$env(APACHEROOT)/bin/aplcopy -map $output_dir/cell_mapping_file $output_dir/merged.cdev $output_dir/renamed.cdev"
close $tmp_cmd1
if { [ catch { exec bash $output_dir/aplcopy.cmd} ] == 0 } {
} else {
global errorInfo 
#puts $log "$errorInfo"
}
} else {

puts "Merging cdev files is unsuccesfull"
puts $log "Merging APL files is unsuccesfull"
}
cd $curr_dir
	
if { [file exists $output_dir/renamed.cdev] } {
puts $extra_gsr "$output_dir/renamed.cdev cap"
puts "INFO : Finished renaming cells using aplcopy"
puts $log "INFO : Finished renaming cells using aplcopy"
} else {
puts "INFO : Renaming cells using aplcopyid unsuccessful"
puts $log "INFO : Renaming cells using aplcopyid unsuccessful"
}
set length_spec_count "$spec_count" 
while { $length_spec_count > 0 } {
set count_path [expr $path_files_count($length_spec_count,$capacitance_type($length_spec_count),$capacitance_model_type($length_spec_count))-1]
	
	
if {[regexp "^CDEV" $capacitance_type($length_spec_count)]} {
if { [regexp -nocase "hard-ip" $cell_type($length_spec_count)] || [regexp -nocase "hard-ip" $cell_type($length_spec_count)] } {
	while {$count_path >= 0 } {
	puts $extra_gsr "$path_files($length_spec_count,$capacitance_type($length_spec_count),$capacitance_model_type($length_spec_count),$count_path) cap"
	set count_path [expr $count_path-1]
}	
	}
}
if {[regexp "^PWCDEV" $capacitance_type($length_spec_count)]} {	
	while {$count_path >= 0 } {
	puts $extra_gsr "$path_files($length_spec_count,$capacitance_type($length_spec_count),$capacitance_model_type($length_spec_count),$count_path) pwcap"
	set count_path [expr $count_path-1]
	}
	}
set length_spec_count [expr $length_spec_count-1]
}
puts $extra_gsr "\}"
puts $extra_gsr "\n\nDEF_COVER_CELL \{"
set length_spec_count "$spec_count"
while { $length_spec_count > 0 } {
	if {[regexp "PWCDEV" $capacitance_type($length_spec_count)] && ( [regexp -nocase "block" $cell_type($length_spec_count)] || [regexp -nocase "hard-ip" $cell_type($length_spec_count) ] || [regexp -nocase "routed-block" $cell_type($length_spec_count) ] || [regexp -nocase "fullchip$" $cell_type($length_spec_count)])} {
	puts $extra_gsr "$master_cell($length_spec_count)"
	}
set length_spec_count [expr $length_spec_count-1]
	}
puts $extra_gsr "\}"
puts $extra_gsr "\n\nBLOCK_POWER_FOR_SCALING \{"
set length_spec_count "$spec_count"
while { $length_spec_count > 0 } {
	if {[regexp "PWCDEV" $capacitance_type($length_spec_count)] && ([regexp -nocase "block" $cell_type($length_spec_count) ] || [regexp -nocase "hard-ip" $cell_type($length_spec_count) ] || [regexp -nocase "routed-block" $cell_type($length_spec_count) ] || [regexp -nocase "fullchip" $cell_type($length_spec_count)])} {
	puts $extra_gsr "FULLCHIP $power_spec_name($length_spec_count) 1e-09"
	}
set length_spec_count [expr $length_spec_count-1]
	}
puts $extra_gsr "\}"
puts $extra_gsr "\n\nBLOCK_POWER_ASSIGNMENT \{"
set length_spec_count "$spec_count"
while { $length_spec_count > 0 } {
if {[regexp "^CDEV" $capacitance_type($length_spec_count)] && ([regexp -nocase "block$" $cell_type($length_spec_count)] || [regexp -nocase "fullchip$" $cell_type($length_spec_count)] || [regexp  -nocase "region$" $cell_type($length_spec_count)] )} {
set NPL_count [expr $Net_Pin_Layer_info_count($length_spec_count)-1]
while { $NPL_count >= 0 } {
	
	puts $extra_gsr "$spec_name($length_spec_count)  REGION  $Layer_info($length_spec_count,$NPL_count) $Net_info($length_spec_count,$NPL_count) -1 $bbox($length_spec_count)"
set NPL_count [expr $NPL_count-1]
	}
	}
if {[regexp "^CDEV" $capacitance_type($length_spec_count)] && ([regexp -nocase "block_rectilinear" $cell_type($length_spec_count)] || [regexp -nocase "region_rectilinear" $cell_type($length_spec_count)] || [regexp -nocase "fullchip_rectilinear" $cell_type($length_spec_count)])} {
set NPL_count [expr $Net_Pin_Layer_info_count($length_spec_count)-1]
while { $NPL_count >= 0 } {
	
	puts $extra_gsr "$spec_name($length_spec_count)  REGION  $Layer_info($length_spec_count,$NPL_count) $Net_info($length_spec_count,$NPL_count) -1 $rect($length_spec_count)"
	
set NPL_count [expr $NPL_count-1]
	}
	puts $extra_gsr "$spec_name($length_spec_count)  REGION  RECTILINEAR $bbox($length_spec_count)"
	}
if { [regexp -nocase "hard-ip" $cell_type($length_spec_count)] } {
set NPL_count [expr $Net_Pin_Layer_info_count($length_spec_count)-1]
while { $NPL_count >= 0 } {
	
		
	puts $extra_gsr "$power_spec_name($length_spec_count) PIN $Layer_info($length_spec_count,$NPL_count) $Net_info($length_spec_count,$NPL_count) -1"
set NPL_count [expr $NPL_count-1]
	}
	}
if { [regexp -nocase "routed-block" $cell_type($length_spec_count)] } {
		
	puts $extra_gsr "$power_spec_name($length_spec_count) BLOCK EXCLUDE"
	}
#puts "$cell_type($length_spec_count)"
if {[regexp "^PWCDEV" $capacitance_type($length_spec_count)] && [regexp -nocase "block$" $cell_type($length_spec_count)] } {
set NPL_count [expr $Net_Pin_Layer_info_count($length_spec_count)-1]
while { $NPL_count >= 0 } {
	
		
	puts $extra_gsr "$power_spec_name($length_spec_count) BLOCK  $Layer_info($length_spec_count,$NPL_count) $Net_info($length_spec_count,$NPL_count) -1 "
set NPL_count [expr $NPL_count-1]
	}
	}
if {[regexp "^PWCDEV" $capacitance_type($length_spec_count)] && [regexp -nocase "fullchip$" $cell_type($length_spec_count)]} {
set NPL_count [expr $Net_Pin_Layer_info_count($length_spec_count)-1]
while { $NPL_count >= 0 } {
	puts $extra_gsr "adsFULLCHIP FULLCHIP  $Layer_info($length_spec_count,$NPL_count) $Net_info($length_spec_count,$NPL_count) -1"	
set NPL_count [expr $NPL_count-1]
	}
	}
if {[regexp "^PWCDEV" $capacitance_type($length_spec_count)] && [regexp -nocase "block_rectilinear" $cell_type($length_spec_count)] } {
set NPL_count [expr $Net_Pin_Layer_info_count($length_spec_count)-1]
while { $NPL_count >= 0 } {
	puts $extra_gsr "$power_spec_name($length_spec_count) BLOCK  $Layer_info($length_spec_count,$NPL_count) $Net_info($length_spec_count,$NPL_count) -1"	
set NPL_count [expr $NPL_count-1]
	}
	puts $extra_gsr "$power_spec_name($length_spec_count) BLOCK RECTILINEAR  $bbox($length_spec_count)"
	}
if {[regexp "^PWCDEV" $capacitance_type($length_spec_count)] && [regexp -nocase "fullchip_rectilinear" $cell_type($length_spec_count)]} {
set NPL_count [expr $Net_Pin_Layer_info_count($length_spec_count)-1]
while { $NPL_count >= 0 } {
	puts $extra_gsr "adsFULLCHIP FULLCHIP  $Layer_info($length_spec_count,$NPL_count) $Net_info($length_spec_count,$NPL_count) -1"	
set NPL_count [expr $NPL_count-1]
	}
	puts $extra_gsr "adsFULLCHIP FULLCHIP BLOCK RECTILINEAR -1 "
	}
set length_spec_count [expr $length_spec_count-1]
}
puts $extra_gsr "\}"
close $extra_gsr
close $log
}
proc create_combined_user_sta_files_proc {} {
global timing_type
global timing_model_type
global spec_name
global path_files
global spec_count
global switch_info_count
global switch_cell_info
global output_dir
set count 0 
file delete -force -- $output_dir/user_sta_file_comb.timing	
set user_sta_combined_file [open "$output_dir/user_sta_file_comb.timing" "a"]
set length_spec_count "$spec_count"
while { $length_spec_count >0 } {
if { [regexp "USER_STA_FILE" $timing_model_type($length_spec_count)] ||[ regexp "PREDEFINED_SWITCHING_SEQUENCE" $timing_model_type($length_spec_count)] || [regexp "SEQUENCE_ORDER_FILE" $timing_model_type($length_spec_count)] } {	
	#puts "DEBUG $path_files($length_spec_count,$timing_type($length_spec_count),$timing_model_type($length_spec_count),$count)"
	
	if {![file exists $path_files($length_spec_count,$timing_type($length_spec_count),$timing_model_type($length_spec_count),$count)]} {
	#puts "ERROR : Specified file $path_files($length_spec_count,$timing_type($length_spec_count),$timing_model_type($length_spec_count),$count) for  is not found"
	
	} else {
	set user_stafile [open $path_files($length_spec_count,$timing_type($length_spec_count),$timing_model_type($length_spec_count),$count) "r"]
	fcopy  $user_stafile $user_sta_combined_file
	}
	}
	set length_spec_count [expr $length_spec_count-1]
}
close $user_sta_combined_file
}
proc create_timing_files {} {
global path_switch_files
global spec_count
global timing_type
global timing_model_type
global switch_info_count
global switch_cell_info
global path_files
global switch_interval_delay
global path_switch_files
global output_dir
set count 0
set length_spec_count $spec_count
set sim_start_time 0
while { $length_spec_count > 0 } {
if { [regexp "^SWITCHING_SEQUENCE" $timing_type($length_spec_count) ] } {
set timing_file  [open "$path_switch_files($length_spec_count,$timing_type($length_spec_count),$timing_model_type($length_spec_count),$count)" "r"]
set file_out [open "$output_dir/user_sta_$length_spec_count.txt" "w+"]
set switch_count [expr $switch_info_count($length_spec_count)-1]
while { $switch_count >= 0 } {
                
		regsub ":" $switch_cell_info($length_spec_count,$switch_count) " " switch_cell_info($length_spec_count,$switch_count)
                regsub -all -- {[[:space:]]+} $switch_cell_info($length_spec_count,$switch_count) " " switch_cell_info($length_spec_count,$switch_count)
      
         set switch_cell_info_split [split $switch_cell_info($length_spec_count,$switch_count) ]
         set switch_cntrl_pin1 "[lindex $switch_cell_info_split 3]"
         set switch_pin([lindex $switch_cell_info_split 0]) $switch_cntrl_pin1
	set switch_count [expr $switch_count-1]
}
 set count2 0
   while {[gets $timing_file line] >= 0} {
#theck for comments
	regsub -all -- {[[:space:]]+} $line " " line
                regsub {^[\ ]*} $line "" line
                regsub {[\ ]*$} $line "" line
if {[regexp "PREDEFINED_SWITCHING_SEQUENCE" $timing_model_type($length_spec_count)] && [regexp "#" $line]} {
	set count2 0
#puts "DEBUG"	
continue
	}
if {[regexp "SEQUENCE_ORDER_FILE" $timing_model_type($length_spec_count)] && [regexp "#" $line]} {
	continue
	}
      regsub -all -- {[[:space:]]+} $line " " line
 
      string trim $line
      set element [split $line]
      set elem_length [llength $element]
      if {[expr $elem_length%2 ] != 0 } {
          #puts "$element $elem_length wrong number of arguments in the switching sequence file"
          continue
      }
     set elem_length [expr $elem_length/2]
  
    set i 0
    while { $elem_length >0 } {
      
	set sw_inst_name [lindex $element $i] 
      set sw_master_name [lindex $element [expr $i+1]]
      incr i 2
	if {[info exists switch_pin($sw_master_name)] } { 	
      set sw_ctrl_pin_name $switch_pin($sw_master_name)
      set time [expr $sim_start_time+$switch_interval_delay($length_spec_count)*$count2]
      puts $file_out "$sw_inst_name/$sw_ctrl_pin_name SW $time $time"
    
	} 
	set elem_length [expr $elem_length-1]
	}
  incr count2
 }
set path_files($length_spec_count,$timing_type($length_spec_count),$timing_model_type($length_spec_count),0) "$output_dir/user_sta_$length_spec_count.txt"
close $timing_file
close $file_out
}
set length_spec_count [expr $length_spec_count-1]
}
}	
proc create_apl_files {} {
global timing_model_type
global spec_count
global area
global cap_value
global name_cap_res_files
global power_spec_id
global power_spec_name
global master_cell
global Net_Pin_Layer_info_count
global Pin_info
global capacitance_type
global capacitance_model_type
global name_cap_res_files
global name_cap_res_files_count
global path_files
global path_files_count
global Net_pin_info
global output_dir
global vdd_arc
global vss_arc
set length_spec_count $spec_count 
while { $length_spec_count > 0 } {
#puts "DEBUG $length_spec_count $capacitance_model_type($length_spec_count)"
if {[regexp "CAP_PER_UNIT_AREA" $capacitance_model_type($length_spec_count) ]} {
#$area($length_spec_count) -- area 
set abs_cap_value [expr $cap_value($length_spec_count) * 0.000001 * 1000 * $area($length_spec_count)]
set  abs_cap_value [format "%0.2f" $abs_cap_value]
set er_cap_file [open "$output_dir/cap_per_unit_area_$power_spec_id($length_spec_count).cdev" w]
                puts $er_cap_file  "data_version cell.cdev 5v3\ntool_name aplcap\nversion 5.3 rel 0B\nReleased Date: date/month/year\ndata_tag asc 0 Sun Jan 21 19:10:45 2007\nfile_signature /proj/coremac11/products/gs60/dev/Char/ESPEC//lib_files/char_inputs/hspice_models/2006.12.08/model.paths.weak_mod 125 1.21 -322320349 SS"
                set cdev_print_out "$master_cell($length_spec_count) 200 $Net_Pin_Layer_info_count($length_spec_count) "
		for { set i 0 } { $i < $Net_Pin_Layer_info_count($length_spec_count) } { incr i } {
                set net_name_for_cpua $Pin_info($length_spec_count,$i) 
                set cdev_print_out [append cdev_print_out "$net_name_for_cpua $abs_cap_value 0 $abs_cap_value 0 0 0  " ]
                }
set path_files($length_spec_count,$capacitance_type($length_spec_count),$capacitance_model_type($length_spec_count),0) "$output_dir/cap_per_unit_area_$power_spec_id($length_spec_count).cdev"
set path_files_count($length_spec_count,$capacitance_type($length_spec_count),$capacitance_model_type($length_spec_count)) 1
                puts $er_cap_file $cdev_print_out
                close $er_cap_file
}
if {[regexp "USER_SPECIFIED" $capacitance_model_type($length_spec_count) ] } { 
set files_count [expr $name_cap_res_files_count($length_spec_count,$capacitance_type($length_spec_count))-1]
set er_cdev_user [open "$output_dir/user_cdev_$power_spec_id($length_spec_count).cdev" w]
puts $er_cdev_user  "data_version cell.cdev 5v3\ntool_name aplcap\nversion 5.3 rel 0B\nReleased Date: date/month/year\ndata_tag asc 0 Sun Jan 21 19:10:45 2007\nfile_signature /proj/coremac11/products/gs60/dev/Char/ESPEC//lib_files/char_inputs/hspice_models/2006.12.08/model.paths.weak_mod 125 1.21 -322320349 SS"
                set cdev_print_out "$master_cell($length_spec_count) 200 $name_cap_res_files_count($length_spec_count,$capacitance_type($length_spec_count)) "
while { $files_count >= 0 } {
		regsub ":"  "$name_cap_res_files($length_spec_count,CDEV,$files_count) " name_cap_res_files($length_spec_count,CDEV,$files_count) 
		regsub -all -- {[[:space:]]+} $name_cap_res_files($length_spec_count,CDEV,$files_count) " " name_cap_res_files($length_spec_count,CDEV,$files_count)
	
			
		set nrcl_split [split $name_cap_res_files($length_spec_count,CDEV,$files_count) ]
	 	set  net_name "[lindex $nrcl_split 0]"
	 	set  ESC_user_cdev "[lindex $nrcl_split 2]"
	 	set  ESR_user_cdev "[lindex $nrcl_split 1]"
	 	set  Leakage_user_cdev "[lindex $nrcl_split 3]"
if {([string equal $ESC_user_cdev "-"]) || ([string equal $ESC_user_cdev "NA"])} {
set ESC_user_cdev 0
}
if {([string equal $ESR_user_cdev "-"]) || ([string equal $ESR_user_cdev "NA"])} {
set ESR_user_cdev 0
}
if {([string equal $Leakage_user_cdev "-"]) || ([string equal $Leakage_user_cdev "NA"])} {
set Leakage_user_cdev 0
}
set cdev_print_out [append cdev_print_out "$Net_pin_info($net_name) $ESC_user_cdev $ESR_user_cdev $ESC_user_cdev $ESR_user_cdev $Leakage_user_cdev $Leakage_user_cdev " ]
set files_count [expr $files_count-1]
}
puts $er_cdev_user "$cdev_print_out"
set path_files($length_spec_count,$capacitance_type($length_spec_count),$capacitance_model_type($length_spec_count),0) "$output_dir/user_cdev_$power_spec_id($length_spec_count).cdev"
set path_files_count($length_spec_count,$capacitance_type($length_spec_count),$capacitance_model_type($length_spec_count)) 1
close $er_cdev_user
}
if {[regexp "PWCAP_DATA" $capacitance_model_type($length_spec_count) ] } { 
set npl_count $Net_Pin_Layer_info_count($length_spec_count)
set files_count [expr $name_cap_res_files_count($length_spec_count,$capacitance_type($length_spec_count))-1]
set er_aplpwcap_file [open "$output_dir/user_pwcdev_$power_spec_id($length_spec_count).pwcdev" w]
puts $er_aplpwcap_file "APLPWCAP version 13.2  Released Date: 01/02/2014   Linux 2.6.18-348.16.1.el5\nThu Jan  2 20:57:05 2014\n1000000000\nasc\n1"
puts $er_aplpwcap_file "$power_spec_name($length_spec_count)"
	puts $er_aplpwcap_file "$vdd_arc($length_spec_count)"
	puts $er_aplpwcap_file "$vss_arc($length_spec_count)"
puts $er_aplpwcap_file "[expr $files_count+1]"
for {set i 0 } { $i <= $files_count } {incr i} {
		regsub ":"  "$name_cap_res_files($length_spec_count,PWCDEV,$i) " name_cap_res_files($length_spec_count,PWCDEV,$i) 
	
			
		regsub {^\s*} $name_cap_res_files($length_spec_count,PWCDEV,$i) "" name_cap_res_files($length_spec_count,PWCDEV,$i)
		regsub {\s$} $name_cap_res_files($length_spec_count,PWCDEV,$i) "" name_cap_res_files($length_spec_count,PWCDEV,$i)
 		regsub -all -- {[[:space:]]+} $name_cap_res_files($length_spec_count,PWCDEV,$i) " " name_cap_res_files($length_spec_count,PWCDEV,$i)
		set vrcl_split [split $name_cap_res_files($length_spec_count,PWCDEV,$i) ]
	 	set  vol_name "[lindex $vrcl_split 0]"
	 	set  ESC_pwcdev "[lindex $vrcl_split 2]"
	 	set  ESR_pwcdev "[lindex $vrcl_split 1]"
	 	set  Leakage_pwcdev "[lindex $vrcl_split 3]"
puts $er_aplpwcap_file "$vol_name"
puts $er_aplpwcap_file "$ESC_pwcdev"
puts $er_aplpwcap_file "$ESR_pwcdev"
puts $er_aplpwcap_file "$ESC_pwcdev"
puts $er_aplpwcap_file "$ESR_pwcdev"
puts $er_aplpwcap_file "$Leakage_pwcdev"
puts $er_aplpwcap_file "$Leakage_pwcdev"
}
set path_files($length_spec_count,$capacitance_type($length_spec_count),$capacitance_model_type($length_spec_count),0) "$output_dir/user_pwcdev_$power_spec_id($length_spec_count).pwcdev"
set path_files_count($length_spec_count,$capacitance_type($length_spec_count),$capacitance_model_type($length_spec_count)) 1
#puts "DEBUG path_files pwcap_data $length_spec_count,$capacitance_type($length_spec_count),$capacitance_model_type($length_spec_count),0 $path_files($length_spec_count,$capacitance_type($length_spec_count),$capacitance_model_type($length_spec_count),0)"
close $er_aplpwcap_file
}
set length_spec_count [expr $length_spec_count-1]
}
}
proc gps_analyze_mesh { args } {

# Start Reading Arguments
set state flag
set argv [split $args]
global gps_ir_mode
global gps_output_dir

foreach arg $argv {
 	
                switch -- $state {
                        flag {
                                switch -glob -- $arg {
                               
                                        -output_dir { set state output }
                                      						
                                }
			}	
			
			output {
			set output_dir $arg
			set state flag
			}
			
		}
			
}
# Create Intermediate File for Reference 
set sens_log [ open "$output_dir/gps_analyze_mesh.log" w ]

global gps_main_iterative_analysis_number

global gps_sensitivity_check_done

if { $gps_sensitivity_check_done == 1} {

if { [ catch {source $output_dir/constraints_global_variables} ] == 0 } {
puts $sens_log "INFO : Finished Reading Constraints from Input Constraints File $output_dir/constraints_global_variables"
} else {
puts $sens_log "INFO : ERROR Reading Constraints from Input Constraints File $output_dir/constraints_global_variables"
global errorInfo
puts $sens_log "$errorInfo"
flush $sens_log
return
}

file mkdir $output_dir/IR_RESULTS/

set ir_results_dir "$output_dir/IR_RESULTS/"

puts $sens_log "#INFO : Started Getting IR drop profile for all regions"
flush $sens_log

set spec_file [ glob "*optInput" ]

if { [ catch { rhe get ir_drop_profile -i $spec_file -o $output_dir/IR_RESULTS/ } ] == 0 } {

puts $sens_log "#INFO : Finished Getting IR drop profile for all regions"
flush $sens_log

} else {

puts $sens_log "#INFO : Error Getting IR drop profile for all regions"
flush $sens_log

}


} else {

if { [ catch {source $output_dir/constraints_global_variables} ] == 0 } {
puts $sens_log "INFO : Finished Reading Constraints from Input Constraints File $output_dir/golden_input_spec"
} else {
puts $sens_log "INFO : ERROR Reading Constraints from Input Constraints File $output_dir/golden_input_spec"
global errorInfo
puts $sens_log "$errorInfo"
return
}


file mkdir $output_dir/IR_RESULTS/

set ir_results_dir "$output_dir/IR_RESULTS/"

puts $sens_log "#INFO : Started Getting IR drop profile for all regions"
flush $sens_log

if { [ catch { rhe get ir_drop_profile -i $output_dir/golden_input_spec -o $output_dir/IR_RESULTS/ } ] == 0 } {

puts $sens_log "#INFO : Finished Getting IR drop profile for all regions"
flush $sens_log

} else {

puts $sens_log "#INFO : Error Getting IR drop profile for all regions"
flush $sens_log

}

}

set output_file "$output_dir/MESH_analysis.rpt"

set out_mesh [ open "$output_file" w ]
puts $sens_log "INFO : MESH Details available in $output_file"
flush $sens_log

# Started Analyzing All Regions 
foreach region_id [ array names gps_nets_within_region ] {

set my_region_name $gps_fetch_region_name($region_id)
puts $sens_log "DEBUG : $region_id $my_region_name"
flush $sens_log
puts $sens_log "INFO : Started Analyzing Region $region_id"

puts -nonewline $out_mesh "#REGION $region_id"

puts $sens_log "INFO : BBOX $gps_region_xll($region_id) $gps_region_yll($region_id) $gps_region_xur($region_id) $gps_region_yur($region_id)"
puts $out_mesh " \{$gps_region_xll($region_id),$gps_region_yll($region_id),$gps_region_xur($region_id),$gps_region_yur($region_id)\}\n"
puts $out_mesh "\n"

if { [ info exists gps_excluded_regions_within_region($region_id)] } {
puts $out_mesh "#REGION_EXCLUDE $gps_excluded_regions_within_region($region_id)"
}

flush $sens_log
puts $sens_log "INFO : Started Finding IR Drop Trend for REGION $region_id"
flush $sens_log

global gps_avg_drop_net
global gps_mode_drop_net
global gps_worst_drop_net

set hist_file [ open "$output_dir/IR_RESULTS/$region_id/net.layer.info" r ]

while { [ gets $hist_file line1 ]  >= 0 } {

if { $line1 ne "" && ![regexp "^#" $line1] } {

set words1 [ split $line1 " "]
set net_name1 [ lindex $words1 0 ]
set layer_name1 [ lindex $words1 1 ]
set gps_avg_drop_net($region_id,$net_name1,$layer_name1) [ lindex $words1 2 ]
set gps_mode_drop_net($region_id,$net_name1,$layer_name1) [ lindex $words1 3 ]
set gps_worst_drop_net($region_id,$net_name1,$layer_name1) [ lindex $words1 4 ]
}

}

close $hist_file

set switch_file [ open "$output_dir/IR_RESULTS/$region_id/switch_drop.info" r ]

set start_sw_net_pair 0

global gps_switch_ext_net
global gps_switch_int_net
global gps_switch_net_pair
global gps_switch_drop_profile_avg
global gps_switch_drop_profile_mode
global gps_switch_drop_profile_worst

while { [ gets $switch_file line1 ]  >= 0 } {

set words1 [ split $line1 " "]

if { $line1 ne "" && [ regexp "^#SWITCH_NET_PAIR" $line1 ] } {

set start_sw_net_pair 1
set ext_net [ lindex $words1 1 ]
set int_net [ lindex $words1 2 ]
set gps_switch_ext_net($ext_net) 1
set gps_switch_int_net($int_net) 1
set gps_switch_net_pair($int_net) $ext_net
}

if { $line1 ne "" && [ regexp "^#END_SWITCH_NET_PAIR" $line1 ] } {
set start_sw_net_pair 0
}

if { $line1 ne "" && ![ regexp "^#SWITCH_NET_PAIR" $line1 ] && $start_sw_net_pair == 1 } {

set gps_switch_drop_profile_avg($region_id,$ext_net,$int_net) [ lindex $words1 0 ]
set gps_switch_drop_profile_mode($region_id,$ext_net,$int_net) [ lindex $words1 1 ]
set gps_switch_drop_profile_worst($region_id,$ext_net,$int_net) [ lindex $words1 2 ]

}

}

close $switch_file

# Analyze all Nets for this region

foreach netname $gps_nets_within_region($region_id) {

puts $out_mesh "#NET $netname"
# Analyze all layers of this region
puts $out_mesh "#<LAYER> <SPEC_NAME> <WIDTH> <SPACING> <GROUP_PITCH> <AVG_DROP(mV)> <MODE_DROP(mV)> <WORST_DROP(mV)> <DROP_DIFF(mV)>"

if { [ info exists drop_diff ] } {
unset drop_diff
}

foreach layername $gps_layers_of_net_within_region($region_id,$netname) {

if { [ info exists gps_avg_drop_net($region_id,$netname,$layername) ] } {

if { $gps_ir_mode eq "avg" } {
if { ![ info exists drop_diff ] } {

if { $gps_avg_drop_net($region_id,$netname,$layername) != 0} {
set drop_diff($layername) $gps_avg_drop_net($region_id,$netname,$layername)
set last_drop $gps_avg_drop_net($region_id,$netname,$layername)
} else {
set drop_diff($layername) $gps_avg_drop_net($region_id,$netname,$layername) 
}

} else {

if { $gps_avg_drop_net($region_id,$netname,$layername) != 0} {
set drop_diff($layername) [ expr $gps_avg_drop_net($region_id,$netname,$layername) - $last_drop ]
set last_drop $gps_avg_drop_net($region_id,$netname,$layername)
} else {
set drop_diff($layername) [ expr $gps_avg_drop_net($region_id,$netname,$layername) - $last_drop ]
}

}
}
 
if { $gps_ir_mode eq "mode" } {
if { ![ info exists drop_diff ] } {

if { $gps_mode_drop_net($region_id,$netname,$layername) != 0} {
set drop_diff($layername) $gps_mode_drop_net($region_id,$netname,$layername)
set last_drop $gps_mode_drop_net($region_id,$netname,$layername)
} else {
set drop_diff($layername) $gps_mode_drop_net($region_id,$netname,$layername)
}

} else {

if { $gps_mode_drop_net($region_id,$netname,$layername) != 0} {
set drop_diff($layername) [ expr $gps_mode_drop_net($region_id,$netname,$layername) - $last_drop ]
set last_drop $gps_mode_drop_net($region_id,$netname,$layername)
} else {
set drop_diff($layername) [ expr $gps_mode_drop_net($region_id,$netname,$layername) - $last_drop ]
}

}
}

if { $gps_ir_mode eq "worst" } {
if { ![ info exists drop_diff ] } {

if { $gps_worst_drop_net($region_id,$netname,$layername) != 0} {
set drop_diff($layername) $gps_worst_drop_net($region_id,$netname,$layername)
set last_drop $gps_worst_drop_net($region_id,$netname,$layername)
} else {
set drop_diff($layername) $gps_worst_drop_net($region_id,$netname,$layername)
}

} else {

if { $gps_worst_drop_net($region_id,$netname,$layername) != 0} {
set drop_diff($layername) [ expr $gps_worst_drop_net($region_id,$netname,$layername) - $last_drop ]
set last_drop $gps_worst_drop_net($region_id,$netname,$layername)
} else {
set drop_diff($layername) [ expr $gps_worst_drop_net($region_id,$netname,$layername) - $last_drop ]
}

}
}

foreach spec_name $gps_specs_within_region($region_id) {
# Actually it should be 1 . Awaiting Fix from Vishal
if { [ lsearch $gps_nets_within_spec($spec_name) $netname] != -1} {

foreach layer $gps_layers_within_spec($spec_name) {
if { $layer eq $layername } {

# PUT LAYER SPEC AND IR DROP TREND IN MESH_ANALYSIS.RPT FILE 
puts $out_mesh [ format "%s %s %0.2f %0.2f %0.2f %0.2f %0.2f %0.2f %0.2f" $layername $spec_name $gps_spec_width($spec_name) $gps_spec_spacing($spec_name) $gps_spec_group_pitch($spec_name) $gps_avg_drop_net($region_id,$netname,$layername) $gps_mode_drop_net($region_id,$netname,$layername) $gps_worst_drop_net($region_id,$netname,$layername) $drop_diff($layername)]

}
}
}

}

}
puts $sens_log "INFO : Finished Analyzing Layer $layername"
}
puts $out_mesh "#END_LAYER"
puts $out_mesh "#END_NET"
# Analyze All Layers for this net

puts $sens_log "INFO : Finished Analyzing Net $netname"

}
# Analyze all Nets for this region
puts -nonewline $out_mesh "\n#END_REGION\n\n"

puts $sens_log "INFO : Finished Analyzing Region $region_id"



}



# Analyze All Regions

close $out_mesh
close $sens_log

}
proc gps_compute_sensitivity_index { args } {

global gps_output_dir

# Start Reading Arguments
set state flag
set argv [split $args]

foreach arg $argv {
 	
                switch -- $state {
                        flag {
                                switch -glob -- $arg {
                               
                                        -golden_dir { set state golden }
                                        -new_dir { set state new }
						
                                }
			}	
			
			golden {
			set golden_input_directory $arg
			set state flag
			}
			
			new {
			set new_iteration_directory $arg
			set state flag
			}
			
		}
			
}
# Finish Reading Arguments

# Open Log file
set log [ open "$new_iteration_directory/gps_compute_sensitivity_reports.log" w ]

if { [ catch { source $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables_mesh_params_only } ] == 0} {

puts $log "INFO : Finished Reading Constraints from Input Constraints File $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables_mesh_params_only"

} else {
puts $log "INFO : ERROR Reading Constraints from Input Constraints File $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables_mesh_params_only"
global errorInfo
puts $log "$errorInfo"
return
}

if { [ catch { source $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables } ] == 0} {

puts $log "INFO : Finished Reading Constraints from Input Constraints File $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables"

} else {
puts $log "INFO : ERROR Reading Constraints from Input Constraints File $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables"
global errorInfo
puts $log "$errorInfo"
return
}
# Open Sensitivity Index Computation Report

set sens_fp [ open "$new_iteration_directory/sensitivity_index.rpt" w ]


# Start Reading Edit TCL file to get the metal whose sensitivity is being tested .
set edit_metal_layer ""

set edit_tcl_file [ glob "$new_iteration_directory/edit_mesh_*tcl" ]

set voltage_tcl [ open "$new_iteration_directory/voltage_change_by_sensitivity_settings" w ]

set edit_fp [ open "$edit_tcl_file" r ]

while { [ gets $edit_fp line ] >= 0 } {

if { $line ne "" } {

regsub -all {\t} $line " " line0
regsub -all -- {[[:space:]]+} $line0 " " line1
regsub -all -- {^\s+} $line1 " " line2

set words [ split $line2 " " ]

if { [ regexp "#EDIT MESH TCL" $line2] } {
set edit_metal_layer [ lindex $words 9 ]
puts $log "INFO : Sensitivity runs was done earlier on layer $edit_metal_layer"

puts $sens_fp "#METAL_CHANGED $edit_metal_layer"

flush $log
}
if { [ regexp "db edit" $line2] } {
set spc_name [ lindex $words 2 ]
set edited_width($spc_name) [ lindex $words 4 ]
if { ! [ info exists edited_specs ] } {
set edited_specs { }
}

lappend edited_specs $spc_name
}

if { [ regexp "#REGION " $line2] } {

if { ! [ info exists available_regions ] } {
set available_regions { }
}
set region_name [ lindex $words 1 ]
lappend available_regions $region_name

puts $log "INFO : Sensitivity runs was done on REGION $region_name"
flush $log

}
}

}

close $edit_fp

puts $log "INFO : Finished Reading Edit Mesh TCL command File for this Iteration"
flush $log

# Finish Reading Edit TCL file to get the metal whose sensitivity is being tested .

puts $log "INFO : Started Reading Constraints from $new_iteration_directory/constraints_global_variables"
flush $log


if { [ catch { source $new_iteration_directory/constraints_global_variables } ] == 0 } {


puts $log "INFO : Finished Reading Constraints from $new_iteration_directory/constraints_global_variables"
flush $log


} else {



puts $log "INFO : Error Reading Constraints from $new_iteration_directory/constraints_global_variables"
flush $log


}


# Start Computing IR drop changes due to change in width

puts $log "INFO : Started Analyzing IR drop change in the iteration due to change in layer $edit_metal_layer"
flush $log

foreach region_id $available_regions {

puts $log "INFO : Started Reading IR DROP Reports From Golden Run $golden_input_directory/IR_RESULTS/$region_id directory"
flush $log

puts $sens_fp "#REGION $region_id\n"

set old_ir_fp [ open "$golden_input_directory/IR_RESULTS/$region_id/net.layer.info" r ]

while { [ gets $old_ir_fp line ] >= 0 } {
set words [ split $line " " ]
if { $line ne "" && ! [regexp "#" $line] && ![ regexp "does_not_exist" $line ] } {
set metal_layer [ lindex $words 1 ]
set net_name [ lindex $words 0 ]

if { $metal_layer eq $edit_metal_layer } {
set net_name_has_edit_layer($net_name) 1
}

if { ! [ info exists worst_golden_drop($region_id,$net_name,$edit_metal_layer) ] } {
set worst_golden_drop($region_id,$net_name,$edit_metal_layer) [ lindex $words 4 ]
} else {
set drop [ lindex $words 4 ]
if { $drop > $worst_golden_drop($region_id,$net_name,$edit_metal_layer) } {
set worst_golden_drop($region_id,$net_name,$edit_metal_layer) $drop
}
}

}
}

close $old_ir_fp


puts $log "INFO : Finished Reading IR DROP Reports From Golden Run $golden_input_directory/$region_id directory"
flush $log


puts $log "INFO : Started Reading IR DROP Reports From New Iteration Run $new_iteration_directory/IR_RESULTS/$region_id directory"
flush $log

set new_ir_fp [ open "$new_iteration_directory/IR_RESULTS/$region_id/net.layer.info" r ]

while { [ gets $new_ir_fp line ] >= 0 } {
set words [ split $line " " ]
if { $line ne "" && ![regexp "#" $line] } {
set metal_layer [ lindex $words 1 ]
set net_name [ lindex $words 0 ]
if { ! [ info exists worst_new_drop($region_id,$net_name,$edit_metal_layer) ] } {
set worst_new_drop($region_id,$net_name,$edit_metal_layer) [ lindex $words 4 ]
} else {
set drop [ lindex $words 4 ]
if { $drop > $worst_new_drop($region_id,$net_name,$edit_metal_layer) } {
set worst_new_drop($region_id,$net_name,$edit_metal_layer) $drop
}
}

}
}
close $new_ir_fp


puts $sens_fp "#NET_SPECIFIC_VOLTAGE_DROP_CHANGE"
puts $sens_fp "#NETNAME GOLDEN_DROP NEW_DROP CHANGE_IN_DROP\n"

foreach data_point [ array names worst_golden_drop $region_id,*,$edit_metal_layer] {

set my_words [ split $data_point "," ]
set netname [ lindex $my_words 1 ]

puts $sens_fp "#NETNAME $netname"

if { [ info exists worst_golden_drop($region_id,$netname,$edit_metal_layer) ] && [ info exists worst_new_drop($region_id,$netname,$edit_metal_layer) ] && [ info exists edited_specs ] } {

set change_in_net_drop($region_id,$netname,$edit_metal_layer) [ format "%0.2f" [ expr $worst_golden_drop($region_id,$netname,$edit_metal_layer) - $worst_new_drop($region_id,$netname,$edit_metal_layer) ] ]

puts $voltage_tcl "set gps_change_in_voltage_drop_per_layer_from_sensitivity($region_id,$netname,$edit_metal_layer) $change_in_net_drop($region_id,$netname,$edit_metal_layer)"


if { $worst_golden_drop($region_id,$netname,$edit_metal_layer) != 0 } {
set perc_change_in_net_drop($region_id,$netname,$edit_metal_layer) [ format "%0.2f" [ expr $change_in_net_drop($region_id,$netname,$edit_metal_layer)*100/$worst_golden_drop($region_id,$netname,$edit_metal_layer) ] ]

puts $sens_fp "$netname $worst_golden_drop($region_id,$netname,$edit_metal_layer) $worst_new_drop($region_id,$netname,$edit_metal_layer) $change_in_net_drop($region_id,$netname,$edit_metal_layer)"
}

set worst_spec "NA"
set max_edited_width -10000

flush $log


set total_area_change($region_id) 0

foreach edited_spec $edited_specs {

if { [ lsearch $gps_specs_within_region($region_id) $edited_spec ] != -1} {

if { [ lsearch $gps_nets_within_spec($edited_spec) $netname ] != -1} {

set golden_area $gps_spec_area_golden($edited_spec)
set new_area $gps_spec_area($edited_spec)

set change_in_area [ expr $new_area - $golden_area ]

set total_area_change($region_id) [ expr $total_area_change($region_id) + $change_in_area ]

if { $edited_width($edited_spec) > $max_edited_width } {

set max_edited_width $edited_width($edited_spec)
set worst_spec $edited_spec


}

}
}
}

set metal_area_change [ format "%0.3f" $total_area_change($region_id) ]

puts $sens_fp "#METAL_AREA_CHANGE $metal_area_change um"

if { $worst_spec ne "NA" } {

puts $sens_fp "\n#MOST_EFFECTIVE_SPEC $worst_spec"

set width_change [ format "%0.3f" [ expr $max_edited_width - $gps_spec_width_golden($worst_spec) ] ]

puts $sens_fp "#BIGGEST_WIDTH_CHANGE_IN_EFFECTIVE_SPEC $width_change um"

set max_edited_width_perc [ format "%0.2f" [ expr $width_change*1.0*100/$gps_spec_width_golden($worst_spec) ] ]

puts $sens_fp "#BIGGEST_PERC_WIDTH_CHANGE_IN_EFFECTIVE_SPEC $max_edited_width_perc %"

puts $sens_fp "#PERC_CHANGE_IN_IR_DROP $perc_change_in_net_drop($region_id,$netname,$edit_metal_layer) %"

set sensitivity_index [ format "%0.2f" [ expr abs($perc_change_in_net_drop($region_id,$netname,$edit_metal_layer)*1000000/($max_edited_width_perc*$metal_area_change))]]

global gps_metal_sensitivity_index

if { $sensitivity_index ne "inf" } {
set gps_metal_sensitivity_index($region_id,$netname,$edit_metal_layer) $sensitivity_index
puts $sens_fp "\n#METAL_SENSITIVITY_INDEX $sensitivity_index\n"

} else {
set gps_metal_sensitivity_index($region_id,$netname,$edit_metal_layer) 100000000
puts $sens_fp "\n#METAL_SENSITIVITY_INDEX 100000000\n"

}


}

}

puts $sens_fp "#END_NETNAME"

}

puts $sens_fp "\n#END_NET_SPECIFIC_VOLTAGE_DROP_CHANGE"

puts $sens_fp "#END_REGION\n"

puts $log "INFO : Finished Reading IR DROP Reports From New Iteration Run $new_iteration_directory/IR_RESULTS/$region_id directory"
flush $log
}

puts $log "INFO : Finished Analyzing IR drop change in the iteration due to change in layer $edit_metal_layer"
flush $log

# Finish Computing IR drop changes due to change in width

close $log
close $sens_fp
close $voltage_tcl
}
proc GPS_CreateIRHist {args} {

global gps_output_dir

set argv [regexp -inline -all {\S+} $args]

set state flag

catch "unset dir_name"
catch "unset resolution"
catch "unset x1"
catch "unset y1"
catch "unset x2"
catch "unset y2"
set bbox 0

foreach arg $argv {
   switch $state {
          flag {
             switch -exact -- $arg {
                -dir_name {set state dir_name}
		-ir_text_report {set state ir_txt}
		-resolution {set state resolution}
		-bbox {set state x1; set bbox 1}
                 default {puts "Wrong argument $arg";return;}
             }          
          }
          dir_name {
	      set dir_name $arg;
              set state flag
          }
	  ir_txt {
	      set ir_text_report_file $arg; 
              set state flag
          }
	  resolution {
	      set resolution $arg;
              set state flag
          }
	  x1 {
              set x1 $arg
              set state y1
          }
          y1 {
              set y1 $arg
              set state x2
          }
          x2 {
              set x2 $arg
              set state y2
          }
          y2 {
              set y2 $arg;
              set state flag
          }

	  
   }
}

exec mkdir -p $dir_name
puts "INFO : Started Finding IR Drop Trend . See Log file $dir_name/IR_histogram.log for more details"

set histogram_log [ open "$dir_name/IR_histogram.log" w ]


	      set gps_region_llx $x1
	  
	      set gps_region_lly $y1
  	     
	      set gps_region_urx $x2
	   
	      set gps_region_ury $y2

puts $histogram_log "INFO : Dumping IR Histogram for region $gps_region_llx $gps_region_lly $gps_region_urx $gps_region_ury"
flush $histogram_log


if {!([info exists resolution])} {set resolution 700; }


#set resolution 100
set mode_count 0

catch "unset max_drop"
catch "array unset count"
catch "array unset sum"
catch "array unset bin_count"

set fp_layer_rpt [open "adsRpt/Static/layer_drop.rpt" "r"];

puts $histogram_log "INFO : Reading Layer Drop Report adsRpt/Static/layer_drop.rpt"
flush $histogram_log

while {[gets $fp_layer_rpt line] >= 0} {
   if {[regexp {^#} $line] > 0} {
         continue;
   } elseif {[regexp {^$} $line] > 0} {
        continue;
   } else {
        set words [regexp -inline -all {\S+} $line];
        if {[lindex $words 0] eq "Net"} {
           break;
        } else {
#           set min_drop([lindex $words 0]) [lindex $words 1];
#           set max_drop([lindex $words 0]) [lindex $words 2];
           if {[info exists max_drop]} {
               if {[lindex $words 2] > $max_drop} {
                  set max_drop [lindex $words 2];
               }
           } else {
                 set max_drop [lindex $words 2];
           }
        }
   }
}

close $fp_layer_rpt


set fp_ir_rpt [open "$ir_text_report_file" "r"]
set fp_out [open "$dir_name/debug.txt" "w"]

puts $histogram_log "INFO : Reading IR report $ir_text_report_file"
flush $histogram_log

if {$bbox == 0} {
puts $histogram_log "INFO : BBOX is not set . Hence Using Fullchip"
flush $histogram_log

puts $fp_out "#Net Layer IR_Drop Count IR_Sum Bin_Number Bin_Count"
  while {[gets $fp_ir_rpt line] >= 0} {
     if {!([regexp {^#} $line])} {
         set words [regexp -inline -all {\S+} $line]
         set ir [expr abs([lindex $words 0] - [lindex $words 1])]
         set net [lindex $words 2]
	 
	
	 
	 set pg_nets($net) 1
         set layer [lindex $words 6]
	 set layers($layer) 1
         if {[info exists sum($net,$layer)]} {set sum($net,$layer) [expr $sum($net,$layer) + $ir]} else {set sum($net,$layer) $ir}
         if {[info exists count($net,$layer)]} {incr count($net,$layer)} else {set count($net,$layer) 1}
	 if {$ir <= 0} {set bin_number 1} elseif {$ir >= $max_drop} {set bin_number $resolution} else {set bin_number [expr int(ceil(($ir*$resolution)/($max_drop)))]}
         
	     
	    if { [ info exists max_drop_net($net,$layer) ] } {	 
	 
	 if { $ir > $max_drop_net($net,$layer) } {
	 set max_drop_net($net,$layer) $ir
	 } 
	 
	 } else {
	 set max_drop_net($net,$layer) $ir
	 }
	 
	 
	 if { [ info exists min_drop_net($net,$layer) ] } {  
	 
	 if { $ir < $min_drop_net($net,$layer) } {
	 set min_drop_net($net,$layer) $ir
	 } 
	 
	 } else {
	 set min_drop_net($net,$layer) $ir
	 }
	 
	 if {[info exists bin_count($net,$layer,$bin_number)]} {incr  bin_count($net,$layer,$bin_number)} else {set bin_count($net,$layer,$bin_number) 1}   
 	 puts $fp_out "$net $layer $ir $count($net,$layer) $sum($net,$layer) $bin_number $bin_count($net,$layer,$bin_number)"
     }
  }
} else {
puts $histogram_log "INFO : BBOX is set ."
flush $histogram_log

puts $fp_out "#Net Layer  XY IR_Drop Count IR_Sum Bin_Number Bin_Count"
  while {[gets $fp_ir_rpt line] >= 0} {
     if {!([regexp {^#} $line])} {
         set words [regexp -inline -all {\S+} $line]
	 regsub -all {,} [lindex $words 4] {} x
	 regsub -all {\)} [lindex $words 5] {} y
	 
	 if { ($x >= $x1) && ($x <= $x2) && ($y >= $y1) && ($y <= $y2) } {
           set ir [expr abs([lindex $words 0] - [lindex $words 1])]
            set net [lindex $words 2]
            set pg_nets($net) 1
            set layer [lindex $words 6]
            set layers($layer) 1
	    
	    if { [ info exists max_drop_net($net,$layer) ] } {	 
	 
	 if { $ir > $max_drop_net($net,$layer) } {
	 set max_drop_net($net,$layer) $ir
	 } 
	 
	 } else {
	 set max_drop_net($net,$layer) $ir
	 }
	 
	 
	 if { [ info exists min_drop_net($net,$layer) ] } {  
	 
	 if { $ir < $min_drop_net($net,$layer) } {
	 set min_drop_net($net,$layer) $ir
	 } 
	 
	 } else {
	 set min_drop_net($net,$layer) $ir
	 }
	    
            if {[info exists sum($net,$layer)]} {set sum($net,$layer) [expr $sum($net,$layer) + $ir]} else {set sum($net,$layer) $ir}
            if {[info exists count($net,$layer)]} {incr count($net,$layer)} else {set count($net,$layer) 1}
            if {$ir <= 0} {set bin_number 1} elseif {$ir >= $max_drop} {set bin_number $resolution} else {set bin_number [expr int(ceil(($ir*$resolution)/($max_drop)))]}
            if {[info exists bin_count($net,$layer,$bin_number)]} {incr  bin_count($net,$layer,$bin_number)} else {set bin_count($net,$layer,$bin_number) 1}
            puts $fp_out "$net $layer ($x, $y) $ir $count($net,$layer) $sum($net,$layer) $bin_number $bin_count($net,$layer,$bin_number)"
	 }
    }
  }


}

close $fp_ir_rpt
close $fp_out


if { [ info exists gps_avg_drop_net ] } {
unset gps_avg_drop_net
}

if { [ info exists gps_mode_drop_net ] } {
unset gps_mode_drop_net
}

if { [ info exists gps_worst_drop_net ] } {
unset gps_worst_drop_net
}

if { [ info exists gps_worst_drop_net_all_layers ] } {
unset gps_worst_drop_net_all_layers
}


global gps_avg_drop_net
global gps_mode_drop_net
global gps_worst_drop_net
global gps_worst_drop_net_all_layers

set mode_count 0

exec mkdir -p $gps_output_dir

puts $histogram_log "INFO : Started Creating Net Layer Report $dir_name/net.layer.info"
flush $histogram_log

set fp_out [open "$dir_name/net.layer.info" "w"]
puts $fp_out "#Net Layer Avg Mode Worst Mode_Count"

puts $histogram_log "INFO : Started Creating Histogram Report $dir_name/histogram.out"
flush $histogram_log

set fp_out2 [open "$dir_name/histogram.out" "w"]

foreach net [array names pg_nets] {
puts $fp_out "\n"

set gps_worst_drop_net_all_layers($net) -1000

   foreach layer [array names layers] {
       puts $fp_out2 "# IR $net.$layer"
       if {[info exists count($net,$layer)]} {
#       if {$count($net,$layer) > 0} {set avg  [expr (($sum($net,$layer)/$count($net,$layer)))]} else {set avg "NA"}
       set avg  [expr (($sum($net,$layer)/$count($net,$layer)))]

       for {set i 1} {$i <= $resolution} {incr i} {
           if {[info exists bin_count($net,$layer,$i)] && $bin_count($net,$layer,$i) != 0} {
              if {$bin_count($net,$layer,$i) > $mode_count} {
                 set mode_count $bin_count($net,$layer,$i);
                 set mode [expr ($i*$max_drop_net($net,$layer))/($resolution)]
              }
            puts $fp_out2 "[ format "%0.3f" [expr ($i*$max_drop_net($net,$layer))/($resolution)] ] $bin_count($net,$layer,$i)"
           } 
       }

#       regsub -all {\/} $net . new_net

#       puts $fp_out "$avg $mode"
#set max_drop_net($net)  [ expr $max_drop_net($net)*1000 ]
#
#set avg_1 [ expr $avg*1000 ]
#
#set mode_1 [ expr $mode*1000 ]



       set gps_avg_drop_net($net,$layer) [ expr $avg*1000 ]
       set gps_mode_drop_net($net,$layer) [ expr $mode*1000 ]
       set gps_worst_drop_net($net,$layer) [ expr $max_drop_net($net,$layer)*1000]
       
       if { $gps_worst_drop_net($net,$layer) > $gps_worst_drop_net_all_layers($net) } {
       set gps_worst_drop_net_all_layers($net) [ format "%0.2f" $gps_worst_drop_net($net,$layer) ]
       }
       
       puts $fp_out [format "%s %s %0.2f %0.2f %0.2f %d" $net $layer $gps_avg_drop_net($net,$layer) $gps_mode_drop_net($net,$layer) $gps_worst_drop_net($net,$layer) $mode_count]
       
       
       puts $fp_out2 "\n"

       set mode_count 0
   } else {puts $fp_out "$net $layer does_not_exist"}
   }
  
}

close $fp_out
close $fp_out2
#Uncomment below if ta0 histogram plots are needed. Exec may not work on some machines.
#puts "Creating ta0 files...."
#foreach net [array names pg_nets] {
#   foreach layer [array names layers] {
#      exec grep "$net.$layer" "$dir_name/histogram.out" -A$resolution > .tmp
#      regsub -all {\/} $net . new_net
#      catch "exec prraw .tmp $dir_name/$new_net.$layer.ta0"
#   }
#}
puts $histogram_log "INFO : Finished Creating Net Layer Report $dir_name/net.layer.info"
flush $histogram_log

puts $histogram_log "INFO : Finished Creating Histogram Report $dir_name/histogram.out"
flush $histogram_log

close $histogram_log
puts "INFO : Finished Finding IR Drop Trend ."
}

proc gps_find_sensitivity_specs { } {

# Global Variables
global gps_output_dir
global gps_ir_mode

# Creating folder for sensitivity_checks
file mkdir $gps_output_dir/sensitivity_checks
file mkdir $gps_output_dir/sensitivity_checks/sensitivity_specs


# Open Log file for GPS sensitivity check 
puts "INFO : Creating Sensivity Checks Log File $gps_output_dir/sensitivity_checks/sensitivity_specs/gps_find_sensitivity_specs.log" 
set sens_log [ open "$gps_output_dir/sensitivity_checks/sensitivity_specs/gps_find_sensitivity_specs.log" w ]


# Dumping IR for all nodes in design
puts $sens_log "INFO : Started dumping IR drop for nodes in the design in $gps_output_dir/sensitivity_checks/sensitivity_specs/ir.txt"
flush $sens_log

set fname "$gps_output_dir/sensitivity_checks/sensitivity_specs/ir.txt"
report ir -routing -limit 0 -o $fname
puts $sens_log "INFO : Finished dumping IR drop for nodes in the design in $gps_output_dir/sensitivity_checks/sensitivity_specs/ir.txt"
flush $sens_log

# Global Variable To Vary the width of a layer by this percentage to check sensitivity . Default is 20 %
global gps_sensitivity_width_variation_perc

# Fetching Initial Spec File and Backing it Up to the file $gps_output_dir/sensitivity_checks/sensitivity_specs/golden_input_spec
puts $sens_log "INFO : Copying Golden Spec to $gps_output_dir/sensitivity_checks/sensitivity_specs/golden_input_spec File"
flush $sens_log
set initial_spc_file [ glob *optInput ]
file copy -force $initial_spc_file $gps_output_dir/sensitivity_checks/sensitivity_specs/golden_input_spec

# Read All Constraints from input constraint file


puts $sens_log "INFO : Started Reading Constraints from Input Constraints File $gps_output_dir/sensitivity_checks/sensitivity_specs/golden_input_spec"

if { [ catch { gps_read_constraint_file -golden_run 1 -input_file $gps_output_dir/sensitivity_checks/sensitivity_specs/golden_input_spec -output_file $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables} ] == 0 } {

if { [ catch {source $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables} ] == 0 } {
puts $sens_log "INFO : Finished Reading Constraints from Input Constraints File $gps_output_dir/sensitivity_checks/sensitivity_specs/golden_input_spec"
} else {
puts $sens_log "INFO : ERROR Reading Constraints from Input Constraints File $gps_output_dir/sensitivity_checks/sensitivity_specs/golden_input_spec"
global errorInfo
puts $sens_log "$errorInfo"
return
}

} else {
puts $sens_log "INFO : ERROR Reading Constraints from Input Constraints File $gps_output_dir/sensitivity_checks/sensitivity_specs/golden_input_spec"
global errorInfo
puts $sens_log "$errorInfo"
return
}

# Read All Constraints from input constraint file

# Fetching Initial Metal Density Profile and Backing it Up to the file $gps_output_dir/sensitivity_checks/sensitivity_specs/golden_metal_density.rpt
puts $sens_log "INFO : Copying Golden Metal Density Profile to $gps_output_dir/sensitivity_checks/sensitivity_specs/golden_metal_density.rpt File"
flush $sens_log

file copy -force Metal_density.rpt $gps_output_dir/sensitivity_checks/sensitivity_specs/golden_metal_density.rpt

puts $sens_log "INFO : Started Writing Mesh Analysis Report to $gps_output_dir/sensitivity_checks/sensitivity_specs/MESH_analysis.rpt File"
if { [ catch { gps_analyze_mesh -output_dir $gps_output_dir/sensitivity_checks/sensitivity_specs } ] == 0 } {
puts $sens_log "INFO : Finished Writing Mesh Analysis Report to $gps_output_dir/sensitivity_checks/sensitivity_specs/MESH_analysis.rpt File"
} else {
puts $sens_log "INFO : ERROR Writing Mesh Analysis Report to $gps_output_dir/sensitivity_checks/sensitivity_specs/MESH_analysis.rpt File"
global errorInfo
puts $sens_log "$errorInfo"
flush $sens_log
}

close $sens_log
# Finish Reading Initial Golden Spec

}


proc gps_find_top_sensitive_layers { } {

global gps_vary_group_pitch_keeping_spacing_constant

set gps_vary_group_pitch_keeping_spacing_constant 0

# Global variables
global gps_output_dir
global gps_global_drop_target_perc
global gps_net_specific_target_perc
global gps_ideal_voltage_net
global gps_sensitivity_width_variation_perc
global gps_sensitivity_iteration_counter


# Set Sensitivity variation percentage to 20 percent by default
if { ![ info exists gps_sensitivity_width_variation_perc ] } {
set gps_sensitivity_width_variation_perc 20
}

set found_region_section 0
set found_net_section 0
set found_layer_section 0

set sens_log [ open "$gps_output_dir/sensitivity_checks/sensitivity_specs/gps_find_sensitivity_specs.log" a ]

set top_sens_tcl [ open "$gps_output_dir/sensitivity_checks/sensitivity_specs/load_top_sensitive_layer_settings" w ]

puts $top_sens_tcl "global gps_top_sensitive_layers_in_region"

puts $top_sens_tcl "if \{ \[ info exists gps_top_sensitive_layers_in_region \] \} \{\n unset gps_top_sensitive_layers_in_region \n\}\n"

puts $top_sens_tcl "global gps_top_sensitive_layers_in_region"

puts "INFO : Started Reading Constraints from Input Constraints File $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables"

if { [ catch { source $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables } ] == 0} {

puts "INFO : Finished Reading Constraints from Input Constraints File $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables"

} else {

puts "INFO : ERROR Reading Constraints from Input Constraints File $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables"
return

}

puts "INFO : Started Reading Constraints from Input Constraints File $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables_mesh_params_only"

if { [ catch { source $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables_mesh_params_only } ] == 0} {

puts "INFO : Finished Reading Constraints from Input Constraints File $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables_mesh_params_only"

} else {

puts "INFO : ERROR Reading Constraints from Input Constraints File $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables_mesh_params_only"
return

}
# Reporting the top 2 sensitive layers in $gps_output_dir/sensitivity_checks/sensitivity_specs//TOP_sensitive_layers.rpt
puts $sens_log "INFO : Top Voltage Drop Layers reported in $gps_output_dir/sensitivity_checks/sensitivity_specs//TOP_sensitive_layers.rpt"

# Reading file $gps_output_dir/sensitivity_checks/sensitivity_specs/MESH_analysis.rpt
if { [ file exists $gps_output_dir/sensitivity_checks/sensitivity_specs/MESH_analysis.rpt ] } {
set read_mesh [ open "$gps_output_dir/sensitivity_checks/sensitivity_specs/MESH_analysis.rpt" r ]
set sens_rpt [ open "$gps_output_dir/sensitivity_checks/sensitivity_specs/TOP_sensitive_layers.rpt" w ]

while { [ gets $read_mesh line ] >= 0 } {

if { $line ne "" } {

regsub -all {\t} $line " " line0
regsub -all -- {[[:space:]]+} $line0 " " line1
regsub -all -- {^\s+} $line1 " " line2

# AIM is to find top 2 Voltage Drop Contributing Layers in every region in which sensitivity analysis needs to be done

if { $found_region_section == 0 && [ regexp "#REGION" $line2 ] } {

set words1 [ split $line2 " " ]
set region_name1 [ lindex $words1 1 ]

#if { ![ info exists gps_excluded_regions_within_region($region_name1)] } {

set found_region_section 1 ;

set bbox($region_name1) [ lindex $words1 2 ]
puts $sens_rpt "$line2" 
puts $sens_rpt "#<LAYER> <SPEC_NAME> <WIDTH> <SPACING> <GROUP_PITCH> <AVG_DROP(mV)> <MODE_DROP(mV)> <WORST_DROP(mV)> <DROP_DIFF(mV)>"

#}

}

if { $found_region_section == 1 && [ regexp "#END_REGION" $line2 ] } {
set found_region_section 0 ;

# Start Sorting the top drop layers
 if { [ info exists printed_once ] } {
unset printed_once
}

}

if { $found_region_section == 1 && [regexp "#NET" $line2 ] } {
set found_net_section 1
set words [ split $line2 " " ]
set netname1 [ lindex $words 1 ]
regsub -all -- {[[:space:]]+} $netname1 "" netname

set tmp_file [ open "$gps_output_dir/sensitivity_checks/sensitivity_specs/.tmp" w ]
puts $sens_rpt "#NET $netname"
set worst_drop_net($region_name1,$netname) -1000000

if { [ catch { unset printed_once } ] == 0 } {

}

}

if { $found_region_section == 1 && [regexp "#END_NET" $line2 ] } {


global gps_avg_drop_net
global gps_mode_drop_net
global gps_worst_drop_net

if { $worst_drop_net($region_name1,$netname) == -1000000} {

foreach entry_name2 [ array names gps_worst_drop_net $region_name1,$netname,* ] {

set tmp_worst $gps_worst_drop_net($entry_name2)

if { $tmp_worst > $worst_drop_net($region_name1,$netname)} {
set worst_drop_net($region_name1,$netname) $tmp_worst
}

}

}

set found_net_section 0

close $tmp_file
global gps_num_main_iterations

if { $gps_num_main_iterations < 2} {
set sort_num 2
} else {
set sort_num $gps_num_main_iterations
}

set split_sorted_data  [ split [ rhe_nx::rhe_sort $gps_output_dir/sensitivity_checks/sensitivity_specs/.tmp 9 decreasing "" "" $sort_num ] "\n" ]


foreach data_point $split_sorted_data   {

set chosen_metal_words [ split $data_point " "]
set chosen_metal [ lindex $chosen_metal_words 0 ]

if { $data_point ne "" && $gps_layer_edit_allowed($chosen_metal) == 1 } {

set unique_metal($chosen_metal) 1
puts $sens_rpt "$data_point"

lappend unique_metal_spec($region_name1,$chosen_metal) $data_point

if { ![ info exists printed_once($chosen_metal) ]  } {

puts $top_sens_tcl "lappend gps_top_sensitive_layers_in_region($region_name1,$netname) $chosen_metal"
set printed_once($chosen_metal) 1
}

}

}


puts $sens_rpt "#END_NET"
}

if { $found_region_section == 1 && $found_net_section == 1 && [regexp "#<LAYER>" $line2 ] } {
set found_layer_section 1

}

if { $found_region_section == 1 && $found_net_section == 1 && $found_layer_section == 1 && [ regexp "#END_LAYER" $line2 ] } {
set found_layer_section 0
}


if { $found_region_section == 1 && $found_net_section == 1 && $found_layer_section == 1 && ![ regexp "#" $line2 ] } {

set my_words [ split $line2 " " ]
set my_metal_layer  [ lindex $my_words 0 ]
set worst_drop_number [ lindex $my_words 7 ]

if { ![ info exists have_printed_once($region_name1,$netname,$my_metal_layer) ] } {
puts $tmp_file "$line2"
}

set have_printed_once($region_name1,$netname,$my_metal_layer) 1

if { $worst_drop_number > $worst_drop_net($region_name1,$netname)} {
set worst_drop_net($region_name1,$netname) $worst_drop_number
}

}

}

}
close $read_mesh
close $sens_rpt
close $top_sens_tcl
}

global gps_num_sensitivity_iterations

set sorted_unique_metal [ lsort -unique [array names unique_metal ]]

set gps_num_sensitivity_iterations [ llength  $sorted_unique_metal ]

# After creating $gps_output_dir/sensitivity_checks/sensitivity_specs/TOP_sensitive_layers.rpt , we know how many sensitivity iterations will be required 

# Once we have identified regions which needs IR drop improvement , we will find if the regions have a layer in common . 
# In one sensitivity run , we will sweep only one layer .
# If 'N' regions they have a sensitive layer in common , then in a single sensitivity run , we will sweep that layer in all 'N' regions . 

puts $sens_log "INFO : SENSITIVITY RUNS will take $gps_num_sensitivity_iterations iterations"
puts "INFO : SENSITIVITY RUNS will take $gps_num_sensitivity_iterations iterations"
set count 0 

# We will dump the unique sensitivity sweep tcls in edit_tcls as edit_mesh_0.tcl , edit_mesh_1.tcl etc depending on number of sensitivity runs we need

file mkdir $gps_output_dir/sensitivity_checks/sensitivity_specs/edit_tcls

set top_sens_tcl [ open "$gps_output_dir/sensitivity_checks/sensitivity_specs/load_top_sensitive_layer_settings" a ]

puts $top_sens_tcl "global gps_sensitivity_run_id_number"

global gps_net_specific_target_drop_per_region
global gps_net_specific_voltage_drop_improvement_needed_per_region

foreach met $sorted_unique_metal {

incr count
puts $sens_log "INFO : Creating File tmp_edit_mesh_$count.tcl for Sensitivity Iteration Number $count"

set out_tcl [ open "$gps_output_dir/sensitivity_checks/sensitivity_specs/edit_tcls/tmp_edit_mesh_$count.tcl" w ]

set glob_var [ open "$gps_output_dir/sensitivity_checks/sensitivity_specs/edit_tcls/width_change_iteration_$count.tcl" w ]

puts $glob_var "global gps_sensitivity_width_change_perc_guessed"

puts $sens_log "INFO : Creating File restore_mesh_$count.tcl for Sensitivity Iteration Number $count"

set restore_tcl [ open "$gps_output_dir/sensitivity_checks/sensitivity_specs/edit_tcls/tmp_restore_mesh_$count.tcl" w ]

puts $out_tcl "#EDIT MESH TCL TO DO SENSITIVITY ANALYSIS OF METAL $met\n"

puts $top_sens_tcl "set gps_sensitivity_run_id_number($met) $count"

puts $restore_tcl "#TCL TO DO RESTORE THE MESH OF METAL $met AFTER ITS SENSITIVITY CALCULATION IS DONE\n"

if { [ info exists spec_printed ] } {
if { [ catch {unset spec_printed} ] == 0 } { 

}
}

##### Set Target Only for External Nets First #####
global gps_switch_int_net

foreach data1 [ array names unique_metal_spec *,$met ] {

set wrd [ split $data1 "," ]
set rgn [ lindex $wrd 0 ]

global gps_region_xll
global gps_region_yll
global gps_region_xur
global gps_region_yur

puts $out_tcl "#REGION $rgn \{$gps_region_xll($rgn),$gps_region_yll($rgn),$gps_region_xur($rgn),$gps_region_yur($rgn)\}\n"
puts $restore_tcl "#REGION $rgn \{$gps_region_xll($rgn),$gps_region_yll($rgn),$gps_region_xur($rgn),$gps_region_yur($rgn)\}\n"


puts $out_tcl "#INFO : Started Processing External Nets First"
flush $out_tcl
puts $restore_tcl "#INFO : Started Processing External Nets First"
flush $restore_tcl

foreach spc_name $gps_specs_within_region($rgn) {

if { [ lsearch $gps_layers_within_spec($spc_name) $met ] != -1 } {

if { ![ info exists spec_printed($spc_name) ] } {
set spec_printed($spc_name) 0
}

if { $spec_printed($spc_name) == 0 } {

set max_improvement_required -10000 

global gps_ideal_voltage_net
global gps_min_vdd_voltage
global gps_switch_int_net
foreach netname $gps_nets_within_spec($spc_name) {

if { ![ info exists gps_switch_int_net($netname) ] } {

if { $gps_ideal_voltage_net($netname) != 0 } {

set target_drop [ format "%0.2f" [ expr $gps_net_specific_target_drop_perc($netname)*1.0*$gps_ideal_voltage_net($netname)*1000/100 ]]

set gps_net_specific_target_drop_per_region($rgn,$netname) $target_drop

} else {

set target_drop [ format "%0.2f" [ expr $gps_net_specific_target_drop_perc($netname)*1.0*$gps_min_vdd_voltage*1000/100 ]]

set gps_net_specific_target_drop_per_region($rgn,$netname) $target_drop

}

set improvement_need [ format "%0.2f" [ expr $worst_drop_net($rgn,$netname) - $target_drop ]]


if { ! [ info exists gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname) ]} {

set gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname) $improvement_need

} else {

if { $improvement_need > $gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname)} {

set gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname) $improvement_need

}

}


if { $improvement_need > $max_improvement_required } {

set max_improvement_required $improvement_need

set max_improvement_required_perc [ format "%0.2f" [ expr $improvement_need*1.0*100/$worst_drop_net($rgn,$netname) ]]

set max_improvement_required_net $netname

}

}

}

if { $max_improvement_required != -10000 } {

set layer_width $gps_spec_width_golden($spc_name)

set final_variation_perc [ expr 100 + $max_improvement_required_perc ]
set new_width [ format "%0.3f" [ expr $final_variation_perc*1.0*$layer_width/100 ]]

set mod_width_change [ expr $new_width - $layer_width ]

set layer_spacing $gps_spec_spacing_golden($spc_name)
set grp_pitch $gps_spec_group_pitch_golden($spc_name)

global gps_nets_within_spec
set num_layers_in_spec [ llength $gps_nets_within_spec($spc_name) ]

if { $max_improvement_required > 0 } {

if { $layer_spacing  == 0 || $num_layers_in_spec == 1} {

puts $out_tcl "# MAX DROP_IMPROVEMENT NEEDED FOR THIS MESH SPEC WAS $max_improvement_required mV ( $max_improvement_required_perc % )"

if { $gps_vary_group_pitch_keeping_spacing_constant == 0 } {

puts $out_tcl "db edit $spc_name -width $new_width\n"

flush $out_tcl

}

if { $gps_vary_group_pitch_keeping_spacing_constant == 1 } {

set mod_grp_pitch [ format "%0.3f" [ expr $grp_pitch + $mod_width_change ] ]

puts $out_tcl "db edit $spc_name -width $new_width -pitch $mod_grp_pitch\n"

flush $out_tcl

}

if { ![ info exists gps_sensitivity_width_change_perc_guessed($spc_name,$met) ]} {

set gps_sensitivity_width_change_perc_guessed($spc_name,$met) $max_improvement_required_perc

} else {

if { $max_improvement_required_perc > $gps_sensitivity_width_change_perc_guessed($spc_name,$met) } {
set gps_sensitivity_width_change_perc_guessed($spc_name,$met) $max_improvement_required_perc
}

}

flush $out_tcl
} else {

puts $out_tcl "# MAX DROP_IMPROVEMENT NEEDED FOR THIS MESH SPEC WAS $max_improvement_required mV ( $max_improvement_required_perc % )"
flush $out_tcl
set new_width [ format "%0.3f" [ expr $final_variation_perc*1.0*$layer_width/100 ]]

set mod_width_change [ expr $new_width - $layer_width ]

set new_spacing [ format "%0.3f" [ expr $layer_spacing - ( $new_width - $layer_width ) ]]

if { $new_spacing < 0.01 } {

set new_spacing 0.01

set new_width [ format "%0.3f" [ expr $layer_width + $layer_spacing - 0.01 ] ]

}

global gps_nets_within_spec
global gps_spec_group_pitch

set num_layers_in_spec [ llength $gps_nets_within_spec($spc_name) ]

if { $gps_spec_spacing($spc_name) != 0 && $num_layers_in_spec != 1 && $new_spacing >= 0.01 } {

set sum_total [ expr $num_layers_in_spec*$new_width + ( $num_layers_in_spec - 1 )*$new_spacing ]

while { $sum_total >= $gps_spec_group_pitch($spc_name)  } {

set sum_total [ expr $num_layers_in_spec*$new_width + ( $num_layers_in_spec - 1 )*$new_spacing ]

set amount_exceeded [ format "%0.3f" [ expr $sum_total - $gps_spec_group_pitch($spc_name) + 0.01 ] ]

set new_width [ format "%0.3f" [ expr $new_width - ($amount_exceeded*1.0/$num_layers_in_spec) ] ]

set new_spacing [ format "%0.3f" [ expr $new_spacing + ($amount_exceeded*1.0/$num_layers_in_spec) ] ]

}

}

if { $gps_vary_group_pitch_keeping_spacing_constant == 1 } {

set mod_grp_pitch [ format "%0.3f" [ expr $grp_pitch + $num_layers_in_spec*$mod_width_change ] ]

puts $out_tcl "db edit $spc_name -width $new_width -pitch $mod_grp_pitch -spacing $layer_spacing\n"

flush $out_tcl

}

if { $gps_vary_group_pitch_keeping_spacing_constant == 0 } {

puts $out_tcl "db edit $spc_name -width $new_width -spacing $new_spacing\n"
flush $out_tcl

}
if { ![ info exists gps_sensitivity_width_change_perc_guessed($spc_name,$met) ]} {

set gps_sensitivity_width_change_perc_guessed($spc_name,$met) $max_improvement_required_perc

} else {

if { $max_improvement_required_perc > $gps_sensitivity_width_change_perc_guessed($spc_name,$met) } {
set gps_sensitivity_width_change_perc_guessed($spc_name,$met) $max_improvement_required_perc
}

}

}


puts $restore_tcl "db edit $spc_name -width $layer_width -spacing $layer_spacing -pitch $gps_spec_group_pitch_golden($spc_name)\n"
flush $restore_tcl

} else {

puts $out_tcl "#INFO : Max Improvement required for region $rgn is $max_improvement_required ($max_improvement_required_perc %) . Hence Dropping Optimization in this region and net ."
flush $out_tcl

}

set spec_printed($spc_name) 1


}

}

}
}

puts $out_tcl "#INFO : Finished Processing External Nets"
flush $out_tcl

puts $restore_tcl "#INFO : Finished Processing External Nets"
flush $restore_tcl

##### Set Target Only for External Nets First #####


puts $sens_log "Started Looping through the nets in this region to get the internal net targets"
flush $sens_log

global gps_ideal_voltage_net
global gps_min_vdd_voltage
global gps_switch_int_net
global gps_nets_within_region


set max_improvement_required -10000 

foreach netname $gps_nets_within_region($rgn) {

if { [ info exists gps_switch_int_net($netname) ] } {

if { $gps_ideal_voltage_net($netname) != 0 } {

set target_drop [ format "%0.2f" [ expr $gps_net_specific_target_drop_perc($netname)*1.0*$gps_ideal_voltage_net($netname)*1000/100 ]]

set gps_net_specific_target_drop_per_region($rgn,$netname) $target_drop

} else {

set target_drop [ format "%0.2f" [ expr $gps_net_specific_target_drop_perc($netname)*1.0*$gps_min_vdd_voltage*1000/100 ]]

set gps_net_specific_target_drop_per_region($rgn,$netname) $target_drop

}

set improvement_need [ format "%0.2f" [ expr $worst_drop_net($rgn,$netname) - $target_drop ]]

if {  ![ info exists gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname) ] } {

set gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname) $improvement_need

} else {

if { $improvement_need > $gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname) } {

set gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname) $improvement_need

}

}

#### Subtract External Drop Improvement from internal drop #####
global gps_switch_net_pair

global gps_switch_drop_profile_avg

if {  [ info exists gps_switch_net_pair($netname) ] && [ info exists gps_switch_drop_profile_avg($rgn,$gps_switch_net_pair($netname),$netname) ] } {

set ext_net $gps_switch_net_pair($netname)

if { [ info exists gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$ext_net) ] && ![ info exists gps_ext_int_drop_adjustment_done($rgn,$ext_net,$netname)] } {

puts $sens_log "#INFO : Drop Improvement on External Net $ext_net in region $rgn is $gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$ext_net) mV"
flush $sens_log

puts $sens_log "#INFO : Drop Improvement Required on Internal Net $netname in region $rgn is $gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname) mV"
flush $sens_log

global gps_switch_drop_profile_avg

if { $gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$ext_net) >=0 } {

puts $sens_log "#INFO : Average Switch Drop in this region is $gps_switch_drop_profile_avg($rgn,$ext_net,$netname)"
flush $sens_log

set my_tmp [ format "%0.2f" [ expr $gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname) - $gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$ext_net)]]

if {  ![ info exists gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname) ] } {

set gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname) $my_tmp

} else {

set gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname) $my_tmp

}


set gps_ext_int_drop_adjustment_done($rgn,$ext_net,$netname) 1

set improvement_need $gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname)

puts $sens_log "#INFO : Balance IR Drop Improvement required on Internal Net $netname in region $rgn to $gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname) mV"
flush $sens_log

set tmp_sum [ expr $gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$ext_net) + $gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname) ]

set drop_contribution_ext_net $worst_drop_net($rgn,$ext_net)

set drop_contribution_int_net [ format "%0.2f" [ expr $worst_drop_net($rgn,$netname) - $gps_switch_drop_profile_avg($rgn,$ext_net,$netname) - $worst_drop_net($rgn,$ext_net) ]]

set tmp_sum [ expr $drop_contribution_ext_net + $drop_contribution_int_net]

set ext_ratio [ expr $drop_contribution_ext_net*1.0/$tmp_sum ]

set addl_ext_drop [ format "%0.2f" [ expr $ext_ratio * $gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname)] ]

set my_tmp1 [ format "%0.2f" [ expr $gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$ext_net) + $addl_ext_drop ]]

if {  ![ info exists gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$ext_net) ] } {

set gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$ext_net) $my_tmp1

} else {

if { $my_tmp1 > $gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$ext_net) } {

set gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$ext_net) $my_tmp1

}

}

set my_tmp2 [ format "%0.2f" [ expr $gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname) - $addl_ext_drop ]]

if {  ![ info exists gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname) ] } {

set gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname) $my_tmp2

} else {

if { $my_tmp2 < $gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname) } {

set gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname) $my_tmp2

}

}
} else {

# If no improvement is required on external net in first calculation 

set drop_contribution_ext_net $worst_drop_net($rgn,$ext_net)

set drop_contribution_int_net [ format "%0.2f" [ expr $worst_drop_net($rgn,$netname) - $gps_switch_drop_profile_avg($rgn,$ext_net,$netname) - $worst_drop_net($rgn,$ext_net) ]]

if { $drop_contribution_int_net >=0 } {
set tmp_sum [ expr $drop_contribution_ext_net + $drop_contribution_int_net ]
} else {
set tmp_sum $drop_contribution_ext_net

puts $sens_log "#INFO : Dropping improvement on internal net since value is negative"
flush $sens_log
}

set ext_ratio [ expr $drop_contribution_ext_net*1.0/$tmp_sum ]

set addl_ext_drop [ format "%0.2f" [ expr $ext_ratio * $gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname)] ]

set my_tmp1 [ format "%0.2f" $addl_ext_drop ]

if {  ![ info exists gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$ext_net) ] } {

set gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$ext_net) $my_tmp1

} else {

if { $my_tmp1 > $gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$ext_net) } {

set gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$ext_net) $my_tmp1

}

}

set my_tmp2 [ format "%0.2f" [ expr $gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname) - $addl_ext_drop ]]

if {  ![ info exists gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname) ] } {

set gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname) $my_tmp2

} else {

if { $my_tmp2 < $gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname) } {

set gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname) $my_tmp2

}

}

# If no improvement is required on external net in first calculation 


}


puts $sens_log "#INFO : Reassigning the IR drop to the external and internal nets"
flush $sens_log

puts $sens_log "#INFO : External Net Contribution to the region : $worst_drop_net($rgn,$ext_net) mV"
flush $sens_log

puts $sens_log "#INFO : Internal Net Contribution to the region : $worst_drop_net($rgn,$netname) mV"
flush $sens_log


puts $sens_log "#INFO : Average Switch Drop in this region is $gps_switch_drop_profile_avg($rgn,$ext_net,$netname)"
flush $sens_log

puts $sens_log "#INFO : After reassignment , Final Drop Improvement on External Net $ext_net in region $rgn is $gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$ext_net) mV"
flush $sens_log

puts $sens_log "#INFO : After reassignment , Final Drop Improvement Required on Internal Net $netname in region $rgn is $gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname) mV"
flush $sens_log

set improvement_need $gps_net_specific_voltage_drop_improvement_needed_per_region($rgn,$netname)

if { $improvement_need > $max_improvement_required } {

set max_improvement_required $improvement_need

set max_improvement_required_perc [ format "%0.2f" [ expr $improvement_need*1.0*100/$worst_drop_net($rgn,$netname) ]]

set max_improvement_required_net $netname

}

}

}

}
}



puts $sens_log "Finished Looping through the nets in this region to get the internal net targets"
flush $sens_log

puts $out_tcl "#INFO : Started Processing Internal Nets"
flush $out_tcl
puts $restore_tcl "#INFO : Started Processing Internal Nets"
flush $restore_tcl

if {  [catch { unset spec_printed } ] == 0} {

}

##### Set Target for Internal Nets Next ######

foreach spc_name $gps_specs_within_region($rgn) {

if { [ lsearch $gps_layers_within_spec($spc_name) $met ] != -1 } {
foreach netname $gps_nets_within_spec($spc_name) {

if { [ info exists gps_switch_int_net($netname) ] } {


if { ![ info exists spec_printed($spc_name) ] } {
set spec_printed($spc_name) 0
}

if { $spec_printed($spc_name) == 0 } {


global gps_ideal_voltage_net
global gps_min_vdd_voltage
global gps_switch_int_net
 

puts $sens_log "#####DEBUG : max improve $max_improvement_required"
flush $sens_log

if { $max_improvement_required != -10000 } {

set layer_width $gps_spec_width_golden($spc_name)

set final_variation_perc [ expr 100 + $max_improvement_required_perc ]
set new_width [ format "%0.3f" [ expr $final_variation_perc*1.0*$layer_width/100 ]]

set mod_width_change [ expr $new_width - $layer_width ]

set layer_spacing $gps_spec_spacing_golden($spc_name)
set grp_pitch $gps_spec_group_pitch_golden($spc_name)

set new_spacing [ format "%0.3f" [ expr $layer_spacing - ( $new_width - $layer_width ) ]]

global gps_nets_within_spec
set num_layers_in_spec [ llength $gps_nets_within_spec($spc_name) ]


### check if the width constraints are violation ####



if { [ info exists gps_layer_specific_metal_min_width_perc($met) ] && $gps_layer_specific_metal_min_width_perc($met) ne "NA"} {

set layer_min_width [ expr $gps_layer_specific_metal_min_width_perc($met)*1.0*$gps_spec_width_golden($spc_name)/100 ]

} else {

if {  [ info exists gps_global_metal_min_width_perc ] && $gps_global_metal_min_width_perc ne "NA" } {
set layer_min_width [ expr $gps_global_metal_min_width_perc*1.0*$gps_spec_width_golden($spc_name)/100 ]
} else {

set layer_min_width 1000000

}

}

if { [ info exists gps_layer_specific_metal_max_width_perc($met) ] && $gps_layer_specific_metal_max_width_perc($met) ne "NA"} {

set layer_max_width [ expr $gps_layer_specific_metal_max_width_perc($met)*1.0*$gps_spec_width_golden($spc_name)/100 ]

} else {

if {  [ info exists gps_global_metal_max_width_perc ] && $gps_global_metal_max_width_perc ne "NA" } {
set layer_max_width [ expr $gps_global_metal_max_width_perc*1.0*$gps_spec_width_golden($spc_name)/100 ]
} else {

# Limiting max width increase to 5X percentage if there are no global or layer specific constraints .

set layer_max_width [ expr 500*1.0*$gps_spec_width_golden($spc_name)/100 ]

}

}


# Make sure that spacing between the wires is minimum of 10 nm
# If there is a spacing violation . set variable spacing_violation to 1

global gps_spec_group_pitch
global gps_spec_spacing

set num_layers_in_spec [ llength $gps_nets_within_spec($spc_name) ]

set spacing_violation 0

flush $sens_log

if { $gps_spec_spacing($spc_name) != 0 && $new_spacing < 0.010 && $num_layers_in_spec != 1} {

set spacing_violation 1

}

if { $gps_spec_spacing($spc_name) == 0 && $num_layers_in_spec == 1 && $new_width >= $gps_spec_group_pitch($spc_name) } {

set spacing_violation 1

}


if { $gps_spec_spacing($spc_name) != 0 && $num_layers_in_spec != 1 && $new_spacing >= 0.01} {

set sum_total [ expr $num_layers_in_spec*$new_width + ( $num_layers_in_spec - 1 )*$new_spacing ]

if { $sum_total >= $gps_spec_group_pitch($spc_name) } {

set spacing_violation 1

}

}



if { ( $new_width > $layer_max_width ) && $spacing_violation == 0 } {
set old_width $new_width
set new_width $layer_max_width

if { [ info exists gps_layer_specific_metal_max_width_perc($met) ] && $gps_layer_specific_metal_max_width_perc($met) ne "NA"} {

set new_width_perc_increase [ expr $gps_layer_specific_metal_max_width_perc($met) - 100 ]

} else {

if {  [ info exists gps_global_metal_max_width_perc ] && $gps_global_metal_max_width_perc ne "NA" } {

set new_width_perc_increase [ expr $gps_global_metal_max_width_perc - 100 ]

} else {

set new_width_perc_increase [ format "%0.2f" [ expr ($new_width - $layer_max_width)*1.0*100/$layer_max_width ] ]

}

}

puts $sens_log "#INFO : WARNING Layer $met has hit max width limit of $layer_max_width um . Cannot widen it anymore !"
flush $sens_log

puts $sens_log "#INFO : Old Voltage Drop improvement number is $max_improvement_required mV ( $max_improvement_required_perc % )"
flush $sens_log

set old_max_improvement_required_perc $max_improvement_required_perc

set max_improvement_required [ format "%0.2f" [ expr $old_max_improvement_required_perc*1.0*$new_width/$old_width ] ]

set max_improvement_required_net $netname

set max_improvement_required_perc [ format "%0.2f" [ expr $max_improvement_required*1.0*100/$worst_drop_net($rgn,$netname) ]]

puts $sens_log "#INFO : WARNING Layer $met has hit max width limit of $layer_max_width um . Cannot widen it anymore !"
flush $sens_log

puts $sens_log "#INFO : Resetting Voltage Drop improvement number to $max_improvement_required mV ( $max_improvement_required_perc % )"
flush $sens_log

}

### check if the width constraints are violated ####

### check if spacing or grp pitch constraints are violated 

if { $spacing_violation == 1 } {

puts $sens_log "#INFO : WARNING Layer $met has hit spacing limitation . Maintaining minimum distance of 10 nm between wires "
flush $sens_log

set new_width [ format "%0.3f" [ expr $gps_spec_width($spc_name) + $gps_spec_spacing($spc_name) - 0.01 ] ]
set new_width_perc_increase [ format "%0.3f" [ expr ($new_width-$gps_spec_width($spc_name))*100/$gps_spec_width($spc_name) ] ]

puts $sens_log "#INFO : Resetting layer width to $new_width um . Maintaining minimum distance of 10 nm between wires "
flush $sens_log

set num_layers_in_spec [ llength $gps_nets_within_spec($spc_name) ]

set new_min_grp_pitch_needed [ expr $num_layers_in_spec*$new_width + $num_layers_in_spec*0.01 ]

set grp_pitch_diff [ expr $new_min_grp_pitch_needed - $gps_spec_group_pitch($spc_name) ]

if { $grp_pitch_diff > 0 } {

puts $sens_log "#INFO : Group Pitch getting violated"

set width_decrease [ expr $grp_pitch_diff*1.0/$num_layers_in_spec ]

set new_width [ format "%0.3f" [ expr $new_width - $width_decrease ] ]
set new_width_perc_increase [ format "%0.3f" [ expr ($new_width-$gps_spec_width($spc_name))*100/$gps_spec_width($spc_name) ] ]

puts $sens_log "#INFO : Resetting layer width to $new_width um Maintaining minimum spacing and group pitch of 10 nm between wires "
flush $sens_log

}


if { $gps_spec_spacing($spc_name) != 0 && $num_layers_in_spec != 1 && $new_spacing >= 0.01 } {

set sum_total [ expr $num_layers_in_spec*$new_width + ( $num_layers_in_spec - 1 )*$new_spacing ]

while { $sum_total >= $gps_spec_group_pitch($spc_name)  } {

set sum_total [ expr $num_layers_in_spec*$new_width + ( $num_layers_in_spec - 1 )*$new_spacing ]

set amount_exceeded [ format "%0.3f" [ expr $sum_total - $gps_spec_group_pitch($spc_name) + 0.01 ] ]

set new_width [ format "%0.3f" [ expr $new_width - ($amount_exceeded*1.0/$num_layers_in_spec) ] ]

set new_spacing [ format "%0.3f" [ expr $new_spacing + ($amount_exceeded*1.0/$num_layers_in_spec) ] ]

}

}



if { $new_spacing < 0.01 } {

set new_spacing 0.01
foreach nt_name $gps_nets_within_spec($spc_name) {

}

}


### check if spacing or grp pitch constraints are violated 

if { $max_improvement_required > 0 } {

if { $layer_spacing  == 0 || $num_layers_in_spec == 1} {

puts $out_tcl "# MAX DROP_IMPROVEMENT NEEDED FOR THIS MESH SPEC WAS $max_improvement_required mV ( $max_improvement_required_perc % )"
flush $out_tcl
if { $gps_vary_group_pitch_keeping_spacing_constant == 0 } {

puts $out_tcl "db edit $spc_name -width $new_width\n"

flush $out_tcl

}

if { $gps_vary_group_pitch_keeping_spacing_constant == 1 } {

set mod_grp_pitch [ format "%0.3f" [ expr $grp_pitch + $mod_width_change ] ]

puts $out_tcl "db edit $spc_name -width $new_width -pitch $mod_grp_pitch\n"

flush $out_tcl


}

if { ![ info exists gps_sensitivity_width_change_perc_guessed($spc_name,$met) ]} {

set gps_sensitivity_width_change_perc_guessed($spc_name,$met) $max_improvement_required_perc

} else {

if { $max_improvement_required_perc > $gps_sensitivity_width_change_perc_guessed($spc_name,$met) } {
set gps_sensitivity_width_change_perc_guessed($spc_name,$met) $max_improvement_required_perc
}

}

flush $out_tcl
} else {

puts $out_tcl "# MAX DROP_IMPROVEMENT NEEDED FOR THIS MESH SPEC WAS $max_improvement_required mV ( $max_improvement_required_perc % )"
flush $out_tcl
set new_width [ format "%0.3f" [ expr $final_variation_perc*1.0*$layer_width/100 ]]

set mod_width_change [ expr $new_width - $layer_width ]

set new_spacing [ format "%0.3f" [ expr $layer_spacing - ( $new_width - $layer_width ) ]]

if { $new_spacing < 0.01 } {

set new_spacing 0.01

set new_width [ format "%0.3f" [ expr $layer_width + $layer_spacing - 0.01 ] ]

}

if { $gps_vary_group_pitch_keeping_spacing_constant == 1 } {

set mod_grp_pitch [ format "%0.3f" [ expr $grp_pitch + $num_layers_in_spec*$mod_width_change ] ]

puts $out_tcl "db edit $spc_name -width $new_width -pitch $mod_grp_pitch -spacing $layer_spacing\n"

flush $out_tcl

}

if { $gps_vary_group_pitch_keeping_spacing_constant == 0 } {

puts $out_tcl "db edit $spc_name -width $new_width -spacing $new_spacing\n"
flush $out_tcl

}

if { ![ info exists gps_sensitivity_width_change_perc_guessed($spc_name,$met) ]} {

set gps_sensitivity_width_change_perc_guessed($spc_name,$met) $max_improvement_required_perc

} else {

if { $max_improvement_required_perc > $gps_sensitivity_width_change_perc_guessed($spc_name,$met) } {
set gps_sensitivity_width_change_perc_guessed($spc_name,$met) $max_improvement_required_perc
}

}

}


puts $restore_tcl "db edit $spc_name -width $layer_width -spacing $layer_spacing -pitch $gps_spec_group_pitch_golden($spc_name)\n"
flush $restore_tcl

} else {

puts $out_tcl "#INFO : Max Improvement required for region $rgn and net $max_improvement_required_net is $max_improvement_required ($max_improvement_required_perc %) . Hence Dropping Optimization in this region and net ."
flush $out_tcl

}

set spec_printed($spc_name) 1


}


if { ( $new_width < $layer_max_width ) && ( $new_width > $layer_min_width ) && $spacing_violation == 0 } {
puts $out_tcl "#INFO : Max Improvement required for region $rgn and net $max_improvement_required_net is $max_improvement_required ($max_improvement_required_perc %) . Hence Dropping Optimization in this region and net ."
flush $out_tcl

puts $out_tcl "db edit $spc_name -width $new_width -spacing $new_spacing\n"
flush $out_tcl

}

}

}


}

}
} else {


}

}

puts $out_tcl "#INFO : Finished Processing Internal Nets"
flush $out_tcl
puts $restore_tcl "#INFO : Finished Processing Internal Nets"
flush $restore_tcl

##### Set Target for Internal Nets Next ######

}

close $out_tcl
close $restore_tcl



foreach entry_name1 [ array names gps_sensitivity_width_change_perc_guessed ] {
puts $glob_var "set gps_sensitivity_width_change_perc_guessed($entry_name1) $gps_sensitivity_width_change_perc_guessed($entry_name1)"
}

close $glob_var

puts $sens_log "INFO : Started Sorting Unique Specs in TCL File $gps_output_dir/sensitivity_checks/sensitivity_specs/edit_tcls/edit_mesh_$count.tcl"
flush $sens_log
if { [ catch { unset best_spc_command } ] == 0 } {

}

if { [ catch { unset best_spc_width } ] == 0 } {

}

set tmp_edt [ open "$gps_output_dir/sensitivity_checks/sensitivity_specs/edit_tcls/tmp_edit_mesh_$count.tcl" r ]
set edt [ open "$gps_output_dir/sensitivity_checks/sensitivity_specs/edit_tcls/edit_mesh_$count.tcl" w ]

while { [ gets $tmp_edt line ] >= 0 } {
set words [ split $line " " ]

if { [ regexp "#EDIT MESH TCL" $line] } {
set layer_info $line
}

if { [ regexp "#REGION " $line] } {
set tmp_info $line
lappend avl_regions $tmp_info
}

if { [ regexp "db edit" $line ] } { 
set wdt [ lindex $words 6 ]
set spc_name [ lindex $words 4 ]
set spc_command $line

if { ![ info exists best_spc_command($spc_name) ] } {
set best_spc_command($spc_name) $spc_command
set best_spc_width($spc_name) $wdt
} else {

if { $wdt > $best_spc_width($spc_name) } {
set best_spc_command($spc_name) $spc_command
set best_spc_width($spc_name) $wdt

}

} 

}

}

puts $edt "$layer_info\n"
if { [ info exists avl_regions ] } {
foreach rgn_info $avl_regions {
if { ! [info exists already_printed($rgn_info) ] } {
puts $edt "$rgn_info"
set already_printed($rgn_info) 1
}
}
}
flush $edt
if { [ catch { unset already_printed } ] == 0 } {

}

foreach spc [ array names best_spc_width ] {
puts $edt "$best_spc_command($spc)\n"
}


close $edt
close $tmp_edt

puts $sens_log "INFO : Finished Sorting Unique Specs in TCL File $gps_output_dir/sensitivity_checks/sensitivity_specs/edit_tcls/edit_mesh_$count.tcl"
flush $sens_log

if { [ catch { unset best_spc_command } ] == 0 } {

}

if { [ catch { unset best_spc_width } ] == 0 } {

}
if { [ catch { unset layer_info } ] == 0 } {

}

if { [ catch { unset avl_regions } ] == 0 } {

}

puts $sens_log "INFO : Started Sorting Unique Specs in TCL File $gps_output_dir/sensitivity_checks/sensitivity_specs/edit_tcls/restore_mesh_$count.tcl"
flush $sens_log

set tmp_edt [ open "$gps_output_dir/sensitivity_checks/sensitivity_specs/edit_tcls/tmp_restore_mesh_$count.tcl" r ]
set edt [ open "$gps_output_dir/sensitivity_checks/sensitivity_specs/edit_tcls/restore_mesh_$count.tcl" w ]

while { [ gets $tmp_edt line ] >= 0 } {
set words [ split $line " " ]
if { [ regexp "#TCL TO DO RESTORE THE" $line] } {
set layer_info $line
}

if { [ regexp "#REGION " $line] } {
set tmp_info $line
lappend avl_regions $tmp_info
}

if { [ regexp "db edit" $line ] } { 
set wdt [ lindex $words 4 ]
set spc_name [ lindex $words 2 ]
set spc_command $line


if { ![ info exists best_spc_command($spc_name) ] } {
set best_spc_command($spc_name) $spc_command
set best_spc_width($spc_name) $wdt
} else {

if { $wdt > $best_spc_width($spc_name) } {
set best_spc_command($spc_name) $spc_command
set best_spc_width($spc_name) $wdt

}

} 

}
}

puts $edt "$layer_info\n"
if { [ info exists avl_regions ] } {
foreach rgn_info $avl_regions {
if { ! [info exists already_printed($rgn_info) ] } {
puts $edt "$rgn_info"
set already_printed($rgn_info) 1
}
}
}
flush $edt
if { [ catch { unset already_printed } ] == 0 } {

}

foreach spc [ array names best_spc_width ] {
puts $edt "$best_spc_command($spc)\n"
}


close $edt
close $tmp_edt

puts $sens_log "INFO : Finished Sorting Unique Specs in TCL File $gps_output_dir/sensitivity_checks/sensitivity_specs/edit_tcls/restore_mesh_$count.tcl"
flush $sens_log


}

#############################

close $top_sens_tcl

set rpt [ open "$gps_output_dir/sensitivity_checks/sensitivity_specs/gps_region_specific_voltage_target_report.tcl" w ]

puts $rpt "global gps_net_specific_target_drop_per_region\nglobal gps_net_specific_voltage_drop_improvement_needed_per_region\n"



if { [ info exists gps_net_specific_voltage_drop_improvement_needed_per_region]} {
foreach entry_name [ array names  gps_net_specific_voltage_drop_improvement_needed_per_region ] {

puts $rpt "set gps_net_specific_voltage_drop_improvement_needed_per_region($entry_name) $gps_net_specific_voltage_drop_improvement_needed_per_region($entry_name)"

set my_entries [ split $entry_name "," ]
set my_region [ lindex $my_entries 0 ]
set my_netname [ lindex $my_entries 1 ]

set gps_net_specific_target_drop_per_region($my_region,$my_netname) [ expr $worst_drop_net($my_region,$my_netname) - $gps_net_specific_voltage_drop_improvement_needed_per_region($my_region,$my_netname) ]

puts $rpt "set gps_net_specific_target_drop_per_region($my_region,$my_netname) $gps_net_specific_target_drop_per_region($my_region,$my_netname)"

flush $rpt
}
}

close $rpt

close $sens_log
}
proc gps_perform_after_sensitivity_analysis { args } {

global gps_vary_group_pitch_keeping_spacing_constant

set gps_vary_group_pitch_keeping_spacing_constant 0

# Start Reading Arguments
set state flag
set argv [split $args]

global gps_output_dir
global gps_main_iterative_analysis_number


file mkdir $gps_output_dir/main_iterations

file mkdir $gps_output_dir/main_iterations/iteration_$gps_main_iterative_analysis_number

set log [ open "$gps_output_dir/main_iterations/iteration_$gps_main_iterative_analysis_number/iteration.log" w ]

set layer_hit [ open "$gps_output_dir/main_iterations/iteration_$gps_main_iterative_analysis_number/layer_width_already_hit" w ]

puts $layer_hit "global gps_layer_max_width_limit_hit"

puts $layer_hit "if \{ \[ info exists gps_layer_max_width_limit_hit \] \} \{\nunset gps_layer_max_width_limit_hit\n\}"

puts $layer_hit "global gps_layer_max_width_limit_hit"
flush $layer_hit
set old_main_iteration_number [ expr $gps_main_iterative_analysis_number - 1 ]

if { $gps_main_iterative_analysis_number > 1} {
puts $log "INFO : Started Reading Width Restricted layers from $gps_output_dir/main_iterations/iteration_$old_main_iteration_number/layer_width_already_hit"

if { [ catch { source $gps_output_dir/main_iterations/iteration_$old_main_iteration_number/layer_width_already_hit } ] == 0} {

puts $log "INFO : Finished Reading Width Restricted layers from $gps_output_dir/main_iterations/iteration_$old_main_iteration_number/layer_width_already_hit"

} else {

puts $log "INFO : Error Reading Width Restricted layers from $gps_output_dir/main_iterations/iteration_$old_main_iteration_number/layer_width_already_hit"

}
}
global gps_net_specific_target_drop_per_region
global gps_net_specific_voltage_drop_improvement_needed_per_region

puts $log "INFO : Started Reading Net Specific Targets from $gps_output_dir/sensitivity_checks/sensitivity_specs/gps_region_specific_voltage_target_report.tcl"
flush $log
if { [ file exists $gps_output_dir/sensitivity_checks/sensitivity_specs/gps_region_specific_voltage_target_report.tcl ] } {
if { [ catch { source $gps_output_dir/sensitivity_checks/sensitivity_specs/gps_region_specific_voltage_target_report.tcl} ] == 0 } {

puts $log "INFO : Finished Reading Net Specific Targets from $gps_output_dir/sensitivity_checks/sensitivity_specs/gps_region_specific_voltage_target_report.tcl"
flush $log
} else {

puts $log "INFO : Error Reading Net Specific Targets from $gps_output_dir/sensitivity_checks/sensitivity_specs/gps_region_specific_voltage_target_report.tcl"
flush $log
}
}

set found_region_section 0
set found_net_section 0
set found_layer_section 0

if { $gps_main_iterative_analysis_number == 1} {
# Load Golden Variables if called first time
puts $log "INFO : Started Reading Constraints from Input Constraints File $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables"

if { [ catch { source $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables } ] == 0} {

puts $log "INFO : Finished Reading Constraints from Input Constraints File $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables"

} else {
puts $log "INFO : ERROR Reading Constraints from Input Constraints File $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables"
global errorInfo
puts $log "$errorInfo"
return
}


if { [ catch { source $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables_mesh_params_only } ] == 0} {

puts $log "INFO : Finished Reading Constraints from Input Constraints File $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables_mesh_params_only"

} else {
puts $log "INFO : ERROR Reading Constraints from Input Constraints File $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables_mesh_params_only"
global errorInfo
puts $log "$errorInfo"
return
}


#
} else {

# Read All Constraints from input constraint file

set const_file [ glob *optInput ]


set old_main_iterative_analysis_number [ expr $gps_main_iterative_analysis_number - 1 ]

puts $log "INFO : Started Reading Constraints from Input Constraints File $const_file"

if { [ catch { gps_read_constraint_file -golden_run 0 -input_file $const_file -output_file $gps_output_dir/main_iterations/iteration_$old_main_iterative_analysis_number/constraints_global_variables} ] == 0 } {

if { [ catch {source $gps_output_dir/main_iterations/iteration_$old_main_iterative_analysis_number/constraints_global_variables } ] == 0 } {
puts $log "INFO : Finished Reading Constraints from Input Constraints File $gps_output_dir/main_iterations/iteration_$old_main_iterative_analysis_number/constraints_global_variables"
} else {
puts $log "INFO : ERROR Reading Constraints from Input Constraints File $gps_output_dir/main_iterations/iteration_$old_main_iterative_analysis_number/constraints_global_variables"
global errorInfo
puts $log "$errorInfo"
flush $log
return
}

} else {
puts $log "INFO : ERROR Reading Constraints from Input Constraints File $gps_output_dir/main_iterations/iteration_$old_main_iterative_analysis_number/constraints_global_variables"
global errorInfo
puts $log "$errorInfo"
flush $log
return
}


if { [ catch { source $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables_mesh_params_only } ] == 0} {

puts $log "INFO : Finished Reading Constraints from Input Constraints File $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables_mesh_params_only"

} else {
puts $log "INFO : ERROR Reading Constraints from Input Constraints File $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables_mesh_params_only"
global errorInfo
puts $log "$errorInfo"
return
}


}

puts $log "INFO : Started Reading Sensitivity Indices from File $gps_output_dir/sensitivity_checks/load_metal_sensitivity_settings"
flush $log
if { [ catch { source $gps_output_dir/sensitivity_checks/load_metal_sensitivity_settings } ] == 0 } {

puts $log "INFO : Finished Reading Sensitivity Indices from File $gps_output_dir/sensitivity_checks/load_metal_sensitivity_settings"

} else {

puts $log "INFO : ERROR Reading Sensitivity Indices from File $gps_output_dir/sensitivity_checks/load_metal_sensitivity_settings"
flush $log
}


puts $log "INFO : Started Reading Top Sensitive Layers From $gps_output_dir/sensitivity_checks/sensitivity_specs/load_top_sensitive_layer_settings"

if { [ catch { source $gps_output_dir/sensitivity_checks/sensitivity_specs/load_top_sensitive_layer_settings} ] == 0 } {
puts $log "INFO : Finished Reading Top Sensitive Layers From $gps_output_dir/sensitivity_checks/sensitivity_specs/load_top_sensitive_layer_settings"
flush $log

} else {
puts $log "INFO : ERROR Reading Top Sensitive Layers From $gps_output_dir/sensitivity_checks/sensitivity_specs/load_top_sensitive_layer_settings"
flush $log
global errorInfo
puts $log "$errorInfo"
flush $log
}


global gps_ideal_voltage_net
global gps_min_vdd_voltage


if { $gps_main_iterative_analysis_number == 1} {

set mesh_rpt [ open "$gps_output_dir/sensitivity_checks/sensitivity_specs/MESH_analysis.rpt" r ]

} else {

set old_main_iterative_analysis_number [ expr $gps_main_iterative_analysis_number - 1 ]

puts $log "INFO : Started dumping IR drop for nodes in the design in $gps_output_dir/main_iterations/iteration_$old_main_iterative_analysis_number/ir.txt"
flush $log

set fname "$gps_output_dir/main_iterations/iteration_$old_main_iterative_analysis_number/ir.txt"
report ir -routing -limit 0 -o $fname
puts $log "INFO : Finished dumping IR drop for nodes in the design in $gps_output_dir/main_iterations/iteration_$old_main_iterative_analysis_number/ir.txt"
flush $log

puts $log "INFO : Started Writing Mesh Analysis Report to $gps_output_dir/main_iterations/iteration_$old_main_iterative_analysis_number/MESH_analysis.rpt File"
flush $log
if { [ catch { gps_analyze_mesh -output_dir $gps_output_dir/main_iterations/iteration_$old_main_iterative_analysis_number } ] == 0 } {
puts $log "INFO : Finished Writing Mesh Analysis Report to $gps_output_dir/main_iterations/iteration_$old_main_iterative_analysis_number/MESH_analysis.rpt File"
flush $log
} else {
puts $log "INFO : ERROR Writing Mesh Analysis Report to $gps_output_dir/main_iterations/iteration_$old_main_iterative_analysis_number/MESH_analysis.rpt File"
global errorInfo
puts $log "$errorInfo"
flush $log

}

set mesh_rpt [ open "$gps_output_dir/main_iterations/iteration_$old_main_iterative_analysis_number/MESH_analysis.rpt" r ]

}

global gps_change_in_voltage_drop_per_layer_from_sensitivity
if { [ info exists gps_change_in_voltage_drop_per_layer_from_sensitivity ] } {
unset gps_change_in_voltage_drop_per_layer_from_sensitivity
}

while { [ gets $mesh_rpt line ] >= 0} {

if { $line ne "" } {

regsub -all {\t} $line " " line0
regsub -all -- {[[:space:]]+} $line0 " " line1
regsub -all -- {^\s+} $line1 " " line2

set words [ split $line2 " " ]

if { $found_region_section == 0 && [ regexp "#REGION" $line2 ] } {
set region_name [ lindex $words 1 ]
#if { ![ info exists gps_excluded_regions_within_region($region_name)] } {

set found_region_section 1
puts $log "\nINFO : #REGION $region_name"
flush $log

#}

}

if { $found_region_section == 1 && [ regexp "#END_REGION" $line2 ] } {
set found_region_section 0 ;
puts $log "INFO : #END_REGION\n"
flush $log
}

if { $found_region_section == 1 && [regexp "#NET" $line2 ] } {
set found_net_section 1
set words [ split $line2 " " ]
set netname1 [ lindex $words 1 ]
regsub -all -- {[[:space:]]+} $netname1 "" netname
if { $gps_net_edit_allowed($netname) == 1 } {
puts $log "\nINFO : #NET $netname"
flush $log

set total_sensitivity_number 0
set proceed_after_net 0

if { [ info exists gps_top_sensitive_layers_in_region($region_name,$netname) ] } {

foreach met_id $gps_top_sensitive_layers_in_region($region_name,$netname) {

if { [ info exists gps_metal_sensitivity_index($region_name,$netname,$met_id) ] } {

set total_sensitivity_number [ expr $gps_metal_sensitivity_index($region_name,$netname,$met_id) + $total_sensitivity_number ]

set proceed_after_net 1

}

}

}

if { $proceed_after_net == 0 } {
set found_net_section 0
}

set filtered_sensitive_layers($region_name,$netname) { }
set dropped_sensitive_layers($region_name,$netname) { }
set final_total_sensitivity_number 0


if { [ info exists gps_top_sensitive_layers_in_region($region_name,$netname) ]} {

foreach met_id $gps_top_sensitive_layers_in_region($region_name,$netname) {

set any_spec_available_in_layer 0

set specs_editable [ array names gps_layer_max_width_limit_hit $region_name,$netname,$met_id,* ]

if { $specs_editable ne "" } {

foreach spec_entry $specs_editable {

if { $gps_layer_max_width_limit_hit($spec_entry) == 0 } {
set any_spec_available_in_layer 1
}

}

} else {

set any_spec_available_in_layer 1

}

if { [ info exists gps_metal_sensitivity_index($region_name,$netname,$met_id) ] && $gps_metal_sensitivity_index($region_name,$netname,$met_id) != 0 && $any_spec_available_in_layer == 1 && $total_sensitivity_number != 0} {


set metal_sensitivity_ratio($region_name,$netname,$met_id) [ format "%0.3f" [ expr $gps_metal_sensitivity_index($region_name,$netname,$met_id)*1.0/$total_sensitivity_number ]]

if { $metal_sensitivity_ratio($region_name,$netname,$met_id) >= 0.2 } {
lappend filtered_sensitive_layers($region_name,$netname) $met_id
set final_total_sensitivity_number [ expr $gps_metal_sensitivity_index($region_name,$netname,$met_id) + $final_total_sensitivity_number ]
puts $log "INFO : Sensitive Layer $met_id selected since sensitivity ratio is $metal_sensitivity_ratio($region_name,$netname,$met_id) is high . Sensitivity Index = $gps_metal_sensitivity_index($region_name,$netname,$met_id)"
flush $log
} else {
lappend dropped_sensitive_layers($region_name,$netname) $met_id
puts $log "INFO : Sensitive Layer $met_id dropped since sensitivity ratio is $metal_sensitivity_ratio($region_name,$netname,$met_id) is low . Sensitivity Index = $gps_metal_sensitivity_index($region_name,$netname,$met_id)"
flush $log
}

}

}

#### Retreiving Dropped Layers if nothing is available ####

if {$final_total_sensitivity_number == 0 } {

foreach met_id $gps_top_sensitive_layers_in_region($region_name,$netname) {

set any_spec_available_in_layer 0

set specs_editable [ array names gps_layer_max_width_limit_hit $region_name,$netname,$met_id,* ]

if { $specs_editable ne "" } {

foreach spec_entry $specs_editable {

if { $gps_layer_max_width_limit_hit($spec_entry) == 0 } {
set any_spec_available_in_layer 1
}

}

} else {

set any_spec_available_in_layer 1

}

if { [ info exists gps_metal_sensitivity_index($region_name,$netname,$met_id) ] && $gps_metal_sensitivity_index($region_name,$netname,$met_id) != 0 && $any_spec_available_in_layer == 1 && $total_sensitivity_number != 0} {


set metal_sensitivity_ratio($region_name,$netname,$met_id) [ format "%0.3f" [ expr $gps_metal_sensitivity_index($region_name,$netname,$met_id)*1.0/$total_sensitivity_number ]]

lappend filtered_sensitive_layers($region_name,$netname) $met_id
set final_total_sensitivity_number [ expr $gps_metal_sensitivity_index($region_name,$netname,$met_id) + $final_total_sensitivity_number ]
puts $log "INFO : Sensitive Layer $met_id re-selected since no other layers are available . Sensitivity Index = $gps_metal_sensitivity_index($region_name,$netname,$met_id)"
flush $log
set dropped_layer_position1 [ lsearch -exact $dropped_sensitive_layers($region_name,$netname) $met_id ]
set new_list [ lreplace $dropped_sensitive_layers($region_name,$netname) $dropped_layer_position1 $dropped_layer_position1 ]
set dropped_sensitive_layers($region_name,$netname) $new_list
puts $log "MY DEBUG10 : $region_name $netname $dropped_sensitive_layers($region_name,$netname)"
flush $log
}

}

}
##### Retreiving Dropped Layers if nothing is available ####



}


}
}

if { $found_net_section == 1 && [regexp "#END_NET" $line2 ] && [ info exists worst_drop_in_net($region_name,$netname) ] } {
set found_net_section 0

if { $gps_net_edit_allowed($netname) == 1 } {

#if { $gps_ideal_voltage_net($netname) != 0 } {
#set target_net_drop [ format "%0.2f" [ expr $gps_net_specific_target_drop_perc($netname)*$gps_ideal_voltage_net($netname)*1000*1.0/100 ] ]
#} else {
#set target_net_drop [ format "%0.2f" [ expr $gps_net_specific_target_drop_perc($netname)*$gps_min_vdd_voltage*1000*1.0/100 ] ]
#}
global gps_net_specific_target_drop_per_region
global gps_net_specific_voltage_drop_improvement_needed_per_region

puts $log "INFO : Found worst IR drop for net $netname as $worst_drop_in_net($region_name,$netname) mV"
puts $log "INFO : Target IR drop for net $netname is $gps_net_specific_target_drop_per_region($region_name,$netname) mV \( $gps_net_specific_target_drop_perc($netname) %\)"
flush $log

set drop_improvement_required($region_name,$netname) [ format "%0.2f" [ expr $worst_drop_in_net($region_name,$netname) - $gps_net_specific_target_drop_per_region($region_name,$netname) ] ]

#set drop_improvement_required($region_name,$netname) $gps_net_specific_voltage_drop_improvement_needed_per_region($region_name,$netname)

 
puts $log "INFO : Improvement Required for $netname is $drop_improvement_required($region_name,$netname) mV"
flush $log

### START SENSITIVE LAYERS SECTION 

if { [llength $filtered_sensitive_layers($region_name,$netname) ] != 0 } {

foreach sensitive_layer $filtered_sensitive_layers($region_name,$netname) {

set drop_contribution_per_sensitive_layer [ format "%0.2f" [ expr $gps_metal_sensitivity_index($region_name,$netname,$sensitive_layer)*1.0*$drop_improvement_required($region_name,$netname)/$final_total_sensitivity_number ]]

puts $log "INFO : Expected Drop Improvement From layer $sensitive_layer is $drop_contribution_per_sensitive_layer mV"
flush $log
global gps_change_in_voltage_drop_per_layer_from_sensitivity

global gps_sensitivity_run_id_number
set directory_id $gps_sensitivity_run_id_number($sensitive_layer) 

puts $log "INFO : Start Loading Sensitivity Voltage Drop Changes from $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$directory_id/voltage_change_by_sensitivity_settings"
flush $log
if { [ catch { source $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$directory_id/voltage_change_by_sensitivity_settings } ] == 0 } {

puts $log "INFO : Finish Loading Sensitivity Voltage Drop Changes from $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$directory_id/voltage_change_by_sensitivity_settings"
flush $log
} else {

puts $log "INFO : ERROR Loading Sensitivity Voltage Drop Changes from $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$directory_id/voltage_change_by_sensitivity_settings"
flush $log
}

global gps_sensitivity_width_variation_perc
global gps_sensitivity_width_change_perc_guessed

puts $log "INFO : Start Loading Sensitivity Width Changes from $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$directory_id/width_change.tcl"
flush $log
if { [ catch { source $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$directory_id/width_change.tcl } ] == 0 } {

puts $log "INFO : Finish Loading Sensitivity Width Changes from $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$directory_id/width_change.tcl"
flush $log
} else {

puts $log "INFO : ERROR Loading Sensitivity Width Changes from $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$directory_id/width_change.tcl"
flush $log
}

foreach spec_name_data [ array names gps_sensitivity_width_change_perc_guessed ] {

set spec_name_data1 [ split $spec_name_data "," ]
set spec_name [ lindex $spec_name_data1 0 ]
set spec_metal [ lindex $spec_name_data1 1 ]

if { [ info exists gps_layer_max_width_limit_hit($region_name,$netname,$spec_metal,$spec_name)] } {
foreach nt_name $gps_nets_within_spec($spec_name) {
puts $layer_hit "set gps_layer_max_width_limit_hit($region_name,$nt_name,$spec_metal,$spec_name) 1"
flush $layer_hit
}
}

if { $spec_metal eq $sensitive_layer } {

if { [ lsearch $gps_specs_within_region($region_name) $spec_name ] != -1 && [ lsearch $gps_nets_within_spec($spec_name) $netname ] != -1 && $gps_change_in_voltage_drop_per_layer_from_sensitivity($region_name,$netname,$sensitive_layer) != 0 } {

puts $log "INFO : During Sensitivity Analysis , By Varying width by $gps_sensitivity_width_change_perc_guessed($spec_name,$spec_metal) % for spec $spec_name Voltage Drop Change Brought About by this layer $sensitive_layer in this region $region_name for this net $netname is $gps_change_in_voltage_drop_per_layer_from_sensitivity($region_name,$netname,$sensitive_layer) mV"
flush $log

### This voltage drop is assigned based on sensitivity index but it does not consider layer width constraints

set perc_width_increase_required_bkp($region_name,$netname,$sensitive_layer) [ format "%0.2f" [ expr ($gps_sensitivity_width_change_perc_guessed($spec_name,$spec_metal)*1.0*$drop_contribution_per_sensitive_layer)/$gps_change_in_voltage_drop_per_layer_from_sensitivity($region_name,$netname,$sensitive_layer) ]]

set drop_contribution_per_sensitive_layer_detail($region_name,$netname,$sensitive_layer) $drop_contribution_per_sensitive_layer

set perc_width_increase_required($region_name,$netname,$sensitive_layer) $perc_width_increase_required_bkp($region_name,$netname,$sensitive_layer)

puts $log "INFO : To ACHIEVE Expected Drop Improvement in layer $sensitive_layer of $drop_contribution_per_sensitive_layer_detail($region_name,$netname,$sensitive_layer) mV , Expected Percentage Increase In Width required is $perc_width_increase_required($region_name,$netname,$sensitive_layer) %"
flush $log

if { ! [ info exists max_perc_width_increase_required($region_name,$netname,$sensitive_layer) ] } {

set max_perc_width_increase_required($region_name,$netname,$sensitive_layer) $perc_width_increase_required($region_name,$netname,$sensitive_layer)

} else {

if { $perc_width_increase_required($region_name,$netname,$sensitive_layer) > $max_perc_width_increase_required($region_name,$netname,$sensitive_layer)} {
set max_perc_width_increase_required($region_name,$netname,$sensitive_layer) $perc_width_increase_required($region_name,$netname,$sensitive_layer)

}

}


}

}

}


}

}
### END SENSITIVE LAYERS SECTION 

### START DROPPED SENSITIVE LAYERS SECTION 
if { [llength $dropped_sensitive_layers($region_name,$netname) ] != 0 } {

foreach sensitive_layer $dropped_sensitive_layers($region_name,$netname) {

set drop_contribution_per_sensitive_layer [ format "%0.2f" [ expr $gps_metal_sensitivity_index($region_name,$netname,$sensitive_layer)*1.0*$drop_improvement_required($region_name,$netname)/$final_total_sensitivity_number ]]

puts $log "INFO : Expected Drop Improvement From layer $sensitive_layer is $drop_contribution_per_sensitive_layer mV"
flush $log
global gps_change_in_voltage_drop_per_layer_from_sensitivity

global gps_sensitivity_run_id_number
set directory_id $gps_sensitivity_run_id_number($sensitive_layer) 

puts $log "INFO : Start Loading Sensitivity Voltage Drop Changes from $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$directory_id/voltage_change_by_sensitivity_settings"
flush $log
if { [ catch { source $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$directory_id/voltage_change_by_sensitivity_settings } ] == 0 } {

puts $log "INFO : Finish Loading Sensitivity Voltage Drop Changes from $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$directory_id/voltage_change_by_sensitivity_settings"
flush $log
} else {

puts $log "INFO : ERROR Loading Sensitivity Voltage Drop Changes from $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$directory_id/voltage_change_by_sensitivity_settings"
flush $log
}

global gps_sensitivity_width_variation_perc
global gps_sensitivity_width_change_perc_guessed

puts $log "INFO : Start Loading Sensitivity Width Changes from $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$directory_id/width_change.tcl"
flush $log
if { [ catch { source $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$directory_id/width_change.tcl } ] == 0 } {

puts $log "INFO : Finish Loading Sensitivity Width Changes from $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$directory_id/width_change.tcl"
flush $log
} else {

puts $log "INFO : ERROR Loading Sensitivity Width Changes from $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$directory_id/width_change.tcl"
flush $log
}

foreach spec_name_data [ array names gps_sensitivity_width_change_perc_guessed ] {

set spec_name_data1 [ split $spec_name_data "," ]
set spec_name [ lindex $spec_name_data1 0 ]
set spec_metal [ lindex $spec_name_data1 1 ]

if { [ info exists gps_layer_max_width_limit_hit($region_name,$netname,$spec_metal,$spec_name)] } {
foreach nt_name $gps_nets_within_spec($spec_name) {
puts $layer_hit "set gps_layer_max_width_limit_hit($region_name,$nt_name,$spec_metal,$spec_name) 1"
flush $layer_hit
}
}

if { $spec_metal eq $sensitive_layer } {

if { [ lsearch $gps_specs_within_region($region_name) $spec_name ] != -1 && [ lsearch $gps_nets_within_spec($spec_name) $netname ] != -1 && $gps_change_in_voltage_drop_per_layer_from_sensitivity($region_name,$netname,$sensitive_layer) != 0 } {

puts $log "INFO : During Sensitivity Analysis , By Varying width by $gps_sensitivity_width_change_perc_guessed($spec_name,$spec_metal) % for spec $spec_name Voltage Drop Change Brought About by this layer $sensitive_layer in this region $region_name for this net $netname is $gps_change_in_voltage_drop_per_layer_from_sensitivity($region_name,$netname,$sensitive_layer) mV"
flush $log

### This voltage drop is assigned based on sensitivity index but it does not consider layer width constraints

set perc_width_increase_required_bkp($region_name,$netname,$sensitive_layer) [ format "%0.2f" [ expr ($gps_sensitivity_width_change_perc_guessed($spec_name,$spec_metal)*1.0*$drop_contribution_per_sensitive_layer)/$gps_change_in_voltage_drop_per_layer_from_sensitivity($region_name,$netname,$sensitive_layer) ]]

set drop_contribution_per_sensitive_layer_detail($region_name,$netname,$sensitive_layer) $drop_contribution_per_sensitive_layer

set perc_width_increase_required($region_name,$netname,$sensitive_layer) $perc_width_increase_required_bkp($region_name,$netname,$sensitive_layer)

puts $log "INFO : To ACHIEVE Expected Drop Improvement in layer $sensitive_layer of $drop_contribution_per_sensitive_layer_detail($region_name,$netname,$sensitive_layer) mV , Expected Percentage Increase In Width required is $perc_width_increase_required($region_name,$netname,$sensitive_layer) %"
flush $log

if { ! [ info exists max_perc_width_increase_required($region_name,$netname,$sensitive_layer) ] } {

set max_perc_width_increase_required($region_name,$netname,$sensitive_layer) $perc_width_increase_required($region_name,$netname,$sensitive_layer)

} else {

if { $perc_width_increase_required($region_name,$netname,$sensitive_layer) > $max_perc_width_increase_required($region_name,$netname,$sensitive_layer)} {
set max_perc_width_increase_required($region_name,$netname,$sensitive_layer) $perc_width_increase_required($region_name,$netname,$sensitive_layer)

}

}


}

}

}


}

}
### END DROPPED SENSITIVE LAYERS SECTION 
puts $log "INFO : #END_NET\n"
flush $log



}

}

if { $found_region_section == 1 && $found_net_section == 1 && [regexp "#<LAYER>" $line2 ] } {
set found_layer_section 1

}

if { $found_region_section == 1 && $found_net_section == 1 && $found_layer_section == 1 && [ regexp "#END_LAYER" $line2 ] } {
set found_layer_section 0
}


if { $found_region_section == 1 && $found_net_section == 1 && $found_layer_section == 1 && ![ regexp "#" $line2 ] } {
set drop [ lindex $words 7 ]
if { ! [ info exists worst_drop_in_net($region_name,$netname) ] } {

set worst_drop_in_net($region_name,$netname) $drop
} else {
if { $drop > $worst_drop_in_net($region_name,$netname) } {
set worst_drop_in_net($region_name,$netname) $drop
}

}
}

}

}

close $mesh_rpt

puts $log "INFO : Started Preparing Final TCL for Main Iteration Number $gps_main_iterative_analysis_number"
flush $log
set final_tcl [ open "$gps_output_dir/main_iterations/iteration_$gps_main_iterative_analysis_number/tmp_edit_mesh.tcl" w ]

foreach data_point [ array names worst_drop_in_net ] {

set my_words1 [ split $data_point "," ]

set region [ lindex $my_words1 0 ]
set netname [ lindex $my_words1 1 ]

set balance_ir_drop($region,$netname) 0

puts $log "DEBUG3 : $balance_ir_drop($region,$netname)"
flush $log

set balance_left 0
set first_time_enter 0
# Run till the balance drop is assigned on all possible layers

if { [ catch { unset sensitive_layer_available } ] == 0 } {

}

puts $log "#INFO : REGION TO BE IMPROVED : $region"
puts $log "#INFO : NET TO BE IMPROVED : $netname"
flush $log

while { ( $first_time_enter == 0 ) || ( $balance_ir_drop($region,$netname) > 0 ) } {

set first_time_enter 1

foreach data_point1 [ array names max_perc_width_increase_required $region,$netname,* ] {

set my_words2 [ split $data_point1 "," ]

set layername [ lindex $my_words2 2 ]

puts $log "MY DEBUG : $layername"

puts $log "DROPPED LAYERS : $dropped_sensitive_layers($region,$netname)"
flush $log

if { $gps_change_in_voltage_drop_per_layer_from_sensitivity($region,$netname,$layername) != 0 && [ lsearch $dropped_sensitive_layers($region,$netname) $layername ] == -1 } {

set sensitive_layer_available($layername) 1

foreach spec_name $gps_specs_within_region($region) {

if { [ lsearch $gps_nets_within_spec($spec_name) $netname ] != -1 && [ lsearch $gps_layers_within_spec($spec_name) $layername ] != -1 &&  [ info exists gps_sensitivity_width_change_perc_guessed($spec_name,$layername) ] } {

if { $drop_contribution_per_sensitive_layer_detail($region,$netname,$layername) >= 0 } {


if { $gps_change_in_voltage_drop_per_layer_from_sensitivity($region,$netname,$layername) >= 0} {
set spec_available_count  [ llength [ array names gps_layer_max_width_limit_hit $region,*,$layername,$spec_name ]]
} else {
set spec_available_count  [ llength [ array names gps_layer_min_width_limit_hit $region,*,$layername,$spec_name ]]
}

} else {

if { $gps_change_in_voltage_drop_per_layer_from_sensitivity($region,$netname,$layername) < 0} {
set spec_available_count  [ llength [ array names gps_layer_min_width_limit_hit $region,*,$layername,$spec_name ]]
} else {
set spec_available_count  [ llength [ array names gps_layer_max_width_limit_hit $region,*,$layername,$spec_name ]]
}

}


puts $log "DEBUG123 : $drop_contribution_per_sensitive_layer_detail($region,$netname,$layername) $gps_change_in_voltage_drop_per_layer_from_sensitivity($region,$netname,$layername) $spec_available_count"
flush $log 

if { $spec_available_count == 0 } {

puts $log "#INFO : SPEC CHOSEN IS : $spec_name"
flush $log

if { ![ info exists balance_ir_drop_layer($region,$netname,$layername) ] } {
set balance_ir_drop_layer($region,$netname,$layername) 0
set layername_chosen_first_time 1
} else {
set layername_chosen_first_time 0
}

if { [ info exists gps_layer_specific_metal_min_width_perc($layername) ] && $gps_layer_specific_metal_min_width_perc($layername) ne "NA"} {
set layer_min_width [ expr $gps_layer_specific_metal_min_width_perc($layername)*1.0*$gps_spec_width_golden($spec_name)/100 ]
} else {

if {  [ info exists gps_global_metal_min_width_perc ] && $gps_global_metal_min_width_perc ne "NA" } {
set layer_min_width [ expr $gps_global_metal_min_width_perc*1.0*$gps_spec_width_golden($spec_name)/100 ]
} else {

set layer_min_width 1000000

}

}

if { [ info exists gps_layer_specific_metal_max_width_perc($layername) ] && $gps_layer_specific_metal_max_width_perc($layername) ne "NA"} {
set layer_max_width [ expr $gps_layer_specific_metal_max_width_perc($layername)*1.0*$gps_spec_width_golden($spec_name)/100 ]
} else {

if {  [ info exists gps_global_metal_max_width_perc ] && $gps_global_metal_max_width_perc ne "NA" } {
set layer_max_width [ expr $gps_global_metal_max_width_perc*1.0*$gps_spec_width_golden($spec_name)/100 ]
} else {

# Limiting max width increase to 5X percentage if there are no global or layer specific constraints .

set layer_max_width [ expr 500*1.0*$gps_spec_width_golden($spec_name)/100 ]

}

}

if { [ info exists drop_contribution_per_sensitive_layer_detail($region,$netname,$layername) ] } {

puts $log "DEBUG : $layername_chosen_first_time $region $netname $layername"
flush $log

if { $layername_chosen_first_time == 1 } {
set ir_drop_required_layer [ format "%0.2f" [ expr $drop_contribution_per_sensitive_layer_detail($region,$netname,$layername)+$balance_ir_drop_layer($region,$netname,$layername) + $balance_ir_drop($region,$netname)]]
} else {
set ir_drop_required_layer [ format "%0.2f" [ expr $balance_ir_drop_layer($region,$netname,$layername) + $balance_ir_drop($region,$netname)]]
}


puts $log "#INFO : BALANCE IR DROP FOR NET $netname : $balance_ir_drop($region,$netname) mV"
puts $log "#INFO : BALANCE IR DROP FOR NET $netname FROM LAYER $layername : $balance_ir_drop_layer($region,$netname,$layername) mV"
puts $log "#INFO : TOTAL IR DROP REQUIRED FROM LAYER $layername FOR NET $netname IN REGION $region : $ir_drop_required_layer mV"
flush $log


set perc_width_increase_required($region,$netname,$layername) [ format "%0.2f" [ expr ($gps_sensitivity_width_change_perc_guessed($spec_name,$layername)*1.0*$ir_drop_required_layer)/$gps_change_in_voltage_drop_per_layer_from_sensitivity($region,$netname,$layername) ]]

if { ![ info exists perc_width_increase_required_spec($region,$netname,$layername,$spec_name) ] } {
set perc_width_increase_required_spec($region,$netname,$layername,$spec_name) $perc_width_increase_required($region,$netname,$layername)
} else {
set perc_width_increase_required($region,$netname,$layername) [ expr $perc_width_increase_required($region,$netname,$layername) + $perc_width_increase_required_spec($region,$netname,$layername,$spec_name)]
}

}

set new_width [ format "%0.3f" [ expr $gps_spec_width($spec_name)*(100+$perc_width_increase_required($region,$netname,$layername))*1.0/100 ]  ]

set num_layers_in_spec [ llength $gps_nets_within_spec($spec_name) ]

if { $gps_spec_spacing($spec_name)  == 0 || $num_layers_in_spec == 1} {

set new_spacing $gps_spec_spacing($spec_name)

} else {

set new_spacing [format "%0.3f" [ expr $gps_spec_spacing($spec_name) - ( $new_width - $gps_spec_width($spec_name) ) ]]

}

# Make sure that spacing between the wires is minimum of 10 nm

set spacing_violation 0

if { $gps_spec_spacing($spec_name) != 0 && $new_spacing < 0.010 && $num_layers_in_spec != 1} {

set spacing_violation 1

}

if { $gps_spec_spacing($spec_name) == 0 && $num_layers_in_spec == 1 && $new_width >= $gps_spec_group_pitch($spec_name) } {

set spacing_violation 1

}


if { $gps_spec_spacing($spec_name) != 0 && $num_layers_in_spec != 1 && $new_spacing >= 0.01} {

set sum_total [ expr $num_layers_in_spec*$new_width + ( $num_layers_in_spec - 1 )*$new_spacing ]

if { $sum_total >= $gps_spec_group_pitch($spec_name) } {

set spacing_violation 1

}

}

global gps_nets_within_spec

set proceed_and_print 1

if { $perc_width_increase_required($region,$netname,$layername) < 0 } {

foreach tmp_netname $gps_nets_within_spec($spec_name) {

if { $drop_improvement_required($region,$tmp_netname) > 0 } {
set proceed_and_print 0
}

}


}


if { ( $new_width <= $layer_max_width ) && ( $new_width >= $layer_min_width ) && $spacing_violation == 0 } {

set num_layers_in_spec [ llength $gps_nets_within_spec($spec_name) ]

if { $gps_spec_spacing($spec_name)  == 0 || $num_layers_in_spec == 1 } {

if { $gps_vary_group_pitch_keeping_spacing_constant == 0 } {


if { $proceed_and_print == 1 } {
puts $final_tcl "db edit $spec_name -width $new_width\n"
flush $final_tcl
}

}

if { $gps_vary_group_pitch_keeping_spacing_constant == 1 } {

set mod_width_change [ expr $new_width - $gps_spec_width($spec_name) ]

set mod_grp_pitch [ format "%0.3f" [ expr $gps_spec_group_pitch($spec_name) + $mod_width_change ] ]

if { $proceed_and_print == 1 } {
puts $final_tcl "db edit $spec_name -width $new_width -pitch $mod_grp_pitch\n"
}
flush $final_tcl


}


} else {

set new_spacing [format "%0.3f" [ expr $gps_spec_spacing($spec_name) - ( $new_width - $gps_spec_width($spec_name) ) ]]

if { $gps_vary_group_pitch_keeping_spacing_constant == 0 } {

if { $proceed_and_print == 1 } {
puts $final_tcl "db edit $spec_name -width $new_width -spacing $new_spacing\n"
}
flush $final_tcl
}


if { $gps_vary_group_pitch_keeping_spacing_constant == 1 } {

set mod_width_change [ format "%0.3f" [ expr $new_width - $gps_spec_width($spec_name) ]]

set num_layers_in_spec [ llength $gps_nets_within_spec($spec_name) ]

set mod_grp_pitch [ format "%0.3f" [ expr $gps_spec_group_pitch($spec_name) + $num_layers_in_spec*$mod_width_change ] ]

if { $proceed_and_print == 1 } {
puts $final_tcl "db edit $spec_name -width $new_width -pitch $mod_grp_pitch -spacing $gps_spec_spacing($spec_name)\n"

flush $final_tcl
}

}


}

foreach balance_left_entry [ array names balance_ir_drop_layer $region,$netname,* ] {

if { $balance_ir_drop_layer($balance_left_entry) > 0 } {
set balance_ir_drop_layer($balance_left_entry) 0
}

}

if { $balance_ir_drop($region,$netname) > 0 } {
set balance_ir_drop($region,$netname) 0
}

puts $log "DEBUG4"
flush $log

puts $log "#INFO : Expected Drop from layer $layername for net $netname in Region $region was $ir_drop_required_layer mV"
puts $log "#INFO : This Expected Drop needs width to be $new_width um which was $perc_width_increase_required($region,$netname,$layername) % increase"

puts $log "DEBUG5"

flush $log

} else {

set old_width $new_width

if { ( $new_width > $layer_max_width ) && $spacing_violation == 0 } {
set new_width $layer_max_width

if { [ info exists gps_layer_specific_metal_max_width_perc($layername) ] && $gps_layer_specific_metal_max_width_perc($layername) ne "NA"} {

set new_width_perc_increase [ expr $gps_layer_specific_metal_max_width_perc($layername) - 100 ]

} else {

if {  [ info exists gps_global_metal_max_width_perc ] && $gps_global_metal_max_width_perc ne "NA" } {

set new_width_perc_increase [ expr $gps_global_metal_max_width_perc - 100 ]

} else {

set new_width_perc_increase [ format "%0.2f" [ expr ($new_width-$gps_spec_width($spec_name))*1.0*100/$gps_spec_width($spec_name) ] ]

}

}

puts $log "#INFO : WARNING Layer $layername has hit max width limit of $layer_max_width um . Cannot widen it anymore !"
flush $log



foreach nt_name $gps_nets_within_spec($spec_name) {
set gps_layer_max_width_limit_hit($region,$nt_name,$layername,$spec_name) 1
puts $layer_hit "set gps_layer_max_width_limit_hit($region,$nt_name,$layername,$spec_name) 1"
flush $layer_hit
}


}

if { ( $new_width < $layer_min_width ) && $spacing_violation == 0} {
set new_width $layer_min_width

if { [ info exists gps_layer_specific_metal_min_width_perc($layername) ] && $gps_layer_specific_metal_min_width_perc($layername) ne "NA"} {

set new_width_perc_increase [ expr 100 - $gps_layer_specific_metal_min_width_perc($layername) ]

} else {

if {  [ info exists gps_global_metal_min_width_perc ] && $gps_global_metal_min_width_perc ne "NA" } {

set new_width_perc_increase [ expr 100 - $gps_global_metal_min_width_perc ]

} 

}


set num_layers_in_spec [ llength $gps_nets_within_spec($spec_name) ]

if { $gps_spec_spacing($spec_name)  == 0 || $num_layers_in_spec == 1 } {

} else {

set new_spacing [format "%0.3f" [ expr $gps_spec_spacing($spec_name) - ( $new_width - $gps_spec_width($spec_name) ) ]]

}

foreach nt_name $gps_nets_within_spec($spec_name) {
set gps_layer_min_width_limit_hit($region,$nt_name,$layername,$spec_name) 1
puts $layer_hit "set gps_layer_min_width_limit_hit($region,$nt_name,$layername,$spec_name) 1"
flush $layer_hit
}

}

if { $spacing_violation == 1 } {

puts $log "#INFO : WARNING Layer $layername has hit spacing limitation . Maintaining minimum distance of 10 nm between wires "
flush $log

set new_width [ format "%0.3f" [ expr $gps_spec_width($spec_name) + $gps_spec_spacing($spec_name) - 0.01 ] ]
set new_width_perc_increase [ format "%0.3f" [ expr ($new_width-$gps_spec_width($spec_name))*100/$gps_spec_width($spec_name) ] ]

puts $log "#INFO : Resetting layer width to $new_width um . Maintaining minimum distance of 10 nm between wires "
flush $log

set num_layers_in_spec [ llength $gps_nets_within_spec($spec_name) ]

set new_min_grp_pitch_needed [ expr $num_layers_in_spec*$new_width + $num_layers_in_spec*0.01 ]

set grp_pitch_diff [ expr $new_min_grp_pitch_needed - $gps_spec_group_pitch($spec_name) ]

if { $grp_pitch_diff > 0 } {

puts $log "#INFO : Group Pitch getting violated"

set width_decrease [ expr $grp_pitch_diff*1.0/$num_layers_in_spec ]

set new_width [ format "%0.3f" [ expr $new_width - $width_decrease ] ]
set new_width_perc_increase [ format "%0.3f" [ expr ($new_width-$gps_spec_width($spec_name))*100/$gps_spec_width($spec_name) ] ]

puts $log "#INFO : Resetting layer width to $new_width um Maintaining minimum spacing and group pitch of 10 nm between wires "
flush $log

}


if { $gps_spec_spacing($spec_name) != 0 && $num_layers_in_spec != 1 && $new_spacing >= 0.01 } {

set sum_total [ expr $num_layers_in_spec*$new_width + ( $num_layers_in_spec - 1 )*$new_spacing ]

while { $sum_total >= $gps_spec_group_pitch($spec_name)  } {

set sum_total [ expr $num_layers_in_spec*$new_width + ( $num_layers_in_spec - 1 )*$new_spacing ]

set amount_exceeded [ format "%0.3f" [ expr $sum_total - $gps_spec_group_pitch($spec_name) + 0.01 ] ]

set new_width [ format "%0.3f" [ expr $new_width - ($amount_exceeded*1.0/$num_layers_in_spec) ] ]

set new_spacing [ format "%0.3f" [ expr $new_spacing + ($amount_exceeded*1.0/$num_layers_in_spec) ] ]

}

}


# 0.01 = 10 nm - min distance between wires
if { $new_width > $layer_max_width } {
set new_width $layer_max_width
set new_width_perc_increase [ expr $gps_layer_specific_metal_max_width_perc($layername) - 100 ]

puts $log "#INFO : WARNING Layer $layername has hit max width limit of $layer_max_width um \( $new_width_perc_increase % increase \) . Cannot widen it anymore !"
flush $log

foreach nt_name $gps_nets_within_spec($spec_name) {
set gps_layer_max_width_limit_hit($region,$nt_name,$layername,$spec_name) 1
puts $layer_hit "set gps_layer_max_width_limit_hit($region,$nt_name,$layername,$spec_name) 1"
flush $layer_hit
}


set num_layers_in_spec [ llength $gps_nets_within_spec($spec_name) ]

if { $gps_spec_spacing($spec_name)  == 0 || $num_layers_in_spec == 1} {

set new_width [ format "%0.3f" [ expr $gps_spec_group_pitch($spec_name) - 0.010 ]]
 
} else {

set new_spacing [ format "%0.3f" [ expr $gps_spec_spacing($spec_name) - ( $new_width - $gps_spec_width($spec_name) ) ] ]

}

} else {

if { $new_spacing < 0.01 } {

set new_spacing 0.01
foreach nt_name $gps_nets_within_spec($spec_name) {
set gps_layer_max_width_limit_hit($region,$nt_name,$layername,$spec_name) 1
puts $layer_hit "set gps_layer_max_width_limit_hit($region,$nt_name,$layername,$spec_name) 1"
flush $layer_hit
}

}

}

}

if { [ info exists drop_contribution_per_sensitive_layer_detail($region,$netname,$layername) ] } {

if { $layername_chosen_first_time == 1 } {
set expected_drop [ format "%0.2f" [ expr $drop_contribution_per_sensitive_layer_detail($region,$netname,$layername)+$balance_ir_drop_layer($region,$netname,$layername) + $balance_ir_drop($region,$netname)]]
} else {
set expected_drop [ format "%0.2f" [ expr $balance_ir_drop_layer($region,$netname,$layername) + $balance_ir_drop($region,$netname)]]
}

puts $log "#INFO : Expected Drop from layer $layername for net $netname in Region $region was $expected_drop mV"
puts $log "#INFO : This Expected Drop needs width to be $old_width um which was $perc_width_increase_required($region,$netname,$layername) % increase"
flush $log
if { $perc_width_increase_required($region,$netname,$layername) != 0 } {

set new_expected_drop [ format "%0.2f" [ expr $expected_drop*1.0*$new_width_perc_increase/$perc_width_increase_required($region,$netname,$layername) ]]

puts $log "#INFO : Now the drop contribution can be only $new_expected_drop mV with new width as $new_width um ( $new_width_perc_increase % )"
flush $log

} else {

set new_expected_drop $expected_drop

}

if { $expected_drop >= 0 } {
set tmp [ expr $expected_drop - $new_expected_drop ]
} else {
set tmp $new_expected_drop
}

set balance_ir_drop_layer($region,$netname,$layername) [ format "%0.2f" $tmp ]

### WARNING CODE ###

set balance_ir_drop($region,$netname) [ expr $balance_ir_drop($region,$netname) + $balance_ir_drop_layer($region,$netname,$layername) ]


### WARNING CODE ###

puts $log "#INFO : Balance IR drop for net $netname in Region $region and layer $layername is $balance_ir_drop_layer($region,$netname,$layername) mV"
flush $log

}

set num_layers_in_spec [ llength $gps_nets_within_spec($spec_name) ]

global gps_nets_within_spec

set proceed_and_print 1

if { $perc_width_increase_required($region,$netname,$layername) < 0 } {
foreach tmp_netname $gps_nets_within_spec($spec_name) {

if { $drop_improvement_required($region,$tmp_netname) > 0 } {
set proceed_and_print 0
}

}


}


if { $gps_spec_spacing($spec_name)  == 0 || $num_layers_in_spec == 1} {

if { $gps_vary_group_pitch_keeping_spacing_constant == 0 } {
if { $proceed_and_print == 1} {
puts $final_tcl "db edit $spec_name -width $new_width\n"
}
flush $final_tcl
}

if { $gps_vary_group_pitch_keeping_spacing_constant == 1 } {

set mod_width_change [ expr $new_width - $gps_spec_width($spec_name) ]

set mod_grp_pitch [ format "%0.3f" [ expr $gps_spec_group_pitch($spec_name) + $mod_width_change ] ]
if { $proceed_and_print == 1} {
puts $final_tcl "db edit $spec_name -width $new_width -pitch $mod_grp_pitch\n"
}
flush $final_tcl


}

} else {

if { $gps_vary_group_pitch_keeping_spacing_constant == 0 } {
if { $proceed_and_print == 1} {
puts $final_tcl "db edit $spec_name -width $new_width -spacing $new_spacing\n"
}
flush $final_tcl
}

if { $gps_vary_group_pitch_keeping_spacing_constant == 1 } {

set mod_width_change [ expr $new_width - $gps_spec_width($spec_name) ]

set num_layers_in_spec [ llength $gps_nets_within_spec($spec_name) ]

set mod_grp_pitch [ format "%0.3f" [ expr $gps_spec_group_pitch($spec_name) + $num_layers_in_spec*$mod_width_change ] ]
if { $proceed_and_print == 1} {
puts $final_tcl "db edit $spec_name -width $new_width -pitch $mod_grp_pitch -spacing $gps_spec_spacing($spec_name)\n"
}
flush $final_tcl

}

}


}

} else {
puts $log "#INFO : Spec $spec_name dropped because it has hit width or spacing limitation "
flush $log
}

}

}

} else {

if { $gps_change_in_voltage_drop_per_layer_from_sensitivity($region,$netname,$layername) == 0 } {
puts $log "#INFO : Dropping Layer $layername in Region $region for Net $netname Since it produced Zero Voltage Change In Sensitivity Analysis"
flush $log
}

if { [ lsearch $dropped_sensitive_layers($region,$netname) $layername ] != -1 } {


puts $log "#INFO : Dropping Layer $layername since its sensitivity index is low"
flush $log

}

}

}

#puts $log "MY DEBUG1 : $layername $region $netname $balance_ir_drop($region,$netname)"
flush $log


if { [ info exists balance_ir_drop_layer ] } {

foreach balance_left_entry [ array names balance_ir_drop_layer $region,$netname,* ] {

set balance_ir_drop($region,$netname) [ format "%0.2f" [ expr $balance_ir_drop($region,$netname) + $balance_ir_drop_layer($balance_left_entry) ]]

}

}

if { [ info exists layername ] && [ info exists balance_ir_drop_layer($region,$netname,$layername)]} {
puts $log "DEBUG1 :$layername $balance_ir_drop_layer($region,$netname,$layername) $balance_ir_drop($region,$netname)"
flush $log
}

set continue_run 1

foreach lyr [ array names sensitive_layer_available ] {
#####
if { $drop_contribution_per_sensitive_layer_detail($region,$netname,$lyr) >= 0 } {

if { $gps_change_in_voltage_drop_per_layer_from_sensitivity($region,$netname,$lyr) >= 0} {
set entries [ array names gps_layer_max_width_limit_hit $region,$netname,$lyr,* ]
} else {
set entries [ array names gps_layer_min_width_limit_hit $region,$netname,$lyr,* ]
}

} else {

if { $gps_change_in_voltage_drop_per_layer_from_sensitivity($region,$netname,$lyr) < 0} {
set entries [ array names gps_layer_min_width_limit_hit $region,$netname,$lyr,* ]
} else {
set entries [ array names gps_layer_max_width_limit_hit $region,$netname,$lyr,* ] 
}

}
#####
if { $entries ne "" } {

foreach entry1 $entries {
#####
if { $drop_contribution_per_sensitive_layer_detail($region,$netname,$lyr) >= 0 } {

if { $gps_change_in_voltage_drop_per_layer_from_sensitivity($region,$netname,$lyr) >= 0} {
if { $gps_layer_max_width_limit_hit($entry1) == 0} {
puts $log "#INFO : LAYERS AVAILABLE AT PRESENT FOR DROP IMPROVEMENT : $lyr"
flush $log
set continue_run 0
}
} else {

}

} else {

if { $gps_change_in_voltage_drop_per_layer_from_sensitivity($region,$netname,$lyr) < 0} {
if { $gps_layer_min_width_limit_hit($entry1) == 0} {
puts $log "#INFO : LAYERS AVAILABLE AT PRESENT FOR DROP IMPROVEMENT : $lyr"
flush $log
set continue_run 0
}
} else {

}

}
#####

}

} else {
puts $log "#INFO : LAYERS AVAILABLE AT PRESENT FOR DROP IMPROVEMENT : $lyr"
flush $log
set continue_run 0
}


}


if { $balance_ir_drop($region,$netname) == 0 } {
puts $log "#INFO : SUCCESS : Utilized all possible layers to meet IR drop of net $netname in region $region"
flush $log
}

if { $continue_run == 1  && [ info exists dropped_sensitive_layers($region,$netname) ] } {

set dropped_sensitive_layers_count [ llength $dropped_sensitive_layers($region,$netname) ]

puts $log "#INFO : WARNING , COULD NOT MEET BALANCE DROP  : $balance_ir_drop($region,$netname) because all sensitive layers have hit layer width constraints !"
flush $log

if { [ info exists dropped_sensitive_layers_count ] && $dropped_sensitive_layers_count != 0 } {

foreach dropped_layer $dropped_sensitive_layers($region,$netname) {

lappend filtered_sensitive_layers($region,$netname) $dropped_layer

puts $log "#INFO : Sensitive Layer $dropped_layer  \( which was dropped earlier  \) is available . Hence reusing it"
flush $log

set continue_run 0

}

set entering_first_time_here 1

foreach dropped_layer $dropped_sensitive_layers($region,$netname) {

if { $entering_first_time_here == 1} {
set search_list $dropped_sensitive_layers($region,$netname)
set dropped_layer_position [ lsearch -exact $search_list $dropped_layer ]
set new_list [ lreplace $search_list $dropped_layer_position $dropped_layer_position ]
puts $log "DEBUG : $search_list $dropped_layer_position $new_list"
flush $log
} else {
set entering_first_time_here 0
set search_list $new_list
set dropped_layer_position [ lsearch -exact $search_list $dropped_layer ]
set new_list [ lreplace $search_list $dropped_layer_position $dropped_layer_position ]
puts $log "DEBUG : $search_list $dropped_layer_position $new_list"
flush $log
}

}

set dropped_sensitive_layers($region,$netname) { }


} else {

puts $log "#INFO : WARNING , COULD NOT MEET BALANCE DROP  : $balance_ir_drop($region,$netname) because all sensitive layers have hit layer width constraints !"
flush $log
set balance_ir_drop($region,$netname) 0
puts $log "DEBUG2 : $balance_ir_drop($region,$netname)"
flush $log
}

}


}

# Run till the balance drop is assigned on all possible layers

}



close $final_tcl
puts $log "INFO : Finished Preparing Final TCL for Main Iteration Number $gps_main_iterative_analysis_number"
flush $log
puts $log "INFO : Started Sorting Unique Specs in TCL File"
flush $log

set tmp_edt [ open "$gps_output_dir/main_iterations/iteration_$gps_main_iterative_analysis_number/tmp_edit_mesh.tcl" r ]
set edt [ open "$gps_output_dir/main_iterations/iteration_$gps_main_iterative_analysis_number/edit_mesh.tcl" w ]

while { [ gets $tmp_edt line ] >= 0 } {
set words [ split $line " " ]
if { [ regexp "db edit" $line ] } { 
set wdt [ lindex $words 4 ]
set spc_name [ lindex $words 2 ]
set spc_command $line

if { ![ info exists best_spc_command($spc_name) ] } {
set best_spc_command($spc_name) $spc_command
set best_spc_width($spc_name) $wdt
} else {

if { $wdt > $best_spc_width($spc_name) } {
set best_spc_command($spc_name) $spc_command
set best_spc_width($spc_name) $wdt

}

} 

}
}

foreach spc [ array names best_spc_width ] {
puts $edt "$best_spc_command($spc)\n"
}


close $edt
close $tmp_edt

puts $log "INFO : Finished Sorting Unique Specs in TCL File"
puts $log "INFO : Final Edit Mesh TCL file is $gps_output_dir/main_iterations/iteration_$gps_main_iterative_analysis_number/edit_mesh.tcl"
flush $log
close $log
close $layer_hit

}
proc gps_perform_sensitivity_analysis { } {

# Global Variables
global gps_output_dir
global gps_ir_mode
global gps_sensitivity_sweep_started
global gps_sensitivity_check_done
global gps_num_sensitivity_iterations
global gps_sensitivity_iteration_number

# Set Initial Sensitivity Iteration Number to 1

if { ! [ info exists gps_sensitivity_iteration_number ] } {
set gps_sensitivity_iteration_number 1
}

# Creating folder for current sensitivity_iteration
file mkdir $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number



# Creating folder for IR results of previous sensitivity_iteration
if { $gps_sensitivity_iteration_number != 1 } {
set gps_sensitivity_iteration_number_old [ expr $gps_sensitivity_iteration_number - 1 ]
file mkdir $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number_old/IR_RESULTS
}

if { $gps_sensitivity_iteration_number <= $gps_num_sensitivity_iterations } {
file copy -force $gps_output_dir/sensitivity_checks/sensitivity_specs/edit_tcls/edit_mesh_$gps_sensitivity_iteration_number.tcl $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number/edit_mesh_$gps_sensitivity_iteration_number.tcl
file copy -force $gps_output_dir/sensitivity_checks/sensitivity_specs/edit_tcls/restore_mesh_$gps_sensitivity_iteration_number.tcl $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number/restore_mesh_$gps_sensitivity_iteration_number.tcl

}
# Creating log file for sensitivity_iteration
set log [ open "$gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number/sensitivity_iteration.log" w ]

# Dump variables for new constraints
puts $log "INFO : Started Sensitivity Iteration Number $gps_sensitivity_iteration_number"
flush $log
puts "INFO : Started Sensitivity Iteration Number $gps_sensitivity_iteration_number"


puts $log "INFO : Started Reading Constraints from Input Constraints File $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables"

if { [ catch { source $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables } ] == 0} {

puts $log "INFO : Finished Reading Constraints from Input Constraints File $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables"

} else {
puts $log "INFO : ERROR Reading Constraints from Input Constraints File $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables"
return
}



if { $gps_sensitivity_iteration_number == 1 } {
file copy -force $gps_output_dir/sensitivity_checks/sensitivity_specs/edit_tcls/edit_mesh_$gps_sensitivity_iteration_number.tcl $gps_output_dir/edit_mesh.tcl
file copy -force $gps_output_dir/sensitivity_checks/sensitivity_specs/edit_tcls/width_change_iteration_$gps_sensitivity_iteration_number.tcl $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number/width_change.tcl
incr gps_sensitivity_iteration_number

puts $log "INFO : Started Saving Sensitivity Settings in file $gps_output_dir/sensitivity_checks/sensitivity_iterations_settings.rpt"
if { [ catch { gps_save_sensitivity_settings} ] == 0 } {
puts $log "INFO : Finished Saving Sensitivity Settings in file $gps_output_dir/sensitivity_checks/sensitivity_iterations_settings.rpt"
} else {
puts $log "INFO : ERROR in Saving Sensitivity Settings in file $gps_output_dir/sensitivity_checks/sensitivity_iterations_settings.rpt"
}
close $log
return
} else {

# Start Open Sensitivity TCL file for the corresponding Iteration Number

if {[ catch { file copy -force $gps_output_dir/sensitivity_checks/sensitivity_specs/edit_tcls/width_change_iteration_$gps_sensitivity_iteration_number.tcl $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number/width_change.tcl} ] == 0 } {

}



set const_file [ glob *optInput ]

puts $log "INFO : Started Dumping Constraints in $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number_old/constraints_global_variables"

if { [ catch { gps_read_constraint_file -golden_run 0 -input_file $const_file -output_file $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number_old/constraints_global_variables} ] == 0 } {

puts $log "INFO : Finished Dumping Constraints in $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number_old/constraints_global_variables"

} else {
puts $log "INFO : ERROR Reading Constraints from $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number_old/constraints_global_variables"
global errorInfo
puts $log "$errorInfo"
flush $log
return
}

if { [ file exists $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number_old/edit_mesh_$gps_sensitivity_iteration_number_old.tcl ] } {
puts $log "INFO : Started Opening Previous Iteration Edit TCL File $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number_old/edit_mesh_$gps_sensitivity_iteration_number_old.tcl"
flush $log

set tcl_file [ open "$gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number_old/edit_mesh_$gps_sensitivity_iteration_number_old.tcl" r ]

while { [ gets $tcl_file line ] >= 0 } {

if { $line ne "" } {

regsub -all {\t} $line " " line0
regsub -all -- {[[:space:]]+} $line0 " " line1
regsub -all -- {^\s+} $line1 " " line2

set words [ split $line2 " " ]

if { [ regexp "#EDIT MESH TCL" $line2] } {
set edit_metal_layer [ lindex $words 9 ]
puts $log "INFO : Sensitivity runs was done earlier on layer $edit_metal_layer"
flush $log
}

if { [ regexp "#REGION " $line2] } {

if { ! [ info exists available_regions ] } {
set available_regions { }
}
set region_name [ lindex $words 1 ]
lappend available_regions $region_name

}
}
}
close $tcl_file
# Finish Open Sensitivity TCL file for the corresponding Iteration Number
puts $log "INFO : Finished Opening Last Iteration Edit TCL File $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number_old/edit_mesh_$gps_sensitivity_iteration_number_old.tcl"
flush $log

}

# Start Dumping IR for all nodes in design
puts $log "INFO : Started dumping IR drop for nodes in the design for last Iteration in $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number_old/ir.txt"
flush $log

set fname "$gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number_old/ir.txt"
puts $log "DEBUG : $fname"

flush $log

report ir -routing -limit 0 -o $fname
puts $log "INFO : Finished dumping IR drop for nodes in the design for last Iteration  in $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number_old/ir.txt"
flush $log


# Finish Dumping IR for all nodes in design

# DUMP IR HISTOGRAM FOR ALL REGIONS in sensitivity_iteration folder
foreach region_id $available_regions {
global gps_region_xll
global gps_region_yll
global gps_region_xur
global gps_region_yur

set gps_sensitivity_iteration_number_old [ expr $gps_sensitivity_iteration_number - 1 ]

GPS_CreateIRHist -ir_text_report $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number_old/ir.txt -dir_name $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number_old/IR_RESULTS/$region_id -resolution 5 -bbox $gps_region_xll($region_id) $gps_region_yll($region_id) $gps_region_xur($region_id) $gps_region_yur($region_id)

puts $log "GPS_CreateIRHist -ir_text_report $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number_old/ir.txt -dir_name $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number_old/IR_RESULTS/$region_id -resolution 5 -bbox $gps_region_xll($region_id) $gps_region_yll($region_id) $gps_region_xur($region_id) $gps_region_yur($region_id)
"
flush $log

}

file mkdir $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number_old/IR_RESULTS/

set ir_results_dir "$gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number_old/IR_RESULTS/"

puts $log "#INFO : Started Getting IR drop profile for all regions"
flush $log

if { [ catch { set spec_file [ glob "*optInput" ] } ] == 0 } {

}

if { [ catch { file copy -force $spec_file $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number_old/$spec_file } ] == 0 } {

}

if { [ catch { rhe get ir_drop_profile -i $spec_file -o $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number_old/IR_RESULTS/ } ] == 0 } {

puts $log "#INFO : Finished Getting IR drop profile for all regions"
flush $log

} else {

puts $log "#INFO : Error Getting IR drop profile for all regions"
flush $log

}

if { $gps_sensitivity_iteration_number <= $gps_num_sensitivity_iterations } {

set gps_sensitivity_iteration_number_old [ expr $gps_sensitivity_iteration_number - 1 ]

# Fetching the Metal Density Profile in previous iteration 
puts $log "INFO :  Fetching the metal density profile from Iteration $gps_sensitivity_iteration_number_old and backing it up in $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number_old/Metal_Density.rpt File"
flush $log

file copy -force Metal_density.rpt $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number_old/Metal_Density.rpt

puts $log "INFO : Started Fetching EDIT TCL for Current Iteration $gps_sensitivity_iteration_number"
flush $log

file copy -force $gps_output_dir/sensitivity_checks/sensitivity_specs/edit_tcls/edit_mesh_$gps_sensitivity_iteration_number.tcl $gps_output_dir/edit_mesh.tcl

set restore_fp [ open "$gps_output_dir/sensitivity_checks/sensitivity_specs/edit_tcls/restore_mesh_$gps_sensitivity_iteration_number_old.tcl" r ]

set restore_data [ read $restore_fp ]

close $restore_fp

set new_tcl_fp [ open "$gps_output_dir/edit_mesh.tcl" a ]
puts $new_tcl_fp "\n$restore_data"
close $new_tcl_fp

puts $log "INFO : Finished Fetching EDIT TCL for Current Iteration $gps_sensitivity_iteration_number"
flush $log

} else {

set gps_sensitivity_iteration_number_old [ expr $gps_sensitivity_iteration_number - 1 ]

# Fetching the Metal Density Profile in previous iteration 
puts $log "INFO :  Fetching the metal density profile from Iteration $gps_sensitivity_iteration_number_old and backing it up in $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number_old/Metal_Density.rpt File"
flush $log

file copy -force Metal_density.rpt $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$gps_sensitivity_iteration_number_old/Metal_Density.rpt

set restore_fp [ open "$gps_output_dir/sensitivity_checks/sensitivity_specs/edit_tcls/restore_mesh_$gps_sensitivity_iteration_number_old.tcl" r ]

set restore_data [ read $restore_fp ]

close $restore_fp

set new_tcl_fp [ open "$gps_output_dir/edit_mesh.tcl" w ]
puts $new_tcl_fp "\n$restore_data"
close $new_tcl_fp
}

incr gps_sensitivity_iteration_number

puts $log "INFO : Started Saving Sensitivity Settings in file $gps_output_dir/sensitivity_checks/sensitivity_iterations_settings.rpt"
if { [ catch { gps_save_sensitivity_settings} ] == 0 } {
puts $log "INFO : Finished Saving Sensitivity Settings in file $gps_output_dir/sensitivity_checks/sensitivity_iterations_settings.rpt"
} else {
puts $log "INFO : ERROR in Saving Sensitivity Settings in file $gps_output_dir/sensitivity_checks/sensitivity_iterations_settings.rpt"
}

close $log
return


}



}

proc gps_save_sensitivity_settings { } {

global gps_output_dir

# GPS Sensitivity Global Variables
global gps_sensitivity_check_on
global gps_sensitivity_sweep_started
global gps_sensitivity_specs_found
global gps_sensitivity_check_done
global gps_sensitivity_iteration_number
global gps_num_sensitivity_iterations
global gps_sensitivity_index_computed


# Store the value of GPS Sensitivity Variables in sensitivity_settings file .

set settings_file [ open "$gps_output_dir/sensitivity_checks/sensitivity_iterations_settings.rpt" w ]

puts $settings_file "
global gps_sensitivity_check_on
global gps_sensitivity_sweep_started
global gps_sensitivity_specs_found
global gps_sensitivity_check_done
global gps_sensitivity_iteration_number
global gps_num_sensitivity_iterations
global gps_sensitivity_index_computed
"

if { [ info exists gps_sensitivity_check_on ] } {
puts $settings_file "set gps_sensitivity_check_on $gps_sensitivity_check_on"
}

if { [ info exists gps_sensitivity_check_done ] } {
puts $settings_file "set gps_sensitivity_check_done $gps_sensitivity_check_done"
}

if { [ info exists gps_sensitivity_sweep_started ] } {
puts $settings_file "set gps_sensitivity_sweep_started $gps_sensitivity_sweep_started"
}

if { [ info exists gps_sensitivity_specs_found ] } {
puts $settings_file "set gps_sensitivity_specs_found $gps_sensitivity_specs_found"
}

if { [ info exists gps_sensitivity_iteration_number ] } {
puts $settings_file "set gps_sensitivity_iteration_number $gps_sensitivity_iteration_number"
}

if { [ info exists gps_num_sensitivity_iterations ] } {
puts $settings_file "set gps_num_sensitivity_iterations $gps_num_sensitivity_iterations"
}

if { [ info exists gps_sensitivity_index_computed ] } {
puts $settings_file "set gps_sensitivity_index_computed $gps_sensitivity_index_computed"
}

close $settings_file
# Store the value of GPS Sensitivity Variables in sensitivity_settings file .

}

proc gps_profile_ir_drop { args } {

# GPS Input Global Variables
global gps_output_dir
global gps_input_file
global gps_ir_mode
global gps_iteration_number

# GPS Sensitivity Global Variables
global gps_sensitivity_check_on
global gps_sensitivity_sweep_started
global gps_sensitivity_specs_found
global gps_sensitivity_check_done
global gps_sensitivity_iteration_number
global gps_num_sensitivity_iterations
global gps_sensitivity_width_variation_perc

# Start Reading Arguments
set state flag
set argv [split $args]

foreach arg $argv {
 	


                switch -- $state {
                        flag {
                                switch -glob -- $arg {
                               
                                        -i { set state input_file }
                                        -o { set state output_dir }
					-iter { set state iter_num }
					-drop_param { set state drop_param }

	
                                }
			}	
			
			input_file {
			set gps_input_file $arg
			set state flag
			}
			
			output_dir {
			set gps_output_dir $arg
			set state flag
			}
			
			iter_num {
			set gps_iteration_number $arg
			set state flag
			}
			
			drop_param {
			set gps_ir_mode $arg
			set state flag
			}
			
			}
			
}
# Finish Reading Arguments

if { [ file exists out ] && $gps_iteration_number == 0 } {
puts "INFO : Detected Presence Of Output Directory \'out\'. Deleting it ." ;
file delete -force out
}

# Check If Input Spec File is present
if { $gps_input_file eq "" } {
puts "ERROR : Input File is not given\n\nUSAGE : gps_profile_ir_drop -i <input_spec_file> -o <gps_output_directory>" ;
return ;
}

# Start Creating Output Directory
if { $gps_output_dir eq "" } {
puts "ERROR : Output File is not given\n\nUSAGE : gps_profile_ir_drop -i <input_spec_file> -o <gps_output_directory>" ;
return ;
} else {
puts  "INFO : Creating Output Directory $gps_output_dir"
if { [ catch { file mkdir  $gps_output_dir } ] == 0 } {

} else {
global env
global errorInfo
puts "INFO : Unable to create output directory $env(PWD)/$gps_output_dir"
puts "INFO : EXITTING\n$errorInfo"
return
}
}
# End Creating Output Directory

# Opening Optimizer Log File
set log [ open "$gps_output_dir/gps_optimizer.log" a ]

# Retrieve the value of GPS Sensitivity Variables from sensitivity_settings file .
if { [ file exists $gps_output_dir/sensitivity_checks/sensitivity_iterations_settings.rpt ] } {
if { [catch { source $gps_output_dir/sensitivity_checks/sensitivity_iterations_settings.rpt } ] == 0 } {
puts  $log "INFO : SUCCESS in loading sensitivity settings from $gps_output_dir/sensitivity_checks/sensitivity_iterations_settings.rpt"
flush $log
} else {
puts  $log "INFO : ERROR in loading sensitivity settings from $gps_output_dir/sensitivity_checks/sensitivity_iterations_settings.rpt"
flush $log
}
}
# Retrieve the value of GPS Sensitivity Variables from sensitivity_settings file .

# Start Setting Initial Values for Sensitivity Variables .
if { ! [ info exists gps_sensitivity_check_on ] } {
set gps_sensitivity_check_on 1
}

if { ![ info exists gps_sensitivity_check_done ] } {
set gps_sensitivity_check_done 0
}

if { ![ info exists gps_sensitivity_sweep_started ] } {
set gps_sensitivity_sweep_started 0
}

if { ![ info exists gps_sensitivity_specs_found ] } {
set gps_sensitivity_specs_found 0
}

if { ![ info exists gps_sensitivity_iteration_number ] } {
set gps_sensitivity_iteration_number 1
}

# Set  the initial value very high 
if { ![ info exists gps_num_sensitivity_iterations ] } {
set gps_num_sensitivity_iterations 1000
}

# Set Sensitivity variation percentage to 20 percent by default
if { ![ info exists gps_sensitivity_width_variation_perc ] } {
set gps_sensitivity_width_variation_perc 20
}

# End Setting Initial Values for Sensitivity Variables

# Start Finding Domain Ideal Voltages
# This will be done only once .
global gps_ideal_voltage_net
global gps_min_vdd_voltage

if { ! [ info exists gps_ideal_voltage_net ] } {

puts $log "INFO : Fetching Supply Voltages for all Power and Ground Nets"

flush $log

set gps_min_vdd_voltage 10000000000

foreach power_net [ get net * -glob -type power ] { 

if { [ catch { set gps_ideal_voltage_net($power_net) [ get net $power_net -ideal_voltage ] } ] == 0 } {

if { $gps_ideal_voltage_net($power_net) < $gps_min_vdd_voltage } {

set gps_min_vdd_voltage $gps_ideal_voltage_net($power_net)

}

} else {
set gps_ideal_voltage_net($power_net) "NA"
}

}

foreach gnd_net [ get net * -glob -type ground ] { 

if { [ catch { set gps_ideal_voltage_net($gnd_net) [ get net $gnd_net -ideal_voltage ] } ] == 0 } {

} else {
set gps_ideal_voltage_net($gnd_net) "NA"
}

}

puts $log "INFO : Found Minimum VDD net voltage to be $gps_min_vdd_voltage V"
flush $log
}
# Finish Finding Domain Ideal Voltages

if { $gps_sensitivity_check_on == 1 && $gps_sensitivity_specs_found == 0 && $gps_sensitivity_sweep_started == 0 && $gps_sensitivity_check_done ==0 } { 
puts $log "INFO : SENSITIVITY ANALYSIS TURNED ON" 
puts $log "WARNING : INCREASE IN RUNTIME IS EXPECTED"
puts "INFO : SENSITIVITY ANALYSIS TURNED ON" 
puts "WARNING : INCREASE IN RUNTIME IS EXPECTED"
flush $log
}



# Start Finding Specs For Sensitivity Analysis
if { $gps_sensitivity_specs_found == 0 && $gps_sensitivity_sweep_started == 0 && $gps_sensitivity_check_done == 0} {
puts "INFO : STARTED FINDING SENSITIVITY SPECS"
puts $log "INFO : STARTED FINDING SENSITIVITY SPECS"
flush $log
if { [ catch { gps_find_sensitivity_specs } ] == 0 } {

puts "INFO : STARTED GETTING FINAL SENSITIVITY ITERATIONS"
puts $log "INFO : STARTED GETTING FINAL SENSITIVITY ITERATIONS"
flush $log

# Call proc gps_find_top_sensitive_layers to get the edit mesh tcls for all sensitivity iterations and to find number of sensitivity iterations required

if { [ catch { gps_find_top_sensitive_layers } ] == 0 } {

puts "INFO : FINISH GETTING FINAL SENSITIVITY ITERATIONS"
puts $log "INFO : FINISH GETTING FINAL SENSITIVITY ITERATIONS"
flush $log
set gps_sensitivity_sweep_started 1
set gps_sensitivity_specs_found 1
} else {
global errorInfo
puts $log "$errorInfo"
flush $log

puts "INFO : ERROR GETTING FINAL SENSITIVITY ITERATIONS"
puts $log "INFO : ERROR GETTING FINAL SENSITIVITY ITERATIONS"
flush $log


}

} else {
puts "INFO : ERROR FINDING SENSITIVITY SPECS" 
puts $log "INFO : ERROR FINDING SENSITIVITY SPECS" 
global errorInfo
puts "$errorInfo"
flush $log
return
}
puts "INFO : FINISH FINDING SENSITIVITY SPECS"
puts $log "INFO : FINISH FINDING SENSITIVITY SPECS" 
flush $log
}
# Finish Finding Specs For Sensitivity Analysis



# Start Sensitivity Analysis Till Iterations are complete
if { $gps_sensitivity_check_on == 1  && $gps_sensitivity_check_done == 0 && $gps_sensitivity_sweep_started == 1} {
puts "INFO : STARTED SENSITIVITY ANALYSIS ITERATION NUMBER $gps_sensitivity_iteration_number"
puts $log "INFO : STARTED SENSITIVITY ANALYSIS ITERATION NUMBER $gps_sensitivity_iteration_number"
flush $log
file mkdir $gps_output_dir/sensitivity_checks/sensitivity_iterations

if { [ catch { gps_perform_sensitivity_analysis } ] == 0 } {

puts "INFO : FINISHED SENSITIVITY ANALYSIS"
puts $log "INFO : FINISHED SENSITIVITY ANALYSIS"

} else {

puts "INFO : ERROR SENSITIVITY ANALYSIS FAILED"
puts $log "INFO : ERROR SENSITIVITY ANALYSIS FAILED"
flush $log
global errorInfo
puts $log "ERROR IS : $errorInfo"
flush $log
}

}

# Check If Sensitivity Iterations are complete .
global gps_num_sensitivity_iterations
global gps_sensitivity_iteration_number
global gps_sensitivity_index_computed

if { $gps_sensitivity_iteration_number > [ expr $gps_num_sensitivity_iterations + 1 ] } {

flush $log

global gps_sensitivity_check_done
global gps_sensitivity_sweep_started

set gps_sensitivity_check_done 1
set gps_sensitivity_sweep_started 0


puts $log "INFO : Started Reading Constraints from Input Constraints File $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables"
flush $log
if { [ catch { source $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables } ] == 0} {

puts $log "INFO : Finished Reading Constraints from Input Constraints File $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables"
flush $log
} else {
puts $log "INFO : ERROR Reading Constraints from Input Constraints File $gps_output_dir/sensitivity_checks/sensitivity_specs/constraints_global_variables"
global errorInfo
puts "$errorInfo"
flush $log
return
}


global gps_metal_sensitivity_index

global gps_sensitivity_index_computed
set not_proceed 0
if { [ info exists gps_sensitivity_index_computed ] && $gps_sensitivity_index_computed == 1} {
set not_proceed 1
}
if { $not_proceed == 0 } {

puts $log "INFO : Started Computing Sensitivity Indices of all sensitive layers"
flush $log


for { set i 1 } { $i <= $gps_num_sensitivity_iterations } { incr i } {

puts $log "INFO : Started Computing Sensitivity Index of Iteration Number $i"
flush $log
if { [ catch { gps_compute_sensitivity_index -golden_dir $gps_output_dir/sensitivity_checks/sensitivity_specs/ -new_dir $gps_output_dir/sensitivity_checks/sensitivity_iterations/iterations_$i } ] == 0 } {

puts $log "INFO : Finished Computing Sensitivity Index of Iteration Number $i"
flush $log
} else {

puts $log "INFO : ERROR Computing Sensitivity Index of Iteration Number $i"
global errorInfo
puts $log "$errorInfo"

flush $log

}

}

puts $log "INFO : Finished Computing Sensitivity Indices of all sensitive layers"
flush $log
global gps_sensitivity_index_computed
set gps_sensitivity_index_computed 1



if { $gps_sensitivity_check_done == 1 } {


global gps_metal_sensitivity_index
set sens_rpt [ open "$gps_output_dir/sensitivity_checks/metal_sensitivity_report.rpt" w ]
set sens_tcl [ open "$gps_output_dir/sensitivity_checks/load_metal_sensitivity_settings" w ]

puts $sens_rpt "<region_id> <region_name> <netname> <metal_layer> <sensitivity_index>\n"
puts $sens_tcl "global gps_metal_sensitivity_index"
global gps_fetch_region_name
foreach data_point [ array names gps_metal_sensitivity_index ] {
set my_words [ split $data_point "," ]
set region_id [ lindex $my_words 0 ]
set region_name $gps_fetch_region_name($region_id)
set netname [ lindex $my_words 1 ]
set metal_layer [ lindex $my_words 2 ]

puts $sens_rpt "$region_id $region_name $netname $metal_layer $gps_metal_sensitivity_index($region_id,$netname,$metal_layer)"
puts $sens_tcl "set gps_metal_sensitivity_index($region_id,$netname,$metal_layer) $gps_metal_sensitivity_index($region_id,$netname,$metal_layer)"



}

close $sens_rpt
close $sens_tcl

}


}



puts $log "INFO : Started Saving Sensitivity Settings in file $gps_output_dir/sensitivity_checks/sensitivity_iterations_settings.rpt"
flush $log
if { [ catch { gps_save_sensitivity_settings} ] == 0 } {
puts $log "INFO : Finished Saving Sensitivity Settings in file $gps_output_dir/sensitivity_checks/sensitivity_iterations_settings.rpt"
flush $log
} else {
puts $log "INFO : ERROR in Saving Sensitivity Settings in file $gps_output_dir/sensitivity_checks/sensitivity_iterations_settings.rpt"
flush $log
}

global gps_metal_sensitivity_index

if { $gps_sensitivity_sweep_started == 1 } {

if { [ catch { file delete -force $gps_output_dir/sensitivity_checks/metal_sensitivity_report.rpt} ] == 0 } {

}

if { [ catch { file delete -force $gps_output_dir/sensitivity_checks/load_metal_sensitivity_settings} ] == 0 } {

}

}





global gps_main_iterative_analysis_number

if { $gps_sensitivity_check_done == 0 } {

if { [ catch { file delete -force $gps_output_dir/main_iterations/iteration_settings} ] == 0 } {

}

}

if { [ catch { source $gps_output_dir/main_iterations/iteration_settings} ] == 0 } {

}

if { ! [ info exists gps_main_iterative_analysis_number ] } {
set gps_main_iterative_analysis_number 1
}

if { $gps_main_iterative_analysis_number < [ expr $gps_num_main_iterations + 1 ]} {

puts $log "INFO : Started Running Main Iteration Number $gps_main_iterative_analysis_number"
flush $log

if { [ catch { gps_perform_after_sensitivity_analysis} ] == 0 } {

puts $log "INFO : Finished Running Main Iteration Number $gps_main_iterative_analysis_number"
flush $log

if { [ file exists $gps_output_dir/main_iterations/iteration_$gps_main_iterative_analysis_number/edit_mesh.tcl ] } {

set main_tcl [ open "$gps_output_dir/main_iterations/iteration_$gps_main_iterative_analysis_number/edit_mesh.tcl" r ]

set main_tcl_content [ read $main_tcl ]

close $main_tcl

if { $gps_main_iterative_analysis_number == 1 } {

set final_main_tcl [ open "$gps_output_dir/edit_mesh.tcl" a ]

puts $final_main_tcl "$main_tcl_content"

close $final_main_tcl
 
} else { 

set final_main_tcl [ open "$gps_output_dir/edit_mesh.tcl" w ]

puts $final_main_tcl "$main_tcl_content"

close $final_main_tcl
 
}
 
} else {
puts $log "INFO : Cannot Find TCL File $gps_output_dir/main_iterations/iteration_$gps_main_iterative_analysis_number/edit_mesh.tcl"
flush $log
return
}

incr gps_main_iterative_analysis_number

set save_tcl [ open "$gps_output_dir/main_iterations/iteration_settings" w ]

puts $save_tcl "set gps_main_iterative_analysis_number $gps_main_iterative_analysis_number"

close $save_tcl


} else {
puts $log "INFO : ERROR Running Main Iteration Number $gps_main_iterative_analysis_number"
global errorInfo
puts $log "$errorInfo"
flush $log
return
}

}

if { $gps_main_iterative_analysis_number == [ expr $gps_num_main_iterations + 1 ] } {

set fp2 [ open "$gps_output_dir/done" w ]

close $fp2
puts $log "INFO : ALL MAIN ITERATIONS COMPLETE"

puts "INFO : ALL MAIN ITERATIONS COMPLETE"

}

}
close $log

#close all file channels
foreach file [ file channels ] { if { [regexp "^file" $file ] } { close $file ; } }

}

proc gps_reset_sensitivity_settings { } {

global gps_output_dir

# GPS Sensitivity Global Variables
global gps_sensitivity_check_on
global gps_sensitivity_sweep_started
global gps_sensitivity_specs_found
global gps_sensitivity_check_done
global gps_sensitivity_iteration_number
global gps_num_sensitivity_iterations
if { [ file exists $gps_output_dir/sensitivity_checks/sensitivity_iterations_settings.rpt ] } {
file delete -force $gps_output_dir/sensitivity_checks/sensitivity_iterations_settings.rpt
}
# Start Setting Initial Values for Sensitivity Variables .
if { [ info exists gps_sensitivity_check_on ] } {
set gps_sensitivity_check_on 1
}

if { [ info exists gps_sensitivity_check_done ] } {
set gps_sensitivity_check_done 0
}

if { [ info exists gps_sensitivity_sweep_started ] } {
set gps_sensitivity_sweep_started 0
}

if { [ info exists gps_sensitivity_specs_found ] } {
set gps_sensitivity_specs_found 0
}

if { [ info exists gps_sensitivity_iteration_number ] } {
set gps_sensitivity_iteration_number 1
}

# Set  the initial value very high 
if { [ info exists gps_num_sensitivity_iterations ] } {
set gps_num_sensitivity_iterations 1000
}

# End Setting Initial Values for Sensitivity Variables
puts "INFO : Reset Sensitivity Settings"
}
proc gps_read_constraint_file { args } {

# Start Reading Arguments
set state flag
set argv [split $args]

foreach arg $argv {
 	
                switch -- $state {
                        flag {
                                switch -glob -- $arg {
                               
                                        -input_file { set state input }
                                        -output_file { set state output }
					-golden_run { set state golden }
						
                                }
			}	
			
			input {
			set input_constraint_file $arg
			set state flag
			}
			
			output {
			set output_tcl_file $arg
			set state flag
			}
			
			golden {
			set golden_run_flag $arg
			
			set state flag
			}			
			
		}
			
}
# Finish Reading Arguments

puts "INFO : Started Reading Input Constraint File $input_constraint_file"

set fp_read [ open "$input_constraint_file" r ]

set out_tcl [ open "$output_tcl_file" w ]

if { $golden_run_flag == 1 } {
set out_tcl1 [ open "$output_tcl_file\_mesh_params_only" w ]
}

puts $out_tcl "global gps_region_xll ; global gps_region_yll ; global gps_region_xur ; global gps_region_yur ;"
puts $out_tcl "global gps_excluded_regions_within_region ; global fetch_region_name ;"
puts $out_tcl "global gps_nets_within_region ; global gps_layers_of_net_within_region ; global gps_specs_within_region ; global gps_layers_within_spec ; global gps_nets_within_spec ; global gps_spec_width ; global gps_spec_spacing ; global gps_spec_group_pitch ;\n"

if { $golden_run_flag == 1 } {
puts $out_tcl1 "global gps_spec_width_golden ; global gps_spec_spacing_golden ; global gps_spec_group_pitch_golden ;\n"
}

puts $out_tcl "
if \{ \[catch \{ unset gps_region_xll \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_region_yll \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_region_xur \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_region_yur \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_excluded_regions_within_region \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_nets_within_region \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_layers_of_net_within_region \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_specs_within_region \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_layers_within_spec \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_nets_within_spec \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_spec_width \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_spec_spacing \} \] == 0 \} \{ 
\} ;
if \{ \[catch \{ unset gps_spec_group_pitch \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_spec_area \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_optimization_parameter \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_global_target_voltage_drop_perc \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_global_metal_min_width_perc \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_global_metal_max_width_perc \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_mesh_change_edge_alignment \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_mesh_partitioning_allowed \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_use_tapering_on_width_change \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_mesh_tapering_length \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_layer_specific_min_width_perc \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_layer_specific_max_width_perc \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_all_layers_can_be_edited \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_mesh_edit_allowed \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_block_region_edit_allowed \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_net_edit_allowed \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset net_specific_target_drop_perc \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_all_nets_can_be_edited \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_fetch_region_name \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_fetch_region_id \} \] == 0 \} \{
\} ;"

if { $golden_run_flag == 1 } {
puts $out_tcl1 "
if \{ \[catch \{ unset gps_spec_width_golden \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_spec_spacing_golden \} \] == 0 \} \{ 
\} ;
if \{ \[catch \{ unset gps_spec_group_pitch_golden \} \] == 0 \} \{
\} ;
if \{ \[catch \{ unset gps_spec_area_golden \} \] == 0 \} \{
\} ;

"
}

puts $out_tcl "global gps_region_xll ; global gps_region_yll ; global gps_region_xur ; global gps_region_yur ;"
puts $out_tcl "global gps_excluded_regions_within_region ; global fetch_region_name ;"
puts $out_tcl "global gps_fetch_region_name ; global gps_fetch_region_id ; global gps_nets_within_region ; global gps_layers_of_net_within_region ; global gps_specs_within_region ; global gps_layers_within_spec ; global gps_nets_within_spec ; global gps_spec_width ; global gps_spec_spacing ; global gps_spec_group_pitch ; global gps_spec_area ;\n"

if { $golden_run_flag == 1 } {
puts $out_tcl1 "global gps_spec_width_golden ; global gps_spec_spacing_golden ; global gps_spec_group_pitch_golden ;global gps_spec_area_golden\n"
}

set found_global_constraints 0
set found_layer_constraints 0
set found_mesh_edit_constraints 0
set found_block_edit_constraints 0
set found_net_edit_constraints 0
set found_region_section 0
set found_net_section 0
set found_layer_section 0

while { [ gets $fp_read line0 ] >=0 } {

regsub -all {\t} $line0 " " line1
regsub -all -- {[[:space:]]+} $line1 " " line2
regsub -all -- {^\s+} $line2 " " line

set words [ split $line " "]

if { [ regexp "^#GLOBAL_CONSTRAINTS" $line ] } {
set found_global_constraints 1
puts $out_tcl "# START : GLOBAL CONSTRAINT VARIABLES\n"

}
if { [ regexp "^#END_GLOBAL_CONSTRAINTS" $line ] } {
set found_global_constraints 0
puts $out_tcl "\n# END : GLOBAL CONSTRAINT VARIABLES\n"
}

# Start Reading Global Constraints

if { [ info exists found_global_constraints ] && $found_global_constraints == 1 && ![ regexp ^GLOBAL_CONSTRAINTS" $line ] && $line ne "" && ![ regexp "^#" $line ]} {


if { [regexp "OPTIMIZATION_PARAMETER" $line ] } {
puts $out_tcl "global gps_optimization_parameter ; set gps_optimization_parameter [ lindex $words 1 ]"
}


if { [regexp "TARGET_DROP" $line ] } {


set gps_global_target_voltage_drop_perc [ lindex $words 1 ]
puts $out_tcl "global gps_global_target_voltage_drop_perc ; set gps_global_target_voltage_drop_perc [ lindex $words 1 ]"

flush $out_tcl
}

if { [regexp "METAL_WIDTH_TOLERANCE" $line ] } {

set min_perc1 [ lindex $words 1 ] ; regsub "%" $min_perc1 "" min_perc
set max_perc1 [ lindex $words 2 ] ; regsub "%" $max_perc1 "" max_perc

set gps_global_metal_min_width_perc $min_perc
set gps_global_metal_max_width_perc $max_perc

puts $out_tcl "global gps_global_metal_min_width_perc ; set gps_global_metal_min_width_perc $min_perc"
puts $out_tcl "global gps_global_metal_max_width_perc ; set gps_global_metal_max_width_perc $max_perc"

}

if { [regexp "EDGE_ALIGNMENT" $line ] } {
puts $out_tcl "global gps_mesh_change_edge_alignment ; set gps_mesh_change_edge_alignment [ lindex $words 1 ]"
}

if { [regexp "MESH_PARTITIONING_ALLOWED" $line ] } {
puts $out_tcl "global gps_mesh_partitioning_allowed ; set gps_mesh_partitioning_allowed [ lindex $words 1 ]"
}

if { [regexp "USE_TAPPERING_ON_WIDTH_CHANGE" $line ] } {
puts $out_tcl "global gps_use_tapering_on_width_change ; set gps_use_tapering_on_width_change [ lindex $words 1 ]"
}

if { [regexp "TAPERING_LENGTH" $line ] } {
puts $out_tcl "global gps_mesh_tapering_length ; set gps_mesh_tapering_length [ lindex $words 1 ]"
}

}

# Finish Reading Global Constraints

# Start Reading Optimize Constraints

if { [ regexp {^\#OPTIMIZE_SECTION} $line ] } {


set found_optimize_constraints 1
puts $out_tcl "# START : GLOBAL VARIABLES FOR OPTIMIZE CONSTRAINTS\n"

puts $out_tcl "global gps_layer_specific_min_width_perc ; global gps_layer_specific_max_width_perc ;"

}

if { [ regexp {^\#END_OPTIMIZE_SECTION} $line ] } {
set found_optimize_constraints 0
puts $out_tcl "\n# END : GLOBAL VARIABLES FOR OPTIMIZE CONSTRAINTS\n"
}

if { [ info exists found_optimize_constraints ] && $found_optimize_constraints == 1 && ![ regexp "^#OPTIMIZE_SECTION" $line ] && $line ne "" && ![ regexp "^#" $line ] } {

if { [ regexp "^EFFORT_LEVEL" $line ] } {
set gps_effort_level [ lindex $words 1 ]

if { $gps_effort_level eq "LOW" } {
set iter_num 1
}
if { $gps_effort_level eq "MID" } {
set iter_num 2
}
if { $gps_effort_level eq "HIGH" } {
set iter_num 3
}

puts $out_tcl "global gps_num_main_iterations ; set gps_num_main_iterations $iter_num\n"
} 

}

# Finished Reading Optimize Constraints

# Start Reading Layer Constraints

if { [ regexp "^#LAYER_CONSTRAINTS" $line ] } {
set found_layer_constraints 1
puts $out_tcl "# START : GLOBAL VARIABLES FOR LAYER CONSTRAINTS\n"

puts $out_tcl "global gps_layer_specific_min_width_perc ; global gps_layer_specific_max_width_perc ;"

}
if { [ regexp "^#END_LAYER_CONSTRAINTS" $line ] } {
set found_layer_constraints 0
puts $out_tcl "\n# END : GLOBAL VARIABLES FOR LAYER CONSTRAINTS\n"
}


if { [ info exists found_layer_constraints ] && $found_layer_constraints == 1 && ![ regexp "^#LAYER_CONSTRAINTS" $line ] && $line ne "" && ![ regexp "^#" $line ] } {

if { [ regexp "^ALL" $line ] } {

set gps_all_layers_can_be_edited [ lindex $words 1 ]
puts $out_tcl "global gps_all_layers_can_be_edited ; set gps_all_layers_can_be_edited $gps_all_layers_can_be_edited\n"

} else {

set metal_layer [ lindex $words 0 ]

set min_perc1 [ lindex $words 2 ] ; regsub "%" $min_perc1 "" min_perc
set max_perc1 [ lindex $words 1 ] ; regsub "%" $max_perc1 "" max_perc
set edit_allowed [ lindex $words 3 ]

if { $min_perc ne "NA" } {

puts $out_tcl "set gps_layer_specific_metal_min_width_perc($metal_layer) $min_perc ;"

} else {

if { [ info exists gps_global_metal_min_width_perc ] && $gps_global_metal_min_width_perc ne "NA" } {

puts $out_tcl "set gps_layer_specific_metal_min_width_perc($metal_layer) $gps_global_metal_min_width_perc"

} else {

puts $out_tcl "set gps_layer_specific_metal_min_width_perc($metal_layer) 100"

}

}


if { $max_perc ne "NA" } {

puts $out_tcl "set gps_layer_specific_metal_max_width_perc($metal_layer) $max_perc ;"

} else {

if { [ info exists gps_global_metal_max_width_perc ] && $gps_global_metal_max_width_perc ne "NA" } {
puts $out_tcl "set gps_layer_specific_metal_max_width_perc($metal_layer) $gps_global_metal_max_width_perc;"
} else {
puts $out_tcl "set gps_layer_specific_metal_max_width_perc($metal_layer) $max_perc;"
}

}


puts $out_tcl "set gps_layer_edit_allowed($metal_layer) $edit_allowed\n"

}

}
# Finish Reading Layer Constraints

# Start Reading MESH Constraints

if { [ regexp "^#MESH_EDIT_CONSTRAINTS" $line ] } {
set found_mesh_edit_constraints 1
puts $out_tcl "# START : GLOBAL VARIABLES FOR MESH EDIT CONSTRAINTS\n"
puts $out_tcl "global gps_mesh_edit_allowed ;"

}
if { [ regexp "^#END_MESH_EDIT_CONSTRAINTS" $line ] } {
set found_mesh_edit_constraints 0
puts $out_tcl "\n# END : GLOBAL VARIABLES FOR MESH EDIT CONSTRAINTS\n"
}


if { [ info exists found_mesh_edit_constraints ] && $found_mesh_edit_constraints == 1 && ![ regexp "^#MESH_EDIT_CONSTRAINTS" $line ] && $line ne "" && ![ regexp "^#" $line ] } {

set spec_name [ lindex $words 0 ]

puts $out_tcl "set gps_mesh_edit_allowed($spec_name) [ lindex $words 1 ]"

}

# Finish Reading Mesh Constraints

# Start Reading Block Edit Constraints

if { [ regexp "^#BLOCK_REGION_EDIT_CONSTRAINTS" $line ] } {
set found_block_edit_constraints 1
puts $out_tcl "# START : GLOBAL VARIABLES FOR BLOCK/REGION EDIT CONSTRAINTS\n"
puts $out_tcl "global gps_block_region_edit_allowed ;"

}

if { [ regexp "^#END_BLOCK_REGION_EDIT_CONSTRAINTS" $line ] } {
set found_block_edit_constraints 0
puts $out_tcl "\n# END : GLOBAL VARIABLES FOR BLOCK/REGION EDIT CONSTRAINTS\n"
}


if { [ info exists found_block_edit_constraints ] && $found_block_edit_constraints == 1 && ![ regexp "^#BLOCK_REGION_EDIT_CONSTRAINTS" $line ] && $line ne "" && ![ regexp "^#" $line ]  } {

set block_name [ lindex $words 0 ]

puts $out_tcl "set gps_block_region_edit_allowed($block_name) [ lindex $words 1 ]"

}

# Finish Reading Block Edit Constraints

# Start Reading Net Edit Constraints

if { [ regexp "^#NET_EDIT_CONSTRAINTS" $line ] } {
set found_net_edit_constraints 1
puts $out_tcl "# START : GLOBAL VARIABLES FOR NET EDIT CONSTRAINTS\n"
puts $out_tcl "global gps_net_edit_allowed ; global net_specific_target_drop_perc\n"

}
if { [ regexp "^#END_NET_EDIT_CONSTRAINTS" $line ] } {
set found_net_edit_constraints 0
puts $out_tcl "\n# END : GLOBAL VARIABLES FOR NET EDIT CONSTRAINTS\n"
}


if { [ info exists found_net_edit_constraints ] && $found_net_edit_constraints == 1 && ![ regexp "^#NET_EDIT_CONSTRAINTS" $line ] && $line ne "" && ![ regexp "^#" $line ]  && ![ regexp "ALL" $line ]} {

set net_name [ lindex $words 0 ]
set edit_allowed [ lindex $words 2 ]
set perc_value1 [ lindex $words 1] ; regsub "%" $perc_value1 "" perc_value
puts $out_tcl "set gps_net_edit_allowed($net_name) $edit_allowed"

if { $perc_value != 0 && $perc_value ne "NA"} {
puts $out_tcl "set gps_net_specific_target_drop_perc($net_name) $perc_value\n"
} else {
puts $out_tcl "set gps_net_specific_target_drop_perc($net_name) $gps_global_target_voltage_drop_perc\n"
}

}

# Finish Reading Net Edit Constraints

# Start Reading Advanced Mesh Information Section

#if { [ regexp "^#NET_EDIT_CONSTRAINTS" $line ] } {
#set found_advanced_mesh_information_section 1
#puts $out_tcl "# START : GLOBAL VARIABLES FOR ADVANCED MESH CONSTRAINTS\n"
#puts $out_tcl "global gps_net_edit_allowed ; global net_specific_target_drop_perc\n"
#
#}
#if { [ regexp "^#END_NET_EDIT_CONSTRAINTS" $line ] } {
#set found_advanced_mesh_information_section 0
#puts $out_tcl "\n# END : GLOBAL VARIABLES FOR ADVANCED MESH CONSTRAINTS\n"
#}


# Finish Reading Advanced Mesh Information Section

if { [ regexp "^#REGION :" $line ] } {
set found_region_section 1
set region_name [ lindex $words 2 ]

puts $out_tcl "\n# START : MESH VARIABLES FOR REGION $region_name\n"
puts $out_tcl "set gps_fetch_region_name($region_name) [ lindex $words 4 ]"
puts $out_tcl "set gps_fetch_region_id([lindex $words 4]) $region_name"
}

if { [ regexp "^#END_REGION" $line ] } {
set found_region_section 0
puts $out_tcl "\n# END : MESH VARIABLES FOR REGION $region_name\n"
}

if { $found_region_section == 1 && ![ regexp "^#REGION :" $line ] && $line ne ""} {

if { [ regexp "^#BBOX" $line ] } {
puts $out_tcl "set gps_region_xll($region_name) [ lindex $words 3 ]"
puts $out_tcl "set gps_region_yll($region_name) [ lindex $words 4 ]"
puts $out_tcl "set gps_region_xur($region_name) [ lindex $words 5 ]"
puts $out_tcl "set gps_region_yur($region_name) [ lindex $words 6 ]"
}

if { [ regexp "^#REGION_EXCLUDE" $line ] } {
set exc_name [ lindex $words 3 ]
puts $out_tcl "lappend gps_excluded_regions_within_region($region_name) $exc_name"
puts $out_tcl "set gps_region_xll($exc_name) [ lindex $words 5 ]"
puts $out_tcl "set gps_region_yll($exc_name) [ lindex $words 6 ]"
puts $out_tcl "set gps_region_xur($exc_name) [ lindex $words 7 ]"
puts $out_tcl "set gps_region_yur($exc_name) [ lindex $words 8 ]"
}

if { [ regexp "^#NET :" $line ] } {
set found_net_section 1
set net_name [ lindex $words 2 ]
set net_written 0
}

if { [ regexp "^#END_NET" $line ] } {
set found_net_section 0
set net_name [ lindex $words 2 ]
}

if { $found_net_section == 1 && ![ regexp "^#NET :" $line ]  && $line ne "" } {

if { [ regexp "^#LAYER" $line ] } {
set found_layer_section 1
}

if { [ regexp "^#END_LAYER" $line ] } {
set found_layer_section 0
}

if { $found_layer_section == 1 && ![ regexp "^#LAYER " $line ] && $line ne "" } {

if { $net_written == 0 } {
puts $out_tcl "lappend gps_nets_within_region($region_name) $net_name"
set net_written 1
}

set layer_name [ lindex $words 0 ]

if { ! [ info exists gps_layers_of_net_within_region($region_name,$net_name) ] } {
lappend gps_layers_of_net_within_region($region_name,$net_name) $layer_name
puts $out_tcl "lappend gps_layers_of_net_within_region($region_name,$net_name) $layer_name"
}

if { [ lsearch $gps_layers_of_net_within_region($region_name,$net_name) $layer_name ] == -1} {

lappend gps_layers_of_net_within_region($region_name,$net_name) $layer_name

puts $out_tcl "lappend gps_layers_of_net_within_region($region_name,$net_name) $layer_name"

}

set spec_name [ lindex $words 1 ]

if { ! [ info exists gps_specs_within_region($region_name)] } {
lappend gps_specs_within_region($region_name) $spec_name

puts $out_tcl "lappend gps_specs_within_region($region_name) $spec_name"
}

if { [ lsearch $gps_specs_within_region($region_name) $spec_name ] == -1 } {

lappend gps_specs_within_region($region_name) $spec_name

puts $out_tcl "lappend gps_specs_within_region($region_name) $spec_name"

}


if { ! [ info exists gps_layers_within_spec($spec_name)] } {
lappend gps_layers_within_spec($spec_name) $layer_name
puts $out_tcl "lappend gps_layers_within_spec($spec_name) $layer_name"
}

if { [ lsearch $gps_layers_within_spec($spec_name) $layer_name] == -1 } {

lappend gps_layers_within_spec($spec_name) $layer_name

puts $out_tcl "lappend gps_layers_within_spec($spec_name) $layer_name"

}


if { ! [ info exists gps_nets_within_spec($spec_name)] } {
lappend gps_nets_within_spec($spec_name) $net_name
puts $out_tcl "lappend gps_nets_within_spec($spec_name) $net_name"
}

if { [ lsearch $gps_nets_within_spec($spec_name) $net_name] == -1} {

lappend gps_nets_within_spec($spec_name) $net_name

puts $out_tcl "lappend gps_nets_within_spec($spec_name) $net_name"

}

set gps_spec_width($spec_name) [ lindex $words 2 ] 

puts -nonewline $out_tcl "set gps_spec_width($spec_name) [ lindex $words 2 ] ; set gps_spec_spacing($spec_name) [ lindex $words 3 ] ; set gps_spec_group_pitch($spec_name) [ lindex $words 4 ] ; set gps_spec_area($spec_name) [ lindex $words 6 ] ;"
if { $golden_run_flag == 1 } {
puts $out_tcl1 "set gps_spec_width_golden($spec_name) [ lindex $words 2 ] ; set gps_spec_spacing_golden($spec_name) [ lindex $words 3 ] ; set gps_spec_group_pitch_golden($spec_name) [ lindex $words 4 ] ; set gps_spec_area_golden($spec_name) [ lindex $words 6 ] ;"

}
puts $out_tcl "set gps_mesh_edit_allowed($spec_name) [ lindex $words 5 ]"

}



}

}



}

close $fp_read


close $out_tcl

if { $golden_run_flag == 1 } {
close $out_tcl1
}

puts "INFO : Finished Reading Input Constraint File $input_constraint_file"


}
proc reportCorrectUsage { } {
error "ERROR in command usage, Correct usage is:\ncreate_staples -name <> -net <> -layer <> -width <> -length <> -direction <h/v>  -x_pitch <> -y_pitch <> -bbox x1 y1 x2 y2 -offset l r t b "

}


proc create_staples { args } {
	
	set state flag
	set argv [split $args ]
	set count 0
        
 	exec mkdir -p ./STAPLES
 	
	foreach arg $argv {

				switch -- $state {
						flag {
							switch -glob -- $arg {
									-name {set state name_flag }
									-net { set state net_flag }
									-layer { set state layer_flag }
									-direction { set state direction_flag }
									-length { set state length_flag }
									-width { set state width_flag }
									-x_pitch { set state xpitch_flag }
									-y_pitch { set state ypitch_flag }
									-bbox { set state bbox_flag }
									-offset { set state offset_flag }
									-topdropvias { set state topdropvias_flag }
									-botdropvias { set state botdropvias_flag }
									 default {
									          [reportCorrectUsage]
									    }
										}
							}

						name_flag {
								set name $arg
								if { [regexp {^-} $name]} {
												error "[reportCorrectUsage]"
												return
											  }
								set state flag
								set fp [open "./STAPLES/$name.rpt" w]
						          }



						net_flag {
								set net $arg
								if { [regexp {^-} $net]} {
												error "[reportCorrectUsage]"
												return
										      }
								set state flag
							}

						layer_flag {
								set layer $arg
								if { [regexp {^-} $layer] } {
												error "[reportCorrectUsage]"
												return
											}
								set state flag
							   }
						
						direction_flag {
								 set direction $arg
        							 if { [regexp {^-} $direction] } {
                                                                                                 error "[reportCorrectUsage]"
                                                                                                return
                                                                                        }
                                                                 set state flag
								}

						length_flag {
								set length $arg
								if { [regexp {^-} $length]} {
												error "[reportCorrectUsage]"
												return
											}
								set state flag
							    }

						width_flag {
								set width $arg
								if { [regexp {^-} $width]} {
												error "[reportCorrectUsage]"
												return
											}
								set state flag
							   }


						xpitch_flag {
								set xpitch $arg
								if { [regexp {^-} $xpitch]} {
												error "[repotCorrectUsage]"
												return
											}
								set state flag
							   }

						ypitch_flag {
								set ypitch $arg
								if { [regexp {^-} $ypitch]} {
												error "[reportCorrectUsage]"
												return
											}
								set state flag
							   }


						bbox_flag {
								set count  [expr $count+1]
								set bbox $arg
								if { [regexp {^-} $bbox]} {
											       error "[reportCorrectUsage]"	
												return
											}

								if { $count == 1 } {
									set x1 $bbox
									set state bbox_flag
										   } elseif { $count == 2 } {
														set y1 $bbox
														set state bbox_flag
													    } elseif { $count == 3 } {
																	set x2 $bbox
																	set stage bbox_flag
																     } elseif { $count == 4 } {
																				set y2 $bbox
																				set count 0
																				set state flag
																	
																			      } else {
																			             }
							}

									
						offset_flag {
							     set count [expr $count+1]
								set offset $arg
								if { [regexp {^-} $offset]} {
												error "[reportCorrectUsage]"
												return
											}

                                                                if { $count == 1 } {
                                                                        set l $offset
									set state offset_flag
                                                                                   } elseif { $count == 2 } {
                                                                                                                set r $offset
														set state offset_flag
                                                                                                            } elseif { $count == 3 } {
                                                                                                                                        set t $offset
																	set state offset_flag
                                                                                                                                     } elseif { $count == 4 } {
                                                                                                                                                                set b $offset
                                                                                                                                                                set count 0
																				set state flag

                                                                                                                                                              } else {
			
                                                                                                                                                                     }
							   }

						topdropvias_flag {
								set topdropvias $arg
								if { [regexp {^-} $topdropvias]} {
												  error "[reportCorrectUsage]"
												return
											}
								set state flag
								}

						botdropvias_flag {
								set botdropvias $arg
								if { [regexp {^-} $botdropvias]} {
												 error "[reportCorrectUsage]"
												return
											}
								set state flag 
								}


     }

 }

global env

			    if {![info exists offset]} {
				set l 0;
				set r 0;
				set t 0;
				set b 0;
						       }

			   if { $l < 0 | $r < 0 | $t < 0 | $b < 0 } {                                                                                                                                                                 error "Please give Positive Offset values"                                                                                                                                                          return                                                                                                                                                                                                        }



		if {[info exists name] & [info exists net] & [info exists layer] & [info exists width] & [info exists length] & [info exists xpitch] & [info exists ypitch] & [info exists direction] & [info exists bbox] } {
		 	     auto_gui_update off
                             if { [string equal $direction v] } {

				  set row_count 0;
			          set col_count 0;
 				  set row 0;
				  set col 0;
                                  set col_limit [expr $x2-$x1]
                                  set row_limit [expr $y2-$y1]
				  if {$col_limit <= 0 | $row_limit <= 0} {
                                        error "Give proper BBOX coordinates llx lly urx ury"
					return
                                                      }

				  set loff [expr $l]
				  set roff [expr $r]
                                  for { set row 0 } { $row <= $row_limit } {incr row_count } {
                                         
                                          set bot_off_temp [expr $row_count*$ypitch]
					  set bot_off [expr $bot_off_temp+$b]
                                          set temp2 [expr $bot_off+$length]
					  set top_off [expr $row_limit -$temp2]
                                       
                                          set row $bot_off
                                          if { $bot_off <= [expr $y2-$t] && $top_off >= $t  } {
						puts $fp "$name$row_count"
                                          set cmdd  "create_route_mesh -name $name$row_count -nets  \{ $net \}  -layer $layer -dir $direction -width $width -spacing 0 -pitch $xpitch -offsets \{ $top_off $loff $bot_off $roff \}  -region \{ $x1 $y1 $x2 $y2 \}"  
					  eval $cmdd
                                                                                           }
												}
					  auto_gui_update on
					  refresh_gui

							        } elseif { [string equal $direction h] } {
  				  set row_count 0;
                                  set col_count 0;
                                  set row 0;
                                  set col 0;
                                  set col_limit [expr $x2-$x1]
                                  set row_limit [expr $y2-$y1]
                                  set boff [expr $b]
                                  set toff [expr $t]

				  if {$col_limit <= 0 | $row_limit <= 0} {
					error "Give proper BBOX coordinates llx lly urx ury"
						      }
                                  for { set col 0 } { $col <= $col_limit } {incr col_count } {

                                          set left_off_temp [expr $col_count*$ypitch]
                                          set left_off [expr $left_off_temp+$l]
                                          set temp2 [expr $left_off+$length]
                                          set right_off [expr $col_limit -$temp2]

                                          set col $left_off
                                          if { $left_off <= [expr $x2-$r] && $right_off >= $r} {
                                                puts $fp "$name$col_count"
                                          set cmdd  "create_route_mesh -name $name$col_count -nets  \{ $net \}  -layer $layer -dir $direction -width $width -spacing 0 -pitch $xpitch -offsets \{ $toff $left_off $boff $right_off \}  -region \{ $x1 $y1 $x2 $y2 \}"
                                          eval $cmdd


                                    }

                                                                                               }
					auto_gui_update on
				        refresh_gui
					     }

} else  { 
		[reportCorrectUsage]
		return
	 }
close $fp

};#proc

									

proc CorrectUsagemodel { } {
error "Error in usage: Correct Usage is \n delete_staples -name <staples spec name>"
			  }


proc delete_staples { args } {

  set argv [split $args]
  
  set state flag

  foreach arg $argv {
		switch -- $state {

				 flag { 

					switch -glob -- $arg {
								    
							      -name { set state name_flag }
							      default {
							      error "Error: Unknown flag $arg: Correct Usage is [CorrectUsagemodel]"
							      return
								      }
							    }

				    } 

				name_flag {

					   set spec_name $arg

					   if { [regexp {^-} $spec_name] } {
									error "[CorrectUsagemodel]"
									return
								      }

					  set state flag

					    }


                               } 
		  } 

global env

if { [info exists spec_name]} {

set file_path "./STAPLES/$spec_name.rpt"

set fp [open "$file_path" r]

   if {[info exists fp]} {

	auto_gui_update off
      
	while { [gets $fp line1] >= 0 } {
		delete_mesh $line1
 		}
	auto_gui_update on
	refresh_gui

	exec rm  $file_path


			} else { error "Staples with spec $spec_name doesn't exist" }

                         } else { "[CorrectUsagemodel]" }
close $fp	 
} 
proc create_rh_summary {args} {
global env
config cmdlog off
if { [llength $args] < 4} {
        error "Usage: create_rh_summary -analysis_type <static|dynamic|rampup|cpm> -o <output_file>"
    }
set flag_MD 0
set design_name [get design]
set layers [get design -layers -type metal]
set layers [lindex $layers 0]
set all_layers [get design -layers]
set all_layers [lindex $all_layers 0]
set dir [pwd]
set analysis_type [lindex $args 1]
set output_file [lindex $args 3]
set fileW [open $output_file "w"]
dump metal_density -o Metal_density.rpt
set fileMD [open "Metal_density.rpt" "r"]
set log_file "$dir/adsRpt/redhawk.log"
set fileLOG [open $log_file "r"]
set power_rpt "$dir/adsRpt/power_summary.rpt"
set filePower [open $power_rpt "r"]
set em_metal_val 0.0
set em_via_val 0.0
set em_via_per 0.0
set em_metal_per 0.0
set total_chip_power 0
set layer_md_cnt 0
set total_md_value 0
set power_hier "$dir/adsRpt/${design_name}.power.hiers"
set per_value_gp 0.1
set domain_min_y_val_for_gp 0
set use_max_min_voltage_rampup "min"
if { [regexp {static} $analysis_type] } {
set analysis_dir "Static"
}
if { [regexp {dynamic} $analysis_type] } {
set analysis_dir "Dynamic"
}


puts $fileW "#Metal Density:"
flush $fileW 
#puts $fileW "#Layer\tMetal Density(%)"
while { [gets $fileMD line] >= 0 } {
	if { [regexp {Metal Density Profile for all P/G nets} $line] } {
		set flag_MD 1
		gets $fileMD line
	}
if {$flag_MD == 1} {
if { ![regexp {^\#} $line] } {
 set layer_md([lindex $line 0]) [lindex $line 1]
 set total_md_value [expr $total_md_value + [lindex $line 1] ]
 incr layer_md_cnt
} else {
puts $fileW $line
flush $fileW 
}
}
}
foreach md_disp $layers {
 if {[info exists layer_md($md_disp)]} {
  puts $fileW "$md_disp\t\t$layer_md($md_disp)"
  flush $fileW 
 } else {
  puts $fileW "$md_disp\t\tNA"
  flush $fileW 
 }
}
puts $fileW "\n"
flush $fileW 
if { $layer_md_cnt != 0 } {
set avg_md_value [expr $total_md_value/$layer_md_cnt]
set avg_md_value [ format "%0.4f" $avg_md_value]
} else {
set avg_md_value "NA"
}
puts $fileW "#Avg_Metal_Density\t$avg_md_value"
puts $fileW "\n"
puts $fileW "#Power Summary Report:\n"
flush $fileW 
puts $fileW "#Power Summary Report per Domain:"
flush $fileW 
puts $fileW "#Domain\t\tPower(mW)"
flush $fileW 
set end_pwr_flag 0
while { [gets $filePower line_power] >= 0 } {
if { [regexp {Power of different Vdd domain in Watt} $line_power] } {
gets $filePower line_power
gets $filePower line_power
while { [gets $filePower line_power] >= 0 } {
if { [regexp {For NA domain} $line_power] } {
set end_pwr_flag 1
break
}
regexp {(^.*)\s+\(\s*(.*)V\)} $line_power matched_3 vdd_domain vdd_value
set power_domain(${vdd_domain}) $vdd_value
set var_power [split $line_power ")"]

set var_power_1 [lindex $var_power 1]
#puts $fileW -nonewline [lindex $var_power 0]
set pwr_dom [lindex $var_power 0]
#puts $fileW -nonewline ")\t"
set Total_power_domain [lindex $var_power_1 0]
#puts $fileW [expr {${Total_power_domain}*1000}]
if {[regexp {^\s*$} $line_power]} {
continue
} else { 
set pwr_dom_1 [ format "%0.2f" [expr {${Total_power_domain} * 1000}]]
puts $fileW "${pwr_dom}\)\t${pwr_dom_1}"
set total_chip_power [expr $total_chip_power + $pwr_dom_1]
flush $fileW 
}
}	
}
if {$end_pwr_flag == 1} {
break
}
}

puts $fileW "\n#Power Summary Report per Block:"
flush $fileW 
puts $fileW "#Block\t\t\t\tPower(mW)"
flush $fileW 
if { [file exists $power_hier] } {
set filePHeir [open $power_hier "r"]
while { [gets $filePHeir line_hier] >= 0 } {
 if { [regexp {^[0-9]} $line_hier] } {
	set var_hier_pwr $line_hier
        set block_pwr_W [lindex $var_hier_pwr 0]
	set blk_pwr [expr {${block_pwr_W} * 1000}]
set blk_pwr [ expr abs($blk_pwr) ]
set blk_pwr [expr int($blk_pwr*100)]
set blk_pwr1 [ expr $blk_pwr/100 ]
	set block_name [lindex $var_hier_pwr 5]
 	puts $fileW [format "%-25s\t%0.2f" $block_name $blk_pwr1]
flush $fileW 

   }
}
close $filePHeir
} else {
puts "Please specify POWER_HIER_REPORT_LEVEL 1 in gsr file"
}

puts $fileW "\n"
flush $fileW 

set total_chip_power [ format "%0.3f" $total_chip_power]
puts $fileW "#Total Power(mW): $total_chip_power"
puts $fileW "\n"
flush $fileW 

set max 0
set flag_domain_wise 0
set flag_layer_wise 0
set flag_static_em 0
## Static Analysis
if {$analysis_type == "static"} {
puts $fileW "#Static IR Report:\n"
flush $fileW 
puts $fileW "#Static IR Summary:"
flush $fileW 
puts $fileW "#Parameter\tValue(mV)"
flush $fileW 
while { [gets $fileLOG line_log] >= 0 } {

#if { [regexp {^INST\s*(.*)mV} $line_log matched inst_volt] } {
#	puts $fileW "Inst Drop\t${inst_volt}"
#}
if { [regexp {^WIRE\s*(.*)mV\s+(.*)\s+[0-9]} $line_log matched2 wire_drop wire_dom] } {
	set wire_drop [format "%0.2f" $wire_drop]
	puts $fileW "Wire Drop(${wire_dom})\t${wire_drop}"
flush $fileW 
}
regexp {Total number of metal EM violations: (.*$)} $line_log matched_5 em_metal_val
regexp {Total number of via   EM violations: (.*$)} $line_log matched_6 em_via_val

if { [regexp {The worst IR\-drop for the top cover of the chip:} $line_log] } {
set flag_domain_wise 1
}
if {$flag_domain_wise == 1} {
if { [regexp {NET\<(.*)\>\s*:} $line_log matched_4 net_name] } {
#regexp {NET<(.*)>\s*:} $line_log matched_4 net_name
gets $fileLOG line_log
#set Nets()
set net_power_dom [lindex $line_log 2]
#-----------------------------------------------------------------
foreach var_dummy [array names power_domain] {
if {$var_dummy == $net_name} {
set flag_dummy 1
break
} else {
set flag_dummy 0
}
}
if { $flag_dummy == 0} {
set power_domain(${net_name}) 0
}
#-----------------------------------------------------------------
set Domain($net_name) [expr {$power_domain(${net_name}) - ${net_power_dom}}]
}
}
if { [regexp {Static Result Summary} $line_log] } {
set flag_domain_wise 0
#break
}
if { [regexp {Worst Static EM} $line_log] } {
set flag_static_em 1
}
if { $flag_static_em == 1 } {
  regexp {^WIRE\s+(.*)\%} $line_log matched_7 em_metal_per
  regexp {^VIA\s+(.*)\%} $line_log matched_8 em_via_per
}

if { [regexp {Finish Dumping metal_density} $line_log] } {
break;
}
}
## End of Log file Parsing
set Sw_rpt_file "$dir/adsRpt/Static/switch_static.rpt"
if {[file exists $Sw_rpt_file]} {
set fileSWs [open "$dir/adsRpt/Static/switch_static.rpt" "r"]
while { [gets $fileSWs line_SWs] >= 0 } {
if { [regexp {^#+} $line_SWs] } {
continue
} else {
set sw_rpt $line_SWs
set sw_type [lindex $sw_rpt 1]
	if { [regexp {header} $sw_type] || [regexp {footer} $sw_type] } {
		if {$max < [lindex $sw_rpt 3]} {
			set max [lindex $sw_rpt 3]
			set sw_name_max [lindex $sw_rpt 0]
		}
	}
}
}

close $fileSWs
}
## End of switch file parsing
set sw_max [expr {${max} * 1000}]
set sw_max [format "%0.2f" $sw_max]
puts $fileW "Switch Drop\t${sw_max}\n"
flush $fileW 
puts $fileW "#Static IR Drop per Domain:"
flush $fileW 
puts $fileW "#Domain\tValue(mV)"
flush $fileW 
foreach { line_layer_pr line_layer_val_pr } [array get Domain] {
set line_layer_val_pr [format "%f" $line_layer_val_pr]
set line_layer_val_pr [expr {${line_layer_val_pr} * 1000}]
set line_layer_val_pr [ expr abs($line_layer_val_pr) ]
set line_layer_val_pr [expr int($line_layer_val_pr*1.0*100)]
set line_layer_val_pr1 [ expr $line_layer_val_pr*1.0/100 ]

puts $fileW "$line_layer_pr\t$line_layer_val_pr1"
flush $fileW 
} 

puts $fileW "\n#Static IR Drop per Layer:"
flush $fileW 
puts $fileW "#Layer\tDrop(mV)"
flush $fileW 
set Layer_rpt_file "$dir/adsRpt/Static/layer_drop.rpt"
if {[file exists $Layer_rpt_file]} {
set fileLDrop [open "$dir/adsRpt/Static/layer_drop.rpt" "r"]
while { [gets $fileLDrop line_LDrop] >= 0 } {
if { [regexp {^#TOP} $line_LDrop] } {
set flag_layer_wise 1
}
if { [regexp {^Net} $line_LDrop] } {
set flag_layer_wise 0
break
}
if { $flag_layer_wise == 1 } {
if { [regexp {^#+} $line_LDrop] } {
continue
} else {
#set var_layer $line_LDrop
set my_last_index [llength $line_LDrop]
set my_last_index [expr $my_last_index-1]
set layer_name [lindex $line_LDrop 0]
set layer_drop [lindex $line_LDrop $my_last_index]
set layer_name [expr {$layer_name}]
set layer_drop [expr {$layer_drop}]
if {[regexp {^\S+} $line_LDrop]} {
set layer_drop [expr $layer_drop * 1000]
set layer_drop [expr int($layer_drop*1.0*100)]
set layer_drop1 [ expr $layer_drop*1.0/100 ]
set all_layer_drop($layer_name) $layer_drop1

#puts $fileW "${layer_name}\t$layer_drop1"
#flush $fileW 
}
}
}
}
foreach layer_stack_drop $all_layers {
 if {[info exists all_layer_drop($layer_stack_drop)]} {
  puts $fileW "${layer_stack_drop}\t$all_layer_drop($layer_stack_drop)"
  flush $fileW 
 } else {
  if {![regexp {instance} $layer_stack_drop]} {
  puts $fileW "${layer_stack_drop}\tNA"
  flush $fileW 
  }
 }
}
close $fileLDrop
}
## End of Layerwise Reporting
puts $fileW "\n#Static EM Summary:"
flush $fileW 

}




## End of Static Analysis Reporting


### Start of dynamic-Analysis ###
if {$analysis_type == "dynamic"} {
exec mkdir -p GPSResults
puts $fileW "#Dynamic IR Report:\n"
flush $fileW 
puts $fileW "#Dynamic IR Summary:"
flush $fileW 
puts $fileW "#Parameter\tValue(mV)"
flush $fileW 

set battery_cur_file "$dir/adsRpt/Dynamic/${design_name}.ivdd"
set demand_cur_file "$dir/adsRpt/Dynamic/${design_name}.ipwr"
if {[file exists $battery_cur_file]} {
#puts "file exists"
set fileBC [open $battery_cur_file "r"]
set max_bc 0
set min_y_val_g 0
set worst_min_y_val_for_gp 0
while { [gets $fileBC line_bc] >= 0 } {
if {[regexp {^\s*#} $line_bc]} {
continue
}
set bc_curr [lindex $line_bc 1]
if { $min_y_val_g > $bc_curr } {
set min_y_val_g $bc_curr
set add_per_for_min_y [expr $per_value_gp * $min_y_val_g]
set add_per_for_min_y [expr abs($add_per_for_min_y)]
set worst_min_y_val_for_gp [expr $min_y_val_g - $add_per_for_min_y]
}
if {$bc_curr > ${max_bc}} {
set max_bc $bc_curr
}
}
close $fileBC
} else {
set max_bc "NA"
#puts ""
}
if {[file exists $demand_cur_file]} {
set fileDC [open $demand_cur_file "r"]
set max_dc 0
set max_x_val_g 0
set max_y_val_g 0
set min_x_val_g 0
while { [gets $fileDC line_dc] >= 0 } {
if {[regexp {^\s*#} $line_dc]} {
continue
}
set x_val_com [lindex $line_bc 0]
set dc_curr [lindex $line_dc 1]
#if { $min_x_val_g > $x_val_com } {
#set min_x_val_g $x_val_com
#set add_per_for_min_x [expr $per_value_gp * $min_x_val_g]
#set add_per_for_min_x [expr abs($add_per_for_min_x)]
#set worst_min_x_val_for_gp [expr $min_x_val_g - $add_per_for_min_x]
#}
#if { $max_x_val_g < $x_val_com } {
#set max_x_val_g $x_val_com
#set add_per_for_max_x [expr $per_value_gp * $max_x_val_g]
#set add_per_for_max_x [expr abs($add_per_for_max_x)]
#set worst_max_x_val_for_gp [expr $add_per_for_max_x + $max_x_val_g]
#}
if {$dc_curr > ${max_dc}} {
set max_dc $dc_curr
set add_per_for_max_y [expr $per_value_gp * $max_dc]
set add_per_for_max_y [expr abs($add_per_for_max_y)]
set worst_max_y_val_for_gp [expr $add_per_for_max_y + $max_dc]
}
}
close $fileDC
} else {
set max_dc "NA"
#puts ""
}
while { [gets $fileLOG line_log] >= 0 } {

#if { [regexp {^INST\s*(.*)mV} $line_log matched inst_volt] } {
#	puts $fileW "Inst Drop\t${inst_volt}"
#}
if { [regexp {^avgTW} $line_log matched_tw ] } {
#set var_avgtw [split $line_log " "]
set var_avgtw $line_log
set avgtw_volt [lindex $var_avgtw 1]
regsub -- {mV} $avgtw_volt {} avgtw_volt
set avgtw_inst [lindex $var_avgtw 5]
set avgtw_net [lindex $var_avgtw 2]
	#puts $fileW "avgTW Drop( ${avgtw_net}, ${avgtw_inst} )\t${avgtw_volt}"
	#puts $fileW "avgTW Drop \t${avgtw_volt}"
}
if { [regexp {^minTW} $line_log matched_tw ] } {
#set var_mintw [split $line_log " "]
set var_mintw $line_log
set mintw_volt [lindex $var_mintw 1]
set mintw_inst [lindex $var_mintw 5]
set mintw_net [lindex $var_mintw 2]
regsub -- {mV} $mintw_volt {} mintw_volt
	#puts $fileW "minTW Drop( ${mintw_net}, ${mintw_inst} )\t${mintw_volt}"
	#puts $fileW "minTW Drop \t${mintw_volt}"
}
if { [regexp {^maxTW} $line_log matched_tw ] } {
#set var_maxtw [split $line_log " "]
set var_maxtw $line_log
set maxtw_volt [lindex $var_maxtw 1]
set maxtw_inst [lindex $var_maxtw 5]
set maxtw_net [lindex $var_maxtw 2]
regsub -- {mV} $maxtw_volt {} maxtw_volt
	#puts $fileW "maxTW Drop( ${maxtw_net}, ${maxtw_inst} )\t${maxtw_volt}"
	#puts $fileW "maxTW Drop \t${maxtw_volt}"
}
if { [regexp {^minWC} $line_log matched_tw ] } {
#set var_minwc [split $line_log " "]
set var_minwc $line_log
set minwc_volt [lindex $var_minwc 1]
set minwc_inst [lindex $var_minwc 5]
set minwc_net [lindex $var_minwc 2]
regsub -- {mV} $minwc_volt {} minwc_volt
	#puts $fileW "minWC Drop( ${minwc_net}, ${minwc_inst} )\t${minwc_volt}"
	puts $fileW "minWC Drop \t${minwc_volt}"
flush $fileW 
}
if { [regexp {^WIRE\s*(.*)mV\s+(.*)\s+[0-9]} $line_log matched2 wire_drop wire_dom] } {
	set wire_drop [format "%0.2f" $wire_drop]
	puts $fileW "Wire Drop(${wire_dom})\t${wire_drop}"
flush $fileW 
}
regexp {Total number of metal EM violations: (.*$)} $line_log matched_5 em_metal_val
regexp {Total number of via   EM violations: (.*$)} $line_log matched_6 em_via_val

if { [regexp {The worst dynamic voltage drop for the top cover of the chip:} $line_log] } {
set flag_domain_wise 1
}
if {$flag_domain_wise == 1} {
if { [regexp {NET\<(.*)\>\s*:} $line_log matched_4 net_name] } {
#regexp {NET<(.*)>\s*:} $line_log matched_4 net_name
gets $fileLOG line_log
#set Nets()
set net_power_dom [lindex $line_log 2]
set power_domain_corrected($net_name) 1
#-----------------------------------------------------------------
foreach var_dummy [array names power_domain] {
if {$var_dummy == $net_name} {
set flag_dummy 1
break
} else {
set flag_dummy 0
}
}
if { $flag_dummy == 0} {
set power_domain(${net_name}) 0
set power_domain_corrected($net_name) 0
}
#-----------------------------------------------------------------
set Domain($net_name) [expr {$power_domain(${net_name}) - ${net_power_dom}}]
}
}
if { [regexp {Dynamic Result Summary} $line_log] } {
set flag_domain_wise 0
#break
}
if { [regexp {Worst PEAK EM} $line_log] } {
set flag_static_em 1
}
if { $flag_static_em == 1 } {
  regexp {^WIRE\s+(.*)\%} $line_log matched_7 em_metal_per
  regexp {^VIA\s+(.*)\%} $line_log matched_8 em_via_per
}
if { [regexp {Finish Dumping metal_density} $line_log] } {
break
}
}
## End of Log file Parsing
set Sw_rpt_file "$dir/adsRpt/Dynamic/switch_dynamic.rpt"
if {[file exists $Sw_rpt_file]} {
set fileSWs [open "$dir/adsRpt/Dynamic/switch_dynamic.rpt" "r"]
while { [gets $fileSWs line_SWs] >= 0 } {
if { [regexp {^#+} $line_SWs] } {
continue
} else {
set sw_rpt $line_SWs
set sw_type [lindex $sw_rpt 1]
	if { [regexp {header} $sw_type] || [regexp {footer} $sw_type]} {
		if {$max < [lindex $sw_rpt 3]} {
			set max [lindex $sw_rpt 3]
			set sw_name_max [lindex $sw_rpt 0]
		}
	}
}
}

close $fileSWs
}
## End of switch file parsing

## Getting Pkg Drop
set ploc_name_power [get pad * -glob -power]
set pkg_power_vmaxdrop 0
set ploc_name_ground [get pad * -glob -ground]
set pkg_gnd_vmaxdrop 0
foreach ploc_drop $ploc_name_power {
set ploc_power_drop [get pad $ploc_drop -net]
set pkg_power_absvolt [get pad $ploc_drop -voltage]
set pkg_power_idealvolt [get net $ploc_power_drop -ideal_voltage]
set pkg_power_vdrop [expr {$pkg_power_idealvolt - $pkg_power_absvolt}]
if {$pkg_power_vmaxdrop <= $pkg_power_vdrop} {
set pkg_power_vmaxdrop $pkg_power_vdrop
set pkg_power_vmaxdrop_net $ploc_power_drop
}
}
foreach ploc_ground_drop $ploc_name_ground {
set ploc_gnd_drop [get pad $ploc_ground_drop -net]
set pkg_gnd_absvolt [get pad $ploc_ground_drop -voltage]
set pkg_gnd_idealvolt [get net $ploc_gnd_drop -ideal_voltage]
set pkg_gnd_vdrop [expr {$pkg_gnd_idealvolt - $pkg_gnd_absvolt}]
set pkg_gnd_vdrop [expr abs($pkg_gnd_vdrop)]
if {$pkg_gnd_vmaxdrop <= $pkg_gnd_vdrop} {
set pkg_gnd_vmaxdrop $pkg_gnd_vdrop
set pkg_ground_vmaxdrop_net $ploc_gnd_drop
}
}

## End of Pkg Drop.
set sw_max [expr {${max} * 1000}]
set sw_max [format "%0.2f" $sw_max]
puts $fileW "Switch Drop\t${sw_max}"
flush $fileW 

set pkg_power_vmaxdrop [expr {${pkg_power_vmaxdrop} * 1000 } ]
set pkg_power_vmaxdrop [format "%0.2f" $pkg_power_vmaxdrop ]
puts $fileW "Pkg Drop(${pkg_power_vmaxdrop_net}) \t$pkg_power_vmaxdrop"
flush $fileW 

set pkg_gnd_vmaxdrop [expr {${pkg_gnd_vmaxdrop} * 1000 } ]
set pkg_gnd_vmaxdrop [format "%0.2f" $pkg_gnd_vmaxdrop ]
puts $fileW "Pkg Drop(${pkg_ground_vmaxdrop_net}) \t$pkg_gnd_vmaxdrop"
flush $fileW 


puts $fileW "\n#Dynamic IR Drop per Domain:"
flush $fileW 
puts $fileW "#Domain\tValue(mV)"
flush $fileW 
foreach { line_layer_pr line_layer_val_pr } [array get Domain] {
set line_layer_val_pr [format "%f" $line_layer_val_pr]
set line_layer_val_pr [expr {${line_layer_val_pr} * 1000}]
set line_layer_val_pr [ expr abs($line_layer_val_pr) ]
set line_layer_val_pr [expr int($line_layer_val_pr*1.0*100)]
set line_layer_val_pr1 [ expr $line_layer_val_pr*1.0/100 ]

puts $fileW "$line_layer_pr\t$line_layer_val_pr1"
flush $fileW 
} 

puts $fileW "\n#Dynamic IR Drop per Layer:"
flush $fileW 
puts $fileW "#Layer\tDrop(mV)"
flush $fileW 
set Layer_rpt_file "$dir/adsRpt/Dynamic/layer_drop.rpt"
if {[file exists $Layer_rpt_file]} {
set fileLDrop [open "$dir/adsRpt/Dynamic/layer_drop.rpt" "r"]
while { [gets $fileLDrop line_LDrop] >= 0 } {
if { [regexp {^#TOP} $line_LDrop] } {
set flag_layer_wise 1
}
if { [regexp {^Net} $line_LDrop] } {
set flag_layer_wise 0
break
}
if { $flag_layer_wise == 1 } {
if { [regexp {^#+} $line_LDrop] } {
continue
} else {
#set var_layer $line_LDrop
set layer_name [lindex $line_LDrop 0]
set layer_drop [lindex $line_LDrop 2]
set layer_name [expr {$layer_name}]
set layer_drop [expr {$layer_drop}]
if {[regexp {^\S+} $line_LDrop]} {
set layer_drop [expr $layer_drop * 1000]
set layer_drop [expr int($layer_drop*1.0*100)]
set layer_drop1 [ expr $layer_drop*1.0/100 ]
set all_layer_drop($layer_name) $layer_drop1

#puts $fileW "${layer_name}\t$layer_drop1"
#flush $fileW 
}
}
}
}
foreach layer_stack_drop $all_layers {
 if {[info exists all_layer_drop($layer_stack_drop)]} {
  puts $fileW "${layer_stack_drop}\t$all_layer_drop($layer_stack_drop)"
  flush $fileW 
 } else {
  if {![regexp {instance} $layer_stack_drop]} {
  puts $fileW "${layer_stack_drop}\tNA"
  flush $fileW 
  }
 }
}
close $fileLDrop
}
## End of Layerwise Reporting
## Dynamic Current Reporting:
puts $fileW "\n#Dynamic Current Report:"
flush $fileW 
puts $fileW "\n#Dynamic Current Summary:"
flush $fileW 
puts $fileW "#Parameter\tCurrent"
flush $fileW 
if {[file exists $battery_cur_file]} {
set max_bc [expr {${max_bc}} * 1000]
set max_bc [format "%0.1f" ${max_bc}]
puts $fileW "Peak Battery Current\t${max_bc}"
flush $fileW 
} else {
puts $fileW "Peak Battery Current\t${max_bc}"
flush $fileW 
}
if {[file exists $demand_cur_file]} {
set max_dc [expr {${max_dc}} * 1000]
set max_dc [format "%0.1f" ${max_dc}]
puts $fileW "Peak Demand Current\t${max_dc}\n"
flush $fileW 
### Worst DynCurr gnuplot generation ### 
##Dumping DC plots

set gnu_plot_outfile "GPSResults/${design_name}_gp.dem"
set fileGPW [open $gnu_plot_outfile "w"]

puts $fileGPW "set size 1,1"
puts $fileGPW "set terminal png size 384,288"
puts $fileGPW "set grid"
puts $fileGPW "set key on"
puts $fileGPW "set title \"Battery/Demand Current\""
#puts $fileGPW "set xrange [$worst_min_x_val_for_gp:$worst_max_x_val_for_gp]"
puts $fileGPW "set yrange \[${worst_min_y_val_for_gp}:${worst_max_y_val_for_gp}\]"
puts $fileGPW "set xlabel \"Time (ps)\""
puts $fileGPW "set ylabel \"Current (A)\""
puts $fileGPW "set output \"GPSResults/${design_name}.png\""
puts $fileGPW "plot \"$battery_cur_file\" using 1:2 w l tit \"Battery Current\", \"$demand_cur_file\" using 1:2 w l title \"Demand Current\""
#puts $fileGPW "quit"
close $fileGPW
exec $env(APACHEROOT)/bin/gnuplot $gnu_plot_outfile >& GPSResults/gd.err
} else {
puts $fileW "Peak Demand Current\t${max_dc}\n"
flush $fileW 
}
### End of Worst DynCurr gnuplot generation ###
set DC_power_net [get net * -glob -type power]
set DC_ground_net [get net * -glob -type ground]
set DC_allnets_dummy "$DC_power_net $DC_ground_net"
set DC_allnets [split $DC_allnets_dummy " "]
foreach flag_setting_sw_domian $DC_allnets {
set flag_interanal_net(${flag_setting_sw_domian}) 0
}
puts $fileW "\n#Dynamic Current per Domain:"
flush $fileW 
puts $fileW "#Domain\tI(vdd) mA\tI(pwr) mA"
flush $fileW 
set internal_domain_detect ".apache/apache.swn"
if {[file exists ".apache/apache.swn"]} {
set FileSWNet [open $internal_domain_detect "r"]
while { [gets $FileSWNet line_swnet] >= 0 } {
set int_sw_net [lindex $line_swnet 1]
set flag_interanal_net(${int_sw_net}) 1
#puts "${int_sw_net}: $flag_interanal_net(${int_sw_net})"
}
close $FileSWNet
}
#set DC_power_net [get net * -glob -type power]
#set DC_ground_net [get net * -glob -type ground]
#set DC_allnets_dummy "$DC_power_net $DC_ground_net"
#set DC_allnets [split $DC_allnets_dummy " "]
#foreach debug_DC_for_domain_curr [array names power_domain_corrected] {
#puts "Net: $debug_DC_for_domain_curr This is correct; Value: $power_domain_corrected($debug_DC_for_domain_curr)"
#}
foreach DC_for_domain_curr [array names power_domain_corrected] {
#foreach DC_for_domain_curr $DC_power_net { }
if { $power_domain_corrected($DC_for_domain_curr) == 0 } {
continue
}
#puts "Net Name: $DC_for_domain_curr"
if {$flag_interanal_net(${DC_for_domain_curr}) == 1} {
set flag_print_int_BC_na 1
} else {
plot current -net -name $DC_for_domain_curr -pad -o GPSResults/${design_name}_${DC_for_domain_curr}_BC.rpt -nograph
set flag_print_int_BC_na 0
}
plot current -net -name $DC_for_domain_curr -o GPSResults/${design_name}_${DC_for_domain_curr}_DC.rpt -nograph

set demand_domainwise_cur_file "GPSResults/${design_name}_${DC_for_domain_curr}_DC.rpt"
if {[file exists $demand_domainwise_cur_file]} {
set fileDCDomain [open $demand_domainwise_cur_file "r"]
#puts "DEBUG: GPSResults/${design_name}_${DC_for_domain_curr}_DC.rpt"
set max_domain_dc 0
set min_x_val_g 0
set max_x_val_g 0
set max_y_val_g 0
set domain_max_y_val_for_gp_dc 0
set domain_max_y_val_for_gp_bc 0
while { [gets $fileDCDomain line_dc_domain] >= 0 } {
if {[regexp {^\s*#} $line_dc_domain]} {
continue
}
if {[regexp {^\s*\"} $line_dc_domain]} {
continue
}
set x_val_com_domain [lindex $line_dc_domain 0]
set dc_curr_domain [lindex $line_dc_domain 1]
set dc_curr_domain [ expr abs($dc_curr_domain) ]
####
#if { $min_x_val_g > $x_val_com_domain } {
#set min_x_val_g $x_val_com_domain
#set add_per_for_min_x [expr $per_value_gp * $min_x_val_g]
#set add_per_for_min_x [expr abs($add_per_for_min_x)]
#set domain_min_x_val_for_gp [expr $min_x_val_g - $add_per_for_min_x]
#}
#if { $max_x_val_g < $x_val_com_domain } {
#set max_x_val_g $x_val_com_domain
#set add_per_for_max_x [expr $per_value_gp * $max_x_val_g]
#set add_per_for_max_x [expr abs($add_per_for_max_x)]
#set domain_max_x_val_for_gp [expr $add_per_for_max_x + $max_x_val_g]
#}
####
#puts "DC current Domain: $dc_curr_domain"
if {$dc_curr_domain > ${max_domain_dc}} {
set max_domain_dc $dc_curr_domain
set add_per_for_max_y [expr $per_value_gp * $max_domain_dc]
set add_per_for_max_y [expr abs($add_per_for_max_y)]
set domain_max_y_val_for_gp_dc [expr $add_per_for_max_y + $max_domain_dc]
}
}
set max_domain_dc [ format "%0.2f" [expr {${max_domain_dc} * 1000}]]
#puts "DEBUG: Net: $DC_for_domain_curr Max_DC:$max_domain_dc Range: $domain_max_y_val_for_gp_dc"
close $fileDCDomain
} else {
set max_domain_dc "NA"
#puts ""
}

set battery_domainwise_cur_file "GPSResults/${design_name}_${DC_for_domain_curr}_BC.rpt"
if {[file exists $battery_domainwise_cur_file]} {
set fileBCDomain [open $battery_domainwise_cur_file "r"]
set max_domain_bc 0
set min_y_val_g 0
set domain_min_y_val_for_gp 0
set domain_max_y_val_for_gp_bc 0
set domain_max_y_val_for_gp_dc 0
while { [gets $fileBCDomain line_bc_domain] >= 0 } {
if {[regexp {^\s*#} $line_bc_domain]} {
continue
}
if {[regexp {^\s*\"} $line_bc_domain]} {
continue
}
set bc_curr_domain [lindex $line_bc_domain 1]
set bc_curr_domain [expr abs($bc_curr_domain)]
if { $dc_curr_domain < $min_y_val_g } {
set min_y_val_g $dc_curr_domain
set add_per_for_max_y [expr $per_value_gp * $min_y_val_g]
set add_per_for_max_y [expr abs($add_per_for_max_y)]
set domain_min_y_val_for_gp [expr $add_per_for_max_y + $min_y_val_g]
}

if {$bc_curr_domain > ${max_domain_bc}} {
set max_domain_bc $bc_curr_domain
set max_xlimit_dyncurr [lindex $line_bc_domain 0]
set add_per_for_max_y [expr $per_value_gp * $max_domain_bc]
set add_per_for_max_y [expr abs($add_per_for_max_y)]
set domain_max_y_val_for_gp_bc [expr $add_per_for_max_y + $max_domain_bc]
}
}
close $fileBCDomain
#puts "DEBUG: Net: $DC_for_domain_curr Max_DC:$max_domain_bc Range: $domain_max_y_val_for_gp_bc"
set max_domain_bc [ format "%0.2f" [expr {${max_domain_bc} * 1000}]]
#set max_domain_bc [expr $max_domain_bc * 1000]
} else {
set max_domain_bc "NA"
#puts ""
}
puts $fileW "$DC_for_domain_curr\t$max_domain_bc\t$max_domain_dc"
flush $fileW 
##Dumping DC plots

set gnu_plot_outfile "GPSResults/${DC_for_domain_curr}_gp.dem"
set fileGPW [open $gnu_plot_outfile "w"]
if {$domain_max_y_val_for_gp_bc > $domain_max_y_val_for_gp_dc} {
set domain_max_y_val_for_gp $domain_max_y_val_for_gp_bc
set domain_max_y_val_for_gp_bc 0
#puts "DEBUG: Reset_Value: $domain_max_y_val_for_gp_bc"
} else {
set domain_max_y_val_for_gp $domain_max_y_val_for_gp_dc
set domain_max_y_val_for_gp_dc 0
}
#puts "DEBUG: Net: $DC_for_domain_curr Range: $domain_max_y_val_for_gp DC_Value: $domain_max_y_val_for_gp_dc BC_value: $domain_max_y_val_for_gp_bc"
puts $fileGPW "set size 1,1"
puts $fileGPW "set terminal png small size 384,288"
puts $fileGPW "set grid"
puts $fileGPW "set key on"
puts $fileGPW "set title \"BC/DC plot of domain $DC_for_domain_curr\""
puts $fileGPW "set xlabel \"Time (ps)\""
puts $fileGPW "set ylabel \"Current (A)\""
#puts $fileGPW "set xrange [$domain_min_x_val_for_gp:$domain_max_x_val_for_gp]"
puts $fileGPW "set yrange \[${domain_min_y_val_for_gp}:${domain_max_y_val_for_gp}\]"
puts $fileGPW "set output \"GPSResults/${design_name}_${DC_for_domain_curr}.png\""
#if {${flag_print_int_BC_na} == 0} {}
if {$flag_interanal_net(${DC_for_domain_curr}) == 0} {
puts $fileGPW "plot \"GPSResults/${design_name}_${DC_for_domain_curr}_BC.rpt\" using 1:2 w l tit \"BC of ${DC_for_domain_curr}\", \"GPSResults/${design_name}_${DC_for_domain_curr}_DC.rpt\" using 1:2 w l title \"DC of ${DC_for_domain_curr}\""
} else {
puts $fileGPW "plot \"GPSResults/${design_name}_${DC_for_domain_curr}_DC.rpt\" using 1:2 w l title \"DC of ${DC_for_domain_curr}\""
}
#puts $fileGPW "quit"
##End of DC Plots
set domain_max_y_val_for_gp 0 
close $fileGPW
exec $env(APACHEROOT)/bin/gnuplot $gnu_plot_outfile >& GPSResults/gd.err
}
##### For Gnd seperate battery current display
#foreach DC_for_domain_curr $DC_ground_net { }
foreach DC_for_domain_curr [array names power_domain_corrected] {
#foreach DC_for_domain_curr $DC_power_net { }
if { $power_domain_corrected($DC_for_domain_curr) > 0 } {
continue
}
#puts "Net Name: $DC_for_domain_curr"
if {$flag_interanal_net(${DC_for_domain_curr}) == 1} {
set flag_print_int_BC_na 1
} else {
plot current -net -name $DC_for_domain_curr -pad -o GPSResults/${design_name}_${DC_for_domain_curr}_BC_temp.rpt -nograph
set flag_print_int_BC_na 0
}
plot current -net -name $DC_for_domain_curr -o GPSResults/${design_name}_${DC_for_domain_curr}_DC.rpt -nograph

set demand_domainwise_cur_file "GPSResults/${design_name}_${DC_for_domain_curr}_DC.rpt"
if {[file exists $demand_domainwise_cur_file]} {
set fileDCDomain [open $demand_domainwise_cur_file "r"]
set max_domain_dc 0
set min_x_val_g 0
set max_x_val_g 0
set max_y_val_g 0
set domain_max_y_val_for_gp_dc 0
set domain_max_y_val_for_gp_bc 0
while { [gets $fileDCDomain line_dc_domain] >= 0 } {
if {[regexp {^\s*#} $line_dc_domain]} {
continue
}
if {[regexp {^\s*\"} $line_dc_domain]} {
continue
}
set x_val_com_domain [lindex $line_dc_domain 0]
set dc_curr_domain [lindex $line_dc_domain 1]
set dc_curr_domain [ expr abs($dc_curr_domain) ]
#puts "DC current Domain: $dc_curr_domain"
#if { $min_x_val_g > $x_val_com_domain } {
#set min_x_val_g $x_val_com_domain
#set add_per_for_min_x [expr $per_value_gp * $min_x_val_g]
#set add_per_for_min_x [expr abs($add_per_for_min_x)]
#set domain_min_x_val_for_gp [expr $min_x_val_g - $add_per_for_min_x]
#}
#if { $max_x_val_g < $x_val_com_domain } {
#set max_x_val_g $x_val_com_domain
#set add_per_for_max_x [expr $per_value_gp * $max_x_val_g]
#set add_per_for_max_x [expr abs($add_per_for_max_x)]
#set domain_max_x_val_for_gp [expr $add_per_for_max_x + $max_x_val_g]
#}
if {$dc_curr_domain > ${max_domain_dc}} {
set max_domain_dc $dc_curr_domain
set add_per_for_max_y [expr $per_value_gp * $max_domain_dc]
set add_per_for_max_y [expr abs($add_per_for_max_y)]
set domain_max_y_val_for_gp_dc [expr $add_per_for_max_y + $max_domain_dc]
}
}
set max_domain_dc [ format "%0.2f" [expr {${max_domain_dc} * 1000}]]
close $fileDCDomain
} else {
set max_domain_dc "NA"
#puts ""
}

set battery_domainwise_cur_file "GPSResults/${design_name}_${DC_for_domain_curr}_BC_temp.rpt"
set extra_for_battery_ground_domain_output "GPSResults/${design_name}_${DC_for_domain_curr}_BC.rpt"
set fileBCgndDomain [open "$extra_for_battery_ground_domain_output" "w"]
if {[file exists $battery_domainwise_cur_file]} {
set fileBCDomain [open $battery_domainwise_cur_file "r"]
set max_domain_bc 0
set min_y_val_g 0
set domain_min_y_val_for_gp 0
set domain_max_y_val_for_gp_bc 0
set domain_max_y_val_for_gp_dc 0
while { [gets $fileBCDomain line_bc_domain] >= 0 } {
if {[regexp {^\s*#} $line_bc_domain]} {
continue
}
if {[regexp {^\s*\"} $line_bc_domain]} {
puts $fileBCgndDomain "$line_bc_domain"
continue
}
set bc_curr_time_pt [lindex $line_bc_domain 0]
set bc_curr_domain [lindex $line_bc_domain 1]
set bc_curr_domain [expr abs($bc_curr_domain)]
if { $dc_curr_domain < $min_y_val_g } {
set min_y_val_g $dc_curr_domain
set add_per_for_max_y [expr $per_value_gp * $min_y_val_g]
set add_per_for_max_y [expr abs($add_per_for_max_y)]
set domain_min_y_val_for_gp [expr $add_per_for_max_y + $min_y_val_g]
}
puts $fileBCgndDomain "$bc_curr_time_pt $bc_curr_domain"

if {$bc_curr_domain > ${max_domain_bc}} {
set max_domain_bc $bc_curr_domain
set max_xlimit_dyncurr [lindex $line_bc_domain 0]
set add_per_for_max_y [expr $per_value_gp * $max_domain_bc]
set add_per_for_max_y [expr abs($add_per_for_max_y)]
set domain_max_y_val_for_gp_bc [expr $add_per_for_max_y + $max_domain_bc]
}
}
close $fileBCDomain
close $fileBCgndDomain
set max_domain_bc [ format "%0.2f" [expr {${max_domain_bc} * 1000}]]
#set max_domain_bc [expr $max_domain_bc * 1000]
} else {
set max_domain_bc "NA"
#puts ""
}
puts $fileW "$DC_for_domain_curr\t$max_domain_bc\t$max_domain_dc"
flush $fileW 
##Dumping DC plots

set gnu_plot_outfile "GPSResults/${DC_for_domain_curr}_gp.dem"
set fileGPW [open $gnu_plot_outfile "w"]
if {$domain_max_y_val_for_gp_bc > $domain_max_y_val_for_gp_dc} {
set domain_max_y_val_for_gp $domain_max_y_val_for_gp_bc
set domain_max_y_val_for_gp_bc 0
set domain_max_y_val_for_gp_dc 0
} else {
set domain_max_y_val_for_gp $domain_max_y_val_for_gp_dc
#puts "DEBUG: Net $DC_for_domain_curr $domain_max_y_val_for_gp "
set domain_max_y_val_for_gp_dc 0
set domain_max_y_val_for_gp_bc 0
}

puts $fileGPW "set size 1,1"
puts $fileGPW "set terminal png small size 384,288"
puts $fileGPW "set grid"
puts $fileGPW "set key on"
puts $fileGPW "set title \"BC/DC plot of domain $DC_for_domain_curr\""
puts $fileGPW "set xlabel \"Time (ps)\""
puts $fileGPW "set ylabel \"Current (A)\""
#puts $fileGPW "set xrange [$domain_min_x_val_for_gp:$domain_max_x_val_for_gp]"
puts $fileGPW "set yrange \[${domain_min_y_val_for_gp}:${domain_max_y_val_for_gp}\]"
puts $fileGPW "set output \"GPSResults/${design_name}_${DC_for_domain_curr}.png\""
#if {${flag_print_int_BC_na} == 0} {}
if {$flag_interanal_net(${DC_for_domain_curr}) == 0} {
puts $fileGPW "plot \"GPSResults/${design_name}_${DC_for_domain_curr}_BC.rpt\" using 1:2 w l tit \"BC of ${DC_for_domain_curr}\", \"GPSResults/${design_name}_${DC_for_domain_curr}_DC.rpt\" using 1:2 w l title \"DC of ${DC_for_domain_curr}\""
} else {
puts $fileGPW "plot \"GPSResults/${design_name}_${DC_for_domain_curr}_DC.rpt\" using 1:2 w l title \"DC of ${DC_for_domain_curr}\""
}
#puts $fileGPW "quit"
##End of DC Plots
set domain_max_y_val_for_gp 0 
close $fileGPW
exec $env(APACHEROOT)/bin/gnuplot $gnu_plot_outfile >& GPSResults/gd.err
}
### End of Gnd battery current

## End of Dynamic Current Reporting:
puts $fileW "\n#PEAK EM Summary:"
flush $fileW 
}
##End of Dynamic IR Drop Analysis Reporting:

### Start of Rampup-Analysis ###
if {$analysis_type == "rampup"} {
exec mkdir -p GPSResults
puts $fileW "#Low-power Analysis Report:\n"
flush $fileW 
puts $fileW "#Rampup Summary:"
flush $fileW 
puts $fileW "#Parameter\tValue"
flush $fileW 

set rampup_cur_file "$dir/adsRpt/Dynamic/virtual_domain_total_i.rpt"
if {[file exists $rampup_cur_file]} {
#puts "file exists"
set fileRC [open $rampup_cur_file "r"]
set max_rampup_current 0
set count_int_domain 0
set flag_print_rampup_net 0
while { [gets $fileRC line_rc] >= 0 } {
if {[regexp {^\s*#} $line_rc]} {
continue
}
if {[regexp {^\s*$} $line_rc]} {
continue
}
if {[regexp {^\s*\"} $line_rc]} {
regsub -- {^\s*\"} $line_rc {} rampup_net
#puts "DEBUG: I am inside current domain"
incr count_int_domain
set rampup_domains($count_int_domain) rampup_net
set rampup_current_val($rampup_net) 0
if { $flag_print_rampup_net == 1 } {
close $File_DomainRampup
}
set flag_print_rampup_net 1
set File_DomainRampup [open "GPSResults/${design_name}_${rampup_net}_current.rpt" "w"]
continue
}
set ramp_curr [lindex $line_rc 1]
if { $flag_print_rampup_net == 1 } {
puts $File_DomainRampup "$line_rc"
flush $File_DomainRampup
}
if {$ramp_curr > $rampup_current_val($rampup_net)} {
set rampup_current_val($rampup_net) $ramp_curr
if {$max_rampup_current < $rampup_current_val($rampup_net)} {
set max_rampup_current $rampup_current_val($rampup_net)
}
set add_per_for_max_y [expr $per_value_gp * $rampup_current_val($rampup_net)]
set add_per_for_max_y [expr abs($add_per_for_max_y)]
set worst_max_y_val_for_gp($rampup_net) [expr $add_per_for_max_y + $rampup_current_val($rampup_net)]
}
}
if { $flag_print_rampup_net == 1 } {
close $File_DomainRampup
}
close $fileRC
} else {
set max_rampup_current "NA"
#puts ""
}
if { $max_rampup_current == "NA"} {
set max_rampup_current "NA"
} else {
set max_rampup_current [expr $max_rampup_current * 1000]
set max_rampup_current [format "%0.2f" $max_rampup_current]
}

puts $fileW "Rampup Current\(mA\)\t${max_rampup_current}"
flush $fileW 
 

set RC_power_nets [get net * -glob -type power]
set RC_ground_nets [get net * -glob -type ground]
##Get minimum voltage for footer switch transition 
set firsttime_get_voltvalue_flag 1
foreach min_volt_for_footer $RC_power_nets {
if { $firsttime_get_voltvalue_flag == 1 } {
set minimum_vdd_volt_for_footer_switch [get net $min_volt_for_footer -ideal_voltage]
set maximum_vdd_volt_for_footer_switch [get net $min_volt_for_footer -ideal_voltage]
set firsttime_get_voltvalue_flag 0
continue
}
set min_foot_volt [get net $min_volt_for_footer -ideal_voltage]
if { $minimum_vdd_volt_for_footer_switch > $min_foot_volt} {
set minimum_vdd_volt_for_footer_switch $min_foot_volt
}
if { $maximum_vdd_volt_for_footer_switch < $min_foot_volt} {
set maximum_vdd_volt_for_footer_switch $min_foot_volt
}
} 

## Start Voltage file dumping and worst rampup time getting
set rampup_voltage_file "$dir/adsRpt/Dynamic/virtual_domain_worst_v.rpt"
if {[file exists $rampup_voltage_file]} {
set max_rampup_turnon_time 0
set flag_print_rampup_volt_net 0
set fileRampV [open "$rampup_voltage_file" "r"]
while { [gets $fileRampV line_RV] >= 0 } {
if {[regexp {^\s*#} $line_RV]} {
#puts "DEBUG: I m in rampup_voltage also"
continue
}
if {[regexp {^\s*$} $line_RV]} {
#puts "DEBUG: I m in rampup_voltage also"
continue
}
#puts "DEBUG: I m in rampup_voltage"
if {[regexp {^\s*\"} $line_RV]} {
regsub -- {^\s*\"} $line_RV {} rampup_volt_net
foreach power_nets_for_turnon_time $RC_power_nets {
if { $rampup_volt_net == $power_nets_for_turnon_time } {
#puts "DEBUG: Coming in Header"
set power_net_found_flag 1
set switch_type "header"
set ideal_volt($rampup_volt_net) [get net $power_nets_for_turnon_time -ideal_voltage]
set ideal_volt_for_expr $ideal_volt($rampup_volt_net)
set turnon_volt($rampup_volt_net) [expr $ideal_volt_for_expr * 0.9]
## below statement needs enhancement if we have VSS arc value below 0V
set turnoff_volt($rampup_volt_net) 0
set starttime_ramp_power_flag 1
break
}
set power_net_found_flag 0
}
foreach ground_nets_for_turnon_time $RC_ground_nets {
if {$power_net_found_flag == 0} {
if { $rampup_volt_net == $ground_nets_for_turnon_time } {
set ground_net_found_flag 1
set switch_type "footer"
set get_turnon_time_voltvalue_for_gndnet_flag 1
set starttime_ramp_ground_flag 1
break
}
} else {
set get_turnon_time_voltvalue_for_gndnet_flag 0
break
}
set ground_net_found_flag 0
}

if { $flag_print_rampup_volt_net == 1 } {
close $File_DomainVoltRampup
}
set flag_print_rampup_volt_net 1
set File_DomainVoltRampup [open "GPSResults/${design_name}_${rampup_volt_net}_voltage.rpt" "w"]
continue
}
if { $flag_print_rampup_volt_net == 1 } {
puts $File_DomainVoltRampup "$line_RV"
flush $File_DomainVoltRampup
}

if { $switch_type == "header"} {
set var_time_virtual [lindex $line_RV 0]
set var_time_virtual [expr int($var_time_virtual)]
set var_volt_virtual [lindex $line_RV 1]
if { $starttime_ramp_power_flag == 1} {
if { $turnoff_volt($rampup_volt_net) <= $var_volt_virtual} {
set start_turnontime($rampup_volt_net) $var_time_virtual
set starttime_ramp_power_flag 0
}
}
if {$turnon_volt($rampup_volt_net) <= $var_volt_virtual} {
set end_turnontime($rampup_volt_net) $var_time_virtual
set end_turnontime_for_expr $end_turnontime($rampup_volt_net)
set start_turnontime_for_expr $start_turnontime($rampup_volt_net)
set total_turnontime($rampup_volt_net) [expr $end_turnontime_for_expr - $start_turnontime_for_expr]
if { $max_rampup_turnon_time < $total_turnontime($rampup_volt_net) } {
set max_rampup_turnon_time $total_turnontime($rampup_volt_net)
}
set switch_type "over"
}
}
if { $switch_type == "footer"} {
## Below IF conditional statement should be enhanced if we get VDD arc value. Here voltage of VSS at 0sec time is taken as VDD value.
if {$get_turnon_time_voltvalue_for_gndnet_flag == 1} {
 if {$use_max_min_voltage_rampup == "max" } {
     set turnoff_volt($rampup_volt_net) $maximum_vdd_volt_for_footer_switch	
   } else {
	set first_max_volt_value_rampup [lindex $line_RV 1]
	if { $first_max_volt_value_rampup > $minimum_vdd_volt_for_footer_switch } {
	set turnoff_volt($rampup_volt_net) $first_max_volt_value_rampup
	} else {
	set turnoff_volt($rampup_volt_net) $minimum_vdd_volt_for_footer_switch
	}
   }
## Hard coding 1st value as voltage of vdd to 1st value in virtual_domain_worst_v
set turnoff_volt($rampup_volt_net) $first_max_volt_value_rampup
set perc_turnoff_volt_value [expr $turnoff_volt($rampup_volt_net) * 0.1 ]
set ideal_volt($rampup_volt_net) [get net $rampup_volt_net -ideal_voltage]
set turnon_volt($rampup_volt_net) [expr $ideal_volt($rampup_volt_net) + $perc_turnoff_volt_value]
set get_turnon_time_voltvalue_for_gndnet_flag 0
}
set var_time_virtual [lindex $line_RV 0]
set var_time_virtual [expr int($var_time_virtual)]
set var_volt_virtual [lindex $line_RV 1]
if { $starttime_ramp_ground_flag == 1} {
if { $turnoff_volt($rampup_volt_net) >= $var_volt_virtual} {
set start_turnontime($rampup_volt_net) $var_time_virtual
set starttime_ramp_power_flag 0
}
}

if {$turnon_volt($rampup_volt_net) >= $var_volt_virtual} {
set end_turnontime($rampup_volt_net) $var_time_virtual
set switch_type "over"
set total_turnontime($rampup_volt_net) [expr $end_turnontime($rampup_volt_net) - $start_turnontime($rampup_volt_net)]
if { $max_rampup_turnon_time < $total_turnontime($rampup_volt_net) } {
set max_rampup_turnon_time $total_turnontime($rampup_volt_net)
}
}

}
}
if { $flag_print_rampup_volt_net == 1 } {
close $File_DomainVoltRampup
set flag_print_rampup_volt_net 0
}
close $fileRampV
} else {
set max_rampup_turnon_time "NA"
}
 if { $max_rampup_turnon_time == "NA" } {
set max_rampup_turnon_time "NA"
} else {
set max_rampup_turnon_time [expr $max_rampup_turnon_time * 1.00 / 1000]
set max_rampup_turnon_time [format "%0.2f" $max_rampup_turnon_time]
}

puts $fileW "Rampup Time\(nS\)\t${max_rampup_turnon_time}"
flush $fileW 
## End worst rampup time getting

## Start reporting Switch Max Current
set Sw_rpt_file "$dir/adsRpt/Dynamic/switch_dynamic.rpt"
set max_switch_current 0
if {[file exists $Sw_rpt_file]} {
set fileSWs [open "$dir/adsRpt/Dynamic/switch_dynamic.rpt" "r"]
while { [gets $fileSWs line_SWs] >= 0 } {
if { [regexp {^#+} $line_SWs] } {
continue
} else {
set sw_rpt $line_SWs
set sw_type [lindex $sw_rpt 1]
	if { [regexp {header} $sw_type] || [regexp {footer} $sw_type]} {
		if {$max_switch_current < [lindex $sw_rpt 2]} {
			set max_switch_current [lindex $sw_rpt 2]
			set sw_name_max [lindex $sw_rpt 0]
		}
	}
}
}

close $fileSWs
} else {
set max_switch_current "NA"
}
 if { $max_switch_current == "NA" } {
set max_switch_current "NA"
} else {
set max_switch_current [expr $max_switch_current * 1000]
set max_switch_current [format "%0.2f" $max_switch_current]
}

puts $fileW "Switch Current\(mA\)\t${max_switch_current}"
flush $fileW 
## End of switch file parsing

## Getting Pkg Drop
set ploc_name_power [get pad * -glob -power]
set pkg_power_vmaxdrop 0
set ploc_name_ground [get pad * -glob -ground]
set pkg_gnd_vmaxdrop 0
foreach ploc_drop $ploc_name_power {
set ploc_power_drop [get pad $ploc_drop -net]
set pkg_power_absvolt [get pad $ploc_drop -voltage]
set pkg_power_idealvolt [get net $ploc_power_drop -ideal_voltage]
set pkg_power_vdrop [expr {$pkg_power_idealvolt - $pkg_power_absvolt}]
if {$pkg_power_vmaxdrop <= $pkg_power_vdrop} {
set pkg_power_vmaxdrop $pkg_power_vdrop
set pkg_power_vmaxdrop_net $ploc_power_drop
}
}
foreach ploc_ground_drop $ploc_name_ground {
set ploc_gnd_drop [get pad $ploc_ground_drop -net]
set pkg_gnd_absvolt [get pad $ploc_ground_drop -voltage]
set pkg_gnd_idealvolt [get net $ploc_gnd_drop -ideal_voltage]
set pkg_gnd_vdrop [expr {$pkg_gnd_idealvolt - $pkg_gnd_absvolt}]
set pkg_gnd_vdrop [expr abs($pkg_gnd_vdrop)]
if {$pkg_gnd_vmaxdrop <= $pkg_gnd_vdrop} {
set pkg_gnd_vmaxdrop $pkg_gnd_vdrop
set pkg_ground_vmaxdrop_net $ploc_gnd_drop
}
}

## End of Pkg Drop.
set pkg_power_vmaxdrop [expr {${pkg_power_vmaxdrop} * 1000 } ]
set pkg_power_vmaxdrop [format "%0.2f" $pkg_power_vmaxdrop ]
puts $fileW "Pkg Drop\(Pwr\)\(mV\) \t${pkg_power_vmaxdrop}"
flush $fileW 

set pkg_gnd_vmaxdrop [expr {${pkg_gnd_vmaxdrop} * 1000 } ]
set pkg_gnd_vmaxdrop [format "%0.2f" $pkg_gnd_vmaxdrop ]
puts $fileW "Pkg Drop\(Gnd\)\(mV\) \t${pkg_gnd_vmaxdrop}"
flush $fileW 


puts $fileW "\n#Rampup Current Waveform:"
flush $fileW 
puts $fileW "#Domain\tPeak Current(mA)"
flush $fileW
if {[array exists rampup_current_val]} { 
foreach { domain_net_name domain_peak_current } [array get rampup_current_val] {
set domain_peak_current [expr {${domain_peak_current} * 1000}]
set domain_peak_current [format "%0.2f" $domain_peak_current]

puts $fileW "$domain_net_name\t$domain_peak_current"
flush $fileW 
set rampup_current_file "GPSResults/${design_name}_${domain_net_name}_current.rpt"
if {[file exists $rampup_current_file]} {
### Rampup Current gnuplot generation ### 
##Dumping RC plots

set gnu_plot_outfile "GPSResults/${design_name}_${domain_net_name}_current_gp.dem"
set fileGPW [open $gnu_plot_outfile "w"]

puts $fileGPW "set size 1,1"
puts $fileGPW "set terminal png size 384,288"
puts $fileGPW "set grid"
puts $fileGPW "set key off"
puts $fileGPW "set title \"Rampup Current of domain $domain_net_name\""
#puts $fileGPW "set xrange [$worst_min_x_val_for_gp:$worst_max_x_val_for_gp]"
if { [info exists worst_max_y_val_for_gp($domain_net_name)] } {
puts $fileGPW "set yrange \[:$worst_max_y_val_for_gp($domain_net_name)\]"
}
puts $fileGPW "set xlabel \"Time (ps)\""
puts $fileGPW "set ylabel \"Current (A)\""
puts $fileGPW "set output \"GPSResults/${design_name}_${domain_net_name}_current.png\""
puts $fileGPW "plot \"$rampup_current_file\" using 1:2 w l"
#puts $fileGPW "quit"
close $fileGPW
exec $env(APACHEROOT)/bin/gnuplot $gnu_plot_outfile >& GPSResults/gd.err
}
}
} else {
puts "Rampup current waveforms file is missing"
}
### Voltage waveform generation for Rampup
puts $fileW "\n#Rampup Voltage Waveform:"
flush $fileW 
puts $fileW "#Domain\tRampup Time(nS)"
flush $fileW 
set per_add_volt_waveform [expr $maximum_vdd_volt_for_footer_switch * 0.05]
set max_y_range_for_gp [expr $maximum_vdd_volt_for_footer_switch + $per_add_volt_waveform]

if {[array exists total_turnontime]} { 
foreach { domain_net_name domain_turnon_time } [array get total_turnontime] {
if {$domain_turnon_time != "NA"} {
set domain_turnon_time [expr ${domain_turnon_time} * 1.00 / 1000]
}
#set domain_turnon_time [format "%0.3f" $domain_turnon_time]
#puts "\nDEBUG Net Domain: $domain_net_name"
#puts "DEBUG: Turn ON Volt: $turnon_volt($domain_net_name)"
#puts "DEBUG: Turn OFF Volt: $turnoff_volt($domain_net_name)"
#puts "DEBUG: Start Time: $start_turnontime($domain_net_name)"
#puts "DEBUG: End Time: $end_turnontime($domain_net_name)"
#puts "DEBUG: Total Time: $total_turnontime($domain_net_name)"
#puts "DEBUG: $domain_net_name\t$domain_turnon_time\n"
puts $fileW "$domain_net_name\t$domain_turnon_time"
flush $fileW 
set rampup_voltage_file "GPSResults/${design_name}_${domain_net_name}_voltage.rpt"
if {[file exists $rampup_voltage_file]} {
### Rampup Current gnuplot generation ### 
##Dumping RC plots

set gnu_plot_outfile "GPSResults/${design_name}_${domain_net_name}_voltage_gp.dem"
set fileGPW [open $gnu_plot_outfile "w"]

puts $fileGPW "set size 1,1"
puts $fileGPW "set terminal png size 384,288"
puts $fileGPW "set grid"
puts $fileGPW "set key off"
puts $fileGPW "set title \"Rampup Voltage of domain $domain_net_name\""
#puts $fileGPW "set xrange [$worst_min_x_val_for_gp:$worst_max_x_val_for_gp]"
puts $fileGPW "set yrange \[:$max_y_range_for_gp\]"
puts $fileGPW "set xlabel \"Time (ps)\""
puts $fileGPW "set ylabel \"Voltage (V)\""
puts $fileGPW "set output \"GPSResults/${design_name}_${domain_net_name}_voltage.png\""
puts $fileGPW "plot \"$rampup_voltage_file\" using 1:2 w l"
#puts $fileGPW "quit"
close $fileGPW
exec $env(APACHEROOT)/bin/gnuplot $gnu_plot_outfile >& GPSResults/gd.err
}
}
} else {
puts "Rampup voltage waveforms file is missing"
}
}

if {$analysis_type == "rampup"} {
#puts "Rampup result generation for RH-GPS is successfully completed"
} else {
puts $fileW "#Parameter\t\t\tValue"
flush $fileW 
puts $fileW "Number of Metal EM Violations\t${em_metal_val}"
flush $fileW 
puts $fileW "Worst Metal EM Violation \%\t${em_metal_per}"
flush $fileW 
puts $fileW "Number of Via EM Violations\t${em_via_val}"
flush $fileW 
puts $fileW "Worst Via EM Violation \%\t${em_via_per}"
flush $fileW 
}
close $fileW
close $fileMD
close $fileLOG
close $filePower
config cmdlog on
}

proc gps_query_memory { } {
# function used to query memory inside redhawk_gps
                 scan [lindex [split\
                   [exec ps --pid [pid] --format vsize]\
                   \n] end] %d measured_size
                 set measured_size [expr {$measured_size/1e0/1024}]
                 set string "MEMORY USAGE: $measured_size MBytes"
		 
		 return $string
 
}
proc reportTemplate_help {} {
        puts "Usage: report_sensitivity -block <block_name> -layer <layer_name> -net <net_name>"
}
proc report_sensitivity { args } {
	set argv [split $args]
	set state flag
	foreach arg $argv {
		switch -- $state {
			flag {
				switch -glob -- $arg {
					-block { set state region_flag }
					-layer { set state layer_flag }
					-net { set state net_flag }
					default { 
					 error  "Error : unknown flag $arg \n [reportTemplate_help]" 
					
					return
					}
				}
			}
		
			region_flag {
				set regionf $arg
				if {[regexp {^-} $regionf]} {

				puts "Wrong usage of TCL command"		
				reportTemplate_help
				return
				}
				set state flag
			}
			
			layer_flag {
				set layerf $arg
				if {[regexp {^-} $layerf]} {

				puts "Wrong usage of TCL command"
				reportTemplate_help
				return
				}
				set state flag
			}
			

			net_flag {
				set netf $arg
				set state flag
			}
				
		}
		

	}
if {![info exists regionf]} {
puts "Wrong usage of TCL command"
				reportTemplate_help
				return
				}

	
global env

set PT0 [ open "$env(PWD)/out/sensitivity_checks/metal_sensitivity_report.rpt" r]

set region_name ""
set net_name ""
set Rln <layer_name>-<net_name>
set ns <net_name>-<metal_sensitivity_index>
set ls <layer_name>-<metal_sensitivity-index>
set lns <layer_name>-<net_name>-<metal_sensitivity_index>


	if {[info exists PT0]} {
		
		while {[gets $PT0 line1]>=0 } {

			regsub { [" "]*} $line1 { } line2
			regsub {\t} $line2 { } line
			set words [split $line " "]
			set count 0
			set x0 [lindex $words 1]
			set x1 [lindex $words 2]
			set x2 [lindex $words 3]
			set x3 [lindex $words 4]
			if {[regexp -all -nocase {<region_name} $x0]} { continue }
			if {[regexp -all -nocase { } $x0]} { continue }
			set a($x0,$x1,$x2) $x3
			set a_layer($x0,$x2) $x3
			set a_net($x0,$x1) $x3
			set regionc($x0) $x3 
			if { [string equal $regionf $x0] } {
			lappend Rln "\n$x2	$x1"
			lappend lns "\n$x2	 $x1	     $x3"
			}
			if {[info exists layerf]} {
			if { [string equal $layerf $x2] && [string equal $regionf $x0]} {
			lappend ns "\n$x1	$x3"
			}
			}
			if {[info exists netf]} {
			if {[string equal $netf $x1] && [string equal $regionf $x0]} {
			lappend ls "\n$x2	$x3"
			}
			}
		if {![regexp -all "$x0" $region_name]} { lappend region_name "$x0\n"}
		
			
		}					
	
	if {![info exists regionc($regionf)]} {puts "ERROR: The block $regionf is not present in the design.\n\nINFO: The available blocks are:"
			set region_name1 [join $region_name "" ]
			puts "$region_name1"
			} else {
	if {[info exists layerf] && [info exists netf]} {
						
			if {[info exists a($regionf,$netf,$layerf)]} {
				puts "metal sensitivity is $a($regionf,$netf,$layerf)"
			} else { 
					set abc [join $Rln "" ]
					puts "ERROR: In region $regionf $netf is not present in layer $layerf.\nINFO:The layer and nets present in $regionf are:"
					puts "$abc"
				} 			
	} else {
		if {[info exists layerf] || [info exists netf]} {
			if {[info exists layerf]} { 
				if {[info exists a_layer($regionf,$layerf)]} {
					set abcns [join $ns "" ]
					puts "\nMetal sensitivity index for the layer $layerf in  block $regionf :\n $abcns"
					} else { puts "ERROR: In region $regionf $layerf is not present.\nINFO: The layer and nets present in $regionf are:"
						set abc [join $Rln "" ]
						puts "$abc"
					}
			}
			if {[info exists netf]} { 
				if {[info exists a_net($regionf,$netf)]} {
					set abcls [join $ls "" ]
	puts "\nMetal sensitivity index for net $netf in block $regionf is : \n$abcls"
					} else { puts "ERROR: In region $regionf $netf is not present.\nINFO: The layer and nets present in $regionf are:\n"
						set abc [join $Rln "" ]
						puts "$abc"
					}
			}
		} else {
			puts "\nMetal sensitivity index for block $regionf is :"
			set abclns [join $lns "" ]
			puts "$abclns"
		}
	}
	}
	} else {error "Metal sensitivity report is either not present or not readable"}

}
proc gps_create_dynamic_setup { args } {

#Start reading Arguments
set state flag
set PWD [exec pwd]

set argv [split $args]

foreach arg $argv {
	switch -- $state {
		flag {
			switch -glob -- $arg {
					-i { set state input_flag }
					-out_dir { set state output_dir_flag }
					default {
   					        }
   				              }	
		     }
			
		input_flag {
			set input $arg
			if { [regexp {^-} $input] } {
					error " "
					return
						    }
					set state flag
			  }


		output_dir_flag {
			set output_dir $arg
			if { [regexp {^-} $output_dir] } {
					 error " "
					 return
							  }
				}

		          };#End of States

		  };#End of foreach

global env

################################################################################################################################################
#Pre Processing step of Early Dynamic analysis, Here we clean up the already existing area and create the required files for Early Dynamic Analysis

#puts "INFO : Changing directory to adsRpt/p/DropAndEM/Dynamic/"

#Adding following lines to support CPM Dynamic
#if { [catch { cd adsRpt/p/DropAndEM/Dynamic/ }] == 0 } {
#} elseif { [catch { cd adsRpt/p/CPM/Dynamic/ }] == 0 } {
#} else {
#if { [catch {file  mkdir adsRpt/Log/Temp }] == 0 } {
#cd adsRpt/Log/Temp
# }
#  }

if {[catch { cd $output_dir}] == 0} {
} else {}


#Opening the EarlyDynamicSpecInput Constraint file for Processing it
set fp_read [open "$input" "r"]

#Cleaning up the area before starting to dump the output files
#exec mkdir -p $output_dir/
file delete -force $output_dir/*
#Creating output files to be created
#*****************This is the final Extra GSR file  which will contain following sections****#
#APL_FILES
#USER_STA_FILE
#DEF_COVER_CELL
#INSTANCE_TOGGLE_RATE_FILE
set power_assignment_line_count [exec wc -l $output_dir/power_assignment.spec];
set split_power_assignment_line_count [lindex $power_assignment_line_count 0];

if { $split_power_assignment_line_count != 0 } { 

set fp_write_extra_gsr [open "$output_dir/extra.gsr" w]
#********************************************************************************************#

puts $fp_write_extra_gsr "APL_FILES \{"
set fp_write_bpa [open "$output_dir/final_bap.txt" w]
puts $fp_write_bpa "BLOCK_POWER_ASSIGNMENT \{"

set fp_write_sta [open "$output_dir/final_user_sta.txt" w]
set fp_def_cover [open "$output_dir/def_cover.txt" w]
puts $fp_def_cover "DEF_COVER_CELL \{"

set fp_instance_toggle_rate [open "$output_dir/instance_toggle_rate.txt" w]

set fp_extra_lef [open "$output_dir/extra_lefs.txt" w]

set fp_gsc [open "$output_dir/design.gsc" w]

#End of creating output file

#Global variable settings
global found_region_section
set found_region_section 0
set found_net_section 0
set found_current_modeling_section 0
set found_cap_modeling_section 0
set modeling "none"
set current_use "none"
set cap_use "none"
set shape "none"
set net "none"
set model "none"
set print_bpa "none"
set found_model 0
set cap_flag 0
set flag_current_assignment_net_layer 0
set count_net_layer_current_assignment 0
set found_net_power_section 0
set count_net_power_section 0
set count_cust_triangle 0
set found_user_cap_net_section 0
set count_user_spec_cap 0
set print_cell_type "none"
set print_pwl 0
set update_apl_bpa "none"
set print_user_cap 0
set create_model 0
set vddpin ""
set vsspin ""
set pin_voltage ""
set final_freq 1000e+09
set print_pwl_current 0
set print_sim_current 0
set cnetlayer 0
set cdnp 0
set cusc 0
set cct 0
set found_rectilinear 0
#End of Global variable section


#Start of processign the input constraing file and processing it
if { [info exists fp_read] } {

while { [gets $fp_read line] >= 0 } {


if { $line ne "" } {

	regsub " : " $line " " line1
	regsub -all { [ ( ] } $line1 " " line2
	regsub -all { [ )]} $line2 " " line3
	regsub -all { [ ) ] } $line3 " " line9
	regsub -all { [( ] } $line9 " " line10
	regsub -all {\t} $line10 " " line4
	regsub -all -- {[[:space:]]+} $line4 " " line5
	regsub -all -- {^\s+} $line5 " " line6

	set line7 "$line6"
                
if { $found_region_section == 0 && [ regexp "#POWER_SPEC" $line7 ] } {
	global RegionId
	global RegionName

	set words [split $line7 " "]
	set RegionId [lindex $words 1]
	set RegionName [lindex $words 2]
	#regsub -all "/" $RegionName_temp "_hash_" RegionName
	set flag($RegionId,$RegionName) 1			
	set found_region_section 1
}

if { [regexp "#BBOX" $line7] && $found_region_section == 1 } {
	
	if { [llength $line7] <= 5 } {  
	set words [split $line7 " "]
	set x1 [lindex $words 1]
	set y1 [lindex $words 2]
	set x2 [lindex $words 3]
	set y2 [lindex $words 4]

	} elseif { [llength $line7] > 5 } {

	set found_rectilinear 1
	set words $line7
	set length_rect [llength $words]

	set max_x [lindex $words 1]
	set min_x [lindex $words 1]
	set max_y [lindex $words 2]
	set min_y [lindex $words 2]

	regsub {#BBOX } $words "" print_rect_extra	


	for { set i 1 } { $i < $length_rect } {set i [expr {$i+2}]} {
	if { [lindex $words $i] <= $min_x } {
	set min_x [lindex $words $i]
	} elseif { [lindex $words $i] >= $max_x } {
		set max_x [lindex $words $i]
		}
	}

	for { set i 2 } { $i < $length_rect } {set i [expr {$i+2}]} {
	if { [lindex $words $i] <= $min_y } {
	set min_y [lindex $words $i]
	} elseif { [lindex $words $i] >= $max_y } {
		set max_y [lindex $words $i]
		}
}
}
}


if { [regexp "#AREA" $line7] && $found_region_section == 1 } {
	set words [split $line7 " "]
	set area [lindex $words 1]
}

#Global Current assignment net and layer info

if { [regexp "#CURRENT_ASSIGNMENT_NET_PIN_LAYER_VOLTAGE" $line7] && $found_region_section == 1} {
	set flag_current_assignment_net_layer 1
	set count_net_layer_current_assignment 0
} elseif { [regexp "#END_CURRENT_ASSIGNMENT_NET_PIN_LAYER_VOLTAGE" $line7] && $found_region_section == 1} {
	set flag_current_assignment_net_layer 0
	set count_net_layer_current_assignment 0
}

if { $flag_current_assignment_net_layer == 1 && ![regexp "#CURRENT_ASSIGNMENT_NET_PIN_LAYER_VOLTAGE" $line7] } {
	set count_net_layer_current_assignment [expr $count_net_layer_current_assignment+1]
	set words [split $line7 " "]
	set Region_net($count_net_layer_current_assignment) [lindex $words 0]
	set Region_pin($count_net_layer_current_assignment) [lindex $words 1]
	set Region_layer($count_net_layer_current_assignment) [lindex $words 2]
	set Region_voltage($count_net_layer_current_assignment) [lindex $words 3]
	if { $Region_pin($count_net_layer_current_assignment) == "-"} {
		set Region_pin($count_net_layer_current_assignment) "$Region_net($count_net_layer_current_assignment)"
	}
	set cnetlayer $count_net_layer_current_assignment
}

if { [regexp "#NET_POWER" $line7] && $found_region_section == 1 && $found_current_modeling_section == 1} {
	set found_net_power_section 1
	set count_net_power_section 0
} elseif { [regexp "END_NET_POWER" $line7] && $found_region_section == 1 && $found_current_modeling_section == 1} {
	set found_net_power_section 0
	set count_net_power_section 0
	set print_bpa "start"
}

if { $found_net_power_section == 1 && ![regexp "#NET_POWER" $line7] } {
	set count_net_power_section [expr $count_net_power_section+1]
	set words [split $line7 " "]
	set net_default_triangle($count_net_power_section) [lindex $words 0]
	set power_default_triangle($count_net_power_section) [lindex $words 1]
	set cdnp $count_net_power_section
}


if { [regexp "#END_CURRENT_MODELING" $line7] && $found_current_modeling_section == 1 } {
	set found_current_modeling_section 0
}

if  { [regexp "#END_CAP_MODELING" $line7] && $found_cap_modeling_section == 1 } {
	set found_cap_modeling_section 0
									  }

if { [ regexp "#END_POWER_SPEC" $line7 ] && $found_region_section == 1 } {
	if { $found_region_section ==1 && ($print_cell_type == "BLOCK" || $print_cell_type == "BLOCK_RECTILINEAR") && [info exists master] } {

		if { $current_use == "IMPORTING_CURRENT_PROFILE" || $current_use == "CUSTOMISED_TRIANGLE" } {
		puts $fp_def_cover "$master"
		}
		
		if { [regexp "/" $RegionName] } {
	        set name [split $RegionName "/"]
        	set Region [lindex $name 1]
        	} else {set Region $RegionName}


		set fp_lef($RegionName) [open "$output_dir/$RegionId.lef" w]
		puts "$fp_lef($RegionName)" "### Apache demo PNR LEF ####\n\nVERSION 5.4 ; \n\nNAMESCASESENSITIVE ON ; \nBUSBITCHARS \"\[\]\" ;\nDIVIDERCHAR \"\/\" ;\n\nUNITS\n DATABASE MICRONS 1000 ;\nEND UNITS\n\n"
		puts "$fp_lef($RegionName)" "MACRO $master\n CLASS BLOCK ;\n SIZE 1250 BY 1000 ;\n FOREIGN birdie 0 0 ;\n ORIGIN 0 0 ;\n SYMMETRY X Y R90 ;"
		for { set i 1} { $i <= $cnetlayer } {incr i} {
			if { $Region_voltage($i) !=0 } {
			puts "$fp_lef($RegionName)" "PIN $Region_pin($i)\n DIRECTION INOUT ;\n USE POWER ;\nEND $Region_pin($i)"
			} else { puts "$fp_lef($RegionName)" "PIN $Region_pin($i)\n DIRECTION INOUT ;\n USE GROUND ;\nEND $Region_pin($i)" }
		 }

		puts "$fp_lef($RegionName)" "\nEND $master\n\n \nEND LIBRARY"

		close "$fp_lef($RegionName)"

		puts $fp_extra_lef "$output_dir/$RegionId.lef"

	   }

	if { ![info exists net_default_triangle(1)] && $current_use == "DEFAULT_TRIANGLE" } {

	for { set i 1 } { $i <= $cnetlayer } {incr i} {
	if { $print_cell_type == "FULLCHIP" || $print_cell_type == "FULLCHIP_RECTILINEAR"} {
        puts $fp_write_bpa "FULLCHIP FULLCHIP $Region_layer($i) $Region_net($i) -1"
        } elseif { $print_cell_type == "BLOCK" || $print_cell_type == "BLOCK_RECTILINEAR"} {
        puts $fp_write_bpa "$RegionName BLOCK $Region_layer($i) $Region_net($i) -1"
        } elseif { $print_cell_type == "HARD-IP" } {
        puts $fp_write_bpa "$RegionName PIN $Region_layer($i) $Region_net($i) -1"
        } elseif { $print_cell_type == "REGION" } {
        puts $fp_write_bpa "$RegionName REGION $Region_layer($i) $Region_net($i) -1 $x1 $y1 $x2 $y2 "
        } elseif { $print_cell_type == "REGION_RECTILINEAR" } {
	puts $fp_write_bpa "$RegionName REGION $Region_layer($i) $Region_net($i) -1 $min_x $min_y $max_x $max_y "
	}

	}
	
	if { $print_cell_type == "BLOCK_RECTILINEAR" } {
	puts $fp_write_bpa "$RegionName BLOCK RECTILINEAR $print_rect_extra"
	} elseif { $print_cell_type == "REGION_RECTILINEAR" } {
	puts $fp_write_bpa "$RegionName BLOCK RECTILINEAR $print_rect_extra"
	}
		if { ![regexp "FULLCHIP" $print_cell_type] } {
		puts $fp_instance_toggle_rate "$RegionName 1"
		} else {
		puts $fp_instance_toggle_rate "adsFULLCHIP 1"
		}


}

	set found_region_section 0
	set found_net_section 0
	set found_current_modeling_section 0
	set found_cap_modeling_section 0
	set modeling "none"
	set current_use "none"
	set cap_use "none"
	set shape "none"
	set net "none"
	set model "none"
	set print_bpa "none"
	set found_model 0
	set cap_flag 0
	set flag_current_assignment_net_layer 0
	set count_net_layer_current_assignment 0
	set found_net_power_section 0
	set count_net_power_section 0
	set count_cust_triangle 0
	set found_user_cap_net_section 0
	set count_user_spec_cap 0
	set print_cell_type "none"
	set print_pwl 0
	set update_apl_bpa "none"
	set print_user_cap 0
	set vdd_pin ""
	set vsspin ""
	set pin_voltage ""
	set create_model 0
	set print_pwl_current 0
	set print_sim_current 0
	set cnetlayer 0
	set cdnp 0
	set cusc 0
	set cct 0
	set found_rectilinear 0
}


if { [regexp "#CELL_TYPE" $line7 ] && $found_region_section == 1 } {

	set words [split $line7 " "]
	set cell_type [lindex $words 1]

	if { $cell_type == "Region" } {
	set print_cell_type "REGION"
	regsub -all "/" $RegionName "_hash_" RegionName 
	} elseif { $cell_type == "Block" || $cell_type == "Routed_Block" } {
	set print_cell_type "BLOCK" 
	} elseif { $cell_type == "FULLCHIP" } {
	set print_cell_type "FULLCHIP"
	} elseif { $cell_type == "Hard-IP" } {
	set print_cell_type "HARD-IP"
	} elseif { $cell_type == "Block_Rectilinear" } {
	set print_cell_type "BLOCK_RECTILINEAR" 
	} elseif { $cell_type == "Region_Rectilinear" } {
	set print_cell_type "REGION_RECTILINEAR"
	regsub -all "/" $RegionName "_hash_" RegionName
	} elseif { $cell_type == "FULLCHIP_Rectilinear" } {
	set print_cell_type "FULLCHIP_RECTILINEAR" 
	}

 

}

if { [regexp "#MASTER_CELL" $line7] && $found_region_section == 1 } {
	set words [split $line7 " "]
	set master_temp [lindex $words 1]
	regsub -all "/" $master_temp "_hash_" master
	}


if { [regexp "#CURRENT_MODELING" $line7] && $found_region_section == 1 && $found_current_modeling_section == 0 } {
	set modeling "current"
	set found_current_modeling_section 1
}

if { [regexp "#CAP_MODELING" $line7] && $found_region_section == 1 && $found_cap_modeling_section == 0 } {
	set modeling "cap"
	set found_cap_modeling_section 1
}

if { [regexp "#USE" $line7] && $found_region_section == 1 && $modeling == "current" && $found_current_modeling_section == 1} {
	set words [split $line7 " "]
	set current_use [lindex $words 1]
} elseif { [regexp "#USE" $line7] && $found_region_section == 1 && $modeling == "cap" && $found_cap_modeling_section == 1} {
	set words [split $line7 " "]
	set cap_use [lindex $words 1]
}

if { [regexp "#SHAPE" $line7] && [regexp "TRAPEZOIDAL" $line7] && $found_region_section == 1 && $found_current_modeling_section == 1} {
	set shape "trapezoidal"
} elseif { [regexp "#SHAPE" $line7] && [regexp " TRIANGLE" $line7] && $found_region_section == 1 && $found_current_modeling_section == 1} {
	set shape "single_triangle"
} elseif { [regexp "#SHAPE" $line7] && [regexp "DUAL-TRIANGLE" $line7] && $found_region_section == 1 && $found_current_modeling_section == 1} {
	set shape "double_triangle"
}

if { [regexp "#MODEL_TYPE" $line7] && $found_region_section == 1 && $found_current_modeling_section == 1 && $found_model == 0} {
	set words [split $line7 " "]
	set model [lindex $words 1]
	set found_model 1
} elseif { [regexp "#END_MODEL_TYPE" $line7] && $found_region_section == 1 && $found_current_modeling_section == 1 && $found_model == 1} {
	set found_model 0
	set update_apl_bpa "start"
	set create_model 0
}


#Creating the Current and Cap profiles

#modeling current
if { $modeling == "current" && $current_use == "DEFAULT_TRIANGLE" && $found_region_section == 1 && $found_current_modeling_section == 1} {


	if { [regexp "#FREQ" $line7] && $found_region_section == 1 && $found_current_modeling_section == 1} {
		set words [split $line7 " "]
		set freq_temp [lindex $words 1]
		
		if { $freq_temp != "NA" } {
		set freq [expr $freq_temp*10e05]
		} else { set freq $freq_temp }

		if { $freq != "NA" && $freq <= $final_freq } {
			set final_freq $freq
		  } elseif { $freq != "NA" && $freq >= $final_freq } {
			set final_freq $final_freq
		}

	
}
	if { [regexp "#INPUT_TRANSITION" $line7] && $found_region_section == 1 && $found_current_modeling_section == 1} {
		set words [split $line7 " "]
		set input_tran_temp [lindex $words 1]
		if { $input_tran_temp != "NA" } {
		set input_tran [expr $input_tran_temp*1e-09]
		} else { set input_tran $input_tran_temp }
		#create_user_sta_file and update it
		if { $freq != "NA" && $input_tran != "NA" } {
		#set fp_usr_sta($RegionName) [open "$output_dir/user_sta_$RegionName.txt" w]
		#puts "$fp_usr_sta($RegionName)" "$RegionName TW 0 0 $freq"
		if { ![regexp "FULLCHIP" $print_cell_type] } {
		puts $fp_write_sta "$RegionName TW 0 0 $freq"
		#puts "$fp_usr_sta($RegionName)" "$RegionName SL $input_tran $input_tran"
		puts $fp_write_sta "$RegionName SL $input_tran $input_tran" 
		#close "$fp_usr_sta($RegionName)"
		puts $fp_instance_toggle_rate "$RegionName 1"
		puts $fp_gsc "$RegionName TOGGLE"
		} else {

		puts $fp_write_sta "adsFULLCHIP TW 0 0 $freq"
		puts $fp_write_sta "adsFULLCHIP SL $input_tran $input_tran"
		puts $fp_instance_toggle_rate "adsFULLCHIP 1"
		puts $fp_gsc "adsFULLCHIP TOGGLE"
		}
}	
}
	if { [info exists print_bpa] } {
	if { $print_bpa == "start" } {
			if { $cell_type == "FULLCHIP" } {
			set RegionName "FULLCHIP"
				}

		for {set i 1} {$i <= $cnetlayer } {incr i } {
		for {set j 1} {$j <= $cdnp } {incr j} {
		if { [info exists "Region_net($i)"] && [info exists "net_default_triangle($j)"] } {
		if { $Region_net($i) == $net_default_triangle($j) } {
		set layer_default_triangle($j) "$Region_layer($i)"
}
}
}
}


	#set fp_default_triangle_bpa($RegionName) [open "$output_dir/bpa_default_triangle_$RegionName.txt" w]
	#puts "$fp_default_triangle_bpa($RegionName)" "BLOCK_POWER_ASSIGNMENT \{"

	if { $print_cell_type == "REGION" } {
	for {set i 1} {$i <= $cdnp} {incr i} {
	#puts "$fp_default_triangle_bpa($RegionName)" "$RegionName $print_cell_type $layer_default_triangle($i) $net_default_triangle($i) $power_default_triangle($i) $x1 $y1 $x2 $y2"
	#flush "$fp_default_triangle_bpa($RegionName)"
	puts $fp_write_bpa "$RegionName $print_cell_type $layer_default_triangle($i) $net_default_triangle($i) $power_default_triangle($i) $x1 $y1 $x2 $y2"
	flush $fp_write_bpa
					     }
	#puts "$fp_default_triangle_bpa($RegionName)" "\}"
	#close "$fp_default_triangle_bpa($RegionName)"

	} elseif { $print_cell_type == "BLOCK" } {
	for {set i 1} {$i <= $cdnp} {incr i} {
	#puts "$fp_default_triangle_bpa($RegionName)" "$RegionName $print_cell_type $layer_default_triangle($i) $net_default_triangle($i) $power_default_triangle($i)"
	#flush "$fp_default_triangle_bpa($RegionName)"
	puts $fp_write_bpa "$RegionName $print_cell_type $layer_default_triangle($i) $net_default_triangle($i) $power_default_triangle($i)"
	flush $fp_write_bpa
					     }
	#puts "$fp_default_triangle_bpa($RegionName)" "\}"
	#close "$fp_default_triangle_bpa($RegionName)"
	} elseif { $print_cell_type == "HARD-IP" } {
	for {set i 1} {$i <= $cdnp} {incr i} {
	#puts "$fp_default_triangle_bpa($RegionName)" "$RegionName PIN $layer_default_triangle($i) $net_default_triangle($i) $power_default_triangle($i)"
	#flush "$fp_default_triangle_bpa($RegionName)"
	puts $fp_write_bpa "$RegionName PIN $layer_default_triangle($i) $net_default_triangle($i) $power_default_triangle($i)"
	flush $fp_write_bpa
					     }
	#puts "$fp_default_triangle_bpa($RegionName)" "\}"
	#close "$fp_default_triangle_bpa($RegionName)"
	} elseif { $print_cell_type == "FULLCHIP" || $print_cell_type == "FULLCHIP_RECTILINEAR" } {

	for {set i 1} {$i <= $cdnp} {incr i} {
	#puts "$fp_default_triangle_bpa($RegionName)" "FULLCHIP FULLCHIP $layer_default_triangle($i) $net_default_triangle($i) $power_default_triangle($i)"
	#flush "$fp_default_triangle_bpa($RegionName)"
	puts $fp_write_bpa "FULLCHIP FULLCHIP $layer_default_triangle($i) $net_default_triangle($i) $power_default_triangle($i)"
	flush $fp_write_bpa
					     }
	#puts "$fp_default_triangle_bpa($RegionName)" "\}"
	#close "$fp_default_triangle_bpa($RegionName)"
	} elseif { $print_cell_type == "REGION_RECTILINEAR" } {
	for {set i 1} {$i <= $cdnp} {incr i} {
	puts $fp_write_bpa "$RegionName REGION $layer_default_triangle($i) $net_default_triangle($i) $power_default_triangle($i) $min_x $min_y $max_x $max_y"
	flush $fp_write_bpa
	}
	puts $fp_write_bpa "$RegionName BLOCK RECTILINEAR $print_rect_extra" 

	} elseif { $print_cell_type == "BLOCK_RECTILINEAR" } {
	for {set i 1} {$i <= $cdnp} {incr i} {
	puts $fp_write_bpa "$RegionName BLOCK $layer_default_triangle($i) $net_default_triangle($i) $power_default_triangle($i)"
	flush $fp_write_bpa
					     }
	puts $fp_write_bpa "$RegionName BLOCK RECTILINEAR $print_rect_extra"
}

}

} else {   }


	

} elseif { $modeling == "current" &&  $current_use == "CUSTOMISED_TRIANGLE" && $found_region_section == 1 && $found_current_modeling_section == 1 } {

if { (($shape == "trapezoidal") || ($shape == "single_triangle") || ($shape == "double_triangle")) && (($found_region_section == 1) && ($found_current_modeling_section == 1)) } {
	if { [regexp "#NET" $line7] && $found_region_section == 1 && $found_current_modeling_section == 1  && $found_net_section == 0 } {
	set found_net_section 1
} elseif { [regexp "#END_NET" $line7] && $found_region_section == 1 && $found_current_modeling_section == 1 &&  $found_net_section == 1 } {
	set found_net_section 0
	set count_cust_triangle 0
	set print_pwl 1
	if { ![regexp "FULLCHIP" $print_cell_type] } {
	puts $fp_instance_toggle_rate "$RegionName 1"
	puts $fp_gsc "$RegionName TOGGLE"
	} else {
		puts $fp_instance_toggle_rate "adsFULLCHIP 1" 
		puts $fp_gsc "adsFULLCHIP TOGGLE"
}

	
}
	
	if {[info exists found_net_section] && $found_net_section } {
	if { ![regexp "#NET" $line7] } {
	set count_cust_triangle [expr $count_cust_triangle+1]
	if { $shape == "trapezoidal" } {
	set words [split $line7 " "]
	set net_cust($count_cust_triangle) [lindex $words 0]
	set i_peak($count_cust_triangle) [lindex $words 1]
	set T_start($count_cust_triangle) [lindex $words 2]
	set T_rise($count_cust_triangle) [lindex $words 3]
	set T_on($count_cust_triangle) [lindex $words 4]
	set T_fall($count_cust_triangle) [lindex $words 5]
	set T_period_temp [lindex $words 6]
	set offset 0.00000000001
	set T_period($count_cust_triangle) [expr $T_period_temp+$offset]
	set T_period_ps($count_cust_triangle) [expr $T_period($count_cust_triangle)*0.000000001]
} elseif { $shape == "single_triangle" } {

	set words [split $line7 " "]
	set net_cust($count_cust_triangle) [lindex $words 0]
	set i_peak($count_cust_triangle) [lindex $words 1]
	set T_start($count_cust_triangle) [lindex $words 2]
	set T_rise($count_cust_triangle) [lindex $words 3]
	set T_fall($count_cust_triangle) [lindex $words 4]
	set T_period_temp [lindex $words 5]
	set offset 0.00000000001
	set T_period($count_cust_triangle) [expr $T_period_temp+$offset]
	set T_period_ps($count_cust_triangle) [expr $T_period($count_cust_triangle)*0.000000001]
} elseif { $shape == "double_triangle" } {
	set words [split $line7 " "]
	set net_cust($count_cust_triangle) [lindex $words 0]
	set i_peak1($count_cust_triangle) [lindex $words 1]
	set i_peak2($count_cust_triangle) [lindex $words 2]
	set T_start($count_cust_triangle) [lindex $words 3]
	set T_rise1($count_cust_triangle) [lindex $words 4]
	set T_fall1($count_cust_triangle) [lindex $words 5]
	set T_delay($count_cust_triangle) [lindex $words 6]
	set T_rise2($count_cust_triangle) [lindex $words 7]
	set T_fall2($count_cust_triangle) [lindex $words 8]
	set T_period_temp [lindex $words 9]
	set offset 0.00000000001
	set T_period($count_cust_triangle) [expr $T_period_temp+$offset]
	set T_period_ps($count_cust_triangle) [expr $T_period($count_cust_triangle)*0.000000001]
	} 

	if { $final_freq != "NA" && $final_freq != 0 } {
		if { $final_freq <= [expr 1/$T_period_ps(1)] } {
			set final_freq $final_freq
		   } else { set final_freq [expr 1/$T_period_ps(1)] }
				} else { set final_freq [expr 1/$T_period_ps(1)] }
	
	set cct $count_cust_triangle
}
}

	if { [info exists print_pwl] && $print_pwl == 1} {
	#set fp_user_sta($RegionName) [open "$output_dir/user_sta_$RegionName.txt" w]
	#puts "$fp_user_sta($RegionName)" "$RegionName TW 0 0 [expr 1/$T_period_ps(1)]"
	if { $print_cell_type == "FULLCHIP" || $print_cell_type == "FULLCHIP_RECTILINEAR" } {
	puts $fp_write_sta "adsFULLCHIP TW 0 0 [expr 1/$T_period_ps(1)]"
	set master "adsFULLCHIP"
	} else { 
		puts $fp_write_sta "$RegionName TW 0 0 [expr 1/$T_period_ps(1)]" 
		}
	if { [regexp "/" $RegionName] } {
        set name [split $RegionName "/"]
        set Region [lindex $name 1]
        } else {set Region $RegionName}

	set fp_write_pwl($RegionName) [open "$output_dir/$RegionId.pwl" w]
	set key "+"
	set pin_voltage ""
	set vddpin ""
	set vsspin ""
	
	for {set i 1} {$i <= $cct} {incr i} {
	
	if { $Region_voltage($i) != 0} {
	set pin_voltage [append pin_voltage "$Region_pin($i)\=$Region_voltage($i) "]
	set vddpin [append vddpin "$Region_pin($i) "] 
	} else { set vsspin [append vsspin "$Region_pin($i) "] }
	
	if { $print_cell_type == "BLOCK" || $print_cell_type == "HARD-IP" || $print_cell_type == "FULLCHIP" || $print_cell_type == "BLOCK_RECTILINEAR" || $print_cell_type == "FULLCHIP_RECTILINEAR" } {
	puts "$fp_write_pwl($RegionName)" "I$Region_pin($i) PWL \(\n$key 0e-12 0"
	} elseif { $print_cell_type == "REGION" || $print_cell_type == "REGION_RECTILINEAR"} {
	puts "$fp_write_pwl($RegionName)" "I$Region_pin($i) PWL \(\n$key 0e-12 0"
	} 

	if { $shape == "trapezoidal" } {	
	set t1 [expr $T_start($i)+$T_rise($i)]
	set t2 [expr $T_start($i)+$T_rise($i)+$T_on($i)]
	set t3 [expr $T_start($i)+$T_rise($i)+$T_on($i)+$T_fall($i)]
	set t4 $T_period($i)
	set t5 [expr $t4+0.01]

	set i_peak_ps($i) [expr $i_peak($i)*0.001]
	set T_start_ps($i) [expr $T_start($i)*0.000000001]
	set t1_ps [expr $t1*0.000000001]
	set t2_ps [expr $t2*0.000000001]
	set t3_ps [expr $t3*0.000000001]
	set t4_ps [expr $t4*0.000000001]
	set t5_ps [expr $t5*0.000000001]
	set T_period_ps($i) [expr $T_period($i)*0.000000001]
	#update the user sta file with the given Waveform shape  for this net
	puts "$fp_write_pwl($RegionName)"  "$key $T_start_ps($i) 0 \n$key $t1_ps $i_peak_ps($i) \n$key $t2_ps $i_peak_ps($i) \n$key $t3_ps 0 \n$key $t4_ps 0 \n$key $t5_ps 0"
	puts "$fp_write_pwl($RegionName)" "$key\)"

} elseif { $shape == "single_triangle" } {
	set t1 [expr $T_start($i)+$T_rise($i)]
	set t2 [expr $T_start($i)+$T_rise($i)+$T_fall($i)]
	set t3 $T_period($i)
	set t4 [expr $t3+0.01]

	set i_peak_ps($i) [expr $i_peak($i)*0.001]
	set T_start_ps($i) [expr $T_start($i)*0.000000001]
	set t1_ps [expr $t1*0.000000001]
	set t2_ps [expr $t2*0.000000001]
	set t3_ps [expr $t3*0.000000001]
	set t4_ps [expr $t4*0.000000001]
	set T_period_ps($i) [expr $T_period($i)*0.000000001]
	#update the user sta file with the given Waveform shape  for this net
	puts "$fp_write_pwl($RegionName)"  "$key $T_start_ps($i) 0 \n$key $t1_ps $i_peak_ps($i) \n$key $t2_ps 0 \n$key $t3_ps 0 \n$key $t4_ps 0"
	puts "$fp_write_pwl($RegionName)" "$key\)"
} elseif { $shape == "double_triangle" } {
	set t1 [expr $T_start($i)+$T_rise1($i)]
	set t2 [expr $T_start($i)+$T_rise1($i)+$T_fall1($i)]
	set t3 [expr $T_start($i)+$T_rise1($i)+$T_delay($i)+$T_fall1($i)]
	set t4 [expr $T_start($i)+$T_rise1($i)+$T_delay($i)+$T_fall1($i)+$T_rise2($i)]
	set t5 [expr $T_start($i)+$T_rise1($i)+$T_delay($i)+$T_fall1($i)+$T_rise2($i)+$T_fall2($i)]

	set t6 $T_period($i)
	set t7 [expr $t6+0.01]

	set i_peak_ps1($i) [expr $i_peak1($i)*0.001]
	set i_peak_ps2($i) [expr $i_peak2($i)*0.001]

	set T_start_ps($i) [expr $T_start($i)*0.000000001]
	set t1_ps [expr $t1*0.000000001]
	set t2_ps [expr $t2*0.000000001]
	set t3_ps [expr $t3*0.000000001]
	set t4_ps [expr $t4*0.000000001]
	set t5_ps [expr $t5*0.000000001]
	set t6_ps [expr $t6*0.000000001]
	set t7_ps [expr $t7*0.000000001]
	set T_period_ps($i) [expr $T_period($i)*0.000000001]
	#update the user sta file with the given Waveform shape  for this net
	puts "$fp_write_pwl($RegionName)"  "$key $T_start_ps($i) 0 \n$key $t1_ps $i_peak_ps1($i) \n$key $t2_ps 0  \n$key $t3_ps 0 \n$key $t4_ps $i_peak_ps2($i) \n$key $t5_ps 0 \n$key $t6_ps 0 \n$key $t7_ps 0"
	puts "$fp_write_pwl($RegionName)" "$key\)"

}	
	
	if { $print_cell_type == "FULLCHIP" || $print_cell_type == "FULLCHIP_RECTILINEAR"} {
	puts $fp_write_bpa "FULLCHIP FULLCHIP $Region_layer($i) $net_cust($i) -1"
	} elseif { $print_cell_type == "BLOCK" || $print_cell_type == "BLOCK_RECTILINEAR"} {
	puts $fp_write_bpa "$RegionName BLOCK $Region_layer($i) $net_cust($i) -1"
	} elseif { $print_cell_type == "HARD-IP" } {
	puts $fp_write_bpa "$RegionName PIN $Region_layer($i) $net_cust($i) -1"
	} elseif { $print_cell_type == "REGION" } {
	puts $fp_write_bpa "$RegionName REGION $Region_layer($i) $net_cust($i) -1 $x1 $y1 $x2 $y2 "
	} elseif { $print_cell_type == "REGION_RECTILINEAR" } {
	puts $fp_write_bpa "$RegionName REGION $Region_layer($i) $net_cust($i) -1 $min_x $min_y $max_x $max_y "
	}

	}

	if { $print_cell_type == "BLOCK_RECTILINEAR" } {
	puts $fp_write_bpa "$RegionName BLOCK RECTILINEAR $print_rect_extra"
	} elseif { $print_cell_type == "REGION_RECTILINEAR" } {
	puts $fp_write_bpa "$RegionName BLOCK RECTILINEAR $print_rect_extra"
	} 
	close "$fp_write_pwl($RegionName)"

	set fp_custom_triangle_config($RegionName) [open "$output_dir/$RegionId.cfg" w]
	
	puts "$fp_custom_triangle_config($RegionName)" "CELL $master \{\nFILENAME \{\n$output_dir\/$RegionId.pwl $pin_voltage\n\}\n\n"
	puts "$fp_custom_triangle_config($RegionName)" "VDD_PIN $vddpin\nVSS_PIN $vsspin\n\n" 

	puts "$fp_custom_triangle_config($RegionName)" "SIM_TIME \{\nREAD 0 \nWRITE 0\n\n\}\n\n"
	puts "$fp_custom_triangle_config($RegionName)" "DURATION $T_period_ps(1)\n\n"
	puts "$fp_custom_triangle_config($RegionName)" "LEAKAGE 0\n\n\}"
	close "$fp_custom_triangle_config($RegionName)"

	set fp3 [open "temp3" w]
	puts $fp3 "$env(APACHEROOT)/bin/sim2iprof $output_dir/$RegionId.cfg -o $output_dir/$RegionId.current"

	close $fp3

	if { [catch { exec bash temp3 }] == 0 } {
	#puts "current success: $RegionName"
	} else {
	puts $RegionName
	global errorInfo
	puts $errorInfo
	}
	puts $fp_write_extra_gsr "$output_dir/$RegionId.current current"
}
					
} elseif { $shape == "single_triangle" && $found_region_section == 1 && $found_current_modeling_section == 1 } {
           #do nothing for now in this release
} elseif { $shape == "double_triangle" && $found_region_section == 1 && $found_current_modeling_section == 1 } {
           #do nothing for now in this release	
}
			

} elseif { $modeling == "current" && $current_use == "IMPORTING_CURRENT_PROFILE" && $found_region_section == 1 && $found_current_modeling_section == 1 } {

	if { [regexp "#FREQ" $line7] } {
		set words [split $line7 " "]
		set freq_import_current_temp [lindex $words 1]
		if { $freq_import_current_temp != "NA" } {
		set freq_import_current [expr $freq_import_current_temp*10e05]
		} else { set freq_import_current $freq_import_current_temp }

		if { $freq_import_current <= $final_freq } {
			set final_freq $freq_import_current
		   } else { set final_freq $final_freq }

					}

	if { $model == "APL" && $found_region_section == 1 && $found_current_modeling_section == 1 && $found_model == 1 } {

		if { $found_model == 1 && ![regexp "MODEL_TYPE" $line7] && ![regexp "#FREQ" $line7]} {
			set apl_file $line7
			puts $fp_write_extra_gsr "$apl_file current"
		if { ![regexp "FULLCHIP" $print_cell_type] } {
		puts $fp_instance_toggle_rate "$RegionName 1"
		puts $fp_write_sta "$RegionName TW 0 0 $freq_import_current"	
		puts $fp_gsc "$RegionName TOGGLE"
		} else {
		puts $fp_instance_toggle_rate "adsFULLCHIP 1"
		puts $fp_gsc "adsFULLCHIP TOGGLE"
		puts $fp_write_sta "adsFULLCHIP TW 0 0 $freq_import_current"
		} 
		 }	
		
		if { $found_model == 1 && ![regexp "MODEL_TYPE" $line7] && ![regexp "#FREQ" $line7]} {
			for {set i 1} {$i <= $cnetlayer } {incr i} {
                if { $Region_voltage($i) != 0} {
                set pin_voltage [append pin_voltage "$Region_pin($i)\=$Region_voltage($i)"]
                set vddpin [append vddpin "$Region_pin($i)"]
                } else { set vsspin [append vsspin "$Region_pin($i)"] }

                if { $print_cell_type == "FULLCHIP" || $print_cell_type == "FULLCHIP_RECTILINEAR" } {
                puts $fp_write_bpa "FULLCHIP FULLCHIP $Region_layer($i) $Region_net($i) -1"
                } elseif { $print_cell_type == "BLOCK" || $print_cell_type == "BLOCK_RECTILINEAR" } {
                puts $fp_write_bpa "$RegionName BLOCK $Region_layer($i) $Region_net($i) -1"
                } elseif { $print_cell_type == "HARD-IP" } {
                puts $fp_write_bpa "$RegionName PIN $Region_layer($i) $Region_net($i) -1"
                } elseif { $print_cell_type == "REGION" } {
                puts $fp_write_bpa "$RegionName REGION $Region_layer($i) $Region_net($i) -1 $x1 $y1 $x2 $y2"
                } elseif { $print_cell_type == "REGION_RECTILINEAR" } {
		puts $fp_write_bpa "$RegionName REGION $Region_layer($i) $Region_net($i) -1 $min_x $min_y $max_x $max_y "
		}

		   }

		if { $print_cell_type == "BLOCK_RECTILINEAR" } {
		puts $fp_write_bpa "$RegionName BLOCK RECTILINEAR $print_rect_extra"
		} elseif { $print_cell_type == "REGION_RECTILINEAR" } {
		puts $fp_write_bpa "$RegionName BLOCK RECTILINEAR $print_rect_extra"
		}

		}
	   } elseif { $model == "RPM" && $found_region_section == 1 && $found_current_modeling_section == 1 && $found_model == 1 } {	
			#do nothing for now in this release	
	   } elseif { $model == "AVM" && $found_region_section == 1 && $found_current_modeling_section == 1 && $found_model == 1 } { 
			 		
			if { $found_model == 1 && ![regexp "MODEL_TYPE" $line7] && ![regexp "FREQ" $line7]} {
				set avm_file $line7
				puts $fp_write_extra_gsr "$avm_file avm"
				if { ![regexp "FULLCHIP" $print_cell_type] } {
                	puts $fp_instance_toggle_rate "$RegionName 1"
                	puts $fp_gsc "$RegionName TOGGLE"
			puts $fp_write_sta "$RegionName TW 0 0 $freq_import_current"
                	} else { 
                	puts $fp_instance_toggle_rate "adsFULLCHIP 1"
                	puts $fp_gsc "adsFULLCHIP TOGGLE"
			puts $fp_write_sta "adsFULLCHIP TW 0 0 $freq_import_current"
                	}

			   }

	if { $found_model == 1 && ![regexp "MODEL_TYPE" $line7] && ![regexp "#FREQ" $line7]} {
                        for {set i 1} {$i <= $cnetlayer } {incr i} {
                if { $Region_voltage($i) != 0} {
                set pin_voltage [append pin_voltage "$Region_pin($i)\=$Region_voltage($i)"]
                set vddpin [append vddpin "$Region_pin($i)"]
                } else { set vsspin [append vsspin "$Region_pin($i)"] }

                if { $print_cell_type == "FULLCHIP" || $print_cell_type == "FULLCHIP_RECTILINEAR"} {
                puts $fp_write_bpa "FULLCHIP FULLCHIP $Region_layer($i) $Region_net($i) -1"
                } elseif { $print_cell_type == "BLOCK" || $print_cell_type == "BLOCK_RECTILINEAR"} {
                puts $fp_write_bpa "$RegionName BLOCK $Region_layer($i) $Region_net($i) -1"
                } elseif { $print_cell_type == "HARD-IP" } {
                puts $fp_write_bpa "$RegionName PIN $Region_layer($i) $Region_net($i) -1"
                } elseif { $print_cell_type == "REGION" } {
                puts $fp_write_bpa "$RegionName REGION $Region_layer($i) $Region_net($i) -1 $x1 $y1 $x2 $y2"
                }  elseif { $print_cell_type == "REGION_RECTILINEAR" } {
		puts $fp_write_bpa "$RegionName REGION $Region_layer($i) $Region_net($i) -1 $min_x $min_y $max_x $max_y "
		}


                   }

		if { $print_cell_type == "BLOCK_RECTILINEAR" } {
		puts $fp_write_bpa "$RegionName BLOCK RECTILINEAR $print_rect_extra"
		} elseif { $print_cell_type == "REGION_RECTILINEAR" } {
		puts $fp_write_bpa "$RegionName BLOCK RECTILINEAR $print_rect_extra"
		}


                }

	   } elseif { $model == "PWL" && $found_region_section == 1 && $found_current_modeling_section == 1 && $found_model == 1 } {
			set pwl_file $line7
			set create_config 1
			set print_pwl_current 1
	   } elseif { $model == "Sim2iprof" && $found_region_section == 1 && $found_current_modeling_section == 1 && $found_model == 1 } {
			#run sim2iprof on background and get the apl files
	   
if { $found_model == 1 && ![regexp "MODEL_TYPE" $line7] && ![regexp "FREQ" $line7]} {
                                set sim_file $line7
				set print_sim_current 1
                                if { ![regexp "FULLCHIP" $print_cell_type] } {
                        puts $fp_instance_toggle_rate "$RegionName 1"
                        puts $fp_gsc "$RegionName TOGGLE"
                        puts $fp_write_sta "$RegionName TW 0 0 $freq_import_current"
                        } else { 
                        puts $fp_instance_toggle_rate "adsFULLCHIP 1"
                        puts $fp_gsc "adsFULLCHIP TOGGLE"
                        puts $fp_write_sta "adsFULLCHIP TW 0 0 $freq_import_current"
                        }

                           }

        if { $found_model == 1 && ![regexp "MODEL_TYPE" $line7] && ![regexp "#FREQ" $line7]} {
                        for {set i 1} {$i <= $cnetlayer } {incr i} {
                if { $Region_voltage($i) != 0} {
                set pin_voltage [append pin_voltage "$Region_pin($i)\=$Region_voltage($i)"]
                set vddpin [append vddpin "$Region_pin($i)"]
                } else { set vsspin [append vsspin "$Region_pin($i)"] }

                if { $print_cell_type == "FULLCHIP" || $print_cell_type == "FULLCHIP_RECTILINEAR" } {
                puts $fp_write_bpa "FULLCHIP FULLCHIP $Region_layer($i) $Region_net($i) -1"
                } elseif { $print_cell_type == "BLOCK" || $print_cell_type == "BLOCK_RECTILINEAR" } {
                puts $fp_write_bpa "$RegionName BLOCK $Region_layer($i) $Region_net($i) -1"
                } elseif { $print_cell_type == "HARD-IP" } {
                puts $fp_write_bpa "$RegionName PIN $Region_layer($i) $Region_net($i) -1"
                } elseif { $print_cell_type == "REGION" } {
                puts $fp_write_bpa "$RegionName REGION $Region_layer($i) $Region_net($i) -1 $x1 $y1 $x2 $y2"
                } elseif { $print_cell_type == "REGION_RECTILINEAR" } {
		puts $fp_write_bpa "$RegionName REGION $Region_layer($i) $Region_net($i) -1 $min_x $min_y $max_x $max_y"
	}
                   }

		  if { $print_cell_type == "BLOCK_RECTILINEAR" } {
		puts $fp_write_bpa "$RegionName BLOCK RECTILINEAR $print_rect_extra"
		} elseif { $print_cell_type == "REGION_RECTILINEAR" } {
		puts $fp_write_bpa "$RegionName BLOCK RECTILINEAR $print_rect_extra"
		}


                }


}

	if { $print_pwl_current == 1 && ![regexp "#MODEL_TYPE" $line7] && ![regexp "#FREQ" $line7] && $found_current_modeling_section } {

		if { $freq_import_current != "NA" } {

		if { $print_cell_type != "FULLCHIP" || $print_cell_type != "FULLCHIP_RECTILINEAR"} {
		puts $fp_write_sta "$RegionName TW 0 0 $freq_import_current"
		} else { puts $fp_write_sta "adsFULLCHIP TW 0 0 $freq_import_current" }
		}
		set pin_voltage ""
		set vddpin ""
		set vsspin ""
		
		for {set i 1} {$i <= $cnetlayer } {incr i} {
		if { $Region_voltage($i) != 0} {
		set pin_voltage [append pin_voltage "$Region_pin($i)\=$Region_voltage($i) "]
		set vddpin [append vddpin "$Region_pin($i) "] 
		} else { set vsspin [append vsspin "$Region_pin($i) "] }

		
		if { $print_cell_type == "FULLCHIP" || $print_cell_type == "FULLCHIP_RECTILINEAR" } {
		puts $fp_write_bpa "FULLCHIP FULLCHIP $Region_layer($i) $Region_net($i) -1"
		} elseif { $print_cell_type == "BLOCK" || $print_cell_type == "BLOCK_RECTILINEAR"} {
		puts $fp_write_bpa "$RegionName BLOCK $Region_layer($i) $Region_net($i) -1"
		} elseif { $print_cell_type == "HARD-IP" } {
		puts $fp_write_bpa "$RegionName PIN $Region_layer($i) $Region_net($i) -1"
		} elseif { $print_cell_type == "REGION" } {
		puts $fp_write_bpa "$RegionName REGION $Region_layer($i) $Region_net($i) -1 $x1 $y1 $x2 $y2"
		} elseif { $print_cell_type == "REGION_RECTILINEAR" } {
		puts $fp_write_bpa "$RegionName REGION $Region_layer($i) $Region_net($i) -1 $min_x $min_y $max_x $max_y "
		}
		

}

		if { $print_cell_type == "BLOCK_RECTILINEAR" } {
		puts $fp_write_bpa "$RegionName BLOCK RECTILINEAR $print_rect_extra"
		} elseif { $print_cell_type == "REGION_RECTILINEAR" } {
		puts $fp_write_bpa "$RegionName BLOCK RECTILINEAR $print_rect_extra"
		}

	if { $model == "PWL" } {
	if { [regexp "/" $RegionName] } {
	set name [split $RegionName "/"]
	set Region [lindex $name 1]
	} else {set Region $RegionName}	
	set fp_import_apl_config($Region) [open "$output_dir/$RegionId.cfg" w]

	set fp_read_pwl [open "$pwl_file" r]
	
	while { [gets $fp_read_pwl line_pwl] >= 0 } {
	set words [split $line_pwl " "]

        if { [lindex $words 0] == "+" && ![regexp {\)} $line_pwl] } {                           set temp_t2 [lindex $words 1];                                               }

	if { [lindex $words 1] == "0e-12" } {
	set t_1 0
	} elseif {[regexp {\)} $line_pwl]} {
	set t_2 $temp_t2;
	set duration [expr $t_2-$t_1-0.000000000001]
	}
	
}

	close $fp_read_pwl

	if { $print_cell_type == "FULLCHIP" || $print_cell_type == "FULLCHIP_RECTILINEAR"} {
	set master "adsFULLCHIP" 
} else { set master $master }	
	puts "$fp_import_apl_config($Region)" "CELL $master \{\nFILENAME \{\n $pwl_file $pin_voltage\n\}\n\n"
	puts "$fp_import_apl_config($Region)" "VDD_PIN $vddpin\nVSS_PIN $vsspin\n\n" 

	puts "$fp_import_apl_config($Region)" "SIM_TIME \{\nREAD 0 \nWRITE 0\n\n\}\n\n"
	puts "$fp_import_apl_config($Region)" "DURATION $duration\n\n"
	puts "$fp_import_apl_config($Region)" "LEAKAGE 0\n\n\}"

	close "$fp_import_apl_config($Region)"
}
	if { ![regexp "FULLCHIP" $print_cell_type] } {
	puts $fp_instance_toggle_rate "$RegionName 1"	
	puts $fp_gsc "$RegionName TOGGLE"
	} else {
	puts $fp_instance_toggle_rate "adsFULLCHIP 1"
	puts $fp_gsc "adsFULLCHIP TOGGLE"
	}

}

if { $print_pwl_current == 1 && $model == "PWL"} {
 	if { ![regexp "MODEL_TYPE" $line7] && ![regexp "FREQ" $line7] && $found_current_modeling_section == 1} {
	set fp6 [open "temp6" w]
	puts $fp6 "$env(APACHEROOT)/bin/sim2iprof $output_dir/$RegionId.cfg -o $output_dir/$RegionId.current"

	close $fp6

	if { [catch { exec bash temp6 }] == 0 } {
	#puts "current success: $Region"
	} else {
	puts $RegionName
	global errorInfo
	puts $errorInfo
	}
	puts $fp_write_extra_gsr "$output_dir/$RegionId.current current"
}
}

if { $print_sim_current == 1 && $model == "Sim2iprof"} {
	if { [regexp "/" $RegionName] } {
	set name [split $RegionName "/"]
	set Region [lindex $name 1]
	} else {set Region $RegionName}	
 	if { ![regexp "MODEL_TYPE" $line7] && ![regexp "FREQ" $line7] && $found_current_modeling_section == 1} {
	set fp7 [open "temp7" w]
	puts $fp7 "$env(APACHEROOT)/bin/sim2iprof $sim_file -o $output_dir/$RegionId.current"

	close $fp7

	if { [catch { exec bash temp7 }] == 0 } {
	#puts "current success: $Region"
	} else {
	puts $RegionName
	global errorInfo
	puts $errorInfo
	}
	puts $fp_write_extra_gsr "$output_dir/$RegionId.current current"
}
}





}		

if { $modeling == "cap" && $cap_use == "CAP_PER_UNIT_AREA" && $found_region_section == 1 && $found_cap_modeling_section == 1} {

	if { [regexp "CAP_VALUE" $line7] && $found_region_section == 1 && $found_cap_modeling_section == 1 } {

		if { [regexp "/" $RegionName] } {
	        set name [split $RegionName "/"]
        	set Region [lindex $name 1]
        	} else {set Region $RegionName}
		
		if { $print_cell_type == "FULLCHIP" || $print_cell_type == "FULLCHIP_RECTILINEAR"} {
		set master "adsFULLCHIP"
		} else { set master $master }

		set words [split $line7 " "]
		set cap_per_unit_area [lindex $words 1]
		set cap_value [expr $cap_per_unit_area*10e-04*$area]
		#set cap_value [lindex $words 1]
		#generate cdev file based on area based cap given
		set fp_cap_file($RegionName) [open "$output_dir/cap_per_unit_area_$RegionId.cdev" w]
		puts "$fp_cap_file($RegionName)"  "data_version cell.cdev 5v3\ntool_name aplcap\nversion 5.3 rel 0B\nReleased Date: date/month/year\ndata_tag asc 0 Sun Jan 21 19:10:45 2007\nfile_signature /proj/coremac11/products/gs60/dev/Char/ESPEC//lib_files/char_inputs/hspice_models/2006.12.08/model.paths.weak_mod 125 1.21 -322320349 SS"
		set cdev "$master 200 $cnetlayer "
		for { set i 1 } { $i <= $cnetlayer } { incr i } {
		set cdev [append cdev "$Region_pin($i) $cap_value 0 $cap_value 0 0 0  " ]
		}
		puts "$fp_cap_file($RegionName)" $cdev
		
		close "$fp_cap_file($RegionName)"
		

set fp1 [ open "temp" w ]

puts $fp1 "$env(APACHEROOT)/bin/aplchk -c -a2b $output_dir/$RegionId.cdev $output_dir/cap_per_unit_area_$RegionId.cdev"

close $fp1

if { [ catch { exec bash temp }] == 0 } {
#puts "cap success $Region" 
} else {
#global errorInfo
#puts "$errorInfo"
}

puts $fp_write_extra_gsr "$output_dir/$RegionId.cdev cap"
}

} elseif { $modeling == "cap" && $cap_use == "USER_SPECIFIED" && $found_region_section == 1 && $found_cap_modeling_section == 1} {
	if { [regexp "#NET" $line7] && $found_region_section == 1 && $found_cap_modeling_section == 1 && $found_user_cap_net_section == 0 } {

		set found_user_cap_net_section 1
           } elseif { [regexp "#END_NET" $line7] && $found_region_section == 1 && $found_cap_modeling_section == 1 && $found_user_cap_net_section == 1 } {

                       set found_user_cap_net_section 0
		       set count_user_spec_cap 0
		       set print_user_cap 1
                    } 

if { $found_user_cap_net_section && [info exists found_user_cap_net_section] & ![regexp "#NET" $line7] } {

	set count_user_spec_cap [expr $count_user_spec_cap+1]

	set words [split $line7]
	set net_user_cap($count_user_spec_cap) [lindex $words 0]
	set ESR($count_user_spec_cap) [lindex $words 1]
	set ESC($count_user_spec_cap) [lindex $words 2]
	set Leakage($count_user_spec_cap) [lindex $words 3]
	set cusc $count_user_spec_cap
}

	if { [info exists print_user_cap] && $print_user_cap == 1 } {

	if { $print_cell_type == "FULLCHIP" || $print_cell_type == "FULLCHIP_RECTILINEAR"} {
                set master "adsFULLCHIP"
                } else { set master $master }

	if { [regexp "/" $RegionName] } {
        set name [split $RegionName "/"]
        set Region [lindex $name 1]
        } else {set Region $RegionName}


	set fp_user_spec_cap($RegionName) [open "$output_dir/user_specific_cap_$RegionId.cdev" w]
	puts "$fp_user_spec_cap($RegionName)"  "data_version cell.cdev 5v3\ntool_name aplcap\nversion 5.3 rel 0B\nReleased Date: date/month/year\ndata_tag asc 0 Sun Jan 21 19:10:45 2007\nfile_signature /proj/coremac11/products/gs60/dev/Char/ESPEC//lib_files/char_inputs/hspice_models/2006.12.08/model.paths.weak_mod 125 1.21 -322320349 SS"
	set cdev "$master 200 $cnetlayer "
	for {set i 1} {$i <= $cusc} {incr i} {
	set cdev [append cdev "$Region_pin($i) $ESC($i) $ESR($i) $ESC($i) $ESR($i) $Leakage($i) $Leakage($i) " ]  
	}
	puts "$fp_user_spec_cap($RegionName)" $cdev
	close "$fp_user_spec_cap($RegionName)"

	set fp2 [ open "temp2" w ]

	puts $fp2 "$env(APACHEROOT)/bin/aplchk -c -a2b $output_dir/$RegionId.cdev $output_dir/user_specific_cap_$RegionId.cdev"

	close $fp2
        if { [ catch { exec bash temp2 }] == 0 } {
	#puts "cap success $Region"
	} else {
	#global errorInfo
	#puts "$errorInfo"
	}

	puts $fp_write_extra_gsr "$output_dir/$RegionId.cdev cap"
}


} elseif { $modeling == "cap" && $cap_use == "IMPORTING_APL_CAP" && $found_region_section == 1 && $found_cap_modeling_section == 1} {
		
	if { [regexp "MODEL_TYPE" $line7] && $cap_flag == 0 } {
		set cap_flag 1	
	   }

	if  { $cap_flag == 1 && ![regexp "MODEL_TYPE" $line7] } {
		set cap_apl $line7
		puts $fp_write_extra_gsr "$cap_apl cap"
	   }

}
} 
}
}

#Post Processing the output files to create an extra GSR 
 
close $fp_read
puts $fp_write_bpa "\}"
close $fp_write_bpa
close $fp_gsc
close $fp_write_sta
close $fp_instance_toggle_rate
puts $fp_def_cover "\}"
close $fp_def_cover
puts $fp_write_extra_gsr "\}\n\n"

puts $fp_write_extra_gsr "INSTANCE_TOGGLE_RATE_FILE $output_dir/instance_toggle_rate.txt\n\n"

puts $fp_write_extra_gsr "USER_STA_FILE $output_dir/final_user_sta.txt \n\n"

if { $final_freq != 0 } {
puts $fp_write_extra_gsr "DYNAMIC_SIMULATION_TIME [expr 1/$final_freq]\n\n"
}

puts $fp_write_extra_gsr "GSC_FILE $output_dir/design.gsc\n\n"
puts $fp_write_extra_gsr "POWER_MODE APL\n\n"
puts $fp_write_extra_gsr "IGNORE_MULTISTATE_ERROR 1\n\n"
puts $fp_write_extra_gsr "IGNORE_BPA_ERROR 1\n\n"
close $fp_write_extra_gsr
close $fp_extra_lef


#Appending Final BPA file to Extra GSR
set fp4 [open "temp4" w]
puts $fp4 "cat $output_dir/final_bap.txt >> $output_dir/extra.gsr"
close $fp4

if { [catch { exec bash temp4 }] == 0 } {
	} else {
	puts $RegionName
	global errorInfo
	puts $errorInfo
	}


#Appending Def cover cell to Extra GSR
set fp5 [open "temp5" w]
puts $fp5 "cat $output_dir/def_cover.txt >> $output_dir/extra.gsr"
close $fp5

if { [catch { exec bash temp5 }] == 0 } {
	} else {
	puts $RegionName
	global errorInfo
	puts $errorInfo
	}

set del_files [ glob *temp* ]
foreach tmp_file $del_files {
if { [ catch { file delete -force $tmp_file } ] == 0 } {

}
}


} else {
set fp_write_extra_gsr [open "$output_dir/extra.gsr" w]
close $fp_write_extra_gsr;
}

#puts "INFO : Changing CWD to original directory"
#cd ../../../../
cd $PWD
}


proc cdev_header_template { args } {


}




proc open_in_gps { args } {
######## open_in_gps script developed by Nita Simon (2014) #####
######## First version: without options #########
######## Second version : With options to call help function and additional data to be added to the GIS file created using extra_gis option ####
######## Third version : v3 : fp_only, extra_gps_tcl options added in script. Without option fp_only script will add import_all to all DEF files.########### Version chnages 3.1: import_ploc command from RedHawk. ######
proc help {} {

puts " USAGE : open_in_gps ?-extra_gis <extra_gis_setting_file>? ? -fp_only? ?-extra_gps_tcl <extra_gps_tcl_file>?"
puts " -fp_only : will import only the floorplan information from the DEF. Default behaviour is to import routing information as well."
puts " -extra_gps_tcl : additional commanda to be appended to the GPS cmd file can be specified using this keyword."
return
}


#to convert file name to absolute file path
proc true_path {f} {
  set dir_name [file dirname $f]
  set file_name [file tail $f]
  set tru_wd [pwd]
  cd $dir_name
  set cwd1 [pwd]
  set file_name [file join $cwd1 $file_name]
  cd $tru_wd
  return $file_name
}


proc rest_of_gsr {} {
#dummy brackets {{{{
gsr dump -o gps_run/extra_gsr.tcl
catch { exec sed -i '/TECH_FILE/d' gps_run/extra_gsr.tcl} 


exec /bin/sh -c "sed -i '/DEF_FILES/,/}/d' gps_run/extra_gsr.tcl"
exec /bin/sh -c "sed -i '/LIB_FILES/,/}/d' gps_run/extra_gsr.tcl"
exec /bin/sh -c "sed -i '/LEF_FILES/,/}/d' gps_run/extra_gsr.tcl"
exec /bin/sh -c "sed -i '/GDS_CELLS/,/}/d' gps_run/extra_gsr.tcl"

set dummy_var [gsr get SWITCH_MODEL_FILE]
if { [regexp "{.*}" $dummy_var] } {
#dummy bracket {
  exec /bin/sh -c "sed -i '/SWITCH_MODEL_FILE/,/}/d' gps_run/extra_gsr.tcl"
} else {
exec /bin/sh -c "sed -i 's/SWITCH_MODEL_FILE.*//' gps_run/extra_gsr.tcl"
}

}

#rest_of_gsr
#puts "Preraring setup for RedHawk-GPS"
message log "Preparing setup for RedHawk-GPS\n"
set flag_fp_only 0
set flag_batch 0
global env
set f1 0
set f2 0
set extra_gis1 ""
set argv [split $args]
if {[llength $argv] ==0 } { 
 set f3 0
} else {
   set state "flag"
   set extra_gis ""
   #puts "enetering else"
   #puts " $argv"
   foreach arg $argv {
	switch -- $state {
	   flag {
		 switch -glob -- $arg { 
		  -extra_gis { set state "extra_gis" }
		  -extra_gps_tcl { set state "extra_gps_tcl" }
		  -h* { help ; return }
		  -m* { help ; return }
		  -fp_only { 
				set flag_fp_only 1
				set state flag

		 	   }
		 
		 -b {
			set flag_batch 1
			set state flag

		  }
		  default { puts "Unrecognized flag $arg"; help ; return }
		}
	  } 
	  extra_gps_tcl {
	   	set extra_gps_tcl1 $arg
		#puts "$extra_gis1"
		if { ! [file exists $extra_gps_tcl1] } {
  			puts "File $extra_gps_tcl1 does not exist. Aborting execution."
 			 return
		} else {
			 # puts "file $extra_gis1 exists."
			 set f2 1
			  set extra_gps_tcl1 [true_path $extra_gps_tcl1]
		}

		set state flag
	   }
	}
    }

}


if { $flag_fp_only == 1 } {
puts "Only floorplan will be imported from DEF "
set additional_def_option " "
} else {
set additional_def_option "import_all"
}

file mkdir ./gps_run
set name [get design]
set tcl [open "gps_run/$name.tcl" w]
set sh [open "gps_run/run.sh" w]
set sw_file1 [open "gps_run/sw_file.out" w]
set p [pwd]
set files_kw {TECH_FILE LIB_FILES GDS_CELLS LEF_FILES DEF_FILES SWITCH_MODEL_FILE FREQ}
set nets_kw {VDD_NETS GND_NETS}
set sw_file "gps_run/sw_file.out"




#starting main loop
foreach kw $files_kw {

 set value [gsr get $kw]

 #checking for empty elements
 if {[string match "#*" $value]} {
  #puts $gis "$value"
  continue
 }
 if {$kw == "FREQ"} {
  set val [gsr get FREQ]	
  puts $tcl "config set frequency $val \n"
  continue
 }
 if {$kw == "TECH_FILE"} {

  set val [file join [pwd] $value]
  set val [true_path $value]

  puts $tcl "config set tech { $val }\n"
  continue
 }

 if {$kw == "SWITCH_MODEL_FILE" } {
 
   set v [regsub -all "\n" $value " "]
   set v [regsub -all "{" $v ""]
   set v [regsub -all "}" $v ""] 
   #splitting with multiple whitespace
   set v [split [regsub -all {\s+} $v " "]]
   #removing trailing empty space
   set v [lreplace $v end end]
   set v [lrange $v 1 [llength $v]]
   #set sw1 [lindex $v 0]
   #initializing an empty list and finding true path of files.
   set sw2 [list]
   foreach sw1 $v {
    set sw1 [file join [pwd] $sw1]
    set sw1 [true_path $sw1]
    lappend sw2 $sw1
   }
   #checking for empty elements, single element, multiple element.
     if {0 ==[llength $sw2]} {
        #puts $gis "# SWITCH_MODEL_FILE"
        #set flag 1
        continue
     } elseif {1 < [llength $sw2]} {
          #puts "entered eleseif"
          foreach file1 $sw2 {
            exec cat $file1 >> $sw_file
            #puts "$sw_file $file1"
           }
       set sw_file [file join [pwd] $sw_file]
       set sw_file [true_path $sw_file]
       puts $tcl "data read switch_model { $sw_file }"
       continue
      } else {
         puts $tcl "data read switch_model { $sw2 }"
         continue
       }
 } 
 
 set v [regsub -all "\n" $value " "]
 set v [regsub -all "{" $v ""]
 set v [regsub -all "}" $v ""] 
 #splitting with multiple whitespace
 set v [split [regsub -all {\s+} $v " "]]
 #removing trailing empty space
 set v [lreplace $v end end]
 set v [lrange $v 1 [llength $v]]
 #checking for empty elements
 if {0 ==[llength $v]} {
   #puts $gis "$kw { \n }"
   continue
 }


 if {$kw == "GDS_CELLS" } {
 # we need to find the lef files in directory, then add to the new directory, then strip the lef files of apachecell.
  set count 0
  if { [llength $v] == 0 } {
    continue
  }
  foreach val $v {
        if { [regexp -- "^#" $val] } {
		continue
	} 
	set count2 [ expr $count -1]
	set v2 [lindex $v $count2]
	#puts "$count $val $count2 $v2"
	if { $count % 2 == 1} {
#	   lappend lef_list_gds [glob -nocomplain -directory $val *adsgds.lef]
		set file_name $val/${v2}_adsgds.lef
	     if { [ file exists $file_name ] } {
		lappend lef_list_gds "$val/${v2}_adsgds.lef"
	     }
	}

       incr count
  }

  file mkdir ./gps_run/gds_cells
  foreach val $lef_list_gds {
	exec cp -f $val ./gps_run/gds_cells/
  }
  set lef_list_gds [glob -nocomplain -directory gps_run/gds_cells *]

  foreach val $lef_list_gds {
	lappend lef_files_gds [true_path $val]
	set val [true_path $val]
	set fp [open temp_cmd w]
	puts $fp "sed -i 's/_APACHECELL//g' $val"
	close $fp
	exec bash ./temp_cmd 
	file delete ./temp_cmd
#	exec mv -f ${val}_copy $val
  }
 # puts "$lef_files_gds"
  continue

  #closing braces for gds_cells if
 }
#needs to be changed to reflect different ones for each new kw. 
	if { $kw == "DEF_FILES" } {
		puts -nonewline $tcl "data read defs "
	}
	if { $kw == "LEF_FILES" } {
		puts -nonewline $tcl "data read lefs {"
		##dummy end brace }
	}
	if { $kw == "LIB_FILES" } {
		puts -nonewline $tcl "config set libs {"
		##dummy end brace }
	}
	if { $kw == "GDS_CELLS" } {
		#puts -nonewline $tcl "data read gds {"
		##dummy end brace }
	}
	 
#puts $gis "$kw {"
 #} to compensate for the braces in quotes.
 
 if {$kw == "DEF_FILES"} {
   set length [llength $v]
 }
 if {$kw == "LEF_FILES"} {
   set length_lef [llength $v]
   set count 0
   #set v2 $v
    
foreach val $v {
     #matching string to find commented file names.
     if {[string match "#*" $val]} {
       #puts $gis "$val"
       continue
     }
    # if {[string match ".gz$" $val]} {
    #     continue
     # }

	
     set val_copy $val
     set val [file join [pwd] $val]
     set val [true_path $val]
	set cond_lefs 1
	#puts "$v"
	if { [ regexp -- ".lefs$" $val] } {
 		set cond_lefs 0
		#puts "found lefs file"
	}  
	if { $cond_lefs == 0 } {
	if { [file exists $val] } {
         set fp [open $val]
        while {[gets $fp line] >= 0} {
	 if [ regexp -- "^#" $line ] {
		continue
	  }
	 regsub -all -- {[[:space:]]+} $line "" line
	if {$line == "" } {
		continue
	}

	   lappend v $line
          }
		close $fp
		#puts "$cond_lefs cond_lef has been left unset"
		regsub $val_copy $v "" v
		#puts " $v"

         }
	}
      }		
 while {[lsearch $v {}] >= 0} { 
    set v [lreplace $v [lsearch $v {}] [lsearch $v {}]] 
 }

  foreach val $v {
    set found_tech_lef 0
     #matching string to find commented file names.
     if {[string match "#*" $val]} {
       #puts $gis "$val"
       continue
     }
     
     set val [file join [pwd] $val]
     set val [true_path $val]
	#puts "new: val : $val "
     set found_tech_lef 0 
     set re "TYPE CUT "

set filetype [ exec file $val ] ;
if { [ regexp "gzip compressed data" $filetype ] } {

if { [ catch { file delete -force .tmp.lef.gz .tmp.lef } ] } {

}

if { [ catch { exec cp $val .tmp.lef.gz } ] == 0 } {


if { [ catch { exec gunzip .tmp.lef.gz } ] == 0 } {

set file_open [ true_path .tmp.lef ]

}

}

} else {

set file_open $val

}
     set fp [open $file_open]
        while {[gets $fp line] >= 0} {
	 if [ regexp -- "^#" $line ] {
		continue
	  }
            if [regexp -- $re $line] {
                lappend tech_lef $val
		set found_tech_lef 1
		break
            } 
        } 
        close $fp
	if { $found_tech_lef == 1} {
		lappend tech_lefs $val
	} else {
		lappend non_tech_lef $val
	}
    }


if { [ catch { file delete -force .tmp.lef.gz .tmp.lef } ] } {

}

   ## the foreach loop has ended. now dump the appropriate names into the gis file.
  set no_tech_lef 0
    if { [ info exists tech_lefs ] } {
     #puts $gis "### Tech LEF section"
     foreach fp $tech_lefs {
	puts -nonewline $tcl " $fp "
     }
   } else {
	set no_tech_lef 1
   }
  if { [info exists non_tech_lef ] } {
     #puts $gis "### Non Tech LEF."
     foreach fp $non_tech_lef {
	puts -nonewline $tcl " $fp "
     }
 }
  if { [info exists lef_files_gds] } {
      #puts $gis "### GDS LEF cells"
      foreach fp $lef_files_gds {
	puts -nonewline $tcl " $fp "
      }
  }
    # { compensatiry braces
    puts $tcl " } \n"
     
    continue

 }

#puts " $v" 
 if { $kw == "DEF_FILES" } {
foreach val $v {
     #matching string to find commented file names.
     if {[string match "^#*" $val]} {
      # puts $gis "$val"
       continue
     }
    if {$val == "top" || $val == "block" || $val == "custom" || $val == "routed_block" || $val == "TOP" || $val == "Top" } {
           continue 
      }
   
      #puts "$val is val" 
     set val_copy $val
     set val [file join [pwd] $val]
     set val [true_path $val]
	set cond_defs 1
       if { [ regexp -- ".defs$" $val] } {
		set cond_defs 0
	} 
	if { $cond_defs == 0 } {
      #puts "entered into cond_defs == 0 for $val"
	if { [file exists $val] } {
	#puts "file is found to exist"
         set fp [open $val r]
         while {[gets $fp line] >= 0} {
	   if [ regexp -- "^#" $line ] {
		continue
		 #puts " found # lines lines in $val"
	   }
  	  regsub -all -- {[[:space:]]+} $line " " line
	 set line2 [string trim $line ]
	 set line $line2
	  if {$line == " " } {
	   continue
	     #puts " found empty lines in $val"
	  }
 	#puts "$line"	
	 #splitting with multiple whitespace
	 set line [split [regsub -all {\s+} $line " "]]
	#puts "[llength $line]"
	 
	 #checking for empty elements
	 if { [llength $line] == 0 } {
	   continue
	 } else {
		#puts "$line"
	    foreach elem $line {
		#puts "$elem"
		lappend v $elem
	    }
	 }
        }
		close $fp
		#puts "$cond_defs cond_def has been left unset"
		# removing the element *.defs from list v
		regsub $val_copy $v "" v
		#puts " $v"
	} else {
		puts " $val file is missing"
	}

	}
      
       }
  }		
  while {[lsearch $v {}] >= 0} { 
    set v [lreplace $v [lsearch $v {}] [lsearch $v {}]] 
  }
 if {$kw == "DEF_FILES"} {
   set length [llength $v]
 }

  #puts "$v" 
 #count to keep track of the top and block keywords in gsr. count must be incremented in the beginning of the loop.
 set count 0
 #loop to convert file path and write the path to gis.
 foreach val $v {
     #puts " $val first"
     incr count
      set v2 [lindex $v $count]
       #puts "my val: $v2"
     if {$val == "top" || $val == "block" || $val == "custom" || $val == "routed_block" || $val == "TOP" || $val == "Top" || $val == "CUSTOM"} {
           continue 
      }
     #matching string to find commented file names.
     if {[string match "#*" $val]} {
       #puts $gis "$val"
       continue
     }
     set val [file join [pwd] $val]
     set val [true_path $val]
     set v2 [lindex $v $count]
     
     if {$kw == "DEF_FILES" && $count == $length && $v != "top" && $v != "TOP" && $v != "Top"} {
       puts -nonewline $tcl "{ $val top $additional_def_option } "

       continue
     }
     if { $v2 == "top" || $v2 == "block" || $v2 == "routed_block" || $v2 == "TOP" || $v2 == "Top" } {
       puts -nonewline $tcl "{ $val $v2 $additional_def_option } "
     } else {
	    if { $kw == "DEF_FILES" } {
	       puts -nonewline $tcl "{ $val block $additional_def_option } "
	    } else {
	          puts -nonewline $tcl " $val "
	    }
       }
  }
 if { $kw == "DEF_FILES" } {
	puts $tcl "\n"
 }    
 if {$kw != "SWITCH_MODEL_FILES" && $kw != "TECH_FILE" && $kw != "DEF_FILES"} {
   #{ to compensate for braces in quotes
    puts $tcl "}"
  }
  
}
set ploc_file "adsRpt/PG.ploc"
if { [file exists $ploc_file] } {

  set ploc_file_path [true_path $ploc_file]
  puts $tcl "data read ploc /work/${name} $ploc_file_path" 

} else {

  puts "adsRpt/PG.ploc file not available. PLOC information will not be imported in GPS."

} 

###############################
##### net name section #######
###############################


 foreach kw $nets_kw {
 
 set value [gsr get $kw]
 set v [regsub -all "\n" $value " "]
 set v [regsub -all "{" $v ""]
 set v [regsub -all "}" $v ""] 
 #splitting with multiple whitespace
 set v [split [regsub -all {\s+} $v " "]]
 #removing trailing empty space
 set v [lreplace $v end end]
 set v [lrange $v 1 [llength $v]]
 #checking for empty elements
 if {0 ==[llength $v]} {
   #puts $gis "$kw { \n }"
   continue
 }
	#puts "$v"
 	set count 0
	foreach val1 $v {
		incr count
		regsub -all {/} $val1 {\/} val3
		if { [expr $count % 2] != 0 } {
			set val2 [lindex $v $count] 
			puts $tcl "if \{ \[catch \{db edit /work/${name}::p/net:${val3} -volt $val2\} \] \} \{ \} "
		}
	}
 
}


##############################
### POST PROCESSING #####
#############################

 if { $flag_batch == 0 } {
 puts $sh "$env(APACHEROOT)/bin/redhawk_gps -f $name.tcl &"
 } else {
 puts $sh "$env(APACHEROOT)/bin/redhawk_gps -b $name.tcl &"
 }
 close $sh
 
close $tcl
if {$f2 == 1} {
 exec cat $extra_gps_tcl1 >> "gps_run/$name.tcl"
}

  if { $no_tech_lef == 1 } {
	puts " No Tech LEF found. \nGPS will not be invoked. \nSetups created at [pwd]/gps_run. \nPlease modify [pwd]/gps_run/$name.gis to include tech lef also. Tech lef should be the first lef under LEF_FILES"
	return
  }
 set cwd [pwd]
 cd gps_run
 exec bash run.sh &
 cd $cwd
   message log "GPS setup done. Launching RedHawk-GPS...\n"
}
proc switch_spec_creation { args } {
if {$args eq "" } {puts "ERROR: wrong usage " ; help ;}
set argv [ split $args ] ;
global cc;
set fgcs 0
set fgcfg 0

set state flag ;
foreach arg $argv {
   switch $state {
          flag {
             switch -exact -- $arg { 
		-config { set state config } 
		-cell { set state topcell } 
                -clear_spec { set state clear_spec }
		-help { help ; return ;}
		-h { help ; return ;}
		default { puts "Wrong argument $arg"; help ; return; }
             }          
          }
          config { set state flag ; set file $arg ; set fgcfg 1 }
          topcell { 	 set state flag;
		if {![info exists cc] } { 
			if {[regexp "work\/" $arg ]} {
			set tp_cell $arg ;
	   		} else { 
			set tp_cell "/work/$arg" ; 
			} 
		} 
	  }
	  clear_spec {
			set state flag ; 
			if { $arg == 1 } { set fgcs 1 ; }
			}
   }
}

if {[info exists cc ]} {set tp_cell $cc}

if { $fgcs } { clr_spec $tp_cell ;  if { !$fgcfg } { return ;} }
if { !$fgcfg } { puts " No config file specified Eixting." ; return ; } else { puts " Reading config file: $file " } 



set i 0
set sw_flag 1
set dv_flag 1
array set a {}
set fp1 [open $file "r"] 
set fdata1 [read $fp1]
close $fp1;
set fdata [split $fdata1 "\n"]
#for1
foreach data $fdata {

switch -regexp $data {
 START_ROUTE_MESH_SPEC {
	set a($i,fg0) 0 ; set a($i,fg1) 0 ; set a($i,fg2) 0 ; set a($i,fg3) 0 ;
	set a($i,fg4) 0 ; set a($i,fg5) 0 ; set a($i,fg6) 0 ; set a($i,fg7) 0 ;
	set a($i,fg8) 0 ; set a($i,fg9) 0 ; set a($i,fg10) 0			
	set a($i,flag2) 0 ;	#for Drop Via Layer
	set a($i,flag3) 0 ;	#for drop via layer
	set a($i,flag4) 0 ;	#for via_rules/models
	
                         }
 END_ROUTE_MESH_SPEC { incr i }
 ALL_SWITCHES { 
	if {[regexp "NO" $data]} { set a($i,fg0) 1 } 
	 }
 SWITCH_FILE_PATH { set sw_file_path [ regexp -all -inline {\S+} $data ] ; set a($i,sw_file) [lindex $sw_file_path 1 ] }
 DOMAIN_PAIR { 
	set data1 [string trim $data] ; 
	set data2 [ split $data1 {:} ];
	set a1 [ regexp -all -inline {\S+} [lindex $data2 1 ] ] 
	set a($i,ext) [lindex $a1 0] ; set a($i,int) [lindex $a1 1] ;

	}
 NET_PATTERN { set data1 [string trim $data] ; set data2 [ split $data1 {:} ]; set a($i,np) [lindex $data2 1 ]  }
 DROP_VIA_LAYER {
	#puts "enter_DV"
	set data1 [ split $data {:} ] ;
	set data2 [ regexp -all -inline {\S+} [lindex $data1 1] ] ; 
	#set a($i,fg8) 1 ; 
	# set a($i,vu) [lindex $data2 1] ;  set a($i,vl) [lindex $data2 0]
	if { [ regexp "PIN" [lindex $data2 0] ] } { 
	 set a($i,tap_lyr)  [lindex [split [lindex $data2 0] "(PIN)" ] 0]
	 set a($i,fg10) 1
	 set n_lst [ regexp -all -inline {\S+} $a($i,np)] ; set nets [lsort -unique $n_lst ] ;
	 } elseif { "-" ne [lindex $data2 0] } {
	 set a($i,vl) [lindex $data2 0] ; set a($i,fg8) 1 ; 
	}
	if { "-" ne [lindex $data2 1] } { set a($i,vu) [lindex $data2 1] ; set a($i,fg9) 1 ;  } 
	}
 LAYER { 
	set data1 [string trim $data] ; 
	set data2 [ split $data1 {:} ]; 
	set a($i,lyr) [lindex $data2 1 ] 
	}
 DIR   { 
	set data1 [string trim $data] ; 
	set data2 [ split $data1 {:} ]; 
	set a($i,dir) [lindex $data2 1 ] ;
	 }
 WIDTH { set data1 [string trim $data] ; set data2 [ split $data1 {:} ]; set a($i,w) [lindex $data2 1 ]  }
 SPACING { set data1 [string trim $data] ; set data2 [ split $data1 {:} ]; set a($i,sp) [lindex $data2 1 ]  }
 PITCH { set data1 [string trim $data] ; set data2 [ split $data1 {:} ]; set a($i,pit) [lindex $data2 1 ];  }
 OFFSETS { 
	set data1 [string trim $data] ; 
	set data2 [ split $data1 {:} ]; 
	set a($i,off) [lindex $data2 1 ] ; 
	set a($i,fg1) 1 ;
	 }
 VIARULES { 
	set data1 [string trim $data] ; 
	set data2 [  regexp -all -inline {\S+} [ lindex  [split $data1 {:} ] 1 ] ];
	#set data2 [ split $data1 {:} ]; 
	if {"-" ne [lindex $data2 0] && !$a($i,fg3)} {
	   set a($i,viar) [lindex [split $data1 {:}] 1 ] ; 
	   set a($i,fg2) 1 
	}
	}
 VIAMODEL { 
	set data1 [string trim $data] ; 
	set data2 [  regexp -all -inline {\S+} [ lindex  [split $data1 {:} ] 1 ] ]; 
	if {"-" ne [lindex $data2 0] && !$a($i,fg2)} {
	   set a($i,viam) [lindex [split $data1 {:}] 1 ] ;
	   set a($i,fg3) 1 
	}
	}
 PERC_VIA_INSERTION { 
	set data1 [string trim $data] ; 
	set data2 [ regexp -all -inline {\S+} [ lindex [split $data1 {:}] 1 ]]; 
	if { "-" ne [lindex $data2 1] && "-" ne [lindex $data2 0] && !$a($i,fg5) && !$a($i,fg6) } {
	set a($i,pvi) [lindex [split $data1 {:}] 1 ] ; 
	set a($i,fg4) 1 ;
	}
	}
 ABSOLUTE_VALUES { 
	set data1 [string trim $data] ; 
	set data2 [ regexp -all -inline {\S+} [ lindex [split $data1 {:}] 1 ]];
	#set data2 [ split $data1 {:} ];
	if { "-" ne [lindex $data2 1] && "-" ne [lindex $data2 0] && !$a($i,fg4) && !$a($i,fg6) } { 
	set a($i,av) [lindex [split $data1 {:}] 1 ] ; 
	set a($i,fg5) 1 ;
	}
	}
 NUM_CUTS { 
	set data1 [string trim $data] ; 
	set data2 [ regexp -all -inline {\S+} [ lindex [split $data1 {:}] 1 ]];
	#set data2 [ split $data1 {:} ]; 
	if { "-" ne [lindex $data2 1] && "-" ne [lindex $data2 0] && !$a($i,fg5) && !$a($i,fg4) } {
	set a($i,nc) [lindex [split $data1 {:}] 1 ] ; 
	set a($i,fg6) 1 ;
	}
	}
 VIA_INSERTION_LENGTH_GAP { 
	set data1 [string trim $data] ; 
	set data2 [ regexp -all -inline {\S+} [ lindex [split $data1 {:}] 1 ]];
	#set data2 [ split $data1 {:} ]; 
	if { "-" ne [lindex $data2 1] && "-" ne [lindex $data2 0] } {
	set a($i,vilg) [lindex [split $data1 {:}] 1 ] ;
	set a($i,fg7) 1 
	}
	}
 default {
	#under maintenece
	set data1 [ split $data {:} ] ;
	set data2 [ regexp -all -inline {\S+} [lindex $data1 1] ] ; 
	if { "-" ne [lindex $data2 1] } {  }
	 }

}
#puts "$data"
#end of for1
} 
#puts "end of for "
puts "Creating Spec Commands....";
set fp2 [ open "adsRpt/.switch_spec_cmd.tcl" "w" ]
set fp4 [ open "adsRpt/.switch_existing_spec.rpt" "w" ]

set inst_type "switch"
set inst [db query $tp_cell insts -type $inst_type]  ;
set insts [ join $inst " + "];

puts $fp2 "config set gui_auto_update off"

for { set j 0 } {$j < $i } {incr j} {
#puts "spec_$j $a($j,dp)" 
#puts  "enter for"
puts  -nonewline $fp2  "db create route_mesh $tp_cell -name sw_script_spec_00$j -nets { $a($j,np) } -layer $a($j,lyr) -dir $a($j,dir) -width $a($j,w) -spacing $a($j,sp) -hide_spec 1  -pitch $a($j,pit)  " ;
puts $fp4 "sw_script_spec_00$j" ;
if { $a($j,fg1) } { puts  -nonewline $fp2  "-offsets { $a($j,off) } "; }
if { $a($j,fg2) } { puts  -nonewline $fp2  "-via_rules { $a($j,viar) } "; }
if { $a($j,fg8) && $a($j,fg9) } { 
	puts  -nonewline $fp2  "-drop_via_layers { $a($j,vu) $a($j,vl) }   ";
	} elseif { !$a($j,fg8) && $a($j,fg9) } { 
	puts  -nonewline $fp2  " -drop_via_layers { $a($j,vu) - } ";
	} elseif { $a($j,fg8) && !$a($j,fg9) } { 
	puts  -nonewline $fp2  " -drop_via_layers { - $a($j,vl) } ";
	}

if { $a($j,fg3) } { puts  -nonewline $fp2  "-via_models { $a($j,viam) } ";}
if { $a($j,fg4) } { puts  -nonewline $fp2  "-via_occupancy_percentage { $a($j,pvi) } ";}
if { $a($j,fg5) } { puts  -nonewline $fp2  "-via_occupancy {  $a($j,av) } ";}
if { $a($j,fg6) } { puts  -nonewline $fp2  "-via_num_cuts { $a($j,nc) } ";}
if { $a($j,fg7) } { puts  -nonewline $fp2  "-vias_between_parallel_metals 1 -parallel_metals_via_spec  { $a($j,vilg) } ";}

#set c "\$cc"
#puts $j ;
if { $a($j,fg0) } { 
	#puts "$a($j,sw_file)"
	set fp3 [open "$a($j,sw_file)" "r" ];
	set dt [read $fp3 ] ; 
	set inst [ split $dt "\n" ] ;
	set insts [ join $inst " + "];
	#puts -nonewline $fp2 " -spec_boundary select_region { $insts } ";
	}  

puts -nonewline $fp2 " -spec_boundary { select_region { + $insts } }  ";
puts  -nonewline $fp2  "\n" ;

if { $a($j,fg10) } { 
puts  -nonewline $fp2  "db create pin_tap_spec $tp_cell -name sw_script_tap_spec_00$j -route_layer $a($j,lyr) -pin_layers $a($j,tap_lyr) -nets { $nets } ";
puts $fp4 "sw_script_tap_spec_00$j" ;

if { $a($j,fg2) } { puts  -nonewline $fp2  "-via_rules { $a($j,viar) } "; }
if { $a($j,fg3) } { puts  -nonewline $fp2  "-via_models { $a($j,viam) } ";}
if { $a($j,fg4) } { puts  -nonewline $fp2  "-via_occupancy_percentage { $a($j,pvi) } ";}
if { $a($j,fg5) } { puts  -nonewline $fp2  "-via_occupancy { $a($j,av) } ";}
if { $a($j,fg6) } { puts  -nonewline $fp2  "-via_num_cuts { $a($j,nc) } ";}
if { $a($j,fg7) } { puts  -nonewline $fp2  "-vias_between_parallel_metals 1 -parallel_metals_via_spec  { $a($j,vilg) } ";}

puts -nonewline $fp2 " -insts { $inst }  "

puts -nonewline $fp2 " \n"

 }
#puts "for end"

}

puts $fp2 "config set gui_auto_update on \nrefresh_gui" ;

close $fp2 ;
close $fp4 ;
source adsRpt/.switch_spec_cmd.tcl
}

proc clr_spec { top } {

puts "Cleaning up Existing spec" ; 
set fp4 [ open "adsRpt/.switch_existing_spec.rpt" "r" ]
set specs [split [ read $fp4 ] "\n" ];
set fp5 [ open "adsRpt/.clear_existing_spec.rpt" "w" ]
puts "tp$top 1"

foreach sp $specs { 
if { ( [ regexp "_tap" $sp ]  && [db exists $top/pin_tapping:$sp ] ) } { 
#	puts "enter tap"
	puts $fp5 "db delete $top/pin_tapping:$sp " ;
} elseif {$sp ne "" } {
#	puts "mesh spec"
#	puts "$top/rm:$sp"
	puts $fp5 "db delete $top/rm:$sp" ;
}

}

close $fp5 ;
close $fp4 ;
source adsRpt/.clear_existing_spec.rpt
} 

proc help {} {
puts "Usage:"
puts "switch_spec_creation -config <config_file> ? -cell <top_cell_name> ?  ?-clean_spec 1|0 ?"
puts "  -config <config_file>  to specify the config file"
puts "  -cell <top_cell_name>  top_cell_name can be specified in both the formats \" /work/TOP\"  or  \"TOP\" "
puts "  -clean_spec 1|0           if set to 1 and no config files specified, deletes existing spec created via script and exit. If set to 1 and config file specified, deletes existing spec created via script and creates the mesh based on the given config file"
puts "  -h | -help             help" ;    

}

#######################################################
## METAL DENSITY/EM/SESSION_SUMMARY DATA CREATION PROC
## Owner   : Siddalingesh
## Contact : siddalingesh.tenginakai@ansys.com
## Date    : 1/12/2015
########################################################
proc get_data_md_em_ss_from_all_sessions {args} {
set args_length [llength $args]
for {set si 0} {$si < $args_length } {incr si} {
		   switch -glob -- [lindex $args $si] {
					-gps_dir { incr si ; set gps_dir [lindex $args $si] ; }
                                        -design_name { incr si ; set design_name [lindex $args $si] ; }
					-clone_session_count { incr si ; set session_cnt [lindex $args $si] ;  }
					-help { puts "Usage: get_data_md_em_ss_from_all_sessions -gps_dir <dir_path> -clone_session_count <session counts> -design_name <design_name>"; return ; }
					default { 
					 error  "Error : unknown switch $arg \n Usage: get_data_md_em_ss_from_all_sessions -gps_dir <dir_path> -clone_session_count <session counts> -design_name <design_name>" 
					
					return
					}
				}
}
exec mkdir -p adsRHE
exec mkdir -p adsRHE/reports
set out_dir adsRHE/reports
set FileLOG [open "${out_dir}/.md_em_ss.log" "w"]
set FileAMD [open "${out_dir}/Avg_Metal_Density_per_session.rpt" "w"]
set FileLMD [open "${out_dir}/Metal_Density_per_layer.rpt" "w"]
set FileLMDD [open "${out_dir}/Metal_Density_per_layer_detail_summary.rpt" "w"]
set FileMEM [open "${out_dir}/Metal_EM_Violations_per_session.rpt" "w"]
set FileVEM [open "${out_dir}/Via_EM_Violations_per_session.rpt" "w"]
#set FileWMEM [open "${out_dir}/Worst_Metal_EM_per_session.rpt" "w"]
#set FileWVEM [open "${out_dir}/Worst_Via_EM_per_session.rpt" "w"]
set FileWERES [open "${out_dir}/Worst_Eff_res_per_session.rpt" "w"]
set FileWCRES [open "${out_dir}/Worst_case_res_per_session.rpt" "w"]
puts $FileAMD "#Session wise Average Metal Density Report\n#Session\tAvg_Metal_Density"
puts $FileLMD "#Layer wise Worst Metal Density Report\n#Layer\tMetal_Density\tSession"
puts $FileMEM "#Session wise Number of Metal EM Violations Report\n#Session\tWorst_EM(%)\tNumber_of_Violations"
puts $FileVEM "#Session wise Number of Via EM Violations Report\n#Session\tWorst_EM(%)\tNumber_of_Violations"
#puts $FileWMEM "#Session wise Worst Metal EM Violation Report\n#Session\tWorst_EM(%)"
#puts $FileWVEM "#Session wise Worst Via EM Violation Report\n#Session\tWorst_EM(%)"
puts $FileWERES "#Session wise Worst Case Resistance Report\n#Session\tResistance(Ohm)"
puts $FileWCRES "#Session wise Worst Case Effective Resistance Report\n#Session\tResistance(Ohm)"
puts $FileLMDD "#Layer wise all sessions's Metal density Report"
set flag_get_layer_stackup 1
for { set sj 0 } { $sj <= $session_cnt } { incr sj } {
if { $sj == 0 } {
set session "p"
set all_sessions $session
} else {
set session "c${sj}"
lappend all_sessions $session
}
set FileSS [open "${out_dir}/session_${session}_summary.rpt" "w"]
if { [file exists "$gps_dir/adsRpt/work/${design_name}/${session}/DropAndEM/Static/rh_results_summary.out"] } {
set rh_result_file "$gps_dir/adsRpt/work/${design_name}/${session}/DropAndEM/Static/rh_results_summary.out"
set rh_run_path "$gps_dir/adsRpt/work/${design_name}/${session}/DropAndEM/Static"
set analysis_type "Static"
puts $FileLOG "Start getting data from Session: ${session}"
flush $FileLOG
set flag_log 1
} elseif {[file exists "$gps_dir/adsRpt/work/${design_name}/${session}/DropAndEM/Dynamic/rh_results_summary.out"]} {
set rh_result_file "$gps_dir/adsRpt/work/${design_name}/${session}/DropAndEM/Dynamic/rh_results_summary.out"
set rh_run_path "$gps_dir/adsRpt/work/${design_name}/${session}/DropAndEM/Dynamic"
set analysis_type "Dynamic"
puts $FileLOG "Start getting data from Session: ${session}"
flush $FileLOG
set flag_log 1
} else {
puts $FileLOG "Getting data from Session: ${session} went Fail, due to RH failure or session count mentioned is wrong\n"
flush $FileLOG
set flag_log 0
continue
}
set flag_md_read 0
set flag_power_read 0
set flag_staticir_read 0
set end_staticir_flag 0
set flag_staticem_read 0
set flag_worst_res_inc_in_ss 1
set flag1_worst_res_inc_in_ss 0
#puts $FileLMDD "#Session $session"
puts $FileSS "#Grid Details:"
set FileRHS [open $rh_result_file r]
while {[gets $FileRHS line]>=0} {
if { [regexp {^#Metal Density} $line] } {
 set flag_md_read 1
 puts $FileSS "\t#Metal Density" 
 #puts $FileLMDD "\t#Metal Density" 
 continue
}
if {([regexp {^\s*$} $line]) && ($flag_md_read == 1)} {
 set flag_md_read 0
 continue
}
if { $flag_md_read == 1} {
 if {[regexp {^#layer} $line]} {
   
 puts $FileSS "\t\t$line"
 #puts $FileLMDD "\t\t$line" 
  continue
 }
 regsub -all {\t+} $line " " line
 regsub -all {\s+} $line " " line
 set line_arr [split $line " "]
 set layer [lindex $line_arr 0]
 set md_per_layer_session($layer,$session) [lindex $line 1]
  if { $session eq "p" } {
    if {$flag_get_layer_stackup == 1} {
      set layer_stackup [lindex $line_arr 0]
       
      set flag_get_layer_stackup 0
    } else {
      lappend layer_stackup [lindex $line_arr 0]
    }
  }
if {![info exists min_md($layer)]} {
  set min_md($layer) [lindex $line 1]
  set session_md_min($layer) $session
 } else {
  if { $min_md($layer) > [lindex $line 1] } {
	set min_md($layer) [lindex $line 1]
  	set session_md_min($layer) $session
  }
 }
 if {![info exists max_md($layer)]} {
  set max_md($layer) [lindex $line 1]
  set session_md($layer) $session
 } else {
  if { $max_md($layer) < [lindex $line 1] } {
	set max_md($layer) [lindex $line 1]
  	set session_md($layer) $session
  }
 }
 puts $FileSS "\t\t$line"
 continue 
}
if {[regexp {^#Avg_Metal_Density\s*(.*$)} $line matched avg_md($session)]} {
 puts $FileAMD "$session\t\t$avg_md($session)"
 continue
}
if {[regexp {#Power Summary Report:} $line ]} {
 set flag_power_read 1
  puts $FileSS "\n"
 # puts $FileSS "$line"
  continue
}
if {[regexp {#Power Summary Report per Block} $line]} {
 set flag_power_read 0
 set flag1_worst_res_inc_in_ss 1
  puts $FileSS "\n"
  continue
}
if { $flag_power_read == 1} {
 if {[regexp {^#Power Summary Report per Domain} $line]} {
  puts $FileSS "#Power Summary Report:"
  continue
 }
 if {[regexp {^#} $line]} {
  puts $FileSS "\t$line"
  continue
 }
 set net [lindex $line 0]
 set power_per_net_session($net,$session) [lindex $line 2]
 puts $FileSS "\t$line"
 continue 
}
if {($flag_worst_res_inc_in_ss == 1) && ($flag1_worst_res_inc_in_ss == 1) } {
### Need to parse Worst Resistance Values, Printing Memory values.
### End of Calculation
  if {[file exists "$rh_run_path/.worst_eff_res.rpt"]} {
   set FileWRES [open "$rh_run_path/.worst_eff_res.rpt" r]
    while {[gets $FileWRES data] >= 0} {
     if {[regexp {^#END\sWorst_Resistance} $data]} {
      puts $FileWCRES ""
      puts $FileWERES "$session\t[lindex $data 6]"
      puts -nonewline $FileWCRES "$session\t[lindex $data 5]"
      puts $FileSS "\n"
      continue
     } elseif {[regexp {^#Worst_Wire_Resistance} $data]} { 
      puts -nonewline $FileWCRES "\tWire: [lindex $data 1]"
     } elseif {[regexp {^#Worst_Via_Resistance} $data]} { 
      puts -nonewline $FileWCRES "\tVia: [lindex $data 1]"
     } elseif {[regexp {^#Worst_Switch_Resistance} $data]} { 
      puts -nonewline $FileWCRES "\tSwitch: [lindex $data 1]"
     } else {
      puts $FileSS $data
     }
    }
   close $FileWRES
  }
  set flag_worst_res_inc_in_ss 0
  set flag1_worst_res_inc_in_ss 0
  continue
}
#if {[regexp {#Worst Case Resistance} $line]} {
#  puts $FileSS "#Worst Case Resistance:   [lindex $line 3]"
#}
#if {[regexp {#Worst Case Eff_Resistance} $line]} {
#  puts $FileSS "#Worst Case Effective Resistance:   [lindex $line 3]"
#  puts $FileSS ""
#}
if {[regexp {#Static IR Report:} $line ]} {
  puts $FileSS "#Static IR/EM Report:"
  set flag_staticir_read 1
  continue
}
if {[regexp {#Static IR Drop per Layer:} $line]} {
  set end_staticir_flag 1
}
if {([regexp {^\s*$} $line]) && ($end_staticir_flag == 1)} {
  set flag_staticir_read 0
  set end_staticir_flag 0
  puts $FileSS "\n"
}
if {$flag_staticir_read == 1} {
  if {[regexp {#Static IR Summary:} $line]} {
   puts $FileSS "\t$line"
   continue
  }
  puts $FileSS "\t\t$line"
  continue
}
if {[regexp {#Static EM Summary:} $line]} {
  set flag_staticem_read 1
  puts $FileSS "$line"
  continue
}
if {[regexp {^\s*$} $line]} {
  set flag_staticem_read 0
}
if {$flag_staticem_read == 1} {
  puts $FileSS "\t\t$line"
  if {[regexp {Number of Metal EM Violations\s*(.*$)} $line matched Metal_EM_violations($session)]} {
	#puts $FileMEM "$session\t\t$Metal_EM_violations($session)"
   continue
  } 
  if {[regexp {Number of Via EM Violations\s*(.*$)} $line matched Via_EM_violations($session)]} {
	#puts $FileVEM "$session\t\t$Via_EM_violations($session)"
   continue
  } 
  if {[regexp {Worst Metal EM Violation %\s*(.*$)} $line matched Worst_Metal_EM($session)]} {
	#puts $FileWMEM "$session\t\t$Worst_Metal_EM($session)"
   continue
  } 
  if {[regexp {Worst Via EM Violation %\s*(.*$)} $line matched Worst_Via_EM($session)]} {
	#puts $FileWVEM "$session\t\t$Worst_Via_EM($session)"
   continue
  } 
}
}
 #puts $FileLMDD "#End Session" 
puts $FileMEM "$session\t\t$Worst_Metal_EM($session)\t\t$Metal_EM_violations($session)"
puts $FileVEM "$session\t\t$Worst_Via_EM($session)\t\t$Via_EM_violations($session)"
close $FileRHS
close $FileSS
if {$flag_log == 1} {
puts $FileLOG "END getting data from Session: ${session}\n"
flush $FileLOG
}
}
set layers_stackup_file ""
if {[file exists "$layers_stackup_file"]} {
 set lsf_IN [open "$layers_stackup_file" "r"]
 set flag_ls_file 1
 while {[gets $lsf_IN ls_line] >= 0 } {
  if {$flag_ls_file == 1} {
   set layer_stackup_file $ls_line
  } else {
   lappend layer_stackup_file $ls_line
  }
 }
close $lsf_IN ;
 foreach for_md $layer_stackup_file {
 puts $FileLMDD "\t#Layer: $for_md"
 if([info exists max_md($for_md)]) {
 puts $FileLMD "$for_md\t$max_md($for_md)\t\t$session_md($for_md)"
 flush $FileLMD
 } else {
 puts $FileLMD "$for_md\tNA\t\tNA"
 flush $FileLMD
 }
  foreach for_session $all_sessions {
   if {[info exists md_per_layer_session($for_md,$for_session)]} {
    puts $FileLMDD "\t\t$for_session\t$md_per_layer_session($for_md,$for_session)"
   } else {
    puts $FileLMDD "\t\t$for_session\tNA"
   }
  }
  puts $FileLMDD ""
 }
} else {
#puts "Layers: $layer_stackup"
#puts "Sessions: $all_sessions"
 foreach for_md $layer_stackup {
 puts $FileLMDD "\t#Layer: $for_md"
 if {[info exists max_md($for_md)]} {
 puts $FileLMD "$for_md\t$max_md($for_md)\t\t$session_md($for_md)"
 flush $FileLMD
 } else {
 puts $FileLMD "$for_md\tNA\t\tNA"
 flush $FileLMD
 }
  foreach for_session $all_sessions {
   if {[info exists md_per_layer_session($for_md,$for_session)]} {
    puts $FileLMDD "\t\t$for_session\t$md_per_layer_session($for_md,$for_session)" 
   } else {
    puts $FileLMDD "\t\t$for_session\tNA"
   }
  }
  puts $FileLMDD ""
 }
}
#foreach key [array names max_md] { 
#puts $FileLMD "$key\t$max_md($key)\t\t$session_md($key)"
#flush $FileLMD
#}

close $FileLMD
close $FileAMD
close $FileMEM
close $FileVEM
#close $FileWMEM
#close $FileWVEM
close $FileWERES
close $FileWCRES
close $FileLOG
close $FileLMDD
}
##END OF METAL DENSITY DATA CREATION PROC ##

#######################################################
## POWER SUMMARY DATA CREATION PROC
## Owner   : Rishikanth
## Contact : rishikanth.mekala@ansys.com
## Date    : 1/12/2015
########################################################
proc get_sessions_power_summary  {args} {

#Reading Arguments
if {[regexp "gps_dir" [lindex $args 0]]} {
set gps_dir  [lindex $args 1]
} else {
error "Wrong argument. Correct usage is get_sessions_power_summary -gps_dir <gps_dir> -sessions_count <> -out_dir <>"
exit;
}

if {[regexp "sessions_count" [lindex $args 2]]} {
set sessions_count [lindex $args 3]
} else {
error "Wrong argument. Correct usage is get_sessions_power_summary -gps_dir <gps_dir> -sessions_count <> -out_dir <>"
exit;
}

if {[regexp "design_name" [lindex $args 4]]} {
set d_name [lindex $args 5]
} else {
error "Wrong argument. Correct usage is get_sessions_power_summary -gps_dir <gps_dir> -sessions_count <> -out_dir <>"
exit;
}

if {[regexp "out_dir" [lindex $args 6]]} {
set out_dir [lindex $args 7]

} else {
error "Wrong argument. Correct usage is get_sessions_power_summary -gps_dir <gps_dir> -sessions_count <> -out_dir <>"
exit;
}

#End of Reading Arguments

#Output file 
set fp_out [open "$out_dir/sessions_power_summary.rpt" w];
puts $fp_out "#Session Power(mW)";
for {set i 0} {$i <= $sessions_count} {incr i} {

if {$i == 0} {
set session_name "p";
} else {
set session_name "c$i";
}

set Power_line [exec grep "#Total Power(mW):" $gps_dir/adsRpt/work/$d_name/$session_name/DropAndEM/Static/rh_results_summary.out]
regsub -all {\s+} $Power_line { } Power_line
puts $fp_out "$session_name [lindex $Power_line 2]";
}

close $fp_out;

}


## END OF POWER SUMMARY DATA CREATION PROC ##

#######################################################
## STATIC IR DATA CREATION PROC
## Owner   : Rishikanth
## Contact : rishikanth.mekala@ansys.com
## Date    : 1/12/2015
########################################################
proc get_sessions_ir_summary  {args} {

#Reading Arguments
if {[regexp "gps_dir" [lindex $args 0]]} {
set gps_dir  [lindex $args 1]
} else {
error "Wrong argument. Correct usage is get_sessions_ir_summary -gps_dir <gps_dir> -sessions_count <> -out_dir <>"
exit;
}

if {[regexp "sessions_count" [lindex $args 2]]} {
set sessions_count [lindex $args 3]
} else {
error "Wrong argument. Correct usage is get_sessions_ir_summary -gps_dir <gps_dir> -sessions_count <> -out_dir <>"
exit;
}

if {[regexp "design_name" [lindex $args 4]]} {
set d_name [lindex $args 5]
} else {
error "Wrong argument. Correct usage is get_sessions_ir_summary -gps_dir <gps_dir> -sessions_count <> -out_dir <>"
exit;
}

if {[regexp "out_dir" [lindex $args 6]]} {
set out_dir [lindex $args 7]

} else {
error "Wrong argument. Correct usage is get_sessions_ir_summary -gps_dir <gps_dir> -sessions_count <> -out_dir <>"
exit;
}

#End of Reading Arguments


#Output file 
set fp_summary1 [open "$out_dir/sessions_ir_summary_power.rpt" w];
set fp_summary2 [open "$out_dir/sessions_ir_summary_ground.rpt" w];
set fp_net_specific [open "$out_dir/net_specific_ir_summary.rpt" w];
set fp_layer_specific [open "$out_dir/layer_specific_ir_summary.rpt" w];
set fp_domain_summary [open "$out_dir/domain_worst_drop_summary.rpt" w];
set fp_layer_summary [open "$out_dir/layer_worst_drop_summary.rpt" w];

#set domain_list "";
#puts $fp_out "#Session Worst Drop(mW)";
for {set i 0} {$i <= $sessions_count} {incr i} {

set flag_ir_summary 0;
set flag_ir_domain 0;
set flag_ir_layer 0;
set count_ir_summary 0;
set count_ir_domain 0;
set count_ir_layer 0;
set flag_em 0;

if {$i == 0} {
set session_name "p";
} else {
set session_name "c$i";
}

#Reading Results summary file
set fp_read [open "$gps_dir/adsRpt/work/$d_name/$session_name/DropAndEM/Static/rh_results_summary.out" r];

while { [gets $fp_read line] >= 0 } {

#IR summary processing
if { [regexp "#Static IR Summary:" $line] && $flag_ir_summary == 0 } {
set flag_ir_summary 1
}

if { $flag_ir_summary == 1 } {
set count_ir_summary [incr count_ir_summary];
regsub -all {\s+} $line { } line_power_summary
set domain_name [split [lindex $line_power_summary 1] "("];
if { $count_ir_summary == 3} {
 puts $fp_summary1 "$session_name [lindex $domain_name 1] [lindex $line_power_summary 3]"
} elseif {$count_ir_summary == 4} {
 puts $fp_summary2 "$session_name [lindex $domain_name 1] [lindex $line_power_summary 3]";
set count_ir_summary 0;
set flag_ir_summary 0;
}
}

#Net Specific Processing
if { [regexp "#Static IR Drop per Domain:" $line] && $flag_ir_domain == 0 } {
set flag_ir_domain 1
}

if { $flag_ir_domain == 1 } {
set count_ir_domain [incr count_ir_domain];
regsub -all {\s+} $line { } line_ir_domain
set domain_name_value [split $line_ir_domain " "];
set domain [lindex $domain_name_value 0];
set ir_drop [lindex $domain_name_value 1];

if { $count_ir_domain >=3 && $line ne "" && ![regexp "#Static IR Drop per Layer:" $line]} {
set net_ir($domain,$session_name) $ir_drop;
lappend domain_list($session_name) $domain;
} 
}

#Layer Specific  Processing
if { [regexp "#Static IR Drop per Layer:" $line] && $flag_ir_layer == 0} {
set flag_ir_layer 1
set flag_ir_domain 0
}

if { $flag_ir_layer == 1 } {
set count_ir_layer [incr count_ir_layer];
regsub -all {\s+} $line { } line_ir_layer
set layer_name_value [split $line_ir_layer " "];
set layer [lindex $layer_name_value 0];
set ir_drop [lindex $layer_name_value 1];

if { $count_ir_layer >=3 && $line ne "" && ![regexp "#Static EM Summary:" $line]} {
set layer_ir($layer,$session_name) $ir_drop;

lappend layer_list($session_name) $layer;

} 
}

if {[regexp "#Static EM Summary:" $line] && $flag_em == 0} {
set flag_em 1;
set flag_ir_layer 0;
}
}

close $fp_read;
}
close $fp_summary1;
close $fp_summary2;


set domain_count [llength $domain_list(p)];

puts $fp_domain_summary "#Domain Worst-Drop Session";

for {set net 0} {$net < $domain_count} {incr net} {

 set worst_domain_drop "NA";
 set worst_session p;
 set pg_domain [lindex $domain_list($session_name) $net];
 puts $fp_net_specific "#Net: $pg_domain";
 for {set j 0 } {$j <= $sessions_count} {incr j} {

 if {$j == 0} {
 set session_name "p";
 } else {
 set session_name "c$j";
 }
 
if {[info exists net_ir($pg_domain,$session_name)]} {
  if {$net_ir($pg_domain,$session_name) <= $worst_domain_drop } {
  set worst_domain_drop $net_ir($pg_domain,$session_name);
  set worst_session $session_name
} else {
 set worst_domain_drop $worst_domain_drop;
 set worst_session $worst_session;
}
  
 puts $fp_net_specific "$session_name $net_ir($pg_domain,$session_name)";
}
}
puts $fp_domain_summary "$pg_domain $worst_domain_drop $worst_session";
}



set layer_count [llength $layer_list(p)];

puts $fp_layer_summary "#Layer Worst-Drop Session";
for {set layer 0} {$layer < $layer_count} {incr layer} {
 set worst_layer_drop "NA";
 set worst_session p;
 set Layer [lindex $layer_list($session_name) $layer];
 puts $fp_layer_specific "#Layer: $Layer";
 for {set k 0 } {$k <= $sessions_count} {incr k} {

 if {$k == 0} {
 set session_name "p";
 } else {
 set session_name "c$k";
 }
if { [info exists layer_ir($Layer,$session_name)]} {
if { $layer_ir($Layer,$session_name) <= $worst_layer_drop } {
  set worst_layer_drop $layer_ir($Layer,$session_name);
  set worst_session $session_name
} else {
 set worst_layer_drop $worst_layer_drop;
 set worst_session $worst_session;
}
 puts $fp_layer_specific "$session_name $layer_ir($Layer,$session_name)";
}
}

puts $fp_layer_summary "$Layer $worst_layer_drop $worst_session";
}

close $fp_net_specific;
close $fp_layer_specific;
close $fp_domain_summary;
close $fp_layer_summary;
}

##END OF STATIC IR DATA CREATION PROC##

#######################################################
## DESIGN SUMMARY DATA CREATION PROC
## Owner   : Rishikanth
## Contact : rishikanth.mekala@ansys.com
## Date    : 1/12/2015
########################################################
proc get_design_summary  {args} {

#Reading Arguments
if {[regexp "gps_dir" [lindex $args 0]]} {
set gps_dir  [lindex $args 1]
} else {
error "Wrong argument. Correct usage is get_sessions_power_summary -gps_dir <gps_dir> -sessions_count <> -out_dir <>"
exit;
}

if {[regexp "sessions_count" [lindex $args 2]]} {
set sessions_count [lindex $args 3]
} else {
error "Wrong argument. Correct usage is get_sessions_power_summary -gps_dir <gps_dir> -sessions_count <> -out_dir <>"
exit;
}

if {[regexp "design_name" [lindex $args 4]]} {
set design_name [lindex $args 5]

} else {
error "Wrong argument. Correct usage is get_sessions_power_summary -gps_dir <gps_dir> -sessions_count <> -out_dir <>"
exit;
}
if {[regexp "out_dir" [lindex $args 6]]} {
set out_dir [lindex $args 7]

} else {
error "Wrong argument. Correct usage is get_sessions_power_summary -gps_dir <gps_dir> -sessions_count <> -out_dir <>"
exit;
}



set fp_design_summary [open "$out_dir/gps_design_summary.rpt" w];
set fp_net_voltage [open "$out_dir/gps_net_voltage.rpt" w];
set fp_layer_stackup [open "$out_dir/gps_layer_stackup.rpt" w];
#Open Parent Cell
#db open cell /work/$design_name

set layer_count [llength [db query /tech layers]];

foreach layer [db query /tech layers] {
puts $fp_layer_stackup $layer;
}

close $fp_layer_stackup

gui dump jpeg $out_dir/design_snapshot.jpeg 

set design_coordinates_raw [db query /work/$design_name bbox]
set design_coordinates [split $design_coordinates_raw " "];

set x1 [lindex $design_coordinates 0];
set x2 [lindex $design_coordinates 2];
set y1 [lindex $design_coordinates 1];
set y2 [lindex $design_coordinates 3];

regsub -all "\{" $x1 "" x1;
regsub -all "\}" $x1 "" x1;
regsub -all "\{" $x2 "" x2;
regsub -all "\}" $x2 "" x2;
regsub -all "\{" $y1 "" y1;
regsub -all "\}" $y1 "" y1;
regsub -all "\{" $y2 "" y2;
regsub -all "\}" $y2 "" y2;


set width [expr $x2-$x1];
set height [expr $y2-$y1];

set power_nets_count [ llength [db query /work/$design_name nets -type power]];
set ground_nets_count [ llength [db query /work/$design_name nets -type ground]];

set mem [gps_query_memory]

set fp_open_cmd [open "$gps_dir/adsRpt/gps.cmd" r];

set count 0;
while { [gets $fp_open_cmd line] >= 0} {

if {[regexp "#timestamp" $line] && $count == 0} {
set start_time_line $line;
set count [incr count];
} elseif {[regexp "#timestamp" $line]} {
set end_time_line $line;
}

}
regsub -all {\s+} $start_time_line " " start_time_line
regsub -all {\s+} $end_time_line " " end_time_line


set split_start_time [split $start_time_line " "];
set split_end_time [split $end_time_line " "];
set start_month [lindex $split_start_time 2];
set end_month [lindex $split_end_time 2];

set start_date [lindex $split_start_time 3];
set end_date [lindex $split_end_time 3];

set start_year [lindex $split_start_time 5];
set end_year [lindex $split_end_time 5];
regsub -all "\]" $start_year "" start_year
regsub -all "\]" $end_year "" end_year

set start_time [lindex $split_start_time 4];
set end_time [lindex $split_end_time 4];

set start_time_split [split $start_time ":"];
set end_time_split [split $end_time ":"];

set s_hr [lindex $start_time_split 0];
set e_hr [lindex $end_time_split 0];

set s_min [lindex $start_time_split 1];
set e_min [lindex $end_time_split 1];


set s_sec [lindex $start_time_split 2];
set e_sec [lindex $end_time_split 2];

array set month [list Jan 1 Feb 2 Mar 3 Apr 4 May 5 Jun 6 Jul 7 Aug 8 Sep 9 Oct 10 Nov 11 Dec 12]

#puts "$start_year-$month($start_month)-$start_date $s_hr:$s_min:$s_sec"
set t1 [clock scan "$start_year-$month($start_month)-$start_date $s_hr:$s_min:$s_sec" \
           -format "%Y-%m-%d %H:%M:%S" ]
set t2 [clock scan "$end_year-$month($end_month)-$end_date $e_hr:$e_min:$e_sec" \
           -format "%Y-%m-%d %H:%M:%S" ]


set number_of_hours [expr ($t2-$t1)/3600.0];

set min_fraction [expr $number_of_hours -int($number_of_hours)];
set min [expr $min_fraction*60];
if {$number_of_hours < 1 } {
set number_of_hours 0
puts $fp_design_summary "Design_Name: $design_name\nDesign_Size: $width\u x $height\u \nNumber_of_voltage_domains: $power_nets_count\(power\) and $ground_nets_count\(ground\) \nNumber_of_layers: $layer_count\nNumber_of_sessions: $sessions_count\nTotal_run_time: [format "%.2f" $min] minutes \n$mem\nRun_area: $gps_dir\nGUI_snapshot: $out_dir\/design_snapshot.jpeg";
} elseif {$number_of_hours >= 1} {

puts $fp_design_summary "Design_Name: $design_name\nDesign_Size: $width\u x $height\u \nNumber_of_voltage_domains: $power_nets_count\(power\) and $ground_nets_count\(ground\) \nNumber_of_layers: $layer_count\nNumber_of_sessions: $sessions_count\nTotal_run_time: [format "%.2f" $number_of_hours] hours [format "%.2f" $min] minutes \n$mem\nRun_area: $gps_dir\nGUI_snapshot: $out_dir\/design_snapshot.jpeg";
}

close $fp_design_summary;

#Dumping PG Domain and Voltage Info
puts $fp_net_voltage "#PG_DOMAINS VOLTAGE"

db foreach net "query /work/$design_name nets" {
if {[catch {set voltage [db query $net voltage]}] ==  0 } {
    regsub "/work/$design_name\/net\:" $net {} net
   puts $fp_net_voltage "$net $voltage";
} else {
#puts $errorInfo
}
}

close $fp_net_voltage;

}

## END OF DESIGN SUMMARY DATA COLLECTION SCRIPT ##


#####Res calc and Min Res path script by Sidda####
proc get_data_gc_rc_mrp {} {
set take_from_log 1
if { $take_from_log == 1 } {
set redhawk_log "adsRpt/redhawk.log"
 if {[file exists $redhawk_log]} {
  set redlog [open "$redhawk_log" "r"]
  while {[gets $redlog log_file] >= 0 } {
   if { [regexp {^\s*NET\<(.*)\>\s*:} $log_file matched net_name] } {
     if {[info exists all_nets]} {
      lappend all_nets $net_name
     } else {
      set all_nets $net_name
     }
   }
  }
 } else {
  puts "ERROR: Res calc cannot be performed as \'redhawk.log\' file does not exists"
  return
 }
} else {
 set power_nets [get net * -glob -type power -gsr_only]
 set ground_nets [get net * -glob -type ground -gsr_only]
 set all_nets [concat $power_nets $ground_nets]
}
 set FileW [open ".worst_eff_res.rpt" "w"]
 puts $FileW "#Worst Resistance Report:"
 puts $FileW "\t#Worst Case Resistance:"
 puts $FileW "\t#Domain\tMin_Path_Resistance"
 flush $FileW
 set max_res_grid 0
 foreach net $all_nets {
  
###########Added By Rishi###############
regsub -all "/" $net "_" net_hier 
########################################

  perform gridcheck -fullchip -net $net -limit 10 -o .net_${net_hier}_grid.rpt
  set FileG [open ".net_${net_hier}_grid.rpt" r]
  set flag_gd_net 0
   while {[gets $FileG line] >= 0} {
    if {[regexp {^# Max resistance.* R_MAX: (.*$)} $line matched grid_rmax($net)]} {
     #puts $FileW "\t$net\t$grid_rmax($net)"
     #flush $FileW
    if { $max_res_grid < $grid_rmax($net) } {
     set max_res_grid $grid_rmax($net)
     set max_res_net $net
    }
     continue
    }
    if {$flag_gd_net == 1} {
     set x [lindex $line 1]
     set y [lindex $line 2]
     set layer [lindex $line 3]
     break
    }
    if {[regexp {^# Resistance\(%\)} $line]} {
     set flag_gd_net 1
    }
   }
  close $FileG
  #dump gif -o minres_path.png

###########Added By Rishi###############
regsub -all "/" $net "_" net_hier 
########################################

 if { [ catch { perform min_res_path -to "$x $y $layer $net" -o .net_${net_hier}_respath.rpt } ] == 0 } {
set FileR [open ".net_${net_hier}_respath.rpt" r]
 set flag_res_path 0
  while { [gets $FileR data] >= 0 } {
   if {[regexp {^\#} $data]} {
    #gets $FileR data
    set flag_res_path 1
    continue
   }
   if {$flag_res_path == 1} { 
   # set data_split [split $data]
    if { [regexp {Wire:} $data ] } {
     if {![info exists res_wire_path_rmax($net)]} {
      set res_wire_path_rmax($net) [lindex $data 4]
     } else {
      set res_wire_path_rmax($net) [ expr { $res_wire_path_rmax($net) + [lindex $data 4] } ]
     }
    } elseif { [regexp {Via:} $data ] } {
     if {![info exists res_via_path_rmax($net)]} {
      set res_via_path_rmax($net) [lindex $data 4]
     } else {
      set res_via_path_rmax($net) [ expr { $res_via_path_rmax($net) + [lindex $data 4] } ]
     }
    } elseif { [regexp {Switch:} $data ] } {
     if {![info exists res_switch_path_rmax($net)]} {
      set res_switch_path_rmax($net) [lindex $data 4]
     } else {
      set res_switch_path_rmax($net) [ expr { $res_switch_path_rmax($net) + [lindex $data 4] } ]
     }
    }

    }
   
  }
  close $FileR
}
  if { [catch  { perform res_calc -to "$x $y $layer $net" -o .net_${net_hier}_rescalc.rpt } ] == 0 } {
 set FileR [open ".net_${net_hier}_rescalc.rpt" r]
 set flag_res_calc 0
  while { [gets $FileR data] >= 0 } {
   if {[regexp {^\#} $data]} {
    #gets $FileR data
    set flag_res_calc 1
    continue
   }
   if {$flag_res_calc == 1} { 
    set res_calc_rmax($net) [lindex $data 0]
    break
    }
   
  }
  close $FileR
}
 

 }

 foreach net $all_nets {
if {[info exists res_wire_path_rmax($net)]} {
 set res_wire_path_rmax($net) [format "%0.3f" $res_wire_path_rmax($net)]
 } else {
 set res_wire_path_rmax($net) 0
 }
 if {[info exists res_via_path_rmax($net)]} {
 set res_via_path_rmax($net) [format "%0.3f" $res_via_path_rmax($net)]
 } else {
 set res_via_path_rmax($net) 0
 }
 if {[info exists res_switch_path_rmax($net)]} {
 set res_switch_path_rmax($net) [format "%0.3f" $res_switch_path_rmax($net)]
 } else {
 set res_switch_path_rmax($net) 0
 }
  puts $FileW "\t$net\t$grid_rmax($net)\tWire:$res_wire_path_rmax($net)\tVia:$res_via_path_rmax($net)\tSwitch:$res_switch_path_rmax($net)"
  flush $FileW
 }
 puts $FileW ""
 puts $FileW "\t#Worst Case Effective Resistance:"
 puts $FileW "\t#Domain\tEffective_Resistance"
 flush $FileW
#set total_via_res 0
#set total_wire_res 0
#set total_switch_res 0

 foreach net $all_nets {
  #if {[info exists res_wire_path_rmax($net)]} {
  #set total_wire_res [expr $total_wire_res + $res_wire_path_rmax($net)]
  #}
  #if {[info exists res_via_path_rmax($net)]} {
  #set total_via_res [expr $total_via_res + $res_via_path_rmax($net)]
  #}
  #if {[info exists res_via_path_rmax($net)]} {
  #set total_switch_res [expr $total_switch_res + $res_switch_path_rmax($net)]
  #}
  puts $FileW "\t$net\t$res_calc_rmax($net)"
  flush $FileW
 }
 puts $FileW "#END Worst_Resistance and Effective Resistance $max_res_grid $res_calc_rmax($max_res_net)"
 if {[info exists res_wire_path_rmax($max_res_net)]} {
 set res_wire_path_rmax($max_res_net) [format "%0.3f" $res_wire_path_rmax($max_res_net)]
 puts $FileW "#Worst_Wire_Resistance: $res_wire_path_rmax($max_res_net)"
 } else {
 puts $FileW "#Worst_Wire_Resistance: 0"
 }
 if {[info exists res_via_path_rmax($max_res_net)]} {
 set res_via_path_rmax($max_res_net) [format "%0.3f" $res_via_path_rmax($max_res_net)]
 puts $FileW "#Worst_Via_Resistance: $res_via_path_rmax($max_res_net)"
 } else {
 puts $FileW "#Worst_Via_Resistance: 0"
 }
 if {[info exists res_switch_path_rmax($max_res_net)]} {
 set res_switch_path_rmax($max_res_net) [format "%0.3f" $res_switch_path_rmax($max_res_net)]
 puts $FileW "#Worst_Switch_Resistance: $res_switch_path_rmax($max_res_net)"
 } else {
 puts $FileW "#Worst_Switch_Resistance: 0"
 }
close $FileW
}
###End of Res calc and Min Res path script

##MAIN HTML PAGE PROC
proc setup_main_html  {args} {

#Reading Arguments
if {[regexp "html_template" [lindex $args 0]]} {
set html_template  [lindex $args 1]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}
if {[regexp "results_dir" [lindex $args 2]]} {
set results_dir  [lindex $args 3]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}


if {[regexp "out_dir" [lindex $args 4]]} {
set out_dir [lindex $args 5]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}

#Reading Design Parameters
set fp_open [open "$results_dir/gps_design_summary.rpt" r];

set d_name "-";set d_size "-"; set n_vol_domains "-";set n_layers "-"; set n_sessions "-"; set t_run_time "-" ;set mem "-" ;set run_area "-";
set line_split "";

if {[info exists fp_open] } {
while { [gets $fp_open line] >= 0} {
if { $line ne "" } {
set line_split [split $line ":"];
if {[info exists line_split] } {
if { [regexp "Design_Name" $line] } {
set d_name [lindex $line_split 1];
} elseif {[regexp "Design_Size" $line] } {
set d_size [lindex $line_split 1];
} elseif {[regexp "Number_of_voltage_domains" $line] } {
set n_vol_domains [lindex $line_split 1];
} elseif {[regexp "Number_of_layers" $line] } {
set n_layers [lindex $line_split 1];
} elseif {[regexp "Number_of_sessions" $line] } {
set n_sessions [lindex $line_split 1];
} elseif {[regexp "Total_run_time" $line]} {
set t_run_time [lindex $line_split 1];
} elseif {[regexp "MEMORY USAGE" $line]} {
set mem [lindex $line_split 1];
} elseif {[regexp "Run_area" $line]} {
set run_area [lindex $line_split 1];
} elseif {[regexp "GUI_snapshot" $line]} {
set snapshot [lindex $line_split 1];
} else {
set d_name "-";set d_size "-"; set n_vol_domains "-";set n_layers "-"; set n_sessions "-"; set t_run_time "-" ;set mem "-" ;set run_area "-";
}


}
}
}
}

close $fp_open;
#Setting up main HTML Page
set fp_open_html [open "$html_template" r];
set fp_open_write_main_html [open "$out_dir/main.html" w];

while {[gets $fp_open_html line] >=0 } {
if {[regexp "DESIGNNAME" $line]} {
puts $fp_open_write_main_html "<td style=\"width:600px\">$d_name</td>"
} elseif {[regexp "DESIGNSIZE" $line] } {
puts $fp_open_write_main_html "<td style=\"width:600px\">$d_size</td>"
set d_size [lindex $line_split 1];
} elseif {[regexp "NUMBER_VOLTAGE_DOMAINS" $line] } {
puts $fp_open_write_main_html "<td style=\"width:600px\"><a href=\"/rhe/file?fname=adsRHE/gps_net_voltage.html\">$n_vol_domains</a></td>"
} elseif {[regexp "NUMBER_LAYERS" $line] } {
puts $fp_open_write_main_html "<td style=\"width:600px\">$n_layers</td>"
} elseif {[regexp "NUMBER_SESSIONS" $line] } {
set n_sessions [expr $n_sessions+1];
puts $fp_open_write_main_html "<td style=\"width:600px\"><a href=\"/rhe/file?fname=adsRHE/session_summary.html\">$n_sessions</a></td>"
} elseif {[regexp "RUN_TIME" $line]} {
puts $fp_open_write_main_html "<td style=\"width:600px\">$t_run_time</td>"
} elseif {[regexp "MEMORY" $line]} {
puts $fp_open_write_main_html "<td style=\"width:600px\">$mem</td>"
} elseif {[regexp "RUN_AREA" $line]} {
puts $fp_open_write_main_html "<td style=\"width:600px\">$run_area</td>"
} elseif {[regexp "GUI_SNAPSHOT" $line]} {
puts $fp_open_write_main_html "<td style=\"width:600px\">$snapshot</td>"
} else {
puts $fp_open_write_main_html $line
}
}

close $fp_open_write_main_html;
close $fp_open_html;

}
##END OF MAIN HTML PAGE PROC

##METAL DENSTIY HTML PAGE PROC
proc setup_metal_density_html  {args} {

#Reading Arguments
if {[regexp "html_template" [lindex $args 0]]} {
set html_template  [lindex $args 1]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}
if {[regexp "results_dir" [lindex $args 2]]} {
set results_dir  [lindex $args 3]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}


if {[regexp "out_dir" [lindex $args 4]]} {
set out_dir [lindex $args 5]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}

#Reading Design Parameters
set fp_open [open "$results_dir/Avg_Metal_Density_per_session.rpt" r];
set metal_density_summary_count 0;
set bar_graph_summary_x "";
set bar_graph_summary_y "";

while { [gets $fp_open line] >= 0 } {
if { $line ne "" && ![regexp "#" $line]  } {
set metal_density_summary_count [incr metal_density_summary_count];
regsub -all {\s+} $line " " line
set line_split [split $line " "];
set session_name [lindex $line_split 0]
set session_avg_metal_density [lindex $line_split 1];

lappend bar_graph_summary_x "\'$session_name\' \,"
lappend bar_graph_summary_y "$session_avg_metal_density\, "

set density_session_name($metal_density_summary_count) $session_name;
set density_session_avg($metal_density_summary_count) $session_avg_metal_density;
}
}


close $fp_open;


#Reading Layer Specific IR Drop
set fp_open_layer_density [open "$results_dir/Metal_Density_per_layer.rpt" r];
set count_layer_density_line 0
set bar_graph_layer_x "";
set bar_graph_layer_y "";

while {[gets $fp_open_layer_density line] >= 0} {

if { $line ne "" && ![regexp "#" $line] } {
regsub -all {\s+} $line " " line
set fp_line_split [split $line " "];
set count_layer_density_line [incr count_layer_density_line];
set layer_name($count_layer_density_line) [lindex $fp_line_split 0];
set layer_density($count_layer_density_line) [lindex $fp_line_split 1];
set layer_session($count_layer_density_line) [lindex $fp_line_split 2];
lappend bar_graph_layer_x "\'$layer_name($count_layer_density_line)\' \,"
lappend bar_graph_layer_y "$layer_density($count_layer_density_line)\, "

}
}
close $fp_open_layer_density


#Setting up main HTML Page
set fp_open_html [open "$html_template" r];
set fp_open_write_metal_density_html [open "$out_dir/metal_density.html" w];
regsub -all "\{" $bar_graph_summary_x "" bar_graph_summary_x;
regsub -all "\}" $bar_graph_summary_x "" bar_graph_summary_x;
regsub -all "\{" $bar_graph_summary_y "" bar_graph_summary_y;
regsub -all "\}" $bar_graph_summary_y "" bar_graph_summary_y;

regsub -all "\{" $bar_graph_layer_x "" bar_graph_layer_x;
regsub -all "\}" $bar_graph_layer_x "" bar_graph_layer_x;
regsub -all "\{" $bar_graph_layer_y "" bar_graph_layer_y;
regsub -all "\}" $bar_graph_layer_y "" bar_graph_layer_y;

set pixel_unit "px"

while {[gets $fp_open_html line] >=0 } {

if { [regexp "DENSITY_SUMMARY_HERE" $line]} {

for {set i 1 } {$i <= $metal_density_summary_count} {incr i} {
puts $fp_open_write_metal_density_html "\n"
puts $fp_open_write_metal_density_html "<tr>"
set file1 "_summary.html";
set file "$density_session_name($i)$file1"
puts $fp_open_write_metal_density_html "<td><a href=\"/rhe/file?fname=adsRHE/session_$file\"><center>$density_session_name($i)</a></center></td>"
puts $fp_open_write_metal_density_html "<td><center>$density_session_avg($i)</center></td>"
puts $fp_open_write_metal_density_html "</tr>"
puts  $fp_open_write_metal_density_html "\n"
}

} elseif { [regexp "LAYER_SPECIFIC_SUMMARY_HERE" $line]} {

for {set k 1 } {$k <= $count_layer_density_line} {incr k} {
set file1 "_summary.html";
set file "$layer_session($k)$file1"

puts $fp_open_write_metal_density_html "\n"
puts $fp_open_write_metal_density_html "<tr>"
puts $fp_open_write_metal_density_html "<td><a href=\"/rhe/file?fname=adsRHE/$layer_name($k)_metal_density.html\"><center>$layer_name($k)</a></center></td>"
puts $fp_open_write_metal_density_html "<td><center>$layer_density($k)</center></td>"
puts $fp_open_write_metal_density_html "<td><a href=\"/rhe/file?fname=adsRHE/session_$file\"><center>$layer_session($k)</a></center></td>"
puts $fp_open_write_metal_density_html "</tr>"
puts  $fp_open_write_metal_density_html "\n"
}

} elseif { [regexp "SESSIONS" $line] } {
puts $fp_open_write_metal_density_html "categories: \[$bar_graph_summary_x]\,"
} elseif {[regexp "AVG_MD" $line]} {
puts $fp_open_write_metal_density_html "data: \[$bar_graph_summary_y]"
} elseif { [regexp "LAYERS" $line] } {
puts $fp_open_write_metal_density_html "categories: \[$bar_graph_layer_x]\,"
} elseif {[regexp "WORST_MD" $line]} {
puts $fp_open_write_metal_density_html "data: \[$bar_graph_layer_y]"
} elseif {[regexp "HEIGHT_SUMMARY" $line]} {
set h [expr 30*$metal_density_summary_count];
regsub "HEIGHT_SUMMARY" $line "$h$pixel_unit" line_new
puts $fp_open_write_metal_density_html $line_new;
} elseif {[regexp "HEIGHT_LAYER" $line]} {
set h [expr 60*$count_layer_density_line];
regsub "HEIGHT_LAYER" $line "$h$pixel_unit" line_new
puts $fp_open_write_metal_density_html $line_new;
} elseif {[regexp "HEIGHT_TABLE_LAYER" $line]} {
set h [expr 25*$count_layer_density_line];
regsub "HEIGHT_TABLE_LAYER" $line "$h" line_new
puts $fp_open_write_metal_density_html $line_new;
}  else {
puts  $fp_open_write_metal_density_html $line
}

}

close $fp_open_html
close $fp_open_write_metal_density_html
}

##END OF METAL DENSITY HTML PROC

##LAYER SPECIFIC METAL DENSITY PAGE PROC

proc setup_layer_md_html  {args} {

#Reading Arguments
if {[regexp "html_template" [lindex $args 0]]} {
set html_template  [lindex $args 1]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}
if {[regexp "results_dir" [lindex $args 2]]} {
set results_dir  [lindex $args 3]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}


if {[regexp "out_dir" [lindex $args 4]]} {
set out_dir [lindex $args 5]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}

#Reading Design Parameters
set fp_open [open "$results_dir/Metal_Density_per_layer_detail_summary.rpt" r];
set power_summary_count 0;
set net_count 0;
while { [gets $fp_open line] >= 0 } {

if {![regexp "Layer wise all sessions's Metal density Report" $line]} {
regsub -all {\s+} $line " " line
if { [regexp "#Layer:" $line] } {
set line_net_split [split $line " "];

set net_split [lindex $line_net_split 2];
set net_count [incr net_count];
set net($net_count) [lindex $line_net_split 2];
set bar_graph_x($net_split) "";
set bar_graph_y($net_split) "";

}


if { $line ne "" && ![regexp "#" $line] } {

set power_summary_count [expr $power_summary_count+1];

if { $net_count == 1 } {
set No_of_sessions $power_summary_count
}

set line_split_p [split $line " "];
set net_session [lindex $line_split_p 1]
set net_drop [lindex $line_split_p 2];

set session_name($power_summary_count) $net_session;
set session_drop($power_summary_count) $net_drop;
lappend bar_graph_x($net_split) "\'$net_session\' \,"
lappend bar_graph_y($net_split) "$net_drop\, "
}
}
}

close $fp_open;


#Setting up main HTML Page
#set fp_domain_list [open "$out_dir/design_domain_list" w];
set pixel_unit "px"
set fp_rhe_copy [open "$out_dir/layer_specific_sessions_md_rhe_copy.rpt" w]
for {set i_net 1} {$i_net <= $net_count} {incr i_net} {
set net_name $net($i_net);
set fp_open_html [open "$html_template" r];
set op_name1 "_metal_density";
set op_name "$net_name$op_name1.html";
set fp_open_write_drop_html [open "$out_dir/$op_name" w];
puts $fp_rhe_copy "rhe_nx::rhe_copy_tcl \"$out_dir/$op_name\" \"adsRHE/$op_name\"" 
#puts $fp_domain_list "$op_name"
regsub -all "\{" $bar_graph_x($net_name) "" bar_graph_x($net_name);
regsub -all "\}" $bar_graph_x($net_name) "" bar_graph_x($net_name);
regsub -all "\{" $bar_graph_y($net_name) "" bar_graph_y($net_name);
regsub -all "\}" $bar_graph_y($net_name) "" bar_graph_y($net_name);


while { [gets $fp_open_html line] >=0 } {

if { [regexp "DOMAIN_DROP_HERE" $line]} {
for {set i 1 } {$i <= $No_of_sessions} {incr i} {

set factor [expr ($i_net-1)*$No_of_sessions];
set a [expr $factor+$i];

set file1 "_summary.html";
set file "$session_name($a)$file1"

puts $fp_open_write_drop_html "\n"
puts $fp_open_write_drop_html "<tr>"
puts $fp_open_write_drop_html "<td><a href=\"/rhe/file?fname=adsRHE/session_$file\"><center>$session_name($a)</a></center></td>"
puts $fp_open_write_drop_html "<td><center>$session_drop($a)</center></td>"
puts $fp_open_write_drop_html "</tr>"
puts  $fp_open_write_drop_html "\n"
}

} elseif { [regexp "SESSIONS" $line]} {
puts  $fp_open_write_drop_html "categories: \[$bar_graph_x($net_name)]\,"
} elseif { [regexp "DROP_TABLE" $line]} {
puts  $fp_open_write_drop_html "data: \[$bar_graph_y($net_name)]"
 } elseif { [regexp "DOMAIN_TITLE" $line]} {
puts $fp_open_write_drop_html "title:\"$net_name Metal Density Summary\"\,"
} elseif {[regexp "HEIGHT_HERE" $line]} {
set h [expr 30*$No_of_sessions];
regsub "HEIGHT_HERE" $line "$h$pixel_unit" line_new
puts $fp_open_write_drop_html $line_new;
} else {
puts  $fp_open_write_drop_html $line
}

}

close $fp_open_html
close $fp_open_write_drop_html
}
#close $fp_domain_list
close $fp_rhe_copy
}

##END OF LAYER SPECIFIC METAL DENSITY PROC

##POWER SUMMARY HTML PAGE PROC

proc setup_power_summary_html  {args} {

#Reading Arguments
if {[regexp "html_template" [lindex $args 0]]} {
set html_template  [lindex $args 1]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}
if {[regexp "results_dir" [lindex $args 2]]} {
set results_dir  [lindex $args 3]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}


if {[regexp "out_dir" [lindex $args 4]]} {
set out_dir [lindex $args 5]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}

#Reading Design Parameters
set fp_open [open "$results_dir/sessions_power_summary.rpt" r];
set power_summary_count 0;
set bar_graph_x "";
set bar_graph_y "";

while { [gets $fp_open line_p] >= 0} {
if { $line_p ne "" && ![regexp "#" $line_p] } {
set power_summary_count [incr power_summary_count];
set line_split_p [split $line_p " "];
set session_power [lindex $line_split_p 0]
set session_name [lindex $line_split_p 1];

set power_session($power_summary_count) $session_power;
set power_name($power_summary_count) $session_name;

lappend bar_graph_x "\'$session_power\' \,"
lappend bar_graph_y "$session_name\, "
}
}


close $fp_open;


#Setting up main HTML Page
set fp_open_html [open "$html_template" r];
set fp_open_write_power_html [open "$out_dir/power.html" w];
regsub -all "\{" $bar_graph_x "" bar_graph_x;
regsub -all "\}" $bar_graph_x "" bar_graph_x;
regsub -all "\{" $bar_graph_y "" bar_graph_y;
regsub -all "\}" $bar_graph_y "" bar_graph_y;
set pixel_unit "px"

while {[gets $fp_open_html line] >=0 } {

if { [regexp "POWER_SUMMARY_HERE" $line]} {

for {set i 1 } {$i <= $power_summary_count} {incr i} {
set file1 "_summary.html";
set file "$power_session($i)$file1"
puts $fp_open_write_power_html "\n"
puts $fp_open_write_power_html "<tr>"
puts $fp_open_write_power_html "<td><a href=\"/rhe/file?fname=adsRHE/session_$file\"><center>$power_session($i)</a></center></td>"
puts $fp_open_write_power_html "<td><center>$power_name($i)</center></td>"
puts $fp_open_write_power_html "</tr>"
puts  $fp_open_write_power_html "\n"
}

} elseif { [regexp "SESSIONS" $line]} {
puts  $fp_open_write_power_html "categories: \[$bar_graph_x]\,"
} elseif { [regexp "POWER" $line]} {
puts  $fp_open_write_power_html "data: \[$bar_graph_y]"
 } elseif {[regexp "HEIGHT_HERE" $line]} {
set h [expr 30*$power_summary_count];
regsub "HEIGHT_HERE" $line "$h$pixel_unit" line_new
puts $fp_open_write_power_html $line_new;
} else {
puts  $fp_open_write_power_html $line
}

}

close $fp_open_html
close $fp_open_write_power_html
}

##END OF POWER SUMMARY HTML PAGE PROC

## RESISTANCE HTML PAGE PROC
proc setup_resistance_html  {args} {

#Reading Arguments
if {[regexp "html_template" [lindex $args 0]]} {
set html_template  [lindex $args 1]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}
if {[regexp "results_dir" [lindex $args 2]]} {
set results_dir  [lindex $args 3]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}


if {[regexp "out_dir" [lindex $args 4]]} {
set out_dir [lindex $args 5]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}

#Reading Design Parameters
set fp_open [open "$results_dir/Worst_case_res_per_session.rpt" r];
set resistance_summary_count 0;
set bar_graph_summary_x "";
set bar_graph_summary_y "";

while { [gets $fp_open line] >= 0 } {
if { $line ne "" && ![regexp "#" $line]  } {
set resistance_summary_count [incr resistance_summary_count];
regsub -all {\s+} $line " " line
set line_split [split $line " "];
set session_name [lindex $line_split 0]
set session_resistance [lindex $line_split 1];
set Wire_res_val [lindex $line_split 3];
set Via_res_val [lindex $line_split 5];
set Switch_res_val [lindex $line_split 7];
lappend bar_graph_summary_x "\'$session_name\' \,"
lappend bar_graph_summary_y "$session_resistance\, "

set resistance_session_name($resistance_summary_count) $session_name;
set resistance_session($resistance_summary_count) $session_resistance;
set Wire_res($resistance_summary_count) $Wire_res_val;
set Via_res($resistance_summary_count) $Via_res_val;
set Switch_res($resistance_summary_count) $Switch_res_val;

}
}


close $fp_open;


#Worst case Effective resistance
set fp_open_layer [open "$results_dir/Worst_Eff_res_per_session.rpt" r];
set count_layer_line 0
set bar_graph_layer_x "";
set bar_graph_layer_y "";

while {[gets $fp_open_layer line] >= 0} {

if { $line ne "" && ![regexp "#" $line] } {
regsub -all {\s+} $line " " line
set fp_line_split [split $line " "];
set count_layer_line [incr count_layer_line];
set eff_res_name($count_layer_line) [lindex $fp_line_split 0];
set eff_res_val($count_layer_line) [lindex $fp_line_split 1];

lappend bar_graph_layer_x "\'$eff_res_name($count_layer_line)\' \,"
lappend bar_graph_layer_y "$eff_res_val($count_layer_line)\, "

}
}
close $fp_open_layer


#Setting up main HTML Page
set fp_open_html [open "$html_template" r];
set fp_open_write_resistance_html [open "$out_dir/resistance.html" w];
regsub -all "\{" $bar_graph_summary_x "" bar_graph_summary_x;
regsub -all "\}" $bar_graph_summary_x "" bar_graph_summary_x;
regsub -all "\{" $bar_graph_summary_y "" bar_graph_summary_y;
regsub -all "\}" $bar_graph_summary_y "" bar_graph_summary_y;

regsub -all "\{" $bar_graph_layer_x "" bar_graph_layer_x;
regsub -all "\}" $bar_graph_layer_x "" bar_graph_layer_x;
regsub -all "\{" $bar_graph_layer_y "" bar_graph_layer_y;
regsub -all "\}" $bar_graph_layer_y "" bar_graph_layer_y;

set pixel_unit "px"

while {[gets $fp_open_html line] >=0 } {

if { [regexp "WORST_CASE_R_HERE" $line]} {

for {set i 1 } {$i <= $resistance_summary_count} {incr i} {
set file1 "_summary.html";
set file "$resistance_session_name($i)$file1"

puts $fp_open_write_resistance_html "\n"
puts $fp_open_write_resistance_html "<tr>"
puts $fp_open_write_resistance_html "<td><a href=\"/rhe/file?fname=adsRHE/session_$file\"><center>$resistance_session_name($i)</a></center></td>"
puts $fp_open_write_resistance_html "<td><center>$resistance_session($i)</center></td>"
puts $fp_open_write_resistance_html "<td><center>$eff_res_val($i)</center></td>"
puts $fp_open_write_resistance_html "<td>WIRE = $Wire_res($i)<br>VIA = $Via_res($i)<br>SWITCH = $Switch_res($i)</td>"

puts $fp_open_write_resistance_html "</tr>"
puts  $fp_open_write_resistance_html "\n"
}

}  elseif { [regexp "SESSION_SUMMARY" $line] } {
puts $fp_open_write_resistance_html "categories: \[$bar_graph_summary_x]\,"
} elseif {[regexp "WORST_CASE_R" $line]} {
puts $fp_open_write_resistance_html "data: \[$bar_graph_summary_y]"
} elseif { [regexp "SESSION_HERE" $line] } {
puts $fp_open_write_resistance_html "categories: \[$bar_graph_layer_x]\,"
} elseif {[regexp "WORST_CASE_EFF_R" $line]} {
puts $fp_open_write_resistance_html "data: \[$bar_graph_layer_y]"
} elseif {[regexp "HEIGHT_WCR" $line]} {
set h [expr 30*$resistance_summary_count];
regsub "HEIGHT_WCR" $line "$h$pixel_unit" line_new
puts $fp_open_write_resistance_html $line_new;
} elseif {[regexp "HEIGHT_WCER" $line]} {
set h [expr 30*$count_layer_line];
regsub "HEIGHT_WCER" $line "$h$pixel_unit" line_new
puts $fp_open_write_resistance_html $line_new;
} else {
puts  $fp_open_write_resistance_html $line
}

}

close $fp_open_html
close $fp_open_write_resistance_html
}

## END OF RESISTANCE PAGE HTML PROC

## STATIC IR MAIN HTML PAGE

proc setup_ir_html  {args} {

#Reading Arguments
if {[regexp "html_template" [lindex $args 0]]} {
set html_template  [lindex $args 1]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}
if {[regexp "results_dir" [lindex $args 2]]} {
set results_dir  [lindex $args 3]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}


if {[regexp "out_dir" [lindex $args 4]]} {
set out_dir [lindex $args 5]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}

#Reading Design Parameters
set fp_open_power [open "$results_dir/sessions_ir_summary_power.rpt" r];
set fp_open_ground [open "$results_dir/sessions_ir_summary_ground.rpt" r];
set ir_summary_count 0;
set bar_graph_summary_x "";
set bar_graph_summary_y "";

while { [gets $fp_open_power line_p] >= 0 && [gets $fp_open_ground line_g] >= 0  } {
if { $line_p ne "" && $line_g ne "" && ![regexp "#" $line_p] && ![regexp "#" $line_g]  } {
set ir_summary_count [incr ir_summary_count];
set line_split_p [split $line_p " "];
set line_split_g [split $line_g " "];
set session_power [lindex $line_split_p 0]
set session_ground [lindex $line_split_g 0]
set drop_power [lindex $line_split_p 2]
set drop_ground [lindex $line_split_g 2]
set drop_net_p [lindex $line_split_p 1];
set drop_net_g [lindex $line_split_g 1];

lappend bar_graph_summary_power_x "\'$session_power\' \,"
lappend bar_graph_summary_power_y "$drop_power\, "

lappend bar_graph_summary_ground_x "\'$session_ground\' \,"
lappend bar_graph_summary_ground_y "$drop_ground\, "


set power_session($ir_summary_count) $session_power;
set ground_session($ir_summary_count) $session_ground;
set power_drop($ir_summary_count) $drop_power;
set ground_drop($ir_summary_count) $drop_ground;
set power_net($ir_summary_count) $drop_net_p;
set ground_net($ir_summary_count) $drop_net_g;
}
}


close $fp_open_power;
close $fp_open_ground;

#Reading Domain Specific IR Drop
set fp_open_domain_drop [open "$results_dir/domain_worst_drop_summary.rpt" r];
set count_domain_drop_line 0
set bar_graph_domain_x "";
set bar_graph_domain_y "";

while {[gets $fp_open_domain_drop line] >= 0 } {

if { $line ne "" && ![regexp "#" $line] } {
set fp_line_split [split $line " "];
set count_domain_drop_line [incr count_domain_drop_line];
set domain_name($count_domain_drop_line) [lindex $fp_line_split 0];
set domain_drop($count_domain_drop_line) [lindex $fp_line_split 1];
set domain_session($count_domain_drop_line) [lindex $fp_line_split 2];

lappend bar_graph_domain_x "\'$domain_name($count_domain_drop_line)\' \,"
lappend bar_graph_domain_y "$domain_drop($count_domain_drop_line)\, "


}
}
close $fp_open_domain_drop

#Reading Layer Specific IR Drop
set fp_open_layer_drop [open "$results_dir/layer_worst_drop_summary.rpt" r];
set count_layer_drop_line 0
set bar_graph_layer_x "";
set bar_graph_layer_y "";

while {[gets $fp_open_layer_drop line] >= 0} {

if { $line ne "" && ![regexp "#" $line] } {
set fp_line_split [split $line " "];
set count_layer_drop_line [incr count_layer_drop_line];
set layer_name($count_layer_drop_line) [lindex $fp_line_split 0];
set layer_drop($count_layer_drop_line) [lindex $fp_line_split 1];
set layer_session($count_layer_drop_line) [lindex $fp_line_split 2];
lappend bar_graph_layer_x "\'$layer_name($count_layer_drop_line)\' \,"
lappend bar_graph_layer_y "$layer_drop($count_layer_drop_line)\, "


}
}
close $fp_open_layer_drop


#Setting up main HTML Page
set fp_open_html [open "$html_template" r];
set fp_open_write_ir_html [open "$out_dir/ir.html" w];
regsub -all "\{" $bar_graph_summary_power_x "" bar_graph_summary_power_x;
regsub -all "\}" $bar_graph_summary_power_x "" bar_graph_summary_power_x;
regsub -all "\{" $bar_graph_summary_power_y "" bar_graph_summary_power_y;
regsub -all "\}" $bar_graph_summary_power_y "" bar_graph_summary_power_y;

regsub -all "\{" $bar_graph_summary_ground_x "" bar_graph_summary_ground_x;
regsub -all "\}" $bar_graph_summary_ground_x "" bar_graph_summary_ground_x;
regsub -all "\{" $bar_graph_summary_ground_y "" bar_graph_summary_ground_y;
regsub -all "\}" $bar_graph_summary_ground_y "" bar_graph_summary_ground_y;

regsub -all "\{" $bar_graph_domain_x "" bar_graph_domain_x;
regsub -all "\}" $bar_graph_domain_x "" bar_graph_domain_x;
regsub -all "\{" $bar_graph_domain_y "" bar_graph_domain_y;
regsub -all "\}" $bar_graph_domain_y "" bar_graph_domain_y;

regsub -all "\{" $bar_graph_layer_x "" bar_graph_layer_x;
regsub -all "\}" $bar_graph_layer_x "" bar_graph_layer_x;
regsub -all "\{" $bar_graph_layer_y "" bar_graph_layer_y;
regsub -all "\}" $bar_graph_layer_y "" bar_graph_layer_y;
set pixel_unit "px"

while {[gets $fp_open_html line] >=0 } {

if { [regexp "IR_DROP_SUMMARY_HERE" $line]} {

for {set i 1 } {$i <= $ir_summary_count} {incr i} {
set file1 "_summary.html";
set file "$power_session($i)$file1"

puts $fp_open_write_ir_html "\n"
puts $fp_open_write_ir_html "<tr>"
puts $fp_open_write_ir_html "<td><a href=\"/rhe/file?fname=adsRHE/session_$file\"><center>$power_session($i)</a></center></td>"
#puts $fp_open_write_ir_html "<td><center>$power_net($i) = $power_drop($i) ; $ground_net($i) = $ground_drop($i)</center></td>"
puts $fp_open_write_ir_html "<td><center>$power_drop($i)</center></td>"
puts $fp_open_write_ir_html "<td><center>$ground_drop($i)</center></td>"
puts $fp_open_write_ir_html "</tr>"
puts  $fp_open_write_ir_html "\n"
}

} elseif { [regexp "NET_SPECIFIC_SUMMARY_HERE" $line]} {

for {set j 1 } {$j <= $count_domain_drop_line} {incr j} {
set file1 "_summary.html";
set file "$domain_session($j)$file1"

puts $fp_open_write_ir_html "\n"
puts $fp_open_write_ir_html "<tr>"
puts $fp_open_write_ir_html "<td><center><a href=\"/rhe/file?fname=adsRHE/$domain_name($j)_drop.html\">$domain_name($j)</a></center></td>"
puts $fp_open_write_ir_html "<td><center>$domain_drop($j)</center></td>"
puts $fp_open_write_ir_html "<td><a href=\"/rhe/file?fname=adsRHE/session_$file\"><center>$domain_session($j)</a></center></td>"
puts $fp_open_write_ir_html "</tr>"
puts  $fp_open_write_ir_html "\n"
}

} elseif { [regexp "LAYER_SPECIFIC_SUMMARY_HERE" $line]} {

for {set k 1 } {$k <= $count_layer_drop_line} {incr k} {
set file1 "_summary.html";
set file "$layer_session($k)$file1"


puts $fp_open_write_ir_html "\n"
puts $fp_open_write_ir_html "<tr>"
puts $fp_open_write_ir_html "<td><center><a href=\"/rhe/file?fname=adsRHE/$layer_name($k)_drop.html\">$layer_name($k)</a></center></td>"
puts $fp_open_write_ir_html "<td><center>$layer_drop($k)</center></td>"
puts $fp_open_write_ir_html "<td><a href=\"/rhe/file?fname=adsRHE/session_$file\"><center>$layer_session($k)</a></center></td>"
puts $fp_open_write_ir_html "</tr>"
puts  $fp_open_write_ir_html "\n"
}

} elseif {[regexp "POWER_SUMMARY" $line] } {
puts $fp_open_write_ir_html "categories: \[$bar_graph_summary_power_x]\,"
}  elseif {[regexp "POWER_DROP_SUMMARY_HERE" $line] } {
puts $fp_open_write_ir_html "data: \[$bar_graph_summary_power_y]"
} elseif {[regexp "GROUND_SUMMARY" $line] } {
puts $fp_open_write_ir_html "categories: \[$bar_graph_summary_ground_x]\,"
}  elseif {[regexp "GROUND_DROP_SUMMARY_HERE" $line] } {
puts $fp_open_write_ir_html "data: \[$bar_graph_summary_ground_y]"
} elseif {[regexp "DOMAIN_HERE" $line] } {
puts $fp_open_write_ir_html "categories: \[$bar_graph_domain_x]\,"
}  elseif {[regexp "DOMAIN_DROP" $line] } {
puts $fp_open_write_ir_html "data: \[$bar_graph_domain_y]"
} elseif {[regexp "LAYER_HERE" $line] } {
puts $fp_open_write_ir_html "categories: \[$bar_graph_layer_x]\,"
}  elseif {[regexp "LAYER_DROP" $line] } {
puts $fp_open_write_ir_html "data: \[$bar_graph_layer_y]"
} elseif {[regexp "HEIGHT_SUMMARY" $line]} {
set h [expr 30*$ir_summary_count];
regsub "HEIGHT_SUMMARY" $line "$h$pixel_unit" line_new
puts $fp_open_write_ir_html $line_new;
} elseif {[regexp "HEIGHT_DOMAIN" $line]} {
set h [expr 60*$count_domain_drop_line];
regsub "HEIGHT_DOMAIN" $line "$h$pixel_unit" line_new
puts $fp_open_write_ir_html $line_new;
} elseif {[regexp "HEIGHT_LAYER" $line]} {
set h [expr 60*$count_layer_drop_line];
regsub "HEIGHT_LAYER" $line "$h$pixel_unit" line_new
puts $fp_open_write_ir_html $line_new;
} elseif {[regexp "HEIGHT_TABLE_DOMAIN" $line]} {
set h [expr 25*$count_domain_drop_line];
regsub "HEIGHT_TABLE_DOMAIN" $line "$h" line_new
puts $fp_open_write_ir_html $line_new;
} elseif {[regexp "HEIGHT_TABLE_LAYER" $line]} {
set h [expr 25*$count_layer_drop_line];
regsub "HEIGHT_TABLE_LAYER" $line "$h" line_new
puts $fp_open_write_ir_html $line_new;
}  else {
puts  $fp_open_write_ir_html $line
}

}

close $fp_open_html
close $fp_open_write_ir_html
}

## END OF STATIC IR MAIN HTML PAGE

## DOMAIN SPECIFIC IR HTML PAGE PROC
proc setup_domain_ir_html  {args} {

#Reading Arguments
if {[regexp "html_template" [lindex $args 0]]} {
set html_template  [lindex $args 1]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}
if {[regexp "results_dir" [lindex $args 2]]} {
set results_dir  [lindex $args 3]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}


if {[regexp "out_dir" [lindex $args 4]]} {
set out_dir [lindex $args 5]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}

#Reading Design Parameters
set fp_open [open "$results_dir/net_specific_ir_summary.rpt" r];
set power_summary_count 0;
set net_count 0;
while { [gets $fp_open line_p] >= 0} {

if { [regexp "#Net:" $line_p] } {
set line_net_split [split $line_p " "];
set net_split [lindex $line_net_split 1];
set net_count [incr net_count];
set net($net_count) [lindex $line_net_split 1];
set bar_graph_x($net_split) "";
set bar_graph_y($net_split) "";

}

if { $line_p ne "" && ![regexp "#" $line_p] } {

set power_summary_count [expr $power_summary_count+1];

if { $net_count == 1 } {
set No_of_sessions $power_summary_count
}

set line_split_p [split $line_p " "];
set net_session [lindex $line_split_p 0]
set net_drop [lindex $line_split_p 1];

set session_name($power_summary_count) $net_session;
set session_drop($power_summary_count) $net_drop;
lappend bar_graph_x($net_split) "\'$net_session\' \,"
lappend bar_graph_y($net_split) "$net_drop\, "
}
}


close $fp_open;


#Setting up main HTML Page
set fp_domain_list [open "$out_dir/design_domain_list" w];
set fp_rhe_copy [open "$out_dir/domain_specific_sessions_ir_rhe_copy.rpt" w]
for {set i_net 1} {$i_net <= $net_count} {incr i_net} {
set net_name $net($i_net);
set fp_open_html [open "$html_template" r];
set op_name1 "_drop";
set op_name "$net_name$op_name1.html";
set fp_open_write_drop_html [open "$out_dir/$op_name" w];
puts $fp_rhe_copy "rhe_nx::rhe_copy_tcl \"$out_dir/$op_name\" \"adsRHE/$op_name\"" 
puts $fp_domain_list "$op_name"
regsub -all "\{" $bar_graph_x($net_name) "" bar_graph_x($net_name);
regsub -all "\}" $bar_graph_x($net_name) "" bar_graph_x($net_name);
regsub -all "\{" $bar_graph_y($net_name) "" bar_graph_y($net_name);
regsub -all "\}" $bar_graph_y($net_name) "" bar_graph_y($net_name);
set pixel_unit "px"

while {[gets $fp_open_html line] >=0 } {

if { [regexp "DOMAIN_DROP_HERE" $line]} {
for {set i 1 } {$i <= $No_of_sessions} {incr i} {

set factor [expr ($i_net-1)*$No_of_sessions];
set a [expr $factor+$i];

set file1 "_summary.html";
if {[info exists session_name($a)]} {
set file "$session_name($a)$file1"

puts $fp_open_write_drop_html "\n"
puts $fp_open_write_drop_html "<tr>"
puts $fp_open_write_drop_html "<td><a href=\"/rhe/file?fname=adsRHE/session_$file\"><center>$session_name($a)</a></center></td>"
puts $fp_open_write_drop_html "<td><center>$session_drop($a)</center></td>"
puts $fp_open_write_drop_html "</tr>"
puts  $fp_open_write_drop_html "\n"
}
}

} elseif { [regexp "SESSIONS" $line]} {
puts  $fp_open_write_drop_html "categories: \[$bar_graph_x($net_name)]\,"
} elseif { [regexp "DROP_TABLE" $line]} {
puts  $fp_open_write_drop_html "data: \[$bar_graph_y($net_name)]"
 } elseif { [regexp "DOMAIN_TITLE" $line]} {
puts $fp_open_write_drop_html "title:\"$net_name Drop Summary\"\,"
} elseif {[regexp "HEIGHT_HERE" $line]} {
set h [expr 30*$No_of_sessions];
regsub "HEIGHT_HERE" $line "$h$pixel_unit" line_new
puts $fp_open_write_drop_html $line_new;
} else {
puts  $fp_open_write_drop_html $line
}

}

close $fp_open_html
close $fp_open_write_drop_html
}
close $fp_domain_list
close $fp_rhe_copy
}

##END DOMAIN IR HTML PAGE PROC

##LAYER IR HTML PAGE PROC

proc setup_layer_ir_html  {args} {

#Reading Arguments
if {[regexp "html_template" [lindex $args 0]]} {
set html_template  [lindex $args 1]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}
if {[regexp "results_dir" [lindex $args 2]]} {
set results_dir  [lindex $args 3]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}


if {[regexp "out_dir" [lindex $args 4]]} {
set out_dir [lindex $args 5]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}

#Reading Design Parameters
set fp_open [open "$results_dir/layer_specific_ir_summary.rpt" r];
set power_summary_count 0;
set layer_count 0;
while { [gets $fp_open line_p] >= 0} {

if { [regexp "#Layer:" $line_p] } {
set line_layer_split [split $line_p " "];
set layer_split [lindex $line_layer_split 1];
set layer_count [incr layer_count];
set layer($layer_count) [lindex $line_layer_split 1];
set bar_graph_x($layer_split) "";
set bar_graph_y($layer_split) "";

}

if { $line_p ne "" && ![regexp "#" $line_p] } {

set power_summary_count [expr $power_summary_count+1];

if { $layer_count == 1 } {
set No_of_sessions $power_summary_count
}

set line_split_p [split $line_p " "];
set layer_session [lindex $line_split_p 0]
set layer_drop [lindex $line_split_p 1];

set session_name($power_summary_count) $layer_session;
set session_drop($power_summary_count) $layer_drop;
lappend bar_graph_x($layer_split) "\'$layer_session\' \,"
lappend bar_graph_y($layer_split) "$layer_drop\, "
}
}


close $fp_open;


#Setting up main HTML Page
set fp_domain_list [open "$out_dir/design_layer_list" w];
set fp_rhe_copy [open "$out_dir/layer_specific_sessions_ir_rhe_copy.rpt" w];
for {set i_layer 1} {$i_layer <= $layer_count} {incr i_layer} {
set layer_name $layer($i_layer);
set fp_open_html [open "$html_template" r];
set op_name1 "_drop";
set op_name "$layer_name$op_name1.html";
set fp_open_write_drop_html [open "$out_dir/$op_name" w];
puts $fp_rhe_copy "rhe_nx::rhe_copy_tcl \"$out_dir/$op_name\" \"adsRHE/$op_name\"" 
puts $fp_domain_list "$op_name"
regsub -all "\{" $bar_graph_x($layer_name) "" bar_graph_x($layer_name);
regsub -all "\}" $bar_graph_x($layer_name) "" bar_graph_x($layer_name);
regsub -all "\{" $bar_graph_y($layer_name) "" bar_graph_y($layer_name);
regsub -all "\}" $bar_graph_y($layer_name) "" bar_graph_y($layer_name);
set pixel_unit "px"

while {[gets $fp_open_html line] >=0 } {

if { [regexp "DOMAIN_DROP_HERE" $line]} {
for {set i 1 } {$i <= $No_of_sessions} {incr i} {
set factor [expr ($i_layer-1)*$No_of_sessions];
set a [expr $factor+$i];
set file1 "_summary.html";
if {[info exists session_name($a)]} {
set file "$session_name($a)$file1"

puts $fp_open_write_drop_html "\n"
puts $fp_open_write_drop_html "<tr>"
puts $fp_open_write_drop_html "<td><a href=\"/rhe/file?fname=adsRHE/session_$file\"><center>$session_name($a)</a></center></td>"
puts $fp_open_write_drop_html "<td><center>$session_drop($a)</center></td>"
puts $fp_open_write_drop_html "</tr>"
puts  $fp_open_write_drop_html "\n"
}
}
} elseif { [regexp "SESSIONS" $line]} {
puts  $fp_open_write_drop_html "categories: \[$bar_graph_x($layer_name)]\,"
} elseif { [regexp "DROP_TABLE" $line]} {
puts  $fp_open_write_drop_html "data: \[$bar_graph_y($layer_name)]"
 } elseif { [regexp "DOMAIN_TITLE" $line]} {
puts $fp_open_write_drop_html "title:\"$layer_name Drop Summary\"\,"
} elseif {[regexp "HEIGHT_HERE" $line]} {
set h [expr 30*$No_of_sessions];
regsub "HEIGHT_HERE" $line "$h$pixel_unit" line_new
puts $fp_open_write_drop_html $line_new;
} else {
puts  $fp_open_write_drop_html $line
}

}

close $fp_open_html
close $fp_open_write_drop_html
}
close $fp_domain_list
close $fp_rhe_copy
}

##END LAYER IR HTML PAGE

##EM HTML PAGE PROC

proc setup_em_summary_html  {args} {

#Reading Arguments
if {[regexp "html_template" [lindex $args 0]]} {
set html_template  [lindex $args 1]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}
if {[regexp "results_dir" [lindex $args 2]]} {
set results_dir  [lindex $args 3]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}


if {[regexp "out_dir" [lindex $args 4]]} {
set out_dir [lindex $args 5]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}

#Reading Number of metal EM violations per session
set fp_open [open "$results_dir/Metal_EM_Violations_per_session.rpt" r];
set em_summary_count 0;
set bar_graph_summary_x1 "";
set bar_graph_summary_y1 "";
set bar_graph_summary_y2 "";

while { [gets $fp_open line] >= 0 } {
if { $line ne "" && ![regexp "#" $line]  } {
set em_summary_count [incr em_summary_count];
regsub -all {\s+} $line " " line
set line_split [split $line " "];
set session_name_em [lindex $line_split 0]
set metal_em_vio [lindex $line_split 2];
set session_name_em_worst [lindex $line_split 1];

lappend bar_graph_summary_x1 "\'$session_name_em\'\,";
lappend bar_graph_summary_y1 "$metal_em_vio\, ";
lappend bar_graph_summary_y2 "$session_name_em_worst\, ";

set session_name_metal_em($em_summary_count) $session_name_em;
set session_metal_em($em_summary_count) $metal_em_vio;
set session_metal_em_worst($em_summary_count) $session_name_em_worst;
set session_name_metal_em_worst($em_summary_count) $session_name_em;

}
}
close $fp_open;

#Reading Number of via EM violations per session
set fp_open [open "$results_dir/Via_EM_Violations_per_session.rpt" r];
set via_em_summary_count 0;
set bar_graph_via_x1 "";
set bar_graph_via_y1 "";
set bar_graph_via_y2 "";





while { [gets $fp_open line] >= 0 } {
if { $line ne "" && ![regexp "#" $line]  } {
set via_em_summary_count [incr via_em_summary_count];
regsub -all {\s+} $line " " line
set line_split [split $line " "];
set session_name_em [lindex $line_split 0]
set via_em_vio [lindex $line_split 2];
set via_em_vio_worst [lindex $line_split 1];

lappend bar_graph_via_x1 "\'$session_name_em\'\,";
lappend bar_graph_via_y1 "$via_em_vio\, ";
lappend bar_graph_via_y2 "$via_em_vio_worst\, ";

set session_name_via_em($via_em_summary_count) $session_name_em;
set session_via_em($via_em_summary_count) $via_em_vio;
set session_name_via_em_worst($via_em_summary_count) $session_name_em;
set session_via_em_worst($via_em_summary_count) $via_em_vio_worst;
}
}
close $fp_open;


#Setting up main HTML Page
set fp_open_html [open "$html_template" r];
set fp_open_em_summary_html [open "$out_dir/em.html" w];

regsub -all "\{" $bar_graph_summary_x1 "" bar_graph_summary_x1;
regsub -all "\}" $bar_graph_summary_x1 "" bar_graph_summary_x1;
regsub -all "\{" $bar_graph_summary_y1 "" bar_graph_summary_y1;
regsub -all "\}" $bar_graph_summary_y1 "" bar_graph_summary_y1;
regsub -all "\{" $bar_graph_summary_y2 "" bar_graph_summary_y2;
regsub -all "\}" $bar_graph_summary_y2 "" bar_graph_summary_y2;

regsub -all "\{" $bar_graph_via_x1 "" bar_graph_via_x1;
regsub -all "\}" $bar_graph_via_x1 "" bar_graph_via_x1;
regsub -all "\{" $bar_graph_via_y1 "" bar_graph_via_y1;
regsub -all "\}" $bar_graph_via_y1 "" bar_graph_via_y1;
regsub -all "\{" $bar_graph_via_y2 "" bar_graph_via_y2;
regsub -all "\}" $bar_graph_via_y2 "" bar_graph_via_y2;
set pixel_unit "px"

while {[gets $fp_open_html line] >=0 } {

if { [regexp "NUMBER_METAL_EM_HERE" $line]} {

for {set i 1 } {$i <= $em_summary_count} {incr i} {
set file1 "_summary.html";
set file "$session_name_metal_em($i)$file1"

puts $fp_open_em_summary_html "\n"
puts $fp_open_em_summary_html "<tr>"
puts $fp_open_em_summary_html "<td><a href=\"/rhe/file?fname=adsRHE/session_$file\"><center>$session_name_metal_em($i)</a></center></td>"
puts $fp_open_em_summary_html "<td><center>$session_metal_em($i)</center></td>"
puts $fp_open_em_summary_html "<td><center>$session_metal_em_worst($i)</center></td>"
puts $fp_open_em_summary_html "</tr>"
puts  $fp_open_em_summary_html "\n"
}

} elseif { [regexp "NUMBER_VIA_EM_HERE" $line]} {

for {set j 1 } {$j <= $via_em_summary_count} {incr j} {
set file1 "_summary.html";
set file "$session_name_via_em($j)$file1"

puts $fp_open_em_summary_html "\n"
puts $fp_open_em_summary_html "<tr>"
puts $fp_open_em_summary_html "<td><a href=\"/rhe/file?fname=adsRHE/session_$file\"><center>$session_name_via_em($j)</a></center></td>"
puts $fp_open_em_summary_html "<td><center>$session_via_em($j)</center></td>"
puts $fp_open_em_summary_html "<td><center>$session_via_em_worst($j)</center></td>"
puts $fp_open_em_summary_html "</tr>"
puts  $fp_open_em_summary_html "\n"
}

} elseif {[regexp "TABLE_METAL_EM_HERE1" $line] } {
puts $fp_open_em_summary_html "categories: \[$bar_graph_summary_x1]\,"
} elseif {[regexp "TABLE_NO_METAL_EM_HERE1" $line] } {
puts $fp_open_em_summary_html "data: \[$bar_graph_summary_y1]"
} elseif {[regexp "TABLE_METAL_EM_HERE2" $line] } {
puts $fp_open_em_summary_html "categories: \[$bar_graph_summary_x1]\,"
} elseif {[regexp "TABLE_WORST_METAL_EM_HERE2" $line] } {
puts $fp_open_em_summary_html "data: \[$bar_graph_summary_y2]"
} elseif {[regexp "TABLE_VIA_EM_HERE1" $line] } {
puts $fp_open_em_summary_html "categories: \[$bar_graph_via_x1]\,"
} elseif {[regexp "TABLE_NO_VIA_EM_HERE1" $line] } {
puts $fp_open_em_summary_html "data: \[$bar_graph_via_y1]"
} elseif {[regexp "TABLE_VIA_EM_HERE2" $line] } {
puts $fp_open_em_summary_html "categories: \[$bar_graph_via_x1]\,"
} elseif {[regexp "TABLE_WORST_VIA_EM_HERE2" $line] } {
puts $fp_open_em_summary_html "data: \[$bar_graph_via_y2]"
} elseif {[regexp "HEIGHT_METAL1" $line]} {
set h [expr 35*$em_summary_count];
regsub "HEIGHT_METAL1" $line "$h$pixel_unit" line_new
puts $fp_open_em_summary_html $line_new;
} elseif {[regexp "HEIGHT_METAL2" $line]} {
set h [expr 30*$em_summary_count];
regsub "HEIGHT_METAL2" $line "$h$pixel_unit" line_new
puts $fp_open_em_summary_html $line_new;
} elseif {[regexp "HEIGHT_VIA1" $line]} {
set h [expr 35*$via_em_summary_count];
regsub "HEIGHT_VIA1" $line "$h$pixel_unit" line_new
puts $fp_open_em_summary_html $line_new;
} elseif {[regexp "HEIGHT_VIA2" $line]} {
set h [expr 30*$via_em_summary_count];
regsub "HEIGHT_VIA2" $line "$h$pixel_unit" line_new
puts $fp_open_em_summary_html $line_new;
} else {
puts  $fp_open_em_summary_html $line
}

}

close $fp_open_html
close $fp_open_em_summary_html
}

## END HTML PAGE PROC

## SESSION SUMMARY MAIN HTML PAGE PROC

proc setup_sessions_main_page_html  {args} {

#Reading Arguments
if {[regexp "html_template" [lindex $args 0]]} {
set html_template  [lindex $args 1]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}
if {[regexp "results_dir" [lindex $args 2]]} {
set results_dir  [lindex $args 3]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}


if {[regexp "out_dir" [lindex $args 4]]} {
set out_dir [lindex $args 5]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}

if {[regexp "session_count" [lindex $args 6]]} {
set sessions_count [lindex $args 7]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}


#Reading Design Parameters
set files [glob -directory $results_dir session_*.rpt];
set files_sorted [lsort -dictionary $files]
#set sessions_count [llength $files_sorted]
set sessions_count [expr $sessions_count+1]
#Setting up main HTML Page
set fp_open_html [open "$html_template" r];
set fp_open_write_main_html [open "$out_dir/sessions_main.html" w];

while {[gets $fp_open_html line] >=0 } {
if {[regexp "SESSIONS_HERE" $line]} {
for {set i 0} {$i < $sessions_count} {incr i} {

if { $i == 0} {
set session "p"
} else {
set session "c$i";
}
set file1 "_summary.html";
set file "$session$file1";
set l [expr $i+1]
set flag1 [expr $l%15];
set flag2 [expr $sessions_count-1]
if {$i == 0 } {
puts $fp_open_write_main_html "<tr>" 
puts $fp_open_write_main_html "<td><center><a href=\"/rhe/file?fname=adsRHE/session_$file\">$session</a></center></td>"
} elseif { $i == $flag2} {
 puts $fp_open_write_main_html "<td><center><a href=\"/rhe/file?fname=adsRHE/session_$file\">$session</a></center></td>"
puts $fp_open_write_main_html "</tr>"
} elseif {$flag1 == 0} {
puts $fp_open_write_main_html "<td><center><a href=\"/rhe/file?fname=adsRHE/session_$file\">$session</a></center></td>"
puts $fp_open_write_main_html "</tr>"
puts $fp_open_write_main_html "<tr>"
} elseif { $flag1 != 0 } {
puts $fp_open_write_main_html "<td><center><a href=\"/rhe/file?fname=adsRHE/session_$file\">$session</a></center></td>"
}
}
} elseif {[regexp "HEIGHT_TABLE_SESSION" $line] } {
set r [expr $sessions_count/15];
set q [expr $sessions_count%15];
if { $q == 0} {
set h $r;
} else {
set h [expr $r+1];
}
set height [expr 25*$h]
regsub "HEIGHT_TABLE_SESSION" $line "$height" line_new
puts $fp_open_write_main_html $line_new
} elseif {[regexp "WIDHT_HERE" $line]} {
set width_line [expr 15*32.5];
regsub -all "WIDTH_HERE" $line "$width_line" line
} else {
puts $fp_open_write_main_html $line
}
}

close $fp_open_write_main_html;
close $fp_open_html;

}

## END SESSION SUMMARY MAIN PAGE HTML

## SESSION SPECIFIC METRIC SUMMARY PAGE HTML

proc setup_session_summary_html  {args} {

#Reading Arguments
if {[regexp "html_template" [lindex $args 0]]} {
set html_template  [lindex $args 1]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}
if {[regexp "results_dir" [lindex $args 2]]} {
set results_dir  [lindex $args 3]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}


if {[regexp "out_dir" [lindex $args 4]]} {
set out_dir [lindex $args 5]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}

#Reading Design Parameters
set files [glob -directory $results_dir session_*.rpt];
set files_sorted [lsort -dictionary $files]
set sessions_count [llength $files_sorted]
set fp_rhe_copy [open "$out_dir/sessions_rhe_copy.rpt" w];
for {set i 0} {$i < $sessions_count} {incr i} {
if { $i == 0} {
set session "p"
} else {
set session "c$i";
}
set file1 "session_$session";
set file2 "_summary";
set file "$file1$file2";
set fp_open_write [open "$out_dir/$file.html" w]
puts $fp_rhe_copy "rhe_nx::rhe_copy_tcl \"$out_dir/$file.html\" \"adsRHE/$file.html\""
set fp_open_read [open "$html_template" r]

while { [gets $fp_open_read line1] >= 0} {

if { [regexp "SESSION_TITLE" $line1]}  {
regsub -all "SESSION_TITLE" $line1 "$session Session Metric Summary" line1
puts $fp_open_write $line1;
} elseif {[regexp "METRIC_SUMMARY_HERE" $line1]} {

set fp_open [open "$results_dir/$file.rpt" r];
while { [gets $fp_open line] >= 0} {
if { ![regexp "#" $line]} {
if { [regexp {[a-z]} $line] || [regexp {[A-Z]} $line] } {
regsub -all {\s+} $line { } line
set line_split [split $line " "];
set name [lindex $line_split 1];
set value [lindex $line_split 2];
if {[regexp "Switch" $name]} {
set name "[lindex $line_split 1] [lindex $line_split 2]";
set value [lindex $line_split 3];
puts $fp_open_write "<tr>"
puts $fp_open_write "<td width=\"50%\">$name</td>"
puts $fp_open_write "<td width=\"50%\">$value</td>"
puts $fp_open_write "</tr>"
} elseif {[regexp "Wire" $name] || [regexp "Via" $name] || [regexp {[(]} $line] || [regexp {[)]} $line]   } {
set line_split [split $line ")"]
set name "[lindex $line_split 0]\)";
set value [lindex $line_split 1];
puts $fp_open_write "<tr>"
puts $fp_open_write "<td width=\"50%\">$name</td>"
puts $fp_open_write "<td width=\"50%\">$value</td>"
puts $fp_open_write "</tr>"
}  elseif {[regexp "EM" $line]} {
puts $fp_open_write "<tr>"
puts $fp_open_write "<td colspan=\"2\">$line</td>"
puts $fp_open_write "</tr>"
} else {
puts $fp_open_write "<tr>"
puts $fp_open_write "<td width=\"50%\">$name</td>"
puts $fp_open_write "<td width=\"50%\">$value</td>"
puts $fp_open_write "</tr>"
}
}
} elseif { [regexp "#" $line] && ![regexp "Grid Details" $line] && ![regexp "Worst Resistance Report" $line] && ![regexp "Static IR/EM Report" $line]} {
regsub -all "#" $line "" line
set line_header_split [split $line " "];
if { [regexp "perc_die_area_occupied" $line]} {
puts $fp_open_write "<tr>"
puts $fp_open_write "<td width=\"50%\">Layer</td>"
puts $fp_open_write "<td width=\"50%\">Metal Density (%)</td>"
puts $fp_open_write "</tr>"
} elseif { [regexp "mW" $line]} {
puts $fp_open_write "<tr>"
puts $fp_open_write "<td width=\"50%\">Domain</td>"
puts $fp_open_write "<td width=\"50%\">Power(mW)</td>"
puts $fp_open_write "</tr>"
}  elseif { [regexp "Min_Path_Resistance" $line]} {
puts $fp_open_write "<tr>"
puts $fp_open_write "<td width=\"50%\">Domain</td>"
puts $fp_open_write "<td width=\"50%\">Resistance( Ohm )</td>"
puts $fp_open_write "</tr>"
}  elseif { [regexp "Effective_Resistance" $line]} {
puts $fp_open_write "<tr>"
puts $fp_open_write "<td width=\"50%\">Domain</td>"
puts $fp_open_write "<td width=\"50%\">Resistance( Ohm )</td>"
puts $fp_open_write "</tr>"
} elseif { [regexp "mV" $line] && [regexp "Parameter" $line]} {
puts $fp_open_write "<tr>"
puts $fp_open_write "<td width=\"50%\">Parameter</td>"
puts $fp_open_write "<td width=\"50%\">Drop(mV)</td>"
puts $fp_open_write "</tr>"
} elseif { [regexp "mV" $line] && [regexp "Domain" $line]} {
puts $fp_open_write "<tr>"
puts $fp_open_write "<td width=\"50%\">Domain</td>"
puts $fp_open_write "<td width=\"50%\">Drop(mV)</td>"
puts $fp_open_write "</tr>"
} elseif { [regexp "mV" $line] && [regexp "Layer" $line]} {
puts $fp_open_write "<tr>"
puts $fp_open_write "<td width=\"50%\">Layer</td>"
puts $fp_open_write "<td width=\"50%\">Drop(mV)</td>"
puts $fp_open_write "</tr>"
} elseif { [regexp "Parameter" $line] && [regexp "Value" $line]} {

} else {
if {[regexp "Power Summary Report:" $line]} {
regsub -all "Power Summary Report:" $line "Power Summary:" line
}
puts $fp_open_write "<tr bgcolor=#A8A8A8 >"
puts $fp_open_write "<th colspan=\"2\">$line</th>"
puts $fp_open_write "</tr>"

}
}
}
close $fp_open;
} else {
puts $fp_open_write $line1;
}
}
close $fp_open_write 

}
close $fp_rhe_copy
}

##END OF SESSION SPECIFIC METRIC SUMMARY 


##Figure of Merit SUMMARY PROC
proc setup_FOM_page_html  {args} {

#Reading Arguments
if {[regexp "html_template" [lindex $args 0]]} {
set html_template  [lindex $args 1]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}
if {[regexp "results_dir" [lindex $args 2]]} {
set results_dir  [lindex $args 3]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}


if {[regexp "out_dir" [lindex $args 4]]} {
set out_dir [lindex $args 5]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}

if {[regexp "session_count" [lindex $args 6]]} {
set session_count [lindex $args 7]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}


#Reading Design Parameters
for {set m 0} {$m <= $session_count} {incr m} {
if { $m == 0} {
set session "p"
} else {
set session "c$m";
}
set file1 "session_$session";
set file2 "_summary";
set file "$file1$file2";
set fp_open [open "$results_dir/$file.rpt" r];
set power_flag 0
set metal_density_report_flag 0;
set eff_res_path_flag 0;
set min_res_path_flag 0;
set ir_drop_domain_flag 0;
set ir_drop_layer_flag 0;
set ir_drop_summary_flag 0;

set em_count 0;
set header_count 0;
set ir_domain_count 0;
set ir_layer_count 0;
set ir_summary_count 0;
set metaldensity_count 0;
set power_count 0;
set wcer_count 0;
set wcr_count 0;
set session_row_height 0;

while { [gets $fp_open line] >= 0} {
if { ![regexp "#" $line]} {
if { [regexp {[a-z]} $line] || [regexp {[A-Z]} $line] } {
regsub -all {\s+} $line { } line
set line_split [split $line " "];
set name [lindex $line_split 1];
set value [lindex $line_split 2];
if {[regexp "Switch" $name]} {
set name "[lindex $line_split 1] [lindex $line_split 2]";
set value [lindex $line_split 3];
set ir_summary_x_${session}($ir_summary_count) "$name"
set ir_summary_y_${session}($ir_summary_count) "$value"
set ir_summary_count [expr $ir_summary_count+1]
} elseif {[regexp "Wire Drop" $line] || [regexp "Via Drop" $line]  } {
set line_split [split $line ")"]
set name "[lindex $line_split 0]\)";
set value [lindex $line_split 1];
set ir_summary_x_${session}($ir_summary_count) "$name"
set ir_summary_y_${session}($ir_summary_count) "$value"
set ir_summary_count [expr $ir_summary_count+1]
}  elseif {[regexp "EM" $line]} {
set em_${session}($em_count) "$line"
set em_count [expr $em_count+1]
} else {
if { $power_flag == 1} {
set line_split [split $line ")"]
set name "[lindex $line_split 0]\)";
set value [lindex $line_split 1];
set power_x_${session}($power_count) "$name"
set power_y_${session}($power_count) "$value"
set power_count [expr $power_count+1]
} elseif { $metal_density_report_flag == 1} {
set md_x_${session}($metaldensity_count) "$name"
set md_y_${session}($metaldensity_count) "$value"
set metaldensity_count [expr $metaldensity_count+1]
} elseif { $min_res_path_flag == 1} {
set wcr_x_${session}($wcr_count) "$name"
set wcr_y_${session}($wcr_count) "$value"
set wcr_count [expr $wcr_count+1]
} elseif { $eff_res_path_flag == 1} {
set wcer_x_${session}($wcer_count) "$name"
set wcer_y_${session}($wcer_count) "$value"
set wcer_count [expr $wcer_count+1]
} elseif { $ir_drop_domain_flag == 1 } {
set ir_domain_x_${session}($ir_domain_count) "$name"
set ir_domain_y_${session}($ir_domain_count) "$value"
set ir_domain_count [expr $ir_domain_count+1]
} elseif { $ir_drop_layer_flag == 1 } {
set ir_layer_x_${session}($ir_layer_count) "$name"
set ir_layer_y_${session}($ir_layer_count) "$value"
set ir_layer_count [expr $ir_layer_count+1]
}  
}
}
} elseif { [regexp "#" $line] && ![regexp "Grid Details" $line] && ![regexp "Worst Resistance Report" $line] && ![regexp "Static IR/EM Report" $line]} {
regsub -all "#" $line "" line
set line_header_split [split $line " "];
if { [regexp "perc_die_area_occupied" $line]} {
set metal_density_report_flag 1;
set md_x_${session}($metaldensity_count) "Layer"
set md_y_${session}($metaldensity_count) "Metal Density (%)"
set metaldensity_count [expr $metaldensity_count+1]
} elseif { [regexp "mW" $line]} {
set power_flag 1;
set metal_density_report_flag 0;

set power_x_${session}($power_count) "Domain"
set power_y_${session}($power_count) "Power(mW)"
set power_count [expr $power_count+1]
}  elseif { [regexp "Min_Path_Resistance" $line]} {
set power_flag 0;
set min_res_path_flag 1;
set wcr_x_${session}($wcr_count) "Domain"
set wcr_y_${session}($wcr_count) "Resistance"
set wcr_count [expr $wcr_count+1]
}  elseif { [regexp "Effective_Resistance" $line]} {
set eff_res_path_flag 1;
set min_res_path_flag 0;
set wcer_x_${session}($wcer_count) "Domain"
set wcer_y_${session}($wcer_count) "Resistance"
set wcer_count [expr $wcer_count+1]
} elseif { [regexp "mV" $line] && [regexp "Parameter" $line]} {
set power_flag 0;
set ir_drop_summary_flag 1;
set eff_res_path_flag 0;
set ir_summary_x_${session}($ir_summary_count) "Parameter"
set ir_summary_y_${session}($ir_summary_count) "Drop(mV)"
set ir_summary_count [expr $ir_summary_count+1]
} elseif { [regexp "mV" $line] && [regexp "Domain" $line]} {
set ir_drop_domain_flag 1;
set ir_drop_summary_flag 0;
set ir_domain_x_${session}($ir_domain_count) "Domain"
set ir_domain_y_${session}($ir_domain_count) "Drop(mV)"
set ir_domain_count [expr $ir_domain_count+1]
} elseif { [regexp "mV" $line] && [regexp "Layer" $line]} {
set ir_drop_layer_flag 1;
set ir_drop_domain_flag 0;
set ir_layer_x_${session}($ir_layer_count) "Layer"
set ir_layer_y_${session}($ir_layer_count) "Drop(mV)"
set ir_layer_count [expr $ir_layer_count+1]
} elseif { [regexp "Parameter" $line] && [regexp "Value" $line]} {

} else {
if {[regexp "Power Summary Report:" $line]} {
regsub -all "Power Summary Report:" $line "Power Summary:" line
}
set header_${session}($header_count) "$line"
set header_count [expr $header_count+1]
}
}
}
close $fp_open;

#Finding the Averege Drop for the Session
set avg_metal_density 0;
for {set i 1 } {$i < $metaldensity_count} {incr i} {
set md_value [set md_y_${session}($i)];
if {[regexp {([A-Za-z]+) +([a-z]+)} $md_value] || $md_value == "NA"} {
set md_value 0;
} else {
set md_value $md_value
}
set avg_metal_density [expr $avg_metal_density+$md_value];
}
set avg_metal_density [format "%.2f" $avg_metal_density];
set md($session) $avg_metal_density;

#Finding the Total Power for the Session
set total_power 0;
for {set i 1 } {$i < $power_count} {incr i} {
set pwr_value  [set power_y_${session}($i)];
if {[regexp {([A-Za-z]+) +([a-z]+)} $pwr_value] || $pwr_value == "NA"} {
set pwr_value 0;
} else {
set pwr_value $pwr_value
}

set total_power [expr $total_power+$pwr_value];
}

set power($session) $total_power;

#Finding the Wort case Reistance point for the Session
set worst_case_res 0;

for {set i 1} {$i < $wcr_count } {incr i} {

set wcr_value [set wcr_y_${session}($i)];

if {[regexp {([A-Za-z]+) +([a-z]+)} $wcr_value] || $wcr_value == "NA" } {
set wcr_value 0;
} else {
set wcr_value $wcr_value
}

if { $worst_case_res <= $wcr_value} {
set worst_case_res $wcr_value;
} else {
set worst_case_res $worst_case_res;
}

}
set wcr($session) $worst_case_res;

#Finding the Wort case Effective Reistance point for the Session
set worst_case_eff_res 0;

for {set i 1} {$i < $wcer_count } {incr i} {
set wcer_value [set wcer_y_${session}($i)];

if {[regexp {([A-Za-z]+) +([a-z]+)} $wcer_value] || $wcer_value == "NA" } {
set wcer_value 0;
} else {
set wcer_value $wcer_value
}
if { $worst_case_eff_res <= $wcer_value} {
set worst_case_eff_res $wcer_value;
} else {
set worst_case_eff_res $worst_case_eff_res;
}

}
set wcer($session) $worst_case_eff_res;

#Finding Worst Power and Ground Drop
set worst_power_drop  [set ir_summary_y_${session}(1)];
set worst_ground_drop [set ir_summary_y_${session}(2)];

if {[regexp {([A-Za-z]+) +([a-z]+)} $worst_power_drop] || $worst_power_drop == "NA" } {
set worst_power_drop 0;
} else {
set worst_power_drop $worst_power_drop
}

if {[regexp {([A-Za-z]+) +([a-z]+)} $worst_ground_drop] || $worst_ground_drop == "NA" } {
set worst_ground_drop 0;
} else {
set worst_ground_drop $worst_ground_drop
}

set wpd($session) $worst_power_drop;
set wgd($session) $worst_ground_drop;

#Finding Worst METAL and Via EM Percentage

set worst_metal_perc [set em_${session}(1)];
set worst_via_perc  [set em_${session}(3)];

regsub -all "Worst Metal EM Violation %" $worst_metal_perc "" worst_metal_perc
regsub -all "Worst Via EM Violation %" $worst_via_perc "" worst_via_perc

if {[regexp {([A-Za-z]+) +([a-z]+)} $worst_metal_perc] || $worst_metal_perc == "NA" } {
set worst_metal_perc 0;
} else {
set worst_metal_perc $worst_metal_perc
}

if {[regexp {([A-Za-z]+) +([a-z]+)} $worst_via_perc] || $worst_via_perc == "NA" } {
set worst_via_perc 0;
} else {
set worst_via_perc $worst_via_perc
}

set mep($session) $worst_metal_perc
set vep($session) $worst_via_perc

set md_weight 0.16666666666
set power_weight 0.16666666666
set wcr_weight 0.16666666666
set wcer_weight 0.16666666666
set drop_weight 0.16666666666
set em_weight 0.16666666666

if {$avg_metal_density < 1 } {
set $avg_metal_density 1
}
if {$total_power < 1} {
set total_power 1;
}
if {$worst_case_res < 1} {
set worst_case_res 1;
}
if {$worst_case_eff_res < 1} {
set worst_case_eff_res 1;
}

if {$worst_power_drop < 1 } {
set worst_power_drop 1;
}

if {$worst_ground_drop < 1 } {
set worst_ground_drop 1;
}

if {$worst_metal_perc < 1 } {
set worst_metal_perc 1;
}

if {$worst_via_perc < 1 } {
set worst_via_perc 1;
}

#Finding Session Un Normalized Figure of Merit Index
set md_i [expr $md_weight*$avg_metal_density];
set power_i [expr $power_weight*$total_power];
set wcr_i [expr $wcr_weight*$worst_case_res];
set wcer_i [expr $wcer_weight*$worst_case_eff_res];
set drop [expr $worst_power_drop+$worst_ground_drop];
set drop_i [expr $drop_weight*$drop];
set em [expr $worst_metal_perc+$worst_via_perc];
set em_i [expr $em_weight*$em];

set num [expr $power_i];
set denom [expr $md_i*$wcr_i*$wcer_i*$drop_i*$em_i];

set fom_un_norm($session) [expr $num/$denom];

}
######

#Finding Normalized Figure of merit numbers
set fom_max $fom_un_norm(p);
set fom_min $fom_un_norm(p);
for {set m 0} {$m <= $session_count} {incr m} {
if { $m == 0} {
set session "p"
} else {
set session "c$m";
}

set fom $fom_un_norm($session);
if {$fom <= $fom_min } {
set fom_min $fom
} else {
set fom_min $fom_min
}

if {$fom >= $fom_max } {
set fom_max $fom
} else {
set fom_max $fom_max
}
}
set fom_max [expr $fom_max*1000000];
set fom_min [expr $fom_min*1000000];
set fom_sub [expr $fom_max-$fom_min];

set fp_open_html [open "$html_template" r];
set fp_output_write [open "$out_dir/figure_of_merit.html" w];

##Writing HTML Page 

while {[gets $fp_open_html line] >=0 } {

if { [regexp "METRIC_SUMMARY_HERE" $line]} {

for {set m 0} {$m <= $session_count} {incr m} {
if { $m == 0} {
set session "p"
} else {
set session "c$m";
}

if {$fom_sub != 0} {
set fom_un_nor [expr $fom_un_norm($session)*1000000];
set fom_un_nor_num [expr $fom_un_nor-$fom_min];
set fom_a [expr $fom_un_nor_num/$fom_sub];
set fom_norm [expr $fom_a*100];
set fom_norm_trunc [format "%.2f" $fom_norm];
} else {
set fom_norm_trunc 100
}
set row_color "";
if {$fom_norm_trunc == 100} {
set row_color "tr bgcolor=#9AFE2E";
} else {
set row_color "tr"
}
puts $fp_output_write "<$row_color>"
set key1 "_"
set key2 "summary.html"
set file "session$key1$session$key1$key2"
puts $fp_output_write "<td width=\"40px\"><a href=\"/rhe/file?fname=adsRHE/$file\">$session</a></td>"
puts $fp_output_write "<td>$md($session)</td>"
puts $fp_output_write "<td>$power($session)</td>"
puts $fp_output_write "<td>$wcr($session)</td>"
puts $fp_output_write "<td>$wcer($session)</td>"
puts $fp_output_write "<td>POWER=$wpd($session)<br>GROUND=$wgd($session)</td>"
puts $fp_output_write "<td>METAL=$mep($session)<br>VIA=$vep($session)</td>"
puts $fp_output_write "<td>$fom_norm_trunc</td>"
puts $fp_output_write "</tr>"


}

} elseif {[regexp "HEIGHT" $line]} {
set pixel_unit "px"
set h [expr 30*$session_count];
regsub "HEIGHT" $line "$h$pixel_unit" line
puts $fp_output_write $line;
} else {
puts $fp_output_write $line;
} 
}
close $fp_open_html;
close $fp_output_write;
}

##END OF FOM PROC


## DOMAIN VOLTAGE PROC
proc setup_domain_voltage_summary_html  {args} {

#Reading Arguments
if {[regexp "html_template" [lindex $args 0]]} {
set html_template  [lindex $args 1]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}
if {[regexp "results_dir" [lindex $args 2]]} {
set results_dir  [lindex $args 3]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}


if {[regexp "out_dir" [lindex $args 4]]} {
set out_dir [lindex $args 5]
} else {
error "Wrong argument. Correct usage is setup_main_html"
exit;
}

#Reading Design Parameters
set fp_open [open "$results_dir/gps_net_voltage.rpt" r];
set power_summary_count 0;
set bar_graph_x "";
set bar_graph_y "";

while { [gets $fp_open line_p] >= 0} {
if { $line_p ne "" && ![regexp "#" $line_p] } {
set power_summary_count [incr power_summary_count];
set line_split_p [split $line_p " "];
set session_power [lindex $line_split_p 0]
set session_name [lindex $line_split_p 1];

set power_session($power_summary_count) $session_power;
set power_name($power_summary_count) $session_name;

lappend bar_graph_x "\'$session_power\' \,"
lappend bar_graph_y "$session_name\, "
}
}


close $fp_open;


#Setting up main HTML Page
set fp_open_html [open "$html_template" r];
set fp_open_write_power_html [open "$out_dir/net_voltage.html" w];
regsub -all "\{" $bar_graph_x "" bar_graph_x;
regsub -all "\}" $bar_graph_x "" bar_graph_x;
regsub -all "\{" $bar_graph_y "" bar_graph_y;
regsub -all "\}" $bar_graph_y "" bar_graph_y;


while {[gets $fp_open_html line] >=0 } {

if { [regexp "DOMAIN_VOLTAGE_SUMMARY_HERE" $line]} {

for {set i 1 } {$i <= $power_summary_count} {incr i} {
puts $fp_open_write_power_html "\n"
puts $fp_open_write_power_html "<tr>"
puts $fp_open_write_power_html "<td><center>$power_session($i)</center></td>"
puts $fp_open_write_power_html "<td><center>$power_name($i)</center></td>"
puts $fp_open_write_power_html "</tr>"
puts  $fp_open_write_power_html "\n"
}

} elseif { [regexp "SESSIONS" $line]} {
puts  $fp_open_write_power_html "categories: \[$bar_graph_x]\,"
} elseif { [regexp "POWER" $line]} {
puts  $fp_open_write_power_html "data: \[$bar_graph_y]"
 }  elseif {[regexp "HEIGHT_TABLE_LAYER" $line]} {
set h [expr 25*$power_summary_count];
regsub "HEIGHT_TABLE_LAYER" $line "$h" line_new
puts $fp_open_write_power_html $line_new;
} else {
puts  $fp_open_write_power_html $line
}

}

close $fp_open_html
close $fp_open_write_power_html
}


## END OF DOMAIN VOLTAGE PROC

##Launching Explorer
proc launch_explorer {args} {

#Reading Arguments

set arg [split $args " "];
if {[regexp "design" [lindex $arg 0]]} {
set d_name [lindex $arg 1];
} else {
error "Correct usage is \"launch_explorer -design <design name> -clone_count <> -gps_run_dir <> -report_only 0|1 \" ";
}

if {[regexp "clone_count" [lindex $arg 2] ]} {
set clone_count [lindex $arg 3];
} else {
error "Correct usage is \"launch_explorer -design <design name> -clone_count <> -gps_run_dir <> -report_only 0|1 \" ";
}

if {[regexp "gps_run_dir" [lindex $arg 4]] } {
set gps_run_dir [lindex $arg 5];
} else {
error "Correct usage is \"launch_explorer -design <design name> -clone_count <> -gps_run_dir <> -report_only 0|1 \" ";
}


set flag_report_only 0;

if {[regexp "report_only" [lindex $arg 6] ]} {
set flag_report_only [lindex $arg 7];
} else {
error "Correct usage is \"launch_explorer -design <design name> -clone_count <> -gps_run_dir <> -report_only 0|1 \" ";
}
#Creating Results directory

exec mkdir -p $gps_run_dir/adsRHE/reports


#DATA COLLECTION REPORTS GENERATION
get_design_summary -gps_dir $gps_run_dir -sessions_count $clone_count -design_name $d_name -out_dir $gps_run_dir/adsRHE/reports
get_data_md_em_ss_from_all_sessions -gps_dir $gps_run_dir -clone_session_count $clone_count -design_name $d_name

get_sessions_power_summary -gps_dir $gps_run_dir  -sessions_count $clone_count -design_name $d_name -out_dir $gps_run_dir/adsRHE/reports

get_sessions_ir_summary -gps_dir $gps_run_dir  -sessions_count $clone_count -design_name $d_name -out_dir $gps_run_dir/adsRHE/reports

if {$flag_report_only == 1 } {
return;
}

#HTML REPORT GENERATION

#Step 1 :- Generate Template HTMLS

set main_html_page_template  { 


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>RedHawk-GPS Explorer-TOP</title>
<!-- CSS Style Sheets-->
<link rel="stylesheet" href="/rhe/file?fname=styles/style.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=styles/ui.jquery.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/flexigrid/flexigrid/flexigrid.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/flexigrid/flexigrid/verticaltables.css" type="text/css" media="screen" />
<link rel="stylesheet" href="/rhe/file?fname=js/colorpicker/colorpicker.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=graph.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/jqModal/jqModal.css" type="text/css" media="screen">

<!-- END - CSS Style Sheets-->
<!-- Javascript files -->
<script src="/rhe/file?fname=js/sorttable.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/jquery.min.custom.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery-ui-personalized-1.6rc6.min.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/interface.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery.jimagetags.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery.corners.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/flexigrid.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/selectToUISlider.jQuery.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/colorpicker.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jqModal.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/jschart.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/highcharts.js" type="text/javascript"></script>


        <script src="/rhe/file?fname=raphael.js" type="text/javascript" charset="utf-8"></script>
        
        <script src="/rhe/file?fname=pie.js" type="text/javascript" charset="utf-8"></script>
     
<!-- END - Javascript files -->
</head>


<body>
<div id="container">
  <div id="header">
    <h1 class="prodt-title left"><img src="/rhe/file?fname=rh_gps_exploer_logo.png"/></h1>

    <div id="logo" class="right"><img    style="margin-left:-244px;"    src="/rhe/file?fname=logo.png" alt="Apache Design Solutions"></div>
    <div class="clear-left"></div>
    <div id="main-nav">
      <ul>

      </ul>
    </div>
    <div id="toolbar" style="color:#f6cf47">
      <ul>
        <li style="color:black"><a onclick="window.history.back();" title="Go back to previous page"><img src="/rhe/file?fname=icon-back.png"  alt="Back" style="margin-top:5px;"> Back</a></li>
        <li style="color:black"><a onclick="window.history.forward();" title="Go forward one page">Forward <img src="/rhe/file?fname=icon-forward.png"  alt="Forward" style="margin-top:5px;"></a></li>
      </ul>
    </div>
  </div>
  <!--<div id="header">-->
  <div id="sidebar">
    <ul>
      <li class="summary active">
          <a href="/rhe/file?fname=adsRHE/index.html" title="Design Summary"><B>Design Summary</B></a>

      </li>
     <li class="summary" style="padding: 5px 2px 0px 2px;">
          &nbsp&nbsp&nbsp<b>Results Summary<BR><BR></b>
          <ul>
	  
	  <li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Grid Details</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/metal_density.html" title="Metal Density">Metal Density</a></li>
            <li class="noicon disabled">&nbsp&nbsp Track Utilization</li>
	</ul>
            	    
  
            <li class="noicon"><a style="padding:5px 35px 5px 0px" href="/rhe/file?fname=adsRHE/power_summary.html" title="Power Summary">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Power Summary</b></a></li>
	    <li class="noicon"><a style="padding:5px 35px 5px 0px" href="/rhe/file?fname=adsRHE/resistance_summary.html" title="Resistance">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Resistance</b></a></li>

<li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Static EM&IR Results</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/static_ir.html" title="IR Results">IR Results</a></li>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/em_results.html" title="EM Results">EM Results</a></li>
 </ul>
 
	<li class="noicon disabled">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Dynamic EM&IR Results</b></li>
<ul>
            <li class="noicon disabled"><a  title="Current Waveforms">&nbsp&nbsp Current Waveforms</a></li>

            <li class="noicon disabled"><a  title="EM Results">&nbsp&nbsp EM Results</a></li>	
</ul>
         
<li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Session Metrics</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/session_summary.html" title="Session Summary">Session Summary</a></li>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/figure_of_merit.html" title="Metric Comparision">Metric Comparision</a></li>
 </ul>

    </ul>
  </div>
  <!--<div id="sidebar">-->

  <div id="sidebarshow" class="left"><img src="/rhe/file?fname=toggleLeft.gif" id="lateralClickImg"/></div>
  <div id="content" class="left">
    <ul id="breadcrumps"></ul>


 <script type="text/javascript">
    
  
      $(document).ready(function(){
        $("#tabs").tabs();
      });
    </script>

    
<div id="summary">


 <script type="text/javascript">
          $(function(){
            //Scrollable Table
  	        $('.tabledata2 table').flexigrid({
              showToggleBtn:false,
              height:220,
              width:"505",
              resizable:false,
              title:"Design Summary",
            });
          });
        </script>
        <div class="tabledata2 min-item2">

          <table>
            <thead>
              <tr>
              </tr>
            </thead>
            <tbody>




  <tr>
  <td align="left">Design Name</td>
<!-- DESIGNNAME -->    
</tr>

  <tr>
  <td>Design Size</td>
 <!-- DESIGNSIZE -->    
</tr>

  <tr>
  <td>Number of voltage domains</td>
 <!-- NUMBER_VOLTAGE_DOMAINS -->    
</tr>

  <tr>
  <td>Number of Layers</td>
 <!-- NUMBER_LAYERS -->    
</tr>

  <tr>
  <td>Number of sessions</td>
 <!-- NUMBER_SESSIONS -->    
</tr>

  <tr>
  <td>Total Run Time</td>
 <!-- RUN_TIME -->    
</tr>
  <tr>
  <td>Peak Memory</td>
  <!--  MEMORY  -->    
    </tr>
  <tr>
  <td>Run Area</td>
  <!--  RUN_AREA -->    
</tr>

  
  </tbody>
          </table>
        </div>

<div class="verticaltable-container min-item">
      <h3>Chip Layout</h3>
      <div class="imageholder"><img src="/rhe/file?fname=chip_layout.jpeg" width=400.00" height="298" alt="Chip layout"></div>
    </div>
  </div>




					 <div class="clear"></div>




</div>
<!-- <div id="container"> -->
</body>
</html>

}


set domain_voltage_html_page { 

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>RedHawk-GPS Explorer-TOP</title>
<!-- CSS Style Sheets-->
<link rel="stylesheet" href="/rhe/file?fname=styles/style.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=styles/ui.jquery.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/flexigrid/flexigrid/flexigrid.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/flexigrid/flexigrid/verticaltables.css" type="text/css" media="screen" />
<link rel="stylesheet" href="/rhe/file?fname=js/colorpicker/colorpicker.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=graph.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/jqModal/jqModal.css" type="text/css" media="screen">

<!-- END - CSS Style Sheets-->
<!-- Javascript files -->
<script src="/rhe/file?fname=js/sorttable.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/jquery.min.custom.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery-ui-personalized-1.6rc6.min.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/interface.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery.jimagetags.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery.corners.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/flexigrid.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/selectToUISlider.jQuery.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/colorpicker.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jqModal.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/jschart.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/highcharts.js" type="text/javascript"></script>


        <script src="/rhe/file?fname=raphael.js" type="text/javascript" charset="utf-8"></script>
        
        <script src="/rhe/file?fname=pie.js" type="text/javascript" charset="utf-8"></script>
     
<!-- END - Javascript files -->
</head>


<body>
<div id="container">
  <div id="header">
    <h1 class="prodt-title left"><img src="/rhe/file?fname=rh_gps_exploer_logo.png"/></h1>

    <div id="logo" class="right"><img    style="margin-left:-244px;"    src="/rhe/file?fname=logo.png" alt="Apache Design Solutions"></div>
    <div class="clear-left"></div>
    <div id="main-nav">
      <ul>

      </ul>
    </div>
    <div id="toolbar">
      <ul>
        <li><a onclick="window.history.back();" title="Go back to previous page"><img src="/rhe/file?fname=icon-back.png"  alt="Back" style="margin-top:5px;"> Back</a></li>
        <li><a onclick="window.history.forward();" title="Go forward one page">Forward <img src="/rhe/file?fname=icon-forward.png"  alt="Forward" style="margin-top:5px;"></a></li>
      </ul>
    </div>
  </div>
  <!--<div id="header">-->
  <div id="sidebar">
    <ul>
      <li class="summary active">
          <a href="/rhe/file?fname=adsRHE/index.html" title="Design Summary"><B>Design Summary</B></a>

      </li>
     <li class="summary" style="padding: 5px 2px 0px 2px;">
          &nbsp&nbsp&nbsp<b>Results Summary<BR><BR></b>
          <ul>
	  
	  <li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Grid Details</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/metal_density.html" title="Metal Density">Metal Density</a></li>
            <li class="noicon disabled">&nbsp&nbsp Track Utilization</li>
	</ul>
            	    
  
            <li class="noicon"><a style="padding:5px 35px 5px 0px" href="/rhe/file?fname=adsRHE/power_summary.html" title="Power Summary">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Power Summary</b></a></li>
	    <li class="noicon"><a style="padding:5px 35px 5px 0px" href="/rhe/file?fname=adsRHE/resistance_summary.html" title="Resistance">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Resistance</b></a></li>

<li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Static EM&IR Results</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/static_ir.html" title="IR Results">IR Results</a></li>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/em_results.html" title="EM Results">EM Results</a></li>
 </ul>
 
	<li class="noicon disabled">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Dynamic EM&IR Results</b></li>
<ul>
            <li class="noicon disabled"><a  title="Current Waveforms">&nbsp&nbsp Current Waveforms</a></li>

            <li class="noicon disabled"><a  title="EM Results">&nbsp&nbsp EM Results</a></li>	
</ul>

<li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Session Metrics</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/session_summary.html" title="Session Summary">Session Summary</a></li>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/figure_of_merit.html" title="Metric Comparision">Metric Comparision</a></li>
 </ul>




    </ul>
  </div>
  <!--<div id="sidebar">-->

  <div id="sidebarshow" class="left"><img src="/rhe/file?fname=toggleLeft.gif" id="lateralClickImg"/></div>
  <div id="content" class="left">
    <ul id="breadcrumps"></ul>


 <script type="text/javascript">
    
  
      $(document).ready(function(){
        $("#tabs").tabs();
      });
    </script>

    <div id="tabs" class="min-item" style="width:620px;height:"auto";">


     <ul>
          <li><a href="#summary"><span>Domain voltage Info</span></a></li>
	  
</ul>



<div id="summary">

 <script type="text/javascript">
          $(function(){
            //Scrollable Table
  	        $('.tabledata2 table').flexigrid({
              showToggleBtn:false,
              height:HEIGHT_TABLE_LAYER,
              width:"325",
              resizable:false,
              <!--title:"Summary",-->
            });
          });
        </script>
        <div class="tabledata2 min-item2">

          <table>
            <thead>
              <tr>
                <th width="250"><center>Domain</center></th>
                <th width="50"><center>Voltage</center></th>
              </tr>
            </thead>
            <tbody>

<!-- DOMAIN_VOLTAGE_SUMMARY_HERE -->
  
  </tbody>
          </table>
        </div>

</div>


</div>
<!-- <div id="container"> -->
</body>
</html>

}

set  metal_density_page_html { 

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>RedHawk-GPS Explorer-TOP</title>
<!-- CSS Style Sheets-->
<link rel="stylesheet" href="/rhe/file?fname=styles/style.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=styles/ui.jquery.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/flexigrid/flexigrid/flexigrid.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/flexigrid/flexigrid/verticaltables.css" type="text/css" media="screen" />
<link rel="stylesheet" href="/rhe/file?fname=js/colorpicker/colorpicker.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=graph.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/jqModal/jqModal.css" type="text/css" media="screen">

<!-- END - CSS Style Sheets-->
<!-- Javascript files -->
<script src="/rhe/file?fname=js/sorttable.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/jquery.min.custom.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery-ui-personalized-1.6rc6.min.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/interface.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery.jimagetags.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery.corners.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/flexigrid.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/selectToUISlider.jQuery.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/colorpicker.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jqModal.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/jschart.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/highcharts.js" type="text/javascript"></script>


        <script src="/rhe/file?fname=raphael.js" type="text/javascript" charset="utf-8"></script>
        
        <script src="/rhe/file?fname=pie.js" type="text/javascript" charset="utf-8"></script>
     
<!-- END - Javascript files -->
</head>


<body>
<div id="container">
  <div id="header">
    <h1 class="prodt-title left"><img src="/rhe/file?fname=rh_gps_exploer_logo.png"/></h1>

    <div id="logo" class="right"><img    style="margin-left:-244px;"    src="/rhe/file?fname=logo.png" alt="Apache Design Solutions"></div>
    <div class="clear-left"></div>
    <div id="main-nav">
      <ul>

      </ul>
    </div>
    <div id="toolbar">
      <ul>
        <li><a onclick="window.history.back();" title="Go back to previous page"><img src="/rhe/file?fname=icon-back.png"  alt="Back" style="margin-top:5px;"> Back</a></li>
        <li><a onclick="window.history.forward();" title="Go forward one page">Forward <img src="/rhe/file?fname=icon-forward.png"  alt="Forward" style="margin-top:5px;"></a></li>
      </ul>
    </div>
  </div>
  <!--<div id="header">-->
  <div id="sidebar">
    <ul>
      <li class="summary">
          <a href="/rhe/file?fname=adsRHE/index.html" title="Design Summary"><B>Design Summary</B></a>

      </li>
     <li class="summary" style="padding: 5px 2px 0px 2px;">
          &nbsp&nbsp&nbsp<b>Results Summary<BR><BR></b>
          <ul>
	  
	  <li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Grid Details</b></li>
<ul>
            <li class="noicon active"><a href="/rhe/file?fname=adsRHE/metal_density.html" title="Metal Density">Metal Density</a></li>
            <li class="noicon disabled">&nbsp&nbsp Track Utilization</li>
	</ul>
            	    
  
            <li class="noicon"><a style="padding:5px 35px 5px 0px" href="/rhe/file?fname=adsRHE/power_summary.html" title="Power Summary">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Power Summary</b></a></li>
	    <li class="noicon"><a style="padding:5px 35px 5px 0px" href="/rhe/file?fname=adsRHE/resistance_summary.html" title="Resistance">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Resistance</b></a></li>

<li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Static EM&IR Results</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/static_ir.html" title="IR Results">IR Results</a></li>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/em_results.html" title="EM Results">EM Results</a></li>
 </ul>
 
	<li class="noicon disabled">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Dynamic EM&IR Results</b></li>
<ul>
            <li class="noicon disabled"><a  title="Current Waveforms">&nbsp&nbsp Current Waveforms</a></li>

            <li class="noicon disabled"><a  title="EM Results">&nbsp&nbsp EM Results</a></li>	
</ul>

<li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Session Metrics</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/session_summary.html" title="Session Summary">Session Summary</a></li>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/figure_of_merit.html" title="Metric Comparision">Metric Comparision</a></li>
 </ul>





    </ul>
  </div>
  <!--<div id="sidebar">-->

  <div id="sidebarshow" class="left"><img src="/rhe/file?fname=toggleLeft.gif" id="lateralClickImg"/></div>
  <div id="content" class="left">
    <ul id="breadcrumps"></ul>


 <script type="text/javascript">
    
  
      $(document).ready(function(){
        $("#tabs").tabs();
      });
    </script>

    <div id="tabs" class="min-item" style="width:620px;height:"auto";">


     <ul>
          <li><a href="#summary"><span>Summary</span></a></li>
          <li><a href="#layer_specific"><span>Layer Specific</span></a></li>
	  
</ul>



<div id="summary">



 <script type="text/javascript">
          $(function(){
            //Scrollable Table
  	        $('.tabledata1 table').flexigrid({
              showToggleBtn:false,
              height:200,
              width:"320",
              resizable:false,
              title:"Summary",
            });
          });
        </script>
        <div class="tabledata1">

          <table class="sortable">
            <thead>
              <tr>
                <th width="50"><center>Session</center></th>
                <th width="250"><center>Average Metal Density(%)</center></th>
              </tr>
            </thead>
            <tbody>



<!-- DENSITY_SUMMARY_HERE -->
  
  </tbody>
          </table>

</div>
<div class="min-item" style= "position: relative; top:6px">
     <!-- <h3>Average Metal Density</h3> -->
<div id="container1" class="highcharts-container" style="height:HEIGHT_SUMMARY; width: 500px;position: relative; left:0px; top:0px">
</div>
<div class="min-item">

<!-- Adding Bar Graph -->




					<script type="text/javascript">

		var chart;
		$(document).ready(function() {
			chart = new Highcharts.Chart({
					chart: {
					renderTo: 'container1',
					defaultSeriesType: 'bar',
					marginLeft: 25,
					marginTop: 5,
					borderColor: "#FFFFFF"
					},
					title: {
					text: ''
				},
				
				xAxis: {
				<!--SESSIONS-->
					title: {											
						text: null
					}
				},
				yAxis: {
					min: 0,
					title: {
						text: 'Avg Metal Density (%)',
					}
				},
				tooltip: {
					enabled:false
				},
				plotOptions: {
					bar:  {
    					animation: false,
					borderWidth: 0,
					pointWidth:5,
					shadow: false
				  }
				},
				legend: {
					enabled:false,
					layout: 'vertical',
					align: 'top',
					verticalAlign: 'right',
					x: -100,
					y: 100,
					borderWidth: 0,
					backgroundColor: '#FFFFFF'
				},
				credits: {
					enabled: false
				},
			        series: [{
					name: 'Average Metal Density(%)',
					<!--AVG_MD-->		
				}]
			});
			
			
		});
	</script>

<!-- End of Tables -->

</div>
</div>
</div>


<div id="layer_specific">



 <script type="text/javascript">
          $(function(){
            //Scrollable Table
  	        $('.tabledata2 table').flexigrid({
              showToggleBtn:false,
              height:HEIGHT_TABLE_LAYER,
              width:"286.5",
              resizable:false,
              title:"Layer Specific Metal Density Summary",
            });
          });
        </script>
        <div class="tabledata2">

          <table class="sortable">
            <thead>
              <tr>
                <th width="50"><center>Layer</center></th>
                <th width="150"><center>Best-Metal Density(%)</center></th>
                <th width="50"><center>Session</center></th>
              </tr>
            </thead>
            <tbody>


<!--  LAYER_SPECIFIC_SUMMARY_HERE -->
  
  </tbody>
          </table>
</div>

<!-- Adding Bar Graph -->
<div class="min-item17" style= "position: relative; top:6px">
    <!--  <h3>Layer Specific Worst Metal Density</h3> -->
<div id="container2" class="highcharts-container" style="height:HEIGHT_LAYER; width: 500px;position: relative; left:0px; top: 0px">
</div>

<div class="min-item5">



					<script type="text/javascript">

		var chart1;
		$(document).ready(function() {
			chart1 = new Highcharts.Chart({
					chart: {
					renderTo: 'container2',
					defaultSeriesType: 'bar',
					marginLeft: 35,
					marginTop: 5,
					borderColor: "#FFFFFF"
					},
					title: {
					text: ''
				},
				
				xAxis: {
				<!--LAYERS-->
					title: {											
						text: null
					}
				},
				yAxis: {
					min: 0,
					title: {
						text: 'Metal Density (%)',
					}
				},
				tooltip: {
					enabled:false
				},
				plotOptions: {
					bar:  {
    					animation: false,
					borderWidth: 0,
					pointWidth:15,
					shadow: false
				  }
				},
				legend: {
					enabled:false,
					layout: 'vertical',
					align: 'top',
					verticalAlign: 'right',
					x: -100,
					y: 100,
					borderWidth: 0,
					backgroundColor: '#FFFFFF'
				},
				credits: {
					enabled: false
				},
			        series: [{
					name: 'Metal Density(%)',
					<!--WORST_MD-->		
				}]
			});
			
			
		});
	</script>
</div>
</div>
</div>
<!-- End of Tables -->

</div>
<!-- <div id="container"> -->
</body>
</html>


}

set layer_specific_metal_density_page_html { 

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>RedHawk-GPS Explorer-TOP</title>
<!-- CSS Style Sheets-->
<link rel="stylesheet" href="/rhe/file?fname=styles/style.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=styles/ui.jquery.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/flexigrid/flexigrid/flexigrid.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/flexigrid/flexigrid/verticaltables.css" type="text/css" media="screen" />
<link rel="stylesheet" href="/rhe/file?fname=js/colorpicker/colorpicker.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=graph.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/jqModal/jqModal.css" type="text/css" media="screen">

<!-- END - CSS Style Sheets-->
<!-- Javascript files -->
<script src="/rhe/file?fname=js/sorttable.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/jquery.min.custom.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery-ui-personalized-1.6rc6.min.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/interface.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery.jimagetags.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery.corners.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/flexigrid.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/selectToUISlider.jQuery.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/colorpicker.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jqModal.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/jschart.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/highcharts.js" type="text/javascript"></script>


        <script src="/rhe/file?fname=raphael.js" type="text/javascript" charset="utf-8"></script>
        
        <script src="/rhe/file?fname=pie.js" type="text/javascript" charset="utf-8"></script>
     
<!-- END - Javascript files -->
</head>


<body>
<div id="container">
  <div id="header">
    <h1 class="prodt-title left"><img src="/rhe/file?fname=rh_gps_exploer_logo.png"/></h1>

    <div id="logo" class="right"><img    style="margin-left:-244px;"    src="/rhe/file?fname=logo.png" alt="Apache Design Solutions"></div>
    <div class="clear-left"></div>
    <div id="main-nav">
      <ul>

      </ul>
    </div>
    <div id="toolbar">
      <ul>
        <li><a onclick="window.history.back();" title="Go back to previous page"><img src="/rhe/file?fname=icon-back.png"  alt="Back" style="margin-top:5px;"> Back</a></li>
        <li><a onclick="window.history.forward();" title="Go forward one page">Forward <img src="/rhe/file?fname=icon-forward.png"  alt="Forward" style="margin-top:5px;"></a></li>
      </ul>
    </div>
  </div>
  <!--<div id="header">-->
  <div id="sidebar">
    <ul>
      <li class="summary">
          <a href="/rhe/file?fname=adsRHE/index.html" title="Design Summary"><B>Design Summary</B></a>

      </li>
     <li class="summary" style="padding: 5px 2px 0px 2px;">
          &nbsp&nbsp&nbsp<b>Results Summary<BR><BR></b>
          <ul>
	  
	  <li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Grid Details</b></li>
<ul>
            <li class="noicon active"><a href="/rhe/file?fname=adsRHE/metal_density.html" title="Metal Density">Metal Density</a></li>
            <li class="noicon disabled">&nbsp&nbsp Track Utilization</li>
	</ul>
            	    
  
            <li class="noicon"><a style="padding:5px 35px 5px 0px" href="/rhe/file?fname=adsRHE/power_summary.html" title="Power Summary">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Power Summary</b></a></li>
	    <li class="noicon"><a style="padding:5px 35px 5px 0px" href="/rhe/file?fname=adsRHE/resistance_summary.html" title="Resistance">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Resistance</b></a></li>

<li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Static EM&IR Results</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/static_ir.html" title="IR Results">IR Results</a></li>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/em_results.html" title="EM Results">EM Results</a></li>
 </ul>
 
	<li class="noicon disabled">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Dynamic EM&IR Results</b></li>
<ul>
            <li class="noicon disabled"><a  title="Current Waveforms">&nbsp&nbsp Current Waveforms</a></li>

            <li class="noicon disabled"><a  title="EM Results">&nbsp&nbsp EM Results</a></li>	
</ul>
<li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Session Metrics</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/session_summary.html" title="Session Summary">Session Summary</a></li>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/figure_of_merit.html" title="Metric Comparision">Metric Comparision</a></li>
 </ul>


    </ul>
  </div>
  <!--<div id="sidebar">-->

  <div id="sidebarshow" class="left"><img src="/rhe/file?fname=toggleLeft.gif" id="lateralClickImg"/></div>
  <div id="content" class="left">
    <ul id="breadcrumps"></ul>


 <script type="text/javascript">
    
  
      $(document).ready(function(){
        $("#tabs").tabs();
      });
    </script>

    <div id="tabs" class="min-item" style="width:620px;height:"auto";">


     <ul>
          <li><a href="#summary"><span>Summary</span></a></li>
	  
</ul>



<div id="summary">


 <script type="text/javascript">
          $(function(){
            //Scrollable Table
  	        $('.tabledata1 table').flexigrid({
              showToggleBtn:false,
              height:200,
              width:"250",
              resizable:false,
              <!-- DOMAIN_TITLE -->
            });
          });
        </script>
        <div class="tabledata1">

          <table class="sortable">
            <thead>
              <tr>
                <th width="50"><center>Session</center></th>
                <th width="157"><center>Worst Metal Density(%)</center></th>
              </tr>
            </thead>
            <tbody>

<!-- DOMAIN_DROP_HERE -->

  
  </tbody>
          </table>
        </div>
<div class="min-item" style= "position: relative; top:6px">
     <!-- <h3>Sessions Worst Drop</h3> -->
<div id="container1" class="highcharts-container" style="height:HEIGHT_HERE; width: 500px;position: relative; left:0px; top:0px">
</div>
<div class="min-item">

<!-- Adding Bar Graph -->




					<script type="text/javascript">

		var chart;
		$(document).ready(function() {
			chart = new Highcharts.Chart({
					chart: {
					renderTo: 'container1',
					defaultSeriesType: 'bar',
					marginLeft: 25,
					marginTop: 5,
					borderColor: "#FFFFFF"
					},
					title: {
					text: ''
				},
				
				xAxis: {
				<!-- SESSIONS -->
					title: {											
						text: null
					}
				},
				yAxis: {
					min: 0,
					title: {
						text: 'Worst Metal Density (%)',
					}
				},
				tooltip: {
					enabled:false
				},
				plotOptions: {
					bar:  {
    					animation: false,
					borderWidth: 0,
					pointWidth:5,
					shadow: false
				  }
				},
				legend: {
					enabled:false,
					layout: 'vertical',
					align: 'top',
					verticalAlign: 'right',
					x: -100,
					y: 100,
					borderWidth: 0,
					backgroundColor: '#FFFFFF'
				},
				credits: {
					enabled: false
				},
			        series: [{
					name: 'Drop(mV)',
					<!-- DROP_TABLE -->		
				}]
			});
			
			
		});
	</script>

<!-- End of Tables -->

</div>
</div>
</div>

</div>
<!-- <div id="container"> -->
</body>
</html>

}

set power_summary_page_html { 


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>RedHawk-GPS Explorer-TOP</title>
<!-- CSS Style Sheets-->
<link rel="stylesheet" href="/rhe/file?fname=styles/style.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=styles/ui.jquery.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/flexigrid/flexigrid/flexigrid.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/flexigrid/flexigrid/verticaltables.css" type="text/css" media="screen" />
<link rel="stylesheet" href="/rhe/file?fname=js/colorpicker/colorpicker.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=graph.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/jqModal/jqModal.css" type="text/css" media="screen">

<!-- END - CSS Style Sheets-->
<!-- Javascript files -->
<script src="/rhe/file?fname=js/sorttable.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/jquery.min.custom.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery-ui-personalized-1.6rc6.min.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/interface.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery.jimagetags.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery.corners.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/flexigrid.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/selectToUISlider.jQuery.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/colorpicker.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jqModal.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/jschart.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/highcharts.js" type="text/javascript"></script>


        <script src="/rhe/file?fname=raphael.js" type="text/javascript" charset="utf-8"></script>
        
        <script src="/rhe/file?fname=pie.js" type="text/javascript" charset="utf-8"></script>
     
<!-- END - Javascript files -->
</head>


<body>
<div id="container">
  <div id="header">
    <h1 class="prodt-title left"><img src="/rhe/file?fname=rh_gps_exploer_logo.png"/></h1>

    <div id="logo" class="right"><img    style="margin-left:-244px;"    src="/rhe/file?fname=logo.png" alt="Apache Design Solutions"></div>
    <div class="clear-left"></div>
    <div id="main-nav">
      <ul>

      </ul>
    </div>
    <div id="toolbar">
      <ul>
        <li><a onclick="window.history.back();" title="Go back to previous page"><img src="/rhe/file?fname=icon-back.png"  alt="Back" style="margin-top:5px;"> Back</a></li>
        <li><a onclick="window.history.forward();" title="Go forward one page">Forward <img src="/rhe/file?fname=icon-forward.png"  alt="Forward" style="margin-top:5px;"></a></li>
      </ul>
    </div>
  </div>
  <!--<div id="header">-->
  <div id="sidebar">
    <ul>
      <li class="summary">
          <a href="/rhe/file?fname=adsRHE/index.html" title="Design Summary"><B>Design Summary</B></a>

      </li>
     <li class="summary" style="padding: 5px 2px 0px 2px;">
          &nbsp&nbsp&nbsp<b>Results Summary<BR><BR></b>
          <ul>
	  
	  <li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Grid Details</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/metal_density.html" title="Metal Density">Metal Density</a></li>
            <li class="noicon disabled">&nbsp&nbsp Track Utilization</li>
	</ul>
            	    
  
            <li class="noicon active"><a style="padding:5px 35px 5px 0px" href="/rhe/file?fname=adsRHE/power_summary.html" title="Power Summary">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Power Summary</b></a></li>
	    <li class="noicon"><a style="padding:5px 35px 5px 0px" href="/rhe/file?fname=adsRHE/resistance_summary.html" title="Resistance">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Resistance</b></a></li>

<li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Static EM&IR Results</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/static_ir.html" title="IR Results">IR Results</a></li>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/em_results.html" title="EM Results">EM Results</a></li>
 </ul>
 
	<li class="noicon disabled">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Dynamic EM&IR Results</b></li>
<ul>
            <li class="noicon disabled"><a  title="Current Waveforms">&nbsp&nbsp Current Waveforms</a></li>

            <li class="noicon disabled"><a title="EM Results">&nbsp&nbsp EM Results</a></li>	
</ul>

<li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Session Metrics</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/session_summary.html" title="Session Summary">Session Summary</a></li>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/figure_of_merit.html" title="Metric Comparision">Metric Comparision</a></li>
 </ul>




    </ul>
  </div>
  <!--<div id="sidebar">-->

  <div id="sidebarshow" class="left"><img src="/rhe/file?fname=toggleLeft.gif" id="lateralClickImg"/></div>
  <div id="content" class="left">
    <ul id="breadcrumps"></ul>


 <script type="text/javascript">
    
  
      $(document).ready(function(){
        $("#tabs").tabs();
      });
    </script>

    <div id="tabs" class="min-item" style="width:620px;height:"auto";">


     <ul>
          <li><a href="#summary"><span>Power Summary</span></a></li>
	  
</ul>



<div id="summary">

 <script type="text/javascript">
          $(function(){
            //Scrollable Table
  	        $('.tabledata2 table').flexigrid({
              showToggleBtn:false,
              height:200,
              width:"250",
              resizable:false,
              title:"Summary",
            });
          });
        </script>
        <div class="tabledata2 min-item2">

          <table class="sortable">
            <thead>
              <tr>
                <th width="50"><center>Session</center></th>
                <th width="157"><center>Power (mW)</center></th>
              </tr>
            </thead>
            <tbody>

<!-- POWER_SUMMARY_HERE -->
  
  </tbody>
          </table>
        </div>

<!-- Adding Bar Graph -->
<div class="min-item" style= "position: relative; top:6px">
      <!--<h3>Power Summary</h3>-->

<div id="container2" class="highcharts-container" style="height:HEIGHT_HERE; width: 500px;position: relative; left:0px; top:0px"></div>
<div class="min-item">

					<script type="text/javascript">

		var chart2;
		$(document).ready(function() {
			chart2 = new Highcharts.Chart({
					chart: {
					renderTo: 'container2',
					defaultSeriesType: 'bar',
					marginLeft: 25,
					marginTop: 5,
					borderColor: "#FFFFFF"
					},
					title: {
					text: ''
				},
				
				xAxis: {
				<!--SESSIONS-->
					title: {											
						text: null
					}
				},
				yAxis: {
					min: 0,
					title: {
						text: 'Power (mW)',
					}
				},
				tooltip: {
					enabled:false
				},
				plotOptions: {
					bar:  {
    					animation: false,
					borderWidth: 0,
					pointWidth:5,
					shadow: false
				  }
				},
				legend: {
					enabled:false,
					layout: 'vertical',
					align: 'top',
					verticalAlign: 'right',
					x: -100,
					y: 100,
					borderWidth: 0,
					backgroundColor: '#FFFFFF'
				},
				credits: {
					enabled: false
				},
			        series: [{
					name: 'Power(mW)',
					<!--POWER-->		
				}]
			});
			
			
		});
	</script>

<!-- End of Tables -->


</div>
</div>
</div>


</div>
<!-- <div id="container"> -->
</body>
</html>

}


set resistance_page_html { 


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>RedHawk-GPS Explorer-TOP</title>
<!-- CSS Style Sheets-->
<link rel="stylesheet" href="/rhe/file?fname=styles/style.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=styles/ui.jquery.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/flexigrid/flexigrid/flexigrid.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/flexigrid/flexigrid/verticaltables.css" type="text/css" media="screen" />
<link rel="stylesheet" href="/rhe/file?fname=js/colorpicker/colorpicker.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=graph.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/jqModal/jqModal.css" type="text/css" media="screen">

<!-- END - CSS Style Sheets-->
<!-- Javascript files -->
<script src="/rhe/file?fname=js/sorttable.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/jquery.min.custom.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery-ui-personalized-1.6rc6.min.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/interface.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery.jimagetags.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery.corners.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/flexigrid.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/selectToUISlider.jQuery.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/colorpicker.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jqModal.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/jschart.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/highcharts.js" type="text/javascript"></script>


        <script src="/rhe/file?fname=raphael.js" type="text/javascript" charset="utf-8"></script>
        
        <script src="/rhe/file?fname=pie.js" type="text/javascript" charset="utf-8"></script>
     
<!-- END - Javascript files -->
</head>


<body>
<div id="container">
  <div id="header">
    <h1 class="prodt-title left"><img src="/rhe/file?fname=rh_gps_exploer_logo.png"/></h1>

    <div id="logo" class="right"><img    style="margin-left:-244px;"    src="/rhe/file?fname=logo.png" alt="Apache Design Solutions"></div>
    <div class="clear-left"></div>
    <div id="main-nav">
      <ul>

      </ul>
    </div>
    <div id="toolbar">
      <ul>
        <li><a onclick="window.history.back();" title="Go back to previous page"><img src="/rhe/file?fname=icon-back.png"  alt="Back" style="margin-top:5px;"> Back</a></li>
        <li><a onclick="window.history.forward();" title="Go forward one page">Forward <img src="/rhe/file?fname=icon-forward.png"  alt="Forward" style="margin-top:5px;"></a></li>
      </ul>
    </div>
  </div>
  <!--<div id="header">-->
  <div id="sidebar">
    <ul>
      <li class="summary">
          <a href="/rhe/file?fname=adsRHE/index.html" title="Design Summary"><B>Design Summary</B></a>

      </li>
     <li class="summary" style="padding: 5px 2px 0px 2px;">
          &nbsp&nbsp&nbsp<b>Results Summary<BR><BR></b>
          <ul>
	  
	  <li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Grid Details</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/metal_density.html" title="Metal Density">Metal Density</a></li>
            <li class="noicon disabled">&nbsp&nbsp Track Utilization</li>
	</ul>
            	    
  
            <li class="noicon"><a style="padding:5px 35px 5px 0px" href="/rhe/file?fname=adsRHE/power_summary.html" title="Power Summary">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Power Summary</b></a></li>
	    <li class="noicon active"><a style="padding:5px 35px 5px 0px" href="/rhe/file?fname=adsRHE/resistance_summary.html" title="Resistance">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Resistance</b></a></li>

<li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Static EM&IR Results</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/static_ir.html" title="IR Results">IR Results</a></li>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/em_results.html" title="EM Results">EM Results</a></li>
 </ul>
 
	<li class="noicon disabled">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Dynamic EM&IR Results</b></li>
<ul>
            <li class="noicon disabled"><a title="Current Waveforms">&nbsp&nbsp Current Waveforms</a></li>

            <li class="noicon disabled"><a  title="EM Results">&nbsp&nbsp EM Results</a></li>	
</ul>

<li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Session Metrics</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/session_summary.html" title="Session Summary">Session Summary</a></li>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/figure_of_merit.html" title="Metric Comparision">Metric Comparision</a></li>
 </ul>




    </ul>
  </div>
  <!--<div id="sidebar">-->

  <div id="sidebarshow" class="left"><img src="/rhe/file?fname=toggleLeft.gif" id="lateralClickImg"/></div>
  <div id="content" class="left">
    <ul id="breadcrumps"></ul>


 <script type="text/javascript">
    
  
      $(document).ready(function(){
        $("#tabs").tabs();
      });
    </script>

    <div id="tabs" class="min-item" style="width:620px;height:"auto";">


     <ul>
          <li><a href="#worst_case_res"><span>Worst Case Resistance and Effective Resistance</span></a></li>
         <!-- <li><a href="#worst_case_eff_res"><span>Worst Case Effective Resistance</span></a></li> -->
</ul>



<div id="worst_case_res">


 <script type="text/javascript">
          $(function(){
            //Scrollable Table
  	        $('.tabledata1 table').flexigrid({
              showToggleBtn:false,
              height:200,
              width:"613",
              resizable:false,
              title:"Worst Case Resistance and Effective Resistance",
            });
          });
        </script>
        <div class="tabledata1">

          <table class="sortable">
            <thead>
              <tr>
                <th width="50"><center>Session</center></th>
                <th width="150"><center>Worst case R(Ohm)</center></th>
                <th width="150"><center>Worst case Eff R(Ohm)</center></th>
                <th width="200"><center>WIRE/VIA/SWITCH Contribution</center></th>
              </tr>
            </thead>
            <tbody>

<!-- WORST_CASE_R_HERE -->

  
  </tbody>
          </table>
        </div>
<div class="min-item" style= "position: relative; top:6px">
     <!-- <h3>Worst case resistance</h3>-->
<div id="container1" class="highcharts-container" style="height:HEIGHT_WCR; width: 500px;position: relative; left:0px; top:0px">
</div>
<div class="min-item">

<!-- Adding Bar Graph -->




					<script type="text/javascript">

		var chart;
		$(document).ready(function() {
			chart = new Highcharts.Chart({
					chart: {
					renderTo: 'container1',
					defaultSeriesType: 'bar',
					marginLeft: 25,
					marginTop: 5,
					borderColor: "#FFFFFF"
					},
					title: {
					text: ''
				},
				
				xAxis: {
				<!-- SESSION_SUMMARY -->
					title: {											
						text: null
					}
				},
				yAxis: {
					min: 0,
					title: {
						text: 'Resistance (Ohm)',
					}
				},
				tooltip: {
					enabled:false
				},
				plotOptions: {
					bar:  {
    					animation: false,
					borderWidth: 0,
					pointWidth:5,
					shadow: false
				  }
				},
				legend: {
					enabled:false,
					layout: 'vertical',
					align: 'top',
					verticalAlign: 'right',
					x: -100,
					y: 100,
					borderWidth: 0,
					backgroundColor: '#FFFFFF'
				},
				credits: {
					enabled: false
				},
			        series: [{
					name: 'Resistance (Ohm)',
					<!-- WORST_CASE_R -->	
	                               }, {
					name: 'Resistance (Ohm)',
					<!-- WORST_CASE_EFF_R -->	
				}]
			});
			
			
		});
	</script>

<!-- End of Tables -->

</div>
</div>
</div>

</div>
<!-- <div id="container"> -->
</body>
</html>

}

set ir_summary_page_html { 
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>RedHawk-GPS Explorer-TOP</title>
<!-- CSS Style Sheets-->
<link rel="stylesheet" href="/rhe/file?fname=styles/style.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=styles/ui.jquery.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/flexigrid/flexigrid/flexigrid.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/flexigrid/flexigrid/verticaltables.css" type="text/css" media="screen" />
<link rel="stylesheet" href="/rhe/file?fname=js/colorpicker/colorpicker.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=graph.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/jqModal/jqModal.css" type="text/css" media="screen">

<!-- END - CSS Style Sheets-->
<!-- Javascript files -->
<script src="/rhe/file?fname=js/sorttable.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/jquery.min.custom.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery-ui-personalized-1.6rc6.min.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/interface.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery.jimagetags.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery.corners.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/flexigrid.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/selectToUISlider.jQuery.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/colorpicker.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jqModal.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/jschart.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/highcharts.js" type="text/javascript"></script>


        <script src="/rhe/file?fname=raphael.js" type="text/javascript" charset="utf-8"></script>
        
        <script src="/rhe/file?fname=pie.js" type="text/javascript" charset="utf-8"></script>
     
<!-- END - Javascript files -->
</head>


<body>
<div id="container">
  <div id="header">
    <h1 class="prodt-title left"><img src="/rhe/file?fname=rh_gps_exploer_logo.png"/></h1>

    <div id="logo" class="right"><img    style="margin-left:-244px;"    src="/rhe/file?fname=logo.png" alt="Apache Design Solutions"></div>
    <div class="clear-left"></div>
    <div id="main-nav">
      <ul>

      </ul>
    </div>
    <div id="toolbar">
      <ul>
        <li><a onclick="window.history.back();" title="Go back to previous page"><img src="/rhe/file?fname=icon-back.png"  alt="Back" style="margin-top:5px;"> Back</a></li>
        <li><a onclick="window.history.forward();" title="Go forward one page">Forward <img src="/rhe/file?fname=icon-forward.png"  alt="Forward" style="margin-top:5px;"></a></li>
      </ul>
    </div>
  </div>
  <!--<div id="header">-->
  <div id="sidebar">
    <ul>
      <li class="summary">
          <a href="/rhe/file?fname=adsRHE/index.html" title="Design Summary"><B>Design Summary</B></a>

      </li>
     <li class="summary" style="padding: 5px 2px 0px 2px;">
          &nbsp&nbsp&nbsp<b>Results Summary<BR><BR></b>
          <ul>
	  
	  <li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Grid Details</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/metal_density.html" title="Metal Density">Metal Density</a></li>
            <li class="noicon disabled">&nbsp&nbsp Track Utilization</li>
	</ul>
            	    
  
            <li class="noicon"><a style="padding:5px 35px 5px 0px" href="/rhe/file?fname=adsRHE/power_summary.html" title="Power Summary">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Power Summary</b></a></li>
	    <li class="noicon"><a style="padding:5px 35px 5px 0px" href="/rhe/file?fname=adsRHE/resistance_summary.html" title="Resistance">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Resistance</b></a></li>

<li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Static EM&IR Results</b></li>
<ul>
            <li class="noicon active"><a href="/rhe/file?fname=adsRHE/static_ir.html" title="IR Results">IR Results</a></li>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/em_results.html" title="EM Results">EM Results</a></li>
 </ul>
 
	<li class="noicon disabled">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Dynamic EM&IR Results</b></li>
<ul>
            <li class="noicon disabled"><a  title="Current Waveforms">&nbsp&nbsp Current Waveforms</a></li>

            <li class="noicon disabled"><a  title="EM Results">&nbsp&nbsp EM Results</a></li>	
</ul>

<li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Session Metrics</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/session_summary.html" title="Session Summary">Session Summary</a></li>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/figure_of_merit.html" title="Metric Comparision">Metric Comparision</a></li>
 </ul>




    </ul>
  </div>
  <!--<div id="sidebar">-->

  <div id="sidebarshow" class="left"><img src="/rhe/file?fname=toggleLeft.gif" id="lateralClickImg"/></div>
  <div id="content" class="left">
    <ul id="breadcrumps"></ul>


 <script type="text/javascript">
    
  
      $(document).ready(function(){
        $("#tabs").tabs();
      });
    </script>

    <div id="tabs" class="min-item" style="width:620px;height:"auto";">


     <ul>
          <li><a href="#summary"><span>Summary</span></a></li>
          <li><a href="#net_specific"><span>Net Specific</span></a></li>
          <li><a href="#layer_specific"><span>Layer Specific</span></a></li>
	  
</ul>



<div id="summary">


 <script type="text/javascript">
          $(function(){
            //Scrollable Table
  	        $('.tabledata1 table').flexigrid({
              showToggleBtn:false,
              height:200,
              width:"417",
              resizable:false,
              title:"IR Drop Summary",
            });
          });
        </script>
        <div class="tabledata1">

          <table class="sortable">
            <thead>
              <tr>
                <th width="50"><center>Session</center></th>
                <th width="157"><center>Worst POWER Drop(mV)</center></th>
                <th width="157"><center>Worst GROUND Drop(mV)</center></th>
              </tr>
            </thead>
            <tbody>

<!-- IR_DROP_SUMMARY_HERE -->

  
  </tbody>
          </table>
        </div>
<div class="min-item" style= "position: relative; top:6px">
     <!-- <h3>Sessions Worst Drop</h3>-->
<div id="container1" class="highcharts-container" style="height:HEIGHT_SUMMARY; width: 500px;position: relative; left:0px; top:0px">
</div>
<div class="min-item">

<!-- Adding Bar Graph -->




					<script type="text/javascript">

		var chart;
		$(document).ready(function() {
			chart = new Highcharts.Chart({
					chart: {
					renderTo: 'container1',
					defaultSeriesType: 'bar',
					marginLeft: 25,
					marginTop: 5,
					borderColor: "#FFFFFF"
					},
					title: {
					text: ''
				},
				
				xAxis: {
				<!-- POWER_SUMMARY -->
					title: {											
						text: null
					}
				},
				yAxis: {
					min: 0,
					title: {
						text: 'Worst Drop (mV)',
					}
				},
				tooltip: {
					enabled:false
				},
				plotOptions: {
					bar:  {
    					animation: false,
					borderWidth: 0,
					pointWidth:5,
					shadow: false
				  }
				},
				legend: {
					enabled:false,
					layout: 'vertical',
					align: 'top',
					verticalAlign: 'right',
					x: -100,
					y: 100,
					borderWidth: 0,
					backgroundColor: '#FFFFFF'
				},
				credits: {
					enabled: false
				},
			        series: [{
					name: 'POWER DOMAIN(mV)',
					<!-- POWER_DROP_SUMMARY_HERE -->
                                   }, {
					name: 'GROUND DOMAIN(mV)',
					<!-- GROUND_DROP_SUMMARY_HERE -->		
				}]
			});
			
			
		});
	</script>

<!-- End of Tables -->

</div>
</div>
</div>


<div id="net_specific">


 <script type="text/javascript">
          $(function(){
            //Scrollable Table
  	        $('.tabledata2 table').flexigrid({
              showToggleBtn:false,
              height:HEIGHT_TABLE_DOMAIN,
              width:"373",
              resizable:false,
              title:"Net Specific IR Drop Summary",
            });
          });
        </script>
        <div class="tabledata2">

          <table class="sortable">
            <thead>
              <tr>
                <th width="150"><center>Net</center></th>
                <th width="137"><center>Best-Drop(mV)</center></th>
                <th width="50"><center>Session</center></th>
              </tr>
            </thead>
            <tbody>


<!-- NET_SPECIFIC_SUMMARY_HERE -->

  
  </tbody>
          </table>
        </div>

<!-- Adding Bar Graph -->
<div class="min-item1" style= "position: relative; top:6px">
    <!--  <h3>Domain Specific Worst Drop</h3> -->
<div id="container2" class="highcharts-container" style="height:HEIGHT_DOMAIN; width: 500px;position: relative; left:0px; top: 0px">
</div>

<div class="min-item1">



					<script type="text/javascript">

		var chart1;
		$(document).ready(function() {
			chart1 = new Highcharts.Chart({
					chart: {
					renderTo: 'container2',
					defaultSeriesType: 'bar',
					marginLeft: 120,
					marginTop: 5,
					borderColor: "#FFFFFF"
					},
					title: {
					text: ''
				},
				
				xAxis: {
				<!--DOMAIN_HERE-->
					title: {											
						text: null
					}
				},
				yAxis: {
					min: 0,
					title: {
						text: 'Drop (mV)',
					}
				},
				tooltip: {
					enabled:false
				},
				plotOptions: {
					bar:  {
    					animation: false,
					borderWidth: 0,
					pointWidth:15,
					shadow: false
				  }
				},
				legend: {
					enabled:false,
					layout: 'vertical',
					align: 'top',
					verticalAlign: 'right',
					x: -100,
					y: 100,
					borderWidth: 0,
					backgroundColor: '#FFFFFF'
				},
				credits: {
					enabled: false
				},
			        series: [{
					name: 'Drop (mV)',
					<!--DOMAIN_DROP-->		
				}]
			});
			
			
		});
	</script>
</div>
</div>
</div>


<div id="layer_specific">


 <script type="text/javascript">
          $(function(){
            //Scrollable Table
  	        $('.tabledata3 table').flexigrid({
              showToggleBtn:false,
              height:HEIGHT_TABLE_LAYER,
              width:"373",
              resizable:false,
              title:"Layer Specific IR Drop Summary",
            });
          });
        </script>
        <div class="tabledata3">

          <table class="sortable">
            <thead>
              <tr>
                <th width="150"><center>Net</center></th>
                <th width="137"><center>Best-Drop(mV)</center></th>
                <th width="50"><center>Session</center></th>
              </tr>
            </thead>
            <tbody>

<!-- LAYER_SPECIFIC_SUMMARY_HERE -->
  
  </tbody>
          </table>
        </div>

<!-- Adding Bar Graph -->
<div class="min-item17" style= "position: relative; top:6px">
<!--      <h3>Layer Specific Worst Drop</h3> -->
<div id="container3" class="highcharts-container" style="height:HEIGHT_LAYER; width: 500px;position: relative; left:0px; top: 0px">
</div>

<div class="min-item5">



					<script type="text/javascript">

		var chart2;
		$(document).ready(function() {
			chart2 = new Highcharts.Chart({
					chart: {
					renderTo: 'container3',
					defaultSeriesType: 'bar',
					marginLeft: 60,
					marginTop: 5,
					borderColor: "#FFFFFF"
					},
					title: {
					text: ''
				},
				
				xAxis: {
				<!--LAYER_HERE-->
					title: {											
						text: null
					}
				},
				yAxis: {
					min: 0,
					title: {
						text: 'Drop (mV)',
					}
				},
				tooltip: {
					enabled:false
				},
				plotOptions: {
					bar:  {
    					animation: false,
					borderWidth: 0,
					pointWidth:15,
					shadow: false
				  }
				},
				legend: {
					enabled:false,
					layout: 'vertical',
					align: 'top',
					verticalAlign: 'right',
					x: -100,
					y: 100,
					borderWidth: 0,
					backgroundColor: '#FFFFFF'
				},
				credits: {
					enabled: false
				},
			        series: [{
					name: 'Drop (mV)',
					<!--LAYER_DROP-->		
				}]
			});
			
			
		});
	</script>
</div>
</div>
</div>
<!-- <div id="container"> -->
</body>
</html>


}

set domain_ir_page_html { 

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>RedHawk-GPS Explorer-TOP</title>
<!-- CSS Style Sheets-->
<link rel="stylesheet" href="/rhe/file?fname=styles/style.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=styles/ui.jquery.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/flexigrid/flexigrid/flexigrid.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/flexigrid/flexigrid/verticaltables.css" type="text/css" media="screen" />
<link rel="stylesheet" href="/rhe/file?fname=js/colorpicker/colorpicker.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=graph.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/jqModal/jqModal.css" type="text/css" media="screen">

<!-- END - CSS Style Sheets-->
<!-- Javascript files -->
<script src="/rhe/file?fname=js/sorttable.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/jquery.min.custom.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery-ui-personalized-1.6rc6.min.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/interface.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery.jimagetags.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery.corners.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/flexigrid.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/selectToUISlider.jQuery.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/colorpicker.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jqModal.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/jschart.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/highcharts.js" type="text/javascript"></script>


        <script src="/rhe/file?fname=raphael.js" type="text/javascript" charset="utf-8"></script>
        
        <script src="/rhe/file?fname=pie.js" type="text/javascript" charset="utf-8"></script>
     
<!-- END - Javascript files -->
</head>


<body>
<div id="container">
  <div id="header">
    <h1 class="prodt-title left"><img src="/rhe/file?fname=rh_gps_exploer_logo.png"/></h1>

    <div id="logo" class="right"><img    style="margin-left:-244px;"    src="/rhe/file?fname=logo.png" alt="Apache Design Solutions"></div>
    <div class="clear-left"></div>
    <div id="main-nav">
      <ul>

      </ul>
    </div>
    <div id="toolbar">
      <ul>
        <li><a onclick="window.history.back();" title="Go back to previous page"><img src="/rhe/file?fname=icon-back.png"  alt="Back" style="margin-top:5px;"> Back</a></li>
        <li><a onclick="window.history.forward();" title="Go forward one page">Forward <img src="/rhe/file?fname=icon-forward.png"  alt="Forward" style="margin-top:5px;"></a></li>
      </ul>
    </div>
  </div>
  <!--<div id="header">-->
  <div id="sidebar">
    <ul>
      <li class="summary">
          <a href="/rhe/file?fname=adsRHE/index.html" title="Design Summary"><B>Design Summary</B></a>

      </li>
     <li class="summary" style="padding: 5px 2px 0px 2px;">
          &nbsp&nbsp&nbsp<b>Results Summary<BR><BR></b>
          <ul>
	  
	  <li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Grid Details</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/metal_density.html" title="Metal Density">Metal Density</a></li>
            <li class="noicon disabled">&nbsp&nbsp Track Utilization</li>
	</ul>
            	    
  
            <li class="noicon"><a style="padding:5px 35px 5px 0px" href="/rhe/file?fname=adsRHE/power_summary.html" title="Power Summary">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Power Summary</b></a></li>
	    <li class="noicon"><a style="padding:5px 35px 5px 0px" href="/rhe/file?fname=adsRHE/resistance_summary.html" title="Resistance">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Resistance</b></a></li>

<li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Static EM&IR Results</b></li>
<ul>
            <li class="noicon active"><a href="/rhe/file?fname=adsRHE/static_ir.html" title="IR Results">IR Results</a></li>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/em_results.html" title="EM Results">EM Results</a></li>
 </ul>
 
	<li class="noicon disabled">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Dynamic EM&IR Results</b></li>
<ul>
            <li class="noicon disabled"><a title="Current Waveforms">&nbsp&nbsp Current Waveforms</a></li>

            <li class="noicon disabled"><a  title="EM Results">&nbsp&nbsp EM Results</a></li>	
</ul>

<li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Session Metrics</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/session_summary.html" title="Session Summary">Session Summary</a></li>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/figure_of_merit.html" title="Metric Comparision">Metric Comparision</a></li>
 </ul>


    </ul>
  </div>
  <!--<div id="sidebar">-->

  <div id="sidebarshow" class="left"><img src="/rhe/file?fname=toggleLeft.gif" id="lateralClickImg"/></div>
  <div id="content" class="left">
    <ul id="breadcrumps"></ul>


 <script type="text/javascript">
    
  
      $(document).ready(function(){
        $("#tabs").tabs();
      });
    </script>

    <div id="tabs" class="min-item" style="width:620px;height:"auto";">


     <ul>
          <li><a href="#summary"><span>Summary</span></a></li>
	  
</ul>



<div id="summary">


 <script type="text/javascript">
          $(function(){
            //Scrollable Table
  	        $('.tabledata1 table').flexigrid({
              showToggleBtn:false,
              height:200,
              width:"250",
              resizable:false,
              <!-- DOMAIN_TITLE -->
            });
          });
        </script>
        <div class="tabledata1">

          <table class="sortable">
            <thead>
              <tr>
                <th width="50"><center>Session</center></th>
                <th width="157"><center>Worst Drop(mV)</center></th>
              </tr>
            </thead>
            <tbody>

<!-- DOMAIN_DROP_HERE -->

  
  </tbody>
          </table>
        </div>
<div class="min-item" style= "position: relative; top:6px">
     <!-- <h3>Sessions Worst Drop</h3> -->
<div id="container1" class="highcharts-container" style="height:HEIGHT_HERE; width: 500px;position: relative; left:0px; top:0px">
</div>
<div class="min-item">

<!-- Adding Bar Graph -->




					<script type="text/javascript">

		var chart;
		$(document).ready(function() {
			chart = new Highcharts.Chart({
					chart: {
					renderTo: 'container1',
					defaultSeriesType: 'bar',
					marginLeft: 25,
					marginTop: 5,
					borderColor: "#FFFFFF"
					},
					title: {
					text: ''
				},
				
				xAxis: {
				<!-- SESSIONS -->
					title: {											
						text: null
					}
				},
				yAxis: {
					min: 0,
					title: {
						text: 'Worst Drop (mV)',
					}
				},
				tooltip: {
					enabled:false
				},
				plotOptions: {
					bar:  {
    					animation: false,
					borderWidth: 0,
					pointWidth:5,
					shadow: false
				  }
				},
				legend: {
					enabled:false,
					layout: 'vertical',
					align: 'top',
					verticalAlign: 'right',
					x: -100,
					y: 100,
					borderWidth: 0,
					backgroundColor: '#FFFFFF'
				},
				credits: {
					enabled: false
				},
			        series: [{
					name: 'Drop(mV)',
					<!-- DROP_TABLE -->		
				}]
			});
			
			
		});
	</script>

<!-- End of Tables -->

</div>
</div>
</div>

</div>
<!-- <div id="container"> -->
</body>
</html>

}

set layer_ir_page_html { 


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>RedHawk-GPS Explorer-TOP</title>
<!-- CSS Style Sheets-->
<link rel="stylesheet" href="/rhe/file?fname=styles/style.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=styles/ui.jquery.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/flexigrid/flexigrid/flexigrid.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/flexigrid/flexigrid/verticaltables.css" type="text/css" media="screen" />
<link rel="stylesheet" href="/rhe/file?fname=js/colorpicker/colorpicker.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=graph.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/jqModal/jqModal.css" type="text/css" media="screen">

<!-- END - CSS Style Sheets-->
<!-- Javascript files -->
<script src="/rhe/file?fname=js/sorttable.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/jquery.min.custom.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery-ui-personalized-1.6rc6.min.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/interface.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery.jimagetags.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery.corners.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/flexigrid.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/selectToUISlider.jQuery.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/colorpicker.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jqModal.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/jschart.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/highcharts.js" type="text/javascript"></script>


        <script src="/rhe/file?fname=raphael.js" type="text/javascript" charset="utf-8"></script>
        
        <script src="/rhe/file?fname=pie.js" type="text/javascript" charset="utf-8"></script>
     
<!-- END - Javascript files -->
</head>


<body>
<div id="container">
  <div id="header">
    <h1 class="prodt-title left"><img src="/rhe/file?fname=rh_gps_exploer_logo.png"/></h1>

    <div id="logo" class="right"><img    style="margin-left:-244px;"    src="/rhe/file?fname=logo.png" alt="Apache Design Solutions"></div>
    <div class="clear-left"></div>
    <div id="main-nav">
      <ul>

      </ul>
    </div>
    <div id="toolbar">
      <ul>
        <li><a onclick="window.history.back();" title="Go back to previous page"><img src="/rhe/file?fname=icon-back.png"  alt="Back" style="margin-top:5px;"> Back</a></li>
        <li><a onclick="window.history.forward();" title="Go forward one page">Forward <img src="/rhe/file?fname=icon-forward.png"  alt="Forward" style="margin-top:5px;"></a></li>
      </ul>
    </div>
  </div>
  <!--<div id="header">-->
  <div id="sidebar">
    <ul>
      <li class="summary">
          <a href="/rhe/file?fname=adsRHE/index.html" title="Design Summary"><B>Design Summary</B></a>

      </li>
     <li class="summary" style="padding: 5px 2px 0px 2px;">
          &nbsp&nbsp&nbsp<b>Results Summary<BR><BR></b>
          <ul>
	  
	  <li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Grid Details</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/metal_density.html" title="Metal Density">Metal Density</a></li>
            <li class="noicon disabled">&nbsp&nbsp Track Utilization</li>
	</ul>
            	    
  
            <li class="noicon"><a style="padding:5px 35px 5px 0px" href="/rhe/file?fname=adsRHE/power_summary.html" title="Power Summary">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Power Summary</b></a></li>
	    <li class="noicon"><a style="padding:5px 35px 5px 0px" href="/rhe/file?fname=adsRHE/resistance_summary.html" title="Resistance">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Resistance</b></a></li>

<li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Static EM&IR Results</b></li>
<ul>
            <li class="noicon active"><a href="/rhe/file?fname=adsRHE/static_ir.html" title="IR Results">IR Results</a></li>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/em_results.html" title="EM Results">EM Results</a></li>
 </ul>
 
	<li class="noicon disabled">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Dynamic EM&IR Results</b></li>
<ul>
            <li class="noicon disabled"><a  title="Current Waveforms">&nbsp&nbsp Current Waveforms</a></li>

            <li class="noicon disabled"><a  title="EM Results">&nbsp&nbsp EM Results</a></li>	
</ul>

<li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Session Metrics</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/session_summary.html" title="Session Summary">Session Summary</a></li>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/figure_of_merit.html" title="Metric Comparision">Metric Comparision</a></li>
 </ul>


    </ul>
  </div>
  <!--<div id="sidebar">-->

  <div id="sidebarshow" class="left"><img src="/rhe/file?fname=toggleLeft.gif" id="lateralClickImg"/></div>
  <div id="content" class="left">
    <ul id="breadcrumps"></ul>


 <script type="text/javascript">
    
  
      $(document).ready(function(){
        $("#tabs").tabs();
      });
    </script>

    <div id="tabs" class="min-item" style="width:620px;height:"auto";">


     <ul>
          <li><a href="#summary"><span>Summary</span></a></li>
	  
</ul>



<div id="summary">


 <script type="text/javascript">
          $(function(){
            //Scrollable Table
  	        $('.tabledata1 table').flexigrid({
              showToggleBtn:false,
              height:200,
              width:"250",
              resizable:false,
              <!-- DOMAIN_TITLE -->
            });
          });
        </script>
        <div class="tabledata1">

          <table class="sortable">
            <thead>
              <tr>
                <th width="50"><center>Session</center></th>
                <th width="157"><center>Worst Drop(mV)</center></th>
              </tr>
            </thead>
            <tbody>

<!-- DOMAIN_DROP_HERE -->

  
  </tbody>
          </table>
        </div>
<div class="min-item" style= "position: relative; top:6px">
      <!--<h3>Sessions Worst Drop</h3> -->
<div id="container1" class="highcharts-container" style="height:HEIGHT_HERE; width: 500px;position: relative; left:0px; top:0px">
</div>
<div class="min-item">

<!-- Adding Bar Graph -->




					<script type="text/javascript">

		var chart;
		$(document).ready(function() {
			chart = new Highcharts.Chart({
					chart: {
					renderTo: 'container1',
					defaultSeriesType: 'bar',
					marginLeft: 25,
					marginTop: 5,
					borderColor: "#FFFFFF"
					},
					title: {
					text: ''
				},
				
				xAxis: {
				<!-- SESSIONS -->
					title: {											
						text: null
					}
				},
				yAxis: {
					min: 0,
					title: {
						text: 'Worst Drop (mV)',
					}
				},
				tooltip: {
					enabled:false
				},
				plotOptions: {
					bar:  {
    					animation: false,
					borderWidth: 0,
					pointWidth:5,
					shadow: false
				  }
				},
				legend: {
					enabled:false,
					layout: 'vertical',
					align: 'top',
					verticalAlign: 'right',
					x: -100,
					y: 100,
					borderWidth: 0,
					backgroundColor: '#FFFFFF'
				},
				credits: {
					enabled: false
				},
			        series: [{
					name: 'Drop(mV)',
					<!-- DROP_TABLE -->		
				}]
			});
			
			
		});
	</script>

<!-- End of Tables -->

</div>
</div>
</div>

</div>
<!-- <div id="container"> -->
</body>
</html>

}

set em_page_html { 

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>RedHawk-GPS Explorer-TOP</title>
<!-- CSS Style Sheets-->
<link rel="stylesheet" href="/rhe/file?fname=styles/style.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=styles/ui.jquery.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/flexigrid/flexigrid/flexigrid.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/flexigrid/flexigrid/verticaltables.css" type="text/css" media="screen" />
<link rel="stylesheet" href="/rhe/file?fname=js/colorpicker/colorpicker.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=graph.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/jqModal/jqModal.css" type="text/css" media="screen">

<!-- END - CSS Style Sheets-->
<!-- Javascript files -->
<script src="/rhe/file?fname=js/sorttable.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/jquery.min.custom.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery-ui-personalized-1.6rc6.min.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/interface.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery.jimagetags.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery.corners.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/flexigrid.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/selectToUISlider.jQuery.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/colorpicker.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jqModal.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/jschart.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/highcharts.js" type="text/javascript"></script>


        <script src="/rhe/file?fname=raphael.js" type="text/javascript" charset="utf-8"></script>
        
        <script src="/rhe/file?fname=pie.js" type="text/javascript" charset="utf-8"></script>
     
<!-- END - Javascript files -->
</head>


<body>
<div id="container">
  <div id="header">
    <h1 class="prodt-title left"><img src="/rhe/file?fname=rh_gps_exploer_logo.png"/></h1>

    <div id="logo" class="right"><img    style="margin-left:-244px;"    src="/rhe/file?fname=logo.png" alt="Apache Design Solutions"></div>
    <div class="clear-left"></div>
    <div id="main-nav">
      <ul>

      </ul>
    </div>
    <div id="toolbar">
      <ul>
        <li><a onclick="window.history.back();" title="Go back to previous page"><img src="/rhe/file?fname=icon-back.png"  alt="Back" style="margin-top:5px;"> Back</a></li>
        <li><a onclick="window.history.forward();" title="Go forward one page">Forward <img src="/rhe/file?fname=icon-forward.png"  alt="Forward" style="margin-top:5px;"></a></li>
      </ul>
    </div>
  </div>
  <!--<div id="header">-->
  <div id="sidebar">
    <ul>
      <li class="summary">
          <a href="/rhe/file?fname=adsRHE/index.html" title="Design Summary"><B>Design Summary</B></a>

      </li>
     <li class="summary" style="padding: 5px 2px 0px 2px;">
          &nbsp&nbsp&nbsp<b>Results Summary<BR><BR></b>
          <ul>
	  
	  <li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Grid Details</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/metal_density.html" title="Metal Density">Metal Density</a></li>
            <li class="noicon disabled">&nbsp&nbsp Track Utilization</li>
	</ul>
            	    
  
            <li class="noicon"><a style="padding:5px 35px 5px 0px" href="/rhe/file?fname=adsRHE/power_summary.html" title="Power Summary">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Power Summary</b></a></li>
	    <li class="noicon"><a style="padding:5px 35px 5px 0px" href="/rhe/file?fname=adsRHE/resistance_summary.html" title="Resistance">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Resistance</b></a></li>

<li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Static EM&IR Results</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/static_ir.html" title="IR Results">IR Results</a></li>
            <li class="noicon active"><a href="/rhe/file?fname=adsRHE/em_results.html" title="EM Results">EM Results</a></li>
 </ul>
 
	<li class="noicon disabled">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Dynamic EM&IR Results</b></li>
<ul>
            <li class="noicon disabled"><a title="Current Waveforms">&nbsp&nbsp Current Waveforms</a></li>

            <li class="noicon disabled"><a title="EM Results">&nbsp&nbsp EM Results</a></li>	
</ul>


<li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Session Metrics</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/session_summary.html" title="Session Summary">Session Summary</a></li>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/figure_of_merit.html" title="Metric Comparision">Metric Comparision</a></li>
 </ul>



    </ul>
  </div>
  <!--<div id="sidebar">-->

  <div id="sidebarshow" class="left"><img src="/rhe/file?fname=toggleLeft.gif" id="lateralClickImg"/></div>
  <div id="content" class="left">
    <ul id="breadcrumps"></ul>


 <script type="text/javascript">
    
  
      $(document).ready(function(){
        $("#tabs").tabs();
      });
    </script>

    <div id="tabs" class="min-item" style="width:620px;height:"auto";">


     <ul>
          <li><a href="#metal_em_violations"><span>Metal EM Violations</span></a></li>
          <li><a href="#via_em_violations"><span>Via EM Violations</span></a></li>
	  
</ul>

<div id="metal_em_violations">


 <script type="text/javascript">
          $(function(){
            //Scrollable Table
  	        $('.tabledata2 table').flexigrid({
              showToggleBtn:false,
              height:200,
              width:"420",
              resizable:false,
              title:"Metal EM Violations",
            });
          });
        </script>
        <div class="tabledata2">

          <table class="sortable">
            <thead>
              <tr>
                <th width="50"><center>Session</center></th>
                <th width="130"><center>#Metal EM violations</center></th>
                <th width="185"><center>Worst Metal EM violations(%)</center></th>
              </tr>
            </thead>
            <tbody>

<!-- NUMBER_METAL_EM_HERE -->
  
  </tbody>
          </table>
        </div>

<!-- Adding Bar Graph -->

<div class="min-item" style= "position: relative; top:0px">
     <!--  <h3>Number of Metal EM Violations</h3> -->
<div id="container1" class="highcharts-container" style="height:HEIGHT_METAL1; width: 250px;position: relative; left:0px; top:0px">
</div>
<div class="min-item">

					<script type="text/javascript">

		var chart;
		$(document).ready(function() {
			chart = new Highcharts.Chart({
					chart: {
					renderTo: 'container1',
					defaultSeriesType: 'bar',
					marginLeft: 25,
					marginTop: 5,
					borderColor: "#FFFFFF"
					},
					title: {
					text: ''
				},
				
				xAxis: {
				<!-- TABLE_METAL_EM_HERE1 -->
					title: {											
						text: null
					}
				},
				yAxis: {
					min: 0,
					title: {
						text: 'Number of Metal EM violations',
					}
				},
				tooltip: {
					enabled:false
				},
				plotOptions: {
					bar:  {
    					animation: false,
					borderWidth: 0,
					pointWidth:5,
					shadow: false
				  }
				},
				legend: {
					enabled:false,
					layout: 'vertical',
					align: 'top',
					verticalAlign: 'right',
					x: -100,
					y: 100,
					borderWidth: 0,
					backgroundColor: '#FFFFFF'
				},
				credits: {
					enabled: false
				},
			        series: [{
					name: 'Numer of Metal EM Violations',
					<!-- TABLE_NO_METAL_EM_HERE1 -->
				}]
			});
			
			
		});
	</script>
</div>
</div>
<!-- End of Tables -->

<div class="min-item" style= "position: relative; top:0px">
     <!-- <h3>Worst Metal EM Violations</h3> -->
<div id="container2" class="highcharts-container" style="height:HEIGHT_METAL2; width: 250px;position: relative; left:0px; top:0px">
</div>
<div class="min-item">

					<script type="text/javascript">

		var chart1;
		$(document).ready(function() {
			chart1 = new Highcharts.Chart({
					chart: {
					renderTo: 'container2',
					defaultSeriesType: 'bar',
					marginLeft: 25,
					marginTop: 5,
					borderColor: "#FFFFFF"
					},
					title: {
					text: ''
				},
				
				xAxis: {
				<!-- TABLE_METAL_EM_HERE2 -->
					title: {											
						text: null
					}
				},
				yAxis: {
					min: 0,
					title: {
						text: 'Worst Metal EM violations(%)',
					}
				},
				tooltip: {
					enabled:false
				},
				plotOptions: {
					bar:  {
    					animation: false,
					borderWidth: 0,
					pointWidth:5,
					shadow: false
				  }
				},
				legend: {
					enabled:false,
					layout: 'vertical',
					align: 'top',
					verticalAlign: 'right',
					x: -100,
					y: 100,
					borderWidth: 0,
					backgroundColor: '#FFFFFF'
				},
				credits: {
					enabled: false
				},
			        series: [{
					name: 'Worst Metal EM Violations',
					<!-- TABLE_WORST_METAL_EM_HERE2 -->
				}]
			});
			
			
		});
	</script>
</div>
</div>
<!-- End of Tables -->




</div>



<div id="via_em_violations">


 <script type="text/javascript">
          $(function(){
            //Scrollable Table
  	        $('.tabledata4 table').flexigrid({
              showToggleBtn:false,
              height:200,
              width:"393",
              resizable:false,
              title:"Via EM Violations",
            });
          });
        </script>
        <div class="tabledata4">

          <table class="sortable">
            <thead>
              <tr>
                <th width="50"><center>Session</center></th>
                <th width="130"><center>#Via EM violations</center></th>
                <th width="160"><center>Worst Via EM violations(%)</center></th>
              </tr>
            </thead>
            <tbody>

 <!-- NUMBER_VIA_EM_HERE --> 
  </tbody>
          </table>
        </div>

<!-- Adding Bar Graph -->

<div class="min-item" style= "position: relative; top:0px">
      <!-- <h3>Number of VIA EM Violations</h3> -->
<div id="container3" class="highcharts-container" style="height:HEIGHT_VIA1; width: 250px;position: relative; left:0px; top:0px">
</div>
<div class="min-item">

					<script type="text/javascript">

		var chart;
		$(document).ready(function() {
			chart = new Highcharts.Chart({
					chart: {
					renderTo: 'container3',
					defaultSeriesType: 'bar',
					marginLeft: 25,
					marginTop: 5,
					borderColor: "#FFFFFF"
					},
					title: {
					text: ''
				},
				
				xAxis: {
				<!-- TABLE_VIA_EM_HERE1 -->
					title: {											
						text: null
					}
				},
				yAxis: {
					min: 0,
					title: {
						text: 'Number of Via EM violations',
					}
				},
				tooltip: {
					enabled:false
				},
				plotOptions: {
					bar:  {
    					animation: false,
					borderWidth: 0,
					pointWidth:5,
					shadow: false
				  }
				},
				legend: {
					enabled:false,
					layout: 'vertical',
					align: 'top',
					verticalAlign: 'right',
					x: -100,
					y: 100,
					borderWidth: 0,
					backgroundColor: '#FFFFFF'
				},
				credits: {
					enabled: false
				},
			        series: [{
					name: 'Numer of Via EM Violations',
					<!-- TABLE_NO_VIA_EM_HERE1 -->
				}]
			});
			
			
		});
	</script>
</div>
</div>
<!-- End of Tables -->

<div class="min-item" style= "position: relative; top:0px">
 <!--      <h3>Worst VIA EM Violations</h3> -->
<div id="container4" class="highcharts-container" style="height:HEIGHT_VIA2; width: 250px;position: relative; left:0px; top:0px">
</div>
<div class="min-item">

					<script type="text/javascript">

		var chart1;
		$(document).ready(function() {
			chart1 = new Highcharts.Chart({
					chart: {
					renderTo: 'container4',
					defaultSeriesType: 'bar',
					marginLeft: 25,
					marginTop: 5,
					borderColor: "#FFFFFF"
					},
					title: {
					text: ''
				},
				
				xAxis: {
				<!-- TABLE_VIA_EM_HERE2 -->
					title: {											
						text: null
					}
				},
				yAxis: {
					min: 0,
					title: {
						text: 'Worst Via EM violations(%)',
					}
				},
				tooltip: {
					enabled:false
				},
				plotOptions: {
					bar:  {
    					animation: false,
					borderWidth: 0,
					pointWidth:5,
					shadow: false
				  }
				},
				legend: {
					enabled:false,
					layout: 'vertical',
					align: 'top',
					verticalAlign: 'right',
					x: -100,
					y: 100,
					borderWidth: 0,
					backgroundColor: '#FFFFFF'
				},
				credits: {
					enabled: false
				},
			        series: [{
					name: 'Worst Via EM Violations',
					<!-- TABLE_WORST_VIA_EM_HERE2 -->
				}]
			});
			
			
		});
	</script>
</div>
</div>
<!-- End of Tables -->




</div>




</div>
<!-- <div id="container"> -->
</body>
</html>


} 

set session_main_page_html {  

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>RedHawk-GPS Explorer-TOP</title>
<!-- CSS Style Sheets-->
<link rel="stylesheet" href="/rhe/file?fname=styles/style.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=styles/ui.jquery.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/flexigrid/flexigrid/flexigrid.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/flexigrid/flexigrid/verticaltables.css" type="text/css" media="screen" />
<link rel="stylesheet" href="/rhe/file?fname=js/colorpicker/colorpicker.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=graph.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/jqModal/jqModal.css" type="text/css" media="screen">

<!-- END - CSS Style Sheets-->
<!-- Javascript files -->

<script src="/rhe/file?fname=js/jquery.min.custom.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery-ui-personalized-1.6rc6.min.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/interface.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery.jimagetags.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery.corners.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/flexigrid.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/selectToUISlider.jQuery.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/colorpicker.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jqModal.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/jschart.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/highcharts.js" type="text/javascript"></script>


        <script src="/rhe/file?fname=raphael.js" type="text/javascript" charset="utf-8"></script>
        
        <script src="/rhe/file?fname=pie.js" type="text/javascript" charset="utf-8"></script>
     
<!-- END - Javascript files -->
</head>


<body>
<div id="container">
  <div id="header">
    <h1 class="prodt-title left"><img src="/rhe/file?fname=rh_gps_exploer_logo.png"/></h1>

    <div id="logo" class="right"><img    style="margin-left:-244px;"    src="/rhe/file?fname=logo.png" alt="Apache Design Solutions"></div>
    <div class="clear-left"></div>
    <div id="main-nav">
      <ul>

      </ul>
    </div>
    <div id="toolbar">
      <ul>
        <li><a onclick="window.history.back();" title="Go back to previous page"><img src="/rhe/file?fname=icon-back.png"  alt="Back" style="margin-top:5px;"> Back</a></li>
        <li><a onclick="window.history.forward();" title="Go forward one page">Forward <img src="/rhe/file?fname=icon-forward.png"  alt="Forward" style="margin-top:5px;"></a></li>
      </ul>
    </div>
  </div>
  <!--<div id="header">-->
  <div id="sidebar">
    <ul>
      <li class="summary">
          <a href="/rhe/file?fname=adsRHE/index.html" title="Design Summary"><B>Design Summary</B></a>

      </li>
     <li class="summary" style="padding: 5px 2px 0px 2px;">
          &nbsp&nbsp&nbsp<b>Results Summary<BR><BR></b>
          <ul>
	  
	  <li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Grid Details</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/metal_density.html" title="Metal Density">Metal Density</a></li>
            <li class="noicon disabled">&nbsp&nbsp Track Utilization</li>
	</ul>
            	    
  
            <li class="noicon"><a style="padding:5px 35px 5px 0px" href="/rhe/file?fname=adsRHE/power_summary.html" title="Power Summary">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Power Summary</b></a></li>
	    <li class="noicon"><a style="padding:5px 35px 5px 0px" href="/rhe/file?fname=adsRHE/resistance_summary.html" title="Resistance">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Resistance</b></a></li>

<li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Static EM&IR Results</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/static_ir.html" title="IR Results">IR Results</a></li>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/em_results.html" title="EM Results">EM Results</a></li>
 </ul>
 
	<li class="noicon disabled">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Dynamic EM&IR Results</b></li>
<ul>
            <li class="noicon disabled"><a  title="Current Waveforms">&nbsp&nbsp Current Waveforms</a></li>

            <li class="noicon disabled"><a title="EM Results">&nbsp&nbsp EM Results</a></li>	
</ul>

<li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Session Metrics</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/session_summary.html" title="Session Summary">Session Summary</a></li>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/figure_of_merit.html" title="Metric Comparision">Metric Comparision</a></li>
 </ul>




    </ul>
  </div>
  <!--<div id="sidebar">-->

  <div id="sidebarshow" class="left"><img src="/rhe/file?fname=toggleLeft.gif" id="lateralClickImg"/></div>
  <div id="content" class="left">
    <ul id="breadcrumps"></ul>


 <script type="text/javascript">
    
  
      $(document).ready(function(){
        $("#tabs").tabs();
      });
    </script>

    <div id="tabs" class="min-item" style="width:620px;height:"auto";">


     <ul>
          <li><a href="#summary"><span>Session Summary</span></a></li>
	  
</ul>



<div id="summary">

 <script type="text/javascript">
          $(function(){
            //Scrollable Table
  	        $('.tabledata2 table').flexigrid({
              showToggleBtn:false,
              height:HEIGHT_TABLE_SESSION,
              width:"WIDTH_HERE",
              resizable:false,
              title:"Sessions",
            });
          });
        </script>
        <div class="tabledata2 min-item2">

          <table>
            <tbody>

<!-- SESSIONS_HERE -->
  
  </tbody>
          </table>
        </div>

<!-- End of Tables -->


</div>
</div>
</div>


</div>
<!-- <div id="container"> -->
</body>
</html>

}



set session_page_html { 

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>RedHawk-GPS Explorer-TOP</title>
<!-- CSS Style Sheets-->
<link rel="stylesheet" href="/rhe/file?fname=styles/style.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=styles/ui.jquery.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/flexigrid/flexigrid/flexigrid.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/flexigrid/flexigrid/verticaltables.css" type="text/css" media="screen" />
<link rel="stylesheet" href="/rhe/file?fname=js/colorpicker/colorpicker.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=graph.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/jqModal/jqModal.css" type="text/css" media="screen">

<!-- END - CSS Style Sheets-->
<!-- Javascript files -->

<script src="/rhe/file?fname=js/jquery.min.custom.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery-ui-personalized-1.6rc6.min.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/interface.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery.jimagetags.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery.corners.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/flexigrid.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/selectToUISlider.jQuery.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/colorpicker.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jqModal.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/jschart.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/highcharts.js" type="text/javascript"></script>


        <script src="/rhe/file?fname=raphael.js" type="text/javascript" charset="utf-8"></script>
        
        <script src="/rhe/file?fname=pie.js" type="text/javascript" charset="utf-8"></script>
     
<!-- END - Javascript files -->
</head>


<body>
<div id="container">
  <div id="header">
    <h1 class="prodt-title left"><img src="/rhe/file?fname=rh_gps_exploer_logo.png"/></h1>

    <div id="logo" class="right"><img    style="margin-left:-244px;"    src="/rhe/file?fname=logo.png" alt="Apache Design Solutions"></div>
    <div class="clear-left"></div>
    <div id="main-nav">
      <ul>

      </ul>
    </div>
    <div id="toolbar">
      <ul>
        <li><a onclick="window.history.back();" title="Go back to previous page"><img src="/rhe/file?fname=icon-back.png"  alt="Back" style="margin-top:5px;"> Back</a></li>
        <li><a onclick="window.history.forward();" title="Go forward one page">Forward <img src="/rhe/file?fname=icon-forward.png"  alt="Forward" style="margin-top:5px;"></a></li>
      </ul>
    </div>
  </div>
  <!--<div id="header">-->
  <div id="sidebar">
    <ul>
      <li class="summary">
          <a href="/rhe/file?fname=adsRHE/index.html" title="Design Summary"><B>Design Summary</B></a>

      </li>
     <li class="summary" style="padding: 5px 2px 0px 2px;">
          &nbsp&nbsp&nbsp<b>Results Summary<BR><BR></b>
          <ul>
	  
	  <li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Grid Details</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/metal_density.html" title="Metal Density">Metal Density</a></li>
            <li class="noicon disabled">&nbsp&nbsp Track Utilization</li>
	</ul>
            	    
  
            <li class="noicon"<a style="padding:5px 35px 5px 0px" href="/rhe/file?fname=adsRHE/power_summary.html" title="Power Summary">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Power Summary</b></a></li>
	    <li class="noicon"><a style="padding:5px 35px 5px 0px" href="/rhe/file?fname=adsRHE/resistance_summary.html" title="Resistance">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Resistance</b></a></li>

<li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Static EM&IR Results</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/static_ir.html" title="IR Results">IR Results</a></li>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/em_results.html" title="EM Results">EM Results</a></li>
 </ul>
 
	<li class="noicon disabled">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Dynamic EM&IR Results</b></li>
<ul>
            <li class="noicon disabled"><a title="Current Waveforms">&nbsp&nbsp Current Waveforms</a></li>

            <li class="noicon disabled"><a  title="EM Results">&nbsp&nbsp EM Results</a></li>	
</ul>

<li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Session Metrics</b></li>
<ul>
            <li class="noicon active"><a href="/rhe/file?fname=adsRHE/session_summary.html" title="Session Summary">Session Summary</a></li>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/figure_of_merit.html" title="Metric Comparision">Metric Comparision</a></li>
 </ul>




    </ul>
  </div>
  <!--<div id="sidebar">-->

  <div id="sidebarshow" class="left"><img src="/rhe/file?fname=toggleLeft.gif" id="lateralClickImg"/></div>
  <div id="content" class="left">
    <ul id="breadcrumps"></ul>
 <script type="text/javascript">
    
  
      $(document).ready(function(){
        $("#tabs").tabs();
      });
    </script>

    
<div id="summary">


 <script type="text/javascript">
          $(function(){
            //Scrollable Table
  	        $('.tabledata2 table').flexigrid({
              showToggleBtn:false,
               height:2000,
              width:"505",
              resizable:false,
              title:"SESSION_TITLE",
            });
          });
        </script>
        <div class="tabledata2 min-item2">

          <table style="width:505px">
            <thead>
              <tr>
              </tr>
            </thead>
            <tbody>

<!-- METRIC_SUMMARY_HERE -->
  </tbody>
          </table>
        </div>

</div>
<!-- <div id="container"> -->


</body>
</html>

}
###

set fom_html { 

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>RedHawk-GPS Explorer-TOP</title>
<!-- CSS Style Sheets-->
<link rel="stylesheet" href="/rhe/file?fname=styles/style.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=styles/ui.jquery.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/flexigrid/flexigrid/flexigrid.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/flexigrid/flexigrid/verticaltables.css" type="text/css" media="screen" />
<link rel="stylesheet" href="/rhe/file?fname=js/colorpicker/colorpicker.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=graph.css" type="text/css" media="screen">
<link rel="stylesheet" href="/rhe/file?fname=js/jqModal/jqModal.css" type="text/css" media="screen">

<!-- END - CSS Style Sheets-->
<!-- Javascript files -->
<script src="/rhe/file?fname=js/sorttable.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery.min.custom.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery-ui-personalized-1.6rc6.min.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/interface.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery.jimagetags.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jquery.corners.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/flexigrid.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/selectToUISlider.jQuery.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/colorpicker.js" type="text/javascript"></script>
<script src="/rhe/file?fname=js/jqModal.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/jschart.js" type="text/javascript"></script>

<script src="/rhe/file?fname=js/highcharts.js" type="text/javascript"></script>


        <script src="/rhe/file?fname=raphael.js" type="text/javascript" charset="utf-8"></script>
        
        <script src="/rhe/file?fname=pie.js" type="text/javascript" charset="utf-8"></script>
     
<!-- END - Javascript files -->
</head>


<body>
<div id="container">
  <div id="header">
    <h1 class="prodt-title left"><img src="/rhe/file?fname=rh_gps_exploer_logo.png"/></h1>

    <div id="logo" class="right"><img    style="margin-left:-244px;"    src="/rhe/file?fname=logo.png" alt="Apache Design Solutions"></div>
    <div class="clear-left"></div>
    <div id="main-nav">
      <ul>

      </ul>
    </div>
    <div id="toolbar">
      <ul>
        <li><a onclick="window.history.back();" title="Go back to previous page"><img src="/rhe/file?fname=icon-back.png"  alt="Back" style="margin-top:5px;"> Back</a></li>
        <li><a onclick="window.history.forward();" title="Go forward one page">Forward <img src="/rhe/file?fname=icon-forward.png"  alt="Forward" style="margin-top:5px;"></a></li>
      </ul>
    </div>
  </div>
  <!--<div id="header">-->
  <div id="sidebar">
    <ul>
      <li class="summary">
          <a href="/rhe/file?fname=adsRHE/index.html" title="Design Summary"><B>Design Summary</B></a>

      </li>
     <li class="summary" style="padding: 5px 2px 0px 2px;">
          &nbsp&nbsp&nbsp<b>Results Summary<BR><BR></b>
          <ul>
	  
	  <li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Grid Details</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/metal_density.html" title="Metal Density">Metal Density</a></li>
            <li class="noicon disabled">&nbsp&nbsp Track Utilization</li>
	</ul>
            	    
  
            <li class="noicon"><a style="padding:5px 35px 5px 0px" href="/rhe/file?fname=adsRHE/power_summary.html" title="Power Summary">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Power Summary</b></a></li>
	    <li class="noicon"><a style="padding:5px 35px 5px 0px" href="/rhe/file?fname=adsRHE/resistance_summary.html" title="Resistance">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Resistance</b></a></li>

<li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Static EM&IR Results</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/static_ir.html" title="IR Results">IR Results</a></li>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/em_results.html" title="EM Results">EM Results</a></li>
 </ul>
 
	<li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Dynamic EM&IR Results</b></li>
<ul>
            <li class="noicon disabled"><a  title="Current Waveforms">&nbsp&nbsp Current Waveforms</a></li>

            <li class="noicon disabled"><a  title="EM Results">&nbsp&nbsp EM Results</a></li>	
</ul>

<li class="noicon">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Session Metrics</b></li>
<ul>
            <li class="noicon"><a href="/rhe/file?fname=adsRHE/session_summary.html" title="Session Summary">Session Summary</a></li>
            <li class="noicon active"><a href="/rhe/file?fname=adsRHE/figure_of_merit.html" title="Metric Comparision">Metric Comparision</a></li>
 </ul>

    </ul>
  </div>
  <!--<div id="sidebar">-->

  <div id="sidebarshow" class="left"><img src="/rhe/file?fname=toggleLeft.gif" id="lateralClickImg"/></div>
  <div id="content" class="left">
    <ul id="breadcrumps"></ul>


 <script type="text/javascript">
    
  
      $(document).ready(function(){
        $("#tabs").tabs();
      });
    </script>

<div id="tabs" class="min-item" style="width:630px;height:"auto";">


     <ul>
          <li><a href="#summary"><span>Metric Summary</span></a></li>

</ul>


<div id="summary">

 <script type="text/javascript">
          $(function(){
            //Scrollable Table
  	        $('.tabledata2 table').flexigrid({
              showToggleBtn:false,
              height:HEIGHT,
              width:"630",
              resizable:false,
              title:"Sessions Metric Summary ",
            });
          });
        </script>
        <div class="tabledata2 min-item2">

          <table class="sortable">
            <thead>
              <tr bgcolor="#D8D8D8">
<th width="40">Session</th>
<th width="80">Avg Metal<br />Density(%)</th>
<th width="60">Power<br />(mW)</th>
<th width="60">Res<br />(Ohm)</th>
<th width="70">Eff Res<br />(Ohm)<br />  </th>
<th width="120">Worst Drop(mV)<br />  </th>
<th width="120">Worst EM(%)</th>
<th width="100">Figure of Merit</th>
              </tr>
            </thead>
            <tbody>

<!-- METRIC_SUMMARY_HERE -->
  
  </tbody>
          </table>
        </div>
</div>
</div>
</div>
</div>
<!-- <div id="container"> -->
</body>
</html>   }

exec mkdir -p $gps_run_dir/adsRpt/work/$d_name/.HTMLS

#Creating HTML Templates

set fp_main_html_page_template [open "$gps_run_dir/adsRpt/work/$d_name/.HTMLS/.main_template.html" w];
puts $fp_main_html_page_template $main_html_page_template;
close $fp_main_html_page_template;

set fp_domain_voltage_html_page [open "$gps_run_dir/adsRpt/work/$d_name/.HTMLS/.gps_net_voltage.html" w];
puts $fp_domain_voltage_html_page $domain_voltage_html_page;
close $fp_domain_voltage_html_page;

set fp_metal_density_page_html [open "$gps_run_dir/adsRpt/work/$d_name/.HTMLS/.metal_density.html" w];
puts $fp_metal_density_page_html $metal_density_page_html;
close $fp_metal_density_page_html;

set fp_layer_specific_metal_density_page_html [open "$gps_run_dir/adsRpt/work/$d_name/.HTMLS/.layer_specific_md.html" w];
puts $fp_layer_specific_metal_density_page_html $layer_specific_metal_density_page_html;
close $fp_layer_specific_metal_density_page_html;

set fp_power_summary_page_html [open "$gps_run_dir/adsRpt/work/$d_name/.HTMLS/.power_summary.html" w];
puts $fp_power_summary_page_html $power_summary_page_html;
close $fp_power_summary_page_html;

set fp_resistance_page_html [open "$gps_run_dir/adsRpt/work/$d_name/.HTMLS/.resistance.html" w];
puts $fp_resistance_page_html $resistance_page_html;
close $fp_resistance_page_html;

set fp_ir_summary_page_html [open "$gps_run_dir/adsRpt/work/$d_name/.HTMLS/.static_ir.html" w];
puts $fp_ir_summary_page_html $ir_summary_page_html;
close $fp_ir_summary_page_html;

set fp_domain_ir_page_html [open "$gps_run_dir/adsRpt/work/$d_name/.HTMLS/.domain_specific_ir.html" w];
puts $fp_domain_ir_page_html $domain_ir_page_html;
close $fp_domain_ir_page_html;

set fp_layer_ir_page_html [open "$gps_run_dir/adsRpt/work/$d_name/.HTMLS/.layer_specific_ir.html" w];
puts $fp_layer_ir_page_html $layer_ir_page_html;
close $fp_layer_ir_page_html;

set fp_em_page_html [open "$gps_run_dir/adsRpt/work/$d_name/.HTMLS/.em_results.html" w];
puts $fp_em_page_html $em_page_html;
close $fp_em_page_html;

set fp_session_main_page_html [open "$gps_run_dir/adsRpt/work/$d_name/.HTMLS/.session_summary_main_page.html" w];
puts $fp_session_main_page_html $session_main_page_html;
close $fp_session_main_page_html;

set fp_session_page_html [open "$gps_run_dir/adsRpt/work/$d_name/.HTMLS/.session_summary.html" w];
puts $fp_session_page_html $session_page_html;
close $fp_session_page_html;

set fp_fom_html  [open "$gps_run_dir/adsRpt/work/$d_name/.HTMLS/.fom.html" w];
puts $fp_fom_html $fom_html ;
close $fp_fom_html;

#HTML CREATION STAGE
setup_main_html -html_template $gps_run_dir/adsRpt/work/$d_name/.HTMLS/.main_template.html -results_dir $gps_run_dir/adsRHE/reports/ -out_dir $gps_run_dir/adsRpt/work/$d_name/.HTMLS

setup_metal_density_html -html_template $gps_run_dir/adsRpt/work/$d_name/.HTMLS/.metal_density.html -results_dir $gps_run_dir/adsRHE/reports/ -out_dir $gps_run_dir/adsRpt/work/$d_name/.HTMLS

setup_layer_md_html -html_template $gps_run_dir/adsRpt/work/$d_name/.HTMLS/.layer_specific_md.html -results_dir $gps_run_dir/adsRHE/reports/ -out_dir $gps_run_dir/adsRpt/work/$d_name/.HTMLS

setup_power_summary_html -html_template $gps_run_dir/adsRpt/work/$d_name/.HTMLS/.power_summary.html -results_dir $gps_run_dir/adsRHE/reports/ -out_dir $gps_run_dir/adsRpt/work/$d_name/.HTMLS

setup_resistance_html -html_template $gps_run_dir/adsRpt/work/$d_name/.HTMLS/.resistance.html -results_dir $gps_run_dir/adsRHE/reports/ -out_dir $gps_run_dir/adsRpt/work/$d_name/.HTMLS

setup_ir_html -html_template $gps_run_dir/adsRpt/work/$d_name/.HTMLS/.static_ir.html -results_dir $gps_run_dir/adsRHE/reports/ -out_dir $gps_run_dir/adsRpt/work/$d_name/.HTMLS

setup_layer_ir_html -html_template $gps_run_dir/adsRpt/work/$d_name/.HTMLS/.layer_specific_ir.html -results_dir $gps_run_dir/adsRHE/reports/ -out_dir $gps_run_dir/adsRpt/work/$d_name/.HTMLS

setup_domain_ir_html -html_template $gps_run_dir/adsRpt/work/$d_name/.HTMLS/.domain_specific_ir.html -results_dir $gps_run_dir/adsRHE/reports/ -out_dir $gps_run_dir/adsRpt/work/$d_name/.HTMLS

setup_domain_voltage_summary_html -html_template $gps_run_dir/adsRpt/work/$d_name/.HTMLS/.gps_net_voltage.html -results_dir $gps_run_dir/adsRHE/reports/ -out_dir $gps_run_dir/adsRpt/work/$d_name/.HTMLS

setup_em_summary_html -html_template $gps_run_dir/adsRpt/work/$d_name/.HTMLS/.em_results.html -results_dir $gps_run_dir/adsRHE/reports/ -out_dir $gps_run_dir/adsRpt/work/$d_name/.HTMLS

setup_sessions_main_page_html -html_template $gps_run_dir/adsRpt/work/$d_name/.HTMLS/.session_summary_main_page.html -results_dir $gps_run_dir/adsRHE/reports/ -out_dir $gps_run_dir/adsRpt/work/$d_name/.HTMLS -session_count $clone_count

setup_session_summary_html -html_template $gps_run_dir/adsRpt/work/$d_name/.HTMLS/.session_summary.html -results_dir $gps_run_dir/adsRHE/reports -out_dir $gps_run_dir/adsRpt/work/$d_name/.HTMLS

setup_session_summary_html -html_template $gps_run_dir/adsRpt/work/$d_name/.HTMLS/.session_summary.html -results_dir $gps_run_dir/adsRHE/reports -out_dir $gps_run_dir/adsRpt/work/$d_name/.HTMLS

setup_FOM_page_html -html_template $gps_run_dir/adsRpt/work/$d_name/.HTMLS/.fom.html -results_dir $gps_run_dir/adsRHE/reports -out_dir $gps_run_dir/adsRpt/work/$d_name/.HTMLS -session_count $clone_count

#Launching Explorer

set rh_command_file [open "$gps_run_dir/adsRpt/work/$d_name/.run_explorer.cmd" w];

puts $rh_command_file " exec cp \$env(APACHEROOT)/scripts/rhe.rdb adsRHE/.rhe.rdb
##rhe_copy  \"/nfs/sjo2ae384-1.data2/rmekala/GPS/GPS-Explorer/Testcases/GPS_Tutorial/02.static_run/sorttable.js\" \"js/sorttable.js\"
##rhe_copy \"/home/rmekala/GPS-Explorer_watermark.png\" \"rh_gps_exploer_logo.png\"
rhe_nx::rhe_copy_tcl \"$gps_run_dir/adsRpt/work/$d_name/.HTMLS/ir.html\" \"adsRHE/static_ir.html\"
rhe_nx::rhe_copy_tcl \"$gps_run_dir/adsRpt/work/$d_name/.HTMLS/power.html\" \"adsRHE/power_summary.html\"
rhe_nx::rhe_copy_tcl \"$gps_run_dir/adsRpt/work/$d_name/.HTMLS/metal_density.html\" \"adsRHE/metal_density.html\"
rhe_nx::rhe_copy_tcl \"$gps_run_dir/adsRpt/work/$d_name/.HTMLS/em.html\" \"adsRHE/em_results.html\"
rhe_nx::rhe_copy_tcl \"$gps_run_dir/adsRpt/work/$d_name/.HTMLS/resistance.html\" \"adsRHE/resistance_summary.html\"
rhe_nx::rhe_copy_tcl \"$gps_run_dir/adsRpt/work/$d_name/.HTMLS/sessions_main.html\" \"adsRHE/session_summary.html\"
rhe_nx::rhe_copy_tcl \"$gps_run_dir/adsRpt/work/$d_name/.HTMLS/figure_of_merit.html\" \"adsRHE/figure_of_merit.html\"
##rhe_copy \"/nfs/sjo2ae384-1.data2/rmekala/GPS/GPS-Explorer/Testcases/GPS_Tutorial/02.static_run/Results/design_snapshot.jpeg\" \"chip_layout.jpeg\"
rhe_nx::rhe_copy_tcl \"$gps_run_dir/adsRpt/work/$d_name/.HTMLS/main.html\" \"adsRHE/index.html\"
rhe_nx::rhe_copy_tcl \"$gps_run_dir/adsRpt/work/$d_name/.HTMLS/net_voltage.html\" \"adsRHE/gps_net_voltage.html\"
source $gps_run_dir/adsRpt/work/$d_name/.HTMLS/layer_specific_sessions_ir_rhe_copy.rpt
source $gps_run_dir/adsRpt/work/$d_name/.HTMLS/domain_specific_sessions_ir_rhe_copy.rpt
source $gps_run_dir/adsRpt/work/$d_name/.HTMLS/sessions_rhe_copy.rpt
source $gps_run_dir/adsRpt/work/$d_name/.HTMLS/layer_specific_sessions_md_rhe_copy.rpt
if {[catch {file delete -force $gps_run_dir/adsRpt/work/$d_name/.HTMLS/*.html}]} {
}

puts \" \"
puts \" \"
puts \" \"
puts \" \"
puts \" \"
puts \" \"
puts \" \"
puts \" \"
explore design -view "

close $rh_command_file;

exec redhawk -f $gps_run_dir/adsRpt/work/$d_name/.run_explorer.cmd &

}

proc create_parametric_sweep { args } {

set state flag

regsub -all -- {[[:space:]]+} $args " " args

set argv [split $args]

global env

global autopath

global json_file

global output_file

global flag_create_clone_files

global flag_launch_explorer

global create_jsons

global clone_stype

global clone_spin_pair

global clone_sregion_name

unset -nocomplain  clone_stype

unset -nocomplain  clone_spin_pair

unset -nocomplain  clone_sregion_name

unset -nocomplain json_file

unset -nocomplain output_file

unset -nocomplain flag_create_clone_files

unset -nocomplain create_jsons

unset -nocomplain flag_launch_explorer
unset -nocomplain autopath 

 

  global excel2json

  global design_name

  global tech_file

  global lef_file

  global def_size

  global def_file

  global switch_model_file

  global pad_file

  global bump_cell

  global temperature

  unset -nocomplain excel2json

  unset -nocomplain design_name

  unset -nocomplain tech_file

  unset -nocomplain lef_file

  unset -nocomplain def_size

  unset -nocomplain def_file

  unset -nocomplain switch_model_file

  unset -nocomplain pad_file

  unset -nocomplain bump_cell

  unset -nocomplain temperature

global block_data

unset -nocomplain block_data

global read_switch

global count_clones_switch

unset -nocomplain count_clones_switch

unset -nocomplain read_switch

global count_nets

unset -nocomplain count_nets

  global lib_file

unset -nocomplain lib_file

 

global count_block

unset -nocomplain count_block

global pad_data

unset -nocomplain pad_data

global count_blocks

unset -nocomplain count_blocks

global default_voltage

unset -nocomplain default_voltage

global count_layer

unset -nocomplain count_layer

global layer_data

unset -nocomplain layer_data

global power_number

unset -nocomplain power_number

global Pin_tap_data

unset -nocomplain  Pin_tap_data

global old_switch_xpitch

unset -nocomplain  old_switch_xpitch

global old_switch_ypitch

unset -nocomplain  old_switch_ypitch

global old_pad_xpitch

global old_pad_ypitch

global old_lwchange

global old_powerpitch

global old_lspacing

global old_lviamodel

global old_lviarule

global old_lviacut

global old_lexclude

global old_llength

global old_lgap

global old_lpitch

global old_lwidth

global delete_wire

global old_delete_wire

unset -nocomplain old_pad_xpitch

unset -nocomplain old_pad_ypitch

unset -nocomplain old_lwchange

unset -nocomplain old_powerpitch

unset -nocomplain old_lspacing

unset -nocomplain old_lviamodel

unset -nocomplain old_lviarule

unset -nocomplain old_lviacut

unset -nocomplain old_lexclude

unset -nocomplain old_llength

unset -nocomplain old_lgap

unset -nocomplain old_lpitch

unset -nocomplain old_lwidth

unset -nocomplain delete_wire

unset -nocomplain old_delete_wire

global old_vviamodel

global old_vviarule

global batch_option
global post_tcl
unset -nocomplain post_tcl

unset -nocomplain batch_option

unset -nocomplain  old_vviamodel

unset -nocomplain  old_vviarule

 

#### Default Settings

global cur_dir

global output_file

global flag_create_clone_files

global flag_launch_explorer

global create_jsons

global analysistype

set analysistype "static"

set cur_dir [exec pwd]

set output_file "$cur_dir/run_script.tcl"

set flag_create_clone_files 0

set flag_launch_explorer 1

set create_jsons 0

set  batch_option  1


set autopath "/home/sramacha/json_parsing/json_package/" 
#### Default Settings - END

 

foreach arg $argv {

 

                switch -- $state {

                        flag {

                                switch -glob -- $arg {

 

                                        -i { set state input }

                                        -o { set state output }

                                        -run_setup_script {set state run_setup}

                                        -create_clone_files { set state create_clone_files}

                                        -launch_explorer {set state launch_explorer}

                                        -create_jsons {set state create_jsons}

                                        -analysis_type {set state anatype}

                                        -json_package_path {set state auto_path}

                                        -batch_option {set state batchoption}

                                        -post_tcl {set state posttcl}

                                }

                        }

 

                        input {

                        global json_file

                        set json_file $arg

                        set state flag

                        }

 

                        output {

                        set output_file $arg

                        set state flag

                        }

                        run_setup_script {

                        set run_setup_script $arg

                        set state flag

                        }

                        create_clone_files {

                        set flag_create_clone_files $arg

                        set state flag

                        }

                        launch_explorer {

                        set flag_launch_explorer $arg

                        set state flag

                        }

                        create_jsons {

                        set create_jsons $arg

                        set state flag

                        }
                        batchoption {

                        set batch_option $arg

                        set state flag

                        }

                        posttcl {

                        set post_tcl $arg

                        set state flag

                        }


                        auto_path {

                        set autopath $arg

                        set state flag

                        }

                        anatype {

                        set analysistype $arg

                        set state flag

                        }

 

 

                }

 

}


if { ![info exists json_file ] } {

puts stderr "Please provide a json file"

return

}

set ::auto_path [ concat $::auto_path $autopath ]

if {[catch {package require json}]==1} {
puts "Please point to the json_package "
}

 

set jf [open "$json_file" r]

set data [read $jf]

global infile

set infile [ json::json2dict $data ]

 

### process for reading global inputs

read_floorplan

### process for reading global inputs - END

 

### Create Tcl files

create_tcl_files

### Create Tcl files - END

 

}

 

proc read_floorplan {} {

global infile

if { [dict exists $infile Mode_excel2json] } {

  global excel2json

  set excel2json [dict get $infile Mode_excel2json]

}

 

if { [dict exists $infile Power_assignment_file] } {

  global power_assignment_file

  set power_assignment_file [dict get $infile Power_assignment_file]

}

 

if { [dict exists $infile Additional_gsr_settings] } {

  global additional_gsr_settings

  set additional_gsr_settings [dict get $infile Additional_gsr_settings]

}

 

if { [dict exists $infile Design_name] } {

  global design_name

  set design_name [dict get $infile Design_name]

}

 

if { [dict exists $infile Techfile] } {

  global tech_file

  set tech_file [dict get $infile Techfile]

}

 

if { [dict exists $infile Lib_file] } {

  global lib_file

  set lib_file [dict get $infile Lib_file]

}

 

if { [dict exists $infile Leffile] } {

  global lef_file

  set lef_file [dict get $infile Leffile]

}

 

if { [dict exists $infile Diesize] } {

  global def_size

  set def_size [dict get $infile Diesize]

}

global offset

set offset "0 0 0 0"

if { [dict exists $infile Offset] } {

  set offset [dict get $infile Offset]

}

 

if { [dict exists $infile Def_file] } {

  global def_file

  set def_file [dict get $infile Def_file]

}

 

 

if { [dict exists $infile Switch_model_file] } {

  global switch_model_file

  set switch_model_file [dict get $infile Switch_model_file]

}

 

if { [dict exists $infile Pad_loc_file] } {

  global pad_file

  set pad_file [dict get $infile Pad_loc_file ]

}

if { [dict exists $infile Bump_cell_loc_file] } {

set readline [dict get $infile Bump_cell_loc_file]

  global bump_cell

  dict for { name value } $readline {

        set bump_cell($name) $value

        }

}

 

 

if { [dict exists $infile Temp] } {

  global temperature

  set temperature [dict get $infile Temp]

}

 

if { [dict exists $infile Switch] } {

  set switch_data [dict get $infile Switch]

### reading swicth data

  read_switch_data $switch_data noring

### reading swicth data - END

}

 

if { [dict exists $infile Switch_around_block] } {

  set switch_around_block_data [dict get $infile Switch_around_block]

### reading switch_around_block_data data

  read_switch_data $switch_around_block_data ring

### reading switch_around_block_data data - END

}

 

if { [dict exists $infile Nets] } {

global nets_data

  set nets_data [dict get $infile Nets]

### reading nets data

  read_nets_data $nets_data

### reading nets data - END

}

 

if { [dict exists $infile Via_mesh] } {

  set read_data [dict get $infile Via_mesh]

  set type "viamesh"

### reading via mesh data

  read_block_data $read_data $type

### reading via mesh data - END

}

 

if { [dict exists $infile Ring_spec] } {

  set read_data [dict get $infile Ring_spec]

  set type "ringspec"

### reading Ring_spec data

  read_block_data $read_data $type

### reading Ring_spec data - END

}

 

if { [dict exists $infile Floor_plan] } {

  set read_data [dict get $infile Floor_plan]

  set type "fp"

### reading fp_blocks data

  read_block_data $read_data $type

### reading fp_blocks data - END

}

 

if { [dict exists $infile Probes] } {

  set read_data [dict get $infile Probes]

  set type "probes"

### reading probes data

  read_block_data $read_data $type

### reading probes data - END

}

 

if { [dict exists $infile Sim2iprof] } {

  set read_sim2iprof_data [dict get $infile Sim2iprof]

### reading sim2iprof data

  read_sim2iprof $read_sim2iprof_data

### reading sim2iprof data - END

}

 

 

}

 

 

proc read_block_data { read_data type} {

global count_block

set count_block($type) 0

foreach block3 [dict keys $read_data] {

   incr count_block($type)

   global block

   regsub -all ":" $block3 " " block2

   regsub -all -- {[[:space:]]+} $block2 " " block2

   split $block2

   regsub -all {\{|\}} $block2 "" block2

   set block($type,$count_block($type)) $block3

   global block_data

   set block_data($type,$block3,$count_block($type),Name)  [lindex $block2 1]

   dict for {name value } [dict get $read_data $block3] {

        set block_data($type,$block3,$count_block($type),$name) $value

   }

}

}

 

proc read_sim2iprof { read_data} {

set count sim_block 0

foreach block3 [dict keys $read_data] {

   regsub -all  ":" $block3 " " block2

   regsub -all -- {[[:space:]]+} $block2 " " block2

   split $block2

   regsub -all {\{|\}} $block2 "" block2

   incr count_sim_block

   global block_sim

   set block1 [lindex $block2 0]

   set block_sim($count_fp_block) $block1

   set block_sim_data($block1,$name) [lindex $block2 1]

   set count_netpair 0

   foreach net_pair [dict get $read_data $block1] {

   incr count_netpair

   global net_sim_pair

   set net_sim_pair($block1,$count_netpair) $net_pair

   dict for {name value } [dict get $read_data $block3 $net_pair] {

        global block_sim_data

        set block_sim_data($block1,$name) $value

   }

   }

}

}

 

 

 

proc read_switch_data { switch_data ring} {

   global count_switch

global count_region_switch

set count_switch($ring) 0

foreach pin_pair [ dict keys $switch_data ] {

set count_region 0

   incr count_switch($ring)

   global switch_pin_pair

   set switch_pin_pair($ring,$count_switch($ring)) $pin_pair

   foreach region3 [ dict keys [ dict get $switch_data $pin_pair]] {

   incr count_region

   global switch_region

   regsub -all  ":" $region3 " " region2

   regsub -all -- {[[:space:]]+} $region2 " " region2

   split $region2

   regsub  -all {\{|\}} $region2 "" region2

   set region [lindex $region2 0]

   set switch_region($ring,$switch_pin_pair($ring,$count_switch($ring)),$count_region) $region3

        global read_switch

        set  read_switch($ring,$switch_pin_pair($ring,$count_switch($ring)),$region3,Name) [lindex $region2 1]

        dict for {name value} [ dict get $switch_data $pin_pair $region3] {

        set read_switch($ring,$switch_pin_pair($ring,$count_switch($ring)),$region3,$name) $value

        }

   }

        set count_region_switch($ring,$pin_pair) $count_region

}

 

}

 

proc read_nets_data { nets_data } {

global count_nets

set count_nets 0

foreach nets_pair [ dict keys $nets_data] {

set count_region 0

  incr count_nets

   global count_blocks

  set count_blocks($nets_pair,$count_nets) 0

  global net_pair

  set net_pair($count_nets) $nets_pair

  foreach netkey [dict keys [ dict get $nets_data $net_pair($count_nets)]] {

  if { [regexp "$netkey" Split_grid ] } {

  global split_grid

  set split_grid($net_pair($count_nets)) [dict get $nets_data $net_pair($count_nets)  Split_grid]

  }

 

  if { [regexp "$netkey"  Offset ] } {

  global default_offset

  set default_offset($net_pair($count_nets)) [dict get $nets_data $net_pair($count_nets)  Offset]

  }

 

  if { [regexp "$netkey"  Width ] } {

  global default_width

  set default_width($net_pair($count_nets)) [dict get  $nets_data $net_pair($count_nets)  Width]

  }

 

  if { [regexp "$netkey"  Spacing ] } {

  global default_spacing

  set default_spacing($net_pair($count_nets)) [dict get  $nets_data $net_pair($count_nets)  Spacing]

  }

  if { [regexp "$netkey"  Voltage ] } {

  global default_voltage

  set default_voltage($net_pair($count_nets)) [dict get  $nets_data $net_pair($count_nets)  Voltage]

  }

 

  if { [regexp "$netkey"  Pitch ] } {

  global default_Pitch

  set default_Pitch($net_pair($count_nets)) [dict get  $nets_data $net_pair($count_nets) Pitch]

  }

 

  if { [regexp "$netkey"  Length ] } {

  global default_length

  set default_length($net_pair($count_nets)) [dict get  $nets_data $net_pair($count_nets)  Length]

 }

 

  if { [regexp "$netkey"  Gap ] } {

  global default_gap

  set default_gap($net_pair($count_nets)) [dict get  $nets_data $net_pair($count_nets)  Gap]

  }

 

  if { [regexp "$netkey"  Exclude ] } {

  global default_exclude

  set default_exclude($net_pair($count_nets)) [dict get  $nets_data $net_pair($count_nets)  Exclude]

  }

 

  if { [regexp "$netkey"  Include ] } {

  global default_include

  set default_include($net_pair($count_nets)) [dict get  $nets_data $net_pair($count_nets)  Include]

  }

 

  if { [regexp "$netkey"  Pad ] } {

  dict for { name value} [dict get $nets_data $net_pair($count_nets)  Pad ]  {

        global pad_data

        set pad_data($net_pair($count_nets),$count_nets,$name) $value

        set pad_data($net_pair($count_nets),$count_nets,exists) 1

  }

  }

  if {[regexp "BLOCK" $netkey] || [regexp "REGION" $netkey]} {

   set d_block $netkey

   set dblock  1

    read_nets_block_data $count_nets $d_block $dblock

  }

  if { [regexp "$netkey"  Metal_layers ] } {

   set d_block 0

   set dblock 0

    read_nets_block_data $count_nets $d_block $dblock

  }

 

 

}

}

}

 

proc read_nets_block_data {count_nets d_block3 dblock} {

global nets_data

global net_pair

global count_blocks

global count_layer

global design_name

global block_name

if {$dblock == 1 } {

   regsub  -all ":" $d_block3 " " d_block2

   regsub -all -- {[[:space:]]+} $d_block2 " " d_block2

   split $d_block2

   regsub  -all {\{|\}} $d_block2 "" d_block2

  set d_block $d_block3

  incr count_blocks($net_pair($count_nets),$count_nets)

  global block_name

if {[lindex $d_block2 2] ne ""} {

  set block_name($net_pair($count_nets),$count_nets,$count_blocks($net_pair($count_nets),$count_nets)) "[lindex $d_block2 1] [lindex $d_block2 2]"

} else {

  set block_name($net_pair($count_nets),$count_nets,$count_blocks($net_pair($count_nets),$count_nets)) "[lindex $d_block2 1]"

 

}

  if {$block_name($net_pair($count_nets),$count_nets,$count_blocks($net_pair($count_nets),$count_nets)) eq ""} {

  puts stderr "Please use proper Block name for net $net_pair($count_nets). The syntax is BLOCK:<block_name>"

  return

  }

  set count_layers 0

  if { [dict exists [dict get $nets_data $net_pair($count_nets) $d_block] Metal_layers ] } {

   foreach layer [ dict keys [ dict get $nets_data $net_pair($count_nets) $d_block Metal_layers] ] {

        incr count_layers

        global layer_name

        set layer_name($net_pair($count_nets),$block_name($net_pair($count_nets),$count_nets,$count_blocks($net_pair($count_nets),$count_nets)),$count_layers) $layer

        foreach  name  [dict keys  [ dict get $nets_data $net_pair($count_nets) $d_block Metal_layers $layer]] {

                if { [ regexp "^$name\$"  Power] } {

                global power_number

                set power_number($net_pair($count_nets),$block_name($net_pair($count_nets),$count_nets,$count_blocks($net_pair($count_nets),$count_nets)),$count_layers,$layer,$name) [dict get $nets_data $net_pair($count_nets) $d_block Metal_layers  $layer Power Power_number ]

                } elseif {[regexp "^$name\$"  Pin_tap]} {

                global Pin_tap_data

                set Pin_tap_data($net_pair($count_nets),$block_name($net_pair($count_nets),$count_nets,$count_blocks($net_pair($count_nets),$count_nets)),$count_layers,$layer,Pin_tap) "1"

                dict for {name value} [dict get $nets_data $net_pair($count_nets) $d_block Metal_layers $layer Pin_tap] {

                set Pin_tap_data($net_pair($count_nets),$block_name($net_pair($count_nets),$count_nets,$count_blocks($net_pair($count_nets),$count_nets)),$count_layers,$layer,$name) $value

                }

                } else {

                set value [dict get $nets_data $net_pair($count_nets) $d_block Metal_layers $layer $name]

                global layer_data

                set layer_data($net_pair($count_nets),$block_name($net_pair($count_nets),$count_nets,$count_blocks($net_pair($count_nets),$count_nets)),$count_layers,$layer,$name) $value

                }

        }

 

     }

     set count_layer($net_pair($count_nets),$block_name($net_pair($count_nets),$count_nets,$count_blocks($net_pair($count_nets),$count_nets))) $count_layers

   }

 

} else {

 

  incr count_blocks($net_pair($count_nets),$count_nets)

  set block_name($net_pair($count_nets),$count_nets,$count_blocks($net_pair($count_nets),$count_nets)) "$design_name"

 

   set count_layers 0

  if { [dict exists [dict get $nets_data $net_pair($count_nets) ] Metal_layers ] } {

   foreach layer [ dict keys [ dict get $nets_data $net_pair($count_nets) Metal_layers] ] {

        incr count_layers

        global layer_name

        set layer_name($net_pair($count_nets),$block_name($net_pair($count_nets),$count_nets,$count_blocks($net_pair($count_nets),$count_nets)),$count_layers) $layer

        foreach  name  [dict keys  [ dict get $nets_data $net_pair($count_nets) Metal_layers $layer]] {

                if { [ regexp "^$name\$"  Power] } {

                global power_number

                set power_number($net_pair($count_nets),$block_name($net_pair($count_nets),$count_nets,$count_blocks($net_pair($count_nets),$count_nets)),$count_layers,$layer,$name) [dict get $nets_data $net_pair($count_nets) Metal_layers  $layer Power Power_number ]

                } elseif {[regexp "^$name\$"  Pin_tap]} {

                global Pin_tap_data

                set Pin_tap_data($net_pair($count_nets),$block_name($net_pair($count_nets),$count_nets,$count_blocks($net_pair($count_nets),$count_nets)),$count_layers,$layer,Pin_tap) "1"

               dict for {name value} [dict get $nets_data $net_pair($count_nets) Metal_layers $layer Pin_tap] {

                set Pin_tap_data($net_pair($count_nets),$block_name($net_pair($count_nets),$count_nets,$count_blocks($net_pair($count_nets),$count_nets)),$count_layers,$layer,$name) $value

                }

                } else {

                set value [dict get $nets_data $net_pair($count_nets) Metal_layers $layer $name]

                global layer_data

                set layer_data($net_pair($count_nets),$block_name($net_pair($count_nets),$count_nets,$count_blocks($net_pair($count_nets),$count_nets)),$count_layers,$layer,$name) $value

                }

        }

 

     }

     set count_layer($net_pair($count_nets),$block_name($net_pair($count_nets),$count_nets,$count_blocks($net_pair($count_nets),$count_nets))) $count_layers

   }

 

}

}

 

proc create_tcl_files {} {
global batch_option

  global cur_dir

  global offset

  global output_file

  global done

  global old_switch_xpitch

  global old_switch_xpitch

  global clone

  global count_switch

  global switch_pin_pair

  global block

  global block_data

  global count_block

  global excel2json

  global design_name

  global tech_file

  global lef_file

  global def_size

  global def_file

  global switch_model_file

  global pad_file

  global bump_cell

  global temperature

  global outfile

  global log

global output_file

global flag_create_clone_files

global count_nets

global old_pad_xpitch

global old_pad_xpitch

global old_lwchange

global additional_gsr_settings

global env

  global lib_file


if {[catch {exec rm -rf $cur_dir/gps_res_source}]} {

}

global post_tcl

#if {[catch {puts $outfile "config set rh_post_analysis_tcl \{$post_tcl\}"}]==0} {}
set ressourcefile [open "$cur_dir/gps_res_source" "w"]
puts $ressourcefile "get_data_gc_rc_mrp"
if {[catch {set posttclfile [open $post_tcl "r"]}]==0} {

while {[gets $posttclfile read_posttclline] >= 0} {

puts $ressourcefile $read_posttclline
}
}

close $ressourcefile

if {[catch { exec rm -rf .sourcedef}] == 0} {

}

if {[catch { exec rm -rf .sourcelef}]} {}

set source_lef_file [open ".sourcelef" w]

set log [open "json.log" w ]

set outfile [open "$output_file" w]

 

puts $log "Global settings"

flush $log

puts $outfile "source $env(APACHEROOT)/scripts/atcl/gps_utils.tcl"

flush $outfile

puts "source $env(APACHEROOT)/scripts/atcl/gps_utils.tcl"


if {[ catch {puts $outfile "config set tech \{$tech_file\}"}] == 0} {

flush $outfile

if {[catch { exec rm -rf .sourcetech}]} {}

set source_tech_file [open ".sourcetech" w]

puts $log "Setting Tech file - Done"

flush $log

puts $source_tech_file "config set tech \{$tech_file\}"

close $source_tech_file

}

 

if {[ catch {puts $outfile "config set TEMPERATURE \{$temperature\}"}] == 0} {

flush $outfile

puts $log "Setting Temperature file - Done"

flush $log

}

 

if {[ catch {puts $outfile "config set libs  \{$lib_file\}"}] == 0} {

flush $outfile

puts $log "Setting Lib file - Done"

flush $log

}

 

if {[ catch {puts $outfile "data read lefs \{$lef_file\}"}] == 0} {

flush $outfile

puts $source_lef_file "data read lefs \{$lef_file\}"

puts $log "Setting  lef file - Done"

flush $log

}

 

if {[ catch {puts $outfile "data read switch_model \{$switch_model_file\}"}] == 0} {

flush $outfile

puts $source_lef_file "data read switch_model \{$switch_model_file\}"

puts $log "Setting  switch_model file - Done"

flush $log

}

close $source_lef_file

source .sourcelef

 

if { [info exists def_file] } {

if {[catch { exec rm -rf .sourcedef}]} {}

set source_def_file [open ".sourcedef" w]

set floorplan 0

puts $outfile "data read defs \{$def_file\}"

flush $outfile

puts $source_def_file "data read defs \{$def_file\}"

puts $log "Setting  def file - Done"

flush $log

puts $outfile "db open cell /work/$design_name"

flush $outfile

close $source_def_file

}

if  {[catch {source .sourcedef} ]==0} {}

if {![info exists def_file] && [info exists def_size] } {

set floorplan 1

regsub -nocase "x" $def_size " " def_size

split $def_size

regsub  -all {\{|\}} $def_size "" def_size

set width [lindex $def_size 0]

set height [lindex $def_size 1]

 

regsub -all -- {[[:space:]]+} $offset " " offset

split $offset

regsub  -all {\}|\{} $offset " " offset

puts $outfile "db create floorplan -name $design_name -offsets { $offset } -size {$width $height} -origin {0 0}"

flush $outfile

puts $outfile "db open cell /work/$design_name"

flush $outfile

puts $log "Create the floorplan - Done"

flush $log

}

puts $outfile "\nauto_gui_update off "

flush $outfile

if {[info exists count_block(fp) ]} {

if { $count_block(fp) > 0} {

 

for {set i 1 } {$i <= $count_block(fp)} {incr i} {

if {[regexp "BLOCK" $block(fp,$i)]} {

if {![info exists block_data(fp,$block(fp,$i),$i,Cellname)]} {

puts $log "Please provide the valid cell name for $block_data(fp,$block(fp,$i),$i,Name)"

flush $log

puts stderr "Please provide the valid cell name for $block_data(fp,$block(fp,$i),$i,Name)"

return

}

puts $outfile "db create inst /work/$design_name -name $block_data(fp,$block(fp,$i),$i,Name) -loc {$block_data(fp,$block(fp,$i),$i,Xloc) $block_data(fp,$block(fp,$i),$i,Yloc)}  -master /work/$block_data(fp,$block(fp,$i),$i,Cellname)"

flush $outfile

puts $log "Create Block $block(fp,$i)- Done"

flush $log

} elseif {[regexp "REGION" $block(fp,$i)]} {

if {![info exists block_data(fp,$block(fp,$i),$i,Width)] && ![info exists block_data(fp,$block(fp,$i),$i,Height)]} {

puts $log "Please provide the valid details for $block_data(fp,$block(fp,$i),$i,Name)"

flush $log

puts stderr "Please provide the valid details for $block_data(fp,$block(fp,$i),$i,Name)"

return

}

if {[info exists def_file] } {

if {[regexp "import_all" $def_file]} {

if {[regexp "REGION" $block(fp,$i)]} {

puts $log "Creation of regions are not accepted in routed DEF case"

flush $log

puts stderr  "Creation of regions are not accepted in routed DEF case"

return

}

}

}

puts $outfile "db create region /work/$design_name -name $block_data(fp,$block(fp,$i),$i,Name)  -rect {$block_data(fp,$block(fp,$i),$i,Xloc) $block_data(fp,$block(fp,$i),$i,Yloc) [expr {$block_data(fp,$block(fp,$i),$i,Xloc) + $block_data(fp,$block(fp,$i),$i,Width)}] [expr {$block_data(fp,$block(fp,$i),$i,Yloc) + $block_data(fp,$block(fp,$i),$i,Height)}]}"

flush $outfile

puts $log "Create Block $block(fp,$i)- Done"

flush $log

}

}

}

}

 

if {[ catch {puts $outfile "config set ploc_files \{ $pad_file\}"}] == 0} {

flush $outfile

puts $log "Setting  pad file - Done"

flush $log

}

 

puts $outfile "config set rh_post_analysis_tcl {$cur_dir/gps_res_source}"

flush $outfile

 

if {[info exists additional_gsr_settings]} {

if {$additional_gsr_settings ne ""} {

set addgsrfile [open "$additional_gsr_settings" "r"]

puts $outfile "config set additional_gsr_settings \{"

flush $outfile

while {[gets $addgsrfile read_gsrline] >= 0} {

puts $outfile $read_gsrline

flush $outfile

}

puts $outfile "\}"

flush $outfile

close $addgsrfile

}

}

if { [info exists count_nets] && $count_nets > 0} {

set clone 0

create_voltage

}

if { [info exists count_switch(noring)] } {

if { $count_switch(noring) >0} {

####

set clone 0

create_switch_tcl  $clone

####

}

}

##### Creating Tcl for Route mesh

if { [info exists count_nets] && $count_nets > 0} {

set clone 0

create_net_route_tcl

create_net_pad_tcl

}

 

##### Creating Tcl for Via mesh

if { [info exists count_block(viamesh)]} {

if {$count_block(viamesh)> 0} {

set clone 0

create_via_tcl

}

}

##### Creating Tcl for Via mesh - END

 

puts $outfile "\nauto_gui_update on"

flush $outfile

puts $outfile "refresh_gui"

flush $outfile

global analysistype


if {$batch_option == 0} {
puts $outfile  "rh perform analysis /work/$design_name -$analysistype"
} else {
puts $outfile  "rh perform analysis /work/$design_name -$analysistype -batch"
}
flush $outfile

#### creating clones.tcl

if {$flag_create_clone_files ==1 } {

if {[catch {exec rm -rf clones_tcl}] == 0} {

}

if {[catch {exec mkdir clones_tcl}] == 0} {

}

close $outfile

file copy -force $output_file clones_tcl/parent.cmd

set outfile [open "$output_file" a]

puts $log "Creating parent.cmd - Done"

flush $log

}

#### creating clones.tcl -END

 

 

### Creating clones

set done 0

set clone 1

for {set i 1} {$i<= 10000000} {incr i} {

create_clones

if {$done == 1} {

break

#return

}

}

### Creating clones -END

 

 

close $log

close $outfile

}

proc find_cellname {inst_cell session} {

global design_name

global count_block

global block_data

global block

global log

global def_size

###### Deciding whethere the provided name under Switch is cell or instance name

                set present 0

                 if {[db exists /work/$inst_cell]} {

                if {![regexp "^$inst_cell\$" $design_name]} {

                 set open_cell 1

                 puts $outfile "db open cell /work/$inst_cell\::$session"

flush $outfile

                }

                 puts $log "Block placement of switches for $inst_cell  Opening cell for Block edits -Done"

flush $log

                set present 1

                 set dn "/work/$inst_cell\::$session"

                 set qcn "/work/$inst_cell"

                set xy [db query $qcn bbox]

                } elseif {[db exists /work/$design_name/$inst_cell] == 1} {

                set xy [db query $qcn bbox]

                set present 1

                set dn "/work/$design_name\::$session"

                 set qcn "/work/$design_name/$inst_cell"

                } else {

                if {[info exists def_size] && $def_size ne ""}  {

                if {[regexp "^$design_name\$" $inst_cell]} {

                 set dn "/work/$design_name\::$session"

                 set qcn "/work/$inst_cell"

                 set xy " 0 0 [lindex $def_size 0] [lindex $def_size 1]"

                 set present 1

                        }

                }

 

                if {[info exists count_block(fp)] && $count_block(fp) > 0} {

                for {set k 1} {$k<= $count_block(fp)} {incr k} {

                  if {[regexp "^$inst_cell\$" $block_data(fp,$block(fp,$k),$k,Name)]} {

                set present 1

                 set dn "/work/$design_name\::$session"

                 set qcn "/work/$design_name/$inst_cell"

                if {[regexp "REGION" $block(fp,$k)]} {

                set xy "$block_data(fp,$block(fp,$k),$k,Xloc) $block_data(fp,$block(fp,$k),$k,Yloc) [expr {$block_data(fp,$block(fp,$k),$k,Xloc)+$block_data(fp,$block(fp,$k),$k,Width)}]  [expr {$block_data(fp,$block(fp,$k),$k,Yloc)+$block_data(fp,$block(fp,$k),$k,Height)}]"

                        } else {

                set xy "$block_data(fp,$block(fp,$k),$k,Xloc) $block_data(fp,$block(fp,$k),$k,Yloc) [expr { $block_data(fp,$block(fp,$k),$k,Xloc) + [db query /work/$block_data(fp,$block(fp,$k),$k,Cellname) width] } ] [expr {$block_data(fp,$block(fp,$k),$k,Yloc) + [db query /work/$block_data(fp,$block(fp,$k),$k,Cellname) height]}] "

 

                }

                }

                }

                }

                }

 

                if {$present == 0} {

                puts $log "Please provide Valid block/region name $inst_cell"

flush $log

                puts stderr "Please provide Valid block/region name $inst_cell"

                return

                }

 

###### Deciding whethere the provided name under Switch is cell or instance name - END

 

return [list $dn $qcn $xy]

}

proc create_switch_tcl {clone} {

global flag_create_clone_files

global clonefile

    global count_clones_switch

    global design_name

    global old_switch_xpitch

    global old_switch_ypitch

   global count_switch

   global switch_region

   global read_switch

   global count_region_switch

   global switch_pin_pair

   global log

   global outfile

   global count_block

    global block_data

    global block

global clone_stype

global clone_spin_pair

global clone_sregion_name

global def_size

if {$clone > 0} {

set session c$clone

} else {

set session p

 

}

if {$count_switch(noring) > 0} {

for {set i 1} {$i<= $count_switch(noring)} {incr i} {

        for {set j 1} {$j<= $count_region_switch(noring,$switch_pin_pair(noring,$i))} {incr j} {

                set open_cell 0

###### Deciding whethere the provided name under Switch is cell or instance name

                if {[info exists clone_stype] && [info exists clone_spin_pair] && [info exists clone_sregion_name] } {

                if { ![regexp "^$clone_stype\$" noring] || ![regexp "^$clone_spin_pair\$" $switch_pin_pair(noring,$i)] || ![regexp "^$clone_sregion_name\$" $read_switch(noring,$switch_pin_pair(noring,$i),$switch_region(noring,$switch_pin_pair(noring,$i),$j),Name)]} {

                continue

                }

                }

                if {[catch {set inst_cell $read_switch(noring,$switch_pin_pair(noring,$i),$switch_region(noring,$switch_pin_pair(noring,$i),$j),Name)}] == 0 } {

                set result [find_cellname $inst_cell $session]

                } else {

                puts $log "Please provide Valid block/region name for the switch cell placement"

flush $log

                puts stderr "Please provide Valid block/region name for the switch cell placement"

                return

        }

###### Deciding whethere the provided name under Switch is cell or instance name - END

                split $result

                set dn [lindex $result 0]

                set qcn [lindex $result 1]

                set xy "[lindex $result 2] [lindex $result 3] [lindex $result 4] [lindex $result 5]"

                regsub  -all {\{|\}} $xy "" xy

 

###### Deleting the existing instances if delete_existing is one

                if {$clone == 0} {

                if {[info exists read_switch(noring,$switch_pin_pair(noring,$i),$switch_region(noring,$switch_pin_pair(noring,$i),$j),Delete_existing)]} {

                set delete_exist  $read_switch(noring,$switch_pin_pair(noring,$i),$switch_region(noring,$switch_pin_pair(noring,$i),$j),Delete_existing)

                } else {

                set delete_exist 0

                }

                if {$delete_exist == 1} {

                 puts $outfile "db foreach inst \"query $dn insts -type switch -master $read_switch(noring,$switch_pin_pair(noring,$i),$switch_region(noring,$switch_pin_pair(noring,$i),$j),Inst) -bbox \{$xy\}\" \{"

flush $outfile

                 puts $outfile "db delete $dn \$inst"

flush $outfile

                 puts $outfile "\}"

flush $outfile

 

                 puts $log "Delete existing switches for $switch_pin_pair(noring,$i) in $switch_region(noring,$switch_pin_pair(noring,$i),$j) - Done"

flush $log

                }

                }

 

 

###### Deleting the existing instances if delete_existing is one - END

 

##### Creating the Switch Instances

                regsub  -all {:} $switch_pin_pair(noring,$i) " " swp

                split $swp

                regsub  -all {\}|\{} $swp " " swp

                set ext [lindex $swp 0]

                set int [lindex $swp 1]

                if {[catch {set extpin [db query /work/$read_switch(noring,$switch_pin_pair(noring,$i),$switch_region(noring,$switch_pin_pair(noring,$i),$j),Inst) pins -domain_type external]} ] == 1} {

                puts $log "Please provide the lef files for $read_switch(noring,$switch_pin_pair(noring,$i),$switch_region(noring,$switch_pin_pair(noring,$i),$j),Inst) "

flush $log

                puts stderr "Please provide the lef files for $read_switch(noring,$switch_pin_pair(noring,$i),$switch_region(noring,$switch_pin_pair(noring,$i),$j),Inst) "

                return

                }

                if {[catch {set intpin [db query /work/$read_switch(noring,$switch_pin_pair(noring,$i),$switch_region(noring,$switch_pin_pair(noring,$i),$j),Inst) pins -domain_type internal]} ] == 1} {

                puts $log "Please provide the lef files for $read_switch(noring,$switch_pin_pair(noring,$i),$switch_region(noring,$switch_pin_pair(noring,$i),$j),Inst) "

flush $log

                puts stderr "Please provide the lef files for $read_switch(noring,$switch_pin_pair(noring,$i),$switch_region(noring,$switch_pin_pair(noring,$i),$j),Inst) "

                return

                }

                regsub  -all {:} $extpin " " extpin

                regsub -all -- {[[:space:]]+} $extpin " " extpin

 

                split $extpin

                regsub  -all {\}|\{} $extpin " " extpin

                set extpin [lindex $extpin 1]

 

                regsub  -all {:} $intpin " " intpin

                regsub -all -- {[[:space:]]+} $intpin " " intpin

                split $intpin

                regsub  -all {\}|\{} $intpin " " intpin

                set intpin [lindex $intpin 1]

 

 

                set master $read_switch(noring,$switch_pin_pair(noring,$i),$switch_region(noring,$switch_pin_pair(noring,$i),$j),Inst)

                set blockname $read_switch(noring,$switch_pin_pair(noring,$i),$switch_region(noring,$switch_pin_pair(noring,$i),$j),Name)

                set count_sxpitch [llength $read_switch(noring,$switch_pin_pair(noring,$i),$switch_region(noring,$switch_pin_pair(noring,$i),$j),X_pitch)]

                set count_sypitch [llength $read_switch(noring,$switch_pin_pair(noring,$i),$switch_region(noring,$switch_pin_pair(noring,$i),$j),Y_pitch)]

                set ypitch [lindex $read_switch(noring,$switch_pin_pair(noring,$i),$switch_region(noring,$switch_pin_pair(noring,$i),$j),Y_pitch) $clone]

                set xpitch [lindex $read_switch(noring,$switch_pin_pair(noring,$i),$switch_region(noring,$switch_pin_pair(noring,$i),$j),X_pitch) $clone]

                set exclude_switch ""

                if {[info exists read_switch(noring,$switch_pin_pair(noring,$i),$switch_region(noring,$switch_pin_pair(noring,$i),$j),Exclude)]} {

                set exclude_switch1 "$read_switch(noring,$switch_pin_pair(noring,$i),$switch_region(noring,$switch_pin_pair(noring,$i),$j),Exclude)"

                string trim $exclude_switch1

                regsub -all -- {[[:space:]]+} $exclude_switch1 " " exclude_switch

                regsub  -all ":" $exclude_switch "-" exclude_switch

                set exclude_switch "-$exclude_switch"

                }

                if {![info exists old_switch_xpitch(noring,$switch_pin_pair(noring,$i),$blockname)] && ![info exists old_switch_ypitch(noring,$switch_pin_pair(noring,$i),$blockname)]} {

                set old_switch_xpitch(noring,$switch_pin_pair(noring,$i),$blockname) 0

                set old_switch_ypitch(noring,$switch_pin_pair(noring,$i),$blockname) 0

                }

                if {$xpitch eq "" } {

                set xpitch $old_switch_xpitch(noring,$switch_pin_pair(noring,$i),$blockname)

                }

                if {$ypitch eq ""} {

                set ypitch $old_switch_ypitch(noring,$switch_pin_pair(noring,$i),$blockname)

                }

                set old_switch_xpitch(noring,$switch_pin_pair(noring,$i),$blockname) $xpitch

                set old_switch_ypitch(noring,$switch_pin_pair(noring,$i),$blockname) $ypitch

                if {[info exists read_switch(noring,$switch_pin_pair(noring,$i),$switch_region(noring,$switch_pin_pair(noring,$i),$j),Offset)]} {

                set switch_offset "$read_switch(noring,$switch_pin_pair(noring,$i),$switch_region(noring,$switch_pin_pair(noring,$i),$j),Offset)"

                } else {

                if {[info exists read_switch(noring,$switch_pin_pair(noring,$i),$switch_region(noring,$switch_pin_pair(noring,$i),$j),X_loc)] && [info exists read_switch(noring,$switch_pin_pair(noring,$i),$switch_region(noring,$switch_pin_pair(noring,$i),$j),Y_loc) ]} {

                set xloc $read_switch(noring,$switch_pin_pair(noring,$i),$switch_region(noring,$switch_pin_pair(noring,$i),$j),X_loc)

                set yloc $read_switch(noring,$switch_pin_pair(noring,$i),$switch_region(noring,$switch_pin_pair(noring,$i),$j),Y_loc)

                set switch_offset "0 $xloc $yloc 0"

                } else {

                puts stderror "Please provide Either Offset or X_loc/Y_loc for placement of switches"

                puts $log "Please provide Either Offset or X_loc/Y_loc for placement of switches"

flush $log

                return

                }

                }

                if {$clone == 0} {

                 puts $outfile "db create switch_mesh $dn -name switch_$master\_$ext\_$int\_$blockname -logical_conn { {$extpin $ext} { $intpin $int} } -master /work/$master -inst_prefix para_switch -spacing {$old_switch_xpitch(noring,$switch_pin_pair(noring,$i),$blockname) $old_switch_ypitch(noring,$switch_pin_pair(noring,$i),$blockname)} -offsets { $switch_offset  } -spec_boundary { select_region {+$inst_cell $exclude_switch} }"

flush $outfile

                } else {

                if {$flag_create_clone_files == 1 } {

 

                 puts $clonefile($clone) "db edit $dn/\sm:switch_$master\_$ext\_$int\_$blockname -logical_conn {{ $extpin $ext } {$intpin $int} } -master /work/$master -inst_prefix para_switch -spacing {$old_switch_xpitch(noring,$switch_pin_pair(noring,$i),$blockname) $old_switch_ypitch(noring,$switch_pin_pair(noring,$i),$blockname)} -offsets { $switch_offset } -spec_boundary  { select_region {+$inst_cell $exclude_switch} }"

                }

                 puts $outfile "db edit $dn/\sm:switch_$master\_$ext\_$int\_$blockname -logical_conn { { $extpin $ext } {$intpin $int} } -master /work/$master -inst_prefix para_switch -spacing {$old_switch_xpitch(noring,$switch_pin_pair(noring,$i),$blockname) $old_switch_ypitch(noring,$switch_pin_pair(noring,$i),$blockname)} -offsets { $switch_offset } -spec_boundary { select_region {$inst_cell} }"

flush $outfile

                }

##### Creating the Switch Instances - END

                if {![info exists count_clones_switch(noring,$switch_pin_pair(noring,$i),$blockname)]} {

                  set count_clones_switch(noring,$switch_pin_pair(noring,$i),$blockname) 0

                }

                if {$clone == 0} {

 

                  if {$count_sxpitch > $count_clones_switch(noring,$switch_pin_pair(noring,$i),$blockname)} {

                  set count_clones_switch(noring,$switch_pin_pair(noring,$i),$blockname) $count_sxpitch

                  }

                  if {$count_sypitch > $count_clones_switch(noring,$switch_pin_pair(noring,$i),$blockname)} {

                  set count_clones_switch(noring,$switch_pin_pair(noring,$i),$blockname) $count_sxpitch

                  }

                }

        if {$open_cell == 1} {

                puts $outfile "gui close /work/$inst_cell\::$session"

flush $outfile

        }

        }

}

}

 

}

 

proc create_net_pad_tcl {} {

global default_voltage

global def_size

global clone

global count_nets

global count_blocks

global pad_file

global pad_data

global outfile

global design_name

global log

global block_name

global old_pad_xpitch

global old_pad_ypitch

global design_name

global count_clones_pad

global net_pair

global clone_pnetpair

global clone_count_nets

global flag_create_clone_files

global clonefile

global def_file

 

if {$clone > 0} {

set session c$clone

} else {

set session p

}

set dn "/work/$design_name\::$session"

set bumpinst 0

for {set i 1 } { $i <= $count_nets} {incr i} {

if {$clone > 0} {

if {[info exists clone_pnetpair] && [info exists clone_count_nets]} {

if {![regexp "^$clone_pnetpair\$" $net_pair($i)] || ![regexp "^$clone_count_nets\$" $i]} {

continue

}

}

}

###### Creating Pad for the net pair

        if {![info exists pad_file]} {

        if {[info exists pad_data($net_pair($i),$i,exists)] && $pad_data($net_pair($i),$i,exists) == 1 } {

                set count_pxpitch [llength $pad_data($net_pair($i),$i,X_pitch)]

                set count_pypitch [llength $pad_data($net_pair($i),$i,Y_pitch)]

                if {![info exists count_clones_pad($net_pair($i),$i)]} {

                  set count_clones_pad($net_pair($i),$i) 0

                }

                if {![info exists old_pad_xpitch($net_pair($i),$i)] && ![info exists old_pad_ypitch($net_pair($i),$i)]} {

                set old_pad_xpitch($net_pair($i),$i) 0

                set old_pad_ypitch($net_pair($i),$i) 0

                }

                if {$clone == 0} {

 

                  if {$count_pxpitch > $count_clones_pad($net_pair($i),$i)} {

                  set count_clones_pad($net_pair($i),$i) $count_pxpitch

                  }

                  if {$count_pypitch > $count_clones_pad($net_pair($i),$i)} {

                  set count_clones_pad($net_pair($i),$i) $count_pypitch

                  }

                }

                set ypitch [lindex $pad_data($net_pair($i),$i,Y_pitch) $clone]

                set xpitch [lindex $pad_data($net_pair($i),$i,X_pitch) $clone]

                if {$xpitch eq ""} {

                set xpitch $old_pad_xpitch($net_pair($i),$i)

                }

                if {$ypitch eq ""} {

                set ypitch $old_pad_ypitch($net_pair($i),$i)

                }

                set old_pad_xpitch($net_pair($i),$i) $xpitch

                set old_pad_ypitch($net_pair($i),$i) $ypitch

                set layer "$pad_data($net_pair($i),$i,Layer)"

                if {[catch {set bbox [db query /work/$design_name bbox] }]==1} {

                        if {[info exists def_size]} {

                                if {$def_size ne ""} {

                                regsub -nocase "x" $def_size " " def_size

                                split $def_size

                                regsub  -all {\{|\}} $def_size "" def_size

                                set width [lindex $def_size 0]

                                set height [lindex $def_size 1]

                                set lx 0

                                set ly 0

                                }

                        }

                } else {

                                regsub -all -- {[[:space:]]+} $bbox " " bbox

                                split $bbox

                                regsub  -all {\}|\{} $bbox " " bbox

                                set lx [lindex $bbox 0]

                                set ly [lindex $bbox 1]

                                set width [lindex $bbox 2]

                                set height [lindex $bbox 3]

                }

                if {[info exists pad_data($net_pair($i),$i,Offset)]}  {

                set offset $pad_data($net_pair($i),$i,Offset)

                } else {

                if {[info exists pad_data($net_pair($i),$i,X_loc)] && [info exists pad_data($net_pair($i),$i,Y_loc)]} {

                set xloc $pad_data($net_pair($i),$i,X_loc)

                set yloc $pad_data($net_pair($i),$i,Y_loc)

                set offset "$xloc $yloc $width $height"

                } else {

                puts $log "Please provide vaid Pad details for $net_pair($i)"

flush $log

                puts stderr "Please provide vaid Pad details for $net_pair($i)"

                return

                }

                }

           if {![info exists pad_data($net_pair($i),$i,Cell)]} {

                if {$clone == 0 } {

                puts $outfile "db create ploc_mesh $dn -name para_$net_pair($i)_$i -layer $layer -spacing { $xpitch $ypitch } -offsets {$offset} -spec_boundary {entire_core}"

flush $outfile

                puts $log "Creating pad for nets $net_pair($i)"

flush $log

                } else {

                puts $outfile "db edit ploc_mesh $dn -name para_$net_pair($i)_$i -layer $layer -spacing { $xpitch $ypitch } -offsets {$offset} -spec_boundary {entire_core}"

flush $outfile

                puts $log "Creating pad for nets $net_pair($i)"

flush $log

                if {$flag_create_clone_files == 1} {

                puts $clonefile($clone) "db edit ploc_mesh $dn -name para_$net_pair($i)_$i -layer $layer -spacing { $xpitch $ypitch } -offsets {$offset} -spec_boundary {entire_core}"

                }

                }

           } else {

 

 

                regsub -all -- {[[:space:]]+} $offset " " ofset1

                split $ofset1

                regsub -all {\{|\}} $ofset1 "" ofset1

                if {$lx < [lindex $ofset1 0]} {

                set lx [lindex $ofset1 0]

                }

                if {$ly < [lindex $ofset1 1]} {

                set ly [lindex $ofset1 1]

                }

                set pady_loc $ly

                set master $pad_data($net_pair($i),$i,Cell)

                set m_width [db query /work/$master width]

                set m_height [db query /work/$master height]

                set break1 0

                set break2 0

                set count 0

                if {$clone > 0} {

                puts -nonewline $outfile  " db foreach padinst \"query $dn insts -master /work/$master\" \{ \n"

                puts -nonewline $outfile  "if \{\[regexp \"^para_pad_$master\_$i\$\" \$padinst\]\} \{ \n"

                puts -nonewline $outfile  "db delete \$padinst \n"

                puts -nonewline $outfile  "\} \n"

                puts -nonewline $outfile "\} \n"

                puts $log "Deleting pad instances - Done"

flush $log

 

                if {$flag_create_clone_files == 1} {

                puts -nonewline $clonefile($clone)  " db foreach padinst \"query $dn insts -master /work/$master\" \{ \n"

                puts -nonewline $clonefile($clone)  "if \{\[regexp \"^para_pad_$master\_$i\$\" \$padinst\]\} \{ \n"

                puts -nonewline $clonefile($clone)  "db delete \$padinst \n"

                puts -nonewline $clonefile($clone)  "\} \n"

                puts -nonewline $clonefile($clone) "\} \n"

                }

                }

                if {[catch {exec rm -rf .sourcebump}]} {}

                set sourcebump [open ".sourcebump" w]

 

                                puts $sourcebump "proc logicconn \{wirefound padx_loc pady_loc urx ury layer1 m_width m_height master session\}  \{ "

                                puts $sourcebump "set objects \[db query /work/$design_name:\$session objs -bbox \{ \$padx_loc \$pady_loc \$urx \$ury \}\]"

                                puts $sourcebump "foreach object \$objects \{ "

                                puts $sourcebump "if \{ \[regexp \"^W-\" \$object \]\} \{ "

                                puts $sourcebump "if \{ \$wirefound == 0\} \{"

                                puts $sourcebump "set pad_layer \[db query \$object layer \]"

                                puts $sourcebump "if \{ !\[regexp \"^\$pad_layer\\$\" \$layer1 \]\} \{ "

                                puts $sourcebump "continue"

                                puts $sourcebump "\}"

                                puts $sourcebump "set wirefound 1"

                                puts $sourcebump "puts \"set logical_conn \[db query \$object net \]\""

                                puts $sourcebump "\} else \{"

                                puts $sourcebump "puts stderr \"The swicth cell \$master falling at \{\$padx_loc \$pady_loc \[expr \{\$padx_loc + \$m_width \} \] \[ expr \{\$pady_loc + \$m_height \}\]\} is crossing two nets. Please correct the position\" "

                                puts $sourcebump "puts \"The swicth cell \$master falling at \{\$padx_loc \$pady_loc \[expr \{\$padx_loc + \$m_width \} \] \[ expr \{\$pady_loc + \$m_height \}\]\} is crossing two nets. Please correct the position\" "

                                puts $sourcebump "return"

                                puts $sourcebump "\}"

                                puts $sourcebump "\}"

                                puts $sourcebump "\}"

                                puts $sourcebump "\}"

                close $sourcebump

                puts $outfile "source .sourcebump"

flush $outfile

                for {set k 1 } {$k < 10000000000} {incr k} {

                set padx_loc $lx

                if {[ expr {$pady_loc + $m_height }] > $height || [ expr {$pady_loc + $m_height }] > [lindex $ofset1 3]} {

                break

                }

                for {set l 1 } {$l < 1000000000} {incr l} {

                        incr count

                        if {[expr {$padx_loc + $m_width } ] > $width  || [expr {$padx_loc + $m_width } ] > [lindex $ofset1 2]} {

                        break

 

                        } else {

 

                                if {[catch {set padpin_name "[db query /work/$master pins]"}] == 1 } {

                                puts stderr "Please provide lef file for Bump cell $master"

                                puts $log "Please provide lef file for Bump cell $master"

flush $log

                                return

                                } else {

                                regsub "/work/$master/pin:" $padpin_name "" padpin_name

                                }

                                puts $outfile "db create inst $dn -name para_pad_$master\_$i\_$count -loc {$padx_loc $pady_loc}  -master /work/$master -logical_conn { {$padpin_name \[logiccon 0  $padx_loc $pady_loc [expr {$padx_loc + $m_width } ] [ expr {$pady_loc + $m_height }] $layer $m_width $m_height $master $session\]} }  "

flush $outfile

                                if {$flag_create_clone_files == 1 && $clone> 0} {

                                puts $clonefile($clone) "db create inst $dn -name para_pad_$master\_$i\_$count -loc {$padx_loc $pady_loc}  -master /work/$master -logical_conn { {$padpin_name \[logiccon 0 $padx_loc $pady_loc [expr {$padx_loc + $m_width } ] [ expr {$pady_loc + $m_height }] $layer $m_width $m_height $master $session\]} }  "

 

                                }

 

                        }

                                set padx_loc [expr {$padx_loc + $xpitch}]

 

                }

                                set pady_loc [expr {$pady_loc + $ypitch}]

                }

                puts $log "Creating pad for nets $net_pair($i)"

flush $log

                set pcellfile [open "gps.pcell" w]

                puts $pcellfile "$master bump"

                close $pcellfile

 

                set bumpinst 1

                }

                if {![info exists count_clones_pad($net_pair($i),$i)]} {

                  set count_clones_pad($net_pair($i),$i) 0

                }

                if {$clone == 0} {

 

                  if {$count_pxpitch > $count_clones_pad($net_pair($i),$i)} {

                  set count_clones_pad($net_pair($i),$i) $count_pxpitch

                  }

                  if {$count_pypitch > $count_clones_pad($net_pair($i),$i)} {

                  set count_clones_pad($net_pair($i),$i) $count_pypitch

                  }

                }

        }

        }

###### Creating Pad for the net pair - END

 

 

  }

  if {$bumpinst == 1 && $clone == 0} {

        puts $outfile "config set PAD_FILES \{ gps.cell \}"

flush $outfile

        if {$flag_create_clone_files == 1 && $clone > 0} {

        puts $clonefile($clone) "config set PAD_FILES \{ gps.cell \}"

 

        }

  }

}

proc create_voltage {} {

global clone

global outfile

global log

global default_voltage

global net_pair

global count_nets

global design_name

 

for {set i  1} {$i <= $count_nets} {incr i} {

###### Setting the voltages

        if {[info exists default_voltage($net_pair($i))] && $clone == 0} {

           regsub  -all ":" $default_voltage($net_pair($i)) " " default_voltage($net_pair($i))

           regsub -all -- {[[:space:]]+} $default_voltage($net_pair($i)) " " default_voltage($net_pair($i))

           split $default_voltage($net_pair($i))

           regsub  -all {\}|\{} $default_voltage($net_pair($i)) " " default_voltage($net_pair($i))

           set count_default_voltage [llength $default_voltage($net_pair($i))]

                        regsub  -all ":" $net_pair($i) " " np($i)

                        regsub -all -- {[[:space:]]+} $np($i) " " np($i)

                        split $np($i)

                        regsub  -all {\}|\{} $np($i) " " np($i)

           set cnets [llength $np($i)]

           for {set nv 0 } {$nv < $cnets} {incr nv} {

        set np1 [lindex $np($i) $nv]

        set df1 [lindex $default_voltage($net_pair($i)) $nv]

        set netpresent 0

        if {![info exists netvoltage($np1)]} {

        set netvoltage($np1) 0

        }

        set a1 ""

        set a2 ""

        if {[catch {set a1 [db query /work/$design_name nets -type power]} ] == 0} {}

        if {[catch {set a2 [db query /work/$design_name nets -type ground]} ] == 0} {}

        set a [concat $a1 $a2]
        if {$a ne ""} {

        foreach net1 $a {

        regsub "/work/$design_name/net:" $net1 "" net1

        if {[regexp "^$net1\$" $np1]} {

        set netpresent 1

        }

        }

           if { $netpresent == 0 } {

                if {$cnets <= $count_default_voltage} {

                if {$netvoltage($np1) == 0} {

                set netvoltage($np1) 1

                if {$df1  > 0} {

                puts $outfile "db create net /work/$design_name -name $np1 -voltage [lindex $default_voltage($net_pair($i)) $nv] -type p"

flush $outfile

                } else {

                puts $outfile "db create net /work/$design_name -name $np1 -voltage [lindex $default_voltage($net_pair($i)) $nv] -type g"

flush $outfile

                }

                } else {

                puts $outfile "db edit /work/$design_name/net:$np1 -voltage [lindex $default_voltage($net_pair($i)) $nv]"

flush $outfile

                }

                } else {

                        puts $log "Please provide the valid number of voltage values"

flush $log

                        puts stderr "Please provide the valid number of voltage values"

                        return

                }

           } else {

                if {$df1 eq ""} {

                } else {

                puts $outfile "db edit /work/$design_name/net:$np1 -voltage [lindex $default_voltage($net_pair($i)) $nv]"

flush $outfile

                }

 

        }

        } else {

                if {$df1 ne ""} {

                if {$netvoltage($np1) == 0} {

                set netvoltage($np1) 1

                if {$df1  > 0} {

                puts $outfile "db create net /work/$design_name -name $np1 -voltage [lindex $default_voltage($net_pair($i)) $nv] -type p"

flush $outfile

                } else {

                puts $outfile "db create net /work/$design_name -name $np1 -voltage [lindex $default_voltage($net_pair($i)) $nv] -type g"

flush $outfile

                }

                } else {

                puts $outfile "db edit /work/$design_name/net:$np1 -voltage [lindex $default_voltage($net_pair($i)) $nv]"

flush $outfile

                }

                } else {

                puts stderr "Please provide valid voltage values"

                puts $log "Please provide valid voltage values"

flush $log

                }

        }

 

 

        }

 

        } else {

           puts $log "Please provide the voltage for nets $net_pair($i)"

flush $log

        }

###### Setting the voltages - Done

}

}

 

proc create_net_route_tcl {} {

global power_number

global Pin_tap_data

global clone_rnetpair

global clone_count_rnets

global clone_rblock

global clone_count_rblocks

global clone_rlayer

global clone_count_rlayer

global old_lwchange

global old_powerpitch

global old_lspacing

global old_lviamodel

global old_lviarule

global old_lviacut

global old_lexclude

global old_llength

global old_lgap

global old_lpitch

global old_lwidth

global default_offset

global default_gap

global default_exclude

global default_include

global default_length

global def_size

global clone

global count_nets

global count_blocks

global count_layer

global count_block

global outfile

global design_name

global log

global block_name

global block_data

global block

global design_name

global net_pair

global flag_create_clone_files

global clonefile

global layer_name

global layer_data

global def_file

global count_clones_route

global count_clones_power

global clone_power

global def_size

global delete_wire

global old_delete_wire

if {$clone > 0} {

set session c$clone

} else {

set session p

if {[catch {exec rm -rf .sourcemacro}]} {}

set sourcemacro [open ".sourcemacro" "w"]

puts $sourcemacro "proc find_macro \{ inst_cell lexcludepin\} \{"

puts $sourcemacro "set list_inst \"\""

puts $sourcemacro "db foreach macro_inst \"query /work/\$inst_cell insts -type hardip -hier_level \{0 max\}\" \{"

#puts $sourcemacro "regsub \"/work/$design_name/\" \$macro_inst \"\" macro_inst"

puts $sourcemacro "set exclude \"0\""

puts $sourcemacro  "if \{ \$lexcludepin ne 0\} \{"

puts $sourcemacro "foreach inst_exclude \$lexclude \{"

puts $sourcemacro "if \{ \[regexp \"\$inst_exclude\" \$macro_inst \]\} \{"

puts $sourcemacro "set exclude \"1\""

puts $sourcemacro  "\}"

puts $sourcemacro  "\}"

puts $sourcemacro  "\}"

puts $sourcemacro  "if \{ \$exclude == 0\} \{"

puts $sourcemacro  "set list_int \"\$list_inst \$macro_inst\""

puts $sourcemacro  "\}"

puts $sourcemacro  "\}"

puts $sourcemacro "db foreach macro_inst \"query /work/\$inst_cell insts -type switch -hier_level \{0 max\}\" \{"

#puts $sourcemacro "regsub \"/work/$design_name/\" \$macro_inst \"\" macro_inst"

puts $sourcemacro "set exclude \"0\""

puts $sourcemacro  "if \{ \$lexcludepin ne 0\} \{"

puts $sourcemacro "foreach inst_exclude \$lexclude \{"

puts $sourcemacro "if \{ \[regexp \"\$inst_exclude\" \$macro_inst \]\} \{"

puts $sourcemacro "set exclude \"1\""

puts $sourcemacro  "\}"

puts $sourcemacro  "\}"

puts $sourcemacro  "\}"

puts $sourcemacro  "if \{ \$exclude == 0\} \{"

puts $sourcemacro  "set list_int \"\$list_inst \$macro_inst\""

puts $sourcemacro  "\}"

puts $sourcemacro  "\}"

puts $sourcemacro  "return \$list_inst"

puts $sourcemacro  "\}"

close $sourcemacro

puts $outfile "source .sourcemacro"

flush $outfile

}

for {set i 1 } { $i <= $count_nets} {incr i} {

if {$clone > 0} {

if {[info exists clone_rnetpair] && [info exists clone_count_rnets]} {

if {![regexp "^$clone_rnetpair\$" $net_pair($i)] || ! [regexp "^$clone_count_rnets\$" $i]} {

continue

}

}

}

 

if {[info exists count_blocks] && $count_blocks($net_pair($i),$i) > 0} {

   for {set j 1} { $j <= $count_blocks($net_pair($i),$i)} {incr j} {

        set open_cell 0

        if {$clone > 0} {

        if {[info exists clone_rblock] && [info exists clone_count_rblocks]} {

        if {![regexp "^$clone_rblock\$" $block_name($net_pair($i),$i,$j)] || ![regexp "^$clone_count_rblocks\$" $j]} {

        continue

        }

        }

        }

        ###### Deciding whethere the provided name under Nets is cell or instance name

                if {[catch {set inst_cell $block_name($net_pair($i),$i,$j)}] == 0 } {

                if {[regexp "DUMMY" $inst_cell]} {

                split $inst_cell

                set inst_cell [lindex $inst_cell 1]

                if {$inst_cell eq ""} {

                set inst_cell $design_name

                }

                }

                string trim $inst_cell

                set result [find_cellname $inst_cell $session]

        } else {

                puts $log "Please provide Valid block/region name for $net_pair($i)"

flush $log

                puts stderr "Please provide Valid block/region name for $net_pair($i)"

                return

        }

                split $result

                set dn [lindex $result 0]

                set qcn [lindex $result 1]

                set xy "[lindex $result 2] [lindex $result 3] [lindex $result 4] [lindex $result 5]"

                regsub  -all {\{|\}} $xy "" xy

        ###### Deciding whethere the provided name under Nets is cell or instance name - Done

 

###### looping through Layers

        if {[info exists count_layer($net_pair($i),$block_name($net_pair($i),$i,$j))] && $count_layer($net_pair($i),$block_name($net_pair($i),$i,$j)) > 0} {

           for { set l 1 } {$l <= $count_layer($net_pair($i),$block_name($net_pair($i),$i,$j))}  {incr l} {

                if {$clone > 0} {

                if {[info exists clone_rlayer] && [info exists clone_count_rlayer]} {

                if {![regexp "^$clone_rlayer\$" $layer_name($net_pair($i),$block_name($net_pair($i),$i,$j),$l)] || ![regexp "^$clone_count_rlayer\$" $l]} {

                continue

                }

                }

                }

                if {$clone == 0} {

                 set count_clones_route($net_pair($i),$block_name($net_pair($i),$i,$j),$l) 0

                set count_clones_power($net_pair($i),$block_name($net_pair($i),$i,$j),$l) 0

                }

                set layername $layer_name($net_pair($i),$block_name($net_pair($i),$i,$j),$l)

                        regsub -all  ":" $net_pair($i) " " np($i)

                        regsub -all -- {[[:space:]]+} $np($i) " " np($i)

                        split $np($i)

                        regsub  -all {\}|\{} $np($i) " " np($i)

                        set layerinclude "$inst_cell"

                        if { [catch {set layerinclude $layer_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Include)} ] == 1 } {

                        if {[catch {set layerinclude $default_include($net_pair($i))}] == 1 } {

                        }

                        }

                                regsub -all -- {[[:space:]]+} $layerinclude " " linclude

                                regsub  -all {\}|\{} $linclude " " linclude

                                regsub  -all ":" $linclude "+" linclude

                                set linclude "$linclude"

                        set excludeexists 1

                        if { [catch {set layerexclude $layer_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Exclude)} ] == 1 } {

                        if {[catch {set layerexclude $default_exclude($net_pair($i))}] == 1 } {

                        set excludeexists 0

                                set lexclude ""

                                set count_lexclude 0

                        }

                        }

                        if {$excludeexists == 1} {

                          set count_lexclude [llength $layerexclude]

                           set lexclude [lindex $layerexclude $clone]

                           if {$lexclude eq ""} {

                                set lexclude $old_lexclude($net_pair($i),$block_name($net_pair($i),$i,$j),$l)

                           }

                           set old_lexclude($net_pair($i),$block_name($net_pair($i),$i,$j),$l) $lexclude

                                regsub -all -- {[[:space:]]+} $lexclude " " lexclude

                                regsub  -all {\}|\{} $lexclude " " lexclude

                                regsub  -all ":" $lexclude "-" lexclude

                                set lexclude "-$lexclude"

                                 }

                        if {($clone > 0 && $clone_power == 0) || $clone == 0 } {

                        if { [catch {set layerviadrop $layer_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Via_drop_layers)} ] == 1 } {

                                set layerviadrop " - -"

                        }
                        regsub  -all {\}|\{} $layerviadrop " " layerviadrop

 

                        if { [catch {set layerviamodel $layer_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Via_model)}] ==1 } {

                        set lviamodel ""

                        set count_lviamodel 0

                        } elseif {[llength $layerviamodel] == 0} {

                        set lviamodel ""

                        set count_lviamodel 0

                        } else {

                        set count_lviamodel [llength $layerviamodel]

                           set lviamodel [lindex $layerviamodel $clone]

                           if {$lviamodel eq ""} {

                                set lviamodel $old_lviamodel($net_pair($i),$block_name($net_pair($i),$i,$j),$l)

                           }

                           set old_lviamodel($net_pair($i),$block_name($net_pair($i),$i,$j),$l) $lviamodel

                           regsub -all  ":" $lviamodel " " lviamodel

                           regsub -all -- {[[:space:]]+} $lviamodel " " lviamodel

                           split $lviamodel

                           regsub  -all {\}|\{} $lviamodel " " lviamodel

                        }

 

                        if { [catch {set layerviarule $layer_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Via_rule)}] ==1 } {

                        set lviarule ""

                        set count_lviarule 0

                        } elseif {[llength $layerviarule] == 0} {

                        set lviarule ""

                        set count_lviarule 0

                        } else {

                        set count_lviarule [llength $layerviarule]

                           set lviarule [lindex $layerviarule $clone]

                           if {$lviarule eq ""} {

                                set lviarule $old_lviarule($net_pair($i),$block_name($net_pair($i),$i,$j),$l)

                           }

                           set old_lviarule($net_pair($i),$block_name($net_pair($i),$i,$j),$l) $lviarule

                           regsub  -all ":" $lviarule " " lviarule

                           regsub -all -- {[[:space:]]+} $lviarule " " lviarule

                           split $lviarule

                           regsub  -all {\}|\{} $lviarule " " lviarule

                        }

                        if { [catch {set layerviacut $layer_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Via_cuts)}] ==1 } {

                        set count_lviacut 0

                        } else {

                        set count_lviacut [llength $layerviacut]

                           set lviacut [lindex $layerviacut $clone]

                           if {$lviacut eq ""} {

                                set lviacut $old_lviacut($net_pair($i),$block_name($net_pair($i),$i,$j),$l)

                           }

                           set old_lviacut($net_pair($i),$block_name($net_pair($i),$i,$j),$l) $lviacut

                           regsub -all  ":" $lviacut " " lviacut

                           regsub -all -- {[[:space:]]+} $lviacut " " lviacut

                           split $lviacut

                           regsub  -all {\}|\{} $lviacut " " lviacut

                        }

 

                        if {$clone == 0} {

                        if {$count_lviamodel > $count_clones_route($net_pair($i),$block_name($net_pair($i),$i,$j),$l)} {

                        set count_clones_route($net_pair($i),$block_name($net_pair($i),$i,$j),$l) $count_lviamodel

                        }

                        if {$count_lviarule > $count_clones_route($net_pair($i),$block_name($net_pair($i),$i,$j),$l)} {

                        set count_clones_route($net_pair($i),$block_name($net_pair($i),$i,$j),$l) $count_lviarule

                        }

                        if {$count_lexclude > $count_clones_route($net_pair($i),$block_name($net_pair($i),$i,$j),$l)} {

                        set count_clones_route($net_pair($i),$block_name($net_pair($i),$i,$j),$l) $count_lexclude

                        }

                        if {$count_lviacut > $count_clones_route($net_pair($i),$block_name($net_pair($i),$i,$j),$l)} {

                        set count_clones_route($net_pair($i),$block_name($net_pair($i),$i,$j),$l) $count_lviacut

                        }

                        }

                if {[info exists def_file] && [info exists layer_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Width_change)]} {

                        set layerwidthchange $layer_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Width_change)

                           regsub -all  ":" $layerwidthchange " " layerwidthchange

                           regsub -all -- {[[:space:]]+} $layerwidthchange " " layerwidthchange

                           split $layerwidthchange

                          regsub  -all {\}|\{} $layerwidthchange " " layerwidthchange

                        set count_lwchange [llength $layerwidthchange]

                        if {$clone == 0} {

                        if {$count_lwchange > $count_clones_route($net_pair($i),$block_name($net_pair($i),$i,$j),$l)} {

                        set count_clones_route($net_pair($i),$block_name($net_pair($i),$i,$j),$l)  $count_lwchange

                        }

                        }

                        set lwchange [lindex $layerwidthchange $clone]

                        if {$lwchange eq ""} {

                        set lwchange $old_lwchange($net_pair($i),$block_name($net_pair($i),$i,$j),$l)

                        }

                        set old_lwchange($net_pair($i),$block_name($net_pair($i),$i,$j),$l) $lwchange

                        if {[catch { set layerwidthfilter $layer_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Width_filter)}]== 0} {

                           regsub  -all ":" $layerwidthfilter " " layerwidthfilter

                           regsub -all -- {[[:space:]]+} $layerwidthfilter " " layerwidthfilter

                           split $layerwidthfilter

                           regsub  -all {\}|\{} $layerwidthfilter " " layerwidthfilter

 

 

                        set lwfilter [lindex $layerwidthfilter $clone]

                        if {$lwfilter eq ""} {

                        set lwfilter $old_lwfilter($net_pair($i),$block_name($net_pair($i),$i,$j),$l)

                        set widthfilter 0

                        } else {

                        set widthfilter 1

                        }

                        } else {

                        set widthfilter 0

                        }

 

                                puts -nonewline  $outfile "perform adv_route_edit  -layer $layername -nets {$np($i)} -spec_boundary {select_region { $linclude $lexclude} } -new_width $lwchange -recreate_vias 1 -via_models {$lviamodel } -via_rules {$lviarule} -vias_between_parallel_metals 1  -parallel_metals_via_spec { 0 0 } -via_occupancy_percentage { 100 100 } -short_check 1 -min_spacing 0.0005"

                        if {$flag_create_clone_files == 1 && $clone > 0} {

                                puts -nonewline $clonefile($clone) "perform adv_route_edit  -layer $layername -nets {$np($i)} -spec_boundary {select_region { $linclude $lexclude} } -new_width $lwchange -recreate_vias 1 -via_models {$lviamodel } -via_rules {$lviarule} -vias_between_parallel_metals 1  -parallel_metals_via_spec { 0 0 } -via_occupancy_percentage { 100 100 } -short_check 1 -min_spacing 0.0005"

 

                        }

                        if {$width_filter > 0} {

                        if {regexp "-" $lwfilter} {

                                regsub  -all "-" $lwfilter "<width<" lwfilter

                        }

                                puts -nonewline $outfile "-width_filter $lwfilter "

                        if {$flag_create_clone_files == 1 && $clone > 0} {

                                puts -nonewline $clonefile($clone) "-width_filter $lwfilter "

                        }

                        }

                        if {$count_lviacut > 0} {

                        puts $outfile  " -via_num_cuts { $lviacut}"

flush $outfile

                        if {$flag_create_clone_files == 1 && $clone > 0} {

                        puts $clonefile($clone) " -via_num_cuts { $lviacut}"

                        }

                        }

                        puts $outfile ""

flush $outfile

                        if {$flag_create_clone_files == 1 && $clone > 0} {

                        puts $clonefile($clone) ""

                        }

                } else {

                        if {$clone == 0} {

                        if {[info exists layer_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Delete_existing) ] && $layer_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Delete_existing) == 1} {

                                puts $outfile "perform adv_route_edit  -layer $layername -nets {$np($i)} -spec_boundary {select_region { $linclude $lexclude} } -delete_wires 1"

flush $outfile

                        }

                        if {$flag_create_clone_files == 1 && $clone > 0} {

                                puts $clonefile($clone) "perform adv_route_edit  -layer $layername -nets {$np($i)} -spec_boundary {select_region { $linclude $lexclude} } -delete_wires 1"

                        }

                        }

                        if {[info exists layer_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Create_staples)]} {

                        if {$layer_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Create_staples) ne ""} {

                        set create_staples $layer_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Create_staples)

                        } else {

                        set create_staples 0

                        }

                        } else {

                        set create_staples 0

                        }

                        if { [catch {set layerlength $layer_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Length)} ] == 1 } {

                                if {[catch {set layerlength $default_length($net_pair($i))}] == 1 } {

                                        if {$create_staples == 1} {

                                        puts $log "Please provide the Length for $layername in nets $net_pair($i) for creating staples"

flush $log

                                        puts stderr "Please provide the Length for $layername in nets $net_pair($i) for creating staples"

                                        return

                                        }

                                }

                        }

                        if { [catch {set layergap $layer_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Gap)} ] == 1 } {

                                if {[catch {set layergap $default_gap($net_pair($i))}] == 1 } {

                                        if {$create_staples == 1} {

                                        puts $log "Please provide the Gap for $layername in nets $net_pair($i) for creating staples"

flush $log

                                        puts  stderr $errorInfo "Please provide the Gap for $layername in nets $net_pair($i) for creating staples"

                                        return

                                        }

                                }

                        }

                        if { [catch {set layeroffset $layer_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Offset)} ] == 1 } {

                                if {[catch {set layeroffset $default_offset($net_pair($i))}] == 1 } {

                                set layeroffset "0 0 0 0"

                                }

                        }

                           regsub  -all ":" $layeroffset " " layeroffset

                           regsub -all -- {[[:space:]]+} $layeroffset " " layeroffset

                           split $layeroffset

                           regsub  -all {\}|\{} $layeroffset " " layeroffset

                        set count_loffset [expr { [llength $layeroffset]/4}]

                        set loffset "[lindex $layeroffset [expr {$clone*4}] ] [lindex $layeroffset [expr {[expr {$clone*4}]+1}]] [lindex $layeroffset [expr {[expr {$clone*4}]+2}]] [lindex $layeroffset [expr {[expr {$clone*4}]+3}]]"

                        if {$loffset eq ""} {

                        set loffset $old_loffset($net_pair($i),$block_name($net_pair($i),$i,$j),$l)

                        }

                        set old_loffset($net_pair($i),$block_name($net_pair($i),$i,$j),$l) $loffset

 

                        if { [catch {set layerspacing $layer_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Spacing)} ] == 1 } {

                                if {[catch {set layerspacing $default_spacing($net_pair($i))}] == 1 } {

                                set layerspacing 0

                                }

                        }

                        if { [catch {set layerpitch $layer_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Pitch)} ] == 1 } {

                                if {[catch {set layerpitch $default_pitch($net_pair($i))}] == 1 } {

                                set pitchexists 0

                                }

                        }

                        if { [catch {set layerwidth $layer_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Width)} ] == 1 } {

                                if {[catch {set layerwidth $default_width($net_pair($i))}] == 1 } {

                                set widthexists 0

                                set layerwidth 0

                                }

                        }

                        if { [catch {set layerdir $layer_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Direction)} ] == 1 } {

                        source .sourcetech

                        foreach layer1 [db query /tech -type metal -dir h] {

                        if {[regexp "^$layer1\$" $layername]} {

                        set layerdir "h"

                        }

                        }

                        foreach layer1 [db query /tech -type metal -dir v] {

                        if {[regexp "^$layer1\$" $layername]} {

                        set layerdir "v"

                        }

                        }

                        }
                        regsub  -all {\{|\}} $layerdir "" layerdir

                        if {$create_staples == 1} {

                        set count_llength [llength $layerlength]

                        set l_length [lindex $layerlength $clone]

                        if {$l_length eq ""} {

                        set l_length $old_llength($net_pair($i),$block_name($net_pair($i),$i,$j),$l)

                        }

                        set old_llength($net_pair($i),$block_name($net_pair($i),$i,$j),$l) $l_length

 

                        set count_lgap [llength $layergap]

                        set lgap [lindex $layergap $clone]

                        if {$lgap eq ""} {

                        set lgap $old_lgap($net_pair($i),$block_name($net_pair($i),$i,$j),$l)

                        }

                        set old_lgap($net_pair($i),$block_name($net_pair($i),$i,$j),$l) $lgap

                        } else {

                        set count_llength 0

                        set count_lgap 0

                        }

                        set count_lspacing [llength $layerspacing]

                        set lspacing [lindex $layerspacing $clone]

                        if {$lspacing eq ""} {

                        set lspacing $old_lspacing($net_pair($i),$block_name($net_pair($i),$i,$j),$l)

                        }

                        set old_lspacing($net_pair($i),$block_name($net_pair($i),$i,$j),$l) $lspacing

 

                        set count_lwidth [llength $layerwidth]

                        set lwidth [lindex $layerwidth $clone]

                        if {$lwidth eq ""} {

                        set lwidth $old_lwidth($net_pair($i),$block_name($net_pair($i),$i,$j),$l)

                        }

                        set old_lwidth($net_pair($i),$block_name($net_pair($i),$i,$j),$l) $lwidth

                        if {[info exists pitchexists] && $pitchexists == 0} {

                        set lpitch [expr {[llength $np($i) * [expr {$lwidth + $lspacing}]]}]

                        set count_lpitch 1

                        } else {

                        set count_lpitch [llength $layerpitch]

                        set lpitch [lindex $layerpitch $clone]

                        }

                        if {$lpitch eq ""} {

                        set lpitch $old_lpitch($net_pair($i),$block_name($net_pair($i),$i,$j),$l)

                        }

                        set old_lpitch($net_pair($i),$block_name($net_pair($i),$i,$j),$l) $lpitch

                        if {$lpitch < [format {%0.2f} [expr {[llength $np($i)] * [expr {$lwidth + $lspacing}]}]]} {

                        puts stderr "The pitch value provided $lpitch is not a valid one. Please provide the valid pitch value $net_pair($i) $layername $lwidth + $lspacing [llength $np($i)] [expr {[llength $np($i)] * [expr {$lwidth + $lspacing}]}]"

                        puts $log "The pitch value provided $lpitch is not a valid one. Please provide the valid pitch value"

flush $log

                        return

                        }

                        if {$clone == 0} {

                        if {$count_lpitch > $count_clones_route($net_pair($i),$block_name($net_pair($i),$i,$j),$l)} {

                        set count_clones_route($net_pair($i),$block_name($net_pair($i),$i,$j),$l)  $count_lpitch

                        }

                        if {$count_lspacing > $count_clones_route($net_pair($i),$block_name($net_pair($i),$i,$j),$l)} {

                        set count_clones_route($net_pair($i),$block_name($net_pair($i),$i,$j),$l)  $count_lspacing

                        }

                        if {$count_lwidth > $count_clones_route($net_pair($i),$block_name($net_pair($i),$i,$j),$l)} {

                        set count_clones_route($net_pair($i),$block_name($net_pair($i),$i,$j),$l)  $count_lwidth

                        }

                        if {$count_llength > $count_clones_route($net_pair($i),$block_name($net_pair($i),$i,$j),$l)} {

                        set count_clones_route($net_pair($i),$block_name($net_pair($i),$i,$j),$l)  $count_llength

                        }

                        if {$count_lgap > $count_clones_route($net_pair($i),$block_name($net_pair($i),$i,$j),$l)} {

                        set count_clones_route($net_pair($i),$block_name($net_pair($i),$i,$j),$l)  $count_lgap

                        }

                        if {$count_loffset > $count_clones_route($net_pair($i),$block_name($net_pair($i),$i,$j),$l)} {

                        set count_clones_route($net_pair($i),$block_name($net_pair($i),$i,$j),$l)  $count_loffset

                        }

 

 

                        }

                        if {![info exists delete_wire($net_pair($i),$block_name($net_pair($i),$i,$j),$l)]} {

                        set delete_wire($net_pair($i),$block_name($net_pair($i),$i,$j),$l) 1

                        }

                        if {![info exists old_delete_wire($net_pair($i),$block_name($net_pair($i),$i,$j),$l)]} {

                        set old_delete_wire($net_pair($i),$block_name($net_pair($i),$i,$j),$l) 1

                        }

                        if {$lwidth != 0} {

                        if {$old_delete_wire($net_pair($i),$block_name($net_pair($i),$i,$j),$l) == 1} {

                        puts  -nonewline $outfile "db create route_mesh $dn  -name para_route_$layername\_$i\_$j\_$l  -nets { $np($i) }   -layer $layername  -dir $layerdir  -width $lwidth  -spacing $lspacing  -pitch $lpitch  -offsets { $loffset }  -offset_from_blockages 0  -offset_from_exclude_scopes 0  -short_check 1  -min_spacing 0.0005   -spec_boundary {select_region { $linclude $lexclude} }  -drop_via_layers { $layerviadrop }   -vias_between_parallel_metals 1  -parallel_metals_via_spec { 0 0 } -via_occupancy_percentage { 100 100 }"

                        } else {

                        puts -nonewline $outfile "db edit $dn/rm:para_route_$layername\_$i\_$j\_$l  -name para_route_$layername\_$i\_$j\_$l  -nets { $np($i) }   -layer $layername  -dir $layerdir  -width $lwidth  -spacing $lspacing  -pitch $lpitch  -offsets { $loffset }  -offset_from_blockages 0  -offset_from_exclude_scopes 0  -short_check 1  -min_spacing 0.0005  -drop_via_layers { $layerviadrop } -spec_boundary {select_region { $linclude $lexclude} }  -vias_between_parallel_metals 1  -parallel_metals_via_spec { 0 0 } -via_occupancy_percentage { 100 100 } "

                        if {$flag_create_clone_files == 1 && $clone > 0} {

                        puts -nonewline $clonefile($clone) "db edit $dn/rm:para_route_$layername\_$i\_$j\_$l  -name para_route_$layername\_$i\_$j\_$l  -nets { $np($i) }   -layer $layername  -dir $layerdir  -width $lwidth  -spacing $lspacing  -pitch $lpitch  -offsets { $loffset }  -offset_from_blockages 0  -offset_from_exclude_scopes 0  -short_check 1  -min_spacing 0.0005  -drop_via_layers { $layerviadrop } -spec_boundary {select_region { $linclude $lexclude} }  -vias_between_parallel_metals 1  -parallel_metals_via_spec { 0 0 } -via_occupancy_percentage { 100 100 }"

                        }

                        }

                        puts -nonewline $outfile ""

                        if {$lviamodel ne ""} {

                        puts -nonewline $outfile "  -via_models { $lviamodel} "

                        if {$flag_create_clone_files == 1 && $clone > 0} {

                        puts  -nonewline $clonefile($clone) " -via_models { $lviamodel} "

                        }

                        }

                        if {$lviarule ne ""} {

                        puts -nonewline $outfile "  -via_rules { $lviarule} "

                        if {$flag_create_clone_files == 1 && $clone > 0} {

                        puts  -nonewline $clonefile($clone) " -via_rules { $lviarule} "

                        }

                        }

                        if {$create_staples > 0} {

                        puts -nonewline $outfile " -staples {$l_length $lgap}"

                        if {$flag_create_clone_files == 1 && $clone > 0} {

                        puts  -nonewline $clonefile($clone) " -staples {$l_length $lgap}"

                        }

                        }

                        if {$count_lviacut > 0} {

                        puts $outfile  " -via_num_cuts { $lviacut}"

flush $outfile

                        if {$flag_create_clone_files == 1 && $clone > 0} {

                        puts $clonefile($clone) " -via_num_cuts { $lviacut}"

                        }

                        }

                        puts $outfile ""

flush $outfile

 

                        set delete_wire($net_pair($i),$block_name($net_pair($i),$i,$j),$l) 0

                        } else {

                        if {$delete_wire($net_pair($i),$block_name($net_pair($i),$i,$j),$l) == 0} {

                        set delete_wire($net_pair($i),$block_name($net_pair($i),$i,$j),$l) 1

                        puts $outfile "delete para_route_$layername\_$i\_$j\_$l"

flush $outfile

                        }

                        }

                        set old_delete_wire($net_pair($i),$block_name($net_pair($i),$i,$j),$l) $delete_wire($net_pair($i),$block_name($net_pair($i),$i,$j),$l)

 

                }

                puts $outfile ""

flush $outfile

                if {$flag_create_clone_files == 1 && $clone > 0} {

                puts $clonefile($clone) ""

                }

                        set pin_layers ""

                        if {[info exists Pin_tap_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Pin_tap)]} {

                        if {[info exists Pin_tap_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Pin_layer)]} {

                        if { $Pin_tap_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Pin_layer) ne "" } {

                        set pin_layers $Pin_tap_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Pin_layer)

                        regsub -all -- {[[:space:]]+} $pin_layers " " pin_layers

                        regsub -all {\{|\}} $pin_layers "" pin_layers

                }

                }

                        set insts_macro "/work/$design_name"

                        if {[info exists Pin_tap_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Include)]} {

                        if {$Pin_tap_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Include) ne ""} {

                                set insts_macro "$Pin_tap_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Include)"

                                set insts_macro "/work/$design_name/$insts_macro"

                                regsub -all ":" $insts_macro ":/work/$design_name/" insts_macro

                                regsub -all ":" $insts_macro " " insts_macro

                        }

                        } elseif {[info exists Pin_tap_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Exclude)]} {

                                if {[info exists Pin_tap_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Exclude)]} {

                                        set lexcludepin $Pin_tap_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Exclude)

                                        regsub  -all ":" $lexcludepin " " lexcludepin

 

                                } else {

                                        regsub -all {\-}  $lexclude " " lexcludepin

                                }

 

                        puts $outfile "set insts_macro \"\[find_macro $inst_cell $lexcludepin\]\""

flush $outfile

                if {$flag_create_clone_files == 1 && $clone > 0} {

                        puts $clonefile($clone) "set insts_macro \"\[find_macro $inst_cell $lexcludepin\]\""

                        }

                        }

                        set pin_tap_lvcut ""

                        if {[info exists Pin_tap_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Via_cuts)]} {

                        if {$Pin_tap_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Via_cuts) ne ""} {

                        set pin_tap_lvcut $Pin_tap_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Via_cuts)

                                        regsub  -all ":" $pin_tap_lvcut " " pin_tap_lvcut

 

                        }

                        }

                        set pin_tap_lvrule ""

                        if {[info exists Pin_tap_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Via_rule)]} {

                        if {$Pin_tap_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Via_rule) ne ""} {

                        set pin_tap_lvrule $Pin_tap_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Via_rule)

                                        regsub  -all ":" $pin_tap_lvrule " " pin_tap_lvrule

 

                        }

                        }

                        set pin_tap_logicconn ""

                        if {[info exists Pin_tap_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Logical_connection)] && $Pin_tap_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Logical_connection) ne ""} {

                        set pin_tap_logicconn $Pin_tap_data($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Logical_connection)

                        regsub -all -- {[[:space:]]+} $pin_tap_logicconn " " pin_tap_logicconn

                                        regsub  -all ":" $pin_tap_logicconn " " pin_tap_logicconn

                                split $pin_tap_logicconn

                        }

                        if {$pin_tap_logicconn ne ""} {

                        if {[llength $pin_tap_logicconn] != [llength $np($i)]} {

                        puts "Please provide valid number of logical connection data for $np($i) , $block_name($net_pair($i),$i,$j) $layername"

                        puts $log "Please provide valid number of logical connection data for $np($i) , $block_name($net_pair($i),$i,$j) $layername"

flush $log

                        return

                        }

                        for {set ii 0} {$ii <  [llength $np($i)]} {incr ii} {

                        puts $outfile "db edit $dn/net:[lindex $np($i) $ii] -name [lindex $np($i) $ii] -logical_conn \{\{ * [lindex $pin_tap_logicconn $ii] \}\}"

flush $outfile

 

                        }

                        }

 

                if {$clone == 0} {

                        puts -nonewline $outfile "db create pin_tap_spec $dn  -name para_pintap_$layername\_$i\_$j\_$l  -route_layer $layername   -nets { $np($i) } -vias_between_parallel_metals 1  -parallel_metals_via_spec { 0 0 } -via_occupancy_percentage { 100 100 } -all_insts"

                        } else {

                        puts -nonewline $outfile "db edit $dn/pin_tapping:para_pintap_$layername\_$i\_$j\_$l -name para_pintap_$layername\_$i\_$j\_$l  -route_layer $layername   -nets { $np($i) } -vias_between_parallel_metals 1  -parallel_metals_via_spec { 0 0 } -via_occupancy_percentage { 100 100 } -all_insts"

                if {$flag_create_clone_files == 1 && $clone > 0} {

                        puts -nonewline $clonefile($clone) "db edit $dn/pin_tapping:para_pintap_$layername\_$i\_$j\_$l -name para_pintap_$layername\_$i\_$j\_$l  -route_layer $layername   -nets { $np($i) } -vias_between_parallel_metals 1  -parallel_metals_via_spec { 0 0 } -via_occupancy_percentage { 100 100 } -all_insts"

 

                        }

                        }

                        if {$pin_layers ne ""} {

                        puts -nonewline $outfile " -pin_layers { $pin_layers  }"

                        if {$flag_create_clone_files == 1 && $clone > 0} {

                        puts  -nonewline $clonefile($clone)  " -pin_layers { $pin_layers  } "

 

                        }

                        } else {

                        puts -nonewline $outfile " -all_pin_layers "

                        if {$flag_create_clone_files == 1 && $clone > 0} {

                        puts  -nonewline $clonefile($clone)  " -all_pin_layers "

 

                        }

                        }

                        if {$pin_tap_lvcut ne ""} {

                        puts -nonewline $outfile " -via_num_cuts {$pin_tap_lvcut}"

                        if {$flag_create_clone_files == 1 && $clone > 0} {

                        puts  -nonewline $clonefile($clone)  " -via_num_cuts {$pin_tap_lvcut}"

 

                        }

                        }

                        if {$pin_tap_lvrule ne ""} {

                        puts -nonewline $outfile  " -via_rules {$pin_tap_lvrule}"

                        if {$flag_create_clone_files == 1 && $clone > 0} {

                        puts -nonewline $clonefile($clone) " -via_rules {$pin_tap_lvrule}"

 

                        }

                        }

                        puts $outfile ""

flush $outfile

                        if {$flag_create_clone_files == 1 && $clone > 0} {

                        puts $clonefile($clone) ""

                        }

                }

                }

                if {($clone > 0 && $clone_power == 1) || $clone == 0 } {

                if {[info exists power_number($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Power)] && $power_number($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Power) ne ""} {

                set count_powerpitch [llength $power_number($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Power)]

                if {$clone == 0} {

                if {$count_powerpitch > $count_clones_power($net_pair($i),$block_name($net_pair($i),$i,$j),$l)} {

                set count_clones_power($net_pair($i),$block_name($net_pair($i),$i,$j),$l)  $count_powerpitch

                }

                }

                set powerpitch [lindex $power_number($net_pair($i),$block_name($net_pair($i),$i,$j),$l,$layername,Power) $clone]

                if {$powerpitch eq ""} {

                set powerpitch $old_powerpitch($net_pair($i),$block_name($net_pair($i),$i,$j),$l)

                }

                set old_powerpitch($net_pair($i),$block_name($net_pair($i),$i,$j),$l) $powerpitch

 

                regsub -all {\+} $linclude " " linclude1

               split $linclude1

                set cnt1 0

                for {set ilin 0} {$ilin < [llength $linclude1]} {incr ilin} {

                set cnt 0

                if {$clone == 0} {

                puts $outfile ""

flush $outfile

                puts -nonewline $outfile " db create power_spec $dn -name para_power_$layername\_$i\_$j\_$l\_$cnt1 -spec_boundary \{ select_region \{[lindex $linclude1 $ilin]\} \} -static_power \{"

 

                } else {

                puts $outfile ""

flush $outfile

                puts -nonewline $outfile " db edit $dn/power:para_power_$layername\_$i\_$j\_$l\_$cnt1 -spec_boundary \{ select_region \{[lindex $linclude1 $ilin]\} \} -static_power \{"

                }

                foreach np1 $np($i) {

 

                        regsub -all  ":" $powerpitch " " pn

                        regsub -all -- {[[:space:]]+} $pn " " pn

                        split $pn

                        regsub  -all {\}|\{} $pn " " pn

                        set pn1 [lindex $pn $cnt]

                        if {$pn1 eq ""} {

                        } else {

                                puts -nonewline $outfile "\{ $np1 $layername $pn1\} "

                        }

                incr cnt

                }

                puts $outfile "\}"

flush $outfile

                if {$flag_create_clone_files == 1 && $clone > 0} {

                puts $outfile ""

flush $outfile

                puts -nonewline $clonefile($clone) " db edit $dn/power:para_power_$layername\_$i\_$j\_$l_$cnt1 -spec_boundary \{ select_region \{[lindex $linclude1 $ilin]\} \} -static_power \{"

                foreach np1 $np($i) {

 

                        regsub -all  ":" $powerpitch " " pn

                        regsub -all -- {[[:space:]]+} $pn " " pn

                        split $pn

                        regsub  -all {\}|\{} $pn " " pn

                        set pn1 [lindex $pn $cnt]

                        if {$pn1 eq ""} {

                        } else {

                                puts -nonewline $clonefile($clone) "\{ $np1 $layername $pn1\} "

                        }

                incr cnt

                }

                puts $clonefile($clone) "\}"

                }

                incr cnt1

                }

                }

           }

        }

        }

###### looping through Layers - Done

        if {$open_cell == 1} {

                puts $outfile "gui close /work/$inst_cell\::$session"

flush $outfile

        }

   }

 

}

}

 

 

 

}

 

proc create_via_tcl {} {

global clonefile

global outfile

global log

global count_block

global block

global block_data

global count_clones_via

global clone_vblock

global clone_count_vblocks

global clone

global design_name

global flag_create_clone_files

 

if {$clone > 0} {

set session c$clone

} else {

set session p

}

for {set i 1 } {$i <= $count_block(viamesh)} {incr i} {

if {$clone > 0} {

if {[info exists clone_vblock] && [info exists clone_count_vblocks]} {

if {![regexp "^$clone_vblock\$" $block(viamesh,$i)] || ! [regexp "^$clone_count_vblocks\$" $i]} {

continue

}

}

}

                if {$clone == 0} {

                 set count_clones_via(viamesh,$block(viamesh,$i),$i) 0

                }

 

        ###### Deciding whethere the provided name under Nets is cell or instance name

                if {[catch {set inst_cell $block_data(viamesh,$block(viamesh,$i),$i,Name)}] == 0 } {

                set result [find_cellname $inst_cell $session]

                } else {

                puts $log "Please provide Valid block/region name for $net_pair($i)"

flush $log

                puts stderr "Please provide Valid block/region name for $net_pair($i)"

                return

        }

                split $result

                set dn [lindex $result 0]

                set qcn [lindex $result 1]

                set xy "[lindex $result 2] [lindex $result 3] [lindex $result 4] [lindex $result 5]"

                regsub  -all {\{|\}} $xy "" xy

        ###### Deciding whethere the provided name under Nets is cell or instance name - Done

                if { [catch {set viaviadrop $block_data(viamesh,$block(viamesh,$i),$i,Via_drop_layers)} ] == 1 } {

                puts stderr "Please provide Top and Bottom layers for recreating vias in block $block(viamesh,$i)"

                puts $log "Please provide Top and Bottom layers for recreating vias in block $block(viamesh,$i)"

flush $log

                return

                }

                regsub -all  ":" $viaviadrop " " viaviadrop

                regsub -all -- {[[:space:]]+} $viaviadrop " " viaviadrop

                split $viaviadrop

                regsub -all {\{|\}} $viaviadrop "" viaviadrop

                if { [catch {set viaoffset $block_data(viamesh,$block(viamesh,$i),$i,Offset)} ] == 1 } {

                        set viaoffset "0 0 0 0"

                }

                if { [catch {set vianets $block_data(viamesh,$block(viamesh,$i),$i,Nets)} ] == 1 } {

                        set vianets ""

                }

                regsub -all  ":" $vianets " " vianets

                regsub -all -- {[[:space:]]+} $vianets " " vianets

                split $vianets

                regsub -all {\{|\}} $vianets "" vianets

        if { [catch {set viaviamodel $block_data(viamesh,$block(viamesh,$i),$i,Via_model)}] ==1 } {

                        set vviamodel ""

                        set count_vviamodel 0

                        } else {

                        set count_vviamodel [llength $viaviamodel]

                           set vviamodel [lindex $viaviamodel $clone]

                           if {$vviamodel eq ""} {

                                set vviamodel $old_vviamodel(viamesh,$block(viamesh,$i),$i)

                           }

                           set old_vviamodel(viamesh,$block(viamesh,$i),$i) $vviamodel

                           regsub  -all ":" $vviamodel " " vviamodel

                           regsub -all -- {[[:space:]]+} $vviamodel " " vviamodel

                           split $vviamodel

                           regsub  -all {\}|\{} $vviamodel " " vviamodel

                        }

 

                        if { [catch {set viaviarule $block_data(viamesh,$block(viamesh,$i),$i,Via_rule)}] ==1 } {

                        set vviarule ""

                        set count_vviarule 0

                        } else {

                        set count_vviarule [llength $viaviarule]

                           set vviarule [lindex $viaviarule $clone]

                           if {$vviarule eq ""} {

                                set vviarule $old_vviarule(viamesh,$block(viamesh,$i),$i)

                           }

                           set old_vviarule(viamesh,$block(viamesh,$i),$i) $vviarule

                           regsub -all ":" $vviarule " " vviarule

                           regsub -all -- {[[:space:]]+} $vviarule " " vviarule

                           split $vviarule

                           regsub  -all {\}|\{} $vviarule " " vviarule

                        }

                        set vexclude ""

                        if {[catch {set via_exclude $block_data(viamesh,$block(viamesh,$i),$i,Exclude)}] == 0} {

                           regsub -all -- {[[:space:]]+} $vexclude "" vexclude

                          regsub -all ":" $via_exclude "-" vexclude

                           split $vexclude

                           regsub  -all {\}|\{} $vexclude "" vexclude

                           set vexclude "-$vexclude"

                        }

                        set vinclude "$inst_cell"

                        if {[catch {set via_include $block_data(viamesh,$block(viamesh,$i),$i,Include)}] == 0} {

                           regsub -all -- {[[:space:]]+} $vinclude "" vinclude

                           regsub -all ":" $via_include "+" vinclude

                           split $vinclude

                           regsub  -all {\}|\{} $vinclude "" vinclude

                           set vinclude "+$vinclude"

                        }

                        set via_offset_exists 0

                        if {[catch {set via_offset $block_data(viamesh,$block(viamesh,$i),$i,Offset)}] == 0} {

                        set via_offset_exists 1

                        }

                        if {$clone == 0} {

                        if {$count_vviamodel > $count_clones_via(viamesh,$block(viamesh,$i),$i)} {

                        set count_clones_via(viamesh,$block(viamesh,$i),$i) $count_vviamodel

                        }

                        if {$count_vviarule > $count_clones_via(viamesh,$block(viamesh,$i),$i)} {

                        set count_clones_via(viamesh,$block(viamesh,$i),$i) $count_vviarule

                        }

                        }

                if {[info exists block_data(viamesh,$block(viamesh,$i),$i,Delete_existing)]} {

                if {$block_data(viamesh,$block(viamesh,$i),$i,Delete_existing) == 1} {

                        puts -nonewline $outfile "perform adv_via_edit $dn -layer { $viaviadrop }  -delete_vias"

                                if {$via_offset_exists == 1} {

                                puts $outfile " -spec_boundary {bbox {$via_offset}}"

flush $outfile

 

                                } else {

                                puts $outfile " -spec_boundary {select_region {$vinclude $vexclude}}"

flush $outfile

 

                                }

 

                }

                }

                puts -nonewline $outfile "perform adv_via_edit $dn -layer { $viaviadrop }  -via_rules {$vviarule } -via_models {$vviamodel} -vias_between_parallel_metals 1  -parallel_metals_via_spec { 0 0 } -via_occupancy_percentage { 100 100 } -short_check 1 -min_spacing 0.0005"

                if {$flag_create_clone_files == 1 && $clone > 0} {

                puts -nonewline $clonefile($clone) "perform adv_via_edit $dn -layer { $viaviadrop }  -via_rules {$vviarule } -via_models {$vviamodel} -vias_between_parallel_metals 1  -parallel_metals_via_spec { 0 0 } -via_occupancy_percentage { 100 100 } -short_check 1 -min_spacing 0.0005"

 

                }

                if {$via_offset_exists == 1} {

                puts $outfile " -spec_boundary {bbox {$via_offset}}"

flush $outfile

                if {$flag_create_clone_files == 1 && $clone > 0} {

                puts $clonefile($clone) " -spec_boundary {bbox {$via_offset}}"

                }

                } else {

                puts $outfile " -spec_boundary {select_region {$vinclude $vexclude}}"

flush $outfile

                if {$flag_create_clone_files == 1 && $clone > 0} {

                puts $clonefile($clone) " -spec_boundary {select_region {$vinclude $vexclude}}"

                }

                }

 

}

}

 

 

 

 

 

proc create_clones {} {

global count_clones_route

global clone

global count_clones_switch

global outfile

global log

global flag_create_clone_files

global clonefile

global design_name

global clone_stype

global clone_spin_pair

global clone_sregion_name

global count_switch

global count_region_switch

global switch_pin_pair

global read_switch

global switch_region

global done

global pad_file

global pad_data

global count_nets

global count_clones_pad

global count_pypitch

global net_pair

global clone_pnetpair

global clone_count_nets

global count_blocks

global count_layer

global clone_rnetpair

global clone_count_rnets

global clone_rblock

global clone_count_rblocks

global clone_rlayer

global clone_count_rlayer

global block_name

global layer_name

global clone_power

global count_clones_power

global block

global clone_vblock

global clone_count_vblocks

global count_block

global count_clones_via

set clone_open($clone) 0

set done_switch 1

set done_pad 1

set done_route 1

set done_via 1

 

 

###### Deciding whether to create clone or not Based on Switch cell

set done_switch 1

if {[info exists count_switch] && $count_switch(noring) > 0} {

for {set i 1} {$i<= $count_switch(noring)} {incr i} {

for {set j 1} {$j<= $count_region_switch(noring,$switch_pin_pair(noring,$i))} {incr j} {

if {$count_clones_switch(noring,$switch_pin_pair(noring,$i),$read_switch(noring,$switch_pin_pair(noring,$i),$switch_region(noring,$switch_pin_pair(noring,$i),$j),Name)) <= $clone} {

} else {

set done_switch 0

if {$clone_open($clone) == 0} {

create_clones_open_tcl

set clone_open($clone) 1

}

set clone_stype "noring"

set clone_spin_pair $switch_pin_pair(noring,$i)

set clone_sregion_name $read_switch(noring,$switch_pin_pair(noring,$i),$switch_region(noring,$switch_pin_pair(noring,$i),$j),Name)

create_switch_tcl $clone

}

}

}

}

###### Deciding whether to create clone or not Based on Switch cell - Done

 

 

 

 

###### Deciding whether to create clone or not Based on Route Sweeps - Done

set done_route 1

set done_power 1

if {[info exists count_nets]} {

for {set i 1 } { $i <= $count_nets} {incr i} {

if {[info exists count_blocks] && $count_blocks($net_pair($i),$i) > 0} {

   for {set j 1} { $j <= $count_blocks($net_pair($i),$i)} {incr j} {

        if {[info exists count_layer($net_pair($i),$block_name($net_pair($i),$i,$j))] && $count_layer($net_pair($i),$block_name($net_pair($i),$i,$j)) > 0} {

           for { set l 1 } {$l <= $count_layer($net_pair($i),$block_name($net_pair($i),$i,$j))}  {incr l} {

           if {$count_clones_route($net_pair($i),$block_name($net_pair($i),$i,$j),$l) <= $clone} {

                } else {

                set done_route 0

                if {$clone_open($clone) == 0} {

                create_clones_open_tcl

                set clone_open($clone) 1

                }

                set clone_rnetpair $net_pair($i)

                set clone_count_rnets $i

                set clone_rblock $block_name($net_pair($i),$i,$j)

                set clone_count_rblocks $j

                set clone_rlayer $layer_name($net_pair($i),$block_name($net_pair($i),$i,$j),$l)

                set clone_count_rlayer $l

                set clone_power 0

                create_net_route_tcl

                }

                if {$count_clones_power($net_pair($i),$block_name($net_pair($i),$i,$j),$l) <= $clone} {

                } else {

                set done_power 0

                if {$clone_open($clone) == 0} {

                create_clones_open_tcl

                set clone_open($clone) 1

                }

                set clone_rnetpair $net_pair($i)

                set clone_count_rnets $i

                set clone_rblock $block_name($net_pair($i),$i,$j)

                set clone_count_rblocks $j

                set clone_rlayer $layer_name($net_pair($i),$block_name($net_pair($i),$i,$j),$l)

                set clone_count_rlayer $l

                set clone_power 1

                create_net_route_tcl

                }

           }

        }

   }

}

}

}

###### Deciding whether to create clone or not Based on Route Sweeps - Done

 

###### Deciding whether to create clone or not Based on Pad pitch

set done_pad 1

if {[info exists count_nets]} {

for {set i 1 } { $i <= $count_nets} {incr i} {

if {![info exists Pad_file] && [info exists pad_data($net_pair($i),$i,X_pitch)]} {

if {$count_clones_pad($net_pair($i),$i) <= $clone} {

} else {

set done_pad 0

if {$clone_open($clone) == 0} {

create_clones_open_tcl

set clone_open($clone) 1

}

set clone_pnetpair $net_pair($i)

set clone_count_nets $i

create_net_pad_tcl

}

}

}

}

 

###### Deciding whether to create clone or not Based on Pad pitch - Done

 

 

 

 

###### Deciding whether to create clone or not Based on Via Sweeps

set done_via 1

if {[info exists count_block(viamesh)]} {

for {set i 1 } {$i <= $count_block(viamesh)} {incr i} {

if {[ info exists count_clones_via(viamesh,$block(viamesh,$i),$i)]} {

        if { $count_clones_via(viamesh,$block(viamesh,$i),$i) > 0} {

           if {$count_clones_via(viamesh,$block(viamesh,$i),$i) <= $clone} {

           } else {

                set done_via 0

                if {$clone_open($clone) == 0} {

                create_clones_open_tcl

                set clone_open($clone) 1

                }

                set clone_vblock $block(viamesh,$i)

                set clone_count_vblocks $i

                create_via_tcl

           }

 

 

           }

        }

 

}

}

###### Deciding whether to create clone or not Based on Via Sweeps - Done

global analysistype
global batch_option
if {$flag_create_clone_files == 1 } {

if {[info exists clonefile($clone)]} {

                puts $clonefile($clone) "\nauto_gui_update on"

                puts $clonefile($clone) "refresh_gui"

if {$batch_option == 0} {
puts $clonefile($clone)  "rh perform analysis /work/$design_name\::c$clone -$analysistype"
} else {
puts $clonefile($clone)  "rh perform analysis /work/$design_name\::c$clone -$analysistype -batch"
}

puts $clonefile($clone) "######## End of Clone c[expr {$clone-1}]\n\n\n\n"

close $clonefile($clone)

 

}

}

if {$done_pad == 1 && $done_switch == 1 && $done_route == 1 && $done_power == 1 && $done_via == 1} {

set done 1

global flag_launch_explorer

if {$flag_launch_explorer == 1} {

puts $outfile "launch_explorer -design $design_name -clone_count [expr {$clone-1}] -gps_run_dir ./ -report_only 0"

flush $outfile

}

} else {

puts $outfile "\nauto_gui_update on"

flush $outfile

puts $outfile "refresh_gui"

flush $outfile

global batch_option
if {$batch_option == 0} {
puts $outfile  "rh perform analysis /work/$design_name\::c$clone -$analysistype"
} else {
puts $outfile  "rh perform analysis /work/$design_name\::c$clone -$analysistype -batch"
}

flush $outfile

set done 0

}

incr clone

}

 

proc create_clones_open_tcl {} {

global clone

global flag_create_clone_files

global clonefile

global log

global outfile

global design_name

 

##### Opening the clone session

if {$clone > 1} {

#puts $outfile "db open cell /work/$design_name"

flush $outfile

 

puts $outfile "gui close \$clone_session"

flush $outfile

puts $outfile "######## End of Clone c[expr {$clone-1}]\n\n\n\n"

flush $outfile

}

puts $outfile "\n\n\n\n######## Start of Clone c$clone"

flush $outfile

if {[expr {$clone-1}] == 0} {

set session  "p"

} else {

set session "c[expr {$clone-1}]"

}

puts $outfile "set clone_session \[db clone cell /work/$design_name \]"

flush $outfile

puts $outfile "db open cell \$clone_session "

flush $outfile

                puts $outfile "\nauto_gui_update off"

flush $outfile

if {$flag_create_clone_files == 1 } {

global clonefile

exec touch  clones_tcl/clone_$clone\.tcl

file copy -force clones_tcl/parent.cmd  clones_tcl/clone_$clone\.tcl

set clonefile($clone) [open "clones_tcl/clone_$clone\.tcl" a]

exec cp clones_tcl/parent.cmd clones_tcl/clone_$clone\.tcl

puts  $clonefile($clone) "\n\n\n\n######## Start of Clone c$clone"

puts  $clonefile($clone) "db open cell /work/$design_name"

puts  $clonefile($clone) "set clone_session \[db clone cell /work/$design_name \]"

puts  $clonefile($clone) "db open cell \$clone_session "

                puts $clonefile($clone) "\nauto_gui_update off"

}

 

puts $log "Creating Clone c$clone - Done"

flush $log

##### Opening the clone session - END

 

}
#!/usr/bin/tclsh

proc create_pg_connectivity_file {args} {

if {[regexp "out_dir" [lindex $args 2]]} {

} else {
error "Wrong argument. Correct usage is create_pg_connectivity_file -design <top design>  -out_dir <>"
exit;
}

if {[regexp "design" [lindex $args 0]]} {

} else {
error "Wrong argument. Correct usage is create_pg_connectivity_file -design <top design> -out_dir <>"
exit;
}

set design [lindex $args 1];

global design_path;
global design_path;
global net;
global Inst;
global Instpin;
global net_name;

set design_path "/work/$design";
set path [lindex $args 3];
set fp [open "$path/pg_connectivity.rpt" w];

puts $fp "#PG_DOMAINS DOMAIN VOLTAGE"

db foreach net "query $design_path nets -type power" {
if {[catch {set voltage [db query $net voltage]}] ==  0 } {
    regsub "$design_path\/net\:" $net {} net
   puts $fp "$net POWER $voltage";
} else {
#puts $errorInfo
}
}

db foreach net "query $design_path nets -type ground" {
if {[catch {set voltage [db query $net voltage]}] == 0 } {
regsub "$design_path\/net\:" $net {} net
puts $fp "$net GROUND $voltage";
}
}

puts $fp "#END_PG_DOMAINS"

puts $fp "#Instance   <net1>   <pin1>    <net2> ...."

db foreach Inst "query $design_path insts -hier_level {0 max} " { 

regsub "$design_path\/" $Inst {} Inst1

if {[catch {set power_conn [db query $Inst connectivity -type power -top_net 1];}] == 0} {
regsub -all { { ([A-Za-z0-9_]+)  } } $power_conn "" power_conn
set power_split [regsub {\s{2,}} [string trim [string map {"{" "" "}" ""} $power_conn]] " "]

regsub -all {\s+} $power_split { } power_split
set p_length [llength $power_split];
set power_net [lindex $power_split 1];
set power_pin [lindex $power_split 0];
set power "$power_net $power_pin";

for {set p_count 2} {$p_count < $p_length} {incr p_count} {
set flag [expr $p_count%2];
#puts $power_split
if { $flag == 0} {
set var_inc [expr $p_count+1];
#puts $power_split
set power_net [lindex $power_split $var_inc];
set power_pin [lindex $power_split $p_count];

lappend power "$power_net $power_pin";
regsub -all "\{" $power {} power
regsub -all "\}" $power {} power
regsub -all {\s+} $power { } power
}
}


if {[catch {set ground_conn [db query $Inst connectivity -type ground -top_net 1];}] == 0} {

regsub -all { { ([A-Za-z0-9_]+)  } } $ground_conn "" ground_conn

set ground_split [regsub {\s{2,}} [string trim [string map {"{" "" "}" ""} $ground_conn]] " "]

regsub -all {\s+} $ground_split { } ground_split
set g_length [llength $ground_split];

set ground_net [lindex $ground_split 1];
set ground_pin [lindex $ground_split 0];
set ground "$ground_net $ground_pin";

for {set g_count 2} {$g_count < $g_length} {incr g_count} {
set flag [expr $g_count%2];
#puts $ground_split
if { $flag == 0} {
set var_inc [expr $g_count+1];
set ground_net [lindex $ground_split $var_inc];
set ground_pin [lindex $ground_split $g_count];

lappend ground "$ground_net $ground_pin";
regsub -all "\{" $ground {} ground
regsub -all "\}" $ground {} ground
regsub -all {\s+} $ground { } ground
}
}

if {$power != " " || $ground != " "} {
puts $fp "$Inst1 $power $ground";

}

}
}
} 

close $fp;

}
