# Security

## Supported scope

This project modifies Windows appearance settings and integrates third-party shell utilities.

The standard installer deliberately avoids:

- patching protected Windows DLLs;
- replacing explorer.exe;
- disabling Microsoft Defender;
- disabling Windows security features;
- bypassing driver or code-signing enforcement.

## Third-party downloads

Pinned releases are recorded in `config/components.json` with SHA-256 hashes.

If a downloaded file does not match the expected hash, installation must stop.

## Reporting a security issue

Do not publish secrets, access tokens or personal data in an issue.

For ordinary non-sensitive bugs, use GitHub Issues.

## Local backups

The `backups/` and `state/` directories can contain machine/user-specific registry data and are excluded from Git.
