#!/bin/bash

# 和风天气 API 代理服务一键部署脚本
# 使用方法：bash deploy.sh

set -e  # 遇到错误立即退出

echo "========================================="
echo "  和风天气 API 代理服务部署脚本"
echo "  服务器: 106.12.143.105"
echo "========================================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}错误: 未检测到 Node.js，正在安装...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    source ~/.bashrc
    nvm install 20
    nvm use 20
else
    echo -e "${GREEN}✓ Node.js 已安装: $(node -v)${NC}"
fi

# 检查 npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}错误: npm 未安装${NC}"
    exit 1
else
    echo -e "${GREEN}✓ npm 已安装: $(npm -v)${NC}"
fi

# 安装依赖
echo -e "${YELLOW}正在安装依赖...${NC}"
npm install

# 检查环境变量
if [ ! -f .env ]; then
    echo -e "${YELLOW}警告: .env 文件不存在，正在创建模板...${NC}"
    cat > .env << EOF
QWEATHER_API_KEY=你的和风天气API_Key
PORT=3000
EOF
    echo -e "${RED}请编辑 .env 文件，添加真实的和风天气 API Key${NC}"
    exit 1
else
    echo -e "${GREEN}✓ .env 文件已存在${NC}"
fi

# 安装 PM2
if ! command -v pm2 &> /dev/null; then
    echo -e "${YELLOW}正在安装 PM2...${NC}"
    npm install -g pm2
else
    echo -e "${GREEN}✓ PM2 已安装${NC}"
fi

# 停止旧服务（如果存在）
echo -e "${YELLOW}检查旧服务...${NC}"
pm2 stop qweather-proxy 2>/dev/null || true
pm2 delete qweather-proxy 2>/dev/null || true
pm2 stop pollen-api 2>/dev/null || true  # 兼容旧名称
pm2 delete pollen-api 2>/dev/null || true

# 启动服务
echo -e "${YELLOW}启动服务...${NC}"
pm2 start qweather-proxy.js --name qweather-proxy

# 配置开机自启
echo -e "${YELLOW}配置开机自启...${NC}"
pm2 startup
pm2 save

# 显示状态
echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  部署完成！${NC}"
echo -e "${GREEN}=========================================${NC}"
pm2 status

echo ""
echo "接口地址实时天气: http://106.12.143.105:3000/weather/now?location=113.26,23.12"
echo "  - 7天预报: http://106.12.143.105:3000/weather/7d?location=113.26,23.12"
echo "  - 日出日落: http://106.12.143.105:3000/astronomy/sun?location=113.26,23.12"
echo ""
echo "管理命令:"
echo "  - 查看日志: pm2 logs qweather-proxy"
echo "  - 重启服务: pm2 restart qweather-proxy"
echo "  - 停止服务: pm2 stop qweather-proxy"
echo ""
echo -e "${YELLOW}注意: 花粉数据由 AWS Lambda 提供，此服务器仅提供天气数据
echo ""
echo -e "${YELLOW}注意: 请确保防火墙已开放 3000 端口！${NC}"
