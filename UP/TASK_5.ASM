; task was to set a resident into program
; create a chain of resident programs, catching 9th interuption

.286
.model tiny
.code
org 100h
locals @@

Start:              jmp Main

;------------------------------------------------
New09               proc
                    push ax bx es

                    mov bx, 0b800h                          ; set vidmem
                    mov es, bx                              ; set vidmem

                    in al, 60h                              ; read scan code from PPI
                    mov ah, 4eh                             ; set color(red)
                    mov bx, 160d*5 + 80d                    ; get vid mem - 5th line
                    mov es:[bx], ax         

                    in al, 61h                              ; recieve scan code                 PPI->
                    or al, 80h                              ; 10000000 disable keyboard no matter what is set in al

                    out 61h, al                             ; verify that scan code was recieved ->PPI
                    and al, not 80h                         ; 01111111 enable keyboard

                    mov al, 20h                             ; send signal to 20 port INTC
                    out 20h, al

                    pop es bx ax
                    db 0EAh                                 ; jmp comand
Old09Ofs            dw 0
Old09Seg            dw 0

                    ; iret
                    endp
;------------------------------------------------
Main:

                    cli                                     ; change int table New->Old; disable interups until 
                    xor bx, bx
                    mov es, bx
                    mov bx, 24h                             ; set memory on 9h
                    
                    mov ax, es:[bx]                         ; save old int
                    mov word ptr Old09Ofs, ax
                    mov ax, offset New09
                    mov word ptr es:[bx], ax                ; get new int

                    add bx, 2
                    
                    mov ax, es:[bx]                         ; save old int
                    mov word ptr Old09Seg, ax
                    mov ax, cs
                    mov word ptr es:[bx], ax                ; get new int
                    sti
                    
                    mov ax, 3100h                           ; terminate and stay resident
                    mov dx, offset EOP                      ; save end of program
                    shr dx, 4                               ; dx /= 16
                    inc dx
                    mov cl, 1h                              ; set hot_key

                    SET_VID_PTR                                 ; ES
                    xor di, di                                  ; DI

                    ; STAB_DS                                     ; DS
                    mov si, offset Draw_buf                     ; SI

                    mov cx, 2000d                               ; 
@@Next:             movsw                                       ; ds:si -> ax -> es:di
                    loop @@Next

Next:               in al, 60h
                    cmp al, cl                              ; if(scan == 'esc')break;
                    jne Next

                    int 21h
EOP:
end                 Start
