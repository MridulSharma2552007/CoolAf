[BITS 16]
[ORG 0x8000]

start:
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

message db "Stage 0 Loaded !",0