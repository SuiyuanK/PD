
"""
脚本功能：
1. 从本脚本所在目录开始递归扫描所有子目录。
2. 查找 RTL 源文件并按后缀分类：`.v` 与 `.sv`。
3. 过滤文件名中包含 `tb`（不区分大小写）的文件。
4. 以相对脚本目录的路径格式输出列表（路径分隔符统一为 `/`）。
5. 生成两个清单文件：
   - rtl_verilog.list    （保存 .v 文件）
   - rtl_sverilog.list   （保存 .sv 文件）

运行环境：
- Python 3.6 及以上（仅依赖标准库 os）。
- 适用于 Windows    Linux 与 macOS 未做测试

运行方式：
在命令行进入本脚本所在目录后执行：
    python find_rtl.py
"""

import os

def find_verilog_files():
    # 获取当前脚本所在的目录（而非运行目录）
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # 存储找到的文件路径
    verilog_files = []
    sverilog_files = []
    
    # 遍历脚本所在目录及其子目录
    for root, dirs, files in os.walk(script_dir):
        for file in files:
            # 检查文件名不包含tb（不区分大小写）
            if 'tb' not in file.lower():
                # 获取文件相对于脚本目录的相对路径
                rel_path = os.path.relpath(os.path.join(root, file), script_dir)
                # 将路径中的反斜杠替换为斜杠
                rel_path = rel_path.replace('\\', '/')
                
                # 根据扩展名分类
                if file.lower().endswith('.v'):
                    verilog_files.append(rel_path)
                elif file.lower().endswith('.sv'):
                    sverilog_files.append(rel_path)
    
    # 将Verilog文件写入rtl_verilog.list
    verilog_output_path = os.path.join(script_dir, 'rtl_verilog.list')
    with open(verilog_output_path, 'w', encoding='utf-8', newline='\n') as f:
        for file_path in verilog_files:
            f.write(f"{file_path}\n")
    
    # 将SystemVerilog文件写入rtl_sverilog.list
    sverilog_output_path = os.path.join(script_dir, 'rtl_sverilog.list')
    with open(sverilog_output_path, 'w', encoding='utf-8', newline='\n') as f:
        for file_path in sverilog_files:
            f.write(f"{file_path}\n")
    
    print(f"已找到 {len(verilog_files)} 个Verilog文件(.v)，已写入rtl_verilog.list")
    print(f"已找到 {len(sverilog_files)} 个SystemVerilog文件(.sv)，已写入rtl_sverilog.list")

if __name__ == "__main__":
    find_verilog_files()