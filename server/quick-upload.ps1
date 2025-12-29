# 快速上传脚本（仅上传代码，不执行部署）

$SERVER = "106.12.143.105"
$USER = "root"

Write-Host "正在上传文件到 $SERVER..." -ForegroundColor Cyan
scp -r C:\HarmonyOS_App_Plans\PollenForecast\server\* ${USER}@${SERVER}:/root/pollen-api/

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ 上传完成" -ForegroundColor Green
    Write-Host "`n手动部署命令:" -ForegroundColor Yellow
    Write-Host "ssh root@$SERVER" -ForegroundColor White
    Write-Host "cd /root/pollen-api" -ForegroundColor White
    Write-Host "bash deploy.sh" -ForegroundColor White
} else {
    Write-Host "✗ 上传失败" -ForegroundColor Red
}
