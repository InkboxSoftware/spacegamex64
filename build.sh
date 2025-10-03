#!/bin/bash

# Build script for Space Game x64 on Linux
# Requires: asmc-linux, binutils, dosfstools

set -e

# Test for root privileges (needed for mounting)
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (sudo ./build.sh)"
    exit 1
fi

echo "=== Building Space Game x64 for UEFI ==="

# Check for required tools
echo "Checking for required tools..."
command -v asmc >/dev/null 2>&1 || { echo "asmc not found. Install with: apt-get install asmc-linux"; exit 1; }
command -v ld >/dev/null 2>&1 || { echo "ld not found. Install with: apt-get install binutils"; exit 1; }
command -v mkfs.vfat >/dev/null 2>&1 || command -v /sbin/mkfs.vfat >/dev/null 2>&1 || { echo "mkfs.vfat not found. Install with: apt-get install dosfstools"; exit 1; }

# Clean previous builds
echo "Cleaning previous builds..."
rm -f space.o BOOTX64.efi esp.img

# Assemble
echo "Assembling space.s..."
asmc -win64 space.s -c -Fo space.o
if [ ! -f space.o ]; then
    echo "Assembly failed!"
    exit 1
fi

# Link as UEFI PE executable
echo "Linking as UEFI executable..."
ld -m i386pep --oformat=pei-x86-64 --subsystem=10 -e EFI_MAIN space.o -o BOOTX64.efi
if [ ! -f BOOTX64.efi ]; then
    echo "Linking failed!"
    exit 1
fi

# Create ESP disk image
echo "Creating ESP disk image..."
dd if=/dev/zero of=esp.img bs=1M count=100 status=none
/sbin/mkfs.vfat -F 32 esp.img >/dev/null 2>&1 || mkfs.vfat -F 32 esp.img >/dev/null 2>&1

# Mount and copy files
echo "Mounting ESP image and copying files..."
mkdir -p esp_mount
mount -o loop esp.img esp_mount
mkdir -p esp_mount/EFI/BOOT
cp BOOTX64.efi esp_mount/EFI/BOOT/
sync
umount esp_mount
rmdir esp_mount

# Fix permissions so user can run QEMU without sudo
chmod 644 esp.img
chown $SUDO_USER:$SUDO_USER esp.img BOOTX64.efi 2>/dev/null || true

echo "=== Build complete! ==="
echo "ESP image created: esp.img"
echo "EFI executable: BOOTX64.efi"
echo "Run with: ./run_qemu.sh"
