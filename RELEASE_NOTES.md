# NGOS 0.1.0 — Stable Baseline

NGOS 0.1.0 is the first stable desktop baseline for the Next Generation Operating System project. It combines Void Linux, a branded NGOS panel and dock, Openbox window management, an NGOS wallpaper, WhiteSur cursor/icon integration, and a Kali-inspired Zsh configuration.

## Included

The release provides real application title bars and controls through Openbox, including close, minimize, maximize, move, resize, focus, and stacking behavior. The NGOS session loads the wallpaper from `/usr/share/backgrounds/ngos/wallpaper.svg`, selects the configured cursor theme, and exposes the `Super+D` dark-mode toggle.

The image package list intentionally excludes a web browser. The default application set remains minimal: terminal, files, settings entry point, and the core desktop session.

## Verification

The release was compiled with the local X11 toolchain and validated with the GUI, terminal-launch, stable Openbox, shell-syntax, and image-root asset-installation checks. The stable screenshot is stored at `docs/screenshots/ngos-stable-terminal.png`.

## Scope

This is a stable baseline, not a claim of production-grade hardware coverage. PAM policy, power management, accessibility, signed artifacts, a graphical installer, and broader hardware validation remain follow-up work.
