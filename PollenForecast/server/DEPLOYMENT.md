# 花粉 API 服务部署指南

## 服务器信息
- **IP**: 106.12.143.105
- **带宽**: 2Mbps
- **位置**: 广州百度云

---

## 部署步骤

### 1. 连接服务器
```bash
ssh root@106.12.143.105
```

### 2. 安装 Node.js (如未安装)
```bash
# 使用 NVM 安装 Node.js 20
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 20
nvm use 20
node -v  # 验证安装
```

### 3. 上传代码到服务器
```powershell
# 在本地执行（PowerShell）
scp -r C:\HarmonyOS_App_Plans\PollenForecast\server root@106.12.143.105:/root/
```

### 4. 安装依赖
```bash
cd /root/server
npm install
```

### 5. 配置环境变量
```bash
# 创建 .env 文件
nano .env
```

添加以下内容：
```env
GOOGLE_POLLEN_API_KEY=你的Google_API_Key
PORT=3000
```

### 6. 安装 PM2 (进程管理)
```bash
npm install -g pm2
```

### 7. 启动服务
```bash
# 使用 PM2 启动（推荐 - 自动重启）
pm2 start pollen-api.js --name pollen-api

# 或直接启动
npm start
```

### 8. 配置开机自启
```bash
pm2 startup
pm2 save
```

### 9. 查看运行状态
```bash
pm2 status
pm2 logs pollen-api
```

---

## 防火墙配置

### 开放端口 3000
```bash
# 检查防火墙状态
systemctl status firewalld

# 开放 3000 端口
firewall-cmd --zone=public --add-port=3000/tcp --permanent
firewall-cmd --reload

# 验证
firewall-cmd --list-ports
```

### 或者使用安全组（百度云控制台）
1. 登录百度云控制台
2. 进入 BCC 实例详情
3. 点击「安全组」
4. 添加入站规则：
   - 协议：TCP
   - 端口：3000
   - 来源：0.0.0.0/0

---

## 测试接口

### 健康检查
```bash
curl http://106.12.143.105:3000/health
```

### 花粉数据查询
```bash
# 广州花粉数据
curl "http://106.12.143.105:3000/pollen-api?lat=23.1291&lng=113.2644&days=5"
```

---

## Nginx 反向代理（可选）

如果要使用 80 端口，可以配置 Nginx：

```nginx
server {
    listen 80;
    server_name 106.12.143.105;

    location /pollen-api {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /health {
        proxy_pass http://localhost:3000;
    }
}
```

---

## 监控与维护

### 查看日志
```bash
pm2 logs pollen-api --lines 100
```

### 重启服务
```bash
pm2 restart pollen-api
```

### 停止服务
```bash
pm2 stop pollen-api
```

### 查看资源占用
```bash
pm2 monit
```

---

## 性能优化建议

1. **启用 Gzip 压缩**（Nginx 层）
2. **增加缓存时间**（当前15分钟）
3. **添加 Redis 缓存**（替代内存缓存）
4. **配置 CDN**（加速全国访问）

---

## 故障排查

### 端口被占用
```bash
lsof -i :3000
kill -9 <PID>
```

### 查看服务器资源
```bash
htop
df -h
free -h
```

### 网络连通性测试
```bash
# 测试到 Google API 的连通性
curl -I https://pollen.googleapis.com
```
