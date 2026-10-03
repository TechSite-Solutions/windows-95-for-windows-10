# Installation

This guide targets **Windows 10 64-bit**.

## 1. Create a Windows restore point

Before changing the shell appearance:

1. Press `Win + R`.
2. Run `SystemPropertiesProtection.exe`.
3. Enable protection for the Windows drive if needed.
4. Click **Create**.
5. Name the restore point:

```text
Before Windows 95 Theme
```

The project also creates its own user-settings backup, but a System Restore point is an additional safety layer.

## 2. Clone the project

```powershell
git clone https://github.com/TechSite-Solutions/windows-95-for-windows-10.git
cd windows-95-for-windows-10
```

## 3. Allow scripts for this PowerShell process only

```powershell
Set-ExecutionPolicy -Scope Process Bypass
```

This does not permanently change the machine execution policy.

## 4. Check the machine

```powershell
.\scripts\check-system.ps1
```

The project is intended for Windows 10. Do not force it onto another Windows version unless you are deliberately testing it.

## 5. Run the automated installer

```powershell
.\scripts\install.ps1
```

The installer performs these stages:

1. creates a timestamped user-settings backup;
2. applies the Windows 95 base palette;
3. downloads the latest stable RetroBar installer from `dremin/RetroBar`;
4. installs RetroBar and enables autostart;
5. writes the RetroBar `Windows 95-98` profile;
6. downloads the latest stable Open-Shell installer from `Open-Shell/Open-Shell-Menu`;
7. installs the Open-Shell Start Menu feature;
8. writes the Windows 95-oriented Open-Shell profile.

Open-Shell installation may show a Windows UAC prompt.

No RetroBar or Open-Shell binaries are stored in this repository.

## 6. What gets configured

### Base Windows profile

The core palette includes:

- Desktop: `#008080`
- Button face: `#C0C0C0`
- Active title: `#000080`
- Active title text: `#FFFFFF`
- Window: `#FFFFFF`
- Window text: `#000000`
- Highlight: `#000080`

### RetroBar

The generated user profile selects:

- `Windows 95-98` theme;
- clock enabled;
- Quick Launch enabled;
- one taskbar row;
- no auto-hide;
- no task thumbnails;
- no modern desktop peek;
- no task badges;
- blur disabled;
- classic-oriented font rendering options.

RetroBar settings are stored under:

```text
%LOCALAPPDATA%\RetroBar\settings.json
```

### Open-Shell

The installer configures:

- Menu style: `Classic1`;
- built-in skin: `Classic Skin`;
- Windows key: Open-Shell classic menu;
- Shift+Windows: Windows menu;
- align menu to work area;
- glass disabled;
- menu shadow disabled;
- menu/submenu animation disabled;
- classic-oriented font smoothing.

Open-Shell stores this profile under:

```text
HKCU\Software\OpenShell\StartMenu\Settings
```

## 7. Installation switches

Skip RetroBar:

```powershell
.\scripts\install.ps1 -SkipRetroBar
```

Skip Open-Shell:

```powershell
.\scripts\install.ps1 -SkipOpenShell
```

Do not launch RetroBar/Open-Shell immediately:

```powershell
.\scripts\install.ps1 -NoLaunch
```

You can also install/configure components separately:

```powershell
.\scripts\install-retrobar.ps1
.\scripts\configure-retrobar.ps1

.\scripts\install-openshell.ps1
.\scripts\configure-openshell.ps1
```

## 8. Verify the setup

Run:

```powershell
.\scripts\status.ps1
```

It reports:

- Windows version/build;
- whether RetroBar is installed;
- whether the RetroBar profile exists;
- whether Open-Shell is installed;
- whether Open-Shell settings exist;
- current desktop/title/button colors;
- whether the base Windows 95 palette is active.

## 9. Refresh the Windows shell

For the most reliable result, **sign out and sign back in**.

A lighter refresh helper is also available:

```powershell
.\scripts\restart-explorer.ps1
```

Restarting Explorer closes File Explorer windows, so save your work first.

## 10. Optional local Windows 95 assets

The public project cannot redistribute original Microsoft Windows 95 resources.

If you own suitable assets, place them in the ignored `local-assets\` tree and use the local import layer documented in:

[../local-assets/README.md](../local-assets/README.md)

## 11. Optional deeper window chrome

Windows 10 does not expose enough supported theme controls to make every title bar, frame and caption button identical to Windows 95.

The standard project therefore leaves protected Windows binaries untouched.

For a deeper visual layer, WindowBlinds can be used manually. Treat this as optional because it changes more of the desktop rendering stack than RetroBar/Open-Shell.

## Troubleshooting

If the desktop still looks partly modern after installation, that is expected for applications that draw their own UI or for Windows 10 surfaces not controlled by classic color registry values.

Run:

```powershell
.\scripts\status.ps1
```

Then sign out/in before diagnosing further.
