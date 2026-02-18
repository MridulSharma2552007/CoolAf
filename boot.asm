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
    hlt ; halt Cpu stops execution 

message db "CoolAf v0.1",0  ; message for printing 
times 510-($-$$) db 0 ; padding 
dw 0xAA55 ; dw=Define word BIOS check last two bytes if they are 0x55 , 0xAA bios will boot it  and x86 is little endian thats why we write 0xAA55 = 55 AA  not 0x55A