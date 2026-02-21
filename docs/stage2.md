# CoolAf Stage 2 Documentation (stage2.asm)

## What is Stage 2?

Stage 2 is the second part of our OS that gets loaded from disk by the bootloader.
- Bootloader (boot.asm) = 512 bytes at 0x7C00
- Stage 2 (stage2.asm) = loaded at 0x9000

```
Memory Map:
┌─────────────────┐ 0x0000
│     Stack       │ (grows down ↓)
├─────────────────┤ 0x7C00
│   Bootloader    │ (512 bytes)
├─────────────────┤ 0x7E00
│      Free       │
├─────────────────┤ 0x9000
│    Stage 2      │ ← We are here!
└─────────────────┘
```

---

## Part 1: Setup

### [BITS 16]
- Still in 16-bit mode (we'll switch to 32-bit later)

### [ORG 0x9000]
- Our code starts at memory address 0x9000
- Why not 0x8000? To avoid conflicts with other code

---

## Part 2: Enable A20 Line

### What is A20?
In old computers, memory was limited to 1MB. The A20 line is the 21st address line that lets us access MORE than 1MB of memory.

```
A20 Disabled:  Can only use 1MB (0x00000 - 0xFFFFF)
A20 Enabled:   Can use 4GB+ (0x00000 - 0xFFFFFFFF)
```

### call enable_a20
- Calls the function that enables A20 line
- Think of it like unlocking extra memory

### enable_a20 function:

1. **in al, 0x92**
   - "in" = read from hardware port
   - Port 0x92 = System Control Port A
   - Reads 8 bits into AL register
   - Like: AL = read_hardware(0x92);

2. **or al, 00000010b**
   - OR operation with binary 00000010 (bit 1 = 1)
   - Sets bit 1 to 1 (enables A20)
   - Other bits stay the same
   ```
   Example:
   AL before: 00000000
   OR with:   00000010
   AL after:  00000010  ← A20 is now ON!
   ```

3. **out 0x92, al**
   - "out" = write to hardware port
   - Writes AL back to port 0x92
   - Like: write_hardware(0x92, AL);
   - A20 line is now enabled!

4. **ret**
   - Return from function
   - Goes back to where we called enable_a20

---

## Part 3: Print Message

### mov ah, 0x0E
- Same as bootloader
- 0x0E = BIOS teletype mode (print characters)

### mov si, message
- SI = pointer to "Stage2 Loaded!" string
- SI holds the memory address

### print loop:

```
Flow Diagram:
┌──────────┐
│  lodsb   │ ← Load byte from [SI] into AL, SI++
└────┬─────┘
     │
┌────▼─────┐
│ cmp al,0 │ ← Is it end of string?
└────┬─────┘
     │
  ┌──▼──┐
  │ Yes │ → je done → Jump to done
  └─────┘
     │ No
     │
┌────▼─────┐
│ int 0x10 │ ← Print character in AL
└────┬─────┘
     │
┌────▼─────┐
│jmp print │ ← Loop back
└──────────┘
```

1. **lodsb** - Load String Byte
   - AL = [SI]
   - SI = SI + 1
   - Gets next character

2. **cmp al, 0** - Compare to 0
   - Strings end with 0 (null terminator)
   - Checks if we're done

3. **je done** - Jump if Equal
   - If AL == 0, we're done printing
   - Jump to "done" label

4. **int 0x10** - BIOS Print
   - Prints character in AL to screen
   - Uses AH (0x0E) for teletype mode

5. **jmp print** - Loop
   - Go back to print next character

---

## Part 4: Infinite Loop

### done:
### jmp $
- $ = current address
- jmp $ = jump to yourself
- Creates infinite loop
- Why? Keeps CPU running, prevents reset

```
Without jmp $:
CPU → runs code → reaches end → ???  → RESET!

With jmp $:
CPU → runs code → jmp $ → jmp $ → jmp $ → (forever)
```

---

## Part 5: Data

### message db "Stage2 Loaded!", 0
- db = Define Byte
- String with null terminator (0)
- This is what we print to screen

---

## Summary: What Stage 2 Does

1. ✅ Enable A20 (unlock more memory)
2. ✅ Print "Stage2 Loaded!" message
3. ✅ Loop forever (stay alive)

## Next Steps (Future):
- Switch to 32-bit protected mode
- Load kernel from disk
- Set up GDT (Global Descriptor Table)
- Enter 64-bit long mode

---

## How Boot Process Works:

```
Step 1: BIOS runs
   ↓
Step 2: BIOS loads boot.asm to 0x7C00
   ↓
Step 3: boot.asm prints "CoolAf v0.1"
   ↓
Step 4: boot.asm reads sector 2 from disk
   ↓
Step 5: boot.asm loads stage2.asm to 0x9000
   ↓
Step 6: boot.asm jumps to 0x9000
   ↓
Step 7: stage2.asm enables A20
   ↓
Step 8: stage2.asm prints "Stage2 Loaded!"
   ↓
Step 9: stage2.asm loops forever (jmp $)
```

---

## Key Differences: Bootloader vs Stage 2

| Feature | Bootloader (boot.asm) | Stage 2 (stage2.asm) |
|---------|----------------------|---------------------|
| Location | 0x7C00 | 0x9000 |
| Size Limit | 512 bytes (strict!) | No limit |
| Loaded By | BIOS | Bootloader |
| Purpose | Load Stage 2 | Enable features, load kernel |
| A20 Line | Not enabled | Enabled! |
