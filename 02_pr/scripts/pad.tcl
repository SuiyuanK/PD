# ============================================================================
# pad.tcl - 各边 pad 顺序定义(信号 pad + 电源 pad 混合)
#
# 每边构成: 2 corner(由 create_io_corner_cell 处理) + 信号pad
#          + 1 对 core 电源(PVDD1/PVSS1) + 5 对 IO 电源(PVDD2/PVSS2)
# 电源 pad 插入规则:
#   - 开头/结尾各留 2 个信号 pad(与 corner 隔开)
#   - core 电源对放正中
#   - 5 对 IO 电源尽量均匀分布在 core 两侧(左 2 对 / 右 3 对)
# ============================================================================

# ---- 电源 pad 分配(每边 1 对 core + 5 对 IO) ----
set left_core   { CORE_PVDD1RN_0 CORE_PVSS1RN_0 }
set top_core     { CORE_PVDD1RN_1 CORE_PVSS1RN_1 }
set right_core  { CORE_PVDD1RN_2 CORE_PVSS1RN_2 }
set bottom_core { CORE_PVDD1RN_3 CORE_PVSS1RN_3 }

proc _io_pairs {indices} {
    set r {}
    foreach i $indices { lappend r [list PAD_PVDD2RN_${i} PAD_PVSS2RN_${i}] }
    return $r
}
set left_io   [_io_pairs {00 01 02 03 04}]
set top_io     [_io_pairs {05 06 07 08 09}]
set right_io  [_io_pairs {10 11 12 13 14}]
set bottom_io [_io_pairs {15 16 17 18 19}]

# ---- 在信号 pad 列表中均匀插入电源对 ----
# _distribute: 把 k 个电源对均匀插入 sigs, 信号 pad 分成 k+1 组
proc _distribute {sigs pairs} {
    set k [llength $pairs]
    set g [llength $sigs]
    set base [expr {$g / ($k + 1)}]
    set rem  [expr {$g % ($k + 1)}]
    set result {}
    set s 0
    for {set i 0} {$i <= $k} {incr i} {
        set len [expr {$base + ($i < $rem ? 1 : 0)}]
        lappend result {*}[lrange $sigs $s [expr {$s + $len - 1}]]
        incr s $len
        if {$i < $k} { lappend result {*}[lindex $pairs $i] }
    }
    return $result
}

# interleave_power: 按规则把电源对插进信号 pad 列表, 返回混合列表
proc interleave_power {signals core_pair io_pair_list} {
    set n [llength $signals]
    set start_sig [lrange $signals 0 1]        ;# 开头 2 个信号 pad
    set end_sig   [lrange $signals end-1 end]  ;# 结尾 2 个信号 pad
    set mid_sig   [lrange $signals 2 end-2]    ;# 中间信号 pad
    set M [llength $mid_sig]
    # core 放正中: 左半取 ceil(M/2) 个信号 pad
    set half [expr {($M + 1) / 2}]
    set left_mid  [lrange $mid_sig 0 [expr {$half - 1}]]
    set right_mid [lrange $mid_sig $half end]
    # 5 对 IO 电源: 左侧 2 对, 右侧 3 对
    set left_io  [lrange $io_pair_list 0 1]
    set right_io [lrange $io_pair_list 2 end]
    set left_part  [_distribute $left_mid  $left_io]
    set right_part [_distribute $right_mid $right_io]
    set result {}
    lappend result {*}$start_sig
    lappend result {*}$left_part
    lappend result {*}$core_pair
    lappend result {*}$right_part
    lappend result {*}$end_sig
    return $result
}

set left_pads {
    u_pad_clk_gen_syn_u_pad
    gen_touch_btn_pad_0__u_pad_touch_btn_gen_syn_u_pad
    gen_touch_btn_pad_1__u_pad_touch_btn_gen_syn_u_pad
    gen_touch_btn_pad_2__u_pad_touch_btn_gen_syn_u_pad
    gen_touch_btn_pad_3__u_pad_touch_btn_gen_syn_u_pad
    gen_dip_sw_pad_0__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_1__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_2__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_3__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_4__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_5__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_6__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_7__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_8__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_9__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_10__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_11__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_12__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_13__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_14__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_15__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_16__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_17__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_18__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_19__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_20__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_21__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_22__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_23__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_24__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_25__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_26__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_27__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_28__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_29__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_30__u_pad_dip_sw_gen_syn_u_pad
    gen_dip_sw_pad_31__u_pad_dip_sw_gen_syn_u_pad
    u_pad_spi_miso_gen_syn_u_pad
    gen_base_ram_data_pad_0__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_1__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_2__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_3__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_4__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_5__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_6__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_7__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_8__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_9__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_10__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_11__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_12__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_13__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_14__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_15__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_16__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_17__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_18__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_19__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_20__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_21__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_22__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_23__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_24__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_25__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_26__u_pad_base_ram_data_gen_syn_u_pad
}

set bottom_pads {
    gen_base_ram_data_pad_27__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_28__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_29__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_30__u_pad_base_ram_data_gen_syn_u_pad
    gen_base_ram_data_pad_31__u_pad_base_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_0__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_1__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_2__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_3__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_4__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_5__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_6__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_7__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_8__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_9__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_10__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_11__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_12__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_13__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_14__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_15__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_16__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_17__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_18__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_19__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_20__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_21__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_22__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_23__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_24__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_25__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_26__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_27__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_28__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_29__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_30__u_pad_ext_ram_data_gen_syn_u_pad
    gen_ext_ram_data_pad_31__u_pad_ext_ram_data_gen_syn_u_pad
    gen_flash_d_pad_0__u_pad_flash_d_gen_syn_u_pad
    gen_flash_d_pad_1__u_pad_flash_d_gen_syn_u_pad
    gen_flash_d_pad_2__u_pad_flash_d_gen_syn_u_pad
    gen_flash_d_pad_3__u_pad_flash_d_gen_syn_u_pad
    gen_flash_d_pad_4__u_pad_flash_d_gen_syn_u_pad
    gen_flash_d_pad_5__u_pad_flash_d_gen_syn_u_pad
    gen_flash_d_pad_6__u_pad_flash_d_gen_syn_u_pad
    gen_flash_d_pad_7__u_pad_flash_d_gen_syn_u_pad
    gen_flash_d_pad_8__u_pad_flash_d_gen_syn_u_pad
    gen_flash_d_pad_9__u_pad_flash_d_gen_syn_u_pad
    gen_flash_d_pad_10__u_pad_flash_d_gen_syn_u_pad
    gen_flash_d_pad_11__u_pad_flash_d_gen_syn_u_pad
    gen_flash_d_pad_12__u_pad_flash_d_gen_syn_u_pad
    gen_flash_d_pad_13__u_pad_flash_d_gen_syn_u_pad
    gen_flash_d_pad_14__u_pad_flash_d_gen_syn_u_pad
    gen_flash_d_pad_15__u_pad_flash_d_gen_syn_u_pad
    u_pad_iic_sda_gen_syn_u_pad
    u_pad_uart_rx_gen_syn_u_pad
    u_pad_uart_tx_gen_syn_u_pad
    u_pad_reset_gen_syn_u_pad
    u_pad_spi_ss_gen_syn_u_pad
    gen_video_red_pad_0__u_pad_video_red/gen_syn_u_pad
    gen_video_red_pad_1__u_pad_video_red/gen_syn_u_pad
    gen_video_red_pad_2__u_pad_video_red/gen_syn_u_pad
    gen_video_green_pad_0__u_pad_video_green/gen_syn_u_pad
    gen_video_green_pad_1__u_pad_video_green/gen_syn_u_pad
    gen_video_green_pad_2__u_pad_video_green/gen_syn_u_pad
    gen_video_blue_pad_0__u_pad_video_blue/gen_syn_u_pad
    gen_video_blue_pad_1__u_pad_video_blue/gen_syn_u_pad
}

set right_pads {
    u_pad_video_hsync/gen_syn_u_pad
    u_pad_video_vsync/gen_syn_u_pad
    u_pad_video_clk/gen_syn_u_pad
    u_pad_video_de/gen_syn_u_pad
    gen_leds_pad_0__u_pad_leds/gen_syn_u_pad
    gen_leds_pad_1__u_pad_leds/gen_syn_u_pad
    gen_leds_pad_2__u_pad_leds/gen_syn_u_pad
    gen_leds_pad_3__u_pad_leds/gen_syn_u_pad
    gen_leds_pad_4__u_pad_leds/gen_syn_u_pad
    gen_leds_pad_5__u_pad_leds/gen_syn_u_pad
    gen_leds_pad_6__u_pad_leds/gen_syn_u_pad
    gen_leds_pad_7__u_pad_leds/gen_syn_u_pad
    gen_leds_pad_8__u_pad_leds/gen_syn_u_pad
    gen_leds_pad_9__u_pad_leds/gen_syn_u_pad
    gen_leds_pad_10__u_pad_leds/gen_syn_u_pad
    gen_leds_pad_11__u_pad_leds/gen_syn_u_pad
    gen_leds_pad_12__u_pad_leds/gen_syn_u_pad
    gen_leds_pad_13__u_pad_leds/gen_syn_u_pad
    gen_leds_pad_14__u_pad_leds/gen_syn_u_pad
    gen_leds_pad_15__u_pad_leds/gen_syn_u_pad
    gen_dpy0_pad_0__u_pad_dpy0/gen_syn_u_pad
    gen_dpy0_pad_1__u_pad_dpy0/gen_syn_u_pad
    gen_dpy0_pad_2__u_pad_dpy0/gen_syn_u_pad
    gen_dpy0_pad_3__u_pad_dpy0/gen_syn_u_pad
    gen_dpy0_pad_4__u_pad_dpy0/gen_syn_u_pad
    gen_dpy0_pad_5__u_pad_dpy0/gen_syn_u_pad
    gen_dpy0_pad_6__u_pad_dpy0/gen_syn_u_pad
    gen_dpy0_pad_7__u_pad_dpy0/gen_syn_u_pad
    gen_dpy1_pad_0__u_pad_dpy1/gen_syn_u_pad
    gen_dpy1_pad_1__u_pad_dpy1/gen_syn_u_pad
    gen_dpy1_pad_2__u_pad_dpy1/gen_syn_u_pad
    gen_dpy1_pad_3__u_pad_dpy1/gen_syn_u_pad
    gen_dpy1_pad_4__u_pad_dpy1/gen_syn_u_pad
    gen_dpy1_pad_5__u_pad_dpy1/gen_syn_u_pad
    gen_dpy1_pad_6__u_pad_dpy1/gen_syn_u_pad
    gen_dpy1_pad_7__u_pad_dpy1/gen_syn_u_pad
    gen_base_ram_addr_pad_0__u_pad_base_ram_addr/gen_syn_u_pad
    gen_base_ram_addr_pad_1__u_pad_base_ram_addr/gen_syn_u_pad
    gen_base_ram_addr_pad_2__u_pad_base_ram_addr/gen_syn_u_pad
    gen_base_ram_addr_pad_3__u_pad_base_ram_addr/gen_syn_u_pad
    gen_base_ram_addr_pad_4__u_pad_base_ram_addr/gen_syn_u_pad
    gen_base_ram_addr_pad_5__u_pad_base_ram_addr/gen_syn_u_pad
    gen_base_ram_addr_pad_6__u_pad_base_ram_addr/gen_syn_u_pad
    gen_base_ram_addr_pad_7__u_pad_base_ram_addr/gen_syn_u_pad
    gen_base_ram_addr_pad_8__u_pad_base_ram_addr/gen_syn_u_pad
    gen_base_ram_addr_pad_9__u_pad_base_ram_addr/gen_syn_u_pad
    gen_base_ram_addr_pad_10__u_pad_base_ram_addr/gen_syn_u_pad
    gen_base_ram_addr_pad_11__u_pad_base_ram_addr/gen_syn_u_pad
    gen_base_ram_addr_pad_12__u_pad_base_ram_addr/gen_syn_u_pad
    gen_base_ram_addr_pad_13__u_pad_base_ram_addr/gen_syn_u_pad
    gen_base_ram_addr_pad_14__u_pad_base_ram_addr/gen_syn_u_pad
    gen_base_ram_addr_pad_15__u_pad_base_ram_addr/gen_syn_u_pad
    gen_base_ram_addr_pad_16__u_pad_base_ram_addr/gen_syn_u_pad
    gen_base_ram_addr_pad_17__u_pad_base_ram_addr/gen_syn_u_pad
    gen_base_ram_addr_pad_18__u_pad_base_ram_addr/gen_syn_u_pad
    gen_base_ram_addr_pad_19__u_pad_base_ram_addr/gen_syn_u_pad
    gen_base_ram_be_pad_0__u_pad_base_ram_be_n/gen_syn_u_pad
    gen_base_ram_be_pad_1__u_pad_base_ram_be_n/gen_syn_u_pad
    gen_base_ram_be_pad_2__u_pad_base_ram_be_n/gen_syn_u_pad
    gen_base_ram_be_pad_3__u_pad_base_ram_be_n/gen_syn_u_pad
    u_pad_base_ram_ce_n/gen_syn_u_pad
    u_pad_base_ram_oe_n/gen_syn_u_pad
    u_pad_base_ram_we_n/gen_syn_u_pad
    gen_ext_ram_addr_pad_0__u_pad_ext_ram_addr/gen_syn_u_pad
    gen_ext_ram_addr_pad_1__u_pad_ext_ram_addr/gen_syn_u_pad
}

set top_pads {
    gen_ext_ram_addr_pad_2__u_pad_ext_ram_addr/gen_syn_u_pad
    gen_ext_ram_addr_pad_3__u_pad_ext_ram_addr/gen_syn_u_pad
    gen_ext_ram_addr_pad_4__u_pad_ext_ram_addr/gen_syn_u_pad
    gen_ext_ram_addr_pad_5__u_pad_ext_ram_addr/gen_syn_u_pad
    gen_ext_ram_addr_pad_6__u_pad_ext_ram_addr/gen_syn_u_pad
    gen_ext_ram_addr_pad_7__u_pad_ext_ram_addr/gen_syn_u_pad
    gen_ext_ram_addr_pad_8__u_pad_ext_ram_addr/gen_syn_u_pad
    gen_ext_ram_addr_pad_9__u_pad_ext_ram_addr/gen_syn_u_pad
    gen_ext_ram_addr_pad_10__u_pad_ext_ram_addr/gen_syn_u_pad
    gen_ext_ram_addr_pad_11__u_pad_ext_ram_addr/gen_syn_u_pad
    gen_ext_ram_addr_pad_12__u_pad_ext_ram_addr/gen_syn_u_pad
    gen_ext_ram_addr_pad_13__u_pad_ext_ram_addr/gen_syn_u_pad
    gen_ext_ram_addr_pad_14__u_pad_ext_ram_addr/gen_syn_u_pad
    gen_ext_ram_addr_pad_15__u_pad_ext_ram_addr/gen_syn_u_pad
    gen_ext_ram_addr_pad_16__u_pad_ext_ram_addr/gen_syn_u_pad
    gen_ext_ram_addr_pad_17__u_pad_ext_ram_addr/gen_syn_u_pad
    gen_ext_ram_addr_pad_18__u_pad_ext_ram_addr/gen_syn_u_pad
    gen_ext_ram_addr_pad_19__u_pad_ext_ram_addr/gen_syn_u_pad
    gen_ext_ram_be_pad_0__u_pad_ext_ram_be_n/gen_syn_u_pad
    gen_ext_ram_be_pad_1__u_pad_ext_ram_be_n/gen_syn_u_pad
    gen_ext_ram_be_pad_2__u_pad_ext_ram_be_n/gen_syn_u_pad
    gen_ext_ram_be_pad_3__u_pad_ext_ram_be_n/gen_syn_u_pad
    u_pad_ext_ram_ce_n/gen_syn_u_pad
    u_pad_ext_ram_oe_n/gen_syn_u_pad
    u_pad_ext_ram_we_n/gen_syn_u_pad
    gen_flash_a_pad_0__u_pad_flash_a/gen_syn_u_pad
    gen_flash_a_pad_1__u_pad_flash_a/gen_syn_u_pad
    gen_flash_a_pad_2__u_pad_flash_a/gen_syn_u_pad
    gen_flash_a_pad_3__u_pad_flash_a/gen_syn_u_pad
    gen_flash_a_pad_4__u_pad_flash_a/gen_syn_u_pad
    gen_flash_a_pad_5__u_pad_flash_a/gen_syn_u_pad
    gen_flash_a_pad_6__u_pad_flash_a/gen_syn_u_pad
    gen_flash_a_pad_7__u_pad_flash_a/gen_syn_u_pad
    gen_flash_a_pad_8__u_pad_flash_a/gen_syn_u_pad
    gen_flash_a_pad_9__u_pad_flash_a/gen_syn_u_pad
    gen_flash_a_pad_10__u_pad_flash_a/gen_syn_u_pad
    gen_flash_a_pad_11__u_pad_flash_a/gen_syn_u_pad
    gen_flash_a_pad_12__u_pad_flash_a/gen_syn_u_pad
    gen_flash_a_pad_13__u_pad_flash_a/gen_syn_u_pad
    gen_flash_a_pad_14__u_pad_flash_a/gen_syn_u_pad
    gen_flash_a_pad_15__u_pad_flash_a/gen_syn_u_pad
    gen_flash_a_pad_16__u_pad_flash_a/gen_syn_u_pad
    gen_flash_a_pad_17__u_pad_flash_a/gen_syn_u_pad
    gen_flash_a_pad_18__u_pad_flash_a/gen_syn_u_pad
    gen_flash_a_pad_19__u_pad_flash_a/gen_syn_u_pad
    gen_flash_a_pad_20__u_pad_flash_a/gen_syn_u_pad
    gen_flash_a_pad_21__u_pad_flash_a/gen_syn_u_pad
    gen_flash_a_pad_22__u_pad_flash_a/gen_syn_u_pad
    u_pad_flash_rp_n/gen_syn_u_pad
    u_pad_flash_vpen/gen_syn_u_pad
    u_pad_flash_ce_n/gen_syn_u_pad
    u_pad_flash_oe_n/gen_syn_u_pad
    u_pad_flash_we_n/gen_syn_u_pad
    u_pad_flash_byte_n/gen_syn_u_pad
    u_pad_iic_scl/gen_syn_u_pad
    u_pad_spi_mosi/gen_syn_u_pad
    u_pad_spi_sclk/gen_syn_u_pad
    gen_pwm_pad_0__u_pad_pwm/gen_syn_u_pad
    gen_pwm_pad_1__u_pad_pwm/gen_syn_u_pad
    gen_pwm_pad_2__u_pad_pwm/gen_syn_u_pad
    gen_pwm_pad_3__u_pad_pwm/gen_syn_u_pad
    gen_pwm_pad_4__u_pad_pwm/gen_syn_u_pad
    gen_pwm_pad_5__u_pad_pwm/gen_syn_u_pad
    gen_pwm_pad_6__u_pad_pwm/gen_syn_u_pad
    gen_pwm_pad_7__u_pad_pwm/gen_syn_u_pad
}

# ---- 把电源 pad 插入各边信号 pad 列表(重定义 left_pads 等为混合列表) ----
set left_pads   [interleave_power $left_pads   $left_core   $left_io]
set top_pads    [interleave_power $top_pads    $top_core    $top_io]
set right_pads  [interleave_power $right_pads  $right_core  $right_io]
set bottom_pads [interleave_power $bottom_pads $bottom_core $bottom_io]


