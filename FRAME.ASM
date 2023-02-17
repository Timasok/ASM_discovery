.model tiny
.code
org 100h
locals @@

Start:          jmp Main                        ; write video mem address beginning

INCLUDE FUNCS.ASM

Main:           mov bx, 0b800h
                mov es, bx
                xor bx, bx
                
                mov ah, 31h                     ; frame width
                mov al, 0ah                     ; frame height
                mov dh, 12                      ; x0
                mov dl, 10                      ; y0

                call drawFrame

                EXIT
end             Start