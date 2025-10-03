# Space Game for x64
Space Game for x64 is a recreation of Zaxxon for the x86_64 platform as a UEFI image. This project is released as open source under the GPLv3 license. 

### Assemble
Assemble via Microsoft Macro Assembler (set to 64-bit mode)
```
ml64.exe %TARGET%.s /c /Fo space.obj
```
### Link
Link using Microsoft Visual C++ Linker
```
link.exe /nologo /SUBSYSTEM:EFI_APPLICATION /ENTRY:EFI_MAIN /MACHINE:X64 space.obj /OUT:BOOTX64.efi
```

### Running
The compiled BOOTX64.EFI program must be placed in the EFI/BOOT/ directory of an EFI partition on a disk using a GPT. <br>
The program can be run by entering the firmware settings, turning off secure boot, and selecting the disk as the device to boot from. 

## Building on Linux

### Prerequisites
Install the required tools:
```bash
sudo apt-get install asmc-linux qemu-system-x86 ovmf dosfstools
```

### Build
Build the game and create an ESP disk image:
```bash
sudo ./build.sh
```

### Run in QEMU
Launch the game in QEMU with UEFI:
```bash
./run_qemu.sh
```

The game should boot automatically. If you see the UEFI Shell instead, type:
```
FS0:
\EFI\BOOT\BOOTX64.efi
```

## Built in Options
### Hardware upscaling
When hardware upscaling is on, the program will use the application processors of the machine to quickly render the game buffer into the target 1024x1024 buffer. Otherwise if off, the program will simply output the 256x256 buffer to the screen. 
```
UPSCALE_MODE	DQ 00H	;0 FOR MULTI-CORE HARDWARE UPSCALED IMAGE OUTPUT, 1 FOR NO UPSCALING
```
### Hitboxes
Show hitboxes. (Only useful when hardware upscaling is turned on)
```
SHOW_HITBOX		DQ 00H	;1 TO SHOW HIT BOXES
```
### Debug
Show debug information on the console. Control input, column count. 
```
JMP DEBUGSKIP  ;Comment this line to show debug info on the console
```

