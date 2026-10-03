# Changelog

## Unreleased

### Added

- one-click Install.cmd and Uninstall.cmd;
- Windows 95 base palette and teal desktop;
- classic 96-DPI-oriented WindowMetrics profile;
- classic desktop namespace visibility and Windows 95-era labels;
- automatic timestamped rollback backup before modifications;
- best-effort System Restore point creation;
- install state tracking for automatic rollback;
- pinned RetroBar 1.22.122 installer;
- pinned Open-Shell 4.4.198 installer;
- SHA-256 verification of third-party release assets before execution;
- automated RetroBar Windows 95-98 configuration and autostart;
- automated Open-Shell Classic1 / Classic Skin configuration;
- RetroBar-owned Start button with Open-Shell-owned Start menu;
- user-owned local cursor import and application;
- user-owned local sound import and application;
- user-owned local desktop icon import and application;
- rollback coverage for cursor, sound, Open-Shell, RetroBar and shell-icon settings;
- expanded status diagnostics;
- strict configuration verifier;
- PowerShell parser and manifest checks in GitHub Actions;
- installation, rollback, dependency, security, asset and troubleshooting documentation.

### Safety

- no protected system-DLL patching;
- no explorer.exe replacement;
- no Defender or Windows security disablement;
- no bundled Microsoft Windows 95 proprietary assets;
- official upstream downloads only;
- pinned SHA-256 digests;
- pre-existing RetroBar/Open-Shell installations are preserved during rollback.

### Remaining before v1.0

- native Windows 10 22H2 clean-VM acceptance;
- DPI 100%, 125% and 150% validation;
- multi-monitor validation;
- repeated install/reboot/rollback soak;
- optional deeper window-chrome validation;
- public clean-room asset pack and screenshots.
