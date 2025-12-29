# 花粉 API 服务上传与部署脚本
# 用途: 从 Windows 上传代码到广州服务器并部署

$SERVER = "106.12.143.105"
$USER = "root"
$REMOTE_DIR = "/root/pollen-api"
$LOCAL_DIR = "C:\HarmonyOS_App_Plans\PollenForecast\server"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  花粉 API 服务部署工具" -ForegroundColor Cyan
Write-Host "  目标服务器: $SERVER" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# 检查 SSH 连通性
Write-Host "`n[1/4] 检查服务器连通性..." -ForegroundColor Yellow
$ping = Test-Connection -ComputerName $SERVER -Count 2 -Quiet
if (-not $ping) {
    Write-Host "错误: 无法连接到服务器 $SERVER" -ForegroundColor Red
    exit 1
}
Write-Host "✓ 服务器连接正常" -ForegroundColor Green

# 检查本地文件
Write-Host "`n[2/4] 检查本地文件..." -ForegroundColor Yellow
if (-not (Test-Path $LOCAL_DIR)) {
    Write-Host "错误: 本地目录不存在: $LOCAL_DIR" -ForegroundColor Red
    exit 1
}
$files = Get-ChildItem -Path $LOCAL_DIR -Recurse | Measure-Object
Write-Host "✓ 找到 $($files.Count) 个文件" -ForegroundColor Green

# 上传文件
Write-Host "`n[3/4] 上传文件到服务器..." -ForegroundColor Yellow
Write-Host "提示: 需要输入服务器密码" -ForegroundColor Cyan

# 使用 SCP 上传（需要手动输入密码）
scp -r "$LOCAL_DIR\*" "${USER}@${SERVER}:${REMOTE_DIR}/"

if ($LASTEXITCODE -ne 0) {
    Write-Host "错误: 文件上传失败" -ForegroundColor Red
    exit 1
}
Write-Host "✓ 文件上传完成" -ForegroundColor Green

# 远程部署
Write-Host "`n[4/4] 远程部署服务..." -ForegroundColor Yellow
Write-Host "提示: 再次输入密码以执行部署脚本" -ForegroundColor Cyan

ssh ${USER}@${SERVER} "cd $REMOTE_DIR && chmod +x deploy.sh && bash deploy.sh"

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n=========================================" -ForegroundColor Green
    Write-Host "  部署成功！" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "`n接口地址:" -ForegroundColor Cyan
    Write-Host "  http://$SERVER:3000/health" -ForegroundColor White
    Write-Host "  http://$SERVER:3000/pollen-api?lat=23.12&lng=113.26&days=5" -ForegroundColor White
} else {
    Write-Host "`n部署失败，请检查错误信息" -ForegroundColor Red
}

Write-Host "`n按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
