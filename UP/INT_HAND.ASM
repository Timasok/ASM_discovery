;------------------------------------------------
; Handles 8th interuption 
;------------------------------------------------
;Entry:     BX - mode
;Exit:      None
;Expects:   
;Destroys: BX, SI, DI
;------------------------------------------------
New08               proc                   

	                push ax bx cx dx si di bp sp es ds	; saving regs

                    push si
                    mov si, offset Mode
                    mov byte ptr bl, [si]
                    pop si

                    cmp bl, 00h 
                    je @@Hide_registers
                    cmp bl, 0FFh
                    je @@Change_draw_buf

@@Error:            
                    SET_ES_B800
                    push dx di                 ; write_string check
                    mov dx, 0a01h
                    mov di, offset Draw_buf
                    push offset ERROR
                    call Write_str_buf                  ; destroys DX!               
                    pop di dx
                    SET_ES_DS

                    jmp @@Exit    

@@Change_draw_buf:  

                    push ax cx dx
                    call Print_regs 
                    pop dx cx ax
                    jmp @@Refresh

@@Hide_registers:   
                    push bx cx dx di
                    mov bx, 4d
                    mov cx, 13d
                    mov dx, 4503h                           ; register
                    mov di, offset Draw_buf
                    call Clr_Rect                           ; destroys nothing
                    pop di dx cx bx
                    jmp @@Refresh

@@Refresh:
                    push ax bx cx dx si di es
                    SET_ES_B800                             ; ES = b800 bx = 0
                    xor di, di                              ; DI
                                                            ; DS
                    lea si, Draw_buf                 ; SI
                    mov cx, 2000d                           ; refresh window

; @@Next:             movsw
;                     loop @@Next

@@Next:             mov word ptr ax, es:[di]                         ; ds:si -> ax -> es:di
                    mov bx,[si] 
                    cmp bx, ax
                    je @@Equal

@@Not_equal:        mov word ptr ax, es:[di]
                    mov word ptr ds:[offset Save_buf + di], ax
                    movsw

                    jmp @@End_loop

@@Equal:            add si, 2
                    add di, 2
                    jmp @@End_loop
@@End_loop:         
                    loop @@Next                             ; es = ds bx = 0
                    ; ax bx cx dx si di es
                    pop es di si dx cx bx ax      
@@Exit:
	                pop ds es sp bp di si dx cx bx ax	      ; revive reg

                    db 0EAh                                   ; jmp comand
Old08Ofs            dw 0
Old08Seg            dw 0

                    endp
; -----------------------------------------------

;------------------------------------------------
; Handles 9th interuption 
;------------------------------------------------
;Entry:
;Exit:      BX = 1 if registers on
;           BX = 0 if registers off
;Expects:   
;Destroys:
;------------------------------------------------
New09               proc
                    push ax bx cx dx si di bp sp es ds
;==


                    in al, 60h

                    jmp @@Def_end

@@ON:               db  0ffh, ' ~72ON!', 00dh
@@OFF:              db  0ffh, ' ~74OFF', 00dh       
              
@@Def_end:          
                    ; SET_ES_DS                                 ; set vidmem
                    cmp al, 0018h                               ; hot key "on" - ctrl+O (->save)
                    je @@Turn_on

                    cmp al, 0019h                               ; hot key "off" - ctrl+P(save->vid)
                    jne @@Exit_int 
                    
@@Turn_off:          
                    push ax bx cx si di
                    mov ax, cs		                            ; segment of src copying
                    mov si, offset Save_buf			            ; address of src copying
                    mov bx, 0B800h				                ; segment of dst copying
                    mov di, 0h 	                                ; address of dst copying
                    mov cx, 4000d			                    ; number of copying buf
                    call MemCpy			                        ; copy from VideoMem to SaveBuf
                    pop  di si cx bx ax

                    push si dx di
                    push offset @@OFF
                    mov dx, 0101h                               ; print current scan code
                    mov di, offset Draw_buf
                    call Write_str_buf

                    mov si, offset Mode
                    mov byte ptr ds:[si], 00h		                ; set "off" mode

                    push di dx si

                    call dbg

                    mov bl, 00h
                    jmp @@Exit_int
@@Turn_on:
                    push ax bx cx si di
                    mov ax, 0B800h			                    ; segment of src copying
                    mov si, 0h			                        ; address of src copying
                    mov bx, cs			                        ; segment of dst copying
                    mov di, offset Save_buf 	                ; address of dst copying
                    mov cx, 4000d			                    ; number of copying buf
                    call MemCpy			                        ; copy from VideoMem to SaveBuf
                    pop  di si cx bx ax

                    push si dx di
                    push offset @@ON
                    mov dx, 0101h                               ; print current scan code
                    mov di, offset Draw_buf
                    call Write_str_buf

                    mov si, offset Mode
                    mov byte ptr ds:[si], 0FFh		    ; set "off" mode
                    pop di dx si

                    mov bl, 0FFh
                    jmp @@Exit_int 

@@Exit_int:
                    in al, 61h                                  ; recieve scan code                 PPI->
                    or al, 80h                                  ; 10000000 disable keyboard no matter what is set in al

                    out 61h, al                                 ; verify that scan code was recieved ->PPI
                    and al, not 80h                             ; 01111111 enable keyboard

;==
                    pop  ds es sp bp di si dx cx bx ax
                    db 0EAh                                   ; jmp comand
Old09Ofs            dw 0
Old09Seg            dw 0

                    endp
;------------------------------------------------