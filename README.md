# Windows 95 for Windows 10

A safe, reversible project for making **Windows 10 look and feel as close as practical to Windows 95** while keeping the modern Windows 10 system underneath.

> Goal: Windows 10 inside, Windows 95 outside.

## Status

**Early development / v0.1 foundation**

The project currently focuses on:

- safe backup and rollback;
- classic Windows 95 color palette;
- Windows 95-style desktop configuration;
- RetroBar integration for the classic taskbar;
- Open-Shell integration for the classic Start menu;
- optional WindowBlinds integration for deeper window-frame theming;
- documentation for installation, removal and troubleshooting.

## Safety first

This project intentionally does **not** patch or replace:

- `explorer.exe`
- `uxtheme.dll`
- `themeui.dll`
- other protected Windows system binaries

The default path is designed to be reversible.

Before applying anything, read [docs/INSTALL.md](docs/INSTALL.md).

## Quick start

1. Create a Windows restore point.
2. Clone the repository.
3. Open PowerShell.
4. Run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\check-system.ps1
.\scripts\backup.ps1
.\scripts\install.ps1
```

5. Install/configure RetroBar and Open-Shell using the instructions in [docs/INSTALL.md](docs/INSTALL.md).
6. Reboot or sign out/sign in if a visual change does not apply immediately.

## Components

| Area | Component | Required |
|---|---|---|
| Desktop colors | Included scripts | Yes |
| Backup / rollback | Included scripts | Yes |
| Taskbar | RetroBar | Recommended |
| Start menu | Open-Shell | Recommended |
| Window frames | WindowBlinds 11 | Optional |
| Icons | Project recreation/import layer | Planned |
| Cursors | Project recreation/import layer | Planned |
| Sounds | Import/recreation layer | Planned |

Official projects:

- RetroBar: https://github.com/dremin/RetroBar
- Open-Shell: https://github.com/Open-Shell/Open-Shell-Menu
- WindowBlinds: https://www.stardock.com/products/windowblinds/

## Project principles

1. **Reversible by default** — backup before changing user settings.
2. **No system-DLL patching in the standard installer.**
3. **No copyrighted Microsoft Windows 95 binary assets are redistributed.**
4. **Pixel accuracy where practical** without sacrificing Windows 10 stability.
5. **Small, auditable PowerShell scripts** instead of opaque installers during early development.

## Documentation

- [Installation](docs/INSTALL.md)
- [Uninstall / rollback](docs/UNINSTALL.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Windows 95 design specification](docs/DESIGN-SPEC.md)
- [Assets and copyright policy](docs/ASSETS.md)
- [Roadmap](docs/ROADMAP.md)

## Important note about Microsoft assets

Windows 95 artwork, icons, sounds and other original Microsoft resources may be copyrighted. This repository does not include original Microsoft binaries or extracted resources.

Where possible, this project will use clean-room recreation assets, user-provided assets, or import mechanisms.

## Target

Primary target:

- Windows 10 64-bit

The project may work on other versions, but Windows 10 is the supported target unless stated otherwise.

## Disclaimer

This is an independent community project and is not affiliated with, endorsed by, or sponsored by Microsoft, RetroBar, Open-Shell, Stardock, or the authors of third-party tools used by the project.
