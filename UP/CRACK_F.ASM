;------------------------------------------------
;Calculate hash of 4 digit password
;------------------------------------------------
;Entry:     cmd arg with line
;Exit:      BX - calculated hash
;Expects:   SI is password start
;Destroys:  AX, BX, CX, SI
;------------------------------------------------
Calc_hash           proc
                    mov cx, 4
                    xor bx, bx
                    xor ax, ax
; h = h*33 + 5

; bx = bx*33 + 

@@Next:             
                    mov byte ptr al, [si]                        ; your entry
                    inc si
                    add bx, ax
                    and bx, 7fffh

                    loop @@Next

                    ret
                    endp
;------------------------------------------------