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

                    mov ax, 8d
                    call Set_int_reg

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
                    
                    jmp @@Def_end

@@ON:               db  0ffh, ' ~72ON!', 00dh
@@OFF:              db  0ffh, ' ~74OFF', 00dh       
              
@@Def_end:          
                    SET_ES_B800
                    mov ah, 4eh                             ; set color(red)
                    mov bx, 160d*5 + 80d                    ; get vid mem - 5th line
                    mov es:[bx], ax         
                    
                    call Handle_key

                    call Get_mode
                    je @@Turn_on
                    jmp @@Turn_off

@@Turn_on:
@@Turn_off:
@@Exit_int:
                    in al, 61h                                  ; recieve scan code                 PPI->
                    or al, 80h                                  ; 10000000 disable keyboard no matter what is set in al

                    out 61h, al                                 ; verify that scan code was recieved ->PPI
                    and al, not 80h                             ; 01111111 enable keyboard

                    mov al, 20h                             ; send signal to 20 port INTC
                    out 20h, al

                    pop  ds es sp bp di si dx cx bx ax
                    sti
                    db 0EAh                                   ; jmp comand
Old09Ofs            dw 0
Old09Seg            dw 0

                    endp
;------------------------------------------------