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

Buf_seg         db   3    dup (?)
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
INCLUDE 3_BUF.ASM

INCLUDE INT_HAND.ASM

CHECK:              db  0ffh, ' ~72CHECK', 00dh
ERROR:              db  0ffh, ' ~73ERROR', 00dh

Main:                                                       ; TODO use this memory for buffer       
                    ; push ax bx es si

                    ; push offset New08
                    ; push offset Old08Seg
                    ; push offset Old08Ofs
                    ; mov ax, 8d

                    ; call Change_int                       ; change int table 9h in particular
                    ; pop si es bx ax

                    push ax bx es si                        ; use macro

                    push offset New09
                    push offset Old09Seg
                    push offset Old09Ofs
                    mov ax, 9d

                    call Change_int                         ; change int table 9h in particular
                    pop si es bx ax

;--------------
                    mov word ptr offset Buf_seg, ds         ; save ds segment value
                                                            ; set segment register of drae_buf
                    mov di, offset Draw_buf                 ; offset must be even!

                    SET_ES_DS                                  ; es = ds bx = 0
                    push ax bx cx dx di
                    mov bx, 80d
                    mov cx, 24d
                    mov dx, 0101h
                    call Clr_Rect                           ; clr_scr
                    pop di dx cx bx ax

                    SET_ES_DS
                    push ax bx cx dx di si               ; write_string check
                    mov dx, 0101h
                    push offset CHECK
                    call Write_str_buf                   
                    pop si di dx cx bx ax

                    xor bx, bx                              ; set default mode(registers off)
                    ; mov bx, 1                            ; set mode off
Next:               
                    cmp bx, 0
                    je @@Hide_registers
                    cmp bx, 1
                    je @@Change_draw_buf

@@Error:            
                    ; SET_ES_B800
                    ; push ax bx cx dx si               ; write_string check
                    ; mov dx, 0a01h
                    ; push offset ERROR
                    ; mov di, offset Draw_buf
                    ; call Write_str_buf                   
                    ; pop si dx cx bx ax

                    jmp @@Handle_button    

@@Change_draw_buf:  SET_ES_DS                               ; es = ds bx = 0
                    push ax cx dx
                    call Print_regs                         ; print reg (!No parameters via registers!)
                    pop dx cx ax
                    jmp @@Refresh

@@Hide_registers:   
                    SET_ES_DS                               ; es = ds bx = 0
                    push ax bx cx dx
                    mov bx, 4d
                    mov cx, 13d
                    mov dx, 4503h                           ; register
                    mov di, offset Draw_buf
                    call Clr_Rect                           ; clr_scr
                    pop dx cx bx ax
                    jmp @@Refresh

@@Refresh:
                    push ax cx di si
                    SET_ES_B800                             ; ES = b800 bx = 0
                    xor di, di                              ; DI
                                                            ; DS
                    mov si, offset Draw_buf                 ; SI

                    mov cx, 2000d                           ; refresh window
@@Next:             movsw                                   ; ds:si -> ax -> es:di
                                                            ; todo add special check(use other buffers!)
                    loop @@Next

                    pop  si di cx ax      
                    SLEEP
                                                            ;TODO write menu
@@Handle_button:    in al, 60h                              ; scanf
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
                    mov word ptr [si], ax                   ; save old int(relative)

                    mov ax, [bp+8]
                    mov word ptr es:[bx], ax                ; get new int(relative)

                    add bx, 2                               ; shift bx
                    
                    mov ax, es:[bx]   
                    mov si, [bp+6]                    
                    mov word ptr [si], ax                    ; save old int(segment)

;---------------new_features---------------------
                    ; mov si, ax                              ; write segment into int handler
                    ; add si, 4 
                    ;                                         ; for resident condition
                    ; mov [si], ax                            ; new_seg->new_seg[new_addr+4]
;------------------------------------------------
                    mov ax, ds
                    mov word ptr es:[bx], ax                ; get new int(segment)
                    sti

                    pop bp
                    retn 6
                    endp
;------------------------------------------------
END_all:
end                 Start