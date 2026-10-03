# Installation

This guide targets **Windows 10 64-bit**.

## 0. Read this first

The default installation path is intentionally conservative. It changes user-level appearance settings and configures third-party shell tools, but does **not** replace protected Windows binaries.

Do not skip backup.

## 1. Create a System Restore point

Press:

```text
Win + R
```

Run:

```text
SystemPropertiesProtection.exe
```

Enable protection for the system drive if necessary, then create a restore point named:

```text
Before Windows 95 Theme
```

## 2. Clone the repository

```powershell
git clone https://github.com/TechSite-Solutions/windows-95-for-windows-10.git
cd windows-95-for-windows-10
```

## 3. Run the system check

Open PowerShell in the repository folder:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\check-system.ps1
```

The script verifies:

- Windows platform;
- Windows 10 target;
- PowerShell version;
- basic registry access;
- whether the process is elevated.

Administrator mode is not required for the current user-level theme settings.

## 4. Back up your current appearance settings

Run:

```powershell
.\scripts\backup.ps1
```

A timestamped backup will be created under:

```text
backups\YYYYMMDD-HHMMSS\
```

Keep this folder until you are satisfied with the setup.

## 5. Apply the included Windows 95 base profile

Run:

```powershell
.\scripts\install.ps1
```

The current base profile applies classic Windows 95-inspired user colors, including:

- teal desktop background;
- navy active title;
- classic gray 3D face;
- white window background;
- classic selection colors.

Some changes may require sign-out/sign-in.

## 6. Install RetroBar

Use the official project:

https://github.com/dremin/RetroBar

After installing and launching RetroBar:

1. Right-click the taskbar.
2. Open **Properties**.
3. Select the built-in **Windows 95-98** theme.
4. Enable the clock.
5. Keep taskbar auto-hide off for the classic look.
6. Disable modern thumbnail behavior if you want a stricter retro appearance.

RetroBar provides the closest practical replacement for the Windows 95 taskbar without replacing Explorer.

## 7. Install Open-Shell

Use the official project:

https://github.com/Open-Shell/Open-Shell-Menu

Recommended setup:

- Start Menu style: **Classic style**
- Show all settings: enabled
- Windows key: open Open-Shell Menu
- Align Start menu to the working area

The exact options can vary slightly by Open-Shell version.

## 8. Optional: deeper window-frame theming

Windows 10 does not expose enough built-in theming controls to recreate every Windows 95 title-bar and frame detail.

For deeper frame/button skinning, you can optionally use:

https://www.stardock.com/products/windowblinds/

This is **not required** by the base project.

## 9. Restart Explorer or sign out

For user-level changes, sign-out/sign-in is the most reliable refresh.

A helper script is included:

```powershell
.\scripts\restart-explorer.ps1
```

Note: restarting Explorer closes open File Explorer windows.

## 10. Verify the result

Expected base appearance:

- desktop teal: `#008080`
- classic 3D gray: `#C0C0C0`
- active title navy: `#000080`
- selection navy with white text
- classic taskbar through RetroBar
- classic Start menu through Open-Shell

## Next steps

See:

- [DESIGN-SPEC.md](DESIGN-SPEC.md)
- [ROADMAP.md](ROADMAP.md)
- [UNINSTALL.md](UNINSTALL.md)
