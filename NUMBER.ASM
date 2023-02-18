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

                and ax, 0001h
                add ax, 00a30h              ; set green ascii code of '0'

                mov word ptr es:[bx], ax
                add bx, 2

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

;------------------------------------------------
;Write number in decimal
;------------------------------------------------
;Entry:     AX - number
;           BX - video mem address, to save number
;Exit:      Nothing
;Expects:   ES = 0b800h
;Destroys:  CX, DX
;------------------------------------------------
Write_dec       proc

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
                
                ret
                endp
;------------------------------------------------


;------------------------------------------------
;Check for space
; if (line[0] != ' ') {return;}               
;------------------------------------------------
;Entry:
;Exit:                 
;Expects:   lodsb called previously
;Destroys:  
;------------------------------------------------
CHECK_SPACE     macro
                nop
                cmp al, 20h                         ; if (line[0] != ' ') {return;}
                jne @@Finish
                nop
                endm
;------------------------------------------------

;------------------------------------------------
;MyAtoi
;------------------------------------------------
;Entry:     None
;Exit:      AX = number
;           SI = 0080h                       ; write line address
;Expects:   ES = 0b800h
;           
;Destroys:  AX, BX, CX, DX
;------------------------------------------------
My_Atoi         proc

                mov si, 0080h                       ; write line address
                xor ah, ah
                xor bx, bx
                xor cx, cx

                lodsb

                dec al                              ; don't count last symbol
                mov cl, al                          ; set counter (for first cycle)
                
                lodsb                               ; al = [si++]
                CHECK_SPACE
                ; dec cl
@@Next:
                lodsb

                cmp al, 20h                         ; if (line[0] != ' ') {return;}
                je @@Finish
                
                sub ax, 0030h                       ; num -= '0'
                push ax                             ; save value
                
                mov ax, 10d
                mul bx                              ; count prev value*=10
                mov dx, bx                          
                mov dx, ax                          ; exmp 12 = 10 * 1 + 2 here we have 10*1

                pop ax                              ; revive value
                add dx, ax                          ; here we have 10*1
                mov bx, dx

                loop @@Next

@@Finish:     
                mov ax, bx                          ; save number

                mov byte ptr [si], cl               ; save si ptr

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
;           Cmd line has some arguments
;Destroys:  AX, BX, CX, DX
;------------------------------------------------
Print_num       proc                
                
                call My_Atoi

                push ax
                mov dh, 40                      ; x0
                mov dl, 11                      ; y0
                call Get_Vid_Mem
                pop ax

                call Write_dec  

                push ax
                mov dh, 40                      ; x0
                mov dl, 12                      ; y0
                call Get_Vid_Mem
                pop ax

                call Write_hex

                push ax
                mov dh, 40                      ; x0
                mov dl, 13                      ; y0
                call Get_Vid_Mem
                pop ax

                call Write_bin

                mov bx, 0b800h
                mov es, bx

                xor bx, bx
                xor cx, cx

;=======================krgbiRGB
                mov bh, 00001100b               ; set color

                mov ah, 22d                     ; frame width
                mov al, 5d                     ; frame height
                mov dh, 22                      ; x0
                mov dl, 10                      ; y0

                call drawFrame

                ret
                endp
;------------------------------------------------