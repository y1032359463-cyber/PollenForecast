/**
 * 和风天气 API 代理服务
 * 部署到广州百度云服务器 (106.12.143.105)
 *
 * 功能：
 * - 代理和风天气 API 请求（隐藏 API Key）
 * - 数据缓存（减少 API 调用）
 * - 国内访问优化
 */

const express = require('express');
const axios = require('axios');
const NodeCache = require('node-cache');

const app = express();
const PORT = process.env.PORT || 3000;

// 和风天气 API 配置（个人版 API Host）
const QWEATHER_API_BASE = 'https://me7h2r64qx.re.qweatherapi.com/v7';
const QWEATHER_API_KEY = process.env.QWEATHER_API_KEY || '3e369ec38fd04c17bf786d8468e969ea';

// 缓存配置：15分钟过期
const cache = new NodeCache({ stdTTL: 900 });

// CORS 配置
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type');
  next();
});

// 健康检查
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    server: '广州百度云 - 和风天气代理',
    version: '1.0.0'
  });
});

/**
 * 实时天气查询
 * GET /weather/now?location=<经度>,<纬度>
 */
app.get('/weather/now', async (req, res) => {
  try {
    const { location } = req.query;

    if (!location) {
      return res.status(400).json({
        error: 'Missing required parameter',
        message: '缺少必需参数 location (格式: 经度,纬度)'
      });
    }

    // 缓存键
    const cacheKey = `weather_now_${location}`;

    // 检查缓存
    const cachedData = cache.get(cacheKey);
    if (cachedData) {
      console.log(`[CACHE HIT] ${cacheKey}`);
      return res.json(cachedData);
    }

    console.log(`[API REQUEST] 实时天气 - location=${location}`);

    // 调用和风天气 API
    const url = `${QWEATHER_API_BASE}/weather/now?location=${location}&key=${QWEATHER_API_KEY}`;
    const response = await axios.get(url, {
      timeout: 10000
    });

    const data = response.data;

    // 存入缓存
    cache.set(cacheKey, data);

    res.json(data);

  } catch (error) {
    console.error('[ERROR] 实时天气查询失败:', error.message);
    res.status(500).json({
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * 7天天气预报
 * GET /weather/7d?location=<经度>,<纬度>
 */
app.get('/weather/7d', async (req, res) => {
  try {
    const { location } = req.query;

    if (!location) {
      return res.status(400).json({
        error: 'Missing required parameter',
        message: '缺少必需参数 location (格式: 经度,纬度)'
      });
    }

    // 缓存键
    const cacheKey = `weather_7d_${location}`;

    // 检查缓存
    const cachedData = cache.get(cacheKey);
    if (cachedData) {
      console.log(`[CACHE HIT] ${cacheKey}`);
      return res.json(cachedData);
    }

    console.log(`[API REQUEST] 7天预报 - location=${location}`);

    // 调用和风天气 API
    const url = `${QWEATHER_API_BASE}/weather/7d?location=${location}&key=${QWEATHER_API_KEY}`;
    const response = await axios.get(url, {
      timeout: 10000
    });

    const data = response.data;

    // 存入缓存
    cache.set(cacheKey, data);

    res.json(data);

  } catch (error) {
    console.error('[ERROR] 7天预报查询失败:', error.message);
    res.status(500).json({
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * 太阳和月亮数据（日出日落）
 * GET /astronomy/sun?location=<经度>,<纬度>&date=<YYYYMMDD>
 */
app.get('/astronomy/sun', async (req, res) => {
  try {
    const { location, date } = req.query;

    if (!location || !date) {
      return res.status(400).json({
        error: 'Missing required parameters',
        message: '缺少必需参数 location 或 date (格式: YYYYMMDD)'
      });
    }

    // 缓存键
    const cacheKey = `astronomy_sun_${location}_${date}`;

    // 检查缓存
    const cachedData = cache.get(cacheKey);
    if (cachedData) {
      console.log(`[CACHE HIT] ${cacheKey}`);
      return res.json(cachedData);
    }

    console.log(`[API REQUEST] 日出日落 - location=${location}, date=${date}`);

    // 调用和风天气 API
    const url = `${QWEATHER_API_BASE}/astronomy/sun?location=${location}&date=${date}&key=${QWEATHER_API_KEY}`;
    const response = await axios.get(url, {
      timeout: 10000
    });

    const data = response.data;

    // 存入缓存
    cache.set(cacheKey, data);

    res.json(data);

  } catch (error) {
    console.error('[ERROR] 日出日落查询失败:', error.message);
    res.status(500).json({
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

// 404 处理
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: '接口不存在',
    availableEndpoints: [
      'GET /health',
      'GET /weather/now?location=<经度>,<纬度>',
      'GET /weather/7d?location=<经度>,<纬度>',
      'GET /astronomy/sun?location=<经度>,<纬度>&date=<YYYYMMDD>'
    ]
  });
});

// 启动服务
app.listen(PORT, '0.0.0.0', () => {
  console.log('========================================');
  console.log('   和风天气 API 代理服务已启动');
  console.log(`   服务器: 106.12.143.105:${PORT}`);
  console.log(`   时间: ${new Date().toLocaleString('zh-CN', { timeZone: 'Asia/Shanghai' })}`);
  console.log('========================================');
  console.log('接口列表:');
  console.log('  - GET /health');
  console.log('  - GET /weather/now?location=<经度>,<纬度>');
  console.log('  - GET /weather/7d?location=<经度>,<纬度>');
  console.log('  - GET /astronomy/sun?location=<经度>,<纬度>&date=<YYYYMMDD>');
  console.log('========================================');
});
