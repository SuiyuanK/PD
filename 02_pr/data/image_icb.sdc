create_clock -period [expr {20/3}] -name CLK [get_ports clk]


#复位信号到内部逻辑之间的路径被标记为“假路径”，不参与时序分析
set_false_path -from [get_ports resetn] -to [all_registers]


