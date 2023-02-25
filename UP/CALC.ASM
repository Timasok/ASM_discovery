;------------------------------------------------
;Write number in binary
;------------------------------------------------
;Entry:     AX - number
;           DH - x left top coordinate(0-80)
;           DL - y left top coordinate(0-25)
;Exit:      Nothing
;Expects:   ES = 0b800h
;Destroys:  BX, CX
;------------------------------------------------
Write_bin       proc

                push ax                         ; revive cords values
                call Get_Vid_Mem
                pop ax

                mov cl, 15                  ; set counter
                
@@Next:         push ax
                
                shr ax, cl
                and ax, 0001h
                add ax, 00a30h              ; set green ascii code of '0'

                mov word ptr es:[bx], ax
                add bx, 2

                pop ax
                loop @@Next 

                and ax, 0001h
                add ax, 00a30h              ; set green ascii code of '0'

                mov word ptr es:[bx], ax
                add bx, 2

                xor bx, bx

                ret
                endp
;------------------------------------------------

;------------------------------------------------
;Write number in hex
;------------------------------------------------
;Entry:     AX - number
;           DH - x left top coordinate(0-80)
;           DL - y left top coordinate(0-25)
;Exit:      Nothing
;Expects:   ES = 0b800h
;Destroys:  BX, CX, DX
;------------------------------------------------
Write_hex       proc

                push ax                         ; revive cords values
                call Get_Vid_Mem
                pop ax

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
                
                xor bx, bx

                ret
                endp

Hex_val:        db "0123456789ABCDEF"                
;------------------------------------------------

;------------------------------------------------
;Write number in decimal
;------------------------------------------------
;Entry:     AX - number
;           DH - x left top coordinate(0-80)
;           DL - y left top coordinate(0-25)
;Exit:      Nothing
;Expects:   ES = 0b800h
;Destroys:  CX, DX
;------------------------------------------------
Write_dec       proc

                push ax                         ; revive cords values
                call Get_Vid_Mem
                pop ax

                push ax
                mov cx, 0FFFFh          ; add poison to stack's bottom
                push cx

                mov cx, 10d             ; add value that we are going to delete

@@First:        cmp ax, 0
                je @@End_first

                xor dx, dx
                div cx

                push dx

                jmp @@First

@@End_first:    
@@Second:       
                pop dx

                cmp dx, 0FFFFh          ; check if poison
                je @@End_second

                add dx, 00a30h              ; set green ascii code of '0'
                mov word ptr es:[bx], dx
                add bx, 2

                jmp @@Second
@@End_second:

                pop ax
                xor bx, bx

                ret
                endp
;------------------------------------------------

;------------------------------------------------
;Print number from cmd args in different numeral systems
;------------------------------------------------
;Entry:     DH - x0 coordinate(0-80)
;           DL - y0 coordinate(0-25)
;Exit:      None
;Expects:   ES = 0b800h
;           DRAW, READ, WRITE modules should be included
;           Cmd line has 2 arguments!(add assert maybe)
;Destroys:  AX, BX, CX, DX
;------------------------------------------------
Print_num       proc                
                
                push dx                         ; save coordinates

                call My_Atoi

                pop dx
                push dx

                add dx, 0501h                   ; shift dec number start
                call Write_dec  

                pop dx
                push dx

                add dx, 0502h                   ; shift dec number start
                call Write_hex

                pop dx
                push dx

                add dx, 0503h                   ; shift dec number start
                call Write_bin

                xor cx, cx
;=======================krgbiRGB
                mov bh, 00001100b               ; set frame color
                mov ah, 22d                     ; frame width
                mov al, 5d                      ; frame height

                pop dx                  

                call drawFrame

                ret
                endp
;------------------------------------------------