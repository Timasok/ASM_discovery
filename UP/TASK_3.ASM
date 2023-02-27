;   task 3 was
;   -give user ability to set frame parameters in the cmd line
;   -make some preset styles so instead of writing ACSII codes of 
;       frame symbols he could just set number of frame style
;   *give ability to write text in the frame
;   *make automatic centration of the frame
;   *make frame move and zoom
; change color in string+hex 

.model tiny
.code
org 100h
locals @@

Start:          jmp Main                        ; write video mem address beginning

INCLUDE BASE.ASM
INCLUDE STRING.ASM
INCLUDE WRITE.ASM
INCLUDE READ.ASM
INCLUDE CALC.ASM
INCLUDE DRAW.ASM

Main:           
                push bp
                mov bp, sp

                SET_VID_PTR
                mov ax, 0720h                   ; space, clear screen  
                call ClrScr
                
                mov cx, 15d                     ; push 15 parameters from cmd line
                call Read_args

                call Draw_frame

                ; push di

                ; call Get_str_params

                ; pop di

                mov dx, di
                add dx, 0202h                   ; set frame shift
                call Write_line

                pop bp
                EXIT
end             Start