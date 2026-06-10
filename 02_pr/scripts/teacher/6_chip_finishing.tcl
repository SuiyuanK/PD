
# 打开Milkyway库并基于最终布线的单元(route_opt_final)创建一个用于芯片收尾(chip_finish)的新单元
open_mw_lib aes_ASIC.mw
copy_mw_cel -from route_opt_final -to chip_finish
open_mw_cel chip_finish

start_gui

# 计算设计的短路临界面积(Short Critical Area, CCA)，并将结果保存到报告文件中
report_critical_area -fault_type short
sh mv output_heatmap cca.short.before.rpt

# 通过拉大布线间隙(Wire Spreading)来降低金属走线的短路故障良率风险
spread_zrt_wires
report_critical_area -fault_type short
sh mv output_heatmap cca.short.after.rpt

# DFM - 分析造成断路(Open)规则违例的临界面积
report_critical_area -fault_type open
sh mv output_heatmap cca.open.before.rpt
# 通过加宽布线(Wire Widening)来降低断线故障的风险
widen_zrt_wires
report_critical_area -fault_type open
sh mv output_heatmap cca.open.after.rpt

# 在更改导线宽度和间距后重新验证布线DRC及违例
verify_zrt_route
report_constraint -all_violators -nosplit

save_mw_cel -as chip_finish_ca

# 加载天线效应 (Antenna Effect) 工具规则
source -echo scripts/antenna_rules.tcl

# 配置Zroute详细布线开启天线效应规则检查，并允许自动插入天线防护二极管(Diodes)
set_route_zrt_detail_options -antenna true -insert_diodes_during_routing true
# 执行一次增量路由寻找修复天线效应的方案
route_zrt_detail -incremental true

# 重新建立可能新插入二极管单元的电源地(PG)连接
derive_pg_connection -power_net $PWR_NAME -power_pin $PWR_NAME -ground_net $GND_NAME -ground_pin $GND_NAME
derive_pg_connection -power_net $PWR_NAME -ground_net $GND_NAME -tie
verify_zrt_route
report_constraint -all_violators -nosplit

# 增量执行路由和时序优化，以修复由于上述散线、宽线或插二极管所可能引起的新时序或DRC违例
route_opt -incremental
derive_pg_connection -power_net $PWR_NAME -power_pin $PWR_NAME -ground_net $GND_NAME -ground_pin $GND_NAME
derive_pg_connection -power_net $PWR_NAME -ground_net $GND_NAME -tie
verify_zrt_route
report_constraint -all_violators -nosplit

save_mw_cel -as chip_finish_antenna

# 插入标准单元填充物 (Filler Cells)
# 目的是保证N-Well连续，以及确保标准电源轨地轨能够相连到底，符合流片的DRC要求
insert_stdcell_filler -cell_with_metal "FILLER64HD FILLER32HD FILLER16HD FILLER8HD FILLER6HD FILLER4HD FILLER3HD FILLER2HD FILLER1HD" -connect_to_power $PWR_NAME -connect_to_ground $GND_NAME -between_std_cells_only

verify_zrt_route
report_constraint -all_violators -nosplit

# 报告插入前的物理设计数据统计
report_design_physical -route
# 插入冗余过孔 (Redundant Vias) 以提高良率，将单过孔(Single Via)替换成阵列过孔或其他多过孔结构防断开
insert_zrt_redundant_vias -list_only
insert_zrt_redundant_vias -effort medium

# 报告插入冗余过孔后的物理设计数据以验证数量
report_design_physical -route
verify_zrt_route
report_constraint -all_violators -nosplit

# 插入金属假充填填充物 (Metal Dummy/Metal Filler)
# 用于帮助满足化学机械抛光(CMP)的工艺金属密度DRC要求。timing_driven为避免填入对关键时序连线产生严重寄生电容干扰
insert_metal_filler -routing_space 2 -timing_driven

derive_pg_connection -power_net $PWR_NAME -power_pin $PWR_NAME -ground_net $GND_NAME -ground_pin $GND_NAME
derive_pg_connection -power_net $PWR_NAME -ground_net $GND_NAME -tie

#            FINAL DESIGN CHECKS       #
# 进行终版的最终物理DRC验证和LVS匹配验证检查
verify_zrt_route
verify_lvs  -ignore_floating_port -ignore_floating_net -check_short_locator -check_open_locator -ignore_metal_without_net_name
report_constraint -all_violators -nosplit

save_mw_cel -as chip_finish_final

# 格式化导出名称以确保纯符合网表Verilog的要求语法
change_names -hierarchy -rules verilog
# 导出只保留逻辑器件的Verilog仿真用网表
write_verilog -no_physical_only_cells  aes_ASIC_sim.vg
# 导出包含电源地、物理二极管端口连接供物理LVS对照验证的Verilog网表
write_verilog -diode_ports -pg  aes_ASIC_lvs.vg

# 导出寄生参数文件 SPEF (Standard Parasitic Exchange Format) 供静态时序分析工具进行Signoff (如PT)
write_parasitics -format SPEF -output aes_ASIC.spef

# 选项配置GDSII层级与MAP映象导出表（将内部布线层映射转换为代工厂识别的层号码）
set_write_stream_options -child_depth 255  -map_layer ../lib/SMIC18_Ver2.7/BEView_STDIO/TECH/gdsLayers.map.strmout -output_pin {text geometry} -flatten_via
# 最终向晶圆厂流片交付导出 GDSII 版图文件
write_stream -cells chip_finish_final aes_ASIC.gdsii

close_mw_lib