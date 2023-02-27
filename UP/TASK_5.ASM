; task was to set a resident into program

.286
.model tiny
.code
org 100h
locals @@


Start:            
Main:               mov bx, 0b800h
                    mov es, bx              ; set vidmem

                    mov ah, 4eh             ; set color(red)
                    mov bx, 160d*5 + 80d    ; get vid mem - 5th line

Next:               in al, 60h
                    mov word ptr es:[bx], ax ;depict scan code

                    cmp al, 1               ; if(scan == 'esc')break;
                    jne Next

                    mov ax, 4c00h
                    int 21h
end                 Start

