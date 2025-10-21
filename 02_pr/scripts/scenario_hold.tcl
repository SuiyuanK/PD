### load setting
source scripts/00_common_design_settings.tcl

### initialize setting
source scripts/initialization_settings.tcl

#-------------------------------------------
# Scenario Stup
#-------------------------------------------
### Scenario = mode + corner
# mode = SDC 
# corner = lib_corner(PVT) + rc_coner(rc_variation + temp)
# mode_libcorner_rcconer

create_corner ff1p21vm40c_cmin
create_scenario -mode func -corner ff1p21vm40c_cmin -name func_ff1p21vm40c_cmin

current_mode func
current_corner ff1p21vm40c_cmin
current_scenario func_ff1p21vm40c_cmin

### rc tech
# name 
read_parasitic_tech -tlup $icc2rc_tech(cmin) -layermap $itf_tluplus_map -name minTLU
### SDC
remove_sdc -scenario [current_scenario]
source $import_sdc

### PVT conditions
# get_libs report_lib XXXX
# get_nets -physical_context -filter net_type==power||net_type==ground  ------>>>>> {VDD VSS}
set_process_number -corners [current_corner] 1.21
set_process_label  -corners [current_corner] ff
set_voltage -object_list {VDD} 1.21
set_voltage -object_list {VSS} 0
set_temperature -corners [current_corner] -40
set_parasitic_parameters -corners [current_corner] -late_spec minTLU  -early_spec minTLU


### boundary constraints
#  Half of the clk cycle (3.3ns)          report_units
set input_ports [all_inputs]
set data_inputs [remove_from_collection $input_ports [get_ports [get_attribute [get_clocks] sources -quiet]]]
set_input_delay 3.6 -max $data_inputs
set_input_delay 3.0 -min $data_inputs

# no output clk
set output_ports [all_outputs]
set_output_delay 3.6 -max $output_ports
set_output_delay 3.3 -min $output_ports

# get_lib_cells *BUF*4*RVT  
# Set the driving capacity of $data_inputs to be equivalent to XXX
set_driving_cell -lib_cell BUFV8_12TR40 $data_inputs
set_load 0.5 $output_ports

### DRV constraints
# 7-10%
set_max_transition 0.6 CLK -scenarios func_ss0p99v125c_cmax -clock_path
# 20 25 ...%
set_max_transition 1.6 CLK -scenarios func_ss0p99v125c_cmax -data_path
# Even if it has set_max_transition, the max_capacitance won't be too large
# set_max_capacitance 1.5 CLK -scenarios func_ss0p99v125c_cmax

### margin : derate & uncertttainty
# 5%-10% (6.7)
set_timing_derate -early 0.95 -cell_delay -net_delay 
set_timing_derate -late  1.05 -cell_delay -net_delay 

set_clock_uncertainty 0.2 [get_clocks *]

#### scenario status
set_scenario_status func_ff1p21vm40c_cmin -active true -setup true -hold true -max_capacitance true -max_transition true -min_capacitance true -leakage_power false -dynamic_power false

### report
# no warning
report_pvt


#-------------------------------------------
# End
#-------------------------------------------




