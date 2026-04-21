
#****************************************************

set CLOCK_PERIOD_REFCLK [expr 1000 / 50.0 ]

# set Rst_list		[list PAD_wb_rst_i]
# set Clk_list		[list PAD_wb_clk_i]

set Rst_list		[list ap_rst_n]
set Clk_list		[list ap_clk]

create_clock -name ref_clk -period ${CLOCK_PERIOD_REFCLK} [get_ports "$Clk_list"]

set_clock_latency	    0.8	    [all_clocks]
set_clock_uncertainty	0.3	    [all_clocks]
set_clock_transition    0.3     [all_clocks]


set_drive 0	            [get_ports "$Rst_list"]
set_drive 0 	        [get_ports "$Clk_list"]
set_dont_touch_network  [all_clocks]
# set_ideal_network       [get_pins "U_wb_clk_i/D"]
set_ideal_network       [get_ports "$Clk_list"]
set_dont_touch_network  [get_ports "$Rst_list"]
set_ideal_network       [get_ports "$Rst_list"]


set_false_path -from [get_ports "$Rst_list"]
# case_analysis
# set_case_analysis 0 [get_pins "U_wb_rst_i/D"]
set_case_analysis 1 [get_ports "$Rst_list"]
#****************************************************


set input_ports [all_inputs]
set data_inputs [remove_from_collection $input_ports [get_ports "$Clk_list"]]
set data_inputs [remove_from_collection $data_inputs [get_ports "$Rst_list"]]
set output_ports [all_outputs]


# set MAX_LOAD	[load_of smic18_ss_1p62v_125c/NAND2HD2X/A]
set MAX_LOAD	[load_of scc40nll_vhsc40_hvt_ss_v0p99_125c_basic/NAND2BV4_12TH40/A1]

set_max_fanout 10 $input_ports
set_max_capacitance [expr $MAX_LOAD*12] [get_designs *]
set_load [expr $MAX_LOAD*15] [all_outputs]
set_driving_cell -lib_cell BUFV8_12TR40 $data_inputs

#****************************************************

#  Half of the clk cycle (10ns)          report_units
set_input_delay 10.5 -max $data_inputs -clock ref_clk
set_input_delay 9.5 -min $data_inputs -clock ref_clk

# no output clk
set_output_delay 10.5 -max $output_ports -clock ref_clk
set_output_delay 9.5 -min $output_ports -clock ref_clk

# 7-10%
set_max_transition 2 -clock_path [get_clocks ref_clk]
# 20 25 ...%
set_max_transition 4 -data_path  [get_clocks ref_clk]
# 5%-10% 值为0.1到2.0
set_timing_derate -early 0.95 -cell_delay -net_delay  
set_timing_derate -late  1.05 -cell_delay -net_delay 
#****************************************************

#路径分组。-from -to 优先级最大，-from 次之，-to 优先级最小
group_path -name reg2out -to [all_outputs]
#来自除去clk和rst之外的所有输入信号的路径
group_path -name in2reg -from $data_inputs
#除去clk和rst之外的所有输入信号到所有输出信号的路径
group_path -name in2out -from $data_inputs -to [all_outputs]

#****************************************************
# # don't touch 所有的IPAD
# set_dont_touch        [get_cells U_* ]


