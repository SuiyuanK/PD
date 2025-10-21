reset_app_options lib.workspace.allow_missing_related_pg_pins
reset_app_options lib.logic_model.auto_remove_timing_only_designs
reset_app_options lib.workspace.keep_all_physical_cells
set_app_options -name lib.logic_model.auto_remove_timing_only_designs -value true
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true
set_app_options -name lib.workspace.keep_all_physical_cells -value true
set 40NM_dir        /mnt/hgfs/Em/40NM
set lef_site_name 	sc9mc_logic0040ll
set mdb_site_name   	unit
set lib_dir_name  	RAMSP128X16
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc12mc_tech.tf RAMSP128X16_ff_1p_c
read_db ${40NM_dir}/SRAM_Lib/RAMSP128X16/db/RAMSP128X16_ff_1p10v_1p10v_125c.db
read_db ${40NM_dir}/SRAM_Lib/RAMSP128X16/db/RAMSP128X16_ff_1p21v_1p21v_125c.db
read_db ${40NM_dir}/SRAM_Lib/RAMSP128X16/db/RAMSP128X16_ff_1p26v_1p26v_125c.db
read_db ${40NM_dir}/SRAM_Lib/RAMSP128X16/db/RAMSP128X16_ff_1p10v_1p10v_m40c.db
read_db ${40NM_dir}/SRAM_Lib/RAMSP128X16/db/RAMSP128X16_ff_1p21v_1p21v_m40c.db
read_db ${40NM_dir}/SRAM_Lib/RAMSP128X16/db/RAMSP128X16_ff_1p26v_1p26v_m40c.db
set_process -libraries RAMSP128X16_ff_1p10v_1p10v_125c -label ff -number 1.1
set_process -libraries RAMSP128X16_ff_1p21v_1p21v_125c -label ff -number 1.21
set_process -libraries RAMSP128X16_ff_1p26v_1p26v_125c -label ff -number 1.26
set_process -libraries RAMSP128X16_ff_1p10v_1p10v_m40c -label ff -number 1.1
set_process -libraries RAMSP128X16_ff_1p21v_1p21v_m40c -label ff -number 1.21
set_process -libraries RAMSP128X16_ff_1p26v_1p26v_m40c -label ff -number 1.26
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}}  ${40NM_dir}/SRAM_Lib/RAMSP128X16/lef/RAMSP128X16.lef
check_workspace
commit_workspace -output ./RAMSP128X16_ff_1p_c.ndm
remove_workspace

create_workspace -technology /mnt/hgfs/Em/40NM/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc12mc_tech.tf RAMSP128X16_ss_c
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP128X16/db/RAMSP128X16_ss_0p90v_0p90v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP128X16/db/RAMSP128X16_ss_0p99v_0p99v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP128X16/db/RAMSP128X16_ss_1p08v_1p08v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP128X16/db/RAMSP128X16_ss_0p90v_0p90v_m40c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP128X16/db/RAMSP128X16_ss_0p99v_0p99v_m40c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP128X16/db/RAMSP128X16_ss_1p08v_1p08v_m40c.db
set_process -libraries RAMSP128X16_ss_0p90v_0p90v_125c -label ss -number 0.9
set_process -libraries RAMSP128X16_ss_0p99v_0p99v_125c -label ss -number 0.99
set_process -libraries RAMSP128X16_ss_1p08v_1p08v_125c -label ss -number 1.08
set_process -libraries RAMSP128X16_ss_0p90v_0p90v_m40c -label ss -number 0.9
set_process -libraries RAMSP128X16_ss_0p99v_0p99v_m40c -label ss -number 0.99
set_process -libraries RAMSP128X16_ss_1p08v_1p08v_m40c -label ss -number 1.08
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}}  /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP128X16/lef/RAMSP128X16.lef
check_workspace
commit_workspace -output ./RAMSP128X16_ss_c.ndm
remove_workspace

create_workspace -technology /mnt/hgfs/Em/40NM/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc12mc_tech.tf RAMSP128X16_tt_1p_25c
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP128X16/db/RAMSP128X16_tt_1p00v_1p00v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP128X16/db/RAMSP128X16_tt_1p10v_1p10v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP128X16/db/RAMSP128X16_tt_1p20v_1p20v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP128X16/db/RAMSP128X16_tt_1p00v_1p00v_25c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP128X16/db/RAMSP128X16_tt_1p10v_1p10v_25c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP128X16/db/RAMSP128X16_tt_1p20v_1p20v_25c.db
set_process -libraries RAMSP128X16_tt_1p00v_1p00v_125c -label tt -number 1
set_process -libraries RAMSP128X16_tt_1p10v_1p10v_125c -label tt -number 1.1
set_process -libraries RAMSP128X16_tt_1p20v_1p20v_125c -label tt -number 1.2
set_process -libraries RAMSP128X16_tt_1p00v_1p00v_25c  -label tt -number 1
set_process -libraries RAMSP128X16_tt_1p10v_1p10v_25c  -label tt -number 1.1
set_process -libraries RAMSP128X16_tt_1p20v_1p20v_25c  -label tt -number 1.2
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}}  /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP128X16/lef/RAMSP128X16.lef
check_workspace
commit_workspace -output ./RAMSP128X16_tt_1p_25c.ndm
remove_workspace

create_workspace -flow aggregate RAMSP128X16

read_ndm ./RAMSP128X16_ff_1p_c.ndm
read_ndm ./RAMSP128X16_ss_c.ndm
read_ndm ./RAMSP128X16_tt_1p_25c.ndm
get_libs

set_lib_order {RAMSP128X16_tt_1p_25c RAMSP128X16_ff_1p_c RAMSP128X16_ss_c}

check_workspace
commit_workspace 
remove_workspace


set lib_dir_name  	RAMSP1024X16
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc12mc_tech.tf RAMSP1024X16_ff_1p_c
read_db ${40NM_dir}/SRAM_Lib/RAMSP1024X16/db/RAMSP1024X16_ff_1p10v_1p10v_125c.db
read_db ${40NM_dir}/SRAM_Lib/RAMSP1024X16/db/RAMSP1024X16_ff_1p21v_1p21v_125c.db
read_db ${40NM_dir}/SRAM_Lib/RAMSP1024X16/db/RAMSP1024X16_ff_1p26v_1p26v_125c.db
read_db ${40NM_dir}/SRAM_Lib/RAMSP1024X16/db/RAMSP1024X16_ff_1p10v_1p10v_m40c.db
read_db ${40NM_dir}/SRAM_Lib/RAMSP1024X16/db/RAMSP1024X16_ff_1p21v_1p21v_m40c.db
read_db ${40NM_dir}/SRAM_Lib/RAMSP1024X16/db/RAMSP1024X16_ff_1p26v_1p26v_m40c.db
set_process -libraries RAMSP1024X16_ff_1p10v_1p10v_125c -label ff -number 1.1
set_process -libraries RAMSP1024X16_ff_1p21v_1p21v_125c -label ff -number 1.21
set_process -libraries RAMSP1024X16_ff_1p26v_1p26v_125c -label ff -number 1.26
set_process -libraries RAMSP1024X16_ff_1p10v_1p10v_m40c -label ff -number 1.1
set_process -libraries RAMSP1024X16_ff_1p21v_1p21v_m40c -label ff -number 1.21
set_process -libraries RAMSP1024X16_ff_1p26v_1p26v_m40c -label ff -number 1.26
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}}  ${40NM_dir}/SRAM_Lib/RAMSP1024X16/lef/RAMSP1024X16.lef
check_workspace
commit_workspace -output ./RAMSP1024X16_ff_1p_c.ndm
remove_workspace

create_workspace -technology /mnt/hgfs/Em/40NM/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc12mc_tech.tf RAMSP1024X16_ss_c
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP1024X16/db/RAMSP1024X16_ss_0p90v_0p90v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP1024X16/db/RAMSP1024X16_ss_0p99v_0p99v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP1024X16/db/RAMSP1024X16_ss_1p08v_1p08v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP1024X16/db/RAMSP1024X16_ss_0p90v_0p90v_m40c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP1024X16/db/RAMSP1024X16_ss_0p99v_0p99v_m40c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP1024X16/db/RAMSP1024X16_ss_1p08v_1p08v_m40c.db
set_process -libraries RAMSP1024X16_ss_0p90v_0p90v_125c -label ss -number 0.9
set_process -libraries RAMSP1024X16_ss_0p99v_0p99v_125c -label ss -number 0.99
set_process -libraries RAMSP1024X16_ss_1p08v_1p08v_125c -label ss -number 1.08
set_process -libraries RAMSP1024X16_ss_0p90v_0p90v_m40c -label ss -number 0.9
set_process -libraries RAMSP1024X16_ss_0p99v_0p99v_m40c -label ss -number 0.99
set_process -libraries RAMSP1024X16_ss_1p08v_1p08v_m40c -label ss -number 1.08
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}}  /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP1024X16/lef/RAMSP1024X16.lef
check_workspace
commit_workspace -output ./RAMSP1024X16_ss_c.ndm
remove_workspace

create_workspace -technology /mnt/hgfs/Em/40NM/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc12mc_tech.tf RAMSP1024X16_tt_1p_25c
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP1024X16/db/RAMSP1024X16_tt_1p00v_1p00v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP1024X16/db/RAMSP1024X16_tt_1p10v_1p10v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP1024X16/db/RAMSP1024X16_tt_1p20v_1p20v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP1024X16/db/RAMSP1024X16_tt_1p00v_1p00v_25c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP1024X16/db/RAMSP1024X16_tt_1p10v_1p10v_25c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP1024X16/db/RAMSP1024X16_tt_1p20v_1p20v_25c.db
set_process -libraries RAMSP1024X16_tt_1p00v_1p00v_125c -label tt -number 1
set_process -libraries RAMSP1024X16_tt_1p10v_1p10v_125c -label tt -number 1.1
set_process -libraries RAMSP1024X16_tt_1p20v_1p20v_125c -label tt -number 1.2
set_process -libraries RAMSP1024X16_tt_1p00v_1p00v_25c  -label tt -number 1
set_process -libraries RAMSP1024X16_tt_1p10v_1p10v_25c  -label tt -number 1.1
set_process -libraries RAMSP1024X16_tt_1p20v_1p20v_25c  -label tt -number 1.2
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}}  /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP1024X16/lef/RAMSP1024X16.lef
check_workspace
commit_workspace -output ./RAMSP1024X16_tt_1p_25c.ndm
remove_workspace

create_workspace -flow aggregate RAMSP1024X16

read_ndm ./RAMSP1024X16_ff_1p_c.ndm
read_ndm ./RAMSP1024X16_ss_c.ndm
read_ndm ./RAMSP1024X16_tt_1p_25c.ndm
get_libs

set_lib_order {RAMSP1024X16_tt_1p_25c RAMSP1024X16_ff_1p_c RAMSP1024X16_ss_c}

check_workspace
commit_workspace 
remove_workspace




set lib_dir_name  	RAMSP2048X16
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc12mc_tech.tf RAMSP2048X16_ff_1p_c
read_db ${40NM_dir}/SRAM_Lib/RAMSP2048X16/db/RAMSP2048X16_ff_1p10v_1p10v_125c.db
read_db ${40NM_dir}/SRAM_Lib/RAMSP2048X16/db/RAMSP2048X16_ff_1p21v_1p21v_125c.db
read_db ${40NM_dir}/SRAM_Lib/RAMSP2048X16/db/RAMSP2048X16_ff_1p26v_1p26v_125c.db
read_db ${40NM_dir}/SRAM_Lib/RAMSP2048X16/db/RAMSP2048X16_ff_1p10v_1p10v_m40c.db
read_db ${40NM_dir}/SRAM_Lib/RAMSP2048X16/db/RAMSP2048X16_ff_1p21v_1p21v_m40c.db
read_db ${40NM_dir}/SRAM_Lib/RAMSP2048X16/db/RAMSP2048X16_ff_1p26v_1p26v_m40c.db
set_process -libraries RAMSP2048X16_ff_1p10v_1p10v_125c -label ff -number 1.1
set_process -libraries RAMSP2048X16_ff_1p21v_1p21v_125c -label ff -number 1.21
set_process -libraries RAMSP2048X16_ff_1p26v_1p26v_125c -label ff -number 1.26
set_process -libraries RAMSP2048X16_ff_1p10v_1p10v_m40c -label ff -number 1.1
set_process -libraries RAMSP2048X16_ff_1p21v_1p21v_m40c -label ff -number 1.21
set_process -libraries RAMSP2048X16_ff_1p26v_1p26v_m40c -label ff -number 1.26
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}}  ${40NM_dir}/SRAM_Lib/RAMSP2048X16/lef/RAMSP2048X16.lef
check_workspace
commit_workspace -output ./RAMSP2048X16_ff_1p_c.ndm
remove_workspace

create_workspace -technology /mnt/hgfs/Em/40NM/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc12mc_tech.tf RAMSP2048X16_ss_c
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP2048X16/db/RAMSP2048X16_ss_0p90v_0p90v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP2048X16/db/RAMSP2048X16_ss_0p99v_0p99v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP2048X16/db/RAMSP2048X16_ss_1p08v_1p08v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP2048X16/db/RAMSP2048X16_ss_0p90v_0p90v_m40c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP2048X16/db/RAMSP2048X16_ss_0p99v_0p99v_m40c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP2048X16/db/RAMSP2048X16_ss_1p08v_1p08v_m40c.db
set_process -libraries RAMSP2048X16_ss_0p90v_0p90v_125c -label ss -number 0.9
set_process -libraries RAMSP2048X16_ss_0p99v_0p99v_125c -label ss -number 0.99
set_process -libraries RAMSP2048X16_ss_1p08v_1p08v_125c -label ss -number 1.08
set_process -libraries RAMSP2048X16_ss_0p90v_0p90v_m40c -label ss -number 0.9
set_process -libraries RAMSP2048X16_ss_0p99v_0p99v_m40c -label ss -number 0.99
set_process -libraries RAMSP2048X16_ss_1p08v_1p08v_m40c -label ss -number 1.08
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}}  /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP2048X16/lef/RAMSP2048X16.lef
check_workspace
commit_workspace -output ./RAMSP2048X16_ss_c.ndm
remove_workspace

create_workspace -technology /mnt/hgfs/Em/40NM/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc12mc_tech.tf RAMSP2048X16_tt_1p_25c
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP2048X16/db/RAMSP2048X16_tt_1p00v_1p00v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP2048X16/db/RAMSP2048X16_tt_1p10v_1p10v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP2048X16/db/RAMSP2048X16_tt_1p20v_1p20v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP2048X16/db/RAMSP2048X16_tt_1p00v_1p00v_25c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP2048X16/db/RAMSP2048X16_tt_1p10v_1p10v_25c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP2048X16/db/RAMSP2048X16_tt_1p20v_1p20v_25c.db
set_process -libraries RAMSP2048X16_tt_1p00v_1p00v_125c -label tt -number 1
set_process -libraries RAMSP2048X16_tt_1p10v_1p10v_125c -label tt -number 1.1
set_process -libraries RAMSP2048X16_tt_1p20v_1p20v_125c -label tt -number 1.2
set_process -libraries RAMSP2048X16_tt_1p00v_1p00v_25c  -label tt -number 1
set_process -libraries RAMSP2048X16_tt_1p10v_1p10v_25c  -label tt -number 1.1
set_process -libraries RAMSP2048X16_tt_1p20v_1p20v_25c  -label tt -number 1.2
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}}  /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP2048X16/lef/RAMSP2048X16.lef
check_workspace
commit_workspace -output ./RAMSP2048X16_tt_1p_25c.ndm
remove_workspace

create_workspace -flow aggregate RAMSP2048X16

read_ndm ./RAMSP2048X16_ff_1p_c.ndm
read_ndm ./RAMSP2048X16_ss_c.ndm
read_ndm ./RAMSP2048X16_tt_1p_25c.ndm
get_libs

set_lib_order {RAMSP2048X16_tt_1p_25c RAMSP2048X16_ff_1p_c RAMSP2048X16_ss_c}

check_workspace
commit_workspace 
remove_workspace

set lib_dir_name  	RAMSP4096X16
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc12mc_tech.tf RAMSP4096X16_ff_1p_c
read_db ${40NM_dir}/SRAM_Lib/RAMSP4096X16/db/RAMSP4096X16_ff_1p10v_1p10v_125c.db
read_db ${40NM_dir}/SRAM_Lib/RAMSP4096X16/db/RAMSP4096X16_ff_1p21v_1p21v_125c.db
read_db ${40NM_dir}/SRAM_Lib/RAMSP4096X16/db/RAMSP4096X16_ff_1p26v_1p26v_125c.db
read_db ${40NM_dir}/SRAM_Lib/RAMSP4096X16/db/RAMSP4096X16_ff_1p10v_1p10v_m40c.db
read_db ${40NM_dir}/SRAM_Lib/RAMSP4096X16/db/RAMSP4096X16_ff_1p21v_1p21v_m40c.db
read_db ${40NM_dir}/SRAM_Lib/RAMSP4096X16/db/RAMSP4096X16_ff_1p26v_1p26v_m40c.db
set_process -libraries RAMSP4096X16_ff_1p10v_1p10v_125c -label ff -number 1.1
set_process -libraries RAMSP4096X16_ff_1p21v_1p21v_125c -label ff -number 1.21
set_process -libraries RAMSP4096X16_ff_1p26v_1p26v_125c -label ff -number 1.26
set_process -libraries RAMSP4096X16_ff_1p10v_1p10v_m40c -label ff -number 1.1
set_process -libraries RAMSP4096X16_ff_1p21v_1p21v_m40c -label ff -number 1.21
set_process -libraries RAMSP4096X16_ff_1p26v_1p26v_m40c -label ff -number 1.26
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}}  ${40NM_dir}/SRAM_Lib/RAMSP4096X16/lef/RAMSP4096X16.lef
check_workspace
commit_workspace -output ./RAMSP4096X16_ff_1p_c.ndm
remove_workspace

create_workspace -technology /mnt/hgfs/Em/40NM/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc12mc_tech.tf RAMSP4096X16_ss_c
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP4096X16/db/RAMSP4096X16_ss_0p90v_0p90v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP4096X16/db/RAMSP4096X16_ss_0p99v_0p99v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP4096X16/db/RAMSP4096X16_ss_1p08v_1p08v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP4096X16/db/RAMSP4096X16_ss_0p90v_0p90v_m40c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP4096X16/db/RAMSP4096X16_ss_0p99v_0p99v_m40c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP4096X16/db/RAMSP4096X16_ss_1p08v_1p08v_m40c.db
set_process -libraries RAMSP4096X16_ss_0p90v_0p90v_125c -label ss -number 0.9
set_process -libraries RAMSP4096X16_ss_0p99v_0p99v_125c -label ss -number 0.99
set_process -libraries RAMSP4096X16_ss_1p08v_1p08v_125c -label ss -number 1.08
set_process -libraries RAMSP4096X16_ss_0p90v_0p90v_m40c -label ss -number 0.9
set_process -libraries RAMSP4096X16_ss_0p99v_0p99v_m40c -label ss -number 0.99
set_process -libraries RAMSP4096X16_ss_1p08v_1p08v_m40c -label ss -number 1.08
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}}  /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP4096X16/lef/RAMSP4096X16.lef
check_workspace
commit_workspace -output ./RAMSP4096X16_ss_c.ndm
remove_workspace

create_workspace -technology /mnt/hgfs/Em/40NM/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc12mc_tech.tf RAMSP4096X16_tt_1p_25c
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP4096X16/db/RAMSP4096X16_tt_1p00v_1p00v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP4096X16/db/RAMSP4096X16_tt_1p10v_1p10v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP4096X16/db/RAMSP4096X16_tt_1p20v_1p20v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP4096X16/db/RAMSP4096X16_tt_1p00v_1p00v_25c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP4096X16/db/RAMSP4096X16_tt_1p10v_1p10v_25c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP4096X16/db/RAMSP4096X16_tt_1p20v_1p20v_25c.db
set_process -libraries RAMSP4096X16_tt_1p00v_1p00v_125c -label tt -number 1
set_process -libraries RAMSP4096X16_tt_1p10v_1p10v_125c -label tt -number 1.1
set_process -libraries RAMSP4096X16_tt_1p20v_1p20v_125c -label tt -number 1.2
set_process -libraries RAMSP4096X16_tt_1p00v_1p00v_25c  -label tt -number 1
set_process -libraries RAMSP4096X16_tt_1p10v_1p10v_25c  -label tt -number 1.1
set_process -libraries RAMSP4096X16_tt_1p20v_1p20v_25c  -label tt -number 1.2
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}}  /mnt/hgfs/Em/40NM/SRAM_Lib/RAMSP4096X16/lef/RAMSP4096X16.lef
check_workspace
commit_workspace -output ./RAMSP4096X16_tt_1p_25c.ndm
remove_workspace

create_workspace -flow aggregate RAMSP4096X16

read_ndm ./RAMSP4096X16_ff_1p_c.ndm
read_ndm ./RAMSP4096X16_ss_c.ndm
read_ndm ./RAMSP4096X16_tt_1p_25c.ndm
get_libs

set_lib_order {RAMSP4096X16_tt_1p_25c RAMSP4096X16_ff_1p_c RAMSP4096X16_ss_c}

check_workspace
commit_workspace 
remove_workspace





set lib_dir_name  	RAMTP128X16
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc12mc_tech.tf RAMTP128X16_ff_1p_c
read_db ${40NM_dir}/SRAM_Lib/RAMTP128X16/db/RAMTP128X16_ff_1p10v_1p10v_125c.db
read_db ${40NM_dir}/SRAM_Lib/RAMTP128X16/db/RAMTP128X16_ff_1p21v_1p21v_125c.db
read_db ${40NM_dir}/SRAM_Lib/RAMTP128X16/db/RAMTP128X16_ff_1p26v_1p26v_125c.db
read_db ${40NM_dir}/SRAM_Lib/RAMTP128X16/db/RAMTP128X16_ff_1p10v_1p10v_m40c.db
read_db ${40NM_dir}/SRAM_Lib/RAMTP128X16/db/RAMTP128X16_ff_1p21v_1p21v_m40c.db
read_db ${40NM_dir}/SRAM_Lib/RAMTP128X16/db/RAMTP128X16_ff_1p26v_1p26v_m40c.db
set_process -libraries RAMTP128X16_ff_1p10v_1p10v_125c -label ff -number 1.1
set_process -libraries RAMTP128X16_ff_1p21v_1p21v_125c -label ff -number 1.21
set_process -libraries RAMTP128X16_ff_1p26v_1p26v_125c -label ff -number 1.26
set_process -libraries RAMTP128X16_ff_1p10v_1p10v_m40c -label ff -number 1.1
set_process -libraries RAMTP128X16_ff_1p21v_1p21v_m40c -label ff -number 1.21
set_process -libraries RAMTP128X16_ff_1p26v_1p26v_m40c -label ff -number 1.26
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}}  ${40NM_dir}/SRAM_Lib/RAMTP128X16/lef/RAMTP128X16.lef
check_workspace
commit_workspace -output ./RAMTP128X16_ff_1p_c.ndm
remove_workspace

create_workspace -technology /mnt/hgfs/Em/40NM/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc12mc_tech.tf RAMTP128X16_ss_c
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP128X16/db/RAMTP128X16_ss_0p90v_0p90v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP128X16/db/RAMTP128X16_ss_0p99v_0p99v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP128X16/db/RAMTP128X16_ss_1p08v_1p08v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP128X16/db/RAMTP128X16_ss_0p90v_0p90v_m40c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP128X16/db/RAMTP128X16_ss_0p99v_0p99v_m40c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP128X16/db/RAMTP128X16_ss_1p08v_1p08v_m40c.db
set_process -libraries RAMTP128X16_ss_0p90v_0p90v_125c -label ss -number 0.9
set_process -libraries RAMTP128X16_ss_0p99v_0p99v_125c -label ss -number 0.99
set_process -libraries RAMTP128X16_ss_1p08v_1p08v_125c -label ss -number 1.08
set_process -libraries RAMTP128X16_ss_0p90v_0p90v_m40c -label ss -number 0.9
set_process -libraries RAMTP128X16_ss_0p99v_0p99v_m40c -label ss -number 0.99
set_process -libraries RAMTP128X16_ss_1p08v_1p08v_m40c -label ss -number 1.08
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}}  /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP128X16/lef/RAMTP128X16.lef
check_workspace
commit_workspace -output ./RAMTP128X16_ss_c.ndm
remove_workspace

create_workspace -technology /mnt/hgfs/Em/40NM/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc12mc_tech.tf RAMTP128X16_tt_1p_25c
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP128X16/db/RAMTP128X16_tt_1p00v_1p00v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP128X16/db/RAMTP128X16_tt_1p10v_1p10v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP128X16/db/RAMTP128X16_tt_1p20v_1p20v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP128X16/db/RAMTP128X16_tt_1p00v_1p00v_25c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP128X16/db/RAMTP128X16_tt_1p10v_1p10v_25c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP128X16/db/RAMTP128X16_tt_1p20v_1p20v_25c.db
set_process -libraries RAMTP128X16_tt_1p00v_1p00v_125c -label tt -number 1
set_process -libraries RAMTP128X16_tt_1p10v_1p10v_125c -label tt -number 1.1
set_process -libraries RAMTP128X16_tt_1p20v_1p20v_125c -label tt -number 1.2
set_process -libraries RAMTP128X16_tt_1p00v_1p00v_25c  -label tt -number 1
set_process -libraries RAMTP128X16_tt_1p10v_1p10v_25c  -label tt -number 1.1
set_process -libraries RAMTP128X16_tt_1p20v_1p20v_25c  -label tt -number 1.2
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}}  /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP128X16/lef/RAMTP128X16.lef
check_workspace
commit_workspace -output ./RAMTP128X16_tt_1p_25c.ndm
remove_workspace

create_workspace -flow aggregate RAMTP128X16

read_ndm ./RAMTP128X16_ff_1p_c.ndm
read_ndm ./RAMTP128X16_ss_c.ndm
read_ndm ./RAMTP128X16_tt_1p_25c.ndm
get_libs

set_lib_order {RAMTP128X16_tt_1p_25c RAMTP128X16_ff_1p_c RAMTP128X16_ss_c}

check_workspace
commit_workspace 
remove_workspace





set lib_dir_name  	RAMTP1024X16
create_workspace -technology ${40NM_dir}/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc12mc_tech.tf RAMTP1024X16_ff_1p_c
read_db ${40NM_dir}/SRAM_Lib/RAMTP1024X16/db/RAMTP1024X16_ff_1p10v_1p10v_125c.db
read_db ${40NM_dir}/SRAM_Lib/RAMTP1024X16/db/RAMTP1024X16_ff_1p21v_1p21v_125c.db
read_db ${40NM_dir}/SRAM_Lib/RAMTP1024X16/db/RAMTP1024X16_ff_1p26v_1p26v_125c.db
read_db ${40NM_dir}/SRAM_Lib/RAMTP1024X16/db/RAMTP1024X16_ff_1p10v_1p10v_m40c.db
read_db ${40NM_dir}/SRAM_Lib/RAMTP1024X16/db/RAMTP1024X16_ff_1p21v_1p21v_m40c.db
read_db ${40NM_dir}/SRAM_Lib/RAMTP1024X16/db/RAMTP1024X16_ff_1p26v_1p26v_m40c.db
set_process -libraries RAMTP1024X16_ff_1p10v_1p10v_125c -label ff -number 1.1
set_process -libraries RAMTP1024X16_ff_1p21v_1p21v_125c -label ff -number 1.21
set_process -libraries RAMTP1024X16_ff_1p26v_1p26v_125c -label ff -number 1.26
set_process -libraries RAMTP1024X16_ff_1p10v_1p10v_m40c -label ff -number 1.1
set_process -libraries RAMTP1024X16_ff_1p21v_1p21v_m40c -label ff -number 1.21
set_process -libraries RAMTP1024X16_ff_1p26v_1p26v_m40c -label ff -number 1.26
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}}  ${40NM_dir}/SRAM_Lib/RAMTP1024X16/lef/RAMTP1024X16.lef
check_workspace
commit_workspace -output ./RAMTP1024X16_ff_1p_c.ndm
remove_workspace

create_workspace -technology /mnt/hgfs/Em/40NM/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc12mc_tech.tf RAMTP1024X16_ss_c
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP1024X16/db/RAMTP1024X16_ss_0p90v_0p90v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP1024X16/db/RAMTP1024X16_ss_0p99v_0p99v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP1024X16/db/RAMTP1024X16_ss_1p08v_1p08v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP1024X16/db/RAMTP1024X16_ss_0p90v_0p90v_m40c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP1024X16/db/RAMTP1024X16_ss_0p99v_0p99v_m40c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP1024X16/db/RAMTP1024X16_ss_1p08v_1p08v_m40c.db
set_process -libraries RAMTP1024X16_ss_0p90v_0p90v_125c -label ss -number 0.9
set_process -libraries RAMTP1024X16_ss_0p99v_0p99v_125c -label ss -number 0.99
set_process -libraries RAMTP1024X16_ss_1p08v_1p08v_125c -label ss -number 1.08
set_process -libraries RAMTP1024X16_ss_0p90v_0p90v_m40c -label ss -number 0.9
set_process -libraries RAMTP1024X16_ss_0p99v_0p99v_m40c -label ss -number 0.99
set_process -libraries RAMTP1024X16_ss_1p08v_1p08v_m40c -label ss -number 1.08
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}}  /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP1024X16/lef/RAMTP1024X16.lef
check_workspace
commit_workspace -output ./RAMTP1024X16_ss_c.ndm
remove_workspace

create_workspace -technology /mnt/hgfs/Em/40NM/techfile/ARM_pr/SM09TF000-FE-00000-r3p4-00eac0/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P8M_2TM_ALPA2/sc12mc_tech.tf RAMTP1024X16_tt_1p_25c
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP1024X16/db/RAMTP1024X16_tt_1p00v_1p00v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP1024X16/db/RAMTP1024X16_tt_1p10v_1p10v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP1024X16/db/RAMTP1024X16_tt_1p20v_1p20v_125c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP1024X16/db/RAMTP1024X16_tt_1p00v_1p00v_25c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP1024X16/db/RAMTP1024X16_tt_1p10v_1p10v_25c.db
read_db /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP1024X16/db/RAMTP1024X16_tt_1p20v_1p20v_25c.db
set_process -libraries RAMTP1024X16_tt_1p00v_1p00v_125c -label tt -number 1
set_process -libraries RAMTP1024X16_tt_1p10v_1p10v_125c -label tt -number 1.1
set_process -libraries RAMTP1024X16_tt_1p20v_1p20v_125c -label tt -number 1.2
set_process -libraries RAMTP1024X16_tt_1p00v_1p00v_25c  -label tt -number 1
set_process -libraries RAMTP1024X16_tt_1p10v_1p10v_25c  -label tt -number 1.1
set_process -libraries RAMTP1024X16_tt_1p20v_1p20v_25c  -label tt -number 1.2
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}}  /mnt/hgfs/Em/40NM/SRAM_Lib/RAMTP1024X16/lef/RAMTP1024X16.lef
check_workspace
commit_workspace -output ./RAMTP1024X16_tt_1p_25c.ndm
remove_workspace

create_workspace -flow aggregate RAMTP1024X16

read_ndm ./RAMTP1024X16_ff_1p_c.ndm
read_ndm ./RAMTP1024X16_ss_c.ndm
read_ndm ./RAMTP1024X16_tt_1p_25c.ndm
get_libs

set_lib_order {RAMTP1024X16_tt_1p_25c RAMTP1024X16_ff_1p_c RAMTP1024X16_ss_c}

check_workspace
commit_workspace 
remove_workspace