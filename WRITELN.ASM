INCLUDE FUNCS.ASM

;------------------------------------------------
;Write line from cmd arg
;------------------------------------------------
;Entry:     DH - x0 coordinate(0-80)
;           DL - y0 coordinate(0-25)
;Exit:      ES = 0b800h
;           SI = 00080h
;Expects:   Nothing
;Destroys:  AX, BX, CX
;------------------------------------------------
Write_line      proc

                mov si, 0080h                      ; write line address

                cmp dx, 0000h 
                jne @@Set_Data_Shift

                mov bx, 80*25+40

                jmp @@End_Data_Shift

@@Set_Data_Shift:
        
                call    Get_Vid_Mem                    ; set window size

@@End_Data_Shift:

                lodsb
                dec al                              ; don't count last symbol
                mov cl, al

                lodsb

                cmp al, 20h                         ; if (line[0] != ' ') {return;}
                jne @@Finish

@@Write_name: 
                lodsb                               ; al = [si++]
                
                mov ah, 00001111b                  ; set white color - default

                mov word ptr es:[bx], ax
                add bx, 2

                loop @@Write_name

@@Finish:     
                ret
                endp
;------------------------------------------------
