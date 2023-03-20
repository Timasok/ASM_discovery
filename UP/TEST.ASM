
.286
.model tiny
.code
org 100h
locals @@

Start:              jmp Main

INCLUDE BASE.ASM
INCLUDE READ.ASM
INCLUDE STRING.ASM
INCLUDE WRITE.ASM
INCLUDE CALC.ASM
INCLUDE DRAW.ASM
INCLUDE CRACK_F.ASM

Main:  

                mov ax, 0aaaah
                mov bx, 0bbbbh
                mov cx, 0cccch
                mov dx, 0ddddh

                mov ah, 0
                int 16h

                EXIT
PASS:
end             Start