
#****************************************************

set CLOCK_PERIOD_REFCLK [expr 1000 / 100.0 ]

# set Rst_list		[list PAD_wb_rst_i]
# set Clk_list		[list PAD_wb_clk_i]


set Rst_list		[list reset]
set Clk_list		[list clk]

create_clock -name ref_clk -period ${CLOCK_PERIOD_REFCLK} [get_ports "$Clk_list"]


set div_inst "u_soc_top_ASIC/pll_clk.u_clk_divider_100m"
set div_clk_in [get_pins ${div_inst}/clk_in]

# 100MHz: clk_100m = clk_in，组合直通
create_generated_clock -name conv_clk \
    -source $div_clk_in \
    -master_clock ref_clk \
    -divide_by 1 \
    -combinational \
    [get_pins ${div_inst}/clk_100m]

# 50MHz: clk_50m 每个 clk_in 上升沿翻转一次，2 分频，50% duty
create_generated_clock -name sys_clk \
    -source $div_clk_in \
    -master_clock ref_clk \
    -divide_by 2 \
    [get_pins ${div_inst}/clk_50m]

# 33.33MHz: 高 10ns，低 20ns，不能简单用 -divide_by 3
create_generated_clock -name cpu_clk \
    -source $div_clk_in \
    -master_clock ref_clk \
    -edges {1 3 7} \
    [get_pins ${div_inst}/clk_33m]


set_clock_latency	    0.8	            [all_clocks]
set_clock_uncertainty	0.3	            [all_clocks]
set_clock_transition    0.3             [all_clocks]


set_drive 0	            [get_ports "$Rst_list"]
set_drive 0 	        [get_ports "$Clk_list"]

set_dont_touch_network  [all_clocks]
# set_ideal_network       [get_pins "U_wb_clk_i/D"]
set_ideal_network       [get_ports "$Clk_list"]
set_ideal_network -no_propagate [get_nets -of [get_pins ${div_inst}/clk_100m]]
set_ideal_network -no_propagate [get_nets -of [get_pins ${div_inst}/clk_50m]]
set_ideal_network -no_propagate [get_nets -of [get_pins ${div_inst}/clk_33m]]

set_dont_touch_network               [get_ports "$Rst_list"]
set_ideal_network       [get_ports "$Rst_list"]


set_false_path -from [get_ports "$Rst_list"]
# case_analysis
# set_case_analysis 0 [get_pins "U_wb_rst_i/D"]
set_case_analysis 0 [get_ports "$Rst_list"]
#****************************************************


set input_ports [all_inputs]
set data_inputs [remove_from_collection $input_ports [get_ports "$Clk_list"]]
set data_inputs [remove_from_collection $data_inputs [get_ports "$Rst_list"]]
set output_ports [all_outputs]

# set MAX_LOAD	[load_of smic18_ss_1p62v_125c/NAND2HD2X/A]
set MAX_LOAD	[load_of scc40nll_vhsc40_hvt_ss_v0p99_125c_basic/NAND2BV4_12TH40/A1]

set_max_fanout 10 $input_ports
set_max_capacitance [expr $MAX_LOAD*15] [get_designs *]
set_load [expr $MAX_LOAD*15] [all_outputs]

# 输入PAD
set_driving_cell -lib_cell PISRN $data_inputs

#****************************************************

#路径分组。-from -to 优先级最大，-from 次之，-to 优先级最小
group_path -name reg2out -to [all_outputs]
#来自除去clk和rst之外的所有输入信号的路径
group_path -name in2reg -from $data_inputs
#除去clk和rst之外的所有输入信号到所有输出信号的路径
group_path -name in2out -from $data_inputs -to [all_outputs]

#****************************************************


set data_inputs  [remove_from_collection $data_inputs  [get_ports spi_miso]]
set output_ports [remove_from_collection $output_ports [get_ports {spi_mosi spi_sclk spi_ss}]]


#  Half of the clk cycle (10ns 50MHz)          report_units
set_input_delay 10.5 -max $data_inputs -clock sys_clk
set_input_delay 9.5 -min $data_inputs -clock sys_clk

# no output clk
set_output_delay 10.5 -max $output_ports -clock sys_clk
set_output_delay 9.5 -min $output_ports -clock sys_clk


set_input_delay 5.5 -max -clock conv_clk [get_ports spi_miso]
set_input_delay 4.5 -min -clock conv_clk [get_ports spi_miso]
set_output_delay 5.5 -max -clock conv_clk [get_ports {spi_mosi spi_ss spi_sclk}]
set_output_delay 4.5 -min -clock conv_clk [get_ports {spi_mosi spi_ss spi_sclk}]


# 7-10%
set_max_transition 1 -clock_path [get_clocks ref_clk]
set_max_transition 1 -clock_path [get_clocks conv_clk]
set_max_transition 2 -clock_path [get_clocks sys_clk]
set_max_transition 3 -clock_path [get_clocks cpu_clk]

# 20 25 ...%
set_max_transition 2 -data_path [get_clocks ref_clk]
set_max_transition 2 -data_path [get_clocks conv_clk]
set_max_transition 4 -data_path [get_clocks sys_clk]
set_max_transition 6 -data_path [get_clocks cpu_clk]

# 5%-10% 值为0.1到2.0
set_timing_derate -early 0.95 -cell_delay -net_delay  
set_timing_derate -late  1.05 -cell_delay -net_delay 
#****************************************************


# don't touch all IO PAD cells
set IO_PAD_CELLS [get_cells -hier -filter "ref_name == PISRN || ref_name == PBS4RN"]

if {[sizeof_collection $IO_PAD_CELLS] == 0} {
    echo "WARNING: No IO PAD cells found. Please check PAD ref_name or hierarchy."
} else {
    set_dont_touch $IO_PAD_CELLS
}


