@Set filename=CRACK_ME(1)
@Set input=
@Set execute=%filename%.com
@cls
td %execute%

@del *.lst
@del *.map
@del *.obj

:finish
@exit