rm -rf ../data/pr_outputs
# 复制必要文件
mkdir -p ../data/pr_outputs
cp -rv ../../02_pr/outputs ../data/pr_outputs

rm -rf ./log
mkdir -p ./log

icwbev -run icw_merge_cells.tcl |tee -i ./log/icw.log