@Set filename=TSR_2
@Set execute=%filename%.com

@tasm /la %filename%.asm
@tlink /t %filename%.obj
@cls
@echo Run with debugger?

@CHOICE
@if ERRORLEVEL == 2 goto clear
@echo
:debug
td %execute%

@goto finish

:clear

%execute%
@CLEAR.BAT

:finish
@exit