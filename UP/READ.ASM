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
;Exit if any key was pressed
;------------------------------------------------
;Entry:     None
;Exit:      None
;Expects:   eternal loop is on
;Destroys:  AX
;------------------------------------------------
KEY_EXIT    macro
		    nop
            mov ah, 01h						; finish program by pressing a key
		    int 16h
		    cmp al, 0
		    jmp 0
            nop
            endm
;------------------------------------------------

;------------------------------------------------
;Sets si to cmd line args beginning
;------------------------------------------------
;Entry:     None
;Exit:      SI = 0b800h
;Expects:   Nothing
;Destroys:  BX, SI
;------------------------------------------------
SET_CMD_ARG     macro
                nop
		        mov bx, 0080h					    ; write video mem address beginning
		        mov si, bx
                xor bx, bx
                nop
                endm
;------------------------------------------------

;------------------------------------------------
;Get width and height according to string
;------------------------------------------------
;Entry:     cmd arg with line
;Exit:      AX - optimal width
;           BX - optimal height
;Expects:   SI is set
;           STRING MODULE ADDED!
;Destroys:  AX, BX, CX, DX, DI
;------------------------------------------------
Get_str_params  proc
                push si
                              
                ; inc si                ; inc si if needed                 

                mov dx, '&'
                mov ax, 1h              ; set initial height of the line
                mov bx, 1h              ; set initial width(maximum width)
@@Next:         
                mov di, si              ; di = line start

                push cx
                push bx
                push ax

                push si
                xor bx, bx
                call Check_NULL
                cmp bx, 1
                je @@End                ; if reached '\0' finish

                push si                 ; push current si
                push dx                 ; push '\n'
                call strchr

                pop ax
                pop bx
                pop cx

                cmp si, 0h              ; if( no ch == '\n') break;
                je @@End
                
                inc ax                  ; inc height
                mov cx, si
                sub cx, di              ; cx = current length

                cmp cx, bx              ; if(cur_len>max_len)
                ja @@Change_width       ;   max_len = cur_len;
                jmp @@Next

@@Change_width: mov bx, cx
                jmp @@Next

@@End:          add ax, 2               ; add border thickness to width and height
                add bx, 2
                pop si
                ret
                endp
;------------------------------------------------

;------------------------------------------------
;MyAtoi
;------------------------------------------------
;Entry:     None
;Exit:      AX = number
;Expects:   SI = 0080h                       ; write line address
;Destroys:  AX, BX, DX
;------------------------------------------------
My_Atoi         proc
                push cx

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
                sub si, 2
                mov byte ptr [si], cl               ; save si ptr


                pop cx
                ret
                endp
;------------------------------------------------

;------------------------------------------------
;Read N arguments from cmd line
;------------------------------------------------
;Entry:     CX = number of arguments
;Exit:      None
;Expects:   None
;           SI = 0080h                       
; write line address(only decimal numbers) and push them to stack
;Destroys:  AX, BX, CX, DX, BP, SI
;------------------------------------------------
Read_args       proc

                mov bp, sp                      ; although sp won't change

                mov ax, 2
                mul cx                          ; ax = N*2

                mov si, sp                      ; si = sp
                mov dx, [si]                    ; dx = retaddr
                sub sp, ax

                mov si, sp                      ; si = sp
                mov word ptr [si], dx

                SET_CMD_ARG                     ; set si = 0080h

@@Next:         call My_Atoi

                mov word ptr [bp], ax           ; ax = i-th arg save i-th arg
                
                sub bp, 2

                loop @@Next

                ret
                endp
;------------------------------------------------