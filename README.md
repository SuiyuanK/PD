# 数字 IC 后端全流程 (Physical Design Full Flow)

本项目为数字 IC 后端物理设计全流程，基于 Synopsys 和 Mentor/Calibre 工具链，覆盖从 RTL 综合到 GDSII 签核的完整流程。采用 **SMIC** 工艺库。

---

## 项目成员（名单）

| 姓名 | 角色 | 联系方式 |
| :--- | :--- | :--- |
| **孔坚威** (Kong / SuiyuanK) | 项目负责人 | 3334108165@qq.com |

---

## 设计流程

```
RTL 源码
   │
   ▼
┌──────────────────────────────────────────────────────┐
│ 00_dc  — 逻辑综合 (Design Compiler)                    │
│          RTL → 门级网表 (.v) + 约束 (.sdc)              │
└──────────────────────────────────────────────────────┘
   │
   ▼
┌──────────────────────────────────────────────────────┐
│ 01_fm_post_dc  — 形式验证 (Formality)                  │
│                   综合后网表 vs RTL                     │
└──────────────────────────────────────────────────────┘
   │
   ▼
┌──────────────────────────────────────────────────────┐
│ 02_pr  — 布局布线 (IC Compiler II)                     │
│          Floorplan → Placement → CTS → Route → Finish │
└──────────────────────────────────────────────────────┘
   │
   ▼
┌──────────────────────────────────────────────────────┐
│ 03_fm_post_pr  — 形式验证 (Formality)                  │
│                   布局布线后网表 vs 综合后网表            │
└──────────────────────────────────────────────────────┘
   │
   ▼
┌──────────────────────────────────────────────────────┐
│ 04_pt  — 静态时序分析 STA (PrimeTime + StarRC)         │
│          Setup / Hold 时序检查与签核                    │
└──────────────────────────────────────────────────────┘
   │
   ▼
┌──────────────────────────────────────────────────────┐
│ 05_pv  — 物理验证 (Calibre)                           │
│          DRC / LVS / GDS Merge / Dummy Fill           │
└──────────────────────────────────────────────────────┘
   │
   ▼
┌──────────────────────────────────────────────────────┐
│ 06_power  — 功耗与 EM 分析 (Voltus / RedHawk)          │
│           Static Power / Dynamic Power / Signal EM    │
└──────────────────────────────────────────────────────┘
   │
   ▼
┌──────────────────────────────────────────────────────┐
│ 07_signoff_check  — 签核检查                            │
│        Net Length / VT Ratio / DCap / ECO Cap         │
└──────────────────────────────────────────────────────┘
```

---

## 目录结构

```
PD/
├── 00_dc/                  # 逻辑综合 (Design Compiler)
│   ├── scripts/
│   │   ├── dc.tcl          # 综合主脚本
│   │   ├── find_rtl.py     # RTL 文件列表生成器
│   │   ├── old/            # 旧版脚本备份
│   │   └── teacher/        # 教师参考脚本
│   ├── data/               # 输入数据 (RTL, 约束)
│   ├── outputs/            # 输出网表、约束
│   ├── logs/               # 运行日志
│   ├── rpts/               # 综合报告
│   ├── run_dc.sh           # 启动脚本
│   └── clean.sh            # 清理脚本
│
├── 01_fm_post_dc/          # DC 后形式验证 (Formality)
│   ├── scripts/            # FM 脚本
│   ├── data/               # 参考网表 & 实现网表
│   └── log/                # 运行日志
│
├── 02_pr/                  # 布局布线 (IC Compiler II)
│   ├── scripts/
│   │   ├── 00_common_design_settings.tcl
│   │   ├── 01_import_netlist.tcl
│   │   ├── 02_floorplan.tcl
│   │   ├── 03_power_routing.tcl
│   │   ├── 04_place_opt.tcl
│   │   ├── 05_cts.tcl
│   │   ├── 06_cts_opt.tcl
│   │   ├── 07_route.tcl
│   │   ├── 08_route_opt.tcl
│   │   ├── 09_chipfinish.tcl
│   │   ├── scenario_setup.tcl / scenario_hold.tcl
│   │   └── teacher/        # 教师参考脚本
│   └── data/               # 设计数据
│
├── 03_fm_post_pr/          # PR 后形式验证 (Formality)
│   ├── scripts/            # FM 脚本
│   ├── data/               # 参考 & 实现网表
│   └── log/                # 运行日志
│
├── 04_pt/                  # 静态时序分析 (PrimeTime)
│   ├── sta/                # STA 脚本
│   └── starrc/             # StarRC 寄生提取
│
├── 05_pv/                  # 物理验证 (Calibre)
│   ├── drc/                # DRC 设计规则检查
│   ├── lvs/                # LVS 版图与原理图比对
│   ├── merge/              # GDS 合并
│   └── dummy/              # Dummy Fill
│
├── 06_power/               # 功耗分析 (Voltus/RedHawk)
│   ├── ele_static_power/   # 静态功耗分析
│   ├── ele_dynamic_power/  # 动态功耗分析
│   ├── ele_signal_em/      # 信号 EM 分析
│   └── apldi/              # APLDI 分析
│
├── 07_signoff_check/       # 签核检查
│   ├── 01_check_net_length.tcl
│   ├── check_vt_ratio.tcl
│   ├── check_dcap_ecocap.tcl
│   └── check_list.png      # 签核检查清单
│
├── eco/                    # ECO 工程变更
│   ├── scripts/
│   └── data/
│
├── doc/                    # 文档
│   ├── dc.docx             # DC 综合文档
│   ├── pr.docx             # PR 布局布线文档
│   └── PPT/                # 答辩 PPT
│
├── others/                 # 其他资源
│   └── scripts/
│
└── SMIC_IO_Cell_Categories_CN.md  # SMIC I/O 单元分类参考
```

---

## 快速开始

### 1. 逻辑综合 (DC)

DC 脚本位于 `00_dc/` 目录下，运行 `run_dc.sh` 即可启动。整个 DC 流程通过 `run_dc.sh` 顶部的环境变量来控制：

```bash
cd 00_dc
# 等号两边不能有空格
# Define RTL source files directory
export rtlDir="../../RTL"
export TOP_MODULE="soc_pad_wrapper"

export exit_switch=false
# 开启只读RTL模式, 其它选项除exit_switch外无效
export read_rtl_switch=false

export area_switch=true
export power_switch=true
export fix_hold_switch=true
export remove_tie_dont_use_switch=false

# ultra_switch开启时 high_switch无效
export ultra_switch=true
export high_switch=true

# gate_clock_switch开启时 compile_ultra 使用 -gate_clock 插入时钟门控单元
export gate_clock_switch=true

./run_dc.sh
```

#### 变量说明

| 变量 | 作用 |
| :--- | :--- |
| `rtlDir` | RTL 文件目录。需包含 `rtl_verilog.list` 与 `rtl_sverilog.list`。将 `scripts/find_rtl.py` 放入你的 RTL 目录运行即可自动生成。该脚本会过滤文件名以 `tb`、`tb_` 开头或以 `_tb`、`_testbench` 结尾的 `.v` / `.sv` 文件（避免误过滤 `btb.v` 这类正常 RTL）。 |
| `TOP_MODULE` | 顶层模块名称。脚本将读入 RTL 并以该模块为 TOP 进行综合。 |
| `exit_switch` | 退出开关。 |
| `read_rtl_switch` | 开启只读 RTL 模式，此时除 `exit_switch` 外其他选项无效。 |
| `area_switch` | 面积优化开关。 |
| `power_switch` | 功耗优化开关。 |
| `fix_hold_switch` | hold 修复开关。 |
| `remove_tie_dont_use_switch` | 移除 tie / dont_use 单元开关。 |
| `ultra_switch` | 开启 `compile_ultra`。开启时 `high_switch` 无效。 |
| `high_switch` | 高级优化开关（`ultra_switch` 开启时无效）。 |
| `gate_clock_switch` | 时钟门控开关。开启时 `compile_ultra` 附加 `-gate_clock` 插入时钟门控单元（仅在 `ultra_switch` 开启时生效）。 |

#### 注意事项

- 同一时刻只能运行一个 DC 流程。
- 需要将 `scripts/dc.tcl` 中的工艺库改成你自己的库。
- 本人 DC 所用的工艺库放在 `00_dc/data/lib/` 下，**未上传**。使用时需自行放置该目录或修改 `scripts/dc.tcl` 中的库路径指向你自己的库。
- 脚本还有一些未完善的功能，使用时请注意。

### 2. 形式验证 — DC 后 (FM)

```bash
cd 01_fm_post_dc
# 修改 ./run_fm.sh 顶部的相关变量（rtlDir / TOP_MODULE / netlistDir / svfDir）
# 以及 scripts/run_fm.tcl 中的工艺库路径
./run_fm.sh
```

### 3. 布局布线 (PR)

```bash
cd 02_pr
# 在 ICC II 中依次执行 scripts 下的脚本：
# 00_common → 01_import → 02_floorplan → 03_power → 04_place → 05_cts → ... → 09_chipfinish
icc2_shell -f scripts/00_common_design_settings.tcl
```

### 4. 形式验证 — PR 后 (FM)

```bash
cd 03_fm_post_pr
# 修改 ./run_fm.sh 顶部的相关变量（TOP_MODULE / post_dc_Dir / post_pr_Dir）
# 以及 scripts/run_fm.tcl 中的工艺库路径
./run_fm.sh
```

### 5. 静态时序分析 — STA (PT)

```bash
cd 04_pt
# 修改对应库路径后运行 STA
```

### 6. 物理验证 (PV)

```bash
cd 05_pv
# DRC / LVS / GDS Merge / Dummy Fill
```

### 7. 功耗分析

```bash
cd 06_power
# 静态 / 动态功耗 & 信号 EM
```

### 8. 签核检查

```bash
cd 07_signoff_check
# 线长、VT 比例、DCap / ECO Cap 检查
```

---

## 工具链

| 步骤 | 工具 | 用途 |
| :--- | :--- | :--- |
| 逻辑综合 | Synopsys Design Compiler (DC) | RTL → 门级网表 |
| 形式验证 | Synopsys Formality | 网表等价性检查 |
| 布局布线 | Synopsys IC Compiler II (ICC2) | 物理实现 |
| 静态时序分析 | Synopsys PrimeTime (PT) | 时序签核 |
| 寄生提取 | Synopsys StarRC | RC 寄生参数提取 |
| 物理验证 | Mentor Calibre | DRC / LVS |
| 功耗分析 | Cadence Voltus / RedHawk | 功耗 & EM 签核 |

---

## 工艺库

- **Foundry**: SMIC
- **IO 单元**: 见 [SMIC_IO_Cell_Categories_CN.md](SMIC_IO_Cell_Categories_CN.md)

---

## 参考文档

- `doc/dc.docx` — 综合阶段详细文档
- `doc/pr.docx` — 布局布线阶段详细文档
- `doc/PPT/` — 答辩演示文稿
- `SMIC_IO_Cell_Categories_CN.md` — SMIC I/O 单元分类速查