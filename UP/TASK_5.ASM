; task was to set a resident into program

.286
.model tiny
.code
org 100h
locals @@

Start:              jmp Main

;------------------------------------------------
New09               proc
                    mov bx, 0b800h          ; set vidmem
                    mov es, bx              ; set vidmem

                    in al, 60h              ; read scan code from PPI
                    mov ah, 4eh             ; set color(red)
                    mov bx, 160d*5 + 80d    ; get vid mem - 5th line
                    mov es:[bx], ax         

                    in al, 61h              ; recieve scan code                 PPI->
                    or al, 80h              ; 10000000 disable keyboard no matter what is set in al

                    out 61h, al             ; verify that scan code was recieved ->PPI
                    and al, not 80h         ; 01111111 enable keyboard

                    ; mov al, 20h             ; send signal to 20 port INTC
                    ; out 20h, al

                    db 0EAh                 ; jmp comand
Old09Ofs            dw 0
Old09Seg            dw 0

                    iret
                    endp
;------------------------------------------------
Main:
                    mov cl, 1h                       ; set hot scan key
Next:               in al, 60h
                    cmp al, cl                       ; if(scan == 'esc')break;
                    jne Next

EOP:                cli                                     ; change int table New->Old; disable interups until 

                    xor bx, bx
                    mov es, bx
                    mov bx, 4*9h                            ; set memory on 9h
                    
                    mov word ptr offset Old09Ofs, es:[bx]   ; save prev ptr  
                    mov es:[bx+2], offset New09             ; write load start because offset New09 is relative


                    add bx, 2
                    mov word ptr offset Old09Seg, es:[bx]
                    mov es:[bx], offset New09+2

                    sti

                    mov ax, 2509h                    ; change int table Old->New
                    mov dx, offset New09
                    int 21h

                    mov ax, 3100h                    ; terminate and stay resident
                    mov dx, offset EOP               ; save end of program
                    shr dx, 4                        ; dx /= 16
                    inc dx

                    int 21h

end                 Start


                    ; mov ax, 4c00h             ; standart exit
                    ; int 21h
