# 数字 IC 物理设计（数字后端）参考流程

本仓库沉淀了嵌入式竞赛项目及后续项目中实际使用、持续优化的数字 IC 物理设计（数字后端）脚本与资料。流程以 Tcl 和 Shell 组织，涉及 RTL 综合、形式等价验证、物理实现、寄生参数提取、静态时序分析、物理验证、电源完整性及电迁移分析，以及后期工程变更（ECO）。

主要工具包括 Synopsys Design Compiler、Formality、IC Compiler II（ICC2）、PrimeTime、StarRC，Siemens EDA（Mentor）Calibre，以及 Ansys/Apache RedHawk。

> [!IMPORTANT]
> 本仓库保留了不同项目、设计版本和流程阶段的有效配置。它是经过项目实践的流程沉淀，但当前检出内容**不是单一设计的可直接端到端连续运行工程**。复用、迁移或串联阶段前，必须先选定目标项目和阶段范围，并统一设计名、输入产物、工艺库、角点和上下游路径。

## 复用前先确认

运行任何阶段前，先核对以下项目专属内容：

1. 顶层模块、RTL、综合网表、SDC、SVF 和 DEF/GDS/OASIS；
2. 标准单元、I/O 单元、SRAM/宏单元的时序库、物理库和模型；
3. PVT 角点、RC 角点与多模式多角点（MCMM）场景；
4. 电源/地网络、层栈、Floorplan、I/O/Pad 规划及签核规则；
5. 阶段 NDM 数据库、寄生文件、报告和下游消费路径；
6. 工具版本、许可证、Linux 挂载路径及其他机器相关设置。

仓库不包含所有项目所需的 RTL、PDK、专有库和大型生成物。不要将脚本内的设计名、绝对路径或工艺版本视为可移植默认值。

## 项目配置与流程关系

### 当前保留的项目配置

| 阶段或区域 | 当前配置 | 复用时的含义 |
| --- | --- | --- |
| `00_dc/`、`01_fm_post_dc/` | `CNN` | DC 与综合后 Formality 的历史项目配置；默认 RTL 目录和文件列表未随仓库提供。 |
| `02_pr/` | `soc_pad_wrapper` | ICC2 物理实现主流程示例；其导入网表及工艺输入需要按项目准备。 |
| `03_fm_post_pr/` | `conv` | 后 PR Formality 的独立配置，当前设计名、路径、压缩网表和 Tcl 变量存在需同步适配的项。 |
| `eco/`、`04_pt/`、`05_pv/`、`06_power/` | 多以 `image_icb` 为例 | 后期 ECO/签核项目配置，不能自动消费 `02_pr/` 的 `soc_pad_wrapper` 输出。 |

这些配置反映了不同项目的实际交付范围：有的项目只做到综合，有的做到布局布线（Place & Route，PR），有的继续进行 STA、PV、电源完整性和 EM 分析。复用时应以目标项目的设计版本和所需阶段为边界，而不是跨表格行直接拼接脚本。

### 主线与 ECO 反馈闭环

```text
RTL
 │
 ├─ 00_dc              RTL 综合（DC）
 ├─ 01_fm_post_dc      RTL ↔ 综合网表等价验证（Formality）
 ├─ 02_pr              ICC2 物理实现：导入、Floorplan、Power Routing、
 │                      布局、CTS、布线、优化与 Chip Finish
 ├─ 03_fm_post_pr      综合后 ↔ PR 后网表等价验证（按项目适配）
 ├─ 04_pt/starrc       寄生参数提取（RC Extraction）
 ├─ 04_pt/sta          静态时序分析（Static Timing Analysis，STA）
 │    │
 │    ├─ 若 PT 存在 timing/hold/setup 等违例
 │    │  └─ eco          ECO 修复 → 回到 04_pt/starrc 与 04_pt/sta 复查
 │    │
 ├─ 05_pv              物理验证（Physical Verification，PV）
 │    │
 │    ├─ 若 PV 存在 DRC 等违例
 │    │  └─ eco          ECO 修复 → 回到 04_pt/starrc、04_pt/sta 与 05_pv 复查
 │    │
 ├─ 06_power           RedHawk 电源完整性、IR drop 与 EM 分析
 └─ 07_signoff_check   辅助签核检查
```

`eco/` 不是固定的末端步骤：它以已有实现 NDM 数据库和 PT/PV 检查报告为输入。ECO 影响网表、布局或布线时，应重新执行受影响的提取、STA、PV、Power 及辅助签核检查。`others/` 保存辅助工具、库生成脚本和参考资料，不是生产流程阶段。

## 运行环境与目录约定

流程面向具备许可证的 Linux/Unix EDA 环境。Bash/C shell 包装器、`tee`、后台作业及商业 EDA 二进制程序不能在 Windows PowerShell 中直接执行。大多数脚本使用相对路径，必须从所属阶段目录启动。

```text
PD/
├─ 00_dc/                  RTL 综合
├─ 01_fm_post_dc/          综合后形式等价验证
├─ 02_pr/                  ICC2 物理实现主流程
├─ 03_fm_post_pr/          PR 后形式等价验证
├─ 04_pt/starrc/           StarRC 寄生参数提取
├─ 04_pt/sta/              PrimeTime 多角点 STA
├─ 05_pv/                  GDS 合并、DRC/Antenna、LVS、Dummy Fill 资料
├─ 06_power/               APL-DI、RedHawk 电源完整性与 EM
├─ 07_signoff_check/       ICC2/PrimeTime 会话内检查片段
├─ eco/                    PT/PV 违例的后期 ECO 修复
├─ others/                 辅助工具和参考材料
└─ doc/                    课程与流程资料
```

常见目录用途：

- `data/`：阶段输入、项目本地工艺或设计数据；
- `nlib/`、`*.nlib`：ICC2 的阶段 NDM 数据库；
- `outputs/`：正式阶段输出；
- `rpts/`、`reports/`：工具报告；
- `logs/`、`log/`：日志；
- `WORK/`、`tmp_work/`：工具工作目录。

这些命名是仓库约定，不保证所有阶段均提供完整、相互兼容的实现。

## 按阶段使用

以下命令展示各阶段入口和正常依赖关系。它们不是在当前 Windows 环境中的可执行验证，也不保证未经适配即可成功。

### 1. RTL 综合（DC）

入口：`00_dc/run_dc.sh` 与 `00_dc/scripts/dc.tcl`。

```bash
cd 00_dc
./run_dc.sh
```

运行前：

- 修改 `run_dc.sh` 中的 `rtlDir`、`TOP_MODULE` 及编译、面积、功耗、hold、`compile_ultra` 和门控时钟等开关；
- 根据项目设置 `scripts/dc.tcl` 中的库、约束和输出；
- 准备 `rtlDir` 下的 `rtl_verilog.list` 与 `rtl_sverilog.list`；
- 确认所选模式需要的前序输入。当前默认是完整编译模式，仓库未提供默认 `../../RTL` 输入或此前 RTL-read 产生的项目产物。

`00_dc/scripts/find_rtl.py` 扫描**其自身所在目录树**，并在脚本旁输出两份文件列表。将它置于 RTL 源码根目录，或调整脚本扫描路径后运行：

```bash
cd <RTL_SOURCE_ROOT>
python find_rtl.py
```

> [!WARNING]
> `00_dc/clean.sh` 会删除工作、日志、报告和输出数据。清理前先保存需要的结果。

### 2. 综合后形式等价验证（Formality）

入口：`01_fm_post_dc/run_fm.sh` 与 `scripts/run_fm.tcl`。

```bash
cd 01_fm_post_dc
./run_fm.sh
```

运行前统一 `rtlDir`、`TOP_MODULE`、综合网表目录、SVF 目录与库路径。当前仓库未随默认配置提供所需 RTL、网表和 SVF 输入。

该包装器会清理旧日志、重建临时工作目录。验收时检查 Formality 最终 `verify` 结论与完整日志，不要只看 Shell 返回状态。

### 3. ICC2 物理实现（PR）

`02_pr/scripts/` 的编号脚本表示正常依赖顺序：

```text
01_import_netlist.tcl   导入网表、约束并创建初始 NDM 数据库
02_floorplan.tcl        布局规划（Floorplan）
03_power_routing.tcl    电源网络（Power Routing）
04_place_opt.tcl        布局优化（Placement Optimization）
05_cts.tcl              时钟树综合（Clock Tree Synthesis，CTS）
06_cts_opt.tcl          CTS 后优化
07_route.tcl            布线（Routing）
08_route_opt.tcl        布线后优化（Route Optimization）
09_chipfinish.tcl       Chip Finish 与交付物输出
```

`00_common_design_settings.tcl` 是由编号阶段 source 的共享配置，不是独立入口。`01_import_netlist.tcl` 默认引用 `data/soc_pad_wrapper.v`；该项目网表不在当前检出内容中，运行前需按项目提供。

#### PR 的状态门控与迭代

不能从 `01` 到 `09` 一次性无脑运行。先建立初始数据库：

```bash
cd 02_pr
icc2_shell -f scripts/01_import_netlist.tcl
```

随后围绕 `02_floorplan.tcl` 与 `03_power_routing.tcl` 反复调整、运行和检查。迭代依据至少包括：利用率、宏单元、I/O/Pad、供电拓扑、层栈、IR drop、EM、拥塞与时序结果。每轮必须确认相关 NDM 数据库、日志、QoR 和检查报告；基础物理架构稳定后，才按实际需要逐阶段推进 Placement、CTS、Routing 和 Chip Finish。

每个后续阶段依赖前一阶段的 NDM 数据库，不能从空会话跳过前序状态直接运行。多个阶段会删除同名目标 NDM 数据库并重建报告；`09_chipfinish.tcl` 会删除、重建 `02_pr/outputs/`，再写出压缩网表、DEF、GDS/OASIS、LEF 等交付物。

> [!WARNING]
> 当前 `09_chipfinish.tcl` 中 tech LEF 的输出变量需要结合实际产物检查；不要仅以脚本结束判断 `.tlef` 已正确生成。

`scripts/teacher/` 是替代/参考材料，不能在未核对设计假设、库和数据库格式的前提下与主编号阶段混用。

### 4. PR 后形式等价验证（Formality）

入口文件存在：

```bash
cd 03_fm_post_pr
./run_fm.sh
```

但当前配置是运行前阻断项，而非可直接执行的连续入口。适配时应一起核对：

- `TOP_MODULE=conv` 与当前 PR 默认 `soc_pad_wrapper` 不一致；
- `post_pr_Dir` 指向 `../02_pr/data`，而 PR Chip Finish 写入 `../02_pr/outputs`；
- PR 输出使用压缩 `.v.gz` 网表，读取规则需相应调整；
- `scripts/run_fm.tcl` 定义 `TOPDIR`，但后续使用 `${topDir}`；
- DC 输出设计名、PR 设计名、库和黑盒策略必须统一。

完成上述适配后，再检查 Formality 的匹配、未解析模块和最终等价结果。该包装器同样会重建日志与临时工作目录。

### 5. 寄生参数提取与 STA

一般依赖顺序是先完成 StarRC 的 RC Extraction，再让 PrimeTime 使用对应寄生参数：

```bash
cd 04_pt/starrc
./run_starrc.sh

cd ../sta
./run_pt.sh
```

`run_starrc.sh` 会后台启动其配置的多个角点，但没有 `wait`；脚本返回仅表示任务已提交。开始 STA 前，确认所有提取任务结束，并逐个检查日志、寄生文件及 short/open 结果。

`run_pt.sh` 顺序运行多个角点，没有 fail-fast 或统一状态汇总。可在单个已适配角点中执行：

```bash
cd 04_pt/sta/<CORNER_DIRECTORY>
pt_shell -f run_pt.tcl
```

当前 StarRC/STA 脚本使用 `image_icb` 和 `eco/nlib/image_icb_09_chipfinish.nlib` 等后期项目配置，不是 `02_pr/soc_pad_wrapper` 输出的自动下游。验证时检查库、网表、SDC、寄生文件、时钟/例外约束、unconstrained path、setup/hold、transition、capacitance 与所有工具错误。

### 6. 物理验证（PV）

`05_pv/` 中存在多条需要按项目适配的路径，它们不会自动串联：

- `merge/icw/run_icw.csh`：删除本地 `data/pr_outputs` 和日志后，复制 `02_pr/outputs` 并执行 ICW 合并；脚本没有 shebang，应使用现场支持的 Unix Shell 显式启动；
- `merge/Calibredrv/merge.tcl`：Calibre 合并配置，当前包含 `image_icb`、外部路径和旧 `04_pv` 目录；
- `drc/run_drc.sh`：依次执行 Calibre DRC 与 Antenna；
- `lvs/`：LVS 相关脚本，包含机器相关的网表路径；
- `dummy/`：Dummy Fill 工艺资料；`merge_dummy.tcl` 只合并外部产生的 `Dummy.gds`，不生成 Dummy Fill。

DRC/Antenna 入口：

```bash
cd 05_pv/drc
./run_drc.sh
```

按项目配置 GDS、网表、规则文件、层映射、顶层名称和输出扩展名。ICW 当前匹配压缩 GDS 文件名，而 ICC2 Chip Finish 的输出命名也需实际核验；Calibre 合并、DRC runset 和 ICW 输出之间没有自动连接。

> [!WARNING]
> GDS 合并相关脚本会删除并重建本地中间目录和日志。执行前检查输入与待保留结果。

### 7. RedHawk、APL-DI

APL-DI（design-independent）是 RedHawk 设计分析前的标准单元库准备流程，不等同于某个设计的静态/动态功耗分析。仓库在 `06_power/apldi/{hvt,lvt,rvt}/` 中为 HVT、LVT、RVT 提供了示例 `apldi.conf` 和 `apldi.cmd`。

按实际项目使用的工艺库、VT 库和角点执行：

1. 修改 `apldi.conf` 中的 LEF、CDL/SPICE、Liberty、器件模型、VDD/VSS、PVT 角点、仿真器、并行度及工作目录；
2. 确认 `06_power/data/celllist/<vt>/` 与所用库一致；
3. 从对应 VT 目录以现场支持的 POSIX Shell 执行 `apldi.cmd`；
4. 检查 `apldi`、`aplmerge` 产生的 `.cdev`、`.pwcdev` 和 `.spiprof`，并只在匹配的 RedHawk 配置中使用它们。

例如：

```bash
cd 06_power/apldi/hvt
sh apldi.cmd
```

当前脚本定义的产物仅覆盖其列出的 FF/SS 角点；更换工艺库、VT、器件模型、供电或角点后，应重新生成匹配结果。

RedHawk Tcl 入口为 `ele_static_power/run_static_power.tcl`、`ele_dynamic_power/run_dynamic_power.tcl` 与 `ele_signal_em/run_signalem.tcl`。常见调用形式示例：

```bash
cd 06_power/ele_static_power
redhawk -f run_static_power.tcl
```

实际启动程序和参数依赖已安装 RedHawk 版本。当前 GSR 配置读取 `image_icb` ECO DEF，并保留旧 `../../03_pt/starrc/` 寄生路径和容错选项；它不能直接分析 `02_pr/soc_pad_wrapper`，也不应在未核对 LEF/DEF/库一致性时依赖容错选项掩盖错误。`write_timing_file.tcl` 同样包含机器相关的 Ansys 路径和 `image_icb` 会话设置。

### 8. ECO 与辅助签核检查

PT 或 PV 报告发现 timing、hold、setup、DRC 等违例后，可在已有实现数据库的可恢复副本上开展 ECO：

1. 保存当前 NDM 数据库、网表、报告与违例输入；
2. 按问题选择 `eco/scripts/fix_drc.tcl`、`fix_hold.tcl` 或 `fix_stup.tcl`；
3. 这些脚本会写入并覆盖 `eco/scripts/fix_ecotiming.tcl`，不要将它当作稳定、独立的固定输入；
4. 使用 `eco/scripts/09_chipfinish.tcl` 完成合法化、ECO 布线、输出与报告；该脚本会改动数据库并重建 `eco/outputs/`、`eco/rpts/`；
5. 重新执行受影响的 STA、PV 与必要的 Power 分析，确认修复未引入新违例。

当前 ECO 以 `image_icb` 为例，需替换为目标项目的 NDM、库、约束和检查输入后才能使用。

`07_signoff_check/` 是已加载设计的 ICC2/PrimeTime 交互会话片段：

- `01_check_net_length.tcl`：对超长 clock/signal net 插入 buffer 后生成报告，会修改当前设计；
- `check_vt_ratio.tcl`：统计不同 VT 单元的数量与面积，比例需由调用者据此计算；
- `check_dcap_ecocap.tcl`：依次改变 GUI 当前选择，后一次选择会覆盖前一次选择，不是统一的累计选择集合。

## 验证与提交边界

仓库没有根目录 build、lint、CI 或自动测试命令。每次变更应运行最小受影响阶段或角点，并检查：

1. 工具真实退出状态，以及 `tee`、后台任务对状态判断的影响；
2. 完整日志中的 error、warning、unresolved reference 和缺失输入；
3. 预期 NDM、网表、寄生文件、报告等产物是否生成且能被下游读取；
4. Formality 等价结果；
5. STA 约束完整性、setup/hold、transition、capacitance；
6. PV 的 DRC、Antenna、LVS、short/open；
7. RedHawk 的库、VT、角点、活动率、IR drop 和 EM 输入一致性。

修改设计名、输出文件名、角点、库或目录后，必须搜索下游 Formality、ICC2、StarRC/PrimeTime、PV、ECO 和 RedHawk 消费者。提交前使用 `git status` 检查生成物；不要提交 PDK、`.db`、LEF、NDM、技术文件、GDS/OASIS、提取数据库、大型网表或其他专有数据。

## 参考资料

- [`doc/dc.docx`](doc/dc.docx)：数字集成电路课程中对老师提供的 DC 脚本所作的注释与学习资料；
- [`doc/pr.docx`](doc/pr.docx)：数字集成电路课程中对老师提供的 PR 脚本所作的注释与学习资料；
- [`doc/PPT/`](doc/PPT/)：课程讲义和演示资料；
- [`SMIC_IO_Cell_Categories_CN.md`](SMIC_IO_Cell_Categories_CN.md)：SMIC I/O 单元分类参考。

这些课程文档针对老师提供的脚本编写，和仓库内本人持续调整的脚本并非逐行对应。阅读时应以当前目录中的脚本及其实际配置为准。
