;------------------------------------------------
;Checks for \n 
;------------------------------------------------
;Entry:     AL - symbol
;           BX - current video memory shift
;Exit:      flag changes
;Expects:   AH = 0
;Destroys:  AH
;------------------------------------------------
Check_NL        proc
                mov ah, 26h           ; ah = '&'
                cmp al, ah
                je @@Print_NL

                xor ah, ah            ; if(c != '&') ah = 0        
                jmp @@Finish

@@Print_NL:     add bx, 80d*2           ; bx += screen_width

@@Finish:
                ret
                endp
;------------------------------------------------


;------------------------------------------------
;Write line from cmd arg
;------------------------------------------------
;Entry:     DH - x0 coordinate(0-80)
;           DL - y0 coordinate(0-25)
;Exit:      CX - 
;Expects:   SI is set
;Destroys:  AX, BX, CX, SI
;------------------------------------------------
Write_line      proc
               
                cmp dx, 0000h 
                jne @@Set_Data_Shift

                mov bx, 80*25+40

                jmp @@End_Data_Shift

@@Set_Data_Shift:

                call    Get_Vid_Mem                 ; set window size
 
@@End_Data_Shift:

                lodsb
                dec al                              ; don't count last symbol
                mov cl, al

                lodsb

                cmp al, 20h                         ; if (line[0] != ' ') {return;}
                jne @@Finish

@@Write_name: 
                lodsb                               ; al = [si++]
                
                xor ah, ah
                call Check_NL
                cmp ah, 0
                jne @@Loop

                mov ah, 00001111b                   ; set white color - default

                mov word ptr es:[bx], ax
                add bx, 2

@@Loop:         loop @@Write_name

@@Finish:     
                ret
                endp
;------------------------------------------------
