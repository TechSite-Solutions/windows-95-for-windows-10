# Dependencies

Third-party executables are not committed to this repository.

The standard installer uses pinned official release assets defined in config/components.json and verifies SHA-256 before execution.

## RetroBar

Official repository:

https://github.com/dremin/RetroBar

Pinned release:

- Version: 1.22.122
- Tag: v1.22.122
- Asset: RetroBar.Installer.zip
- SHA-256: 6499a3b4411166c44a921546237033697a05cab61d69482a6339df1e9dd5849f

Role:

- Windows 95-98 taskbar;
- notification area;
- clock;
- Quick Launch;
- visible Start button.

## Open-Shell

Official repository:

https://github.com/Open-Shell/Open-Shell-Menu

Pinned release:

- Version: 4.4.198
- Tag: v4.4.198
- Asset: OpenShellSetup_4_4_198.exe
- SHA-256: a4d2d4459de55b5e962ba2a14f7bb794170511649138173dfa72949837b48c3f

Role:

- classic Start menu;
- Windows-key behavior;
- built-in Classic Skin.

Only the core/OpenShell and StartMenu MSI features are requested by the automated installer.

## Optional WindowBlinds

WindowBlinds is not downloaded or installed automatically.

It can provide deeper title-bar/window-frame skinning than supported Windows 10 user-level theme settings, but it remains an optional manual layer.

## Updating a dependency

Do not merely change the URL.

For each update:

1. verify the release is from the official upstream repository;
2. record the exact release asset;
3. record its SHA-256 digest from trusted release metadata or a separately verified download;
4. update config/components.json;
5. run CI;
6. perform native Windows 10 installation/rollback validation;
7. update CHANGELOG.md.

Hash mismatch is a hard failure and must not be bypassed.
