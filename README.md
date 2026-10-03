# Windows 95 for Windows 10

A reversible Windows 95 desktop experience for Windows 10.

> Windows 10 inside. Windows 95 outside.

## Status

The repository now includes an automated core installation path:

- Windows 95 color palette and teal desktop;
- classic desktop/window metrics;
- classic desktop namespace icons and Windows 95-era labels;
- RetroBar installation and Windows 95-98 configuration;
- Open-Shell installation and Classic1 / Classic Skin configuration;
- RetroBar-owned Start button with Open-Shell-owned Start menu;
- automatic timestamped backup before changes;
- best-effort System Restore point creation;
- SHA-256 verification of pinned third-party installers;
- one-click rollback;
- configuration verification;
- user-owned cursor, sound and desktop-icon import;
- dry-run and interactive installer modes;
- GitHub Actions PowerShell syntax validation.

The main remaining milestone is native Windows 10 validation across DPI/multi-monitor configurations and optional deeper window-frame skinning.

## Safety

The standard installer does not replace or patch:

- explorer.exe
- uxtheme.dll
- themeui.dll
- protected Windows system DLLs
- Defender or Windows security settings

Third-party binaries are downloaded from official upstream GitHub releases. Their expected versions and SHA-256 hashes are pinned in config/components.json.

## One-click install

Clone the repository:

    git clone https://github.com/TechSite-Solutions/windows-95-for-windows-10.git
    cd windows-95-for-windows-10

Then double-click:

    Install.cmd

For a guided menu, double-click:

    Install-Interactive.cmd

Or run from PowerShell:

    Set-ExecutionPolicy -Scope Process Bypass
    .\scripts\install.ps1

Preview the full plan without changing Windows:

    .\scripts\install.ps1 -DryRun

The installer creates a rollback backup before making theme changes. Open-Shell installation can trigger a Windows UAC prompt.

After installation, sign out and sign back in for the most complete refresh.

## One-click rollback

Double-click:

    Uninstall.cmd

Or run:

    .\scripts\uninstall.ps1

The rollback automatically uses state/last-install.json when available. Programs that were already installed before this project are preserved. Third-party components installed by this project are removed through their normal uninstallers unless KeepThirdParty is requested.

## Components

| Area | Implementation | State |
|---|---|---|
| Desktop palette | Project scripts | Automated |
| Classic metrics | Project scripts | Automated |
| Desktop classic icons/labels | Windows namespace configuration | Automated |
| Backup / restore | Project scripts | Automated |
| Taskbar | RetroBar | Automated |
| Start menu | Open-Shell | Automated |
| Verification | Project scripts | Automated |
| Cursors | User-owned asset importer | Automated when assets are supplied |
| Sounds | User-owned asset importer | Automated when assets are supplied |
| Original Microsoft Win95 assets | Never redistributed | User-supplied only |
| Window borders/title bars | Optional WindowBlinds layer | Manual / optional |

## Pinned dependencies

Current tested installation targets in config/components.json:

- RetroBar 1.22.122
- Open-Shell 4.4.198

The downloaded files are checked against pinned SHA-256 digests before execution.

## User-owned Windows 95 assets

Because this is a public repository, original Microsoft Windows 95 icons, WAV files, cursors, fonts and binary resources are not bundled.

If you legally own compatible assets, use:

    .\scripts\import-user-assets.ps1 -SourceDirectory "C:\MyWin95Assets" -ApplyCursors -ApplySounds -ApplyIcons

You can also import and apply all supplied local assets during the main install:

    .\scripts\install.ps1 -ImportAssetsFrom "C:\MyWin95Assets"

See docs/ASSET-IMPORT.md.

## Verification

Run:

    .\scripts\status.ps1
    .\scripts\verify.ps1

status.ps1 gives a readable overview. verify.ps1 checks the expected theme configuration and returns a non-zero exit code for mismatches.

## Documentation

- docs/INSTALL.md — full installation
- docs/UNINSTALL.md — rollback
- docs/TROUBLESHOOTING.md — troubleshooting
- docs/ARCHITECTURE.md — architecture
- docs/DESIGN-SPEC.md — Windows 95 visual specification
- docs/FULL-CHROME.md — optional WindowBlinds/SkinStudio frame layer
- docs/DEPENDENCIES.md — pinned external components
- docs/ASSET-IMPORT.md — local user-owned assets
- docs/ASSETS.md — public asset policy
- docs/ROADMAP.md — milestones
- SECURITY.md — security model

## Target

Primary target:

- Windows 10 64-bit

Windows 11 and other platforms are not considered supported unless explicitly validated.

## Important limitation

Modern applications that draw their own UI will not automatically become Windows 95 applications. Windows 10 also does not expose every classic non-client metric through supported APIs. The project therefore recreates the shell experience as closely as practical without patching protected system files.

## License and trademark notice

Project code is MIT licensed. Microsoft, Windows and Windows 95 are trademarks of Microsoft Corporation.

This project is independent and is not affiliated with, endorsed by or sponsored by Microsoft, RetroBar, Open-Shell or Stardock.
