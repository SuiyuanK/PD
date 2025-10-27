### load setting
source scripts/00_common_design_settings.tcl

### open database
file delete -force ${nlib_dir}/${design}_09_chipfinish.nlib
copy_lib -from_lib ${nlib_dir}/${design}_08_route_opt.nlib -to_lib ${nlib_dir}/${design}_09_chipfinish.nlib
current_lib ${design}_09_chipfinish.nlib
open_block ${design}

### initialize setting
source scripts/initialization_settings.tcl  

### insert decap/filler
#GDCAP/ECOCAP

# remove_stdcell_fillers_with_violation
# route_eco

#DECAP
create_stdcell_fillers -lib_cells $decap_ref -continue_on_error
remove_stdcell_fillers_with_violation
route_eco
#FILLER
create_stdcell_fillers -lib_cells $fillers_ref -continue_on_error
# remove_stdcell_fillers_with_violation


### connect pg 
connect_pg_net -all_blocks -automatic

### save & quit
save_block
save_lib -all


### write data
set  output_dir "outputs"
file delete -force $output_dir
file mkdir $output_dir
# gds/oasis

if { [get_routing_blockages * -quiet] != "" } {
    remove_routing_blockages *
}
set gds_file "${output_dir}/${design}.gds"
set_app_options -name file.gds.contact_prefix -value "${design}_"

write_gds -layer_map $mapping_file -long_names -design $design -hierarchy design_lib -compress -lib_cell_view frame -keep_data_type -fill include $gds_file

set oasis_file "${output_dir}/${design}.oasis"
set_app_options -name file.oasis.contact_prefix -value "${design}_"
# maybe need map -layer_map 
write_oasis -layer_map $mapping_file -design $design -hierarchy design_lib -compress 9 -lib_cell_view frame -keep_data_type -fill include $oasis_file

# netlist
set netlist_file "${output_dir}/${design}.v.gz"
write_verilog -compress gzip $netlist_file -exclude { all_physical_cells analog_pg corner_cells cover_cells diode_cells empty_modules end_cap_cells physical_only_cells filler_cells pg_objects well_tap_cells leaf_module_declarations }

# lvs netlist
set lvs_netlist_file "${output_dir}/${design}.lvs.v.gz"
write_verilog -compress gzip $lvs_netlist_file -exclude { empty_modules end_cap_cells well_tap_cells supply_statements }

# pg netlist 如果有些库文件(gds)没有 要先删掉对应的cell

# set ports [get_object_name [get_ports *]]
# foreach port $ports {
#     set x [lindex [lindex [get_attribute [get_port $port] bbox] 0] 0]
#     set y [lindex [lindex [get_attribute [get_port $port] bbox] 0] 1]
#     echo "LAYOUT TEXT ${port} ${x} ${y} 64"
# }
# LAYOUT TEXT FILE "../XX.text"加在lvs.cmd里 
set pg_netlist_file "${output_dir}/${design}.pg.v.gz"
write_verilog -compress gzip $pg_netlist_file -exclude { empty_modules flip_chip_pad_cells pad_spacer_cells leaf_module_declarations } -force_no_reference {*/PFILL* */PCORNER*} -split_bus -hierarchy all

# def
set def_file "${output_dir}/${design}.def.gz"
write_def -design $design -compress gzip -include_tech_via_definitions -include { blockages bounds cells nets ports routing_rules rows_tracks specialnets vias } $def_file 
# or -include_tech_via_definitions   -version 5.8

# lef
set lef_file "${output_dir}/${design}.lef"
# create_frame
create_frame -block_all auto -hierarchical true -merge_metal_blockage true 
# write_lef
write_lef -design ${design}.frame $lef_file -include cell 

set techlef_file "${output_dir}/${design}.tlef"
write_lef -design ${design}.frame $lef_file -include tech 


### reports
set report_dir "./rpts/chipfinish"
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
check_pg_connectivity > $report_dir/check_pg_connectivity.rpt


# read_drc_error_file -error_data cali -file ../04_pv/drc/drc.db

