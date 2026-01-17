# -*- coding: utf-8 -*-
"""
从敏舒官方城市列表生成 cities.json
数据来源: PollenForecast/figma/日志.md
"""

import json
import os
import re

# 文件路径
script_dir = os.path.dirname(os.path.abspath(__file__))
minshu_file = os.path.join(script_dir, '..', 'PollenForecast', 'figma', '日志.md')
output_file = os.path.join(script_dir, 'cities.json')

# 读取敏舒官方城市列表
with open(minshu_file, 'r', encoding='utf-8') as f:
    content = f.read()

cities = []
lines = content.strip().split('\n')

# 跳过标题行（第一行是"城市编码\t名称"）
for i, line in enumerate(lines):
    if i == 0:  # 跳过标题行
        continue
    
    line = line.strip()
    if not line:
        continue
    
    # 解析每行：adcode\tname
    parts = line.split('\t')
    if len(parts) >= 2:
        adcode = parts[0].strip()
        name = parts[1].strip()
        
        # 验证 adcode 格式（6位数字）
        if re.match(r'^\d{6}$', adcode) and name:
            cities.append({
                'adcode': adcode,
                'name': name
            })

# 保存为 JSON
with open(output_file, 'w', encoding='utf-8') as f:
    json.dump(cities, f, ensure_ascii=False, indent=2)

print('=' * 40)
print('Done! Generated cities.json from Minshu official list')
print(f'   Source: {minshu_file}')
print(f'   Total cities: {len(cities)}')
print('=' * 40)
