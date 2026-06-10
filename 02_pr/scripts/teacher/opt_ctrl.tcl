# ============================================================================
# 优化控制参数 (Placement/Optimization Control)
# 功能: 配置放置和物理优化的全局参数、时序约束、DRC 约束处理
# ============================================================================

# 启用多时钟寄存器支持 - 允许同一寄存器有多个时钟
set_app_var timing_enable_multiple_clocks_per_reg true

# 启用逻辑常数的时序分析 - 在时序分析中考虑逻辑常数化的影响
set_app_var case_analysis_with_logic_constants true

# 禁用未加载单元的删除 - 在优化过程中保留未加载的标准单元
set_app_var physopt_delete_unloaded_cells false

# 设置功率临界范围为 0.4 倍周期 - 在此范围内的路径被视为功率关键路径
set_app_var physopt_power_critical_range 0.4

# 设置面积临界范围为 0.4 倍周期 - 在此范围内的路径被视为面积关键路径
set_app_var physopt_area_critical_range 0.4

# [注释] 可选的虚假路径设置示例，用于排除时序分析中的某些路径
# set_false_path from <clock_name> -to <clock_name>

# 修复多端口网络 - 对所有多端口网络添加缓冲器以处理常数
set_fix_multiple_port_nets -all -buffer_constants

# 禁用常数 DRC 网络的自动禁用 - 不自动禁用包含常数的 DRC 网络
set_auto_disable_drc_nets -constant false

# 设置最大时序延迟 margin 为 0.95 - 设置 0.95 的 de-rate factor (5% 悲观裕度)
set_timing_derate -max -early 0.95

# 设置最大可用面积为 0 - 不限制单元面积增长 (0 表示无限制)
set_max_area 0

# 为输入端口创建路径分组 - 便于时序分析和报告的组织
group_path -name INPUTS -from [all_inputs]

# 为输出端口创建路径分组 - 便于时序分析和报告的组织
group_path -name OUTPUTS -to [all_outputs]

# 为组合路径创建路径分组 - 从输入到输出的纯组合逻辑路径
group_path -name COMBO -from [all_inputs] -to [all_outputs]

# 生成路径分组报告 - 显示所有已定义的路径分组及其统计信息
report_path_group

# 标记时钟树网络为理想网络 - 在时序分析中忽略时钟树的寄生延迟，只保留逻辑延迟
set_ideal_network [all_fanout -flat -clock_tree]