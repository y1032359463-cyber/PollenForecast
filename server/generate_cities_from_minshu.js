/**
 * 从敏舒官方城市列表生成 cities.json
 * 数据来源: PollenForecast/figma/日志.md
 */

const fs = require('fs');
const path = require('path');

// 读取敏舒官方城市列表
const minshuFile = path.join(__dirname, '..', 'PollenForecast', 'figma', '日志.md');
const content = fs.readFileSync(minshuFile, 'utf8');

const cities = [];
const lines = content.split('\n');

// 跳过标题行（第一行是"城市编码	名称"）
for (let i = 1; i < lines.length; i++) {
  const line = lines[i].trim();
  if (!line) continue;
  
  // 解析每行：adcode\tname
  const parts = line.split('\t');
  if (parts.length >= 2) {
    const adcode = parts[0].trim();
    const name = parts[1].trim();
    
    // 验证 adcode 格式（6位数字）
    if (/^\d{6}$/.test(adcode) && name) {
      cities.push({
        adcode: adcode,
        name: name
      });
    }
  }
}

// 保存为 JSON
const outputPath = path.join(__dirname, 'cities.json');
fs.writeFileSync(outputPath, JSON.stringify(cities, null, 2), 'utf8');

console.log('========================================');
console.log('✅ 已从敏舒官方列表生成 cities.json');
console.log(`   数据来源: ${minshuFile}`);
console.log(`   城市数量: ${cities.length} 个`);
console.log('========================================');
console.log('前10个城市:');
cities.slice(0, 10).forEach(city => {
  console.log(`  ${city.adcode}: ${city.name}`);
});
console.log('...');
console.log('后5个城市:');
cities.slice(-5).forEach(city => {
  console.log(`  ${city.adcode}: ${city.name}`);
});
