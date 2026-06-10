
# 打开floorplan结果
open_mw_lib aes_ASIC.mw
open_mw_cel floorplanned

# 参数设置
source scripts/opt_ctrl.tcl

# 宏单元保护
if {[all_macro_cells] != "" } {
  set_dont_touch_placement [all_macro_cells]
}

# 设置可用于布线的最高层
remove_ignored_layers -all
set_ignored_layers -max_routing_layer M6

# 禁止单元与电源网络重叠 M5/M6
remove_pnet_options
set_pnet_options -complete "M5 M6"

# 报告刚刚的设计
report_ignored_layers
report_pnet_options

# 打印physopt_hard_keepout_distance变量的值
printvar physopt_hard_keepout_distance

# 通过时钟树驱动的负载端口设置为“理想网络”
set_ideal_network [all_fanout -flat -clock_tree ]

# 为时钟线设置特殊的布线规则
#read from .tf file
#space = 2 * pitch - NDR width 
#for M6: space = 2 * 0.95 - (2* 0.44) = 1.02
define_routing_rule 2X_SPACING -spacings {M3 0.56 M4 0.76 M5 0.66 M6 1.02}
set_clock_tree_options -clock_tree [all_clocks] -routing_rule 2X_SPACING -layer_list "M3 M6"

#（Placement）优化之前，检查当前的数字芯片设计数据是否完整、合理
check_physical_design -stage pre_place_opt
# 检查物理约束是否正确
check_physical_constraints

# 报告扫描链（Scan Chain）状态和连接情况
report_scan_chain

# 报告当前设计的开关活动注释统计信息
report_saif

# 报告 optimize_pre_cts_power 命令的选项设置
report_optimize_pre_cts_power_options
# low_power_placement
set_optimize_pre_cts_power_options -low_power_placement true

# 执行placement，启用面积恢复和功率优化选项
place_opt -area_recovery -power

# 拥塞分析
report_congestion -grc_based -by_layer -routing_stage global

# 详细的物理属性报告
report_design -physical
# 报告时序质量（QoR）指标，包括时序、面积和功率等方面的统计信息
report_qor
# 报告 optimize_pre_cts_power 命令的选项设置
report_optimize_pre_cts_power_options

# 对设计进行增量式（Incremental）的调整和修补。
# -power 进一步压低芯片的功耗（Power）
psynopt -power

save_mw_cel -as placed
close_mw_lib