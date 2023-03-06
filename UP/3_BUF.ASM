

;------------------------------------------------
;Handle hot key
;------------------------------------------------
;Entry:     AL - scan code
;Exit:      Nothing
;Expects:   
;Destroys:  
;------------------------------------------------
;------------------------------------------------


;------------------------------------------------
;Print all registers
;------------------------------------------------
;Entry:     
;Exit:      Nothing
;Expects:   
;Destroys: 
;------------------------------------------------
Print_regs          proc
                    push si ax                              ; save ax

                    push bx cx dx
                    mov dx, 4005h                           ; print register
                    mov bx, 0b800h                          ; set vidmem
                    mov es, bx                              ; set vidmem

                    call Write_hex                          
                    pop dx bx cx

                    mov ax, bx                              ; BX

                    push bx cx dx
                    mov dx, 4006h                           ; print register
                    mov bx, 0b800h                          ; set vidmem
                    mov es, bx                              ; set vidmem

                    call Write_hex                          
                    pop dx bx cx

                    mov ax, cx                              ; save cx value

                    push bx cx dx
                    mov dx, 4007h                           ; print register
                    mov bx, 0b800h                          ; set vidmem
                    mov es, bx                              ; set vidmem

                    call Write_hex                          
                    pop dx bx cx

                    mov ax, dx
                    push bx cx dx
                    mov dx, 4008h                           ; print register
                    mov bx, 0b800h                          ; set vidmem
                    mov es, bx                              ; set vidmem

                    call Write_hex                          
                    pop dx bx cx

                    pop ax si

                    ret
                    endp
;------------------------------------------------