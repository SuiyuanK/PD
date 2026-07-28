#****************************************************
# CNN Block-Level Constraints
# Clock: 50MHz (period = 20ns)
# No PAD — pure block-level design
#****************************************************

set CLOCK_PERIOD [expr 1000 / 50.0]

set Rst_list    [list rst]
set Clk_list    [list clk]

create_clock -name clk -period ${CLOCK_PERIOD} [get_ports "$Clk_list"]

set_clock_latency       0.8     [all_clocks]
set_clock_uncertainty   0.3     [all_clocks]
set_clock_transition    0.3     [all_clocks]

set_drive 0     [get_ports "$Rst_list"]
set_drive 0     [get_ports "$Clk_list"]

set_dont_touch_network  [all_clocks]
set_ideal_network       [get_ports "$Clk_list"]
set_dont_touch_network  [get_ports "$Rst_list"]
set_ideal_network       [get_ports "$Rst_list"]

set_false_path -from [get_ports "$Rst_list"]
set_case_analysis 0 [get_ports "$Rst_list"]

#****************************************************
# I/O constraints
#****************************************************

set input_ports  [all_inputs]
set data_inputs  [remove_from_collection $input_ports [get_ports "$Clk_list"]]
set data_inputs  [remove_from_collection $data_inputs  [get_ports "$Rst_list"]]
set output_ports [all_outputs]

set MAX_LOAD [load_of scc40nll_vhsc40_hvt_ss_v0p99_125c_basic/NAND2BV4_12TH40/A1]

set_max_fanout 10 $input_ports
set_max_capacitance [expr $MAX_LOAD * 15] [get_designs *]
set_load [expr $MAX_LOAD * 15] [all_outputs]

# Block-level: drive inputs with a standard buffer
set_driving_cell -lib_cell BUFV4_12TH40 $data_inputs

#****************************************************
# Path groups
#****************************************************

group_path -name reg2out -to [all_outputs]
group_path -name in2reg -from $data_inputs
group_path -name in2out -from $data_inputs -to [all_outputs]

#****************************************************
# I/O timing — 50MHz (20ns period)
#****************************************************

set_input_delay  10.5 -max $data_inputs -clock clk
set_input_delay   9.5 -min $data_inputs -clock clk

set_output_delay 10.5 -max $output_ports -clock clk
set_output_delay  9.5 -min $output_ports -clock clk

#****************************************************
# Transition constraints
#****************************************************

# Clock path: 5%-10% of period → 1-2ns → use 1ns
set_max_transition 1 -clock_path [get_clocks clk]
# Data path: ~10% → 2ns
set_max_transition 2 -data_path   [get_clocks clk]

# OCV derate
set_timing_derate -early 0.95 -cell_delay -net_delay
set_timing_derate -late  1.05 -cell_delay -net_delay

#****************************************************