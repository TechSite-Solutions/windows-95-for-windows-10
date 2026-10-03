# Roadmap

## M0 — Foundation

- [x] public repository
- [x] README and documentation
- [x] safety principles
- [x] asset/copyright policy
- [x] initial backup/restore
- [x] PowerShell CI parsing

## M1 — Base Windows 95 appearance

- [x] canonical Windows 95 palette
- [x] teal desktop
- [x] classic-like WindowMetrics
- [x] classic desktop namespace visibility/labels
- [ ] native clean Windows 10 validation
- [ ] validate DPI 100%, 125%, 150%
- [ ] validate multi-monitor behavior

## M2 — Taskbar

- [x] RetroBar automated install
- [x] pinned release + SHA-256
- [x] Windows 95-98 configuration
- [x] clock/Quick Launch profile
- [x] autostart
- [ ] native tray/clock soak
- [ ] multi-monitor validation

## M3 — Start menu

- [x] Open-Shell automated install
- [x] pinned release + SHA-256
- [x] Classic1 / Classic Skin profile
- [x] Windows key behavior
- [x] AlignToWorkArea
- [x] duplicate Start-button prevention
- [ ] native compatibility validation with RetroBar

## M4 — Assets

- [x] public asset policy
- [x] user-owned cursor importer
- [x] user-owned sound importer
- [ ] clean-room public icon set
- [ ] clean-room public cursor set
- [ ] original project sound set
- [ ] optional user-owned icon import

## M5 — Installer and rollback

- [x] one-click Install.cmd
- [x] one-click Uninstall.cmd
- [x] automatic backup
- [x] best-effort restore point
- [x] install state tracking
- [x] automatic rollback on install failure
- [x] preserve pre-existing third-party components
- [x] uninstall components installed by project
- [x] strict verification script
- [ ] dry-run mode
- [ ] interactive component chooser

## M6 — Window chrome

- [ ] evaluate optional WindowBlinds profile
- [ ] document supported skinning path
- [ ] validate title-bar/caption-button appearance
- [ ] maintain a safe standard mode without DLL patching

## M7 — Native validation

- [ ] Windows 10 22H2 clean VM
- [ ] installation from fresh clone
- [ ] sign-out/reboot testing
- [ ] Windows Update/reboot testing
- [ ] rollback validation
- [ ] repeated install/uninstall cycles
- [ ] 100/125/150% DPI
- [ ] multi-monitor
- [ ] accessibility sanity check

## M8 — v1.0

- [ ] native acceptance complete
- [ ] screenshots
- [ ] packaged release
- [ ] release notes
- [ ] known-limitations matrix
