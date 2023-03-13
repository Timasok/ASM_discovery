@Set filename=task_7
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