#****************************************************

set CLOCK_PERIOD_REFCLK [expr 1000 / 100.0 ]

# 1. 修正输入端口名，匹配 soc_pad_wrapper 的真实管脚名称
set Rst_list		[list reset]
set Clk_list		[list clk]

# 创建主时钟 (100MHz)
create_clock -name ref_clk -period ${CLOCK_PERIOD_REFCLK} [get_ports "$Clk_list"]

# ====================================================
# 内部衍生时钟约束 (Generated Clocks)
# ====================================================
# 假设分频模块例化在 u_soc_top 内部，路径为 u_soc_top/u_clk_divider_100m
set div_inst "u_soc_top/u_clk_divider_100m"

# 100MHz 卷积/高速模块时钟 (1分频)
create_generated_clock -name conv_clk \
    -source [get_ports "$Clk_list"] \
    -divide_by 1 \
    [get_pins ${div_inst}/clk_100m]

# 50MHz 系统其他模块时钟 (2分频)
create_generated_clock -name sys_clk \
    -source [get_ports "$Clk_list"] \
    -divide_by 2 \
    [get_pins ${div_inst}/clk_50m]

# 33.33MHz CPU时钟 (3分频，非对称占空比：高10ns，低20ns)
create_generated_clock -name cpu_clk \
    -source [get_ports "$Clk_list"] \
    -edges {1 3 7} \
    [get_pins ${div_inst}/clk_33m]

# SPI 输出时钟 (以 100MHz 为基准进行分频，此处假设为 4 分频得到 25MHz)
create_generated_clock -name spi_clk_out \
    -source [get_ports "$Clk_list"] \
    -divide_by 4 \
    [get_ports spi_sclk]


# 时钟属性设置 (作用于主时钟及所有衍生时钟)
set_clock_latency	    0.8	    [all_clocks]
set_clock_uncertainty	0.3	    [all_clocks]
set_clock_transition    0.3     [all_clocks]


set_drive 0	            [get_ports "$Rst_list"]
set_drive 0 	        [get_ports "$Clk_list"]
set_dont_touch_network  [all_clocks]
set_ideal_network       [get_ports "$Clk_list"]
set_dont_touch_network  [get_ports "$Rst_list"]
set_ideal_network       [get_ports "$Rst_list"]


set_false_path -from [get_ports "$Rst_list"]
set_case_analysis 1 [get_ports "$Rst_list"]
#****************************************************

set input_ports [all_inputs]
set data_inputs [remove_from_collection $input_ports [get_ports "$Clk_list"]]
set data_inputs [remove_from_collection $data_inputs [get_ports "$Rst_list"]]

set_max_fanout 10 $input_ports
set_max_capacitance [expr $MAX_LOAD*12] [get_designs *]
set_load [expr $MAX_LOAD*15] [all_outputs]
set_driving_cell -lib_cell BUFV8_12TR40 $data_inputs

# ====================================================
# 划分普通数据端口与 SPI 专用端口
# ====================================================
set output_ports [all_outputs]
# 从通用端口集合中剔除 SPI 端口，避免误用 100MHz 主时钟进行过约束
set data_inputs  [remove_from_collection $data_inputs  [get_ports spi_miso]]
set output_ports [remove_from_collection $output_ports [get_ports {spi_mosi spi_sclk spi_ss}]]

#****************************************************

# 普通数据端口时序延迟 (参考 100MHz 主时钟 ref_clk)
set_input_delay 10.5 -max $data_inputs -clock ref_clk
set_input_delay 9.5 -min $data_inputs -clock ref_clk

set_output_delay 10.5 -max $output_ports -clock ref_clk
set_output_delay 9.5 -min $output_ports -clock ref_clk

# ====================================================
# SPI 专用时序延迟 (参考 spi_clk_out)
# ====================================================
set_input_delay 5.0 -max -clock spi_clk_out [get_ports spi_miso]
set_input_delay 1.0 -min -clock spi_clk_out [get_ports spi_miso]

set_output_delay 5.0 -max -clock spi_clk_out [get_ports {spi_mosi spi_ss}]
set_output_delay 1.0 -min -clock spi_clk_out [get_ports {spi_mosi spi_ss}]

# 异步路径解耦：防止工具去分析内部高速时钟域与外部 SPI 接口之间的硬时序
set_false_path -from [get_clocks conv_clk] -to [get_clocks spi_clk_out]
set_false_path -from [get_clocks spi_clk_out] -to [get_clocks conv_clk]


# 7-10% (作用于所有定义的时钟网络)
set_max_transition 2 -clock_path [all_clocks]
# 20 25 ...%
set_max_transition 4 -data_path  [all_clocks]
# 5%-10% 值为0.1到2.0
set_timing_derate -early 0.95 -cell_delay -net_delay  
set_timing_derate -late  1.05 -cell_delay -net_delay 
#****************************************************

# 路径分组
group_path -name reg2out -to [all_outputs]
group_path -name in2reg -from $data_inputs
group_path -name in2out -from $data_inputs -to [all_outputs]

# 针对内部衍生时钟域进行路径分组优化，提升建立时间收敛权重
group_path -name clk_conv -weight 1 -to [get_clocks conv_clk]
group_path -name clk_sys  -weight 1 -to [get_clocks sys_clk]
group_path -name clk_cpu  -weight 1 -to [get_clocks cpu_clk]

#****************************************************
# # don't touch 所有的IPAD
# set_dont_touch        [get_cells U_* ]