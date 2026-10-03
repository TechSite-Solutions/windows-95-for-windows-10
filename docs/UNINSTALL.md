# Uninstall and rollback

There are two rollback levels.

## Level 1: restore the backup created by this project

Find the backup folder created by:

```powershell
.\scripts\backup.ps1
```

Then run:

```powershell
.\scripts\restore.ps1 -BackupPath ".\backups\YYYYMMDD-HHMMSS"
```

After restoration, sign out and sign back in.

## Level 2: manual component removal

### RetroBar

Exit RetroBar and uninstall/remove it using its normal installation method.

### Open-Shell

Uninstall Open-Shell from Windows Apps & Features / Programs and Features.

### WindowBlinds

If you installed the optional WindowBlinds layer, switch back to the default Windows theme before uninstalling it.

## Restore Point fallback

If a configuration becomes unusable, use the restore point created before installation:

```text
Before Windows 95 Theme
```

## What this project does not modify

The standard installer does not replace:

- explorer.exe
- uxtheme.dll
- themeui.dll

That is deliberate so rollback remains simple.
