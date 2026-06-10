

# 开启零互连延迟模式 (Zero Interconnect Delay Mode)
# 在此模式下，工具会忽略所有走线的RC寄生延迟，仅计算标准单元(Cell)的内部延迟。
# 这通常用于早期（如布局后，布线前）评估时序约束的合理性，检查只考虑单元延迟时是否存在不可修复的逻辑时序违例。
set_zero_interconnect_delay_mode true

# 检查当前所有的约束违规情况，并将结果输出（同时在终端显示并保存到文件）到 zic.report_constraint 报告中
redirect -tee zic.report_constraint { report_constraint -all }

# 报告时序路径，并将零互连延迟下的时序分析结果保存到 zic.report_timing 报告中
redirect -tee zic.report_timing { report_timing }

# 关闭零互连延迟模式，恢复正常的真实互连线RC延迟计算
set_zero_interconnect_delay_mode false
