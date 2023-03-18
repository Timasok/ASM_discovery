; Task was to set a resident into program
; Create a chain of resident programs, catching 9th interuption
; Every int handler function contains seg value in address as a db in it's begining(after jmp)

.286
.model tiny
.code
org 100h
locals @@

Start:              jmp Main

escape          equ    1                                    ; esc symbol
reg_show        equ    2                                    ; 1 symbol
reg_hide        equ    3                                    ; 2 symbol
clear           equ    4                                    ; 3 symbol
stop            equ    5                                    ; 4 symbol

; Buf_seg         db   2    dup (?)
Mode            db   0h
Draw_buf        db   4000 dup (?)
Save_buf        db   4000 dup (?)
Change_buf      db   4000 dup (?)

Reg_area        dw   618d                                   ; register start
Reg_num         dw   13d                                    ; number of registers 
Button          dw   0d

INCLUDE BASE.ASM
INCLUDE READ.ASM
INCLUDE STRING.ASM
INCLUDE WRITE.ASM
INCLUDE CALC.ASM
INCLUDE DRAW.ASM
INCLUDE BUF_F.ASM

INCLUDE INT_3.ASM

CHECK:              db  0ffh, ' ~72Wow wow wow!!!', 00dh
ERROR:              db  0ffh, ' ~74ERROR', 00dh

Main:
;=============9h
                    push ax bx es si                        ; use macro
                    push offset New09
                    push offset Old09Seg
                    push offset Old09Ofs
                    mov ax, 9d

                    call Change_int                         ; change int table 9h in particular
                    pop si es bx ax
;=============8h 
                    push ax bx es si                        ; change int table 8h in particular
                    push offset New08
                    push offset Old08Seg
                    push offset Old08Ofs
                    mov ax, 8d
                    call Change_int                       
                    pop si es bx ax
;===============

;=========HARD_DEBUG

                    ; int 8h
                    ; mov cl, 18h 
                    ; int 9h 
                    ; int 8h
                    ; mov cl, 19h
                    ; int 9h
                    ; int 8h
                    ; mov cl, 18h 
                    ; int 9h
                    ; int 8h 
;===================

PASS:               mov ax, 3100h                           ; terminate and stay resident
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
                    mov word ptr [si], ax                   ; save old int(relative)

                    mov ax, [bp+8]
                    mov word ptr es:[bx], ax                ; get new int(relative)

                    add bx, 2                               ; shift bx
                    
                    mov ax, es:[bx]   
                    mov si, [bp+6]                    
                    mov word ptr [si], ax                    ; save old int(segment)

                    mov ax, ds
                    mov word ptr es:[bx], ax                ; get new int(segment)
                    sti

                    pop bp
                    retn 6
                    endp
;------------------------------------------------
END_all:
End                 Start