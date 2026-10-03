# Windows 95 Full Shell mode

Full Shell mode is the standard Windows 10 profile used by this project.

It targets the parts of the operating system visible in the user's screenshots that were still clearly Windows 10:

- black/dark Explorer;
- modern Control Panel window chrome;
- Windows 10 Quick Access-first Explorer behavior;
- Windows 7-style/two-column Open-Shell Start menu;
- modern search box in Start;
- transparent/modern shell effects;
- modern Explorer ribbon-first layout.

## What Full Shell changes

### Desktop

- removes the wallpaper so the classic teal desktop can be visible;
- applies RGB `0,128,128` / `#008080`;
- pushes the classic Win32 color table through `SetSysColors`.

### Windows theme preference

- applications that follow Windows choose light mode;
- system surfaces that follow Windows choose light mode;
- transparency is disabled;
- title-bar/border accent preference is enabled with the classic navy target.

This fixes the large black Explorer/Control Panel surfaces visible in the first native test.

### Explorer

- Explorer opens to **This PC** instead of Quick Access;
- classic menu preference is enabled;
- status-bar preference is enabled;
- ribbon is kept collapsed;
- Open-Shell **Classic Explorer** is installed;
- Classic Explorer uses an XP/classic navigation-tree mode;
- breadcrumbs are disabled;
- Explorer search field is hidden by Classic Explorer where supported;
- classic 16/24 px toolbar metrics are requested;
- Classic Explorer status bar is enabled.

Open-Shell documents that its Classic Explorer toolbar may need to be enabled once as **Classic Explorer Bar** after installation. This browser-band visibility state is intentionally not forced through undocumented registry blobs.

### Control Panel

The project requests:

- All Control Panel Items;
- icon view rather than category-first navigation;
- light system appearance.

The individual Windows 10 Control Panel applets remain the Windows 10 implementations. Their internal functionality is not replaced.

### Start menu

The profile now uses Open-Shell's real numeric radio values:

- `MenuStyle = 0` → Classic1;
- `MouseClick = 1` → ClassicMenu;
- `WinKey = 1` → ClassicMenu;
- search box hidden;
- Classic Skin;
- animations/glass/shadow disabled;
- RetroBar remains owner of the visible Start button.

This is intended to produce the **single-column Windows 95-style Start hierarchy**, not the two-column menu shown in the first native screenshot.

## What cannot be globally converted

Applications that draw their own entire interface do not use classic Win32 colors or controls. Examples include:

- ChatGPT;
- Chrome/Chromium UI;
- Visual Studio Code;
- Steam;
- many Electron applications;
- applications with custom Qt themes.

The OS theme can influence some of them if they follow system light/dark mode, but the project cannot honestly make them pixel-identical to Windows 95 globally.

They need an application-specific theme if desired.

## Window frames

Windows 10's DWM still owns modern non-client rendering. Full Shell mode can make those surfaces light/classic-colored where Windows allows, but **true Windows 95 borders and caption buttons require the optional Full Chrome layer**.

See [FULL-CHROME.md](FULL-CHROME.md).

## Rollback

All new Full Shell registry areas are included in backup schema v4:

- Themes/Personalize;
- DWM;
- Explorer Advanced;
- Explorer Ribbon;
- Control Panel view;
- Open-Shell Classic Explorer.

They are restored by `scripts/restore.ps1` / `Uninstall.cmd`.
