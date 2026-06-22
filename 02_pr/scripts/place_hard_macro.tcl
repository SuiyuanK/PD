################################################################################
#
# Created by icc2 write_floorplan on Sun Jun 21 19:09:43 2026
#
################################################################################


set _dirName__0 [file dirname [file normalize [info script]]]

################################################################################
# Cells
################################################################################

set cellInst [get_cells { u_soc_top_ASIC_u_AXI_FFT_IFFT_Briage_u_fft_ctrl_axi_u_out_ram_imag }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 2803.6000 306.7350 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_soc_top_ASIC_u_AXI_FFT_IFFT_Briage_u_fft_ctrl_axi_u_out_ram_real }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 2944.7150 306.7350 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_soc_top_ASIC_u_AXI_FFT_IFFT_Briage_u_fft_ctrl_axi_u_in_ram_imag }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 2098.0250 306.7350 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_soc_top_ASIC_u_AXI_FFT_IFFT_Briage_u_fft_ctrl_axi_u_in_ram_real }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1815.7950 306.7350 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_soc_top_ASIC_u_AXI_FFT_IFFT_Briage_u_fft_ctrl_axi_u_fft_core_natural_u_reorder_bank1_imag }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 2521.3700 306.7350 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_soc_top_ASIC_u_AXI_FFT_IFFT_Briage_u_fft_ctrl_axi_u_fft_core_natural_u_reorder_bank1_real }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 2662.4850 306.7350 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_soc_top_ASIC_u_AXI_FFT_IFFT_Briage_u_fft_ctrl_axi_u_fft_core_natural_u_reorder_bank0_imag }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 3085.8300 306.7350 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_soc_top_ASIC_u_AXI_FFT_IFFT_Briage_u_fft_ctrl_axi_u_fft_core_natural_u_reorder_bank0_real }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 2380.2550 306.7350 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_soc_top_ASIC_u_AXI_FFT_IFFT_Briage_u_fft_ctrl_axi_u_fft_core_FFT_INST_fft_ins_stagX_11__u_fft_stage_BF_inst_I_u0_shiftTaps_genblk1_RAMTP1024_D1023_u1_RAMTP1024X16 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1955.1150 330.9700 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_soc_top_ASIC_u_AXI_FFT_IFFT_Briage_u_fft_ctrl_axi_u_fft_core_FFT_INST_fft_ins_stagX_11__u_fft_stage_BF_inst_I_u0_shiftTaps_genblk1_RAMTP1024_D1023_u0_RAMTP1024X16 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 2237.3450 330.9700 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_soc_top_ASIC_u_AXI_FFT_IFFT_Briage_u_fft_ctrl_axi_u_fft_core_FFT_INST_fft_ins_stagX_11__u_fft_stage_BF_inst_I_u1_shiftTaps_genblk1_RAMTP1024_D1023_u1_RAMTP1024X16 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 2237.3450 163.5950 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_soc_top_ASIC_u_AXI_FFT_IFFT_Briage_u_fft_ctrl_axi_u_fft_core_FFT_INST_fft_ins_stagX_11__u_fft_stage_BF_inst_I_u1_shiftTaps_genblk1_RAMTP1024_D1023_u0_RAMTP1024X16 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 2096.2300 163.5950 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_soc_top_ASIC_u_AXI_FFT_IFFT_Briage_u_fft_ctrl_axi_u_fft_core_FFT_INST_fft_ins_stagX_11__u_fft_stage_LARGER_THAN_2_BF_inst_II_u0_shiftTaps_genblk1_RAMTP1024_D511_u1_RAMTP1024X16 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 2660.6900 163.5950 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_soc_top_ASIC_u_AXI_FFT_IFFT_Briage_u_fft_ctrl_axi_u_fft_core_FFT_INST_fft_ins_stagX_11__u_fft_stage_LARGER_THAN_2_BF_inst_II_u0_shiftTaps_genblk1_RAMTP1024_D511_u0_RAMTP1024X16 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 2801.8050 163.5950 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_soc_top_ASIC_u_AXI_FFT_IFFT_Briage_u_fft_ctrl_axi_u_fft_core_FFT_INST_fft_ins_stagX_11__u_fft_stage_LARGER_THAN_2_BF_inst_II_u1_shiftTaps_genblk1_RAMTP1024_D511_u1_RAMTP1024X16 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 3084.0350 163.5950 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_soc_top_ASIC_u_AXI_FFT_IFFT_Briage_u_fft_ctrl_axi_u_fft_core_FFT_INST_fft_ins_stagX_11__u_fft_stage_LARGER_THAN_2_BF_inst_II_u1_shiftTaps_genblk1_RAMTP1024_D511_u0_RAMTP1024X16 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 2942.9200 163.5950 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_soc_top_ASIC_u_AXI_FFT_IFFT_Briage_u_fft_ctrl_axi_u_fft_core_FFT_INST_fft_ins_stagX_9__u_fft_stage_BF_inst_I_u0_shiftTaps_genblk1_RAMTP1024_D255_u1_RAMTP1024X16 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 2378.4600 163.5950 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_soc_top_ASIC_u_AXI_FFT_IFFT_Briage_u_fft_ctrl_axi_u_fft_core_FFT_INST_fft_ins_stagX_9__u_fft_stage_BF_inst_I_u0_shiftTaps_genblk1_RAMTP1024_D255_u0_RAMTP1024X16 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1955.1150 163.5950 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_soc_top_ASIC_u_AXI_FFT_IFFT_Briage_u_fft_ctrl_axi_u_fft_core_FFT_INST_fft_ins_stagX_9__u_fft_stage_BF_inst_I_u1_shiftTaps_genblk1_RAMTP1024_D255_u1_RAMTP1024X16 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 2519.5750 163.5950 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_soc_top_ASIC_u_AXI_FFT_IFFT_Briage_u_fft_ctrl_axi_u_fft_core_FFT_INST_fft_ins_stagX_9__u_fft_stage_BF_inst_I_u1_shiftTaps_genblk1_RAMTP1024_D255_u0_RAMTP1024X16 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1814.0000 163.5950 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_soc_top_ASIC_u_AXI_FFT_IFFT_Briage_u_fft_ctrl_axi_u_fft_core_FFT_INST_fft_ins_stagX_9__u_fft_stage_LARGER_THAN_2_BF_inst_II_u0_shiftTaps_genblk1_RAMTP128_D127_u1_RAMTP128X16 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 3151.1200 660.0600 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_soc_top_ASIC_u_AXI_FFT_IFFT_Briage_u_fft_ctrl_axi_u_fft_core_FFT_INST_fft_ins_stagX_9__u_fft_stage_LARGER_THAN_2_BF_inst_II_u0_shiftTaps_genblk1_RAMTP128_D127_u0_RAMTP128X16 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 3151.1200 777.8350 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_soc_top_ASIC_u_AXI_FFT_IFFT_Briage_u_fft_ctrl_axi_u_fft_core_FFT_INST_fft_ins_stagX_9__u_fft_stage_LARGER_THAN_2_BF_inst_II_u1_shiftTaps_genblk1_RAMTP128_D127_u1_RAMTP128X16 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 3151.1200 542.2850 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_soc_top_ASIC_u_AXI_FFT_IFFT_Briage_u_fft_ctrl_axi_u_fft_core_FFT_INST_fft_ins_stagX_9__u_fft_stage_LARGER_THAN_2_BF_inst_II_u1_shiftTaps_genblk1_RAMTP128_D127_u0_RAMTP128X16 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 3151.1200 424.5100 }
set_attribute -quiet -objects $cellInst -name status -value placed



