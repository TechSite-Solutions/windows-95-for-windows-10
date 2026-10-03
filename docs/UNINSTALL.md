# Uninstall and rollback

The standard project is designed to return to the recorded pre-install appearance without replacing Windows system binaries.

## Fast rollback

Double-click:

    Uninstall.cmd

or run:

    .\scripts\uninstall.ps1

The script automatically reads state/last-install.json and restores the backup created by the matching installation.

If state is missing, it can fall back to the newest backup directory.

## Explicit backup

To choose a specific snapshot:

    .\scripts\uninstall.ps1 -BackupPath ".\backups\YYYYMMDD-HHMMSS"

To restore settings only:

    .\scripts\restore.ps1 -BackupPath ".\backups\YYYYMMDD-HHMMSS"

## Third-party components

If RetroBar or Open-Shell existed before this project ran, uninstall.ps1 preserves them.

If they were installed by this project, uninstall.ps1 attempts to remove them through their registered uninstallers.

To keep third-party programs even when this project installed them:

    .\scripts\uninstall.ps1 -KeepThirdParty

## Imported assets

Imported cursor/sound files are kept by default.

To remove the project local asset directory too:

    .\scripts\uninstall.ps1 -RemoveImportedAssets

## What is restored

Depending on the snapshot, rollback restores:

- Windows colors;
- desktop settings and classic metrics;
- cursor settings;
- AppEvents sound settings;
- Open-Shell Start Menu settings;
- desktop namespace icon visibility;
- desktop namespace label overrides;
- RetroBar settings.json;
- previous RetroBar autostart value.

## Final refresh

Sign out and sign back in after rollback.

## Emergency fallback

If Windows becomes difficult to use, use the Windows System Restore point:

    Before Windows 95 Theme

The standard installer never replaces explorer.exe, uxtheme.dll or themeui.dll and never disables Defender/security protections.
