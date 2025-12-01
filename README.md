# 后端全流程

## 00_dc
1. 修改 `scripts/dc.tcl` 里面的工艺库路径和相应的 RTL 路径
2. 把 `scripts` 目录下的 `find_rtl.py` 放 RTL 文件夹下运行，生成 `rtl.list` 文件（生成相对路径，该 `.py` 仅在 Windows 下测试过）
3. 在 `scripts` 目录下运行 `run_dc.sh` 即可

## 01_fm
1. 修改 `scripts` 下 `run_fm.tcl` 或者 `run_fm_dc_vs_pr.tcl` 里面的工艺库路径
2. 运行相应 `.sh` 文件即可
3. dc vs pr 的网表要吃库的 `.v` 文件，svf 可不吃

## 02_pr
1. 根据实际情况修改 `scripts` 下的脚本
2. 在 `02_pr` 目录下启动 `icc2_shell` 再吃 `scripts` 下对应的脚本

## 03_pt
1. 修改对应的库路径

## 其它类似操作