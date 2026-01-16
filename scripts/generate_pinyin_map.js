const fs = require('fs');
const path = require('path');
const pinyin = require('pinyin').pinyin;

// 读取 china_area_full.json
const rawData = fs.readFileSync(path.join(__dirname, '../entry/src/main/resources/rawfile/china_area_full.json'), 'utf-8');
const provinces = JSON.parse(rawData);

const areas = [];

function traverse(node) {
    // 提取省、市、区县
    if (['province', 'city', 'district'].includes(node.level)) {
        const pinyinArray = pinyin(node.name, {
            style: pinyin.STYLE_NORMAL,
            heteronym: false
        });
        
        const fullPinyin = pinyinArray.map(p => p[0]).join('');
        const initial = pinyinArray.map(p => p[0][0].toUpperCase()).join('');
        // 新增：每个汉字的首字母（短缩写）
        const shortInitial = pinyinArray.map(p => p[0][0].toUpperCase()).join('');
        
        areas.push({
            name: node.name,
            pinyin: fullPinyin,
            initial: initial,
            shortInitial: shortInitial,  // 短缩写，如"BJ"对应"北京市"
            adcode: node.adcode,
            level: node.level
        });
    }

    if (node.districts && node.districts.length > 0) {
        node.districts.forEach(child => traverse(child));
    }
}

provinces.forEach(province => traverse(province));

// 去重（同一adcode只保留一个）
const uniqueAreas = Array.from(new Set(areas.map(a => a.adcode)))
    .map(adcode => {
        return areas.find(a => a.adcode === adcode);
    })
    .filter(Boolean); // 过滤掉undefined

console.log(`提取完成，共 ${uniqueAreas.length} 个区域`);
console.log(`  - 省/直辖市: ${uniqueAreas.filter(a => a.level === 'province').length} 个`);
console.log(`  - 地级市: ${uniqueAreas.filter(a => a.level === 'city').length} 个`);
console.log(`  - 区县: ${uniqueAreas.filter(a => a.level === 'district').length} 个`);

// 写入 pinyin_map.json
const outputPath = path.join(__dirname, '../entry/src/main/resources/rawfile/pinyin_map.json');
fs.writeFileSync(outputPath, JSON.stringify(uniqueAreas, null, 2));
console.log(`\n生成文件: ${outputPath}`);

// 写入到服务器端（备用）
const serverOutputPath = path.join(__dirname, '../server/pinyin_map.json');
fs.writeFileSync(serverOutputPath, JSON.stringify(uniqueAreas, null, 2));
console.log(`生成文件: ${serverOutputPath}`);

// 显示前10个示例
console.log('\n前10个区域示例:');
uniqueAreas.slice(0, 10).forEach(area => {
    console.log(`  ${area.name} | ${area.pinyin} | ${area.initial}`);
});
