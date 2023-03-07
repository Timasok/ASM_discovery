;------------------------------------------------
;Write number in hex
;------------------------------------------------
;Entry:     AX - number
;           DH - x left top coordinate(0-80)
;           DL - y left top coordinate(0-25)
;Exit:      Nothing
;Expects:   ES = 0b800h
;Destroys:  
;------------------------------------------------
Write_in_hex    proc

                push bx cx dx

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

                cmp dx, 000ah 
                jb @@Digit
                jmp @@Symbol

@@Digit:        add dx, 48d
                jmp @@Finish_him
@@Symbol:
                add dx, 55d
                jmp @@Finish_him

@@Finish_him:   
                xor ax, ax
                add ax, dx              
                mov ah, 0ah                     ; set color

                mov word ptr es:[bx], ax
                add bx, 2

                pop ax
                pop cx
                loop @@Next
                
                xor bx, bx

                pop dx cx bx

                ret 
                endp
;------------------------------------------------

;------------------------------------------------
;Draw rectangle
;------------------------------------------------
;Entry:     DI - area start
;           AX - width
;           BX - height
;Exit:      None
;Expects:   ES = 0b800h
;Destroys:  None
;------------------------------------------------
Clr_Rect        proc

                mov cx, bx
                mov bx, 0720h               ; black symbol
@@First:                                    ; height
                push cx                     
                mov cx, ax
@@Second:                                   ; width
                mov word ptr es:[di], bx    

                loop @@Second
                pop cx
        
                loop @@First

                ret
                endp
;------------------------------------------------

;------------------------------------------------
;Print all registers
;------------------------------------------------
;Entry:    
;Exit:      Nothing
;Expects:   
;Destroys: None
;------------------------------------------------
Print_regs          proc
                    pushf
                    push ax bx cx dx                             ; save ax

                    push cs ss es ds es sp bp di si dx cx bx ax

                    mov cx, 13d
                    mov dx, 4503h                           ; set initial cordinates

                    mov bx, 0b800h                          ; set vidmem
                    mov es, bx                              ; set vidmem

@@Next:         
                    pop ax
                    call Write_in_hex                       ; todo add print via buffer  
                    add dx, 0001h

                    loop @@Next

                    pop dx cx bx ax
                    popf

                    ret
                    endp
;------------------------------------------------