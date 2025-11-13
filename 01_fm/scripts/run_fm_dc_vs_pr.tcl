set_mismatch_message_filter -warn FMR_ELAB-147
set_app_var synopsys_auto_setup true
set_app_var verification_set_undriven_signals 0:X
# 启用8核（需系统支持，不超过许可证上限）
set_host_options -max_cores 8

set topModuleName       image_icb

set_svf ../data/${topModuleName}.svf
#这里的lib 从dc的ss换成了tt max换成了typ

read_db [list   ../data/lib/scc40nll_vhsc40_hvt_tt_v1p1_25c_basic.db    \
                ../data/lib/scc40nll_vhsc40_lvt_tt_v1p1_25c_basic.db    \
                ../data/lib/scc40nll_vhsc40_rvt_tt_v1p1_25c_basic.db    \
                ../data/lib/RAMSP128X16_tt_1p20v_1p20v_25c.db           \
                ../data/lib/RAMSP1024X16_tt_1p20v_1p20v_25c.db          \
                ../data/lib/RAMSP2048X16_tt_1p20v_1p20v_25c.db          \
                ../data/lib/RAMSP4096X16_tt_1p20v_1p20v_25c.db          \
                ../data/lib/RAMTP128X16_tt_1p20v_1p20v_25c.db           \
                ../data/lib/RAMTP1024X16_tt_1p20v_1p20v_25c.db          \
                ../data/lib/SP40NLLD2RN_3P3V_V0p4_tt_V1p10_25C.db   ]



read_verilog -r ../data/verilog/RAMSP1024X16.v
read_verilog -r ../data/verilog/RAMTP1024X16.v
read_verilog -r ../data/verilog/scc40nll_vhsc40_hvt.v
read_verilog -r ../data/verilog/scc40nll_vhsc40_lvt.v
read_verilog -r ../data/verilog/scc40nll_vhsc40_rvt.v
read_verilog -r ../data/${topModuleName}.v.gz
set_top r:/WORK/${topModuleName}

read_verilog -i ../data/${topModuleName}.v
set_top i:/WORK/${topModuleName}

verify

exit