############################################################################
# RTL to GATE name mapping file
# Raj S Kashyap <raj.kashyap@ansys.com>
############################################################################
proc GenerateMapfileBlock {args} {
global env

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
set MAP_FILE       "adsRpt/rtl2gate.map.points"
set RTL_INSTS_MAP  ".apache/insts_map_rtl.map"
set GATE_INSTS_MAP ".apache/insts_map_gate.map"
set GATE_PORTS_MAP ".apache/insts_map_ports.map"

if {$BLOCK_NUMBER ne ""} {
    append RTL_REGS   "." $BLOCK_NUMBER
    append RTL_INSTS  "." $BLOCK_NUMBER
    append GATE_REGS  "." $BLOCK_NUMBER
    append GATE_INSTS "." $BLOCK_NUMBER
    append GATE_REGS_PINS  "." $BLOCK_NUMBER
    append MAP_FILE        "." $BLOCK_NUMBER
    append RTL_INSTS_MAP   "." $BLOCK_NUMBER
    append GATE_INSTS_MAP  "." $BLOCK_NUMBER
    append GATE_PORTS_MAP  "." $BLOCK_NUMBER
}


if {$RTLSimFileType eq "RTL_FSDB"} {
    set fsdbdebug "$env(APACHEROOT)/bin/fsdbdebug"
}

# Run RTL Sim parser:
if {$RTLSimFileType eq "RTL_FSDB"} {
    set fsdbdebug_file "$MapRunDir/fsdbdebug.log"
    exec $fsdbdebug -tree $RTLSimFile >& $fsdbdebug_file
    puts "Parsing the FSDB....\n"
    exec perl "$env(APACHEROOT)/scripts/parse_fsdb.pl" -fsdb_file $fsdbdebug_file -topinst $FRONT_PATH -run_dir $MapRunDir -out_reg $RTL_REGS -out_inst $RTL_INSTS -rule_file $RuleFile
    puts "FSDB parsing done.\n"
} else {
    puts "Parsing the VCD....\n"
    exec "$env(APACHEROOT)/scripts/parse_vcd" -vcd_file $RTLSimFile -topinst $FRONT_PATH -run_dir $MapRunDir -out_reg $RTL_REGS -out_inst $RTL_INSTS -rule_file $RuleFile
    puts "VCD parsing done.\n"
}
# Generate gate data
set gate_regs_file  [open $GATE_REGS  w]
set gate_insts_file [open $GATE_INSTS w]
set gate_regs_pins  [open $GATE_REGS_PINS  w]

if { ![catch {set flops [get inst *$SUBSTITUTE_PATH* -glob -type flop]} fid] } {
set flops_sorted [lsort -dictionary $flops]
 foreach flop $flops_sorted {
    if { ![catch {set master [report inst $flop -master]} fid] } {
    }
    if { [catch {set pins [report cell $master -pins -direction output]} fid] } {
        set out "no_out_pins"
    } else {
        set out "$pins"
    }
    regsub -all "\n" $out " " out
    puts $gate_regs_pins $out
    if {$SUBSTITUTE_PATH ne ""} {
        regsub -all $SUBSTITUTE_PATH $flop {} flop
    }
	puts $gate_regs_file $flop
 }
}

if { [catch {set insts_id [get inst_id *$SUBSTITUTE_PATH* -glob]} fid] } {
   if { [catch {set insts_id [get inst *$SUBSTITUTE_PATH* -glob]} fid] } {
    puts "Mapping Error: could not get inst id list"
  }
}

foreach inst_id $insts_id {
    if { [catch {set master [report inst $inst_id -id -master]} fid] } {
      if { ![catch {set master [report inst $inst_id -master]} fid] } {
     }
    }
    if { ![catch {set celltype [report cell $master -type]} fid] } {
    }
    if { [catch {set inst [report inst $inst_id -id -name]} fid]} {
	set inst $inst_id
    }
        
    if { [regexp "primitive  seq_generic" $celltype]}  {
        if { [catch {set pins [report cell $master -pins -direction output]} fid] } {
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
###################
# Map IO ports
# set out_map_file [open $MAP_FILE w]
#         if { ![catch {set pins [get cell [ get design ] -pins]} fid] } {
#         }

# run mapping script
exec rm -rf $MAP_FILE
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
        if { ![catch {set master [report inst $inst -master]} fid] } {
            if { ![catch {set ports [report cell $master -pins]} fid] } {
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

puts "Mapping file generated at $MAP_FILE\n"

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
        puts "USAGE:\n"
        puts "1. GenerateMapfile -sim_file <file> -file_type <type> -front_path <path> -block <block>\n\n"
        puts "2. GenerateMapfile ?(-rule_file <file>)\nEg. GenerateMapfile -rule_file rule.file\n\n"
        puts "3. GenerateMapfile ?(-change_rtl_name <rtl> <gate>) ?(-skip_rtl_element <RTL element to ignore>) ?(-skip_gate_element <GATE element to ignore>) ?(-define_bus_rule <rtl bus> <gate transform>) -rtl_inst_level \[0|1\]\nEg. GenerateMapfile -change_rtl_name \"block_RTL block_GATE\" -skip_rtl_element \"dummy_RTL\" -skip_gate_element \"DFT\" -define_bus_rule {\[\%d\] _reg_\%d} -rtl_inst_level \[0|1\]\n"
        puts "4. GenerateMapfile ?(-change_rtl_name <rtl> <gate>) ?(-skip_rtl_element <RTL element to ignore>) ?(-skip_gate_element <GATE element to ignore>) ?(-define_bus_rule <rtl bus> <gate transform>) ?(-rule_file <file)\nEg. GenerateMapfile -skip_gate_element \"scan\" -rule_file <file> -rtl_inst_level \[0|1\]\n\n"
        puts "The rule file is an optional input and can accept following syntax: 
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

    array set opt [concat { -rule_file "" -change_rtl_name "" -change_gate_name "" -skip_rtl_element "" -skip_gate_element "" -define_bus_rule "" -rtl_inst_level "" -include_rtl_wire "" -sim_file "" -file_type "" -front_path "" -block "" -case_sensitive ""} $args]
    set rule_file $opt(-rule_file)
    set change_rtl_name $opt(-change_rtl_name)
    set include_rtl_wire $opt(-include_rtl_wire)
    set case_sensitive $opt(-case_sensitive)
    set change_gate_name $opt(-change_gate_name)
    set skip_rtl_element $opt(-skip_rtl_element)
    set skip_gate_element $opt(-skip_gate_element)
    set define_bus_rule $opt(-define_bus_rule)
    set rtl_inst_level $opt(-rtl_inst_level)
    set sim_file $opt(-sim_file)
    set file_type $opt(-file_type)
    set front_path $opt(-front_path)
    set block $opt(-block)
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
        
global env

puts "GenerateMapfile proc started on [exec date]\n"

puts "Generating Mapping file for $sim_file \n"
if { [catch {GenerateMapfileBlock $block $sim_file $front_path $block $file_type $rule_file} fid] } {
    puts "MAPPING ERROR: Auto mapping failed\n"
}
# if { $block eq "" } {
# set map "    MAPPING .apache/rtl2gate.map.points"
# } else {
# set map "    MAPPING .apache/rtl2gate.map.points.$block"
# }

puts "GenerateMapfile proc finished on [exec date]\n"
}

