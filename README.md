# Windows 95 for Windows 10

A safe, reversible project for making **Windows 10 look and feel as close as practical to Windows 95** while keeping the modern Windows 10 system underneath.

> **Windows 10 inside. Windows 95 outside.**

## Current status

The project now has an automated installation path for the core experience:

- Windows 95 base color palette and teal desktop;
- automatic backup before changes;
- automatic download/install/configuration of **RetroBar** from its official GitHub release;
- automatic download/install/configuration of **Open-Shell** from its official GitHub release;
- RetroBar **Windows 95-98** taskbar profile;
- Open-Shell **Classic1 + Classic Skin** Start menu profile;
- status diagnostics;
- rollback/restore tooling;
- PowerShell syntax checks in GitHub Actions;
- optional local-asset layer for user-owned Windows 95 icons, cursors and sounds.

The remaining work is primarily **native Windows 10 validation**, clean-room assets for public distribution, and optional deeper window-frame skinning.

## Safety model

The standard installer deliberately does **not** patch or replace:

- `explorer.exe`
- `uxtheme.dll`
- `themeui.dll`
- protected Windows DLLs
- Windows security components

Third-party programs are downloaded from their official GitHub release endpoints at install time; their binaries are not stored in this repository.

## Quick install

First create a Windows restore point. Then:

```powershell
git clone https://github.com/TechSite-Solutions/windows-95-for-windows-10.git
cd windows-95-for-windows-10

Set-ExecutionPolicy -Scope Process Bypass
.\scripts\check-system.ps1
.\scripts\install.ps1
.\scripts\status.ps1
```

The installer creates a timestamped backup automatically.

Open-Shell installation may trigger a Windows UAC prompt.

After installation, **sign out and sign back in** for the most reliable shell refresh.

See [docs/INSTALL.md](docs/INSTALL.md) for the full procedure.

## Installation options

Install only the base theme + Open-Shell:

```powershell
.\scripts\install.ps1 -SkipRetroBar
```

Install only the base theme + RetroBar:

```powershell
.\scripts\install.ps1 -SkipOpenShell
```

Configure everything without launching the shell replacements immediately:

```powershell
.\scripts\install.ps1 -NoLaunch
```

## Components

| Area | Implementation | State |
|---|---|---|
| Desktop palette | project scripts | Automated |
| Backup / restore | project scripts | Automated |
| Taskbar | RetroBar | Automated |
| Start menu | Open-Shell | Automated |
| Status diagnostics | project scripts | Automated |
| Local user-owned assets | import layer | In progress |
| Public clean-room icons | project assets | Planned |
| Public clean-room cursors | project assets | Planned |
| Public clean-room sounds | project assets | Planned |
| Window borders/title bars | optional WindowBlinds layer | Optional / manual |

Official dependencies:

- RetroBar: https://github.com/dremin/RetroBar
- Open-Shell: https://github.com/Open-Shell/Open-Shell-Menu
- WindowBlinds (optional): https://www.stardock.com/products/windowblinds/

## Rollback

Find the timestamped backup created under `backups\`, then run:

```powershell
.\scripts\uninstall.ps1 -BackupPath ".\backups\YYYYMMDD-HHMMSS"
```

The project restores the backed-up user registry configuration and RetroBar settings. Third-party programs are intentionally removed through their official uninstallers / Windows Apps & Features.

See [docs/UNINSTALL.md](docs/UNINSTALL.md).

## Personal pixel-accuracy mode

This is a **public repository**, so it does not redistribute original Microsoft Windows 95 icons, sounds, cursors, fonts, DLLs or executable resources.

For personal use, the project supports a local asset folder that is ignored by Git. You may place assets you lawfully own there and apply them locally without publishing them.

See [local-assets/README.md](local-assets/README.md).

## Documentation

- [Installation](docs/INSTALL.md)
- [Uninstall / rollback](docs/UNINSTALL.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Windows 95 design specification](docs/DESIGN-SPEC.md)
- [Dependencies](docs/DEPENDENCIES.md)
- [Asset policy](docs/ASSETS.md)
- [Roadmap](docs/ROADMAP.md)
- [Security](SECURITY.md)

## Target

Primary supported target:

- Windows 10 64-bit

Other Windows versions are not considered validated unless explicitly documented.

## Disclaimer

This is an independent community project and is not affiliated with, endorsed by, or sponsored by Microsoft, RetroBar, Open-Shell, Stardock, or the authors of third-party tools used by the project.
