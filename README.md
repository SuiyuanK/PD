# SMIC 数字 IC 物理设计参考流程

本仓库是一套以 Tcl 和 Shell 脚本组织的数字 IC 设计参考流程，覆盖 RTL 综合、形式等价验证、物理实现、寄生参数提取、静态时序分析、物理验证、功耗/电迁移分析及部分签核检查。

主要使用以下 EDA 工具：

- Synopsys Design Compiler
- Synopsys Formality
- Synopsys IC Compiler II
- Synopsys PrimeTime
- Synopsys StarRC
- Siemens EDA（Mentor）Calibre
- Ansys/Apache RedHawk

> [!IMPORTANT]
> 本仓库是**参考流程和课程/项目资料集合**，不是检出后即可直接运行的完整工程。脚本中仍包含不同示例设计、外部 Linux 路径和机器相关配置。运行前必须统一设计名、输入输出文件名、工艺库、角点、场景及上下游路径。

## 流程概览

```text
RTL
 │
 ├─ 00_dc              Design Compiler 综合
 │                      └─ 门级网表、SDC、DDC、SVF、报告
 │
 ├─ 01_fm_post_dc      Formality：RTL 与综合后网表等价验证
 │
 ├─ 02_pr              ICC2 物理实现
 │                      └─ 导入 → Floorplan → 电源网络 → 布局
 │                         → CTS → 布线 → 优化 → Chip Finish
 │
 ├─ 03_fm_post_pr      Formality：综合后与布局布线后网表等价验证
 │
 ├─ 04_pt
 │   ├─ starrc         多角点寄生参数提取
 │   └─ sta            PrimeTime 多角点静态时序分析
 │
 ├─ 05_pv              GDS 合并、DRC/Antenna、LVS、Dummy Fill
 │
 ├─ 06_power           RedHawk 静态/动态电源完整性和信号 EM 分析
 │
 └─ 07_signoff_check   线长、VT 比例、去耦/ECO 电容等辅助检查
```

`eco/` 是独立的 `image_icb` 后期 ICC2 ECO 参考路径，不是 `02_pr/` 默认设计的下一阶段。`others/` 保存辅助工具、库生成脚本和其他参考材料。

## 当前配置状态

仓库内的默认脚本来自多个示例，尚未形成统一的端到端配置：

| 区域 | 当前可见的示例设计或特点 |
| --- | --- |
| `00_dc/`、`01_fm_post_dc/` | 默认顶层模块为 `CNN` |
| `02_pr/` | 默认设计为 `soc_pad_wrapper` |
| `03_fm_post_pr/` | 默认顶层模块为 `conv`，且布局布线网表路径与当前 PR 输出不一致 |
| `04_pt/`、`05_pv/`、`06_power/`、`eco/` | 多处使用 `image_icb` 及外部绝对路径 |

因此，不应直接把所有顶层脚本依次运行。跨阶段执行前，至少应统一：

1. 顶层模块名；
2. RTL、网表、SDC 和 SVF 文件名；
3. 工艺文件、标准单元、I/O、SRAM 及其他宏单元库；
4. PVT 角点、RC 角点和 MCMM 场景；
5. 每个阶段的输出目录及下游消费路径；
6. 电源/地网络名称、层栈、版图和签核规则文件。

## 运行环境

这些流程面向具备相应许可证的 Linux/Unix EDA 环境。脚本依赖 Bash/C shell、Unix 命令和商业 EDA 工具，不能在 Windows PowerShell 中直接执行。

运行前需要准备或确认：

- 对应工具及许可证；
- SMIC 工艺文件和签核规则；
- 标准单元、I/O、SRAM/宏单元的时序与物理库；
- RTL、综合网表、SDC、GDS/OASIS 等阶段输入；
- 脚本中硬编码的挂载路径和版本相关命令；
- 足够的磁盘空间及正确的当前工作目录。

仓库可能不包含完整 PDK、专有库、RTL 或大型生成数据。不要把仓库中的示例路径当作可移植的默认配置。

## 目录说明

```text
PD/
├─ 00_dc/                  RTL 综合
├─ 01_fm_post_dc/          综合后形式等价验证
├─ 02_pr/                  ICC2 物理实现主流程
├─ 03_fm_post_pr/          布局布线后形式等价验证
├─ 04_pt/
│  ├─ starrc/              StarRC 寄生参数提取
│  └─ sta/                 PrimeTime 多角点 STA
├─ 05_pv/
│  ├─ merge/               GDS 合并
│  ├─ drc/                 DRC 与天线检查
│  ├─ lvs/                 LVS 相关脚本与配置
│  └─ dummy/               Dummy Fill 工艺资料（无完整启动脚本）
├─ 06_power/               RedHawk 电源完整性与 EM 分析
├─ 07_signoff_check/       ICC2/PrimeTime 会话内使用的检查片段
├─ eco/                    独立的后期 ECO 参考流程
├─ others/                 辅助工具和参考材料
├─ doc/                    课程与流程文档
└─ SMIC_IO_Cell_Categories_CN.md
```

常见的数据目录约定如下：

- `data/`：阶段输入或本地工艺/设计数据；
- `outputs/`：供下游阶段使用的正式输出；
- `rpts/`、`reports/`：工具报告；
- `logs/`、`log/`：运行日志；
- `WORK/`、`tmp_work/`、`*.nlib`：工具工作区或阶段数据库。

这些目录并非每个阶段都完整存在，部分目录会在运行时创建或重建。

## 使用方法

### 1. Design Compiler 综合

入口文件：

- `00_dc/run_dc.sh`
- `00_dc/scripts/dc.tcl`
- `00_dc/scripts/find_rtl.py`

先修改 `00_dc/run_dc.sh` 顶部的设计变量和开关，并检查 `00_dc/scripts/dc.tcl` 中的库、约束及输出设置。然后从阶段目录运行：

```bash
cd 00_dc
./run_dc.sh
```

`rtlDir` 指向的目录需要包含：

```text
rtl_verilog.list
rtl_sverilog.list
```

`find_rtl.py` 扫描的是**脚本自身所在目录树**，并把两个列表写到脚本旁边。若要用它生成列表，应把脚本复制到 RTL 源码根目录，或先修改脚本中的扫描逻辑，再执行：

```bash
cd <RTL_SOURCE_ROOT>
python find_rtl.py
```

`run_dc.sh` 支持只读 RTL、SystemVerilog 读入、面积/功耗优化、hold 修复、`compile_ultra` 和门控时钟等开关。实际效果以 `run_dc.sh` 和 `dc.tcl` 当前实现为准。

> [!WARNING]
> `00_dc/clean.sh` 会清理生成目录。执行前先确认已有报告、网表和工作区不再需要。

### 2. 综合后形式等价验证

先设置 `01_fm_post_dc/run_fm.sh` 中的 `rtlDir`、`TOP_MODULE`、`netlistDir` 和 `svfDir`，并检查 `scripts/run_fm.tcl` 中的库路径：

```bash
cd 01_fm_post_dc
./run_fm.sh
```

该脚本会删除旧日志，并重新整理 Formality 工作目录。不能只根据 Shell 返回状态判断成功；还应检查 `log/fm.log` 和 Formality 的最终 `verify` 结果。

### 3. ICC2 物理实现

主流程脚本位于 `02_pr/scripts/`：

```text
00_common_design_settings.tcl   共享变量和工艺/设计配置
01_import_netlist.tcl           导入网表和约束
02_floorplan.tcl                Floorplan
03_power_routing.tcl            电源网络
04_place_opt.tcl                布局优化
05_cts.tcl                      时钟树综合
06_cts_opt.tcl                  CTS 后优化
07_route.tcl                    布线
08_route_opt.tcl                布线后优化
09_chipfinish.tcl               Chip Finish 与最终输出
```

`00_common_design_settings.tcl` 是由各阶段 source 的共享配置，**不是可单独完成导入的流程入口**。完成配置后，应从 `01_import_netlist.tcl` 开始，按编号逐阶段执行：

```bash
cd 02_pr
icc2_shell -f scripts/01_import_netlist.tcl
icc2_shell -f scripts/02_floorplan.tcl
icc2_shell -f scripts/03_power_routing.tcl
icc2_shell -f scripts/04_place_opt.tcl
icc2_shell -f scripts/05_cts.tcl
icc2_shell -f scripts/06_cts_opt.tcl
icc2_shell -f scripts/07_route.tcl
icc2_shell -f scripts/08_route_opt.tcl
icc2_shell -f scripts/09_chipfinish.tcl
```

每一阶段依赖上一阶段保存的 NDM library。执行下一阶段前，应检查当前阶段日志、QoR、时序、DRC 和数据库保存结果。

> [!WARNING]
> 多个阶段会复制前一阶段的 NDM library，并强制删除同名目标库；`09_chipfinish.tcl` 还会重建 `02_pr/outputs/`。重新运行前请保留需要的结果。

`02_pr/scripts/teacher/` 和其他参考目录包含替代流程，不能在未核对设计假设和数据库格式的情况下与主编号流程混用。

### 4. 布局布线后形式等价验证

入口为：

```bash
cd 03_fm_post_pr
./run_fm.sh
```

当前默认配置不能直接使用，至少存在以下不一致：

- `TOP_MODULE` 与 `02_pr/` 默认设计不同；
- `post_pr_Dir` 指向 `../02_pr/data`，而 `09_chipfinish.tcl` 将网表写入 `../02_pr/outputs`；
- PR 输出网表为压缩的 `.v.gz`；
- `scripts/run_fm.tcl` 中存在 `TOPDIR`/`topDir` 大小写不一致的变量引用。

这些问题应作为一组同时修正，再运行 Formality。该阶段也会重建日志和临时工作目录。

### 5. StarRC 寄生参数提取

每个 RC 角点在 `04_pt/starrc/` 下有独立的 `.run`、`.cmd` 和 `.smc` 配置。检查设计文件、版图、层映射、工艺模型和输出路径后运行：

```bash
cd 04_pt/starrc
./run_starrc.sh
```

> [!CAUTION]
> `run_starrc.sh` 使用后台任务并行启动各角点，但没有执行 `wait`。脚本返回不代表提取已经完成。开始 PrimeTime 分析前，必须确认所有 StarRC 进程均已结束，并逐个检查日志、SPEF/DSPF 等预期产物以及 short/open 汇总。

### 6. PrimeTime 静态时序分析

各 STA 角点位于 `04_pt/sta/func.*` 目录，每个角点有自己的 `run_pt.tcl`。批量运行：

```bash
cd 04_pt/sta
./run_pt.sh
```

也可以只验证一个已适配的角点：

```bash
cd 04_pt/sta/<CORNER_DIRECTORY>
pt_shell -f run_pt.tcl
```

`run_pt.sh` 顺序执行多个角点，但没有 fail-fast 或统一状态汇总。必须逐角点检查日志和报告，重点确认：

- 库、网表、SDC 和寄生参数是否成功读入；
- 时钟和例外约束是否生效；
- 是否存在 unconstrained path；
- setup/hold、transition、capacitance 等检查结果；
- 工具错误、缺失引用和未注释寄生网络。

### 7. Calibre 物理验证

DRC 和天线检查从 `05_pv/drc/` 启动：

```bash
cd 05_pv/drc
./run_drc.sh
```

仅运行其中一项时可直接执行：

```bash
calibre -hier -drc -turbo 4 -hyper -64 ./drc.cmd | tee drc.log
calibre -hier -drc -turbo 4 -hyper -64 ./ant.cmd | tee ant.log
```

GDS 合并入口位于：

```bash
cd 05_pv/merge/icw
./run_icw.csh
```

虽然文件扩展名为 `.csh`，该脚本没有 shebang，并使用 Unix 命令。运行前应先确认所用 Shell 和脚本内容。

LVS、GDS Merge、DRC 和 Dummy Fill 的现有 runset 多处包含外部规则路径及 `image_icb` 文件名。`merge/Calibredrv/merge.tcl` 还引用了不存在的 `04_pv` 旧目录；仓库实际阶段目录是 `05_pv`。`dummy/` 主要保存 DMF 工艺资料和文档，并没有完整的 Dummy Fill 启动脚本；已有的 `merge/Calibredrv/merge_dummy.tcl` 只负责合并外部生成的 `Dummy.gds`。应把设计名、GDS、网表、规则文件、层映射及 Dummy Fill 产物作为一个整体适配。

> [!WARNING]
> GDS 合并脚本会删除并重建部分本地日志和 `merge/data/pr_outputs` 数据。`lvs/gen_spi.sh` 也包含机器相关的绝对网表路径。执行前先检查目标和输入。

### 8. RedHawk 功耗与 EM 分析

主要 Tcl 入口如下。具体启动程序和批处理参数可能随 RedHawk 版本及现场环境变化；以下 `redhawk -f` 仅作为常见调用示例，执行前应按已安装版本确认：

```bash
cd 06_power/ele_static_power
redhawk -f run_static_power.tcl

cd ../ele_dynamic_power
redhawk -f run_dynamic_power.tcl

cd ../ele_signal_em
redhawk -f run_signalem.tcl
```

这些脚本当前导入 `image_icb.gsr`，并消费独立 ECO 示例的 `../../eco/outputs/image_icb.def.gz`，不能直接接收 `02_pr/` 默认 `soc_pad_wrapper` 的产物。GSR 中还保留了指向 `../../03_pt/starrc/` 的旧路径，而本仓库时序/提取阶段实际位于 `04_pt/`。此外，流程依赖外部技术库、时序和活动率数据。`06_power/write_timing_file.tcl` 是 PrimeTime 侧的数据准备脚本，其中的 Ansys 安装路径、`image_icb` 输出名和时序会话路径都需要按实际环境更新。

### 9. 辅助签核检查

`07_signoff_check/` 中的文件是供已加载设计的 ICC2/PrimeTime 交互会话 source 的 Tcl 片段，不是独立的通用 Tcl 程序，也不是完整的自动签核套件。

典型内容包括：

- `01_check_net_length.tcl`：超长网络报告及修复；
- `check_vt_ratio.tcl`：不同阈值电压单元比例；
- `check_dcap_ecocap.tcl`：去耦/ECO 电容相关 GUI 选择。

> [!WARNING]
> `01_check_net_length.tcl` 会插入 buffer 并修改当前设计；`check_dcap_ecocap.tcl` 会改变 GUI 选择。使用前应保存设计或在可恢复的会话中操作。

## 结果验证

本仓库没有根目录构建系统、CI、统一 lint 或自动测试命令。正确的验证方式是运行受影响的最小 EDA 阶段，并同时检查：

1. 工具退出状态；
2. 完整日志中的 error、warning 和 unresolved reference；
3. 阶段预期输出是否生成且可被下游读取；
4. Formality 是否等价；
5. 时序是否完整约束，以及 setup/hold 是否满足；
6. DRC、LVS、antenna、short/open 等签核结果；
7. 功耗、IR drop 和 EM 报告是否使用了正确活动率、网表和角点。

许多 Shell 命令通过 `tee` 管道输出，Shell 脚本的返回码不一定等同于 EDA 工具的真实结果。不要只凭“脚本执行结束”判断阶段成功。

## 修改流程时的检查清单

修改一个阶段的命名或输出后，应搜索所有下游消费者，而不是只改当前脚本：

- Design Compiler 输出的网表、SDC、SVF；
- 两个 Formality 阶段的参考设计与实现设计；
- ICC2 的设计名、NDM library 和 MCMM 场景；
- StarRC/PrimeTime 的版图、网表、寄生文件和角点；
- Calibre 的 GDS、LVS 网表、规则和层映射；
- ECO、RedHawk 及签核脚本中的设计名和路径。

提交更改前使用 `git status` 检查生成物。不要提交 PDK、`.db`、LEF、NDM/技术文件、GDS/OASIS、提取数据库、大型网表或其他无权分发的专有数据。

## 参考资料

- [`doc/dc.docx`](doc/dc.docx)：综合阶段资料；
- [`doc/pr.docx`](doc/pr.docx)：物理实现阶段资料；
- [`doc/PPT/`](doc/PPT/)：课程讲义和演示资料；
- [`SMIC_IO_Cell_Categories_CN.md`](SMIC_IO_Cell_Categories_CN.md)：SMIC I/O 单元分类参考。

## 说明

脚本中的工艺、库和设计参数仅用于展示流程结构，不构成特定芯片项目的签核保证。实际流片项目应使用经项目批准的 PDK、库版本、工具版本、方法学和 signoff rule deck，并由各阶段负责人审核最终结果。
