
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

MESSAGE:       db  0ffh, ' ~7C          Enter your password &(<8 symbols, terminate with Enter)', 00dh
Granted:       db  0ffh, ' ~72ACCESS GRANTED', 00dh
Denied:        db  0ffh, ' ~74ACCESS DENIED ', 00dh ; 14 symbols
matched:       db  0
flag:          db  7
value:         db  'huysosi'
password:      db  8 dup (?)
_ntr:          db  ENTER_        

ENTER_         equ     0dh

Main:  
		        mov bx, 0b800h					    ; write video mem address beginning
		        mov es, bx

@@Begin:                
                mov ax, BL_SPACE
                call ClrScr

                mov dx, 1403h                               ; write "on" to draw buffer
                push si dx di
                push offset MESSAGE
                call Write_string
                pop di dx si

                xor cx, cx
                mov bh, 00001100b               ; set frame color
                mov ah, 10d                      ; frame width
                mov al, 3d                      ; frame height

                mov dx, 2006h                   ; shift frame down a little              

                call drawFrame

                add dx, 0101h                               ; add coordinates
                mov cx, 8                                   ; change
                mov si, offset password
                xor ax, ax

@@Enter_password:
                mov ah, 10h 
                int 16h

                mov byte ptr [si], al
                inc si

                cmp al, ENTER_
                je @@Check_password

                call check_hash_2

                mov ax, 052ah                               ; mov star
                push ax bx cx dx
                call DispSym    
                pop dx cx bx ax

                add dx, 0100h                   

                loop @@Enter_password

@@Check_password:
                xor ax, ax
                xor bx, bx

                mov di, offset value
@@Start_check:
                mov si, offset flag
                mov byte ptr cl, [si]
                mov si, offset password                      ; si = initial
@@Iteration:
                mov byte ptr al, [si]                        ; your entry
                mov byte ptr bl, [di]                        ; what to cmp with

                cmp al, ENTER_
                je @@Access_denied

                cmp bl, al                                  ; basic check
                je  @@Equal
                jne @@Not_equal

@@Equal:        
                push si
                mov si, offset matched
                mov byte ptr dl, [si]
                pop si
                inc dx
                mov byte ptr offset matched, dl

                jmp @@Cmp_pass
@@Not_equal:
                mov byte ptr offset matched, 0              ; one match was detected!
                jmp @@Final_thoughts
@@Cmp_pass:     
                push si
                push cx
                mov si, offset flag
                mov byte ptr dl, [si]
                mov si, offset matched
                mov byte ptr cl, [si]
                mov dh, cl
                pop cx
                pop si
                cmp dh, dl
                je @@Access_granted

@@Final_thoughts:
                inc si
                inc di

                loop @@Iteration
                jmp @@Start_check

@@Access_granted:
                inc si                                       ; last check of termination
                mov byte ptr al, [si]
                cmp al, ENTER_
                jne @@Access_denied   

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
PASS:
                EXIT
end             Start