### input data
set top_name    "image_icb"
set netlist     "../../../eco/outputs/${top_name}.v.gz"
set sdc         "../../data/${top_name}.tcl"
set spef        "../../starrc/cmin_125c/image_icb.cmin_125c.spef.gz"
set 40NM_dir    "/mnt/hgfs/Em/40NM"

### link design


lappend link_path \
${40NM_dir}/S40/smic/SCC40NLL_VHSC40_HVT_V0.1/SCC40NLL_VHSC40_HVT_V0p1/liberty/1.1v/scc40nll_vhsc40_hvt_ss_v0p99_125c_ccs.db \
${40NM_dir}/S40/smic/SCC40NLL_VHSC40_LVT_V0.1/SCC40NLL_VHSC40_LVT_V0p1/liberty/1.1v/scc40nll_vhsc40_lvt_ss_v0p99_125c_ccs.db \
${40NM_dir}/S40/smic/SCC40NLL_VHSC40_RVT_V0.1/SCC40NLL_VHSC40_RVT_V0p1/liberty/1.1v/scc40nll_vhsc40_rvt_ss_v0p99_125c_ccs.db \
${40NM_dir}/S40/smic/SP40NLLD2RN_3P3V_V0p4/syn/3p3v/SP40NLLD2RN_3P3V_V0p4_ss_V0p99_125C.db \
${40NM_dir}/SRAM_Lib/RAMSP128X16/db/RAMSP128X16_ss_0p99v_0p99v_125c.db \
${40NM_dir}/SRAM_Lib/RAMSP1024X16/db/RAMSP1024X16_ss_0p99v_0p99v_125c.db \
${40NM_dir}/SRAM_Lib/RAMSP2048X16/db/RAMSP2048X16_ss_0p99v_0p99v_125c.db \
${40NM_dir}/SRAM_Lib/RAMSP4096X16/db/RAMSP4096X16_ss_0p99v_0p99v_125c.db \
${40NM_dir}/SRAM_Lib/RAMTP128X16/db/RAMTP128X16_ss_0p99v_0p99v_125c.db \
${40NM_dir}/SRAM_Lib/RAMTP1024X16/db/RAMTP1024X16_ss_0p99v_0p99v_125c.db 


read_verilog ${netlist}
current_design ${top_name}
link_design

### read spef
read_parasitic ${spef}

### set constraint
source -e ${sdc}
# max transition已经设置了
set_max_capacitance -clock_path 1.5 [get_clocks ] 
set_max_capacitance -data_path 1.5 [get_clocks ] 
set_max_fanout 32 [current_design]

### update timing
set_propagated_clock [all_clocks]
set_false_path -to [all_outputs]
set_false_path -from [all_inputs]
update_timing

### report
report_global_timing > ./rpts/timing.sum
report_timing -nosplit -input_pins -significant_digits 3 -nets -slack_lesser_than 0 -max_paths 9999 > ./rpts/timing.rpt
report_constraint -max_transition -all_violators  -significant_digits 3 -nosplit  >  ./rpts/tran.rpt
report_constraint -max_capacitance -all_violators  -significant_digits 3 -nosplit  >  ./rpts/cap.rpt
report_constraint -max_fanout -all_violators  -significant_digits 3 -nosplit  >  ./rpts/fanout.rpt

### save

save_session func.ss0p99v.cmin_125c




exit