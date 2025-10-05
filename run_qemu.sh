#!/bin/bash

# Run Space Game x64 in QEMU with UEFI

set -e

# Check for required files
if [ ! -f esp.img ]; then
    echo "Error: esp.img not found. Run ./build.sh first"
    exit 1
fi

# Check for QEMU
command -v qemu-system-x86_64 >/dev/null 2>&1 || { echo "qemu-system-x86_64 not found. Install with: apt-get install qemu-system-x86"; exit 1; }

# Find OVMF firmware
OVMF=""
if [ -f /usr/share/ovmf/OVMF.fd ]; then
    OVMF="/usr/share/ovmf/OVMF.fd"
elif [ -f /usr/share/OVMF/OVMF_CODE.fd ]; then
    OVMF="/usr/share/OVMF/OVMF_CODE.fd"
elif [ -f /usr/share/edk2-ovmf/x64/OVMF_CODE.fd ]; then
    OVMF="/usr/share/edk2-ovmf/x64/OVMF_CODE.fd"
else
    echo "Error: OVMF UEFI firmware not found. Install with: apt-get install ovmf"
    exit 1
fi

echo "Starting QEMU with UEFI firmware..."
echo "The game should auto-boot. If it drops to UEFI Shell, type:"
echo "  FS0:"
echo "  \\EFI\\BOOT\\BOOTX64.efi"
echo ""

# Run QEMU
qemu-system-x86_64 \
    -cpu qemu64,+rdrand \
    -bios "$OVMF" \
    -drive file=esp.img,format=raw \
    -m 2048

echo "QEMU exited."
