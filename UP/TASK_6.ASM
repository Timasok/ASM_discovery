; task was to set a resident into program
; create a chain of resident programs, catching 9th interuption

.286
.model tiny
.code
org 100h
locals @@

Start:              jmp Main

INCLUDE BASE.ASM
INCLUDE STRING.ASM
INCLUDE WRITE.ASM
INCLUDE CALC.ASM
INCLUDE DRAW.ASM
INCLUDE 3_BUF.ASM

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
Main:                                                       ; TODO use this memory for buffer       
                    push ax bx es si

                    push offset New09
                    push offset Old09Seg
                    push offset Old09Ofs
                    mov ax, 9d

                    call Change_int                         ; change int table 9h in particular

                    pop si es bx ax

Next:               in al, 60h                              ;TODO write menu
                    
                    cmp al, 1                               ; can == 'esc')break;
                    je h_key_esc
                    cmp al, 2                               ; if(scan == 'esc')break;
                    je h_key_print_reg
                    
                    jmp Next

                    jmp Finish

h_key_esc:
                    jmp Finish

h_key_print_reg:

                    push bx cx dx
                    mov dx, 4005h                           ; print register
                    mov bx, 0b800h                          ; set vidmem
                    mov es, bx                              ; set vidmem

                    call Write_hex                          

                    mov ax, bx                              ; BX

                    push bx cx dx
                    mov dx, 4006h                           ; print register
                    mov bx, 0b800h                          ; set vidmem
                    mov es, bx                              ; set vidmem

                    call Write_hex                          
                    pop dx  bx cx

                    mov ax, cx

                    push bx cx dx
                    mov dx, 4007h                           ; print register
                    mov bx, 0b800h                          ; set vidmem
                    mov es, bx                              ; set vidmem

                    call Write_hex                          
                    pop dx  bx cx

                    mov ax, dx
                    push bx cx dx
                    mov dx, 4008h                           ; print register
                    mov bx, 0b800h                          ; set vidmem
                    mov es, bx                              ; set vidmem

                    call Write_hex                          
                    pop dx  bx cx

                    jmp Next

Finish:             mov ax, 3100h                           ; terminate and stay resident
                    mov dx, offset EOP                      ; save end of program
                    shr dx, 4                               ; dx /= 16
                    inc dx
                    int 21h
EOP:                                                        ; after EOP db for buffer
                    jmp END_all

;------------------------------------------------
;change int table
;------------------------------------------------
;Entry:     p3 - New addr
;           p2 - old addr segment
;           p1 - old addr 
;           AX - interuption number
;Exit:      Nothing
;Expects:   
;Destroys:  AX, BX, ES, SI
;------------------------------------------------
Change_int          proc
                    push bp
                    mov bp, sp

                    cli                                     ; change int table New->Old; disable interups until 
                    xor bx, bx
                    mov es, bx                              ; set es

                    shl ax, 2                               ; ax *= 4
                    mov bx, ax                              ; set bx

                    mov ax, es:[bx]                         
                    mov si, [bp+4]
                    mov word ptr [si], ax                          ; save old int(relative)

                    mov ax, [bp+8]
                    mov word ptr es:[bx], ax                ; get new int(relative)

                    add bx, 2                               ; shift bx
                    
                    mov ax, es:[bx]   
                    mov si, [bp+6]                    
                    mov word ptr [si], ax                          ; save old int(segment)

                    mov ax, cs
                    mov word ptr es:[bx], ax                ; get new int(segment)
                    sti

                    pop bp
                    retn 6
                    endp
;------------------------------------------------
END_all:
end                 Start


