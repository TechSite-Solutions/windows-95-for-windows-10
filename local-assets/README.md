# Local assets

This directory is for **private, local-only assets** that are not committed to the public repository.

The project does not distribute original Microsoft Windows 95 resources.

If you lawfully own Windows 95 assets, place compatible files here and run:

```powershell
.\scripts\backup.ps1
.\scripts\import-local-assets.ps1
```

## Cursors

Place files under `local-assets\cursors\`.

Recognized names:

```text
arrow.cur
help.cur
appstarting.ani
appstarting.cur
wait.ani
wait.cur
cross.cur
ibeam.cur
no.cur
size-ns.cur
size-we.cur
size-nwse.cur
size-nesw.cur
size-all.cur
up.cur
hand.cur
```

## Sounds

Place WAV files under `local-assets\sounds\`.

Recognized names:

```text
asterisk.wav
exclamation.wav
critical-stop.wav
question.wav
default-beep.wav
empty-recycle-bin.wav
logon.wav
logoff.wav
notification.wav
```

Windows 10 may not play every legacy event even when an event path is configured.

## Desktop icons

Place ICO files under `local-assets\icons\`.

Recognized names:

```text
computer.ico
network.ico
recycle-empty.ico
recycle-full.ico
```

These are applied as current-user shell icon overrides. Explorer may require restart/sign-out before showing the changes.

## Public-repository rule

Do not commit proprietary Microsoft assets here.

The repository's `.gitignore` keeps local asset contents out of Git while retaining this README.
