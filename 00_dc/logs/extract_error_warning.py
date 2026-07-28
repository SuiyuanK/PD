#!/usr/bin/env python3
"""
Automatically scans for *.log files in the SCRIPT'S directory, 
extracts Errors/Warnings, deduplicates by type, and counts occurrences.
"""

from __future__ import annotations

import re
import sys
from collections import defaultdict
from pathlib import Path
from typing import Dict, List, Tuple

# Regex Patterns
LEVEL_RE = re.compile(r"^\s*(Error|Warning)\s*:\s*(.*)$", re.IGNORECASE)
TYPE_CODE_RE = re.compile(r"\(([A-Za-z][A-Za-z0-9_-]*-\d+)\)\s*$")
LEADING_LOC_RE = re.compile(r"^.+?:\d+\s*:\s*")
QUOTED_RE = re.compile(r"'[^']*'|\"[^\"]*\"")
INDEX_RE = re.compile(r"\[\d+\]")
SPACE_RE = re.compile(r"\s+")

def normalize_message(message: str) -> str:
    """Normalize message text to group similar errors together."""
    s = LEADING_LOC_RE.sub("", message)
    s = QUOTED_RE.sub("<STR>", s)
    s = INDEX_RE.sub("[N]", s)
    s = SPACE_RE.sub(" ", s).strip()
    return s

def parse_line(line: str) -> Tuple[str, str, str] | None:
    """Parse a single log line into (level, type_key, sample_message)."""
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
    """Analyzes the log and returns a summary dictionary."""
    result: Dict[str, Dict[str, object]] = {
        "Error": defaultdict(lambda: {"count": 0, "sample": ""}),
        "Warning": defaultdict(lambda: {"count": 0, "sample": ""}),
    }

    try:
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
    except Exception as e:
        print(f"Error reading {log_path.name}: {e}")

    return result

def format_summary(summary: Dict[str, Dict[str, object]], log_path: Path) -> str:
    """Formats the analysis results into a string for writing to a file."""
    lines: List[str] = []
    lines.append(f"Log: {log_path.absolute()}")
    lines.append("-" * 40)

    for level in ("Error", "Warning"):
        groups = summary[level]
        total = sum(item["count"] for item in groups.values())
        lines.append(f"[{level}] Total: {total}, Unique Types: {len(groups)}")

        # Sort by count descending, then alphabetically by key
        sorted_items = sorted(groups.items(), key=lambda kv: (-kv[1]["count"], kv[0]))
        for type_key, item in sorted_items:
            lines.append(f"- Type:   {type_key}")
            lines.append(f"  Count:  {item['count']}")
            lines.append(f"  Sample: {item['sample']}")
            lines.append("")

        if not groups:
            lines.append("- None")
            lines.append("")

    return "\n".join(lines).rstrip() + "\n"

def main() -> None:
    # CHANGE: Default to script's directory instead of terminal's CWD
    script_dir = Path(__file__).parent.resolve()
    
    # Allow passing a directory as an argument
    target_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else script_dir

    print(f"Scanning directory: {target_dir}")

    input_logs = sorted([
        p for p in target_dir.glob("*.log") 
        if not p.name.endswith("_err_war.log")
    ])

    if not input_logs:
        print(f"No log files found in: {target_dir}")
        return

    for log_path in input_logs:
        summary = analyze_log(log_path)
        text = format_summary(summary, log_path)
        
        # Generate output file name
        out_path = log_path.with_name(f"{log_path.stem}_err_war.log")
        out_path.write_text(text, encoding="utf-8", newline="\n")
        print(f"Generated: {out_path.name}")

if __name__ == "__main__":
    main()