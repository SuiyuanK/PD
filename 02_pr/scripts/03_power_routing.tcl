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

set macro_pgregions [get_pg_regions *]

remove_routes -net_types {power ground} -ring -stripe -macro_pin_connect -lib_cell_pin_connect

# rail pattern for std cells
# layers跟pin同一层 width 也一样
create_pg_std_cell_conn_pattern pattern_pg_rail -layers M2 -rail_width {@w} -parameters {w}
set_pg_strategy strategy_pg_rail \
    -voltage_areas DEFAULT_VA \
    -pattern "{name : pattern_pg_rail} {nets : VDD VSS} {parameters : 0.2}" \
    -blockage {{pg_regions : $macro_pgregions} {placement_blockages : all}}

# stripe
create_pg_wire_pattern pattern_wire_based_on_track -direction @d -layer @l -width @w -spacing @s -pitch @p -parameters {d l w s p} -track_alignment track
# pitch 0.84 0.14 线宽 = 2 * 节距 - 4 * 最小间距
create_pg_composite_pattern pattern_core_TM2_mesh -net {VDD VSS} \
    -add_patterns {{{pattern: pattern_wire_based_on_track}{nets : {VDD VSS}} {parameters : {vertical TM2 7.2 interleaving 40 }}{offset : 1.68 1.68}}}
create_pg_composite_pattern pattern_core_TM1_mesh -net {VDD VSS} \
    -add_patterns {{{pattern: pattern_wire_based_on_track}{nets : {VDD VSS}} {parameters : {horizontal TM1 7.2 interleaving 40 }}{offset : 1.68 1.68}}}
create_pg_composite_pattern pattern_core_M7_mesh -net {VDD VSS} \
    -add_patterns {{{pattern: pattern_wire_based_on_track}{nets : {VDD VSS}} {parameters : {vertical M7 1.4 interleaving 21}}{offset : 1.68 1.68}}}


set_pg_strategy strategy_M7_pg_mesh -pattern "{name : pattern_core_M7_mesh} {nets : VDD VSS}" -voltage_areas DEFAULT_VA -blockage {{pg_regions : $macro_pgregions} {placement_blockages : all}}
# macro also need 手动连
set_pg_strategy strategy_TM1_pg_mesh -pattern "{name : pattern_core_TM1_mesh} {nets : VDD VSS}" -voltage_areas DEFAULT_VA -blockage {{pg_regions : $macro_pgregions} {placement_blockages : all}}
set_pg_strategy strategy_TM2_pg_mesh -pattern "{name : pattern_core_TM2_mesh} {nets : VDD VSS}" -voltage_areas DEFAULT_VA 


### via rules
# set_pg_strategy_via_rule via_pg_core -via_rule { \
#     {{{strategies: strategy_TM2_pg_mesh} {layers: TM2}} {{strategies: strategy_TM1_pg_mesh} {layers: TM1}} {via_master: default}} \
#     {{{strategies: strategy_TM1_pg_mesh} {layers: TM2}} {{strategies: strategy_M7_pg_mesh} {layers: M7}} {via_master: default}} \
#     {{{strategies: strategy_M7_pg_mesh} {layers: M7}}  {{existing: std_conn}}} \
#     {{{strategies: strategy_memory_ring_top} {layers: M6}} {{strategies: strategy_TM1_pg_mesh} {layers: TM1}} {via_master: default}} \
#     {{intersection: undefined} {via_master: NIL}}
# }



### macro ring connection
#  -via_rule {{intersection: adjacent} {via_master: default}}
# width 可宽一点 
create_pg_ring_pattern pattern_memory_ring -horizontal_layer M6 -horizontal_width 1.2 -vertical_layer M5 -vertical_width 1.2 -corner_bridge true -via_rule {{intersection: all} {via_master: V5_8_XX_F0}}
set_pg_strategy strategy_memory_ring_top -macro $memory_top -pattern {{pattern: pattern_memory_ring} {nets: {VDD VSS}} {offset : {0.8 0.8}}}
# set_pg_strategy_via_rule strategy_memory_ring_via -via_rule { \
#     {{{strategies: strategy_memory_ring_top} {layers: M6}} {{strategies: strategy_TM1_pg_mesh} {layers: TM1}} {via_master: default}} \
#     {{{strategies: strategy_memory_ring_top} {layers: M5}} {existing: strap} {via_master: default}} \
#     {{intersection: undefined} {via_master: NIL}}
# }


### macro pin connection
# -layers Choose which layer the pin is on {hor_layer ver_layer}
create_pg_macro_conn_pattern pattern_memory_pin -pin_conn_type scattered_pin -layers {M4 M5}
set_pg_strategy strap_top_pins -macros $memory_top -pattern {{pattern: pattern_memory_pin} {nets : {VDD VSS}}}


### compile_pg
# compile_pg
compile_pg -strategies {strategy_pg_rail} -tag pattern_pg_rail 
compile_pg -strategies {strategy_memory_ring_top} -tag pg_ring  
compile_pg -strategies {strap_top_pins} -tag macro_pins 
set_app_options -name plan.pgroute.disable_via_creation -value true
compile_pg -strategies {strategy_TM2_pg_mesh strategy_TM1_pg_mesh strategy_M7_pg_mesh} -tag pg_stripes 

#  -ignore_via_drc
### pg via
set die_box [get_attribute [current_block] boundary_bbox ]
create_pg_vias -nets {VDD VSS} -from_types stripe -to_types lib_cell_pin_connect -from_layers M7 -to_layers M2 -mark_as strap -allow_parallel_objects
create_pg_vias -nets {VDD VSS} -from_types stripe -to_types stripe -from_layers M7 -to_layers TM1 -mark_as strap -allow_parallel_objects
create_pg_vias -nets {VDD VSS} -from_types stripe -to_types stripe -from_layers TM1 -to_layers TM2 -mark_as strap -allow_parallel_objects
create_pg_vias -nets {VDD VSS} -from_types ring -to_types stripe -from_layers M6 -to_layers TM2 -mark_as strap -allow_parallel_objects



# block 不打pad 所以在top VDD VSS 上加 terminal
# 为 TM2 层上所有 VDD 网络的金属线创建终端
create_terminal \
    -of_objects [get_shapes -of_objects [get_layers TM2] -filter {net_type  == "power"}] \
    -direction {bottom top}

# 为 TM2 层上所有 VSS 网络的金属线创建终端
create_terminal \
    -of_objects [get_shapes -of_objects [get_layers TM2] -filter {net_type  == "ground"}] \
    -direction {bottom top}
analyze_power_plan -voltage 1.1 -nets {VDD VSS} -power_budget 5 -use_terminals_as_pads 


set_fixed_objects [get_ports *]

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
gui_start