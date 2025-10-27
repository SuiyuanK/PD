################################################################################
#
# Created by icc2 write_floorplan on Mon Oct 27 19:02:19 2025
#
################################################################################


set _dirName__0 [file dirname [file normalize [info script]]]

################################################################################
# Cells
################################################################################

set cellInst [get_cells { u_VIP_Plate_Locate_u_VIP_horizon_projection_u_projection_ram }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1384.1650 341.9020 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_VIP_Plate_Locate_u_VIP_vertical_projection_u_projection_ram }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1384.1650 251.4420 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_VIP_Char_Divide_u_VIP_vertical_projection_char_u_projection_ram }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1384.1650 975.1220 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_VIP_Char_Divide_u_VIP_Bit_Dilation_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1384.1650 1246.5020 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_VIP_Char_Divide_u_VIP_Bit_Dilation_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1384.1650 1336.9620 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_VIP_Plate_Locate_u_Sobel_Edge_Detector_u_matrix_generate_3x3_8bit_u_line_shift_ram_8bit_u_ram_1024x8_1 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1384.1650 794.2020 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_VIP_Plate_Locate_u_Sobel_Edge_Detector_u_matrix_generate_3x3_8bit_u_line_shift_ram_8bit_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1384.1650 884.6620 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_VIP_Plate_Locate_u_VIP_Bit_Erosion_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1384.1650 432.3620 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_VIP_Plate_Locate_u_VIP_Bit_Erosion_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1384.1650 522.8220 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_VIP_Plate_Locate_u_VIP_Bit_Dilation_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1384.1650 613.2820 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_VIP_Plate_Locate_u_VIP_Bit_Dilation_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1384.1650 703.7420 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_VIP_Char_Divide_u_VIP_Bit_Erosion_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1384.1650 1065.5820 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_VIP_Char_Divide_u_VIP_Bit_Erosion_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1384.1650 1156.0420 }
set_attribute -quiet -objects $cellInst -name status -value placed



