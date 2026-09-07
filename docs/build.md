# NGOS image build

The image builder is intentionally written for a Void Linux x86_64 host because Void package bootstrap, `xbps-install`, and `void-mklive` are the source of truth for the base image. Install `void-mklive`, `xorriso`, `make`, `gcc`, and `libX11-devel` using the host's normal package workflow. Run `sudo ./iso/build-iso.sh` from the repository root.

The builder uses a deliberately small package set: the Void base system, minimal Xorg, Xinit, Xterm, Xsetroot, Picom, D-Bus, and elogind. It then compiles the native components and applies a hard 100 MiB byte limit. A final image is not produced in the current Ubuntu sandbox because Void's image bootstrap tools are unavailable there.

The initial NGDM is a prototype session launcher, not yet a hardened login service. For a production release, integrate PAM, seat management, VT switching, user authentication, logind session registration, and signed update metadata.
