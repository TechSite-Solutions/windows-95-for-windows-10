# Contributing

Contributions are welcome.

## Rules

- Keep the default install path reversible.
- Do not add extracted Microsoft Windows binaries or proprietary assets.
- Do not add scripts that disable security protections.
- Do not patch protected Windows system DLLs in the standard installer.
- Prefer official upstream release URLs.
- Pin third-party downloads and verify SHA-256 hashes.
- PowerShell changes must pass syntax validation.

## Pull requests

Explain:

1. what visual/system behavior changes;
2. which registry keys/files are affected;
3. how rollback works;
4. which Windows 10 build/DPI setting was tested.
