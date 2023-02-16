.model tiny
.code
org 100h
locals @@

Start:          jmp Main                        ; write video mem address beginning

INCLUDE FUNCS.ASM

Main:           mov bx, 0b800h
                mov es, bx
                xor bx, bx
                
                ; call ClrScr

                ;-------kRGBirgb********
                mov ax, 1000110000000000b + 14d        ; red node
                ; mov dh, 80
                ; mov dl, 25

                ; call DispSym

                ; mov ax, 4eb1h                   ;add symbol that will paint the screen
                mov dh, 1                       ; x0
                mov dl, 10                      ; y0

                mov bh, 1                       ; k1
                mov bl, 0                       ; k2

                mov cx, 8                      ; counter

                call DrawSeq

                EXIT
end             Start

                ; mov cx, 5
; Step:           push cx
;                 push dx
;                 push ax


;                 pop ax
;                 pop dx
;                 pop cx

;                 inc dh
;                 loop Step