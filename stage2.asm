[BITS 16]
[ORG 0x8000]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    call enable_a20

    mov ah, 0x0E
    mov si, message

print:
    lodsb
    cmp al, 0
    je switch_to_pm
    int 0x10
    jmp print


; =========================
; SWITCH TO PROTECTED MODE
; =========================

switch_to_pm:
    cli
    lgdt [gdt_descriptor]

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp 0x08:pm_entry   ; FAR jump


; =========================
; A20
; =========================

enable_a20:
    in al, 0x92
    or al, 00000010b
    out 0x92, al
    ret


; =========================
; GDT
; =========================

gdt_start:
gdt_null: dq 0
gdt_code: dq 0x00CF9A000000FFFF
gdt_data: dq 0x00CF92000000FFFF
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start


message db "Stage2 Loaded!", 0


; =========================
; 32 BIT SECTION
; =========================

[BITS 32]

pm_entry:

    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov esp, 0x90000

    ; CLEAR SCREEN FULLY (VERY OBVIOUS)
    mov edi, 0xB8000
    mov ecx, 80*25
    mov ax, 0x1F41    ; 'A' bright white on blue

clear_screen:
    mov [edi], ax
    add edi, 2
    loop clear_screen

hang:
    jmp hang