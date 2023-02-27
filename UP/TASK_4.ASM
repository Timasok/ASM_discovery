;   task 4 was
; to write my own string functions

.model tiny
.code
org 100h
locals @@

Start:          jmp Main                        ; write video mem address beginning

INCLUDE BASE.ASM
INCLUDE DEF_STR.ASM
INCLUDE STRING.ASM

S2           db 'Hello World!$'                  ; lhs
S1           db 'H$'                             ; rhs

Main:

                mov ax, offset S1
                push ax

                mov ax, offset S2
                push ax

                xor ax, ax
                call strcmp

                EXIT
End             Start