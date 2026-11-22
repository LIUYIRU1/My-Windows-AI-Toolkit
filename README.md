# Windows AI Toolkit

Windows 11 diagnostics, maintenance and automation toolkit.

## Quick start

1. Download or clone this repository to your Windows 11 PC.
2. Double-click `Start-Toolkit.bat`.
3. Choose an option from the menu.

## Current features

- Basic hardware and Windows inventory.
- Extended read-only diagnostics for storage, network, proxy summary, Git TLS settings and recent system errors.
- Basic GitHub DNS and TCP 443 connectivity test.
- Opt-in maintenance checks: DISM CheckHealth, SFC VerifyOnly and DNS cache flush.
- Opens local diagnostic reports and project folder.

## Safety and privacy

- Diagnostic scripts are read-only. The maintenance menu runs only after you type `YES` for the selected action.
- DISM CheckHealth and SFC VerifyOnly are checks, not repairs. DNS flush clears only the local resolver cache.
- No automatic registry edits, service disabling, driver installation, firewall changes, bulk cleanup, or network stack resets.
- Reports are saved locally in `Reports`. Do not commit reports to this public repository: they can contain computer names, usernames, IP addresses, adapter details and software configuration.
- Redact identifying information before sharing a report.
- Review scripts before running them. Do not run scripts from sources you do not trust.

## Project structure

- `Start-Toolkit.bat`: one-click local launcher.
- `scripts/Toolkit-Menu.ps1`: menu interface.
- `scripts/Computer-Health-Check.ps1`: basic read-only system inventory.
- `scripts/Extended-Diagnostics.ps1`: extended read-only diagnostics.
- `scripts/Confirmed-Maintenance.ps1`: opt-in maintenance checks.
- `Reports/`: generated local reports (do not upload).

## Planned modules

Guided network repair, startup-app review, storage cleanup preview, Windows integrity repair with explicit approval, restore-point safeguards, operation logs and rollback guidance.
