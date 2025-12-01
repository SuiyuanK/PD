rm -f ../data/*.v
rm -f ../data/*.svf
# 复制必要文件
cp -v ../../00_dc/outputs/netlist/*.v ../data/
cp -v ../../00_dc/outputs/svf/*.svf   ../data/
cp -v ../../eco/outputs/image_icb.v.gz  ../data/

rm -f ../log/fm_pr.log
fm_shell -64bit -file run_fm_dc_vs_pr.tcl |tee -i ../log/fm_pr.log

mv *.log ../log/

rm -rf ../tmp_work
mkdir -p ../tmp_work

mv -f ./FM_INFO ../tmp_work/
mv -f ./formality_svf ../tmp_work/