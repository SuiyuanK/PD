### design information
set design              "image_process"

### gate level netlist files
set import_netlist      ""
lappend import_netlist  "data/${design}.v"

### scandef
set scandef_file        ""

### sdc files
set import_sdc          ""
lappend import_sdc      "data/${design}.sdc"

### upf files
set golden_upf          ""

### tech files
set tech_tf             "data/techfile/milkyway/1P9M_2TM/sc12mc_tech.tf"

### ndm files
set ndm_files           ""
lappend ndm_files       "data/lib/ndm/scc40nll_vhsc40_hvt.ndm"
lappend ndm_files       "data/lib/ndm/scc40nll_vhsc40_lvt.ndm"
lappend ndm_files       "data/lib/ndm/scc40nll_vhsc40_rvt.ndm"
lappend ndm_files       "data/lib/ndm/SP40NLLD2RN_3P3V_V0p4.ndm"
lappend ndm_files       "data/lib/ndm/sram/RAMSP128X16.ndm"
lappend ndm_files       "data/lib/ndm/sram/RAMSP1024X16.ndm"
lappend ndm_files       "data/lib/ndm/sram/RAMSP2048X16.ndm"
lappend ndm_files       "data/lib/ndm/sram/RAMSP4096X16.ndm"
lappend ndm_files       "data/lib/ndm/sram/RAMTP128X16.ndm"
lappend ndm_files       "data/lib/ndm/sram/RAMTP1024X16.ndm"

### mapping files
set mapping_file        "data/techfile/milkyway/1P9M_2TM/stream_out_layer_map"


### lef files
set lef_files           ""
lappend lef_files       "data/lef/scc40nll_9lm_2tm.lef"
lappend lef_files       "data/lef/scc40nll_vhsc40_hvt_ant.lef"
lappend lef_files       "data/lef/scc40nll_vhsc40_lvt_ant.lef"
lappend lef_files       "data/lef/scc40nll_vhsc40_rvt_ant.lef"
lappend lef_files       "data/lef/SP40NLLD2RN_3P3V_V0p1_9MT_2TM.lef"
lappend lef_files       "data/lef/sram/RAMSP128X16.lef"
lappend lef_files       "data/lef/sram/RAMSP1024X16.lef"
lappend lef_files       "data/lef/sram/RAMSP2048X16.lef"
lappend lef_files       "data/lef/sram/RAMSP4096X16.lef"
lappend lef_files       "data/lef/sram/RAMTP128X16.lef"
lappend lef_files       "data/lef/sram/RAMTP1024X16.lef"

### PEX tech
set starrc_tech(cmax)       ""
set starrc_tech(cmin)       ""
set starrc_tech(normal)     ""
set icc2rc_tech(cmax)       "data/techfile/synopsys_tluplus/1P9M_2TM/CMAX.tluplus"
set icc2rc_tech(cmin)       "data/techfile/synopsys_tluplus/1P9M_2TM/CMIN.tluplus"
set icc2rc_tech(normal)     "data/techfile/synopsys_tluplus/1P9M_2TM/TYP.map"
set itf_tluplus_map         "data/techfile/synopsys_tluplus/1P9M_2TM/tluplus.map"

#### scenarios of each step
set default_scenarios       "func_ss0p99v125c_cmax"
set placeopt_scenarios      "func_ss0p99v125c_cmax test_ss0p99v125c_cmax"
set cts_scenarios           "cts_ss0p99v125c_cmax"
set clockopt_scenarios      "func_ss0p99v125c_cmax test_ss0p99v125c_cmax func_ff1p21vm40c_cmin test_ff1p21v125c_cmin"
set routeopt_scenarios      "func_ss0p99v125c_cmax test_ss0p99v125c_cmax func_ff1p21vm40c_cmin test_ff1p21v125c_cmin"

### cells type settings
# filler from big to small
set fillers_ref             "*/F_FILL128_12TH40 */F_FILL64_12TH40 */F_FILL32_12TH40 */F_FILL16_12TH40 */F_FILL8_12TH40 */F_FILL4_12TH40 */F_FILL2_12TH40 */F_FILL1_12TH40"                            
set endcap_left             "*/F_FILL2_12TH40"
set endcap_right            "*/F_FILL2_12TH40"
set endcap_top              "*/F_FILL2_12TH40 */F_FILL1_12TH40"
set endcap_bottom           "*/F_FILL2_12TH40 */F_FILL1_12TH40"
set tapcell_ref             "*/FILLTIE3_12TH40"
set hold_fix_ref            "*/CLKBUFV10RQ_12TH40 */CLKBUFV10_12TH40 */CLKBUFV2_12TH40 */CLKBUFV3_12TH40 */CLKBUFV4RQ_12TH40 */CLKBUFV4_12TH40 */CLKBUFV5_12TH40 */CLKBUFV6RQ_12TH40 */CLKBUFV6_12TH40 */CLKBUFV7_12TH40 */CLKBUFV8RQ_12TH40 */CLKBUFV8_12TH40 */CLKBUFV10RQ_12TR40 */CLKBUFV10_12TR40 */CLKBUFV2_12TR40 */CLKBUFV3_12TR40 */CLKBUFV4RQ_12TR40 */CLKBUFV4_12TR40 */CLKBUFV5_12TR40 */CLKBUFV6RQ_12TR40 */CLKBUFV6_12TR40 */CLKBUFV7_12TR40 */CLKBUFV8RQ_12TR40 */CLKBUFV8_12TR40"
set cts_cells               "*/CLKBUFV10RQ_12TL40 */CLKBUFV10_12TL40 */CLKBUFV12RQ_12TL40 */CLKBUFV12_12TL40 */CLKBUFV16RQ_12TL40 */CLKBUFV16_12TL40 */CLKBUFV20RQ_12TL40 */CLKBUFV20_12TL40 */CLKBUFV24RQ_12TL40 */CLKBUFV24_12TL40 */CLKBUFV32_12TL40 */CLKBUFV4RQ_12TL40 */CLKBUFV4_12TL40 */CLKBUFV5_12TL40 */CLKBUFV6RQ_12TL40 */CLKBUFV6_12TL40 */CLKBUFV7_12TL40 */CLKBUFV8RQ_12TL40 */CLKBUFV8_12TL40 */CLKINV10_12TL40 */CLKINV12_12TL40 */CLKINV16_12TL40 */CLKINV20_12TL40 */CLKINV24_12TL40 */CLKINV32_12TL40 */CLKINV4_12TL40 */CLKINV5_12TL40 */CLKINV6_12TL40 */CLKINV7_12TL40 */CLKINV8_12TL40"
set decap_ref               "*/FDCAP128_12TH40 */FDCAP64_12TH40 */FDCAP32_12TH40 */FDCAP16_12TH40 */FDCAP8_12TH40 */FDCAP4_12TH40"
### nlib data dir
set nlib_dir                "nlib"

################################################
#END
################################################






