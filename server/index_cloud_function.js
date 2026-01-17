/* eslint-env es8 */
/* jshint esversion: 8 */
// 云函数：定时抓取花粉数据
const cloud = require('@agconnect/cloud-function');
const axios = require('axios');
const fs = require('fs');
const path = require('path');

// 敏舒 API 配置
const MINSHU_API_BASE = 'https://cdn.myminshu.com';
const MINSHU_API_KEY = 'AK-lYpA8KnbT0lzPNvfjIqCSLDMLPz1n3htrENs';

// 城市列表（3210个城市）- 使用 fs.readFileSync 加载（云函数推荐方式）
let CITY_LIST = [];
try {
  CITY_LIST = JSON.parse(
    fs.readFileSync(path.join(__dirname, 'cities.json'), 'utf8')
  );
  console.log(`[云函数] 成功加载 ${CITY_LIST.length} 个城市`);
} catch (error) {
  console.error('[云函数] 加载 cities.json 失败:', error.message);
  throw error;
}

// 延迟函数（避免循环中 setTimeout 警告）
const delay = (ms) => {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
};

// 处理单个城市的数据抓取
const fetchCityData = async (city, day, collection) => {
  try {
    const url = `${MINSHU_API_BASE}/day/pollen/${day}/${city.adcode}?apikey=${MINSHU_API_KEY}`;
    const response = await axios.get(url, { timeout: 15000 });
    
    // 写入云数据库
    await collection.doc(`${city.adcode}_${day}`).set({
      adcode: city.adcode,
      recordDate: day,
      data: JSON.stringify(response.data),  // 转换为 JSON 字符串
      updatedAt: Date.now()  // Long 类型（毫秒时间戳）
    });
    
    return { success: true, city: city.name, adcode: city.adcode };
  } catch (error) {
    console.error(`[云函数] ${city.name}(${city.adcode}) ${day} 失败:`, error.message);
    return { success: false, city: city.name, adcode: city.adcode, error: error.message };
  }
};

exports.main = async (event, context) => {
  console.log('[云函数] 开始预抓取花粉数据...');
  
  // 计算需要抓取的日期（今天 + 未来5天）
  const days = [];
  for (let i = 0; i < 6; i++) {
    const date = new Date();
    date.setDate(date.getDate() + i);
    days.push(date.toISOString().split('T')[0]);
  }
  
  const QPS_LIMIT = 10;
  const BATCH_SIZE = 10;
  let successCount = 0;
  let failCount = 0;
  
  // 获取云数据库实例
  const cloudDB = cloud.database();
  const db = cloudDB.database();
  const collection = db.collection('PollenData');
  
  // 为每个日期抓取数据
  for (const day of days) {
    console.log(`[云函数] 抓取日期: ${day}`);
    
    // 分批处理城市
    for (let i = 0; i < CITY_LIST.length; i += BATCH_SIZE) {
      const batch = CITY_LIST.slice(i, i + BATCH_SIZE);
      
      // 并发请求（10个城市）- 使用独立的函数避免闭包警告
      const promises = batch.map((city) => fetchCityData(city, day, collection));
      const results = await Promise.all(promises);
      
      // 统计成功和失败数量
      const batchResults = results.reduce((acc, result) => {
        if (result.success) {
          acc.success++;
        } else {
          acc.fail++;
        }
        return acc;
      }, { success: 0, fail: 0 });
      
      successCount += batchResults.success;
      failCount += batchResults.fail;
      
      // 批次之间延迟 1 秒（确保不超过 QPS 10）
      if (i + BATCH_SIZE < CITY_LIST.length) {
        await delay(1000);
      }
      
      // 每 100 个城市打印进度
      if ((i + BATCH_SIZE) % 100 === 0 || i + BATCH_SIZE >= CITY_LIST.length) {
        console.log(`[云函数] 进度: ${Math.min(i + BATCH_SIZE, CITY_LIST.length)}/${CITY_LIST.length}`);
      }
    }
  }
  
  console.log(`[云函数] 完成: 成功 ${successCount}, 失败 ${failCount}`);
  
  return {
    code: 0,
    message: 'success',
    successCount,
    failCount,
    totalDays: days.length,
    totalCities: CITY_LIST.length
  };
};
