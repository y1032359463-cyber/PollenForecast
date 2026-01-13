import json

# 读取文件（尝试不同编码）
input_file = "china_area_full.json"
output_file = "china_area_full_fixed.json"

# 尝试用UTF-8读取
try:
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    print(f"UTF-8读取成功，第一个省份: {data[0]['name']}")
except:
    print("UTF-8失败，尝试GBK")
    try:
        with open(input_file, 'r', encoding='gbk') as f:
            data = json.load(f)
        print(f"GBK读取成功，第一个省份: {data[0]['name']}")
    except Exception as e:
        print(f"GBK也失败: {e}")
        exit(1)

# 写回UTF-8（无BOM）
with open(output_file, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f"✅ 转换完成！输出文件: {output_file}")
print(f"共 {len(data)} 个省份")
print(f"前3个省份: {[p['name'] for p in data[:3]]}")
