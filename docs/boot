# CoolAf Bootloader Documentation (boot.asm)

## Part 1: Setup (Preparing the CPU)

### cli - Clear Interrupts
- Disables hardware interrupts temporarily
- Why? We're manually setting up the stack, don't want interrupts messing it up

### xor ax, ax - Set AX to 0
- Sets AX register to 0
- Why xor instead of "mov ax, 0"? It's faster and smaller in machine code

### mov ds, ax / mov es, ax / mov ss, ax
- Sets Data Segment (DS), Extra Segment (ES), and Stack Segment (SS) to 0
- Why? Simplifies memory addressing. In real mode: physical_address = segment * 16 + offset

### mov sp, 0x7C00 - Set Stack Pointer
- Stack grows DOWNWARD from 0x7C00
- Our bootloader is AT 0x7C00, so stack grows toward 0x0000 (won't overwrite our code)

### sti - Set Interrupts
- Re-enables hardware interrupts
- Now we can use BIOS services again

### [BITS 16] and [ORG 0x7C00]
- BITS 16: CPU starts in 16-bit real mode
- ORG 0x7C00: BIOS loads our bootloader here (first 512 bytes from disk)

---

## Part 2: Print Message

### mov ah, 0x0E
- Sets up BIOS teletype output mode
- AX register = [AH (high 8 bits)][AL (low 8 bits)]
- 0x0E tells BIOS "print character in AL"

### mov si, message
- SI (Source Index) = pointer to our message string
- SI now holds the memory address of "CoolAf v0.1"

### print loop:
1. **lodsb** - Load String Byte
   - Loads byte from [SI] into AL
   - Automatically increments SI (SI++)
   - Like: AL = *SI; SI++;

2. **cmp al, 0** - Compare AL to 0
   - Strings end with null terminator (0)
   - Checks if we reached end of string

3. **je done** - Jump if Equal
   - If AL == 0, jump to "done" label
   - Otherwise, continue to next instruction

4. **int 0x10** - BIOS Video Interrupt
   - Triggers BIOS to print character in AL
   - Uses AH (0x0E) to know what function to perform

5. **jmp print** - Jump back to print
   - Loops until string ends

---

## Part 3: Load Stage 2 from Disk

### xor ax, ax / mov es, ax
- ES (Extra Segment) = 0
- IMPORTANT: Must set ES BEFORE setting BX!

### mov bx, 0x8000
- BX = offset where we'll load stage 2
- Physical address = ES:BX = 0x0000:0x8000 = 0 * 16 + 0x8000 = 0x8000

### Disk Read Parameters (CHS - Cylinder/Head/Sector):
- **mov ah, 0x02** - BIOS function "read sectors"
- **mov al, 1** - Read 1 sector (512 bytes)
- **mov ch, 0** - Cylinder 0
- **mov cl, 2** - Sector 2 (sector 1 is our bootloader, sector 2 is stage 2)
- **mov dh, 0** - Head 0
- **mov dl, 0x80** - Drive 0x80 (first hard disk)

### int 0x13 - BIOS Disk Services
- Reads sector 2 from disk into memory at 0x0000:0x8000
- Sets carry flag if error occurs

### jc disk_error
- Jump if Carry flag is set (disk read failed)
- Shows error message and halts

### jmp 0x0000:0x8000
- Jump to stage 2 code we just loaded
- Format: segment:offset

---

## Part 4: Error Handling

### disk_error:
- Prints "Disk read error!" if sector read fails
- Uses same print logic as main message
- **hlt** - Halts CPU (stops execution)

---

## Part 5: Data and Boot Signature

### message db "CoolAf v0.1", 0
- db = Define Byte
- String with null terminator (0)

### times 510-($-$$) db 0
- Pads bootloader to 510 bytes with zeros
- $ = current position, $$ = start of section

### dw 0xAA55
- dw = Define Word (2 bytes)
- Boot signature: BIOS checks last 2 bytes
- Must be 0x55 0xAA (little-endian, so we write 0xAA55)
- Without this, BIOS won't boot our code!

---

## Memory Layout:
```
0x0000 - 0x7BFF: Stack (grows downward)
0x7C00 - 0x7DFF: Bootloader (512 bytes)
0x8000+        : Stage 2 code (loaded from disk)
```