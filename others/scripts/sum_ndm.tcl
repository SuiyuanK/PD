set lef_site_name   sc9mc_logic0040ll
set mdb_site_name   unit
set 40NM_dir        /mnt/hgfs/Em/40NM
# workspace scc40nll_vhsc40_hvt_ff_v1p21_c_ccs:
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc9mc_tech.tf scc40nll_vhsc40_hvt_ff_v1p21_c_ccs
reset_app_options lib.workspace.allow_missing_related_pg_pins
reset_app_options lib.logic_model.auto_remove_timing_only_designs
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_HVT_V0.1/SCC40NLL_VHSC40_HVT_V0p1/liberty/1.1v/scc40nll_vhsc40_hvt_ff_v1p21_125c_ccs.db
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_HVT_V0.1/SCC40NLL_VHSC40_HVT_V0p1/liberty/1.1v/scc40nll_vhsc40_hvt_ff_v1p21_-40c_ccs.db
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}} ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_HVT_V0.1/SCC40NLL_VHSC40_HVT_V0p1/lef/macro/scc40nll_vhsc40_hvt_ant.lef
set_app_options -name lib.logic_model.auto_remove_timing_only_designs -value true
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true
check_workspace
commit_workspace -output ./scc40nll_vhsc40_hvt_ff_v1p21_c_ccs.ndm
remove_workspace
# workspace scc40nll_vhsc40_hvt_ss_v0p99_c_ccs:
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc9mc_tech.tf scc40nll_vhsc40_hvt_ss_v0p99_c_ccs
reset_app_options lib.workspace.allow_missing_related_pg_pins
reset_app_options lib.logic_model.auto_remove_timing_only_designs
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_HVT_V0.1/SCC40NLL_VHSC40_HVT_V0p1/liberty/1.1v/scc40nll_vhsc40_hvt_ss_v0p99_125c_ccs.db
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_HVT_V0.1/SCC40NLL_VHSC40_HVT_V0p1/liberty/1.1v/scc40nll_vhsc40_hvt_ss_v0p99_-40c_ccs.db
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}} ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_HVT_V0.1/SCC40NLL_VHSC40_HVT_V0p1/lef/macro/scc40nll_vhsc40_hvt_ant.lef
set_app_options -name lib.logic_model.auto_remove_timing_only_designs -value true
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true
check_workspace
commit_workspace -output ./scc40nll_vhsc40_hvt_ss_v0p99_c_ccs.ndm
remove_workspace
# workspace scc40nll_vhsc40_hvt_tt_v1p1_25c_ccs:
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc9mc_tech.tf scc40nll_vhsc40_hvt_tt_v1p1_25c_ccs
reset_app_options lib.workspace.allow_missing_related_pg_pins
reset_app_options lib.logic_model.auto_remove_timing_only_designs
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_HVT_V0.1/SCC40NLL_VHSC40_HVT_V0p1/liberty/1.1v/scc40nll_vhsc40_hvt_tt_v1p1_125c_ccs.db
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_HVT_V0.1/SCC40NLL_VHSC40_HVT_V0p1/liberty/1.1v/scc40nll_vhsc40_hvt_tt_v1p1_25c_ccs.db
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}} ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_HVT_V0.1/SCC40NLL_VHSC40_HVT_V0p1/lef/macro/scc40nll_vhsc40_hvt_ant.lef
set_app_options -name lib.logic_model.auto_remove_timing_only_designs -value true
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true
check_workspace
commit_workspace -output ./scc40nll_vhsc40_hvt_tt_v1p1_25c_ccs.ndm
remove_workspace
# workspace scc40nll_vhsc40_lvt_ff_v1p21_c_ccs:
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc9mc_tech.tf scc40nll_vhsc40_lvt_ff_v1p21_c_ccs
reset_app_options lib.workspace.allow_missing_related_pg_pins
reset_app_options lib.logic_model.auto_remove_timing_only_designs
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_LVT_V0.1/SCC40NLL_VHSC40_LVT_V0p1/liberty/1.1v/scc40nll_vhsc40_lvt_ff_v1p21_125c_ccs.db
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_LVT_V0.1/SCC40NLL_VHSC40_LVT_V0p1/liberty/1.1v/scc40nll_vhsc40_lvt_ff_v1p21_-40c_ccs.db
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}} ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_LVT_V0.1/SCC40NLL_VHSC40_LVT_V0p1/lef/macro/scc40nll_vhsc40_lvt_ant.lef
set_app_options -name lib.logic_model.auto_remove_timing_only_designs -value true
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true
check_workspace
commit_workspace -output ./scc40nll_vhsc40_lvt_ff_v1p21_c_ccs.ndm
remove_workspace
# workspace scc40nll_vhsc40_lvt_ss_v0p99_c_ccs:
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc9mc_tech.tf scc40nll_vhsc40_lvt_ss_v0p99_c_ccs
reset_app_options lib.workspace.allow_missing_related_pg_pins
reset_app_options lib.logic_model.auto_remove_timing_only_designs
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_LVT_V0.1/SCC40NLL_VHSC40_LVT_V0p1/liberty/1.1v/scc40nll_vhsc40_lvt_ss_v0p99_125c_ccs.db
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_LVT_V0.1/SCC40NLL_VHSC40_LVT_V0p1/liberty/1.1v/scc40nll_vhsc40_lvt_ss_v0p99_-40c_ccs.db
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}} ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_LVT_V0.1/SCC40NLL_VHSC40_LVT_V0p1/lef/macro/scc40nll_vhsc40_lvt_ant.lef
set_app_options -name lib.logic_model.auto_remove_timing_only_designs -value true
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true
check_workspace
commit_workspace -output ./scc40nll_vhsc40_lvt_ss_v0p99_c_ccs.ndm
remove_workspace
# workspace scc40nll_vhsc40_lvt_tt_v1p1_25c_ccs:
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc9mc_tech.tf scc40nll_vhsc40_lvt_tt_v1p1_25c_ccs
reset_app_options lib.workspace.allow_missing_related_pg_pins
reset_app_options lib.logic_model.auto_remove_timing_only_designs
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_LVT_V0.1/SCC40NLL_VHSC40_LVT_V0p1/liberty/1.1v/scc40nll_vhsc40_lvt_tt_v1p1_125c_ccs.db
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_LVT_V0.1/SCC40NLL_VHSC40_LVT_V0p1/liberty/1.1v/scc40nll_vhsc40_lvt_tt_v1p1_25c_ccs.db
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}} ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_LVT_V0.1/SCC40NLL_VHSC40_LVT_V0p1/lef/macro/scc40nll_vhsc40_lvt_ant.lef
set_app_options -name lib.logic_model.auto_remove_timing_only_designs -value true
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true
check_workspace
commit_workspace -output ./scc40nll_vhsc40_lvt_tt_v1p1_25c_ccs.ndm
remove_workspace
# workspace scc40nll_vhsc40_rvt_ff_v1p21_c_ccs:
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc9mc_tech.tf scc40nll_vhsc40_rvt_ff_v1p21_c_ccs
reset_app_options lib.workspace.allow_missing_related_pg_pins
reset_app_options lib.logic_model.auto_remove_timing_only_designs
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_RVT_V0.1/SCC40NLL_VHSC40_RVT_V0p1/liberty/1.1v/scc40nll_vhsc40_rvt_ff_v1p21_125c_ccs.db
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_RVT_V0.1/SCC40NLL_VHSC40_RVT_V0p1/liberty/1.1v/scc40nll_vhsc40_rvt_ff_v1p21_-40c_ccs.db
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}} ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_RVT_V0.1/SCC40NLL_VHSC40_RVT_V0p1/lef/macro/scc40nll_vhsc40_rvt_ant.lef
set_app_options -name lib.logic_model.auto_remove_timing_only_designs -value true
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true
check_workspace
commit_workspace -output ./scc40nll_vhsc40_rvt_ff_v1p21_c_ccs.ndm
remove_workspace
# workspace scc40nll_vhsc40_rvt_ss_v0p99_c_ccs:
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc9mc_tech.tf scc40nll_vhsc40_rvt_ss_v0p99_c_ccs
reset_app_options lib.workspace.allow_missing_related_pg_pins
reset_app_options lib.logic_model.auto_remove_timing_only_designs
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_RVT_V0.1/SCC40NLL_VHSC40_RVT_V0p1/liberty/1.1v/scc40nll_vhsc40_rvt_ss_v0p99_125c_ccs.db
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_RVT_V0.1/SCC40NLL_VHSC40_RVT_V0p1/liberty/1.1v/scc40nll_vhsc40_rvt_ss_v0p99_-40c_ccs.db
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}} ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_RVT_V0.1/SCC40NLL_VHSC40_RVT_V0p1/lef/macro/scc40nll_vhsc40_rvt_ant.lef
set_app_options -name lib.logic_model.auto_remove_timing_only_designs -value true
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true
check_workspace
commit_workspace -output ./scc40nll_vhsc40_rvt_ss_v0p99_c_ccs.ndm
remove_workspace
# workspace scc40nll_vhsc40_rvt_tt_v1p1_25c_ccs:
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc9mc_tech.tf scc40nll_vhsc40_rvt_tt_v1p1_25c_ccs
reset_app_options lib.workspace.allow_missing_related_pg_pins
reset_app_options lib.logic_model.auto_remove_timing_only_designs
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_RVT_V0.1/SCC40NLL_VHSC40_RVT_V0p1/liberty/1.1v/scc40nll_vhsc40_rvt_tt_v1p1_125c_ccs.db
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_RVT_V0.1/SCC40NLL_VHSC40_RVT_V0p1/liberty/1.1v/scc40nll_vhsc40_rvt_tt_v1p1_25c_ccs.db
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}} ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_RVT_V0.1/SCC40NLL_VHSC40_RVT_V0p1/lef/macro/scc40nll_vhsc40_rvt_ant.lef
set_app_options -name lib.logic_model.auto_remove_timing_only_designs -value true
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true
check_workspace
commit_workspace -output ./scc40nll_vhsc40_rvt_tt_v1p1_25c_ccs.ndm
remove_workspace
# workspace SP40NLLD2RN_3P3V_V0p4_ff_V1p21_C:
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc9mc_tech.tf SP40NLLD2RN_3P3V_V0p4_ff_V1p21_C
reset_app_options lib.workspace.allow_missing_related_pg_pins
reset_app_options lib.logic_model.auto_remove_timing_only_designs
read_db ${40NM_dir}/S40/smic/SP40NLLD2RN_3P3V_V0p4/syn/3p3v/SP40NLLD2RN_3P3V_V0p4_ff_V1p21_125C.db
read_db ${40NM_dir}/S40/smic/SP40NLLD2RN_3P3V_V0p4/syn/3p3v/SP40NLLD2RN_3P3V_V0p4_ff_V1p21_-40C.db
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}} ${40NM_dir}/S40/smic/SP40NLLD2RN_3P3V_V0p4/lef/SP40NLLD2RN_3P3V_V0p1_8MT_2TM.lef
set_app_options -name lib.logic_model.auto_remove_timing_only_designs -value true
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true
check_workspace
commit_workspace -output ./SP40NLLD2RN_3P3V_V0p4_ff_V1p21_C.ndm
remove_workspace
# workspace SP40NLLD2RN_3P3V_V0p4_ss_V0p99_C:
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc9mc_tech.tf SP40NLLD2RN_3P3V_V0p4_ss_V0p99_C
reset_app_options lib.workspace.allow_missing_related_pg_pins
reset_app_options lib.logic_model.auto_remove_timing_only_designs
read_db ${40NM_dir}/S40/smic/SP40NLLD2RN_3P3V_V0p4/syn/3p3v/SP40NLLD2RN_3P3V_V0p4_ss_V0p99_125C.db
read_db ${40NM_dir}/S40/smic/SP40NLLD2RN_3P3V_V0p4/syn/3p3v/SP40NLLD2RN_3P3V_V0p4_ss_V0p99_-40C.db
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}} ${40NM_dir}/S40/smic/SP40NLLD2RN_3P3V_V0p4/lef/SP40NLLD2RN_3P3V_V0p1_8MT_2TM.lef
set_app_options -name lib.logic_model.auto_remove_timing_only_designs -value true
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true
check_workspace
commit_workspace -output ./SP40NLLD2RN_3P3V_V0p4_ss_V0p99_C.ndm
remove_workspace
# workspace SP40NLLD2RN_3P3V_V0p4_tt_V1p10_25C:
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc9mc_tech.tf SP40NLLD2RN_3P3V_V0p4_tt_V1p10_25C
reset_app_options lib.workspace.allow_missing_related_pg_pins
reset_app_options lib.logic_model.auto_remove_timing_only_designs
read_db ${40NM_dir}/S40/smic/SP40NLLD2RN_3P3V_V0p4/syn/3p3v/SP40NLLD2RN_3P3V_V0p4_tt_V1p10_25C.db
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}} ${40NM_dir}/S40/smic/SP40NLLD2RN_3P3V_V0p4/lef/SP40NLLD2RN_3P3V_V0p1_8MT_2TM.lef
set_app_options -name lib.logic_model.auto_remove_timing_only_designs -value true
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true
check_workspace
commit_workspace -output ./SP40NLLD2RN_3P3V_V0p4_tt_V1p10_25C.ndm
remove_workspace

set lib_dir_name  	RAMSP128X16
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc9mc_tech.tf ${lib_dir_name}_ff_1p_c
reset_app_options lib.workspace.allow_missing_related_pg_pins
reset_app_options lib.logic_model.auto_remove_timing_only_designs
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p10v_1p10v_125c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p21v_1p21v_125c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p26v_1p26v_125c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p10v_1p10v_m40c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p21v_1p21v_m40c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p26v_1p26v_m40c.db
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}} ${40NM_dir}/SRAM_Lib/${lib_dir_name}/lef/${lib_dir_name}.lef
set_app_options -name lib.logic_model.auto_remove_timing_only_designs -value true
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true
check_workspace
commit_workspace -output ./${lib_dir_name}_ff_1p_c.ndm
remove_workspace

set lib_dir_name  	RAMSP1024X16
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc9mc_tech.tf ${lib_dir_name}_ff_1p_c
reset_app_options lib.workspace.allow_missing_related_pg_pins
reset_app_options lib.logic_model.auto_remove_timing_only_designs
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p10v_1p10v_125c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p21v_1p21v_125c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p26v_1p26v_125c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p10v_1p10v_m40c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p21v_1p21v_m40c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p26v_1p26v_m40c.db
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}} ${40NM_dir}/SRAM_Lib/${lib_dir_name}/lef/${lib_dir_name}.lef
set_app_options -name lib.logic_model.auto_remove_timing_only_designs -value true
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true
check_workspace
commit_workspace -output ./${lib_dir_name}_ff_1p_c.ndm
remove_workspace

set lib_dir_name  	RAMSP2048X16
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc9mc_tech.tf ${lib_dir_name}_ff_1p_c
reset_app_options lib.workspace.allow_missing_related_pg_pins
reset_app_options lib.logic_model.auto_remove_timing_only_designs
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p10v_1p10v_125c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p21v_1p21v_125c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p26v_1p26v_125c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p10v_1p10v_m40c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p21v_1p21v_m40c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p26v_1p26v_m40c.db
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}} ${40NM_dir}/SRAM_Lib/${lib_dir_name}/lef/${lib_dir_name}.lef
set_app_options -name lib.logic_model.auto_remove_timing_only_designs -value true
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true
check_workspace
commit_workspace -output ./${lib_dir_name}_ff_1p_c.ndm
remove_workspace

set lib_dir_name  	RAMSP4096X16
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc9mc_tech.tf ${lib_dir_name}_ff_1p_c
reset_app_options lib.workspace.allow_missing_related_pg_pins
reset_app_options lib.logic_model.auto_remove_timing_only_designs
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p10v_1p10v_125c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p21v_1p21v_125c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p26v_1p26v_125c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p10v_1p10v_m40c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p21v_1p21v_m40c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p26v_1p26v_m40c.db
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}} ${40NM_dir}/SRAM_Lib/${lib_dir_name}/lef/${lib_dir_name}.lef
set_app_options -name lib.logic_model.auto_remove_timing_only_designs -value true
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true
check_workspace
commit_workspace -output ./${lib_dir_name}_ff_1p_c.ndm
remove_workspace

set lib_dir_name  	RAMTP128X16
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc9mc_tech.tf ${lib_dir_name}_ff_1p_c
reset_app_options lib.workspace.allow_missing_related_pg_pins
reset_app_options lib.logic_model.auto_remove_timing_only_designs
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p10v_1p10v_125c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p21v_1p21v_125c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p26v_1p26v_125c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p10v_1p10v_m40c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p21v_1p21v_m40c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p26v_1p26v_m40c.db
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}} ${40NM_dir}/SRAM_Lib/${lib_dir_name}/lef/${lib_dir_name}.lef
set_app_options -name lib.logic_model.auto_remove_timing_only_designs -value true
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true
check_workspace
commit_workspace -output ./${lib_dir_name}_ff_1p_c.ndm
remove_workspace

set lib_dir_name  	RAMTP1024X16
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc9mc_tech.tf ${lib_dir_name}_ff_1p_c
reset_app_options lib.workspace.allow_missing_related_pg_pins
reset_app_options lib.logic_model.auto_remove_timing_only_designs
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p10v_1p10v_125c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p21v_1p21v_125c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p26v_1p26v_125c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p10v_1p10v_m40c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p21v_1p21v_m40c.db
read_db ${40NM_dir}/SRAM_Lib/${lib_dir_name}/db/${lib_dir_name}_ff_1p26v_1p26v_m40c.db
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}} ${40NM_dir}/SRAM_Lib/${lib_dir_name}/lef/${lib_dir_name}.lef
set_app_options -name lib.logic_model.auto_remove_timing_only_designs -value true
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true
check_workspace
commit_workspace -output ./${lib_dir_name}_ff_1p_c.ndm
remove_workspace