# User-owned Windows 95 assets

This public repository intentionally does **not** distribute extracted Microsoft Windows 95 icons, cursors, sounds, bitmaps or fonts.

If you legally own compatible assets, the project can copy and apply them locally without committing them to Git.

## Prepare one source directory

The importer accepts the following optional filenames.

### Cursors

```text
arrow.cur
help.cur
appstarting.ani   (or appstarting.cur)
wait.ani          (or wait.cur)
crosshair.cur     (or cross.cur)
ibeam.cur
nwpen.cur
no.cur
sizens.cur        (or size-ns.cur)
sizewe.cur        (or size-we.cur)
sizenwse.cur      (or size-nwse.cur)
sizenesw.cur      (or size-nesw.cur)
sizeall.cur       (or size-all.cur)
uparrow.cur       (or up.cur)
hand.cur
```

### Sounds

```text
asterisk.wav
exclamation.wav
critical-stop.wav
question.wav
default-beep.wav
startup.wav       (or logon.wav)
shutdown.wav      (or logoff.wav)
notification.wav
empty-recycle-bin.wav
```

Windows 10 may not play every legacy event even when a path is configured.

### Desktop icons

```text
computer.ico
network.ico
my-documents.ico  (or documents.ico)
control-panel.ico
recycle-empty.ico
recycle-full.ico
```

## Import only

```powershell
.\scripts\import-user-assets.ps1 -SourceDirectory "C:\MyWin95Assets"
```

## Import and apply everything supplied

```powershell
.\scripts\backup.ps1
.\scripts\import-user-assets.ps1 -SourceDirectory "C:\MyWin95Assets" -ApplyCursors -ApplySounds -ApplyIcons
```

## Apply during the main install

```powershell
.\scripts\install.ps1 -ImportAssetsFrom "C:\MyWin95Assets"
```

The main installer creates its rollback backup **before** applying these local assets.

## Where imported files are stored

```text
%LOCALAPPDATA%\Windows95ForWindows10\Assets
```

## Git safety

The repository ignores `local-assets\` content except its README. You can use that folder as a private staging area, but never commit proprietary Microsoft resources to the public repository.

## Rollback

Cursor, sound and relevant desktop shell registry settings are included in the project's backup/restore scope. To remove the copied local asset files as well:

```powershell
.\scripts\uninstall.ps1 -RemoveImportedAssets
```
