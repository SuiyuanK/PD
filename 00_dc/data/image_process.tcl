set setup_uncertainty 0.2
set hold_uncertainty 0.2

set CLOCK_PERIOD_REFCLK [expr 1000 / 150.0 ]

create_clock -name ref_clk -period ${CLOCK_PERIOD_REFCLK} [get_ports clk]

set_clock_uncertainty [expr ${setup_uncertainty}] -setup [get_clocks [all_clocks]]
set_clock_uncertainty [expr ${hold_uncertainty}]  -hold  [get_clocks [all_clocks]]



set input_ports [all_inputs]
set data_inputs [remove_from_collection $input_ports [get_ports clk]]

set_load 0.5 [all_outputs]
set_driving_cell -lib_cell BUFV8_12TR40 $data_inputs
set output_ports [all_outputs]


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

#对clk与复位信号设置为不被优化，前者视为理想网络
set_dont_touch          [get_ports clk]
set_ideal_network       [get_ports clk]
set_dont_touch          [get_ports rst_n]

#复位信号到内部逻辑之间的路径被标记为“假路径”，不参与时序分析
set_false_path -from [get_ports rst_n] -to [all_registers]


