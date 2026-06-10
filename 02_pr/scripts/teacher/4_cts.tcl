


# ========== 打开库 ==========
open_mw_lib aes_ASIC.mw
copy_mw_cel -from placed -to clock_opt
open_mw_cel clock_opt

# 打印额外的调试信息
set cts_use_debug_mode true 
# 打印时钟树综合所使用的缓冲器和反相器的详细特征数据
set cts_do_characterization true

# 为 CTS 阶段设置实例名称的前缀
set_app_var cts_instance_name_prefix CTS

# 报告当前设计中所有时钟的基本属性和偏移（Skew）设置信息
report_clock -skew -attributes
# 详细报告综合后的时钟树（Clock Tree）状态，包含宏观统计、层级细节和拓扑结构
report_clock_tree -summary -level_info -structure
# 专门报告名为 PAD_wb_clk_i 这个特定端口（Port）的属性信息
report_port PAD_wb_clk_i

# 执行 { report_constraint -all } 命令，
# 将其生成的输出报告保存到 report_constraint_all.rpt 文件中，
# 同时在当前的终端屏幕上同步显示这些输出信息
redirect -tee report_constraint_all.rpt { report_constraint -all}


# 暂停自动删除未负载的单元（时序逻辑与组合逻辑），防止在移除时钟树时误删原有逻辑单元
set physopt_delete_unloaded_cells false
set physopt_delete_unloaded_sequential_cells false
# 移除当前设计中已存在的时钟树（如果有）
remove_clock_tree
# 恢复自动删除未负载单元属性
set physopt_delete_unloaded_cells true
set physopt_delete_unloaded_sequential_cells true

# 如果设计中含有宏单元 (Macro cells)，将它们设置为 dont_touch，避免这阶段被移动
if {[all_macro_cells] != "" } {
  set_dont_touch_placement [all_macro_cells]
}


# 设置时钟树综合目标偏移量 (target skew) 为 0.1
set_clock_tree_options -target_skew 0.1
# 为所有时钟设置 0.1 的时钟不确定度
set_clock_uncertainty 0.1 [all_clocks]

# 指定综合时钟树可以引用的缓冲器 (Buffer) 和反相器 (Inverter) 单元列表
set_clock_tree_references -references {INVCLKHDLX INVCLKHD1X INVCLKHD2X INVCLKHD3X INVCLKHD4X \ 
    INVCLKHD8X INVCLKHD12X INVCLKHD16X INVCLKHD20X INVCLKHD30X INVCLKHD40X INVCLKHD80X \ 
    BUFCLKHDLX  BUFCLKHD1X BUFCLKHD2X BUFCLKHD3X BUFCLKHD4X BUFCLKHD8X \ 
    BUFCLKHD12X BUFCLKHD16X BUFCLKHD20X BUFCLKHD30X BUFCLKHD40X BUFCLKHDL80X}

# 定义非默认布线规则 (Non-Default Routing Rule, NDR)
# 指定 M3~M6 走线层的线间距以减小串扰
define_routing_rule  CLOCK_DOUBLE_SPACING \
	-spacings {M3 0.56 M4 0.76 M5 0.66 M6 1.02}

# 报告刚才定义的布线规则，确认是否生效
report_routing_rule CLOCK_DOUBLE_SPACING

# 应用上述 NDR 布线规则到时钟网络
# 限制时钟布线在 M3 到 M6 层进行，同时靠近终点叶级 (Sink) 的最后一小段线使用默认规则
set_clock_tree_options -routing_rule CLOCK_DOUBLE_SPACING \
	-layer_list {M3 M6} -use_default_routing_for_sinks 1

# 报告时钟树综合（CTS）约束和配置规则
report_clock_tree -settings

# 物理设计预检查：处于 pre_clock_opt (时钟树综合前) 阶段
check_physical_design -stage pre_clock_opt -display

# 设置延迟计算选项
# 预布线时用 awe 算法，布线后（包含常规网络和时钟网络）用 arnoldi 算法，算法计算精度均为 medium 级别
#set_delay_calculation -clock_arnoldi
set_delay_calculation_options -preroute awe -postroute arnoldi -routed_clock arnoldi -arnoldi_effort medium -awe_effort medium

# 排查物理与逻辑问题 排查约束冲突 MCMM (多角多模式) 交叉检查
check_clock_tree 

# 执行时钟树综合，只插 Buffers 生成时钟树 (-only_cts)，此时不进行真实的 clock 绕线 (-no_clock_route)
clock_opt -only_cts -no_clock_route

# 综合结束后，输出时钟树概览报告
report_clock_tree -summary
# 报告时钟偏斜情况并保留 3 位有效数字
report_clock_timing -type skew -significant_digits 3

# 时钟树完成后的时序及约束报告
report_timing
report_constraint -all

# 保存状态到 Milkyway 数据库，另存为 clock_opt_cts
save_mw_cel -as clock_opt_cts

# 时钟网络现已具有真实的走线延迟，移除之前的 ideal_network 属性 (让时序分析包含真实的 RC)
remove_ideal_network [all_fanout -flat -clock_tree]

# 对所有时钟开启 Hold Time (保持时间) 的修复功能，允许在接下来的优化中插入 delay buffer 来修 hold
set_fix_hold [all_clocks]

# 检查当前设计质量
report_qor

# 设置时序通过后竭力压缩面积 (-max_area 0)，允许关键路径 20%的冗余范围内回收面积
set_max_area 0
set physopt_area_critical_range 0.2

# 提取时钟网络 RC 寄生参数
extract_rc 

# 删除先前预估的时钟不确定度 (margin)，因为真实寄生和偏斜已被工具获取
remove_clock_uncertainty [all_clocks]

# -only_psyn (只做物理综合，不做CTS) 数据线，-area_recovery (面积回收)
# -optimize_dft(开启时钟感知（Clock-aware）的扫描链重排（Scan Reordering）)
# -no_clock_route (不布时钟线)
clock_opt -only_psyn -area_recovery -optimize_dft -no_clock_route 

# 优化后输出最新的质量报告和违例报告
report_qor
report_constraint -all

# 保存状态到 Milkyway 数据库，另存为 clock_opt_psyn
save_mw_cel -as clock_opt_psyn

# 把设计中所有的时钟线优先进行详细布线（Detail Route）沿着已经做好的‘全局布线（Global Route）’轨迹来走
# -all_clock_nets (目标是设计中的所有时钟网络)
# -reuse_existing_global_route true (保留并复用现有的全局布线信息)
route_zrt_group -all_clock_nets -reuse_existing_global_route true

# 布线后最后一次检查全芯片的违例状况
report_constraint -all

# 保存布线完成后的完整状态，另存为 clock_opt_route
save_mw_cel -as clock_opt_route

# 报告目前设计的物理层统计信息（如标准单元数目、面积利用率等）
report_design -physical

# 关闭当前工作数据库，CTS 和时钟优化阶段结束
close_mw_lib