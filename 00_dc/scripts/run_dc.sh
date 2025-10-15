
dc_shell -f dc.tcl |tee dc.log

mv -f ./-p ../tmp_work/
mv -f ./alib-52 ../tmp_work/
mv -f ./default.svf ../tmp_work/

# 删除log目录（即使不存在也不报错）
rm -rf ../log

mkdir -p ../log
mv dc.log ../log/
mv command.log ../log/
