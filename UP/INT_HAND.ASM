;------------------------------------------------
; Handles 8th interuption 
;------------------------------------------------
;Entry:     BX - mode
;Exit:      None
;Expects:   
;Destroys: BX, SI, DI
;------------------------------------------------
New08               proc                   

                    push ax bx cx dx di es si                   ; check if on/off
                    mov dx, 4503h                               ; set initial cordinates
                    call Print_regs                             ; print reg 
                                                                ; todo - add check in there 
                    pop si es di dx cx bx ax

                    push ax bx cx dx es ds si di
                                                                ; if is need rewrite vidmem and rewrite save_buf
                    SET_VID_PTR                                 ; ES
                    xor di, di                                  ; DI

                    ; STAB_DS                                     ; DS
                    mov si, offset Draw_buf                     ; SI

                    mov cx, 2000d                               ; 
@@Next:             movsw                                       ; ds:si -> ax -> es:di
                                                                ; todo add special check(use other buffers!)
                    loop @@Next

@@Escape:           pop di si ds es dx cx bx ax                          ; do we need to save es

                    db 0EAh                                     ; jmp comand
Old08Ofs            dw 0
Old08Seg            dw 0

                    endp
; -----------------------------------------------

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
                    push dx es

                    in al, 60h

                    jmp @@Def_end

@@ON:               db  0ffh, ' ~74ON!', 00dh
@@OFF:              db  0ffh, ' ~72OFF', 00dh       
              
@@Def_end:          SET_ES_DS                                   ; set vidmem
                    cmp al, 0018h                               ; hot key "on" - ctrl+O (->save)
                    je @@Turn_on

                    cmp al, 0019h                               ; hot key "off" - ctrl+P(save->vid)
                    jne @@Exit_int 
                    
@@Turn_off:          
                    mov dx, 0101h                               ; print current scan code
                    push offset @@OFF
                    mov di, offset Draw_buf
                    call Write_str_buf

                    mov bx, 0
                    jmp @@Exit_int
@@Turn_on:
                    mov dx, 0101h                             ; print current scan code
                    push offset @@ON
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

                    ; mov al, 20h                             ; send signal to 20 port INTC
                    ; out 20h, al

                    pop es dx

                    db 0EAh                                   ; jmp comand
Old09Ofs            dw 0
Old09Seg            dw 0

                    endp
;------------------------------------------------

