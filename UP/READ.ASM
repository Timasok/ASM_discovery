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
