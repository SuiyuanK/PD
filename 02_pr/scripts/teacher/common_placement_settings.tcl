# ============================================================================
# 放置通用设置 (Common Placement Settings)
# 功能: 配置最小/最大布线层、保护距离、Pnet 选项、拥塞分析参数
# ============================================================================

##########################################################################################
# Version: C-2009.06 (Jun 29th, 2009)
# Copyright (C) 2007-2009 Synopsys, Inc. All rights reserved.
##########################################################################################


echo "\tLoading :\t [info script]"

# Placement Common Session Options - set in all sessions

## Set Min/Max Routing Layers
# ========== 布线层范围设置 ==========
if { $MAX_ROUTING_LAYER != ""} {set_ignored_layers -max_routing_layer $MAX_ROUTING_LAYER}
if { $MIN_ROUTING_LAYER != ""} {set_ignored_layers -min_routing_layer $MIN_ROUTING_LAYER}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Placement keepout variable settings
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# ========== 放置保护距离与 Pnet 选项 ==========
set_app_var physopt_hard_keepout_distance 10

#nonexist
#set_app_var placer_soft_keepout_channel_width 15

## Set PNET Options to control cel placement around P/G straps 
remove_pnet_options
set_pnet_options -partial {M5 M6}
report_pnet_options

## Improved congestion analysis by using Global Route info 
# ========== 拥塞分析增强 ==========
echo "SCRIPT-Info : Enabling Global Gouter during placement"
set_app_var placer_enable_enhanced_router true 

## it is recommended to use the default of the tool
## in case it needs to change ( e.g. for low utlization designs), use the command below :
 # set_congestion_options -max_util 0.85