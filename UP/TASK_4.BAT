@Set filename=task_4
@Set input=
@Set execute=%filename%.com %input%

@tasm /la %filename%.asm
@tlink /t %filename%.obj
@cls
%execute%
@echo Open debugger?

@CHOICE
@if ERRORLEVEL == 2 goto clear
@echo
:debug
td %execute%

@goto finish

:clear

@CLEAR.BAT

:finish
@exit