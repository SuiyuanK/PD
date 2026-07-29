#!/usr/bin/env bash
# Remove generated files from every STA corner directory while preserving run_pt.tcl.

set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

for corner_dir in "$script_dir"/*/; do
    [[ -f "${corner_dir}run_pt.tcl" ]] || continue

    find "$corner_dir" -depth -mindepth 1 \
        ! -path "${corner_dir%/}/run_pt.tcl" \
        -exec rm -rf -- {} +
done
