.model tiny
.code
org 100h
locals @@

Start:          jmp Main                        ; write video mem address beginning

INCLUDE FUNCS.ASM

Main:           
                push bp                         ; save start of parameters of inner funcs

                mov bx, 0b800h
                mov es, bx

                mov ax, 0720h                   ; space, clear screen  
                call ClrScr

                xor ax, ax
                xor bx, bx
                xor cx, cx

                mov dx, 14h                     ;p15 - left top x coordinate
                push dx
                
                mov dx, 08h                     ;p14 - left top y coordinate
                push dx                

                mov ax, 0028h                   ; p13 - frame width
                push ax

                mov ax, 0005h                   ; p12 - frame height
                push ax                         

                mov ax, 000ch                   ; p11 - frame color(black and yellow)
                push ax

                mov ax, 5d                      ; p10 - frame style
                push ax

                mov ax, 00bch                   ; p9  - right  bottom   symbol         
                push ax

                mov ax, 00cdh                   ; p8  - middle bottom   symbol
                push ax

                mov ax, 00c8h                   ; p7  - left   bottom   symbol
                push ax

                mov ax, 00bah                   ; p6  - right  central  symbol         
                push ax

                push 0                          ; p5  - middle central  symbol

                mov ax, 00bah                   ; p4  - left   central  symbol
                push ax

                mov ax, 00bbh                   ; p3  - right  top      symbol         
                push ax

                mov ax, 00cdh                   ; p2  - middle top      symbol
                push ax

                mov ax, 00c9h                   ; p1  - left   top      symbol
                push ax

                call Draw_frame

                pop bp

                EXIT
end             Start