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
;Get video mem address according to cordinates
;------------------------------------------------
;Entry:     DH - x0 coordinate(0-80)
;           DL - y0 coordinate(0-25)
;Exit:      BX - address in RAM
;Expects:   
;           Screen size is 25/80
;Destroys:  AX, CX
;------------------------------------------------
GetVidMem       proc

                sub dx, 0101h                   ; x-=1, y-=1       

                xor ax, ax                      ; set ax = 0
                mov al, dl                      ; ax = y

                push dx                         ; save cordinates

                mov cx, 80d                     ; set window width
                mul cx                          ; ax *= 80

                pop dx                          ; revive cordinates

                mov cl, 8d                      ; set 1 byte shift /2^8
                shr dx, cl                      ; dx = x

                add ax, dx                      ; bx += x

                mov cl, 1d                      ; set 1 bit shift *2^1
                shl ax, cl                      ;
                
                mov bx, ax

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
;Destroys:  BX, CX
;------------------------------------------------
DispSym         proc


                push ax                         ; save symbol

                call GetVidMem

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
DrawLine        proc

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

                mov cx, 00FFh 
                and bx, cx          ; get k2

                mul bx              ; y'' *= k2

                pop dx
                push dx             ; revive dx nipped with mul

                mov cx, 00FFh 
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

                mov si, sp

                mov al, [si+2]                     ;
                mov ah, [si+4]                   ; write new 'x', y' to free reg
                nop

                pop cx

                push dx                          ; save x0,y0

                mov si, sp

                mov dx, ax                      ; set dx to use it DispSym

                mov ax, [si+6]                  ; get ax

                push cx                         ; save counter
                push bx                         ; save k1, k2
                call DispSym

                pop bx                         ; revive k1, k2
                pop cx                         ; revive counter
                pop dx                         ; revive x0, y0

                add sp, 4                      ; delete from stack 'x', 'y' and ax value

                loop @@Next

                pop ax

                ret
                endp
;------------------------------------------------

;------------------------------------------------
;Draw frame
;------------------------------------------------
;Entry:     AH - frame width
;           AL - frame height
;           DH - x left top coordinate(0-80)
;           DL - y left top coordinate(0-25)
;Exit:      None
;Expects:   ES = 0b800h
;           Screen size is 25/80
;Destroys:  
;------------------------------------------------
DrawFrame       proc

                push ax

                mov ax, 0720h                  ; space, clear screen  
                call ClrScr

                xor ax, ax

                pop ax
                push ax
                push dx

                mov cx, ax                      ; x = x0
                and cx, 0000h                   ; y = y0
                add dx, cx

                
                mov ax, 0Fc9h                   ; draw left top

                call DispSym
                pop dx
                pop ax


                push ax
                push dx

                mov cx, ax                      
                and cx, 0FF00h                  ; x = x0 + width - 1
                sub cx, 0100h                   ; y = y0
                add dx, cx
                
                mov ax, 0Fbbh                   ; draw right top

                call DispSym
                pop dx
                pop ax

                push ax
                push dx

                mov cx, ax                      
                and cx, 0FFFFh                  ; x = x0 + width - 1
                sub cx, 0101h                   ; y = y0 + height - 1
                add dx, cx
                
                mov ax, 0Fbch                   ; draw right bottom

                call DispSym

                pop dx
                pop ax

                push ax
                push dx

                mov cx, ax                      
                and cx, 00FFh                   ; x = x0
                sub cx, 0001h                   ; y = y0 + height - 1
                add dx, cx
                
                mov ax, 0Fc8h                   ; draw left bottom

                call DispSym
                pop dx
                pop ax

;================================================

                push ax                         ; draw upper horizontal line
                push dx
                
                mov bx, 0100h                   ; k1 = 1, k2 = 0

                and ax, 0FF00h                  
                sub ax,  0200h                  ; cx = width - 2

                mov cl, 8d 
                shr ax, cl                      ; shift ax left
                
                mov cx, ax                      ; set counter

                mov ax, 0Fcdh                   ; set symbol

                call DrawLine

                pop dx
                pop ax

                push ax                         ; draw upper horizontal line
                push dx
                
                mov cx, ax                      ; move width and height to draw finally
                and cx, 00FFh                   ; get height
                add dx, cx                      
                sub dx, 0001h                   ; y = y0 + height - 1

                mov bx, 0100h                   ; k1 = 1, k2 = 0

                and ax, 0FF00h                  
                sub ax,  0200h                  ; cx = width - 2

                mov cl, 8d 
                shr ax, cl                      ; shift ax left
                
                mov cx, ax                      ; set counter

                mov ax, 0Fcdh                   ; set symbol

                call DrawLine

                pop dx
                pop ax

;================================================

                push ax                         ; draw left vertical line
                push dx
                
                mov bx, 0001h                   ; k1 = 0, k2 = 1

                and ax, 00FFh                  
                sub ax, 0002h                   ; cx = height - 2
                
                mov cx, ax                     

                mov ax, 0Fbah

                call DrawLine

                pop dx
                pop ax

                push ax                         ; draw right vertical line
                push dx
                
                mov cx, ax                      ; move height and height to draw finally
                and cx, 0FF00h                  ; get heght
                add dx, cx                      
                sub dx, 0100h                   ; x = x0 + width - 1

                mov bx, 0001h                   ; k1 = 0, k2 = 1

                and ax, 00FFh                  
                sub ax, 0002h                   ; cx = height - 2

                mov cx, ax                      

                mov ax, 0Fbah

                call DrawLine

                pop dx
                pop ax

                ret
                endp
;------------------------------------------------

                ; ;-------kRGBirgb********
                ; mov ax, 1000110000000000b + 14d        ; red node
                ; ; mov dh, 80
                ; ; mov dl, 25

                ; ; call DispSym

                ; ; mov ax, 4eb1h                   ;add symbol that will paint the screen
                ; mov dh, 1                       ; x0
                ; mov dl, 10                      ; y0

                ; mov bh, 1                       ; k1
                ; mov bl, 0                       ; k2

                ; mov cx, 8                      ; counter

                ; call DrawLine


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
