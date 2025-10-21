set setup_uncertainty 0.2
set hold_uncertainty 0.2

set CLOCK_PERIOD_REFCLK [expr 1000 / 150.0 ]

create_clock -name ref_clk -period ${CLOCK_PERIOD_REFCLK} [get_ports clk]

set_clock_uncertainty [expr ${setup_uncertainty}] -setup [get_clocks [all_clocks]]
set_clock_uncertainty [expr ${hold_uncertainty}]  -hold  [get_clocks [all_clocks]]

set_load 5 [all_outputs]
set_input_transition 1.0 [all_inputs]

set FIX_DELAY 0.1

set_input_delay -clock ref_clk ${FIX_DELAY} [get_ports input_a[*]]
set_input_delay -clock ref_clk ${FIX_DELAY} [get_ports input_b[*]]

set_output_delay -clock ref_clk ${FIX_DELAY} [get_ports output_z[*]]

#对clk与复位信号设置为不被优化，前者视为理想网络
#set_dont_touch          [get_ports clk]
set_ideal_network       [get_ports clk]
#set_dont_touch          [get_ports rst_n]



