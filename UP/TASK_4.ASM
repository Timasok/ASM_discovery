;   task 4 was
; to write my own string functions

.model tiny
.code
org 100h
locals @@

Start:          jmp Main                        ; write video mem address beginning

INCLUDE BASE.ASM
INCLUDE STRING.ASM

S1          db 'HELLO WORLD!$'
S2          db 'FUCK THE WORLD!$'

Main:

                lea si, S1
                lea di, S2
                call My_cmpsw

                EXIT
End             Start