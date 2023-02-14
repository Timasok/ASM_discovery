.model tiny
.code
org 100h

start:		mov bx, 0b800h			; Video mem segment address
		mov es, bx
		xor bx, bx			; bx = 0
		mov byte ptr es:[bx], 65d 	; mov 'A'
		
		mov ax, 4c00h
		int 21h
end 		start