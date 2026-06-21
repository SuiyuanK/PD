#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
脚本功能：
    遍历 02_pr/data 目录下所有 *.sdc 文件，将其中以指定命令开头的行用 '#' 注释掉
    （行首已有 '#' 的不重复注释）。

    用于 PR 阶段取消 DC 侧遗留、但在 PR 中不再适用或不该保留的约束：
      - set_ideal_network：避免在 ICC2 中继续传播理想网络约束，影响 CTS / 时序优化
      - set_max_area：面积约束在 PR 阶段无意义（由 floorplan/utilization 决定），应去掉
      - set_case_analysis：常用于 DC 阶段把复位等信号钉成常量以辅助优化，但会做常量
        传播，禁用异步复位 recovery/removal 时序检查，并可能影响复位树的 transition/
        capacitance 收敛。PR/STA 阶段应改由 set_false_path 声明异步路径，故注释掉。
      - set_max_fanout：该命令在 ICC2 中不被支持（man 显示 "This command is not
        supported"），读入后不会对 fanout DRC 起任何作用，留着只会产生 warning 并
        误导约束阅读。clk 由 CTS 建树、reset 树由 transition/load DRC 驱动 buffer
        插入，均不依赖此命令，故一律注释。

运行方式：
    在本脚本所在目录 (02_pr/data) 下执行：
        python comment_sdc_commands.py

    也可对单个 sdc 文件运行：
        python comment_sdc_commands.py path/to/xxx.sdc
"""

import os
import sys
import glob

# 需要注释的命令（行首允许空白）
TARGET_CMDS = (
    "set_ideal_network",
    "set_max_area",
    "set_case_analysis",
    "set_max_fanout",
)


def comment_target_lines(filepath):
    """注释掉指定 sdc 文件中所有目标命令行，返回被注释的行数。"""
    with open(filepath, "r", encoding="utf-8", errors="replace", newline="") as f:
        lines = f.readlines()

    changed = 0
    new_lines = []
    for line in lines:
        stripped = line.lstrip()
        # 已注释行不重复处理
        if stripped.startswith("#"):
            new_lines.append(line)
            continue
        # 命中任一目标命令则注释
        if stripped.startswith(TARGET_CMDS):
            new_lines.append("# " + line)
            changed += 1
        else:
            new_lines.append(line)

    if changed > 0:
        with open(filepath, "w", encoding="utf-8", newline="") as f:
            f.writelines(new_lines)

    return changed


def main():
    # 默认处理脚本所在目录下的 *.sdc；也可传入指定的 sdc 文件
    if len(sys.argv) > 1:
        files = [a for a in sys.argv[1:] if a.lower().endswith(".sdc") and os.path.isfile(a)]
    else:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        files = sorted(glob.glob(os.path.join(script_dir, "*.sdc")))

    if not files:
        print("未找到任何 .sdc 文件。")
        return

    total = 0
    for fp in files:
        n = comment_target_lines(fp)
        print(f"[{fp}] 注释目标命令行数: {n}")
        total += n

    print(f"完成。共处理 {len(files)} 个 sdc 文件，注释 {total} 行。")


if __name__ == "__main__":
    main()
