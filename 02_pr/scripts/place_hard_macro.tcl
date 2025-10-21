################################################################################
#
# Created by icc2 write_floorplan on Tue Oct 21 14:18:21 2025
#
################################################################################


set _dirName__0 [file dirname [file normalize [info script]]]

################################################################################
# Cells
################################################################################

set cellInst [get_cells { u_VIP_Plate_Locate_u_VIP_horizon_projection_u_projection_ram }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1384.1650 325.4020 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_VIP_Plate_Locate_u_VIP_vertical_projection_u_projection_ram }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1384.1650 233.3700 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_VIP_Char_Divide_u_VIP_vertical_projection_char_u_projection_ram }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1384.1650 969.1220 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_VIP_Char_Divide_u_VIP_Bit_Dilation_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1384.1650 1245.0020 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_VIP_Char_Divide_u_VIP_Bit_Dilation_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1384.1650 1336.9620 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_VIP_Plate_Locate_u_Sobel_Edge_Detector_u_matrix_generate_3x3_8bit_u_line_shift_ram_8bit_u_ram_1024x8_1 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1384.1650 785.2020 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_VIP_Plate_Locate_u_Sobel_Edge_Detector_u_matrix_generate_3x3_8bit_u_line_shift_ram_8bit_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1384.1650 877.1620 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_VIP_Plate_Locate_u_VIP_Bit_Erosion_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1384.1650 417.3620 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_VIP_Plate_Locate_u_VIP_Bit_Erosion_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1384.1650 509.3220 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_VIP_Plate_Locate_u_VIP_Bit_Dilation_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1384.1650 601.2820 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_VIP_Plate_Locate_u_VIP_Bit_Dilation_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1384.1650 693.2420 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_VIP_Char_Divide_u_VIP_Bit_Erosion_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1384.1650 1061.0820 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_VIP_Char_Divide_u_VIP_Bit_Erosion_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1384.1650 1153.0420 }
set_attribute -quiet -objects $cellInst -name status -value placed

