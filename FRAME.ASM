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
                mov dh, 80                      ; x = 3
                mov dl, 25                      ; y = 2

                call DispSym

                mov dh, 1
                mov dl, 1
                mov cx, 10
                xor bx, bx

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