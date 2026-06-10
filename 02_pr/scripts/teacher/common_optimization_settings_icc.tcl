# ============================================================================
# 通用优化设置 (Common Optimization Settings)
# 功能: 配置时序约束、功率约束、面积约束、DRC 网格优化参数
# ============================================================================

##########################################################################################
# Version: C-2009.06 (Jun 29th, 2009)
# Copyright (C) 2007-2009 Synopsys, Inc. All rights reserved.
##########################################################################################

echo "\tLoading :\t [info script]"
## Optimization Common Session Options - set in all sessions

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# General Optimization
# enable the recovery and removal timing checks 
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# ========== 恢复/移除时序弧与多时钟寄存器 ==========
set_app_var enable_recovery_removal_arcs true
set_app_var timing_enable_multiple_clocks_per_reg true 
set_app_var case_analysis_with_logic_constants true 
set_fix_multiple_port_nets -all -buffer_constants  
set_auto_disable_drc_nets -constant false 
set_timing_derate -max -early 0.95
# set_dont_use <off_limit_cells>
# set_prefer -min <hold_fixing_cells>
set_max_area 0
group_path -name INPUTS -from [all_inputs]
group_path -name OUTPUTS -to [all_outputs]
group_path -name COMBO -from [all_inputs] -to [all_outputs]
# set_ideal_network [all_fanout -flat -clock_tree]
# set_cost_priority {max_transistion max_delay}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
## Fix the locations of the hard macros
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# ========== 硬宏单元放置保护 ==========
if {[all_macro_cells] != "" } { 
  set_dont_touch_placement [all_macro_cells]  
} 

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Timing and optimization control variable settings
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# ========== 时序与物理优化参数 ==========
set_app_var physopt_delete_unloaded_cells false
set_app_var physopt_power_critical_range 0.4
set_app_var physopt_area_critical_range 0.4
set_app_var enable_recovery_removal_arcs true

## Turn on leakage 
## Dynamic power opto throughout the flow
#  set_optimize_pre_cts_power_options -low_power_placement false

# ========== 工作条件设置 ==========
set_operating_conditions \
        -max ss_1p62v_125c \
        -max_library smic18_ss_1p62v_125c \
        -min ff_1p98v_0c \
        -min_library smic18_ff_1p98v_0c

## End of Common Optimization Session Options