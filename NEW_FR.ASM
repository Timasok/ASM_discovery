.model tiny
.code
org 100h
locals @@

Start:          jmp Main                        ; write video mem address beginning

INCLUDE FUNCS.ASM

Main:           
                push bp                         ; save start of parameters of inner funcs

                mov bx, 0b800h
                mov es, bx

                mov ax, 0720h                   ; space, clear screen  
                call ClrScr

                xor bx, bx
                xor cx, cx

                mov dx, 1408h                   ; p5 throw left top coordinates
                push dx

                mov ax, 0028h                   ; p4 throw frame width
                push ax

                mov ax, 0cbbh                   ; p3 set right top symbol
                push ax

                mov ax, 0ccdh                   ; p2 set middle symbol
                push ax

                mov ax, 0cc9h                   ; p1 set left top symbol
                push ax

                call Draw_stripe

                pop bp

                EXIT
end             Start