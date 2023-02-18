;------------------------------------------------
;Write number in binary
;------------------------------------------------
;Entry:     AX - number
;           BX - video mem address, to save number
;Exit:      Nothing
;Expects:   ES = 0b800h
;Destroys:  BX, CX
;------------------------------------------------
Write_bin       proc

                mov cl, 15                  ; set counter
                
@@Next:         push ax
                shr ax, cl
                and ax, 0001h
                add ax, 00a30h              ; set green ascii code of '0'

                mov word ptr es:[bx], ax
                add bx, 2

                pop ax
                loop @@Next 

                ret
                endp
;------------------------------------------------


;------------------------------------------------
;Write number in hex
;------------------------------------------------
;Entry:     AX - number
;           BX - video mem address, to save number
;Exit:      Nothing
;Expects:   ES = 0b800h
;Destroys:  BX, CX, DX
;------------------------------------------------
Write_hex       proc

                mov cx, 4                       ; set counter

@@Next:         
                push cx                         ; save counter
                sub cx, 1
                
                push ax                         ; save number 
                mov dx, ax

                mov ax, 4
                mul cx                          ; ax = (cx - 1) * 4 
                mov cx, ax                      ; (ax -> cx and use as a shift)

                pop dx                          ; revive number
                push dx

                shr dx, cl
                and dx, 000Fh                   ; dx = number(current translated half-byte)

                mov cx, offset Hex_val          ; save ptr to db
                add cx, dx

                mov si, cx

                mov ax, [si]                    ; save ascii code
                mov ah, 0ah                     ; set color

                mov word ptr es:[bx], ax
                add bx, 2

                pop ax
                pop cx
                loop @@Next
                
                ret
                endp

Hex_val:        db "0123456789ABCDEF"                
;------------------------------------------------