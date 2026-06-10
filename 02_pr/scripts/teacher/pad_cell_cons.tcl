# ============================================================================
# Pad 单元约束定义
# 功能: 创建 Corner、电源/地 Pad、设置 Pad 物理约束和位置
# ============================================================================

# Create corners and P/G pads
create_cell {corner_ll corner_lr corner_ul corner_ur} PLCORNER_D
create_cell {pad_L_VSSC1 pad_L_VSSC2 pad_L_VSSC3 pad_L_VSSC4} PLVSSC
create_cell {pad_L_VDDC1 pad_L_VDDC2 pad_L_VDDC3 pad_L_VDDC4} PLVDDC
#create_cell {pad_L_VSSH1 pad_L_VSSH2 pad_L_VSSH3 pad_L_VSSH4 pad_L_VSSH5 pad_L_VSSH6 pad_L_VSSH7 pad_L_VSSH8} PLVSSH
create_cell {pad_L_VSSH1 pad_L_VSSH2 pad_L_VSSH3 pad_L_VSSH4 pad_L_VSSH5 pad_L_VSSH6 pad_L_VSSH7} PLVSSH
create_cell {pad_L_VDDH1 pad_L_VDDH2 pad_L_VDDH3 pad_L_VDDH4 pad_L_VDDH5 pad_L_VDDH6 pad_L_VDDH7 pad_L_VDDH8} PLVDDH

# Define corner pad locations
# set_pad_physical_constraints -pad_name PLCORNER_D -lib_cell -lib_cell_orientation { FS FE W FW }
set_pad_physical_constraints -pad_name "corner_ul" -side 1
set_pad_physical_constraints -pad_name "corner_ur" -side 2
set_pad_physical_constraints -pad_name "corner_lr" -side 3
set_pad_physical_constraints -pad_name "corner_ll" -side 4

#should modify after commit_fp_rail
#set_attribute [get_cells -all corner_ul] orientation {FS}
#set_attribute [get_cells -all corner_ur] orientation {FE}
#set_attribute [get_cells -all corner_lr] orientation {W}
#set_attribute [get_cells -all corner_ll] orientation {FW}

# set_attribute [get_cells -all corner_ul] origin {0.000 2191.160}
# set_attribute [get_cells -all corner_ur] origin {2193.380 2191.160}
# set_attribute [get_cells -all corner_lr] origin {2193.380 0.000}
# set_attribute [get_cells -all corner_ll] origin {0.000 0.000}

# Define signal and PG  pad locations
# set_pad_physical_constraints -pad_name PLCORNER_D -lib_cell -lib_cell_orientation { S S S S }
# set_pad_physical_constraints -pad_name "PLVDDC" -lib_cell -lib_cell_orientation { S S S S }
# set_pad_physical_constraints -pad_name "PLVSSC" -lib_cell -lib_cell_orientation { S S S S }
# set_pad_physical_constraints -pad_name "PLVDDH" -lib_cell -lib_cell_orientation { S S S S }
# set_pad_physical_constraints -pad_name "PLVSSH" -lib_cell -lib_cell_orientation { S S S S }
# set_pad_physical_constraints -pad_name "PLFILLER30" -lib_cell -lib_cell_orientation { S S S S }
# set_pad_physical_constraints -pad_name "PLFILLER20" -lib_cell -lib_cell_orientation { S S S S }
# set_pad_physical_constraints -pad_name "PLFILLER10" -lib_cell -lib_cell_orientation { S S S S }
# set_pad_physical_constraints -pad_name "PLFILLER5" -lib_cell -lib_cell_orientation { S S S S }
# set_pad_physical_constraints -pad_name "PLFILLER1" -lib_cell -lib_cell_orientation { S S S S }
# set_pad_physical_constraints -pad_name "PLFILLER01" -lib_cell -lib_cell_orientation { S S S S }
# set_pad_physical_constraints -pad_name "PLFILLER001" -lib_cell -lib_cell_orientation { S S S S }
# set_pad_physical_constraints -pad_name "PLFILLER0005" -lib_cell -lib_cell_orientation { S S S S }
# set_pad_physical_constraints -pad_name "PLBI8F" -lib_cell -lib_cell_orientation { S S S S }

# ========== 左侧 Pad 排列定义 ==========
set_pad_physical_constraints -pad_name "U_wb_dat_o_28"  -side 1 -order 26
set_pad_physical_constraints -pad_name "U_wb_dat_o_29"  -side 1 -order 25
set_pad_physical_constraints -pad_name "U_wb_dat_o_30"  -side 1 -order 24
set_pad_physical_constraints -pad_name "U_wb_dat_o_31"  -side 1 -order 23
set_pad_physical_constraints -pad_name "pad_L_VSSH7"    -side 1 -order 22
set_pad_physical_constraints -pad_name "pad_L_VDDH7"    -side 1 -order 21
set_pad_physical_constraints -pad_name "U_wb_adr_i_0"   -side 1 -order 20
set_pad_physical_constraints -pad_name "U_wb_adr_i_1"   -side 1 -order 19
set_pad_physical_constraints -pad_name "U_wb_adr_i_2"   -side 1 -order 18
set_pad_physical_constraints -pad_name "U_wb_adr_i_3"   -side 1 -order 17
set_pad_physical_constraints -pad_name "U_wb_adr_i_4"   -side 1 -order 16
set_pad_physical_constraints -pad_name "U_wb_adr_i_5"   -side 1 -order 15
set_pad_physical_constraints -pad_name "pad_L_VDDC4"    -side 1 -order 14
set_pad_physical_constraints -pad_name "pad_L_VSSC4"    -side 1 -order 13
set_pad_physical_constraints -pad_name "U_wb_sel_i_0"   -side 1 -order 12
set_pad_physical_constraints -pad_name "U_wb_sel_i_1"   -side 1 -order 11
set_pad_physical_constraints -pad_name "U_wb_sel_i_2"   -side 1 -order 10
set_pad_physical_constraints -pad_name "U_wb_sel_i_3"   -side 1 -order 9
set_pad_physical_constraints -pad_name "U_wb_clk_i"     -side 1 -order 8
set_pad_physical_constraints -pad_name "U_wb_rst_i"     -side 1 -order 7
#set_pad_physical_constraints -pad_name "pad_L_VSSH8"   -side 1 -order 6
set_pad_physical_constraints -pad_name "pad_L_VSSH_POS" -side 1 -order 6
set_pad_physical_constraints -pad_name "pad_L_VDDH8"    -side 1 -order 5
set_pad_physical_constraints -pad_name "U_wb_stb_i"     -side 1 -order 4
set_pad_physical_constraints -pad_name "U_wb_we_i"      -side 1 -order 3
set_pad_physical_constraints -pad_name "U_wb_cyc_i"     -side 1 -order 2
set_pad_physical_constraints -pad_name "U_wb_ack_o"     -side 1 -order 1

# ========== 顶部 Pad 排列定义 ==========
set_pad_physical_constraints -pad_name "U_wb_dat_o_27"  -side 2 -order 1
set_pad_physical_constraints -pad_name "U_wb_dat_o_26"  -side 2 -order 2
set_pad_physical_constraints -pad_name "U_wb_dat_o_25"  -side 2 -order 3
set_pad_physical_constraints -pad_name "U_wb_dat_o_24"  -side 2 -order 4
set_pad_physical_constraints -pad_name "pad_L_VSSH5"    -side 2 -order 5
set_pad_physical_constraints -pad_name "pad_L_VDDH5"    -side 2 -order 6
set_pad_physical_constraints -pad_name "U_wb_dat_o_23"  -side 2 -order 7
set_pad_physical_constraints -pad_name "U_wb_dat_o_22"  -side 2 -order 8
set_pad_physical_constraints -pad_name "U_wb_dat_o_21"  -side 2 -order 9
set_pad_physical_constraints -pad_name "U_wb_dat_o_20"  -side 2 -order 10
set_pad_physical_constraints -pad_name "U_wb_dat_o_19"  -side 2 -order 11
set_pad_physical_constraints -pad_name "U_wb_dat_o_18"  -side 2 -order 12
set_pad_physical_constraints -pad_name "pad_L_VDDC3"    -side 2 -order 13
set_pad_physical_constraints -pad_name "pad_L_VSSC3"    -side 2 -order 14
set_pad_physical_constraints -pad_name "U_wb_dat_o_17"  -side 2 -order 15
set_pad_physical_constraints -pad_name "U_wb_dat_o_16"  -side 2 -order 16
set_pad_physical_constraints -pad_name "U_wb_dat_o_15"  -side 2 -order 17
set_pad_physical_constraints -pad_name "U_wb_dat_o_14"  -side 2 -order 18
set_pad_physical_constraints -pad_name "U_wb_dat_o_13"  -side 2 -order 19
set_pad_physical_constraints -pad_name "U_wb_dat_o_12"  -side 2 -order 20
set_pad_physical_constraints -pad_name "U_wb_dat_o_11"  -side 2 -order 21
set_pad_physical_constraints -pad_name "pad_L_VSSH6"    -side 2 -order 22
set_pad_physical_constraints -pad_name "pad_L_VDDH6"    -side 2 -order 23
set_pad_physical_constraints -pad_name "U_wb_dat_o_10"  -side 2 -order 24
set_pad_physical_constraints -pad_name "U_wb_dat_o_9"   -side 2 -order 25
set_pad_physical_constraints -pad_name "U_wb_dat_o_8"   -side 2 -order 26

# ========== 右侧 Pad 排列定义 ==========
set_pad_physical_constraints -pad_name "U_wb_dat_i_20"  -side 3 -order 1
set_pad_physical_constraints -pad_name "U_wb_dat_i_21"  -side 3 -order 2
set_pad_physical_constraints -pad_name "U_wb_dat_i_22"  -side 3 -order 3
set_pad_physical_constraints -pad_name "U_wb_dat_i_23"  -side 3 -order 4
set_pad_physical_constraints -pad_name "pad_L_VSSH3"    -side 3 -order 5
set_pad_physical_constraints -pad_name "pad_L_VDDH3"    -side 3 -order 6
set_pad_physical_constraints -pad_name "U_wb_dat_i_24"  -side 3 -order 7
set_pad_physical_constraints -pad_name "U_wb_dat_i_25"  -side 3 -order 8
set_pad_physical_constraints -pad_name "U_wb_dat_i_26"  -side 3 -order 9
set_pad_physical_constraints -pad_name "U_wb_dat_i_27"  -side 3 -order 10
set_pad_physical_constraints -pad_name "U_wb_dat_i_28"  -side 3 -order 11
set_pad_physical_constraints -pad_name "U_wb_dat_i_29"  -side 3 -order 12
set_pad_physical_constraints -pad_name "pad_L_VDDC2"    -side 3 -order 13
set_pad_physical_constraints -pad_name "pad_L_VSSC2"    -side 3 -order 14
set_pad_physical_constraints -pad_name "U_wb_dat_i_30"  -side 3 -order 15
set_pad_physical_constraints -pad_name "U_wb_dat_i_31"  -side 3 -order 16
set_pad_physical_constraints -pad_name "U_wb_dat_o_0"   -side 3 -order 17
set_pad_physical_constraints -pad_name "U_wb_dat_o_1"   -side 3 -order 18
set_pad_physical_constraints -pad_name "U_wb_dat_o_2"   -side 3 -order 19
set_pad_physical_constraints -pad_name "U_wb_dat_o_3"   -side 3 -order 20
set_pad_physical_constraints -pad_name "pad_L_VSSH4"    -side 3 -order 21
set_pad_physical_constraints -pad_name "pad_L_VDDH4"    -side 3 -order 22
set_pad_physical_constraints -pad_name "U_wb_dat_o_4"   -side 3 -order 23
set_pad_physical_constraints -pad_name "U_wb_dat_o_5"   -side 3 -order 24
set_pad_physical_constraints -pad_name "U_wb_dat_o_6"   -side 3 -order 25
set_pad_physical_constraints -pad_name "U_wb_dat_o_7"   -side 3 -order 26

# ========== 底部 Pad 排列定义 ==========
set_pad_physical_constraints -pad_name "U_wb_dat_i_0"   -side 4 -order 1
set_pad_physical_constraints -pad_name "U_wb_dat_i_1"   -side 4 -order 2
set_pad_physical_constraints -pad_name "U_wb_dat_i_2"   -side 4 -order 3
set_pad_physical_constraints -pad_name "U_wb_dat_i_3"   -side 4 -order 4
set_pad_physical_constraints -pad_name "pad_L_VSSH1"    -side 4 -order 5
set_pad_physical_constraints -pad_name "pad_L_VDDH1"    -side 4 -order 6
set_pad_physical_constraints -pad_name "U_wb_dat_i_4"   -side 4 -order 7
set_pad_physical_constraints -pad_name "U_wb_dat_i_5"   -side 4 -order 8
set_pad_physical_constraints -pad_name "U_wb_dat_i_6"   -side 4 -order 9
set_pad_physical_constraints -pad_name "U_wb_dat_i_7"   -side 4 -order 10
set_pad_physical_constraints -pad_name "U_wb_dat_i_8"   -side 4 -order 11
set_pad_physical_constraints -pad_name "U_wb_dat_i_9"   -side 4 -order 12
set_pad_physical_constraints -pad_name "pad_L_VDDC1"    -side 4 -order 13
set_pad_physical_constraints -pad_name "pad_L_VSSC1"    -side 4 -order 14
set_pad_physical_constraints -pad_name "U_wb_dat_i_10"  -side 4 -order 15
set_pad_physical_constraints -pad_name "U_wb_dat_i_11"  -side 4 -order 16
set_pad_physical_constraints -pad_name "U_wb_dat_i_12"  -side 4 -order 17
set_pad_physical_constraints -pad_name "U_wb_dat_i_13"  -side 4 -order 18
set_pad_physical_constraints -pad_name "U_wb_dat_i_14"  -side 4 -order 19
set_pad_physical_constraints -pad_name "U_wb_dat_i_15"  -side 4 -order 20
set_pad_physical_constraints -pad_name "pad_L_VSSH2"    -side 4 -order 21
set_pad_physical_constraints -pad_name "pad_L_VDDH2"    -side 4 -order 22
set_pad_physical_constraints -pad_name "U_wb_dat_i_16"  -side 4 -order 23
set_pad_physical_constraints -pad_name "U_wb_dat_i_17"  -side 4 -order 24
set_pad_physical_constraints -pad_name "U_wb_dat_i_18"  -side 4 -order 25
set_pad_physical_constraints -pad_name "U_wb_dat_i_19"  -side 4 -order 26
