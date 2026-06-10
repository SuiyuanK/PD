# ============================================================================
# 短路修复 (Fix Short Circuit Violations)
# 功能: 检测并修复 DRC 短路错误、局部重新路由优化
# ============================================================================

# 检查是否存在 Short 类型的 DRC 错误
if {[regexp "Short" [list_drc_error_types]]} {

  # 获取所有 Short 类型的 DRC 错误对象
  set short_errs [get_drc_errors -type Short]

  # 从 DRC 错误中提取受影响的网络
  set short_nets [get_nets [get_attribute $short_errs nets]]

  # 打印需要修复的网络数量
  puts "Info: remove routing for nets no: [sizeof_collection $short_nets]"

  # 移除这些网络的路由信息，准备重新路由
  remove_net_routing $short_nets

  # 使用 ECO 路由模式重新路由这些网络，修复短路错误
  route_zrt_eco -nets $short_nets

}