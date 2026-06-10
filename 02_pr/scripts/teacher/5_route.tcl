
# 打开Milkyway物理库
open_mw_lib aes_ASIC.mw
# 基于时钟树综合后的单元(clock_opt_route)创建一个新的信号布线阶段单元(signal_route)
copy_mw_cel -from clock_opt_route -to signal_route
open_mw_cel signal_route

# 列出当前加载的逻辑库和物理库
list_libs
# 加载通用的设计和优化设置脚本
source scripts/common_setup.tcl
source scripts/common_optimization_settings_icc.tcl
source scripts/common_placement_settings.tcl
source scripts/common_post_cts_timing_settings.tcl
source scripts/common_route_si_settings_zrt_icc.tcl

# 检查理想网络 (Ideal Nets)
# 理想网络的时序不真实，如果在route_opt之前存在，可能会导致工具优化错误
#Check for Ideal Nets
set num_ideal [sizeof_collection [all_ideal_nets]]
if {$num_ideal >= 1} {echo "SCRIPT-Error-Info: $num_ideal Nets are ideal prior to route_opt. Please investigate."}

# 检查高扇出网络 (High Fanout Nets, HFNs)
# 扇出过高的网络可能需要插入缓冲树(Buffer Tree)来改善时序和解决DRC限制
##Check for HFNs
set hfn_thres "41 101 501"
foreach thres $hfn_thres {
  set num_hfn [sizeof_collection [all_high_fanout -nets -threshold $thres]]
  echo "RM-Info: Number of nets with fanout > $thres = $num_hfn"
  if {$thres == 501 && $num_hfn >=1} {
    echo "RM-Error: $num_hfn Nets with fanout > 500 exist prior to route_opt - Please check if marked ideal - possibly add buffer tree"
  }
}

# 报告所有的设计约束违规情况
report_constraint -all

# 报告首选布线方向及RC寄生参数提取使用的TLU+文件
report_preferred_routing_direction
report_tlu_plus_files

#检查当前布局的合法性并验证电源地(PG)网络连通性
check_legality -verbose
verify_pg_nets

# 自定义布线规则：冻结特定网络(如POS_E3V)，禁止工具对其进行重新布线
set_net_routing_rule -reroute freeze -rule default  [get_nets POS_E3V]

# 创建布线引导区/阻塞区 (Route Guide / Blockage)
# 防止特定金属层或通道在这些特定坐标区域内进行信号布线
create_route_guide -coordinate {{0 0} {116.9 2193.8}} -no_signal_layers  {M1 V1 M2 V2 M3 V3 M4 V4 M5 V5 M6} -no_preroute_layers  {GT M1 M2 M3 M4 M5 M6 } 
create_route_guide -coordinate {{2076.9 0} {2193.8 2193.8}} -no_signal_layers   {M1 V1 M2 V2 M3 V3 M4 V4 M5 V5 M6} -no_preroute_layers {GT M1 M2 M3 M4 M5 M6 } 
create_route_guide -coordinate {{116.9 2076.9} {2076.9 2193.8}} -no_signal_layers   {M1 V1 M2 V2 M3 V3 M4 V4 M5 V5 M6}  -no_preroute_layers  {GT M1 M2 M3 M4 M5 M6 } 
create_route_guide -coordinate {{116.9 0} {2076.9 116.9}} -no_signal_layers   {M1 V1 M2 V2 M3 V3 M4 V4 M5 V5 M6}  -no_preroute_layers  {GT M1 M2 M3 M4 M5 M6 } 

# 配置Zroute引擎细节布线与全局布线的优化参数
# 开启冗余过孔(Redundant Via)高强度插入，改善良率
set_route_zrt_common_options   	-post_detail_route_redundant_via_insertion high
set_route_zrt_detail_options   	-optimize_wire_via_effort_level medium
set_route_zrt_common_options 	  -read_user_metal_blockage_layer true
set_route_zrt_common_options    -verbose_level 2

report_routing_rules; # report routing rules
report_route_opt_strategy; # report route_opt_stretegy
report_route_zrt_common_options; # Reports zrt common route options
report_route_zrt_global_options; # Reports zrt global route options
report_route_zrt_track_options; # Reports zrt route track assignment options
report_route_zrt_detail_options; # Reports zrt detail route options

# 预布线 (Preroute): 自动连接实例化器件(Instance)、宏单元或标准单元的电源和地
#preroute_instances -ignore_pads -ignore_macros -ignore_cover_cells -skip_pad_pins_touching_pad_side_boundaries
preroute_instances -ignore_pads -ignore_macros -ignore_cover_cells
# 移除预布线过程中产生的多余连线(float)
preroute_standard_cells -remove_floating_pieces
verify_pg_nets

# 执行物理层面前期检查，确认设计已经准备好进行自动布线 (Route Opt)
check_physical_design  -stage pre_route_opt

save_mw_cel -as before_route_opt

# 初始布线阶段：进行全局布线(Global Route)和详细布线(Detail Route)连通所有的网络，暂不进行强硬的时序优化
route_opt -initial_route_only

# 布线后快速检查时钟树特性、时序偏差(skew)以及总体的QoR(性能、面积、功耗结果)
report_clock_tree -summary
report_clock_timing -type skew
report_qor
report_constraint -all

# 布线后优化(Post-route Optimization)：主要修复线长、串扰、时序和功耗DRC等问题
route_opt -skip_initial_route  -power

# 因为优化的过程中可能会增加新的缓冲器或改变单元位置，要重新确认和连接它们的电源地
derive_pg_connection -power_net $PWR_NAME -power_pin $PWR_NAME -ground_net $GND_NAME -ground_pin $GND_NAME
derive_pg_connection -power_net $PWR_NAME -ground_net $GND_NAME -tie

# 最终验证布线规则连通性
verify_zrt_route

# 报告路由的物理设计属性与统计结果
report_design_physical -route

save_mw_cel -as route_opt_final

close_mw_lib