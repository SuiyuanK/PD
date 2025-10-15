rm -f ../data/*.v
rm -f ../data/*.svf
# 复制必要文件
cp -v ../../00_dc/outputs/netlist/*.v ../data/
cp -v ../../00_dc/outputs/svf/*.svf   ../data/

rm -rf ../log
mkdir -p ../log
fm_shell -64bit -file run_fm.tcl |tee -i ../log/fm.log

mv *.log ../log/

rm -rf ../tmp_work
mkdir -p ../tmp_work

mv -f ./FM_INFO ../tmp_work/
mv -f ./formality_svf ../tmp_work/