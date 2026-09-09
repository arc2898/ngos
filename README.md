# NGOS

NGOS is an experimental x86_64 operating-system project built around a Rust workspace and a seL4 kernel configuration. The project is **under active development** and is not yet a bootable stable release.

## Repository status

The current `main` branch contains the kernel, userspace, driver, application, and library workspace manifests together with the seL4 configuration stub. The historical desktop prototype (Openbox session, wallpaper, cursor/icon assets, and GUI smoke tests) is not part of the current tree, so desktop validation is not available from this checkout.

## Prerequisites

A Linux development environment needs:

- Rust nightly with Cargo and the `x86_64-unknown-none` target;
- CMake and a C compiler for the seL4 configuration;
- the ISO build tooling referenced by `build.sh` (currently expected at `../plans/ISO_MAKEFILES`); and
- QEMU/OVMF if boot testing is available.

The build scripts intentionally use the `nightly` Rust toolchain because the workspace targets a bare-metal architecture. Install the required toolchain and target before building, for example:

```sh
rustup toolchain install nightly
rustup target add --toolchain nightly x86_64-unknown-none
```

## Build

The Linux build orchestrator is `build.sh`. Run it from the repository root through Bash:

```sh
bash build.sh clean
bash build.sh all
```

Useful narrower targets are `kernel`, `userspace`, `drivers`, `apps`, `libs`, and `iso`. Add `--release` to build Rust packages with the release profile. The Windows equivalent is `build.ps1`.

The repository currently does not provide a `Makefile`; use `build.sh` or `build.ps1` directly rather than `make clean all`.

## Validation

Before submitting a change, run the checks supported by the checkout and environment:

```sh
bash -n build.sh
find . -name '*.sh' -not -path './.git/*' -print0 | xargs -0 -r -n1 bash -n
git diff --check
```

When the required tools and ISO tree are available, run `bash build.sh clean` followed by `bash build.sh all` and boot the resulting ISO with the configured QEMU test target. Openbox/Xvfb GUI tests, terminal-launch tests, and asset-installation checks belong to the historical desktop prototype and are not currently present on `main`.

## Scope

The workspace contains an experimental browser package, but this documentation change does not add or modify browser functionality. Changes should remain small, preserve the existing workspace structure, and document environmental limitations rather than silently skipping failed build steps.
