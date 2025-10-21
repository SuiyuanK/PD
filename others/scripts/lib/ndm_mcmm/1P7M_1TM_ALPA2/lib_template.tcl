# workspace SP40NLLD2RN_3P3V_V0p4_ss_V0p99_125C:
create_workspace "SP40NLLD2RN_3P3V_V0p4_ss_V0p99_125C" -technology /home/projects/techlib/SMIC/40LL/tech/pr_tech/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P7M_1TM_ALPA2/sc9mc_tech.tf
read_db /home/projects/techlib/SMIC/40LL/lib/io/bakup/SP40NLLD2RN_3P3V_V0p4/syn/3p3v/SP40NLLD2RN_3P3V_V0p4_ss_V0p99_125C.db
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}} /home/projects/techlib/SMIC/40LL/lib/io/bakup/SP40NLLD2RN_3P3V_V0p4/lef/SP40NLLD2RN_3P3V_V0p1_7MT_1TM.lef
set_app_options -name lib.logic_model.auto_remove_timing_only_designs -value true
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true
set_attribute -objects [get_layers M1] -name routing_direction -value vertical
set_attribute -objects [get_layers M1] -name track_offset -value 0.0
set_attribute -objects [get_layers M3] -name routing_direction -value vertical
set_attribute -objects [get_layers M3] -name track_offset -value 0.0
set_attribute -objects [get_layers M5] -name routing_direction -value vertical
set_attribute -objects [get_layers M5] -name track_offset -value 0.0
set_attribute -objects [get_layers TM2] -name routing_direction -value vertical
set_attribute -objects [get_layers TM2] -name track_offset -value 0.0
set_attribute -objects [get_layers M2] -name routing_direction -value horizontal
set_attribute -objects [get_layers M2] -name track_offset -value 0.0
set_attribute -objects [get_layers M4] -name routing_direction -value horizontal
set_attribute -objects [get_layers M4] -name track_offset -value 0.0
set_attribute -objects [get_layers M6] -name routing_direction -value horizontal
set_attribute -objects [get_layers M6] -name track_offset -value 0.0
set_attribute -objects [get_layers ALPA] -name routing_direction -value horizontal
set_attribute -objects [get_layers ALPA] -name track_offset -value 0.0
check_workspace
commit_workspace -output ./SP40NLLD2RN_3P3V_V0p4_ss_V0p99_125C.ndm
remove_workspace


# workspace SP40NLLD2RN_3P3V_V0p4_physical_only:
create_workspace "SP40NLLD2RN_3P3V_V0p4_physical_only" -flow physical_only -technology /home/projects/techlib/SMIC/40LL/tech/pr_tech/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/1P7M_1TM_ALPA2/sc9mc_tech.tf
read_db /home/projects/techlib/SMIC/40LL/lib/io/bakup/SP40NLLD2RN_3P3V_V0p4/syn/3p3v/SP40NLLD2RN_3P3V_V0p4_ss_V0p99_125C.db
read_lef -convert_sites {{{${lef_site_name}} {${mdb_site_name}}}} /home/projects/techlib/SMIC/40LL/lib/io/bakup/SP40NLLD2RN_3P3V_V0p4/lef/SP40NLLD2RN_3P3V_V0p1_7MT_1TM.lef
set_app_options -name lib.logic_model.auto_remove_timing_only_designs -value true
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true
set_attribute -objects [get_layers M1] -name routing_direction -value vertical
set_attribute -objects [get_layers M1] -name track_offset -value 0.0
set_attribute -objects [get_layers M3] -name routing_direction -value vertical
set_attribute -objects [get_layers M3] -name track_offset -value 0.0
set_attribute -objects [get_layers M5] -name routing_direction -value vertical
set_attribute -objects [get_layers M5] -name track_offset -value 0.0
set_attribute -objects [get_layers TM2] -name routing_direction -value vertical
set_attribute -objects [get_layers TM2] -name track_offset -value 0.0
set_attribute -objects [get_layers M2] -name routing_direction -value horizontal
set_attribute -objects [get_layers M2] -name track_offset -value 0.0
set_attribute -objects [get_layers M4] -name routing_direction -value horizontal
set_attribute -objects [get_layers M4] -name track_offset -value 0.0
set_attribute -objects [get_layers M6] -name routing_direction -value horizontal
set_attribute -objects [get_layers M6] -name track_offset -value 0.0
set_attribute -objects [get_layers ALPA] -name routing_direction -value horizontal
set_attribute -objects [get_layers ALPA] -name track_offset -value 0.0
check_workspace
commit_workspace -output ./SP40NLLD2RN_3P3V_V0p4_physical_only.ndm
remove_workspace


