.model tiny
.code
org 100h
locals @@

Start:          jmp Main                        ; write video mem address beginning

INCLUDE WRITELN.ASM
INCLUDE NUMBER.ASM

Main:
                SET_VID_PTR

                mov ax, 0720h                  ; space, clear screen  
                call ClrScr

                mov dh, 40                      ; x0
                mov dl, 12                      ; y0

                call Get_Vid_Mem
                mov ax, 47
                
                ; call Write_bin

                call Write_hex

                ; call Write_line

                EXIT
end             Start