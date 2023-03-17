;################################################
; task 1 was
;   -to read line from cmd and display it in the center of the screen           +
;   *create analogy to '\n' - '&'                                               +                                                 
;   *add posibility to enter line in given coordinates on the screen            +
;################################################

.model tiny
.code
.286
org 100h
locals @@

Start:          jmp Main                        ; write video mem address beginning

INCLUDE BASE.ASM
INCLUDE READ.ASM
INCLUDE WRITE.ASM
INCLUDE STRING.ASM
; INCLUDE DRAW.ASM

str1          db 0ffh, ' HELLO_BRUH!', 00dh    ; string for further print(should contain max length, ' ', 0dh)

Main:
                push bp
                mov bp, si

                ; xor ax, ax

                SET_VID_PTR

                mov cx, 2d                      ; set number of arguments that next function is going to use
                call Read_args
                call Encode_cords               ; as a result we have coords in dx

                mov ah, 00101111b
                call Write_line

                push offset str1
                call Write_string
                
                pop bp
PASS:
                EXIT
end             Start
