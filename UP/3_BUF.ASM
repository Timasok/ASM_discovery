

;------------------------------------------------
;push macro
;------------------------------------------------
;Entry:     AL - scan code
;Exit:      Nothing
;Expects:   
;Destroys:  
;------------------------------------------------
Reg_push            macro
                    push bx cx dx
                    mov dx, 4503h                           ; print register
                    mov bx, 0b800h                          ; set vidmem
                    mov es, bx                              ; set vidmem

                    endm    
;------------------------------------------------

;------------------------------------------------
;Print all registers
;------------------------------------------------
;Entry:     AH - reg print mode
;           AH - 0 print
;           AH - 1 hide 
;Exit:      Nothing
;Expects:   
;Destroys: None
;------------------------------------------------
Print_regs          proc
                    pushf
                    push ax bx cx dx                             ; save ax

                    cmp ah, 1
                    je @@Finish

                    push cs ss es ds es sp bp di si dx cx bx ax

                    mov cx, 13d
                    mov dx, 4503h                           ; set initial cordinates

                    mov bx, 0b800h                          ; set vidmem
                    mov es, bx                              ; set vidmem

@@Next:         
                    pop ax
                    call Write_hex                         
                    add dx, 0001h

                    loop @@Next

@@Finish:           pop dx cx bx ax
                    popf

                    ret
                    endp
;------------------------------------------------