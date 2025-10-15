source scripts/00_common_design_settings.tcl

file mkdir $nlib_dir
file delete -force ${nlib_dir}/${design}_01_import_netlist.nlib
create_lib -technology $tech_tf -ref_libs $ndm_files ${nlib_dir}/${design}_01_import_netlist.nlib
get_libs
read_verilog -library ${design}_01_import_netlist.nlib -design $design -top $design $import_netlist


source scripts/initialization_settings.tcl

### load upf
# set_app_options -name mv.upf.enable_golden_upf -value true
# reset_upf
# load_load $golden_upf
# commit_upf

### connect_pg
connect_pg_net  -all_blocks -automatic

### save
save_block
save_lib -all