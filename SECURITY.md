# Security

## Supported target

The project is designed for Windows 10 64-bit.

## Security principles

The standard installer:

- does not patch protected Windows DLLs;
- does not replace `explorer.exe`;
- does not disable Defender;
- does not disable Windows Update;
- does not disable code-signing checks;
- does not require a permanently relaxed PowerShell execution policy;
- downloads third-party installers only from their official GitHub release repositories.

## PowerShell policy

Documentation uses:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
```

This applies only to the current PowerShell process.

## Third-party software

RetroBar and Open-Shell are independent upstream projects.

Their installation packages are not committed to this repository. The scripts retrieve official stable release assets at install time.

## Backups

Run the standard `install.ps1` path so a timestamped backup is created before visual configuration is changed.

Do not commit the generated `backups\` contents; they can include machine/user-specific registry data.

## Local assets

`local-assets\` is ignored because users may place licensed/proprietary resources there for personal use.

Never open a pull request containing extracted Microsoft Windows resources.

## Reporting a security problem

Do not post secrets, private registry exports, tokens or personal files in a public issue. Describe the problem without sensitive data.
