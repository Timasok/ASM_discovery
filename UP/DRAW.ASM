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
@@Next:         mov es:[bx], ax
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
;Destroys:  BX
;------------------------------------------------
DispSym         proc
                push ax                         ; save symbol

                call Get_Vid_Mem

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
;           BH - frame color 
;Exit:      None
;Expects:   ES = 0b800h
;           Screen size is 25/80
;Destroys:  CX, 
;------------------------------------------------
DrawFrame       proc

@@Main_part:
                PUSH_B_A_D

                mov cx, ax                      ; x = x0
                and cx, 0000h                   ; y = y0
                add dx, cx

                mov ax, 00c9h                   ; draw left top
                add ax, bx

                call DispSym
                POP_D_A_B

                PUSH_B_A_D

                mov cx, ax                      
                and cx, 0FF00h                  ; x = x0 + width - 1
                sub cx, 0100h                   ; y = y0
                add dx, cx
                
                mov ax, 00bbh                   ; draw right top
                add ax, bx

                call DispSym
                POP_D_A_B


                PUSH_B_A_D

                mov cx, ax                      
                and cx, 0FFFFh                  ; x = x0 + width - 1
                sub cx, 0101h                   ; y = y0 + height - 1
                add dx, cx
                
                mov ax, 00bch                   ; draw right bottom
                add ax, bx

                call DispSym
                POP_D_A_B

                PUSH_B_A_D

                mov cx, ax                      
                and cx, 00FFh                   ; x = x0
                sub cx, 0001h                   ; y = y0 + height - 1
                add dx, cx
                
                mov ax, 00c8h                   ; draw left bottom
                add ax, bx

                call DispSym
                POP_D_A_B

                PUSH_B_A_D                         ; draw upper horizontal line
                
                mov bx, 0100h                   ; k1 = 1, k2 = 0

                and ax, 0FF00h                  
                sub ax,  0200h                  ; cx = width - 2

                mov cl, 8d 
                shr ax, cl                      ; shift ax left
                
                mov cx, ax                      ; set counter

                mov si, sp
                mov ax, [si+4]  
                mov al, 0cdh                   ; set symbol

                call DrawLine
                POP_D_A_B
                                                ; draw down horizontal line
                PUSH_B_A_D
                
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

                mov si, sp
                mov ax, [si+4]  
                mov al, 0cdh                   ; set symbol

                call DrawLine
                POP_D_A_B

                                                ; draw left vertical line
                PUSH_B_A_D
                
                mov bx, 0001h                   ; k1 = 0, k2 = 1

                and ax, 00FFh                  
                sub ax, 0002h                   ; cx = height - 2
                
                mov cx, ax                     

                mov si, sp
                mov ax, [si+4]  
                mov al, 0bah                   ; set symbol

                call DrawLine
                POP_D_A_B

                                                ; draw right vertical line
                PUSH_B_A_D

                mov cx, ax                      ; move height and height to draw finally
                and cx, 0FF00h                  ; get heght
                add dx, cx                      
                sub dx, 0100h                   ; x = x0 + width - 1

                mov bx, 0001h                   ; k1 = 0, k2 = 1

                and ax, 00FFh                  
                sub ax, 0002h                   ; cx = height - 2

                mov cx, ax                      
                mov si, sp
                mov ax, [si+4]  
                mov al, 0bah                   ; set symbol

                call DrawLine
                POP_D_A_B

@@Ending:
                ret
                endp
;------------------------------------------------

;------------------------------------------------
;Draw stripe - part of the frame
;------------------------------------------------
;Entry:     p5 - left top coordinates
;           p4 - stripe width not counting borders
;           p3 - right symbol
;           p2 - middle symbol
;           p1 - left symbol
;Exit:      None
;Expects:   ES = 0b800h
;           Screen size is 25/80
;Destroys:  AX, DX 
;------------------------------------------------
Draw_stripe     proc
                push bp
                mov bp, sp

                mov dx, [bp+12]                 ; set coordinates

                mov ax, [bp+4]                  ; push left symbol      
                call DispSym

                push cx
                mov cx, [bp+10]                 ; set counter - p4

                mov ax, [bp+6]                  ; push middle symbol
                add dx, 0100h                   ; inc x coordinate
@@Next:
                push cx

                call DispSym
                add dx, 0100h                   ; inc x coordinate

                pop cx
                loop @@Next
                pop cx

                mov ax, [bp+8]                  ; push right symbol      
                call DispSym

                pop bp
                ret
                endp
;------------------------------------------------

;------------------------------------------------
;Draw frame - director's version
;------------------------------------------------
;Entry:     p15 - left top x coordinate p15 = [bp + (15+1)*2]
;           p14 - left top y coordinate
;           p13 - frame width
;           p12 - frame height
;           p11 - frame color h-byte - Background l-byte - borDer color
;           p10 - frame style (if p10 = 5 custom mode, then p1-p10 fill, otherwise consider them 0)
;           p9  - right  bottom  symbol
;           p8  - middle bottom  symbol
;           p7  - left   bottom  symbol
;           p6  - right  central symbol
;           p5  - middle central symbol
;           p4  - left   central symbol
;           p3  - right  top     symbol
;           p2  - middle top     symbol
;           p1  - left   top     symbol
;Exit:      None
;Expects:   ES = 0b800h
;           Screen size is 25/80
;Destroys:  
;------------------------------------------------
Draw_frame      proc
                push bp
                mov bp, sp

                mov bx, [bp+22]                 ; get frame style - p10

                cmp bx, 5d                      ; if(style == 5)
                je @@Main_body
                ja @@Finish_trans

                cmp bx, 0d                      ; if(style <= 0)
                jbe @@Finish_trans

@@Not_custom_style:                             ; fill parameters p1-p9 from memory

@@Main_body:                    

;======================================== draw upper part

                GLUE_P15_P14
                push dx

                GET_COLOR_P11

                xor ax, ax  
                mov ax, [bp+28]                 ; p13.input -> p4.inner_func throw frame width
                push ax

                mov ax, [bp+8]                  ; p3.input ->  p3.inner_func set right top symbol
                add ax, dx
                push ax

                mov ax, [bp+6]                  ; p2.input ->  p2.inner_func  set middle symbol
                add ax, dx
                push ax

                mov ax, [bp+4]                  ; p1.input - > p1.inner_func set left top symbol
                add ax, dx
                push ax

                call Draw_stripe

;======================================== draw middle part

                mov si, sp

                GET_COLOR_P11
                mov ax, [bp+12]                 ; p5.input ->  p2.inner_func  set middle symbol
                mov ah, bh                      ; set backgroundcolor
                mov word ptr [si+2], ax        

                mov ax, [bp+14]                 ; p6.input ->  p3.inner_func set right top symbol
                mov byte ptr [si+4], al

                mov ax, [bp+10]                 ; p4.input - > p1.inner_func set left top symbol
                mov byte ptr [si], al         

;################################################                
                jmp @@Skip

@@Finish_trans: jmp @@Finish
@@Skip:         
;################################################       
 
                ; mov cx, [bp+26]                 ; p12.input get height
                ; sub cx, 2                       ; get max cx

                mov cx, 3
@@Next:         
                ; mov ax, [bp+26]               ; ax = height-2 (max counter value)
                ; sub ax, 2
                ; sub ax, cx                    ; count shift(ax = cxMax-cx)

                mov dx,[si+8]                   ; get last dx value
                ; add dx, ax                    ; change dx 
                inc dx                          ; rekkurent function    

                mov word ptr [si+8], dx         ; p5.inner_func set left coords symbol

                call Draw_stripe

                loop @@Next

;========================================  draw lower part

                mov si, sp

                GLUE_P15_P14
                
                mov bx, [bp+26]                 ; p12.input get height
                
                sub dx, 0001h           
                add dx, bx                      ; change y = y0 + height -1
                mov word ptr [si+8], dx         ; p5.inner_func set right top symbol coordinates
                                                
                                                ; width stays the same hopefully

                mov ax, [bp+20]                 ; p9.input ->  p3.inner_func set right top symbol
                mov byte ptr [si+4], al

                GET_COLOR_P11
                mov ax, [bp+18]                 ; p8.input ->  p2.inner_func  set middle symbol
                mov ah, dh                      ; change color back! set border color
                mov word ptr [si+2], ax  

                mov ax, [bp+16]                 ; p7.input - > p1.inner_func set left top symbol
                mov byte ptr [si], al                

                call Draw_stripe

;========================================
                pop ax                          ; clean stack
                pop ax
                pop ax
                pop ax
                pop ax

@@Finish:
                pop bp
                ret
                endp
;------------------------------------------------