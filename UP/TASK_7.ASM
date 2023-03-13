
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
Denied:        db  0ffh, ' ~74ACCESS DENIED ', 00dh
; password       db  4 dup (?)
password       db  '0047'

Main:  
		        mov bx, 0b800h					    ; write video mem address beginning
		        mov es, bx

                push si dx di
                push offset MESSAGE
                mov dx, 1503h                               ; write "on" to draw buffer
                call Write_string
                pop di dx si

;                 mov cx, 4
;                 mov si, offset password
; @@Enter_password:
;                 mov ah, 10h 
;                 int 16h

;                 mov byte ptr [si], al
;                 inc si

;                 loop @@Enter_password      

@@Check_password:
                xor ax, ax 
                mov si, offset password
                call Num_to_Hex

                cmp ax, 0047h
                je @@Access_granted
                jmp @@Access_denied

@@Access_granted:

                push si dx di
                push offset Granted
                mov dx, 1504h                               ; write "on" to draw buffer
                call Write_string
                pop di dx si

                jmp @@End

@@Access_denied:

                push si dx di
                push offset Denied
                mov dx, 1504h                               ; write "on" to draw buffer
                call Write_string
                pop di dx si
                jmp @@End
@@End:

                EXIT
end             Start