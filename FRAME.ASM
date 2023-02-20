.model tiny
.code
org 100h
locals @@

Start:          jmp Main                        ; write video mem address beginning

INCLUDE FUNCS.ASM

Main:           

                mov bx, 0b800h
                mov es, bx

                mov ax, 0720h                  ; space, clear screen  
                call ClrScr

                xor bx, bx
                xor cx, cx

;=======================krgbiRGB
                mov bh, 00001010b               ; set color

                mov ah, 28h                     ; frame width
                mov al, 0ch                     ; frame height
                mov dh, 14h                      ; x0
                mov dl, 8h                       ; y0

                call drawFrame

;=======================krgbiRGB
                mov bh, 00001110b               ; set color

                mov ah, 26h                     ; frame width
                mov al, 0ah                     ; frame height
                mov dh, 21                      ; x0
                mov dl, 9                       ; y0

                call drawFrame

;=======================krgbiRGB
                mov bh, 00001100b               ; set color

                mov ah, 24h                     ; frame width
                mov al, 08h                     ; frame height
                mov dh, 22                      ; x0
                mov dl, 10                      ; y0

                call drawFrame

                EXIT
end             Start