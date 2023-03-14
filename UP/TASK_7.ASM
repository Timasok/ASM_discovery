
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
; INCLUDE 3_BUF.ASM

MESSAGE:       db  0ffh, ' ~7CEnter your password (hex number)', 00dh
Granted:       db  0ffh, ' ~72ACCESS GRANTED', 00dh
Denied:        db  0ffh, ' ~74ACCESS DENIED ', 00dh ; 14 symbols
password       db  4 dup (?)

Main:  
		        mov bx, 0b800h					    ; write video mem address beginning
		        mov es, bx

@@Begin:                
                mov ax, BL_SPACE
                call ClrScr

                mov dx, 1604h                               ; write "on" to draw buffer
                push si dx di
                push offset MESSAGE
                call Write_string
                pop di dx si

                xor cx, cx
                mov bh, 00001100b               ; set frame color
                mov ah, 6d                      ; frame width
                mov al, 3d                      ; frame height

                mov dx, 2206h                   ; shift frame down a little              

                call drawFrame

                add dx, 0101h                               ; add coordinates
                mov cx, 4
                mov si, offset password
                xor ax, ax 
@@Enter_password:
                mov ah, 10h 
                int 16h

                mov byte ptr [si], al
                inc si

                mov ax, 052ah                               ; mov star
                push ax bx cx dx
                call DispSym    
                pop dx cx bx ax

                add dx, 0100h                   

                loop @@Enter_password      


@@Check_password:
                
                xor ax, ax 
                mov si, offset password
                call Num_to_Hex
                push ax

                push 250d                                 ; set shift of password
                push 10
                push -10
                pop ax
                pop bx
                pop cx

                add di, cx                               ; get address
                pop ax
                cmp ax, [di]
                je @@Access_granted
                jmp @@Access_denied

@@Access_granted:

                push si dx di
                push offset Granted
                mov dx, 1f09h                               ; write "on" to draw buffer
                call Write_string
                pop di dx si

                jmp @@End

@@Access_denied:

                push si dx di
                push offset Denied
                mov dx, 1f09h                               ; write "on" to draw buffer
                call Write_string
                pop di dx si
                jmp @@End
@@End:
                EXIT
PASS       db   250 dup (?)
value      dw   0056h
end             Start