const fs = require('fs');
const path = require('path');

// 读取拼音映射表
const data = JSON.parse(fs.readFileSync(path.join(__dirname, '../entry/src/main/resources/rawfile/pinyin_map.json'), 'utf-8'));

console.log('北京市信息:');
const bj = data.find(a => a.name === '北京市');
console.log(JSON.stringify(bj));

console.log('\n搜索 "bj" (不区分大小写，includes):');
const bjSearch = data.filter(a => a.initial.toLowerCase().includes('bj'));
console.log(`找到 ${bjSearch.length} 个结果:`);
bjSearch.slice(0, 10).forEach(a => console.log(`  ${a.name} | ${a.initial}`));

console.log('\n搜索 "js" (不区分大小写，includes):');
const jsSearch = data.filter(a => a.initial.toLowerCase().includes('js'));
console.log(`找到 ${jsSearch.length} 个结果:`);
jsSearch.slice(0, 10).forEach(a => console.log(`  ${a.name} | ${a.initial}`));

console.log('\n搜索 "金山区" (中文名称):');
const jinshanSearch = data.filter(a => a.name.includes('金山'));
console.log(`找到 ${jinshanSearch.length} 个结果:`);
jinshanSearch.forEach(a => console.log(`  ${a.name} | ${a.pinyin} | ${a.initial}`));
