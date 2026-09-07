# NGOS

**NGOS — Next Generation Operating System** is a tiny Void Linux derivative with a stable X11 desktop baseline. Its visual language combines a Windows-like task surface, macOS-inspired shell affordances, and a cyberpunk glass aesthetic: cyan/violet neon, translucent panels, soft blur, wobbly motion, and a magic-lamp minimize animation.

This repository contains the source for the **NGOS session**, a minimal **NGDM** display-manager prototype, theme assets, and a reproducible Void `mklive` ISO builder. The first milestone targets a compressed image under 150 MiB on x86_64 Intel-compatible hardware.

The stable session loads the NGOS wallpaper from `/usr/share/backgrounds/ngos/wallpaper.svg` and selects the WhiteSur cursor theme at login. `theme/install-assets.sh` installs those runtime assets into an image root.

## Components

| Component | Role |
|---|---|
| `src/ngoswm.c` | Stable branded panel/dock layer with launcher, workspaces, dark-mode toggle, and dock magnification. |
| `openbox` | Mature X11 window manager used for title bars, close/minimize/maximize controls, focus, move, resize, and stacking. |
| `src/ngdm.c` | Minimal foreground display-manager prototype that starts Xorg through `xinit` and launches the NGOS session. |
| `session/ngos-session` | Session startup, wallpaper, compositor, hotkeys, and service setup. |
| `theme/` | SVG logo, mac-inspired dock icon pack, WhiteSur upstream integration, cursor theme, wallpaper, and palette definitions. |
| `iso/build-iso.sh` | Void `mklive` image build with a size gate. |
| `packages/` | Void package templates for `ngoswm` and `ngdm`. |

## Keyboard map

`Super` opens the launcher. `Super+Enter` opens a terminal. `Super+1..4` switches workspaces. `Super+Shift+Q` closes the focused window. `Super+M` triggers the magic-lamp minimize effect. The default shell configuration is Zsh with a Kali-inspired prompt, completion, history, and safe convenience aliases.

## Build

On a Void Linux x86_64 build host with `void-mklive`, `xorriso`, and root privileges:

```sh
sudo ./iso/build-iso.sh
```

The builder downloads only the requested packages, installs the custom components, writes the default session, and rejects an image larger than 150 MiB. The additional 50 MiB budget is reserved for the richer shell, icon/cursor pack, and desktop polish. Proprietary GPU stacks and broad firmware bundles are excluded.

## Status

This is the first stable-release baseline. Before daily-driver use, add PAM policy, session isolation, accessibility support, power management, hardware probing, signed release artifacts, and a real installer.

## License

MIT. See `LICENSE`.

## References

[1]: https://voidlinux.org/ "Void Linux"
[2]: https://docs.voidlinux.org/ "Void Linux Handbook"
[3]: https://github.com/void-linux/void-mklive "Void mklive"
[4]: https://tronche.com/gui/x/xlib/ "Xlib Programming Manual"

References: [1] [2] [3] [4]

**Author:** Manus AI
