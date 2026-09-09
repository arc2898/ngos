#!/usr/bin/env pwsh
<#
.SYNOPSIS
    NGOS Build Orchestrator for Windows
#>

param(
    [ValidateSet("clean", "kernel", "userspace", "drivers", "apps", "libs", "iso", "all", "test")]
    [string]$Target = "all",
    
    [ValidateSet("virtualbox", "hardware", "qemu")]
    [string]$TestTarget = "qemu",
    
    [switch]$Release,
    [switch]$Verbose,
    [switch]$NoColor
)

$ErrorActionPreference = "Stop"
$PROJECT_ROOT = Split-Path -Parent $MyInvocation.MyCommand.Definition
$BUILD_DIR = "$PROJECT_ROOT/build"
$TARGET = if ($Release) { "release" } else { "debug" }
$RUST_TOOLCHAIN = "nightly"

function Write-Log { param($Msg, $Color = "Green") 
    if (-not $NoColor) { Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $Msg" -ForegroundColor $Color }
    else { Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $Msg" }
}

function Invoke-Cargo { param($Args)
    $cmd = "cargo +$RUST_TOOLCHAIN $Args"
    Write-Log "Running: $cmd" "Cyan"
    & cargo +$RUST_TOOLCHAIN $Args
    if ($LASTEXITCODE -ne 0) { throw "Cargo command failed: $cmd" }
}

function Build-Kernel {
    Write-Log "Building seL4 kernel..." "Yellow"
    $kernelDir = "$PROJECT_ROOT/kernel/sel4-config"
    if (-not (Test-Path "$kernelDir/build")) { New-Item -ItemType Directory -Path "$kernelDir/build" | Out-Null }
    Set-Location "$kernelDir/build"
    & cmake .. -DCMAKE_BUILD_TYPE=$([System.String]::new($TARGET).ToUpper())
    & cmake --build . --config $([System.String]::new($TARGET).ToUpper()) --parallel
    Write-Log "seL4 kernel built: kernel.elf" "Green"
}

function Build-Rust { param([string]$Package, [string[]]$Features = @())
    $featStr = if ($Features.Count -gt 0) { "--features " + ($Features -join ",") } else { "" }
    $profile = if ($Release) { "--release" } else { "" }
    Invoke-Cargo "build -p $Package $profile $featStr --target x86_64-unknown-none"
}

function Build-ISO {
    Write-Log "Building bootable ISO..." "Yellow"
    Set-Location "$PROJECT_ROOT/../plans/ISO_MAKEFILES"
    if ($IsWindows) { & ".\build_iso.ps1" -Target $TestTarget -BuildType $TARGET }
    else { & "./build_iso.sh" -Target $TestTarget -BuildType $TARGET }
    Write-Log "ISO created in $BUILD_DIR/iso/" "Green"
}

try {
    switch ($Target) {
        "clean" {
            Write-Log "Cleaning build artifacts..." "Yellow"
            Remove-Item -Recurse -Force "$BUILD_DIR" -ErrorAction SilentlyContinue
            Invoke-Cargo "clean"
        }
        "kernel" { Build-Kernel }
        "userspace" {
            Build-Rust "ngos-init"
            Build-Rust "ngos-vfs"
            Build-Rust "ngos-net"
            Build-Rust "ngos-audio"
            Build-Rust "ngos-agent"
            Build-Rust "ngos-compositor"
            Build-Rust "ngos-shell"
            Build-Rust "ngos-services"
        }
        "drivers" {
            Build-Rust "ngos-intel-i915"
            Build-Rust "ngos-ahci"
            Build-Rust "ngos-ext4"
            Build-Rust "ngos-e1000e"
            Build-Rust "ngos-rtl8188eu"
            Build-Rust "ngos-xhci"
            Build-Rust "ngos-hid"
            Build-Rust "ngos-hda"
            Build-Rust "ngos-acpi"
        }
        "apps" {
            Build-Rust "ngos-terminal"
            Build-Rust "ngos-editor"
            Build-Rust "ngos-browser"
            Build-Rust "ngos-ai-assistant"
            Build-Rust "ngos-settings"
        }
        "libs" {
            Build-Rust "ngos-sel4-sys"
            Build-Rust "ngos-capability"
            Build-Rust "ngos-tahoe-ui"
            Build-Rust "ngos-wasm-runtime"
            Build-Rust "ngos-cursor-assets"
        }
        "iso" { Build-ISO }
        "all" {
            Build-Kernel
            Build-Rust "ngos-sel4-sys"
            Build-Rust "ngos-capability"
            Build-Rust "ngos-tahoe-ui"
            Build-Rust "ngos-wasm-runtime"
            Build-Rust "ngos-cursor-assets"
            Build-Rust "ngos-intel-i915"
            Build-Rust "ngos-ahci"
            Build-Rust "ngos-ext4"
            Build-Rust "ngos-e1000e"
            Build-Rust "ngos-rtl8188eu"
            Build-Rust "ngos-xhci"
            Build-Rust "ngos-hid"
            Build-Rust "ngos-hda"
            Build-Rust "ngos-acpi"
            Build-Rust "ngos-init"
            Build-Rust "ngos-vfs"
            Build-Rust "ngos-net"
            Build-Rust "ngos-audio"
            Build-Rust "ngos-agent"
            Build-Rust "ngos-compositor"
            Build-Rust "ngos-shell"
            Build-Rust "ngos-services"
            Build-Rust "ngos-terminal"
            Build-Rust "ngos-editor"
            Build-Rust "ngos-browser"
            Build-Rust "ngos-ai-assistant"
            Build-Rust "ngos-settings"
            Build-ISO
        }
        "test" {
            $isoPath = "$BUILD_DIR/iso/ngos-*.iso"
            if (-not (Test-Path $isoPath)) { Build-ISO }
            Write-Log "Testing in $TestTarget..." "Yellow"
            if ($TestTarget -eq "qemu") {
                & qemu-system-x86_64 -cdrom $isoPath -bios OVMF.fd -m 4G -cpu host -enable-kvm -serial stdio -display gtk
            } elseif ($TestTarget -eq "virtualbox") {
                Write-Log "Import ISO into VirtualBox manually: $isoPath" "Cyan"
            }
        }
    }
    Write-Log "Build completed successfully!" "Green"
}
catch {
    Write-Log "Build failed: $_" "Red"
    exit 1
}