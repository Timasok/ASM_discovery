.model tiny
.code
org 100h
locals @@

Start:  
        mov bx, 0b800h
        mov es, bx

        xor bx, bx

        mov ax, 8a41h

        mov word ptr es:[bx], ax

        mov ax, 4c00h
		int 21h

end 	Start