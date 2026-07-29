# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

This is a Tcl- and shell-driven digital IC physical-design reference flow for an SMIC process. It connects Synopsys Design Compiler, Formality, IC Compiler II, PrimeTime/StarRC, Siemens EDA (Mentor) Calibre, and Ansys/Apache RedHawk. It is not a conventional software package: there is no root build system, CI workflow, automated test suite, or lint command. Validate a change by running the smallest relevant EDA stage or corner and reviewing its reports and logs.

Most commands assume they are launched from the stage directory because scripts use relative paths. They target a licensed Linux/Unix EDA environment: the Bash/C-shell wrappers, `tee`, background jobs, and proprietary tool binaries are not native PowerShell commands even when the repository is checked out on Windows. PDK, standard-cell/memory libraries, RTL, and large/generated design artifacts may be absent, ignored, or machine-local. Adapt machine-specific library, technology, RTL, netlist, and rule-deck paths before running a flow; do not treat checked-in hard-coded paths as portable defaults.

Interpret the repository's Tcl as Synopsys EDA Tcl, not generic Tcl. `.vscode/settings.json` selects the `synopsys-eda-tcl` dialect.

## Flow architecture

The numbered top-level directories encode the nominal dependency order:

1. `00_dc/` — RTL synthesis. `run_dc.sh` exports design switches and invokes `scripts/dc.tcl`, which reads RTL file lists, applies constraints, compiles, and writes netlist, SDC, DDC, SVF, reports, and logs.
2. `01_fm_post_dc/` — RTL-to-synthesized-netlist equivalence. Its Formality Tcl reads RTL file lists, the DC netlist, and DC's SVF before matching and verifying.
3. `02_pr/` — ICC2 physical implementation. `00_common_design_settings.tcl` is shared configuration sourced by the numbered stages; the executable flow is `01_import_netlist.tcl` through `09_chipfinish.tcl`. The stages cover import, floorplan, power routing, place optimization, CTS, post-CTS optimization, routing, route optimization, and chip finishing. Each stage persists state in a stage-named NDM library consumed by the next stage. Scenario scripts define MCMM timing views. `scripts/teacher/` and other reference directories are alternate material, not stages to mix into the main sequence without checking their assumptions.
4. `03_fm_post_pr/` — post-layout logical equivalence between DC and PR netlists.
5. `04_pt/` — StarRC extraction followed by multi-corner PrimeTime STA. Corner subdirectories carry their own run/setup files rather than sharing one root configuration.
6. `05_pv/` — physical verification inputs and flows for GDS merge, DRC/antenna, LVS, and dummy-related processing. Rule decks and PDK inputs are partly external; `dummy/` contains process material rather than a complete Dummy Fill runner.
7. `06_power/` — RedHawk static/dynamic power and signal-EM analysis, with PrimeTime timing export as an input-preparation step.
8. `07_signoff_check/` — interactive Tcl snippets for net-length repair/reporting, VT-ratio reporting, and decap/ECO-cap GUI selection; there is no wrapper runner or complete automated signoff suite.

`eco/` is a separate `image_icb` late-stage ICC2 repair path, not a continuation of the checked-in `soc_pad_wrapper` PR defaults. It expects an existing base NDM library and provides timing/DRC/hold/setup fixes followed by chip finishing. `others/` contains utilities and library-generation/reference material rather than a normal production stage.

Data moves between stages through conventional `data/`, `outputs/`, `rpts/`/`reports/`, `logs/`, and tool-work directories. Treat the numbered directories as a reference architecture, not a ready-to-run end-to-end configuration: checked-in defaults mix example designs (`CNN` in DC/post-DC FM, `soc_pad_wrapper` in PR, `conv` in post-PR FM, and `image_icb` in ECO/STA/PV/power). Align the top-module name, netlist/SDC/SVF filenames, corner/scenario names, libraries, and producer/consumer paths before crossing stages.

## Stage commands and caveats

### Synthesis

```bash
cd 00_dc
./run_dc.sh
```

Edit the variables at the top of `00_dc/run_dc.sh` first, especially `rtlDir`, `TOP_MODULE`, and the RTL/compile/area/power/hold switches. The wrapper invokes `dc_shell-xg-t -f ./scripts/dc.tcl` in either RTL-read or full-compile mode.

Generate RTL file lists with `00_dc/scripts/find_rtl.py`. The helper scans **its own directory tree**, not the caller's current directory, and writes both lists beside itself. Place/copy it at the RTL source root or adapt `script_dir`, then run:

```bash
cd <RTL source root containing find_rtl.py>
python find_rtl.py
```

It writes `rtl_verilog.list` and `rtl_sverilog.list`; they must be under the directory named by `rtlDir`, because `dc.tcl` reads `$rtlDir/rtl_verilog.list` and `$rtlDir/rtl_sverilog.list`.

`00_dc/clean.sh` removes generated work, log, report, and output data. Inspect and preserve prior results before running it.

### Formal equivalence

```bash
cd 01_fm_post_dc
./run_fm.sh

cd ../03_fm_post_pr
./run_fm.sh
```

Before each run, set the top module and input directories in that stage's `run_fm.sh`, and update library paths in `scripts/run_fm.tcl`. Both wrappers delete or recreate previous log/work directories.

The checked-in post-PR flow is not runnable as-is: `run_fm.sh` points `post_pr_Dir` at `../02_pr/data`, while chip finishing writes compressed `.v.gz` netlists to `../02_pr/outputs`; its default module does not match PR; and `scripts/run_fm.tcl` defines `TOPDIR` but later references `${topDir}`. Correct these together rather than changing only one path.

### ICC2 physical implementation

```bash
cd 02_pr
icc2_shell -f scripts/01_import_netlist.tcl
# After each successful stage, run 02_floorplan.tcl through 09_chipfinish.tcl in order.
```

`00_common_design_settings.tcl` only defines shared variables and is sourced by each numbered stage; running it alone does not import or implement the design. Running one numbered Tcl file is the closest equivalent to running a single stage/test, but it requires the previous stage's saved NDM library and external technology inputs.

Each numbered stage copies the preceding NDM library to a stage-named destination and force-deletes any existing destination. Several stages also recreate report directories. `09_chipfinish.tcl` deletes and recreates `02_pr/outputs/` before writing compressed GDS/netlists and other final deliverables. Preserve needed results before rerunning a stage.

### StarRC and PrimeTime

Extraction must complete before STA consumes its parasitics:

```bash
cd 04_pt/starrc
./run_starrc.sh

cd ../sta
./run_pt.sh
```

`run_starrc.sh` launches multiple corner `.run` files in the background and contains no `wait`; the wrapper can return while extraction is still running. Wait for every process and verify every extraction log and expected parasitic artifact before starting PrimeTime.

`run_pt.sh` sequentially visits configured corners and runs `pt_shell -f run_pt.tcl`, but it has no fail-fast behavior or aggregated status. Inspect every corner's log and report. The checked-in corner scripts consume `image_icb` netlists/constraints and hard-coded external library paths rather than the main PR example.

To validate one adapted STA corner:

```bash
cd 04_pt/sta/<corner-directory>
pt_shell -f run_pt.tcl
```

### Physical verification

From `05_pv/drc/`:

```bash
./run_drc.sh
```

This runs both Calibre DRC and antenna decks. Run one check directly when only that deck is affected:

```bash
calibre -hier -drc -turbo 4 -hyper -64 ./drc.cmd | tee drc.log
calibre -hier -drc -turbo 4 -hyper -64 ./ant.cmd | tee ant.log
```

GDS merge is launched from `05_pv/merge/icw/` with `./run_icw.csh`. Despite the `.csh` name, it has no shebang and uses Unix commands. It force-deletes `05_pv/merge/data/pr_outputs` and its local log directory before copying PR outputs.

The merge/DRC/LVS runsets contain Linux mount paths and `image_icb` names from the separate ECO example; they do not automatically consume `02_pr`'s `soc_pad_wrapper` outputs. In particular, `05_pv/merge/Calibredrv/merge.tcl` refers to a stale `04_pv` path although the actual stage is `05_pv`, and `05_pv/lvs/gen_spi.sh` contains an environment-specific absolute netlist path. `05_pv/dummy/` has process files and documentation but no complete Dummy Fill launcher; `merge/Calibredrv/merge_dummy.tcl` only merges an externally produced `Dummy.gds`.

### Power and signoff

The RedHawk Tcl inputs are under `06_power/ele_static_power/`, `ele_dynamic_power/`, and `ele_signal_em/`. A typical invocation is:

```bash
cd 06_power/ele_static_power
redhawk -f run_static_power.tcl
```

Confirm the executable and batch flags against the installed RedHawk version rather than assuming this example is universal. The scripts import `image_icb.gsr`; those GSR files consume the separate ECO design's `../../eco/outputs/image_icb.def.gz` and contain stale `../../03_pt/starrc/...` references even though extraction is under `04_pt/starrc/`. They cannot directly consume the main `soc_pad_wrapper` PR outputs without coordinated edits.

`06_power/write_timing_file.tcl` is a PrimeTime-side preparation script with an absolute Ansys installation path, `image_icb` output names, and stale timing-session paths. Adapt all of them before use.

Source an individual `07_signoff_check/*.tcl` only in an appropriate loaded ICC2/PrimeTime design session. These are not standalone generic-Tcl programs. `01_check_net_length.tcl` mutates the design by inserting route buffers before appending overlength-net reports, and `check_dcap_ecocap.tcl` changes GUI selections.

## Validation and editing boundaries

- There is no repository-wide build, lint, or test command. Validate the smallest affected EDA stage or corner, then inspect tool exit status, complete logs, reports, and expected output artifacts.
- Shell wrappers often pipe through `tee`; do not assume the wrapper's status proves the EDA command succeeded. Check for tool errors, unresolved references, unconstrained paths, failed equivalence, timing violations, DRC/LVS/antenna violations, and extraction short/open results as applicable.
- Flow scripts are coupled through top-module names, filenames, scenario/corner names, library sets, and relative artifact paths. When changing one stage's output naming, search downstream Formality, ICC2, PrimeTime/StarRC, PV, ECO, and power scripts for consumers.
- Preserve machine-local PDK/path customizations and unrelated generated files. The working tree may intentionally contain untracked or ignored EDA inputs and outputs.
- Check `.gitignore` and `git status` before adding outputs. Do not commit PDK libraries (`.db`, LEF, NDM, technology files), GDS/OASIS, extracted databases, or large generated netlists.
- Before invoking `00_dc/clean.sh`, either Formality wrapper, a numbered ICC2 stage, or merge/setup scripts, inspect the directories they delete or recreate and preserve any required results.
