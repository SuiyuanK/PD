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

# block 级的
# initialize_floorplan -boundary {{0 0} {1352.04 1340.64}} -core_offset {0 1.6800}

# TOP级的 加PAD的 -core_utilization 0.7 可以看看大致需要多大面积 也可根据DC的计算
# initialize_floorplan -core_utilization 0.7 -shape R \
#     -orientation N -side_ratio {1.0 1.0} -core_offset {100.0} \
#     -flip_first_row true -coincident_boundary true

# core估计长度+2*（电源环预留宽度(20)+PAD宽度(30)）or 边PAD数*PAD宽度 + 2* Corner 宽度 
# puts "PISRN count = [sizeof_collection [get_cells -hier -filter {ref_name == PISRN}]]"
# puts "PBS4RN count = [sizeof_collection [get_cells -hier -filter {ref_name == PBS4RN}]]" 
initialize_floorplan -boundary {{0 0} {3200.17 3200.40}} -core_offset {240 240} \
    -flip_first_row true -coincident_boundary true





### place port
# remove_individual_pin_constraints
# #-allowed_layers {M5 M7} 
# set_individual_pin_constraints -ports [all_inputs] -sides 1 -pin_spacing 50 -offset {150 1200} -allowed_layers {M3 M4 M5 M6 M7}
# set_individual_pin_constraints -ports [all_outputs] -sides 1 -pin_spacing  50 -offset {150 1200} -allowed_layers {M3 M4 M5 M6 M7}
# place_pins -self -ports [get_ports *]

### place pad
# Core power pads: 4 pairs PVDD1RN / PVSS1RN
create_cell {
  CORE_PVDD1RN_0 CORE_PVDD1RN_1 CORE_PVDD1RN_2 CORE_PVDD1RN_3
} PVDD1RN

create_cell {
  CORE_PVSS1RN_0 CORE_PVSS1RN_1 CORE_PVSS1RN_2 CORE_PVSS1RN_3
} PVSS1RN


# PAD ring power pads: 20 pairs PVDD2RN / PVSS2RN
create_cell {
  PAD_PVDD2RN_00 PAD_PVDD2RN_01 PAD_PVDD2RN_02 PAD_PVDD2RN_03 PAD_PVDD2RN_04
  PAD_PVDD2RN_05 PAD_PVDD2RN_06 PAD_PVDD2RN_07 PAD_PVDD2RN_08 PAD_PVDD2RN_09
  PAD_PVDD2RN_10 PAD_PVDD2RN_11 PAD_PVDD2RN_12 PAD_PVDD2RN_13 PAD_PVDD2RN_14
  PAD_PVDD2RN_15 PAD_PVDD2RN_16 PAD_PVDD2RN_17 PAD_PVDD2RN_18 PAD_PVDD2RN_19
} PVDD2RN

create_cell {
  PAD_PVSS2RN_00 PAD_PVSS2RN_01 PAD_PVSS2RN_02 PAD_PVSS2RN_03 PAD_PVSS2RN_04
  PAD_PVSS2RN_05 PAD_PVSS2RN_06 PAD_PVSS2RN_07 PAD_PVSS2RN_08 PAD_PVSS2RN_09
  PAD_PVSS2RN_10 PAD_PVSS2RN_11 PAD_PVSS2RN_12 PAD_PVSS2RN_13 PAD_PVSS2RN_14
  PAD_PVSS2RN_15 PAD_PVSS2RN_16 PAD_PVSS2RN_17 PAD_PVSS2RN_18 PAD_PVSS2RN_19
} PVSS2RN


# remove_cells {PCORNER_0 PCORNER_1 PCORNER_2 PCORNER_3}



# 获取PAD
# foreach_in_collection c [get_cells -hierarchical -filter "ref_name =~ PISRN* || ref_name =~ PBS4RN*"] {
#     puts "[get_object_name $c]  -> [get_attribute $c ref_name]"
# }

source scripts/pad.tcl 




# get_attribute [current_block] boundary


set die_llx -240.0000
set die_lly -240.0000
set die_urx 3440.1700
set die_ury 3440.4000

# 最终X方向有0.005导致FILLER无法插满 所以改为177.005
set x_corner 177.005
set y_corner 177.000

set x_len [expr {$die_urx - $die_llx - 2*$x_corner}]
set y_len [expr {$die_ury - $die_lly - 2*$y_corner}]



remove_io_guides -all

create_io_guide -name left_guide -side left -pad_cells $left_pads \
    -line [list [list $die_llx [expr {$die_lly + $y_corner}]] $y_len]

create_io_guide -name top_guide -side top -pad_cells $top_pads \
    -line [list [list [expr {$die_llx + $x_corner}] $die_ury] $x_len]

create_io_guide -name right_guide -side right -pad_cells $right_pads \
    -line [list [list $die_urx [expr {$die_ury - $y_corner}]] $y_len]

create_io_guide -name bottom_guide -side bottom -pad_cells $bottom_pads \
    -line [list [list [expr {$die_urx - $x_corner}] $die_lly] $x_len]

remove_signal_io_constraints
set_signal_io_constraints -io_guide_object left_guide \
    -constraint "{42} $left_pads"
set_signal_io_constraints -io_guide_object top_guide \
    -constraint "{42} $top_pads"
set_signal_io_constraints -io_guide_object right_guide \
    -constraint "{42} $right_pads"
set_signal_io_constraints -io_guide_object bottom_guide \
    -constraint "{42} $bottom_pads"


create_io_corner_cell -reference_cell PCORNERRN {left_guide top_guide}
create_io_corner_cell -reference_cell PCORNERRN {right_guide top_guide}
create_io_corner_cell -reference_cell PCORNERRN {left_guide bottom_guide}
create_io_corner_cell -reference_cell PCORNERRN {right_guide bottom_guide}

place_io -io_guide {left_guide top_guide right_guide bottom_guide} 

puts "PISRN  = [sizeof_collection [get_cells -hierarchical -filter {ref_name == PISRN}]]"
puts "PBS4RN = [sizeof_collection [get_cells -hierarchical -filter {ref_name == PBS4RN}]]"
puts "PVDD1RN = [sizeof_collection [get_cells -hierarchical -filter {ref_name == PVDD1RN}]]"
puts "PVSS1RN = [sizeof_collection [get_cells -hierarchical -filter {ref_name == PVSS1RN}]]"
puts "PVDD2RN = [sizeof_collection [get_cells -hierarchical -filter {ref_name == PVDD2RN}]]"
puts "PVSS2RN = [sizeof_collection [get_cells -hierarchical -filter {ref_name == PVSS2RN}]]"
puts "PCORNERRN = [sizeof_collection [get_cells -hierarchical -filter {ref_name == PCORNERRN}]]"

create_io_filler_cells -reference_cells { PFILL20RN PFILL10RN PFILL5RN PFILL2RN PFILL1RN PFILL01RN PFILL001RN }

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
# file copy -force ./floorplan/fp.tcl ./scripts/place_hard_macro.tcl
# 小的5 大的20
source scripts/place_hard_macro.tcl 
create_keepout_margin -outer {5.02 3.78 5.02 3.78} [get_flat_cells * -filter is_hard_macro==true] ;# 左 下 右 上


### blockage(gui) copy from fp.tcl
# change_selection [get_placement_blockages *]
# write_floorplan -objects [get_selection ] -force -nosplit ;#(-nosplit No line break)



create_placement_blockage -name pb_0 -type allow_buffer_only -blocked_percentage 0 -boundary { {1808.9800 0.0000} {3200.1700 310.5150} }
create_placement_blockage -name pb_1 -type allow_buffer_only -blocked_percentage 0 -boundary { {3146.1000 310.5150} {3200.1700 781.6150} }
create_placement_blockage -name pb_2 -type allow_buffer_only -blocked_percentage 0 -boundary { {1950.0950 310.5150} {2071.2500 334.7500} }
create_placement_blockage -name pb_3 -type allow_buffer_only -blocked_percentage 0 -boundary { {2232.3250 310.5150} {2353.4800 334.7500} }




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
connect_pg_net -net VDD [get_pins */VNW -hierarchical]
connect_pg_net -net VSS [get_pins */VPW -hierarchical]
connect_pg_net -net VDD [get_pins */VDDCE -hierarchical] 
connect_pg_net -net VDD [get_pins */VDDPE -hierarchical] 
connect_pg_net -net VSS [get_pins */VSSE -hierarchical] 
connect_pg_net -all_blocks -automatic

### save & quit
save_block
save_lib -all

