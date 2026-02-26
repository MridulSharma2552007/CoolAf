# CoolAf OS - Project Structure

```
CoolAf/
│
├── boot.asm              # Stage 1: Bootloader (512 bytes)
├── stage2.asm            # Stage 2: A20 enable, protected mode prep
├── kernel.c              # Kernel: Main OS code in C
├── linker.ld             # Linker script: Memory layout
│
├── boot.bin              # Compiled bootloader
├── stage2.bin            # Compiled stage 2
├── kernel.bin            # Compiled kernel
├── os.img                # Final bootable image
│
├── docs/                 # Documentation
│   ├── boot.md           # Bootloader documentation
│   ├── stage2.md         # Stage 2 documentation
│   ├── kernel.md         # Kernel documentation
│   └── wiki.md           # This file + wiki
│
└── README.md             # Main project README
```

---

## File Descriptions

### Source Files

**boot.asm** (Stage 1 Bootloader)
- First 512 bytes loaded by BIOS
- Located at 0x7C00
- Prints boot message
- Loads stage2 from disk sector 2
- Jumps to stage2

**stage2.asm** (Stage 2 Loader)
- Loaded at 0x9000 by bootloader
- Enables A20 line (access >1MB memory)
- Prints "Stage2 Loaded!"
- Prepares for protected mode
- (Future: switches to 32-bit and loads kernel)

**kernel.c** (Kernel)
- Main OS code written in C
- Loaded at 0x8000
- Writes directly to VGA memory (0xB8000)
- Displays colored text
- Runs in protected mode

**linker.ld** (Linker Script)
- Tells compiler where to place kernel in memory
- Sets entry point
- Organizes .text, .data, .bss sections

---

## Binary Files

**boot.bin**
- Assembled from boot.asm
- Exactly 512 bytes
- Must end with 0xAA55 signature

**stage2.bin**
- Assembled from stage2.asm
- Variable size
- Loaded to memory by bootloader

**kernel.bin**
- Compiled from kernel.c
- Linked with linker.ld
- Contains executable kernel code

**os.img**
- Final bootable disk image
- Created by: `cat boot.bin stage2.bin kernel.bin > os.img`
- Can be booted in QEMU or real hardware

---

## Documentation Files

**docs/boot.md**
- Explains bootloader code
- Memory setup, printing, disk reading
- Error handling

**docs/stage2.md**
- Explains stage 2 code
- A20 line enabling
- Protected mode preparation

**docs/kernel.md**
- Explains kernel code
- VGA text mode
- Color codes
- C programming in kernel

**docs/wiki.md**
- Project overview
- Build instructions
- Troubleshooting

---

## Memory Map

```
Address Range    | Purpose
-----------------|----------------------------------
0x0000 - 0x7BFF  | Stack (grows downward)
0x7C00 - 0x7DFF  | Bootloader (boot.asm)
0x7E00 - 0x8FFF  | Free space
0x9000 - 0x9FFF  | Stage 2 (stage2.asm)
0xA000 - 0xAFFFF | Free space
0xB8000          | VGA text mode video memory
```

---

## Boot Flow

```
1. BIOS
   ↓
2. boot.asm (0x7C00)
   - Print "CoolAf v0.1"
   - Load sector 2
   ↓
3. stage2.asm (0x9000)
   - Enable A20
   - Print "Stage2 Loaded!"
   ↓
4. kernel.c (0x8000)
   - Print to VGA memory
   - Run OS
```

---

## Build Process

```
Assembly → Binary:
nasm -f bin boot.asm -o boot.bin
nasm -f bin stage2.asm -o stage2.bin

C → Object → Binary:
gcc -m32 -c kernel.c -o kernel.o -ffreestanding
ld -m elf_i386 -T linker.ld -o kernel.bin kernel.o

Combine:
cat boot.bin stage2.bin kernel.bin > os.img

Run:
qemu-system-i386 -drive format=raw,file=os.img
```

---

## Dependencies

- **NASM**: Assembler for .asm files
- **GCC**: C compiler (with 32-bit support)
- **LD**: Linker
- **QEMU**: Emulator for testing
- **Make**: (Optional) Build automation

---

## Quick Start

```bash
# Clone repository
git clone <your-repo>
cd CoolAf

# Build everything
nasm -f bin boot.asm -o boot.bin
nasm -f bin stage2.asm -o stage2.bin
cat boot.bin stage2.bin > os.img

# Run in QEMU
qemu-system-i386 -drive format=raw,file=os.img
```

---

## Future Structure (Planned)

```
CoolAf/
├── boot/
│   ├── boot.asm
│   └── stage2.asm
├── kernel/
│   ├── kernel.c
│   ├── vga.c
│   ├── keyboard.c
│   └── interrupts.c
├── drivers/
│   ├── disk.c
│   └── timer.c
├── lib/
│   ├── string.c
│   └── memory.c
├── include/
│   └── *.h
├── build/
│   └── *.bin, *.o
└── docs/
    └── *.md
```
