# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

This repository is a Tcl- and shell-driven digital IC physical-design (digital backend) reference flow, built from an embedded-systems competition project and refined across subsequent projects. It contains project-specific examples for Synopsys Design Compiler, Formality, IC Compiler II (ICC2), PrimeTime, StarRC, Siemens EDA (Mentor) Calibre, and Ansys/Apache RedHawk.

It is not a conventional software package: there is no root build system, CI workflow, lint command, or automated test suite. Validate changes using the smallest affected EDA stage or corner, then inspect the real tool log, reports, database state, and expected artifacts.

Scripts target a licensed Linux/Unix EDA environment. Bash/C shell wrappers, `tee`, background jobs, and proprietary tool binaries are not directly runnable in Windows PowerShell. Most scripts require execution from their own stage directory because they use relative paths. PDKs, libraries, RTL, rule decks, and generated artifacts can be absent, ignored, proprietary, or machine-local.

Interpret repository Tcl as Synopsys EDA Tcl, not generic Tcl. `.vscode/settings.json` uses the `synopsys-eda-tcl` dialect.

For detailed Chinese user-facing workflow guidance, use [README.md](README.md). Keep this file focused on agent execution constraints and high-risk checks.

## Architecture and configuration boundaries

The numbered directories express a nominal dependency order:

1. `00_dc/` — RTL synthesis; produces netlist, SDC, DDC, SVF, reports, and logs.
2. `01_fm_post_dc/` — RTL-to-synthesized-netlist Formality verification.
3. `02_pr/` — ICC2 physical implementation; `01_import_netlist.tcl` through `09_chipfinish.tcl` use stage NDM databases.
4. `03_fm_post_pr/` — synthesized-versus-PR-netlist Formality verification.
5. `04_pt/` — StarRC extraction and PrimeTime STA.
6. `05_pv/` — GDS merge, DRC/Antenna, LVS, and Dummy Fill-related material.
7. `06_power/` — APL-DI preparation plus RedHawk power-integrity and signal-EM analysis.
8. `07_signoff_check/` — loaded-session ICC2/PrimeTime helper snippets, not an automated signoff suite.

Do **not** assume those directories form one currently runnable design. Checked-in project configurations include:

| Areas | Current example/configuration | Required handling |
| --- | --- | --- |
| `00_dc/`, `01_fm_post_dc/` | `CNN` | Default RTL directory, lists, netlist, and SVF are not included. |
| `02_pr/` | `soc_pad_wrapper` | `01_import_netlist.tcl` expects project inputs such as `data/soc_pad_wrapper.v`, which are not checked in. |
| `03_fm_post_pr/` | `conv` | Synchronize design name, producer paths, compressed-netlist handling, and `TOPDIR`/`topDir` before use. |
| `eco/`, `04_pt/`, `05_pv/`, `06_power/` | largely `image_icb` | These are later-project/ECO configurations, not automatic consumers of `02_pr` output. |

Treat all project names, absolute paths, libraries, corners, rule decks, and output paths as project configuration—not portable defaults. Before crossing a stage boundary, reconcile the top module, netlist/SDC/SVF/DEF/GDS/SPEF names, standard-cell/I/O/macro libraries, power nets, PVT and RC corners, MCMM scenarios, and output consumers.

## High-value commands and stage rules

### DC and Formality

```bash
cd 00_dc
./run_dc.sh

cd ../01_fm_post_dc
./run_fm.sh
```

`00_dc/run_dc.sh` invokes `scripts/dc.tcl`; adapt `rtlDir`, `TOP_MODULE`, library paths, and compile switches first. `scripts/find_rtl.py` scans the directory containing the script and writes `rtl_verilog.list` and `rtl_sverilog.list` beside it. The full-compile default also needs its expected prior project artifacts.

Formality wrappers clear/recreate logs and temporary work. Check Formality's final `verify` result and unresolved references, not the wrapper status alone.

The checked-in post-PR Formality wrapper is blocked until its `conv` configuration, `post_pr_Dir`, `.v.gz` handling, DC/PR naming, and Tcl `TOPDIR`/`topDir` mismatch are adapted together.

### ICC2 physical implementation

```bash
cd 02_pr
icc2_shell -f scripts/01_import_netlist.tcl
```

`00_common_design_settings.tcl` is sourced shared configuration, not an executable flow entry. The numbered scripts are dependency order, **not** a batch to run blindly from `01` to `09`.

After import, iterate on `02_floorplan.tcl` and `03_power_routing.tcl` for the actual design. Check utilization, macro placement, I/O/Pad planning, supply topology, metal stack, IR drop, EM, congestion, and timing after each iteration. Advance to placement, CTS, routing, route optimization, and chip finish only after the physical foundation is stable.

A later numbered stage requires the preceding NDM database. Several stages force-delete their target NDM database/report directories. `09_chipfinish.tcl` recreates `02_pr/outputs/`; preserve needed results, and verify actual LEF/TLEF output artifacts instead of assuming every declared path was written.

### StarRC, PrimeTime, PV, and ECO

Run extraction before STA:

```bash
cd 04_pt/starrc
./run_starrc.sh
# Wait for every background corner and inspect extraction outputs.

cd ../sta/<adapted-corner>
pt_shell -f run_pt.tcl
```

`run_starrc.sh` starts configured corners in the background without `wait`; `run_pt.sh` has no fail-fast or aggregate status. Current extraction/STA settings consume `image_icb` ECO NDM state, not the `02_pr` default output.

`05_pv/merge/icw/run_icw.csh`, `merge/Calibredrv/merge.tcl`, DRC/Antenna runsets, and LVS scripts are separate paths that do not automatically connect. They contain destructive local cleanup, external/machine paths, and stale `04_pv`/`image_icb` references. `dummy/` is process material; `merge_dummy.tcl` only merges an externally generated `Dummy.gds`.

`eco/` is a feedback path after PT/PV reports timing, hold, setup, DRC, or related violations. Use a recoverable existing implementation database. `eco/scripts/fix_drc.tcl`, `fix_hold.tcl`, and `fix_stup.tcl` write/overwrite `eco/scripts/fix_ecotiming.tcl`; `eco/scripts/09_chipfinish.tcl` modifies design state and rebuilds ECO outputs/reports. Re-run affected PT/PV/Power checks after ECO.

### APL-DI and RedHawk

Before RedHawk design analysis, create matching APL-DI (design-independent) library artifacts. `06_power/apldi/{hvt,lvt,rvt}/` holds example `apldi.conf` and `apldi.cmd` files. Adapt LEF, CDL/SPICE, Liberty, device models, VDD/VSS, simulator, PVT corner, cell lists, work paths, and job count. The current scripts run `apldi`/`aplmerge` and produce `.cdev`, `.pwcdev`, and `.spiprof` only for their configured FF/SS corners.

```bash
cd 06_power/apldi/hvt
sh apldi.cmd

cd ../../ele_static_power
redhawk -f run_static_power.tcl
```

The RedHawk executable/flags are installation-dependent. Current GSR files depend on `image_icb` ECO outputs and stale `03_pt` parasitic paths, and may enable options that tolerate library/DEF mismatches. Do not use them unchanged for `soc_pad_wrapper` or let tolerant options mask input incompatibility.

## Validation and editing boundaries

- Validate the smallest affected stage/corner. Inspect actual tool exit status, full logs, reports, NDM/output artifacts, Formality equivalence, timing constraints/violations, PV results, and RedHawk input consistency. Shell completion, `tee`, or a created log file alone does not prove success.
- When changing names, paths, corners, libraries, or output filenames, search all downstream Formality, ICC2, StarRC/PrimeTime, PV, ECO, and RedHawk consumers.
- Preserve local PDK/path customization and unrelated generated data. Check `.gitignore` and `git status` before adding artifacts.
- Before `00_dc/clean.sh`, a Formality wrapper, a numbered ICC2/ECO stage, or a PV merge/setup script, inspect the targets it deletes or recreates and preserve results required by the requested work.
- Do not commit PDK files, `.db`, LEF/technology libraries, NDM databases, GDS/OASIS, extraction databases, large generated netlists, or other proprietary/generated deliverables.
