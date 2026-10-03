# Windows 95 Design Specification

This document is the visual source of truth for the project.

## Canonical palette

| Role | RGB | HEX |
|---|---:|---|
| Desktop | 0,128,128 | #008080 |
| Button/3D Face | 192,192,192 | #C0C0C0 |
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

## Geometry principles

- square corners;
- no acrylic/transparency;
- no rounded controls;
- hard 1-2 px bevels;
- pressed controls invert light/shadow direction;
- dense spacing compared with modern Windows;
- compact title bars and taskbar.

## Typography

The historical target is the Windows 95-era system UI appearance.

For compatibility on Windows 10, the project should prefer fonts already installed with Windows and avoid redistributing proprietary font files.

## Taskbar

Target:

- gray classic 3D surface;
- raised Start button;
- simple task buttons;
- classic tray and clock;
- no modern blur;
- no centered icons.

## Start menu

Target:

- classic single-column/legacy hierarchy;
- gray surface;
- black text;
- classic submenu arrows;
- no modern tiles.

## Window chrome

Base Windows 10 cannot reproduce every Windows 95 frame metric exactly.

The project therefore treats window-chrome recreation as a separate optional layer.
