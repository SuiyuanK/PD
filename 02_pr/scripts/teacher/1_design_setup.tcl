# 设置4核 并删除旧设计
set_host_options -max_cores 4
file delete -force $my_mw_lib

# 创建 Milkyway 设计库并加载工艺文件
create_mw_lib $my_mw_lib -open -technology $tech_file \
	-mw_reference_library "../lib/SMIC18_Ver2.7/BEView_STDIO/STD/Apollo/SMIC18STDLIBM6 \ 
	../lib/SMIC18_Ver2.7/BEView_STDIO/IO/Apollo/SMIC18IOLIB_L_M6"  -bus_naming_style {[%d]}

#set_check_library_options -all
#check_library

# 导入网表
import_designs $verilog_file \
	-format verilog \
	-top $top_design
if { [check_error -verbose] != 0} { echo "import_designs Error, flagging ..." }

# 加载 TLU+ 文件用于寄生参数
set_tlu_plus_files \
	-max_tluplus $tlup_max \
	-min_tluplus $tlup_min \
	-tech2itf_map  $tlup_map
check_tlu_plus_files

# 检查是否成功创建库
list_libs
check_library

# 推导电源/地连接 
derive_pg_connection -power_net $PWR_NAME -power_pin $PWR_NAME -ground_net $GND_NAME -ground_pin $GND_NAME
derive_pg_connection -power_net $PWR_NAME -ground_net $GND_NAME -tie

# 检查电源/地连接 
check_mv_design -power_nets

# 读入 SDC 约束与时序检查
read_sdc $sdc_file
check_timing

# 报告时序路径的需求
report_timing_requirements 
# 报告当前设计中被禁用的时序弧（Timing Arcs）
# 如果一条时序弧被禁用，意味着时序分析引擎将不再计算经过该路径的延迟，
# 也不会在该路径上检查建立时间（Setup）或保持时间（Hold）
report_disable_timing
# 报告设计中端口（Ports）或引脚（Pins）上的个案分析（Case Analysis）设置情况
report_case_analysis

# 显示设计中所有已定义时钟的配置信息、物理属性以及它们之间的关系
# -skew 主要报告的是由 set_clock_uncertainty 命令手动设置的“虚拟”偏移或不确定度值。
report_clock
report_clock -skew

# 读入opt_ctrl.tcl文件，配置相关设置
source $ctrl_file

# 零互连延迟理想化时序分析
source scripts/zic_timing.tcl

# 保存设计
save_mw_cel -as setuped
close_mw_lib