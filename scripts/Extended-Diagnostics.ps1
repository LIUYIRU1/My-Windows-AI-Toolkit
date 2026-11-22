# Windows AI Toolkit - Extended Diagnostics
# Read-only inventory. Reports stay on this PC; review/redact before sharing.
$ErrorActionPreference = "Continue"
$root = Split-Path -Parent $PSScriptRoot
$dir = Join-Path $root "Reports"
New-Item -ItemType Directory -Path $dir -Force | Out-Null
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$path = Join-Path $dir "Extended-Diagnostics-$stamp.txt"
$lines = [System.Collections.Generic.List[string]]::new()
function Section([string]$s) { $lines.Add(""); $lines.Add(("=" * 60)); $lines.Add($s); $lines.Add(("=" * 60)) }
function Line([string]$s) { $lines.Add($s) }

Line "Windows AI Toolkit - Extended Diagnostics"
Line "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Line "Privacy: this report may contain device, user, network and software details. Keep local and redact before sharing."

Section "Windows and hardware"
try {
  $os = Get-CimInstance Win32_OperatingSystem
  Line "OS: $($os.Caption) | Version: $($os.Version) | Build: $($os.BuildNumber)"
  Line "Architecture: $($os.OSArchitecture)"
  Line "Computer name: $env:COMPUTERNAME"
  Line "User name: $env:USERNAME"
  Get-CimInstance Win32_Processor | ForEach-Object { Line "CPU: $($_.Name.Trim()) | Cores: $($_.NumberOfCores) | Logical: $($_.NumberOfLogicalProcessors)" }
  $mem = Get-CimInstance Win32_ComputerSystem
  Line ("Installed RAM: {0:N2} GB" -f ($mem.TotalPhysicalMemory / 1GB))
  Get-CimInstance Win32_VideoController | ForEach-Object { Line "GPU: $($_.Name) | Driver: $($_.DriverVersion)" }
} catch { Line "Hardware query error: $($_.Exception.Message)" }

Section "Storage"
try {
  Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    Line ("{0} Total {1:N1} GB | Free {2:N1} GB | Free {3:N1}%" -f $_.DeviceID,($_.Size/1GB),($_.FreeSpace/1GB),(100*$_.FreeSpace/$_.Size))
  }
} catch { Line "Storage query error: $($_.Exception.Message)" }
try {
  Get-PhysicalDisk | ForEach-Object { Line "Physical disk: $($_.FriendlyName) | Health: $($_.HealthStatus) | Operational: $($_.OperationalStatus -join ',')" }
} catch { Line "Physical disk health not available through this provider." }

Section "Network and proxy summary"
try {
  $cfg = Get-NetIPConfiguration | Where-Object { $_.NetAdapter.Status -eq "Up" }
  foreach ($c in $cfg) {
    Line "Adapter: $($c.InterfaceAlias) | IPv4: $(($c.IPv4Address.IPAddress -join ',')) | Gateway: $(($c.IPv4DefaultGateway.NextHop -join ','))"
    Line "DNS: $(($c.DNSServer.ServerAddresses -join ','))"
  }
} catch { Line "Network configuration query error: $($_.Exception.Message)" }
try {
  $p = (Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -ErrorAction Stop)
  Line "Windows user proxy enabled: $($p.ProxyEnable)"
  if ($p.ProxyServer) { Line "Windows user proxy server: $($p.ProxyServer)" }
} catch { Line "User proxy settings unavailable." }
try {
  $winhttp = netsh winhttp show proxy 2>&1
  foreach ($x in $winhttp) { Line "WinHTTP: $x" }
} catch { Line "WinHTTP proxy query failed." }
foreach ($port in @(7890,7897,7899,1080,8080)) {
  $test = Test-NetConnection 127.0.0.1 -Port $port -InformationLevel Quiet -WarningAction SilentlyContinue
  Line "Local proxy candidate 127.0.0.1:$port reachable: $test"
}
foreach ($hostName in @("github.com","api.github.com")) {
  try {
    $t = Test-NetConnection $hostName -Port 443 -InformationLevel Detailed -WarningAction SilentlyContinue
    Line "$hostName TCP 443: $($t.TcpTestSucceeded) | Remote: $($t.RemoteAddress)"
  } catch { Line "$hostName test error: $($_.Exception.Message)" }
}

Section "Git TLS/proxy configuration (secrets intentionally omitted)"
try {
  $git = Get-Command git -ErrorAction SilentlyContinue
  if ($git) {
    Line "Git executable: $($git.Source)"
    Line "Git version: $(& git --version 2>&1)"
    foreach ($key in @("http.proxy","https.proxy","http.sslBackend","http.sslVerify","http.version")) {
      $v = & git config --show-origin --get $key 2>$null
      if ($LASTEXITCODE -eq 0 -and $v) {
        if ($key -like "*proxy") {
          $v = $v -replace '(https?://)[^/@]+:[^/@]+@','$1[credentials-redacted]@'
        }
        Line "Git $key = $v"
      } else { Line "Git $key = (not explicitly set)" }
    }
  } else { Line "Git command not found in PATH." }
} catch { Line "Git config query error: $($_.Exception.Message)" }
foreach ($name in @("HTTP_PROXY","HTTPS_PROXY","ALL_PROXY")) {
  $value = [Environment]::GetEnvironmentVariable($name)
  if ($value) { Line "$name is set (value hidden for privacy)." } else { Line "$name is not set." }
}

Section "Recent system errors (last 24 hours)"
try {
  $since = (Get-Date).AddHours(-24)
  $events = Get-WinEvent -FilterHashtable @{LogName="System"; Level=1,2,3; StartTime=$since} -MaxEvents 25 -ErrorAction Stop
  foreach ($e in $events) { Line "$($e.TimeCreated) | $($e.ProviderName) | Event $($e.Id) | $($e.LevelDisplayName)" }
} catch { Line "No matching events found or event log access unavailable." }

Section "Next steps"
Line "This script is read-only. It does not change proxy, firewall, DNS, services, drivers, registry, or startup settings."
Line "Review the report locally. Before sharing, redact computer name, user name, IP addresses, adapter names and any identifying details."
$lines | Out-File -FilePath $path -Encoding UTF8
Write-Host "Extended diagnostics complete. Report saved locally:" -ForegroundColor Green
Write-Host $path -ForegroundColor Cyan
Read-Host "Press Enter to exit"
