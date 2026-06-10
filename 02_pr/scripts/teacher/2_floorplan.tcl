
# 设置当前的任务
gui_set_current_task -name {Design Planning}
# 自动恢复并重新建立该库的设置连接
set auto_restore_mw_cel_lib_setup true

# 打开设计并加载design_setup的结果
open_mw_lib aes_ASIC.mw
open_mw_cel setuped

# 读入PAD单元摆放位置
source -echo -v scripts/pad_cell_cons.tcl

# 推导电源/地连接
derive_pg_connection -power_net $PWR_NAME -power_pin $PWR_NAME -ground_net $GND_NAME -ground_pin $GND_NAME
derive_pg_connection -power_net $PWR_NAME -ground_net $GND_NAME -tie

# 创建 Floorplan 与插入 pad_filler 单元
create_floorplan -control_type width_and_height -core_width 1560 -core_height 1560 -left_io2core 200 -top_io2core 200 -right_io2core 200 -bottom_io2core 200 -start_first_row -flip_first_row
insert_pad_filler -cell "PLFILLER30 PLFILLER20 PLFILLER10 PLFILLER5 PLFILLER1 PLFILLER01 PLFILLER001 PLFILLER0005" -overlap_cell "PLFILLER0005"

# 推导电源/地连接
derive_pg_connection -power_net $PWR_NAME -power_pin $PWR_NAME -ground_net $GND_NAME -ground_pin $GND_NAME
derive_pg_connection -power_net $PWR_NAME -ground_net $GND_NAME -tie

# 保存floorplan pad摆放结果
save_mw_cel -as floorplan_pad_assigned

# 报告当前放置策略
report_fp_placement_strategy

# 设置 Floorplan 放置策略
# -auto_grouping high 表示工具会对所有宏单元尝试生成自动宏阵列
# -macros_on_edge on 指定所有宏单元必须放置在芯片（或规划组）的边缘
# -sliver_size 10 定义宏与宏之间可用于摆放标准单元的最小通道高度
# -virtual_IPO on 启用虚拟 In‑Place Optimization 改善关键路径的时序，得到更好的时序 QoR
set_fp_placement_strategy \
    -auto_grouping high \
    -macros_on_edge on \
    -sliver_size 10 \
    -virtual_IPO on

# 报告当前放置策略
report_fp_placement_strategy
# 报告通过 `set_fp_macro_options` 命令设置的各种选项
report_fp_macro_options

# 设置硬宏保护距离与放置
set_keepout_margin -type hard -all_macros -outer {10 10 10 10}

# 如果存在Macro 解除其“禁止移动”限制
if {[all_macro_cells] != "" } {
  remove_dont_touch_placement [all_macro_cells]
}

# 放置硬宏单元和叶单元
# -timing_driven 启用时序驱动的布局模式
# -no_hierarchy_gravity 忽略逻辑层次结构，不再强制将同一模块的单元聚拢
create_fp_placement -timing_driven -no_hierarchy_gravity

# 拥堵报告
# -routing_stage global 基于全局路由阶段来生成拥堵图
# -grc_based 生成基于 GRC（Global Routing Cell，即全局布线单元）的拥堵报告
# -by_layer 生成基于金属层的拥堵报告
report_congestion -grc_based -by_layer -routing_stage global

# 如果存在Macro 添加“禁止移动”限制
if {[all_macro_cells] != "" } {
  set_dont_touch_placement [all_macro_cells]
}

# 保存floorplan place macro摆放结果
save_mw_cel -as floorplan_placed

# 推导电源/地连接
derive_pg_connection -power_net $PWR_NAME -power_pin $PWR_NAME -ground_net $GND_NAME -ground_pin $GND_NAME
derive_pg_connection -power_net $PWR_NAME -ground_net $GND_NAME -tie

# 设置电源/地轨约束并综合电源/地轨
set_fp_rail_constraints -add_layer  -layer M5 -direction horizontal -max_strap 4 -min_strap 2 -min_width 9 -max_width 18 -spacing 3
set_fp_rail_constraints -add_layer  -layer M6 -direction vertical -max_strap 4 -min_strap 2 -min_width 9 -max_width 18 -spacing 3
set_fp_rail_constraints  -set_ring -horizontal_ring_layer { M3 } -vertical_ring_layer { M4 } -ring_max_width 18 -ring_min_width 9 -extend_strap core_ring -ring_offset 40
set_fp_rail_constraints -set_global   -no_routing_over_hard_macros
synthesize_fp_rail  -nets {VDD GND} -voltage_supply 1.98 -synthesize_power_plan -power_budget 350 -pad_masters { PLVDDC PLVSSC }
commit_fp_rail




# 角落单元方向与位置设置
set_attribute [get_cells -all corner_ul] orientation {FS}
set_attribute [get_cells -all corner_ur] orientation {FE}
set_attribute [get_cells -all corner_lr] orientation {W}
set_attribute [get_cells -all corner_ll] orientation {FW}

set_attribute [get_cells -all corner_ul] origin {0.000 2191.160}
set_attribute [get_cells -all corner_ur] origin {2193.380 2191.160}
set_attribute [get_cells -all corner_lr] origin {2193.380 0.000}
set_attribute [get_cells -all corner_ll] origin {0.000 0.000}

save_mw_cel -as post_commit_fp_rail

# 将实例中的引脚连接到电源和地目标  忽略cover_cells 跳过那些接触焊盘侧边界的焊盘引脚
preroute_instances -ignore_cover_cells -skip_pad_pins_touching_pad_side_boundaries
# 将标准单元的电源和地引脚连接到电源和地环及电源地条带上。连接标准单元内的电源和地轨。
# -fill_empty_rows 在所有行（即使没有单元的行）中填充电源和地轨。
# -remove_floating_pieces 移除浮空、未连接的电源轨段。
preroute_standard_cells -fill_empty_rows -remove_floating_pieces

# 预测电源网格（PG Mesh）的稳健性，检查是否会出现严重的电压降（IR Drop）或电磁迁移（EM）问题
analyze_fp_rail  -nets {VDD GND} -voltage_supply 1.98 -power_budget 350 -pad_masters { PLVDDC PLVSSC }

# -complete：将指定的 PNET（电源条带/环等）视为完全阻挡（Complete Blockage）。
# 这意味着布局工具在放置标准单元时，严禁单元与这些金属层上的电源线产生任何重叠。
# "M5 M6"：指定该约束应用于金属第 5 层（Metal 5）和金属第 6 层（Metal 6）
set_pnet_options -complete "M5 M6"

# 放置硬宏单元和叶单元
# -timing_driven 启用时序驱动的布局模式
# -no_hierarchy_gravity 忽略逻辑层次结构，不再强制将同一模块的单元聚拢
create_fp_placement -timing_driven -no_hierarchy_gravity

# 使用Zroute对设计执行全局布线
route_zrt_global

# 时序分析 
report_timing

# 保存设计
save_mw_cel -as floorplanned

# 移除所有标准单元（Standard Cells）的放置信息
# 输出def
remove_placement -object_type standard_cell
write_def -version 5.6 -placed -all_vias -blockages  -routed_nets -specialnets -rows_tracks_gcells -output design_data/aes_ASIC.def

close_mw_lib

#if 2nd
#read_def design_data/aes_ASIC.def
#set_pnet_options -complete "M5 M6"