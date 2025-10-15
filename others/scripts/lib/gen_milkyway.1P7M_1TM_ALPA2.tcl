extend_mw_layers

set metal_stack  	1P7M_1TM_ALPA2	
set track_num    	9
set lef_metal_stack   	7m1t

####################################################
set block_name  	SP40NLLD2RNP_OV3_V1p1_7MT_1TM
set mem_path      	/projects2/techlib/SMIC/40LL/lib/io/SP40NLLD2RNP_OV3_V1p1a		
set mem_lib_dir   	$mem_path  
set mem_list  [list \
  $block_name  \
]

set tech_file    	/home/projects/techlib/SMIC/40LL/tech/pr_tech/arm/smic/logic0040ll/arm_tech/r3p4/milkyway/${metal_stack}/sc${track_num}mc_tech.tf
set lib_name  ./${block_name}.mdb
set dumped_clf ./${block_name}.clf

### delete milkyway lib
sh rm -rf $lib_name

### create milkyway lib
cmCreateLib
setFormField create_library library_name $lib_name
setFormField create_library technology_file_name $tech_file
setFormField create_library set_case_sensitive 1
formOK create_library

### set bus naming style
cmSetBusNameStyle
setFormField set_bus_naming_style library_name $lib_name
setFormField set_bus_naming_style bus_naming_style \[%d\]
formOK set_bus_naming_style

### read lef
foreach mem_name $mem_list {
  set lef_file ${mem_lib_dir}/lef/${lef_metal_stack}/${mem_name}_merged.lef
  read_lef \
    -lib_name $lib_name \
    -tech_lef_files $lef_file \
    -cell_lef_files $lef_file \
    -cell_version overwrite \
    -advanced_lib_prep_mode
}

### extract pin/blockage/via
auExtractBlockagePinVia
setFormField extract_blockage library_name $lib_name
formButton extract_blockage extractBlkg
setFormField extract_blockage merge_blockage 1
setFormField make_macro routing_blockage_output_layer metBlk
setFormField extract_blockage treat_all_blockage_as_thin_wire 1
formButton extract_blockage extractPin
formOK extract_blockage

## puts "INFO: Please double check antenna clf file $dumped_clf"
sh rm -f *.defineVar*
sh rm -f lefPinOrder*
sh rm -f *log
sh rm -f Milkyway*
sh mkdir -p ../clf
