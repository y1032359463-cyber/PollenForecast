/**
 * Google Pollen API 代理服务（带测试控制台）
 * 部署到广州百度云服务器 (106.12.143.105:3000)
 * 
 * 功能：
 * - 代理 Google Pollen API 请求
 * - 数据缓存（15分钟）
 * - ✨ 可视化测试控制台（调整花粉数据）
 */

const express = require('express');
const axios = require('axios');
const NodeCache = require('node-cache');

const app = express();
const PORT = process.env.PORT || 3000;

// Google Pollen API 配置
const GOOGLE_API_KEY = process.env.GOOGLE_POLLEN_API_KEY || 'AIzaSyDHgU_oXe_qHwRU5-e8gKr1jTiIFz7_Wt8';

// 缓存配置：15分钟过期
const cache = new NodeCache({ stdTTL: 900 });

// ========== 测试模式配置 ==========
let testConfig = {
  enabled: false,
  pollenValue: 150,
  pollenLevel: 'MEDIUM',
  pollenType: 'GRASS',
  city: '广州市',
  lastUpdate: null
};

// CORS 配置
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }
  next();
});

app.use(express.json());

// ========== 健康检查 ==========
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    server: '广州百度云 - Google Pollen API 代理',
    version: '2.0.0',
    testMode: testConfig.enabled,
    features: ['pollen-api', 'admin-console', 'cache']
  });
});

// ========== 管理控制台 - 可视化调整花粉数据 ==========
app.get('/admin', (req, res) => {
  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.send(getAdminHTML());
});

// 获取测试配置
app.get('/admin/status', (req, res) => {
  res.json(testConfig);
});

// 保存测试配置
app.post('/admin/set', (req, res) => {
  const { enabled, pollenValue, pollenLevel, pollenType } = req.body;
  
  testConfig.enabled = Boolean(enabled);
  testConfig.pollenValue = parseInt(pollenValue) || 150;
  testConfig.pollenLevel = pollenLevel || 'MEDIUM';
  testConfig.pollenType = pollenType || 'GRASS';
  testConfig.lastUpdate = new Date().toISOString();
  
  console.log(`[测试配置] 模式: ${testConfig.enabled ? '开启' : '关闭'}, 花粉值: ${testConfig.pollenValue}, 等级: ${testConfig.pollenLevel}`);
  
  res.json({
    success: true,
    config: testConfig
  });
});

// ========== 花粉查询接口 ==========
app.get('/pollen-api', async (req, res) => {
  try {
    const { lat, lng, days = 5 } = req.query;

    // 参数验证
    if (!lat || !lng) {
      return res.status(400).json({
        error: 'Missing required parameters',
        message: '缺少必需参数 lat 或 lng'
      });
    }

    const latitude = parseFloat(lat);
    const longitude = parseFloat(lng);
    const forecastDays = parseInt(days);

    if (isNaN(latitude) || isNaN(longitude)) {
      return res.status(400).json({
        error: 'Invalid parameters',
        message: '无效的经纬度参数'
      });
    }

    // ========== 测试模式：返回自定义数据 ==========
    if (testConfig.enabled) {
      console.log(`[测试模式] 返回自定义花粉数据: ${testConfig.pollenValue} (${testConfig.pollenLevel})`);
      const mockData = generateMockPollenData(testConfig.pollenValue, testConfig.pollenLevel, testConfig.pollenType, forecastDays);
      return res.json(mockData);
    }

    // ========== 正常模式：调用真实API ==========
    const cacheKey = `pollen_${latitude.toFixed(2)}_${longitude.toFixed(2)}_${forecastDays}`;
    
    // 检查缓存
    const cachedData = cache.get(cacheKey);
    if (cachedData) {
      console.log(`[缓存命中] ${cacheKey}`);
      return res.json(cachedData);
    }

    console.log(`[API请求] lat=${latitude}, lng=${longitude}, days=${forecastDays}`);

    // 调用 Google Pollen API
    const googleUrl = `https://pollen.googleapis.com/v1/forecast:lookup?key=${GOOGLE_API_KEY}`;
    const requestBody = {
      location: {
        latitude: latitude,
        longitude: longitude
      },
      days: forecastDays,
      languageCode: 'zh-CN'
    };

    const response = await axios.post(googleUrl, requestBody, {
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json'
      }
    });

    const data = response.data;

    // 转换数据格式
    const result = {
      regionCode: data.regionCode || 'UNKNOWN',
      dailyInfo: (data.dailyInfo || []).map((day) => ({
        date: day.date,
        pollenTypeInfo: day.pollenTypeInfo || [],
        plantInfo: day.plantInfo || []
      }))
    };

    // 存入缓存
    cache.set(cacheKey, result);
    console.log(`[成功] 数据已缓存: ${cacheKey}`);

    res.json(result);

  } catch (error) {
    console.error('[错误]', error.message);
    
    if (error.response) {
      console.error('[Google API错误]', error.response.status, error.response.data);
      return res.status(error.response.status).json({
        error: 'Google API Error',
        message: error.response.data.message || '花粉数据获取失败',
        details: error.response.data
      });
    }

    res.status(500).json({
      error: 'Internal Server Error',
      message: '服务器内部错误'
    });
  }
});

// ========== Mock数据生成函数 ==========
function generateMockPollenData(value, level, type, days) {
  const dailyInfo = [];
  const today = new Date();
  
  for (let i = 0; i < days; i++) {
    const date = new Date(today);
    date.setDate(date.getDate() + i);
    const dateStr = date.toISOString().split('T')[0];
    
    // 模拟每天数据波动（±20%）
    const randomFactor = 0.8 + Math.random() * 0.4;
    const dayValue = Math.round(value * randomFactor);
    
    dailyInfo.push({
      date: dateStr,
      pollenTypeInfo: [
        {
          code: type,
          displayName: getPollenDisplayName(type),
          inSeason: true
        }
      ],
      plantInfo: [
        {
          code: type,
          displayName: getPollenDisplayName(type),
          indexInfo: {
            value: dayValue,
            category: level,
            indexDescription: getIndexDescription(level)
          }
        }
      ]
    });
  }
  
  return {
    regionCode: 'CN',
    dailyInfo: dailyInfo
  };
}

function getPollenDisplayName(code) {
  const names = {
    'GRASS': '草本花粉',
    'TREE': '树木花粉',
    'WEED': '杂草花粉'
  };
  return names[code] || '花粉';
}

function getIndexDescription(level) {
  const descriptions = {
    'LOW': '低',
    'MEDIUM': '中度',
    'HIGH': '高',
    'VERY_HIGH': '极高'
  };
  return descriptions[level] || '中度';
}

// ========== HTML 管理界面 ==========
function getAdminHTML() {
  return `<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>🌸 花粉测试控制台</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Microsoft YaHei', sans-serif;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 20px;
    }
    .container {
      background: white;
      border-radius: 20px;
      box-shadow: 0 20px 60px rgba(0,0,0,0.3);
      max-width: 550px;
      width: 100%;
      padding: 40px;
    }
    h1 {
      color: #333;
      margin-bottom: 8px;
      font-size: 32px;
      text-align: center;
    }
    .subtitle {
      color: #666;
      margin-bottom: 32px;
      font-size: 14px;
      text-align: center;
    }
    .status {
      background: linear-gradient(135deg, #f0f4f8 0%, #e2e8f0 100%);
      border-radius: 12px;
      padding: 20px;
      margin-bottom: 28px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      box-shadow: 0 2px 8px rgba(0,0,0,0.05);
    }
    .status-left {
      display: flex;
      flex-direction: column;
      gap: 4px;
    }
    .status-label {
      font-size: 12px;
      color: #64748b;
      font-weight: 500;
    }
    .status-value {
      font-size: 18px;
      color: #1e293b;
      font-weight: 700;
    }
    .status-badge {
      padding: 8px 16px;
      border-radius: 24px;
      font-size: 13px;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }
    .status-badge.active {
      background: linear-gradient(135deg, #10b981 0%, #059669 100%);
      color: white;
      box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
    }
    .status-badge.inactive {
      background: #cbd5e1;
      color: #475569;
    }
    .form-group {
      margin-bottom: 28px;
    }
    label {
      display: block;
      color: #374151;
      font-weight: 600;
      margin-bottom: 10px;
      font-size: 15px;
    }
    .switch-group {
      display: flex;
      align-items: center;
      gap: 12px;
      background: #f8fafc;
      padding: 16px;
      border-radius: 12px;
    }
    .switch {
      position: relative;
      width: 56px;
      height: 30px;
    }
    .switch input {
      opacity: 0;
      width: 0;
      height: 0;
    }
    .slider {
      position: absolute;
      cursor: pointer;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background-color: #cbd5e1;
      transition: .4s;
      border-radius: 30px;
    }
    .slider:before {
      position: absolute;
      content: "";
      height: 22px;
      width: 22px;
      left: 4px;
      bottom: 4px;
      background-color: white;
      transition: .4s;
      border-radius: 50%;
      box-shadow: 0 2px 4px rgba(0,0,0,0.2);
    }
    input:checked + .slider {
      background: linear-gradient(135deg, #10b981 0%, #059669 100%);
    }
    input:checked + .slider:before {
      transform: translateX(26px);
    }
    input[type="range"] {
      width: 100%;
      height: 8px;
      border-radius: 4px;
      background: linear-gradient(to right, #d1fae5 0%, #fef3c7 50%, #fee2e2 100%);
      outline: none;
      -webkit-appearance: none;
    }
    input[type="range"]::-webkit-slider-thumb {
      -webkit-appearance: none;
      appearance: none;
      width: 24px;
      height: 24px;
      border-radius: 50%;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      cursor: pointer;
      box-shadow: 0 3px 6px rgba(0,0,0,0.3);
      transition: transform 0.2s;
    }
    input[type="range"]::-webkit-slider-thumb:hover {
      transform: scale(1.1);
    }
    .value-display {
      background: #f8fafc;
      padding: 20px;
      border-radius: 12px;
      margin-top: 12px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .value-number {
      font-size: 42px;
      font-weight: 900;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
    }
    .value-label {
      font-size: 16px;
      padding: 6px 16px;
      border-radius: 16px;
      font-weight: 700;
    }
    .level-low { background: #d1fae5; color: #065f46; }
    .level-medium { background: #fef3c7; color: #92400e; }
    .level-high { background: #fecaca; color: #991b1b; }
    .level-very-high { background: #fecdd3; color: #881337; }
    select {
      width: 100%;
      padding: 12px 16px;
      border: 2px solid #e2e8f0;
      border-radius: 8px;
      font-size: 15px;
      color: #1e293b;
      background: white;
      cursor: pointer;
      transition: border-color 0.3s;
    }
    select:hover {
      border-color: #cbd5e1;
    }
    select:focus {
      outline: none;
      border-color: #667eea;
    }
    button {
      width: 100%;
      padding: 16px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      border: none;
      border-radius: 12px;
      font-size: 17px;
      font-weight: 700;
      cursor: pointer;
      transition: all 0.3s;
      box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
    }
    button:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 24px rgba(102, 126, 234, 0.5);
    }
    button:active {
      transform: translateY(0);
    }
    .toast {
      position: fixed;
      top: 24px;
      right: 24px;
      background: linear-gradient(135deg, #10b981 0%, #059669 100%);
      color: white;
      padding: 18px 28px;
      border-radius: 12px;
      box-shadow: 0 6px 20px rgba(16, 185, 129, 0.4);
      display: none;
      animation: slideIn 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);
      font-weight: 600;
    }
    @keyframes slideIn {
      from { transform: translateX(400px); opacity: 0; }
      to { transform: translateX(0); opacity: 1; }
    }
    .info-box {
      background: #f1f5f9;
      border-left: 4px solid #667eea;
      padding: 12px 16px;
      border-radius: 8px;
      font-size: 13px;
      color: #475569;
      margin-top: 8px;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>🌸 花粉测试控制台</h1>
    <p class="subtitle">实时调整花粉浓度数据 - 广州百度云</p>
    
    <div class="status">
      <div class="status-left">
        <span class="status-label">当前模式</span>
        <span class="status-value" id="modeText">正常模式</span>
      </div>
      <span class="status-badge" id="statusBadge">离线</span>
    </div>

    <div class="form-group">
      <div class="switch-group">
        <label class="switch">
          <input type="checkbox" id="testEnabled">
          <span class="slider"></span>
        </label>
        <label for="testEnabled" style="margin: 0; flex: 1;">启用测试模式</label>
      </div>
      <div class="info-box">开启后，应用将接收自定义花粉数据</div>
    </div>

    <div class="form-group">
      <label>花粉类型</label>
      <select id="pollenType">
        <option value="GRASS">🌾 草本花粉</option>
        <option value="TREE">🌳 树木花粉</option>
        <option value="WEED">🌿 杂草花粉</option>
      </select>
    </div>

    <div class="form-group">
      <label>花粉浓度值 (粒/km³)</label>
      <input type="range" id="pollenValue" min="0" max="500" value="150" step="10">
      <div class="value-display">
        <div class="value-number" id="valueDisplay">150</div>
        <div class="value-label" id="levelDisplay">中度</div>
      </div>
    </div>

    <button onclick="saveConfig()">💾 保存配置并应用</button>
  </div>

  <div class="toast" id="toast">✅ 配置已保存！应用将接收新数据</div>

  <script>
    const slider = document.getElementById('pollenValue');
    const valueDisplay = document.getElementById('valueDisplay');
    const levelDisplay = document.getElementById('levelDisplay');
    const statusBadge = document.getElementById('statusBadge');
    const modeText = document.getElementById('modeText');
    const testEnabled = document.getElementById('testEnabled');
    const pollenType = document.getElementById('pollenType');

    // 加载当前配置
    async function loadConfig() {
      try {
        const res = await fetch('/admin/status');
        const config = await res.json();
        
        testEnabled.checked = config.enabled;
        slider.value = config.pollenValue;
        pollenType.value = config.pollenType || 'GRASS';
        updateDisplay(config.pollenValue);
        updateStatus(config.enabled);
      } catch (err) {
        console.error('加载配置失败:', err);
      }
    }

    function updateDisplay(value) {
      valueDisplay.textContent = value;
      
      let level, className, levelCode;
      if (value < 100) {
        level = '低'; className = 'level-low'; levelCode = 'LOW';
      } else if (value < 200) {
        level = '中度'; className = 'level-medium'; levelCode = 'MEDIUM';
      } else if (value < 350) {
        level = '高'; className = 'level-high'; levelCode = 'HIGH';
      } else {
        level = '极高'; className = 'level-very-high'; levelCode = 'VERY_HIGH';
      }
      
      levelDisplay.textContent = level;
      levelDisplay.className = 'value-label ' + className;
      
      // 存储当前等级用于保存
      window.currentLevel = levelCode;
    }

    function updateStatus(enabled) {
      statusBadge.textContent = enabled ? '开启' : '关闭';
      statusBadge.className = 'status-badge ' + (enabled ? 'active' : 'inactive');
      modeText.textContent = enabled ? '测试模式' : '正常模式';
    }

    slider.addEventListener('input', (e) => {
      updateDisplay(e.target.value);
    });

    testEnabled.addEventListener('change', (e) => {
      updateStatus(e.target.checked);
    });

    async function saveConfig() {
      const config = {
        enabled: testEnabled.checked,
        pollenValue: parseInt(slider.value),
        pollenLevel: window.currentLevel || 'MEDIUM',
        pollenType: pollenType.value
      };

      try {
        await fetch('/admin/set', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(config)
        });

        const toast = document.getElementById('toast');
        toast.style.display = 'block';
        setTimeout(() => { toast.style.display = 'none'; }, 3000);
      } catch (err) {
        alert('保存失败: ' + err.message);
      }
    }

    // 初始化
    loadConfig();
  </script>
</body>
</html>`;
}

// ========== 404 处理 ==========
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: '接口不存在',
    availableEndpoints: [
      'GET /health',
      'GET /pollen-api?lat=<纬度>&lng=<经度>&days=<天数>',
      'GET /admin (管理控制台)',
      'GET /admin/status',
      'POST /admin/set'
    ]
  });
});

// ========== 启动服务器 ==========
app.listen(PORT, '0.0.0.0', () => {
  console.log('========================================');
  console.log('   Google Pollen API 代理服务');
  console.log(`   服务器: 106.12.143.105:${PORT}`);
  console.log(`   时间: ${new Date().toLocaleString('zh-CN')}`);
  console.log('========================================');
  console.log(`接口列表:`);
  console.log(`  - GET /health`);
  console.log(`  - GET /pollen-api?lat=<纬度>&lng=<经度>&days=<天数>`);
  console.log(`  - GET /admin (🎨 管理控制台)`);
  console.log('========================================');
});
