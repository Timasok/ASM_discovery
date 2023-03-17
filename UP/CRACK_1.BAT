@Set filename=CRACK_1
@Set input=
@Set execute=%filename%.com

@tasm /la %filename%.asm
@tlink /t %filename%.obj
@cls
%execute%

@del *.lst
@del *.map
@del *.obj

:finish
@exit