# 修复JSON文件编码
$inputFile = "c:/HarmonyOS_App_Plans/PollenForecast/entry/src/main/resources/rawfile/china_area_full.json"
$outputFile = "c:/HarmonyOS_App_Plans/PollenForecast/entry/src/main/resources/rawfile/china_area_full_fixed.json"

# 尝试用GBK读取
$content = Get-Content $inputFile -Raw -Encoding Default

# 用UTF-8（无BOM）写入
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($outputFile, $content, $utf8NoBom)

Write-Host "转换完成！"
