@Set filename=task_3
@Set input=36 8 40 5 12 5 188 205 200 186 20 186 187 205 201 
@Set execute=%filename%.com %input%

@tasm /la %filename%.asm
@tlink /t %filename%.obj
@cls

@REM       x  y w h co st
task_3.com 36 8 40 5 12 5 188 205 200 186 20 186 187 205 201 
PAUSE
task_3.com 15 5 40 5 12 5 3 3 3 3 20 3 3 3 3 I want to congratulate&all dames with 8 march!

@echo Open debugger?

@CHOICE
@if ERRORLEVEL == 2 goto clear
@echo
:debug
td task_3.com 15 5 40 5 12 5 3 3 3 3 20 3 3 3 3 I want to congratulate&all dames with 8 march!
@REM td %execute%

@goto finish

:clear

@CLEAR.BAT

:finish
@exit