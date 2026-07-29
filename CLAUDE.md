# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

This is a Tcl- and shell-driven digital IC physical-design reference flow for an SMIC process. It connects Synopsys Design Compiler, Formality, IC Compiler II, PrimeTime/StarRC, Mentor/Calibre, and RedHawk. It is not a conventional software package: there is no root build system, CI workflow, automated test suite, or lint command. A stage is validated by running the relevant EDA tool and reviewing its reports/logs.

Most commands assume they are launched from the stage directory because scripts use relative paths. They target a licensed Linux/Unix EDA environment: the bash/csh wrappers, `tee`, background jobs, and proprietary tool binaries are not native PowerShell commands even when the repository is checked out on Windows. PDK, standard-cell/memory libraries, RTL, and large/generated design artifacts may be absent, ignored, or machine-local. Before running a flow, adapt machine-specific library, technology, RTL, and netlist paths. Do not treat reference scripts or hard-coded paths as portable defaults.

The repository's Tcl should be interpreted as Synopsys EDA Tcl (`.vscode/settings.json` selects the `synopsys-eda-tcl` dialect), not generic Tcl.

## Flow architecture

The numbered top-level directories encode the dependency order:

1. `00_dc/` — RTL synthesis. `run_dc.sh` exports design switches and invokes `scripts/dc.tcl`, which reads RTL/file lists, applies constraints, compiles, and writes netlist, SDC, DDC, SVF, reports, and logs.
2. `01_fm_post_dc/` — RTL-to-synthesized-netlist equivalence. Its Formality Tcl reads Verilog/SystemVerilog file lists, the DC netlist, and DC's SVF before matching and verifying.
3. `02_pr/` — ICC2 physical implementation. `00_common_design_settings.tcl` is shared configuration sourced by the numbered stages; the executable flow is `01_import_netlist.tcl` through `09_chipfinish.tcl`. They cover import, floorplan, power routing, place optimization, CTS, post-CTS optimization, routing, route optimization, and chip finishing. Each stage persists state in a stage-named NDM library consumed by the next stage. Scenario scripts define MCMM timing views. `scripts/teacher/` and `scripts/ref/` are alternate/reference material, not stages to mix into the main sequence without checking their assumptions.
4. `03_fm_post_pr/` — post-layout logical equivalence between DC and PR netlists.
5. `04_pt/` — StarRC extraction plus multi-corner PrimeTime STA. Extraction produces corner parasitics consumed by the corresponding STA corner runs. Corner subdirectories carry their own run/setup files rather than sharing a single root configuration.
6. `05_pv/` — physical verification: GDS merge, DRC/antenna, LVS, and dummy fill. These flows consume finished layout and netlist artifacts; several rule decks and PDK inputs are external.
7. `06_power/` — RedHawk static/dynamic power and signal-EM analysis, with PrimeTime timing export as an input preparation step.
8. `07_signoff_check/` — interactive Tcl snippets for net-length repair/reporting, VT ratio reporting, and decap/ECO-cap GUI selection; there is no wrapper runner or complete automated signoff suite.

`eco/` is a separate `image_icb` late-stage ICC2 repair path, not a continuation of the checked-in `soc_pad_wrapper` PR defaults. Its setup expects an existing base NDM library and provides timing/DRC/hold/setup fixes followed by chip finishing. `others/` contains utilities and library-generation/reference material rather than a normal production stage.

Data moves between stages through conventional `data/`, `outputs/`, `rpts/`/`reports/`, `logs/`, and tool work directories. Treat the numbered directories as a nominal flow, not a ready-to-run end-to-end configuration: checked-in defaults currently mix example designs (`CNN` in DC/post-DC FM, `soc_pad_wrapper` in PR, `conv` in post-PR FM, and `image_icb` in ECO/PV/power). Align the top-module name, netlist/SDC filenames, corner/scenario names, and producer/consumer paths before crossing stages. Many artifacts are generated, proprietary, or very large. Check `.gitignore` and `git status` before adding any output; do not commit PDK libraries (`.db`, LEF, NDM, technology files), GDS, extracted databases, or large generated netlists.

## Stage commands and caveats

### Synthesis

```bash
cd 00_dc
./run_dc.sh
```

Edit/export the variables at the top of `00_dc/run_dc.sh` first (`rtlDir`, `TOP_MODULE`, and compile/area/power/hold switches). The script selects either the RTL-read or compile path and invokes `dc_shell-xg-t -f ./scripts/dc.tcl`.

Generate RTL file lists with the helper at `00_dc/scripts/find_rtl.py`. The helper scans **its own directory tree**, not the caller's working directory, and writes both lists beside itself. Place/copy it at the RTL source root (or adapt `script_dir`) before running it there:

```bash
cd <RTL source root containing find_rtl.py>
python find_rtl.py
```

It writes `rtl_verilog.list` and `rtl_sverilog.list`; these must end up under the directory named by `rtlDir`, because `dc.tcl` reads `$rtlDir/rtl_verilog.list` and `$rtlDir/rtl_sverilog.list`. The helper excludes common testbench filename patterns.

### Formal equivalence

```bash
cd 01_fm_post_dc
./run_fm.sh

cd ../03_fm_post_pr
./run_fm.sh
```

Before each run, set the top module and input directories in that stage's `run_fm.sh`, and update library paths in `scripts/run_fm.tcl`. Both wrappers also remove or recreate prior log/work directories, so inspect or preserve previous results before launching them. The checked-in post-PR flow is not directly runnable as-is: `run_fm.sh` points `post_pr_Dir` at `../02_pr/data` although chip finishing writes to `../02_pr/outputs` (with compressed `.v.gz` netlists), its default module does not match PR, and `scripts/run_fm.tcl` defines `TOPDIR` but later references `${topDir}`. Correct these together rather than changing only one path.

### ICC2 physical implementation

```bash
cd 02_pr
icc2_shell -f scripts/01_import_netlist.tcl
# After each successful stage, run the next script through 09_chipfinish.tcl.
```

`00_common_design_settings.tcl` only defines shared variables and is sourced by each numbered stage; running it alone does not implement the design. Continue with `scripts/02_floorplan.tcl` through `scripts/09_chipfinish.tcl` in numeric order. Running one numbered Tcl file is the closest equivalent to running a single stage/test; it requires the prior stage's saved design state and external technology inputs. Each stage copies the preceding NDM library into a new stage-named library and force-deletes any existing destination, while several stages also recreate their report/output directories.

### PrimeTime and StarRC

```bash
cd 04_pt/sta
./run_pt.sh

cd ../starrc
./run_starrc.sh
```

`run_pt.sh` sequentially visits its configured corners and runs `pt_shell -f run_pt.tcl` in each, but it has no fail-fast/status aggregation; inspect every corner log/report. The checked-in corner scripts consume `image_icb` netlists/constraints and hard-coded external library paths rather than the main PR example. To validate only one adapted STA corner, enter that corner directory and run:

```bash
pt_shell -f run_pt.tcl
```

`run_starrc.sh` launches multiple corner `.run` files in the background and contains no `wait`; the wrapper can return while extraction is still running. Inspect/edit its corner list, wait for every process yourself, and verify every extraction log/artifact before starting STA.

### Physical verification

From `05_pv/drc/`:

```bash
./run_drc.sh
```

This runs both the Calibre DRC and antenna decks. To execute only one check, run the corresponding command directly:

```bash
calibre -hier -drc -turbo 4 -hyper -64 ./drc.cmd | tee drc.log
calibre -hier -drc -turbo 4 -hyper -64 ./ant.cmd | tee ant.log
```

GDS merge is launched from `05_pv/merge/icw/` with `./run_icw.csh`. Despite the `.csh` name, it has no shebang and uses Unix commands; it force-deletes `05_pv/merge/data/pr_outputs` and its local log directory before copying PR outputs, so inspect/preserve those targets first. The checked-in merge/DRC/LVS runsets contain Linux mount paths and `image_icb` filenames from the alternate ECO example; they do not automatically consume the main PR flow's `soc_pad_wrapper` outputs. Adapt the layout/netlist/rule-deck paths and design name as a consistent set. `05_pv/lvs/gen_spi.sh` likewise contains an environment-specific absolute netlist path.

### Power and signoff

RedHawk scripts are tool Tcl inputs, for example:

```bash
cd 06_power/ele_static_power
redhawk -f run_static_power.tcl
```

Use `ele_dynamic_power/run_dynamic_power.tcl` or `ele_signal_em/run_signalem.tcl` for the analogous analyses from their own directories. These checked-in runners import `image_icb.gsr` and depend on external libraries. `06_power/write_timing_file.tcl` is a PrimeTime-side preparation script with an absolute Ansys installation path and stale `../03_pt/...` session paths even though this repository's timing stage is `04_pt`; adapt it before use.

Run an individual `07_signoff_check/*.tcl` only by sourcing it in an appropriate loaded ICC2/PrimeTime design session; these are interactive snippets, not standalone generic-Tcl programs or a complete signoff suite. In particular, `01_check_net_length.tcl` mutates the design by inserting route buffers before appending overlength-net reports, and `check_dcap_ecocap.tcl` changes GUI selections.

## Validation and editing boundaries

- There is no repository-wide build, lint, or test command. Validate the smallest affected EDA stage or corner, then inspect tool exit status plus generated reports/logs for errors, unconstrained paths, failed equivalence, DRC/LVS violations, or timing failures as applicable.
- Shell wrappers often pipe through `tee`; do not assume the wrapper's status alone proves the EDA command succeeded. Check the tool log and expected reports/artifacts.
- Flow scripts are coupled through top-module names, scenario/corner names, library sets, and relative artifact paths. When changing one stage's output naming, search downstream Formality, ICC2, PrimeTime/StarRC, PV, ECO, and power scripts for consumers.
- Preserve local PDK/path customizations and unrelated generated files. The working tree may intentionally contain untracked or ignored EDA inputs and outputs.
- `00_dc/clean.sh`, both Formality wrappers, the numbered ICC2 stages, and some merge/setup scripts delete or recreate work, stage-library, report, or output directories. Inspect targets and preserve needed results before running them; obtain explicit confirmation before destructive cleanup outside the requested stage run.
