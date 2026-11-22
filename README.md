# Windows AI Toolkit

Windows 11 diagnostics, maintenance and automation toolkit.

## Quick start

1. Download or clone this repository to your Windows 11 PC.
2. Double-click `Start-Toolkit.bat` in the project folder.
3. Choose an option from the menu. Option 1 runs the read-only computer health check.

## Current features

- Basic Windows, CPU, memory, disk and graphics inventory.
- Basic DNS and TCP 443 connectivity test to github.com.
- Opens the local diagnostic report folder.
- Menu and launcher run without Administrator privileges.

## Safety and privacy

- Current tools are diagnostic-only. They do not clean files, change registry values, disable services, install drivers, or alter Windows settings.
- Review a script before running it. Do not run scripts from sources you do not trust.
- Diagnostic reports are saved locally in `Reports`. Do not commit reports to this public repository: they may contain your computer name and device details.
- Before sharing a report in chat or elsewhere, remove computer names, usernames, serial numbers, public IP addresses, and other personal details.

## Project structure

- `Start-Toolkit.bat`: one-click local launcher.
- `scripts/Toolkit-Menu.ps1`: menu interface.
- `scripts/Computer-Health-Check.ps1`: read-only system inventory.
- `Reports/`: generated local reports (do not upload).

## Planned modules

Network diagnostics, startup-app review, storage analysis, Windows health checks, and opt-in maintenance actions with confirmation and logging.
