set_mismatch_message_filter -warn FMR_ELAB-147
set_app_var synopsys_auto_setup true
set_app_var verification_set_undriven_signals 0:X



set topModuleName       top
set rtl_path            "../../../RTL"   

set_svf ../data/${topModuleName}.svf
#这里的lib 从dc的ss换成了tt max换成了typ

read_db [list   ../data/lib/scc40nll_vhsc40_hvt_tt_v1p1_25c_basic.db    \
                ../data/lib/scc40nll_vhsc40_lvt_tt_v1p1_25c_basic.db    \
                ../data/lib/scc40nll_vhsc40_rvt_tt_v1p1_25c_basic.db    \
                ../data/lib/RAMSP128X16_tt_1p20v_1p20v_25c.db           \
                ../data/lib/RAMSP1024X16_tt_1p20v_1p20v_25c.db          \
                ../data/lib/RAMSP2048X16_tt_1p20v_1p20v_25c.db          \
                ../data/lib/RAMSP4096X16_tt_1p20v_1p20v_25c.db          \
                ../data/lib/RAMTP128X16_tt_1p20v_1p20v_25c.db           \
                ../data/lib/RAMTP1024X16_tt_1p20v_1p20v_25c.db          \
                ../data/lib/SP40NLLD2RN_3P3V_V0p4_tt_V1p10_25C.db   ]


set rtl_list_file "$rtl_path/rtl.list"
if {![file exists $rtl_list_file]} {
    puts "Error: rtl.list not found in $rtl_path"
    exit 1
}

set RTLFileList {}
set file_id [open $rtl_list_file r]
while {[gets $file_id line] != -1} {
    # 去除前后空格
    set line [string trim $line]
    # 跳过空行和以#开头的注释行
    if {[string length $line] == 0 || [string index $line 0] == "#"} {
        continue
    }
    lappend RTLFileList "$rtl_path/$line"
}
close $file_id

# 打印读取到的文件列表（可选）
puts "#++++++++++++++++++++++++++"
puts "RTL Files to be analyzed:"
foreach f $RTLFileList {
    puts $f
}
puts "#++++++++++++++++++++++++++"

foreach rtl_file $RTLFileList {
    set ext [file extension $rtl_file]
    if { $ext eq ".v" } {
        read_verilog -r $rtl_file
    } elseif { $ext eq ".sv" } {
        read_sverilog -r $rtl_file
    }
}

set_top r:/WORK/${topModuleName}

read_verilog -i ../data/${topModuleName}.v
set_top i:/WORK/${topModuleName}

verify

exit