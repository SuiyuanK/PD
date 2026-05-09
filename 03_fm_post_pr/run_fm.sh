rm -rf ./log
mkdir -p ./log

export TOP_MODULE="conv"
export post_dc_Dir="../00_dc/outputs"
export post_pr_Dir="../02_pr/data"

fm_shell -64bit -file ./scripts/run_fm.tcl |tee -i ./log/fm.log

mv *.log ./log/

rm -rf ./tmp_work
mkdir -p ./tmp_work

mv -f ./FM_INFO ./tmp_work/
mv -f ./formality_svf ./tmp_work/