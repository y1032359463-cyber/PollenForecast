const fs = require('fs');
const path = require('path');

// 读取拼音映射表
const pinyinData = JSON.parse(fs.readFileSync(path.join(__dirname, '../entry/src/main/resources/rawfile/pinyin_map.json'), 'utf-8'));

console.log('=== 拼音搜索测试 ===\n');

// 测试用例
const testCases = [
  { keyword: 'bj', desc: '搜索"bj" (应该找到北京)' },
  { keyword: 'js', desc: '搜索"js" (应该找到金山、江苏等)' },
  { keyword: 'gz', desc: '搜索"gz" (应该找到广州)' },
  { keyword: 'sz', desc: '搜索"sz" (应该找到深圳)' },
  { keyword: 'sh', desc: '搜索"sh" (应该找到上海)' },
  { keyword: 'bj', desc: '搜索"bj" (大小写不敏感)' },
  { keyword: 'BJ', desc: '搜索"BJ" (大写)' },
  { keyword: '金', desc: '搜索"金" (中文字符)' },
  { keyword: '北京', desc: '搜索"北京" (中文完整)' },
  { keyword: 'beijing', desc: '搜索"beijing" (完整拼音)' },
];

testCases.forEach(({ keyword, desc }) => {
  const lowerKeyword = keyword.toLowerCase().trim();
  const results = [];
  
  for (const item of pinyinData) {
    // 1. 中文名称匹配
    if (item.name.includes(keyword)) {
      results.push(item);
      continue;
    }
    
    // 2. 完整拼音匹配
    if (item.pinyin.includes(lowerKeyword)) {
      results.push(item);
      continue;
    }
    
    // 3. 首字母缩写匹配
    if (item.initial.toLowerCase().includes(lowerKeyword)) {
      results.push(item);
      continue;
    }
    
    // 4. 首字母缩写前缀匹配
    if (item.initial.toLowerCase().startsWith(lowerKeyword)) {
      results.push(item);
      continue;
    }
  }
  
  console.log(`${desc}:`);
  console.log(`  找到 ${results.length} 个结果`);
  
  if (results.length > 0) {
    console.log('  前5个结果:');
    results.slice(0, 5).forEach(item => {
      console.log(`    - ${item.name} (${item.pinyin}, ${item.initial})`);
    });
  }
  console.log('');
});

console.log('=== 测试完成 ===');
