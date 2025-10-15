################################################################################
#
# Created by icc2 write_floorplan on Wed Oct  8 11:36:34 2025
#
################################################################################


set _dirName__0 [file dirname [file normalize [info script]]]

################################################################################
# Cells
################################################################################

set cellInst [get_cells { u_sram_array_u_sram_9 }]
set_attribute -quiet -objects $cellInst -name orientation -value R0
set_attribute -quiet -objects $cellInst -name origin -value { 683.8770 1265.2590 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_sram_array_u_sram_8 }]
set_attribute -quiet -objects $cellInst -name orientation -value R0
set_attribute -quiet -objects $cellInst -name origin -value { 498.2970 1265.2590 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_sram_array_u_sram_7 }]
set_attribute -quiet -objects $cellInst -name orientation -value R0
set_attribute -quiet -objects $cellInst -name origin -value { 312.7170 1265.2590 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_sram_array_u_sram_6 }]
set_attribute -quiet -objects $cellInst -name orientation -value R0
set_attribute -quiet -objects $cellInst -name origin -value { 1055.0370 1265.2590 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_sram_array_u_sram_5 }]
set_attribute -quiet -objects $cellInst -name orientation -value MX
set_attribute -quiet -objects $cellInst -name origin -value { 312.7170 231.6720 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_sram_array_u_sram_4 }]
set_attribute -quiet -objects $cellInst -name orientation -value MX
set_attribute -quiet -objects $cellInst -name origin -value { 498.2970 231.6720 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_sram_array_u_sram_3 }]
set_attribute -quiet -objects $cellInst -name orientation -value MX
set_attribute -quiet -objects $cellInst -name origin -value { 683.8770 231.6720 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_sram_array_u_sram_2 }]
set_attribute -quiet -objects $cellInst -name orientation -value MX
set_attribute -quiet -objects $cellInst -name origin -value { 869.4570 231.6720 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_sram_array_u_sram_1 }]
set_attribute -quiet -objects $cellInst -name orientation -value MX
set_attribute -quiet -objects $cellInst -name origin -value { 1055.0370 231.6720 }
set_attribute -quiet -objects $cellInst -name status -value placed


set cellInst [get_cells { u_sram_array_u_sram_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R0
set_attribute -quiet -objects $cellInst -name origin -value { 869.4570 1265.2590 }
set_attribute -quiet -objects $cellInst -name status -value placed



