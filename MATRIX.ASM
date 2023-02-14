.model tiny
.code
org 100h

Start:	mov bx, 0b800h					; write video mem address beginning
		mov es, bx

Null:	mov bx, 0						; write window size
		
		mov cx, 50						; push First cycle counter
First:	
		push cx							; save First cycle counter

		xor dx, dx
		mov ah, 2ch
		int 21h

		mov cx, 16   					; push Second cycle counter

Second: 

		mov ax, dx						; get lowest word from dx
		and ax, 00001h					; dx = dx & 0001h
		add ax, 00a30h		
	
		push cx							; take first(n-th) word from dx
		mov cl, 1						; shift number in dx left
		shr dx, cl
		pop cx

		mov word ptr es:[bx], ax		; add green '0'
		mov word ptr es:[bx+2], 00020h	; add  ' '

		mov ax, dx						; get lowest word from dx
		and ax, 01h						; dx = dx & 0001h
		add ax, 00a30h

		push cx							; take first(n-th) word from dx
		mov cl, 1						; shift number in dx left
		shr dx, cl
		pop cx

		mov word ptr es:[bx+4], ax		; add green '1'/'0'
		mov word ptr es:[bx+6], 00020h	; add  ' '

		add bx, 8

		loop Second
		
		mov ah, 86h						; sleep(0.1)
		mov cx, 0000h
		mov dx, 2710h
		int 15h

		mov ah, 01h						; finish program by pressing a key
		int 16h
		cmp al, 0
		jne Finish

		pop cx							; revive First cycle counter

		loop First
		jmp Null


Finish: mov ax, 4c00h
		int 21h

end 	Start