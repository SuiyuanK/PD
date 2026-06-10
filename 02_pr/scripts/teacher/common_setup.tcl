# ============================================================================
# 通用设置 - 全流程公共变量定义
# 功能: 配置工艺层、库文件路径、设计参数、通用变量
# ============================================================================

##########################################################################################
# Variables common to all RM scripts
# Script: common_setup.tcl
# Version: C-2009.06 (June 29, 2009)
# Copyright (C) 2007-2009 Synopsys All rights reserved.
##########################################################################################

#set DESIGN_NAME                   ""  ;#  The name of the top-level design

#set DESIGN_REF_DATA_PATH          ""  ;#  Absolute path prefix variable for library/design data.
                                       #  Use this variable to prefix the common absolute path to 
                                       #  the common variables defined below.
                                       #  Absolute paths are mandatory for hierarchical RM flow.


##########################################################################################
# Library Setup Variables
##########################################################################################

# For the following variables, use a blank space to separate multiple entries
# Example: set TARGET_LIBRARY_FILES "lib1.db lib2.db lib3.db"

set MIN_ROUTING_LAYER            "M1"   ;# Min routing layer
set MAX_ROUTING_LAYER            "M6"   ;# Max routing layer

set LIBRARY_DONT_USE_FILE        ""   ;# Tcl file with library modifications for dont_use
