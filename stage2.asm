[BITS 16]                   ; 16-bit real mode code


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

[BITS 32]
global pm_entry
extern kernel_main   ; Tell assembler this function exists in C

pm_entry:

    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov esp, 0x90000

    call kernel_main   ; Jump into C

hang:
    jmp hang