# Architecture

The project is layered so each visual component can be enabled or removed independently.

```text
Windows 10
│
├── Base appearance layer
│   ├── user color registry values
│   ├── desktop background color
│   └── classic palette
│
├── Taskbar layer
│   └── RetroBar
│
├── Start menu layer
│   └── Open-Shell
│
├── Window chrome layer
│   └── optional WindowBlinds
│
├── Asset layer
│   ├── clean-room icons
│   ├── cursors
│   └── sounds/imports
│
└── Safety layer
    ├── backup
    ├── restore
    ├── system checks
    └── documentation
```

## Why layers?

Windows 10 does not expose every classic visual control through one supported theme API.

Using layers provides:

- safer rollback;
- easier troubleshooting;
- independent component replacement;
- less dependency on unsupported DLL patching.

## Standard mode

Standard mode uses:

- included registry/profile scripts;
- RetroBar;
- Open-Shell.

## Full mode

Full mode may additionally use:

- WindowBlinds or another maintained skinning solution.

Full mode is optional because deeper shell/window skinning carries more compatibility risk.

## Non-goals for the standard installer

- replacing Windows system binaries;
- disabling Windows security;
- bypassing code-signing protections;
- shipping extracted Microsoft Windows 95 resources.
