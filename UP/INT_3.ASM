;------------------------------------------------
; Set interuption registers
;------------------------------------------------
;Entry:     AX - interuption number
;Exit:      AX = BX = 0; 
;Expects:   
;Destroys:  AX, BX, DX, ES
;------------------------------------------------
Set_int_reg         proc
                    xor dx, dx
                    mov bx, 4d 
                    mul bx
                    add ax, 2
                    mov bx, ax                  ; 8*4d+2

                    mov ax, 0
                    mov es, ax

                    mov ax, es:[bx]             ; ax = current register       
                    mov ds, ax
                    mov es, ax                  ; revive registers

                    xor ax, ax
                    xor bx, bx

                    ret
                    endp
;------------------------------------------------

;------------------------------------------------
; Handles 8th interuption 
;------------------------------------------------
New08               proc                   
                    cli
	                push ax bx cx dx si di bp sp es ds	       ; saving regs
                    push ds es sp bp di si dx cx bx ax

                    mov ax, 8d
                    call Set_int_reg

                    call Get_mode
                    je @@Set_on
                    ; jmp @@Set_off
@@Set_off:          
                    pop ax ax ax ax ax ax ax ax ax ax
                    jmp @@Exit_int
@@Set_on:           
                    ; change draw buffer
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
                    
@@Exit_int:
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
New09               proc
                    cli
                    push ax bx cx dx si di bp sp es ds

                    mov ax, 9d
                    call Set_int_reg

                    in al, 60h ;ONLY TEST VARIANT!!!
                    ; mov al, cl  ;ONLY TEST VARIANT!!!
                    
                    jmp @@Code_start
@@ON:               db  0ffh, ' ~72ON!', 00dh
@@OFF:              db  0ffh, ' ~74OFF', 00dh       
@@Code_start:          
                    SET_ES_B800
                    mov ah, 4eh                             ; set color(red)
                    mov bx, 160d*5 + 80d                    ; get vid mem - 5th line
                    mov es:[bx], ax         
                    
                    call Handle_key

                    call Get_mode
                    je @@Turn_on
                    ; jmp @@Turn_off
@@Turn_off:
                    SET_ES_B800
                    ; push si dx di
                    push offset @@OFF
                    mov dx, 0101h                               ; write "off" to savebuf
                    mov di, 0
                    call Write_str_buf
                    ; push di dx si

                    jmp @@Exit_int
                    
@@Turn_on:          
                    SET_ES_B800
                    ; push si dx di
                    push offset @@ON
                    mov dx, 0101h                               ; write "off" to savebuf
                    mov di, 0
                    call Write_str_buf
                    ; push di dx si

@@Exit_int:
                    in al, 61h                                  ; recieve scan code                 PPI->
                    or al, 80h                                  ; 10000000 disable keyboard no matter what is set in al

                    out 61h, al                                 ; verify that scan code was recieved ->PPI
                    and al, not 80h                             ; 01111111 enable keyboard

                    ; mov al, 20h                             ; send signal to 20 port INTC
                    ; out 20h, al

                    pop  ds es sp bp di si dx cx bx ax
                    sti

                    db 0EAh                                   ; jmp comand
Old09Ofs            dw 0
Old09Seg            dw 0

                    endp
;------------------------------------------------