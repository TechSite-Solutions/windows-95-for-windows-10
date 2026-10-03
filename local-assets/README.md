# Local assets staging folder

Everything placed under this directory (except this README) is ignored by Git.

Use it only for **private, local-only resources** you are allowed to use. Original Microsoft Windows 95 assets are not distributed by this repository.

You can place all supported files directly in this directory and run:

```powershell
.\scripts\backup.ps1
.\scripts\import-user-assets.ps1 -SourceDirectory ".\local-assets" -ApplyCursors -ApplySounds -ApplyIcons
```

Or apply them during the main install:

```powershell
.\scripts\install.ps1 -ImportAssetsFrom ".\local-assets"
```

See [docs/ASSET-IMPORT.md](../docs/ASSET-IMPORT.md) for the supported filenames.
