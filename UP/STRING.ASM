;------------------------------------------------
CHECK_DF        macro
                nop
                push ax
                lahf                        ; save flag reg to ax
                and ax, 0000010000000000b   ; get 10th byte aka DF
                cmp ax, 0
                pop ax
                nop
                endm
;------------------------------------------------

;------------------------------------------------
; lodsw - reads one word of the string written in SI
;------------------------------------------------
;Entry:     SI - line start
;Exit:      AX - 2 bytes of the string
;           SI += 2
;Expects:   
;Destroys:  SI, AX
;------------------------------------------------
My_lodsw        proc
                mov al, [si]
                CHECK_DF
                
                je @@Inc                    ; dec 2
                sub si, 2

                jmp @@End                   ; inc 2
@@Inc:          add si, 2
@@End:          ret
                endp
;------------------------------------------------

;------------------------------------------------
; lodsb - reads one byte of the string written in SI
;------------------------------------------------
;Entry:     SI - line start
;Exit:      AL - 1 byte of the string
;           SI += 1
;Expects:   
;Destroys:  SI, AX
;------------------------------------------------
My_lodsb        proc
                mov al, [si]
                CHECK_DF
                
                je @@Inc                    ; dec
                dec si

                jmp @@End                   ; inc
@@Inc:          inc si
@@End:          ret
                endp
;------------------------------------------------

;------------------------------------------------
; stosb
;------------------------------------------------
;Entry:     AL - one char
;Exit:      None
;Expects:   ES, DI are set  
;Destroys:  DI
;------------------------------------------------
My_stosb        proc
                mov byte ptr es:[di], al
                CHECK_DF
                
                je @@Inc                    ; dec
                dec di

                jmp @@End                   ; inc
@@Inc:          inc di
@@End:          ret
                endp
;------------------------------------------------


;------------------------------------------------
; stosw
;------------------------------------------------
;Entry:     AX - two chars
;Exit:      None
;Expects:   ES, DI are set  
;Destroys:  DI
;------------------------------------------------
My_stosw        proc
                mov word ptr es:[di], ax
                CHECK_DF
                
                je @@Inc                    ; dec 2
                sub di, 2

                jmp @@End                   ; inc 2
@@Inc:          add di, 2
@@End:          ret
                endp
;------------------------------------------------

;------------------------------------------------
; cmpsb
;------------------------------------------------
;Entry:         
;Exit:      None
;Expects:   ES, DI
;           DS, SI
;Destroys:  AX, DI, SI
;------------------------------------------------
My_cmpsb        proc
                mov al, es:[di]
                mov ah, ds:[si]

                CHECK_DF
                
                je @@Inc                    ; dec
                dec si
                dec di

                jmp @@End                   ; inc
@@Inc:          inc si
                inc di

@@End:          cmp al, ah
                ret
                endp
;------------------------------------------------

;------------------------------------------------
; cmpsw
;------------------------------------------------
;Entry:         
;Exit:      None
;Expects:   ES, DI
;           DS, SI
;Destroys:  AX, BX, DI, SI
;------------------------------------------------
My_cmpsw        proc
                mov ax, es:[di]
                mov bx, ds:[si]

                CHECK_DF
                
                je @@Inc                    ; dec
                sub si, 2
                sub di, 2

                jmp @@End                   ; inc
@@Inc:          add si, 2
                add di, 2

@@End:          cmp ax, bx
                ret
                endp
;------------------------------------------------

;------------------------------------------------
; movsb - moves byte from es:di to ds:si 
;------------------------------------------------
;Entry:     DI, SI
;Exit:      None
;Expects:   
;Destroys: DI, DI
;------------------------------------------------
My_movsb        proc
                mov byte ptr es:[di], ds:[si]

                CHECK_DF
                
                je @@Inc                    ; dec
                dec si
                dec di

                jmp @@End                   ; inc
@@Inc:          inc si
                inc di

@@End:          ret
                endp

                ret
                endp
;------------------------------------------------

;------------------------------------------------
; movsw - moves byte from es:di to ds:si 
;------------------------------------------------
;Entry:     DI, SI
;Exit:      None
;Expects:   
;Destroys:  DI, DI
;------------------------------------------------
My_movsw        proc
                mov word ptr es:[di], ds:[si]

                CHECK_DF
                
                je @@Inc                    ; dec
                sub si, 2
                sub di, 2

                jmp @@End                   ; inc
@@Inc:          add si, 2
                add di, 2

@@End:          ret
                endp
;------------------------------------------------


; strlen
; memset
; memchr
; strchr
; strcpy
; strncpy
; memcpy
; memcmp
; strcmp

;------------------------------------------------
;------------------------------------------------
;Entry:     
;Exit:      None
;Expects:   
;Destroys: 
;------------------------------------------------
; My_        
;                 proc
;                 ret
;                 endp
;------------------------------------------------