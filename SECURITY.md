# Security

## Supported target

The project is designed for Windows 10 64-bit.

## Security principles

The standard installer:

- does not patch protected Windows DLLs;
- does not replace explorer.exe;
- does not disable Defender;
- does not disable Windows Update;
- does not disable code-signing checks;
- does not require a permanently relaxed PowerShell execution policy;
- creates a user-settings rollback backup before theme changes;
- preserves third-party components that existed before installation;
- executes only pinned official third-party release assets after SHA-256 verification.

## PowerShell policy

Documentation uses a process-scoped execution-policy bypass only for the current PowerShell process.

Install.cmd invokes the scripts with the same temporary process-level behavior and does not permanently relax the machine policy.

## Third-party software

RetroBar and Open-Shell are independent upstream projects.

Their binaries are not committed to this repository. The standard installer reads config/components.json, downloads the exact pinned release asset from the official upstream GitHub repository and validates SHA-256 before execution.

A hash mismatch is a hard failure. Do not bypass hash verification.

## Elevation

Most appearance configuration is current-user only.

Elevation can be requested for:

- best-effort System Restore point creation;
- system-wide Open-Shell installation;
- registered third-party uninstallers during rollback.

The main script itself does not require permanent administrator execution.

## Backups

The standard install path creates a timestamped backup under backups/ before visual configuration is changed.

Backups can contain machine/user-specific registry data and must never be committed.

## Runtime state

state/last-install.json records the backup path and whether RetroBar/Open-Shell were pre-existing or installed by this project. state/ is ignored by Git.

## Local assets

local-assets/ is ignored except for its README because users may place licensed/proprietary resources there for personal use.

Never open a pull request containing extracted Microsoft Windows resources.

## Reporting a security problem

Do not publish secrets, tokens, private registry exports, personal files or proprietary Windows assets in a public issue.

For ordinary non-sensitive bugs, use GitHub Issues.
