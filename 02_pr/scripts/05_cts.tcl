### load setting
source scripts/00_common_design_settings.tcl

### open database
file delete -force ${nlib_dir}/${design}_05_cts.nlib
copy_lib -from_lib ${nlib_dir}/${design}_04_place_opt.nlib -to_lib ${nlib_dir}/${design}_05_cts.nlib
current_lib ${design}_05_cts.nlib
open_block ${design}

### initialize setting
source scripts/initialization_settings.tcl

### scenario setup ; 传统CTS不怎么关心timing 只看clk的约束
source scripts/scenario_setup.tcl


### lib cell purpose (choose CTS cell)
# 用LVT的CLKBUF 不要小的 all ICG INV
set_dont_touch [get_lib_cells $cts_cells] false
set_attribute [get_lib_cells $cts_cells] dont_use false
set_lib_cell_purpose -exclude all [get_lib_cells */*]
set_lib_cell_purpose -include cts [get_lib_cells $cts_cells]


set all_master_clocks [get_clocks -filter "is_virtual==false&&is_generated==false"]
set all_real_clocks [get_clocks -filter "is_virtual==false"]

### clock tree options
# 一般不同clk分着 不看generated clk
# latency的10-20% (ps)
set_clock_tree_options -clocks [get_clocks $all_master_clocks] -target_skew 0.050
# 不管做一次 看看 latency有多少
set_clock_tree_options -clocks [get_clocks $all_master_clocks] -target_latency 0.500

### CTS NDR(Non-Default-Rules)
create_routing_rule ndr_2w2s -default_reference_rule -multiplier_width 2 -multiplier_spacing 2

set_clock_routing_rules -min_routing_layer M5 -max_routing_layer M7 -clocks $all_master_clocks -rules ndr_2w2s

### fix remained setup
# set_clock_tree_balance_point -modes [all_modes] -clock $all_real_clocks  -delay 0.43246 -balance_points [get_pin u_sram_array_u_sram_0/CLK]
# set_clock_tree_balance_point -modes [all_modes] -clock $all_real_clocks  -delay 0.43246 -balance_points [get_pin u_sram_array_u_sram_1/CLK]

source scripts/clock_auto_exceptions.tcl

### app options
# cts clock_opt  ccd false
set_app_options -name cts.optimize.enable_local_skew   -value true
set_app_options -name cts.compile.enable_local_skew    -value true
set_app_options -name cts.compile.enable_global_route  -value true
set_app_options -name clock_opt.flow.enable_ccd        -value false
set_app_options -name cts.common.user_instance_name_prefix  -value "CTS_"


### CTS DRV
# 7% (pf) 频率差距过大需要单独set
set_max_transition -corner [current_corner] -clock_path 0.460 $all_real_clocks


### run CTS command
clock_opt -from build_clock -to route_clock
# or
# synthesize_clock_trees
# synthesize_clock_trees -routed_clock_stage detail

### connect pg 
connect_pg_net -all_blocks -automatic

### save & quit
save_block
save_lib -all

### reports

set report_dir "./rpts/cts"
file delete -force $report_dir
file mkdir $report_dir

report_clock_qor -type summary > $report_dir/report_clock_qor.summary.rpt
foreach_in_collection clk $all_real_clocks {
    set clk_name [get_object_name ${clk}]
    report_clock_qor -clock $clk_name -type latency > $report_dir/report_${clk_name}_qor.latency.rpt
    report_clock_qor -clock $clk_name -type local_skew -largest 1000 > $report_dir/report_${clk_name}_qor.local_skew.rpt
}

foreach_in_collection scenario [all_scenario] {
    set sce_name [get_attribute $scenario name]
    report_constraint -scenarios $sce_name -max_transition -all_violators -significant_digits 3 -verbose > $report_dir/report_constraint.max_transition.${sce_name}.rpt
    report_constraint -scenarios $sce_name -max_capacitance -all_violators -significant_digits 3 -verbose > $report_dir/report_constraint.max_capacitance.${sce_name}.rpt
}


