#!/bin/bash
mkdir -p analyzed
mkdir -p logs
mkdir -p rpts
mkdir -p outputs
mkdir -p WORK

# 等号两边不能有空格
# Define RTL source files directory
export rtlDir="../../RTL"
export TOP_MODULE="conv"

export exit_switch=true
# 开启只读RTL模式, 其它选项除exit_switch外无效
export read_rtl_only_switch=true

export area_switch=false
export power_switch=false
export fix_hold_switch=false
export remove_tie_dont_use_switch=false

# ultra_switch开启时 high_switch无效
export ultra_switch=false
export high_switch=false


if [ "$read_rtl_only_switch" = "true" ]; then
    echo "Running RTL only mode..."
    dc_shell-xg-t -f ./scripts/dc.tcl |tee -i logs/read_rtl.log
else
    echo "Running full compilation mode..."
    dc_shell-xg-t -f ./scripts/dc.tcl |tee -i logs/compile.log
fi

# if [ "$read_rtl_only_switch" = "true" ]; then
#     echo "Running RTL only mode..."
#     dc_shell-xg-t -f ./scripts/dc.tcl |tee -i logs/read_rtl_$(date +%Y-%m-%d_%H-%M-%S).log
# else
#     echo "Running full compilation mode..."
#     dc_shell-xg-t -f ./scripts/dc.tcl |tee -i logs/compile_$(date +%Y-%m-%d_%H-%M-%S).log
# fi
