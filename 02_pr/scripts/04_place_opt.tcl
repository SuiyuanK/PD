### load setting
source scripts/00_common_design_settings.tcl

### open database
file delete -force ${nlib_dir}/${design}_04_place_opt.nlib
copy_lib -from_lib ${nlib_dir}/${design}_03_power_routing.nlib -to_lib ${nlib_dir}/${design}_04_place_opt.nlib
current_lib ${design}_04_place_opt.nlib
open_block ${design}

### initialize setting
source scripts/initialization_settings.tcl

### scenario setup
source scripts/scenario_setup.tcl


### opt cell selection : TIE
# set_dont_touch [get_lib_cells */*TIE*] false
# set_attribute [get_lib_cells */*TIE*] dont_use false
# set_lib_cell_purpose -include {optimization} [get_lib_cells */*TIE*]


### aap options
# report_app_options opt*prefix (place_opt*)
# The optimized added cell should be prefixed with "POPT_"
set_app_options -name opt.common.user_instance_name_prefix -value "POPT_"
set_app_options -name place_opt.final_place.effort -value "high"
# There is not much difference for less advanced processes
set_app_options -name place_opt.flow.clock_aware_placement -value "true"
set_app_options -name place_opt.flow.optimize_icgs -value "false"
set_app_options -name place_opt.flow.enable_ccd -value "false"
set_app_options -name place_opt.flow.merge_clock_gates -value "true"
set_app_options -name place_opt.place.congestion_effort -value "high"

# no scandef ---->>> true
set_app_options -name place.coarse.continue_on_missing_scandef -value "true"
# manually control density 
set_app_options -name place.coarse.congestion_driven_max_util -value 0.70
set_app_options -name place.coarse.max_density -value 0.50
# under 16nm need true
set_app_options -name place.legalize.enable_advanced_legalizer -value "true"
set_app_options -name place.legalize.enable_advanced_legalizer_cellmap -value "true"

set_app_options -name opt.area.effort -value "high"
set_app_options -name opt.common.enable_rde -value "high"
# set_app_options -name opt.common.max_net_length -value "1000"
set_app_options -name opt.timing.effort -value "high"
# set_app_options -name opt.tie_cell.max_fanout -value 16

# ### scandef
# remove_scan_def
# read_def $scandef_file

# ### group paths
# group_path -name reg2reg
# group_path -name reg2gating


### run placeopt
place_opt -from initial_place -to final_opto  ;# standard 
# create_placement -effort high -timing_driven -buffering_aware_timing_driven -congestion -congestion_effort high
# place_opt -from initial_place -to final_opto
# create_placement -effort high -congestion -congestion_effort high -incremental
# place_opt -from initial_drc -to final_opto

# initial_place
# initial_drc
# initial_opto
# final_place
# final_opto

### connect pg 
connect_pg_net -net VDD [get_pins */VNW -hierarchical]
connect_pg_net -net VSS [get_pins */VPW -hierarchical]
connect_pg_net -net VDD [get_pins */VDDCE -hierarchical] 
connect_pg_net -net VDD [get_pins */VDDPE -hierarchical] 
connect_pg_net -net VSS [get_pins */VSSE -hierarchical] 
connect_pg_net -all_blocks -automatic

### save
save_block
save_lib -all

### check & reports
set report_dir "./rpts/place_opt"
file delete -force $report_dir
file mkdir $report_dir
check_legality -verbose > $report_dir/check_legality.rpt
check_mv_design > $report_dir/check_mv_design.rpt
report_qor -summary > $report_dir/report_qor.rpt
report_timing -nosplit -transition_time -capacitance -input_pins -nets -derate \
              -delay_type max -path_type full_clock_expanded -voltage -significant_digits 4 \
              -nworst 1 -physical -max_paths 100 \
              > $report_dir/report_timing.full.rpt
report_timing -nosplit -transition_time -capacitance -input_pins -nets -derate \
              -delay_type max -voltage -significant_digits 4 \
              -nworst 1 -physical -max_paths 100 \
              > $report_dir/report_timing.data.rpt
report_utilization > $report_dir/report_utilization.rpt
report_congestion > $report_dir/report_congestion.rpt ;#gui Global Route Congestion > blue is good    cell desnsity   hierarchy


