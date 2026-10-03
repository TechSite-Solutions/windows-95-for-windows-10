# Windows 95 clock and calendar

The project includes a **Win95 Clock Companion** for RetroBar. It does not patch RetroBar, `explorer.exe`, or protected Windows DLLs.

## Authentic mode

Historical Windows 95 behavior:

- hover over the clock -> classic rectangular tooltip containing the current date;
- double-click remains handled by RetroBar/Windows and opens the system Date/Time control panel.

```powershell
.\scripts\install-clock-companion.ps1 -Mode Authentic
```

## Enhanced mode

The theme's enhanced behavior requested for this project:

- hover over the RetroBar clock for 500 ms;
- a compact Windows 95-style month calendar opens next to the taskbar;
- leaving the clock/calendar closes it after a short delay;
- clicking a day only changes the highlight; it never silently changes the Windows system date.

```powershell
.\scripts\install-clock-companion.ps1 -Mode Enhanced
```

Enhanced mode is installed by default by the main installer.

## Styling

- `#C0C0C0` face
- `#000080` selection/header
- white selected text
- square classic controls
- no transparency
- no Windows 10 Action Center calendar

## RetroBar integration

The project sets RetroBar's single-click clock action to **Do nothing**, preventing the Windows 10 Action Center/Modern Calendar from appearing over the classic flyout.

RetroBar currently hard-codes clock double-click to `timedate.cpl`. Replacing that double-click with a fully project-owned Windows 95 Date/Time Properties dialog requires the planned RetroBar patch/fork layer.

## Positioning

The companion reads RetroBar's configured edge and supports bottom, top, left and right taskbars. The popup is constrained to the working area of the monitor that contains the taskbar.

## Local installation

```text
%LOCALAPPDATA%\Windows95ForWindows10\Clock
```

Startup registry value:

```text
HKCU\Software\Microsoft\Windows\CurrentVersion\Run
Win95ClockCompanion
```

Remove:

```powershell
.\scripts\uninstall-clock-companion.ps1
```
