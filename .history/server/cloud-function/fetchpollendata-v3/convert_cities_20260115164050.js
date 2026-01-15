/**
 * 将 figma/日志.md 中的NDJSON格式城市数据转换为JSON数组
 * 用于云函数代码
 */

const fs = require('fs');
const path = require('path');

// 读取NDJSON文件
const inputPath = path.join(__dirname, '../../../../figma/日志.md');
const rawData = fs.readFileSync(inputPath, 'utf-8');

// 解析每行JSON
const lines = rawData.split('\n').filter(line => line.trim());
const cities = [];

for (const line of lines) {
  const trimmed = line.trim();
  if (trimmed && trimmed.startsWith('{')) {
    try {
      const city = JSON.parse(trimmed);
      if (city.adcode && city.name) {
        cities.push(city);
      }
    } catch (e) {
      console.warn('解析失败:', trimmed);
    }
  }
}

console.log(`总共解析 ${cities.length} 个城市/区县`);

// 保存为JSON数组文件（用于云函数）
const outputPath = path.join(__dirname, 'cities.json');
fs.writeFileSync(outputPath, JSON.stringify(cities, null, 2), 'utf-8');
console.log(`已保存到: ${outputPath}`);

// 保存为内联数组格式（可以直接复制到代码中）
const inlinePath = path.join(__dirname, 'cities_inline.js');
const inlineCode = 'var CITY_LIST = ' + JSON.stringify(cities, null, 2) + ';';
fs.writeFileSync(inlinePath, inlineCode, 'utf-8');
console.log(`已保存内联格式到: ${inlinePath}`);

// 统计信息
const cityCount = cities.filter(c => c.adcode.endsWith('00')).length;
const districtCount = cities.length - cityCount;
console.log(`城市数量: ${cityCount}`);
console.log(`区县数量: ${districtCount}`);
