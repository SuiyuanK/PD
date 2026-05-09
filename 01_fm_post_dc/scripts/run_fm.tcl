date
set_app_var synopsys_auto_setup true

# FMR_ELAB-147 索引可能超出数组边界，可能导致仿真不匹配
# set_mismatch_message_filter -warn FMR_ELAB-147

#  BINARY:X：默认值。将参考设计中的未驱动引脚和网络视为 BINARY，实现
#          设计中的视为 X。如果任何匹配的参考比较点受到任何未驱动信号的控制，
#          此值会导致验证失败。
# 0:X：将参考设计中的未驱动引脚和网络视为 0，实现设计中的视为 X
#          （确保参考设计中的未驱动信号在实现中连接到 0）。
# set_app_var verification_set_undriven_signals 0:X

# 未解析的 Verilog 和 VHDL 设计引用将被转换为黑盒
# set_app_var hdlin_unresolved_modules black_box

# 使用此变量可使 source 命令在搜索文件时使用 search_path 变量
# set_app_var sh_source_uses_search_path true

set TOPDIR                      [sh pwd]
# Define RTL source files directory
set rtlDir                      [getenv rtlDir]
set TOP_MODULE                  [getenv TOP_MODULE]       
set netlistDir                  [getenv netlistDir]
set svfDir                      [getenv svfDir]


set_svf ${svfDir}/${TOP_MODULE}.svf
#这里的lib 从dc的ss换成了tt max换成了typ

read_db [list   ${TOPDIR}/data/lib/scc40nll_vhsc40_hvt_tt_v1p1_25c_basic.db    \
                ${TOPDIR}/data/lib/scc40nll_vhsc40_lvt_tt_v1p1_25c_basic.db    \
                ${TOPDIR}/data/lib/scc40nll_vhsc40_rvt_tt_v1p1_25c_basic.db    \
                ${TOPDIR}/data/lib/RAMSP128X16_tt_1p20v_1p20v_25c.db           \
                ${TOPDIR}/data/lib/RAMSP1024X16_tt_1p20v_1p20v_25c.db          \
                ${TOPDIR}/data/lib/RAMSP2048X16_tt_1p20v_1p20v_25c.db          \
                ${TOPDIR}/data/lib/RAMSP4096X16_tt_1p20v_1p20v_25c.db          \
                ${TOPDIR}/data/lib/RAMTP128X16_tt_1p20v_1p20v_25c.db           \
                ${TOPDIR}/data/lib/RAMTP1024X16_tt_1p20v_1p20v_25c.db          \
                ${TOPDIR}/data/lib/SP40NLLD2RN_3P3V_V0p4_tt_V1p10_25C.db   ]


read_verilog -r -vcs "-f ${rtlDir}/rtl_verilog.list"
# 如果有sv
# read_sverilog -r -vcs "-f ${rtlDir}/rtl_sverilog.list"
set_top r:/WORK/${TOP_MODULE}

read_verilog -i ${netlistDir}/${TOP_MODULE}.v
set_top i:/WORK/${TOP_MODULE}

match

if { [verify] } {
	date
	exit
} else {
    date
    # 对最近一次失败的验证运行诊断。默认情况下，此命令诊断实现设计。
  	diagnose
        report_unmatched
        report_failing
        report_error_candidates
    exit
}


