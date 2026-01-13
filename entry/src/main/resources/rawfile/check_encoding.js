const fs = require('fs');

// 读取原始字节
const buffer = fs.readFileSync('china_area_full.json');
console.log('文件大小:', buffer.length, '字节');
console.log('前100字节:', buffer.slice(0, 100).toString('utf-8'));

// 尝试UTF-8解析
try {
  const content = buffer.toString('utf-8');
  const data = JSON.parse(content);
  console.log('\n✅ UTF-8解析成功！');
  console.log('省份数量:', data.length);
  console.log('第1个省份:', data[0].name);
  console.log('第2个省份:', data[1]?.name);
  console.log('第3个省份:', data[2]?.name);
  
  // 查找北京、上海在哪
  const beijing = data.findIndex(p => p.name.includes('北京'));
  const shanghai = data.findIndex(p => p.name.includes('上海'));
  console.log('\n北京省份索引:', beijing);
  console.log('上海省份索引:', shanghai);
  
} catch (e) {
  console.error('\n❌ UTF-8解析失败:', e.message);
}
