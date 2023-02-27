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
;Exit:      
;Expects:   SI is set
;Destroys:  AX, BX, CX, SI
;------------------------------------------------
Write_line      proc
               
                cmp dx, 0000h 
                jne @@Set_Data_Shift

                mov bx, 80*25+40                    ;set default coords - center of the screen

                jmp @@End_Data_Shift

@@Set_Data_Shift:

                call Get_Vid_Mem                    ; set window size
 
@@End_Data_Shift:

                lodsb
                dec al                              ; don't count last symbol
                mov cl, al

                lodsb

                cmp al, 20h                         ; if (line[0] != ' ') {return;}
                jne @@Finish

@@Write_main_part: 
                lodsb                               ; al = [si++]
                
                cmp al, 0dh                         ; if (line[0] == 13) {return;}
                je @@Finish
                cmp al, NULL
                je @@Finish
                
                xor ah, ah
                call Check_NL
                cmp ah, 0
                jne @@Loop

;===============                                    ; sleep 
                push cx
                push dx
                push ax
                mov cx, 0001h
                mov dx, 0FFFFh
                mov ah, 86h
                int 15h
                pop ax
                pop dx
                pop cx
;===============
                
                mov ah, 00001111b                   ; set white color - default
                mov word ptr es:[bx], ax
                add bx, 2

@@Loop:         loop @@Write_main_part

@@Finish:     
                ret
                endp
;------------------------------------------------
