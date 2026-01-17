/**
 * 从 china-area-data 生成完整的 cities.json（3210个城市）
 * 数据结构是嵌套的：{ "86": { "110000": "北京市", ... }, "110000": { "110100": "市辖区", ... }, ... }
 */

const chinaAreaData = require('china-area-data');
const fs = require('fs');
const path = require('path');

const cities = [];
const seen = new Set();

/**
 * 递归提取所有6位adcode和名称
 */
function extractCities(data, parentName = '') {
  if (typeof data === 'string') {
    // 如果是字符串，说明是名称，不需要处理
    return;
  }
  
  if (typeof data === 'object' && data !== null) {
    Object.keys(data).forEach(key => {
      const value = data[key];
      
      // 如果是6位adcode，提取名称
      if (key.length === 6 && /^\d{6}$/.test(key)) {
        if (typeof value === 'string') {
          // 值是字符串，说明是名称
          if (!seen.has(key)) {
            seen.add(key);
            cities.push({
              adcode: key,
              name: value
            });
          }
        } else if (typeof value === 'object' && value !== null) {
          // 值是对象，递归处理
          // 先尝试从父级获取名称
          let currentName = parentName;
          if (typeof value === 'object') {
            // 尝试从对象中找到名称（可能是第一个字符串值）
            const firstStringValue = Object.values(value).find(v => typeof v === 'string');
            if (firstStringValue) {
              currentName = firstStringValue;
            }
          }
          extractCities(value, currentName);
        }
      } else {
        // 不是6位adcode，递归处理
        extractCities(value, parentName);
      }
    });
  }
}

// 从根数据开始提取
extractCities(chinaAreaData);

// 去重并按 adcode 排序
const uniqueCities = Array.from(seen).map(adcode => {
  return cities.find(c => c.adcode === adcode);
}).filter(c => c).sort((a, b) => a.adcode.localeCompare(b.adcode));

// 保存为 JSON
const outputPath = path.join(__dirname, 'cities.json');
fs.writeFileSync(outputPath, JSON.stringify(uniqueCities, null, 2), 'utf8');

console.log('========================================');
console.log(`✅ 已生成 cities.json`);
console.log(`   文件位置: ${outputPath}`);
console.log(`   城市数量: ${uniqueCities.length} 个`);
console.log('========================================');
console.log('前10个城市:');
uniqueCities.slice(0, 10).forEach(city => {
  console.log(`  ${city.adcode}: ${city.name}`);
});
