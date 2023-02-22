@Set filename=task_1
@Set input=34 12 Say &&&&Ho  
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