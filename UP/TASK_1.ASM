;################################################
; task 1 was
;   -to read line from cmd and display it in the center of the screen           +
;   *create analogy to '\n' - '&'                                               +                                                 
;   *add posibility to enter line in given coordinates on the screen            +
;################################################

.model tiny
.code
org 100h
locals @@

Start:          jmp Main                        ; write video mem address beginning

INCLUDE BASE.ASM
INCLUDE READ.ASM
INCLUDE WRITE.ASM
; INCLUDE DRAW.ASM

Main:
                push bp
                mov bp, si

                SET_VID_PTR
                SET_CMD_ARG

                call My_Atoi                    ; get x coordinate from cmd line, and shift si
                push ax                         ; x coordinate set, 

                call My_Atoi                    ; get y coordinate from cmd line, and shift si
                push ax                         ; save y coordinate

                call Encode_cords               ; as a result we have coords in dx

                pop ax                          ; clear stack
                pop ax

                call Write_line

                pop bp
                EXIT
end             Start