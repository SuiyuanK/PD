
#****************************************************
date
#****************************************************

set fix_hold_switch 	            [getenv fix_hold_switch]
set exit_switch 	                [getenv exit_switch]
set area_switch  	                [getenv area_switch]
set power_switch  	                [getenv power_switch]
set ultra_switch 	                [getenv ultra_switch]
set high_switch  	                [getenv high_switch]
set remove_tie_dont_use_switch      [getenv remove_tie_dont_use_switch]
set read_rtl_only_switch            [getenv read_rtl_only_switch]

#****************************************************

# Define working directory
set TOPDIR	            [sh pwd]

# Define RTL source files directory
set rtlDir 		        [getenv rtlDir]
set TOP_MODULE          [getenv TOP_MODULE]                                       

# Output&Reports files directory
set reportsDir          "$TOPDIR/rpts"
set outputsDir          "$TOPDIR/outputs"

set dataDir             "$TOPDIR/data"

# Design Compile system setting
set_app_var search_path                ". $rtlDir"
lappend search_path             "$dataDir/lib"

#****************************************************

# stdcell
set stdcell_libs "
scc40nll_vhsc40_hvt_ss_v0p99_125c_basic.db
scc40nll_vhsc40_lvt_ss_v0p99_125c_basic.db
scc40nll_vhsc40_rvt_ss_v0p99_125c_basic.db"

# memory
set memory_libs "
RAMSP128X16_ss_0p90v_0p90v_125c.db
RAMSP1024X16_ss_0p90v_0p90v_125c.db
RAMSP2048X16_ss_0p90v_0p90v_125c.db
RAMSP4096X16_ss_0p90v_0p90v_125c.db
RAMTP128X16_ss_0p90v_0p90v_125c.db
RAMTP1024X16_ss_0p90v_0p90v_125c.db"

# iopad
set iopad_lib "
SP40NLLD2RN_3P3V_V0p4_ss_V0p99_125C.db"

# set_app_var synthetic_library 	"dw_foundation.sldb" # 优化库

# # symbol library 用于图形化显示的符号库
# set_app_var symbol_library	"smic18io.sdb"
# lappend symbol_library	"smic18.sdb"


set_app_var target_library  "$stdcell_libs"
set_app_var link_library    "* $target_library $memory_libs $iopad_lib"
# set_app_var link_library    	"* $target_library $memory_libs $iopad_lib $synthetic_library"

#****************************************************



# specify directory for intermediate files from analyze
define_design_lib WORK -path WORK

# 输入 h 命令可以查看历史命令，默认保存100条历史命令
alias h history
history keep 100

# specify varibles
set_app_var hdlin_ff_always_sync_set_reset true
set_app_var write_name_nets_same_as_ports true

# reserve unused register
# set_app_var compile_seqmap_propagate_constants false
# set_app_var compile_delete_unloaded_sequential_cells false

# 设置高扇出网络的阈值和引脚电容
set_app_var high_fanout_net_threshold           60
set_app_var high_fanout_net_pin_capacitance     0.01

#****************************************************

if {$read_rtl_only_switch == "true"} {

    set_svf ${outputsDir}/${TOP_MODULE}.svf

    analyze -format verilog -lib WORK  -vcs "-f $rtlDir/rtl_verilog.list"
    # 如果有sv
    # analyze -format sverilog -lib WORK  -vcs "-f $rtlDir/rtl_sverilog.list"
    elaborate $TOP_MODULE

    current_design $TOP_MODULE	

    if { [link] == 0 } {
        echo "Linking Error when deal with $TOP_MODULE"
        exit;
    }
    # 为每个单元实例创建一个唯一的设计，消除当前设计中多重实例化的层级
    uniquify
    if { [check_design] == 0 } {
        echo "Check Design Error when deal with $TOP_MODULE"
        exit;
    }

    write -format ddc -hierarchy -output ${outputsDir}/${TOP_MODULE}_unmapped.ddc

    set_svf -off


    #****************************************************
    #  Finish and Quit
    #****************************************************
    if {$exit_switch == "true"} {
        exit
    }

} else {
    # 增加时钟门控的插入机会并减少设计中时钟门控单元的总数 搭配compile -gate_clock 和 compile_ultra -gate_clock
    set_app_var compile_clock_gating_through_hierarchy true

    set_svf 	${outputsDir}/${TOP_MODULE}.svf  -append

    #Read saved unmapped ddc file
    read_ddc  ${outputsDir}/${TOP_MODULE}_unmapped.ddc

    # # Define The Design Enviroment
    # set_min_library smic18io_line_ss_1p62v_2p97v_125c.db -min_version smic18io_line_ff_1p98v_3p63v_0c.db
    # set_operating_conditions -analysis_type bc_wc -min FF -max SS

    # set_min_library smic18_ss_1p62v_125c.db -min_version  smic18_ff_1p98v_0c.db
    # set_operating_conditions -analysis_type bc_wc -min ff_1p98v_0c -max ss_1p62v_125c

    # set_wire_load_mode  "segmented"
    # set_wire_load_model -name reference_area_10000000 -library smic18_ss_1p62v_125c


    # #****************************************************
    # # List of dont use cells. Avoiding scan and jk flip-flops, latches
    # #****************************************************
    # if 1 {
    # set_dont_use smic18_ss_1p62v_125c/FFSD*
    # set_dont_use smic18_ss_1p62v_125c/FFSED*
    # set_dont_use smic18_ss_1p62v_125c/FFJK*
    # set_dont_use smic18_ss_1p62v_125c/FFSJK*
    # set_dont_use smic18_ff_1p98v_0c/FFSD*
    # set_dont_use smic18_ff_1p98v_0c/FFSED*
    # set_dont_use smic18_ff_1p98v_0c/FFJK*
    # set_dont_use smic18_ff_1p98v_0c/FFSJK*
    # }

    # #****************************************************
    # # remove dont_use attribute
    # #****************************************************
    # if { $remove_tie_dont_use_switch == "true" } {
    #     set_attribute  [get_lib_cells smic18_ss_1p62v_125c/TIE*] dont_touch false
    #     set_attribute  [get_lib_cells smic18_ff_1p98v_0c/TIE*] dont_touch false

    #     set_attribute  [get_lib_cells smic18_ss_1p62v_125c/TIE*] dont_use false
    #     set_attribute  [get_lib_cells smic18_ff_1p98v_0c/TIE*] dont_use false
    # }
    
    current_design $TOP_MODULE
    #****************************************************
    # 读入约束
    source ${dataDir}/${TOP_MODULE}.tcl
    report_clocks -nosplit >  ${reportsDir}/${TOP_MODULE}.clocks.rpt
    #****************************************************


    #****************************************************
    # area and power
    if { $area_switch == "true" } {
        set_max_area     0   
    }
    if { $power_switch == "true" } {
        # # 低功耗布局 需搭配compile_ultra -spg使用 降低设计的总翻转功耗
        # set_app_var power_low_power_placement true
        set_app_var compile_enable_total_power_optimization true
        set_max_total_power 0 uw
        # 动态功耗和漏电优化
        set_dynamic_optimization true
        set_leakage_optimization true
    }
    #****************************************************


    #  Map and Optimize the design
    check_design

    #compile
    #avoid "assign"
    set_app_var verilogout_no_tri true
    set_app_var verilogout_equation false

    set_fix_multiple_port_nets -buffer_constants -all

    if {$ultra_switch == "true"} {
        compile_ultra -gate_clock
    } else {
        if {$high_switch == "true"} {
            compile -map_effort high -boundary_optimization
        } else {
            compile -map_effort medium -boundary_optimization
        }
    }
    
    #  fix_hold_time
    if {$fix_hold_switch == "true"} {
        set_fix_hold [get_clocks *]
        compile -incremental -only_hold_time
    }
    

    check_design  >  ${reportsDir}/${TOP_MODULE}.check_design.rpt
    check_timing  >  ${reportsDir}/${TOP_MODULE}.check_timing.rpt

    #  Output Reports
    report_design       -nosplit >                  ${reportsDir}/${TOP_MODULE}.design.rpt
    report_port         -nosplit >                  ${reportsDir}/${TOP_MODULE}.port.rpt
    report_net          -nosplit >                  ${reportsDir}/${TOP_MODULE}.net.rpt
    report_timing_requirements -nosplit >           ${reportsDir}/${TOP_MODULE}.timing_requirements.rpt
    report_constraint   -nosplit -all_violators >   ${reportsDir}/${TOP_MODULE}.constraint.rpt
    report_timing       -nosplit >                  ${reportsDir}/${TOP_MODULE}.timing.rpt
    report_area         -nosplit >                  ${reportsDir}/${TOP_MODULE}.area.rpt
    report_power        -nosplit >                  ${reportsDir}/${TOP_MODULE}.power.rpt

    #  Change Naming Rule
    remove_unconnected_ports -blast_buses [find -hierarchy cell {"*"}]
    set bus_inference_style {%s[%d]}
    set bus_naming_style {%s[%d]}
    set hdlout_internal_busses true
    change_names -hierarchy -rule verilog
    define_name_rules name_rule -allowed {a-z A-Z 0-9 _} -max_length 255 -type cell
    define_name_rules name_rule -allowed {a-z A-Z 0-9 _[]} -max_length 255 -type net
    define_name_rules name_rule -map {{"\\*cell\\*" "cell"}}
    define_name_rules name_rule -case_insensitive -remove_internal_net_bus -equal_ports_nets
    change_names -hierarchy -rules name_rule


    #  Output Results
    write -format verilog -hierarchy -output    ${outputsDir}/${TOP_MODULE}.v
    write -format ddc -hierarchy -output        ${outputsDir}/${TOP_MODULE}.ddc
    write_sdf                                   ${outputsDir}/${TOP_MODULE}_post_dc.sdf
    write_sdc -nosplit                          ${outputsDir}/${TOP_MODULE}.sdc

    date

    set_svf -off

    #++++++++++++++++++++++++
    # THE END
    #++++++++++++++++++++++++
    set flag [sizeof_collection [get_cells -hier -filter "is_unmapped==true"]]
    if {$flag == 0} {
        puts "--------Synthesis Complete!--------"
    } else {
        puts "--------Synthesis Failed!----------"
    }

    #  Finish and Quit
    if {$exit_switch == "true"} {
        exit
    }
}



