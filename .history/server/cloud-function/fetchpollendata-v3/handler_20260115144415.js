var https = require('https');

// 敏舒 API 配置
var MINSHU_API_BASE = 'https://cdn.myminshu.com';
var DEFAULT_API_KEY = 'AK-lYpA8KnbT0lzPNvfjIqCSLDMLPz1n3htrENs';

// 城市列表
var CITY_LIST = [
  {"adcode":"110000","name":"北京市"},
  {"adcode":"310000","name":"上海市"},
  {"adcode":"440100","name":"广州市"},
  {"adcode":"440300","name":"深圳市"},
  {"adcode":"120000","name":"天津市"},
  {"adcode":"500000","name":"重庆市"},
  {"adcode":"320100","name":"南京市"},
  {"adcode":"330100","name":"杭州市"},
  {"adcode":"420100","name":"武汉市"},
  {"adcode":"430100","name":"长沙市"},
  {"adcode":"510100","name":"成都市"},
  {"adcode":"610100","name":"西安市"},
  {"adcode":"410300","name":"洛阳市"},
  {"adcode":"410323","name":"新安县"},
  {"adcode":"410325","name":"嵩县"},
  {"adcode":"410326","name":"汝阳县"},
  {"adcode":"410327","name":"宜阳县"},
  {"adcode":"410328","name":"洛宁县"},
  {"adcode":"410324","name":"栾川县"},
  {"adcode":"410303","name":"西工区"},
  {"adcode":"410304","name":"瀍河回族区"},
  {"adcode":"410302","name":"老城区"},
  {"adcode":"410329","name":"伊川县"},
  {"adcode":"410307","name":"偃师区"},
  {"adcode":"410308","name":"孟津区"},
  {"adcode":"410311","name":"洛龙区"},
  {"adcode":"410305","name":"涧西区"}
];

/**
 * 简易的 HTTPS GET 请求封装 (替代 axios)
 */
function httpsGet(url) {
  return new Promise(function(resolve, reject) {
    var req = https.get(url, function(res) {
      var data = '';
      res.on('data', function(chunk) {
        data += chunk;
      });
      res.on('end', function() {
        try {
          var json = JSON.parse(data);
          resolve({ data: json });
        } catch (e) {
          reject(new Error('JSON parse failed'));
        }
      });
    });

    req.on('error', function(e) {
      reject(e);
    });
    
    // 设置 10秒超时
    req.setTimeout(10000, function() {
      req.abort();
      reject(new Error('Timeout'));
    });
  });
}

exports.main = function (event, context, callback) {
  var logger = context.getLogger();
  var apiKey = process.env.MINSHU_API_KEY || DEFAULT_API_KEY;
  
  logger.info('[FetchPollen] 开始执行任务 (No-Deps Version)');

  // 1. 初始化云数据库 - 使用运行时提供的数据库API
  var dbCollection;
  try {
    // 华为云函数运行时内置数据库API，无需导入SDK
    var cloudDB = context.database();
    dbCollection = cloudDB.collection('PollenData');
    logger.info('[FetchPollen] 云数据库初始化成功');
  } catch (e) {
    logger.error('[FetchPollen] 云数据库初始化失败: ' + e.message);
    logger.error('[FetchPollen] 错误堆栈: ' + e.stack);
    callback(e);
    return;
  }

  // 2. 准备任务数据
  var stats = { success: 0, fail: 0 };
  var allTasks = []; // 存储所有待执行的任务参数 {city, day}

  var days = [];
  for (var i = 0; i < 6; i++) {
    var d = new Date();
    d.setDate(d.getDate() + i);
    days.push(d.toISOString().split('T')[0]);
  }

  days.forEach(function(day) {
    CITY_LIST.forEach(function(city) {
      allTasks.push({ city: city, day: day });
    });
  });

  logger.info('[FetchPollen] 总任务数: ' + allTasks.length);

  // 3. 执行任务 (简单的并发控制)
  // 使用 "递归链" 方式实现并发数为 5 的池子
  
  var CONCURRENCY = 5;
  var index = 0;
  var activeCount = 0;
  var completedCount = 0;

  function next() {
    // 如果所有任务都完成了
    if (completedCount === allTasks.length) {
      logger.info('[FetchPollen] 所有任务完成: 成功 ' + stats.success + ', 失败 ' + stats.fail);
      callback(null, {
        code: 0,
        message: 'ok',
        stats: stats
      });
      return;
    }

    // 只要还有任务且并发未满，就启动新任务
    while (index < allTasks.length && activeCount < CONCURRENCY) {
      var task = allTasks[index++];
      activeCount++;
      runTask(task);
    }
  }

  function runTask(item) {
    var url = MINSHU_API_BASE + '/day/pollen/' + item.day + '/' + item.adcode + '?apikey=' + apiKey;
    
    logger.info('[FetchPollen] 请求: ' + item.city.name + ' (' + item.day + ')');
    
    httpsGet(url)
      .then(function(response) {
        if (response.data && response.data.code === 200) {
          var dataObj = {
            adcode: item.city.adcode,
            recordDate: item.day,
            data: JSON.stringify(response.data.data),
            updatedAt: Date.now()
          };
          
          logger.info('[FetchPollen] 写入数据库: ' + item.city.name);
          
          // 写入数据库
          return dbCollection.upsert(dataObj);
        } else {
          throw new Error('API Error code: ' + (response.data ? response.data.code : 'unknown'));
        }
      })
      .then(function() {
        stats.success++;
        logger.info('[FetchPollen] ✅ ' + item.city.name + ' (' + item.day + ') 成功');
      })
      .catch(function(err) {
        stats.fail++;
        logger.warn('[FetchPollen] ❌ ' + item.city.name + ' (' + item.day + ') 失败: ' + err.message);
      })
      .finally(function() {
        activeCount--;
        completedCount++;
        next(); // 触发下一个
      });
  }

  // 启动
  next();
};
