# Roadmap

## M0 — Foundation

- [x] public repository
- [x] README / license / contributing guide
- [x] safety model
- [x] install / uninstall documentation
- [x] architecture and design specification
- [x] GitHub Actions PowerShell validation

## M1 — Base Windows 95 appearance

- [x] canonical Windows 95 palette
- [x] registry-based color profile
- [x] classic 96-DPI-oriented WindowMetrics profile
- [x] classic desktop icon visibility and labels
- [x] restore-point helper
- [x] automatic rollback backup
- [ ] native Windows 10 visual validation
- [ ] verify DPI 100%, 125%, 150%

## M2 — Taskbar

- [x] pin verified RetroBar release
- [x] verify official release SHA-256
- [x] automated installation
- [x] Windows 95-98 theme configuration
- [x] startup configuration
- [x] Quick Launch / clock profile
- [ ] native multi-monitor verification
- [ ] native tray/clock soak

## M3 — Start menu

- [x] pin verified Open-Shell release
- [x] verify official release SHA-256
- [x] automated Start Menu installation
- [x] Classic1 + Classic Skin profile
- [x] Windows-key behavior
- [x] AlignToWorkArea for RetroBar compatibility
- [x] disable duplicate Open-Shell Start button
- [ ] native interaction verification

## M4 — Icons

- [x] show/rename classic desktop shell entries
- [x] user-owned local icon import framework
- [x] current-user desktop icon override support
- [ ] public clean-room icon set
- [ ] folder/drive/file-type clean-room icons

## M5 — Cursors

- [x] user-owned cursor importer
- [x] cursor registry application
- [x] backup / rollback coverage
- [ ] public clean-room cursor set

## M6 — Sounds

- [x] user-owned sound importer
- [x] Windows event sound mapping
- [x] backup / rollback coverage
- [ ] public clean-room sound set
- [ ] verify legacy event behavior on Windows 10

## M7 — Window chrome

- [x] document limitation of supported Windows 10 theming
- [ ] evaluate optional WindowBlinds profile on native Windows 10
- [ ] document verified full-chrome configuration
- [ ] rollback validation for optional full-chrome layer

## M8 — Installer UX

- [x] one-command PowerShell installer
- [x] double-click Install.cmd entrypoint
- [x] component skip switches
- [x] automatic backup
- [x] automatic restore point attempt
- [x] automatic rollback on failure
- [x] state tracking
- [x] verification script
- [x] user-owned asset import switch
- [ ] interactive menu UI
- [ ] dry-run mode

## M9 — Validation

- [x] CI parse validation
- [x] manifest validation
- [ ] Windows 10 22H2 native install
- [ ] clean VM install / reboot / sign-out soak
- [ ] uninstall / restore native validation
- [ ] update/reboot testing
- [ ] accessibility sanity check

## M10 — v1.0

- [ ] native acceptance gates passed
- [ ] screenshots
- [ ] release notes
- [ ] packaged release
