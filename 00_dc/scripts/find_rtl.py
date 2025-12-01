import os

def find_verilog_files():
    # 获取当前脚本所在的目录（而非运行目录）
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # 要查找的文件扩展名
    extensions = ('.v', '.sv')
    
    # 存储找到的文件路径
    verilog_files = []
    
    # 遍历脚本所在目录及其子目录
    for root, dirs, files in os.walk(script_dir):
        for file in files:
            # 检查文件扩展名是否匹配，并且文件名不包含tb（不区分大小写）
            if (file.lower().endswith(extensions) and 
                'tb' not in file.lower()):
                # 获取文件相对于脚本目录的相对路径
                rel_path = os.path.relpath(os.path.join(root, file), script_dir)
                # 将路径中的反斜杠替换为斜杠
                rel_path = rel_path.replace('\\', '/')
                verilog_files.append(rel_path)
    
    # 将结果写入rtl.list文件（保存到脚本所在目录）
    output_path = os.path.join(script_dir, 'rtl.list')
    with open(output_path, 'w', encoding='utf-8') as f:
        for file_path in verilog_files:
            f.write(f"{file_path}\n")
    
    print(f"已找到 {len(verilog_files)} 个Verilog/SV文件（已过滤含tb字样的文件），相对路径已写入脚本所在目录的rtl.list")

if __name__ == "__main__":
    find_verilog_files()