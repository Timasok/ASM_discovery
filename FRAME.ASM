.model tiny
.code
org 100h
locals @@

Start:          jmp Main                        ; write video mem address beginning

include FUNCS.ASM

Main:           mov bx, 0b800h
                mov es, bx
                
                ;mov ax, 4eb1h                   ;add symbol that will paint the screen
                ;call ClrScr

                ;-------kRGBirgb********
                mov ax, 1000110000000011b       ; red heart
                mov dx, 256*3 + 3        ; x = 3, y = 3
                mov cx, 5

Step:           push cx
                push dx
                push ax

                call DispSym

                pop ax
                pop dx
                pop cx

                inc dh
                loop Step

                EXIT
end             Start
