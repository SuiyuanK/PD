### load setting
source scripts/00_common_design_settings.tcl

### open database
file delete -force ${nlib_dir}/${design}_03_power_routing.nlib
copy_lib -from_lib ${nlib_dir}/${design}_02_floorplan.nlib -to_lib ${nlib_dir}/${design}_03_power_routing.nlib
current_lib ${design}_03_power_routing.nlib
open_block ${design}

### initialize setting
source scripts/initialization_settings.tcl

### scenario setup
source scripts/scenario_setup.tcl

### remove before create
remove_pg_patterns              -all
remove_pg_strategies            -all
remove_pg_strategy_via_rules    -all
remove_pg_via_master_rules      -all
remove_pg_regions               -all

### connect pg before power routing
connect_pg_net -automatic

### pg region for sram
set region_cnt 0
set macro_col [get_cells -physical_context -filter "is_hard_macro==true" -quiet]
# Obtain the macro cells inside the RISC core
# set memory_risc [get_cells -physical_context -filter "is_hard_macro==true" I_RISC_CORE/*]
# Remove the macro cells within the RISC core from all macro cells
# set memory_top [remove_from_collection $macro_col $memory_risc]
set memory_top $macro_col
# Traverse all macro cells and create PG areas
foreach_in_collection _macro $macro_col {
    set macro_bbox [get_attribute ${_macro} bbox]
    puts "Macro: [get_attribute ${_macro} full_name] | Bounding Box: $macro_bbox"
    create_pg_region -polygon $macro_bbox MEMORY_REGION_${region_cnt}
    incr region_cnt
}

### basic pattern
set macro_pgregions0 [get_pg_regions *]

create_pg_region -polygon {{678.3770 1258.2590} {824.9570 1475.2190}} User_MEMORY_REGION_0
create_pg_region -polygon {{492.7970 1258.2590} {639.3770 1475.2190}} User_MEMORY_REGION_1
create_pg_region -polygon {{307.2170 1258.2590} {453.7970 1475.2190}} User_MEMORY_REGION_2
create_pg_region -polygon {{1049.5370 1258.2590} {1196.1170 1475.2190}} User_MEMORY_REGION_3
create_pg_region -polygon {{307.2170 21.7120} {453.7970 238.6720}} User_MEMORY_REGION_4
create_pg_region -polygon {{492.7970 21.7120} {639.3770 238.6720}} User_MEMORY_REGION_5
create_pg_region -polygon {{678.3770 21.7120} {824.9570 238.6720}} User_MEMORY_REGION_6
create_pg_region -polygon {{863.9570 21.7120} {1010.5370 238.6720}} User_MEMORY_REGION_7
create_pg_region -polygon {{1049.5370 21.7120} {1196.1170 238.6720}} User_MEMORY_REGION_8
create_pg_region -polygon {{863.9570 1258.2590} {1010.5370 1475.2190}} User_MEMORY_REGION_9
set macro_pgregions [get_pg_regions *]

remove_routes -net_types {power ground} -ring -stripe -macro_pin_connect -lib_cell_pin_connect

# rail pattern for std cells
# layers跟pin同一层 width 也一样
create_pg_std_cell_conn_pattern pattern_pg_rail -layers M2 -rail_width {@w} -parameters {w}
set_pg_strategy strategy_pg_rail \
    -voltage_areas DEFAULT_VA \
    -pattern "{name : pattern_pg_rail} {nets : VDD VSS} {parameters : 0.2}" \
    -blockage {{pg_regions : $macro_pgregions0} {placement_blockages : all}}

# stripe
create_pg_wire_pattern pattern_wire_based_on_track -direction @d -layer @l -width @w -spacing @s -pitch @p -parameters {d l w s p} -track_alignment track
# pitch 0.84 0.14 线宽 = 2 * 节距 - 4 * 最小间距
create_pg_composite_pattern pattern_core_TM2_mesh -net {VDD VSS} \
    -add_patterns {{{pattern: pattern_wire_based_on_track}{nets : {VDD VSS}} {parameters : {horizontal TM2 7.2 interleaving 40 }}{offset : 1.68 1.68}}}
create_pg_composite_pattern pattern_core_TM1_mesh -net {VDD VSS} \
    -add_patterns {{{pattern: pattern_wire_based_on_track}{nets : {VDD VSS}} {parameters : {vertical TM1 7.2 interleaving 40 }}{offset : 1.68 1.68}}}
create_pg_composite_pattern pattern_core_M6_mesh -net {VDD VSS} \
    -add_patterns {{{pattern: pattern_wire_based_on_track}{nets : {VDD VSS}} {parameters : {horizontal M6 1.6 interleaving 40 }}{offset : 0.95 0.95}}}

set_pg_strategy strategy_M6_pg_mesh -pattern "{name : pattern_core_M6_mesh} {nets : VDD VSS}" -voltage_areas DEFAULT_VA -blockage {{pg_regions : $macro_pgregions} {placement_blockages : all}}
# macro also need
create_pg_region -polygon {{683.0770 1260.2590} {820.2570 1473.2190}} user_pg_region_0
create_pg_region -polygon {{497.4970 1260.2590} {634.6770 1473.2190}} user_pg_region_1
create_pg_region -polygon {{311.9170 1260.2590} {449.0970 1473.2190}} user_pg_region_2
create_pg_region -polygon {{1054.2370 1260.2590} {1191.4170 1473.2190}} user_pg_region_3
create_pg_region -polygon {{311.9170 23.7120} {449.0970 236.6720}} user_pg_region_4
create_pg_region -polygon {{497.4970 23.7120} {634.6770 236.6720}} user_pg_region_5
create_pg_region -polygon {{683.0770 23.7120} {820.2570 236.6720}} user_pg_region_6
create_pg_region -polygon {{868.6570 23.7120} {1005.8370 236.6720}} user_pg_region_7
create_pg_region -polygon {{1054.2370 23.7120} {1191.4170 236.6720}} user_pg_region_8
create_pg_region -polygon {{868.6570 1260.2590} {1005.8370 1473.2190}} user_pg_region_9
set user_pgregions [get_pg_regions user_pg_region_*]
set_pg_strategy strategy_TM1_pg_mesh -pattern "{name : pattern_core_TM1_mesh} {nets : VDD VSS}" -voltage_areas DEFAULT_VA -blockage {{pg_regions : $user_pgregions}}
set_pg_strategy strategy_TM2_pg_mesh -pattern "{name : pattern_core_TM2_mesh} {nets : VDD VSS}" -voltage_areas DEFAULT_VA -blockage {{pg_regions : $macro_pgregions} {placement_blockages : all}}

### via rules
set_pg_strategy_via_rule via_pg_core -via_rule { \
    {{{strategies: strategy_TM2_pg_mesh} {layers: TM2}} {{strategies: strategy_TM1_pg_mesh} {layers: TM1}} {via_master: default}} \
    {{{strategies: strategy_TM1_pg_mesh} {layers: TM1}} {{strategies: strategy_M6_pg_mesh} {layers: M6}} {via_master: default}} \
    {{{existing: std_conn}}                             {{strategies: strategy_M6_pg_mesh} {layers: M6}} {via_master: default}} \
    {{intersection: adjacent} {via_master: default}}
}





### macro ring connection
#  -via_rule {{intersection: adjacent} {via_master: default}}
# width 可宽一点 
create_pg_ring_pattern pattern_memory_ring -horizontal_layer M5 -horizontal_width 1.6 -vertical_layer M6 -vertical_width 1.6 -corner_bridge true -via_rule {{intersection: all} {via_master: V5_8_XX_F0}}
set_pg_strategy strategy_memory_ring_top -macro $memory_top -pattern {{pattern: pattern_memory_ring} {nets: {VDD VSS}} {offset : {0.8 0.8}}}
set_pg_strategy_via_rule strategy_memory_ring_via -via_rule { \
    {{{strategies: strategy_memory_ring_top} {layers: M6}} {existing: strap} {via_master: default}} \
    {{{strategies: strategy_memory_ring_top} {layers: M5}} {existing: strap} {via_master: default}} \
}


### macro pin connection
# -layers Choose which layer the pin is on
create_pg_macro_conn_pattern pattern_memory_pin -pin_conn_type scattered_pin -layers {M5 M4}
set_pg_strategy strap_top_pins -macros $memory_top -pattern {{pattern: pattern_memory_pin} {nets : {VDD VSS}}}


### compile_pg
# compile_pg
compile_pg -strategies {strategy_pg_rail} -tag pattern_pg_rail  -ignore_via_drc
compile_pg -strategies {strategy_TM2_pg_mesh strategy_TM1_pg_mesh strategy_M6_pg_mesh} -tag pg_stripes  -via_rule {via_pg_core}
compile_pg -strategies {strategy_memory_ring_top} -tag pg_ring -via_rule {strategy_memory_ring_via} 
compile_pg -strategies {strap_top_pins} -tag macro_pins 



### connect pg 
connect_pg_net -all_blocks -automatic

### save & quit
save_block
save_lib -all


set report_dir "./rpts/power_routing"
file delete -force $report_dir
file mkdir $report_dir

check_pg_missing_vias > $report_dir/check_pg_missing_vias.rpt
check_pg_drc -ignore_std_cells > $report_dir/check_pg_drc.rpt
check_pg_connectivity -check_std_cell_pins none > $report_dir/check_pg_connectivity.rpt
check_lvs > $report_dir/check_lvs.rpt ;#net
check_legality -verbose > $report_dir/check_legality.rpt
# gui_start