


create_clock -period [expr {20/3}] -name CLK [get_ports clk]
set_false_path -from [get_ports rst_n] -to [all_registers]



