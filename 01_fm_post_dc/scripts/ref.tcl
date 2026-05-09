date
set TOP_MODULE aes_ASIC
set	search_path	"$search_path "

set 	synopsys_auto_setup 	true

read_db "../lib/SMIC18_Ver2.7/FEView_STDIO/STD/Synopsys/smic18_tt_1p8v_25c.db  ../lib/SMIC18_Ver2.7/FEView_STDIO/IO/Synopsys/smic18io_line_tt_1p8v_3p3v_25c.db"

read_verilog -r "${postDCDir}/${TOP_MODULE}.vg"
set_top ${TOP_MODULE}

read_verilog -i "${postAPRDir}/${TOP_MODULE}_sim.vg"
set_top ${TOP_MODULE}

match
if [ verify ] {
	date
	exit
} else {
    # 对最近一次失败的验证运行诊断。默认情况下，此命令诊断实现设计。
  	diagnose
        report_unmatched
        report_failing
        report_error_candidates
}

date