###环境设置
# 低功耗和时钟门控优化设置
set_app_var pwr_cg_improved_cells_selection_for_remapping true
set_app_var compile_clock_gating_through_hierarchy true
set_app_var power_low_power_placement true
set_app_var power_cg_flatten false

###set syn env###
set topModuleName           conv                                                      
set data_path               "../data"                                      
set rtl_path                "../../../RTL"
set run_dir                 "../"

# set_app_var search_path     "$data_path"
# lappend search_path         "$rtl_path"
# 先删除可能存在的目录（-rf 强制删除目录及内容，即使目录不存在也不会报错）
file delete -force $run_dir/rpts 
file delete -force $run_dir/outputs 
file delete -force $run_dir/tmp_work

#创建目录
file mkdir -p $run_dir/rpts
file mkdir -p $run_dir/outputs
file mkdir -p $run_dir/outputs/ddc
file mkdir -p $run_dir/outputs/netlist
file mkdir -p $run_dir/outputs/sdf
file mkdir -p $run_dir/outputs/svf
file mkdir -p $run_dir/tmp_work


#记录dc在综合时采用的优化、复用、状态机重编码信息等等，供formality验证时使用。
set_svf  $run_dir/outputs/svf/$topModuleName.svf
# DC脚本中启用层次映射
set_app_var hdlin_enable_hier_map true


#指定设计和库的工作路径，放一些运行中的垃圾，临时目录
define_design_lib WORK -path $run_dir/tmp_work

###read library###

# stdcell
set stdcell_libs "
$data_path/lib/scc40nll_vhsc40_hvt_ss_v0p99_125c_basic.db
$data_path/lib/scc40nll_vhsc40_lvt_ss_v0p99_125c_basic.db
$data_path/lib/scc40nll_vhsc40_rvt_ss_v0p99_125c_basic.db"

# memory
set memory_libs "
$data_path/lib/RAMSP128X16_ss_0p90v_0p90v_125c.db
$data_path/lib/RAMSP1024X16_ss_0p90v_0p90v_125c.db
$data_path/lib/RAMSP2048X16_ss_0p90v_0p90v_125c.db
$data_path/lib/RAMSP4096X16_ss_0p90v_0p90v_125c.db
$data_path/lib/RAMTP128X16_ss_0p90v_0p90v_125c.db
$data_path/lib/RAMTP1024X16_ss_0p90v_0p90v_125c.db"

# iopad
set iopad_lib "
$data_path/lib/SP40NLLD2RN_3P3V_V0p4_ss_V0p99_125C.db"

#分页显示关闭
set enable_page_mode false

set_app_var target_library  "$stdcell_libs"
set_app_var link_library    "* $target_library $memory_libs $iopad_lib"



# ---------------------------read RTL from rtl.list----------------------------
set rtl_list_file "$rtl_path/rtl.list"
if {![file exists $rtl_list_file]} {
    puts "Error: rtl.list not found in $rtl_path"
    exit 1
}

set RTLFileList {}
set file_id [open $rtl_list_file r]
while {[gets $file_id line] != -1} {
    # 去除前后空格
    set line [string trim $line]
    # 跳过空行和以#开头的注释行
    if {[string length $line] == 0 || [string index $line 0] == "#"} {
        continue
    }
    lappend RTLFileList "$rtl_path/$line"
}
close $file_id

# 打印读取到的文件列表（可选）
puts "#++++++++++++++++++++++++++"
puts "RTL Files to be analyzed:"
foreach f $RTLFileList {
    puts $f
}
puts "#++++++++++++++++++++++++++"

foreach rtl_file $RTLFileList {
    set ext [file extension $rtl_file]
    if { $ext eq ".v" } {
        analyze -format verilog $rtl_file
    } elseif { $ext eq ".sv" } {
        analyze -format sverilog $rtl_file
    }
}

elaborate      $topModuleName                                                           
current_design $topModuleName

# This command is a part of the recommended Synopsys verification setup(SVF) creation flow.
set_verification_top 

# 链接，查看当前要综合的设计是否缺少子模块，返回值是1，说明子模块完整
link


## 设置约束文件
#读入设计约束
source $data_path/$topModuleName.tcl


#过滤源的类型为端口的clk
set ports_clock_root [filter_collection [get_attribute [get_clocks] sources] object_class==port]
#路径分组。-from -to 优先级最大，-from 次之，-to 优先级最小
group_path -name reg2out -to [all_outputs]
#来自除去clk之外的所有输入信号的路径
group_path -name in2reg -from [remove_from_collection [all_inputs] $ports_clock_root]
#除去clk之外的所有输入信号到所有输出信号的路径
group_path -name in2out -from [remove_from_collection [all_inputs] $ports_clock_root] \
-to [all_outputs]

# 动态功耗和漏电优化
set_dynamic_optimization true
set_leakage_optimization true


#综合并插入门控时钟单元
compile_ultra -gate_clock 

#为formality进行停止记录数据（形式验证）
set_svf -off

#因为DC和其它的XX命名规则不同，为了避免出现问题，在产生网表之前先要定义一些命名规则。
change_names -rules verilog -hierarchy

#保存综合后的设计
write -format ddc -hierarchy -output $run_dir/outputs/ddc/$topModuleName.ddc
#输出网表，自动布局布线需要
write -f verilog -hierarchy -output $run_dir/outputs/netlist/$topModuleName.v
#-version 2.1 兼容性更好 若设计涉及多工艺角（PVT）或先进工艺节点选3.0
#-version 2.1
write_sdf $run_dir/outputs/sdf/$topModuleName.sdf

#****************************************************
# Reporting
#****************************************************    
report_design     -nosplit >                $run_dir/rpts/$topModuleName.design.rpt
report_timing     -nosplit >                $run_dir/rpts/$topModuleName.timing.rpt
report_area       -nosplit >                $run_dir/rpts/$topModuleName.area.rpt
report_power      -nosplit >                $run_dir/rpts/$topModuleName.power.rpt
report_constraint -nosplit -all_violators > $run_dir/rpts/$topModuleName.constraint.rpt
report_port       -nosplit >                $run_dir/rpts/$topModuleName.port.rpt
report_net        -nosplit >                $run_dir/rpts/$topModuleName.net.rpt

check_design  >                             $run_dir/rpts/$topModuleName.check_design.rpt
check_timing  >                             $run_dir/rpts/$topModuleName.check_timing.rpt


##++++++++++++++++++++++++
# THE END
#++++++++++++++++++++++++
set flag [sizeof_collection [get_cells -hier -filter "is_unmapped==true"]]
if {$flag == 0} {
  puts "--------Synthesis Complete!--------"
} else {
  puts "--------Synthesis Failed!----------"
}

exit


