#!/usr/bin/env python3
"""
自动扫描当前目录的 *.log 文件，提取 Error/Warning，按“同类型”去重并统计数量。

同类型判定规则：
1. 优先使用行尾类型码（如 ELAB-366、LINK-5）。
2. 若无类型码，则使用归一化后的消息文本作为类型键。

输出规则：
- 每种类型仅展示一条样例。
- 列出该类型出现次数。
- 对每个输入日志 xxx.log，输出 xxx_err_war.log。

用法示例：
    python extract_error_warning.py
"""

from __future__ import annotations

import re
from collections import defaultdict
from pathlib import Path
from typing import Dict, List, Tuple

LEVEL_RE = re.compile(r"^\s*(Error|Warning)\s*:\s*(.*)$", re.IGNORECASE)
TYPE_CODE_RE = re.compile(r"\(([A-Za-z][A-Za-z0-9_-]*-\d+)\)\s*$")
LEADING_LOC_RE = re.compile(r"^.+?:\d+\s*:\s*")
QUOTED_RE = re.compile(r"'[^']*'|\"[^\"]*\"")
INDEX_RE = re.compile(r"\[\d+\]")
SPACE_RE = re.compile(r"\s+")


def normalize_message(message: str) -> str:
    """归一化消息文本，减少动态字段导致的误分组。"""
    s = LEADING_LOC_RE.sub("", message)
    s = QUOTED_RE.sub("<STR>", s)
    s = INDEX_RE.sub("[N]", s)
    s = SPACE_RE.sub(" ", s).strip()
    return s


def parse_line(line: str) -> Tuple[str, str, str] | None:
    """解析单行日志，返回 (level, type_key, sample_message)。"""
    m = LEVEL_RE.match(line)
    if not m:
        return None

    level = m.group(1).capitalize()
    message = m.group(2).strip()

    code_match = TYPE_CODE_RE.search(message)
    if code_match:
        type_key = code_match.group(1)
    else:
        type_key = normalize_message(message)

    return level, type_key, message


def analyze_log(log_path: Path) -> Dict[str, Dict[str, object]]:
    """
    返回结构：
    {
      "Error": {
         "ELAB-366": {"count": 19, "sample": "..."},
      },
      "Warning": {...}
    }
    """
    result: Dict[str, Dict[str, object]] = {
        "Error": defaultdict(lambda: {"count": 0, "sample": ""}),
        "Warning": defaultdict(lambda: {"count": 0, "sample": ""}),
    }

    with log_path.open("r", encoding="utf-8", errors="ignore") as f:
        for raw_line in f:
            parsed = parse_line(raw_line.rstrip("\n"))
            if not parsed:
                continue

            level, type_key, message = parsed
            bucket = result[level][type_key]
            bucket["count"] += 1
            if not bucket["sample"]:
                bucket["sample"] = message

    return result


def format_summary(summary: Dict[str, Dict[str, object]], log_path: Path) -> str:
    lines: List[str] = []
    lines.append(f"Log: {log_path}")
    lines.append("")

    for level in ("Error", "Warning"):
        groups = summary[level]
        total = sum(item["count"] for item in groups.values())
        lines.append(f"[{level}] 总数: {total}，类型数: {len(groups)}")

        sorted_items = sorted(groups.items(), key=lambda kv: (-kv[1]["count"], kv[0]))
        for type_key, item in sorted_items:
            lines.append(f"- 类型: {type_key}")
            lines.append(f"  数量: {item['count']}")
            lines.append(f"  样例: {item['sample']}")

        if not groups:
            lines.append("- 无")

        lines.append("")

    return "\n".join(lines).rstrip() + "\n"


def find_input_logs(cwd: Path) -> List[Path]:
    """查找当前目录下待处理日志，跳过已生成的汇总日志。"""
    logs = []
    for p in sorted(cwd.glob("*.log")):
        if p.name.endswith("_err_war.log"):
            continue
        logs.append(p)
    return logs


def output_path_for(log_path: Path) -> Path:
    return log_path.with_name(f"{log_path.stem}_err_war.log")


def main() -> None:
    cwd = Path.cwd()
    input_logs = find_input_logs(cwd)

    if not input_logs:
        print(f"当前目录未找到可处理的日志文件: {cwd}")
        return

    for log_path in input_logs:
        summary = analyze_log(log_path)
        text = format_summary(summary, log_path)
        out_path = output_path_for(log_path)
        out_path.write_text(text, encoding="utf-8", newline="\n")
        print(f"已生成: {out_path.name}")


if __name__ == "__main__":
    main()
