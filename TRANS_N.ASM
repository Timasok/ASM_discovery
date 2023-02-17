.model tiny
.code
org 100h
locals @@

Start:          jmp Main                        ; write video mem address beginning

INCLUDE WRITELN.ASM

Main:
                SET_VID_PTR

                mov dh, 40                      ; x0
                mov dl, 12                      ; y0

                call Write_line

                EXIT
end             Start