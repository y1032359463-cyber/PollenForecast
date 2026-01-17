#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
生成 cities.json 文件（3210个城市）
数据来源：中华人民共和国行政区划代码
"""

import json

# 完整的省市区县 adcode 列表（3210个）
# 数据格式：{ "adcode": "110000", "name": "北京市" }

cities = [
    # 直辖市
    {"adcode": "110000", "name": "北京市"},
    {"adcode": "110101", "name": "东城区"},
    {"adcode": "110102", "name": "西城区"},
    {"adcode": "110105", "name": "朝阳区"},
    {"adcode": "110106", "name": "丰台区"},
    {"adcode": "110107", "name": "石景山区"},
    {"adcode": "110108", "name": "海淀区"},
    {"adcode": "110109", "name": "门头沟区"},
    {"adcode": "110111", "name": "房山区"},
    {"adcode": "110112", "name": "通州区"},
    {"adcode": "110113", "name": "顺义区"},
    {"adcode": "110114", "name": "昌平区"},
    {"adcode": "110115", "name": "大兴区"},
    {"adcode": "110116", "name": "怀柔区"},
    {"adcode": "110117", "name": "平谷区"},
    {"adcode": "110118", "name": "密云区"},
    {"adcode": "110119", "name": "延庆区"},
    
    {"adcode": "120000", "name": "天津市"},
    {"adcode": "120101", "name": "和平区"},
    {"adcode": "120102", "name": "河东区"},
    {"adcode": "120103", "name": "河西区"},
    {"adcode": "120104", "name": "南开区"},
    {"adcode": "120105", "name": "河北区"},
    {"adcode": "120106", "name": "红桥区"},
    {"adcode": "120110", "name": "东丽区"},
    {"adcode": "120111", "name": "西青区"},
    {"adcode": "120112", "name": "津南区"},
    {"adcode": "120113", "name": "北辰区"},
    {"adcode": "120114", "name": "武清区"},
    {"adcode": "120115", "name": "宝坻区"},
    {"adcode": "120116", "name": "滨海新区"},
    {"adcode": "120117", "name": "宁河区"},
    {"adcode": "120118", "name": "静海区"},
    {"adcode": "120119", "name": "蓟州区"},
    
    {"adcode": "310000", "name": "上海市"},
    {"adcode": "310101", "name": "黄浦区"},
    {"adcode": "310104", "name": "徐汇区"},
    {"adcode": "310105", "name": "长宁区"},
    {"adcode": "310106", "name": "静安区"},
    {"adcode": "310107", "name": "普陀区"},
    {"adcode": "310109", "name": "虹口区"},
    {"adcode": "310110", "name": "杨浦区"},
    {"adcode": "310112", "name": "闵行区"},
    {"adcode": "310113", "name": "宝山区"},
    {"adcode": "310114", "name": "嘉定区"},
    {"adcode": "310115", "name": "浦东新区"},
    {"adcode": "310116", "name": "金山区"},
    {"adcode": "310117", "name": "松江区"},
    {"adcode": "310118", "name": "青浦区"},
    {"adcode": "310120", "name": "奉贤区"},
    {"adcode": "310151", "name": "崇明区"},
    
    {"adcode": "500000", "name": "重庆市"},
    # ... 需要补充完整的 3210 个城市
]

# 注意：由于数据量巨大，这里只提供了示例
# 完整的 3210 个城市数据需要从官方数据源获取

# 保存为 JSON 文件
with open('cities.json', 'w', encoding='utf-8') as f:
    json.dump(cities, f, ensure_ascii=False, indent=2)

print(f"已生成 cities.json，包含 {len(cities)} 个城市")
