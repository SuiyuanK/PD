### load setting
source scripts/00_common_design_settings.tcl

### open database
file delete -force ${nlib_dir}/${design}_06_cts_opt.nlib
copy_lib -from_lib ${nlib_dir}/${design}_05_cts.nlib -to_lib ${nlib_dir}/${design}_06_cts_opt.nlib
current_lib ${design}_06_cts_opt.nlib
open_block ${design}

### initialize setting
source scripts/initialization_settings.tcl

### scenario ;  setup不能太多 hold 可以多一点 前者ss 后者ff (不是先进工艺)
source scripts/scenario_setup.tcl
# 告诉工具CTS已经做好了
foreach scenario [get_attribute [all_scenarios] name] {
    echo "YFT-Information: Setting propagated clock on scenario $scenario"
    current_scenario $scenario
    set_propagated_clock [get_clocks -filter "is_virtual==false"]
}


### lib cell selection (tie, cts cell, hold fix)
set_dont_touch [get_lib_cells $cts_cells] false
set_attribute [get_lib_cells $cts_cells] dont_use false
set_lib_cell_purpose -exclude all [get_lib_cells */*]
set_lib_cell_purpose -include cts [get_lib_cells $cts_cells]
# set_dont_touch [get_lib_cells */*TIE*] false
# set_attribute [get_lib_cells */*TIE*] dont_use false
# set_lib_cell_purpose -include {optimization} [get_lib_cells */*TIE*]
set_dont_touch [get_lib_cells $hold_fix_ref] false
set_attribute [get_lib_cells $hold_fix_ref] dont_use false
set_lib_cell_purpose -exclude hold [get_lib_cells */*] 
set_lib_cell_purpose -include hold [get_lib_cells $hold_fix_ref]

set all_master_clocks [get_clocks -filter "is_virtual==false&&is_generated==false"]
set all_real_clocks [get_clocks -filter "is_virtual==false"]

### CTS NDR(Non-Default-Rules)
if { [get_routing_rule ndr_2w2s -quiet] == "" } {
    create_routing_rule ndr_2w2s -default_reference_rule -multiplier_width 2 -multiplier_spacing 2
}
set_clock_routing_rules -min_routing_layer M5 -max_routing_layer M7 -clocks $all_master_clocks -rules ndr_2w2s

### post cts app options
set_app_options -name clock_opt.flow.enable_ccd -value false
set_app_options -name clock_opt.place.effort -value high
set_app_options -name clock_opt.place.congestion_effort -value high
set_app_options -name opt.common.user_instance_name_prefix -value "CLKOPT_"
set_app_options -name cts.common.user_instance_name_prefix -value "CCDOPT_"
### run clock opt
clock_opt -from final_opto -to final_opto

### connect pg 
connect_pg_net -all_blocks -automatic

### save & quit
save_block
save_lib -all


### reports
set report_dir "./rpts/cts_opt"
file delete -force $report_dir
file mkdir $report_dir
check_legality -verbose > $report_dir/check_legality.rpt
check_mv_design > $report_dir/check_mv_design.rpt
report_qor -summary -significant_digits 4 > $report_dir/report_qor.rpt
report_timing -nosplit -transition_time -capacitance -input_pins -nets -derate \
              -delay_type max -path_type full_clock_expanded -voltage -significant_digits 4 \
              -nworst 1 -physical -max_paths 100 \
              > $report_dir/report_timing.full.rpt
report_timing -nosplit -transition_time -capacitance -input_pins -nets -derate \
              -delay_type max -voltage -significant_digits 4 \
              -nworst 1 -physical -max_paths 100 \
              > $report_dir/report_timing.data.rpt
foreach_in_collection scenario [all_scenario] {
    set sce_name [get_attribute $scenario name]
    report_constraint -scenarios $sce_name -max_transition -all_violators -significant_digits 3 -verbose > $report_dir/report_constraint.max_transition.${sce_name}.rpt
    report_constraint -scenarios $sce_name -max_capacitance -all_violators -significant_digits 3 -verbose > $report_dir/report_constraint.max_capacitance.${sce_name}.rpt
}


### how to fix remained setup
#  a) bound startpoint and endpoint together
#  b) launch clock -150 
#  c) capture clock +150
#  set_clock_balance_points -modes [all_modes] -clock $all_real_clocks -delay 150 -balance_points dddddddddddddddddddddddddddddddd
#  d) enable ccd
#  重新CTS

