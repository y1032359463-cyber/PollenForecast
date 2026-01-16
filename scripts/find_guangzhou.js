const fs = require('fs');
const path = require('path');

// 读取拼音映射表
const pinyinData = JSON.parse(fs.readFileSync(path.join(__dirname, '../entry/src/main/resources/rawfile/pinyin_map.json'), 'utf-8'));

console.log('查找广州市信息:\n');

const guangzhou = pinyinData.find(item => item.name === '广州市');
if (guangzhou) {
  console.log('找到广州市:');
  console.log(`  name: ${guangzhou.name}`);
  console.log(`  pinyin: ${guangzhou.pinyin}`);
  console.log(`  initial: ${guangzhou.initial}`);
  console.log(`  adcode: ${guangzhou.adcode}`);
  console.log(`  level: ${guangzhou.level}`);
  
  console.log('\n测试搜索 "gz":');
  const lowerKeyword = 'gz';
  const results = [];
  
  for (const item of pinyinData) {
    if (item.name === '广州市') {
      console.log(`  中文名称匹配: ${item.name}`);
    }
    if (item.pinyin.includes(lowerKeyword)) {
      console.log(`  拼音匹配: ${item.pinyin}`);
    }
    if (item.initial.toLowerCase().includes(lowerKeyword)) {
      console.log(`  缩写匹配: ${item.initial}`);
      results.push(item);
    }
    if (item.initial.toLowerCase().startsWith(lowerKeyword)) {
      console.log(`  缩写前缀匹配: ${item.initial}`);
    }
  }
  
  console.log(`\n找到 ${results.length} 个缩写包含 "gz" 的结果`);
} else {
  console.log('未找到广州市');
  console.log('\n查找包含"广州"的结果:');
  const guangzhouResults = pinyinData.filter(item => item.name.includes('广州'));
  console.log(`找到 ${guangzhouResults.length} 个结果:`);
  guangzhouResults.forEach(item => {
    console.log(`  - ${item.name} (${item.pinyin}, ${item.initial})`);
  });
}
