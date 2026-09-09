#!/bin/bash
# NGOS Build Orchestrator for Linux/macOS

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
TARGET="${BUILD_TYPE:-debug}"
RUST_TOOLCHAIN="nightly"

log() { echo "[$(date '+%H:%M:%S')] $*"; }
log_green() { echo -e "\033[32m[$(date '+%H:%M:%S')] $*\033[0m"; }
log_yellow() { echo -e "\033[33m[$(date '+%H:%M:%S')] $*\033[0m"; }
log_red() { echo -e "\033[31m[$(date '+%H:%M:%S')] $*\033[0m"; }
log_cyan() { echo -e "\033[36m[$(date '+%H:%M:%S')] $*\033[0m"; }

cargo_cmd() {
    log_cyan "Running: cargo +$RUST_TOOLCHAIN $*"
    cargo +"$RUST_TOOLCHAIN" "$@"
}

build_kernel() {
    log_yellow "Building seL4 kernel..."
    local kernel_dir="$PROJECT_ROOT/kernel/sel4-config"
    mkdir -p "$kernel_dir/build"
    cd "$kernel_dir/build"
    cmake .. -DCMAKE_BUILD_TYPE="${TARGET^^}"
    cmake --build . --config "${TARGET^^}" --parallel
    log_green "seL4 kernel built: kernel.elf"
}

build_rust() {
    local package="$1"
    shift
    local features=("$@")
    local feat_str=""
    if [[ ${#features[@]} -gt 0 ]]; then
        feat_str="--features $(IFS=,; echo "${features[*]}")"
    fi
    local profile_flag=""
    [[ "$TARGET" == "release" ]] && profile_flag="--release"
    cargo_cmd build -p "$package" $profile_flag $feat_str --target x86_64-unknown-none
}

build_iso() {
    log_yellow "Building bootable ISO..."
    cd "$PROJECT_ROOT/../plans/ISO_MAKEFILES"
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        pwsh ./build_iso.ps1 -Target "$TEST_TARGET" -BuildType "$TARGET"
    else
        ./build_iso.sh -Target "$TEST_TARGET" -BuildType "$TARGET"
    fi
    log_green "ISO created in $BUILD_DIR/iso/"
}

TARGET_CMD="all"
TEST_TARGET="qemu"
while [[ $# -gt 0 ]]; do
    case $1 in
        clean|kernel|userspace|drivers|apps|libs|iso|all|test)
            TARGET_CMD="$1"
            ;;
        --target)
            TEST_TARGET="$2"
            shift
            ;;
        --release)
            TARGET="release"
            ;;
        --verbose)
            set -x
            ;;
        *)
            log_red "Unknown argument: $1"
            exit 1
            ;;
    esac
    shift
done

case $TARGET_CMD in
    clean)
        log_yellow "Cleaning build artifacts..."
        rm -rf "$BUILD_DIR"
        cargo_cmd clean
        ;;
    kernel)
        build_kernel
        ;;
    userspace)
        build_rust ngos-init
        build_rust ngos-vfs
        build_rust ngos-net
        build_rust ngos-audio
        build_rust ngos-agent
        build_rust ngos-compositor
        build_rust ngos-shell
        build_rust ngos-services
        ;;
    drivers)
        build_rust ngos-intel-i915
        build_rust ngos-ahci
        build_rust ngos-ext4
        build_rust ngos-e1000e
        build_rust ngos-rtl8188eu
        build_rust ngos-xhci
        build_rust ngos-hid
        build_rust ngos-hda
        build_rust ngos-acpi
        ;;
    apps)
        build_rust ngos-terminal
        build_rust ngos-editor
        build_rust ngos-browser
        build_rust ngos-ai-assistant
        build_rust ngos-settings
        ;;
    libs)
        build_rust ngos-sel4-sys
        build_rust ngos-capability
        build_rust ngos-tahoe-ui
        build_rust ngos-wasm-runtime
        build_rust ngos-cursor-assets
        ;;
    iso)
        build_iso
        ;;
    all)
        build_kernel
        build_rust ngos-sel4-sys
        build_rust ngos-capability
        build_rust ngos-tahoe-ui
        build_rust ngos-wasm-runtime
        build_rust ngos-cursor-assets
        build_rust ngos-intel-i915
        build_rust ngos-ahci
        build_rust ngos-ext4
        build_rust ngos-e1000e
        build_rust ngos-rtl8188eu
        build_rust ngos-xhci
        build_rust ngos-hid
        build_rust ngos-hda
        build_rust ngos-acpi
        build_rust ngos-init
        build_rust ngos-vfs
        build_rust ngos-net
        build_rust ngos-audio
        build_rust ngos-agent
        build_rust ngos-compositor
        build_rust ngos-shell
        build_rust ngos-services
        build_rust ngos-terminal
        build_rust ngos-editor
        build_rust ngos-browser
        build_rust ngos-ai-assistant
        build_rust ngos-settings
        build_iso
        ;;
    test)
        ISO_PATH=$(ls "$BUILD_DIR/iso/ngos-"*".iso" 2>/dev/null | head -1)
        if [[ -z "$ISO_PATH" ]]; then
            build_iso
            ISO_PATH=$(ls "$BUILD_DIR/iso/ngos-"*".iso" 2>/dev/null | head -1)
        fi
        log_yellow "Testing in $TEST_TARGET..."
        if [[ "$TEST_TARGET" == "qemu" ]]; then
            qemu-system-x86_64 -cdrom "$ISO_PATH" -bios OVMF.fd -m 4G -cpu host -enable-kvm -serial stdio -display gtk
        elif [[ "$TEST_TARGET" == "virtualbox" ]]; then
            log_cyan "Import ISO into VirtualBox manually: $ISO_PATH"
        fi
        ;;
esac

log_green "Build completed successfully!"