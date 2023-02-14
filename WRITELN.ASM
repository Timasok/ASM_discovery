.model tiny
.code
org 100h

Start:	
		    mov bx, 0b800h					    ; write video mem address beginning
            mov si, 00080h                      ; write line address
		    mov es, bx

            mov bx, 80*25                       ; set window size

            lodsb
            dec al
            mov cl, al

            lodsb

            cmp al, 20h                         ; if (line[0] != ' ') {return;}
            jne Finish

Write_name: 
            lodsb                               ; al = [si++]

            mov byte ptr es:[bx], al
            mov byte ptr es:[bx+1], 00001111b
            add bx, 2

            loop Write_name

Finish:     mov ax, 4c00h
            int 21h

end		    Start
