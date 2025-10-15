extend_mw_layers

set metal_stack  	1P7M_1MTT_ALPA2	
set track_num    	9

####################################################
set block_name  	memory
set mem_path    	/home/projects/techlib/SMIC/40LL/lib/memory/HFDP001/20191029_v10	
set mem_lib_dir   	$mem_path  
set mem_list  [list \
  sram_1024x104_sp \
  sram_1024x10_sp \
  sram_1024x120_sp \
  sram_1024x16_dp \
  sram_1024x20_dp \
  sram_1024x20_sp \
  sram_1024x24_dp \
  sram_1024x30_dp \
  sram_1024x32_dp \
  sram_1024x32_sp \
  sram_1024x36_sp \
  sram_1024x40_dp \
  sram_1024x40_sp \
  sram_1024x42_dp \
  sram_1024x48_dp \
  sram_1024x48_sp \
  sram_1024x50_dp \
  sram_1024x52_dp \
  sram_1024x58_dp \
  sram_1024x64_dp \
  sram_1024x64_sp \
  sram_1024x72_dp \
  sram_1024x8_sp \
  sram_1024x9_sp \
  sram_128x102_sp \
  sram_128x106_sp \
  sram_128x116_sp \
  sram_128x16_dp \
  sram_128x18_sp \
  sram_128x20_dp \
  sram_128x30_dp \
  sram_128x32_dp \
  sram_128x40_dp \
  sram_128x40_sp \
  sram_128x48_dp \
  sram_128x52_dp \
  sram_128x66_sp \
  sram_128x70_sp \
  sram_128x74_sp \
  sram_128x78_sp \
  sram_128x84_sp \
  sram_128x88_sp \
  sram_128x92_sp \
  sram_128x96_sp \
  sram_1632x27_dp \
  sram_1632x28_dp \
  sram_1632x29_dp \
  sram_1632x30_dp \
  sram_1632x31_dp \
  sram_1632x32_dp \
  sram_16384x16_sp \
  sram_16384x20_sp \
  sram_180x102_sp \
  sram_200x102_sp \
  sram_200x106_sp \
  sram_200x116_sp \
  sram_200x66_sp \
  sram_200x74_sp \
  sram_200x78_sp \
  sram_200x84_sp \
  sram_200x88_sp \
  sram_200x92_sp \
  sram_200x96_sp \
  sram_2048x11_dp \
  sram_2048x12_dp \
  sram_2048x16_dp \
  sram_2048x16_sp \
  sram_2048x18_dp \
  sram_2048x20_dp \
  sram_2048x24_dp \
  sram_2048x25_dp \
  sram_2048x27_sp \
  sram_2048x30_dp \
  sram_2048x32_dp \
  sram_2048x32_sp \
  sram_2048x40_dp \
  sram_2048x52_sp \
  sram_256x106_sp \
  sram_256x116_sp \
  sram_256x128_sp \
  sram_256x16_dp \
  sram_256x16_sp \
  sram_256x18_sp \
  sram_256x20_dp \
  sram_256x24_dp \
  sram_256x27_sp \
  sram_256x32_dp \
  sram_256x32_sp \
  sram_256x36_sp \
  sram_256x48_dp \
  sram_256x48_sp \
  sram_256x54_dp \
  sram_256x56_dp \
  sram_256x58_sp \
  sram_256x60_sp \
  sram_256x62_sp \
  sram_256x64_sp \
  sram_256x66_sp \
  sram_256x68_sp \
  sram_256x70_sp \
  sram_256x72_dp \
  sram_256x74_dp \
  sram_256x78_sp \
  sram_256x88_sp \
  sram_256x96_sp \
  sram_32768x16_sp \
  sram_32768x32_sp \
  sram_32768x36_sp \
  sram_32x102_sp \
  sram_32x106_sp \
  sram_32x116_sp \
  sram_32x128_sp \
  sram_32x18_sp \
  sram_32x36_sp \
  sram_32x66_sp \
  sram_32x70_sp \
  sram_32x72_sp \
  sram_32x74_sp \
  sram_32x76_sp \
  sram_32x78_sp \
  sram_32x80_sp \
  sram_32x82_sp \
  sram_32x84_sp \
  sram_32x88_sp \
  sram_32x92_sp \
  sram_32x96_sp \
  sram_32x98_sp \
  sram_4096x11_dp \
  sram_4096x14_dp \
  sram_4096x16_dp \
  sram_4096x16_sp \
  sram_4096x18_dp \
  sram_4096x20_dp \
  sram_4096x32_sp \
  sram_4096x36_sp \
  sram_4096x48_sp \
  sram_4096x4_dp \
  sram_4096x8_dp \
  sram_4896x54_sp \
  sram_4896x56_sp \
  sram_4896x58_sp \
  sram_4896x60_sp \
  sram_4896x62_sp \
  sram_5088x54_sp \
  sram_5088x56_sp \
  sram_5088x58_sp \
  sram_5088x60_sp \
  sram_5088x62_sp \
  sram_5088x64_sp \
  sram_5088x66_sp \
  sram_512x102_sp \
  sram_512x116_sp \
  sram_512x128_sp \
  sram_512x12_dp \
  sram_512x16_dp \
  sram_512x16_sp \
  sram_512x18_sp \
  sram_512x20_dp \
  sram_512x20_sp \
  sram_512x24_dp \
  sram_512x24_sp \
  sram_512x27_sp \
  sram_512x30_dp \
  sram_512x32_dp \
  sram_512x32_sp \
  sram_512x36_sp \
  sram_512x40_sp \
  sram_512x41_dp \
  sram_512x42_dp \
  sram_512x46_dp \
  sram_512x48_dp \
  sram_512x48_sp \
  sram_512x4_dp \
  sram_512x51_dp \
  sram_512x56_dp \
  sram_512x58_dp \
  sram_512x60_dp \
  sram_512x62_dp \
  sram_512x64_dp \
  sram_512x66_dp \
  sram_512x68_dp \
  sram_512x70_dp \
  sram_512x74_dp \
  sram_64x102_sp \
  sram_64x116_sp \
  sram_64x128_sp \
  sram_64x18_sp \
  sram_64x20_dp \
  sram_64x20_sp \
  sram_64x24_dp \
  sram_64x29_dp \
  sram_64x32_dp \
  sram_64x32_sp \
  sram_64x41_dp \
  sram_64x42_dp \
  sram_64x44_dp \
  sram_64x46_dp \
  sram_64x49_dp \
  sram_64x51_dp \
  sram_64x52_dp \
  sram_64x54_dp \
  sram_64x58_dp \
  sram_64x60_dp \
  sram_64x62_dp \
  sram_64x64_dp \
  sram_64x66_dp \
  sram_64x68_dp \
  sram_64x72_dp \
  sram_64x74_dp \
  sram_64x76_dp \
  sram_64x80_dp \
  sram_64x82_sp \
  sram_64x8_dp \
  sram_8192x32_sp \
  sram_8192x40_sp \
  sram_8192x4_sp \
  sram_9792x58_sp \
  sram_9792x64_sp \
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
  set lef_file ${mem_lib_dir}/lef/${mem_name}.lef
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
