# NGOS visual system

The dock uses six high-contrast circular icons with a macOS-inspired bottom placement. Pointer proximity increases the icon size and lifts the active icon by ten pixels, producing a lightweight magnification animation without requiring a heavyweight desktop shell. The icon pack is stored as `theme/icons.svg`, and the pointer theme metadata is stored in `theme/cursors.theme` with the default SVG pointer in `theme/cursor.svg`.

The visual system uses cyan `#8bf7ff`, magenta `#ff4fd8`, violet `#a77bff`, green `#4de3a8`, amber `#ffc857`, and a deep navy glass base `#07101d`. The X11 shell renders the panel and dock directly, while Picom remains optional for real translucency and blur on compatible hardware.
