# Windows AI Toolkit - safe local menu
# No Administrator privileges required. This menu does not modify Windows settings.
$ErrorActionPreference = "Continue"
$repoRoot = Split-Path -Parent $PSScriptRoot
$healthScript = Join-Path $PSScriptRoot "Computer-Health-Check.ps1"
$reportDir = Join-Path $repoRoot "Reports"
function Show-Menu {
    Clear-Host
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "       Windows AI Toolkit" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "1. Run basic computer health check (read-only)"
    Write-Host "2. Test GitHub network connection (read-only)"
    Write-Host "3. Open local diagnostic reports folder"
    Write-Host "4. Open project folder"
    Write-Host "Q. Quit"
    Write-Host ""
}
while ($true) {
    Show-Menu
    $choice = Read-Host "Choose an option"
    switch ($choice.ToUpperInvariant()) {
        "1" {
            if (Test-Path $healthScript) { & $healthScript }
            else { Write-Host "Health check script not found." -ForegroundColor Red; Read-Host "Press Enter" }
        }
        "2" {
            Write-Host "Testing DNS and TCP 443 to github.com..." -ForegroundColor Yellow
            try {
                Resolve-DnsName github.com -ErrorAction Stop | Select-Object -First 2 Name, Type, IPAddress | Format-Table -AutoSize
            } catch { Write-Host "DNS lookup failed: $($_.Exception.Message)" -ForegroundColor Red }
            try {
                $test = Test-NetConnection github.com -Port 443 -WarningAction SilentlyContinue
                Write-Host "TCP 443 reachable: $($test.TcpTestSucceeded)"
                if ($test.RemoteAddress) { Write-Host "Remote address: $($test.RemoteAddress)" }
            } catch { Write-Host "Connection test failed: $($_.Exception.Message)" -ForegroundColor Red }
            Read-Host "Press Enter to return to menu"
        }
        "3" {
            New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
            Start-Process -FilePath explorer.exe -ArgumentList $reportDir
        }
        "4" { Start-Process -FilePath explorer.exe -ArgumentList $repoRoot }
        "Q" { break }
        default { Write-Host "Invalid option." -ForegroundColor Yellow; Start-Sleep -Seconds 1 }
    }
}
