# CoolAf OS

A minimal 32-bit operating system written in x86 assembly that boots from scratch and transitions from real mode to protected mode.

## Features

- **Two-stage bootloader**: Boot sector loads stage 2 from disk
- **A20 line enabled**: Access to memory beyond 1MB
- **Protected mode**: Full 32-bit operation with 4GB addressable memory
- **Custom GDT**: Global Descriptor Table with code and data segments
- **VGA text mode**: Direct video memory manipulation for output

## Project Structure

```
CoolAf/
├── boot.asm      # Stage 1: Boot sector (512 bytes)
├── stage2.asm    # Stage 2: Protected mode initialization
└── README.md     # This file
```

## Building

Assemble the bootloader and stage 2:

```bash
nasm -f bin boot.asm -o boot.bin
nasm -f bin stage2.asm -o stage2.bin
```

Create a disk image:

```bash
cat boot.bin stage2.bin > os.img
```

## Running

### With QEMU:
```bash
qemu-system-i386 -drive format=raw,file=os.img
```

### With VirtualBox/VMware:
Convert the raw image to appropriate format and boot from it.

## How It Works

### Stage 1 (boot.asm)
1. BIOS loads first 512 bytes to `0x7C00`
2. Sets up segments and stack
3. Prints boot message using BIOS interrupts
4. Loads stage 2 from disk sector 2 to `0x8000`
5. Jumps to stage 2

### Stage 2 (stage2.asm)
1. Enables A20 line for extended memory access
2. Prints loading message in real mode
3. Sets up Global Descriptor Table (GDT)
4. Switches to 32-bit protected mode
5. Loads segment registers with protected mode selectors
6. Prints welcome message directly to VGA memory

## Memory Map

| Address | Purpose |
|---------|---------|
| `0x0000 - 0x03FF` | Interrupt Vector Table |
| `0x0500 - 0x7BFF` | Free memory |
| `0x7C00 - 0x7DFF` | Boot sector (Stage 1) |
| `0x8000 - 0x8FFF` | Stage 2 code |
| `0x90000` | Stack pointer |
| `0xB8000` | VGA text mode buffer |

## GDT Structure

| Offset | Segment | Description |
|--------|---------|-------------|
| `0x00` | Null | Required null descriptor |
| `0x08` | Code | 32-bit code segment (4GB, executable) |
| `0x10` | Data | 32-bit data segment (4GB, writable) |

## Technical Details

- **Architecture**: x86 (32-bit)
- **Boot method**: Legacy BIOS
- **Assembler**: NASM
- **Video mode**: VGA text mode (80x25)
- **Color scheme**: Bright white on blue (0x1F)

## Requirements

- NASM assembler
- QEMU or other x86 emulator/virtualizer
- Basic understanding of x86 assembly and OS development

## License

Free to use and modify.
