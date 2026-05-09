rm -f ./log/*.log

export rtlDir="../../RTL"
export TOP_MODULE="conv"
export netlistDir="../00_dc/outputs"
export svfDir="../00_dc/outputs"

fm_shell -64bit -file ./scripts/run_fm.tcl |tee -i ./log/fm.log

mv *.log ./log/

rm -rf ./tmp_work
mkdir -p ./tmp_work

mv -f ./FM_INFO ./tmp_work/
mv -f ./formality_svf ./tmp_work/