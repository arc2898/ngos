# NGOS visual system

The dock uses six high-contrast circular icons with a macOS-inspired bottom placement. Pointer proximity increases the icon size and lifts the active icon by ten pixels, producing a lightweight magnification animation without requiring a heavyweight desktop shell. The icon pack is stored as `theme/icons.svg`, and the pointer theme metadata is stored in `theme/cursors.theme` with the default SVG pointer in `theme/cursor.svg`.

The visual system uses cyan `#8bf7ff`, magenta `#ff4fd8`, violet `#a77bff`, green `#4de3a8`, amber `#ffc857`, and a deep navy glass base `#07101d`. The X11 shell renders the panel and dock directly, while Picom remains optional for real translucency and blur on compatible hardware.

For production assets, `theme/install-upstream.sh` pulls the maintained [WhiteSur icon theme](https://github.com/vinceliuice/WhiteSur-icon-theme) and [WhiteSur cursor theme](https://github.com/vinceliuice/WhiteSur-cursors) with shallow Git clones. The script avoids copying an unreviewed binary bundle into the repository. `theme/ngos-zshrc` provides the Kali-style Zsh experience without requiring the full Kali distribution configuration.

NGOS deliberately delegates application window management to Openbox in the stable release. Openbox supplies the tested title bar, close, minimize, maximize, move, resize, focus, and stacking behavior. NGOSWM owns only the branded panel, dock, launcher, workspace shortcuts, and `Super+D` dark-mode toggle. This separation prevents the earlier custom reparenting bugs from affecting application windows.
