;------------------------------------------------
;Checks for \n 
;------------------------------------------------
;Entry:     AL - symbol
;           DX - initial coordinates
;           BX - current video memory shift
;Exit:      flag changes
;Expects:   AH = 0
;Destroys:  AH
;------------------------------------------------
Check_NL        proc
                mov ah, 26h            ; ah = '&'
                cmp al, ah
                je @@Print_NL

                xor ah, ah             ; if(c != '&') ah = 0        
                jmp @@Finish

@@Print_NL:     push ax
                
                add dx, 0001h           ; y+=1
                call Get_Vid_Mem

                pop ax

@@Finish:
                ret
                endp
;------------------------------------------------

;------------------------------------------------
;Write string from cmd arg
;------------------------------------------------
;Entry:     p1 - pointer to db with string
;           AH - color
;           DH - x0 coordinate(0-80)
;           DL - y0 coordinate(0-25)
;Exit:      
;Expects:   db should start with special symbol -
; with code of ffh to save the opportunity to write lines with length up to 255 symbols
;Destroys:  BX, CX
;------------------------------------------------
Write_string        proc
                    push bp
                    mov bp, sp
                    
                    push si
                    mov si, [bp+4]

                    push ax
                    call Write_line
                    pop ax
                    
                    pop si

                    pop bp
                    retn 2
                    endp
;------------------------------------------------

;------------------------------------------------
;Write line from cmd arg
;------------------------------------------------
;Entry:     DH - x0 coordinate(0-80)
;           DL - y0 coordinate(0-25)
;           AH - color
;           AL - 0 if sleep is off, else set 1
;Exit:      
;Expects:   SI is set
;Destroys:  AX, BX, CX, SI, DI
;------------------------------------------------
Write_line      proc
                
                mov di, offset @@Color              ; set label ptr
                mov byte ptr cs:[di], ah
                
                cmp dx, 0000h 
                jne @@Set_Data_Shift

                mov bx, 80*25+40                    ;set default coords - center of the screen

                jmp @@End_Data_Shift

@@Set_Data_Shift:

                call Get_Vid_Mem                    ; set window size
 
@@End_Data_Shift:                                   ; start printin

                lodsb
                dec al                              ; don't count last symbol
                mov cl, al

                lodsb

                cmp al, 20h                         ; if (line[0] != ' ') {return;}
                jne @@Finish

@@Write_main_part: 
                lodsb                               ; al = [si++]
                
                cmp al, 0dh                         ; if (line[0] == '\0') {return;}
                je @@Finish

                cmp al, NULL
                je @@Finish
                
                xor ah, ah
                call Check_NL

                cmp ah, 0
                jne @@Loop

                cmp al, COL
                je @@Change_color

                jmp @@Stays_the_same
@@Change_color: 
                push bx cx dx
                call My_Atoh
                xchg al, ah                         ; change color from now on
                mov di, offset @@Color              ; set label ptr
                mov byte ptr cs:[di], ah
                pop dx cx bx
                
                add cx, 2
                jmp @@Loop
@@Stays_the_same:
;===============                                    ; sleep 
                ; push cx dx ax
                ; mov cx, 0001h
                ; mov dx, 0FFFFh
                ; mov ah, 86h
                ; int 15h
                ; pop ax dx cx
;===============
                mov di, offset @@Color              ; set label ptr
                mov ah, cs:[di]
    
                cmp ah, 0
                jne @@Print
                mov ah, 00001111b                   ; set white color - default

@@Print:        mov word ptr es:[bx], ax
                add bx, 2

@@Loop:         loop @@Write_main_part

@@Finish:       ret
@@Color:        db 0
                endp
;------------------------------------------------
