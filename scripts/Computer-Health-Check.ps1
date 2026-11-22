# Windows 11 电脑体检工具 V1.0
# 只读诊断：收集硬件、系统、磁盘和网络信息，并在仓库 Reports 文件夹生成 TXT 报告。
# 本脚本不会清理文件、修改注册表、关闭服务或更改系统设置。

$ErrorActionPreference = "Continue"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$repoRoot = Split-Path -Parent $PSScriptRoot
$reportDir = Join-Path $repoRoot "Reports"
$reportPath = Join-Path $reportDir "Health-Report-$timestamp.txt"

New-Item -ItemType Directory -Path $reportDir -Force | Out-Null

$report = [System.Collections.Generic.List[string]]::new()
function Add-Section([string]$Title) {
    $report.Add("")
    $report.Add(("=" * 58))
    $report.Add($Title)
    $report.Add(("=" * 58))
}
function Add-Line([string]$Text) {
    $report.Add($Text)
}

Add-Line "Windows 电脑体检报告"
Add-Line "生成时间：$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Add-Line "计算机名称：$env:COMPUTERNAME"
Add-Line "说明：本报告由只读诊断脚本生成，不会主动修改系统设置。"

try {
    Add-Section "一、Windows 系统信息"
    $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
    Add-Line "系统：$($os.Caption)"
    Add-Line "版本：$($os.Version)"
    Add-Line "内部版本：$($os.BuildNumber)"
    Add-Line "系统架构：$($os.OSArchitecture)"
    Add-Line "安装日期：$($os.InstallDate)"
    Add-Line "最近启动：$($os.LastBootUpTime)"
} catch {
    Add-Line "系统信息读取失败：$($_.Exception.Message)"
}

try {
    Add-Section "二、CPU 信息"
    $cpus = Get-CimInstance Win32_Processor -ErrorAction Stop
    foreach ($cpu in $cpus) {
        Add-Line "型号：$($cpu.Name.Trim())"
        Add-Line "核心数：$($cpu.NumberOfCores)"
        Add-Line "逻辑处理器：$($cpu.NumberOfLogicalProcessors)"
        Add-Line "当前负载：$($cpu.LoadPercentage)%"
        Add-Line ""
    }
} catch {
    Add-Line "CPU 信息读取失败：$($_.Exception.Message)"
}

try {
    Add-Section "三、内存信息"
    $memory = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
    $totalGB = [math]::Round($memory.TotalVisibleMemorySize / 1MB, 2)
    $freeGB = [math]::Round($memory.FreePhysicalMemory / 1MB, 2)
    $usedGB = [math]::Round($totalGB - $freeGB, 2)
    $usedPct = if ($totalGB -gt 0) { [math]::Round(($usedGB / $totalGB) * 100, 1) } else { 0 }
    Add-Line "可用物理内存总量：$totalGB GB"
    Add-Line "当前已用：$usedGB GB"
    Add-Line "当前可用：$freeGB GB"
    Add-Line "内存使用率：$usedPct%"
} catch {
    Add-Line "内存信息读取失败：$($_.Exception.Message)"
}

try {
    Add-Section "四、磁盘空间"
    $disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction Stop
    foreach ($disk in $disks) {
        $sizeGB = [math]::Round($disk.Size / 1GB, 2)
        $freeGB = [math]::Round($disk.FreeSpace / 1GB, 2)
        $usedPct = if ($disk.Size -gt 0) { [math]::Round((($disk.Size - $disk.FreeSpace) / $disk.Size) * 100, 1) } else { 0 }
        Add-Line "$($disk.DeviceID) 总容量：$sizeGB GB；剩余：$freeGB GB；已用：$usedPct%"
    }
} catch {
    Add-Line "磁盘信息读取失败：$($_.Exception.Message)"
}

try {
    Add-Section "五、显卡信息"
    $gpus = Get-CimInstance Win32_VideoController -ErrorAction Stop
    foreach ($gpu in $gpus) {
        Add-Line "显卡：$($gpu.Name)"
        if ($gpu.AdapterRAM) {
            Add-Line "报告的显存：$([math]::Round($gpu.AdapterRAM / 1GB, 2)) GB"
        }
        Add-Line "驱动版本：$($gpu.DriverVersion)"
        Add-Line ""
    }
} catch {
    Add-Line "显卡信息读取失败：$($_.Exception.Message)"
}

try {
    Add-Section "六、网络连通性"
    $test = Test-NetConnection -ComputerName "github.com" -Port 443 -WarningAction SilentlyContinue
    Add-Line "目标：github.com:443"
    Add-Line "DNS 解析地址：$($test.RemoteAddress)"
    Add-Line "TCP 443 连通：$($test.TcpTestSucceeded)"
    Add-Line "说明：VPN、代理或防火墙可能影响测试结果。"
} catch {
    Add-Line "网络测试失败：$($_.Exception.Message)"
}

try {
    Add-Section "七、最近系统启动时间"
    $boot = (Get-CimInstance Win32_OperatingSystem -ErrorAction Stop).LastBootUpTime
    $uptime = (Get-Date) - $boot
    Add-Line "最近启动：$boot"
    Add-Line "已运行：$([math]::Floor($uptime.TotalDays)) 天 $($uptime.Hours) 小时 $($uptime.Minutes) 分钟"
} catch {
    Add-Line "启动时间读取失败：$($_.Exception.Message)"
}

Add-Section "诊断说明"
Add-Line "1. 本工具只采集基础信息，不自动判断硬件故障。"
Add-Line "2. 显存容量等字段可能因设备或驱动而无法准确读取。"
Add-Line "3. 网络测试失败不一定代表网络完全不可用，可能受代理或防火墙影响。"
Add-Line "4. 如需进一步分析，请将本报告内容发给 ChatGPT。"

$report | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host ""
Write-Host "体检完成！报告已保存到：" -ForegroundColor Green
Write-Host $reportPath -ForegroundColor Cyan
Write-Host ""
Read-Host "按 Enter 键退出"
