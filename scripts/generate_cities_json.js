const fs = require('fs');
const path = require('path');

// 读取 china_area_full.json
const rawData = fs.readFileSync(path.join(__dirname, '../entry/src/main/resources/rawfile/china_area_full.json'), 'utf-8');
const provinces = JSON.parse(rawData);

const cities = [];

function traverse(node) {
    // 敏舒API支持区县级数据，我们提取所有 district
    // 同时也提取直辖市本身（作为兜底）
    
    // 如果是直辖市 (北京, 上海, 天津, 重庆)
    if (['110000', '310000', '120000', '500000'].includes(node.adcode)) {
        // 直辖市本身添加进去
        cities.push({
            adcode: node.adcode,
            name: node.name
        });
    }

    // 如果是地级市 (level = city)
    if (node.level === 'city') {
         cities.push({
            adcode: node.adcode,
            name: node.name
        });
    }

    // 如果是区县 (level = district)
    if (node.level === 'district') {
        cities.push({
            adcode: node.adcode,
            name: node.name
        });
    }

    if (node.districts && node.districts.length > 0) {
        node.districts.forEach(child => traverse(child));
    }
}

provinces.forEach(province => traverse(province));

// 去重
const uniqueCities = Array.from(new Set(cities.map(c => c.adcode)))
    .map(adcode => {
        return cities.find(c => c.adcode === adcode);
    });

console.log(`Extracted ${uniqueCities.length} cities.`);

// 写入 cities.json
const outputPath = path.join(__dirname, '../server/cloud-function/fetchpollendata/cities.json');
fs.writeFileSync(outputPath, JSON.stringify(uniqueCities, null, 2));
console.log(`Generated cities.json at ${outputPath}`);
