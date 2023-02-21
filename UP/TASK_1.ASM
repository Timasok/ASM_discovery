;################################################
; task 1 was
;   -to read line from cmd and display it in the center of the screen
;   *create analogy to '\n'
;   *add posibility to enter line in given coordinates on the screen
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
                SET_VID_PTR
                SET_CMD_ARG

                mov dx, 220ch
                call Get_Vid_Mem

                ; mov ax, 0720h                  ; space, clear screen  
                ; call ClrScr
                call Write_line

                EXIT
end             Start