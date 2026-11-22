# Windows AI Toolkit - Confirmed Maintenance
# All actions are opt-in. Run as Administrator only when Windows prompts or a command requires it.
$ErrorActionPreference = "Continue"
function Confirm-Action([string]$description) {
  Write-Host ""
  Write-Host $description -ForegroundColor Yellow
  $answer = Read-Host "Type YES to run this action"
  return ($answer -ceq "YES")
}
while ($true) {
  Clear-Host
  Write-Host "Windows AI Toolkit - Maintenance" -ForegroundColor Cyan
  Write-Host "1. DISM CheckHealth (checks component-store health; no repair)"
  Write-Host "2. SFC VerifyOnly (verifies protected system files; no repair)"
  Write-Host "3. Flush DNS resolver cache (temporary network cache reset)"
  Write-Host "4. Open Windows Storage settings"
  Write-Host "Q. Quit"
  $choice = (Read-Host "Choose an option").ToUpperInvariant()
  switch ($choice) {
    "1" {
      if (Confirm-Action "DISM /Online /Cleanup-Image /CheckHealth: diagnostic check only.") {
        DISM.exe /Online /Cleanup-Image /CheckHealth
        Read-Host "Finished. Press Enter"
      }
    }
    "2" {
      if (Confirm-Action "sfc /verifyonly: verifies system files without attempting repairs.") {
        sfc.exe /verifyonly
        Read-Host "Finished. Press Enter"
      }
    }
    "3" {
      if (Confirm-Action "ipconfig /flushdns: clears the local DNS resolver cache; it does not change DNS server settings.") {
        ipconfig.exe /flushdns
        Read-Host "Finished. Press Enter"
      }
    }
    "4" { Start-Process "ms-settings:storagesense" }
    "Q" { break }
    default { Write-Host "Invalid selection."; Start-Sleep -Seconds 1 }
  }
}
