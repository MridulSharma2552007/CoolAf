# CoolAf OS - Wiki

Welcome to the CoolAf OS Wiki! This is your complete guide to understanding and building this operating system from scratch.

---

## Table of Contents

1. [What is CoolAf OS?](#what-is-coolaf-os)
2. [Getting Started](#getting-started)
3. [Architecture Overview](#architecture-overview)
4. [Build Instructions](#build-instructions)
5. [Running the OS](#running-the-os)
6. [Troubleshooting](#troubleshooting)
7. [Learning Resources](#learning-resources)
8. [Contributing](#contributing)

---

## What is CoolAf OS?

CoolAf OS is a minimal 32-bit operating system written from scratch in x86 assembly and C. It boots directly from BIOS and demonstrates fundamental OS concepts.

### Features
- ✅ Two-stage bootloader
- ✅ A20 line enabled (access >1MB memory)
- ✅ Real mode to protected mode transition
- ✅ VGA text mode output
- ✅ Written in Assembly + C

### What You'll Learn
- How computers boot
- x86 assembly programming
- Memory management basics
- Hardware interaction
- OS development fundamentals

---

## Getting Started

### Prerequisites

**Required Tools:**
```bash
# Ubuntu/Debian
sudo apt install nasm gcc qemu-system-x86

# Arch Linux
sudo pacman -S nasm gcc qemu

# macOS
brew install nasm gcc qemu
```

**Knowledge Requirements:**
- Basic programming (C or any language)
- Understanding of hexadecimal numbers
- Willingness to learn assembly!

### Quick Start

```bash
# 1. Clone the repository
git clone <your-repo-url>
cd CoolAf

# 2. Build the OS
nasm -f bin boot.asm -o boot.bin
nasm -f bin stage2.asm -o stage2.bin
cat boot.bin stage2.bin > os.img

# 3. Run it!
qemu-system-i386 -drive format=raw,file=os.img
```

You should see:
```
CoolAf v0.1
Stage2 Loaded!
```

---

## Architecture Overview

### Boot Process

```
┌──────────┐
│   BIOS   │ Power on, hardware init
└────┬─────┘
     │
     ▼
┌──────────────────┐
│  Bootloader      │ Load from disk sector 1
│  (boot.asm)      │ Located at 0x7C00
│  512 bytes       │ Print message, load stage2
└────┬─────────────┘
     │
     ▼
┌──────────────────┐
│  Stage 2         │ Load from disk sector 2
│  (stage2.asm)    │ Located at 0x9000
│  Variable size   │ Enable A20, prepare protected mode
└────┬─────────────┘
     │
     ▼
┌──────────────────┐
│  Kernel          │ Load from disk sector 3+
│  (kernel.c)      │ Located at 0x8000
│  Variable size   │ Main OS code
└──────────────────┘
```

### Memory Layout

```
┌─────────────────────┐ 0x00000000
│  Interrupt Vector   │
│  Table (IVT)        │
├─────────────────────┤ 0x00000500
│  BIOS Data Area     │
├─────────────────────┤ 0x00007C00
│  Bootloader         │ ← boot.asm (512 bytes)
├─────────────────────┤ 0x00007E00
│  Free Space         │
├─────────────────────┤ 0x00009000
│  Stage 2            │ ← stage2.asm
├─────────────────────┤ 0x0000A000
│  Free Space         │
├─────────────────────┤ 0x000B8000
│  VGA Text Memory    │ ← Screen output
├─────────────────────┤ 0x000C0000
│  BIOS ROM           │
└─────────────────────┘ 0xFFFFFFFF
```

### Component Roles

| Component | Language | Size | Purpose |
|-----------|----------|------|---------|
| boot.asm | Assembly | 512B | Load stage2, print message |
| stage2.asm | Assembly | ~40B | Enable A20, prepare for kernel |
| kernel.c | C | Variable | Main OS functionality |

---

## Build Instructions

### Method 1: Manual Build

```bash
# Step 1: Assemble bootloader
nasm -f bin boot.asm -o boot.bin

# Step 2: Assemble stage 2
nasm -f bin stage2.asm -o stage2.bin

# Step 3: Compile kernel (if you have one)
gcc -m32 -c kernel.c -o kernel.o -ffreestanding
ld -m elf_i386 -T linker.ld -o kernel.bin kernel.o

# Step 4: Create disk image
cat boot.bin stage2.bin kernel.bin > os.img

# Step 5: Run
qemu-system-i386 -drive format=raw,file=os.img
```

### Method 2: Using Makefile (Recommended)

Create a `Makefile`:
```makefile
all: os.img

boot.bin: boot.asm
	nasm -f bin boot.asm -o boot.bin

stage2.bin: stage2.asm
	nasm -f bin stage2.asm -o stage2.bin

kernel.bin: kernel.c linker.ld
	gcc -m32 -c kernel.c -o kernel.o -ffreestanding
	ld -m elf_i386 -T linker.ld -o kernel.bin kernel.o

os.img: boot.bin stage2.bin kernel.bin
	cat boot.bin stage2.bin kernel.bin > os.img

run: os.img
	qemu-system-i386 -drive format=raw,file=os.img

clean:
	rm -f *.bin *.o os.img
```

Then just run:
```bash
make        # Build
make run    # Build and run
make clean  # Clean up
```

---

## Running the OS

### QEMU (Emulator)

**Basic:**
```bash
qemu-system-i386 -drive format=raw,file=os.img
```

**With debugging:**
```bash
qemu-system-i386 -drive format=raw,file=os.img -monitor stdio
```

**With serial output:**
```bash
qemu-system-i386 -drive format=raw,file=os.img -serial stdio
```

### VirtualBox

1. Create new VM (Type: Other, Version: Other/Unknown)
2. Set memory to 32MB
3. Don't add virtual hard disk
4. Settings → Storage → Add Floppy Controller
5. Add os.img as floppy disk
6. Boot!

### Real Hardware (Advanced)

```bash
# Write to USB drive (BE CAREFUL!)
sudo dd if=os.img of=/dev/sdX bs=512

# Or write to floppy
sudo dd if=os.img of=/dev/fd0 bs=512
```

⚠️ **WARNING**: Double-check device name! Wrong device = data loss!

---

## Troubleshooting

### Problem: "Disk read error!"

**Cause:** Stage2 not found on disk

**Solution:**
```bash
# Make sure you're combining files correctly
cat boot.bin stage2.bin > os.img

# Check file sizes
ls -l boot.bin stage2.bin os.img
# boot.bin should be 512 bytes
# os.img should be boot.bin + stage2.bin size
```

### Problem: Screen refreshes/resets

**Cause:** CPU halts or crashes

**Solution:**
- Replace `hlt` with `jmp $` (infinite loop)
- Check memory addresses don't overlap
- Verify stage2 ORG matches boot.asm jump address

### Problem: Nothing appears on screen

**Cause:** Wrong memory address or mode

**Solution:**
- Verify VGA address is 0xB8000
- Check you're in text mode
- Make sure interrupts are enabled for BIOS calls

### Problem: QEMU won't start

**Cause:** Missing or wrong file

**Solution:**
```bash
# Check file exists
ls -l os.img

# Check it's not empty
file os.img

# Try with full path
qemu-system-i386 -drive format=raw,file=$(pwd)/os.img
```

### Problem: "Invalid opcode" or crash

**Cause:** Wrong ORG address or corrupted binary

**Solution:**
- Verify ORG in stage2.asm matches jump in boot.asm
- Rebuild everything from scratch
- Check for assembly syntax errors

---

## Learning Resources

### Official Documentation
- [OSDev Wiki](https://wiki.osdev.org/) - Best OS dev resource
- [Intel x86 Manual](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html) - CPU reference
- [NASM Documentation](https://www.nasm.us/docs.php) - Assembler manual

### Tutorials
- [Writing a Simple Operating System from Scratch](https://www.cs.bham.ac.uk/~exr/lectures/opsys/10_11/lectures/os-dev.pdf) - Great PDF guide
- [Bran's Kernel Development](http://www.osdever.net/bkerndev/Docs/intro.htm) - Classic tutorial
- [JamesM's Kernel Tutorial](https://web.archive.org/web/20160326062442/http://jamesmolloy.co.uk/tutorial_html/index.html) - Detailed walkthrough

### Books
- "Operating Systems: From 0 to 1" by Tu, Do Hoang
- "Operating System Concepts" by Silberschatz
- "Modern Operating Systems" by Tanenbaum

### Videos
- [Write Your Own Operating System](https://www.youtube.com/playlist?list=PLHh55M_Kq4OApWScZyPl5HhgsTJS9MZ6M) - YouTube series
- [Making an OS](https://www.youtube.com/watch?v=MwPjvJ9ulSc) - Ben Eater

---

## Contributing

### How to Contribute

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly in QEMU
5. Submit a pull request

### Code Style

**Assembly:**
- Use lowercase for instructions
- Comment every non-obvious line
- Align comments at column 40

**C:**
- K&R style bracing
- 4-space indentation
- Descriptive variable names

### Areas for Contribution

- [ ] Keyboard input driver
- [ ] Interrupt handling (IDT)
- [ ] Memory management
- [ ] File system
- [ ] Shell/command line
- [ ] More documentation
- [ ] Bug fixes

---

## FAQ

**Q: Why is it called CoolAf?**
A: Because building an OS from scratch is cool as f***!

**Q: Can I use this for real work?**
A: No! This is educational. Use Linux/Windows for real work.

**Q: How big can the OS get?**
A: Limited only by disk size and your ambition!

**Q: Do I need to know assembly?**
A: Basic knowledge helps, but you can learn as you go!

**Q: Can I boot this on my laptop?**
A: Yes, but be careful! Use a USB drive, not your main disk.

**Q: Why 32-bit and not 64-bit?**
A: 32-bit is simpler to learn. You can upgrade to 64-bit later!

---

## Project Status

### Current Features
- ✅ Bootloader
- ✅ Stage 2 loader
- ✅ A20 line enabled
- ✅ VGA text output
- ✅ Basic kernel in C

### Planned Features
- ⏳ Protected mode switch
- ⏳ Keyboard input
- ⏳ Interrupt handling
- ⏳ Memory management
- ⏳ Multitasking
- ⏳ File system

### Version History
- **v0.1** - Initial bootloader + stage2
- **v0.2** - (Planned) Protected mode + kernel

---

## License

Free to use, modify, and learn from. No warranty provided.

---

## Credits

Created by learning from:
- OSDev Wiki community
- Various OS development tutorials
- Trial, error, and lots of debugging!

---

## Contact

Questions? Issues? Ideas?
- Open an issue on GitHub
- Check the docs/ folder
- Read the OSDev Wiki

Happy OS development! 🚀
