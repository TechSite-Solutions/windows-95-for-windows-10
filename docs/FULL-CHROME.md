# Optional FULL-CHROME mode

The standard project intentionally keeps Windows 10 protected system files untouched. That makes installation and rollback safer, but it also means Windows 10 can retain modern non-client rendering on some windows.

For users who want a closer Windows 95 recreation, the project supports an **optional FULL-CHROME path** based on WindowBlinds 11.

## Why WindowBlinds

WindowBlinds 11 is designed for Windows 10 and Windows 11 and can skin:

- window frames;
- caption/control buttons;
- colors;
- fonts;
- other desktop interface elements.

Stardock also provides SkinStudio for creating/editing WindowBlinds skins.

Official pages:

- https://www.stardock.com/products/windowblinds/
- https://www.stardock.com/products/skinstudio/

## Important separation

FULL-CHROME is deliberately **not** installed by `Install.cmd`.

Reasons:

1. WindowBlinds is a separately licensed third-party product.
2. It changes a deeper visual layer than RetroBar/Open-Shell.
3. A custom skin must be tested on the exact Windows 10 build/DPI combination.
4. The public repository must not redistribute proprietary Microsoft Windows 95 artwork.

The normal project remains fully usable without it.

## Recommended architecture

Keep ownership split like this:

```text
RetroBar
  -> taskbar
  -> Start button
  -> notification area
  -> clock
  -> Quick Launch

Open-Shell
  -> classic Start menu
  -> Windows-key routing

WindowBlinds
  -> window frames
  -> caption buttons
  -> non-client colors/fonts
  -> compatible Win32 controls

Windows95ForWindows10 scripts
  -> palette
  -> metrics
  -> desktop objects
  -> backup/rollback
  -> local user-owned assets
```

Do not use WindowBlinds to replace the RetroBar/Open-Shell responsibilities unless a native validation explicitly proves the combination is better.

## Building a clean-room Windows 95-style skin

Use SkinStudio to create an original skin inspired by the Windows 95 geometry.

Target design values are documented in:

- DESIGN-SPEC.md

The skin should aim for:

- square title-bar geometry;
- navy active caption;
- gray inactive caption;
- classic gray frame/control surfaces;
- white/gray/black bevel edges;
- compact caption buttons;
- no transparency;
- no acrylic;
- no rounded corners;
- no gradients unless strictly required by the skin format;
- classic font sizing using fonts already present on Windows 10.

Do not include extracted Microsoft bitmaps, fonts, DLL resources or icons in a public skin.

## Installation procedure

1. Complete the normal project installation first.
2. Sign out/in and verify RetroBar + Open-Shell.
3. Create/confirm a Windows System Restore point.
4. Install a licensed/trial copy of WindowBlinds 11 from Stardock.
5. Create or import a clean-room Windows 95-style skin in SkinStudio/WindowBlinds.
6. Apply only the frame/control portions needed for the Windows 95 look.
7. Keep RetroBar as the taskbar.
8. Keep Open-Shell as the Start-menu provider.
9. Test common Win32 apps, File Explorer, browsers and development tools.
10. Record incompatibilities in the validation issue.

## Native acceptance for FULL-CHROME

Do not call the mode validated until all of these pass:

- Windows 10 22H2 x64;
- 100% DPI;
- 125% DPI;
- 150% DPI;
- maximize/restore/minimize/close buttons;
- active/inactive caption transitions;
- resizable and fixed windows;
- File Explorer;
- PowerShell/terminal windows;
- common browsers;
- Python/Qt applications;
- RetroBar/Open-Shell interaction;
- reboot/sign-out;
- WindowBlinds disable/restore;
- project rollback.

## Rollback

Before disabling/uninstalling WindowBlinds:

1. switch WindowBlinds back to the default Windows appearance;
2. verify normal Windows frames are restored;
3. uninstall WindowBlinds through its normal installer if desired;
4. run the project rollback separately:

```powershell
.\scripts\uninstall.ps1
```

WindowBlinds itself is not owned or removed by the standard project installer.

## Status

This path is **documented but not yet native-validated**.

Track the validation work in GitHub issue #7.
