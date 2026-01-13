#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
从日志文件解析3210个adcode数据并生成TypeScript映射表
"""

import re

def parse_adcode_data(input_file):
    """解析adcode数据"""
    with open(input_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    adcode_map = []
    for line in lines[1:3212]:  # 跳过表头，读取3210条数据
        line = line.strip()
        if not line or line.startswith('城市编码'):
            continue
        
        # 匹配格式: 数字 adcode\t名称
        match = re.match(r'\d+→(\d+)\s+(.+)', line)
        if match:
            adcode = match.group(1)
            name = match.group(2).strip()
            
            # 去除后缀（但保留完整名称作为key）
            adcode_map.append({
                'name': name,
                'adcode': adcode
            })
    
    return adcode_map

def generate_typescript_map(adcode_data):
    """生成TypeScript Map初始化代码"""
    lines = []
    for item in adcode_data:
        name = item['name']
        adcode = item['adcode']
        lines.append(f"  ['{name}', '{adcode}'],")
    
    return '\n'.join(lines)

def main():
    input_file = 'figma/日志.md'
    
    print('开始解析adcode数据...')
    adcode_data = parse_adcode_data(input_file)
    print(f'解析完成，共{len(adcode_data)}条数据')
    
    print('\n前10条示例:')
    for i in range(min(10, len(adcode_data))):
        item = adcode_data[i]
        print(f"  ['{item['name']}', '{item['adcode']}'],")
    
    print('\n生成TypeScript代码...')
    ts_code = generate_typescript_map(adcode_data)
    
    # 输出到文件
    output_file = 'scripts/adcode_map_generated.ts'
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('// 自动生成的3210个adcode映射表\n')
        f.write('// 数据来源：舒敏花粉API官方城市编码表\n\n')
        f.write('const ADCODE_MAP: Map<string, string> = new Map([\n')
        f.write(ts_code)
        f.write('\n])\n')
    
    print(f'已生成文件: {output_file}')
    print(f'总行数: {len(adcode_data) + 4}')

if __name__ == '__main__':
    main()
