// 云函数：定时抓取花粉数据
const cloud = require('@agconnect/cloud-function');
const axios = require('axios');

// 敏舒 API 配置
const MINSHU_API_BASE = 'https://cdn.myminshu.com';
const MINSHU_API_KEY = 'AK-lYpA8KnbT0lzPNvfjIqCSLDMLPz1n3htrENs';

// 城市列表（3210个城市）
const CITY_LIST = require('./cities.json');

// 延迟函数（避免循环中 setTimeout 警告）
const delay = (ms) => {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
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
      
      // 使用局部变量避免闭包问题
      let batchSuccess = 0;
      let batchFail = 0;
      
      // 并发请求（10个城市）
      const promises = batch.map(async (city) => {
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
          
          batchSuccess++;
          return { success: true, city: city.name };
        } catch (error) {
          batchFail++;
          console.error(`[云函数] ${city.name}(${city.adcode}) ${day} 失败:`, error.message);
          return { success: false, city: city.name, error: error.message };
        }
      });
      
      await Promise.all(promises);
      
      // 更新全局计数器
      successCount += batchSuccess;
      failCount += batchFail;
      
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
