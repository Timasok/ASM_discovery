;------------------------------------------------
;Exits to DOS
;------------------------------------------------
;Entry:     None
;Exit:      (Not defined)
;Expects:   Nothing
;Destroys:  AX
;------------------------------------------------
EXIT            macro
                nop
                mov ax, 4c00h
                int 21h
                nop
                endm
;------------------------------------------------

;------------------------------------------------
;Clear the screen
;------------------------------------------------
;Entry:     AH - color attr
;           AL - sym
;Exit:      None
;Expects:   ES = 0b800h
;Destroys:  BX, CX
;------------------------------------------------
ClrScr          proc
                xor bx, bx
                mov cx, 80d*25d                 ;symbols in the screen

                mov word ptr es:[bx], ax

@@Next:         mov word ptr es:[bx], ax
                add bx, 2 
                loop @@Next

                ret
                endp
;------------------------------------------------

;------------------------------------------------
;Display symbol, at the following place on the screen
;------------------------------------------------
;Entry:     AH - color attr
;           AL - sym
;           DH - x coordinate(0-80)
;           DL - y coordinate(0-25)
;Exit:      None
;Expects:   ES = 0b800h
;           Screen size is 25/80
;Destroys:  BX, CX, DX
;------------------------------------------------
DispSym         proc


                push ax                         ; save symbol

                sub dx, 0101h                   ; add bit mask to dx       

                xor ax, ax                      ; set ax = 0
                mov al, dl                      ; ax = y

                push dx                         ; save cordinates

                mov cx, 80d                     ; set window width
                mul cx                          ; ax *= 160

                pop dx                          ; revive cordinates

                mov cl, 8d                      ; set 1 byte shift /2^8
                shr dx, cl                      ; dx = x

                add ax, dx                      ; bx += x

                mov cl, 1d                      ; set 1 bit shift *2^1
                shl ax, cl                      ;
                
                mov bx, ax

                pop ax                          ; revive symbol

                mov word ptr es:[bx], ax

                ret
                endp
;------------------------------------------------


;------------------------------------------------
;Draw sequence
;------------------------------------------------
;Entry:     AH - color attr
;           AL - sym
;           DH - x0 coordinate(0-80)
;           DL - y0 coordinate(0-25)
;           BH - k1 (x = k1*cx + x0)
;           BL - k2 (x = k2*cx + y0)
;           CX - counter
;Exit:      None
;Expects:   ES = 0b800h
;           Screen size is 25/80
;Destroys:  CX
;------------------------------------------------
DrawSeq         proc

                push ax
                xor ax, ax

@@Next:
@@Count_x:     ;counting x'

                push cx
                push bx
                push dx

                mov ax, cx          ; x' = counter
                xor cx, cx

                mov cl, 8d 
                shr bx, cl          ; get k1

                mul bx              ; x'' *= k1

                pop dx
                push dx             ; revive dx nipped with mul

                mov cl, 8d 
                shr dx, cl          ; get x0

                add ax, dx          ; x''' += x0

                pop dx
                pop bx
                pop cx

                push ax             ; save x''' to stack
                xor ax, ax

@@Count_y:     ;counting y'
                push cx
                push bx
                push dx

                mov ax, cx          ; y' = counter
                xor cx, cx

                mov cx, 0011h 
                and bx, cx          ; get k2

                mul bx              ; y'' *= k2

                pop dx
                push dx             ; revive dx nipped with mul

                mov cx, 0011h 
                and dx, cx          ; get y0

                add ax, dx          ; y''' += y0

                pop dx
                pop bx
                pop cx

                push ax             ; save y''' to stack
                xor ax, ax

@@Draw_symbol:
                push cx
                
                nop
                xor cx, cx

                mov al, ds:[sp]                 ; MAYBE here 1 and 3     
                mov ah, ds:[sp+2]               ; write new 'x', y' to free reg
                nop

                pop cx                          ; delete from stack 'x'
                pop cx                          ; delete from stack 'y'

                pop cx

                push dx                          ; save x0,y0

                mov dx, ax                      ; set dx to use it DispSym
                mov ax, ds:[sp+2]                  ; get ax

                push cx                         ; save counter
                push bx                         ; save k1, k2
                call DispSym

                pop bx                         ; revive k1, k2
                pop cx                          ; revive counter
                pop dx                         ; revive x0, y0

                loop @@Next

                ret
                endp
;------------------------------------------------


; ;------------------------------------------------
; ;Draw frame
; ;------------------------------------------------
; ;Entry:     AH - frame width
; ;           AL - frame height
; ;           DH - x left top coordinate(0-80)
; ;           DL - y left top coordinate(0-25)
; ;Exit:      None
; ;Expects:   ES = 0b800h
; ;           Screen size is 25/80
; ;Destroys:  
; ;------------------------------------------------
; DrawFrame       proc

                ; pop

                ; mov ah, 0ch
                ; mov al, 0c9h 
;                 push ax
;                 push dx

;                 mov ah, 0ch
;                 mov al, 0c9h 

;                 pop dx
;                 pop ax

;                 mov word ptr es:[bx], ax

;                 ret
;                 endp
; ;------------------------------------------------