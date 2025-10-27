# set lef_site_name   sc9mc_logic0040ll
# set mdb_site_name   unit
# -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}}
set 40NM_dir        /mnt/hgfs/Em/40NM
set lef_site_name 	sc9mc_logic0040ll
set mdb_site_name   	unit
reset_app_options lib.workspace.allow_missing_related_pg_pins
reset_app_options lib.logic_model.auto_remove_timing_only_designs
reset_app_options lib.workspace.keep_all_physical_cells
set_app_options -name lib.logic_model.auto_remove_timing_only_designs -value true
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true
set_app_options -name lib.workspace.keep_all_physical_cells -value true
# workspace scc40nll_vhsc40_hvt
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P9M_2TM_ALPA2/sc12mc_tech.tf scc40nll_vhsc40_hvt
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_HVT_V0.1/SCC40NLL_VHSC40_HVT_V0p1/liberty/1.1v/scc40nll_vhsc40_hvt_ff_v1p21_125c_ccs.db
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_HVT_V0.1/SCC40NLL_VHSC40_HVT_V0p1/liberty/1.1v/scc40nll_vhsc40_hvt_ff_v1p21_-40c_ccs.db
set_process -libraries scc40nll_vhsc40_hvt_ff_v1p21_125c_ccs -label ff -number 1.21
set_process -libraries scc40nll_vhsc40_hvt_ff_v1p21_-40c_ccs -label ff -number 1.21
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_HVT_V0.1/SCC40NLL_VHSC40_HVT_V0p1/liberty/1.1v/scc40nll_vhsc40_hvt_ss_v0p99_125c_ccs.db
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_HVT_V0.1/SCC40NLL_VHSC40_HVT_V0p1/liberty/1.1v/scc40nll_vhsc40_hvt_ss_v0p99_-40c_ccs.db
set_process -libraries scc40nll_vhsc40_hvt_ss_v0p99_125c_ccs -label ss -number 0.99
set_process -libraries scc40nll_vhsc40_hvt_ss_v0p99_-40c_ccs -label ss -number 0.99
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_HVT_V0.1/SCC40NLL_VHSC40_HVT_V0p1/liberty/1.1v/scc40nll_vhsc40_hvt_tt_v1p1_125c_ccs.db
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_HVT_V0.1/SCC40NLL_VHSC40_HVT_V0p1/liberty/1.1v/scc40nll_vhsc40_hvt_tt_v1p1_25c_ccs.db
set_process -libraries scc40nll_vhsc40_hvt_tt_v1p1_125c_ccs -label tt -number 1.1
set_process -libraries scc40nll_vhsc40_hvt_tt_v1p1_25c_ccs -label tt -number 1.1
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}} ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_HVT_V0.1/SCC40NLL_VHSC40_HVT_V0p1/lef/macro/scc40nll_vhsc40_hvt_ant.lef
get_libs
check_workspace
commit_workspace -output ./scc40nll_vhsc40_hvt.ndm
remove_workspace

exit








set 40NM_dir        /mnt/hgfs/Em/40NM
set lef_site_name 	sc9mc_logic0040ll
set mdb_site_name   	unit
reset_app_options lib.workspace.allow_missing_related_pg_pins
reset_app_options lib.logic_model.auto_remove_timing_only_designs
reset_app_options lib.workspace.keep_all_physical_cells
set_app_options -name lib.logic_model.auto_remove_timing_only_designs -value true
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true
set_app_options -name lib.workspace.keep_all_physical_cells -value true
# workspace scc40nll_vhsc40_lvt:
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P9M_2TM_ALPA2/sc12mc_tech.tf scc40nll_vhsc40_lvt
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_LVT_V0.1/SCC40NLL_VHSC40_LVT_V0p1/liberty/1.1v/scc40nll_vhsc40_lvt_ff_v1p21_125c_ccs.db
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_LVT_V0.1/SCC40NLL_VHSC40_LVT_V0p1/liberty/1.1v/scc40nll_vhsc40_lvt_ff_v1p21_-40c_ccs.db
set_process -libraries scc40nll_vhsc40_lvt_ff_v1p21_125c_ccs -label ff -number 1.21
set_process -libraries scc40nll_vhsc40_lvt_ff_v1p21_-40c_ccs -label ff -number 1.21
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_LVT_V0.1/SCC40NLL_VHSC40_LVT_V0p1/liberty/1.1v/scc40nll_vhsc40_lvt_ss_v0p99_125c_ccs.db
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_LVT_V0.1/SCC40NLL_VHSC40_LVT_V0p1/liberty/1.1v/scc40nll_vhsc40_lvt_ss_v0p99_-40c_ccs.db
set_process -libraries scc40nll_vhsc40_lvt_ss_v0p99_125c_ccs -label ss -number 0.99
set_process -libraries scc40nll_vhsc40_lvt_ss_v0p99_-40c_ccs -label ss -number 0.99
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_LVT_V0.1/SCC40NLL_VHSC40_LVT_V0p1/liberty/1.1v/scc40nll_vhsc40_lvt_tt_v1p1_125c_ccs.db
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_LVT_V0.1/SCC40NLL_VHSC40_LVT_V0p1/liberty/1.1v/scc40nll_vhsc40_lvt_tt_v1p1_25c_ccs.db
set_process -libraries scc40nll_vhsc40_lvt_tt_v1p1_125c_ccs -label tt -number 1.1
set_process -libraries scc40nll_vhsc40_lvt_tt_v1p1_25c_ccs  -label tt -number 1.1
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}} ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_LVT_V0.1/SCC40NLL_VHSC40_LVT_V0p1/lef/macro/scc40nll_vhsc40_lvt_ant.lef
get_libs
check_workspace
commit_workspace -output ./scc40nll_vhsc40_lvt.ndm
remove_workspace
exit






set 40NM_dir        /mnt/hgfs/Em/40NM
set lef_site_name 	sc9mc_logic0040ll
set mdb_site_name   	unit
reset_app_options lib.workspace.allow_missing_related_pg_pins
reset_app_options lib.logic_model.auto_remove_timing_only_designs
reset_app_options lib.workspace.keep_all_physical_cells
set_app_options -name lib.logic_model.auto_remove_timing_only_designs -value true
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true
set_app_options -name lib.workspace.keep_all_physical_cells -value true
# workspace scc40nll_vhsc40_rvt:
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P9M_2TM_ALPA2/sc12mc_tech.tf scc40nll_vhsc40_rvt
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_RVT_V0.1/SCC40NLL_VHSC40_RVT_V0p1/liberty/1.1v/scc40nll_vhsc40_rvt_ff_v1p21_125c_ccs.db
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_RVT_V0.1/SCC40NLL_VHSC40_RVT_V0p1/liberty/1.1v/scc40nll_vhsc40_rvt_ff_v1p21_-40c_ccs.db
set_process -libraries scc40nll_vhsc40_rvt_ff_v1p21_125c_ccs -label ff -number 1.21
set_process -libraries scc40nll_vhsc40_rvt_ff_v1p21_-40c_ccs -label ff -number 1.21
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_RVT_V0.1/SCC40NLL_VHSC40_RVT_V0p1/liberty/1.1v/scc40nll_vhsc40_rvt_ss_v0p99_125c_ccs.db
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_RVT_V0.1/SCC40NLL_VHSC40_RVT_V0p1/liberty/1.1v/scc40nll_vhsc40_rvt_ss_v0p99_-40c_ccs.db
set_process -libraries scc40nll_vhsc40_rvt_ss_v0p99_125c_ccs -label ss -number 0.99
set_process -libraries scc40nll_vhsc40_rvt_ss_v0p99_-40c_ccs -label ss -number 0.99
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_RVT_V0.1/SCC40NLL_VHSC40_RVT_V0p1/liberty/1.1v/scc40nll_vhsc40_rvt_tt_v1p1_125c_ccs.db
read_db ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_RVT_V0.1/SCC40NLL_VHSC40_RVT_V0p1/liberty/1.1v/scc40nll_vhsc40_rvt_tt_v1p1_25c_ccs.db
set_process -libraries scc40nll_vhsc40_rvt_tt_v1p1_125c_ccs -label tt -number 1.1
set_process -libraries scc40nll_vhsc40_rvt_tt_v1p1_25c_ccs  -label tt -number 1.1
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}} ${40NM_dir}/S40/smic/SCC40NLL_VHSC40_RVT_V0.1/SCC40NLL_VHSC40_RVT_V0p1/lef/macro/scc40nll_vhsc40_rvt_ant.lef
get_libs
check_workspace
commit_workspace -output ./scc40nll_vhsc40_rvt.ndm
remove_workspace
exit

set 40NM_dir        /mnt/hgfs/Em/40NM
set lef_site_name 	sc9mc_logic0040ll
set mdb_site_name   	unit
reset_app_options lib.workspace.allow_missing_related_pg_pins
reset_app_options lib.logic_model.auto_remove_timing_only_designs
reset_app_options lib.workspace.keep_all_physical_cells
set_app_options -name lib.logic_model.auto_remove_timing_only_designs -value true
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true
set_app_options -name lib.workspace.keep_all_physical_cells -value true
# workspace SP40NLLD2RN_3P3V_V0p4:
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P9M_2TM_ALPA2/sc12mc_tech.tf SP40NLLD2RN_3P3V_V0p4
read_db ${40NM_dir}/S40/smic/SP40NLLD2RN_3P3V_V0p4/syn/3p3v/SP40NLLD2RN_3P3V_V0p4_ff_V1p21_125C.db
read_db ${40NM_dir}/S40/smic/SP40NLLD2RN_3P3V_V0p4/syn/3p3v/SP40NLLD2RN_3P3V_V0p4_ff_V1p21_-40C.db
set_process -libraries SP40NLLD2RN_3P3V_V0p4_ff_V1p21_125C -label ff -number 1.21
set_process -libraries SP40NLLD2RN_3P3V_V0p4_ff_V1p21_-40C -label ff -number 1.21
read_db ${40NM_dir}/S40/smic/SP40NLLD2RN_3P3V_V0p4/syn/3p3v/SP40NLLD2RN_3P3V_V0p4_ss_V0p99_125C.db
read_db ${40NM_dir}/S40/smic/SP40NLLD2RN_3P3V_V0p4/syn/3p3v/SP40NLLD2RN_3P3V_V0p4_ss_V0p99_-40C.db
set_process -libraries SP40NLLD2RN_3P3V_V0p4_ss_V0p99_125C -label ss -number 0.99
set_process -libraries SP40NLLD2RN_3P3V_V0p4_ss_V0p99_-40C -label ss -number 0.99
read_db ${40NM_dir}/S40/smic/SP40NLLD2RN_3P3V_V0p4/syn/3p3v/SP40NLLD2RN_3P3V_V0p4_tt_V1p10_25C.db
set_process -libraries SP40NLLD2RN_3P3V_V0p4_tt_V1p10_25C -label tt -number 1.1
get_libs
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}} ${40NM_dir}/S40/smic/SP40NLLD2RN_3P3V_V0p4/lef/SP40NLLD2RN_3P3V_V0p1_9MT_2TM.lef
check_workspace
commit_workspace -output ./SP40NLLD2RN_3P3V_V0p4.ndm
remove_workspace
exit





