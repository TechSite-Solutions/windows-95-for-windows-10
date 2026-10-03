# Windows 95 Design Specification

This document is the visual source of truth for the project.

## Canonical palette

| Role | RGB | HEX |
|---|---:|---|
| Desktop | 0,128,128 | #008080 |
| Button / 3D Face | 192,192,192 | #C0C0C0 |
| Active Title | 0,0,128 | #000080 |
| Active Title Text | 255,255,255 | #FFFFFF |
| Inactive Title | 128,128,128 | #808080 |
| Window | 255,255,255 | #FFFFFF |
| Window Text | 0,0,0 | #000000 |
| Button Text | 0,0,0 | #000000 |
| 3D Highlight | 255,255,255 | #FFFFFF |
| 3D Light | 223,223,223 | #DFDFDF |
| 3D Shadow | 128,128,128 | #808080 |
| 3D Dark Shadow | 0,0,0 | #000000 |
| Selection | 0,0,128 | #000080 |
| Selection Text | 255,255,255 | #FFFFFF |

## Classic-like metrics used by the project

The base metric profile targets the compact 96-DPI Windows 95-era proportions as closely as practical through Windows 10 WindowMetrics.

| Registry value | Project value |
|---|---:|
| BorderWidth | -15 |
| CaptionHeight | -270 |
| CaptionWidth | -270 |
| MenuHeight | -270 |
| MenuWidth | -270 |
| ScrollHeight | -240 |
| ScrollWidth | -240 |
| SmCaptionHeight | -210 |
| SmCaptionWidth | -210 |
| PaddedBorderWidth | 0 |
| IconSpacing | -1125 |
| IconVerticalSpacing | -1125 |
| Shell Icon Size | 32 |
| Shell Small Icon Size | 16 |

Windows 10 may ignore some metrics for DWM-rendered or custom-drawn applications. Native validation is therefore required at 100%, 125% and 150% DPI.

## Geometry principles

- square visual language;
- no acrylic/transparency;
- no rounded controls;
- hard 1-2 px bevels;
- raised controls use light top/left and dark bottom/right edges;
- pressed controls reverse the bevel;
- compact spacing;
- compact title bars and taskbar;
- no modern centered taskbar layout.

## Typography

Historical Windows 95 UI commonly used MS Sans Serif-era bitmap presentation.

The public project does not redistribute proprietary font files. On Windows 10, compatible installed fonts are preferred and font smoothing is disabled only inside the configured classic shell components where supported.

## Desktop

Target:

- solid teal #008080;
- classic 32 px desktop icon scale;
- My Computer;
- Network Neighborhood;
- My Documents;
- Control Panel;
- Recycle Bin.

The standard installer exposes the Windows 10 equivalents and can apply user-owned ICO files locally.

## Taskbar

RetroBar is responsible for:

- gray classic 3D taskbar;
- Windows 95-98 theme;
- raised Start button;
- task buttons;
- notification area;
- clock;
- Quick Launch;
- no blur;
- no desktop peek;
- no task thumbnails in the strict profile.

## Start menu

Open-Shell is responsible for:

- Classic1 menu layout;
- Classic Skin;
- classic menu hierarchy;
- Windows key opens classic menu;
- Shift+Windows keeps access to the Windows menu;
- AlignToWorkArea for RetroBar;
- its own replacement Start button disabled to avoid duplication.

## Window chrome

The base Windows 10 compositor cannot reproduce every Windows 95 title-bar, border and caption-button detail through supported user-level settings.

Therefore:

- standard mode keeps Windows system binaries intact;
- classic WindowMetrics are applied where Windows honors them;
- full non-client/window-frame recreation remains an optional separately validated layer.

## Assets

Original Windows 95 Microsoft icons, cursors, sounds and fonts are not redistributed.

For personal accuracy, user-owned assets can be imported locally via scripts/import-user-assets.ps1 without entering Git history.
