; task 2 was 
;   -read number from cmd                                                   +
;   -draw frame in the center of the screen                                 +
;   -write number in different number systems inside this frame
;   *add posibility to read to numbers and display results of 
;       arithm operations with them in the same frame

.model tiny
.code
org 100h
locals @@

Start:          jmp Main                        ; write video mem address beginning

INCLUDE BASE.ASM
INCLUDE READ.ASM
INCLUDE WRITE.ASM
INCLUDE CALC.ASM
INCLUDE DRAW.ASM
INCLUDE STRING.ASM

Main:
                push bp
                mov bp, sp

                SET_VID_PTR

                mov cx, 2d                      ; set number of arguments that next function is going to use
                call Read_args
                call Form_arithm
                
                call Print_arithm

                pop bp
                EXIT
end             Start