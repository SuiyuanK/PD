set metal_stack   	1P7M_1MTT_ALPA2	
set if_trim_blkg  	0
set if_involk_tlef   	0
set if_preserve_blkg 	1
set if_no_tech 	 	0	
set if_mcmm     	0
set if_specific_vol  	0p99v
set track_num    	9
set poly_pitch 		96

set lib_dir_name  	memory	
set lib_dir_ver         r0p0	
set lef_ver		100d
set db_ver  		100c
set lef_site_name 	sc9mc_logic0040ll
set mdb_site_name   	unit

set GFVAR_ICC2LM_TECH_INFO " \
  {M1 vertical 0.0} \
  {M3 vertical 0.0} \
  {M5 vertical 0.0} \
  {TM2 vertical 0.0} \
  {M2 horizontal 0.0} \
  {M4 horizontal 0.0} \
  {M6 horizontal 0.0} \
  {ALPA horizontal 0.0} \
"
set mem_lib_dir         /home/projects/techlib/SMIC/40LL/lib/memory/HFDP001/20190701 
set tech_file    	/home/projects/techlib/SMIC/40LL/tech/pr_tech/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/${metal_stack}/sc${track_num}mc_tech.tf
set tech_lef    	""	
set lib_name   		$lib_dir_name
set db_lib_dir_name     ""	
set lef_lib_dir_name    ""
set oper_cond_wc  	ss_*v_125c
set oper_cond_wcl  	ss_*v_m40c
set oper_cond  	  	ss_*v*c
if {$if_specific_vol > 0} {
  set oper_cond_wc  	ss_*${if_specific_vol}*_125c
  set oper_cond_wcl  	ss_*${if_specific_vol}*_m40c
  set oper_cond  	ss_*${if_specific_vol}*c
}

create_workspace $lib_name \
  -flow exploration \
  -technology $tech_file

set if_tech_lef 0
if {$if_involk_tlef && [info exist tech_lef] && [file exist $tech_lef]} {
  puts  "INFO: read tech lef $tech_lef ..."
  read_lef $tech_lef -convert_sites {{${lef_site_name} ${mdb_site_name}} }
  set if_tech_lef 1
} 

if {$if_no_tech} {
  read_lef -include cell  [glob ${mem_lib_dir}/lef/*.lef ] -convert_sites {{ ${lef_site_name} ${mdb_site_name}} }
} else {
  read_lef  [glob ${mem_lib_dir}/lef/*.lef ] -convert_sites {{ ${lef_site_name} ${mdb_site_name}}}
}

### blockage
if {$if_trim_blkg} {
  set_app_options -as_user_default -name lib.physical_model.trim_metal_blockage_around_pin -value true
} 

set db_list  [glob ${mem_lib_dir}/db/*${oper_cond_wc}.db]
if {$if_mcmm} {
  foreach db_name [glob ${mem_lib_dir}/db/*${oper_cond_wcl}.db] {
    lappend db_list $db_name
  }
}
read_db $db_list

group_libs

foreach layer_list $GFVAR_ICC2LM_TECH_INFO {
  set layer 		[lindex $layer_list 0]
  set direction    	[lindex $layer_list 1]
  set offset    	[lindex $layer_list 2]
  set_attribute   [get_layers $layer ] routing_direction $direction
  puts " set_attribute   \[get_layers $layer \] routing_direction $direction"
  set_attribute   [get_layers $layer ] track_offset $offset
  puts " set_attribute   \[get_layers $layer \] track_offset $offset"
}

set_app_options -list [list lib.workspace.allow_missing_related_pg_pins true]

write_workspace -file lib_template.tcl
check_workspace
commit_workspace
exit 1
