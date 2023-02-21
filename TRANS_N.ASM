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

                mov dh, 22                      ; x0
                mov dl, 10                      ; y0
                
                call Print_num

                mov dh, 50                      ; x0
                mov dl, 10                      ; y0
                
                call Print_num


                EXIT
end             Start