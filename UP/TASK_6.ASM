; task was to set a resident into program
; create a chain of resident programs, catching 9th interuption

.286
.model tiny
.code
org 100h
locals @@

Start:              jmp Main

INCLUDE BASE.ASM
INCLUDE READ.ASM
INCLUDE STRING.ASM
INCLUDE WRITE.ASM
INCLUDE CALC.ASM
INCLUDE DRAW.ASM
INCLUDE 3_BUF.ASM

;------------------------------------------------
New09               proc
                    push ax bx dx es

                    in al, 60h 

                    ; mov bx, offset Draw_buf
                    SET_VID_PTR
                    mov ah, 4eh                               ; set color(red)
                    mov bx, 160d*5 + 80d                      ; get vid mem - 5th line
                    mov es:[bx], ax 

                    ; mov ax, 
                    ; mov es, ax
                    
                    jmp @@Def_end

@@ON:               db  0ffh, ' ~74ON!',  00dh
@@OFF:              db  0ffh, ' ~72OFF', 00dh       
              

@@Def_end:                                                    ; set vidmem
                    cmp al, 0018h                             ; hot key "on" - ctrl+O
                    je @@Turn_on

                    cmp al, 0019h                             ; hot key "off" - ctrl+P
                    jne @@Exit_int 
                    
@@Turn_off:
                    mov dx, 0101h                             ; print current scan code
                    push offset @@OFF
                    mov di, offset Draw_buf
                    call Write_str_buf

                    jmp @@Exit_int
@@Turn_on:

                    mov dx, 0101h                             ; print current scan code
                    push offset @@ON
                    mov di, offset Draw_buf
                    call Write_str_buf     

                    jmp @@Exit_int 

@@Exit_int:         in al, 61h                                ; recieve scan code                 PPI->
                    or al, 80h                                ; 10000000 disable keyboard no matter what is set in al

                    out 61h, al                               ; verify that scan code was recieved ->PPI
                    and al, not 80h                           ; 01111111 enable keyboard
                    ; mov al, 20h                             ; send signal to 20 port INTC
                    ; out 20h, al

                    pop es dx bx ax

                    db 0EAh                                   ; jmp comand
Old09Ofs            dw 0
Old09Seg            dw 0

                    ; iret
                    endp
;------------------------------------------------

;------------------------------------------------
; Handles 8th interuption 
;------------------------------------------------
;Entry:     BX - mode
;Exit:      None
;Expects:   
;Destroys: BX, SI, DI
;------------------------------------------------
New08               proc
                    ; cmp al, reg_hide

;                     mov cx, 2000d
;                     SET_VID_PTR
;                     mov si, offset Draw_buf
;                     mov di, 0
; @@Next:             movsw
;                     add si, 2
;                     add di, 2
;                     loop @@Next
; ;                     je @@Reg_hide

                    push ax bx cx dx di es si                           ; save ax
@@Print:            call Print_regs                             ; 1) rewrite draw_buf
                    pop si es di dx cx bx ax
                    
                    mov cx, 1000d                               ; 2) cmp vid_mem with draw_buf 
                                                                ; if is need rewrite vidmem and rewrite save_buf
                    SET_VID_PTR
                    xor di, di
                    mov si, offset Draw_buf

@@Next:             movsw                                       ; copy from draw_buf to vid memory

                    loop @@Next

                    push ax bx cx dx es


@@Escape:           pop es dx cx bx ax

;                     ; mov al, 20h                             ; send signal to 20 port INTC
;                     ; out 20h, al
                    db 0EAh                                     ; jmp comand
Old08Ofs            dw 0
Old08Seg            dw 0

                    ; iret
                    endp
; ------------------------------------------------

escape          equ    1                                       ; esc symbol
reg_show        equ    2                                       ; 1 symbol
reg_hide        equ    3                                       ; 2 symbol
clear           equ    4                                       ; 3 symbol
stop            equ    5                                       ; 4 symbol

Buf_seg         db   3    dup (?)
Draw_buf        db   2000 dup (?)
Save_buf        db   2000 dup (?)
Change_buf      db   2000 dup (?)

Reg_area        dw   618d                                    ; register start
Reg_num         dw   13d                                     ; number of registers 
Button          dw   0d

CHECK:              db  0ffh, ' ~72CHECK', 00dh

Main:                                                       ; TODO use this memory for buffer       
                    push ax bx es si                        ; use macro

                    push offset New09
                    push offset Old09Seg
                    push offset Old09Ofs
                    mov ax, 9d

                    call Change_int                           ; change int table 9h in particular

                    pop si es bx ax

                    push ax bx es si

                    push offset New08
                    push offset Old08Seg
                    push offset Old08Ofs
                    mov ax, 8d

                    call Change_int                           ; change int table 9h in particular
                    pop si es bx ax

;--------------
                    mov word ptr offset Buf_seg, ds           ; save ds segment value
                                                              ; set segment register of drae_buf
                    push ax bx cx dx es
                    
                    mov di, offset Draw_buf
                    mov bx, 40d
                    mov cx, 24d
                    call Clr_Rect                             ; clr_scr
                    pop es dx cx bx ax

                    push ax bx cx dx di es si
                    mov dx, 0101h                             
                    push offset CHECK
                    mov di, offset Draw_buf
                    call Write_str_buf                        ; write_string                   
                    pop si es di dx cx bx ax

                    push ax bx cx dx di es si
                    call Print_regs                           ; print reg
                    pop si es di dx cx bx ax

                    ; push cx dx ax
                    ; mov cx, 0001h
                    ; mov dx, 0FFFFh
                    ; mov ah, 86h
                    ; int 15h
                    ; pop ax dx cx
                                                            ;TODO write menu
Next:               in al, 60h                              ; scanf
                    cmp al, 1                               ; (scan_code == 'esc')break;
                    jne Next

Finish:             mov ax, 3100h                           ; terminate and stay resident
                    mov dx, offset EOP                      ; save end of program
                    shr dx, 4                               ; dx /= 16
                    inc dx
                    int 21h
EOP:                                                        ; after EOP db for buffer
                    jmp END_all

;------------------------------------------------
;Change int table
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


