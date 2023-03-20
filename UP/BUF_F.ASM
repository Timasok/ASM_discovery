;------------------------------------------------
;Get video mem address according to cordinates
;------------------------------------------------
;Entry:     DH - x0 coordinate(0-80)
;           DL - y0 coordinate(0-25)
;           DI - relative shift
;Exit:      NEW DX
;Expects:   
;           Screen size is 25/80
;Destroys:  DX
;------------------------------------------------
Set_coords      proc

                push ax cx di  

                push ax cx di                        ; save unchanged coordinates
                call Get_Vid_Mem
                pop di cx ax

                add di, bx                            ; get value

                mov cl, 1d                            ; set 1 bit shift /2^1
                shr di, cl     

                xor dx, dx                            ; count ax /= 80

                mov ax, di                            ; ax = y
                mov cx, 80d                           ; dx = x
                div cx

                mov dh, al                            ; ah = x, al = y
                xchg dh, dl

                add dx, 0101h                         ; to standart view

                pop di cx ax
                ret
                endp
;------------------------------------------------

;------------------------------------------------
;Stabilize_registers es&ds
;------------------------------------------------
;Entry:     None
;Exit:      
;Expects:   Must be used in int handler
;Destroys:  ES, DS ax
;------------------------------------------------
SET_ES_DS              macro
                    nop
                    push bx 
                    mov bx, ds
                    mov es, bx
                    pop bx 
                    nop
                    endm
;------------------------------------------------

;------------------------------------------------
;Sets vid memory ptr to es
;------------------------------------------------
;Entry:     None
;Exit:      es = 0b800h
;Expects:   Nothing
;Destroys:  
;------------------------------------------------
SET_ES_B800     macro
                nop
                push bx
		        mov bx, 0b800h					    ; write video mem address beginning
		        mov es, bx
                pop bx
                nop
                endm
;------------------------------------------------

;------------------------------------------------
;Stabilize_register ds
;------------------------------------------------
;Entry:     None
;Exit:      
;Expects:   Must be used in int handler
;Destroys:  ds ax
;------------------------------------------------
STAB_DS             macro
                    nop
                    ; push si ax
                    ; mov si, offset @@buf_seg 
                    mov ax, cs
                    mov ds, ax
                    ; pop ax si
                    nop
                    endm
;------------------------------------------------

;------------------------------------------------
;Write number in hex(if bx!=0 number is displayed with shift)
;------------------------------------------------
;Entry:     AX - number
;           DH - x left top coordinate(0-80)
;           DL - y left top coordinate(0-25)
;           DI - initial shift in memory
;Exit:      Nothing
;Expects:   ES = segment draw_buf
;Destroys:  
;------------------------------------------------
Write_in_hex    proc

                push bx cx dx

                push ax                         ; revive cords values
                call Get_Vid_Mem
                pop ax                          ; old_bx->cx
                
                add bx, di                      ; count address         

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
;Write string from cmd arg
;------------------------------------------------
;Entry:     p1 - pointer to db with string
;           AH - color
;           DH - x0 coordinate(0-80)
;           DL - y0 coordinate(0-25)
;           DI - initial shift in memory
;Exit:      
;Expects:   db should start with special symbol -
; with code of ffh to save the opportunity to write lines with length up to 255 symbols
;Destroys:  AX, BX, CX
;------------------------------------------------
Write_str_buf       proc
                    push bp
                    mov bp, sp

                    push ax bx cx dx di
                    call Set_coords                         ; get new dx

                    mov si, [bp+4]                          ; get shift
                    call Write_line

                    pop di dx cx bx ax
                    
                    pop bp
                    retn 2
                    endp
;------------------------------------------------

;------------------------------------------------
;Draw rectangle
;------------------------------------------------
;Entry:     DI - area start relative to ds
;           BX - width
;           CX - height
;           DX - start coords
;Exit:      None
;Expects:   
;Destroys:  AX, BX, CX, ES, DI, DX
;------------------------------------------------
Clr_Rect        proc
;=================
    ;                 mov si, offset Buf_seg                ; set vidmem
    ;                 mov ax, [si]
    ;                 mov es, ax
;=================
                    push bx
                    call Get_Vid_Mem
                    add di, bx
                    pop bx

                    mov ax, BL_SPACE                        ; black space

@@First:                                                    ; height
                    push di si cx     

                    mov cx, bx                              ;--------------------

@@Second:                                                   ; width
                    stosw                                   ; ax->es:di
                    loop @@Second                           ;--------------
                    pop cx si di

                    add si, 160d
                    add di, 160d

                    loop @@First

                    ret
                    endp
;------------------------------------------------

;------------------------------------------------
;Save all reg values in draw buffer
;------------------------------------------------
;Entry:    p1-p13 - registers
;          DX - coordinates
;          DI - initial register address
;Exit:     Nothing
;Expects:   
;Destroys:  ax cx di
;------------------------------------------------
Print_regs          proc
                    ; increament sp 4*2
                    push ds es sp bp di si dx cx bx ax
                    SET_ES_B800
                    mov cx, 10d
                    mov dx, 4503h                           ; register
                    mov di, 0

@@Next:
                    SET_ES_B800
                    pop ax                                  ; get current register
                    call Write_in_hex 
                    add dx, 0001h                           ; y++

                    loop @@Next

                    ret
                    endp
;------------------------------------------------
; Print_regs          proc

;                     ; increament sp 4*2
;                     SET_ES_B800
;                     mov bx, sp
;                     mov cx, 10d
;                     mov dx, 1003h                           ; register
;                     mov di, 0
; @@Next: 
;                     mov word ptr ax, ds:[bx]                ; get current register
;                     add bx, 2

;                     call Write_in_hex 
;                     add dx, 0001h                           ; y++

;                     loop @@Next

;                     ret
;                     endp

;                     jmp @@Start_int
; @@Regs:		        db	"~74DS ", 00dh
;                     db	"ES ", 00dh
;                     db	"SP ", 00dh
;                     db	"BP ", 00dh
;                     db	"DI ", 00dh
;                     db	"SI ", 00dh
;                     db	"DX ", 00dh
;                     db	"CX ", 00dh
;                     db	"BX ", 00dh
;                     db	"~74AX ", 00dh        
; @@Start_int:

;------------------------------------------------
;Vidmem_to_save
;------------------------------------------------
;Entry:    DX - coordinates
;          DI - initial register address
;Exit:     Nothing
;Expects:   
;Destroys:  si di cx ax
;------------------------------------------------
Vidmem_to_save      proc  
                    SET_ES_B800                             ; ES = b800 bx = 0
                    xor di, di                              ; DI
                                                            ; DS
                    mov si, offset Save_buf                 ; SI

                    mov cx, 2000d                           ; refresh window
@@Next:             call Movsw_reverse                      ;  es:di-> ax -> ds:si 
                                                            ; todo add special check(use other buffers!)
                    loop @@Next
                    SET_ES_DS                               ; es = ds bx = 0
                    endp
;------------------------------------------------

;------------------------------------------------
;Save_to_vidmem
;------------------------------------------------
;Entry:    DX - coordinates
;          DI - initial register address
;Exit:     Nothing
;Expects:   
;Destroys:  si di cx ax
;------------------------------------------------
Save_to_vidmem      proc
                    SET_ES_B800                             ; ES = b800 bx = 0
                    xor di, di                              ; DI
                                                            ; DS
                    mov si, offset Save_buf                 ; SI

                    mov cx, 2000d                           ; refresh window
@@Next:             movsw                                   ; ds:si -> ax -> es:di 
                                                            ; todo add special check(use other buffers!)
                    loop @@Next
                    SET_ES_DS                               ; es = ds bx = 0   
                    endp
;------------------------------------------------

;------------------------------------------------
;Set_mode key_press
;------------------------------------------------
;Entry:    AH - coordinates
;Exit:     Mode - changes
;          al = 1 elsewise 
;Expects:   
;Destroys:  al si
;------------------------------------------------
Handle_key      proc

                cmp al, 18h                               ; hot key "on" - ctrl+O (->save)
                je @@On

                cmp al, 19h                               ; hot key "off" - ctrl+P(save->vid)
                je @@Off

                jmp @@No_changes

@@On:           mov al, 0FFh	
                jmp @@Finish    

@@Off:          mov al, 00h

@@Finish:       mov si, offset Mode
                mov byte ptr ds:[si], al	            ; set "on" mode

@@No_changes:   ret
                endp
;------------------------------------------------

;------------------------------------------------
;Get registers mode 
;------------------------------------------------
;Entry:    AH - coordinates
;Exit:     AL - mode
;          flags after cmp al, 0ffh(on mode)
;Expects:   
;Destroys:  al si
;------------------------------------------------
Get_mode        proc
                mov si, offset Mode
                lodsb
                cmp al, 0ffh

                ret
                endp
;------------------------------------------------