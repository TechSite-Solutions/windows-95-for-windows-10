# Architecture

The project is intentionally layered so visual components can be applied and rolled back independently.

    Windows 10
    |
    +-- Safety / transaction layer
    |   +-- system check
    |   +-- timestamped registry/file backup
    |   +-- best-effort System Restore point
    |   +-- install state tracking
    |   +-- rollback/uninstall
    |
    +-- Base appearance layer
    |   +-- Windows 95 color palette
    |   +-- teal desktop
    |   +-- classic-like WindowMetrics
    |   +-- desktop namespace icons/labels
    |
    +-- Taskbar layer
    |   +-- RetroBar
    |       +-- Windows 95-98 theme
    |       +-- Start button
    |       +-- clock
    |       +-- Quick Launch
    |
    +-- Start-menu layer
    |   +-- Open-Shell
    |       +-- Classic1
    |       +-- Classic Skin
    |       +-- Windows-key routing
    |       +-- no duplicate Start button
    |
    +-- Local asset layer
    |   +-- user-owned desktop ICO files
    |   +-- user-owned CUR/ANI files
    |   +-- user-owned WAV files
    |
    +-- Optional full-chrome layer
        +-- third-party window-frame skinning such as WindowBlinds

## Why layers?

Windows 10 does not expose every Windows 95 visual primitive through one supported theme API.

Layering provides:

- safer rollback;
- component-by-component troubleshooting;
- no protected DLL replacement in standard mode;
- preservation of existing RetroBar/Open-Shell installations;
- a clear trust boundary for third-party software and proprietary assets.

## Install transaction

scripts/install.ps1 is the orchestrator.

High-level flow:

1. validate Windows;
2. record whether third-party components already exist;
3. create a rollback backup;
4. record install state;
5. attempt a System Restore point;
6. apply base colors;
7. apply classic metrics;
8. configure classic desktop entries;
9. install/configure RetroBar;
10. install/configure Open-Shell;
11. optionally import user-owned assets;
12. write completed install state;
13. launch components;
14. run strict verification.

If a theme-stage error occurs after backup creation, the installer attempts to restore the appearance snapshot automatically.

## Dependency trust model

config/components.json pins exact release assets and SHA-256 digests.

The standard installer:

1. downloads only the configured official upstream URL;
2. calculates SHA-256 locally;
3. refuses to execute the file if the digest differs.

## Rollback model

scripts/uninstall.ps1 reads state/last-install.json and restores the matching backup.

If RetroBar/Open-Shell existed before the project ran, they are preserved.

If they were installed by this project, rollback can remove them through their registered uninstallers.

## Asset model

The public repository does not contain extracted Microsoft Windows 95 resources.

User-owned assets can be staged in local-assets/ and imported to:

    %LOCALAPPDATA%\Windows95ForWindows10\Assets

Registry/file state required to roll those changes back is captured by the standard backup.

## Standard mode

Standard mode uses only:

- project PowerShell scripts;
- RetroBar;
- Open-Shell;
- optional user-owned assets.

It does not patch Windows system binaries.

## Full-chrome mode

Windows 10 title bars and non-client rendering cannot be made fully identical to Windows 95 using only supported current-user settings.

A deeper window-frame layer therefore remains optional and must be validated separately.

## Non-goals for the standard installer

- replacing explorer.exe;
- patching uxtheme.dll/themeui.dll;
- disabling Defender/security;
- bypassing code-signing protections;
- shipping extracted Microsoft Windows 95 assets.
