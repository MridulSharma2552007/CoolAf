# CoolAf Kernel Documentation (kernel.c)

## What is the Kernel?

The kernel is the BRAIN of your operating system! It's written in C (not assembly) and runs after stage2 switches to protected mode.

```
Boot Process:
BIOS → Bootloader → Stage2 → Kernel ← YOU ARE HERE!
```

---

## Memory Layout

```
┌─────────────────┐ 0x0000
│     Stack       │
├─────────────────┤ 0x7C00
│   Bootloader    │
├─────────────────┤ 0x8000
│     Kernel      │ ← Loaded here by linker.ld
├─────────────────┤ 0xB8000
│  VGA Text Mem   │ ← Screen memory!
└─────────────────┘
```

---

## Part 1: VGA Text Mode Memory

### What is 0xB8000?

0xB8000 is the VIDEO MEMORY address in text mode. When you write to this address, it appears on screen!

```
Screen = 80 columns × 25 rows = 2000 characters

Each character takes 2 bytes:
┌──────────┬──────────┐
│ Byte 1   │ Byte 2   │
│ ASCII    │ Color    │
└──────────┴──────────┘

Example:
video[0] = 'A'   ← Character
video[1] = 0x1F  ← Color (white on blue)
```

### char* video = (char*)0xB8000;
- Creates a pointer to video memory
- (char*) = cast to character pointer
- Now we can write to screen like an array!

---

## Part 2: The Message

### const char* msg = "Welcome to MridulOS Kernel in C!";
- const = constant (won't change)
- char* = pointer to string
- msg = our message to display

---

## Part 3: The Print Loop

### for (int i = 0; msg[i] != 0; i++)

This loop goes through each character in the message:

```
Loop Flow:
┌─────────────┐
│   i = 0     │ Start
└──────┬──────┘
       │
┌──────▼──────┐
│ msg[i] != 0?│ Is there a character?
└──────┬──────┘
       │ Yes
┌──────▼──────┐
│ Print char  │ video[i*2] = msg[i]
└──────┬──────┘
       │
┌──────▼──────┐
│ Set color   │ video[i*2+1] = 0x1F
└──────┬──────┘
       │
┌──────▼──────┐
│   i++       │ Next character
└──────┬──────┘
       │
       └──────┐ Loop back
              │
       ┌──────▼──────┐
       │ msg[i] == 0?│ End of string?
       └──────┬──────┘
              │ Yes
       ┌──────▼──────┐
       │    DONE     │
       └─────────────┘
```

### video[i * 2] = msg[i];
- Why i * 2? Each character takes 2 bytes!
- Writes the ASCII character to video memory

```
Example: Print "Hi"
i=0: video[0] = 'H'  ← Character
     video[1] = 0x1F ← Color
i=1: video[2] = 'i'  ← Character
     video[3] = 0x1F ← Color
```

### video[i * 2 + 1] = 0x1F;
- Sets the color attribute
- 0x1F = color code

---

## Part 4: Color Codes

### What is 0x1F?

Color byte = [Background][Foreground]

```
0x1F breakdown:
┌────┬────┐
│ 1  │ F  │
└────┴────┘
  │    │
  │    └─ F = White (foreground)
  └────── 1 = Blue (background)

Result: White text on blue background
```

### Color Table:
```
0 = Black      8 = Dark Gray
1 = Blue       9 = Light Blue
2 = Green      A = Light Green
3 = Cyan       B = Light Cyan
4 = Red        C = Light Red
5 = Magenta    D = Light Magenta
6 = Brown      E = Yellow
7 = Light Gray F = White
```

### Examples:
- 0x0F = White on Black (normal)
- 0x1F = White on Blue (your code)
- 0x4E = Yellow on Red (error!)
- 0x2A = Light Green on Green

---

## Part 5: Infinite Loop

### while (1) { }
- Loops forever
- Keeps kernel running
- Without this, CPU would run into random memory!

```
Without while(1):
Kernel → prints message → runs off end → CRASH!

With while(1):
Kernel → prints message → while(1) → while(1) → (forever)
```

---

## How It All Works Together

```
Step 1: kernel_main() starts
   ↓
Step 2: Create pointer to video memory (0xB8000)
   ↓
Step 3: Set message string
   ↓
Step 4: Loop through each character
   ↓
Step 5: Write character to video[i*2]
   ↓
Step 6: Write color to video[i*2+1]
   ↓
Step 7: Repeat for all characters
   ↓
Step 8: Enter infinite loop (stay alive)
```

---

## Linker Script (linker.ld)

### What does linker.ld do?

It tells the compiler WHERE to put your kernel in memory.

### ENTRY(pm_entry)
- Entry point = where kernel starts
- pm_entry = protected mode entry (from stage2)

### . = 0x8000;
- Load kernel at address 0x8000
- This is where stage2 jumps to!

### .text : { *(.text*) }
- .text = code section
- Put all code here

### .data : { *(.data*) }
- .data = initialized data
- Variables with values

### .bss : { *(.bss*) }
- .bss = uninitialized data
- Variables without values

```
Memory Sections:
┌─────────────┐ 0x8000
│   .text     │ ← Your code (kernel_main)
├─────────────┤
│   .data     │ ← Your variables (msg)
├─────────────┤
│   .bss      │ ← Uninitialized stuff
└─────────────┘
```

---

## Building the Kernel

```bash
# Compile C to object file
gcc -m32 -c kernel.c -o kernel.o -ffreestanding

# Link with linker script
ld -m elf_i386 -T linker.ld -o kernel.bin kernel.o

# Add to OS image
cat boot.bin stage2.bin kernel.bin > os.img
```

---

## Key Concepts

### 1. Direct Memory Access
- We write DIRECTLY to video memory
- No printf(), no BIOS, no OS functions
- We ARE the OS!

### 2. Pointers
- video pointer = address 0xB8000
- We can read/write memory directly
- Very powerful, very dangerous!

### 3. Freestanding Environment
- No standard library (no printf, malloc, etc.)
- We build everything from scratch
- That's what OS development is!

---

## Next Steps (Future Features)

- [ ] Keyboard input (read from port 0x60)
- [ ] Interrupt handling (IDT)
- [ ] Memory management (paging)
- [ ] Process scheduling
- [ ] File system
- [ ] System calls

---

## Summary

The kernel:
1. ✅ Runs in protected mode (32-bit)
2. ✅ Writes directly to VGA memory (0xB8000)
3. ✅ Displays colored text on screen
4. ✅ Loops forever to stay alive

This is just the beginning! From here, you can add keyboard input, memory management, and build a full operating system! 🚀
