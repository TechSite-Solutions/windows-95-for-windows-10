# Dependencies

The project keeps third-party executables outside this repository and retrieves them from official release sources.

## RetroBar

Official repository:

https://github.com/dremin/RetroBar

Role:

- classic taskbar;
- notification area;
- Quick Launch;
- Windows 95-98 built-in theme.

The installer queries the GitHub **latest stable release** endpoint at runtime and downloads the official `RetroBar.Installer.zip` asset.

The version is intentionally not hard-coded so normal installations can receive a newer stable release. Native validation should record the exact version used.

## Open-Shell

Official repository:

https://github.com/Open-Shell/Open-Shell-Menu

Role:

- classic Start menu;
- Windows key behavior;
- built-in Classic Skin.

The installer queries the GitHub **latest stable release** endpoint and downloads the official `OpenShellSetup_*.exe` asset.

Only the Open-Shell core and Start Menu feature are requested by the automated installer.

## Optional WindowBlinds

Official product page:

https://www.stardock.com/products/windowblinds/

Role:

- optional deeper title-bar/window-frame skinning.

It is not downloaded or installed automatically by this project.

## Trust boundary

The automated installer trusts:

1. GitHub HTTPS;
2. the official upstream repository release metadata;
3. the official release asset supplied by that repository.

Future hardening should pin/verify upstream digests when release metadata exposes a usable SHA-256 digest for all required assets.
