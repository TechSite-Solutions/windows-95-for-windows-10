# Uninstall and rollback

The project is designed so visual changes can be rolled back without replacing Windows system files.

## 1. Find your backup

Each automated installation creates:

```text
backups\YYYYMMDD-HHMMSS\
```

The directory can contain:

- `colors.reg`
- `desktop.reg`
- `openshell.reg`
- `run.reg`
- `retrobar-settings.json`
- `backup.json`

## 2. Restore settings

Run:

```powershell
.\scripts\uninstall.ps1 -BackupPath ".\backups\YYYYMMDD-HHMMSS"
```

Or restore only the saved configuration:

```powershell
.\scripts\restore.ps1 -BackupPath ".\backups\YYYYMMDD-HHMMSS"
```

## 3. Remove third-party programs

The project intentionally does not force-delete third-party software.

Use **Settings → Apps** / **Programs and Features** to uninstall:

- RetroBar
- Open-Shell

This allows their official uninstall logic to run.

## Keep a component installed

You may keep RetroBar:

```powershell
.\scripts\uninstall.ps1 -BackupPath ".\backups\YYYYMMDD-HHMMSS" -KeepRetroBar
```

Or keep Open-Shell:

```powershell
.\scripts\uninstall.ps1 -BackupPath ".\backups\YYYYMMDD-HHMMSS" -KeepOpenShell
```

## 4. Sign out / sign in

After rollback and component removal, sign out of Windows and sign back in.

## Emergency fallback

If the shell becomes difficult to use, restore the System Restore point created before installation:

```text
Before Windows 95 Theme
```

## Files the standard installer does not replace

- `explorer.exe`
- `uxtheme.dll`
- `themeui.dll`

It also does not disable Defender or Windows security.
