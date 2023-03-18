;------------------------------------------------
; Handles 8th interuption 
;------------------------------------------------
;Entry:     BX - mode
;Exit:      None
;Expects:   
;Destroys: BX, SI, DI
;------------------------------------------------
New08               proc                   
                    cli
	                push ax bx cx dx si di bp sp es ds	; saving regs

;===========        revive registers
                    mov ax, 0
                    mov es, ax
                    mov bx, 8*4d+2                      ; set int table shift

                    mov ax, es:[bx]                     ; revive registers
                    mov ds, ax
                    ; mov cs, es:[bx]
;===========         

                    ; jmp @@Exit_int
                    push si                             ; get current mode
                    mov si, offset Mode
                    mov byte ptr bl, [si]
                    pop si

                    cmp bl, 0FFh                            ; if( mode == on) write
                    je @@On_refresh

                    cmp bl, 00h 
                    je @@Off_refresh

@@Error:            
                    SET_ES_B800
                    push dx di                              ; write_string check
                    mov dx, 0a01h
                    mov di, offset Draw_buf
                    push offset ERROR
                    call Write_str_buf                      ; destroys DX!               
                    pop di dx
                    SET_ES_DS

                    jmp @@Exit_int    

@@Off_refresh:
                    jmp @@Exit_int
@@On_refresh:  

                    SET_ES_DS
                    push ax cx dx                           ; change draw buffer
                    call Print_regs                         
                    pop dx cx ax

                    push ax bx cx dx si di es
                    SET_ES_B800                             ; ES = b800 bx = 0
                    xor di, di                              ; DI ; DS
                    lea si, Draw_buf                        ; SI
                    mov cx, 2000d                           ; refresh window

@@Next:             lodsw
                    scasw
                    je @@Equal

@@Not_equal:        mov word ptr ax, es:[di]                ; vidmem[i] != draw_buf[i] vidmem->save_buf
                    mov word ptr ds:[offset Change_buf + di], ax
                    movsw

                    jmp @@End_loop

@@Equal:            add si, 2                               ; vidmem[i] == draw_buf[i]
                    add di, 2
                    jmp @@End_loop
@@End_loop:         
                    loop @@Next                             ; es = ds bx = 0

                    pop es di si dx cx bx ax      

@@Exit_int:             
                    ; push si
                    ; mov si, offset Mode
                    ; mov byte ptr ds:[si], 0FFh		            ; set "on" mode
                    ; pop si

	                pop ds es sp bp di si dx cx bx ax	      ; revive reg
                    sti

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
                    cli
;===========        revive registers
                    mov ax, 0
                    mov es, ax
                    mov bx, 8*4d+2                      ; set int table shift

                    mov ax, es:[bx]                     
                    mov ds, ax
                    mov es, ax                          ; revive registers
                    ; mov cs, es:[bx]

                    xor ax, ax
                    xor bx, bx
;===========         
                    in al, 60h
                    
                    jmp @@Def_end

@@ON:               db  0ffh, ' ~72ON!', 00dh
@@OFF:              db  0ffh, ' ~74OFF', 00dh       
              
@@Def_end:          
                    ; mov al, cl  ;ONLY TEST VARIANT!!!
                    SET_ES_DS                                 ; set vidmem
                    cmp al, 18h                               ; hot key "on" - ctrl+O (->save)
                    je @@Turn_on

                    cmp al, 19h                               ; hot key "off" - ctrl+P(save->vid)
                    jne @@Train_to_exit 
                    
@@Turn_off:          
                    jmp @@Exit_int
                    push si dx di
                    push offset @@OFF
                    mov dx, 0101h                               ; write "off" to savebuf
                    mov di, offset Save_buf
                    call Write_str_buf
                    push di dx si
                                                                ; copy from SaveBuf to VideoMem
                    push ax bx cx si di                         
                    mov ax, ds		                            ; segment of src copying
                    mov si, offset Save_buf			            ; address of src copying
                    mov bx, 0B800h				                ; segment of dst copying
                    mov di, 0h 	                                ; address of dst copying
                    mov cx, 4000d			                    ; number of copying buf
                    call MemCpy			                        
                    pop  di si cx bx ax

                    push si
                    mov si, offset Mode
                    mov byte ptr ds:[si], 00h		            ; set "off" mode
                    pop si

@@Train_to_exit:    jmp @@Exit_int
@@Turn_on:          

                    push si
                    mov si, offset Mode
                    mov byte ptr ds:[si], 0FFh		            ; set "on" mode
                    pop si

                    push si dx di
                    push offset @@ON
                    mov dx, 0101h                               ; write "on" to draw buffer
                    mov di, offset Draw_buf
                    call Write_str_buf
                    pop di dx si

                    ; copy from VideoMem to SaveBuf
                    push ax bx cx si di
                    mov ax, 0B800h			                    ; segment of src copying
                    mov si, 0h			                        ; address of src copying
                    mov bx, ds			                        ; segment of dst copying
                    mov di, offset Save_buf 	                ; address of dst copying
                    mov cx, 4000d			                    ; number of copying buf
                    call MemCpy			                        
                    pop  di si cx bx ax

                    ; copy from DrawBuf to VideoMem
                    push ax bx cx si di
                    mov ax, ds			                        ; segment of src copying
                    mov si, offset Draw_buf		                ; address of src copying
                    mov bx, 0B800h                              ; segment of dst copying
                    mov di, 0h 	                                ; address of dst copying
                    mov cx, 4000d			                    ; number of copying buf
                    call MemCpy			                        
                    pop  di si cx bx ax

                    jmp @@Exit_int 

@@Exit_int:
                    in al, 61h                                  ; recieve scan code                 PPI->
                    or al, 80h                                  ; 10000000 disable keyboard no matter what is set in al

                    out 61h, al                                 ; verify that scan code was recieved ->PPI
                    and al, not 80h                             ; 01111111 enable keyboard

                    mov al, 20h                             ; send signal to 20 port INTC
                    out 20h, al

                    sti
                    pop  ds es sp bp di si dx cx bx ax
                    db 0EAh                                   ; jmp comand
Old09Ofs            dw 0
Old09Seg            dw 0

                    endp
;------------------------------------------------