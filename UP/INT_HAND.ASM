;------------------------------------------------
; Handles 8th interuption 
;------------------------------------------------
;Entry:     BX - mode
;Exit:      None
;Expects:   
;Destroys: BX, SI, DI
;------------------------------------------------
New08               proc                   

                    cmp bx, 0
                    je @@Hide_registers
                    cmp bx, 1
                    je @@Change_draw_buf

@@Error:            
                    SET_ES_B800
                    push ax bx cx dx si               ; write_string check
                    mov dx, 0a01h
                    push offset ERROR
                    mov di, offset Draw_buf
                    call Write_str_buf                   
                    pop si dx cx bx ax
                    SET_ES_DS

                    jmp @@Exit    

@@Change_draw_buf:  push ax cx dx
                    call Print_regs                         ; print reg (!No parameters via registers!)
                    pop dx cx ax
                    jmp @@Refresh

@@Hide_registers:   
                    push ax bx cx dx
                    mov bx, 4d
                    mov cx, 13d
                    mov dx, 4503h                           ; register
                    mov di, offset Draw_buf
                    call Clr_Rect                           ; clr_scr
                    pop dx cx bx ax
                    jmp @@Refresh

@@Refresh:
                    push ax cx si
                    SET_ES_B800                             ; ES = b800 bx = 0
                    xor di, di                              ; DI
                                                            ; DS
                    mov si, offset Draw_buf                 ; SI
                    mov cx, 2000d                           ; refresh window

                    push bx
                    mov bx, offset Save_buf

@@Next:             mov ax, es:[di]                         ; ds:si -> ax -> es:di
                    cmp [si], ax
                    je @@Equal

@@Not_equal:        mov ax, es:[di]
                    mov word ptr ds:[bx], ax
                    movsw

                    jmp @@End_loop

@@Equal:            add si, 2
                    add di, 2
                    jmp @@End_loop

@@End_loop:         add bx, 2
                    loop @@Next
                    pop bx
                    
                    SET_ES_DS                               ; es = ds bx = 0
                    pop si cx ax      
                    
@@Exit:
                    db 0EAh                                     ; jmp comand
Old08Ofs            dw 0
Old08Seg            dw 0

                    endp
; -----------------------------------------------
; @@Next:             movsw                                   ; ds:si -> ax -> es:di
;                                                             ; todo add special check(use other buffers!)
;                     loop @@Next


                    ; mov al, 20h                               ; send signal to 20 port INTC
                    ; out 20h, al

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
                    ; push dx es

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
                    mov ax, cs		                            ; segment of src copying
                    mov si, offset Save_buf			            ; address of src copying
                    mov bx, 0B800h				                ; segment of dst copying
                    mov di, 0h 	                                ; address of dst copying
                    mov cx, 4000d			                    ; number of copying buf
                    call MemCpy			                        ; copy from VideoMem to SaveBuf
                    
                    ; mov bx, offset Show_Regs_Mode
                    ; mov byte ptr [bx], 0FFh		; set "on" mode

                    ; push ax cx di si
                    ; call Save_to_vidmem
                    ; pop  si di cx ax

                    push offset @@OFF
                    mov dx, 0101h                               ; print current scan code
                    mov di, offset Draw_buf
                    call Write_str_buf

                    mov bx, 0
                    jmp @@Exit_int
@@Turn_on:
                    mov ax, 0B800h			                    ; segment of src copying
                    mov si, 0h			                        ; address of src copying
                    mov bx, cs			                        ; segment of dst copying
                    mov di, offset Save_buf 	                ; address of dst copying
                    mov cx, 4000d			                    ; number of copying buf
                    call MemCpy			                        ; copy from VideoMem to SaveBuf
                    
                    ; mov bx, offset Show_Regs_Mode
                    ; mov byte ptr [bx], 0FFh		; set "on" mode

                    ; push ax cx di si
                    ; call Vidmem_to_save
                    ; pop  si di cx ax

                    push offset @@ON
                    mov dx, 0101h                             ; print current scan code
                    mov di, offset Draw_buf
                    call Write_str_buf

                    mov bx, 1
                    jmp @@Exit_int 

@@Exit_int:         push ax
                    in al, 61h                                ; recieve scan code                 PPI->
                    or al, 80h                                ; 10000000 disable keyboard no matter what is set in al

                    out 61h, al                               ; verify that scan code was recieved ->PPI
                    and al, not 80h                           ; 01111111 enable keyboard
                    pop ax

                    mov al, 20h                             ; send signal to 20 port INTC
                    out 20h, al

                    ; pop es dx

                    db 0EAh                                   ; jmp comand
Old09Ofs            dw 0
Old09Seg            dw 0

                    endp
;------------------------------------------------