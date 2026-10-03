# User-owned Windows 95 assets

This public repository intentionally does **not** distribute extracted Microsoft Windows 95 icons, cursors, sounds, bitmaps or fonts.

If you legally have your own Windows 95 media/files, the project can import compatible cursor and sound assets locally without committing them to Git.

## Import directory

Prepare a local folder with any of these optional filenames.

### Cursors

```text
arrow.cur
help.cur
appstarting.ani
wait.ani
crosshair.cur
ibeam.cur
nwpen.cur
no.cur
sizens.cur
sizewe.cur
sizenwse.cur
sizenesw.cur
sizeall.cur
uparrow.cur
hand.cur
```

### Sounds

```text
asterisk.wav
exclamation.wav
critical-stop.wav
question.wav
startup.wav
shutdown.wav
empty-recycle-bin.wav
```

The files may be your own recreations or files you are legally entitled to use.

## Import only

```powershell
.\scripts\import-user-assets.ps1 -SourceDirectory "C:\MyWin95Assets"
```

## Import and apply cursors

```powershell
.\scripts\import-user-assets.ps1 -SourceDirectory "C:\MyWin95Assets" -ApplyCursors
```

## Import and apply sounds

```powershell
.\scripts\import-user-assets.ps1 -SourceDirectory "C:\MyWin95Assets" -ApplySounds
```

## Import and apply both

```powershell
.\scripts\import-user-assets.ps1 -SourceDirectory "C:\MyWin95Assets" -ApplyCursors -ApplySounds
```

Imported files are copied to:

```text
%LOCALAPPDATA%\Windows95ForWindows10\Assets
```

They remain local to your PC and are ignored by the repository.
