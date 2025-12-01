############################################################################
# RTL to GATE name mapping file
# Shreya Sashi <shreya.sashi@ansys.com>
# Raj S Kashyap <raj.kashyap@ansys.com>
# Eldo N Baby <eldo.baby@ansys.com>
############################################################################
proc GenerateMapfileBlock {args} {
config cmdlog no
global env

set cnt 0

set argv [split $args];

set BLOCK_NUMBER [lindex $argv 0]
set RTLSimFile [lindex $argv 1]
set FRONT_PATH [lindex $argv 2]
set SUBSTITUTE_PATH [lindex $argv 3]
set RTLSimFileType [lindex $argv 4]
set RuleFile [lindex $argv 5] 
regsub -all {\"} $SUBSTITUTE_PATH {} SUBSTITUTE_PATH
regsub -all {\{} $SUBSTITUTE_PATH {} SUBSTITUTE_PATH
regsub -all {\}} $SUBSTITUTE_PATH {} SUBSTITUTE_PATH
regsub -all {/$} $SUBSTITUTE_PATH {} SUBSTITUTE_PATH
regsub -all {\"} $FRONT_PATH {} FRONT_PATH
regsub -all {\}} $FRONT_PATH {} FRONT_PATH
regsub -all {\{} $FRONT_PATH {} FRONT_PATH
regsub -all {{}} $BLOCK_NUMBER {} BLOCK_NUMBER

if {$SUBSTITUTE_PATH ne ""} {
    append SUBSTITUTE_PATH "/"
}

set MapRunDir      ".apache"
set RTL_REGS       ".apache/rtl_regs_list.txt"
set RTL_INSTS      ".apache/rtl_insts_list.txt"
set GATE_REGS      ".apache/gate_regs_list.txt"
set GATE_INSTS     ".apache/gate_insts_list.txt"
set GATE_REGS_PINS ".apache/gate_regs_pins_list.txt"
set MAP_FILE       ".apache/rtl2gate.map.points"
set RTL_INSTS_MAP  ".apache/insts_map_rtl.map"
set GATE_INSTS_MAP ".apache/insts_map_gate.map"
set GATE_PORTS_MAP ".apache/insts_map_ports.map"

if {$BLOCK_NUMBER ne ""} {
    append RTL_REGS   ".blk" $BLOCK_NUMBER
    append RTL_INSTS  ".blk" $BLOCK_NUMBER
    append GATE_REGS  ".blk" $BLOCK_NUMBER
    append GATE_INSTS ".blk" $BLOCK_NUMBER
    append GATE_REGS_PINS  ".blk" $BLOCK_NUMBER
    append MAP_FILE        ".blk" $BLOCK_NUMBER
    append RTL_INSTS_MAP   ".blk" $BLOCK_NUMBER
    append GATE_INSTS_MAP  ".blk" $BLOCK_NUMBER
    append GATE_PORTS_MAP  ".blk" $BLOCK_NUMBER
}


#if {$RTLSimFileType eq "RTL_FSDB" || $RTLSimFileType eq "EVENT_RPM" || $RTLSimFileType eq "TOGGLE_RPM"} {
#    set fsdbdebug "$env(APACHEROOT)/bin/fsdbdebug"
#}

# Run RTL Sim parser:
if {$RTLSimFileType eq "RTL_FSDB" || $RTLSimFileType eq "EVENT_RPM" || $RTLSimFileType eq "TOGGLE_RPM" || $RTLSimFileType eq "FSDB"} {
    set fsdbdebug "$env(APACHEROOT)/bin/fsdbdebug"
    set fsdbdebug_file "$MapRunDir/fsdbdebug.log"
    if {[catch {exec $fsdbdebug -tree $RTLSimFile >& $fsdbdebug_file} fid]} {
	message log "FSDB processing failed. Please check the fsdb file, and its version\n"
	return
	}
    message log "Parsing the FSDB....\n"
    message log [exec perl "$env(APACHEROOT)/scripts/parse_fsdb.pl" -fsdb_file $fsdbdebug_file -topinst $FRONT_PATH -run_dir $MapRunDir -out_reg $RTL_REGS -out_inst $RTL_INSTS -rule_file $RuleFile]
    message log "FSDB parsing done.\n"
} else {
    message log "Parsing the VCD....\n"
    message log [exec "$env(APACHEROOT)/scripts/parse_vcd" -vcd_file $RTLSimFile -topinst $FRONT_PATH -run_dir $MapRunDir -out_reg $RTL_REGS -out_inst $RTL_INSTS -rule_file $RuleFile]
    message log "VCD parsing done.\n"
}
# Generate gate data
message log "Generating GATE level data from RedHawk DB\n"
set gate_regs_file  [open $GATE_REGS  w]
set gate_insts_file [open $GATE_INSTS w]
set gate_regs_pins  [open $GATE_REGS_PINS  w]

if { ![catch {set flop_ids [get inst_by_cid *$SUBSTITUTE_PATH* -glob -type flop]} fid] } {
	foreach id $flop_ids {
	if { ![catch {lappend flops [get inst_by_cid $id -name]} fid] } {
	}
	}
set flops_sorted [lsort -dictionary $flops]
 foreach flop $flops_sorted {
    if { ![catch {set master [get inst $flop -master]} fid] } {
    }
    if { [catch {set pins [get cell $master -pins -direction output]} fid] } {
        set out "no_out_pins"
    } else {
        set out "$pins"
    }
    puts $gate_regs_pins $out
    if {$SUBSTITUTE_PATH ne ""} {
        regsub -all $SUBSTITUTE_PATH $flop {} flop
    }
	puts $gate_regs_file $flop
 }
}
message log "Done generating list of flops\n"

if { [catch {set insts_id [get inst_by_cid *$SUBSTITUTE_PATH* -glob]} fid] } {
    message log "Mapping Error: could not get inst id list"
}

foreach inst_id $insts_id {
    if { ![catch {set master [get inst_by_cid $inst_id -master]} fid] } {
    }
    if { ![catch {set celltype [get cell $master -type]} fid] } {
    }
    set inst [get inst_by_cid $inst_id -name]
        
    if { [regexp "primitive  seq_generic" $celltype]}  {
        if { [catch {set pins [get cell $master -pins -direction output]} fid] } {
            set out "no_out_pins"
        } else {
            set out "$pins"
        }
    puts $gate_regs_pins $out
    if {$SUBSTITUTE_PATH ne ""} {
        regsub -all $SUBSTITUTE_PATH $inst {} inst
    }
    puts $gate_regs_file  $inst
  }
    if {$SUBSTITUTE_PATH ne ""} {
        regsub -all $SUBSTITUTE_PATH $inst {} inst
    }
	puts $gate_insts_file $inst
}

close $gate_regs_file
close $gate_insts_file
close $gate_regs_pins
message log "Done generating list of all instances\n"

###################
# Map IO ports
set out_map_file [open $MAP_FILE w]
        if { ![catch {set pins [get cell [ get design ] -pins]} fid] } {
        }

# run mapping script
exec "$env(APACHEROOT)/scripts/generate_mapfile" -top $FRONT_PATH -topinst "" -format rh -flop_port_name "" -run_dir $MapRunDir -rtl_regs $RTL_REGS -rtl_insts $RTL_INSTS -gate_regs $GATE_REGS -gate_insts $GATE_INSTS -gate_regs_pins $GATE_REGS_PINS -out_mapped_gate_insts $GATE_INSTS_MAP -out_file $MAP_FILE -out_mapped_rtl_insts $RTL_INSTS_MAP -rule_file $RuleFile

# Get ports of all instances
set out_file   [open $GATE_PORTS_MAP w]
set in         [open $GATE_INSTS_MAP r]
set insts      [read $in]
set gate_insts [split $insts "\n"]

foreach inst $gate_insts {
    if {$inst ne ""} {
        if {$SUBSTITUTE_PATH ne ""} {
            set inst "$SUBSTITUTE_PATH$inst"
        }
	    regsub -all {\[} $inst {\\[} inst
	    regsub -all {\]} $inst {\\]} inst
        if { ![catch {set master [get inst $inst -master]} fid] } {
            if { ![catch {set ports [get cell $master -pins]} fid] } {
                regsub -all {\}} $ports {} ports
                regsub -all {\{} $ports {} ports
                puts $out_file "$ports"
            } else {
                puts $out_file "NA"
            }
        }
    }
}
close $out_file

# Merge insts ports with original mapfile
puts [exec perl "$env(APACHEROOT)/scripts/merge_rh_map_files.pl" -run_dir $MapRunDir -rtl_map $RTL_INSTS_MAP -gate_insts $GATE_INSTS_MAP -gate_ports $GATE_PORTS_MAP -out_file $MAP_FILE]

message log "Mapping file generated at $MAP_FILE\n"

# cleaning up intermediate files
# exec rm -rf "$MapRunDir/rtl_regs_list.txt"
# exec rm -rf "$MapRunDir/rtl_insts_list.txt"
# exec rm -rf "$MapRunDir/gate_regs_list.txt"
# exec rm -rf "$MapRunDir/special_points.map"
# exec rm -rf "$MapRunDir/gate_insts_list.txt"
# exec rm -rf "$MapRunDir/insts_map_rtl.map"
# exec rm -rf "$MapRunDir/insts_map_gate.map"
# exec rm -rf "$MapRunDir/insts_map_ports.map"
}

proc GenerateMapfile {{args}} {
    if { $args eq "-help" } {
        message log "USAGE:\n"
        message log "1. GenerateMapfile\n\n"
        message log "2. GenerateMapfile ?(-rule_file <file>)\nEg. GenerateMapfile -rule_file rule.file\n\n"
        puts "3. GenerateMapfile ?(-change_rtl_name <rtl> <gate>) ?(-skip_rtl_element <RTL element to ignore>) ?(-skip_gate_element <GATE element to ignore>) ?(-define_bus_rule <rtl bus> <gate transform>) -rtl_inst_level \[0|1\]\nEg. GenerateMapfile -change_rtl_name \"block_RTL block_GATE\" -skip_rtl_element \"dummy_RTL\" -skip_gate_element \"DFT\" -define_bus_rule {\[\%d\] _reg_\%d} -rtl_inst_level \[0|1\]\n"
        message log "4. GenerateMapfile ?(-change_rtl_name <rtl> <gate>) ?(-skip_rtl_element <RTL element to ignore>) ?(-skip_gate_element <GATE element to ignore>) ?(-define_bus_rule <rtl bus> <gate transform>) ?(-rule_file <file)\nEg. GenerateMapfile -skip_gate_element \"scan\" -rule_file <file> -rtl_inst_level \[0|1\]\n\n"
        message log "The rule file is an optional input and can accept following syntax: 
    change_rtl_name <rtl_name> <gate_name> 
    change_gate_name <gate_name> <rtl_name> 
    skip_gate_element <gate_element>    
    skip_rtl_element <rtl_element>
    define_bus_rule <rtl bus> <gate transform>
    include_rtl_wire \[0|1\]
    case_sensitive \[0|1\]
    rtl_inst_level \[0|1\]\n\n"

        return
    }

    array set opt [concat { -rule_file "" -change_rtl_name "" -change_gate_name "" -skip_rtl_element "" -skip_gate_element "" -define_bus_rule "" -rtl_inst_level "" -include_rtl_wire "" -case_sensitive ""} $args]
    set rule_file $opt(-rule_file)
    set change_rtl_name $opt(-change_rtl_name)
    set include_rtl_wire $opt(-include_rtl_wire)
    set case_sensitive $opt(-case_sensitive)
    set change_gate_name $opt(-change_gate_name)
    set skip_rtl_element $opt(-skip_rtl_element)
    set skip_gate_element $opt(-skip_gate_element)
    set define_bus_rule $opt(-define_bus_rule)
    set rtl_inst_level $opt(-rtl_inst_level)
    if { $rule_file ne "" } {
        exec cp $rule_file .apache/mapping.rule_file
        set rule [open .apache/mapping.rule_file a]
    } else {
        set rule [open .apache/mapping.rule_file w]
    }
    set rule_file ".apache/mapping.rule_file"
    if { $change_rtl_name ne "" } {
        puts $rule "change_rtl_name $change_rtl_name\n"
        set rule_file ".apache/mapping.rule_file"
    }
    if {$case_sensitive ne "" } {
        puts $rule "case_sensitive $case_sensitive\n"
        set rule_file ".apache/mapping.rule_file"
    } 
# this part causing case_sensitive 1 to be added to rule_file everytime.
#else { 
#      set gsr_case [gsr get NAME_CASE_SENSITIVE]
#      set case_sensitive [lindex $gsr_case 0]
#        puts $rule "case_sensitive $case_sensitive\n"
#        set rule_file ".apache/mapping.rule_file"
#    }
    if { $include_rtl_wire ne "" } {
        puts $rule "include_rtl_wire $include_rtl_wire\n"
        set rule_file ".apache/mapping.rule_file"
    }
    if { $change_gate_name ne "" } {
        puts $rule "change_gate_name $change_gate_name\n"
        set rule_file ".apache/mapping.rule_file"
    }
    if { $skip_rtl_element ne "" } {
        puts $rule "skip_rtl_element $skip_rtl_element"
        set rule_file ".apache/mapping.rule_file"
    }
    if { $skip_gate_element ne "" } {
        puts $rule "skip_gate_element $skip_gate_element"
        set rule_file ".apache/mapping.rule_file"
    }
    if { $define_bus_rule ne "" } {
        puts $rule "define_bus_rule $define_bus_rule"
        set rule_file ".apache/mapping.rule_file"
    }
    if { $rtl_inst_level ne "" } {
        puts $rule "rtl_inst_level $rtl_inst_level"
        set rule_file ".apache/mapping.rule_file"
    }

    close $rule
        
# set rule_file ""
# set argv [split $args];
# set state flag_s;
# foreach arg $argv {
#     switch -- $state {
#         flag_s {
#             switch -glob -- $arg {
#                 -rule_file { set state rule_file_s}
#             }
#         }
#         rule_file_s {
#             set rule_file $arg
#             set state flag_s
#         }
#     }
# }
config cmdlog no
global env

message log "GenerateMapfile proc started on [exec date]\n"

if { [catch {set tt [gsr get VCD_FILE]} fid] } {
    message log "Import GSR not happened. Call GenerateMapfile after setup design \n"
    return
}
if { [catch {set top [get design]} fid] } {
    message log "Setup design not happened. Call GenerateMapfile after setup design \n"
    return
}
set RTLSimFILE ""
set FRONT_PATH ""
set SUBSTITUTE_PATH ""
set RTLSimFileType ""
set FRAME_SIZE ""
set TRUE_TIME ""
set RPM_MODE ""
set START_TIME ""
set END_TIME ""
set SELECT_RANGE ""
set VCD_DRIVEN ""
set MAPPING_RULE_FILE ""
set block_vcd [gsr get BLOCK_VCD_FILE]
set lines [split $block_vcd "\n"]
set block_vcd 1
if { [regexp "^\# BLOCK_VCD_FILE" [lindex $lines 0] ] } {
 set vcd [gsr get VCD_FILE]
 set lines [split $vcd "\n"]
 set block_vcd 0
}
set test ""
set var ""
set line_cnt 0
set cnt 0
set design_name [get design]

foreach line $lines {

regsub -all {^\s*} $line "" line1
regsub -all "^\}" $line "" line
set word [split $line1]
set word1 [lindex $word 0]
set word2 [lindex $word 1]

if { $line eq "" || [regexp "^\#" $line] || [regexp "^BLOCK_VCD_FILE" $line] || [regexp "MAPPING " $line]} {
  continue
} elseif { $word1 eq "FRONT_PATH" } {
 set FRONT_PATH $word2
} elseif { $word1 eq "SUBSTITUTE_PATH" } {
 set SUBSTITUTE_PATH $word2
 regsub -all {\"} $SUBSTITUTE_PATH {} SUBSTITUTE_PATH
} elseif { $word1 eq "FILE_TYPE" } {
 set RTLSimFileType $word2
} elseif { $word1 eq "FRAME_SIZE" } {
 set FRAME_SIZE $word2
} elseif { $word1 eq "TRUE_TIME" } {
 set TRUE_TIME $word2
} elseif { $word1 eq "RPM_MODE" } {
 set RPM_MODE $word2
} elseif { $word1 eq "START_TIME" } {
 set START_TIME $word2
} elseif { $word1 eq "END_TIME" } {
 set END_TIME $word2
} elseif { $word1 eq "SELECT_RANGE" } {
 set SELECT_RANGE $word2
} elseif { $word1 eq "VCD_DRIVEN" } {
 set VCD_DRIVEN $word2
} elseif { $word1 eq "MAPPING_RULE_FILE" } {
 set MAPPING_RULE_FILE $word2
} elseif { [file exists $word2] } {
 if {![regexp "VCD_FILE \{" $line] && ![regexp "\}" $line]} {
    
        set RTLSimFile $word2
        set BLOCK_NAME $word1
    }
}

if { [regexp "VCD_FILE " $line] } {
 if { $block_vcd eq 1 } {
set test1 "\{" 
set var [lappend test $test1]
if { $cnt > 0 } {

if {![info exist RTLSimFileType]} {
    message log "VCD_FILE keyword not set correctly. Sim file type missing\n"
    return
} elseif {$RTLSimFileType eq "" } {
    message log "VCD_FILE keyword not set correctly. Sim file type null\n"
    return
} elseif {![info exist RTLSimFile]} {
    message log "VCD_FILE keyword not set correctly. Sim file missing\n"
    return
} elseif {$RTLSimFile eq "" } {
    message log "VCD_FILE keyword not set correctly. Sim file null\n"
    return
}
if {$RTLSimFileType eq "FSDB"} {
    message log "MAPPING WARNING : Mapping is only needed for RTL_VCD or RTL_FSDB flow\n"
#    return
} elseif {$RTLSimFileType eq "VCD"} {
    message log "MAPPING WARNING : Mapping is only needed for RTL_VCD or RTL_FSDB flow\n"
#    return
} elseif {$RTLSimFileType eq "EVENT_RPM" || $RTLSimFileType eq "TOGGLE_RPM"} {
   set file_list [split [exec ls $RTLSimFile] "\n"]
puts $file_list
   set index [lsearch -regexp $file_list .fsdb]
   if {$index ne -1} {
    set RTLSimFile [concat $RTLSimFile lindex $file_list $index]]
   } else { 
     message log "VCD_FILE keyword not set correctly. Sim file missingtest\n"
     return
   }

}
if {$SUBSTITUTE_PATH eq "" } {
    if {![regexp $BLOCK_NAME $design_name]} {
        message log "MAPPING ERROR : TOP name provided in GSR for RTL_VCD/RTL_FSDB doesn't correspond to chip top\n"
        return
    }
} else {
    if {![regexp $BLOCK_NAME $SUBSTITUTE_PATH]} {
        message log "MAPPING ERROR : BLOCK name provided in GSR for RTL_VCD/RTL_FSDB doesn't correspond to SUBSTITUTE_PATH\n"
        return
    }
}
message log "\nGenerating Mapping file for $RTLSimFile\n"
if { [catch {GenerateMapfileBlock $cnt $RTLSimFile $FRONT_PATH $SUBSTITUTE_PATH $RTLSimFileType $rule_file} fid] } {
    message log "MAPPING ERROR: Auto mapping failed, please check GSR settings, and input files\n"
}
set RTLSimFILE ""
set FRONT_PATH ""
set SUBSTITUTE_PATH ""
set RTLSimFileType ""
set FRAME_SIZE ""
set TRUE_TIME ""
set RPM_MODE ""
set START_TIME ""
set END_TIME ""
set SELECT_RANGE ""
set VCD_DRIVEN ""
set MAPPING_RULE_FILE ""
set map "    MAPPING .apache/rtl2gate.map.points.blk$cnt"

set test1 [linsert $test [expr $line_cnt - $block_vcd ] $map]
set test $test1
incr line_cnt
}
incr line_cnt
incr cnt
continue
} else {
 continue
}
}
set var [lappend test $line]
incr line_cnt
}
## cnt will be 0 if there is no BLOCK_VCD

if {$block_vcd == 0} {
    set cnt ""

if {![info exist RTLSimFileType]} {
    message log "VCD_FILE keyword not set correctly. Sim file type missing\n"
    return
} elseif {$RTLSimFileType eq "" } {
    message log "VCD_FILE keyword not set correctly. Sim file type null\n"
    return
} elseif {![info exist RTLSimFile]} {
    message log "VCD_FILE keyword not set correctly. Sim file missing\n"
    return
} elseif {$RTLSimFile eq "" } {
    message log "VCD_FILE keyword not set correctly. Sim file null\n"
    return
}
if {$RTLSimFileType eq "FSDB"} {
    message log "MAPPING WARNING : Mapping is only needed for RTL_VCD or RTL_FSDB flow\n"
#   return
} elseif {$RTLSimFileType eq "VCD"} {
    message log "MAPPING WARNING : Mapping is only needed for RTL_VCD or RTL_FSDB flow\n"
#   return
} elseif {$RTLSimFileType eq "EVENT_RPM" || $RTLSimFileType eq "TOGGLE_RPM"} {
   set file_list [split [exec ls $RTLSimFile] "\n"]
   set index [lsearch -regexp $file_list .fsdb]
   if {$index ne -1} {
    set RTLSimFile [concat $RTLSimFile[lindex $file_list $index]]
   } else { 
     message log "VCD_FILE keyword not set correctly. Sim file missingtest\n"
     return
   }

}
if {$SUBSTITUTE_PATH eq "" } {
    if {![regexp $BLOCK_NAME $design_name]} {
        message log "MAPPING ERROR : TOP name provided in GSR for RTL_VCD/RTL_FSDB doesn't correspond to chip top\n"
        return
    }
} else {
    if {![regexp $BLOCK_NAME $SUBSTITUTE_PATH]} {
        message log "MAPPING ERROR : BLOCK name provided in GSR for RTL_VCD/RTL_FSDB doesn't correspond to SUBSTITUTE_PATH\n"
        return
    }
}
message log "Generating Mapping file for $RTLSimFile\n"
if { [catch {GenerateMapfileBlock $cnt $RTLSimFile $FRONT_PATH $SUBSTITUTE_PATH $RTLSimFileType $rule_file} fid] } {
    message log "MAPPING ERROR: Auto mapping failed, please check GSR settings, and input files\n"
}
set map "    MAPPING .apache/rtl2gate.map.points"
} else {
if {![info exist RTLSimFileType]} {
    message log "VCD_FILE keyword not set correctly. Sim file type missing\n"
    return
} elseif {$RTLSimFileType eq "" } {
    message log "VCD_FILE keyword not set correctly. Sim file type null\n"
    return
} elseif {![info exist RTLSimFile]} {
    message log "VCD_FILE keyword not set correctly. Sim file missing\n"
    return
} elseif {$RTLSimFile eq "" } {
    message log "VCD_FILE keyword not set correctly. Sim file null\n"
    return
}
if {$RTLSimFileType eq "FSDB"} {
    message log "MAPPING WARNING : Mapping is only needed for RTL_VCD or RTL_FSDB flow\n"
#    return
} elseif {$RTLSimFileType eq "VCD"} {
    message log "MAPPING WARNING : Mapping is only needed for RTL_VCD or RTL_FSDB flow\n"
#    return
}

message log "Generating Mapping file for $RTLSimFile\n"
if { [catch {GenerateMapfileBlock $cnt $RTLSimFile $FRONT_PATH $SUBSTITUTE_PATH $RTLSimFileType $rule_file} fid] } {
    message log "MAPPING ERROR: Auto mapping failed, please check GSR settings, and input files\n"
}
set map "    MAPPING .apache/rtl2gate.map.points.blk$cnt"
}
set test1 [linsert $test  [expr $line_cnt - $block_vcd] $map]
set var $test1
regsub -all {\\} $var "" var1

if { $block_vcd eq 1 } {
 gsr set BLOCK_VCD_FILE $var1
} else {
 gsr set VCD_FILE $var1
}


message log "GenerateMapfile proc finished on [exec date]\n"
config cmdlog yes
}
