# Installation

Target: Windows 10 64-bit.

## Fast path

1. Clone the repository.
2. Double-click Install.cmd, or Install-Interactive.cmd for a guided component menu.
3. Approve UAC when Windows asks for elevation during restore-point/Open-Shell setup.
4. Sign out and sign back in after the installer finishes.

Command-line equivalent:

    git clone https://github.com/TechSite-Solutions/windows-95-for-windows-10.git
    cd windows-95-for-windows-10
    Set-ExecutionPolicy -Scope Process Bypass
    .\scripts\install.ps1

Preview the plan without changing Windows:

    .\scripts\install.ps1 -DryRun

## What the installer does

The installer is transactional at the user-settings level.

Order:

1. verifies the Windows target;
2. records whether RetroBar/Open-Shell already existed;
3. creates a timestamped rollback backup;
4. attempts to create a System Restore point;
5. applies the Windows 95 base palette;
6. applies Full Shell mode (light system UI, teal desktop refresh, Explorer/Control Panel classic preferences);
7. applies classic shell/window metrics;
8. enables classic desktop namespace icons and labels;
9. downloads the pinned RetroBar release;
9. verifies the RetroBar SHA-256 digest;
10. installs/configures RetroBar;
12. downloads the pinned Open-Shell release;
13. verifies the Open-Shell SHA-256 digest;
14. installs/configures Open-Shell Start Menu + Classic Explorer;
14. records state/last-install.json;
15. starts the configured shell components;
16. runs configuration verification.

If a theme-stage failure occurs after the backup is created, install.ps1 attempts to restore the saved appearance state automatically.

## Backup

Backups are written to:

    backups\YYYYMMDD-HHMMSS\

They can include:

- Windows color/desktop registry data;
- cursor and AppEvents settings;
- Open-Shell Start Menu registry settings;
- desktop icon visibility settings;
- desktop namespace label overrides;
- RetroBar settings.json;
- prior RetroBar autostart value;
- metadata describing which components were already installed.

backups/ is ignored by Git.

## System Restore

The installer tries to create:

    Before Windows 95 Theme

If System Restore is disabled or Windows refuses a restore point, the project continues using its own rollback backup and prints a warning.

## Third-party download security

The project does not execute arbitrary latest-release files by default.

config/components.json pins:

- exact upstream repository;
- version/tag;
- exact official release asset URL;
- SHA-256 digest.

The installer refuses to execute a downloaded asset whose hash does not match.

## Windows 95 base appearance

The default profile applies:

- desktop teal #008080;
- classic gray #C0C0C0;
- active title navy #000080;
- white title text;
- classic selection colors;
- classic-like 96-DPI shell metrics;
- 32 px large and 16 px small icon size targets.

Windows 10 can ignore some non-client metrics on DWM-rendered or custom-drawn applications.

## RetroBar

The installer configures RetroBar with:

- Windows 95-98 theme;
- clock enabled;
- Quick Launch enabled;
- one row;
- auto-hide disabled;
- thumbnails disabled;
- desktop peek disabled;
- task badges disabled;
- blur disabled;
- autostart enabled.

Settings are stored at:

    %LOCALAPPDATA%\RetroBar\settings.json

RetroBar owns the visible Windows 95-style Start button.

## Open-Shell

Open-Shell is configured with:

- Classic1 menu style;
- Classic Skin;
- Windows key opens ClassicMenu;
- Shift+Windows opens WindowsMenu;
- AlignToWorkArea enabled;
- Open-Shell replacement Start button disabled;
- glass disabled;
- menu shadow disabled;
- menu/submenu animation disabled.

Settings are stored at:

    HKCU\Software\OpenShell\StartMenu\Settings

Open-Shell owns the classic menu while RetroBar owns the taskbar/Start button.

## Classic desktop icons

The installer enables Windows namespace desktop icons for:

- My Computer;
- Network Neighborhood;
- My Documents;
- Control Panel;
- Recycle Bin.

The underlying Windows 10 shell objects remain modern. Exact Windows 95 icon artwork can be supplied locally through the user-owned asset layer rather than redistributed publicly.

## Installer switches

Skip RetroBar:

    .\scripts\install.ps1 -SkipRetroBar

Skip Open-Shell:

    .\scripts\install.ps1 -SkipOpenShell

Skip Full Shell conversion:

    .\scripts\install.ps1 -SkipFullShell

Skip classic metrics:

    .\scripts\install.ps1 -SkipMetrics

Skip classic desktop icon labels/visibility:

    .\scripts\install.ps1 -SkipDesktopIcons

Skip restore-point attempt:

    .\scripts\install.ps1 -SkipRestorePoint

Configure without launching RetroBar/Open-Shell immediately:

    .\scripts\install.ps1 -NoLaunch

Preview the selected plan only:

    .\scripts\install.ps1 -DryRun

## User-owned cursors, sounds and icons

Prepare a folder as documented in ASSET-IMPORT.md, then run:

    .\scripts\import-user-assets.ps1 -SourceDirectory "C:\MyWin95Assets" -ApplyCursors -ApplySounds -ApplyIcons

These files are copied only to the local PC. They are never committed by the project.

To apply all supplied local assets as part of the main installation:

    .\scripts\install.ps1 -ImportAssetsFrom "C:\MyWin95Assets"

## Verify

Readable status:

    .\scripts\status.ps1

Strict configured-state verification:

    .\scripts\verify.ps1

## Final refresh

Sign out and sign back in after installation for the most reliable update of cached shell metrics, desktop labels and appearance.

See TROUBLESHOOTING.md if a component still looks modern.


## Full Shell details

See [FULL-SHELL.md](FULL-SHELL.md) for the Explorer, Control Panel, light-mode and desktop behavior.
