### load setting
source scripts/00_common_design_settings.tcl

### open database
file delete -force ${nlib_dir}/${design}_07_route.nlib
copy_lib -from_lib ${nlib_dir}/${design}_06_cts_opt.nlib -to_lib ${nlib_dir}/${design}_07_route.nlib
current_lib ${design}_07_route.nlib
open_block ${design}

### initialize setting
source scripts/initialization_settings.tcl
### scenario ;  不用像CTS_OPT用那么多   
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
set_clock_routing_rules -min_routing_layer M3 -max_routing_layer M6 -clocks $all_master_clocks -rules ndr_2w2s

### post cts app options
set_app_options -name clock_opt.flow.enable_ccd -value false
set_app_options -name clock_opt.place.effort -value high
set_app_options -name clock_opt.place.congestion_effort -value high
set_app_options -name opt.common.user_instance_name_prefix -value "CLKOPT_"
set_app_options -name cts.common.user_instance_name_prefix -value "CCDOPT_"

### post route app options
# 细线就是global 不是真正的金属
set_app_options -name route.global.crosstalk_driven -value true
set_app_options -name route.global.timing_driven -value true
set_app_options -name route.global.effort_level -value high
set_app_options -name route.global.timing_driven_effort_level -value high
# 除极少数情况 route都会走在 track上
set_app_options -name route.track.crosstalk_driven -value true
set_app_options -name route.track.timing_driven -value true

set_app_options -name route.detail.antenna -value true
set_app_options -name route.detail.antenna_fixing_preference -value use_diodes
set_app_options -name route.detail.diode_libcell_names -value */*DIO*TL* ; # 一些库叫*ANT*
set_app_options -name route.detail.timing_driven -value true
# set_app_options -name route.detail.save_after_iterations -value 2  ;# 到设置的轮数save一个数据出来 再继续跑

set_app_options -name time.si_enable_analysis -value true
set_app_options -name time.enable_ccs_rcv_cap -value true
### run route
route_auto
# route_auto -max_detail_route_iterations  40 -save_after_global_route true -reuse_existing_global_route true 
# route_global
# route_track
# route_detail




### connect pg 
connect_pg_net -all_blocks -automatic

### save & quit
save_block
save_lib -all

### reports
set report_dir "./rpts/route"
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

check_routes > $report_dir/check_routes.rpt
check_lvs > $report_dir/check_lvs.rpt ;#net


