[BITS 16]
[ORG 0x8000]

start:
call enable_a20
mov ah,0x0E
mov si,message

print:
lodsb
cmp al,0
je done 
int 0x10
jmp print

done:
hlt




enable_a20:
     in al ,0x92 ; in means reads from a input output port of //here it reads form address 0x92 which has 8 bits  
     or al, 00000010b; doins or operation btw al and 1 or we can say btw 0x92 and 1
     out 0x92,al ; set al or results to 0x92 gurrentess that a20 is enabled 
     ret; just a weired thing that keeps cpu in track i mean that it tell the computer taht what is the next thing he should execute

gdt_start:

gdt_null:
     dq 0x0000000000000000; required by intel 
gdt_code:
     dq 0x00CF9A000000FFFF
gdt_data:
     dq 0x00CF92000000FFFF; for read and wqrite
gdt_end:
 
 gdt_descriptor:
     dw gdt_end - gdt_start -1 ; required by intel gdt=24 bits  24-1=23 8x4=24
     dd  gdt_start


message  db "Stage2 Loaded!",0