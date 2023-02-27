;------------------------------------------------
;Exits to DOS
;------------------------------------------------
;Entry:     None
;Exit:      (Not defined)
;Expects:   Nothing
;Destroys:  AX
;------------------------------------------------
EXIT            macro
                nop
                mov ax, 4c00h
                int 21h
                nop
                endm
;------------------------------------------------

;------------------------------------------------
;Sets vid memory ptr to es
;------------------------------------------------
;Entry:     None
;Exit:      es = 0b800h
;Expects:   Nothing
;Destroys:  BX, ES
;------------------------------------------------
SET_VID_PTR     macro
                nop
		        mov bx, 0b800h					    ; write video mem address beginning
		        mov es, bx
                xor bx, bx
                nop
                endm
;------------------------------------------------

;------------------------------------------------
;Check flag
;------------------------------------------------
;Entry:     AX - all flags saved via command lahf
;           CL - flag number 
;Exit:      CH - flag status
;Expects:   
;Destroys:  CH
;------------------------------------------------
Check_flags     proc
                push ax
                push bx

                mov bx, 1h
                shl bx, cl                      ; get cl-th mask

                and ax, bx                
                shr ax, cl                      ; get in ah right value

                mov ch, al                      ; save result

                pop bx
                pop ax
                ret
                endp
;------------------------------------------------

;------------------------------------------------
;Write coordinates in dx
;------------------------------------------------
;Entry:     p2 - x0 coordinate
;           p1 - y0 coordinate
;Exit:      DH - x0 coordinate(0-80)
;           DL - y0 coordinate(0-25)
;Expects:   
;Destroys:  DX, BP
;------------------------------------------------
Encode_cords    proc
                push bp             ; func's prolog
                mov bp, sp

                mov dh, [bp+6]      ; save x - coord
                mov dl, [bp+4]      ; save y - coord

                pop bp
                retn 4
                endp
;-------------------------------




;------------------------------------------------
;Get video mem address according to cordinates
;------------------------------------------------
;Entry:     DH - x0 coordinate(0-80)
;           DL - y0 coordinate(0-25)
;Exit:      BX - address in RAM
;Expects:   
;           Screen size is 25/80
;Destroys:  AX, BX
;------------------------------------------------
Get_Vid_Mem     proc

                push cx
                push dx                         ; save unchanged coordinates
                sub dx, 0101h                   ; x-=1, y-=1       

                xor ax, ax                      ; set ax = 0
                mov al, dl                      ; ax = y

                push dx                         ; save cordinates

                mov cx, 80d                     ; set window width
                mul cx                          ; ax *= 80

                pop dx                          ; revive cordinates
                
                mov cl, 8d                      ; set 1 byte shift /2^8
                shr dx, cl                      ; dx = x

                add ax, dx                      ; bx += x

                mov cl, 1d                      ; set 1 bit shift *2^1
                shl ax, cl                      ;
                
                mov bx, ax
                pop dx
                pop cx

                ret
                endp
;------------------------------------------------
