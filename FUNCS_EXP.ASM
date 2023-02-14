.386
.model tiny
.code
locals @@
org 100h

Start:          jmp Real_start

;------------------------------------------------
;Exits to DOS
;------------------------------------------------
;Entry:     None
;Exit:      (Not defined)
;Expects:   Nothing
;Destroys:  AX
;------------------------------------------------
EXIT            macro
                nop
                mov ax, 4c00h
                int 21h
                nop
                endm
;------------------------------------------------

;------------------------------------------------
;Clear the screen
;------------------------------------------------
;Entry:     AH - color attr
;           AL - sym
;Exit:      None
;Expects:   ES = 0b800h
;Destroys:  BX, CX
;------------------------------------------------
ClrScr          proc
                xor bx, bx
                mov cx, 80d*25d                 ;symbols in the screen
@@Next:         mov es:[bx], ax
                add bx, 2 
                loop @@Next

                ret
                endp
;------------------------------------------------

;------------------------------------------------
;Display symbol, at the following place on the screen
;------------------------------------------------
;Entry:     AH - color attr
;           AL - sym
;           DH - x coordinate(0-80)
;           DL - y coordinate(0-25)
;Exit:      None
;Expects:   ES = 0b800h
;           Screen size is 25/80
;Destroys:  BX, CX
;------------------------------------------------
DispSym         proc
                mov cx, 80d                     ; set window width
                
                mov bl, dl                      ; bx = y
                imul bx, cx                     ; bx *= 80
            
                mov cl, 8                       ; set 1 byte shift
                shr dx, cl                      ; dx = x

                add bx, dx                      ; bx += x

                mov word ptr es:[bx], ax

                ret
                endp
;------------------------------------------------

;
Real_start:     mov bx, 0b800h
                mov es, bx
                
                mov ax, 4eb1h                   ;add symbol that will paint the screen
                call ClrScr
                
                ; mov ax, 1000110000000011b       ; red heart
                ; mov dx, 0000000100000001b       ; x = 1, y = 1
                ; call DispSym
                
                EXIT
end             Start