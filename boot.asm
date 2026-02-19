cli ;Clear interrupt flag // using because we are modifing Stack Pointer manualt not depending on BIOS anymore
xor ax,ax ;setting ax redister to 0 we can use mov ax,0 but xor is much faster 
mov ds, ax ; We set:DS (Data Segment)ES (Extra Segment SS (Stack Segment)To 0.In real mode, memory address = segment * 16 + offset.By setting segments to 0,we simplify addressing.mov es, axmov ss ,ax
mov sp ,0X7C00 ; stack pointer grows downward so it will grow after the 0x7c00
sti; Set interrupt flag we cuse Hardware devices now 
[BITS 16]    ; Becaus cpu starts at 16 bits we need to set this
[ORG 0X7C00]    ;this is the location where first 512 bytes of memory  BIOS loads  

start:
    mov ah, 0x0E ; this is a half part of a registed called AX =[AH][AL] 8x8 bits  and we are putting binaries of 0X0E which is used for printing ah is used here becaus we use int 0x10 that is video services , which seacrhed ah and all the data is stored in last 8 bits which is [AL] 

    mov si, message ; si=Source index registed which works as a pointer to the message , hence stroe memory address of message 

print:
    lodsb ; lodsb a Cpu instruction or we can say a loop it will put the data from source index register to the al one by one AL=[SI] SI++  
    cmp al,0 ; a funmction that compares the 0 to al because the end of the string containes 0 at the end 
    je done ; je done = jump if done if al=0 then move to next code 
    int 0x10  ; this triggers bios video interrupt
    jmp print ;just a loop  until string ends


done:
   xor ax, ax;=0
   mov es, ax ; ES must be set BEFORE setting BX // es=0   es=segment 
   mov bx, 0x8000 ; memory offset ES:BX = 0x0000:0x8000 ; physical = segment * 16 + offset // physical =0 *16 +0x8000  where our stage 0 lives


   mov ah,0x02 ; BIOS function: read sectors
   mov al,1 ; read 1 sector
   mov ch,0 ; cylinder 0
   mov cl,2 ; sector 2 (stage 0 is in sector 2)
   mov dh,0 ; head 0
   mov dl,0x80 ; first hard disk

   int 0x13 ; BIOS disk read
   jc disk_error ; jump if carry flag set (error)

   jmp 0x0000:0x8000 ; jump to loaded stage 2

disk_error:
   mov si, error_msg
   call print_error
   hlt

print_error:
   lodsb
   cmp al,0
   je error_done
   mov ah,0x0E
   int 0x10
   jmp print_error
error_done:
   ret

error_msg db "Disk read error!",0

message db "CoolAf v0.1",0  ; message for printing 
times 510-($-$$) db 0 ; padding 
dw 0xAA55 ; dw=Define word BIOS check last two bytes if they are 0x55 , 0xAA bios will boot it  and x86 is little endian thats why we write 0xAA55 = 55 AA  not 0x55A