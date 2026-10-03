# Troubleshooting

## Nothing changed after running the installer

Many classic user-interface metrics are cached by the Windows shell.

Try, in order:

1. Press F5 on the desktop.
2. Exit and restart RetroBar.
3. Sign out of Windows and sign back in.
4. Reboot.

## I see two Start buttons

The project configuration disables Open-Shell's own Start button so RetroBar can render the Windows 95-style button.

Re-run:

```powershell
.\scripts\configure-openshell.ps1
```

Then restart Open-Shell and RetroBar.

## RetroBar is not using Windows 95-98

Run:

```powershell
.\scripts\configure-retrobar.ps1
```

The expected settings file is:

```text
%LOCALAPPDATA%\RetroBar\settings.json
```

and its Theme value should be:

```text
Windows 95-98
```

## Open-Shell menu is offset from the taskbar

Run:

```powershell
.\scripts\configure-openshell.ps1
```

The project enables `AlignToWorkArea`, as recommended by RetroBar for Open-Shell compatibility.

## Installation download fails

The project uses pinned official GitHub release assets and verifies their SHA-256 hashes.

Check:

- internet access;
- GitHub availability;
- proxy/firewall rules;
- the values in `config/components.json`.

Do not disable hash verification to work around a mismatch. Treat a mismatch as a failed install.

## Restore point creation fails

System Restore can be disabled by Windows configuration or policy. The project also creates its own local backup before applying settings, so installation can continue if the restore-point step warns.

## Open-Shell setup asks for elevation

Expected. Open-Shell is installed system-wide and Windows can display a UAC prompt.

## How do I verify the setup?

Run:

```powershell
.\scripts\verify.ps1
```

## Emergency rollback

Run:

```powershell
.\scripts\uninstall.ps1
```

If the desktop is difficult to use, press `Ctrl+Shift+Esc`, open Task Manager, run PowerShell, navigate to the repository and execute the rollback script.

As a final fallback, use the System Restore point named:

```text
Before Windows 95 Theme
```
