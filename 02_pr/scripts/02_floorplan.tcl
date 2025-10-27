### load setting
source scripts/00_common_design_settings.tcl

### open database
file delete -force ${nlib_dir}/${design}_02_floorplan.nlib
copy_lib -from_lib ${nlib_dir}/${design}_01_import_netlist.nlib -to_lib ${nlib_dir}/${design}_02_floorplan.nlib
# try to use open_lib to open the newly copied nlib
current_lib ${design}_02_floorplan.nlib
open_block ${design}

### initialize setting
source scripts/initialization_settings.tcl

### scenario setup
source scripts/scenario_setup.tcl




### create floorplan
# 确保core和die的边界左右一致 上下差一个row
# get_attribute [get_site_defs] width    40nm 0.1900
# get_attribute [get_site_defs] height   40nm 1.6800
initialize_floorplan -boundary {{0 0} {1499.86 1495.2}} -core_offset {0 1.6800}

### place port
remove_individual_pin_constraints
#-allowed_layers {M5 M7} 
set_individual_pin_constraints -ports [all_inputs] -sides 1 -pin_spacing 45 -offset {300 1200} -allowed_layers {M3 M4 M5 M6 M7}
set_individual_pin_constraints -ports [all_outputs] -sides 1 -pin_spacing  45 -offset {300 1200} -allowed_layers {M3 M4 M5 M6 M7}
place_pins -self -ports [get_ports *]

### create voltage area
# create_voltage_area -power_domains PD_RISC_CORE -guard_band {{10.032 10}} -region {{0.0000 642.0480} {489.1360 999.8560}}


### An operation
# get_selection    ---->>>> {I_RISC_CORE/I_REG_FILE/REG_FILE_A_RAM}
# change_selection [get_flat_cells I_RISC_CORE/* -filter is_hard_macro==true]
# get_lib_cells "*/*" -filter "is_boundary_cell == true"
### place hard macros && keepout(manully)
# also can read def

# change_selection [get_flat_cells * -filter is_hard_macro==true]
# write_floorplan -objects [get_selection ] -force -nosplit
# cp floorplan/fp.tcl scripts/place_hard_macro.tcl
# 小的5 大的20
source scripts/place_hard_macro.tcl
create_keepout_margin -outer {4 4 4.75 4} [get_flat_cells * -filter is_hard_macro==true]


### blockage(gui) copy from fp.tcl
# change_selection [get_placement_blockages *]
# write_floorplan -objects [get_selection ] -force -nosplit (-nosplit No line break)

# create_placement_blockage -name pb_0 -type hard -boundary { {1379.4150 238.1200} {1499.8600 238.1920} }

# get_voltage_areas  ------>>>  {DEFAULT_VA PD_RISC_CORE}
# Each voltage_area needs to set these cells.

### boundary cell         Around the perimeter of the standard cells
# 40nm 只打左右
remove_boundary_cell_rules -all
remove_cells [get_cells -physical_context *boundarycell* -quiet]
# -top_boundary_cells $endcap_top -bottom_boundary_cells $endcap_bottom
set_boundary_cell_rules -left_boundary_cell $endcap_left -right_boundary_cell $endcap_right 
# -target_objects [get_flat_cells * -filter is_hard_macro==true]
compile_advanced_boundary_cells -voltage_area "DEFAULT_VA" 
### tap cell

create_tap_cells -lib_cell $tapcell_ref -pattern stagger -distance 30 -skip_fixed_cells -voltage_area DEFAULT_VA

set_fixed_objects [get_flat_cells * -filter is_hard_macro==true]

### connect pg
connect_pg_net -all_blocks -automatic

### save & quit
save_block
save_lib -all

