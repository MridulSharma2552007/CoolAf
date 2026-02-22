[BITS 16]                   ; 16-bit real mode code
[ORG 0x8000]                ; Code loaded at memory address 0x8000

start:
    cli                     ; Disable interrupts during setup
    xor ax, ax              ; Set AX to 0
    mov ds, ax              ; Data segment = 0
    mov es, ax              ; Extra segment = 0
    mov ss, ax              ; Stack segment = 0
    mov sp, 0x7C00          ; Stack pointer at 0x7C00 (grows downward)
    sti                     ; Re-enable interrupts

    call enable_a20         ; Enable A20 line for >1MB memory access

    mov ah, 0x0E            ; BIOS teletype function
    mov si, message         ; Point SI to message string

print:
    lodsb                   ; Load byte from [SI] into AL, increment SI
    cmp al, 0               ; Check if null terminator
    je switch_to_pm         ; If zero, done printing - switch to protected mode
    int 0x10                ; BIOS interrupt to print character in AL
    jmp print               ; Loop to print next character


; =========================
; SWITCH TO PROTECTED MODE
; =========================

switch_to_pm:
    cli                     ; Disable interrupts (required for mode switch)
    lgdt [gdt_descriptor]   ; Load GDT register with our GDT

    mov eax, cr0            ; Read control register CR0
    or eax, 1               ; Set bit 0 (PE = Protection Enable)
    mov cr0, eax            ; Write back to CR0 - now in protected mode!

    jmp 0x08:pm_entry       ; Far jump to flush CPU pipeline
                            ; 0x08 = code segment selector (offset 8 in GDT)


; =========================
; A20
; =========================

enable_a20:
    in al, 0x92             ; Read from Fast A20 port
    or al, 00000010b        ; Set bit 1 (A20 enable bit)
    out 0x92, al            ; Write back to enable A20 line
    ret                     ; Return to caller


; =========================
; GDT (Global Descriptor Table)
; =========================

gdt_start:
gdt_null: dq 0                      ; Null descriptor (required, unused)
gdt_code: dq 0x00CF9A000000FFFF     ; Code segment: base=0, limit=4GB, executable, readable
                                    ; Flags: 32-bit, 4KB granularity
gdt_data: dq 0x00CF92000000FFFF     ; Data segment: base=0, limit=4GB, writable
                                    ; Flags: 32-bit, 4KB granularity
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1      ; Size of GDT - 1 (limit)
    dd gdt_start                    ; Base address of GDT (0x8000 + offset)


message db "Stage2 Loaded!", 0


; =========================
; 32 BIT SECTION
; =========================
[BITS 32]                   ; Now in 32-bit protected mode

pm_entry:

    mov ax, 0x10            ; 0x10 = data segment selector (offset 16 in GDT)
    mov ds, ax              ; Set data segment register
    mov es, ax              ; Set extra segment register
    mov ss, ax              ; Set stack segment register

    mov esp, 0x90000        ; Set stack pointer to 0x90000 (safe memory area)

    mov dword [cursor_pos], 0   ; Initialize cursor position to 0 (top-left)
    mov esi, msg32          ; Point ESI to 32-bit message string
    call print32            ; Call 32-bit print function
    jmp hang                ; Jump to infinite loop


print32:
    mov edi, 0xB8000        ; EDI = VGA text buffer start address

.next_char:
    lodsb                   ; Load byte from [ESI] into AL, increment ESI
    cmp al, 0               ; Check if null terminator (end of string)
    je .done                ; If zero, we're done printing

    cmp al, 10              ; Check if newline character (ASCII 10)
    je .newline             ; If newline, handle it separately

    mov ebx, [cursor_pos]   ; Load current cursor position into EBX
    mov [edi + ebx], al     ; Write character to video memory at cursor position
    mov byte [edi + ebx + 1], 0x1F  ; Write color attribute (bright white on blue)

    add dword [cursor_pos], 2   ; Move cursor forward by 2 bytes (char + color)
    jmp .next_char          ; Process next character

.newline:
    mov eax, [cursor_pos]   ; Load current cursor position
    mov ecx, 160            ; 160 bytes per row (80 chars × 2 bytes each)
    xor edx, edx            ; Clear EDX for division
    div ecx                 ; EAX = current row number, EDX = offset in row
    inc eax                 ; Move to next row
    mul ecx                 ; EAX = byte offset of next row start
    mov [cursor_pos], eax   ; Update cursor position to start of next row
    jmp .next_char          ; Continue processing characters

.done:
    ret                     ; Return to caller


hang:
    jmp hang                ; Infinite loop - halt CPU execution


msg32 db "Welcome to CoolAFOS in 32-bit Protected Mode!", 0  ; Null-terminated string
cursor_pos dd 0             ; Double word (4 bytes) to store cursor position