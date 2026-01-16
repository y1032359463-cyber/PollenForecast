const fs = require('fs');
const path = require('path');

// 读取拼音映射表
const data = JSON.parse(fs.readFileSync(path.join(__dirname, '../entry/src/main/resources/rawfile/pinyin_map.json'), 'utf-8'));

console.log('北京市信息:');
const bj = data.find(a => a.name === '北京市');
console.log(JSON.stringify(bj));

console.log('\n包含"金"的结果:');
const jin = data.filter(a => a.name.includes('金'));
jin.slice(0, 10).forEach(a => console.log(`  ${a.name} | ${a.pinyin} | ${a.initial}`));

console.log('\n首字母缩写包含"BJ"的结果:');
const bjInitial = data.filter(a => a.initial === 'BJ');
bjInitial.forEach(a => console.log(`  ${a.name} | ${a.pinyin} | ${a.initial}`));

console.log('\n首字母缩写包含"JS"的结果:');
const jsInitial = data.filter(a => a.initial === 'JS');
jsInitial.slice(0, 10).forEach(a => console.log(`  ${a.name} | ${a.pinyin} | ${a.initial}`));
