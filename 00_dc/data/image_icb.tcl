
#****************************************************

set CLOCK_PERIOD_REFCLK [expr 1000 / 150.0 ]

# set Rst_list		[list PAD_wb_rst_i]
# set Clk_list		[list PAD_wb_clk_i]

set Rst_list		[list PAD_wb_rst_i]
set Clk_list		[list PAD_wb_clk_i]

create_clock -name ref_clk -period ${CLOCK_PERIOD_REFCLK} [get_ports "$Clk_list"]

set_clock_latency	    0.8	    [all_clocks]
set_clock_uncertainty	0.3	    [all_clocks]
set_clock_transition    0.3     [all_clocks]


set_drive 0	            [get_ports "$Rst_list"]
set_drive 0 	        [get_ports "$Clk_list"]
set_dont_touch_network  [all_clocks]
set_ideal_network       [get_pins "U_wb_clk_i/D"]
set_dont_touch_network  [get_ports "$Rst_list"]
set_ideal_network       [get_ports "$Rst_list"]

# 复位信号到内部逻辑之间的路径被标记为“假路径”，不参与时序分析
set_false_path -from [get_ports "$Rst_list"]
# case_analysis
set_case_analysis 0 [get_pins "U_wb_rst_i/D"]
#****************************************************


set input_ports [all_inputs]
set data_inputs [remove_from_collection $input_ports [get_ports "$Clk_list"] [get_ports "$Rst_list"]]

set MAX_LOAD	[load_of smic18_ss_1p62v_125c/NAND2HD2X/A]


set_max_fanout 10 $input_ports
set_max_capacitance [expr $MAX_LOAD*12] [get_designs *]
set_load [expr $MAX_LOAD*15] [all_outputs]
set_driving_cell -lib_cell BUFV8_12TR40 $data_inputs
set output_ports [all_outputs]

#****************************************************

#  Half of the clk cycle (3.3ns)          report_units
set_input_delay 3.6 -max $data_inputs -clock ref_clk
set_input_delay 3.0 -min $data_inputs -clock ref_clk

# no output clk
set_output_delay 3.6 -max $output_ports -clock ref_clk
set_output_delay 3.3 -min $output_ports -clock ref_clk

# 7-10%
set_max_transition 0.6 -clock_path [get_clocks ref_clk]
# 20 25 ...%
set_max_transition 1.6 -data_path  [get_clocks ref_clk]
# 5%-10% (6.7)
set_timing_derate -early 0.95 -cell_delay -net_delay  
set_timing_derate -late  1.05 -cell_delay -net_delay 
#****************************************************





